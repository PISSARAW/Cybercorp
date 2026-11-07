# Réarmement autorisé de CC-DC01 — 7 novembre 2026

CC-DC01 a retrouvé une période de grâce initiale après un unique réarmement autorisé et un redémarrage propre. L'activation officielle et la stabilité au-delà d'une heure restent à confirmer. Aucun DNS, lien WAN, règle réseau ou réglage d'horloge n'a été modifié ; aucune autre VM n'a été démarrée.

## Autorisation et exécution

Après présentation du risque de consommation de l'unique réinitialisation, l'utilisateur a explicitement répondu « Je te l'autorise » à la proposition d'un `/rearm`, du redémarrage du seul DC et des contrôles. Le [diagnostic initial](diagnostic-dc01-2026-11-07.md) conserve l'état préalable et les limites observées.

| Événement | UTC | Europe/Paris |
| --- | --- | --- |
| Début de l'unique `/rearm` | 08:12:27.0677559 | 09:12:27 |
| Retour de la commande, code 0 | 08:12:27.2719177 | 09:12:27 |
| Demande de redémarrage propre | 08:12:50.2798491 | 09:12:50 |
| Nouvel amorçage constaté dans l'invité | 08:12:57.2715760 | 09:12:57 |
| Contrôles après redémarrage | 08:15:10–08:15:13 | 09:15:10–09:15:13 |

La commande de licence exécutée **dans le DC**, par PowerShell Direct, est :

```powershell
cscript.exe //Nologo "$env:windir\System32\slmgr.vbs" /rearm
```

Résultat exact : « La commande a été exécutée. Redémarrez le système pour que les modifications soient prises en compte. » Le redémarrage a été demandé par `shutdown.exe /r /t 0 /d p:0:0`, sans option de fermeture forcée ; code de retour 0. Un fichier témoin créé avant le réarmement empêche sa répétition automatique. Le nouvel horaire d'amorçage confirme le redémarrage effectif.

## Résultat immédiat

| Contrôle | Avant | Après redémarrage |
| --- | --- | --- |
| LicenseStatus | 5, notification | 2, période de grâce initiale |
| Raison | 0xC004F009 | 0x4004F00C |
| Grâce restante | 0 minute | 14 400 minutes au premier relevé, 14 398 au contrôle suivant |
| Réinitialisations Windows / SKU restantes | 1 / 1 | 0 / 0 |
| `/xpr` | Mode notification | Fin de grâce le 17/11/2026 à 09:13:10, heure locale du DC, UTC+1 |

La valeur transitoire `4294967295` retournée par WMI immédiatement après `/rearm`, avant redémarrage, n'est pas interprétée comme un nombre de réinitialisations utilisables. Après amorçage, WMI et `/dlv` confirment zéro.

Ce résultat fournit **dix jours de grâce initiale**, pas une activation de l'évaluation ni une nouvelle période démontrée de 180 jours. La commande ne doit pas être relancée. L'activation doit être traitée avant l'échéance affichée. Microsoft documente le [réarmement des temporisateurs](https://learn.microsoft.com/en-us/windows-server/get-started/activation-slmgr-vbs-options) et [l'activation initiale de l'évaluation](https://www.microsoft.com/en-us/evalcenter/evaluate-windows-server-2025).

À 09:15 Europe/Paris :

- `dcdiag /test:Advertising /test:SysVolCheck /test:NetLogons /q` retourne le code 0, sans erreur affichée.
- DNS, NTDS, Netlogon, DFSR, W32Time, sppsvc et wlms sont en cours d'exécution.
- SYSVOL et NETLOGON sont présents ; le SRV AD se résout vers CC-DC01 / `10.77.10.10`.
- Aucun événement System 1074 n'est relevé depuis ce nouvel amorçage, à ce contrôle précoce.
- Le DC seul est actif, avec 2 Gio affectés ; l'hôte conserve 2,346 Gio libres. Kali et pfSense restent enregistrés, W11 arrêté.

Ces contrôles portent sur la disponibilité initiale et trois tests AD ciblés. Ils ne valident ni toute la recette ni la fin durable des arrêts automatiques.

## Surveillance en cours

Un processus PowerShell caché, PID de lancement `18236`, a démarré le 7 novembre à 08:15:34 UTC. Il effectue des **lectures uniquement**, toutes les 30 secondes, jusqu'à 65 minutes après le nouvel amorçage : fin prévue vers **10:18 Europe/Paris**. Il ne redémarre aucune VM, n'applique aucune correction et signale simplement une RAM libre inférieure à 1,5 Gio.

Il relève l'état Hyper-V, la RAM libre, l'heure du dernier amorçage et l'état de licence. Le bilan final vérifie un amorçage inchangé, plus d'une heure de fonctionnement, l'absence d'événement 1074 depuis cet amorçage, des échantillons tous actifs et l'absence d'erreur de lecture. Le bilan ne peut être déclaré réussi avant sa production et sa lecture.

Fichiers sous le coffre `M-CLIENT-01/transfert` :

- `surveiller-dc01-apres-rearm-20261107.ps1` : collecteur de surveillance.
- `surveillance-dc01-rearm-20261107.launch.json` : lancement et empreinte du collecteur.
- `surveillance-dc01-rearm-20261107.samples.jsonl` : mesures successives.
- `surveillance-dc01-rearm-20261107.final.json` : bilan créé uniquement à la fin ou en cas d'erreur fatale.

Le premier relevé vérifié à 09:16:05 Europe/Paris montre le DC actif, le même amorçage, une grâce en cours et 2,326 Gio libres. **La surveillance est en cours au moment de cette documentation.** Pour permettre la mesure, laisser l'hôte et le DC actifs ; une fermeture de session ou un arrêt pourrait l'interrompre.

## Conservation des preuves

Cinq pièces ont été copiées sans écrasement dans `brut`, tailles et SHA-256 source/copie vérifiés. Le manifeste est `transfert/controle-copies-rearm-20261107T081608418Z.json`.

| Pièce | Fichier dans `brut` | SHA-256 |
| --- | --- | --- |
| Autorisation, préconditions et témoin d'exécution | `M-CLIENT-01_autre_20261107T081608418Z_CC-DC01_Rearm-1.json` | `1BE04B0A18884822C3357DE38978162FBDB08ED45623E847C16467E46FE096DA` |
| Retour du réarmement | `M-CLIENT-01_autre_20261107T081608418Z_CC-DC01_Rearm-2.json` | `182C4FA308F076A8B5577801D12A09CA95BC5E6643B0AF775F26CDFDC6B93132` |
| Demande de redémarrage | `M-CLIENT-01_autre_20261107T081608418Z_CC-DC01_Rearm-3.json` | `5D2F0B5B9692C185810E4A749175936F8595BA524A6EA14C04693A722D7617F2` |
| Contrôles après redémarrage | `M-CLIENT-01_autre_20261107T081608418Z_CC-DC01_Rearm-4.json` | `33BC06D7DB8A7AC56B4E8A2D1ECA61DE1B817F3F23D0C0B6EC8D0BA21A0CCD9B` |
| Lancement de la surveillance | `M-CLIENT-01_autre_20261107T081608418Z_CC-DC01_Rearm-5.json` | `FC20BE5C79E27C1D3CD67833A6A7EEECE5BA645EF47BEB85353FE20C2A261C63` |

Le registre divergent reste inchangé, SHA-256 `05FF3BB292B17D14F21A55EA576501AE73DB083E6DF6AA5D3471AE8D72FEC122`. Ces nouvelles pièces sont conservées avec un manifeste séparé, **sans inscription au registre actif**. Le nombre de pièces disponibles dans ce chemin ne doit pas être confondu avec les 27 pièces historiques annoncées.

## Suite nécessaire

Lire et conserver le bilan de surveillance après son achèvement, puis qualifier la stabilité. Préparer une maintenance réseau bornée pour l'activation officielle, avec accord préalable avant tout DNS/WAN/NAT/règle ou démarrage de pfSense. Le DC conserve son DNS local. Résoudre séparément la divergence de versions du coffre et du dépôt. Les validations métier et GPO restent différées jusqu'à la qualification de la stabilité.
