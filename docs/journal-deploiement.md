# Journal de déploiement CyberCorp

Ce journal conserve les étapes réalisées et validées avec l'utilisateur. Une étape n'est marquée **Validée** qu'après confirmation explicite de l'utilisateur.

## État des étapes

| Étape | Objet | État |
| --- | --- | --- |
| 1 | Inventaire initial et décision de conservation | Validée |
| 2 | Sauvegarde/export des VM existantes | Validée |
| 3 | Contrôle et création des commutateurs Hyper-V | Validée |
| 4 | Décision de réutilisation pour chaque VM | Validée |
| 5 | Adaptation ou reconstruction de `CC-PFS01` | Validée |
| 6 | Adaptation ou reconstruction de `CC-DC01` | Validée |
| 7 | Adaptation ou reconstruction de `CC-W11-01` | Validée |
| 8 | Import et confinement de `CC-KALI01` | Validée |
| 9 | Configuration réseau, domaine et comptes | À faire |
| 10 | Recette de sécurité T01–T15 | En cours |

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

**État : Validée**

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
- [x] Installation pfSense terminée et démarrage depuis le VHDX validé sans ISO.
- [x] Trois interfaces affectées aux commutateurs définitifs `CC-WAN-MAINT`, `CC-LAN` et `CC-AUDIT`.
- [x] Adresses WAN, LAN et AUDIT configurées sur leurs réseaux définitifs.
- [x] Règles de confinement appliquées.
- [x] Configuration exportée et fonctionnement vérifié.

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
- Le nom méta `pkg.pfsense.org` ne publie pas d’adresse `A` ou `AAAA`, comportement normal documenté par Netgate : le client `pkg` découvre les serveurs réels au moyen de l’enregistrement SRV `_https._tcp.pkg.pfsense.org`.
- Contrôle corrigé le 16 octobre 2026 : les cibles officielles `pkg00-atx.netgate.com` (`208.123.73.207`) et `pkg01-atx.netgate.com` (`208.123.73.209`) sont publiées par SRV et répondent toutes deux sur TCP/443 depuis l’hôte.
- Conclusion révisée : le premier échec correspond à un délai de téléchargement ponctuel sur le paquet `perl5-5.42.2`, et non à l’absence anormale d’un enregistrement `A` sur le nom méta. Une nouvelle tentative d’installation est autorisée sans redirection vers un miroir tiers.
- `CC-PFS01` arrêtée proprement avec `shutdown -p now` après le diagnostic. La VM, son disque et ses paramètres sont conservés pour reprendre l'installation.
- Nouvelle tentative menée à terme le 17 octobre 2026 : pfSense CE `2.9.0-RELEASE` installé sur `da0` avec UFS et GPT, puis démarré depuis le disque virtuel.
- État au premier démarrage : WAN `hn0` en DHCP sur le `Default Switch` (`172.21.254.39/20`) et LAN `hn1` sur `10.77.10.1/24`. L’interface `hn2` reste à affecter comme réseau `AUDIT`.
- Interface `hn2` affectée comme `OPT1` puis configurée sur `10.77.20.1/24`, sans passerelle, sans IPv6 et sans serveur DHCP. Le protocole HTTPS du webConfigurator est conservé.
- Après retrait du média d’installation, Hyper-V tentait encore d’ouvrir l’ISO depuis `Downloads` et refusait le démarrage. L’ISO a été éjectée explicitement du lecteur DVD virtuel.
- Le démarrage a ensuite été bloqué par la pression mémoire de l’hôte. Le tampon de mémoire dynamique de `CC-DC01` a été abaissé de 20 % à 5 % sans modifier son minimum de 2 048 Mo. Les quatre conteneurs Docker `tandian` ont été arrêtés proprement, Docker Desktop et WSL ont été arrêtés sans suppression de données, libérant environ 2 068 Mo.
- `CC-PFS01` a alors démarré correctement avec ses 1 024 Mo statiques. La carte WAN est désormais raccordée à `CC-WAN-MAINT`, les cartes LAN et AUDIT restant sur leurs commutateurs privés respectifs.
- Diagnostic du démarrage PXE le 17 octobre 2026 : le VHDX de base et le `.avhdx` attaché ne mesuraient que 4 Mio chacun. Le menu pfSense précédemment observé provenait donc encore du média Netgate chargé en mémoire ; aucune installation amorçable n’avait été écrite sur le disque de 20 Gio.
- Mesure corrective : VM arrêtée, points de contrôle automatiques désactivés, anciens fichiers vides conservés sans suppression, nouveau disque dynamique `CC-PFS01-OS.vhdx` de 20 Gio attaché en SCSI 0:0. L’ISO officielle a été copiée dans `CC-PFS01\ISO` puis attachée en SCSI 0:1 et placée en tête de l’ordre de démarrage.
- Pour permettre le redémarrage avec 1 024 Mo, les jeux de travail des applications ont été purgés sans fermeture ni perte d’état, portant la mémoire libre de l’hôte à environ 2 988 Mo. La VM a ensuite démarré correctement sur l’installateur.
- Seconde installation réellement écrite sur `CC-PFS01-OS.vhdx` : taille physique observée de 4 708 Mio pour une capacité virtuelle de 20 Gio. `hn2` a été réaffectée comme `OPT1` sur `10.77.20.1/24`, sans DHCP ni IPv6.
- Après arrêt propre, l’ISO a été éjectée, le VHDX placé en première position UEFI et `hn0` déplacée du `Default Switch` vers `CC-WAN-MAINT`. Le démarrage depuis disque a réussi et les trois cartes Hyper-V sont revenues à l’état `Ok`.
- Adressage final vérifié sur la console pfSense : WAN `hn0` `172.31.250.2/24` avec passerelle `172.31.250.1`, LAN `hn1` `10.77.10.1/24`, OPT1 `hn2` `10.77.20.1/24` ; IPv6 et serveurs DHCP désactivés sur les réseaux internes.
- Assistant web initial terminé depuis `CC-W11-01`. Nom système `cc-pfs01.ad.cybercorp.test`, DNS primaire `10.77.10.10`, NTP interne `10.77.10.10`, fuseau `Europe/Paris`, WAN statique confirmé et blocage RFC1918 désactivé uniquement sur ce WAN privé de maintenance. Le mot de passe initial `admin` a été remplacé par le secret prévu, sans consignation de sa valeur.
- Tableau de bord vérifié : pfSense CE `2.9.0-RELEASE`, WAN `172.31.250.2`, LAN `10.77.10.1` et OPT1 `10.77.20.1`, trois interfaces actives.
- L’interface `OPT1` a été renommée `AUDIT`, conservée active en IPv4 statique `10.77.20.1/24`, sans IPv6, sans passerelle propre et sans filtrage RFC1918/bogon spécifique à l’interface interne.
- Règle de base appliquée sur `AUDIT` : blocage IPv4 de tout trafic provenant de `AUDIT subnets` vers toute destination, tous protocoles, avec journalisation. Cette règle reste en dernière position ; toute autorisation de scénario devra être temporaire, ciblée et placée au-dessus.
- Règle de segmentation appliquée en tête de l’onglet LAN : blocage IPv4 journalisé de `LAN subnets` vers `AUDIT subnets`, avant la règle par défaut autorisant le reste du trafic LAN. Le trafic direct entre `CC-DC01` et `CC-W11-01` reste local au même commutateur et n’est pas affecté.
- Règle permissive IPv6 par défaut du LAN désactivée (conservée mais inactive), en cohérence avec la désactivation d’IPv6 sur les interfaces du laboratoire.
- Override du résolveur DNS appliqué pour `ad.cybercorp.test` vers le serveur Active Directory/DNS `10.77.10.10`, sans DNS sur TLS.
- Validation de l’override depuis `Diagnostics > DNS Lookup` : `cc-dc01.ad.cybercorp.test` retourne l’enregistrement A `10.77.10.10`; le serveur AD/DNS `10.77.10.10` apparaît dans les mesures de requête.
- Export chiffré de la configuration complète réalisé le 18 octobre 2026 depuis `Diagnostics > Backup & Restore`, avec données RRD exclues, informations de paquets incluses et clés SSH incluses. Le fichier le plus récent observé est `config-cc-pfs01.ad.cybercorp.test-20261018153424 (1).xml`, stocké provisoirement dans les téléchargements de `CC-W11-01`; une copie externe à la VM reste à effectuer.
- Copie externe réalisée sur l’hôte dans `secrets/pfsense-backups/config-cc-pfs01.ad.cybercorp.test-20261018153424.xml`, emplacement exclu de Git. Contrôle sans déchiffrement : enveloppe `BEGIN/END config.xml`, corps Base64 valide de 14 928 octets, charge OpenSSL `Salted__` et absence de section `<system>` en clair. Empreinte SHA-256 : `11501A52D926588688073E9434FD17CE5463F36A39DC33AAB9710394A3E7E28D`.
- Test de confinement effectué depuis `CC-KALI01` le 18 octobre 2026 : `eth0` est actif sur `10.77.20.50/24` avec route par défaut via `10.77.20.1`. Les tests ICMP vers la passerelle AUDIT `10.77.20.1`, le contrôleur de domaine `10.77.10.10` et Internet `1.1.1.1` échouent tous avec 100 % de perte, conformément à la règle de blocage AUDIT.
- Journalisation vérifiée dans `Status > System Logs > Firewall` avec le filtre `Block`, interface `AUDIT`, source `10.77.20.50` : 233 entrées correspondent à la règle `BASELINE - Bloquer et journaliser AUDIT` (Tracking ID `1792264179`). Les événements montrent notamment le rejet des requêtes UDP/53 de Kali vers le DNS AD `10.77.10.10`.
- Test inverse depuis `CC-W11-01` (`10.77.10.100`) vers l’adresse AUDIT de pfSense `10.77.20.1` : deux requêtes ICMP envoyées, aucune réponse et 100 % de perte, résultat conforme au blocage `LAN subnets` vers `AUDIT subnets`.
- Journalisation du test inverse confirmée : deux entrées ICMP bloquées sur l’interface `LAN`, source `10.77.10.100`, destination `10.77.20.1`, associées à la règle `BASELINE - Bloquer LAN vers AUDIT` (Tracking ID `1792265901`).
- Baseline isolée préparée le 18 octobre 2026 : arrêt propre de pfSense, déconnexion Hyper-V de la carte WAN `hn0` (MAC `00:15:5d:01:3c:0e`) du commutateur `CC-WAN-MAINT`, cartes LAN et AUDIT maintenues sur leurs commutateurs privés. Point de contrôle standard `Baseline-pfSense-2.9.0-2026-10-18` créé avec les points automatiques désactivés.
- Redémarrage après point de contrôle réussi : `CC-PFS01` fonctionne avec 1 024 Mio, la carte WAN reste sans commutateur, et les cartes `CC-LAN` et `CC-AUDIT` sont à l’état `Ok`. `CC-DC01` et `CC-W11-01` fonctionnent simultanément avec pfSense tandis que Kali reste arrêtée.

### Validation

- Date : 18 octobre 2026.
- Validation utilisateur : validation progressive par captures et résultats de tests réseau.
- Preuves ou remarques : pfSense CE `2.9.0-RELEASE` démarre depuis son VHDX, les interfaces LAN et AUDIT sont actives sur `10.77.10.1/24` et `10.77.20.1/24`, le WAN de maintenance est déconnecté, les règles de confinement sont effectives et journalisées dans les deux sens, l’override DNS AD fonctionne, la configuration chiffrée est sauvegardée hors de la VM et le point de contrôle `Baseline-pfSense-2.9.0-2026-10-18` a été créé.

## Étape 7 — Reconstruction de `CC-W11-01`

**État : Validée**

### Cible

- Nom : `CC-W11-01`.
- Génération : 2.
- Mémoire : 4 096 Mo pour l’installation, puis mémoire dynamique adaptée à la capacité réelle de l’hôte.
- Processeurs virtuels : 2.
- Disque système : 80 Gio, allocation dynamique.
- Réseau : une seule carte sur `CC-LAN`.
- Système : Windows 11 Enterprise Evaluation FR.
- Adresse prévue : `10.77.10.100/24`, passerelle `10.77.10.1`, DNS `10.77.10.10`.

### Contrôles

- [x] VM créée avec un disque dynamique de 80 Gio, 4 096 Mo au démarrage, une carte sur `CC-LAN` et l’ISO Windows 11 attaché.
- [x] Deux processeurs virtuels et paramètres de mémoire/points de contrôle vérifiés.
- [x] Windows 11 installé et compte local de secours configuré.
- [x] Nom et adresse IPv4 configurés.
- [x] Poste joint au domaine `ad.cybercorp.test` et déplacé dans l’OU `Postes`.
- [x] Configuration sauvegardée et fonctionnement vérifié.

### Création observée

- Première tentative de démarrage : échec `0x800705AA`, Hyper-V ne pouvant pas allouer immédiatement les 4 096 Mo demandés alors que `CC-DC01` est en exécution. Aucun amorçage de l’installateur ni écriture sur le disque n’a eu lieu.
- Mesure corrective retenue : arrêter proprement `CC-DC01` pendant l’installation de Windows 11, conserver 4 096 Mo pour satisfaire les prérequis de l’installateur, puis réduire la mémoire de démarrage du poste après installation afin de permettre l’exécution simultanée du DC et du client.
- Seconde tentative après arrêt annoncé du DC : nouvel échec d’initialisation mémoire `0x8007000E`. Mesure de l’hôte : 11,75 Gio visibles, 2,87 Gio libres et 8,88 Gio utilisés ; une réservation immédiate de 4 096 Mo reste impossible.
- Adaptation retenue pour l’hôte réel : mémoire de démarrage et minimum à 2 048 Mo, maximum à 4 096 Mo, mémoire dynamique activée. Les prérequis Windows 11, dont le TPM virtuel, seront contrôlés avant l’installation ; toute éventuelle dérogation au contrôle de RAM sera limitée à ce laboratoire et documentée.
- Contrôle de compatibilité de l’installateur Windows 11 avec 2 048 Mo : installation bloquée pour deux motifs explicites, TPM 2.0 absent et mémoire système inférieure à 4 Go. Aucune installation n’a commencé. Le TPM virtuel sera activé dans Hyper-V ; seule la contrainte RAM propre à l’hôte limité pourra nécessiter une dérogation de laboratoire.
- TPM virtuel 2.0 activé dans les paramètres de sécurité Hyper-V ; le contrôle suivant de l’installateur ne signale plus que la mémoire inférieure à 4 Go.
- Dérogation limitée appliquée dans l’environnement d’installation : valeur `BypassRAMCheck=1` sous `HKLM\SYSTEM\Setup\LabConfig`. TPM 2.0 et démarrage sécurisé restent activés ; aucun autre contrôle matériel n’a été contourné.
- Installation de Windows 11 terminée jusqu’à l’OOBE, écran de création du compte local. Le compte de secours prévu est `local-admin`, avec le secret correspondant conservé uniquement dans `secrets/initial-passwords.csv`.
- OOBE terminée : ouverture du bureau Windows 11 réussie avec le compte local de secours `local-admin`.
- Configuration matérielle validée avant installation : 2 processeurs virtuels, mémoire dynamique 2 048–4 096 Mo, TPM virtuel activé, démarrage sécurisé Microsoft Windows, points de contrôle de production uniquement, repli standard désactivé et points de contrôle automatiques désactivés.
- Poste renommé `CC-W11-01`, puis redémarré avec succès.
- Configuration IPv4 appliquée : `10.77.10.100/24`, passerelle `10.77.10.1`, DNS préféré `10.77.10.10`, sans DNS auxiliaire.
- Résolution directe validée depuis le client : `cc-dc01.ad.cybercorp.test` retourne `10.77.10.10`. Le message `Serveur : Unknown` correspond à l’absence de zone de recherche inverse et ne bloque pas l’adhésion au domaine.
- Le 14 octobre 2026, nouvelle tentative de démarrage du client alors que le laboratoire et les applications de l’hôte consomment davantage de mémoire : échec `0x8007000E`. L’hôte n’affiche plus que 1,71 Gio libres sur 11,75 Gio.
- Adaptation de coexistence retenue : mémoire de démarrage et minimum du client abaissées à 1 024 Mo, maximum dynamique conservé à 4 096 Mo et tampon réduit. Cette valeur est inférieure au minimum officiellement pris en charge par Windows 11 ; elle est réservée à ce laboratoire contraint et implique des performances réduites.
- Après application du réglage 1 024–4 096 Mo avec tampon de 5 %, `CC-W11-01` démarre simultanément avec `CC-DC01`.
- Le 18 octobre 2026, un nouveau démarrage a échoué avec `0x8007000E` alors que l’hôte ne disposait plus que de 0,59 Gio libres. Les jeux de travail de 28 applications de l’hôte ont été purgés sans fermeture de processus ni perte de données, portant la mémoire libre à environ 2,02 Gio. `CC-W11-01` a ensuite démarré avec 1 024 Mio affectés et l’état Hyper-V `Fonctionnement normal`.
- Depuis la session locale du client, `nltest /dsgetdc:ad.cybercorp.test` réussit et retourne `CC-DC01.ad.cybercorp.test` (`10.77.10.10`) avec les indicateurs PDC, GC, DS, LDAP, KDC, TIMESERV, WRITABLE, DNS_DC, DNS_DOMAIN et DNS_FOREST. L’adhésion et la découverte du domaine sont opérationnelles.
- Une première tentative d’ouverture de session interactive comme administrateur du domaine a été signalée comme refusée. Le test `runas /user:CYBERCORP\Administrateur cmd` effectué depuis le compte local réussit avec le secret `Administrator` et ouvre une invite sous `CYBERCORP\Administrateur`. Le compte, son mot de passe et l’authentification Kerberos sont donc valides ; l’échec initial est attribué à la saisie sur l’écran de connexion.
- Nouvelle ouverture de session interactive réussie sur `CC-W11-01` avec `CYBERCORP\Administrateur`. La commande `whoami` retourne `cybercorp\administrateur`.
- Dans Active Directory, création de l’OU racine protégée `CyberCorp`, puis de l’OU enfant protégée `Postes`.
- L’objet ordinateur `CC-W11-01`, initialement créé dans le conteneur natif `Computers`, a été déplacé dans `OU=Postes,OU=CyberCorp,DC=ad,DC=cybercorp,DC=test` et sa présence y a été vérifiée.
- L’ISO d’installation Windows 11 a été détaché du lecteur DVD virtuel sans supprimer le lecteur.
- Point de contrôle de production créé à chaud puis renommé `Baseline-W11-Domain-2026-10-14` ; la VM est restée en exécution.
- Étape 7 validée : `CC-W11-01` est installé, adressé, joint à `ad.cybercorp.test`, authentifie les comptes du domaine et se trouve dans l’OU `CyberCorp\Postes`.

### Validation

- Date : 14 octobre 2026
- Validation utilisateur : validation progressive par captures et résultats de commandes.
- Preuves ou remarques : paramètres Hyper-V, installation, compte local de secours, adressage, DNS, découverte du DC, authentification de domaine, objet AD et point de contrôle de production vérifiés.

## Étape 8 — Import et confinement de `CC-KALI01`

**État : Validée**

### Cible

- Nom : `CC-KALI01`.
- Génération : 2.
- Mémoire : 2 048 Mo, adaptée ensuite aux contraintes de l’hôte si nécessaire.
- Processeurs virtuels : 2.
- Disque : VHDX Kali Linux 2026.2 préinstallé.
- Réseau : une seule carte sur `CC-AUDIT` ; aucune connexion au `Default Switch`, à `CC-LAN` ou à un commutateur externe.
- Adresse prévue : `10.77.20.50/24`, passerelle `10.77.20.1`, DNS `10.77.10.10` uniquement lorsque les règles pfSense l’autorisent.

### Contrôles

- [x] Archive Kali officielle disponible et contenu inspecté sans exécuter les scripts fournis.
- [x] VHDX extrait dans le stockage CyberCorp et vérifié.
- [x] VM créée avec les paramètres matériels attendus.
- [x] Une seule carte réseau affectée à `CC-AUDIT`.
- [x] Démarrage, identité et adresse réseau vérifiés.
- [x] Identifiants par défaut remplacés par le secret prévu pour `kali`.
- [x] Configuration sauvegardée et confinement vérifié.

### Import observé

- Archive source : `C:\Users\pissa\Downloads\kali-linux-2026.2-hyperv-amd64.7z`.
- Contenu inspecté : `create-vm.ps1`, `install-vm.bat` et `kali-linux-2026.2-hyperv-amd64.vhdx`.
- Le script fourni cible `Default Switch` ; il n’a pas été exécuté afin de préserver l’isolation du laboratoire.
- Seul le VHDX a été extrait et renommé `C:\Users\Public\Documents\Hyper-V\CyberCorp\CC-KALI01\Virtual Hard Disks\CC-KALI01.vhdx`.
- Vérification `Get-VHD` : VHDX dynamique, 16,71 Gio physiques, capacité virtuelle 80,09 Gio, secteurs logiques et physiques de 512 octets.
- VM `CC-KALI01` créée en génération 2 avec le VHDX existant, 2 processeurs virtuels, mémoire dynamique 1 024–2 048 Mo, tampon 10 %, une carte unique sur `CC-AUDIT`, démarrage sécurisé désactivé, TPM/protection désactivés, points de contrôle standard autorisés manuellement et points automatiques désactivés.
- Premier démarrage réussi jusqu’à l’écran de connexion Kali ; la disposition de clavier affichée est `US`.
- Première connexion locale réussie avec le compte Kali préinstallé ; le bureau XFCE s’affiche correctement.
- Le mot de passe initial du compte `kali` a été remplacé avec succès le 16 octobre 2026. Sa valeur n’est pas consignée dans le journal.
- La disposition française a été activée dans la session graphique avec `setxkbmap fr` ; sa persistance après redémarrage reste à valider.
- La persistance du clavier français a été reportée à la demande de l’utilisateur, le réglage de session étant suffisant pour poursuivre.
- Nom d’hôte configuré et vérifié : `cc-kali01`. L’entrée `127.0.1.1 cc-kali01` est présente dans `/etc/hosts`.
- Profil NetworkManager renommé `CC-AUDIT` et configuré en IPv4 statique : `10.77.20.50/24`, passerelle `10.77.20.1`, DNS `10.77.10.10`, IPv6 désactivé. La table de routage et les propriétés du périphérique `eth0` confirment ces valeurs.
- Confinement vérifié : NetworkManager ne présente que `eth0` connecté à `CC-AUDIT` et l’interface locale `lo`. Le test vers `1.1.1.1` échoue avec `Destination Host Unreachable` et 100 % de perte, résultat attendu tant que `CC-PFS01` n’assure aucun routage.
- VM arrêtée proprement et point de contrôle standard `Baseline-Kali-Audit-2026-10-16` créé le 16 octobre 2026.
- Inventaire préalable au nettoyage demandé le 14 octobre 2026 : les anciennes VM arrêtées `CLIENT01`, `DC01` et `PFSENSE01` occupent respectivement 18,24 Gio, 30,10 Gio et 5,70 Gio dans `C:\Users\Public\Documents\Hyper-V\LAB-AD`, soit 54,04 Gio au total.
- Leurs exports distincts existent dans `C:\Users\Public\Documents\Hyper-V\Exports\CyberCorp-PreMigration-2026-10-13` avec les mêmes tailles. Décision proposée : désenregistrer les trois anciennes VM puis supprimer leurs trois dossiers d’origine complets, tout en conservant les exports jusqu’à la recette finale.
- L’archive Kali source de 3,68 Gio est conservée jusqu’au premier démarrage réussi de `CC-KALI01` ; elle ne fait pas encore partie du nettoyage immédiat.
- Incident de nettoyage le 14 octobre 2026 : les trois anciennes VM `CLIENT01`, `DC01` et `PFSENSE01`, leurs dossiers d’origine sous `LAB-AD` et le dossier d’exports `CyberCorp-PreMigration-2026-10-13` ont été supprimés. Les suppressions récentes ne figurent pas dans la Corbeille et les copies de retour arrière de `CLIENT01` et `DC01` ne sont donc plus immédiatement restaurables.
- Contrôle après incident : les actifs actuels `CC-DC01`, `CC-W11-01`, `CC-PFS01` et le VHDX extrait de `CC-KALI01` sont toujours présents. L’espace libre sur `C:` est passé à 237,3 Gio.
- Une ancienne copie distincte de `PFSENSE01`, supprimée le 13 octobre 2026 et totalisant 5,70 Gio, reste dans la Corbeille avec son VHDX. L’utilisateur a explicitement refusé sa restauration afin de ne conserver aucun élément étranger au nouveau projet ; seuls `CC-PFS01`, `CC-DC01`, `CC-W11-01` et `CC-KALI01` sont désormais dans le périmètre.

## Étape 6 — Reconstruction de `CC-DC01`

**État : Validée**

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
- [x] Windows Server 2025 installé.
- [x] Nom `CC-DC01` et adresse `10.77.10.10/24` configurés.
- [x] Second disque de 30 Gio initialisé.
- [x] Rôles AD DS, DNS et fichiers installés.
- [x] Forêt `ad.cybercorp.test` créée et contrôles de santé réussis.
- [x] Configuration sauvegardée et fonctionnement vérifié.

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
- Après redémarrage du service de gestion Hyper-V, `CC-DC01` démarre correctement : l'erreur de partage sur `CC-DC01-DATA.vhdx` a disparu. La VM atteint le microprogramme Hyper-V UEFI et détecte le DVD Windows Server.
- L'écran UEFI affiche `Press any key to boot from CD or DVD`. Plusieurs tentatives de saisie automatisée ont manqué la fenêtre très courte de capture clavier et la VM est passée au démarrage PXE. Aucune écriture d'installation n'a encore eu lieu sur les disques.
- Amorçage DVD finalement validé par l'utilisateur en maintenant une saisie clavier pendant le redémarrage. L'installateur Windows Server 2025 atteint l'écran de sélection d'image.
- Édition retenue pour la suite : **Windows Server 2025 Standard Evaluation (expérience utilisateur)**, afin de disposer de l'interface graphique. Les éditions Server Core et Datacenter ne sont pas retenues pour ce laboratoire.
- Écran de stockage atteint : l'installateur reconnaît `Disque 0` de 80 Go et `Disque 1` de 30 Go, tous deux non alloués. Affectation validée : Windows sera installé sur le disque 0 de 80 Go ; le disque 1 de 30 Go restera non alloué pendant l'installation et sera initialisé ultérieurement comme volume de données.
- Installation terminée jusqu'à l'écran de définition du mot de passe du compte Administrateur intégré.
- Le fichier local ignoré par Git `secrets/initial-passwords.csv` existe. Pour cet écran, l'entrée `Administrator` doit être utilisée. La valeur du secret n'est volontairement ni recopiée dans ce journal ni ajoutée au dépôt. Les entrées `DSRM`, `local-admin` et `admin` restent réservées à leurs usages distincts.
- Windows Server 2025 Standard Evaluation avec expérience utilisateur est installé et le compte Administrateur initial a été configuré. Le Gestionnaire de serveur s'ouvre correctement sur le tableau de bord.
- État initial du serveur local observé : nom temporaire `WIN-8TF2F08DE0P`, appartenance à `WORKGROUP` et interface Ethernet configurée par DHCP. Aucun rôle n'est encore installé.
- Renommage validé après redémarrage : le système invité affiche désormais `CC-DC01`. Il reste temporairement membre de `WORKGROUP` jusqu'à la promotion en contrôleur de domaine.
- Paramètres IPv4 vérifiés avant application : adresse `10.77.10.10`, masque `255.255.255.0`, passerelle `10.77.10.1`, DNS préféré `10.77.10.10`, aucun DNS auxiliaire et validation automatique en quittant désactivée.
- Paramètres IPv4 confirmés après application dans les détails de connexion : DHCP désactivé, `10.77.10.10/24`, passerelle `10.77.10.1`, DNS `10.77.10.10`. Le Gestionnaire de serveur affiche également l'adresse `10.77.10.10` pour l'interface Ethernet.
- Disque de données reconnu comme `Disque 1`, capacité 30 Go. Il a été mis en ligne puis initialisé en GPT ; il reste entièrement non alloué avant la création du volume.
- Volume de données créé avec succès sur le `Disque 1` : lettre `E:`, nom `DATA`, taille 30 Go, système de fichiers NTFS et taille d’unité d’allocation par défaut. Toutes les tâches de l’Assistant Nouveau volume sont indiquées comme terminées.
- Contrôle final dans `Services de fichiers et de stockage > Volumes > Disques` : le `Disque 1` est en ligne, initialisé en GPT, affiche une capacité de 30 Go et `0,00 O` non alloué ; tout l’espace est donc affecté au volume de données.
- Installation des rôles réussie sur `CC-DC01` : Services de domaine Active Directory, Serveur DNS, outils d’administration AD DS/DNS et Gestion de stratégie de groupe. Le service de fichiers de base était déjà présent.
- Le Gestionnaire de serveur affiche désormais les vues `AD DS` et `DNS`. L’avertissement « Configuration requise » confirme que les binaires sont installés mais que le serveur n’est pas encore promu en contrôleur de domaine.
- Un événement DFSR 1202 est visible avant la promotion ; il est conservé comme observation de l’état transitoire et sera réévalué après la création de la forêt et le redémarrage.
- Promotion AD DS effectuée après validation complète des prérequis : nouvelle forêt `ad.cybercorp.test`, nom NetBIOS `CYBERCORP`, niveaux fonctionnels Windows Server 2025, DNS et catalogue global activés, RODC désactivé, délégation DNS non créée et chemins AD DS par défaut conservés.
- Le serveur a redémarré automatiquement et l’ouverture de session avec le compte de domaine `CYBERCORP\Administrateur` a réussi. Le tableau de bord affiche les rôles AD DS, DNS et Services de fichiers et de stockage avec une facilité de gestion opérationnelle.
- Trois alertes de services restent visibles immédiatement après le premier redémarrage ; elles doivent être examinées avant de valider les contrôles de santé de la forêt.
- Examen des trois alertes de services : `cbdhsvc_cddee` (service utilisateur du Presse-papiers), `InventorySvc` (Appraisal Inventory and Compatibility) et `OneSyncSvc_cddee` (hôte de synchronisation) sont arrêtés avec un démarrage automatique différé. Ce sont des services utilisateur déclenchés à la demande ; aucun service critique AD DS, DNS, Netlogon ou DFSR n’est signalé dans cette alerte.
- Vérification dans `Utilisateurs et ordinateurs Active Directory` : le domaine `ad.cybercorp.test` est accessible et expose les conteneurs standards `Builtin`, `Computers`, `Domain Controllers`, `ForeignSecurityPrincipals`, `Managed Service Accounts` et `Users`.
- L’OU `Domain Controllers` contient l’objet ordinateur `CC-DC01`, identifié comme catalogue global (`GC`) dans le site `Default-First-Site-Name`.
- Vérification dans le Gestionnaire DNS : les zones intégrées à Active Directory `_msdcs.ad.cybercorp.test` et `ad.cybercorp.test` sont présentes. Les arborescences `_msdcs`, `_sites`, `_tcp`, `_udp`, `DomainDnsZones` et `ForestDnsZones` ont été créées.
- Premier contrôle `dcdiag /q` après promotion : les tests `DFSREvent` et `SystemLog` signalent des événements produits dans les dernières 24 heures, dont un échec de réplication SYSVOL et un événement Kerberos/SAM généré pendant l’état transitoire suivant la promotion. Le contrôle global n’est donc pas encore validé ; des tests ciblés de l’état actuel de SYSVOL, Netlogon et de la publication du DC sont requis.
- Contrôle ciblé `dcdiag /test:Advertising /test:SysVolCheck /test:NetLogons /q` : aucune sortie d’erreur. Le contrôleur s’annonce correctement, SYSVOL est prêt et Netlogon est opérationnel. Les alertes du contrôle global sont donc des événements historiques récents et non un échec actuel de ces composants.
- Contrôle ciblé `dcdiag /test:DNS /q` : aucune sortie d’erreur. Le service DNS et les enregistrements nécessaires à Active Directory sont opérationnels.
- Conclusion des contrôles de santé : la forêt `ad.cybercorp.test`, le catalogue global, DNS, l’annonce du contrôleur, SYSVOL et Netlogon fonctionnent. Les deux tests de journaux du premier `dcdiag /q` restent documentés comme événements historiques du cycle de promotion et ne correspondent pas à une panne actuelle.
- Point de contrôle de production créé à chaud puis renommé `Baseline-ADDS-DNS-2026-10-13`. La VM est restée en exécution. Ce point constitue un retour arrière pratique pour le laboratoire, sans être considéré comme une sauvegarde Active Directory.
- Étape 6 validée : `CC-DC01` est opérationnel avec Windows Server 2025, le volume `DATA (E:)`, AD DS, DNS, les services de fichiers de base et la forêt `ad.cybercorp.test`.
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

- Date : 13 octobre 2026.
- Validation utilisateur : validation progressive par captures et résultats de commandes.
- Preuves ou remarques : Windows Server 2025, volume de données, AD DS, DNS, forêt `ad.cybercorp.test`, SYSVOL, Netlogon, authentification et point de contrôle `Baseline-ADDS-DNS-2026-10-13` vérifiés.

## Étape 9 — Configuration réseau, domaine et comptes

**État : En cours**

### DNS

- Le 18 octobre 2026, l'inventaire DNS confirme que les zones directes `_msdcs.ad.cybercorp.test` et `ad.cybercorp.test` sont intégrées à Active Directory et utilisent uniquement les mises à jour dynamiques sécurisées.
- La zone inverse IPv4 `10.77.10.in-addr.arpa` a été créée pour le réseau `10.77.10.0/24`. Elle est primaire, intégrée à Active Directory, répliquée à l'échelle du domaine et configurée avec `DynamicUpdate: Secure`.
- Les enregistrements directs existants ont été contrôlés : `cc-dc01.ad.cybercorp.test` pointe vers `10.77.10.10` et `cc-w11-01.ad.cybercorp.test` vers `10.77.10.100`.
- Deux enregistrements PTR ont été créés et résolus avec succès par `10.77.10.10` : `10.77.10.10` vers `cc-dc01.ad.cybercorp.test` et `10.77.10.100` vers `cc-w11-01.ad.cybercorp.test`, avec un TTL observé de 3 600 secondes.
- L'enregistrement SRV `_ldap._tcp.dc._msdcs.ad.cybercorp.test` a été résolu avec succès : cible `cc-dc01.ad.cybercorp.test`, priorité 0, poids 100, port LDAP 389, avec l'adresse additionnelle `10.77.10.10`.

### Organisation Active Directory

- Inventaire initial de l'arborescence : `OU=CyberCorp` et son enfant `OU=Postes` existent et sont protégées contre la suppression accidentelle. Le contrôleur `CC-DC01` demeure dans l'OU native `Domain Controllers`, conformément à la conception. Les OU `Utilisateurs`, `Groupes`, `Admins`, `Tests` et `Desactives` restent à créer sous `CyberCorp`.
- Les OU de premier niveau `Utilisateurs`, `Groupes`, `Admins`, `Tests` et `Desactives` ont été créées sous `OU=CyberCorp`. Avec `Postes`, les six OU enfants directes sont présentes et protégées contre la suppression accidentelle.
- Les sous-OU métiers `Direction`, `RH`, `Finance`, `Commercial`, `Technique` et `Informatique` ont été créées sous `OU=Utilisateurs` et protégées contre la suppression accidentelle.
- Inventaire préalable des groupes de sécurité : aucun groupe dont le `sAMAccountName` commence par `GG_` ou `DL_` n'existait avant la mise en œuvre du modèle AGDLP.
- Sept groupes globaux de sécurité ont été créés dans `OU=Groupes` : `GG_DIRECTION`, `GG_RH`, `GG_FINANCE`, `GG_COMMERCIAL`, `GG_TECHNIQUE`, `GG_IT` et `GG_TOUS`. Leur portée `Global` et leur catégorie `Security` ont été vérifiées.
- Huit groupes locaux de domaine de catégorie Sécurité ont été créés dans `OU=Groupes` pour porter les permissions : `DL_COMMUN_READ`, `DL_COMMUN_MODIFY`, `DL_FINANCE_MODIFY`, `DL_RH_MODIFY`, `DL_CLIENTS_MODIFY`, `DL_TECH_MODIFY`, `DL_SYNTHESES_READ` et `DL_SYNTHESES_MODIFY`.
- Les six groupes globaux métier (`GG_DIRECTION`, `GG_RH`, `GG_FINANCE`, `GG_COMMERCIAL`, `GG_TECHNIQUE` et `GG_IT`) ont été imbriqués dans `GG_TOUS`; l'appartenance a été vérifiée.
- Les correspondances AGDLP ont été appliquées et vérifiées : `GG_TOUS` vers `DL_COMMUN_READ`, `GG_IT` vers `DL_COMMUN_MODIFY`, `GG_FINANCE` vers `DL_FINANCE_MODIFY`, `GG_RH` vers `DL_RH_MODIFY`, `GG_COMMERCIAL` vers `DL_CLIENTS_MODIFY`, `GG_TECHNIQUE` vers `DL_TECH_MODIFY` et `GG_DIRECTION` vers `DL_SYNTHESES_READ`. `DL_SYNTHESES_MODIFY` reste volontairement vide en attente d'un responsable désigné.
- L'inventaire préalable des comptes confirme qu'aucun objet utilisateur dont le `sAMAccountName` commence par `usr.`, `adm.ad` ou `tst.` n'existe encore dans le domaine.
- Le script `scripts/provision-ad-users.ps1` a été préparé pour créer les 29 comptes prévus par `config/comptes.csv` à partir du fichier local de secrets ignoré par Git. Il valide toutes les sources et dépendances avant mutation, ne journalise aucun mot de passe, place les comptes dans leurs OU, applique les groupes globaux métier et laisse les deux comptes de test désactivés.
- Le provisionnement a été exécuté avec succès sur `CC-DC01` : 29 comptes créés, aucun compte préexistant, 25 appartenances aux groupes globaux métier ajoutées, 27 comptes actifs et 2 comptes de test désactivés. Aucun mot de passe n'a été affiché par le script.
- Après le provisionnement, la copie temporaire `C:\CyberCorp-Provisioning\initial-passwords.csv` a été supprimée de `CC-DC01`. Le fichier source demeure uniquement dans le répertoire local `secrets/`, exclu du suivi Git. Aucun point de contrôle n'a été créé avec cette copie sensible présente dans la VM.
- Le contrôle de placement et d'état des comptes est conforme : `Admins` contient 2 comptes actifs ; les OU `Direction`, `RH`, `Finance`, `Commercial`, `Technique` et `Informatique` contiennent respectivement 2, 3, 3, 7, 8 et 2 comptes actifs ; `Tests` contient les 2 comptes désactivés. Le contrôle `Test-Path` de la copie temporaire des secrets a retourné `False`.
- Le contrôle des appartenances directes est conforme : `GG_COMMERCIAL`, `GG_DIRECTION`, `GG_FINANCE`, `GG_IT`, `GG_RH` et `GG_TECHNIQUE` contiennent respectivement 7, 2, 3, 2, 3 et 8 comptes utilisateur, sans groupe enfant ; `GG_TOUS` ne contient aucun utilisateur direct et contient les six groupes métier attendus.
- Les comptes dédiés `adm.ad01` et `adm.ad02` appartiennent uniquement au groupe primaire `Utilisateurs du domaine` (SID terminé par `-513`). Aucun groupe d'administration privilégié ne leur a été attribué à ce stade.

### Partages et permissions

- L'inventaire initial confirme que le volume `E:` porte le nom `DATA`, utilise NTFS, est sain et offre environ 30 Go libres. Le chemin `E:\Partages` n'existe pas encore.
- Aucun partage métier n'existe avant la mise en œuvre. Seuls les partages système et administratifs natifs `ADMIN$`, `C$`, `E$`, `IPC$`, `NETLOGON` et `SYSVOL` sont présents.
- Le chemin de conception `D:\Partages` est adapté à l'installation réelle : les ressources seront créées sous `E:\Partages`, sur le volume de données dédié observé.
- L'arborescence `E:\Partages` a été créée avec les six dossiers attendus : `Clients`, `Commun`, `Finance`, `RH`, `Syntheses` et `Technique`. Aucun de ces dossiers n'est encore publié par SMB à ce stade.
- Les ACL NTFS ont été appliquées par `scripts/configure-share-ntfs-acl.ps1`. Les sept chemins sont protégés contre l'héritage et ne contiennent aucune règle héritée. La racine possède 2 règles ; `Commun` et `Syntheses` en possèdent 4 ; `Finance`, `RH`, `Clients` et `Technique` en possèdent 3. Le script confirme qu'aucun partage SMB n'a été créé pendant cette opération.
- Le détail des ACL NTFS a été contrôlé : `AUTORITE NT\Système` et `BUILTIN\Administrateurs` disposent du contrôle total ; les groupes `DL_*_MODIFY` disposent de `Modify` sur leur seule ressource ; `DL_COMMUN_READ` et `DL_SYNTHESES_READ` disposent de `ReadAndExecute` sur leur ressource. Toutes les règles observées sont non héritées et aucune identité générique (`Everyone`, `Utilisateurs` ou `Utilisateurs authentifiés`) n'est présente.
- Les six partages SMB `Commun`, `Finance`, `RH`, `Clients`, `Technique` et `Syntheses` ont été créés par `scripts/create-smb-shares.ps1` vers les dossiers correspondants sous `E:\Partages`. L'énumération basée sur l'accès est active, le cache hors connexion est désactivé, `Commun` et `Syntheses` possèdent 3 règles de partage et les quatre autres ressources en possèdent 2. Le script a contrôlé les identités, niveaux d'accès et absences de règles supplémentaires.
- L'export indépendant de `Get-SmbShareAccess` confirme la matrice de partage : `BUILTIN\Administrateurs` possède `Full`, chaque groupe `DL_*_MODIFY` concerné possède `Change`, `DL_COMMUN_READ` et `DL_SYNTHESES_READ` possèdent `Read`, toutes les entrées sont de type `Allow` et aucune permission `Everyone` n'est présente.
- Un fichier `_DONNEES-FICTIVES.txt`, explicitement identifié comme contenu de laboratoire sans donnée réelle ni secret, a été créé dans chacune des six ressources afin de préparer les tests fonctionnels de lecture, modification et refus depuis le poste client.
- Avant le démarrage du client pour les tests SMB, la mémoire libre de l'hôte n'était que de 1,47 Gio avec `CC-DC01` et `CC-PFS01` actifs. Le client est configuré avec une mémoire dynamique de 1 024 à 4 096 Mio. pfSense n'étant pas nécessaire aux flux DC-client sur le même segment `CC-LAN`, `CC-PFS01` a été placé temporairement dans l'état Hyper-V `Saved`, sans arrêt brutal ; la mémoire libre est alors remontée à 2,48 Gio. Kali demeure arrêtée.
- Après fermeture de l'outil de capture inutilisé sur l'hôte, la mémoire libre a atteint 2,76 Gio. `CC-W11-01` a ensuite démarré avec 1 024 Mio affectés ; la mémoire libre réelle de l'hôte est restée à 1,65 Gio, au-dessus de la marge minimale de 1,5 Gio. État du profil : DC et client actifs, pfSense enregistré, Kali arrêtée.
- Une première tentative de connexion de `usr.fin01` via la session améliorée Hyper-V a été refusée, car ce mode s'appuie sur RDP et le compte métier ne possède volontairement pas le droit d'ouverture de session Bureau à distance. Aucun droit RDP n'a été ajouté ; la console a été repassée en session standard.
- L'ouverture de session locale standard sur `CC-W11-01` a réussi avec `CYBERCORP\usr.fin01`. La commande `whoami` a retourné `cybercorp\usr.fin01`, confirmant l'identité utilisée pour la recette ACL.
- Test positif Finance : depuis `CC-W11-01`, `usr.fin01` a créé `\\CC-DC01\Finance\T08_usr.fin01.txt` puis l'a relu avec succès. Le contenu relu indique explicitement `cybercorp\usr.fin01`, ce qui valide l'accès effectif en modification du groupe Finance.
- Test négatif interservice : depuis la même session, la lecture de `\\CC-DC01\Clients\_DONNEES-FICTIVES.txt` par `usr.fin01` a été refusée comme attendu. Finance ne reçoit donc pas d'accès au partage Commercial.
- Test du partage commun : `usr.fin01` a lu `\\CC-DC01\Commun\_DONNEES-FICTIVES.txt` avec succès, mais la tentative de créer `T08_usr.fin01-interdit.txt` a été refusée. L'accès indirect via `GG_FINANCE` → `GG_TOUS` → `DL_COMMUN_READ` est donc effectif en lecture seule ; le droit de modification reste réservé à l'IT.
- Le contre-test complémentaire prévu par la conception (`usr.com01` refusé sur `Finance`) est volontairement reporté à la recette T08/T09 afin d'éviter de multiplier les changements de session à ce stade. Il ne doit pas être déclaré exécuté avant sa réalisation effective.

### Stratégies de groupe

- L'inventaire initial des GPO confirme que seules `Default Domain Policy` et `Default Domain Controllers Policy` existent. Les deux stratégies ont tous leurs paramètres activés ; aucune GPO CyberCorp personnalisée n'est encore créée.
- Les liaisons initiales ont été contrôlées : `Default Domain Policy` est directement liée à la racine `DC=ad,DC=cybercorp,DC=test` et héritée par les OU examinées ; `Default Domain Controllers Policy` est directement liée à l'OU native `Domain Controllers`. `OU=Postes` et `OU=Tests` ne possèdent encore aucune liaison directe. Les stratégies natives seront conservées sans déplacement.
- La GPO `CC-Domaine-Comptes` a été créée puis liée à la racine du domaine avec la priorité 1, active et non forcée. `Default Domain Policy` passe à l'ordre 2. La nouvelle GPO est encore vide à ce stade ; aucune politique de compte n'a donc encore changé.
- Dans `CC-Domaine-Comptes`, la stratégie de mot de passe a été configurée avec une longueur minimale de 14 caractères, la complexité activée et un historique de 24 mots de passe. Les durées de vie, le chiffrement réversible, l'audit de longueur et l'assouplissement de la limite restent non définis.
- La stratégie de verrouillage a été configurée à 5 échecs, pour une durée de 15 minutes, avec remise à zéro du compteur après 15 minutes. Le verrouillage du compte Administrateur reste non défini. L'application effective sur le domaine reste à vérifier.
- Après `gpupdate /target:computer /force`, la mise à jour est annoncée sans erreur, mais `Get-ADDefaultDomainPasswordPolicy` retourne encore la politique antérieure : complexité active, longueur minimale 8, historique 20 et seuil de verrouillage 0. Les durées de verrouillage et d'observation affichent 15 minutes, mais le seuil nul désactive le mécanisme. La GPO ne doit donc pas être déclarée effective avant diagnostic et correction.
- Le diagnostic par `Get-GPOReport -ReportType Xml` a confirmé que les premières modifications n'avaient pas été enregistrées dans la GPO : elle contenait encore une longueur minimale de 8 caractères, un historique de 20 mots de passe et aucun paramètre de verrouillage. Les paramètres ont été repris dans l'éditeur en validant chaque boîte de dialogue avec **Appliquer**, puis **OK**.
- Après fermeture et réouverture de l'éditeur, la stratégie de mot de passe affiche bien 14 caractères, la complexité activée et 24 mots de passe mémorisés ; les durées de vie minimale et maximale restent non définies dans `CC-Domaine-Comptes`. La stratégie de verrouillage affiche un seuil de 5 tentatives, une durée de 15 minutes et une remise à zéro après 15 minutes ; le verrouillage du compte Administrateur reste non défini.
- Un nouveau rapport XML de la GPO confirme les six valeurs réellement enregistrées : `MinimumPasswordLength=14`, `PasswordComplexity=true`, `PasswordHistorySize=24`, `LockoutBadCount=5`, `LockoutDuration=15` et `ResetLockoutCount=15`.
- Après une nouvelle exécution réussie de `gpupdate /target:computer /force`, `Get-ADDefaultDomainPasswordPolicy` confirme l'application effective : complexité active, longueur minimale 14, historique 24, verrouillage après 5 échecs, durée de verrouillage 15 minutes et fenêtre d'observation 15 minutes. Les âges minimal et maximal restent respectivement de 1 et 42 jours, valeurs héritées de la stratégie de domaine existante et volontairement non redéfinies dans `CC-Domaine-Comptes`.
- La GPO vide `CC-Postes-Securite` a ensuite été créée et liée directement à `OU=Postes,OU=CyberCorp,DC=ad,DC=cybercorp,DC=test`. La liaison est active, non forcée et placée à l'ordre 1 ; aucune configuration n'a encore été appliquée au poste à ce stade.
- Audit T10 exécuté le 20 octobre 2026 à 12:13:44 avec GPOZaurr 1.1.13, installé hors ligne sur `CC-DC01` avec ses dépendances. Le rapport est produit en lecture seule dans `C:\Audit\T10\GPOZaurr-CC-DC01.html`, avec l'inventaire `C:\Audit\T10\Inventaire-GPO.csv`.
- Le contrôle « Broken / Orphaned Group Policies » ne relève aucun écart : 0 GPO présente dans SYSVOL mais absente d'AD, 0 GPO AD sans contenu SYSVOL, 0 objet de classe inattendue et 0 GPO non évaluée faute de permission. Le domaine `ad.cybercorp.test` ne requiert aucune action pour cette catégorie.
- L'inventaire GPO confirme que `CC-Domaine-Comptes`, `CC-Postes-Securite`, `Default Domain Controllers Policy` et `Default Domain Policy` existent dans AD et SYSVOL ; les quatre stratégies sont actives. Aucune commande corrective GPOZaurr n'a été exécutée.
- Les artefacts sont hachés SHA-256 : rapport HTML `C2D2F3A095CA3F9FFDBAFAC8599D60041569955230E0DA541117849AEA7571BE0` ; inventaire CSV `4228BF6DE331E69892CFF3ACF7B1D4D12115D0325052D7FA152321901AEFCF2B`.

### Durcissement du poste et télémétrie T12–T13

- La GPO `CC-Postes-Securite` a été configurée puis appliquée à `CC-W11-01`, situé dans `OU=Postes`. Elle conserve Microsoft Defender et sa protection en temps réel actifs (les paramètres de désactivation sont eux-mêmes définis à `Désactivé`), impose un verrouillage après 600 secondes, désactive les ouvertures de session invité SMB non sécurisées et refuse aux administrateurs du domaine l'ouverture de session locale ou via les services Bureau à distance sur le poste.
- Le contre-test de connexion locale avec `CYBERCORP\Administrateur` a été refusé comme prévu. Le compte local de secours `CC-W11-01\local-admin` reste disponible pour l'administration de secours.
- Après `gpupdate /force`, le rapport `C:\Preuves\T10_gpresult-poste.html` confirme l'application de `CC-Postes-Securite`, `CC-Domaine-Comptes` et `Default Domain Policy` au poste. Le pare-feu est actif sur les profils Domaine, Privé et Public ; Defender et la protection en temps réel sont actifs ; `SMB1Protocol` est désactivé.
- Un point de contrôle Hyper-V `Baseline-W11-PostGPO-2026-10-19` a été créé sous le point de contrôle de référence du poste avant le déploiement de Sysmon.
- Sysmon autonome Sysinternals v15.22 a été déployé uniquement sur `CC-W11-01`, avec `config/sysmon-restricted.xml`. La configuration limite la création de processus à PowerShell, CMD et `whoami`, les connexions réseau à `10.77.10.10`, et journalise les changements d'heure de création de fichier. Le service `Sysmon64` est en démarrage automatique et était en cours d'exécution lors du test.
- Le scénario contrôlé a produit les événements Sysmon attendus : création du processus `whoami.exe` (ID 1), connexion TCP/445 vers `CC-DC01` (ID 3) et changement d'heure de création du fichier de preuve (ID 2). Le test ID 2 vise `C:\Preuves\T12-Sysmon\test-horodatage-20261020-101417.txt`, déclenché par `powershell.exe` sous `CC-W11-01\local-admin` le 20 octobre 2026 à 08:14:53 UTC.
- L'export final `C:\Preuves\T12-Sysmon\CC-W11-01_Sysmon_Operational_final.evtx` a été créé et haché SHA-256 : `B83A2BAF2D61F7E60915D0F95788557C0A984A39B969FF5302F1DEF2595955A1`.
- Hayabusa v4.2.0 a analysé cet export EVTX hors ligne avec le paquet DFIR complet et ses règles locales. La chronologie `C:\Preuves\T12-Sysmon\Hayabusa_T12_Sysmon_timeline_dfir.csv` a été générée (1 014 030 octets) et hachée SHA-256 : `60B24457DC5988B2C92BB2649B9228CA024FAA6C2B0644F607274F6E2B9CD6C5`.
- La recherche textuelle dans cette chronologie retrouve le fichier contrôlé et l'associe à la règle `Sysmon_2_Low_PossibleTimestomping.yml`, au canal Sysmon et à l'ID 2. Cette détection est classée faible et constitue la trace attendue du scénario pédagogique ; elle ne doit pas être interprétée isolément comme une compromission.
- L'édition d'évaluation de Windows 11 a provoqué un arrêt automatique du poste après l'analyse. Les artefacts EVTX et CSV avaient déjà été écrits et ont été vérifiés après le redémarrage ; cet arrêt ne modifie pas leurs empreintes consignées ci-dessus.

## Étape 10 — Recette de sécurité T01–T15

**État : En cours**

### Scénario S01 — Nmap/Ndiff

- Le 20 octobre 2026, le scénario a été exécuté depuis `CC-KALI01` (`10.77.20.50`) vers l'unique contrôleur de domaine `CC-DC01` (`10.77.10.10`). Seules les VM `CC-PFS01`, `CC-DC01` et `CC-KALI01` étaient nécessaires ; le WAN de pfSense est resté déconnecté et `CC-W11-01` n'a pas été utilisé.
- Le périmètre a été limité à TCP `53`, `88`, `389` et `445`, sans découverte de réseau, script Nmap ni autre cible. La commande de mesure est `nmap -n -Pn -sT -p 53,88,389,445 -oA <prefixe> 10.77.10.10`.
- La mesure de référence a retourné les quatre ports à l'état `filtered`, conformément à `BASELINE - Bloquer et journaliser AUDIT`.
- Quatre règles pfSense temporaires, placées au-dessus de la règle de blocage sur l'interface `AUDIT`, ont été créées avec journalisation : TCP `53`, `88`, `389` et `445`, source `10.77.20.50`, destination `10.77.10.10`. Avec ces seules autorisations, le même scan a retourné les quatre ports à l'état `open`.
- Les artefacts bruts ont été extraits sans flux réseau vers `preuves/S01/artifacts/` sur l'hôte, dossier local exclu de Git : `temporary-pass.xml`, `blocked-restored.xml`, `ndiff-blocked-vs-pass.txt` et `S01-SHA256SUMS.txt`. Le préfixe initial `baseline-blocked` a été réutilisé par erreur pendant le scan autorisé ; il ne constitue donc pas une preuve de blocage et est remplacé par `blocked-restored`.
- Les empreintes SHA-256 vérifiées après extraction sont : `temporary-pass.xml` : `9FC0AFDA20F7B50BE6896013D0EA19441B7C101B2867C751946CC31F1A2083D6` ; `blocked-restored.xml` : `2506FB01CE9074FED400D696877B06D51C3F666F3ACEA4973C089FA1C344E68F` ; `ndiff-blocked-vs-pass.txt` : `34DC3E1B93FE1A79D2D5FCF2C71AA417BDAEAC90E20C83C6854A02819C1B50EB`.
- Les quatre règles temporaires ont été supprimées, sans modifier la règle de référence. Le contre-test enregistré dans `blocked-restored.xml` retourne à nouveau `filtered` pour les ports `53`, `88`, `389` et `445`.
- La commande `ndiff ~/s01-ndiff/blocked-restored.xml ~/s01-ndiff/temporary-pass.xml` confirme, pour chacun des quatre ports, la différence attendue : `filtered` dans l'état bloqué et `open` lorsque les règles temporaires étaient actives.
