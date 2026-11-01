# M-CLIENT-01 — contrôle préalable de la topologie

Ce contrôle en lecture seule vérifie la configuration Hyper-V du profil **audit** avant toute exception réseau. Il ne démarre ni n'arrête de VM, ne modifie aucune carte et ne teste pas le comportement des flux. Il doit être relancé immédiatement avant chaque nouvelle fenêtre d'audit : un PASS ancien ne vaut pas autorisation permanente.

## Exécution

Conftest `0.71.1` (OPA `1.21.1`) est installé localement dans `%LOCALAPPDATA%\CyberCorp\tools\conftest\0.71.1\conftest.exe`. La version est fixe pour rendre les résultats comparables. L'archive Windows x86_64 officielle a été vérifiée avant extraction avec le SHA-256 `34d623334b5e7ed4465bf62a4cb3b092684859cd3d224bbd390925a0852b922a`.

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

## Limites et suite

- Le troisième adaptateur pfSense déconnecté est compatible avec le WAN absent du profil audit, mais l'export ne lit pas la configuration **interne** de pfSense. Vérifier cette correspondance et les règles natives avant toute ouverture.
- Le rapport prouve un état à un instant donné, pas l'absence de changement ultérieur ni l'absence de route ou de flux. T03 exige encore un échec de sortie contrôlé ; T04 exige un refus journalisé.
- La fiche de décision n'a toujours ni responsable, ni fenêtre, ni approbation. Ce PASS ne déclenche aucune autorisation de scan ou de règle temporaire.
- La capture d'écran de présentation reste à produire ; les exports bruts et leurs empreintes sont déjà disponibles.
