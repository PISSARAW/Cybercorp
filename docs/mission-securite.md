# CyberCorp — mission métier du laboratoire

## Situation de l'entreprise fictive

CyberCorp est une société de conseil numérique fictive de 25 personnes. Ses équipes commerciales, techniques, financières et RH travaillent sur des dossiers différents ; deux personnes assurent l'informatique. Les partages `Clients`, `Technique`, `Finance` et `RH` représentent des informations dont l'accès doit rester justifié par le métier. Les noms, comptes et fichiers du laboratoire sont fictifs.

Une PME de ce type doit avancer sur ses missions client tout en répondant à trois demandes pénibles et récurrentes : ouvrir rapidement un accès exceptionnel, vérifier qu'une modification de sécurité n'a pas créé un accès durable non voulu, et expliquer un événement suspect après coup. L'équipe IT ne dispose pas d'un SOC permanent. Ce problème de ressources et de preuves est crédible pour les PME : [l'ENISA décrit leurs difficultés de personnel, de tests et de préparation aux incidents](https://www.enisa.europa.eu/news/whats-driving-cybersecurity-investments-and-where-lie-the-challenges) ; [la CNIL souligne l'utilité des journaux pour comprendre les accès et les incidents](https://www.cnil.fr/fr/securite-tracer-les-operations). Ces sources motivent le scénario ; elles ne prouvent aucun fait sur CyberCorp, qui reste fictive.

## Mandat pilote : une mission client sous pression

Le cas fictif `M-CLIENT-01` commence la veille de la remise d'un dossier technique stocké dans `Clients`. L'interlocuteur du client demande une réponse vérifiable à trois questions : qui peut modifier ce dossier, l'audit réseau exceptionnel est-il bien refermé, et une action inhabituelle sur le poste de préparation a-t-elle touché le livrable ? L'équipe IT de deux personnes doit répondre sans immobiliser durablement les projets. Pour vérifier les services AD nécessaires au laboratoire, elle autorise une courte campagne depuis `CC-KALI01` vers les seuls ports désignés de `CC-DC01`. Une modification bénigne mais inhabituelle d'horodatage est simulée sur `CC-W11-01` afin de tester la capacité d'explication. La direction doit décider si elle peut poursuivre la remise, corriger un écart ou suspendre l'exercice. Aucun client réel, contrat ou incident de production n'est invoqué.

Ce mandat réunit trois problèmes métier, sans prétendre qu'un vrai client, un incident réel ou une obligation contractuelle existent :

| Problème irritant | Ce qui manque dans une PME peu outillée | Décision attendue |
| --- | --- | --- |
| **Une exception urgente survit au projet.** Une règle temporaire et une carte réseau ajoutée pour dépanner peuvent rester en place après la séance. | Une comparaison répétable entre la topologie autorisée, l'exposition pendant l'exception et l'état final. | Autoriser l'audit seulement si les préconditions passent ; retirer la règle ; prouver le retour à l'état bloqué. |
| **Une politique affichée comme appliquée est mal gouvernée.** Une GPO peut produire l'effet attendu sur un poste tandis que son lien, son propriétaire ou ses droits de modification présentent un écart. | Une revue du plan de contrôle AD/SYSVOL, en plus de la preuve d'application sur le poste. | Corriger, accepter explicitement ou bloquer le changement selon l'écart observé. |
| **Un signal sur le poste ne raconte pas toute l'histoire.** Le responsable sait qu'une opération a eu lieu, mais peine à relier processus, connexion, fichier, identité et heure. | Une collecte ciblée puis une chronologie lisible, produites sans serveur de supervision permanent. | Qualifier « action attendue », « anomalie à investiguer » ou « traces insuffisantes » ; ne jamais conclure à l'absence de fuite. |

Le résultat métier est un **dossier de décision** compréhensible par la direction et par un client fictif : demande et périmètre, état initial, autorisation, changement, mesures, événement observé, qualification, fermeture, contre-tests, limites et responsable de la décision. Les exports bruts restent restreints ; le dossier de présentation contient des extraits expurgés.

Le problème peu traité n'est pas « détecter davantage » en soi, mais la **dette de preuve des exceptions** : une demande orale, une règle temporaire, une GPO, un journal et un résultat de scan vivent dans des endroits différents, si bien que personne ne peut répondre rapidement à « que s'est-il réellement passé et qu'est-ce qui reste ouvert ? ». Un outil de ticketing peut tracer la demande, un outil de supervision afficher des alertes et un scanner mesurer des ports ; aucun de ces résultats isolés ne relie l'autorisation, l'effet réel, le signal sur le poste et la décision métier. CyberCorp construit donc une chaîne courte, vérifiable et proportionnée à deux administrateurs, pas un produit qui prétend résoudre tous les incidents.

Trois réponses sont possibles : **poursuivre** si les droits effectifs sur le dossier sont conformes, l'exception est fermée et le signal est expliqué, avec une comparaison d'empreinte du livrable ; **corriger puis contre-tester** si un écart limité est compris ; **suspendre** si l'accès reste ouvert, si la preuve de fermeture manque ou si les traces ne permettent pas de statuer sur le livrable. La comparaison d'empreinte montre seulement si le fichier testé a changé entre deux mesures : elle ne prouve pas l'absence de lecture ou de copie. Cette règle de décision donne un enjeu aux outils : produire une conclusion défendable, pas seulement cinq démonstrations techniques.

## Pourquoi ce choix de cinq outils

Les outils ne sont pas universellement irremplaçables. Ils répondent chacun à une question que les quatre autres ne couvrent pas dans cette architecture et avec 16 Go de RAM.

| Outil | Incertitude qu'il lève | Pourquoi le contrôle habituel ne suffit pas ici | Limite à déclarer |
| --- | --- | --- | --- |
| **Conftest / OPA** | La topologie observée respecte-t-elle les règles de confinement écrites par CyberCorp ? | Une capture Hyper-V se périme ; un script PowerShell ad hoc peut vérifier une fois, mais ne sépare pas aussi nettement la politique versionnée de l'export de l'hôte. | Vérifie un export et des règles : il ne démontre pas à lui seul le comportement du réseau. |
| **GPOZaurr** | Les GPO sont-elles liées, possédées et modifiables comme prévu, avec cohérence AD/SYSVOL ? | `gpresult` montre l'application sur un poste précis ; il ne constitue pas une revue des liens, propriétaires et délégations. Un audit AD général élargirait le périmètre. | Le rapport doit être interprété ; il ne prouve ni l'accès effectif aux fichiers ni l'absence d'abus. |
| **Nmap + Ndiff** | Quelle exposition réelle a changé pendant l'exception, puis après sa fermeture ? | Les règles pfSense expriment l'intention ; un scan borné mesure le résultat. Ndiff compare les sorties XML avec les mêmes cible et ports. Un scanner de vulnérabilités chercherait une autre réponse. | Des ports filtrés ne prouvent ni l'absence d'autre chemin ni la sûreté des services. |
| **Sysmon** | Quels processus, connexions et changements de fichier ont eu lieu sur le poste de test ? | Le pare-feu et Defender ne donnent pas seuls le contexte détaillé du scénario endpoint. | La configuration restreinte actuelle ne trace qu'une partie des activités ; ce n'est ni un EDR ni une preuve d'absence de fuite. |
| **Hayabusa** | Comment relier les EVTX à une chronologie et à une règle de détection sans SOC ? | Une lecture manuelle de plusieurs journaux perd du temps et rend la corrélation fragile. Un SIEM permanent dépasse la capacité du laboratoire. | Analyse hors ligne : pas d'alerte en temps réel ; une règle déclenchée exige une qualification humaine. |

Les contrôles natifs restent indispensables : ACL et tests SMB pour la confidentialité des dossiers, `gpresult` pour l'effet des GPO, journaux pfSense pour les refus, sauvegarde et restauration pour la reprise. Les cinq outils approfondissent le problème des changements et des preuves ; ils ne remplacent pas ces contrôles.

## Déroulé opérationnel de M-CLIENT-01

1. **Demande** — consigner qui demande l'audit, pourquoi, la cible `10.77.10.10`, les quatre ports autorisés, l'heure de début et de fin et la personne qui décide. Une demande incomplète suspend l'ouverture.
2. **Préconditions** — exporter la topologie Hyper-V, exécuter les règles Conftest et revoir les GPO avec GPOZaurr. Un écart de confinement bloque le scénario ; un écart GPO reçoit une décision documentée avant toute suite.
3. **État initial** — mesurer depuis Kali les seuls ports autorisés. Garder le XML Nmap et les journaux pfSense, sans cibler l'hôte ni le réseau personnel.
4. **Exception** — ouvrir les règles pfSense temporaires déjà définies pour S01 ; refaire exactement la mesure et comparer les deux XML avec Ndiff.
5. **Fermeture** — retirer les règles, refaire la même mesure et contrôler l'inventaire. Comparer au XML autorisé et à la mesure initiale disponible. Si l'état initial ne revient pas, la mission est suspendue.
6. **Signal endpoint** — dans un profil mémoire séparé, produire une action bénigne autorisée sur `CC-W11-01`, comparer l'empreinte du fichier de livrable fictif avant/après, exporter Security et Sysmon, conserver les empreintes, puis analyser avec Hayabusa. Chercher l'événement source et expliquer toute alerte ou absence de trace.
7. **Décision** — remettre une fiche « poursuivre / corriger / suspendre » avec preuves avant/après, effet métier, limites de visibilité et responsable. Un test de restauration T14–T15 complète la capacité de reprise, sans être déduit des cinq outils.

Les résultats Nmap/Ndiff, GPOZaurr et Sysmon/Hayabusa déjà consignés dans le [journal de déploiement](journal-deploiement.md) sont des matériaux de ce dossier. Ils ont été obtenus lors de séances différentes. L'export XML initial de S01 a été écrasé par erreur ; seuls les XML de l'autorisation temporaire et du blocage restauré sont conservés. C'est un écart de traçabilité à présenter tel quel. Conftest et plusieurs recettes restent à faire.

## Critères de succès mesurables

| Critère | Méthode de mesure | État initial |
| --- | --- | --- |
| Une exception ouverte possède propriétaire, motif, cible, ports et échéance. | Fiche de changement et règle pfSense correspondante. | À constituer pour `M-CLIENT-01`. |
| Le retour à l'état bloqué est démontré. | XML « autorisé » et « rebloqué », Ndiff et contrôle de la règle retirée ; une nouvelle campagne devra conserver aussi le XML initial. | S01 démontre le retour au blocage ; le premier XML a été écrasé. |
| La topologie interdite est rejetée automatiquement. | PASS sur export réel et FAIL sur copie contenant une carte Kali reliée au mauvais switch. | Conftest à réaliser. |
| Une anomalie GPO est qualifiée avec son effet métier. | Rapport GPOZaurr, `gpresult`, décision et éventuel contre-test. | T10 documente surtout l'absence de GPO cassée/orpheline ; les propriétaires et permissions demandent une revue distincte. |
| Un signal endpoint est traçable jusqu'à sa source. | EVTX, SHA-256, événement source, chronologie Hayabusa et conclusion humaine. | Essai Sysmon/Hayabusa présent ; recette T12–T13 à compléter. |
| Le temps nécessaire pour assembler le dossier est connu. | Chronométrer la préparation et la revue lors de la répétition ; noter les étapes manuelles. | Non mesuré ; aucun délai contractuel annoncé. |

Le laboratoire ne démontre ni une conformité réglementaire, ni une surveillance continue, ni l'absence d'exfiltration. Cette limite fait partie de la décision remise au responsable : une preuve manquante conduit à « indéterminé » ou à une suspension, jamais à un succès supposé.
