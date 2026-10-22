# M-CLIENT-01 — fiche de décision (modèle)

Ce formulaire est à remplir avec les résultats réellement observés. Les noms et données sont fictifs ; les cases vides ne valent ni conformité ni approbation. Conserver les preuves brutes dans un emplacement restreint et ne partager que des extraits expurgés.

## 1. Demande métier

| Champ | Valeur à renseigner |
| --- | --- |
| Mission et livrable client fictif | À renseigner |
| Demandeur et responsable de la décision | À renseigner |
| Motif de l'exception d'audit | À renseigner |
| Début, fin et fuseau horaire | À renseigner |
| Source, cible et ports exacts | À renseigner |
| Critère d'arrêt et plan de fermeture | À renseigner |

## 2. Questions avant autorisation

| Question | Référence de preuve | Résultat observé | Décision |
| --- | --- | --- | --- |
| Topologie Hyper-V conforme à V01–V05 ? | Export + rapport Conftest | À renseigner | À renseigner |
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
| SHA-256 du livrable fictif avant/après | À renseigner |
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

**Temps réel de constitution du dossier :** à mesurer, sans annoncer de délai contractuel fictif.

**Validation du responsable :** identité, date et référence de la preuve à renseigner.
