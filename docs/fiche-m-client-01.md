# M-CLIENT-01 — fiche de décision (modèle)

**Suivi technique du 7 novembre, 11:42 Europe/Paris :** [registre rapproché, AUDIT réactivé et GPO cohérentes](reprise-registre-audit-gpo-2026-11-07.md). Les pièces nouvelles sont référencées dans ce bilan ; les anciennes lignes de revue ci-dessous restent historiques. L'accès local W11 est refusé, les comptes Direction doivent effectuer leur premier changement de mot de passe ; l'application actuelle au poste et les essais métier restent non démontrés. Ce suivi ne prononce aucune décision de remise ni autorisation de scan.

Ce formulaire est à remplir avec les résultats réellement observés. Les cases vides ne valent ni conformité ni approbation. Les pièces citées suivent le [protocole de chaîne de preuves](protocole-preuves.md) ; conserver les exports bruts dans le coffre restreint et ne partager que des extraits expurgés.

**État au 6 novembre 2026, soir : cadrage proposé, non approuvé.** C07–C09 documentent deux essais Clients et les droits associés ; M02/C10–C12 documentent les tests statiques et le WAN sans porteuse. Les inscriptions/contrôles annoncés en séance et les fichiers bruts sont détaillés dans les documents liés ; le registre accessible ne montre pourtant que sept lignes anciennes. Réconcilier cet écart avant clôture. Le dernier export C12 reste à inscrire et les fichiers Nmap sont encore sur Kali. C06, GPO, activation, preuves métier complémentaires, livrable et décision restent ouverts. La fenêtre du 3 novembre est passée ; aucun nouvel accord n'est établi par ces résultats. Voir le [bilan de reprise](journal-deploiement.md#reprise-20261106-soir).

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
| Topologie Hyper-V conforme à V01–V05 ? | [Export `M-CLIENT-01_topologie_20261106T202606368Z_MONNOKOELOBA_HyperV` et rapport `M-CLIENT-01_topologie_20261106T202254132Z_MONNOKOELOBA_Conftest`, C10/C11](controle-topologie.md) | Rapport de 18:43 UTC : PASS sur l'export de 17:52 UTC et cinq FAIL attendus, motifs vérifiés. Export et politique correspondent aux empreintes du rapport. Le nouveau C12 de 21:03 UTC reste sans rapport associé. | Contrôle statique ponctuel obtenu ; réconciliation du registre et contrôle frais avant l'audit nécessaires. **Aucune autorisation d'ouverture accordée.** |
| WAN pfSense déconnecté et Kali confinée ? | [C12 `M-CLIENT-01_topologie_20261106T203930099Z_MONNOKOELOBA_CaptureEcran` et lectures natives](controle-topologie.md#concordance-wan-pfsense-et-hyper-v) | Deux switches privés, Kali uniquement sur AUDIT ; WAN `hn0` sans porteuse, MAC `00155D013C0E` concordante avec la carte Hyper-V sans switch, déconnectée. | Configuration observée conforme sur ce point ; complément console à archiver. Aucun échec de sortie contrôlé ni T03/T04 complet démontré. |
| GPO appliquées et gouvernance examinée ? | `gpresult` + rapport GPOZaurr T10 + [JSON M03, rapport actualisé et C05 enregistrés](controle-gpo-clients.md) | Rapport `M-CLIENT-01_gpo_20261106T085819590Z_CC-DC01_GPOZaurr` et C05 `M-CLIENT-01_gpo_20261106T122808572Z_MONNOKOELOBA_CaptureEcran` archivés, contrôlés et reliés dans le registre. Différences AD/SYSVOL sur les deux GPO natives et erreurs SID/GUID encore à qualifier ; délégations, ACE ciblées et liens consultés nativement. C06 (`gpresult`) reste à faire après préparation de la mémoire. | Non démontré pour une conclusion complète actuelle ; C05 acquise côté traçabilité, qualification et application au poste ouvertes. |
| Fonctionnement durable du DC ? | Événements `System` 1074/6006 et Hyper-V 18508 ; relevés de licence, activation et DNS communiqués | Arrêt du 5/11 attribué à `wlms.exe` / licence ; état notification `0xC004F009`, activation échouée `0x80072EE7`. DC arrêté au relevé du 6/11 à 19:47 UTC ; sa disponibilité pendant Nmap à 19:35 n'est pas établie. Onze captures de diagnostic conservées, sans export natif inscrit confirmé. | Stabilité durable non démontrée ; activation à traiter séparément. Une résolution SRV AD et un `dcdiag /q` silencieux ne prouvent pas la résolution de l'incident. |
| Accès métier aux dossiers sensibles conformes ? | [C07 `…194451915Z…`, C08 `…194539353Z…`, C09 `…194615307Z…`, identifiants complets et SHA-256](controle-gpo-clients.md#accès-clients-et-captures-c07c09--reprise-du-6-novembre) | Sous deux sessions W11 : `usr.com01`, membre Clients observé, crée/relit un fichier dans Livraison ; `usr.fin02` atteint TCP 445 mais reçoit un refus d'écriture exact. SMB/NTFS et groupes sont montrés. | Deux comportements Clients observés ; journaux natifs, contexte complet, fichier/heure/nettoyage et autres scénarios Finance/Direction à compléter. T08/T09 et remise non validés globalement. |
| Registre et disponibilité des pièces concordants ? | [Bilan et écart de registre](journal-deploiement.md#reprise-20261106-soir) | Huit nouvelles pièces brutes présentes, tailles/SHA-256 revérifiés ; lignes annoncées en séance absentes du CSV accessible (sept anciennes lignes). | Écart de traçabilité à réconcilier avant clôture ; ne pas reconstruire le CSV depuis les captures ni réinscrire en masse. |

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

**Décision :** poursuivre / corriger / suspendre — à sélectionner après revue.

**Motif, effets sur le livrable et risques restants :** à renseigner.

**Corrections, contre-tests, responsables et échéances :** à renseigner.

**Temps réel de constitution du dossier :** à mesurer, sans annoncer de délai contractuel non établi.

**Validation du responsable :** identité, date et référence de la preuve à renseigner.
