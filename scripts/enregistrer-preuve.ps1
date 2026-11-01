[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Fichier,

    [ValidatePattern('^[A-Za-z0-9-]{3,40}$')]
    [string]$Dossier = 'M-CLIENT-01',

    [Parameter(Mandatory = $true)]
    [ValidateSet('avant', 'ouvert', 'apres', 'topologie', 'gpo', 'poste', 'analyse', 'autre')]
    [string]$Etape,

    [Parameter(Mandatory = $true)]
    [string]$Source,

    [Parameter(Mandatory = $true)]
    [string]$Outil,

    [Parameter(Mandatory = $true)]
    [string]$Action,

    [string]$EvenementUtc,

    [ValidateSet('Brut', 'ExtraitExpurge')]
    [string]$Type = 'Brut',

    [string]$RelecteurExpurgation
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function ConvertTo-Token {
    param([string]$Value)
    $token = ($Value -replace '[^A-Za-z0-9_-]', '-') -replace '-+', '-'
    $token = $token.Trim('-')
    if ([string]::IsNullOrWhiteSpace($token)) {
        throw "Identifiant vide après normalisation : $Value"
    }
    return $token
}

if (-not (Test-Path -LiteralPath $Fichier -PathType Leaf)) {
    throw "Fichier introuvable : $Fichier"
}
if ([string]::IsNullOrWhiteSpace($Action)) {
    throw 'Décrire la commande ou la tâche réalisée dans -Action.'
}
if ($Type -eq 'ExtraitExpurge' -and [string]::IsNullOrWhiteSpace($RelecteurExpurgation)) {
    throw 'Un extrait exige le nom du relecteur dans -RelecteurExpurgation.'
}

$evenementNormalise = ''
if (-not [string]::IsNullOrWhiteSpace($EvenementUtc)) {
    if ($EvenementUtc -notmatch '(Z|[+-][0-9]{2}:[0-9]{2})$') {
        throw 'Indiquer un fuseau explicite dans -EvenementUtc (Z ou +/-HH:MM).'
    }
    $dateEvenement = [DateTimeOffset]::Parse(
        $EvenementUtc,
        [System.Globalization.CultureInfo]::InvariantCulture
    )
    $evenementNormalise = $dateEvenement.UtcDateTime.ToString('o')
}

$racine = Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) 'CyberCorp\preuves'
if (-not (Test-Path -LiteralPath $racine -PathType Container)) {
    throw "Coffre absent : $racine. Créer et protéger le dossier avant toute collecte."
}
$racine = (Resolve-Path -LiteralPath $racine).Path
if (-not (Get-Acl -LiteralPath $racine).AreAccessRulesProtected) {
    throw "Les droits du coffre héritent encore du parent : $racine"
}

$cheminSource = (Resolve-Path -LiteralPath $Fichier).Path
$empreinteSource = (Get-FileHash -LiteralPath $cheminSource -Algorithm SHA256).Hash
$dossierCas = Join-Path $racine $Dossier
if (-not (Test-Path -LiteralPath $dossierCas -PathType Container)) {
    throw "Dossier de mandat absent : $dossierCas"
}
$sousDossier = if ($Type -eq 'Brut') { 'brut' } else { 'extraits-expurges' }
$destinationDossier = Join-Path $dossierCas $sousDossier
if (-not (Test-Path -LiteralPath $destinationDossier -PathType Container)) {
    throw "Dossier de destination absent : $destinationDossier"
}

$horodatage = [DateTime]::UtcNow.ToString('yyyyMMddTHHmmssfffZ')
$id = '{0}_{1}_{2}_{3}_{4}' -f $Dossier, $Etape, $horodatage, (ConvertTo-Token $Source), (ConvertTo-Token $Outil)
$extension = [System.IO.Path]::GetExtension($cheminSource).ToLowerInvariant()
$nom = $id + $extension
$destination = Join-Path $destinationDossier $nom
[System.IO.File]::Copy($cheminSource, $destination, $false)

$empreinteCopie = (Get-FileHash -LiteralPath $destination -Algorithm SHA256).Hash
if ($empreinteCopie -ne $empreinteSource) {
    throw "Empreinte différente après copie : $destination. Ne pas utiliser cette pièce."
}

$piece = Get-Item -LiteralPath $destination
$enregistrement = [pscustomobject]@{
    id = $id
    dossier = $Dossier
    etape = $Etape
    type = $Type
    collecte_utc = [DateTime]::UtcNow.ToString('o')
    evenement_utc = $evenementNormalise
    source = $Source
    outil = $Outil
    action = $Action
    operateur = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
    nom_origine = [System.IO.Path]::GetFileName($cheminSource)
    chemin_relatif = Join-Path $sousDossier $nom
    taille_octets = $piece.Length
    sha256 = $empreinteCopie
    expurgation_validee_par = $RelecteurExpurgation
}

$registre = Join-Path $dossierCas 'registre.csv'
$enregistrement | Export-Csv -LiteralPath $registre -NoTypeInformation -Encoding UTF8 -Append
Write-Output $enregistrement
