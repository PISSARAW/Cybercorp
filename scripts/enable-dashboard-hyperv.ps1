$ErrorActionPreference = 'Stop'
$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = [Security.Principal.WindowsPrincipal]::new($identity)
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw 'Exécuter ce script dans une session PowerShell élevée.'
}

$agentPath = Join-Path $PSScriptRoot 'dashboard-agent.ps1'
$pwshPath = (Get-Command pwsh -ErrorAction Stop).Source
$dataDir = Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) 'CyberCorp'
$installLog = Join-Path $dataDir 'dashboard-hyperv-install.log'
$collectorLog = Join-Path $dataDir 'collector-last-run.log'
$runKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run'
New-Item -ItemType Directory -Path $dataDir -Force | Out-Null

try {
    Get-VM -ErrorAction Stop | Out-Null
    $switches = @(Get-VMSwitch -ErrorAction Stop)

    $member = @(Get-LocalGroupMember -SID 'S-1-5-32-578' | Where-Object { $_.SID.Value -eq $identity.User.Value })
    if (-not $member) { Add-LocalGroupMember -SID 'S-1-5-32-578' -Member $identity.User.Value }

    # The elevated agent provides an immediate reading. Group membership applies to new
    # logon tokens, so the regular HKCU startup takes over after the next sign-in.
    $oldAgents = @(Get-CimInstance Win32_Process -Filter "Name = 'pwsh.exe'" | Where-Object {
        $_.CommandLine -and $_.CommandLine.Contains($agentPath) -and $_.ProcessId -ne $PID
    })
    foreach ($oldAgent in $oldAgents) { Stop-Process -Id $oldAgent.ProcessId -Force -ErrorAction Stop }

    Unregister-ScheduledTask -TaskName 'CyberCorpDashboardCollector' -Confirm:$false -ErrorAction SilentlyContinue
    $runCommand = '"{0}" -NoProfile -WindowStyle Hidden -File "{1}"' -f $pwshPath, $agentPath
    Set-ItemProperty -Path $runKey -Name 'CyberCorpDashboardCollector' -Value $runCommand

    $startedAt = Get-Date
    $agent = Start-Process -FilePath $pwshPath -ArgumentList @('-NoProfile', '-WindowStyle', 'Hidden', '-File', ('"' + $agentPath + '"')) -WindowStyle Hidden -PassThru
    Start-Sleep -Seconds 10
    if ($agent.HasExited) { throw "L'agent s'est arrêté (code $($agent.ExitCode))." }
    if (-not (Test-Path -LiteralPath $collectorLog)) { throw 'Aucun relevé du nouvel agent.' }
    $collectorRecord = Get-Item -LiteralPath $collectorLog
    $collectorStatus = Get-Content -LiteralPath $collectorLog -Raw -Encoding utf8
    if ($collectorRecord.LastWriteTime -lt $startedAt -or $collectorStatus -notmatch 'Hyper-V : ok') {
        throw "Le nouvel agent n'a pas produit de relevé Hyper-V complet : $collectorStatus"
    }
    $message = "$(Get-Date -Format o) OK Agent élevé PID=$($agent.Id) ; commutateurs Hyper-V visibles : $($switches.Count). $collectorStatus"
    $message | Set-Content -LiteralPath $installLog -Encoding utf8
    Write-Output $message
} catch {
    "$(Get-Date -Format o) ERREUR $($_.Exception.Message)" | Set-Content -LiteralPath $installLog -Encoding utf8
    throw
}
