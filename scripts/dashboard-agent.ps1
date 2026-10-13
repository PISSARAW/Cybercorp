$ErrorActionPreference = 'Stop'
$dataDir = Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) 'CyberCorp'
$log = Join-Path $dataDir 'collector-last-run.log'
$mutex = New-Object System.Threading.Mutex($false, 'Local\CyberCorpDashboardCollector')
if (-not $mutex.WaitOne(0)) { exit 0 }
try {
    while ($true) {
        try {
            $result = & (Join-Path $PSScriptRoot 'collect-dashboard.ps1')
            "$(Get-Date -Format o) OK $result" | Set-Content -LiteralPath $log -Encoding utf8
        } catch {
            "$(Get-Date -Format o) ERREUR $($_.Exception.Message)" | Set-Content -LiteralPath $log -Encoding utf8
        }
        Start-Sleep -Seconds 300
    }
} finally {
    $mutex.ReleaseMutex()
    $mutex.Dispose()
}
