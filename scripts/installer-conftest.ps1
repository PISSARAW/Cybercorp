[CmdletBinding()]
param(
    [string]$DossierInstallation = (Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) 'CyberCorp\tools\conftest\0.71.1'),

    # Permet une installation hors ligne depuis la meme archive officielle.
    [string]$Archive
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$versionAttendue = '0.71.1'
$sha256Attendu = '34d623334b5e7ed4465bf62a4cb3b092684859cd3d224bbd390925a0852b922a'
$url = 'https://github.com/open-policy-agent/conftest/releases/download/v0.71.1/conftest_0.71.1_Windows_x86_64.zip'
$destination = Join-Path ([System.IO.Path]::GetFullPath($DossierInstallation)) 'conftest.exe'

function Assert-ConftestVersion([string]$Chemin) {
    $sortie = (& $Chemin --version) -join [Environment]::NewLine
    if ($LASTEXITCODE -ne 0 -or $sortie -notmatch '(?m)^Conftest: 0\.71\.1\r?$') {
        throw "Version Conftest inattendue dans $Chemin (attendu : $versionAttendue) : $sortie"
    }
}

if (Test-Path -LiteralPath $destination -PathType Leaf) {
    Assert-ConftestVersion $destination
    return [pscustomobject]@{ Conftest = $destination; Version = $versionAttendue; Installe = $false }
}

$archiveTemporaire = $null
$executableTemporaire = Join-Path ([System.IO.Path]::GetTempPath()) ([guid]::NewGuid().ToString('N') + '.exe')
$protocoleInitial = [Net.ServicePointManager]::SecurityProtocol
try {
    if ([string]::IsNullOrWhiteSpace($Archive)) {
        $archiveTemporaire = Join-Path ([System.IO.Path]::GetTempPath()) ([guid]::NewGuid().ToString('N') + '.zip')
        $Archive = $archiveTemporaire
        [Net.ServicePointManager]::SecurityProtocol = $protocoleInitial -bor [Net.SecurityProtocolType]::Tls12
        Write-Verbose "Telechargement de $url"
        Invoke-WebRequest -Uri $url -OutFile $Archive -UseBasicParsing
    }

    $empreinte = (Get-FileHash -LiteralPath $Archive -Algorithm SHA256).Hash
    if ($empreinte -ne $sha256Attendu) {
        throw "SHA-256 incorrect pour l'archive Conftest : $empreinte (attendu : $sha256Attendu). Installation annulee."
    }

    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $zip = [System.IO.Compression.ZipFile]::OpenRead((Resolve-Path -LiteralPath $Archive).Path)
    try {
        $entree = $zip.GetEntry('conftest.exe')
        if ($null -eq $entree) { throw 'Archive Conftest sans conftest.exe.' }
        [System.IO.Compression.ZipFileExtensions]::ExtractToFile($entree, $executableTemporaire)
    }
    finally { $zip.Dispose() }

    Assert-ConftestVersion $executableTemporaire
    [System.IO.Directory]::CreateDirectory((Split-Path -Parent $destination)) | Out-Null
    # Ne pas remplacer une installation apparue pendant le telechargement.
    [System.IO.File]::Move($executableTemporaire, $destination)
    [pscustomobject]@{ Conftest = $destination; Version = $versionAttendue; Installe = $true }
}
finally {
    [Net.ServicePointManager]::SecurityProtocol = $protocoleInitial
    if (Test-Path -LiteralPath $executableTemporaire -PathType Leaf) {
        Remove-Item -LiteralPath $executableTemporaire
    }
    if ($archiveTemporaire -and (Test-Path -LiteralPath $archiveTemporaire -PathType Leaf)) {
        Remove-Item -LiteralPath $archiveTemporaire
    }
}
