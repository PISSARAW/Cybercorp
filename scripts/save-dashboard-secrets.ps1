$ErrorActionPreference = 'Stop'
$collectorKey = Read-Host 'Clé du collecteur' -AsSecureString
$siteServiceToken = Read-Host 'Jeton de service Sites' -AsSecureString
$directory = Join-Path $env:LOCALAPPDATA 'CyberCorp'
New-Item -ItemType Directory -Path $directory -Force | Out-Null
$file = Join-Path $directory 'dashboard-collector.dpapi.json'
if (Test-Path -LiteralPath $file) { throw "Fichier déjà présent : $file" }
$protected = [ordered]@{
    collector_key = ConvertFrom-SecureString $collectorKey
    site_service_token = ConvertFrom-SecureString $siteServiceToken
}
$protected | ConvertTo-Json | Set-Content -LiteralPath $file -Encoding utf8 -NoNewline
Write-Output "Secrets du collecteur protégés pour le compte Windows courant : $file"
