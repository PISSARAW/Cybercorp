[CmdletBinding()]
param([Parameter(Mandatory = $true)][string]$Coffre)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path -LiteralPath $Coffre).Path
$active = Join-Path $root 'registre.csv'
$candidate = Join-Path $root 'registre-avant-suivi-w11-20261107T143053297Z.csv'
$old = @(Import-Csv -LiteralPath $active)
$rows = @(Import-Csv -LiteralPath $candidate)
if ($old.Count -ne 27 -or $rows.Count -ne 42) { throw 'Versions inattendues : rapprochement manuel requis.' }
function Test-Pieces($Entries) {
    foreach ($row in $Entries) {
        $path = [IO.Path]::GetFullPath((Join-Path $root $row.chemin_relatif))
        if (-not $path.StartsWith($root + '\', [StringComparison]::OrdinalIgnoreCase)) { throw 'Chemin hors coffre' }
        if ((Get-Item -LiteralPath $path).Length -ne [long]$row.taille_octets -or
            (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash -ne $row.sha256) { throw "Pièce non conforme : $($row.id)" }
    }
}
Test-Pieces $old
Test-Pieces $rows
if (@($rows | Group-Object id | Where-Object Count -gt 1).Count) { throw 'Identifiants dupliqués' }
$aliases = @(
    foreach ($entry in $old) {
        $sameId = @($rows | Where-Object id -eq $entry.id)
        if ($sameId.Count -eq 1) {
            foreach ($field in $entry.PSObject.Properties.Name) {
                if ([string]$entry.$field -cne [string]$sameId[0].$field) { throw "Métadonnées divergentes : $($entry.id), $field" }
            }
        } else {
            $sameHash = @($rows | Where-Object sha256 -eq $entry.sha256)
            if ($sameHash.Count -ne 1) { throw "Correspondance ambiguë : $($entry.id)" }
            [pscustomobject]@{ ancien_id = $entry.id; id_retenu = $sameHash[0].id; sha256 = $entry.sha256 }
        }
    }
)
$stamp = [datetime]::UtcNow.ToString('yyyyMMddTHHmmssfffZ')
$backup = Join-Path $root ('registre-avant-cloture-' + $stamp + '.csv')
[IO.File]::Copy($active, $backup, $false)
if ((Get-FileHash $backup).Hash -ne (Get-FileHash $active).Hash) { throw 'Sauvegarde incorrecte' }
$manifest = Join-Path $root ('rapprochement-cloture-' + $stamp + '.json')
$result = [ordered]@{ collecte_utc = [datetime]::UtcNow.ToString('o'); sauvegarde = $backup; candidat = $candidate; sha256_candidat = (Get-FileHash $candidate).Hash; lignes_actives_avant = $old.Count; lignes_retenues = $rows.Count; aliases = $aliases; cause_version_ancienne = 'Non établie' }
$json = $result | ConvertTo-Json -Depth 6
[IO.File]::WriteAllText($manifest, $json, [Text.UTF8Encoding]::new($false))
Copy-Item -LiteralPath $candidate -Destination $active
if ((Get-FileHash $active).Hash -ne (Get-FileHash $candidate).Hash) { throw 'Copie active incorrecte' }
Test-Pieces @(Import-Csv -LiteralPath $active)
[pscustomobject]@{ Registre = $active; Lignes = $rows.Count; Alias = $aliases.Count; Manifeste = $manifest; Sauvegarde = $backup }
