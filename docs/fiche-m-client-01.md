# M-CLIENT-01 — fiche de décision (modèle)

Ce formulaire est à remplir avec les résultats réellement observés. Les cases vides ne valent ni conformité ni approbation. Les pièces citées suivent le [protocole de chaîne de preuves](protocole-preuves.md) ; conserver les exports bruts dans le coffre restreint et ne partager que des extraits expurgés.

**État de la demande : cadrage proposé, non approuvé.** Les désignations, le dossier et la fenêtre ci-dessous sont créés pour préparer le mandat ; ils ne prouvent ni l'existence du livrable sur le serveur ni l'accord des personnes nommées. Ils n'autorisent ni l'ouverture d'une règle ni un nouveau scan.

**Référence de cadrage :** rapport Google « Dossier Henri Pissa », annexe E « Mandat de sécurité M-CLIENT-01 ». Le rapport décrit le mandat et ses rôles par fonction, mais ne constitue pas une approbation nominative ou une fenêtre d'audit. Son état des preuves est daté du 20 octobre 2026 ; le contrôle Conftest du 1er novembre est documenté séparément ci-dessous.

## 1. Demande métier

| Champ | Valeur à renseigner |
| --- | --- |
| Mission et livrable client | Référence de mandat `CL-2026-014` ; dossier cible `\\CC-DC01\Clients\CL-2026-014\Livraison` ; livrable proposé `Dossier-technique-exploitation-reprise-CL-2026-014-v1.0.pdf`. Destinataire : responsable informatique du client `CL-2026-014` (identité et canal de remise à confirmer). Le dossier et le fichier doivent encore être créés puis vérifiés sur `CC-DC01`. |
| Demandeur et responsable de la décision | Demandeur proposé : **Alex Martin**, direction des opérations (`usr.dir02`). Responsable de la décision et approbatrice proposée : **Camille Moreau**, direction générale (`usr.dir01`). Opérateur technique proposé : **Raphaël Henry**, administration systèmes (`usr.it01`). Ces attributions ne constituent pas leur accord. |
| Motif de l'exception d'audit | Mesurer l'exposition créée par une règle temporaire, puis prouver son retrait avant la décision de remise. Motif métier du demandeur à confirmer. |
| Début, fin et fuseau horaire | Fenêtre **proposée** : mardi **3 novembre 2026, 14 h 00–15 h 00**, `Europe/Paris` (UTC+01:00). Préconditions à revoir avant 14 h ; règles temporaires prévues uniquement entre 14 h 20 et 14 h 35, retirées et contre-testées avant 14 h 50. Sans approbation explicite avant 14 h, la fenêtre est annulée. |
| Approbation de l'ouverture | **Non obtenue.** À compléter avec identité du signataire, date/heure et référence de l'accord écrit avant toute règle ou mesure depuis Kali. |
| Source, cible et ports exacts | Périmètre documenté : `CC-KALI01` (`10.77.20.50`) → `CC-DC01` (`10.77.10.10`), TCP `53`, `88`, `389`, `445` uniquement ; WAN pfSense déconnecté. L'hôte, le réseau personnel et les systèmes tiers sont exclus. |
| Critère d'arrêt et plan de fermeture | Arrêt si précondition non conforme, absence d'accord, cible/port hors périmètre, comportement inattendu ou expiration de la fenêtre. Retirer les quatre règles temporaires, refaire exactement la même mesure et vérifier le retour à l'état bloqué avant 14 h 50. Si ce retour n'est pas prouvé, suspendre la remise et faire arbitrer la direction. |

## 2. Questions avant autorisation

| Question | Référence de preuve | Résultat observé | Décision |
| --- | --- | --- | --- |
| Topologie Hyper-V conforme à V01–V05 ? | `M-CLIENT-01_topologie_20261101T162606114Z_HOTE-HYPERV_HyperV` + `M-CLIENT-01_topologie_20261101T162606177Z_HOTE-HYPERV_Conftest` | PASS sur l'export réel du 01/11/2026 ; cinq copies fautives refusées. État ponctuel, à revérifier avant l'audit. | Précondition technique satisfaite à cet instant ; **aucune autorisation d'ouverture accordée**. |
| WAN pfSense déconnecté et Kali confinée ? | Cartes Hyper-V + test contrôlé | À renseigner | À renseigner |
| GPO appliquées et gouvernance examinée ? | `gpresult` + rapport GPOZaurr | À renseigner | À renseigner |
| Accès métier aux dossiers sensibles conformes ? | T08–T09 et ACL natives | À renseigner | À renseigner |

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
