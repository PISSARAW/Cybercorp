# Annexe technique — mandat M-CLIENT-01

**Référence :** AT-M-CLIENT-01 · **Version :** 0.4 · **État arrêté au :** 7 novembre 2026, 15 h 30 Europe/Paris · **Statut :** dossier de constats en cours, non approuvé pour la remise.

Cette annexe relie les questions du [mandat](fiche-m-client-01.md) aux configurations, essais, résultats et pièces vérifiables. Le [guide de clôture](plan-cloture-2026-11-05.md) indique l'ordre d'exécution ; le [rapport principal](https://docs.google.com/document/d/1cxUCv6RS4L5Fr2NMFRqwuIYaI75UVpWj4PkX5wN-_-8/edit) porte la synthèse et la décision. Les exports bruts demeurent dans le [coffre restreint](protocole-preuves.md), hors Git et OneDrive. Cette annexe ne reproduit ni secret, ni journal brut, ni contenu client.

## 1. Règles de lecture

- **Observé** : sortie ou fichier identifié, avec sa date et sa portée. Une capture illustre l'observation, sans remplacer l'export source.
- **Contrôlé** : fichier retrouvé, SHA-256 recalculé et, lorsque l'inscription est revendiquée, ligne du registre actif vérifiée. Le lot autonome vérifie 38 pièces principales et 90 annexes, puis ajoute quatre pièces ; la tentative W11 ajoute ensuite une pièce et porte le registre à 43 lignes contrôlées. Ce contrôle ne valide pas le contenu technique de chaque test.
- **Validé** : critère de recette satisfait avec pièce, périmètre, contre-test requis et traçabilité concordante. Les statuts de [T01–T15](../config/recette.csv) restent la référence formelle ; un essai partiel ne change pas leur état.
- **Ouvert** : résultat, autorisation, preuve ou qualification manquant. Laisser la valeur vide ou marquer « non démontré » plutôt que la déduire d'une autre pièce.

Toutes les heures techniques ci-dessous sont en UTC sauf mention contraire. Les noms des captures C10–C12 datent leur rangement, pas nécessairement la prise de vue. Les conclusions valent pour l'état et le périmètre observés ; un contrôle frais est nécessaire avant une nouvelle exception réseau.

## 2. Synthèse technique pour la décision

| Question | Constat au 7 novembre | État de preuve | Conséquence pour la décision |
| --- | --- | --- | --- |
| M01 — Qui autorise l'audit et la remise ? | Fiche de cadrage rédigée ; fenêtre du 3 novembre expirée ; nouvelle approbation et identité du décideur non documentées. | Ouvert. | Aucune nouvelle règle ni campagne Nmap M04 autorisée par cette fiche. |
| M02 — Le laboratoire est-il confiné ? | Conftest sur un export frais du 7 novembre à 14:08 UTC : PASS réel et cinq FAIL attendus, 18 règles par cas. WAN Hyper-V déconnecté et aucun WinNAT. | Contrôles statiques enregistrés ; registre final à 43 lignes conformes après la pièce de reprise W11. Aucun nouveau test de flux ni de règle interne pfSense. | Refaire un état frais juste avant M04 ; ne pas confondre PASS statique et autorisation. |
| M03 — Qui peut modifier `Livraison` et qui gouverne les GPO ? | Création du dossier et deux essais Clients conservés. Après correction native des deux GPO par défaut, les quatre GPO sont cohérentes ; C06 du 6 novembre archivée. Les huit erreurs SID/GUID restent une limite historique de GPOZaurr. | Gouvernance contrôlée nativement ; application actuelle sur W11 et autres scénarios métier non démontrés. T10 à actualiser. | Ne pas conclure à la conformité de tous les accès ou à l'application actuelle des GPO sur le poste. |
| M04 — L'exception réseau a-t-elle été bornée puis refermée ? | Un `blocked-before.xml` du 6 novembre affiche quatre ports `filtered/no-response`. La disponibilité du DC, les règles corrélées et l'accord ne sont pas établis ; aucun triplet complet ni Ndiff nouveau. | Non démontré pour M04. | Ne pas déclarer la fermeture prouvée. |
| M05/M06 — Le signal du poste est-il explicable ? | Sysmon/Hayabusa ont été essayés le 20 octobre, hors chaîne complète du mandat. | Cas métier, EVTX, chronologie et qualification à produire. | Aucune conclusion sur l'action du livrable ni sur une absence d'exfiltration. |
| T14/T15 — Peut-on restaurer ? | Pas de sauvegarde indépendante ni de restauration contrôlée démontrées. | Non démontré. | Inscrire la lacune ou exécuter un test sur copie isolée. |

## 3. Architecture, confinement et Conftest / OPA — M02

**Périmètre.** Hôte Hyper-V, commutateurs `CC-LAN` et `CC-AUDIT` privés, `CC-WAN-MAINT` interne, `CC-DC01`, `CC-W11-01`, `CC-KALI01` et `CC-PFS01`. La [politique versionnée](../policy/topology.rego) contrôle V01–V05 sur l'export JSON ; les cinq copies fautives sont des contre-tests, pas l'état de production.

**Dernier contrôle.** Le [lot autonome de clôture](controle-final-autonome-2026-11-07.md) archive un export collecté à `14:08:17 UTC` le 7 novembre et son rapport Conftest à `14:08:18 UTC` : PASS réel et cinq FAIL attendus, 18 règles par cas. Le relevé hôte distinct montre seul le DC actif, W11/pfSense/Kali Saved et 2,630 Gio libres. Les deux réseaux LAN/AUDIT sont privés, WAN-MAINT interne, WAN pfSense déconnecté et aucun WinNAT. Aucun accès invité ni test de flux n'a été réalisé. Les observations suivantes conservent le contexte historique.

**Suite à 14:27 UTC.** La [reprise W11](reprise-powershell-metier-2026-11-07.md) a été interrompue après constat de 1,251 Gio libres : retour immédiat Saved, 3,312 Gio libres au bilan, aucune authentification ni modification réseau. L'accès Direct sous usr.com01 reste à vérifier. La prochaine préparation vise 4 Gio libres, avec contrôle immédiat après reprise ; les essais métier n'exigent pas local-admin.

**Résultat observé.** Conftest 0.71.1 / OPA 1.21.1 a rendu PASS sur l'export réel collecté à `2026-11-06T17:52:21.6782248Z` et FAIL attendu sur switch externe, seconde carte Kali, WAN rebranché, VM manquante et champ de connexion absent. Le rapport a été produit à `18:43:03.6549012Z` ; 18 règles ont été comptabilisées pour le cas réel. Les empreintes de l'entrée et de `policy/topology.rego` concordent avec celles du rapport. Les messages du JSON sont partiellement altérés à l'affichage ; le brut a été conservé sans réécriture.

**Contrôle WAN distinct.** C12 montre à `20:37:46.8248341Z` la carte Hyper-V WAN sans commutateur, `Connected=False`. Sur pfSense 2.9.0, `ifconfig hn0` affiche `status: no carrier` ; la MAC `00:15:5d:01:3c:0e` correspond à cette carte. L'adresse statique `172.31.250.2/24` ne prouve pas une liaison active. Le dernier export C12 (collecté le 6 novembre à `21:03:11Z`, SHA-256 `94BB58931B14C8C36B24D894E9F4FC4E6A14B0DAFF22A95CA08EB0E2DA24C02F`) et les deux captures pfSense ont été archivés le 7 novembre. Un rapport Conftest ultérieur sur cet export donne PASS réel et cinq FAIL attendus, 18 règles par cas. Un nouvel export Hyper-V du 7 novembre donne le même résultat ; ses MAC WAN/LAN/AUDIT sont respectivement `00155D013C0E`, `00155D013C0F` et `00155D013C10`. Ces relevés n'ont pas été simultanés aux captures pfSense et ne prouvent ni les règles internes ni un flux bloqué.

**Limite.** Conftest lit la configuration Hyper-V, pas les règles internes pfSense ni le comportement d'un flux. T03 exige une sortie contrôlée refusée ; T04, un refus journalisé vers une cible explicitement autorisée. Voir le [contrôle M02 détaillé](controle-topologie.md).

## 4. GPO, partage et accès Clients — M03

### 4.1 Création du dossier et droits déclarés

Les collectes PowerShell du 1er et du 2 novembre inventorient quatre GPO et montrent `clients.mandate_folder_acl.exists=False`, puis `True`. Le partage `Clients` existait ; `CL-2026-014\Livraison` a été créé entre les deux collectes. La racine NTFS `E:\Partages\Clients` bloque son propre héritage et transmet trois règles explicites : Système et Administrateurs en contrôle total, `DL_CLIENTS_MODIFY` en modification. Le sous-dossier `Livraison` hérite de ces trois règles. Une ACL déclarée ne suffit pas à établir l'accès effectif par SMB.

### 4.2 Gouvernance des GPO

GPOZaurr 1.1.13 a audité en lecture seule `ad.cybercorp.test` le 5 novembre. `GPOBroken` n'a pas signalé de GPO sans correspondant AD/SYSVOL dans la catégorie examinée ; `GPOList` dénombre quatre GPO actives. Les deux GPO CyberCorp ont des propriétaires AD/SYSVOL concordants. Le rapport initial montre pour `Default Domain Policy` et `Default Domain Controllers Policy` un propriétaire AD `CYBERCORP\Admins du domaine` et SYSVOL `BUILTIN\Administrators`, avec `IsOwnerConsistent=False`, `ACLConsistent=False` et `ACLConsistentInside=False`. Ces indicateurs sont historiques et ont été complétés par le contrôle natif puis la correction décrite ci-dessous.

La catégorie `GPOPermissions` comporte huit erreurs de conversion de SID en `System.Guid`. Ses indicateurs `PermissionIssue=False` ne constituent pas une revue complète. Les lectures natives `Get-GPPermission`, ACE AD ciblées et `Get-GPInheritance` ont complété l'observation. Un `gpresult` HTML du 6 novembre, retrouvé et archivé le 7 novembre, montre sur `CC-W11-01` l'application de `CC-Domaine-Comptes`, `CC-Postes-Securite` et `Default Domain Policy`, avec révisions AD/SYSVOL 80/80 et 33/33 pour les GPO CyberCorp. Les paramètres affichés comprennent un mot de passe minimal de 14 caractères, un historique de 24, un verrouillage après cinq échecs pendant 15 minutes, un verrouillage de session après 600 secondes, l'activation des trois profils pare-feu et la désactivation des invités SMB non sécurisés. Le HTML ne prouve pas l'état courant après redémarrage, la santé du moteur Defender ni le retrait de SMBv1. Aucun propriétaire, droit ni paramètre GPO n'a été corrigé pendant cette revue. C05, le HTML GPOZaurr et le `gpresult` figurent au registre réconcilié.

Le [suivi du 7 novembre à 11 h 42](reprise-registre-audit-gpo-2026-11-07.md#incohérence-gpo-corrigée-et-contre-contrôlée) documente la correction ultérieure : sauvegarde des deux GPO par défaut, puis `MakeAclConsistent()` natif sur ces deux GPO seulement. Les quatre GPO retournent ensuite `IsAclConsistent=True`, versions AD/SYSVOL concordantes ; ACL AD, versions et fichiers de stratégie des GPO corrigées inchangés. Les propriétaires SYSVOL administratifs sont conservés. Aucune ACE Allow d'écriture non administrative n'a été détectée dans le périmètre examiné. Les huit erreurs GPOZaurr ne sont pas déclarées corrigées dans le logiciel. Un gpresult actuel et les contrôles endpoint restent nécessaires ; T10 est reclassé `À actualiser`.

### 4.3 Essais d'accès métier

C07 montre les ACL/SMB, les appartenances et le contexte de test. Sur deux sessions W11 distinctes, `usr.com01`, membre Clients observé, a créé et relu un fichier de contrôle dans `\\CC-DC01\Clients\CL-2026-014\Livraison` ; `usr.fin02` a atteint TCP 445 puis reçu `UnauthorizedAccessException` / « Accès refusé » sur une tentative de création au même endroit. Le refus ne localise pas à lui seul le mécanisme SMB ou NTFS. L'heure exacte des captures, les exports natifs des essais, le nom et le nettoyage du fichier positif restent à établir. Les scénarios Finance et Direction/Syntheses de T08/T09 ne sont pas couverts par ces deux essais. Voir le [contrôle M03 détaillé](controle-gpo-clients.md).

## 5. Exception réseau — M04 : emplacement de résultats

Une mesure Nmap 7.99 existante, de `2026-11-06T19:35:50Z` à `19:35:53Z`, cible `10.77.10.10` sur TCP `53,88,389,445` avec `-n -Pn -sT`, sous le préfixe `blocked-before`. Son XML de 1709 octets a le SHA-256 `B65E0B245037467A6A887713BDC243F65B93A91AE2C710D11342C45ABB54C837` et affiche quatre ports `filtered/no-response`. Avec `-Pn`, l'état `user-set` n'est pas une preuve que le DC répondait. Les fichiers sont encore sur Kali ; l'accord, la disponibilité de la cible, les règles/journaux pfSense corrélés et leur transfert ne sont pas établis. Cette mesure ne valide ni un blocage initial, ni T03/T04, ni la fermeture de M04.

À renseigner **seulement après nouvelle fenêtre approuvée** : référence de l'accord et du périmètre ; export Conftest frais ; WAN et règles avant changement ; XML `before`, `open`, `after` et leurs SHA-256 ; deux Ndiff ; identifiants et heures des quatre règles temporaires ; journaux pfSense ; preuve du retrait ; écart et décision d'arrêt. L'essai S01 d'octobre reste historique et son premier XML bloqué a été écrasé.

## 6. Poste, investigation et reprise : emplacements de résultats

**M05 — Sysmon.** Renseigner compte, poste, action bénigne sur une *copie de contrôle*, configuration et version Sysmon, heure UTC, SHA-256 du fichier avant/après, EVTX source et EventRecordID. Un hash inchangé ne démontre ni absence de lecture ni absence de copie.

**M06 — Hayabusa.** Renseigner version, paquet de règles, commande, chronologie, règle déclenchée ou absence de détection, correspondance à l'événement source, qualification `attendu / suspect / indéterminé` et limite de visibilité. Les essais du 20 octobre ne sont pas le résultat du mandat.

**T14/T15 — sauvegarde et reprise.** Renseigner support indépendant, copie de départ, heure, restauration sur clone isolé, SHA-256 et ACL de la donnée, santé AD, tests métier et durées RTO/RPO observées. À défaut de support valide, consigner « non démontré » et l'effet sur la décision de remise. Un checkpoint local n'est pas une sauvegarde indépendante.

## 7. Manifeste de preuves et registre réconcilié

Les identifiants ci-dessous désignent des fichiers présents dans `brut`. Le [contrôle autonome de clôture](controle-final-autonome-2026-11-07.md) a recalculé tailles et SHA-256 des 38 pièces principales et de 90 annexes référencées, soit 128 fichiers distincts, sans anomalie. Quatre pièces ont ensuite été ajoutées, puis la [tentative W11](reprise-powershell-metier-2026-11-07.md). Après sauvegardes et contrôle final des pièces principales, **43 identifiants, chemins et empreintes uniques** concordent avec les 43 fichiers. Empreinte finale du `registre.csv` à `14:30:53 UTC` : `1C7A597A7F034CCF5C8CFBD3B4AEBB70F1B721772B2AEC767CA9D29E608DDCA4`. Les 90 annexes restent vérifiées au titre du lot initial. Les anciennes versions sont conservées ; la cause des divergences historiques reste inconnue. La cohérence des fichiers ne valide pas leur contenu technique.

| Pièce | Identifiant de fichier sous `brut` | SHA-256 recalculé |
| --- | --- | --- |
| M03 avant dossier | `M-CLIENT-01_gpo_20261105T090906559Z_CC-DC01_PowerShell.json` | `978B4D4A3A273E7E6350C1C5B7593DF2FA70F5F6060EE728AAC5F7E9BEFC4764` |
| M03 après dossier | `M-CLIENT-01_gpo_20261105T090906603Z_CC-DC01_PowerShell.json` | `6330B1645F0952789AD419D322C82F038447D594CBC879FA2E7286DA8482EC26` |
| Rapport GPOZaurr | `M-CLIENT-01_gpo_20261106T085819590Z_CC-DC01_GPOZaurr.html` | `8CDA26993471BC692A85F8F46D77C0F5E8C2A388DFC0FA03FE72CA4035864314` |
| C05 — GPO | `M-CLIENT-01_gpo_20261106T122808572Z_MONNOKOELOBA_CaptureEcran.png` | `4651F40E122498EA6CD7F03AEB49F8372EF7DDDB80E3BDCE9354045B2ED32177` |
| C07 — ACL/SMB | `M-CLIENT-01_autre_20261106T194451915Z_MONNOKOELOBA_CaptureEcran.png` | `6E90F2CC2D0811DF4B25BE4C185C55FE3829CDEBDEF6DA1B8260C055F5DE45E6` |
| C08 — autorisé | `M-CLIENT-01_poste_20261106T194539353Z_MONNOKOELOBA_CaptureEcran.png` | `D17381C8A0A26E6B42DE707449A0A35330A222DB9B1711EC4178B1F7B0CABBCC` |
| C09 — refusé | `M-CLIENT-01_poste_20261106T194615307Z_MONNOKOELOBA_CaptureEcran.png` | `2EE6B04CD26DF15494CCE52658B0E52E3C1554F0B3F9D018008FCA12285D9623` |
| M02 — rapport | `M-CLIENT-01_topologie_20261106T202254132Z_MONNOKOELOBA_Conftest.json` | `A8F72396A96F1C7FBAE2C928ADD6D6AB441E635A6327C69712932BEB28C12EC9` |
| M02 — export réel | `M-CLIENT-01_topologie_20261106T202606368Z_MONNOKOELOBA_HyperV.json` | `FC25F09C8D2A011A5F5683E4F1A0567F60937EAED1EC065FF6EFC09FCE3E7A78` |
| C10 — PASS/FAIL | `M-CLIENT-01_topologie_20261106T203151512Z_MONNOKOELOBA_CaptureEcran.png` | `28403788F9034CE09AAE1EAA9D8FFC405C42699E2932DFD0F91BB6365C441522` |
| C11 — motifs | `M-CLIENT-01_topologie_20261106T203452384Z_MONNOKOELOBA_CaptureEcran.png` | `D531C0141F7E80006443702F1839F82F5809598AB2803CEDA5353FC70E49F6AB` |
| C12 — Hyper-V | `M-CLIENT-01_topologie_20261106T203930099Z_MONNOKOELOBA_CaptureEcran.png` | `526C447B3DCE6FC85B5D4686A347F32219BEC7D9DE1D2A7839CA0EAA3255C73E` |

**Compléments du 7 novembre.** Les [lots C12/WAN](archivage-c12-wan-2026-11-07.md) et [autonome du matin](avancement-autonome-2026-11-07.md) décrivent les premiers archivages. Le [rapprochement ultérieur](reprise-registre-audit-gpo-2026-11-07.md) référence les récupérations sous leurs identifiants actifs, les manifestes d'activation et les preuves natives GPO. L'identifiant actif du `gpresult` est `M-CLIENT-01_gpo_20261107T102056488Z_CC-W11-01_gpresult-06`, SHA-256 `C550EDAFF75B1F5EB8A7218BF6F0CF2077C57AEA0F0ACF6ABE5C019D4131A9F1` ; sa collecte originale date du 6 novembre à 17:18:10, fuseau non établi. Il n'est pas un contrôle frais du 7 novembre. Les quatre dernières pièces avec leurs identifiants et empreintes sont dans le [lot de clôture autonome](controle-final-autonome-2026-11-07.md).

## 8. Écarts ouverts et renvoi au rapport

| Priorité | Écart / travail restant | Preuve de clôture attendue |
| --- | --- | --- |
| 1 | Préparer la mémoire et reprendre W11 pour les essais métier sous leurs comptes ; traiter séparément accès administratif et C06. Conserver la limite des huit erreurs GPOZaurr. | Marge de 1,5 Gio maintenue, identité et machine vérifiées ; `gpresult` courant et contrôles endpoint avec les droits adaptés. Contrôles natifs GPO déjà acquis. |
| 2 | Relier les pièces C12/WAN archivées à un contrôle de flux et aux règles pfSense. | Refus contrôlé et journalisé, capture de règles datée ; ne pas extrapoler le PASS Conftest. |
| 3 | Compléter les tests Clients, Finance et Direction, et vérifier le vrai PDF de livraison. | Comptes, heures, accès positifs/négatifs, nettoyage et SHA-256 du livrable. |
| 4 | Renseigner M01 puis, si autorisé, démontrer M04 de bout en bout. | Accord, fenêtre, trois XML, deux Ndiff, règles et journaux corrélés, retrait et contre-test. |
| 5 | Réaliser M05/M06 et T14/T15 ou documenter leur non-démonstration. | EVTX et chronologie liés aux événements sources ; restauration sur copie indépendante si disponible. |
| 6 | Diagnostiquer l'expiration de l'évaluation W11 ; le DC est activé jusqu'au 6 mai 2027 avec surveillance et santé ciblée documentées. | Lecture native de licence W11, action adaptée à la licence et vérification de sa disponibilité pour les essais. |

La [fiche M-CLIENT-01](fiche-m-client-01.md) et la section de décision du rapport doivent reprendre les résultats, limites, responsables et pièces retenues. **Aucune décision de remise favorable n'est déduite de cette annexe en l'état.** Les extraits qui quitteront le coffre devront être expurgés et relus avant diffusion.
