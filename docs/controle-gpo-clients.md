# M-CLIENT-01 — contrôle M03 des GPO et du dossier `Clients`

**État au 5 novembre 2026 : deux collectes exécutées sur `CC-DC01`, rapatriées et inscrites au registre ; revue M03 à terminer.** Les commandes et captures communiquées par l'opérateur établissent les observations ci-dessous. Les SHA-256 des copies concordent avec les sources ; le registre et les fichiers dans `brut` ont été contrôlés. Les JSON confirment `False → True`, sans établir les accès effectifs ni autoriser la remise.

## Question métier

Avant la remise du dossier `CL-2026-014`, déterminer qui peut modifier `\\CC-DC01\Clients\CL-2026-014\Livraison` et si les GPO qui encadrent les postes sont gouvernées par les bonnes personnes. L'inventaire d'une ACL ou l'application d'une GPO ne suffit pas : il faut croiser configuration, appartenance aux groupes et essais d'accès sous des comptes métier.

## Observations datées

| Moment | Observation | Portée |
| --- | --- | --- |
| 1er novembre, 20 h 21 Europe/Paris | `M03-GPO-Clients-20261101T202134.json` créé sur `CC-DC01` ; quatre GPO inventoriées ; `MandateFolderExists=False`. SHA-256 affiché : `978B4D4A3A273E7E6350C1C5B7593DF2FA70F5F6060EE728AAC5F7E9BEFC4764`. | Le partage `Clients` existait, mais `CL-2026-014` et `Livraison` étaient absents. Empreinte source/copie vérifiée le 5 novembre. |
| 1er novembre, après la première collecte | ACL de `E:\Partages\Clients` lue : propriétaire `BUILTIN\Administrateurs`, héritage bloqué sur cette racine ; règles explicites et transmissibles `Système` et `Administrateurs` en contrôle total, `DL_CLIENTS_MODIFY` en modification. Création de `CL-2026-014\Livraison` par l'opérateur ; le sous-dossier présente ces trois règles héritées. | Configuration NTFS observée sur le serveur ; elle ne prouve pas encore l'accès via SMB sous un compte métier. |
| 2 novembre, 06 h 58 Europe/Paris | `M03-GPO-Clients-20261102T065842.json` créé sur `CC-DC01` ; quatre GPO inventoriées ; `MandateFolderExists=True`. La capture montre le chemin, l'heure UTC et le SHA-256. | La seconde collecte confirme l'existence du dossier. Empreinte source/copie vérifiée le 5 novembre. |

Le script [collect-m03-gpo-clients.ps1](../scripts/collect-m03-gpo-clients.ps1) vérifie le domaine et le chemin du partage, puis inventorie en lecture seule les GPO et leurs permissions, les liens au domaine et à `OU=Postes`, les droits SMB, les ACL NTFS et les membres récursifs de `DL_CLIENTS_MODIFY`. Une première exécution a révélé que `Get-GPPermission` ne fournissait pas `TrusteeType` sur ce serveur ; le script a été corrigé pour accepter ce champ facultatif, puis les deux collectes ci-dessus ont abouti. Le script ne modifie aucun droit ni aucune GPO.

## Chaîne de preuves — transfert et enregistrement du 5 novembre 2026

Les originaux sont sur `CC-DC01` dans `C:\Audit\M-CLIENT-01`. Une tentative antérieure s'était arrêtée avant le transfert avec « coffre introuvable », tandis qu'une inspection du 4 novembre rapportait un coffre et un registre sur l'hôte, sans pièce M03. Le 5 novembre, la session sur `MONNOKOELOBA`, sous `MONNOKOELOBA\pissa`, a confirmé `LOCALAPPDATA=C:\Users\pissa\AppData\Local`, `Test-Path=False` pour le coffre et une erreur de chemin introuvable pour sa racine `CyberCorp\preuves`. Aucun dossier contenant « Cyber » n'était listé directement dans `LOCALAPPDATA`. Le chemin Windows retourné par .NET correspondait aussi au chemin attendu.

La racine `C:\Users\pissa\AppData\Local\CyberCorp\preuves` a donc été créée et protégée : héritage désactivé (`AreAccessRulesProtected=True`), trois règles explicites transmissibles en contrôle total pour le compte opérateur, `SYSTEM` et les administrateurs locaux. Le dossier `M-CLIENT-01` et ses sous-dossiers `brut`, `extraits-expurges`, `transfert` et `captures` ont ensuite été créés. **La cause de la divergence avec l'inspection antérieure reste inexpliquée** ; cette préparation ne démontre pas la récupération d'anciennes pièces, notamment M02, dont la disponibilité n'a pas été revérifiée pendant cette procédure.

Les deux JSON ont été copiés par PowerShell Direct dans `transfert`, avec refus des destinations déjà présentes. Les SHA-256 locaux ont été comparés aux empreintes lues sur le DC ; la première correspond aussi à celle historiquement consignée. Le champ `clients.mandate_folder_acl.exists` vaut bien `False`, puis `True`.

Les pièces ont été inscrites avec [enregistrer-preuve.ps1](../scripts/enregistrer-preuve.ps1), `-Etape gpo -Source CC-DC01 -Outil PowerShell`. Les actions sont « Inventaire M03 avant création du dossier » et « Inventaire M03 après création du dossier ». `evenement_utc` provient de `collected_utc` dans chaque JSON, pas du nom du fichier ni de l'heure de copie.

| État | Nom d'origine | Événement UTC | Identifiant du registre | Taille (octets) |
| --- | --- | --- | --- | --- |
| `False` | `M03-GPO-Clients-20261101T202134.json` | `2026-11-01T19:21:34.9747174Z` | `M-CLIENT-01_gpo_20261105T090906559Z_CC-DC01_PowerShell` | 19078 |
| `True` | `M03-GPO-Clients-20261102T065842.json` | `2026-11-02T05:58:45.7119232Z` | `M-CLIENT-01_gpo_20261105T090906603Z_CC-DC01_PowerShell` | 20615 |

| État | SHA-256 source, transfert et pièce enregistrée |
| --- | --- |
| `False` | `978B4D4A3A273E7E6350C1C5B7593DF2FA70F5F6060EE728AAC5F7E9BEFC4764` |
| `True` | `6330B1645F0952789AD419D322C82F038447D594CBC879FA2E7286DA8482EC26` |

Une relecture de `registre.csv` le 5 novembre à `09:12:53 UTC` a retrouvé exactement une ligne par identifiant. Le chemin sous `brut`, la taille, le SHA-256 recalculé, l'heure d'événement et l'état booléen ont été vérifiés pour les deux pièces (`RegistreConforme=True`). Chaque fichier enregistré porte son identifiant suivi de `.json`.

Les captures suivantes ont été rangées dans `captures` sous le coffre ; les horodatages de leurs noms reprennent les heures UTC affichées :

| Capture | Fichier | Taille (octets) |
| --- | --- | --- |
| C02 — contexte et ACL avant transfert | `M-CLIENT-01_C02_20261105T085115_MONNOKOELOBA.png` | 72244 |
| C03 — copies, SHA-256 et `False → True` | `M-CLIENT-01_C03_20261105T090424_MONNOKOELOBA.png` | 29252 |
| C04 — registre et contrôle des pièces dans `brut` | `M-CLIENT-01_C04_20261105T091253_MONNOKOELOBA.png` | 44028 |

Les JSON, le registre et les captures restent hors Git et OneDrive. Les captures illustrent les vérifications ; les JSON et le registre restent les pièces principales. Toute image ou tout extrait destiné à la remise doit encore être expurgé et relu selon le [protocole](protocole-preuves.md).

## Revue et décision encore nécessaires

1. Comparer propriétaires, délégations et liens des quatre GPO au rapport GPOZaurr T10 et au besoin métier. Croiser avec `gpresult` sur `CC-W11-01` ; l'application d'une stratégie ne valide pas sa gouvernance.
2. Comparer les droits SMB et NTFS de `Clients` et de `Livraison`, ainsi que les membres de `DL_CLIENTS_MODIFY`, à la matrice d'accès prévue.
3. Réaliser depuis `CC-W11-01` un test de modification autorisée et un refus attendu avec deux comptes métier distincts. Consigner l'identité, l'heure, le résultat et une preuve native ; la liste des membres ne démontre pas l'accès effectif.
4. Renseigner la [fiche M-CLIENT-01](fiche-m-client-01.md) et la [recette](../config/recette.csv) après qualification et éventuel contre-test. La présence du dossier n'établit pas l'existence du livrable PDF ni l'autorisation de remise.
