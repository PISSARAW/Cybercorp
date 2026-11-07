# Avancement autonome — 7 novembre 2026

Les opérations de cette séance se limitent aux fichiers existants, aux lectures Hyper-V et aux contrôles statiques Conftest. Aucun démarrage de VM, modification réseau ou scan n'a été réalisé.

## Résultats

- À `07:31:00 UTC`, mémoire libre de l'hôte : 0,37 Gio. Le relevé archivé suivant affiche 0,633 Gio. DC et W11 sont arrêtés ; Kali et pfSense sont actifs. Le démarrage du profil métier reste incompatible avec la marge de 1,5 Gio prévue pour l'hôte.
- Un relevé natif Hyper-V conserve maintenant les MAC : WAN pfSense `00155D013C0E`, sans commutateur et déconnecté ; LAN `00155D013C0F` ; AUDIT `00155D013C10`. La MAC WAN correspond à celle de la capture pfSense du 6 novembre. Les deux observations ne sont pas simultanées.
- Conftest a testé le dernier export C12, dont l'empreinte est `94BB58931B14C8C36B24D894E9F4FC4E6A14B0DAFF22A95CA08EB0E2DA24C02F` : **PASS réel et cinq FAIL attendus**, 18 règles par cas. C'est une analyse du 7 novembre sur la collecte du 6 novembre à 21:03:11 UTC.
- Un nouvel export Hyper-V a également produit **PASS réel et cinq FAIL attendus**. Ces résultats établissent la conformité statique des rattachements ; ils ne démontrent pas les règles pfSense ni le comportement des flux.
- Le HTML `preuves/M-CLIENT-01/C06-gpresult-machine.html` a été retrouvé, lu et archivé. Il concerne `CYBERCORP\CC-W11-01`, OU `CyberCorp/Postes`, et affiche « Données recueillies le 06/11/2026 17:18:10 ». Le fuseau de cette heure n'est pas établi : `evenement_utc` reste vide. C06 n'est donc plus une pièce absente, mais aucun nouveau `gpresult` du 7 novembre n'a été exécuté.

## Lecture du rapport C06 retrouvé

Le rapport montre `CC-Domaine-Comptes`, `CC-Postes-Securite` et `Default Domain Policy` dans les objets GPO appliqués. Pour les deux GPO CyberCorp, les révisions AD/SYSVOL correspondent respectivement à 80/80 et 33/33.

Paramètres affichés :

- minimum 14 caractères, historique 24, verrouillage 5 tentatives et 15 minutes ;
- refus de session locale et Terminal Server aux administrateurs du domaine ;
- limite d'inactivité de 600 secondes ;
- pare-feu activé pour Domaine, Privé et Public ; connexions entrantes et sortantes non configurées explicitement dans les rubriques affichées ;
- « Désactiver l'antivirus Microsoft Defender » et « Désactiver la protection en temps réel » : Désactivé ;
- « Activer les ouvertures de session invité non sécurisées » : Désactivé.

Le rapport démontre les paramètres de stratégie relevés à sa date. Il ne prouve pas à lui seul la santé du moteur Defender, l'absence du composant SMBv1, l'application actuelle après un nouveau démarrage ou la résolution des écarts de propriétaires GPOZaurr.

## Pièces enregistrées

Toutes figurent sous `brut` dans le coffre hors Git, avec une ligne au registre.

| Pièce | Identifiant | SHA-256 |
| --- | --- | --- |
| État hôte, RAM, VM et MAC | `M-CLIENT-01_topologie_20261107T073221287Z_MONNOKOELOBA_HyperV` | `AB8FE6A99BCAB7D8806A2EA826F93A6D06D477D2B6E5B5AA0B1CEB85AC5715AB` |
| Export Hyper-V actuel | `M-CLIENT-01_topologie_20261107T073221378Z_MONNOKOELOBA_HyperV` | `3F0B3FD47932A6AC3A670BDF8C98A0899EEC450CE1E329BB599FA1C9C93F72F0` |
| Conftest sur l'export actuel | `M-CLIENT-01_topologie_20261107T073221505Z_MONNOKOELOBA_Conftest` | `7A6E31643B2389AF551E45412DE073BD8E93D7A21ED6372B06A9E1F59B274048` |
| Conftest sur le dernier C12 | `M-CLIENT-01_topologie_20261107T073221539Z_MONNOKOELOBA_Conftest` | `234A0959B28DE28D675C83A53EDD489FE88578E7A4AF032302452629B100CA9E` |
| HTML C06 retrouvé | `M-CLIENT-01_gpo_20261107T073302598Z_CC-W11-01_gpresult` | `C550EDAFF75B1F5EB8A7218BF6F0CF2077C57AEA0F0ACF6ABE5C019D4131A9F1` |

Le registre actif comporte **27 lignes**. Les 27 fichiers ont été contrôlés par taille et empreinte. SHA-256 du registre à la fin de la séance : `63DB87C1CA1B0F3B36CF2E37B5943A3BD60C1E4C69FEBF7F5189BC7765FA42C8`.

## Dépendances restantes

- Libérer la RAM avant tout démarrage du DC/client ; résoudre l'activation du DC avec un accès invité autorisé et une procédure adaptée à sa licence.
- Rapatrier les fichiers Nmap depuis Kali : aucune copie correspondante n'a été retrouvée dans le coffre hôte. L'accès à Kali n'est pas établi dans cette session ; aucune carte ni service n'a été activé pour le transfert.
- Compléter les exports natifs GPO, les scénarios Finance/Direction et la qualification des propriétaires/permissions GPOZaurr.
- Obtenir la nouvelle fenêtre approuvée avant le scénario réseau ; préparer les événements Sysmon/Hayabusa, une sauvegarde indépendante et la décision de remise.

Le script `scripts/collect-controle-hote.ps1` ajouté pendant cette séance effectue uniquement des lectures et refuse d'écraser son fichier de sortie. La collecte a réussi sous Windows PowerShell 5.1. Les contrôles Conftest ont utilisé le vérificateur local préexistant ; sa revue de code et l'installateur local restent distincts de la validation des résultats produits.
