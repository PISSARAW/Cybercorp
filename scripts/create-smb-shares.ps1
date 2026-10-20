#requires -RunAsAdministrator
#requires -Modules ActiveDirectory,SmbShare

[CmdletBinding()]
param(
    [string]$RootPath = 'E:\Partages'
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$expectedDomain = 'ad.cybercorp.test'
$domain = Get-ADDomain
if ($domain.DNSRoot -ne $expectedDomain) {
    throw "Domaine inattendu : $($domain.DNSRoot)."
}

$shareConfiguration = [ordered]@{
    Commun = @{
        Read        = @('DL_COMMUN_READ')
        Change      = @('DL_COMMUN_MODIFY')
        Description = 'Documents communs CyberCorp'
    }
    Finance = @{
        Read        = @()
        Change      = @('DL_FINANCE_MODIFY')
        Description = 'Documents Finance CyberCorp'
    }
    RH = @{
        Read        = @()
        Change      = @('DL_RH_MODIFY')
        Description = 'Documents RH CyberCorp'
    }
    Clients = @{
        Read        = @()
        Change      = @('DL_CLIENTS_MODIFY')
        Description = 'Dossiers clients CyberCorp'
    }
    Technique = @{
        Read        = @()
        Change      = @('DL_TECH_MODIFY')
        Description = 'Documents techniques CyberCorp'
    }
    Syntheses = @{
        Read        = @('DL_SYNTHESES_READ')
        Change      = @('DL_SYNTHESES_MODIFY')
        Description = 'Syntheses de direction CyberCorp'
    }
}

$administratorsSid = [System.Security.Principal.SecurityIdentifier]::new('S-1-5-32-544')
$everyoneSid = [System.Security.Principal.SecurityIdentifier]::new('S-1-1-0')
$administratorsAccount = $administratorsSid.Translate(
    [System.Security.Principal.NTAccount]
).Value
$everyoneAccount = $everyoneSid.Translate(
    [System.Security.Principal.NTAccount]
).Value

$qualifiedAccountByGroup = @{}
foreach ($groupName in @(
    $shareConfiguration.Values.Read
    $shareConfiguration.Values.Change
) | Where-Object { $_ } | Sort-Object -Unique) {
    $group = Get-ADGroup -Identity $groupName
    $qualifiedAccountByGroup[$groupName] = "$($domain.NetBIOSName)\$($group.SamAccountName)"
}

# Tous les prerequis sont controles avant la premiere creation.
foreach ($shareName in $shareConfiguration.Keys) {
    $folderPath = Join-Path $RootPath $shareName
    if (-not (Test-Path -LiteralPath $folderPath -PathType Container)) {
        throw "Dossier attendu absent : $folderPath."
    }

    $existingShare = Get-SmbShare -Name $shareName -ErrorAction SilentlyContinue
    if ($null -ne $existingShare -and $existingShare.Path -ne $folderPath) {
        throw "Le partage $shareName existe avec un chemin inattendu : $($existingShare.Path)."
    }
}

foreach ($shareName in $shareConfiguration.Keys) {
    $folderPath = Join-Path $RootPath $shareName
    $configuration = $shareConfiguration[$shareName]
    $existingShare = Get-SmbShare -Name $shareName -ErrorAction SilentlyContinue

    if ($null -eq $existingShare) {
        $parameters = @{
            Name                  = $shareName
            Path                  = $folderPath
            Description           = $configuration.Description
            FullAccess            = $administratorsAccount
            FolderEnumerationMode = 'AccessBased'
            CachingMode           = 'None'
        }

        if ($configuration.Read.Count -gt 0) {
            $parameters.ReadAccess = @(
                $configuration.Read |
                    ForEach-Object { $qualifiedAccountByGroup[$_] }
            )
        }
        if ($configuration.Change.Count -gt 0) {
            $parameters.ChangeAccess = @(
                $configuration.Change |
                    ForEach-Object { $qualifiedAccountByGroup[$_] }
            )
        }

        New-SmbShare @parameters | Out-Null
    }

    $everyoneEntry = Get-SmbShareAccess -Name $shareName |
        Where-Object AccountName -eq $everyoneAccount
    if ($null -ne $everyoneEntry) {
        Revoke-SmbShareAccess `
            -Name $shareName `
            -AccountName $everyoneAccount `
            -Force | Out-Null
    }
}

$results = foreach ($shareName in $shareConfiguration.Keys) {
    $share = Get-SmbShare -Name $shareName
    $access = @(Get-SmbShareAccess -Name $shareName)

    $expectedAccess = @(
        [pscustomobject]@{ Account = $administratorsAccount; Right = 'Full' }
        foreach ($groupName in $shareConfiguration[$shareName].Read) {
            [pscustomobject]@{
                Account = $qualifiedAccountByGroup[$groupName]
                Right   = 'Read'
            }
        }
        foreach ($groupName in $shareConfiguration[$shareName].Change) {
            [pscustomobject]@{
                Account = $qualifiedAccountByGroup[$groupName]
                Right   = 'Change'
            }
        }
    )

    foreach ($expectedEntry in $expectedAccess) {
        $match = @(
            $access | Where-Object {
                $_.AccountName -eq $expectedEntry.Account -and
                $_.AccessRight.ToString() -eq $expectedEntry.Right -and
                $_.AccessControlType.ToString() -eq 'Allow'
            }
        )
        if ($match.Count -ne 1) {
            throw "Droit SMB attendu absent ou duplique sur $shareName : $($expectedEntry.Account) $($expectedEntry.Right)."
        }
    }

    if ($access.Count -ne $expectedAccess.Count) {
        throw "Le partage $shareName contient un nombre inattendu de permissions : $($access.Count)."
    }
    if ($share.FolderEnumerationMode -ne 'AccessBased' -or $share.CachingMode -ne 'None') {
        throw "Options SMB inattendues sur $shareName."
    }

    [pscustomobject]@{
        Name        = $share.Name
        Path        = $share.Path
        AccessBased = $share.FolderEnumerationMode -eq 'AccessBased'
        NoCache     = $share.CachingMode -eq 'None'
        Rules       = $access.Count
    }
}

$results | Format-Table -AutoSize
Write-Host 'Partages SMB crees et controles.' -ForegroundColor Green
