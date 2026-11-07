# Préparation de l'activation de CC-DC01 — 7 novembre 2026

**Maintenance exécutée et clôturée :** [CC-DC01 activé jusqu'au 6 mai 2027, retour au confinement vérifié](activation-dc01-2026-11-07.md). Le présent document conserve le périmètre autorisé, les préconditions et la préparation.

À la préparation, le réarmement avait rétabli dix jours de grâce jusqu'au 17 novembre ; la surveillance de plus d'une heure devait précéder toute maintenance. L'utilisateur a explicitement autorisé le périmètre, puis validé l'élévation UAC. Aucune ouverture WAN ou création de NAT n'a été effectuée pendant la seule phase de préparation. La fenêtre effective ultérieure a duré 15 minutes 38 secondes, puis les paramètres initiaux ont été restaurés.

## Préconditions relevées à 09:21 Europe/Paris

Le DC seul est actif. pfSense et Kali sont enregistrés ; W11 est arrêté. L'hôte dispose de 3,040 Gio libres. La reprise de pfSense, configuré à 1 Gio, laisserait environ 2,040 Gio avant variations de charge ; une nouvelle mesure est obligatoire avant sa reprise et immédiatement après. La marge minimale demeure 1,5 Gio. Aucun réglage RAM n'est proposé.

Le WAN pfSense, MAC `00155D013C0E`, reste sans commutateur et déconnecté. Ses autres cartes sont sur CC-LAN et CC-AUDIT. Kali possède une seule carte sur CC-AUDIT. CC-WAN-MAINT est interne, avec l'interface hôte `172.31.250.1/24`, sans objet WinNAT existant. La route par défaut de l'hôte utilise le Wi-Fi. Les préfixes IPv4 observés ne révèlent pas de chevauchement avec les trois réseaux du laboratoire ; les routes devront être relues avant ouverture.

Le relevé détaillé, contenant les adresses opérationnelles de l'hôte, reste hors dépôt : `transfert/preconditions-maintenance-dc01-20261107T082144070Z.json`, SHA-256 `EA1CC723AAE4EE7EEBA3EAE37D0D64230EF0DDA95ACD13C33DBF2C2C83A6D3BC`.

## Périmètre autorisé

L'utilisateur a répondu « J'autorise oui » à la proposition d'une fenêtre maximale de **20 minutes de WAN connecté**, après qualification de la surveillance du DC. L'autorisation est consignée hors dépôt dans `transfert/autorisation-maintenance-activation-20261107.json`. Elle comprend les opérations suivantes, dans l'ordre :

1. Recontrôler les ressources et la topologie. Garder W11 arrêté et Kali hors exécution ; déconnecter temporairement la carte Kali en conservant son état enregistré.
2. Reprendre seulement pfSense, WAN toujours déconnecté. Lire les règles, les alias, le NAT, les routes et le DNS effectifs ; conserver la configuration avant intervention. L'accès administrateur pfSense reste à établir : aucune installation de service ou activation de SSH n'est incluse dans cette proposition.
3. Préparer le filtrage de maintenance avant toute connexion WAN. Limiter les sorties au seul DC, au DNS nécessaire et aux destinations Microsoft nécessaires à l'activation et à la validation des certificats ; protéger l'hôte et les réseaux non publics. Si ces protections ne peuvent pas être vérifiées, ne pas ouvrir le WAN.
4. Si les indications de racine ne permettent pas la résolution dans ce filtrage borné, ajouter temporairement un redirecteur du serveur DNS du DC vers `1.1.1.1`, UDP/TCP 53, après sauvegarde de ses paramètres. Le DNS client du DC reste `127.0.0.1` / `::1`. Les paramètres antérieurs seront restaurés en fin de fenêtre.
5. Connecter le seul WAN pfSense à CC-WAN-MAINT et créer temporairement un WinNAT dédié au préfixe `172.31.250.0/24`. Aucun raccordement au Default Switch ou à un commutateur externe. Vérifier la résolution et la connectivité nécessaires, sans scan ni autre cible.
6. Exécuter `/ato` une fois dans le DC ; conserver la sortie et le code de retour. Relire `/dlv`, `/xpr`, LicenseStatus et la période restante. Ne pas présumer du succès ni d'une durée de 180 jours.
7. À la fin ou en cas d'échec, déconnecter le WAN, retirer le seul NAT créé pour cette opération, restaurer les paramètres DNS/règles temporaires et l'état initial de la carte Kali. Replacer pfSense dans son état enregistré si sa reprise a été réalisée pour cette seule maintenance. Vérifier et exporter le retour au confinement.

La fenêtre ne comprend aucun nouvel audit, modification des GPO, changement d'horloge, nouvelle clé produit, conversion d'édition ou réarmement supplémentaire. Une erreur d'activation donne lieu à un diagnostic de sa sortie, sans élargissement automatique des accès.

## Destinations et limites du filtrage

Le DC annonce dans `/dlv` les services `activation-v2.sls.microsoft.com` et `validation-v2.sls.microsoft.com`. Microsoft publie également des noms liés à l'activation, à la licence et aux certificats dans sa [documentation de dépannage](https://learn.microsoft.com/en-us/troubleshoot/windows-server/networking/windows-activation-validation-fails). Cette liste décrit notamment un cas de proxy ; elle ne constitue pas une preuve que chaque destination est nécessaire à cette édition d'évaluation.

Les destinations effectivement nécessaires seront définies à partir de ces noms, des réponses DNS et des journaux, avant ou pendant la fenêtre bornée, sans autorisation générale de sortie. Les services HTTPS utilisent TCP 443 ; les éventuels accès HTTP de redirection ou de révocation utilisent TCP 80. Les adresses peuvent changer : ne pas figer une adresse IP devinée ou issue d'une ancienne capture. Un alias de pare-feu fondé sur les adresses résolues d'un nom ne filtre pas à lui seul le chemin d'une URL et peut correspondre à un hébergement partagé ; cette limite doit être prise en compte lors de la revue des règles.

## Écarts du dépôt et du coffre, suite des lectures

L'écart de HEAD est expliqué : `2bf60ab` est un ancêtre du commit documentaire `66b6c8a`. Trois commits locaux préexistaient entre les deux : `e476524` (Conftest), `ba3c9c1` (documentation), `a62864f` (logo). Ils sont préservés. La comparaison porte sur la référence locale origin/main ; aucun fetch, push ou changement de branche n'a été effectué.

Les sources du HTML C06 et du dernier export C12 ont été retrouvées, avec les mêmes SHA-256 que le bilan antérieur. Deux copies **collectées maintenant** ont été conservées hors OneDrive, sans recréer leurs anciens identifiants ni heures de collecte :

| Pièce | Copie dans le coffre, sous `brut` | SHA-256 |
| --- | --- | --- |
| C06 historique | `M-CLIENT-01_recuperation_20261107T082102198Z_C06-gpresult-machine.html` | `C550EDAFF75B1F5EB8A7218BF6F0CF2077C57AEA0F0ACF6ABE5C019D4131A9F1` |
| Dernier C12 | `M-CLIENT-01_recuperation_20261107T082102198Z_C12-20261106T210309003Z.json` | `94BB58931B14C8C36B24D894E9F4FC4E6A14B0DAFF22A95CA08EB0E2DA24C02F` |

Manifeste : `transfert/controle-recuperation-c06-c12-20261107T082102198Z.json`. Le registre actif de 12 lignes et le consolidé de 19 lignes restent inchangés. Ces copies ne démontrent pas la récupération de la version à 27 lignes. Aucun nouveau gpresult, Conftest ou test métier n'a été exécuté pendant ces lectures.

À 09:33 Europe/Paris, les deux sources PNG WAN ont également été retrouvées dans le dossier Screenshots, avec les empreintes historiques attendues. Des copies actuelles ont été conservées sous `brut/M-CLIENT-01_recuperation_20261107T083344829Z_WAN-interfaces.png` (5 544 octets, SHA-256 `6909250057EEE736D948B9CB96E7C975BAE10D6C7AA75913128B65B060C3F534`) et `brut/M-CLIENT-01_recuperation_20261107T083344829Z_WAN-hn0.png` (30 099 octets, SHA-256 `41A192926610E7E2A9383AB77FDEBA85B8EA57F82D4611CB698053BE81BD98A3`). Le manifeste `transfert/controle-recuperation-wan-20261107T083344829Z.json` laisse l'heure d'événement vide. Les originaux n'ont pas été supprimés et les anciens identifiants n'ont pas été recréés. Les quatre anciennes pièces autonomes et la version historique du registre à 27 lignes restent à retrouver.

## Préparation technique après autorisation

Deux auxiliaires sont préparés hors dépôt, sans opération réseau exécutée lors de leur chargement ou de leur vérification syntaxique :

- `transfert/pfsense-maintenance-client-20261107.ps1` prépare une connexion HTTPS administrative depuis le DC vers le seul LAN `10.77.10.1`, avec authentification et jetons CSRF. Le certificat auto-signé est relevé sur ce LAN privé puis épinglé pour les requêtes suivantes. Les configurations complètes téléchargées sont chiffrées avec DPAPI CurrentUser sur l'hôte avant écriture ; aucun mot de passe, cookie ou XML complet n'est affiché. Cette voie s'appuie sur l'interface HTTPS existante et n'active pas SSH.
- `transfert/nat-maintenance-activation-20261107.ps1` est un auxiliaire Windows à exécuter avec élévation pour le NAT. Il refuse une surveillance non validée, une autorisation absente, un filtrage non vérifié, un WAN déjà connecté, un NAT préexistant ou un bail supérieur à 20 minutes. Il ne crée que `CC-MAINT-ACTIVATION-20261107` sur `172.31.250.0/24`. À clôture ou expiration, il déconnecte le WAN de maintenance et retire son propre NAT. Il ne modifie ni DNS invité ni licence. Les droits réels de création du NAT devront être vérifiés au lancement ; aucun contournement d'UAC n'est prévu.

La vérification préparatoire a validé la syntaxe PowerShell et la compilation du client HTTPS, sans exécuter les connexions ou les modifications. Le filtrage effectif de pfSense reste à lire après sa reprise et à vérifier avant toute ouverture WAN.
