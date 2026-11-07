# Reprise des tests métier depuis l'hôte — 7 novembre 2026

**Bilan d'exécution à 15 h 27 Europe/Paris ; inscription et contrôle du registre à 15 h 30.** W11 a été repris une seule fois puis remis immédiatement en état enregistré après constat d'une mémoire libre inférieure à la marge de 1,5 Gio. Aucun essai de connexion ni test métier n'a été exécuté.

## Objectif retenu après le lot autonome

Le [lot autonome de clôture](controle-final-autonome-2026-11-07.md) a vérifié les preuves et la topologie, ajouté quatre pièces et harmonisé les documents. Les échanges suivants ont précisé la suite :

- `local-admin` n'est pas un prérequis général aux essais métier. Les accès Clients, Finance et Direction se testent sous les comptes métier correspondants. Les collectes système protégées demandent séparément les droits adaptés.
- L'hôte peut centraliser le pilotage. Une commande lancée localement sur l'hôte ne reproduit pas le contexte W11, même avec des identifiants réseau différents.
- PowerShell Direct permet d'exécuter des commandes dans une VM Windows locale sans ajouter de chemin réseau ; la VM doit fonctionner et les identifiants être acceptés. L'accès Direct de `usr.com01` reste à vérifier. [Référence Microsoft](https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v/powershell-direct)
- Les scénarios Finance et Direction nécessitent leurs propres identités ; les mesures AUDIT/Nmap doivent partir de Kali. Une session `usr.com01` ne couvre pas tout le mandat.
- Une connexion WinRM peut rencontrer un problème de second saut lors d'un accès ultérieur au partage du DC. Ce problème de transmission d'identifiants ne doit pas être assimilé à un refus démontrant les ACL. Aucun de ces accès n'a été essayé ici. [Référence Microsoft](https://learn.microsoft.com/en-us/powershell/scripting/learn/remoting/ps-remoting-second-hop)

Le projet a donc été poursuivi vers un essai unique PowerShell Direct sous `usr.com01`, précédé des vérifications de ressources. Aucune ouverture réseau, délégation supplémentaire ou élévation du compte métier n'a été mise en place.

## Vérifications préalables et tentative réelle

| Moment UTC | Action ou lecture | Résultat et limite |
| --- | --- | --- |
| 14:17:35 | Lecture hôte et Hyper-V après discussion des prochaines étapes. | 2,612 Gio libres ; DC Running, W11/pfSense/Kali Saved. |
| 14:25:40 | Nouveau relevé avant la tentative. | 2,694 Gio libres ; mêmes états. Mémoire W11 dynamique : démarrage et minimum à 1 Gio, maximum à 4 Gio. |
| Préparation, heure exacte non archivée | Lecture des métadonnées hôte et des fichiers d'état W11. | Compte hôte membre d'Administrateurs Hyper-V ; processus non élevé. Fichier VMRS d'environ 0,973 Gio. Cette taille et la mémoire de démarrage ne prédisent pas la mémoire affectée après reprise. |
| Préparation, heure exacte non archivée | Vérification du fichier local d'identifiants initiaux et de ses noms de colonnes. | Aucun secret affiché, transmis dans une commande de connexion ou utilisé pour une authentification. Aucun fichier d'identifiants modifié. |
| Avant reprise, bilan enregistré à 14:27:08 | Contrôle de la mémoire et des états, création du dossier de suivi restreint. | 2,703 Gio libres, W11 Saved ; seuil préparatoire calculé à partir du démarrage/fichier d'état et d'une marge de 1,6 Gio. Ce critère préparatoire s'est révélé insuffisant pour garantir la marge après reprise. |
| Entre la préparation et 14:27:07 | `Start-VM CC-W11-01` exécuté une fois. | Reprise réussie ; aucune autre VM démarrée. L'heure précise de la commande n'est pas archivée séparément. |
| 14:27:07.1924308 | Premier contrôle après reprise. | W11 Running, 2,080 Gio affectés ; seulement **1,251 Gio libres** sur l'hôte. La marge de 1,5 Gio est franchie. |
| Après ce contrôle, avant 14:27:08.6926345 | `Save-VM CC-W11-01` exécuté immédiatement. | Retour Saved réussi, aucune erreur rapportée, 3,312 Gio libres au bilan. Aucun arrêt forcé ni suppression de l'état enregistré. |
| 14:27:57 | Dernière lecture ponctuelle communiquée. | W11 toujours Saved ; 3,317 Gio libres, fichier VMRS d'environ 0,974 Gio. Cette lecture a été transcrite depuis la sortie de l'outil ; elle n'est pas un second export inscrit. |

Le JSON natif de tentative conserve le relevé avant reprise, la première observation, le retour Saved et `authentication_attempted=false`. Il ne contient pas les autres sorties préalables : leur transcription ci-dessus est distinguée de la pièce native.

## Ce qui demeure non démontré

Aucun `Enter-PSSession`, `New-PSSession`, `Invoke-Command` ou essai de mot de passe n'a été lancé sur W11 pendant cette reprise. La validité du mot de passe de `usr.com01` et son droit d'accès PowerShell Direct ne sont donc pas établis. Le verrouillage de `local-admin` n'a pas été relu.

Aucun nouveau gpresult, diagnostic natif de licence W11, accès SMB, événement Sysmon, scan ou test de restauration n'a été réalisé. Aucun compte, mot de passe, GPO, droit de connexion, paramètre mémoire des VM, réseau ou licence n'a été modifié. Le DC est resté actif ; pfSense et Kali sont restés Saved. Le rapport Google et le site hébergé n'ont pas été modifiés.

La recette reste à **2 tests validés, T10 à actualiser et 12 à faire**. L'essai interrompu ne valide pas T05 et ne constitue pas une mesure du profil métier sur dix minutes.

## Preuve et registre

- Source : `transfert/psdirect-metier-20261107T142703494Z/reprise-w11.json`, 1 604 octets.
- Identifiant actif : `M-CLIENT-01_poste_20261107T143053385Z_MONNOKOELOBA_HyperV`.
- SHA-256 source/copie : `27A0A32F77789165DB4A2046358B78F5BF4C54028668F81098CC77616AADCF70`.
- Heure d'événement inscrite : `2026-11-07T14:27:08.6926345Z`, celle du bilan natif, et non une heure déduite pour Start-VM ou Save-VM.
- Avant ajout : 42 lignes, registre sauvegardé sans écrasement sous `registre-avant-suivi-w11-20261107T143053297Z.csv` ; SHA-256 `1E9FF0874C634BAFEDE58C4F030E7E7752C813650320075FE798CA15AE4FC3F9`.
- Après ajout, contrôle à `14:30:53 UTC` : **43 lignes**, identifiants/chemins/empreintes uniques ; 43 fichiers principaux présents, tailles et SHA-256 conformes. Empreinte du registre : `1C7A597A7F034CCF5C8CFBD3B4AEBB70F1B721772B2AEC767CA9D29E608DDCA4`.

La pièce brute et le registre restent dans le coffre hors Git et OneDrive. Les 90 annexes avaient été vérifiées pendant le lot précédent ; elles ne sont pas présentées comme recalculées une nouvelle fois lors de cette inscription.

## Point de reprise concret

1. Sauvegarder le travail et libérer de la mémoire sur l'hôte ; viser **4 Gio libres** avant une nouvelle reprise. C'est un objectif de préparation, pas une garantie : la mémoire devra être contrôlée immédiatement après.
2. Reprendre uniquement W11, laisser le DC actif et pfSense/Kali Saved. Si la mémoire libre passe sous 1,5 Gio, remettre W11 en état enregistré.
3. Si la marge tient, tenter une seule connexion Direct sous `CYBERCORP\usr.com01` avec des identifiants actuels. Ne pas multiplier les essais en cas de refus et ne pas afficher les secrets.
4. Vérifier dans la session la machine et l'identité, puis commencer par les lectures et essais Clients. Si Direct est refusé, utiliser la console Hyper-V de base avec la session métier, sans modifier les GPO pour contourner le refus.
5. Étendre ensuite aux comptes Finance/Direction ; traiter les collectes administratives et la licence séparément. Enregistrer les résultats réellement obtenus avant de faire évoluer la recette.

La documentation et la recette sont préparées pour un commit local à la demande de l'utilisateur. `tmp/`, les secrets et les preuves brutes ne font pas partie du contenu à versionner ; aucun push n'est demandé.
