# Journal de déploiement CyberCorp

Ce journal conserve les étapes réalisées et validées avec l'utilisateur. Une étape n'est marquée **Validée** qu'après confirmation explicite de l'utilisateur.

## État des étapes

| Étape | Objet | État |
| --- | --- | --- |
| 1 | Inventaire initial et décision de conservation | Validée |
| 2 | Sauvegarde/export des VM existantes | Validée |
| 3 | Contrôle et création des commutateurs Hyper-V | Validée |
| 4 | Décision de réutilisation pour chaque VM | Validée |
| 5 | Adaptation ou reconstruction de `CC-PFS01` | En attente Netgate |
| 6 | Adaptation ou reconstruction de `CC-DC01` | En cours |
| 7 | Adaptation ou reconstruction de `CC-W11-01` | À faire |
| 8 | Import et confinement de `CC-KALI01` | À faire |
| 9 | Configuration réseau, domaine et comptes | À faire |
| 10 | Recette de sécurité T01–T15 | À faire |

## Étape 1 — Inventaire initial et décision de conservation

**État : Validée**

### Constats

- Hôte : Windows 11 Professionnel, Hyper-V actif, AMD Ryzen 7 8745HS (8 cœurs/16 processeurs logiques).
- Mémoire physique détectée : environ 11,75 Gio utilisables ; la cible documentaire supposait 16 Gio.
- Stockage `C:` : environ 272,5 Gio libres au moment du relevé.
- Réseaux actifs observés : Wi-Fi `192.168.1.0/24`, WSL `172.17.112.0/20`, Default Switch `172.23.160.0/20`, Tailscale `100.81.15.122/32`.
- Aucun chevauchement observé avec les réseaux projetés `10.77.10.0/24`, `10.77.20.0/24` et `172.31.250.0/24`.
- VM existantes retrouvées : `CLIENT01`, `DC01`, `PFSENSE01`. La VM Kali n'est pas encore importée.
- Points de contrôle détectés : deux pour `CLIENT01`, deux pour `DC01`, un pour `PFSENSE01`.
- Un ancien réseau Hyper-V `LAB-AD` est exposé sur l'hôte. La présence exacte des commutateurs privés doit être confirmée avec des droits administrateur.
- Supports disponibles : Windows Server 2025 Evaluation FR, Windows 11 Enterprise Evaluation 25H2 FR, Kali Linux 2026.2 Hyper-V AMD64 et Netgate Installer AMD64.

### Décision proposée

- Ne rien supprimer à ce stade.
- Conserver les disques et points de contrôle existants jusqu'à la fin de l'étape de sauvegarde.
- Examiner chaque VM avant de décider de l'adapter ou de la reconstruire.
- Ne jamais supprimer directement un fichier `.avhdx`.
- Ne pas démarrer les quatre VM simultanément ; privilégier les scénarios à 7 Gio de RAM VM.

### Validation

- Date : 13 octobre 2026
- Validation utilisateur : « Je valide »
- Preuves ou remarques : conservation des VM, disques et points de contrôle approuvée avant toute modification.

## Étape 2 — Sauvegarde/export des VM existantes

**État : Validée**

### Objectif

Créer une copie récupérable de `CLIENT01`, `DC01` et `PFSENSE01` avant de modifier les commutateurs, les noms ou les configurations des VM.

### Contrôles préalables

- [x] État de chaque VM confirmé dans le Gestionnaire Hyper-V.
- [x] Toutes les VM arrêtées proprement avant l'export.
- [x] Dossier de destination et espace libre confirmés.
- [x] Export des trois VM terminé sans erreur.
- [x] Contenu des exports vérifié.

### État observé avant export

Capture fournie par l'utilisateur le 13 octobre 2026 :

- `CLIENT01` : **Désactivé**.
- `DC01` : **Désactivé**.
- `PFSENSE01` : **Exécution**, 1 024 Mo de mémoire affectée et 0 % de processeur au moment de la capture.
- La vue des points de contrôle de `CLIENT01` affiche `Point de contrôle automatique - CLIENT01 - (08/10/2026 - 09:00:43)`, puis `Labo AD fonctionnel`, suivis de l'état `Maintenant`.
- Prochaine action : arrêter proprement `PFSENSE01` avant tout export. Ne pas employer l'action brutale **Désactiver**.

Une seconde capture fournie le 13 octobre 2026 confirme ensuite les états suivants :

- `CLIENT01` : **Désactivé**.
- `DC01` : **Désactivé**.
- `PFSENSE01` : **Désactivé** après arrêt propre.

### Destination de sauvegarde

- Dossier créé : `C:\Users\Public\Documents\Hyper-V\Exports\CyberCorp-PreMigration-2026-10-13`.
- Espace libre relevé avant export : environ 272,5 Gio sur `C:`.
- Cette sauvegarde locale protège contre une erreur de reconfiguration ou de suppression logique. Comme elle reste sur le même disque physique, elle ne protège pas contre une panne de ce disque.

### Suivi des exports

- `PFSENSE01` : **export vérifié** le 13 octobre 2026. L'export contient une configuration `.vmcx`, les fichiers d'état associés et un disque consolidé `PFSENSE01.vhdx` d'environ 5,69 Gio. Taille totale : environ 5,70 Gio.
- `CLIENT01` : **export vérifié** le 13 octobre 2026. La copie contient le disque de base, les deux disques différentiels, trois configurations `.vmcx` correspondant à la VM et à ses deux points de contrôle, ainsi que les fichiers d'état associés. Taille totale : environ 18,24 Gio.
- `DC01` : **export vérifié** le 13 octobre 2026. La copie contient le disque de base, les deux disques différentiels, trois configurations `.vmcx` correspondant à la VM et à ses deux points de contrôle, ainsi que les fichiers d'état associés. Taille totale : environ 30,10 Gio.

### Contrôle final des sauvegardes

- Taille totale des trois exports : environ 54,04 Gio.
- Espace libre restant sur `C:` après export : environ 225,6 Gio.
- Les trois dossiers comportent chacun une configuration de VM et leurs disques associés.
- Les exports de `CLIENT01` et `DC01` préservent chacun deux points de contrôle.
- L'export de `PFSENSE01` contient un disque consolidé sans fichier `.avhdx` séparé.

### Validation

- Date : 13 octobre 2026
- Validation utilisateur : « Valide »
- Preuves ou remarques : exports de `PFSENSE01`, `CLIENT01` et `DC01` vérifiés, pour un total d'environ 54,04 Gio.

## Étape 3 — Contrôle et création des commutateurs Hyper-V

**État : Validée**

### Objectif

Inventorier les commutateurs existants, puis construire les trois réseaux isolés prévus par l'architecture sans toucher au `Default Switch` ni au commutateur WSL gérés par Windows.

### Stratégie de reconstruction validée

- Date : 13 octobre 2026
- Validation utilisateur : « je valide »
- Décision : reconstruire entièrement le laboratoire avec de nouvelles VM nommées `CC-PFS01`, `CC-DC01`, `CC-W11-01` et `CC-KALI01`.
- Les anciennes VM `PFSENSE01`, `DC01` et `CLIENT01` restent arrêtées et enregistrées pendant la reconstruction.
- Les exports vérifiés sont conservés jusqu'à la réussite de la recette finale.
- Les anciennes VM et leurs fichiers ne seront supprimés qu'après une validation distincte, car cette suppression sera destructive.

### Cible

| Commutateur | Type | Usage |
| --- | --- | --- |
| `CC-LAN` | Privé | pfSense LAN, contrôleur de domaine et poste Windows |
| `CC-AUDIT` | Privé | pfSense AUDIT et Kali |
| `CC-WAN-MAINT` | Interne | pfSense WAN et interface de maintenance de l'hôte |

### Contrôles

- [x] Liste et type des commutateurs existants relevés.
- [x] Ancien commutateur `LAB-AD` conservé intact pour les dépendances des anciennes VM ; aucune suppression ou réaffectation effectuée.
- [x] `CC-LAN` créé comme commutateur privé.
- [x] `CC-AUDIT` créé comme commutateur privé.
- [x] `CC-WAN-MAINT` créé comme commutateur interne.
- [x] Aucun commutateur cible relié directement au Wi-Fi ou au réseau physique.
- [x] Configuration finale vérifiée.

### Inventaire observé

Capture du Gestionnaire de commutateur virtuel fournie le 13 octobre 2026 :

- `LAB-AD` : commutateur virtuel privé existant, conservé pour les anciennes VM.
- `Default Switch` : réseau par défaut géré par Windows, à ne pas modifier.
- `WSL (Hyper-V firewall)` : commutateur interne géré par Windows/WSL, à ne pas modifier.
- `CC-LAN` : nouveau commutateur virtuel privé, note `CyberCorp LAN`, sans connexion directe à la carte Wi-Fi.
- `CC-AUDIT` : nouveau commutateur virtuel privé, note `CyberCorp Audit`, sans connexion directe à la carte Wi-Fi.
- `CC-WAN-MAINT` : première création observée comme **réseau privé**, puis corrigée et confirmée comme **réseau interne**. Note `CyberCorp WAN maintenance`, sans liaison directe à la carte Wi-Fi.

### Interface de maintenance de l'hôte

- Interface créée par Hyper-V : `vEthernet (CC-WAN-MAINT)`.
- Adresse IPv4 statique vérifiée : `172.31.250.1/24`.
- Route locale vérifiée : `172.31.250.0/24` directement connectée.
- Passerelle par défaut : aucune sur cette interface.
- Serveurs DNS : aucun sur cette interface.
- L'indication Windows « Pas d'accès réseau » est attendue pour ce réseau interne isolé.

### Validation

- Date : 13 octobre 2026
- Validation utilisateur : « valide »
- Preuves ou remarques : les trois commutateurs cibles et l'adresse statique de l'interface hôte ont été contrôlés.

## Étape 4 — Décision de réutilisation pour chaque VM

**État : Validée**

- Date : 13 octobre 2026
- Validation utilisateur : « je valide » lors du choix de reconstruction complète.
- Décision : aucune ancienne VM ne sera transformée en VM cible.
- `PFSENSE01`, `DC01` et `CLIENT01` restent arrêtées comme solution de retour arrière.
- De nouvelles VM seront construites sous les noms `CC-PFS01`, `CC-DC01`, `CC-W11-01` et `CC-KALI01`.

## Étape 5 — Reconstruction de `CC-PFS01`

**État : En cours**

### Cible

- Nom : `CC-PFS01`.
- Mémoire : 1 024 Mo statiques.
- Processeurs virtuels : 2.
- Disque : 20 Gio, allocation dynamique.
- Interfaces définitives : `CC-WAN-MAINT`, `CC-LAN` et `CC-AUDIT`.
- WAN définitif : `172.31.250.2/24`, passerelle `172.31.250.1` uniquement pendant les opérations de maintenance.
- WAN déconnecté pendant les exercices d'audit.

### Contrôles

- [x] VM créée avec les paramètres matériels attendus.
- [ ] Installation pfSense terminée.
- [ ] Trois interfaces affectées aux bons commutateurs.
- [ ] Adresses LAN, AUDIT et WAN configurées.
- [ ] Règles de confinement appliquées.
- [ ] Configuration exportée et fonctionnement vérifié.

### Création observée

Captures et fichiers vérifiés le 13 octobre 2026 :

- VM `CC-PFS01` créée et laissée **Désactivée**.
- Génération : 2.
- Mémoire de démarrage : 1 024 Mo.
- Mémoire dynamique : désactivée.
- Aucun point de contrôle.
- Disque dynamique `CC-PFS01.vhdx` créé dans `C:\Users\Public\Documents\Hyper-V\CyberCorp\CC-PFS01\CC-PFS01\Virtual Hard Disks`.
- Configuration Hyper-V créée sous l'identifiant `5C5BF22F-7663-4D64-B1B0-88379422DDD5`.
- Processeurs virtuels : 2, confirmé par capture.
- Démarrage sécurisé : désactivé, conformément aux prérequis pfSense sous Hyper-V.
- Lecteur DVD : ISO `netgate-installer-v1.2-RELEASE-amd64.iso` attaché.
- Première carte réseau : `Default Switch`, uniquement pour donner un accès Internet temporaire à l'installateur Netgate.
- Deuxième carte réseau : `CC-LAN`.
- Troisième carte réseau : `CC-AUDIT`.
- L'ordre des cartes a été confirmé par capture avant le premier démarrage : WAN temporaire, LAN, puis AUDIT.

Correspondance détectée par l'installateur Netgate :

| Interface pfSense | Adresse MAC | Commutateur pendant l'installation | Rôle définitif |
| --- | --- | --- | --- |
| `hn0` | `00:15:5d:01:3c:05` | `Default Switch` | WAN sur `CC-WAN-MAINT` après installation |
| `hn1` | `00:15:5d:01:3c:06` | `CC-LAN` | LAN métier |
| `hn2` | `00:15:5d:01:3c:07` | `CC-AUDIT` | Réseau d'audit |

Choix de stockage de l'installateur :

- Système de fichiers : UFS, retenu pour limiter la consommation mémoire avec 1 024 Mo de RAM.
- Schéma de partition : GPT.
- Disque cible : `da0`, disque virtuel Microsoft de 20 Go.

Installation pfSense CE lancée via le Netgate Installer. Pendant l'installation, seules `hn0` (WAN) et `hn1` (LAN) sont assignées ; `hn2` reste détectée et sera affectée après le premier démarrage comme `OPT1`, puis renommée `AUDIT`.

Première tentative d'installation : **échec**. Le Netgate Installer indique que le système n'est pas installé et demande de consulter `/tmp/install-log.txt`. Aucun nouvel essai ne doit être lancé avant lecture du journal.

Diagnostic du journal : 156 paquets sur 179 ont été récupérés avec succès, puis le téléchargement de `perl5-5.42.2` depuis `https://pkg.pfsense.org/` a atteint le délai maximal (`Timeout was reached`). La panne est donc liée au téléchargement réseau ou au serveur de paquets, et non à la détection du disque ou des interfaces.

Contrôles réseau après l'échec :

- Accès IPv4 fonctionnel depuis l'installateur : `1.1.1.1`, quatre réponses sur quatre, aucune perte.
- Le résolveur du `Default Switch` répond, mais `pkg.pfsense.org` ne publie momentanément aucune adresse `A` ni `AAAA`.
- Le même résultat a été confirmé depuis l'hôte avec le résolveur système et le résolveur public Cloudflare `1.1.1.1`.
- Conclusion : incident DNS externe côté dépôt Netgate, sans lien avec la configuration Hyper-V locale. L'installation doit être reprise lorsque l'enregistrement DNS officiel est revenu ; aucune redirection manuelle vers un miroir non validé ne sera utilisée.
- `CC-PFS01` arrêtée proprement avec `shutdown -p now` après le diagnostic. La VM, son disque et ses paramètres sont conservés pour reprendre l'installation.

### Validation

- Date : —
- Validation utilisateur : —
- Preuves ou remarques : —

## Étape 6 — Reconstruction de `CC-DC01`

**État : En cours**

### Cible

- Nom : `CC-DC01`.
- Génération : 2.
- Mémoire de démarrage : 4 096 Mo ; mémoire dynamique autorisée avec minimum 2 048 Mo et maximum 4 096 Mo.
- Processeurs virtuels : 2.
- Disque système : 80 Gio, allocation dynamique.
- Disque de données : 30 Gio, allocation dynamique, à ajouter après la création initiale.
- Réseau : une seule carte sur `CC-LAN`.
- Système : Windows Server 2025 Evaluation avec expérience de bureau.
- Aucun accès direct au `Default Switch` ou à un commutateur externe.

### Contrôles

- [x] VM créée avec les paramètres matériels attendus.
- [ ] Windows Server 2025 installé.
- [ ] Nom `CC-DC01` et adresse `10.77.10.10/24` configurés.
- [ ] Second disque de 30 Gio initialisé.
- [ ] Rôles AD DS, DNS et fichiers installés.
- [ ] Forêt `ad.cybercorp.test` créée et contrôles de santé réussis.
- [ ] Configuration sauvegardée et fonctionnement vérifié.

### Création observée

Captures et fichiers vérifiés le 13 octobre 2026 :

- VM `CC-DC01` créée et laissée **Désactivée**.
- Génération : 2.
- Un point de contrôle automatique non souhaité a ensuite été créé le 13 octobre 2026 à 17:12:14, avant le premier démarrage et avant l'installation de Windows. La VM étant encore vide et arrêtée, ce point doit être supprimé proprement depuis le Gestionnaire Hyper-V. Les fichiers `.avhdx` ne doivent jamais être supprimés manuellement.
- Suppression du point de contrôle validée visuellement : le Gestionnaire Hyper-V indique désormais que `CC-DC01` n'a pas de point de contrôle.
- Contrôle complémentaire du stockage : deux fichiers `.avhdx` de 4 Mio portant l'horodatage du point de contrôle subsistent dans le dossier des disques. Une première observation les avait classés prudemment comme résidus, sans les supprimer.
- Cause observée dans les paramètres : les points de contrôle standard étaient sélectionnés et l'option de création automatique était activée. Réglage correctif demandé avant le premier démarrage : points de contrôle de production uniquement, sans repli standard et sans point de contrôle automatique.
- Réglage correctif vérifié par capture : points de contrôle activés, type **Production**, repli vers les points standard désactivé et création automatique désactivée.
- Enregistrement confirmé après fermeture des paramètres : `CC-DC01` reste désactivée et le Gestionnaire Hyper-V indique qu'elle n'a aucun point de contrôle. La VM est prête pour son premier démarrage.
- Premier démarrage : échec avant amorçage avec le code `0x800705AA`, Hyper-V ne pouvant pas allouer les 4 096 Mo demandés.
- Mesure de l'hôte au moment de l'échec : 11,75 Gio de RAM visible, environ 3,54 Gio libres et 8,21 Gio utilisés. Correction retenue : mémoire de démarrage abaissée à 2 048 Mo, mémoire dynamique maintenue avec un maximum de 4 096 Mo.
- Réglage mémoire vérifié par capture : démarrage 2 048 Mo, minimum 2 048 Mo, maximum 4 096 Mo et mémoire dynamique activée.
- La même capture révèle que les deux fichiers `.avhdx` sont encore attachés au contrôleur SCSI malgré la disparition du point de contrôle dans l'interface. Ils ne sont donc pas considérés comme orphelins. Démarrage suspendu jusqu'au rattachement propre des disques de base `.vhdx` ; aucune suppression manuelle de fichier ne sera effectuée.
- Diagnostic affiné : le fichier de configuration du point de contrôle n'existe plus, mais la configuration courante de la VM reste raccordée aux deux `.avhdx`. Hyper-V affiche donc encore un avertissement de point de contrôle et interdit la modification directe du disque. Les `.avhdx` ont une taille de 4 Mio et n'ont jamais été écrits depuis leur création, la VM n'ayant jamais démarré.
- Décision de réparation : déconnecter les `.avhdx` depuis les paramètres Hyper-V, sans supprimer les fichiers, puis rattacher `CC-DC01.vhdx` et `CC-DC01-DATA.vhdx`. La recréation complète de la VM n'est pas nécessaire à ce stade.
- Premier résultat de réparation validé par capture : le disque différentiel système `CC-DC01_C839814B-A624-463C-B1E0-10D7B185CE0B.avhdx` a été déconnecté de la VM, sans suppression du fichier. Le lecteur DVD et le disque différentiel de données restent présents.
- Second résultat validé par capture : le disque différentiel de données `CC-DC01-DATA_7ED2877A-DE03-49A2-BD88-9301CE4F78AA.avhdx` a également été déconnecté sans suppression. Seul le lecteur DVD reste attaché au contrôleur SCSI ; les disques de base peuvent désormais être rattachés.
- Rattachement observé : les deux disques de base `CC-DC01.vhdx` et `CC-DC01-DATA.vhdx` apparaissent de nouveau sous le contrôleur SCSI, sans suffixe `.avhdx`. Le disque de données est confirmé à l'emplacement SCSI 2 et le lecteur DVD à l'emplacement 1. L'emplacement 0 du disque système reste à confirmer visuellement.
- Confirmation utilisateur : le disque système `CC-DC01.vhdx` est à l'emplacement SCSI 0. Configuration finale du contrôleur : système 0, DVD 1, données 2. Les anciens `.avhdx` sont conservés sur le stockage mais ne sont plus attachés à la VM.
- Tentative de démarrage suivante : échec sur `CC-DC01-DATA.vhdx`, signalé comme utilisé par un autre processus. Le disque n'est pas monté sur l'hôte (`Get-DiskImage` indique `Attached: false`). Hypothèse prioritaire : verrou conservé par une ancienne fenêtre d'inspection, de paramètres ou de connexion Hyper-V ; fermeture complète des interfaces demandée avant toute action plus intrusive.
- Nettoyage d'interface confirmé : toutes les consoles et fenêtres Hyper-V ont été fermées, puis le Gestionnaire Hyper-V a été rouvert. Aucun processus `vmconnect` résiduel n'est actif et toutes les VM restent arrêtées avant la nouvelle tentative.
- Nouvelle tentative : même échec de partage sur `CC-DC01-DATA.vhdx`.
- Diagnostic par l'API Windows Restart Manager : le verrou est détenu par `System` (PID 4, application critique non redémarrable), ce qui indique un verrou noyau résiduel du sous-système de disque virtuel et non une fenêtre utilisateur. Toutes les VM étant arrêtées, décision : redémarrer d'abord le service de gestion Hyper-V ; un redémarrage complet de l'hôte ne sera envisagé que si ce nettoyage ciblé échoue.
- Disque système dynamique `CC-DC01.vhdx` créé sous `C:\Users\Public\Documents\Hyper-V\CyberCorp\CC-DC01\Virtual Hard Disks`.
- Configuration Hyper-V créée sous l'identifiant `696B08FF-A882-4E7F-94AF-9C288D960E88`.
- Processeurs virtuels : 2.
- Mémoire dynamique : activée, démarrage 4 096 Mo, minimum 2 048 Mo, maximum 4 096 Mo, tampon 20 %.
- Démarrage sécurisé : activé pour Windows Server.
- Carte réseau unique : `CC-LAN`.
- Lecteur DVD : ISO Windows Server 2025 Evaluation FR attaché.
- Première tentative d'ajout du disque de données : échec, car la configuration référençait `CC-DC01-DATA.vhdx` alors que le fichier n'avait pas été créé. Le disque système `CC-DC01.vhdx` est intact. Correction de l'attachement requise.
- Contrôle ultérieur : `CC-DC01-DATA.vhdx` avait finalement été créé par la première tentative en taille fixe, avec une taille physique d'environ 30 Gio. La tentative de création dynamique a échoué parce que ce fichier existait déjà. Décision : conserver le disque fixe et l'attacher à la VM ; espace libre restant après sa création, environ 193,9 Gio.
- Propriétés du fichier confirmées par capture : format VHDX, disque virtuel de taille fixe, taille actuelle et maximale de 30 Go.
- Les deux disques `CC-DC01.vhdx` et `CC-DC01-DATA.vhdx` sont confirmés comme attachés au contrôleur SCSI.
- Le redémarrage ciblé du service `vmms` n'a pas libéré le verrou noyau sur le disque fixe `CC-DC01-DATA.vhdx` ; une nouvelle tentative a reproduit l'erreur `0x80070020`.
- Correction non destructive appliquée : le disque fixe verrouillé, encore vierge puisque la VM n'avait jamais démarré, a été détaché mais conservé intact. Un disque dynamique de 30 Gio nommé `CC-DC01-DATA-DYNAMIC.vhdx` a été créé et attaché à l'emplacement SCSI 2.
- Configuration finale contrôlée : mémoire dynamique 2–4 Gio, 2 processeurs virtuels, points de contrôle de production, points automatiques désactivés, carte unique sur `CC-LAN`, disque système en SCSI 0 et disque de données dynamique en SCSI 2.
- Démarrage réussi le 13 octobre 2026 à 18:15 (Europe/Paris) : état Hyper-V `Running`, statut `Fonctionnement normal`, 2 048 Mio de mémoire affectée.

### Validation

- Date : —
- Validation utilisateur : —
- Preuves ou remarques : —
