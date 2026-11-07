# Accès CC-W11-01 : session de base et verrouillage local — 7 novembre 2026

**Suivi ultérieur de 15 h 27 :** [W11 repris puis réenregistré faute de mémoire](reprise-powershell-metier-2026-11-07.md). Aucun essai PowerShell Direct ni mot de passe tenté ; le verrouillage local-admin n'a pas été relu. Les tests métier peuvent avancer avec les comptes correspondants sans attendre ce compte administratif. Le registre est ensuite porté à 43 pièces contrôlées ; les 38 lignes et la session ouverte décrites ci-dessous correspondent au diagnostic historique.

Le dernier état montré par l'utilisateur est une session **`CYBERCORP\usr.com01` ouverte sur CC-W11-01**. Le compte `local-admin` existe et est actif, mais la lecture CIM montre **`Lockout=True`**. La stratégie locale prévoit un verrouillage de **15 minutes après cinq échecs**, avec une fenêtre d'observation de 15 minutes. L'attente sans nouvelle tentative a été demandée ; le déverrouillage et une connexion administrative réussie ne sont pas encore confirmés.

Ce document complète la [reprise registre/AUDIT/GPO](reprise-registre-audit-gpo-2026-11-07.md). Il distingue les actions exécutées par l'agent sur l'hôte, les manipulations guidées de l'utilisateur dans la VM et les observations sur ses captures. Les heures visibles sur les images ne sont pas transformées en heures UTC d'événement.

## Travail déjà effectué et documenté

| Phase | Résultat et limites | Compte rendu |
| --- | --- | --- |
| Stabilisation du DC | Diagnostic natif, un réarmement autorisé, redémarrage propre, surveillance de 65 minutes sans arrêt observé. | [Diagnostic initial](diagnostic-dc01-2026-11-07.md), [réarmement et surveillance](rearmement-dc01-2026-11-07.md) |
| Activation du DC | Une activation réussie, échéance d'évaluation au 6 mai 2027 ; maintenance WAN/NAT bornée, puis DNS et confinement rétablis. | [Activation et preuves](activation-dc01-2026-11-07.md) |
| Registre | Sources correspondant aux 27 empreintes historiques retrouvées, 19 lignes anciennes conservées, récupérations et lots référencés ; actif à 38 lignes contrôlées. Le CSV historique exact à 27 lignes reste non retrouvé. | [Rapprochement et empreintes](reprise-registre-audit-gpo-2026-11-07.md#registre-rapproché-sur-les-sources) |
| AUDIT | Blocage IPv4 journalisé 1792264179 réactivé, règle chargée vérifiée, autres règles inchangées ; aucun nouveau test de flux. | [Correction AUDIT](reprise-registre-audit-gpo-2026-11-07.md#blocage-audit-réactivé) |
| Gouvernance GPO | Deux GPO par défaut sauvegardées puis alignées nativement ; quatre GPO cohérentes, ACL AD, versions et fichiers de stratégie inchangés pour les GPO corrigées. Contrôles AD ciblés conformes. | [GPO et contre-contrôles](reprise-registre-audit-gpo-2026-11-07.md#incohérence-gpo-corrigée-et-contre-contrôlée) |

Ces phases ont été consignées dans les commits locaux `66b6c8a`, `a396aa6`, `0f2bdc9` et `2c9c94f`. Aucun push n'a été exécuté par l'agent. Les fichiers préexistants sous `tmp/` ont été laissés hors commit.

## Tentatives PowerShell Direct depuis l'hôte

Trois tentatives de lecture ont été exécutées par l'agent avec le compte de secours de la VM :

1. `CC-W11-01\local-admin`, après le démarrage de W11, avec le secret initial chargé en mémoire depuis le fichier local ignoré par Git : refus d'identification.
2. `local-admin`, après attente de la fin du démarrage : même refus.
3. `CC-W11-01\local-admin`, avec un identifiant actuel saisi par l'utilisateur et exporté sous forme chiffrée : même refus.

L'erreur native était `PSDirectException` / « Les informations d'identification ne sont pas valides ». Elle ne permettait pas, à elle seule, de distinguer un secret incorrect d'un état du compte empêchant la connexion. Le verrouillage n'a été établi qu'ensuite par la lecture CIM dans la VM.

L'utilisateur a exécuté sur l'**hôte** :

```powershell
Get-Credential 'CC-W11-01\local-admin' |
    Export-Clixml "$env:LOCALAPPDATA\CyberCorp\connexion-w11.clixml"
```

L'agent a importé ce `PSCredential` sans afficher le secret. Le fichier était lisible sous le compte hôte et contenait un mot de passe non vide ; cela ne démontrait pas sa validité dans la VM. La pulsation Hyper-V était normale. Les essais automatiques ont ensuite cessé.

Le fichier CLIXML est protégé par DPAPI sous Windows et reste hors dépôt et OneDrive. Sa présence a été vérifiée pendant cette documentation, **sans relire son contenu**. Il n'est pas une pièce de preuve et n'a pas été archivé ni versionné. Sa suppression reste à effectuer après la fin de son usage ; le présent compte rendu ne prétend pas qu'elle a déjà eu lieu.

## Diagnostic guidé dans la console Hyper-V

| Étape | Action ou observation | Conclusion permise |
| --- | --- | --- |
| Cible du compte | Une première capture affichait `CYBERCORP\local-admin`. L'utilisateur a été guidé vers `.\local-admin` ; la capture suivante affichait « Connectez-vous à CC-W11-01 ». | La cible locale a été corrigée dans l'écran de connexion. Cela n'explique pas rétrospectivement les trois refus PowerShell Direct, qui utilisaient le compte local. |
| Saisie | L'utilisateur a signalé un refus du mot de passe, puis confirmé avoir contrôlé le clavier et la saisie. | Vérification déclarée par l'utilisateur ; aucune nouvelle tentative automatique ni affichage du secret par l'agent. |
| Compte métier | Une connexion avec `CYBERCORP\usr.com01` a été proposée pour disposer d'une session permettant des lectures locales. | Ce compte ne sert pas de substitut à une session administrative. |
| Droit de connexion à distance | L'utilisateur a rapporté un message relatif à l'autorisation de connexion à distance. Le texte exact et le code de l'erreur n'ont pas été conservés en sortie native. | Une session étendue utilisant RDP a été suspectée ; aucun droit RDP ou groupe local n'a été modifié. |
| Console de base | La désactivation de **Affichage → Session étendue** a été demandée dans la fenêtre VMConnect. L'utilisateur a ensuite confirmé être connecté. | L'enchaînement est compatible avec un refus lié au mode de connexion. L'état de l'option VMConnect n'a pas été exporté ; la cause exacte du message RDP n'est pas démontrée par un journal natif. |
| Identité | `whoami` a été demandé dans PowerShell **à l'intérieur de W11**. La capture montre `cybercorp\usr.com01`. | Une session métier est ouverte. Aucune élévation administrative ni nouvelle authentification AD en ligne n'est démontrée par `whoami` seul. |

Microsoft précise que la [session étendue de VMConnect utilise RDP et peut être remplacée par une session de base](https://learn.microsoft.com/en-ie/windows-server/virtualization/hyper-v/enhanced-session-mode). Le dépannage PowerShell Direct et celui de la session étendue sont des contrôles distincts ; aucun service n'a été redémarré dans cette séquence.

## État de local-admin établi par lecture CIM

Dans le PowerShell déjà ouvert sous `usr.com01` sur **CC-W11-01**, l'utilisateur a exécuté :

```powershell
Get-CimInstance Win32_UserAccount -Filter "LocalAccount=True AND Name='local-admin'" |
    Select-Object Name, Domain, Disabled, Lockout, Status
```

Résultat visible dans la capture :

```text
Name     : local-admin
Domain   : CC-W11-01
Disabled : False
Lockout  : True
Status   : Degraded
```

Le compte existe et n'est pas désactivé. Le verrouillage est un motif établi empêchant les connexions au moment du relevé ; il ne prouve pas que le mot de passe saisi était correct. `Status=Degraded` est conservé comme valeur de cet objet CIM, sans en déduire une corruption Windows ou un défaut matériel.

Les tentatives répétées, dont celles de l'agent, **ont pu contribuer au verrouillage**. La capture ne donne ni son heure de début, ni le détail des échecs, ni leur attribution. Aucun journal Security 4625/4740 ou relevé d'heure du dernier échec n'a été collecté pour établir cette chronologie.

## Stratégie de compte locale lue dans W11

L'utilisateur a ensuite exécuté, toujours dans **CC-W11-01** :

```powershell
net accounts
```

| Paramètre affiché | Valeur |
| --- | --- |
| Fermeture forcée de session après expiration | Jamais |
| Durée de vie minimale du mot de passe | 1 jour |
| Durée de vie maximale du mot de passe | 42 jours |
| Longueur minimale | 14 caractères |
| Historique | 24 mots de passe |
| Seuil de verrouillage | 5 échecs |
| Durée du verrouillage | 15 minutes |
| Fenêtre d'observation du verrouillage | 15 minutes |
| Rôle de l'ordinateur | STATION |

La commande s'est terminée correctement selon la capture. Ces valeurs sont une lecture de la stratégie locale, pas une preuve de conformité de toutes les GPO du poste ni de la provenance de chaque paramètre.

La consigne donnée a été de garder la session `usr.com01` ouverte et d'attendre **15 minutes sans nouvel essai avec local-admin**, puis de vérifier à nouveau `Lockout`. L'heure du dernier échec n'étant pas connue, aucune heure exacte de déverrouillage n'est annoncée. À la demande de documentation, l'utilisateur n'a pas encore confirmé la fin du délai et aucun nouveau relevé ne montre `Lockout=False`.

## Avertissement de licence W11 observé

Les captures du bureau affichent **Windows 11 Entreprise en évaluation**, « La licence Windows a expiré », build `26100.ge_release.240331-1435`. Ce texte visuel n'a pas été complété par une lecture native de l'état de licence ou des événements d'arrêt de W11. Aucune activation, commande `/rearm`, modification d'horloge, de DNS ou de WAN n'a été exécutée sur le poste. Sa disponibilité devra être qualifiée avant les essais prolongés. L'activation du DC est documentée séparément et ne démontre pas celle du client.

## Portée des preuves et état de reprise

Les commandes et résultats ci-dessus sont **transcrits depuis les captures fournies dans la conversation**. Aucun export natif de ces nouvelles lectures ni copie des images dans le coffre avec SHA-256 et inscription au registre n'est confirmé. Aucun identifiant de pièce n'a été inventé. Pendant la documentation, le CSV actif a été relu : **38 lignes**, SHA-256 `09B59BC57D56F8C5102F40F769E5F4BF0110CA3FED8256B6637B308F5530A171`, inchangé depuis la reprise précédente.

Cette phase n'a modifié aucun mot de passe, compte, groupe, droit de connexion, GPO, règle réseau ou paramètre de licence. Aucun déverrouillage manuel ni nouvelle tentative d'authentification n'a été effectué pendant la documentation. Le dernier profil VM mesuré reste DC/W11 actifs, pfSense/Kali Saved, environ 1,95 Gio libres ; il n'a pas été remesuré pour ce compte rendu.

La prochaine action guidée est une **lecture de `Lockout` dans la session usr.com01 après le délai sans essai**. Une nouvelle connexion administrative ne sera à constater qu'après un résultat déverrouillé. Nouveau `gpresult`, contrôles Defender/SMBv1, essais SMB Finance/Clients/Syntheses, premier changement de mot de passe Direction, diagnostic natif de licence W11 et décision de remise restent ouverts. Les auxiliaires préparés dans le coffre n'ont pas été exécutés sur W11.
