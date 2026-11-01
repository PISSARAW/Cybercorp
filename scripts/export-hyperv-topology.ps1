[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$OutputPath,

    [ValidateSet('audit')]
    [string]$Profile = 'audit'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module Hyper-V -ErrorAction Stop

$expectedSwitches = @('CC-LAN', 'CC-AUDIT', 'CC-WAN-MAINT')
$allVms = @(Get-VM -ErrorAction Stop)
$selectedVms = @($allVms | Where-Object { $_.Name -like 'CC-*' } | Sort-Object Name)
$allSwitches = @(Get-VMSwitch -ErrorAction Stop)
$vmRecords = @(
    foreach ($vm in $selectedVms) {
        $adapters = @(
            Get-VMNetworkAdapter -VMName $vm.Name -ErrorAction Stop |
                Sort-Object SwitchName, Name |
                ForEach-Object {
                    [ordered]@{
                        switch = if ([string]::IsNullOrWhiteSpace($_.SwitchName)) { $null } else { [string]$_.SwitchName }
                        connected = [bool]$_.Connected
                    }
                }
        )
        [ordered]@{
            name = [string]$vm.Name
            adapters = $adapters
        }
    }
)

$referencedSwitches = @($vmRecords | ForEach-Object { $_.adapters } | Where-Object { $_.switch } | ForEach-Object { $_.switch })
$cyberCorpSwitches = @($allSwitches | Where-Object { $_.Name -like 'CC-*' } | ForEach-Object { $_.Name })
$switchNames = @($expectedSwitches + $referencedSwitches + $cyberCorpSwitches | Sort-Object -Unique)
$switchRecords = @(
    foreach ($name in $switchNames) {
        $match = @($allSwitches | Where-Object Name -eq $name)
        if ($match.Count -eq 1) {
            [ordered]@{ name = $name; type = [string]$match[0].SwitchType }
        }
    }
)

$snapshot = [ordered]@{
    schema_version = 1
    profile = $Profile
    captured_utc = [DateTime]::UtcNow.ToString('o')
    switches = $switchRecords
    vms = $vmRecords
}

$target = [System.IO.Path]::GetFullPath($OutputPath)
if (Test-Path -LiteralPath $target) {
    throw "Le fichier existe déjà : $target"
}
$parent = [System.IO.Path]::GetDirectoryName($target)
if (-not (Test-Path -LiteralPath $parent -PathType Container)) {
    throw "Dossier de destination absent : $parent"
}

$json = $snapshot | ConvertTo-Json -Depth 8
[System.IO.File]::WriteAllText($target, $json + [Environment]::NewLine, [System.Text.UTF8Encoding]::new($false))
$hash = (Get-FileHash -LiteralPath $target -Algorithm SHA256).Hash
[pscustomobject]@{ Path = $target; SHA256 = $hash; CapturedUtc = $snapshot.captured_utc }
