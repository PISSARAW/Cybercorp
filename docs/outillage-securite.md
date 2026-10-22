# Outillage de sécurité — réponses au mandat M-CLIENT-01

## Objet et état

Ce document organise les cinq outils autour du [mandat métier M-CLIENT-01](mission-securite.md). Sysmon et Hayabusa ont été démontrés sur un essai de télémétrie du 20 octobre 2026 ; GPOZaurr a été exécuté en lecture seule pour T10 le même jour ; Nmap/Ndiff a été démontré par S01. Les preuves et empreintes sont consignées dans `docs/journal-deploiement.md`. Conftest/OPA reste à réaliser. Ces essais distincts ne constituent pas encore le dossier de décision complet.

Le choix est volontairement limité. Il complète le socle existant (Hyper-V, pfSense, Active Directory, GPO, pare-feu Windows, Defender et Kali) sans ajouter de VM, de SIEM ou d'IDS permanent. Les analyses sont réalisées sur l'hôte ou hors ligne afin de respecter la contrainte de 16 Go et les profils mémoire du laboratoire.

| Catégorie | Outil retenu | Objectif dans CyberCorp | Recette concernée | Livrable attendu | État |
| --- | --- | --- | --- | --- | --- |
| Connu | Nmap + Ndiff | Mesurer l'exposition strictement autorisée depuis Kali et comparer l'état avant/après une règle pfSense. | Scénario S01 ; préconditions T03–T04 | Sorties Nmap XML et diff Ndiff, avec cible, ports et fenêtre de tir identifiés. | Démontré le 20 octobre 2026 ; artefacts bruts conservés hors Git |
| Connu | Sysmon | Produire une télémétrie endpoint Windows exploitable. | T12–T13 ; scénario S03 | Export EVTX du journal Sysmon, configuration appliquée et test horodaté. | Déployé et démontré sur `CC-W11-01` |
| Peu courant | Hayabusa | Construire une chronologie et rechercher les détections Sigma dans les EVTX. | T12–T13 ; scénarios S03–S04 | Chronologie CSV/JSON et extrait explicatif lié à un scénario. | Démontré hors ligne sur l'EVTX Sysmon |
| Peu courant | GPOZaurr | Auditer les liens, propriétaires, permissions et cohérence des GPO. | T10 et M03 | Rapport HTML/CSV expurgé et liste des écarts réellement observés. | Exécuté en lecture seule sur `CC-DC01` le 20 octobre 2026 |
| Niche à fort potentiel | Conftest / OPA | Vérifier des invariants de sécurité sous forme de politiques versionnées. | Préconditions T01–T04 et M02 ; bonus G01–G04 | Rapport PASS/FAIL reproductible sur un export JSON expurgé. | Prévu |

Sysmon, Hayabusa, GPOZaurr et Nmap/Ndiff sont démontrés ; Conftest/OPA reste au statut **prévu**. Les outils envisagés hors de ce pack (PingCastle, Zeek/Zui, KAPE, Kopia et HardeningKitty) restent hors périmètre tant que ce pack n'est pas entièrement démontré.

## Correspondance avec la recette existante

La recette T01–T15 évalue les contrôles du laboratoire. Le mandat M-CLIENT-01 utilise leurs résultats pour répondre à une demande métier. Un rapport d'outil seul ne suffit pas à valider un test.

- **T01 à T04 — confinement et topologie** : Conftest vérifie l'export expurgé de topologie ; Nmap reste limité au scénario autorisé et Ndiff compare deux mesures équivalentes.
- **T10 — GPO et pare-feu Windows** : GPOZaurr complète `gpresult` et l'export natif, sans les remplacer.
- **T12 à T13 — détection, export et intégrité des traces** : Sysmon produit des événements supplémentaires ; Hayabusa les analyse dans les EVTX exportés et hachés.
- **T05 à T09, T11 et T14 à T15** : les commandes et preuves natives prévues dans le dossier restent la référence. Aucun outil du pack ne dispense d'une recette métier, d'un test de restauration ou d'une mesure RTO/RPO.
- **G01 à G04 — bonus GenOS** : Conftest fournit le vérificateur déterministe indépendant ; il n'accorde aucun droit d'écriture à GenOS ni à un agent externe.

## Règles communes

1. Exécuter les tests uniquement sur les IP, VM et comptes de scénario du laboratoire. Le réseau personnel, l'hôte, le MacBook, Tailscale et Internet ne sont jamais des cibles.
2. Avant une action depuis Kali, vérifier que son unique carte est sur `CC-AUDIT`, que la carte WAN de `CC-PFS01` est déconnectée et que la console Hyper-V reste disponible.
3. Enregistrer la version de l'outil, l'identité utilisée, le profil de VM, l'heure Europe/Paris et la commande exacte. Exporter les preuves avant toute restauration de checkpoint.
4. Conserver les données brutes dans un emplacement restreint. Les extraits destinés au jury ne contiennent ni mot de passe, jeton, clé Tailscale, secret DSRM, chemin personnel ou contenu métier fictif inutile.
5. Aucun outil ne corrige automatiquement une configuration. Toute correction passe par une sauvegarde préalable, une modification documentée, un contrôle fonctionnel puis un contre-test.

## 1. Audit réseau : Nmap et Ndiff

Nmap reste le scanner de référence du scénario ; Ndiff est utilisé pour comparer ses sorties XML plutôt que d'interpréter deux captures à l'oeil. Le périmètre initial est celui du dossier de conception : depuis `CC-KALI01`, seule la cible `10.77.10.10` et la liste de ports autorisée pour le scénario sont testées, sans script, exploitation, découverte de sous-réseau ni scan du réseau domestique.

- Profil : audit serveur (`CC-PFS01` + `CC-DC01` + `CC-KALI01`), WAN déconnecté.
- Précondition : règle pfSense temporaire documentée, ciblée et limitée dans le temps ; règles de base conservées.
- Preuves : sortie `-oA` avant et après, export de la règle pfSense et Ndiff entre les deux XML.
- Contre-test : retirer la règle temporaire, vérifier le blocage et démontrer que le fonctionnement métier AD n'a pas été modifié par le scan.

Nmap/Ndiff ne sert pas à conclure qu'un service est sain ou vulnérable : il démontre uniquement l'exposition et l'effet d'une règle de filtrage.

## 2. Télémétrie endpoint : Sysmon

Sysmon est la source de télémétrie Windows du pack. Avant son activation, vérifier qu'une seule implémentation Sysmon est présente ; le Sysmon intégré et l'ancienne version autonome ne doivent pas coexister. Commencer avec une configuration volontairement restreinte et les événements nécessaires aux scénarios, puis mesurer la taille des journaux avant d'élargir la collecte.

- Cibles : `CC-W11-01` d'abord ; `CC-DC01` seulement après validation de l'impact et de la rétention.
- Événements utiles : création de processus, connexions réseau et modification de l'heure de création d'un fichier, complétés par l'audit Windows déjà prévu.
- Preuves : état du service, configuration, export EVTX et taille du journal avant/après le scénario.
- Limite : Sysmon n'analyse pas, n'alerte pas et ne bloque pas ; il fournit les données que Hayabusa interprète hors ligne.

## 3. Analyse des journaux : Hayabusa

Hayabusa analyse les exports EVTX ; il n'est pas installé comme un agent permanent. Il sert à relier un événement de scénario à une règle Sigma et à générer une chronologie lisible.

La piste endpoint exploite d'abord les événements réellement configurés sur `CC-W11-01` : processus sélectionnés, connexion vers le DC et changement d'heure de création d'un fichier. Le verrouillage de `tst.lock` relève surtout du journal Security du DC ; il ne doit pas être présenté comme une démonstration de Sysmon sur le poste. Les scénarios restent simulés, sans malware réel, brute force ni collecte de secrets.

- Entrées : EVTX exportés après chaque scénario, avec leur empreinte SHA-256.
- Sorties : chronologie CSV ou JSON, règle déclenchée, événement source, horodatage UTC et interprétation humaine.
- Validation : rapprocher chaque alerte de la preuve native et de l'action réellement menée ; une détection seule ne constitue pas une conclusion automatique.

## 4. Gouvernance des GPO : GPOZaurr

GPOZaurr est exécuté après la création des GPO de laboratoire, depuis une session d'administration autorisée qui dispose des outils RSAT nécessaires. Son rôle est d'inventorier et de signaler : liens rompus, héritages inattendus, propriétaires, permissions sensibles, incohérences et fichiers historiques de SYSVOL.

- Mode : collecte et rapport uniquement ; aucune commande de correction GPOZaurr n'est exécutée pendant la soutenance.
- Portée : domaine `ad.cybercorp.test`, avec une attention particulière aux GPO liées à `OU=Postes` et aux comptes d'administration.
- Preuves : rapport expurgé, export de la GPO concernée, `gpresult` du client et contre-test du comportement métier.
- Limite : un écart GPOZaurr ouvre un constat ; il ne vaut pas à lui seul preuve d'exploitation ni modification automatique.

## 5. Conformité as code : Conftest / OPA

Conftest est le contrôle préalable du mandat M-CLIENT-01 et peut aussi servir de vérificateur indépendant pour le bonus GenOS. Il évalue un export JSON expurgé avec des règles Rego versionnées. Il est exécuté localement ; aucun serveur OPA ni connecteur d'administration n'est exposé.

L'export initial doit contenir uniquement les informations nécessaires : nom/type des commutateurs, rattachement des cartes VM, états attendus et inventaire de services. Il ne contient ni secrets, adresses Tailscale, données personnelles, journaux bruts ni configuration pfSense complète.

Les premières politiques à écrire sont :

- `V01` : `CC-LAN` et `CC-AUDIT` sont de type `Private`.
- `V02` : `CC-DC01`, `CC-W11-01` et `CC-KALI01` n'ont qu'une carte et ne sont reliés ni à `Default Switch` ni à un commutateur `External`.
- `V03` : `CC-KALI01` est uniquement sur `CC-AUDIT`.
- `V04` : la carte WAN de `CC-PFS01` est absente ou déconnectée dans le profil audit.
- `V05` : les noms de VM, commutateurs et zones correspondent à l'inventaire versionné.

Une politique doit être démontrée avec une entrée conforme (PASS) et un écart artificiel dans une copie (FAIL). Le fichier de référence n'est jamais modifié pour fabriquer un résultat.

## Ordre de clôture du mandat

1. Ouvrir la [fiche de décision M-CLIENT-01](fiche-m-client-01.md), nommer le responsable fictif, le dossier `Clients` concerné, la fenêtre d'audit et les preuves à conserver. Une case non renseignée ne vaut pas approbation.
2. Écrire et exécuter Conftest V01 à V05 sur l'export réel et une copie fautive ; vérifier aussi les cartes dans Hyper-V. Ce contrôle devient une porte d'entrée avant une nouvelle exception.
3. Reprendre le rapport GPOZaurr existant, revoir les liens, propriétaires et permissions, puis tester `gpresult` et les droits effectifs sur le dossier. Consigner les écarts et leurs responsables.
4. Refaire, si le laboratoire le permet, le triplet Nmap « bloqué / autorisé / rebloqué » avec trois fichiers XML distincts et Ndiff pour les deux transitions. S01 fournit déjà une démonstration partielle, pas la première pièce XML.
5. Réaliser une action bénigne définie sur le poste, exporter et hacher les EVTX, puis établir avec Hayabusa une chronologie reliée aux événements sources. Faire trancher la fiche, avec les incertitudes explicites.

Le tableau de recette existant reste la source de vérité des validations : aucun test n'est marqué `Validé` tant que son exécution, sa preuve native et son contre-test n'ont pas été vérifiés.

## Tâches du mandat métier

Chaque tâche doit aboutir à une décision et à une pièce du dossier de remise. « À réaliser » signifie que les preuves existantes peuvent être réutilisées, mais que la décision métier n'a pas encore été prise.

| Tâche | Irritant métier et responsable fictif | Travail à accomplir | Critère de clôture | État |
| --- | --- | --- | --- | --- |
| M01 — Demande traçable | La direction veut une livraison rapide ; l'IT reçoit des demandes orales d'ouverture. Responsable : direction. | Rédiger la fiche `M-CLIENT-01` : motif, porteur, cible, ports, fenêtre, approbation, retour prévu et effet sur le livrable. | La demande permet à un autre administrateur de décider sans deviner le périmètre. | À réaliser. |
| M02 — Refus d'une dérive silencieuse | Une carte Hyper-V ajoutée pour dépanner peut échapper à la revue. Responsable : IT. | Exporter la topologie réelle, écrire V01–V05, exécuter Conftest sur l'export et sur une copie fautive, puis comparer aux cartes natives. | PASS réel, FAIL sur erreur injectée, export daté et vérification de l'absence de faux PASS sur champ manquant. | À réaliser. |
| M03 — GPO gouvernée | Une stratégie fonctionne aujourd'hui, mais ses droits ou son lien peuvent autoriser une modification future non maîtrisée. Responsable : IT. | Reprendre le rapport GPOZaurr T10, examiner liens, propriétaires et permissions pertinents, croiser avec `gpresult`, puis noter toute décision d'écart. | Un constat précis ou une absence d'écart vérifiée sur ces catégories ; effet métier documenté. | T10 couvre les GPO cassées/orphelines ; revue des autres catégories à réaliser. |
| M04 — Exception mesurée et refermée | Une règle d'audit provisoire reste parfois active après la mission. Responsable : IT et auditeur. | Rattacher S01 à la fiche M01 ; confronter les XML « autorisé » et « rebloqué », l'observation initiale consignée et les horaires de règle ; lors d'un prochain changement, conserver trois XML distincts. | Ndiff explique la fermeture ; l'état final et la règle pfSense concordent ; l'export manquant est déclaré. | Deux XML S01 préservés ; XML initial écrasé et dossier de changement à compléter. |
| M05 — Signal endpoint préservé | Après une anomalie, l'IT doit comprendre une action sur un poste sans avoir capturé tout le système. Responsable : IT. | Définir une action bénigne correspondant aux événements Sysmon configurés, relever son heure et son compte, comparer le SHA-256 du livrable fictif avant/après, exporter Sysmon et Security, hacher les EVTX. | Processus et événement source retrouvés ; absence de trace explicitée si la configuration ne la produit pas ; empreinte du livrable interprétée sans prétendre exclure une lecture ou une copie. | Essai Sysmon présent ; cas métier et T12–T13 à compléter. |
| M06 — Qualification pour la direction | Une alerte brute peut provoquer une décision erronée ou être ignorée. Responsable : IT, décision finale : direction. | Traiter les EVTX M05 avec Hayabusa ; relier chronologie, règle, événement source et action connue ; conclure attendu, suspect ou indéterminé. | Fiche lisible qui cite la preuve et ses limites, avec décision poursuivre, corriger ou suspendre. | Chronologie d'essai présente ; qualification du mandat à réaliser. |
| M07 — Contre-test et remise | Le client fictif veut savoir ce qui est encore ouvert après l'intervention. Responsable : IT. | Refaire les contrôles touchés par toute correction et assembler les extraits expurgés, le temps de constitution et les limites. | État final attribué à un responsable, écarts ouverts visibles et preuve avant/après vérifiable. | À réaliser. |

Les tests T08–T09 restent nécessaires pour prouver les droits sur les dossiers `Clients`, `Finance` et `RH`. Les tests T14–T15 vérifient la reprise. Ni GPOZaurr ni les journaux endpoint ne peuvent établir seuls ces résultats.
