# Diagnostic CC-DC01 — 7 novembre 2026, 09 h 07–09 h 09 Europe/Paris

**Suivi ultérieur :** le [réarmement explicitement autorisé a été exécuté à 09:12 Europe/Paris](rearmement-dc01-2026-11-07.md), puis le DC redémarré. Dix jours de grâce initiale sont retrouvés ; l'activation et la surveillance de plus d'une heure restent ouvertes. Le présent document conserve le diagnostic initial de 09:07–09:09.

Au diagnostic initial, le DC est accessible par PowerShell Direct. Sa licence reste en notification et sa stabilité durable n'est pas rétablie. Cette phase a réalisé des lectures et conservé un diagnostic ; aucune commande d'activation ou de réinitialisation, modification d'horloge, de DNS, de WAN ou de règle réseau n'avait alors été exécutée. Aucun autre démarrage de VM n'a été effectué par l'agent.

## État observé

L'opérateur a démarré uniquement `CC-DC01` après avoir relevé 4,14 Gio libres et confirmé ses 2 Gio de démarrage. La mémoire libre immédiatement après démarrage était de 2,15 Gio. La collecte autonome suivante relève 2,613 Gio libres pour 11,752 Gio visibles par Windows. Le matériel est annoncé à 16 Gio, mais le budget opérationnel doit utiliser la mémoire visible et libre mesurée.

| VM | État constaté | Mémoire de démarrage |
| --- | --- | --- |
| CC-DC01 | Running | 2 Gio |
| CC-PFS01 | Saved | 1 Gio |
| CC-KALI01 | Saved | 1 Gio |
| CC-W11-01 | Off | 1 Gio |

Les trois mesures rapprochées de l'heure par PowerShell Direct donnent un écart DC moins milieu de l'intervalle hôte de +14,86 ms, -8,62 ms et -0,43 ms, pour des allers-retours de 49,74 ms, 4,61 ms et 3,00 ms. Ces estimations incluent les incertitudes de transport et de lecture. Aucun décalage important actuel DC/hôte n'est observé. Le DC indique `Romance Standard Time`, UTC+1, et le fournisseur `VM IC Time Synchronization Provider`, avec une dernière synchronisation réussie. Le service de temps de l'hôte répond en revanche qu'il n'est pas démarré (`0x80070426`) : sa synchronisation NTP n'est pas établie par cette collecte. L'heure n'a pas été modifiée.

## Licence et disponibilité

| Lecture | Résultat |
| --- | --- |
| Édition | Windows Server 2025 Standard Evaluation, TIMEBASED_EVAL |
| Installation | 13 octobre 2026, 16:32:13 UTC |
| État | LicenseStatus 5, notification |
| Raison | 0xC004F009 |
| Grâce restante | 0 minute |
| Réinitialisations Windows / SKU disponibles | 1 / 1 |
| `slmgr /xpr` | Windows est en mode notification |
| Heure approuvée affichée par `/dlv` | 7 novembre 2026, 09:07:46, heure locale |
| EvaluationEndDate | Valeur sentinelle de 1601, non exploitable comme échéance réelle |

Les événements `User32` 1074 confirment plusieurs arrêts demandés par `wlms.exe`, notamment le 6 novembre à 18:10:28 UTC, avec commentaire d'expiration de licence. Le diagnostic ne démontre pas la consommation des 180 jours. Microsoft distingue l'évaluation de 180 jours de l'activation initiale requise dans les dix premiers jours pour éviter les arrêts automatiques : [Evaluation Center](https://www.microsoft.com/en-us/evalcenter/evaluate-windows-server-2025).

DNS, NTDS, Netlogon, DFSR, W32Time, sppsvc et wlms sont en cours d'exécution lors de la collecte. Les partages SYSVOL et NETLOGON sont présents. Ces lectures ponctuelles ne valident pas toute la recette ni une absence future d'arrêt automatique.

## Résolution et confinement

- DNS IPv4 du DC : `127.0.0.1`, DNS IPv6 de sa carte : `::1`.
- Le SRV AD `_ldap._tcp.dc._msdcs.ad.cybercorp.test` se résout vers `cc-dc01.ad.cybercorp.test`, port 389, adresse `10.77.10.10`.
- La requête A pour `activation-v2.sls.microsoft.com` auprès du DNS local expire.
- Aucun redirecteur affiché ; recours aux indications de racine actif. Ce constat ne suffit pas à déclarer le DNS incorrect.
- Route par défaut du DC vers `10.77.10.1` ; pfSense est enregistré, donc ne route actuellement pas le trafic.
- WAN pfSense MAC `00155D013C0E`, sans commutateur et déconnecté ; LAN/AUDIT maintenus sur leurs commutateurs respectifs.
- Interface hôte de maintenance `172.31.250.1/24` présente ; aucun objet WinNAT retourné.

L'absence actuelle de sortie est cohérente avec le confinement. Aucune nouvelle tentative `/ato` n'a été faite. Une activation en ligne nécessiterait une maintenance réseau explicitement autorisée et bornée.

## Conservation et divergence du registre

Le diagnostic JSON est conservé dans le coffre hors Git et OneDrive :

- Collecte : `transfert/diagnostic-dc01-20261107T080802480Z.json`.
- Copie vérifiée : `brut/M-CLIENT-01_autre_20261107T080902917Z_CC-DC01_Diagnostic.json`.
- Taille : 57 533 octets.
- SHA-256 source et copie : `B4E9D66C3AE7C069CCD4B8B5F0AEC6670C266EC48EA36278E66BDAE5B764AD40`.
- Manifeste : `transfert/controle-diagnostic-registre-20261107T080902917Z.json`.
- Collecteur utilisé : `transfert/diagnostic-dc01-20261107.ps1`, également hors dépôt. Il n'affiche ni mot de passe ni clé produit et n'applique aucune correction.

Le champ `ok` d'une sonde du collecteur signifie uniquement qu'aucune exception PowerShell n'a été levée. Pour les programmes natifs, leur sortie doit aussi être interprétée ; le retour d'erreur de `w32tm` sur l'hôte n'est pas un succès de synchronisation.

Le bilan précédent annonçait 27 pièces. À 08:09 UTC, le chemin accessible présente un actif de **12 lignes**, un historique de **7 lignes** et un consolidé de **19 lignes**. Les fichiers référencés par ces versions ont tous des tailles et SHA-256 conformes. Avant la nouvelle copie du diagnostic, `brut` contient 19 fichiers ; il en contient ensuite 20. Cela ne démontre pas la perte des autres pièces ni l'annulation de leurs contrôles historiques, mais leur disponibilité actuelle n'est pas établie.

L'actif reste inchangé : SHA-256 avant/après `05FF3BB292B17D14F21A55EA576501AE73DB083E6DF6AA5D3471AE8D72FEC122`. Le diagnostic nouveau n'est **pas inscrit au registre divergent** ; il est conservé avec son manifeste en attendant l'identification de la version à 27 pièces. Aucun remplacement ni réenregistrement en bloc n'a été effectué.

Le HEAD local observé au diagnostic était `a62864f`, différent du dernier commit poussé `2bf60ab` annoncé à la reprise. La lecture ultérieure de l'historique explique cette différence : `2bf60ab` est un ancêtre, suivi de trois commits locaux préexistants, préservés. Aucun checkout, reset ou push n'a été exécuté. Le commit documentaire demandé ensuite par l'utilisateur est `66b6c8a`. Le dossier `tmp/` préexistant est préservé. Voir le [suivi des lectures et de la préparation](preparation-activation-dc01-2026-11-07.md).

## Proposition initiale avant accord

Pour tenter de rétablir une période de grâce sans modifier le réseau, la proposition est d'exécuter **une seule fois** la commande suivante **dans CC-DC01**, puis de redémarrer proprement **ce seul DC** si la commande le demande :

```powershell
cscript.exe //Nologo "$env:windir\System32\slmgr.vbs" /rearm
```

Cette commande modifie l'état de licence et peut consommer l'unique réinitialisation disponible. Elle réinitialise les temporisateurs d'activation ; elle ne garantit ni une nouvelle durée de 180 jours ni une activation réussie. Microsoft documente son fonctionnement dans la [référence Slmgr](https://learn.microsoft.com/en-us/windows-server/get-started/activation-slmgr-vbs-options). Au terme du diagnostic initial de 09:09, elle était **non exécutée**, conformément à la demande d'explication et d'accord préalable. L'accord et l'exécution ultérieurs sont consignés dans le suivi lié en tête de page.

Après accord : conserver le résultat exact, redémarrer si nécessaire, réouvrir une session Direct, relire `/dlv` et `/xpr`, mesurer les ressources et observer le DC au-delà d'une heure de fonctionnement. Préparer ensuite, avec autorisation distincte, la maintenance réseau nécessaire à l'activation officielle de l'évaluation. Une période de grâce retrouvée ne suffira pas à déclarer l'activation ou toute la recette validée.
