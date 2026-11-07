# M-CLIENT-01 — fiche de décision (modèle)

**Clôture documentaire avec réserves — 7 novembre 2026 :** [rapport final](rapport-cloture-avec-reserves-2026-11-07.md). Recette : **2 validés, 6 partiellement démontrés, 7 non démontrés**. Registre actif rapproché à **43 pièces distinctes**, huit alias historiques conservés ; pièce W11 réinscrite sous `M-CLIENT-01_poste_20261107T162640679Z_MONNOKOELOBA_HyperV`. SHA-256 du registre final : `4D7860F21D5C457231F0BA843A3FE055BE05CA4A40CFFB553B00B0D5A45B03CE`. Proposition : remettre les constats avec réserves, acceptation technique globale suspendue, validation humaine en attente. Les états et références des bilans ci-dessous restent historiques.

**État documenté au 7 novembre, 15 h 30 Europe/Paris :** [reprise W11 et pilotage métier](reprise-powershell-metier-2026-11-07.md). Registre à 43 lignes contrôlées. Reprise W11 suivie d'un retour immédiat Saved après 1,251 Gio libres ; aucune authentification ni test métier tenté. DC Running, W11/pfSense/Kali Saved ; aucune modification réseau ni nouvel essai de flux. Le dernier Conftest reste conforme à 14:08 UTC. Deux validations statiques, T10 à actualiser et douze tests à faire ; aucune décision de remise.

**Derniers résultats invités disponibles :** [activation du DC, AUDIT réactivé et quatre GPO cohérentes](reprise-registre-audit-gpo-2026-11-07.md), puis [verrouillage local-admin W11 établi](diagnostic-acces-w11-2026-11-07.md). Aucun déverrouillage ni diagnostic natif de licence W11 confirmé. Les comptes Direction doivent effectuer leur premier changement de mot de passe ; l'application actuelle au poste et les essais métier restent non démontrés.

Ce formulaire est à remplir avec les résultats réellement observés. Les cases vides ne valent ni conformité ni approbation. Les pièces citées suivent le [protocole de chaîne de preuves](protocole-preuves.md) ; conserver les exports bruts dans le coffre restreint et ne partager que des extraits expurgés.

**Historique :** le [bilan du 6 novembre](journal-deploiement.md#reprise-20261106-soir) conserve les essais C07–C12 et les lacunes de classement alors constatées. Le registre, C12, C06 historique, l'activation du DC et la cohérence native des GPO ont depuis été traités. La fenêtre proposée du 3 novembre reste expirée et non approuvée.

**Référence de cadrage :** rapport Google « Dossier Henri Pissa », annexe E « Mandat de sécurité M-CLIENT-01 », mis à jour au 4 novembre 2026. Le rapport décrit le mandat et ses rôles par fonction, mais ne constitue pas une approbation nominative ou une fenêtre d'audit. Les preuves détaillées de Conftest M02 et des collectes M03 restent dans les documents et registres locaux liés ci-dessous.

## 1. Demande métier

| Champ | Valeur à renseigner |
| --- | --- |
| Mission et livrable client | Référence de mandat `CL-2026-014` ; dossier cible `\\CC-DC01\Clients\CL-2026-014\Livraison`, créé et observé sur `CC-DC01` les 1er–2 novembre. Livrable proposé : `Dossier-technique-exploitation-reprise-CL-2026-014-v1.0.pdf`, dont l'existence et l'empreinte restent à établir. Destinataire : responsable informatique du client `CL-2026-014` (identité et canal de remise à confirmer). |
| Demandeur et responsable de la décision | Demandeur proposé : **Alex Martin**, direction des opérations (`usr.dir02`). Responsable de la décision et approbatrice proposée : **Camille Moreau**, direction générale (`usr.dir01`). Opérateur technique proposé : **Raphaël Henry**, administration systèmes (`usr.it01`). Ces attributions ne constituent pas leur accord. |
| Motif de l'exception d'audit | Mesurer l'exposition créée par une règle temporaire, puis prouver son retrait avant la décision de remise. Motif métier du demandeur à confirmer. |
| Début, fin et fuseau horaire | La fenêtre **proposée** du mardi **3 novembre 2026, 14 h 00–15 h 00**, `Europe/Paris`, est dépassée et ne vaut plus autorisation. Nouvelle date, heure de début, heure de fin et créneau de retrait des règles à renseigner après accord écrit. |
| Approbation de l'ouverture | **Non obtenue.** À compléter avec identité du signataire, date/heure et référence de l'accord écrit avant toute règle ou mesure depuis Kali. |
| Source, cible et ports exacts | Périmètre documenté : `CC-KALI01` (`10.77.20.50`) → `CC-DC01` (`10.77.10.10`), TCP `53`, `88`, `389`, `445` uniquement ; WAN pfSense déconnecté. L'hôte, le réseau personnel et les systèmes tiers sont exclus. |
| Critère d'arrêt et plan de fermeture | Arrêt si précondition non conforme, absence d'accord, cible/port hors périmètre, comportement inattendu ou expiration de la nouvelle fenêtre. Retirer les quatre règles temporaires, refaire exactement la même mesure et vérifier le retour à l'état bloqué avant l'heure de fin approuvée. Si ce retour n'est pas prouvé, suspendre la remise et faire arbitrer la direction. |

## 2. Questions avant autorisation

| Question | Référence de preuve | Résultat observé | Décision |
| --- | --- | --- | --- |
| Topologie Hyper-V conforme à V01–V05 ? | [Export `M-CLIENT-01_topologie_20261107T140849846Z_MONNOKOELOBA_HyperV` et rapport `M-CLIENT-01_topologie_20261107T140849862Z_MONNOKOELOBA_Conftest`](controle-final-autonome-2026-11-07.md) | Collecte et exécution du 7 novembre à 14:08 UTC : PASS réel, cinq FAIL attendus, 18 règles par cas ; fichiers enregistrés et contrôlés. | T01/T02 statiques étayés par une collecte fraîche ; à refaire avant l'audit. **Aucune autorisation d'ouverture accordée.** |
| WAN pfSense déconnecté et Kali confinée ? | [Relevé hôte et export du lot autonome](controle-final-autonome-2026-11-07.md), [captures WAN archivées](archivage-c12-wan-2026-11-07.md) | Deux switches privés, Kali uniquement sur AUDIT ; WAN Hyper-V sans switch, Connected=False et MAC `00155D013C0E`. Aucun WinNAT. pfSense/Kali Saved au relevé ; aucun flux testé. | Configuration statique observée ; T03/T04 restent à démontrer par des essais autorisés et journalisés. |
| GPO appliquées et gouvernance examinée ? | [Exports natifs de gouvernance et correction](reprise-registre-audit-gpo-2026-11-07.md#incohérence-gpo-corrigée-et-contre-contrôlée), [C06 historique et suivi poste](controle-gpo-clients.md) | Quatre GPO cohérentes après correction native des deux GPO par défaut ; ACL AD, versions et fichiers de stratégie des GPO corrigées inchangés. C06 du 6 novembre archivée. Huit erreurs SID/GUID GPOZaurr conservées comme limite de l'outil. Aucun gpresult courant ni état endpoint nouveau. | Gouvernance contrôlée nativement ; T10 à actualiser pour l'application actuelle sur W11. |
| Fonctionnement du DC après correction de licence ? | [Activation et surveillance](activation-dc01-2026-11-07.md), [santé AD ciblée après correction GPO](reprise-registre-audit-gpo-2026-11-07.md), [relevé hôte actuel](controle-final-autonome-2026-11-07.md) | Activation réussie, échéance d'évaluation au 6 mai 2027 ; surveillance de 65 minutes sans arrêt observé et contrôles AD ciblés conformes documentés. DC Running à 14:08 UTC. | Incident de licence corrigé selon ces contrôles bornés ; ne prouve ni la disponibilité lors du scan du 6 novembre ni la recette T06/T07 complète. |
| Accès métier aux dossiers sensibles conformes ? | [C07 `…194451915Z…`, C08 `…194539353Z…`, C09 `…194615307Z…`, identifiants complets et SHA-256](controle-gpo-clients.md#accès-clients-et-captures-c07c09--reprise-du-6-novembre) | Sous deux sessions W11 : `usr.com01`, membre Clients observé, crée/relit un fichier dans Livraison ; `usr.fin02` atteint TCP 445 mais reçoit un refus d'écriture exact. SMB/NTFS et groupes sont montrés. | Deux comportements Clients observés ; journaux natifs, contexte complet, fichier/heure/nettoyage et autres scénarios Finance/Direction à compléter. T08/T09 et remise non validés globalement. |
| Registre et disponibilité des pièces concordants ? | [Audit des preuves et quatre nouvelles inscriptions](controle-final-autonome-2026-11-07.md), puis [pièce de reprise W11](reprise-powershell-metier-2026-11-07.md) | 38 pièces principales et 90 annexes vérifiées dans le lot initial ; quatre pièces ajoutées, puis une pièce W11. Contrôle final des 43 pièces principales : identifiants, chemins et empreintes uniques, fichiers présents, tailles/SHA-256 conformes. Versions antérieures sauvegardées. | Cohérence des pièces contrôlée ; aucune validation automatique de leur contenu technique. Extraits et relecture de remise restent à produire. |

## 3. Exception et fermeture

| État | Heure | Règle pfSense | XML Nmap et SHA-256 | Conclusion |
| --- | --- | --- | --- | --- |
| Observation fournie avant changement, blocage non validé | 06/11/2026, 19:35:50–53 UTC | État et journaux corrélés non fournis | `blocked-before.xml`, 1709 octets, SHA-256 `b65e0b245037467a6a887713bdc243f65b93a91ae2c710d11342c45abb54c837`, encore sur Kali | Quatre ports `filtered/no-response`, hôte `user-set` avec `-Pn`. Disponibilité DC et nouvelle autorisation non démontrées ; aucune validation du blocage pfSense ou de la fermeture. |
| Autorisé pendant la fenêtre | À renseigner | À renseigner | À renseigner | À renseigner |
| Bloqué après retrait | À renseigner | À renseigner | À renseigner | À renseigner |

Comparer les deux transitions avec Ndiff, puis confirmer la suppression des règles temporaires. Pour S01 réalisé le 20 octobre 2026, l'export XML de la première mesure bloquée a été écrasé : indiquer cette lacune si ces preuves sont utilisées. Ne pas reconstituer un fichier absent.

## 4. Signal sur le poste

| Champ | Valeur à renseigner |
| --- | --- |
| Action bénigne et compte de test | À renseigner |
| Heure de référence et contrôle des horloges | À renseigner |
| SHA-256 de la copie de contrôle du livrable avant/après | À renseigner |
| EVTX Security/Sysmon et empreintes | À renseigner |
| Événement source, ID et machine | À renseigner |
| Règle Hayabusa et ligne de chronologie | À renseigner |
| Qualification : attendu / suspect / indéterminé | À renseigner |
| Ce que les journaux ne permettent pas de conclure | À renseigner |

Une empreinte inchangée du fichier testé ne démontre pas qu'il n'a pas été lu ou copié. Ne pas présenter Sysmon ou Hayabusa comme une preuve d'absence d'exfiltration.

## 5. Décision et suivi

**Recommandation technique :** remise du dossier de constats avec réserves ; acceptation technique globale suspendue. Décision humaine de remise à dater et signer ; aucun accord déduit.

**Motif et réserves :** socle déployé, DC activé et cohérence GPO native acquise. Réseau complet, état endpoint actuel, Direction, chronologie du mandat et restauration indépendante restent partiels ou non démontrés. PDF métier, hash, destinataire et canal non établis. Aucune certification de sécurité globale, d'absence d'exfiltration ni de RTO/RPO.

**Suivi :** libérer le budget mémoire et clarifier W11 ; compléter les tests endpoint/accès, prévoir une fenêtre réseau approuvée et une restauration indépendante. Responsables et échéances à attribuer par le décideur. Les lacunes restent dans la recette finale.

**Temps réel de constitution du dossier :** à mesurer, sans annoncer de délai contractuel non établi.

**Validation du responsable :** identité, date et référence de la preuve à renseigner.
