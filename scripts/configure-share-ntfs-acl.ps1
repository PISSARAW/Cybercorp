#requires -RunAsAdministrator
#requires -Modules ActiveDirectory

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

$permissions = [ordered]@{
    Commun = @{
        Read   = @('DL_COMMUN_READ')
        Modify = @('DL_COMMUN_MODIFY')
    }
    Finance = @{
        Read   = @()
        Modify = @('DL_FINANCE_MODIFY')
    }
    RH = @{
        Read   = @()
        Modify = @('DL_RH_MODIFY')
    }
    Clients = @{
        Read   = @()
        Modify = @('DL_CLIENTS_MODIFY')
    }
    Technique = @{
        Read   = @()
        Modify = @('DL_TECH_MODIFY')
    }
    Syntheses = @{
        Read   = @('DL_SYNTHESES_READ')
        Modify = @('DL_SYNTHESES_MODIFY')
    }
}

if (-not (Test-Path -LiteralPath $RootPath -PathType Container)) {
    throw "Dossier racine absent : $RootPath."
}

$groupSidByName = @{}
foreach ($groupName in @(
    $permissions.Values.Read
    $permissions.Values.Modify
) | Where-Object { $_ } | Sort-Object -Unique) {
    $groupSidByName[$groupName] = (Get-ADGroup -Identity $groupName).SID
}

foreach ($folderName in $permissions.Keys) {
    $folderPath = Join-Path $RootPath $folderName
    if (-not (Test-Path -LiteralPath $folderPath -PathType Container)) {
        throw "Dossier attendu absent : $folderPath."
    }
}

$systemSid = [System.Security.Principal.SecurityIdentifier]::new('S-1-5-18')
$administratorsSid = [System.Security.Principal.SecurityIdentifier]::new('S-1-5-32-544')
$inheritance = [System.Security.AccessControl.InheritanceFlags]'ContainerInherit, ObjectInherit'
$propagation = [System.Security.AccessControl.PropagationFlags]::None
$allow = [System.Security.AccessControl.AccessControlType]::Allow

function New-ProtectedDirectoryAcl {
    param(
        [string[]]$ReadGroups = @(),
        [string[]]$ModifyGroups = @()
    )

    $acl = [System.Security.AccessControl.DirectorySecurity]::new()
    $acl.SetAccessRuleProtection($true, $false)
    $acl.SetOwner($administratorsSid)

    foreach ($entry in @(
        @{ Identity = $systemSid; Rights = [System.Security.AccessControl.FileSystemRights]::FullControl }
        @{ Identity = $administratorsSid; Rights = [System.Security.AccessControl.FileSystemRights]::FullControl }
    )) {
        $rule = [System.Security.AccessControl.FileSystemAccessRule]::new(
            $entry.Identity,
            $entry.Rights,
            $inheritance,
            $propagation,
            $allow
        )
        [void]$acl.AddAccessRule($rule)
    }

    foreach ($groupName in $ReadGroups) {
        $rule = [System.Security.AccessControl.FileSystemAccessRule]::new(
            $groupSidByName[$groupName],
            [System.Security.AccessControl.FileSystemRights]::ReadAndExecute,
            $inheritance,
            $propagation,
            $allow
        )
        [void]$acl.AddAccessRule($rule)
    }

    foreach ($groupName in $ModifyGroups) {
        $rule = [System.Security.AccessControl.FileSystemAccessRule]::new(
            $groupSidByName[$groupName],
            [System.Security.AccessControl.FileSystemRights]::Modify,
            $inheritance,
            $propagation,
            $allow
        )
        [void]$acl.AddAccessRule($rule)
    }

    return $acl
}

# La racine n'est pas partagee et reste accessible uniquement au systeme
# et aux administrateurs. Chaque enfant recoit ensuite sa matrice AGDLP.
Set-Acl -LiteralPath $RootPath -AclObject (New-ProtectedDirectoryAcl)

foreach ($folderName in $permissions.Keys) {
    $folderPath = Join-Path $RootPath $folderName
    $folderPermissions = $permissions[$folderName]
    $acl = New-ProtectedDirectoryAcl `
        -ReadGroups $folderPermissions.Read `
        -ModifyGroups $folderPermissions.Modify
    Set-Acl -LiteralPath $folderPath -AclObject $acl
}

$results = foreach ($folderPath in @($RootPath) + @(
    $permissions.Keys | ForEach-Object { Join-Path $RootPath $_ }
)) {
    $acl = Get-Acl -LiteralPath $folderPath
    [pscustomobject]@{
        Path      = $folderPath
        Protected = $acl.AreAccessRulesProtected
        Rules     = @($acl.Access).Count
        Inherited = @($acl.Access | Where-Object IsInherited).Count
    }
}

$invalid = @(
    $results | Where-Object { -not $_.Protected -or $_.Inherited -ne 0 }
)
if ($invalid.Count -gt 0) {
    throw 'Le controle final a detecte une ACL non protegee ou une regle heritee.'
}

$results | Format-Table -AutoSize
Write-Host 'ACL NTFS appliquees. Aucun partage SMB n a ete cree.' -ForegroundColor Green
