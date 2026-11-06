# M-CLIENT-01 — fiche de décision (modèle)

Ce formulaire est à remplir avec les résultats réellement observés. Les cases vides ne valent ni conformité ni approbation. Les pièces citées suivent le [protocole de chaîne de preuves](protocole-preuves.md) ; conserver les exports bruts dans le coffre restreint et ne partager que des extraits expurgés.

**État au 6 novembre 2026 : cadrage proposé, non approuvé.** Les deux JSON M03, le rapport GPOZaurr et C05 sont archivés et inscrits au registre, avec SHA-256 vérifiés ; les JSON confirment `False → True` pour le dossier `CL-2026-014\Livraison`. C06 et les accès métier restent à tester. L'arrêt du DC a été relié à une expiration de licence et aucune activation réussie n'est confirmée. Le livrable PDF et l'accord des personnes nommées restent à vérifier. La fenêtre du 3 novembre est passée ; une nouvelle fenêtre et une approbation explicite sont nécessaires avant toute règle ou nouvelle mesure depuis Kali.

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
| Topologie Hyper-V conforme à V01–V05 ? | `M-CLIENT-01_topologie_20261101T162606114Z_HOTE-HYPERV_HyperV` + `M-CLIENT-01_topologie_20261101T162606177Z_HOTE-HYPERV_Conftest` | PASS sur l'export réel du 01/11/2026 ; cinq copies fautives refusées. État ponctuel, à revérifier avant l'audit. | Précondition technique satisfaite à cet instant ; **aucune autorisation d'ouverture accordée**. |
| WAN pfSense déconnecté et Kali confinée ? | Cartes Hyper-V + test contrôlé | À renseigner | À renseigner |
| GPO appliquées et gouvernance examinée ? | `gpresult` + rapport GPOZaurr T10 + [JSON M03, rapport actualisé et C05 enregistrés](controle-gpo-clients.md) | Rapport `M-CLIENT-01_gpo_20261106T085819590Z_CC-DC01_GPOZaurr` et C05 `M-CLIENT-01_gpo_20261106T122808572Z_MONNOKOELOBA_CaptureEcran` archivés, contrôlés et reliés dans le registre. Différences AD/SYSVOL sur les deux GPO natives et erreurs SID/GUID encore à qualifier ; délégations, ACE ciblées et liens consultés nativement. C06 (`gpresult`) reste à faire après préparation de la mémoire. | Non démontré pour une conclusion complète actuelle ; C05 acquise côté traçabilité, qualification et application au poste ouvertes. |
| Fonctionnement durable du DC ? | Événements `System` 1074/6006 et Hyper-V 18508 ; relevés de licence, activation et DNS communiqués par l'opérateur | `wlms.exe` a demandé l'arrêt le 5 novembre pour expiration de licence. État notification, `0xC004F009`, grâce nulle ; activation `/ato` échouée avec `0x80072EE7`, résolution du serveur Microsoft expirée. Le DC a été redémarré et fonctionne au dernier relevé. Export natif de ces diagnostics non encore confirmé au registre. | Non démontré pour la stabilité durable ; activation à traiter par une maintenance autorisée. Le redémarrage ne prouve pas la résolution de l'incident. |
| Accès métier aux dossiers sensibles conformes ? | [ACL M03](controle-gpo-clients.md) + tests SMB T08–T09 | `Clients` présent ; `CL-2026-014\Livraison` créé avec trois règles NTFS héritées, dont `DL_CLIENTS_MODIFY` en modification. Aucun test positif/négatif depuis un compte métier rapporté. | Accès effectif et remise non validés. |

## 3. Exception et fermeture

| État | Heure | Règle pfSense | XML Nmap et SHA-256 | Conclusion |
| --- | --- | --- | --- | --- |
| Bloqué avant changement | À renseigner | À renseigner | À renseigner | À renseigner |
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
