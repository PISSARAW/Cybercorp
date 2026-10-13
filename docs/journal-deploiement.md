# Journal de déploiement CyberCorp

Ce journal conserve les étapes réalisées et validées avec l'utilisateur. Une étape n'est marquée **Validée** qu'après confirmation explicite de l'utilisateur.

## État des étapes

| Étape | Objet | État |
| --- | --- | --- |
| 1 | Inventaire initial et décision de conservation | Validée |
| 2 | Sauvegarde/export des VM existantes | Validée |
| 3 | Contrôle et création des commutateurs Hyper-V | Validée |
| 4 | Décision de réutilisation pour chaque VM | Validée |
| 5 | Adaptation ou reconstruction de `CC-PFS01` | En cours |
| 6 | Adaptation ou reconstruction de `CC-DC01` | À faire |
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

- [ ] VM créée avec les paramètres matériels attendus.
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

### Validation

- Date : —
- Validation utilisateur : —
- Preuves ou remarques : —
