$ErrorActionPreference = 'Stop'
$dataDir = Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) 'CyberCorp'
$log = Join-Path $dataDir 'collector-last-run.log'
$startupLog = Join-Path $dataDir 'collector-startup.log'
trap {
    "$(Get-Date -Format o) ERREUR $($_ | Out-String)" | Set-Content -LiteralPath $startupLog -Encoding utf8
    break
}
"$(Get-Date -Format o) Démarrage PID=$PID identité=$([Security.Principal.WindowsIdentity]::GetCurrent().Name)" | Set-Content -LiteralPath $startupLog -Encoding utf8
$mutex = New-Object System.Threading.Mutex($false, 'Local\CyberCorpDashboardCollector')
$ownsMutex = $false
try {
    try { $ownsMutex = $mutex.WaitOne(0) }
    catch [System.Threading.AbandonedMutexException] { $ownsMutex = $true }
    if (-not $ownsMutex) {
        "$(Get-Date -Format o) Un autre agent détient le mutex." | Add-Content -LiteralPath $startupLog -Encoding utf8
        exit 0
    }
    "$(Get-Date -Format o) Mutex acquis." | Add-Content -LiteralPath $startupLog -Encoding utf8
    while ($true) {
        try {
            $result = & (Join-Path $PSScriptRoot 'collect-dashboard.ps1')
            "$(Get-Date -Format o) OK $result" | Set-Content -LiteralPath $log -Encoding utf8
        } catch {
            "$(Get-Date -Format o) ERREUR $($_.Exception.Message)" | Set-Content -LiteralPath $log -Encoding utf8
        }
        Start-Sleep -Seconds 20
    }
} finally {
    if ($ownsMutex) { $mutex.ReleaseMutex() }
    $mutex.Dispose()
}
