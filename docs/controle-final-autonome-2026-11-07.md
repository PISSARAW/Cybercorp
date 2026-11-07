# Contrôle autonome de clôture — 7 novembre 2026

**État arrêté à 15 h 08 Europe/Paris (14:08 UTC).** Le lot autonome de vérification des preuves, de l'hôte et de la topologie est terminé. Le projet reste en recette ; aucune décision de remise n'est prononcée.

**Suite ultérieure :** la [tentative de reprise W11 à 15 h 27 et le pilotage métier depuis l'hôte](reprise-powershell-metier-2026-11-07.md) sont documentés séparément. W11 a été remis en état enregistré faute de marge mémoire ; aucune authentification n'a été tentée. L'inscription de cette pièce porte ensuite le registre à 43 lignes. Les chiffres de 42 lignes et l'absence d'intervention VM ci-dessous décrivent uniquement le lot de 15 h 08.

## Périmètre et méthode

Lectures des fichiers du coffre, recalcul des empreintes SHA-256, contrôle des droits de sa racine, lectures Hyper-V et WinNAT, export frais et exécution du vérificateur Conftest existant. Aucun accès invité, essai d'authentification, démarrage ou arrêt de VM, changement réseau ou scan n'a été effectué.

Les scripts ont été exécutés avec une politique d'exécution limitée au processus PowerShell, sans modifier la politique persistante de l'hôte. Les fichiers préexistants de travail sous `tmp/` et les secrets n'ont pas été modifiés. Le rapport Google et le site hébergé n'ont pas été actualisés dans ce lot.

## Résultats constatés

| Contrôle | Résultat | Portée |
| --- | --- | --- |
| Registre avant ajout | 38 lignes, aucun doublon d'identifiant, de chemin ou d'empreinte ; fichiers présents, tailles et SHA-256 conformes. | Empreinte identique au dernier bilan de reprise. |
| Annexes des quatre manifestes | 90 fichiers supplémentaires contrôlés : diagnostic (1), réarmement (5), activation (51), reprise (33). | 128 fichiers distincts vérifiés au total avant ajout ; ce périmètre n'est pas un inventaire exhaustif des fichiers non référencés du coffre. |
| Protection du coffre | Héritage désactivé ; trois autorisations explicites de contrôle total : opérateur, SYSTEM et administrateurs locaux. | Lecture de l'ACL de la racine ; aucune modification des droits. |
| Extraits de remise | Aucun fichier dans `extraits-expurges/`. | La préparation et la relecture humaine de la remise restent ouvertes. |
| Hôte à 14:08:15 UTC | 2,630 Gio libres ; DC Running, W11/pfSense/Kali Saved. | Mesure ponctuelle, pas une validation T05 sur dix minutes. |
| Confinement déclaré | LAN/AUDIT Private, WAN-MAINT Internal ; WAN pfSense sans commutateur et déconnecté ; aucun WinNAT. | Configuration lue sur l'hôte ; aucun flux ni règle interne pfSense testé. |
| Conftest à 14:08:18 UTC | PASS réel et cinq FAIL attendus, 18 règles par cas. | Export frais ; switch externe, seconde carte Kali, WAN rebranché, VM absente et champ manquant correctement refusés. |
| Après inscription | 42 lignes, identifiants/chemins/empreintes uniques ; 42 pièces principales présentes avec tailles et SHA-256 conformes. | Les quatre nouveaux fichiers source ont été copiés et vérifiés par le script d'enregistrement existant. |

La présence de W11 en état Saved ne démontre pas que le verrouillage de `local-admin` a expiré. Le dernier diagnostic invité reste celui du [suivi d'accès](diagnostic-acces-w11-2026-11-07.md). Une reprise devra commencer par une mesure mémoire ; ne pas déduire le coût de reprise d'une VM Saved de sa seule mémoire de démarrage.

## Pièces nouvelles et registre

Les quatre pièces sont inscrites dans `brut/`, hors Git et OneDrive. Leurs heures d'événement proviennent des JSON de collecte ou d'exécution.

| Pièce | Identifiant | SHA-256 |
| --- | --- | --- |
| Audit registre, annexes, ACL et WinNAT | `M-CLIENT-01_autre_20261107T140849783Z_MONNOKOELOBA_ControlePreuves` | `AA9065174A9A0A8DE29060BCF6CEAC91D31AAAF661750A6D6F6CBCF5A6DB75AA` |
| Relevé hôte, mémoire, VM et MAC | `M-CLIENT-01_topologie_20261107T140849814Z_MONNOKOELOBA_HyperV` | `859685FDA9F3081C96FA947F6183AAA6CFB4EEE976CD688AF9BC9722075E1D7B` |
| Export frais de topologie | `M-CLIENT-01_topologie_20261107T140849846Z_MONNOKOELOBA_HyperV` | `C103CB476429098F5EC18F4840AFE878DA5153E1E2F4190072ABD551ACADA5A5` |
| Rapport Conftest | `M-CLIENT-01_topologie_20261107T140849862Z_MONNOKOELOBA_Conftest` | `8B973A2BF00325BC4DF1F5850821CC2487B186771D99FBA8574D4975A76C2518` |

Avant ajout, le CSV a été sauvegardé sans écrasement sous `registre-avant-controle-final-20261107T140849720Z.csv`, SHA-256 `09B59BC57D56F8C5102F40F769E5F4BF0110CA3FED8256B6637B308F5530A171`.

Après ajout et relecture à `2026-11-07T14:08:49.9899019Z`, le registre de **42 lignes** a le SHA-256 `1E9FF0874C634BAFEDE58C4F030E7E7752C813650320075FE798CA15AE4FC3F9`. Les copies de travail et le relevé auxiliaire après inscription restent sous `transfert/controle-final-20261107T140752422Z/`. Ce relevé auxiliaire n'est pas une cinquième pièce inscrite.

## Recette et travail restant

La recette compte **2 tests validés, 1 à actualiser et 12 à faire**. T01/T02 conservent leur validation statique, désormais étayée par le contrôle frais. T10 passe de `Validé` à `À actualiser` : l'audit ancien et le gpresult du 6 novembre ne suffisent pas à conclure sur l'application actuelle du poste. Aucune nouvelle validation de recette n'est attribuée.

| Tests / livrable | Travail restant | Dépendance de reprise |
| --- | --- | --- |
| T05–T07, T10 | Profil métier mesuré dix minutes ; DNS A/PTR/SRV, authentification fraîche, gpresult et état Defender/SMBv1/pare-feu. | Budget mémoire mesuré, reprise W11 et accès adapté ; verrouillage et licence W11 à diagnostiquer. |
| T08–T09 | Finance autorisée, refus interservice, Direction/Syntheses en lecture seule ; compléter les traces Clients. | Jetons métier frais ; premier changement de mot de passe Direction. |
| T03–T04, M04 | Rapatrier les fichiers Kali ; démontrer les flux refusés et, si autorisée, l'exception avant/pendant/après avec Ndiff et retrait. | Profil adapté ; cibles explicitement autorisées ; nouvelle fenêtre approuvée pour M04. |
| T11 | Revue RDP/Tailscale et routage, preuve d'absence de route invitée. | Accès aux configurations effectives ; l'absence de WinNAT seule ne valide pas T11. |
| T12–T13 | Action bénigne, EVTX hachés, événement source, chronologie Hayabusa et qualification. | Poste disponible et contexte du mandat documenté. |
| T14–T15 | Restauration de fichier et reprise DC/laboratoire, hash/ACL, santé et durées. | Sauvegarde indépendante vérifiée et capacité de restauration isolée. |
| Remise | PDF client réel et son hash, extraits expurgés, rapport principal et support oral, décision signée. | Résultats et lacunes consolidés, relecteur humain et décideur identifiés. |

L'activation du DC, la remise en cohérence native des quatre GPO et la réactivation du blocage AUDIT sont déjà documentées dans la [reprise de 11 h 42](reprise-registre-audit-gpo-2026-11-07.md). Les huit erreurs SID/GUID du rapport GPOZaurr restent une limite de cet outil, avec contrôle natif indépendant ; elles ne sont pas présentées comme corrigées dans GPOZaurr.

## Trame de remise et d'oral à compléter

1. Présenter le besoin client, le livrable attendu et les autorisations encore manquantes.
2. Montrer la topologie réelle et le PASS accompagné des cinq contre-tests.
3. Présenter la correction native des GPO, les deux essais Clients observés et les scénarios métier restant à prouver.
4. Réserver la démonstration de l'exception réseau aux mesures complètes autorisées ; afficher les limites de l'ancien scan.
5. Relier l'événement Sysmon à la chronologie Hayabusa après réalisation de T12/T13.
6. Présenter la reprise, les lacunes et la décision humaine, sans transformer une absence de preuve en validation.

Cette trame est préparatoire. Elle ne constitue ni un support oral finalisé, ni un extrait relu pour diffusion, ni une approbation de remise.
