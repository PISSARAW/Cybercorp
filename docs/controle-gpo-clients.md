# M-CLIENT-01 — contrôle M03 des GPO et du dossier `Clients`

**État au 6 novembre 2026 : deux JSON M03 et le rapport GPOZaurr archivés et inscrits au registre ; C05 finalisée côté preuves.** Les empreintes source/copie, les fichiers dans `brut` et les lignes du registre ont été contrôlés. Les JSON confirment `False → True`. C05 illustre les propriétaires AD/SYSVOL des quatre GPO et référence le rapport enregistré. Les différences sur les deux GPO natives et les erreurs de `GPOPermissions` restent à qualifier ; C06 (`gpresult`) et les accès métier restent à réaliser. L'arrêt du DC a été attribué à une expiration de licence par le journal invité ; l'activation a échoué sur une résolution de nom. Aucune validation complète de M03 ni décision de remise n'en découle.

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
| Archivage dans le coffre | Réalisé le 6 novembre : `M-CLIENT-01_gpo_20261106T085819590Z_CC-DC01_GPOZaurr`, fichier et registre contrôlés à `09:01:48.2857109Z`. |
| Capture C05 | Réalisée depuis le HTML archivé sur l'hôte, enregistrée au registre et contrôlée à `2026-11-06T12:34:36.9662086Z`. |

Le 6 novembre à `08:51:11.4463257Z`, le fichier retrouvé sur le DC présentait la même taille et la même empreinte que le 5 novembre. Il a été copié dans `transfert\GPOZaurr-20261105T093146410Z\GPOZaurr-M03.html`, sous le coffre, puis inscrit au registre et contrôlé dans `brut`. Les deux JSON enregistrés précédemment ont été conservés.

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

### Rapport et C05 archivés le 6 novembre

Les pièces suivantes sont dans le coffre `C:\Users\pissa\AppData\Local\CyberCorp\preuves\M-CLIENT-01`, hors Git et OneDrive :

| Pièce | Identifiant du registre | Taille (octets) | SHA-256 vérifié |
| --- | --- | --- | --- |
| Rapport GPOZaurr | `M-CLIENT-01_gpo_20261106T085819590Z_CC-DC01_GPOZaurr` | 3980516 | `8CDA26993471BC692A85F8F46D77C0F5E8C2A388DFC0FA03FE72CA4035864314` |
| C05 — tableau des propriétaires | `M-CLIENT-01_gpo_20261106T122808572Z_MONNOKOELOBA_CaptureEcran` | 115043 | `4651F40E122498EA6CD7F03AEB49F8372EF7DDDB80E3BDCE9354045B2ED32177` |

- Le rapport est dans `brut\M-CLIENT-01_gpo_20261106T085819590Z_CC-DC01_GPOZaurr.html`. L'événement du registre reste le début réel de l'audit, `2026-11-05T09:31:46.4100267Z` ; la collecte au coffre date du 6 novembre. L'action mentionne explicitement l'analyse partielle de `GPOPermissions` et les erreurs SID/GUID. Le contrôle à `2026-11-06T09:01:48.2857109Z` a confirmé une ligne unique, le chemin sous `brut`, la taille, le SHA-256 et l'heure d'événement (`RegistreConforme=True`).
- Le rapport archivé a été ouvert localement sur l'hôte. La capture retenue montre la section **Group Policy Owners**, les quatre GPO, les propriétaires AD/SYSVOL, les SID et les valeurs de cohérence : deux lignes natives à `False`, deux lignes CyberCorp à `True`. Le libellé `NotAdministrative` de l'outil reste assorti de la qualification exposée ci-dessus ; aucune correction suggérée par le rapport n'a été exécutée dans les opérations suivies.
- L'image originale a été rangée dans `captures\M-CLIENT-01_C05_20261106T122346_HOTE.png`, à `2026-11-06T12:23:46.5768283Z`, puis enregistrée comme `Brut`, source `MONNOKOELOBA`, outil `CaptureEcran`. La copie enregistrée est `brut\M-CLIENT-01_gpo_20261106T122808572Z_MONNOKOELOBA_CaptureEcran.png`.
- L'heure exacte de prise de vue n'étant pas connue, `evenement_utc` est volontairement vide pour C05. L'horodatage du nom initial correspond au rangement ; il ne doit être assimilé ni à l'heure de l'audit ni à une heure de capture démontrée. L'action du registre cite l'identifiant du rapport GPOZaurr.
- À `2026-11-06T12:34:36.9662086Z`, la relecture du registre a confirmé une ligne unique pour C05 et pour son rapport de référence, le chemin sous `brut`, la taille, le SHA-256 de l'image, le lien contenu dans l'action et l'absence d'heure d'événement inventée (`RegistreConforme=True`). **La traçabilité de C05 est finalisée.** La capture et le rapport demeurent des pièces brutes ; leur présence ne valide pas à elle seule toutes les GPO ni les accès métier, et ne constitue pas une version expurgée destinée à la remise.

### Arrêt du DC — cause établie, activation non résolue

Le DC était de nouveau `Running` lors du contrôle du 6 novembre à `08:46:09.6346304Z`, avec le coffre accessible et 1,71 Gio libres sur l'hôte. Une nouvelle session PowerShell Direct a confirmé `cybercorp\administrateur` et `CC-DC01` à `08:48:35.3302312Z`. Les anciennes variables de l'audit en mémoire n'ont pas été réutilisées pour reconstruire C05 : le fichier HTML déjà produit a été retrouvé puis archivé.

La lecture du journal `System` du DC a établi le motif de l'arrêt du 5 novembre :

| Événement | Heure UTC | Observation |
| --- | --- | --- |
| 1074, `User32` | `2026-11-05T09:59:51.9188700Z` | `C:\Windows\system32\wlms\wlms.exe` a demandé l'arrêt sous Système ; le commentaire indique que la période de licence Windows a expiré. |
| 6006, `EventLog` | `2026-11-05T09:59:52.6555508Z` | Le service de journalisation a été arrêté. |
| 18508, journal Hyper-V de l'hôte | `2026-11-05T09:59:57.6873493Z` | Le système invité a arrêté la VM, comme déjà observé le 5 novembre. |

L'arrêt observé est donc lié à la licence. Le manque de mémoire de l'hôte constituait un obstacle distinct au redémarrage ; il n'est pas le motif donné par l'événement 1074.

Les lectures `SoftwareLicensingProduct` et `slmgr.vbs /dlv` ont donné :

| Champ | Valeur relevée |
| --- | --- |
| Édition | Windows Server 2025 Standard Evaluation, `ServerStandardEval`, canal `TIMEBASED_EVAL` / `Retail:TB:Eval` |
| Installation UTC | `2026-10-13T16:32:13Z` |
| Dernier démarrage au premier relevé de licence | `2026-11-06T08:33:24.9169850Z` ; un redémarrage ultérieur a ensuite été annoncé par l'opérateur. |
| État de licence | `LicenseStatus=5`, notification |
| Motif | `0xC004F009`, délai de grâce expiré |
| Grâce restante | 0 minute |
| Réinitialisations restantes | Windows : 1 ; SKU : 1, au relevé `/dlv` |
| `EvaluationEndDate` affiché | `01/01/1601 01:00:00` ; cette valeur ne fournit pas une échéance réelle exploitable de l'évaluation. |

Ces observations ne démontrent pas à elles seules que les 180 jours de l'évaluation ont été consommés. Microsoft indique que l'évaluation doit être activée dans les dix premiers jours pour éviter les arrêts automatiques : [Evaluation Center](https://www.microsoft.com/en-us/evalcenter/evaluate-windows-server-2025). Le code `0xC004F009` et les options de diagnostic/activation sont décrits dans les [codes d'activation](https://learn.microsoft.com/fr-fr/troubleshoot/windows-server/licensing-and-activation/troubleshoot-activation-error-codes) et la [référence Slmgr](https://learn.microsoft.com/en-us/windows-server/get-started/activation-slmgr-vbs-options).

Une tentative d'activation Microsoft `/ato` de l'édition installée a échoué avec `0x80072EE7`, erreur de résolution de nom. Le contrôle DNS effectué sur le DC a montré : interface `Ethernet`, DNS client `127.0.0.1`, aucun redirecteur affiché, `UseRootHint=True`, `Timeout=3`. La requête DNS de type A pour `activation-v2.sls.microsoft.com.` a expiré (`ERROR_TIMEOUT`). Le DNS local du DC n'a pas été remplacé et aucune règle réseau, carte ou liaison WAN n'a été modifiée dans les commandes suivies. Aucun `/rearm` n'a été exécuté dans cette séquence ; une activation réussie et la fin des arrêts automatiques ne sont pas démontrées. L'absence de redirecteur avec recours aux indications de racine ne suffit pas à établir une erreur de configuration ; l'accès à la résolution externe reste à examiner selon une maintenance autorisée.

Les événements et sorties de licence/DNS ont été communiqués en console ou par capture ; leur export natif et leur inscription au registre ne sont pas confirmés à ce stade. C05 et le rapport GPOZaurr, eux, sont archivés et vérifiés.

### Interruption et point de reprise

**Point actuel : C06, avant le démarrage de `CC-W11-01`.** Le dernier relevé communiqué le 6 novembre, après le contrôle final de C05, ne comporte pas d'horodatage dans sa sortie :

| VM | État | RAM affectée (Gio) | RAM de démarrage (Gio) |
| --- | --- | --- | --- |
| `CC-DC01` | `Running` | 1,28 | 2 |
| `CC-W11-01` | `Off` | 0 | 1 |
| `CC-PFS01` | `Saved` | 0 | 1 |
| `CC-KALI01` | `Off` | 0 | 1 |

L'hôte dispose alors de **1,73 Gio libres**. Ajouter les 1 Gio de démarrage du poste ne laisserait théoriquement que **0,73 Gio**, sous la marge requise de 1,5 Gio. Il faut au minimum 2,5 Gio libres avant ce démarrage, soit **0,77 Gio supplémentaires**, puis contrôler la marge réelle après démarrage. Ce calcul est une estimation préalable ; les allocations réelles et la mémoire libre varient.

Reprendre **une seule action et ses commandes PowerShell à la fois**, puis attendre la sortie :

1. Après sauvegarde de tout autre travail ouvert dans Edge et l'Outil Capture, fermer ces applications maintenant que C05 est archivée ; relever la mémoire libre et l'état du DC. **Aucun démarrage de W11 n'est encore confirmé.**
2. Si le DC fonctionne et si la mémoire permet d'ajouter le poste tout en conservant 1,5 Gio pour l'hôte, démarrer uniquement `CC-W11-01`, puis mesurer la marge réelle. Laisser Kali arrêtée et pfSense dans son état actuel tant qu'aucun besoin distinct n'est établi ; le trafic DC/poste sur `CC-LAN` ne traverse pas pfSense. Ne modifier aucune règle ni connexion WAN pour cette étape.
3. Vérifier l'identité et le contexte d'administration du poste, contrôler sa communication avec le DC, puis préparer un nouveau `gpresult` daté. Les comptes d'administration du domaine sont refusés à l'ouverture de session sur le poste par la GPO documentée ; utiliser le compte local de secours autorisé pour l'administration et distinguer ce contexte des futurs comptes métier de test.
4. Produire et examiner le rapport C06, puis le rapatrier, comparer les SHA-256, l'enregistrer et prendre la capture pertinente. La présence de liens ou un rapport du 20 octobre ne prouvent pas l'application actuelle sur le poste.
5. Poursuivre C07–C09 (ACL/SMB, appartenances et essais métier), la qualification des différences GPO et des erreurs du rapport. Conserver séparément le suivi de l'activation : les lectures ponctuelles restent possibles, mais la stabilité durable du DC ne peut pas être validée tant que les arrêts persistent.

Les étapes relatives au registre et à C05 ne doivent pas être rejouées : leurs identifiants sont consignés ci-dessus. En cas de nouvelle rupture ou de redémarrage du DC, recréer la session PowerShell Direct et vérifier l'identité avant les commandes distantes. Les captures C06–C09 et les essais métier ne sont pas déclarés acquis.

## Revue et décision encore nécessaires

1. Conserver les identifiants du rapport et de C05 déjà archivés ; poursuivre C06 (`gpresult` sur `CC-W11-01`) après préparation du budget mémoire. Terminer la qualification des différences sur les deux GPO natives et des erreurs de `GPOPermissions`, et archiver les contrôles natifs complémentaires. L'application d'une stratégie ne valide pas à elle seule sa gouvernance.
2. Comparer les droits SMB et NTFS de `Clients` et de `Livraison`, ainsi que les membres de `DL_CLIENTS_MODIFY`, à la matrice d'accès prévue.
3. Réaliser depuis `CC-W11-01` un test de modification autorisée et un refus attendu avec deux comptes métier distincts. Consigner l'identité, l'heure, le résultat et une preuve native ; la liste des membres ne démontre pas l'accès effectif.
4. Renseigner la [fiche M-CLIENT-01](fiche-m-client-01.md) et la [recette](../config/recette.csv) après qualification et éventuel contre-test. La présence du dossier n'établit pas l'existence du livrable PDF ni l'autorisation de remise.
