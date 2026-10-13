# Journal de déploiement CyberCorp

Ce journal conserve les étapes réalisées et validées avec l'utilisateur. Une étape n'est marquée **Validée** qu'après confirmation explicite de l'utilisateur.

## État des étapes

| Étape | Objet | État |
| --- | --- | --- |
| 1 | Inventaire initial et décision de conservation | Validée |
| 2 | Sauvegarde/export des VM existantes | En cours |
| 3 | Contrôle et création des commutateurs Hyper-V | À faire |
| 4 | Décision de réutilisation pour chaque VM | À faire |
| 5 | Adaptation ou reconstruction de `CC-PFS01` | À faire |
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

**État : En cours**

### Objectif

Créer une copie récupérable de `CLIENT01`, `DC01` et `PFSENSE01` avant de modifier les commutateurs, les noms ou les configurations des VM.

### Contrôles préalables

- [x] État de chaque VM confirmé dans le Gestionnaire Hyper-V.
- [ ] Toutes les VM arrêtées proprement avant l'export.
- [ ] Dossier de destination et espace libre confirmés.
- [ ] Export des trois VM terminé sans erreur.
- [ ] Contenu des exports vérifié.

### État observé avant export

Capture fournie par l'utilisateur le 13 octobre 2026 :

- `CLIENT01` : **Désactivé**.
- `DC01` : **Désactivé**.
- `PFSENSE01` : **Exécution**, 1 024 Mo de mémoire affectée et 0 % de processeur au moment de la capture.
- La vue des points de contrôle de `CLIENT01` affiche `Point de contrôle automatique - CLIENT01 - (08/10/2026 - 09:00:43)`, puis `Labo AD fonctionnel`, suivis de l'état `Maintenant`.
- Prochaine action : arrêter proprement `PFSENSE01` avant tout export. Ne pas employer l'action brutale **Désactiver**.

### Validation

- Date : —
- Validation utilisateur : —
- Preuves ou remarques : —
