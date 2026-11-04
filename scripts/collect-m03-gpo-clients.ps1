#requires -RunAsAdministrator
#requires -Modules ActiveDirectory,GroupPolicy,SmbShare

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$OutputPath,

    [string]$ClientFolder = 'E:\Partages\Clients\CL-2026-014\Livraison'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$domain = Get-ADDomain -ErrorAction Stop
if ($domain.DNSRoot -ne 'ad.cybercorp.test') {
    throw "Domaine inattendu : $($domain.DNSRoot)"
}

$target = [System.IO.Path]::GetFullPath($OutputPath)
if (Test-Path -LiteralPath $target) {
    throw "Le rapport existe déjà : $target"
}
$parent = [System.IO.Path]::GetDirectoryName($target)
if (-not (Test-Path -LiteralPath $parent -PathType Container)) {
    throw "Dossier de sortie absent : $parent"
}

$expectedSharePath = 'E:\Partages\Clients'
$share = Get-SmbShare -Name Clients -ErrorAction Stop
if ($share.Path -ne $expectedSharePath) {
    throw "Chemin du partage Clients inattendu : $($share.Path)"
}

function Get-AclSummary {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
        return [ordered]@{ path = $Path; exists = $false; owner = $null; inheritance_protected = $null; access = @() }
    }
    $acl = Get-Acl -LiteralPath $Path -ErrorAction Stop
    return [ordered]@{
        path = $Path
        exists = $true
        owner = [string]$acl.Owner
        inheritance_protected = [bool]$acl.AreAccessRulesProtected
        access = @(
            $acl.Access | ForEach-Object {
                [ordered]@{
                    identity = [string]$_.IdentityReference
                    rights = [string]$_.FileSystemRights
                    type = [string]$_.AccessControlType
                    inherited = [bool]$_.IsInherited
                }
            }
        )
    }
}

$gpos = @(
    Get-GPO -All -ErrorAction Stop | Sort-Object DisplayName | ForEach-Object {
        $gpo = $_
        [ordered]@{
            name = [string]$gpo.DisplayName
            id = [string]$gpo.Id
            owner = [string]$gpo.Owner
            status = [string]$gpo.GpoStatus
            modified_utc = $gpo.ModificationTime.ToUniversalTime().ToString('o')
            permissions = @(
                Get-GPPermission -Guid $gpo.Id -All -ErrorAction Stop | ForEach-Object {
                    $permissionName = if ($_.PSObject.Properties['Permission']) {
                        [string]$_.Permission
                    } elseif ($_.PSObject.Properties['PermissionLevel']) {
                        [string]$_.PermissionLevel
                    } else {
                        '<non expose>'
                    }
                    $trusteeType = if ($_.PSObject.Properties['TrusteeType']) {
                        [string]$_.TrusteeType
                    } elseif ($_.Trustee -and $_.Trustee.PSObject.Properties['SidType']) {
                        [string]$_.Trustee.SidType
                    } else {
                        $null
                    }
                    $isInherited = if ($_.PSObject.Properties['Inherited']) {
                        [bool]$_.Inherited
                    } else {
                        $null
                    }
                    [ordered]@{
                        trustee = [string]$_.Trustee
                        trustee_type = $trusteeType
                        permission = $permissionName
                        inherited = $isInherited
                    }
                }
            )
        }
    }
)

$scopeDns = @(
    [string]$domain.DistinguishedName
    'OU=Postes,OU=CyberCorp,DC=ad,DC=cybercorp,DC=test'
)
$links = @(
    foreach ($scopeDn in $scopeDns) {
        $inheritance = Get-GPInheritance -Target $scopeDn -ErrorAction Stop
        [ordered]@{
            target = $scopeDn
            inheritance_blocked = [bool]$inheritance.GpoInheritanceBlocked
            direct = @(
                $inheritance.GpoLinks | ForEach-Object {
                    [ordered]@{
                        name = [string]$_.DisplayName
                        enabled = [bool]$_.Enabled
                        enforced = [bool]$_.Enforced
                        order = [int]$_.Order
                    }
                }
            )
            inherited = @(
                $inheritance.InheritedGpoLinks | ForEach-Object {
                    [ordered]@{
                        name = [string]$_.DisplayName
                        enabled = [bool]$_.Enabled
                        enforced = [bool]$_.Enforced
                        order = [int]$_.Order
                    }
                }
            )
        }
    }
)

$clientsMembers = @(
    Get-ADGroupMember -Identity DL_CLIENTS_MODIFY -Recursive -ErrorAction Stop |
        Sort-Object SamAccountName |
        ForEach-Object {
            [ordered]@{
                sam = [string]$_.SamAccountName
                object_class = [string]$_.ObjectClass
            }
        }
)

$report = [ordered]@{
    mission = 'M-CLIENT-01'
    control = 'M03 - gouvernance GPO et droits du dossier Clients'
    source = $env:COMPUTERNAME
    collected_utc = [DateTime]::UtcNow.ToString('o')
    domain = [string]$domain.DNSRoot
    gpos = $gpos
    links = $links
    clients = [ordered]@{
        share = [ordered]@{
            name = [string]$share.Name
            path = [string]$share.Path
            access = @(
                Get-SmbShareAccess -Name Clients -ErrorAction Stop | ForEach-Object {
                    [ordered]@{
                        account = [string]$_.AccountName
                        right = [string]$_.AccessRight
                        type = [string]$_.AccessControlType
                    }
                }
            )
        }
        root_acl = Get-AclSummary -Path $expectedSharePath
        mandate_folder_acl = Get-AclSummary -Path $ClientFolder
        modify_group_recursive_members = $clientsMembers
    }
}

$json = $report | ConvertTo-Json -Depth 12
[System.IO.File]::WriteAllText($target, $json + [Environment]::NewLine, [System.Text.UTF8Encoding]::new($false))
[pscustomobject]@{
    Path = $target
    SHA256 = (Get-FileHash -LiteralPath $target -Algorithm SHA256).Hash
    CollectedUtc = $report.collected_utc
    GpoCount = $gpos.Count
    MandateFolderExists = [bool]$report.clients.mandate_folder_acl.exists
}
