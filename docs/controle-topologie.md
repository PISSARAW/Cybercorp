# M-CLIENT-01 — contrôle préalable de la topologie

**Suivi ultérieur du 7 novembre, 15 h 30 Europe/Paris :** la [tentative de reprise W11](reprise-powershell-metier-2026-11-07.md) a été interrompue pour conserver la marge mémoire, sans changement réseau ni test de flux. Sa pièce porte le registre à 43 lignes contrôlées. Le dernier Conftest reste celui de 14:08 UTC décrit ci-dessous.

**État courant au 7 novembre, 14:08 UTC :** [nouvel export et contrôle autonome de clôture](controle-final-autonome-2026-11-07.md). PASS réel et cinq FAIL attendus, 18 règles par cas ; les quatre nouvelles pièces portent le registre à 42 lignes vérifiées. WAN Hyper-V déconnecté et aucun WinNAT ; DC Running, trois autres VM Saved. Aucun flux testé ; T03/T04 restent à faire. Les comptes de registre et travaux d'archivage mentionnés dans les suivis ci-dessous sont historiques.

**Suivi du 7 novembre, 07:33 UTC :** [PASS sur le dernier C12 et sur une topologie actuelle](avancement-autonome-2026-11-07.md), avec cinq refus attendus dans chaque série. Relevé natif des MAC Hyper-V archivé. Ces résultats complètent l'archivage décrit ci-dessous ; le registre compte 27 pièces vérifiées. Les mentions d'absence de rapport sur le dernier C12 sont désormais historiques.

**Mise à jour du 7 novembre :** [registre réconcilié](reconciliation-registre-2026-11-07.md), puis [dernier export C12 et deux captures WAN archivés](archivage-c12-wan-2026-11-07.md). Le registre actif compte 22 lignes uniques, avec 22 tailles et SHA-256 conformes. Aucun PASS Conftest n'a été produit sur le dernier export. Les mentions de réconciliation et d'archivage à faire ci-dessous sont historiques.

Ce contrôle en lecture seule vérifie la configuration Hyper-V du profil **audit** avant toute exception réseau. Il ne démarre ni n'arrête de VM, ne modifie aucune carte et ne teste pas le comportement des flux. Il doit être relancé immédiatement avant chaque nouvelle fenêtre d'audit : un PASS ancien ne vaut pas autorisation permanente.

**Suivi du 6 novembre, soir :** nouveau PASS réel et cinq refus attendus examinés ; export, rapport, C10 et C11 archivés et contrôlés en séance. C12 complète les lectures Hyper-V et pfSense du WAN. Les huit nouvelles pièces du soir sont présentes sous `brut`, mais le registre accessible lors de la documentation ne reflète pas leurs lignes annoncées : réconcilier cet écart avant clôture. Le dernier export C12 reste dans `transfert`, sans inscription ni exécution Conftest confirmées. Voir le [bilan de reprise](journal-deploiement.md#reprise-20261106-soir).

## Exécution

Conftest `0.71.1` (OPA `1.21.1`) doit être installé localement dans `%LOCALAPPDATA%\CyberCorp\tools\conftest\0.71.1\conftest.exe` sur chaque hôte. La version est fixe pour rendre les résultats comparables. L'[archive Windows x86_64 officielle](https://github.com/open-policy-agent/conftest/releases/tag/v0.71.1) est vérifiée avant extraction avec le SHA-256 `34d623334b5e7ed4465bf62a4cb3b092684859cd3d224bbd390925a0852b922a`.

Depuis la racine du dépôt, installer l'outil une fois (accès HTTPS à GitHub, sans droits administrateur) :

```powershell
.\scripts\installer-conftest.ps1
```

L'installateur vérifie l'empreinte avant toute extraction, puis la version de l'exécutable. Une installation existante de la bonne version est conservée. Pour un hôte hors ligne, transférer l'archive officielle et utiliser `-Archive 'C:\transfert\conftest_0.71.1_Windows_x86_64.zip'` ; la même empreinte est exigée. Un autre emplacement peut être choisi avec `-DossierInstallation`, puis transmis au vérificateur avec `-Conftest 'C:\chemin\conftest.exe'`. Le vérificateur reste en lecture seule et ne télécharge rien.

Depuis la racine du dépôt, choisir un nom de sortie **nouveau** dans un dossier local restreint hors Git et OneDrive, puis exécuter :

```powershell
.\scripts\export-hyperv-topology.ps1 -OutputPath 'C:\chemin-restreint\topologie-AAAAmmjjTHHMMSS.json'
.\scripts\verifier-topologie.ps1 -Topologie 'C:\chemin-restreint\topologie-AAAAmmjjTHHMMSS.json' -DossierRapport 'C:\chemin-restreint'
```

L'export contient uniquement l'heure UTC, les noms/types des commutateurs pertinents et le rattachement/état des cartes des VM `CC-*`. La [politique Rego](../policy/topology.rego) code V01–V05. Le vérificateur exige un PASS sur l'export réel et un FAIL sur chacune des cinq [copies de test](../tests/topology/) : switch externe, seconde carte Kali, WAN rebranché, VM manquante et champ de connexion absent. Il refuse aussi une exécution à zéro règle. Les copies fautives ne représentent **pas** l'état de l'hôte.

Conserver l'export et le rapport via [enregistrer-preuve.ps1](../scripts/enregistrer-preuve.ps1) avec l'étape `topologie`. Les copies expurgées destinées à la remise doivent être relues séparément.

## Première exécution — 1er novembre 2026

À `16:26:00 UTC` (`17:26:00 Europe/Paris`), l'export réel a constaté `CC-LAN` et `CC-AUDIT` en `Private`, `CC-WAN-MAINT` en `Internal`, une seule carte sur chacune des VM DC/W11/Kali, Kali sur `CC-AUDIT`, et trois cartes pfSense dont une déconnectée. La politique a rendu **PASS** sur cet export et **FAIL** sur les cinq copies fautives, avec les motifs attendus.

Pièces brutes enregistrées dans le coffre M-CLIENT-01 :

| Pièce | Identifiant du registre | SHA-256 |
| --- | --- | --- |
| Export Hyper-V retenu | `M-CLIENT-01_topologie_20261101T162606114Z_HOTE-HYPERV_HyperV` | `35283529490BAEE1FD95FA999BE34D4464A7A1BAE434A5AE3F83E73B24B5F715` |
| Rapport Conftest complet | `M-CLIENT-01_topologie_20261101T162606177Z_HOTE-HYPERV_Conftest` | `BECF2072C5277D310766A71ABF485AA3643460B485B2BAB22814BB82C7866358` |

Des passes exploratoires et des rapports intermédiaires ont également été conservés dans le registre. Les deux pièces ci-dessus sont les références retenues pour M02 ; ne pas effacer ou réécrire les pièces antérieures.

## Reprise du 6 novembre — rapport M02 et captures C10–C12

Le rapport `M-CLIENT-01_M02_Conftest_20261106T184303654Z.json`, 5056 octets, a été produit à `2026-11-06T18:43:03.6549012Z` avec Conftest **0.71.1** / OPA **1.21.1**. Son entrée réelle est `transfert/M04-20261106T185145/topologie.json`, 2448 octets, profil `audit`, collectée à `2026-11-06T17:52:21.6782248Z`. Le nom du dossier `M04-*` ne transforme pas le contrôle M02 en campagne réseau. Un autre export de 2448 octets figure dans `transfert/M04-20261106T184848` ; il n'est pas désigné comme entrée du rapport retenu.

L'empreinte actuelle de l'entrée correspond à `sha256_entree`. Celle de `policy/topology.rego` correspond à `sha256_politique` : `F0F4A694ABDD6BBEF02A98C24B8153E5FDDE8D3DF298C740BD1F0D28EECBC419`. Les six résultats et leurs motifs ont été examinés :

| Cas | Attendu / obtenu | Code | Motif observé |
| --- | --- | --- | --- |
| `reel` | PASS / PASS | 0 | Aucun échec ; 18 règles comptabilisées. |
| `switch-externe-interdit` | FAIL / FAIL | 1 | V01 : `CC-AUDIT` doit être privé. |
| `kali-bridge-interdit` | FAIL / FAIL | 1 | V02/V03 : Kali seulement sur `CC-AUDIT` ; V02 : exactement une carte. |
| `wan-rebranche-interdit` | FAIL / FAIL | 1 | V04 : troisième carte pfSense non déconnectée. |
| `inventaire-incomplet` | FAIL / FAIL | 1 | V05 : `CC-DC01` absente ou dupliquée. |
| `champ-manquant` | FAIL / FAIL | 1 | V02/V03 : carte Kali absente, déconnectée ou état inconnu. |

Les motifs sont résumés ici en français lisible. Les messages du JSON restent partiellement altérés après relecture explicite UTF-8 ; leur cause d'encodage n'est pas résolue. Le brut n'a pas été réécrit pour corriger l'affichage. La première récupération de tableau JSON avait aussi donné un comptage de 1 au lieu de 43 pour le lot de captures : la lecture a été corrigée pour éviter un tableau imbriqué sous PowerShell 5.1, puis les 43 copies ont été contrôlées.

| Pièce | Identifiant communiqué lors de l'inscription | Octets | SHA-256 revérifié sous `brut` |
| --- | --- | --- | --- |
| Rapport Conftest | `M-CLIENT-01_topologie_20261106T202254132Z_MONNOKOELOBA_Conftest` | 5056 | `A8F72396A96F1C7FBAE2C928ADD6D6AB441E635A6327C69712932BEB28C12EC9` |
| Export réel associé | `M-CLIENT-01_topologie_20261106T202606368Z_MONNOKOELOBA_HyperV` | 2448 | `FC25F09C8D2A011A5F5683E4F1A0567F60937EAED1EC065FF6EFC09FCE3E7A78` |
| C10 — tableau des six résultats | `M-CLIENT-01_topologie_20261106T203151512Z_MONNOKOELOBA_CaptureEcran` | 21206 | `28403788F9034CE09AAE1EAA9D8FFC405C42699E2932DFD0F91BB6365C441522` |
| C11 — motifs des refus | `M-CLIENT-01_topologie_20261106T203452384Z_MONNOKOELOBA_CaptureEcran` | 43137 | `D531C0141F7E80006443702F1839F82F5809598AB2803CEDA5353FC70E49F6AB` |
| C12 — interfaces Hyper-V | `M-CLIENT-01_topologie_20261106T203930099Z_MONNOKOELOBA_CaptureEcran` | 20810 | `526C447B3DCE6FC85B5D4686A347F32219BEC7D9DE1D2A7839CA0EAA3255C73E` |

Les contrôles communiqués donnent deux lignes et des tailles/SHA-256 conformes pour le rapport et l'export, puis deux lignes et des tailles/SHA-256 conformes pour C10/C11. C12 a une sortie d'inscription, mais pas de contrôle séparé du registre communiqué avant la pause ; son PNG et son empreinte ont été vérifiés pendant la documentation. Les actions C10/C11 citent l'identifiant du rapport. Les images initiales dans `captures` sont `M-CLIENT-01_C10_20261106T203031290Z_HOTE.png`, `M-CLIENT-01_C11_20261106T203425461Z_HOTE.png` et `M-CLIENT-01_C12_20261106T203848329Z_HOTE.png`. Leurs noms datent le rangement, pas la prise de vue ; `evenement_utc` reste vide dans les sorties d'inscription des captures.

### Concordance WAN pfSense et Hyper-V

À `2026-11-06T20:37:46.8248341Z`, C12 montre `CC-AUDIT` et `CC-LAN` en `Private`, une seule carte Kali sur `CC-AUDIT`, et trois cartes pfSense dont une sans commutateur, `Connected=False`. La première commande avait échoué parce que `Get-VMSwitch -Name` recevait deux noms ; elle a été remplacée par deux lectures séparées avant la capture retenue.

La console de `cc-pfs01`, pfSense **2.9.0-RELEASE**, donne WAN=`hn0`, `172.31.250.2/24` ; LAN=`hn1`, `10.77.10.1/24` ; AUDIT=`hn2`, `10.77.20.1/24`. Dans le Shell (option 8), la lecture `ifconfig hn0` montre la description WAN, MAC `00:15:5d:01:3c:0e`, `media: Ethernet autoselect (none)` et **`status: no carrier`**. L'adresse IP statique affichée ne prouve donc pas un lien actif.

Le relevé hôte fait correspondre `00155D013C0E` à la carte sans commutateur, `Connected=False` ; `00155D013C0F` est sur `CC-LAN`, et `00155D013C10` sur `CC-AUDIT`, toutes deux connectées. Cela établit la correspondance de la carte WAN observée, sans test de sortie ni conclusion sur les règles de filtrage. La capture de console pfSense et le relevé MAC complémentaire restent à archiver durablement ; C12 enregistrée montre uniquement le premier relevé Hyper-V.

### Dernier export C12 — point de reprise exact

`transfert/C12-20261106T210309003Z.json` a été produit avant la pause documentaire. Le fichier présent comporte 2448 octets, profil `audit`, `captured_utc=2026-11-06T21:03:11.1080980Z`, SHA-256 complet **`94BB58931B14C8C36B24D894E9F4FC4E6A14B0DAFF22A95CA08EB0E2DA24C02F`**. Il décrit les deux commutateurs privés, `CC-WAN-MAINT` interne et les rattachements attendus, dont une carte pfSense déconnectée. Il ne contient pas l'état d'alimentation des VM, les MAC ni les règles pfSense.

**Cet export n'est pas encore inscrit au registre et aucun nouveau rapport Conftest ne lui est associé.** Le PASS de `18:43:03 UTC` concerne l'export de `17:52:21 UTC`, pas celui de `21:03:11 UTC`. Reprendre par la réconciliation du registre décrite dans le [journal](journal-deploiement.md#reprise-20261106-soir), puis enregistrer une seule fois ce dernier export et compléter les pièces WAN. Ne pas refaire les inscriptions annoncées sans examiner les doublons.

## Limites et suite

- L'export ne lit pas la configuration **interne** de pfSense. La correspondance MAC/WAN a été vérifiée le 6 novembre en console ; archiver le complément et vérifier les règles natives avant toute ouverture.
- Le rapport prouve un état à un instant donné, pas l'absence de changement ultérieur ni l'absence de route ou de flux. T03 exige encore un échec de sortie contrôlé ; T04 exige un refus journalisé.
- La fiche de décision n'a toujours ni responsable, ni fenêtre, ni approbation. Ce PASS ne déclenche aucune autorisation de scan ou de règle temporaire.
- C10–C12 sont conservées ; les extraits de présentation restent à expurger et à faire relire. L'écart de registre empêche de déclarer la chaîne de preuves entièrement réconciliée.
