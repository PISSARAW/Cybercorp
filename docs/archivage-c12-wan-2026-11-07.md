# Archivage du dernier export C12 et du complément WAN

Le 7 novembre 2026 à 07:23:30 UTC, trois pièces ont été enregistrées dans le coffre M-CLIENT-01 avec `scripts/enregistrer-preuve.ps1`, après recherche de doublons par empreinte. Le registre a été sauvegardé avant l'ajout. Les sources sont conservées.

| Pièce | Identifiant | Taille |
| --- | --- | ---: |
| Dernier export C12 | `M-CLIENT-01_topologie_20261107T072330434Z_MONNOKOELOBA_HyperV` | 2448 |
| Console pfSense et interfaces | `M-CLIENT-01_topologie_20261107T072330513Z_CC-PFS01_CaptureEcran` | 5544 |
| `ifconfig hn0` | `M-CLIENT-01_topologie_20261107T072330546Z_CC-PFS01_CaptureEcran` | 30099 |

Empreintes SHA-256, dans le même ordre :

```text
94BB58931B14C8C36B24D894E9F4FC4E6A14B0DAFF22A95CA08EB0E2DA24C02F
6909250057EEE736D948B9CB96E7C975BAE10D6C7AA75913128B65B060C3F534
41A192926610E7E2A9383AB77FDEBA85B8EA57F82D4611CB698053BE81BD98A3
```

L'export provient de `transfert/C12-20261106T210309003Z.json`. Son heure d'événement est `2026-11-06T21:03:11.1080980Z`, lue dans le JSON. Son empreinte concorde avec celle documentée avant archivage. Aucun rapport Conftest n'est associé à cet export ; le PASS antérieur concerne une autre collecte.

Les captures proviennent respectivement de `Capture d'écran 2026-11-06 214310.png` et `Capture d'écran 2026-11-06 220110.png`, dans le dossier Screenshots de l'opérateur. Elles montrent WAN `hn0`, LAN `hn1`, AUDIT `hn2`, puis WAN `172.31.250.2/24`, MAC `00:15:5d:01:3c:0e`, état `no carrier`. L'heure exacte de prise de vue n'étant pas établie, leur champ `evenement_utc` reste vide.

La correspondance MAC avec Hyper-V demeure décrite dans le journal du 6 novembre ; aucune nouvelle sortie native contenant les MAC Hyper-V n'a été retrouvée parmi ces trois pièces. Le JSON C12 ne contient pas de MAC. Les pièces archivées ne démontrent ni l'état actuel du WAN ni les règles de filtrage.

Contrôle final : **22 lignes, zéro doublon d'identifiant, 22 tailles et empreintes conformes**. SHA-256 du registre après archivage : `4A5BB4B2C7BFC40A528B213006B405FCA85DD48CB0C8B5C259D9352FD1D13FF6`. Sauvegarde préalable : `registre-avant-archivage-c12-20261107T072330156Z.csv`. Les bruts et le registre restent dans le coffre hors Git.
