# Comptes et groupes Active Directory

## CONV-010 — Absence initiale de groupes CyberCorp

```text
Nombre de groupes CyberCorp trouvés : 0
```

Le filtre recherchait les `SamAccountName` commençant par `GG_` ou `DL_`.

## CONV-011 — Groupes globaux de sécurité

Capture transcrite : `codex-clipboard-29970b6c-cc1f-46f8-9008-938e2cf2028f.png`.

```text
GG_COMMERCIAL  Global  Security
GG_DIRECTION   Global  Security
GG_FINANCE     Global  Security
GG_IT          Global  Security
GG_RH          Global  Security
GG_TECHNIQUE   Global  Security
GG_TOUS        Global  Security
```

## CONV-012 — Groupes locaux de domaine

Capture transcrite : `codex-clipboard-3c65fb55-d384-4ee2-98c6-ef41c0c83501.png`.

```text
DL_CLIENTS_MODIFY    DomainLocal  Security
DL_COMMUN_MODIFY     DomainLocal  Security
DL_COMMUN_READ       DomainLocal  Security
DL_FINANCE_MODIFY    DomainLocal  Security
DL_RH_MODIFY         DomainLocal  Security
DL_SYNTHESES_MODIFY  DomainLocal  Security
DL_SYNTHESES_READ    DomainLocal  Security
DL_TECH_MODIFY       DomainLocal  Security
```

## CONV-013 — Groupe fédérateur `GG_TOUS`

Capture transcrite : `codex-clipboard-af4897cb-94be-4590-8b7b-b155f23ec92f.png`. Membres visibles : `GG_COMMERCIAL`, `GG_DIRECTION`, `GG_FINANCE`, `GG_IT`, `GG_RH` et `GG_TECHNIQUE`.

## CONV-014 — Imbrications AGDLP

Capture transcrite : `codex-clipboard-9ddf0ef0-422c-4810-8a08-28fc906eaa71.png`.

```text
DL_CLIENTS_MODIFY    GG_COMMERCIAL
DL_COMMUN_MODIFY     GG_IT
DL_COMMUN_READ       GG_TOUS
DL_FINANCE_MODIFY    GG_FINANCE
DL_RH_MODIFY         GG_RH
DL_SYNTHESES_READ    GG_DIRECTION
DL_TECH_MODIFY       GG_TECHNIQUE
```

`DL_SYNTHESES_MODIFY` ne possède pas encore de groupe métier désigné.

## CONV-015 — Absence initiale de comptes CyberCorp

```text
Nombre de comptes CyberCorp trouvés : 0
```

## CONV-016 — Provisionnement des comptes

```text
Crees                 : 29
DejaPresents          : 0
AppartenancesAjoutees : 25
Total                 : 29
Actifs                : 27
Desactives            : 2

Provisionnement terminé. Aucun mot de passe n'a été affiché.
```

Le fichier contenant les mots de passe initiaux n'est pas reproduit.

## CONV-017 — Suppression du fichier temporaire et répartition

Capture transcrite : `codex-clipboard-cc6477b9-47c6-4f38-83b3-972735b0fb87.png`. Après suppression de `C:\CyberCorp-Provisioning\initial-passwords.csv`, `Test-Path` a retourné `False`.

```text
Admins, True         2
Commercial, True     7
Direction, True      2
Finance, True        3
Informatique, True   2
RH, True             3
Technique, True      8
Tests, False         2
```

## CONV-018 — Effectifs des groupes métiers

Une première commande a échoué avec `EmptyPipeElement`. La commande corrigée a produit la capture `codex-clipboard-1909ac5d-b8de-4af4-be5c-807250738025.png` :

```text
GG_COMMERCIAL  7  0
GG_DIRECTION   2  0
GG_FINANCE     3  0
GG_IT          2  0
GG_RH          3  0
GG_TECHNIQUE   8  0
GG_TOUS        0  6
```

## CONV-019 — Séparation des comptes administratifs

Capture transcrite : `codex-clipboard-46e8f469-48bf-41b6-b426-742572fb236e.png`.

```text
adm.ad01  Utilisateurs du domaine  S-1-5-21-…-513
adm.ad02  Utilisateurs du domaine  S-1-5-21-…-513
```

Aucune appartenance administrative supplémentaire n'est visible.
