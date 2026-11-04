# M-CLIENT-01 — contrôle M03 des GPO et du dossier `Clients`

**État au 4 novembre 2026 : deux collectes exécutées sur `CC-DC01`, revue et enregistrement des preuves à terminer.** Les commandes et captures communiquées par l'opérateur établissent les observations ci-dessous. Les deux JSON sont encore à rapatrier et à inscrire dans le [registre de preuves](protocole-preuves.md) ; aucune conclusion sur les accès effectifs ou la remise n'est acquise.

## Question métier

Avant la remise du dossier `CL-2026-014`, déterminer qui peut modifier `\\CC-DC01\Clients\CL-2026-014\Livraison` et si les GPO qui encadrent les postes sont gouvernées par les bonnes personnes. L'inventaire d'une ACL ou l'application d'une GPO ne suffit pas : il faut croiser configuration, appartenance aux groupes et essais d'accès sous des comptes métier.

## Observations datées

| Moment | Observation | Portée |
| --- | --- | --- |
| 1er novembre, 20 h 21 Europe/Paris | `M03-GPO-Clients-20261101T202134.json` créé sur `CC-DC01` ; quatre GPO inventoriées ; `MandateFolderExists=False`. SHA-256 affiché : `978B4D4A3A273E7E6350C1C5B7593DF2FA70F5F6060EE728AAC5F7E9BEFC4764`. | Le partage `Clients` existait, mais `CL-2026-014` et `Livraison` étaient absents. Empreinte à revérifier après transfert. |
| 1er novembre, après la première collecte | ACL de `E:\Partages\Clients` lue : propriétaire `BUILTIN\Administrateurs`, héritage bloqué sur cette racine ; règles explicites et transmissibles `Système` et `Administrateurs` en contrôle total, `DL_CLIENTS_MODIFY` en modification. Création de `CL-2026-014\Livraison` par l'opérateur ; le sous-dossier présente ces trois règles héritées. | Configuration NTFS observée sur le serveur ; elle ne prouve pas encore l'accès via SMB sous un compte métier. |
| 2 novembre, 06 h 58 Europe/Paris | `M03-GPO-Clients-20261102T065842.json` créé sur `CC-DC01` ; quatre GPO inventoriées ; `MandateFolderExists=True`. La capture montre le chemin, l'heure UTC et le SHA-256. | La seconde collecte confirme l'existence du dossier. Son empreinte sera relevée et comparée sur le JSON rapatrié. |

Le script [collect-m03-gpo-clients.ps1](../scripts/collect-m03-gpo-clients.ps1) vérifie le domaine et le chemin du partage, puis inventorie en lecture seule les GPO et leurs permissions, les liens au domaine et à `OU=Postes`, les droits SMB, les ACL NTFS et les membres récursifs de `DL_CLIENTS_MODIFY`. Une première exécution a révélé que `Get-GPPermission` ne fournissait pas `TrusteeType` sur ce serveur ; le script a été corrigé pour accepter ce champ facultatif, puis les deux collectes ci-dessus ont abouti. Le script ne modifie aucun droit ni aucune GPO.

## Chaîne de preuves à achever

Les JSON sont sur `CC-DC01` dans `C:\Audit\M-CLIENT-01`. La tentative de copie s'est arrêtée avant le transfert : `Test-Path` a indiqué « coffre introuvable » dans la session PowerShell de l'opérateur. Une inspection locale du 4 novembre a trouvé le coffre `C:\Users\pissa\AppData\Local\CyberCorp\preuves\M-CLIENT-01` et son registre sur l'hôte, mais **aucune pièce M03 dans ce coffre ni dans son registre**. L'écart entre les deux observations reste à diagnostiquer ; il ne faut pas déclarer les rapports archivés.

1. Vérifier dans la session de l'opérateur la machine, l'utilisateur et le chemin local du coffre.
2. Copier les deux JSON depuis `CC-DC01` vers un emplacement de transfert dans le coffre restreint, puis recalculer leurs SHA-256 et confirmer `False` puis `True` dans le contenu.
3. Enregistrer chaque JSON avec [enregistrer-preuve.ps1](../scripts/enregistrer-preuve.ps1), `-Etape gpo`, `-Source CC-DC01`, `-Outil PowerShell`, en décrivant la collecte et son état dans `-Action`. Vérifier les identifiants et empreintes ajoutés au registre.
4. Conserver les rapports bruts dans le coffre. Toute capture ou extrait destiné à la remise doit être expurgé et relu selon le [protocole](protocole-preuves.md).

## Revue et décision encore nécessaires

1. Comparer propriétaires, délégations et liens des quatre GPO au rapport GPOZaurr T10 et au besoin métier. Croiser avec `gpresult` sur `CC-W11-01` ; l'application d'une stratégie ne valide pas sa gouvernance.
2. Comparer les droits SMB et NTFS de `Clients` et de `Livraison`, ainsi que les membres de `DL_CLIENTS_MODIFY`, à la matrice d'accès prévue.
3. Réaliser depuis `CC-W11-01` un test de modification autorisée et un refus attendu avec deux comptes métier distincts. Consigner l'identité, l'heure, le résultat et une preuve native ; la liste des membres ne démontre pas l'accès effectif.
4. Renseigner la [fiche M-CLIENT-01](fiche-m-client-01.md) et la [recette](../config/recette.csv) après qualification et éventuel contre-test. La présence du dossier n'établit pas l'existence du livrable PDF ni l'autorisation de remise.
