# Réconciliation du registre de preuves — 7 novembre 2026

**Suivi à 11:42 Europe/Paris :** un [nouveau rapprochement sur les sources](reprise-registre-audit-gpo-2026-11-07.md) traite l'actif revenu à 12 lignes : 19 lignes historiques conservées, huit récupérations actuelles couvrant les empreintes des 27 pièces, puis manifestes et preuves nouvelles, soit 38 lignes uniques contrôlées. Les quatre sources autonomes sont retrouvées dans les sous-dossiers de transfert. Le CSV historique exact à 27 lignes reste non retrouvé ; aucune ancienne inscription n'a été reconstituée. Le texte ci-dessous conserve le bilan antérieur.

Le contrôle final du **7 novembre 2026 à 07:19:35 UTC (08:19:35 Europe/Paris)** confirme un registre actif de **19 lignes, 19 identifiants uniques et zéro anomalie de taille ou de SHA-256** pour les 19 fichiers référencés.

## Versions trouvées dans le coffre

Emplacement : `C:\Users\pissa\AppData\Local\CyberCorp\preuves\M-CLIENT-01`.

| Version | Lignes | Rôle établi |
| --- | ---: | --- |
| `registre.csv` avant intervention | 7 | Historique du 1er novembre |
| `registre-historique-20261101-recupere.csv` | 7 | Copie identique de l'historique |
| `registre-historique-observe-20261106T214149116Z.csv` | 7 | Copie identique de l'historique |
| `registre.csv.sauvegarde-20261106-224032.csv` | 12 | Inscriptions des 5 et 6 novembre |
| `registre-consolide-20261106T214149116Z.csv` | 19 | Réunion exacte des 7 lignes historiques et des 12 inscriptions récentes |

La comparaison a porté sur tous les champs de chaque ligne : identifiant, dates, source, outil, action, opérateur, nom d'origine, chemin, taille, empreinte et relecture. Aucun champ n'a été reconstitué depuis une capture. Les 12 inscriptions récentes couvrent les deux JSON M03, le rapport GPOZaurr, C05, C07–C09, le rapport Conftest, son export Hyper-V et C10–C12.

## Correction réalisée

L'ancien registre actif a été copié sans écrasement vers `registre-avant-reconciliation-20261107T071935221Z.csv`, puis sa copie a été vérifiée par SHA-256. Le consolidé existant a ensuite été copié à l'emplacement actif `registre.csv`. Les fichiers de preuve et les versions précédentes sont conservés. Aucune nouvelle ligne n'a été ajoutée.

Empreintes :

```text
Historique et sauvegarde avant intervention :
1B19B7C82D3C29FBCBC7719A1ADFBB6DD2F7D5FC6F65C1FAD658712BDFDEE8B9

Sauvegarde des 12 inscriptions récentes :
05FF3BB292B17D14F21A55EA576501AE73DB083E6DF6AA5D3471AE8D72FEC122

Consolidé et registre actif après intervention :
5DBAD354D5EA96B59AE2FBE23C50B7C511571CCF1D6FEB0B9B6E72F4B3F436CD
```

Les 19 chemins ont été contrôlés dans le coffre, les 19 tailles et empreintes recalculées concordent. La racine du coffre conserve ses ACL protégées. Le CSV et les bruts restent hors Git.

## Limites et suite

L'écart de couverture du registre est résolu. La cause pour laquelle la version historique était restée au chemin actif n'est pas établie. La concordance des fichiers avec le registre confirme leur intégrité actuelle ; elle ne constitue pas une validation supplémentaire des tests techniques.

Le dernier export `transfert/C12-20261106T210309003Z.json`, le complément WAN et les fichiers Kali restent à traiter selon le plan de clôture. Le présent travail n'ajoute aucune validation de recette, approbation de scan ou preuve de stabilité du DC.
