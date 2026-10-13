param(
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$secretFile = Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) 'CyberCorp\dashboard-collector.dpapi.json'
$siteUrl = 'https://cybercorp-vitrine.fabled-haven-3189.chatgpt.site'
$allowedVMs = @('CC-PFS01', 'CC-DC01', 'CC-W11-01', 'CC-KALI01', 'PFSENSE01', 'DC01', 'CLIENT01')
$allowedSwitches = @('CC-LAN', 'CC-AUDIT', 'CC-WAN-MAINT', 'LAB-AD')

function Read-Secret([string]$encrypted) {
    $secure = ConvertTo-SecureString $encrypted
    $pointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
    try { return [Runtime.InteropServices.Marshal]::PtrToStringBSTR($pointer) }
    finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($pointer) }
}

$memory = Get-CimInstance Win32_OperatingSystem
$availableGb = [math]::Round([double]$memory.FreePhysicalMemory / 1MB, 2)
$vmItems = @()
$switchItems = @()
$hypervState = 'ok'
try {
    $vmItems = @(Get-VM -ErrorAction Stop | Where-Object { $_.Name -in $allowedVMs } | ForEach-Object {
        $vm = $_
        $checkpointCount = @(Get-VMSnapshot -VMName $vm.Name -ErrorAction SilentlyContinue).Count
        [ordered]@{
            name = $vm.Name
            state = [string]$vm.State
            memory_mb = [math]::Round([double]$vm.MemoryAssigned / 1MB)
            checkpoints = $checkpointCount
        }
    })
    $switchItems = @(Get-VMSwitch -ErrorAction Stop | Where-Object { $_.Name -in $allowedSwitches } | ForEach-Object {
        [ordered]@{ name = $_.Name; type = [string]$_.SwitchType }
    })
} catch {
    $hypervState = if ($_.Exception.Message -match 'autorisation|permission|access|privilege') { 'access_denied' } else { 'error' }
    $vmItems = @()
    $switchItems = @()
}

$steps = @()
$journal = Join-Path $repoRoot 'docs\journal-deploiement.md'
if (Test-Path -LiteralPath $journal) {
    foreach ($line in Get-Content -LiteralPath $journal -Encoding utf8) {
        if ($line -match '^\|\s*(\d{1,2})\s*\|\s*([^|]+?)\s*\|\s*(Validée|En cours|À faire|Bloquée)\s*\|\s*$') {
            $steps += [ordered]@{ number = [int]$Matches[1]; title = $Matches[2].Trim(); status = $Matches[3] }
        }
    }
}

$testPassed = 0
$testsFile = Join-Path $repoRoot 'config\recette.csv'
if (Test-Path -LiteralPath $testsFile) {
    $testPassed = @(Import-Csv -LiteralPath $testsFile | Where-Object { $_.statut -eq 'Validé' }).Count
}

$snapshot = [ordered]@{
    schema = 1
    collected_at = (Get-Date).ToUniversalTime().ToString('o')
    collection = [ordered]@{ hyperv = $hypervState }
    host = [ordered]@{ memory_available_gb = $availableGb }
    vms = $vmItems
    switches = $switchItems
    project = [ordered]@{ steps = $steps; tests = [ordered]@{ total = 15; passed = $testPassed } }
}
$payload = ConvertTo-Json -InputObject $snapshot -Depth 6 -Compress

if ($DryRun) {
    $payload
    return
}

if (-not (Test-Path -LiteralPath $secretFile)) { throw "Secrets du collecteur absents : $secretFile" }
$protected = Get-Content -LiteralPath $secretFile -Raw -Encoding utf8 | ConvertFrom-Json
$collectorKey = Read-Secret $protected.collector_key
$serviceToken = Read-Secret $protected.site_service_token
try {
    $headers = @{
        'x-cybercorp-collector-key' = $collectorKey
        'OAI-Sites-Authorization' = "Bearer $serviceToken"
    }
    try {
        $result = Invoke-RestMethod -Uri "$siteUrl/api/telemetry" -Method Post -ContentType 'application/json; charset=utf-8' -Headers $headers -Body ([Text.Encoding]::UTF8.GetBytes($payload)) -TimeoutSec 20
    } catch {
        $detail = $_.ErrorDetails.Message
        throw "Envoi du relevé refusé : $($_.Exception.Message) $detail"
    }
    if (-not $result.accepted) { throw 'Relevé non accepté par le site.' }
    $published = Invoke-RestMethod -Uri "$siteUrl/api/status" -Method Get -Headers @{ 'OAI-Sites-Authorization' = "Bearer $serviceToken" } -TimeoutSec 20
    if ([math]::Abs((([datetime]$published.collected_at).ToUniversalTime() - ([datetime]$snapshot.collected_at).ToUniversalTime()).TotalSeconds) -gt 1) {
        throw 'Le relevé envoyé ne correspond pas au dernier relevé visible sur le site.'
    }
    Write-Output "Relevé envoyé : $($snapshot.collected_at) ; Hyper-V : $hypervState"
} finally {
    $collectorKey = $null
    $serviceToken = $null
    $headers = $null
}
