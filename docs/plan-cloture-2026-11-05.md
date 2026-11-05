# CyberCorp — guide de clôture du projet, 5 novembre 2026

**Objet.** Donner à l'opérateur un déroulé complet pour terminer le dossier M-CLIENT-01 et la recette T01–T15 : préparation, VM nécessaires, outils, personnes, actions, captures, preuves, dépendances et décision. Ce guide décrit le travail à réaliser ; une case à faire n'est pas un résultat. Les heures ci-dessous servent à organiser la journée du **jeudi 5 novembre 2026**, fuseau `Europe/Paris`. La fenêtre de scan doit être fixée et approuvée séparément dans la [fiche de décision](fiche-m-client-01.md).

**Règle de clôture.** À la fin de la journée, chaque exigence porte l'un des états `Validé avec pièce`, `Écart à corriger`, `Non démontré` ou `Hors fenêtre/autorisation`. La direction choisit `poursuivre`, `corriger puis contre-tester` ou `suspendre` pour la remise. Un dossier final peut être rendu avec une décision de suspension motivée ; aucune capture ni ancien essai ne transforme un contrôle manquant en validation.

## 1. État connu avant la journée

| Sujet | État au 4 novembre | Action restante |
| --- | --- | --- |
| M01 — mandat | Cadrage écrit ; fenêtre proposée du 3 novembre dépassée ; approbation non documentée. | Nommer le demandeur, le décideur, l'opérateur, le motif, le livrable, une nouvelle fenêtre et l'accord écrit. |
| M02 — topologie | Conftest V01–V05 : PASS sur l'export réel du 1er novembre, FAIL sur cinq copies fautives ; T01–T02 validés pour cet instant. | Relancer sur un export frais avant toute exception, contrôler la carte WAN et les cartes Hyper-V. |
| M03 — GPO et dossier | Deux JSON produits sur `CC-DC01` : `M03-GPO-Clients-20261101T202134.json` avec `MandateFolderExists=False`, puis `M03-GPO-Clients-20261102T065842.json` avec `True`. `CL-2026-014\Livraison` a été créé ; trois règles NTFS héritées observées. | Rapatrier les JSON, comparer les SHA-256, les enregistrer ; revoir GPOZaurr et `gpresult` ; tester SMB avec deux comptes. |
| M04 — exception réseau | S01 du 20 octobre a montré l'état autorisé et le retour au blocage ; le premier XML bloqué a été écrasé. | Nouvelle campagne avec trois XML distincts, deux Ndiff, règles pfSense datées et preuve de retrait, uniquement après accord. |
| M05–M06 — signal poste | Sysmon et Hayabusa ont fonctionné sur un essai du 20 octobre ; T12–T13 restent à faire pour le mandat. | Action bénigne sur copie de contrôle, EVTX, SHA-256, événement source, chronologie et qualification. |
| T14–T15 — reprise | Sauvegarde indépendante et restauration non démontrées. | Tester sur une copie distincte si un support et une sauvegarde valides existent ; sinon constater la lacune. |
| Preuves M03 | Le coffre local existe dans une inspection de l'hôte, mais la session de l'opérateur a répondu « coffre introuvable » ; aucune pièce M03 n'est inscrite au registre. | Diagnostiquer le contexte de session avant le transfert. |

Références : [mission](mission-securite.md), [architecture et mémoire](architecture.md), [outils](outillage-securite.md), [protocole de preuve](protocole-preuves.md), [M03](controle-gpo-clients.md), [recette](../config/recette.csv), [journal](journal-deploiement.md).

## 2. Personnes et décisions

| Fonction | Qui intervient | Ce qu'il signe ou produit |
| --- | --- | --- |
| Demande métier | Direction des opérations, personne à confirmer dans la fiche. | Motif de la remise et de l'éventuelle exception, dossier concerné et échéance. |
| Responsable de décision | Direction générale, personne et accord à confirmer. | Autorisation écrite de la fenêtre puis décision finale de remise. L'annexe du rapport ne vaut pas signature. |
| Opérateur | Administrateur du projet, identité réelle à inscrire. | Commandes, changements, retrait des règles, horodatages, exports et registre. |
| Relecteur | Seconde personne nommée dans le registre ou la fiche. | Relecture des extraits expurgés et des conclusions. |
| Comptes métier de test | Un membre effectif de `DL_CLIENTS_MODIFY` et un non-membre, à vérifier dans AD. | Essai positif et essai négatif sur le chemin UNC exact. `usr.com01` et `usr.fin01` sont des candidats, pas une preuve d'appartenance. |

Si l'opérateur tient aussi le rôle de demandeur dans l'exercice, l'indiquer explicitement. Ne pas attribuer une approbation à une personne sans trace datée.

## 3. Profils de VM et bascules

L'hôte possède 16 Gio ; ne pas allumer les quatre VM ensemble. Relever la mémoire libre avant chaque bascule et garder au moins 1,5 Gio pour l'hôte. Une VM `Off` n'est pas une preuve que son interface ou une règle pfSense est conforme : contrôler les cartes et les règles séparément.

| Profil | VM allumées | VM éteintes | Utilisation |
| --- | --- | --- | --- |
| Hôte seul | Aucune exigée | Selon état | Coffre, registre, documentation, Conftest sur export Hyper-V, analyse Hayabusa hors ligne. |
| Administration DC | `CC-DC01` | Kali et W11 si mémoire limitée | Transfert M03, GPOZaurr, groupes, ACL, DNS/AD, santé `dcdiag`. pfSense seulement si un flux est nécessaire. |
| Métier | `CC-PFS01`, `CC-DC01`, `CC-W11-01` | `CC-KALI01` | `gpresult`, tests SMB, Sysmon sur le poste, T05–T09 et T12–T13. LAN et poste sont sur `CC-LAN` ; leur trafic ne traverse pas pfSense. |
| Audit serveur | `CC-PFS01`, `CC-DC01`, `CC-KALI01` | `CC-W11-01` | M04 : Nmap/Ndiff vers le DC. WAN pfSense déconnecté ; Kali seulement sur `CC-AUDIT`. |
| Reprise | VM indispensables au test ou clone isolé | Kali et W11 sauf besoin démontré | T14/T15 sur une sauvegarde indépendante. Ne pas restaurer par-dessus le DC actif. |

Avant chaque profil : noter heure, VM, mémoire libre, commutateurs, cartes et état du WAN. Capture **C01**. Avant de quitter un profil : exporter les preuves encore dans les VM, puis arrêter proprement les VM devenues inutiles.

## 4. Ce soir, 4 novembre — préparation indépendante des tests

1. **Rassembler les supports.** Ouvrir la fiche M-CLIENT-01, la recette CSV, le journal, le rapport GPOZaurr T10, le `gpresult` existant, le collecteur M03, la politique Conftest et la configuration Sysmon. Vérifier les chemins et versions sans en changer le contenu.
2. **Obtenir les informations qui bloquent demain.** Faire renseigner demandeur, décideur, motif et nouvelle fenêtre dans la fiche. L'accord doit identifier la source `CC-KALI01` (`10.77.20.50`), la cible `CC-DC01` (`10.77.10.10`), TCP `53,88,389,445`, le début, la fin, le retrait et le critère d'arrêt. Sans cet accord, M04 reste documentaire.
3. **Préparer le livrable client.** Confirmer son contenu et son responsable. Le chemin `\\CC-DC01\Clients\CL-2026-014\Livraison` existe ; le PDF proposé dans la fiche n'a pas été observé. Préparer le vrai PDF et sa version, puis calculer son SHA-256 quand il est déposé. Ne pas placer de données sensibles dans les captures de soutenance.
4. **Préparer les comptes.** Confirmer dans AD le membre autorisé de `DL_CLIENTS_MODIFY` et un compte non membre ; vérifier leur possibilité de connexion sur `CC-W11-01`. Ne pas employer le compte Administrateur pour prouver un droit métier.
5. **Préparer le support de reprise.** Identifier une copie indépendante utilisable pour T14/T15, son heure et son emplacement. Si elle n'existe pas, noter la dépendance dès maintenant ; un checkpoint Hyper-V sur le même disque ne répond pas à T14/T15.
6. **Préparer les captures.** Créer un dossier de travail temporaire sous le coffre restreint avec les noms `C01` à `C26`. Les images brutes et JSON/EVTX restent hors du dépôt et de OneDrive. Les extraits de présentation sont expurgés, relus et inscrits au registre.

## 5. Demain — ordre critique et budget de temps

Les plages suivantes sont des **créneaux de travail**, pas une autorisation de scan. Déplacer M04 à l'intérieur de la fenêtre réellement approuvée ; si aucune fenêtre n'est signée, consacrer ce créneau à la revue des autres preuves.

| Créneau indicatif | Profil | Travail | Fin de bloc attendue |
| --- | --- | --- | --- |
| 08 h 00–08 h 45 | Hôte + DC | Diagnostic du coffre, rapatriement et registre M03. | Deux JSON hachés, `False → True`, deux identifiants du registre. |
| 08 h 45–10 h 15 | DC puis métier | GPOZaurr, `gpresult`, groupes/ACL, tests SMB positif et négatif. | Constat M03 et captures C04–C09. |
| 10 h 15–11 h 00 | Hôte | Export Hyper-V frais, Conftest, cartes et WAN ; vérifier la fiche signée. | Préconditions M01/M02 et captures C10–C12. |
| Fenêtre approuvée | Audit serveur | Bloqué → autorisé → rebloqué, Ndiff, journaux et retrait des règles. | Trois XML, deux comparaisons, preuve de fermeture. |
| 13 h 30–15 h 30 | Métier | T05–T09, T12–T13 : action bénigne Sysmon, EVTX et export. | Tests métiers et journaux sources. |
| 15 h 30–16 h 30 | Hôte seul | Hayabusa, qualification, enregistrement et expurgation. | Chronologie liée aux événements et aux limites. |
| 16 h 30–18 h 00 | Reprise si support disponible | T14/T15 : restauration sur copie, hashes, ACL, santé et durée. | Résultat de reprise ou lacune documentée. |
| 18 h 00–20 h 00 | Hôte seul | Recalcul des SHA-256, revue de la recette, fiche de décision et rapport. | Dossier final attribué, écarts ouverts et captures sélectionnées. |

## 6. Procédure A — coffre et deux collectes M03

**Suivi opérateur du 5 novembre :** préparation du coffre, transfert des deux JSON, comparaison des SHA-256, contrôle `False → True`, inscription au registre et rangement des captures C02–C04 réalisés. Les [identifiants, empreintes et limites du diagnostic](controle-gpo-clients.md#chaîne-de-preuves--transfert-et-enregistrement-du-5-novembre-2026) sont consignés. L'écart avec l'inspection antérieure reste inexpliqué ; la revue GPO et les accès métier relèvent encore de la procédure B.

**VM :** `CC-DC01` allumée ; Kali et W11 inutiles. **Outil :** PowerShell Direct, `collect-m03-gpo-clients.ps1` déjà exécuté, puis `enregistrer-preuve.ps1`. **Dépendance :** accès au coffre sur la même machine que la session PowerShell de l'opérateur. **Captures :** C02–C04.

1. Sur l'hôte, afficher `$env:COMPUTERNAME`, `whoami`, `$env:LOCALAPPDATA`, puis `Get-Item -LiteralPath 'C:\Users\pissa\AppData\Local\CyberCorp\preuves\M-CLIENT-01' -Force`. Comparer au chemin vu par la session qui a renvoyé « coffre introuvable ». Vérifier que la racine `...\CyberCorp\preuves` a l'héritage ACL désactivé. Ne pas utiliser un autre dossier par commodité.
2. Si nécessaire, rouvrir PowerShell Direct avec `$s = New-PSSession -VMName CC-DC01 -Credential (Get-Credential)` et confirmer `Invoke-Command -Session $s -ScriptBlock { whoami; hostname }`.
3. Copier **sans écraser** les deux fichiers `C:\Audit\M-CLIENT-01\M03-GPO-Clients-20261101T202134.json` et `...20261102T065842.json` via `Copy-Item -FromSession $s` vers un dossier `transfert` créé sous le coffre. Si le coffre est réellement absent sur la machine utilisée, diagnostiquer et protéger ce chemin avant la copie ; ne pas exporter les JSON bruts dans le dépôt.
4. Recalculer `Get-FileHash -Algorithm SHA256` sur chaque copie. La première empreinte affichée sur le DC était `978B4D4A3A273E7E6350C1C5B7593DF2FA70F5F6060EE728AAC5F7E9BEFC4764` ; vérifier la seconde contre la console ou directement contre le fichier source. Lire `clients.mandate_folder_acl.exists` dans les deux JSON : `False` puis `True`.
5. Inscrire les deux fichiers avec `scripts/enregistrer-preuve.ps1`, `-Etape gpo -Source CC-DC01 -Outil PowerShell`. Dans `-Action`, décrire « inventaire M03 avant création du dossier » puis « inventaire M03 après création du dossier ». Fournir `-EvenementUtc` à partir des champs `collected_utc` des JSON, pas de l'heure de copie. Conserver les identifiants produits par le registre.
6. Vérifier la ligne de registre, le chemin `brut`, la taille et le SHA-256 des deux copies. Les captures C02–C04 sont des illustrations ; les JSON et le registre sont les pièces principales.

## 7. Procédure B — GPO, dossier et accès métier

**Suivi opérateur du 5 novembre : revue GPO engagée, interrompue avant C05 et avant archivage du nouveau rapport.** GPOZaurr 1.1.13 a produit un HTML à `09:32:16 UTC` ; des différences de propriétaires/cohérence concernent les deux GPO natives et `GPOPermissions` contient des erreurs SID/GUID. Les délégations, ACE AD ciblées et liens ont été contrôlés nativement, sans correction.

**Interruption :** le DC s'est arrêté à `09:59:57 UTC` par le système invité (événement hôte 18508), motif à établir. Dernier état confirmé à `10:27:00 UTC` : `Off`, 2,64 Gio libres, 2 Gio requis pour démarrer, marge prévue 0,64 Gio ; redémarrage annulé par le garde-fou. L'opérateur prévoit de continuer sur téléphone avec ChatGPT fermé sur l'hôte.

**Reprise immédiate : contrôle mémoire et démarrage de la seule VM DC ; aucune sortie ne confirme encore ce démarrage.** Le [point de reprise détaillé et son bloc PowerShell](controle-gpo-clients.md#interruption-et-point-de-reprise) conservent le chemin et le SHA-256 du rapport à retrouver. Ouvrir ensuite une nouvelle session Direct ; les anciennes variables distantes ne doivent pas être supposées disponibles. Attendre la sortie de chaque action avant de donner la suivante.

**VM :** DC seule pour l'audit GPO ; ensuite profil métier (`CC-PFS01`, `CC-DC01`, `CC-W11-01`). **Outils :** GPOZaurr, commandes AD/GPO natives, ACL/SMB, `gpresult`. **Responsable :** IT. **Captures :** C05–C09. **Indépendance :** réalisable avant la fenêtre réseau.

1. Sur le DC, ouvrir le rapport GPOZaurr T10 et les deux JSON M03. Relever, pour les quatre GPO, propriétaire, droits de modification, liens directs/hérités, état et toute incohérence AD/SYSVOL. Qualifier **un écart précis** ou « aucun écart observé dans ces catégories » ; ne pas extrapoler à tout AD. Si le rapport T10 est trop ancien pour une conclusion actuelle, relancer GPOZaurr en lecture seule et hacher le nouveau rapport. C05.
2. Sur le poste, exécuter `gpupdate /force` si autorisé puis produire un nouveau `gpresult /h` daté. Vérifier l'application de `CC-Postes-Securite`, `CC-Domaine-Comptes` et des GPO natives pertinentes. Comparer l'effet du poste à la gouvernance du DC. C06.
3. Sur le DC, relever `Get-SmbShareAccess -Name Clients`, l'ACL de `E:\Partages\Clients\CL-2026-014\Livraison` et les membres récursifs de `DL_CLIENTS_MODIFY`. Les trois ACE NTFS héritées observées donnent contrôle total à Système et Administrateurs, modification à `DL_CLIENTS_MODIFY` ; vérifier à nouveau l'état et les permissions de partage. C07.
4. Sur `CC-W11-01`, ouvrir une session sous le compte métier **membre vérifié** de `DL_CLIENTS_MODIFY`. Montrer `whoami` et l'heure, créer puis relire un fichier de contrôle nommé de façon unique dans `\\CC-DC01\Clients\CL-2026-014\Livraison`. Capturer le succès et conserver le nom, le contenu non sensible et le SHA-256. C08.
5. Fermer cette session, ouvrir une session sous le compte métier **non membre vérifié**. Montrer `whoami` et l'heure, tenter de créer un autre fichier de contrôle au même emplacement. Capturer le refus exact. Un refus de connexion au poste ou une erreur DNS ne prouve pas un refus ACL : résoudre ces causes puis répéter. C09.
6. Supprimer les seuls fichiers de contrôle créés pendant le test après enregistrement des preuves ; documenter l'action. Renseigner la fiche M03 et T08/T09 uniquement pour les scénarios réellement exécutés. Vérifier séparément l'existence et l'empreinte du PDF de livraison.

## 8. Procédure C — Conftest, topologie et préconditions réseau

**VM :** aucune à démarrer pour l'export de configuration ; les VM du profil audit sont ensuite contrôlées. **Outil :** Conftest/OPA sur l'hôte, puis interfaces Hyper-V et pfSense. **Captures :** C10–C12. **Dépendance :** à refaire juste avant M04.

1. Depuis la racine du dépôt, exécuter `scripts/export-hyperv-topology.ps1` avec un `-OutputPath` inédit sous le coffre, puis `scripts/verifier-topologie.ps1 -Topologie <JSON> -DossierRapport <coffre>`. Le script doit donner PASS sur l'export réel et FAIL sur chacune des cinq copies fautives. Conserver JSON, rapport et SHA-256 ; enregistrer via `enregistrer-preuve.ps1 -Etape topologie`. C10–C11.
2. Contrôler dans Hyper-V les cartes de `CC-DC01`, `CC-W11-01` et `CC-KALI01` : une seule chacune ; Kali sur `CC-AUDIT`, DC/W11 sur `CC-LAN` ; aucun switch `External` ou `Default Switch`. Vérifier que la carte WAN de `CC-PFS01` est déconnectée. C12.
3. Contrôler côté pfSense l'interface WAN et les règles AUDIT avant changement. Le PASS de Conftest est un contrôle de l'export Hyper-V ; T03 exige encore une observation de sortie refusée et T04 un refus journalisé dans le périmètre approuvé.

## 9. Procédure D — exception réseau M04

**VM :** `CC-PFS01`, `CC-DC01`, `CC-KALI01` ; `CC-W11-01` éteinte. **Outils :** pfSense, Nmap et Ndiff. **Responsables :** demandeur et décideur pour l'accord, opérateur IT pour la règle et les mesures. **Dépendances impératives :** fiche signée, nouvelle fenêtre en cours, M02 récent conforme, WAN déconnecté, cible et ports confirmés. **Captures :** C13–C19.

1. Avant toute règle, enregistrer l'heure, la table de règles AUDIT, la règle de blocage, l'état WAN et le périmètre approuvé. Depuis Kali, exécuter **une seule cible** avec `nmap -n -Pn -sT -p 53,88,389,445 -oA MCLIENT01-before 10.77.10.10`. Conserver `.xml`, `.nmap`, `.gnmap` et SHA-256 ; résultat attendu : quatre ports `filtered`. Si autre résultat, arrêter et qualifier. C13–C14.
2. Pendant le créneau approuvé seulement, créer quatre règles pfSense temporaires journalisées, source `10.77.20.50`, destination `10.77.10.10`, TCP `53`, `88`, `389`, `445`, au-dessus du blocage. Relever identifiant, auteur, heure et échéance. Vérifier qu'aucun autre flux n'est ouvert. C15.
3. Répéter la **même** commande avec le préfixe inédit `MCLIENT01-open`. Résultat attendu : quatre ports `open`. Exécuter `ndiff MCLIENT01-before.xml MCLIENT01-open.xml` et conserver la sortie. C16–C17.
4. Retirer les quatre règles avant la fin de la fenêtre ; capturer la table sans ces règles et les journaux pfSense utiles. Refaire la même mesure sous `MCLIENT01-after`, puis `ndiff MCLIENT01-open.xml MCLIENT01-after.xml` et `ndiff MCLIENT01-before.xml MCLIENT01-after.xml`. Résultat attendu : retour des quatre ports à `filtered`. C18–C19.
5. Copier les trois XML, les deux Ndiff, les journaux et les captures vers le coffre ; hacher et enregistrer chaque pièce avec source, outil, action et heure. Indiquer que le S01 historique n'a pas de premier XML ; la nouvelle campagne ne répare pas rétroactivement cette lacune.

**Critère d'arrêt.** Pas d'accord écrit, fenêtre expirée, WAN actif, autre cible/port, comportement inattendu, règle non retirée ou retour au blocage non prouvé : cesser les mesures, retirer les règles contrôlables et faire décider `suspendre`. Ne pas utiliser T04 pour sonder l'hôte ou un réseau tiers sans autorisation distincte.

## 10. Procédure E — signal Sysmon et analyse Hayabusa

**VM :** profil métier (`CC-PFS01`, `CC-DC01`, `CC-W11-01`) ; Kali éteinte. **Outils :** Sysmon sur W11, `wevtutil`/journal Security, Hayabusa hors ligne sur l'hôte. **Responsable :** IT ; qualification relue par le décideur. **Indépendance :** peut se faire avant ou après M04, une fois le fichier de contrôle défini. **Captures :** C20–C23.

1. Sur W11, contrôler le service `Sysmon64`, sa version et la configuration [restreinte](../config/sysmon-restricted.xml). Définir une **copie de contrôle** du livrable ou un fichier non sensible, le compte de test et l'heure UTC. Hacher le fichier avant l'action. C20.
2. Réaliser une action bénigne qui correspond aux événements configurés : lancement de `whoami.exe` (Sysmon ID 1), accès SMB au DC (ID 3) et modification documentée de l'heure de création de la **copie de contrôle** (ID 2). Ne pas changer l'horodatage du livrable de remise. Noter heure, identité et commande exacte. Hacher de nouveau le contenu du fichier ; un hash identique n'exclut pas une lecture ou une copie.
3. Sur W11, retrouver les événements sources dans `Microsoft-Windows-Sysmon/Operational`, exporter le canal EVTX avec `wevtutil epl`, et relever `EventRecordID`, `EventID`, heure, machine, utilisateur, processus et chemin de contrôle. Exporter le journal Security pertinent si nécessaire ; le verrouillage de `tst.lock` se traite séparément sur le DC. Calculer les SHA-256. C21.
4. Rapatrier les EVTX au coffre, les inscrire au registre, puis exécuter Hayabusa v4.2.0 hors ligne avec le paquet de règles local. Conserver la commande, la version, les règles utilisées et la chronologie CSV/JSON. Retrouver la ligne liée à l'événement Sysmon ID 2 et sa règle ; citer l'événement source, pas seulement le nom de détection. C22.
5. Écrire une qualification `attendu`, `suspect` ou `indéterminé`, avec ce que la configuration Sysmon ne voit pas. Faire relire l'extrait expurgé avant remise. C23.

## 11. Recette complète T01–T15 : quoi prouver

Les états actuels sont ceux de [config/recette.csv](../config/recette.csv). Une ligne est changée en `Validé` seulement après test, pièce brute, SHA-256 et contre-test lorsque prévu. La matrice ci-dessous évite de confondre les cinq outils avec toute la recette.

| Test | VM / profil | Action et outil | Preuve principale | Capture | Dépendance |
| --- | --- | --- | --- | --- | --- |
| T01 | Hôte | Conftest V01/V05 sur export réel. | JSON, rapport PASS/FAIL et cartes natives. Déjà validé le 1er novembre ; état à rafraîchir. | C10–C12 | Export récent avant M04. |
| T02 | Hôte | Conftest V02/V03 sur toutes les cartes ; copie fautive. | Même rapport, échec contrôlé et inventaire. Déjà validé le 1er novembre. | C10–C12 | Export récent. |
| T03 | Audit serveur | WAN absent, V04 PASS, tentative de sortie **vers destination approuvée** qui échoue. | État WAN, résultat et heure de la sortie refusée. | C12–C13 | Périmètre autorisé ; aucune destination personnelle. |
| T04 | Audit serveur | Vérifier un flux interdit et son refus dans pfSense. | Règle, paquet borné et ligne de journal concordante. | C13–C14 | Cible du test explicitement autorisée ; l'hôte reste exclu de M04. |
| T05 | Métier | Mesurer 10 min RAM/CPU et stabilité avec pfSense, DC, W11. | Relevé daté avec min/max, incidents éventuels. | C01 | Les trois VM allumées. |
| T06 | DC + W11 | Résoudre DNS A, PTR, SRV et vérifier le serveur interrogé. | Sorties `Resolve-DnsName`/`nslookup`, heure et cible DNS. | C24 | Domaine et poste disponibles. |
| T07 | DC + W11 | Tester authentification fraîche d'un compte et `dcdiag` ciblé. | Connexion, `whoami`, santé AD/DNS/SYSVOL. | C24 | Compte et mot de passe autorisés. |
| T08 | Métier | Accès Finance autorisé, refus interservice ; ajouter le cas `Clients/Livraison`. | Identités, fichier de contrôle, succès et refus exacts. | C08–C09 | Groupes vérifiés ; deux sessions distinctes. |
| T09 | Métier | Lecture `Syntheses` autorisée et écriture refusée sous Direction. | Lecture, refus d'écriture, ACL/SMB. | C09 | Compte Direction distinct. |
| T10 | DC + W11 | GPOZaurr T10, export GPO, `gpresult`. | Rapport existant et nouveau `gpresult` ; M03 étend la revue des délégations. | C05–C06 | Aucun lien ou droit conclu sur la seule application. |
| T11 | Hôte / MacBook | Vérifier RDP via Tailscale, routes et absence de chemin invité vers l'hôte. | Configuration et connexion autorisée ; routes natives. | C25 | Ne pas lancer de scan invité de l'hôte. |
| T12 | Métier | Action bénigne Sysmon et, séparément, Security du DC si test `tst.lock`. | EVTX, événements sources et heures. | C20–C21 | Configuration Sysmon et comptes vérifiés. |
| T13 | Hôte | Hacher EVTX, Hayabusa, relire la détection et ses limites. | SHA-256, chronologie, ID source, qualification. | C22–C23 | T12 exporté. |
| T14 | Reprise | Restaurer **un fichier de contrôle** depuis copie indépendante. | Source de sauvegarde, temps, hash et ACL après restauration. | C26 | Support distinct, sauvegarde valide. |
| T15 | Reprise | Tester reprise du DC/du périmètre sur clone isolé, `dcdiag`, `gpresult`, RTO/RPO. | Procédure, horodatages, santé AD, écarts et durée. | C26 | Copie indépendante et espace/temps suffisants. |

## 12. Registre des captures à prendre au bon moment

Une capture est nommée `M-CLIENT-01_Cxx_YYYYMMDDTHHMMSS_<source>.png` et enregistrée dans le coffre. Afficher machine, heure et résultat pertinent ; masquer mot de passe, session, identifiant sensible ou contenu client. Chaque capture renvoie à une pièce brute ; la capture seule n'établit pas la conformité.

| ID | Moment exact | Ce qui doit être visible | Pièce qui la soutient |
| --- | --- | --- | --- |
| C01 | Avant chaque bascule de profil, puis T05 | VM allumées, mémoire libre de l'hôte, heure. | Inventaire Hyper-V et relevé T05. |
| C02 | Avant transfert M03 | Machine, utilisateur, chemin du coffre et ACL de sa racine. | Contrôle du coffre. |
| C03 | Après copie des deux JSON | Noms, SHA-256, `False → True`. | Deux JSON source et copies. |
| C04 | Après enregistrement | Deux lignes du registre avec identifiants et hashes. | `registre.csv`. |
| C05 | Pendant revue GPO | Écran GPOZaurr ciblé : propriétaire, délégation ou lien de la GPO examinée. | Rapport HTML/CSV GPOZaurr. |
| C06 | Après `gpresult` | GPO appliquées sur W11, identité et heure. | Rapport `gpresult` daté. |
| C07 | Avant essai SMB | ACL NTFS de `Livraison`, droits SMB de `Clients`, groupe concerné. | JSON M03 et exports natifs. |
| C08 | Sous le compte autorisé | `whoami`, chemin UNC et création/lecture réussies. | Fichier de contrôle et journal de test. |
| C09 | Sous le non-membre, puis Direction pour T09 | `whoami`, même chemin et refus exact ; lecture seule Syntheses si T09. | Journaux de tests, ACL/SMB. |
| C10 | Juste avant M04 | Conftest PASS sur export réel daté. | JSON et rapport Conftest. |
| C11 | Même séance | FAIL attendu sur copie fautive, motif lisible. | Rapports de tests Conftest. |
| C12 | Avant Kali | Cartes Hyper-V, WAN pfSense déconnecté, zones privées. | Export topologie et contrôle natif. |
| C13 | Avant règle | Fiche approuvée et table pfSense AUDIT sans exception. | Fiche et export de règles. |
| C14 | Avant règle | XML Nmap `before` : quatre ports filtrés, cible et heure. | XML et SHA-256. |
| C15 | Pendant fenêtre | Quatre règles temporaires exactes, journalisation et heure. | Export pfSense/changement. |
| C16 | Règles actives | XML Nmap `open` : quatre ports ouverts. | XML et SHA-256. |
| C17 | Immédiatement après C16 | Ndiff `before → open`. | Sortie Ndiff hachée. |
| C18 | Après retrait | Table sans les règles ; XML `after` : quatre ports filtrés. | Export pfSense, XML et journaux. |
| C19 | Après C18 | Ndiff `open → after` et `before → after`. | Deux sorties Ndiff hachées. |
| C20 | Avant action poste | Service/config Sysmon, compte et hash du fichier de contrôle. | Config XML, commande et SHA-256. |
| C21 | Après action poste | Événement source Sysmon ID 1/2/3 avec heure et `EventRecordID`. | EVTX haché. |
| C22 | Après Hayabusa | Ligne de chronologie, règle et référence à l'événement source. | CSV/JSON Hayabusa haché. |
| C23 | Qualification | Extrait expurgé « attendu/suspect/indéterminé » et limites. | Fiche de qualification relue. |
| C24 | T06–T07 | DNS A/PTR/SRV et santé AD/connexion fraîche, chaque résultat avec identité. | Sorties natives datées. |
| C25 | T11 | RDP/Tailscale et routes autorisées, sans secret affiché. | Configuration et journal d'accès. |
| C26 | T14–T15, si réalisables | Restauration, hash/ACL, santé AD et durée. | Sauvegarde, journal de reprise, RTO/RPO. |

Pour la soutenance, sélectionner les captures qui démontrent une **transition** ou une **décision** (C03, C08–C11, C14–C19, C21–C23, C26). Ne pas projeter 26 captures successives ; garder les autres en annexe.

## 13. Dépendances et tâches indépendantes

| Travail | Peut avancer sans | Attend impérativement |
| --- | --- | --- |
| Diagnostic coffre, transfert M03, revue GPO, tests SMB | Nouvelle fenêtre réseau et Kali. | DC accessible, coffre protégé, comptes métier. |
| Nouveau Conftest M02 | DC/W11/Kali démarrés et accord de scan. | Droits Hyper-V, export actuel. |
| T05–T09 et T12–T13 | Kali et changement pfSense. | Profil métier, comptes, livrable ou fichier de contrôle. |
| Hayabusa M06 | VM allumées une fois les EVTX copiés. | EVTX de T12 et empreintes. |
| M04 Nmap/Ndiff | T12–T13 et restauration. | Accord écrit, fenêtre active, M02 récent, WAN déconnecté, pfSense/DC/Kali. |
| T14–T15 | M04 et Hayabusa. | Sauvegarde indépendante vérifiée, environnement de restauration isolé, capacité disque/temps. |
| Décision de remise | Aucun outil supplémentaire si la preuve est insuffisante. | Fiche complétée, écarts et limites listés, responsable identifié. |

## 14. Assemblage final et critère de sortie

1. Dans le coffre, vérifier tous les originaux : source, heure UTC, action/commande, taille et SHA-256. Un fichier absent reste « absent » ; ne pas reconstituer le premier XML S01.
2. Produire les extraits expurgés et les faire relire. Laisser les EVTX, JSON, rapports complets et captures brutes dans `brut/`. Vérifier qu'aucun secret, chemin personnel inutile ou contenu client n'apparaît dans la remise.
3. Mettre à jour `config/recette.csv` ligne par ligne : état, identifiant de pièce, résultat observé, limite, responsable. Ne pas valider T03/T04 avec le seul PASS Conftest, T08/T09 avec la seule ACL, ni T12/T13 avec la seule alerte.
4. Terminer la [fiche de décision](fiche-m-client-01.md) : demande et accord, état initial, exception, fermeture, accès métier, signal endpoint, reprise, écarts, contre-tests, temps réel de constitution et signature du décideur.
5. Choisir `poursuivre` seulement si le livrable existe et est haché, les accès effectifs sont conformes, l'exception est retirée et contre-testée, le signal est qualifié et les preuves sont enregistrées. Choisir `corriger` avec action, propriétaire et délai pour un écart limité. Choisir `suspendre` si l'accès reste incertain, la fermeture n'est pas prouvée, l'accord manque ou les preuves essentielles ne sont pas disponibles.
6. Relire le rapport Google, le journal, les liens et la table de captures ; mettre à jour les statuts avec les résultats réellement obtenus. Préparer une démonstration courte : problème métier → preuve initiale → outil pertinent → résultat → limite → décision.

**Fin de journée visée :** un dossier M-CLIENT-01 lisible par la direction, chaque affirmation reliée à une pièce, et une décision explicite. La recette T01–T15 peut comporter des lignes non démontrées si les préconditions manquent ; elles doivent alors être visibles dans le rapport et dans la décision.

## 15. Préparer la soutenance et la remise du projet

1. **Rapport.** Mettre à jour le rapport Google et son annexe E avec les résultats du 5 novembre : date, référence des pièces, écarts, limites et décision. Corriger le sommaire et les renvois de pages après les ajouts. Garder les exports bruts dans le coffre, pas dans le rapport.
2. **Dépôt.** Vérifier que README, mission, fiche, journal et recette racontent le même état. Vérifier `git diff --check`, puis créer un commit descriptif et pousser la branche seulement après revue du contenu ; ne pas ajouter `tmp/`, `assets/` non examinés, secrets, EVTX, JSON bruts ou captures sensibles.
3. **Support oral.** Préparer six étapes : problème client et décision attendue ; architecture et confinement ; GPO et droits du dossier ; exception réseau avant/pendant/après ; événement Sysmon et qualification Hayabusa ; limites et décision. Montrer un résultat réel et sa pièce par étape.
4. **Démonstration.** Préférer les artefacts datés et les captures expurgées à un démarrage simultané des quatre VM. Si une démonstration en direct est retenue, annoncer le profil de VM, vérifier la mémoire et disposer d'une capture de secours pour chaque résultat.
5. **Contrôle final.** Faire relire le dossier par une personne qui n'a pas réalisé les commandes : elle doit pouvoir retrouver la source, l'heure, l'action, le hash et la raison de la décision sans explication orale supplémentaire.

## 16. Pourquoi chacun des cinq outils est nécessaire au mandat

| Outil | Question que lui seul traite dans cette chaîne | Pourquoi les autres solutions ne suffisent pas ici | Limite à dire à la soutenance |
| --- | --- | --- | --- |
| Conftest / OPA | L'export Hyper-V du jour respecte-t-il les invariants privés V01–V05, et une dérive serait-elle refusée automatiquement ? | Une capture Hyper-V ou une vérification manuelle montre un instant sans politique versionnée ni test FAIL reproductible. Un script ad hoc pourrait le faire, mais mélangerait souvent la collecte et la règle. | Un PASS sur JSON ne prouve pas le comportement des paquets ni l'état futur. |
| GPOZaurr | Qui possède et peut modifier les GPO, où sont leurs liens, et AD/SYSVOL restent-ils cohérents ? | `gpresult` prouve l'application sur un poste, pas la gouvernance des GPO. Un audit AD général élargit le périmètre sans répondre directement au dossier client. | Le rapport doit être relu ; il ne démontre pas l'accès effectif à `Livraison`. |
| Nmap + Ndiff | Quels ports deviennent réellement ouverts puis filtrés pendant une exception pfSense ? | La table pfSense exprime la règle voulue ; Nmap mesure l'effet depuis Kali, et Ndiff rend les deux transitions comparables. Un scanner de vulnérabilités ajouterait du bruit et sortirait de la question. | Quatre ports filtrés ne prouvent pas l'absence de tout autre chemin ou d'une faille de service. |
| Sysmon | Quel processus, quelle connexion au DC et quel changement d'heure du fichier de contrôle ont eu lieu sur W11 ? | Les journaux standards, Defender et le pare-feu ne donnent pas seuls le même lien entre processus, destination et fichier pour ce scénario précis. | La configuration est restreinte ; Sysmon ne bloque pas et ne démontre pas l'absence de lecture ou d'exfiltration. |
| Hayabusa | Comment transformer les EVTX en chronologie lisible et relier une règle à l'événement source sans SOC permanent ? | Lire les EVTX à la main est lent et fragile ; un SIEM permanent dépasse le besoin et la mémoire disponible pour cette mission. | Une détection Sigma est un indice à qualifier, pas une conclusion de compromission. |

Leur ordre répond à une décision : **Conftest** vérifie les préconditions, **GPOZaurr** et les tests natifs éclairent les droits, **Nmap/Ndiff** mesurent l'exception et sa fermeture, **Sysmon** fournit les traces du poste, **Hayabusa** aide à les expliquer. Le dossier relie enfin ces sorties à l'autorisation et au choix `poursuivre / corriger / suspendre`.

## Annexe — commandes de départ pour le transfert M03

Ces commandes sont à **exécuter par l'opérateur**, depuis la racine du dépôt sur l'hôte, après vérification de la machine et du coffre. Elles ne constituent pas une preuve tant que les sorties n'ont pas été examinées.

```powershell
$env:COMPUTERNAME
whoami
$coffre = Join-Path $env:LOCALAPPDATA 'CyberCorp\preuves\M-CLIENT-01'
Get-Item -LiteralPath $coffre -Force -ErrorAction Stop
(Get-Acl -LiteralPath (Join-Path $env:LOCALAPPDATA 'CyberCorp\preuves')).AreAccessRulesProtected

$s = New-PSSession -VMName CC-DC01 -Credential (Get-Credential)
Invoke-Command -Session $s -ScriptBlock { whoami; hostname }

$transfert = Join-Path $coffre 'transfert'
New-Item -ItemType Directory -Path $transfert -Force | Out-Null
$noms = @('M03-GPO-Clients-20261101T202134.json',
          'M03-GPO-Clients-20261102T065842.json')

foreach ($nom in $noms) {
    $source = "C:\Audit\M-CLIENT-01\$nom"
    $local = Join-Path $transfert $nom
    Copy-Item -Path $source -FromSession $s -Destination $local -ErrorAction Stop
    $shaSource = Invoke-Command -Session $s -ScriptBlock {
        param($p) (Get-FileHash -LiteralPath $p -Algorithm SHA256).Hash
    } -ArgumentList $source
    $shaLocal = (Get-FileHash -LiteralPath $local -Algorithm SHA256).Hash
    if ($shaSource -ne $shaLocal) { throw "SHA-256 différent pour $nom" }
    $json = Get-Content -LiteralPath $local -Raw | ConvertFrom-Json
    $etat = if ($json.clients.mandate_folder_acl.exists) { 'apres' } else { 'avant' }
    [pscustomobject]@{ Nom=$nom; Etat=$etat; SHA256=$shaLocal; HeureUtc=$json.collected_utc }
    .\scripts\enregistrer-preuve.ps1 -Fichier $local -Etape gpo `
        -Source CC-DC01 -Outil PowerShell `
        -Action "Collecte M03 $etat creation du dossier client" `
        -EvenementUtc $json.collected_utc
}
```

Vérifier que la première empreinte est `978B4D4A3A273E7E6350C1C5B7593DF2FA70F5F6060EE728AAC5F7E9BEFC4764` et que les états affichent `avant` puis `apres`. Conserver la sortie du registre et contrôler les deux fichiers copiés sous `brut/`.
