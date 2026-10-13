# CyberCorp

Laboratoire pédagogique Windows sécurisé pour une PME fictive de 25 personnes. Ce dépôt prépare la construction décrite dans le [dossier de conception](CyberCorp_Dossier_Conception.pdf) ; aucune VM, règle de pare-feu ou configuration de l’hôte n’a encore été déployée par ce dépôt.

## Démarrage

1. Lire [l’architecture et les règles de confinement](docs/architecture.md) avant de créer les commutateurs Hyper-V.
2. Vérifier que les trois sous-réseaux proposés dans [l’inventaire](config/infrastructure.csv) ne chevauchent pas le réseau personnel, Tailscale, WSL, Docker ou un VPN. En cas de conflit, modifier les adresses dans le dépôt **avant** l’installation.
3. Importer les identifiants initiaux de `secrets/initial-passwords.csv` dans un gestionnaire de mots de passe, puis supprimer la copie CSV locale dès que l’import est vérifié. Ce fichier est ignoré par Git mais se trouve dans un dossier OneDrive. Changer les secrets après leur première utilisation, en particulier les comptes d’administration. Si le fichier manque avant le déploiement, le recréer avec `python scripts/generate_initial_passwords.py` ; le script refuse d’écraser un fichier existant. Ne pas utiliser ces valeurs pour un système réel.
4. Construire les VM hors ligne, puis suivre la séquence du dossier de conception (p. 10). La carte WAN de pfSense doit rester déconnectée pendant les exercices d’audit.

## Repères

| VM | Rôle | Adresse principale | RAM | Commutateur principal |
| --- | --- | --- | --- | --- |
| `CC-PFS01` | pfSense, pare-feu et routeur | `10.77.10.1/24` (LAN), `10.77.20.1/24` (AUDIT), `172.31.250.2/24` (WAN maintenance) | 1 Go | `CC-LAN`, `CC-AUDIT`, `CC-WAN-MAINT` |
| `CC-DC01` | Windows Server 2025, AD DS, DNS, fichiers | `10.77.10.10/24` | 4 Go | `CC-LAN` |
| `CC-W11-01` | Windows 11 Pro, poste métier | `10.77.10.100/24` | 4 Go | `CC-LAN` |
| `CC-KALI01` | Kali Linux, audit contrôlé | `10.77.20.50/24` | 2 Go | `CC-AUDIT` |

Domaine : `ad.cybercorp.test` ; NetBIOS : `CYBERCORP`. Les comptes à créer figurent dans [config/comptes.csv](config/comptes.csv). Les adresses, passerelles et DNS détaillés figurent dans [config/infrastructure.csv](config/infrastructure.csv). Ce sont des **valeurs de conception**, à vérifier sur l’hôte avant déploiement.

## Entreprise fictive et site vitrine

- [Fiche d’entreprise et identité visuelle](docs/entreprise.md) : mission, offres fictives, valeurs et charte de marque.
- [Organigramme](docs/organigramme.md) : 25 personnages fictifs associés aux 25 comptes métier du laboratoire.
- [Site vitrine](website/dist/index.html) : pages statiques responsive, logo SVG dans `website/dist/assets/`, et manifeste d’hébergement dans `website/.openai/hosting.json`.

Le site précise qu’il s’agit d’une entreprise fictive et ne collecte aucune donnée. Pour un aperçu local : `python -m http.server 8765 --directory website/dist`, puis ouvrir `http://127.0.0.1:8765/`. `site/` est une copie locale de publication ignorée par Git ; les modifications durables se font dans `website/`.

Version hébergée privée : [CyberCorp — site vitrine](https://cybercorp-vitrine.fabled-haven-3189.chatgpt.site).

Le [tableau de bord du projet](https://cybercorp-vitrine.fabled-haven-3189.chatgpt.site/tableau-de-bord) affiche le dernier relevé de l’hôte, les VM, les commutateurs et l’avancement. Voir le [guide de collecte](docs/suivi-site.md) pour le fonctionnement, les droits Hyper-V et l’actualisation automatique.

## Statut

- [x] Noms, rôles, profils mémoire et plan IP documentés
- [x] Comptes et secrets initiaux proposés localement
- [ ] Compatibilité des sous-réseaux et capacité hôte vérifiées
- [ ] VM et règles pfSense créées
- [ ] Recette T01–T15 exécutée et preuves conservées

Les fichiers DOCX et PDF à la racine sont des documents sources non suivis par Git. Leur contenu n’est pas modifié ici.
