#requires -RunAsAdministrator
#requires -Modules ActiveDirectory

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
    [string]$AccountsCsv,

    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
    [string]$SecretsCsv
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$expectedDomain = 'ad.cybercorp.test'
$baseDn = 'DC=ad,DC=cybercorp,DC=test'
$cyberCorpOu = "OU=CyberCorp,$baseDn"

$serviceConfiguration = @{
    Direction    = @{ Ou = "OU=Direction,OU=Utilisateurs,$cyberCorpOu"; Group = 'GG_DIRECTION' }
    RH           = @{ Ou = "OU=RH,OU=Utilisateurs,$cyberCorpOu"; Group = 'GG_RH' }
    Finance      = @{ Ou = "OU=Finance,OU=Utilisateurs,$cyberCorpOu"; Group = 'GG_FINANCE' }
    Commercial   = @{ Ou = "OU=Commercial,OU=Utilisateurs,$cyberCorpOu"; Group = 'GG_COMMERCIAL' }
    Technique    = @{ Ou = "OU=Technique,OU=Utilisateurs,$cyberCorpOu"; Group = 'GG_TECHNIQUE' }
    Informatique = @{ Ou = "OU=Informatique,OU=Utilisateurs,$cyberCorpOu"; Group = 'GG_IT' }
}

function Assert-CsvColumns {
    param(
        [Parameter(Mandatory)]
        [object[]]$Rows,

        [Parameter(Mandatory)]
        [string[]]$RequiredColumns,

        [Parameter(Mandatory)]
        [string]$Label
    )

    if ($Rows.Count -eq 0) {
        throw "$Label est vide."
    }

    $availableColumns = @($Rows[0].PSObject.Properties.Name)
    $missingColumns = @($RequiredColumns | Where-Object { $_ -notin $availableColumns })
    if ($missingColumns.Count -gt 0) {
        throw "$Label ne contient pas les colonnes requises : $($missingColumns -join ', ')."
    }
}

$domain = Get-ADDomain
if ($domain.DNSRoot -ne $expectedDomain -or $domain.DistinguishedName -ne $baseDn) {
    throw "Domaine inattendu : $($domain.DNSRoot) ($($domain.DistinguishedName))."
}

$allAccounts = @(Import-Csv -LiteralPath $AccountsCsv -Encoding UTF8)
$allSecrets = @(Import-Csv -LiteralPath $SecretsCsv -Encoding UTF8)

Assert-CsvColumns -Rows $allAccounts -RequiredColumns @(
    'identifiant', 'type', 'service', 'statut_initial', 'commentaire'
) -Label 'Le fichier des comptes'
Assert-CsvColumns -Rows $allSecrets -RequiredColumns @(
    'identifiant', 'service', 'mot_de_passe_initial'
) -Label 'Le fichier des secrets'

$accounts = @(
    $allAccounts |
        Where-Object { $_.identifiant -match '^(usr\.|adm\.ad|tst\.)' }
)

if ($accounts.Count -ne 29) {
    throw "29 comptes AD étaient attendus, mais $($accounts.Count) ont été trouvés."
}

$duplicateAccounts = @(
    $accounts | Group-Object identifiant | Where-Object Count -gt 1
)
$duplicateSecrets = @(
    $allSecrets | Group-Object identifiant | Where-Object Count -gt 1
)
if ($duplicateAccounts.Count -gt 0 -or $duplicateSecrets.Count -gt 0) {
    throw 'Un identifiant est présent plusieurs fois dans un fichier source.'
}

$secretById = @{}
foreach ($secret in $allSecrets) {
    $secretById[$secret.identifiant] = $secret
}

foreach ($account in $accounts) {
    if (-not $secretById.ContainsKey($account.identifiant)) {
        throw "Secret absent pour $($account.identifiant)."
    }
    if ([string]::IsNullOrWhiteSpace($secretById[$account.identifiant].mot_de_passe_initial)) {
        throw "Secret vide pour $($account.identifiant)."
    }
    if ($secretById[$account.identifiant].service -ne $account.service) {
        throw "Service incohérent entre les deux fichiers pour $($account.identifiant)."
    }

    switch ($account.type) {
        'metier' {
            if (-not $serviceConfiguration.ContainsKey($account.service)) {
                throw "Service métier inconnu pour $($account.identifiant) : $($account.service)."
            }
            if ($account.statut_initial -ne 'actif') {
                throw "Statut métier inattendu pour $($account.identifiant)."
            }
        }
        'administration' {
            if ($account.identifiant -notmatch '^adm\.ad0[12]$' -or $account.statut_initial -ne 'actif') {
                throw "Compte d'administration inattendu : $($account.identifiant)."
            }
        }
        'test' {
            if ($account.identifiant -notmatch '^tst\.(acl|lock)$' -or $account.statut_initial -ne 'desactive') {
                throw "Compte de test inattendu : $($account.identifiant)."
            }
        }
        default {
            throw "Type de compte inattendu pour $($account.identifiant) : $($account.type)."
        }
    }
}

$requiredOus = @(
    $serviceConfiguration.Values.Ou
    "OU=Admins,$cyberCorpOu"
    "OU=Tests,$cyberCorpOu"
) | Sort-Object -Unique

foreach ($ou in $requiredOus) {
    Get-ADOrganizationalUnit -Identity $ou | Out-Null
}
foreach ($group in $serviceConfiguration.Values.Group) {
    Get-ADGroup -Identity $group | Out-Null
}

$created = 0
$alreadyPresent = 0
$membershipsAdded = 0

foreach ($account in $accounts | Sort-Object identifiant) {
    switch ($account.type) {
        'metier' {
            $targetOu = $serviceConfiguration[$account.service].Ou
            $targetGroup = $serviceConfiguration[$account.service].Group
            $enabled = $true
        }
        'administration' {
            $targetOu = "OU=Admins,$cyberCorpOu"
            $targetGroup = $null
            $enabled = $true
        }
        'test' {
            $targetOu = "OU=Tests,$cyberCorpOu"
            $targetGroup = $null
            $enabled = $false
        }
    }

    $existing = Get-ADUser -Filter "SamAccountName -eq '$($account.identifiant)'"
    if ($null -eq $existing) {
        $password = ConvertTo-SecureString `
            -String $secretById[$account.identifiant].mot_de_passe_initial `
            -AsPlainText `
            -Force

        New-ADUser `
            -Name $account.identifiant `
            -SamAccountName $account.identifiant `
            -UserPrincipalName "$($account.identifiant)@$expectedDomain" `
            -DisplayName $account.identifiant `
            -Description $account.commentaire `
            -Path $targetOu `
            -AccountPassword $password `
            -Enabled $enabled `
            -ChangePasswordAtLogon $enabled `
            -PasswordNeverExpires $false

        $created++
    }
    else {
        $expectedDn = "CN=$($account.identifiant),$targetOu"
        if ($existing.DistinguishedName -ne $expectedDn) {
            throw "$($account.identifiant) existe dans un emplacement inattendu : $($existing.DistinguishedName)."
        }
        $alreadyPresent++
    }

    if ($null -ne $targetGroup) {
        $isDirectMember = Get-ADGroupMember -Identity $targetGroup |
            Where-Object SamAccountName -eq $account.identifiant
        if ($null -eq $isDirectMember) {
            Add-ADGroupMember -Identity $targetGroup -Members $account.identifiant
            $membershipsAdded++
        }
    }
}

$provisionedAccounts = @(
    Get-ADUser -Filter * -SearchBase $cyberCorpOu -Properties Enabled |
        Where-Object SamAccountName -match '^(usr\.|adm\.ad|tst\.)'
)
$enabledCount = @($provisionedAccounts | Where-Object Enabled).Count
$disabledCount = @($provisionedAccounts | Where-Object { -not $_.Enabled }).Count

if ($provisionedAccounts.Count -ne 29 -or $enabledCount -ne 27 -or $disabledCount -ne 2) {
    throw "Contrôle final incorrect : total=$($provisionedAccounts.Count), actifs=$enabledCount, désactivés=$disabledCount."
}

[pscustomobject]@{
    Crees              = $created
    DejaPresents       = $alreadyPresent
    AppartenancesAjoutees = $membershipsAdded
    Total              = $provisionedAccounts.Count
    Actifs             = $enabledCount
    Desactives         = $disabledCount
} | Format-List

Write-Host "Provisionnement termine. Aucun mot de passe n'a ete affiche." -ForegroundColor Green
