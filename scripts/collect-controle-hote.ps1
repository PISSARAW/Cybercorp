[CmdletBinding()]
param([Parameter(Mandatory = $true)][string]$OutputPath)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
Import-Module Hyper-V -ErrorAction Stop
if (Test-Path -LiteralPath $OutputPath) { throw "Fichier existant : $OutputPath" }
$os = Get-CimInstance Win32_OperatingSystem
$vms = @(Get-VM | Where-Object Name -like 'CC-*' | Sort-Object Name)
$snapshot = [ordered]@{
    captured_utc = [DateTime]::UtcNow.ToString('o')
    source = $env:COMPUTERNAME
    free_memory_gib = [Math]::Round($os.FreePhysicalMemory / 1MB, 3)
    vms = @($vms | ForEach-Object {
        [ordered]@{
            name = $_.Name
            state = [string]$_.State
            memory_assigned_bytes = $_.MemoryAssigned
            memory_startup_bytes = $_.MemoryStartup
            adapters = @(Get-VMNetworkAdapter -VMName $_.Name | ForEach-Object {
                [ordered]@{
                    name = $_.Name
                    switch = $_.SwitchName
                    connected = [bool]$_.Connected
                    mac = $_.MacAddress
                }
            })
        }
    })
}
$json = $snapshot | ConvertTo-Json -Depth 8
$bytes = [Text.UTF8Encoding]::new($false).GetBytes($json + [Environment]::NewLine)
$stream = [IO.File]::Open($OutputPath, [IO.FileMode]::CreateNew, [IO.FileAccess]::Write)
try { $stream.Write($bytes, 0, $bytes.Length) } finally { $stream.Dispose() }
Get-Item -LiteralPath $OutputPath | Select-Object FullName, Length
