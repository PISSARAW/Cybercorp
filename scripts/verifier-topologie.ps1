[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Topologie,

    [Parameter(Mandatory = $true)]
    [string]$DossierRapport,

    [string]$Conftest = (Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) 'CyberCorp\tools\conftest\0.71.1\conftest.exe')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$racineProjet = Split-Path -Parent $PSScriptRoot
$politique = Join-Path $racineProjet 'policy\topology.rego'
$dossierPolitique = Split-Path -Parent $politique
$cas = @(
    [pscustomobject]@{ nom = 'reel'; fichier = $Topologie; attendu = 'PASS' }
    [pscustomobject]@{ nom = 'switch-externe-interdit'; fichier = (Join-Path $racineProjet 'tests\topology\audit-switch-externe-interdit.json'); attendu = 'FAIL' }
    [pscustomobject]@{ nom = 'kali-bridge-interdit'; fichier = (Join-Path $racineProjet 'tests\topology\audit-kali-bridge-interdit.json'); attendu = 'FAIL' }
    [pscustomobject]@{ nom = 'wan-rebranche-interdit'; fichier = (Join-Path $racineProjet 'tests\topology\audit-wan-rebranche-interdit.json'); attendu = 'FAIL' }
    [pscustomobject]@{ nom = 'inventaire-incomplet'; fichier = (Join-Path $racineProjet 'tests\topology\audit-inventaire-incomplet.json'); attendu = 'FAIL' }
    [pscustomobject]@{ nom = 'champ-manquant'; fichier = (Join-Path $racineProjet 'tests\topology\audit-champ-manquant.json'); attendu = 'FAIL' }
)

if (-not (Test-Path -LiteralPath $Conftest -PathType Leaf)) { throw "Conftest introuvable : $Conftest" }
if (-not (Test-Path -LiteralPath $DossierRapport -PathType Container)) { throw "Dossier absent : $DossierRapport" }
foreach ($test in $cas) {
    if (-not (Test-Path -LiteralPath $test.fichier -PathType Leaf)) { throw "Entrée absente : $($test.fichier)" }
}

$version = (& $Conftest --version) -join '; '
if ($LASTEXITCODE -ne 0) { throw 'Impossible de lire la version de Conftest.' }
$resultats = @(
    foreach ($test in $cas) {
        $fichier = (Resolve-Path -LiteralPath $test.fichier).Path
        $sortie = (& $Conftest test --policy $dossierPolitique --namespace cybercorp.topology --output json $fichier 2>&1) -join [Environment]::NewLine
        $code = $LASTEXITCODE
        if ($sortie -notmatch '^\s*\[') { throw "Sortie Conftest non JSON pour $($test.nom) : $sortie" }
        $analyse = @($sortie | ConvertFrom-Json)
        $tests = @($analyse | Measure-Object -Property successes -Sum)[0].Sum
        $echecs = @($analyse | ForEach-Object { if ($_.PSObject.Properties['failures']) { $_.failures } })
        if ($tests -le 0) { throw "Aucune règle exécutée pour $($test.nom)." }
        $obtenu = if ($code -eq 0 -and $echecs.Count -eq 0) { 'PASS' } elseif ($code -eq 1 -and $echecs.Count -gt 0) { 'FAIL' } else { 'ERREUR' }
        [ordered]@{
            cas = $test.nom
            entree = $fichier
            sha256_entree = (Get-FileHash -LiteralPath $fichier -Algorithm SHA256).Hash
            resultat_attendu = $test.attendu
            resultat_obtenu = $obtenu
            code_sortie = $code
            regles_executees = $tests + $echecs.Count
            echecs = @($echecs | ForEach-Object { $_.msg })
        }
    }
)

$rapport = [ordered]@{
    mission = 'M-CLIENT-01'
    controle = 'M02 - Conftest V01-V05'
    execute_utc = [DateTime]::UtcNow.ToString('o')
    version = $version
    politique = (Resolve-Path -LiteralPath $politique).Path
    sha256_politique = (Get-FileHash -LiteralPath $politique -Algorithm SHA256).Hash
    commande = 'conftest test --policy policy --namespace cybercorp.topology --output json <entree>'
    resultats = $resultats
}
$nom = 'M-CLIENT-01_M02_Conftest_' + [DateTime]::UtcNow.ToString('yyyyMMddTHHmmssfffZ') + '.json'
$destination = Join-Path $DossierRapport $nom
if (Test-Path -LiteralPath $destination) { throw "Rapport déjà présent : $destination" }
$json = $rapport | ConvertTo-Json -Depth 10
[System.IO.File]::WriteAllText($destination, $json + [Environment]::NewLine, [System.Text.UTF8Encoding]::new($false))

$nonConformes = @($resultats | Where-Object { $_.resultat_obtenu -ne $_.resultat_attendu })
[pscustomobject]@{
    Rapport = $destination
    SHA256 = (Get-FileHash -LiteralPath $destination -Algorithm SHA256).Hash
    Conforme = ($nonConformes.Count -eq 0)
    Resultats = $resultats
}
if ($nonConformes.Count -gt 0) { throw 'Le contrôle réel ou un des tests négatifs ne donne pas le résultat attendu.' }
