# M-CLIENT-01 — contrôle M03 des GPO et du dossier `Clients`

**État au 5 novembre 2026 : deux collectes exécutées sur `CC-DC01`, rapatriées et inscrites au registre ; revue GPO engagée, à terminer.** Les commandes et captures communiquées par l'opérateur établissent les observations ci-dessous. Les SHA-256 des copies concordent avec les sources ; le registre et les fichiers dans `brut` ont été contrôlés. Les JSON confirment `False → True`. Un rapport GPOZaurr actualisé a été produit et des contrôles natifs réalisés ; ses erreurs, son archivage restant et l'arrêt du DC empêchent une conclusion complète. Les accès effectifs et la remise ne sont pas validés.

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

## Revue GPO du 5 novembre — procédure B engagée

### Rapport actualisé et portée

Les deux pièces T10 ont été retrouvées sur le DC dans `C:\Audit\T10` : `GPOZaurr-CC-DC01.html` et `Inventaire-GPO.csv`, toutes deux datées du 20 octobre. Pour disposer d'une observation actuelle, GPOZaurr **1.1.13**, installé sous `C:\Program Files\WindowsPowerShell\Modules\GPOZaurr\1.1.13`, a été exécuté en lecture seule sur `ad.cybercorp.test` :

```powershell
# Trace de l'audit deja execute : ne pas relancer sur ce fichier existant.
Invoke-GPOZaurr `
    -Type GPOBroken, GPOOwners, GPOConsistency, GPOList, GPOLinks, GPOPermissions, GPOOrganizationalUnit `
    -IncludeDomains 'ad.cybercorp.test' `
    -FilePath 'C:\Audit\M-CLIENT-01\GPOZaurr-20261105T093146410Z\GPOZaurr-M03.html' `
    -HideHTML -ShowError -ShowWarning -PassThru -ErrorAction Stop
```

| Métadonnée | Valeur observée sur le DC |
| --- | --- |
| Début UTC | `2026-11-05T09:31:46.4100267Z` |
| Fin UTC | `2026-11-05T09:32:16.8774581Z` |
| Rapport source | `C:\Audit\M-CLIENT-01\GPOZaurr-20261105T093146410Z\GPOZaurr-M03.html` |
| Taille | 3980516 octets |
| SHA-256 source affiché | `8CDA26993471BC692A85F8F46D77C0F5E8C2A388DFC0FA03FE72CA4035864314` |
| Archivage dans le coffre | Non confirmé : aucun transfert ni identifiant de registre pour ce nouveau rapport à ce stade. |
| Capture C05 | À finaliser et à ranger ; la commande de synthèse prévue a été refusée car la session était `Broken`. |

Le rapport est une pièce produite sur le DC, pas encore une pièce archivée et contrôlée dans le coffre. L'empreinte ci-dessus devra être comparée au fichier retrouvé puis à sa copie, sans remplacer les deux JSON déjà enregistrés.

### Propriétaires, cohérence et délégations observés

`GPOBroken` ne signale aucune GPO sans correspondant AD/SYSVOL, aucune mauvaise classe d'objet et aucune GPO non évaluée pour défaut de permission dans cette catégorie. `GPOList` dénombre quatre GPO, actives (`AllSettingsEnabled`), sans GPO vide, désactivée ou non liée signalée. Ces résultats portent sur ces catégories seulement.

| GPO | Propriétaire AD | Propriétaire SYSVOL | Propriétaires concordants | `ACLConsistent` / `ACLConsistentInside` |
| --- | --- | --- | --- | --- |
| `CC-Domaine-Comptes` | `CYBERCORP\Admins du domaine` | `CYBERCORP\Admins du domaine` | `True` | `True` / `True` |
| `CC-Postes-Securite` | `CYBERCORP\Admins du domaine` | `CYBERCORP\Admins du domaine` | `True` | `True` / `True` |
| `Default Domain Policy` | `CYBERCORP\Admins du domaine` | `BUILTIN\Administrators` | `False` | `False` / `False` |
| `Default Domain Controllers Policy` | `CYBERCORP\Admins du domaine` | `BUILTIN\Administrators` | `False` | `False` / `False` |

Le SID du propriétaire AD se termine par `-512` ; celui du propriétaire SYSVOL des deux GPO natives est `S-1-5-32-544`. Les lectures natives `Get-GPO` et `Get-Acl` ont confirmé ces propriétaires. Le libellé GPOZaurr `NotAdministrative` sur ces deux GPO ne prouve pas un propriétaire non privilégié : `BUILTIN\Administrators` désigne bien un groupe administratif. Voir la [référence Microsoft des SID](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/manage/understand-security-identifiers). La différence de propriétaire est établie ; sa non-conformité au référentiel et la cause exacte des indicateurs de cohérence restent à qualifier.

La catégorie `GPOPermissions` contient **huit erreurs de conversion de SID en `System.Guid`** (`RuntimeException`), notamment pour `S-1-5-11`, les groupes administratifs `-512` et `-519`, `S-1-5-9` et `S-1-5-18`. Les valeurs `PermissionIssue=False` ou `Status=True` de cette catégorie ne suffisent donc pas à déclarer son analyse complète. L'erreur de conversion JSON rencontrée lors d'un affichage de synthèse est distincte de ces erreurs présentes dans le résultat de l'audit. La cause logicielle de ces erreurs n'a pas été diagnostiquée ni corrigée.

Un contrôle indépendant par `Get-GPPermission -All`, affiché à `2026-11-05T09:53:39.4525959Z`, a donné :

| Bénéficiaire | Deux GPO CyberCorp | Deux GPO natives |
| --- | --- | --- |
| Utilisateurs authentifiés | `GpoApply` | `GpoApply` |
| Admins du domaine | `GpoEditDeleteModifySecurity` | `GpoCustom` |
| Administrateurs de l'entreprise | `GpoEditDeleteModifySecurity` | `GpoCustom` |
| Système | `GpoEditDeleteModifySecurity` | `GpoEditDeleteModifySecurity` |
| Enterprise Domain Controllers | `GpoRead` | `GpoRead` |

Toutes les entrées affichées par cette commande ont `Inherited=False`. Le détail des ACE AD des bénéficiaires `GpoCustom`, lu avec `Get-ADObject -Properties nTSecurityDescriptor`, montre des autorisations `Allow` pour les SID `-512` et `-519` : `CreateChild`, `Self`, `WriteProperty`, `GenericRead`, `WriteDacl`, `WriteOwner` sur l'objet, et des droits supplémentaires `DeleteChild`, `DeleteTree`, `Delete` sur les descendants. Aucun refus n'est affiché dans les ACE filtrées pour ces bénéficiaires. `GpoCustom` ne signifie donc pas une absence de droit de modification. Cette lecture ciblée ne constitue pas une analyse exhaustive de toutes les ACL et de tous les fichiers SYSVOL.

### Liens et héritage contrôlés nativement

`Get-GPInheritance` a été lu sur les trois emplacements à `09:58:48 UTC`. Les liens affichés sont tous activés, non forcés ; aucun des trois emplacements ne bloque l'héritage.

| Emplacement | Liens directs et ordre local | Liste retenue par la configuration d'héritage, par priorité |
| --- | --- | --- |
| Domaine `ad.cybercorp.test` | `CC-Domaine-Comptes` : 1 ; `Default Domain Policy` : 2 | `CC-Domaine-Comptes`, `Default Domain Policy` |
| `OU=Domain Controllers` | `Default Domain Controllers Policy` : 1 | `Default Domain Controllers Policy`, `CC-Domaine-Comptes`, `Default Domain Policy` |
| `OU=Postes,OU=CyberCorp` | `CC-Postes-Securite` : 1 | `CC-Postes-Securite`, `CC-Domaine-Comptes`, `Default Domain Policy` |

La liste `InheritedGpoLinks` comprend aussi des liens directs ; son ordre ne doit pas être confondu avec la colonne `Order`, qui décrit l'ordre du lien sur son emplacement source. Ces observations correspondent aux liens documentés. L'application effective au poste, avec ses filtres et son contexte, reste à contrôler par `gpresult` (C06). Voir [Get-GPInheritance](https://learn.microsoft.com/en-us/powershell/module/grouppolicy/get-gpinheritance?view=windowsserver2025-ps).

**Qualification à ce stade :** différences de propriétaires et indicateurs de cohérence AD/SYSVOL sur les deux GPO natives, à qualifier ; analyse GPOZaurr des permissions partiellement en erreur, complétée par des lectures natives. Aucun changement de propriétaire, d'ACL ou de GPO n'a été appliqué. La revue M03 complète reste **non démontrée** ; aucun nouveau résultat de recette n'est validé sur cette base. Les contrôles natifs ont été consultés en console et transmis par captures ; aucun export de ces contrôles inscrit au registre n'est confirmé à ce stade.

### Interruption et point de reprise

- La session PowerShell Direct `$s` (`WinRM4`) est devenue `Broken`. Le dernier état Hyper-V observé du DC est `Off`.
- Le journal hôte `Microsoft-Windows-Hyper-V-Worker-Admin` indique un démarrage du système invité à `08:59:39.2143588Z` (événement 18601), puis un arrêt **par le système d'exploitation invité** à `09:59:57.6873493Z` (événement 18508). Ce journal n'établit ni le processus ni le motif de l'arrêt. Une cause liée à la licence ou à la mémoire n'est pas démontrée ; lire le journal `System` du DC après redémarrage, notamment l'événement 1074 s'il est présent.
- Les tentatives de redémarrage ont été annulées par le contrôle préalable de mémoire, avant `Start-VM`. Un relevé transitoire à 5,62 Gio libres n'a pas été confirmé au démarrage. Le dernier relevé complet à `2026-11-05T10:27:00.2662781Z` montre `Off`, 2,64 Gio libres, 2 Gio de démarrage et seulement 0,64 Gio de marge prévue, sous les 1,5 Gio requis.
- L'opérateur a confirmé pouvoir suivre les instructions sur son téléphone et fermer ChatGPT sur l'hôte, tout en gardant PowerShell ouvert. **Le bloc de démarrage proposé après ce changement de contexte n'a pas encore de sortie confirmée.** Ne pas déclarer le DC redémarré.
- Une nouvelle session PowerShell Direct sera nécessaire. Les variables distantes `$script:auditM03GpoZaurr` et `$script:rapportM03GpoZaurr` ne doivent pas être supposées disponibles après l'arrêt du DC ; utiliser le chemin du rapport consigné ci-dessus et vérifier le fichier sur disque.

Reprendre **une seule action et ses commandes PowerShell à la fois**, puis attendre la sortie de l'opérateur :

1. Depuis le téléphone, après fermeture de ChatGPT sur l'hôte, exécuter le bloc de démarrage déjà fourni : vérifier `Off`, recalculer la mémoire libre et la marge après les 2 Gio de démarrage, n'allumer que `CC-DC01` si la marge prévue atteint au moins 1,5 Gio, puis afficher l'état de la VM et la mémoire libre réelle. Ne pas allumer les autres VM à ce stade.
2. Si le démarrage et la marge sont confirmés, ouvrir une **nouvelle** session PowerShell Direct, confirmer `hostname` et `whoami`, puis examiner le motif de l'arrêt dans les événements du DC.
3. Retrouver le rapport HTML au chemin exact ci-dessus, contrôler taille et SHA-256 contre les valeurs affichées avant l'arrêt, puis le rapatrier sans écrasement dans le coffre hors Git et OneDrive. Ne pas relancer l'audit pour tenter de retrouver une variable en mémoire ; examiner d'abord le fichier déjà produit.
4. Comparer le SHA-256 source/copie, enregistrer le rapport avec `-Etape gpo -Source CC-DC01 -Outil GPOZaurr`, une action qui mentionne l'analyse partielle et les erreurs SID/GUID, et `-EvenementUtc '2026-11-05T09:31:46.4100267Z'` (début observé de l'audit). Conserver l'identifiant produit et contrôler le registre.
5. Finaliser C05 à partir du rapport et des constats réellement conservés, y faire apparaître les limites de l'analyse et la conserver dans le coffre. Archiver les contrôles natifs complémentaires avec leur source et leur date. Reprendre ensuite `gpresult` et les essais métier, après vérification du budget mémoire du profil nécessaire.

**Prochaine action proposée à l'opérateur, pas encore confirmée :** fermer ChatGPT sur l'hôte, garder PowerShell ouvert et suivre l'échange sur téléphone, puis exécuter uniquement ce bloc et transmettre sa sortie avant toute autre action :

```powershell
& {
    $ErrorActionPreference = 'Stop'
    $dc = Get-VM -Name 'CC-DC01'
    $libre = (Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory * 1KB
    $marge = $libre - $dc.MemoryStartup

    if ($dc.State -ne 'Off') {
        throw "Etat du DC different de Off : $($dc.State)"
    }
    if ($marge -lt 1.5GB) {
        throw ("Demarrage annule : marge prevue de {0:N2} Gio." -f ($marge / 1GB))
    }

    Start-VM -Name 'CC-DC01'
    Start-Sleep -Seconds 15

    Get-VM -Name 'CC-DC01' |
        Select-Object Name, State,
            @{Name='RAM_Gio'; Expression={
                [math]::Round($_.MemoryAssigned / 1GB, 2)
            }} |
        Format-List

    Get-CimInstance Win32_OperatingSystem |
        Select-Object @{Name='MemoireLibre_Gio'; Expression={
            [math]::Round($_.FreePhysicalMemory / 1MB, 2)
        }} |
        Format-List
}
```

## Revue et décision encore nécessaires

1. Terminer la qualification des différences sur les deux GPO natives et des erreurs de `GPOPermissions`, archiver le rapport actualisé et les contrôles natifs, puis finaliser C05. Croiser avec `gpresult` sur `CC-W11-01` ; l'application d'une stratégie ne valide pas sa gouvernance.
2. Comparer les droits SMB et NTFS de `Clients` et de `Livraison`, ainsi que les membres de `DL_CLIENTS_MODIFY`, à la matrice d'accès prévue.
3. Réaliser depuis `CC-W11-01` un test de modification autorisée et un refus attendu avec deux comptes métier distincts. Consigner l'identité, l'heure, le résultat et une preuve native ; la liste des membres ne démontre pas l'accès effectif.
4. Renseigner la [fiche M-CLIENT-01](fiche-m-client-01.md) et la [recette](../config/recette.csv) après qualification et éventuel contre-test. La présence du dossier n'établit pas l'existence du livrable PDF ni l'autorisation de remise.
