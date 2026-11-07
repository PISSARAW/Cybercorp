# CyberCorp

Infrastructure Windows de CyberCorp, société de conseil de 25 collaborateurs. Ce dépôt rassemble le [dossier de conception](CyberCorp_Dossier_Conception.pdf), la configuration, le journal de déploiement, les contrôles de sécurité et les preuves de validation. Le périmètre Hyper-V est opérationnel ; la recette complète et le mandat M-CLIENT-01 restent à clôturer.

## Démarrage

1. Lire [l’architecture et les règles de confinement](docs/architecture.md) avant toute modification des commutateurs Hyper-V.
2. Vérifier que les trois sous-réseaux de [l’inventaire](config/infrastructure.csv) ne chevauchent pas le réseau personnel, Tailscale, WSL, Docker ou un VPN. En cas de conflit, documenter les écarts et adapter les adresses avant une nouvelle intervention.
3. Importer les identifiants initiaux de `secrets/initial-passwords.csv` dans un gestionnaire de mots de passe, puis supprimer la copie CSV locale dès que l’import est vérifié. Ce fichier est ignoré par Git mais se trouve dans un dossier OneDrive. Changer les secrets après leur première utilisation, en particulier les comptes d’administration. Si le fichier manque avant le déploiement, le recréer avec `python scripts/generate_initial_passwords.py` ; le script refuse d’écraser un fichier existant. Ne pas utiliser ces valeurs pour un système réel.
4. Pour une reconstruction, préparer les VM hors ligne puis suivre la séquence du dossier de conception (p. 10). La carte WAN de pfSense doit rester déconnectée pendant les exercices d’audit.

## Mission de sécurité en cours

**Archivage C12/WAN du 7 novembre :** [trois pièces ajoutées et contrôlées](docs/archivage-c12-wan-2026-11-07.md). Le registre actif compte désormais 22 lignes sans doublon, avec 22 fichiers conformes. Le dernier export C12 et les deux captures pfSense sont archivés ; les fichiers Kali restent à rapatrier.

**Mise à jour du 7 novembre 2026 :** [registre réconcilié](docs/reconciliation-registre-2026-11-07.md). Le consolidé existant reprend exactement les 7 lignes historiques et les 12 inscriptions récentes ; il est désormais actif. Les 19 fichiers, tailles et SHA-256 concordent, sans doublon. L'écart de registre décrit dans le bilan historique ci-dessous est résolu ; les autres tâches de clôture restent ouvertes.

CyberCorp doit répondre à une demande client tout en maîtrisant une exception d'audit et en qualifiant un signal sur un poste. Le résultat attendu est un dossier de décision : qui a autorisé quoi, quels accès ont réellement changé, ce qui a été observé, ce qui a été refermé et ce qui demeure incertain. Le [mandat métier M-CLIENT-01](docs/mission-securite.md) donne le cas opérationnel ; le [plan d'outillage](docs/outillage-securite.md) répartit le travail entre Nmap/Ndiff, Sysmon, Hayabusa, GPOZaurr et Conftest/OPA.

Les nouveaux exports suivent le [protocole de chaîne de preuves](docs/protocole-preuves.md) : coffre local hors OneDrive, noms uniques, registre, empreintes SHA-256 et relecture des extraits avant remise.

Les preuves communiquées pendant la construction pas à pas sont inventoriées dans [docs/preuves-conversation](docs/preuves-conversation/README.md). Cet inventaire distingue les sorties textuelles et transcriptions expurgées des originaux numériques conservés selon le protocole.

**État au 6 novembre 2026, reprise du soir :** les pièces M03 avant/après et GPOZaurr/C05 sont conservées. [C07–C09](docs/controle-gpo-clients.md) documentent les droits Clients, une création/lecture réussie sous `usr.com01` et un refus d'écriture sous `usr.fin02`. [M02 et C10–C12](docs/controle-topologie.md) ajoutent un PASS réel, cinq refus attendus et la concordance du WAN pfSense sans porteuse avec sa carte Hyper-V déconnectée. Les empreintes des huit nouvelles pièces sous `brut` ont été revérifiées ; les contrôles du registre annoncés en séance étaient conformes. **Écart à réconcilier : le registre accessible lors de la documentation ne contient que sept lignes anciennes du 1er novembre.** Les 43 captures du lot sont vérifiées et retirées du dossier OneDrive ; les bruts restent hors Git. Le dernier export C12 de `21:03:11 UTC` reste dans `transfert`, sans inscription ni nouveau test Conftest confirmés. Le scan Nmap déjà réalisé donne quatre ports sans réponse, sans disponibilité du DC démontrée pendant la mesure ; aucune nouvelle autorisation n'est documentée. C06, qualification GPO, licence du DC et décision de remise restent ouverts. Dernier relevé VM à `19:47:50 UTC` : pfSense/Kali actifs, DC/W11 arrêtés, 0,58 Gio libres. Voir le [bilan de reprise](docs/journal-deploiement.md#reprise-20261106-soir) et le [guide actualisé](docs/plan-cloture-2026-11-05.md).

Le [guide de clôture du 5 novembre](docs/plan-cloture-2026-11-05.md) détaille l'ordre de travail, les profils de VM, la recette T01–T15, les 26 captures, les preuves et les dépendances. L'[annexe technique M-CLIENT-01](docs/annexe-technique-m-client-01.md) rassemble les constats, les pièces vérifiées, leurs limites et les écarts encore ouverts pour la décision.

## Repères

| VM | Rôle | Adresse principale | RAM | Commutateur principal |
| --- | --- | --- | --- | --- |
| `CC-PFS01` | pfSense, pare-feu et routeur | `10.77.10.1/24` (LAN), `10.77.20.1/24` (AUDIT), `172.31.250.2/24` (WAN maintenance) | 1 Go | `CC-LAN`, `CC-AUDIT`, `CC-WAN-MAINT` |
| `CC-DC01` | Windows Server 2025, AD DS, DNS, fichiers | `10.77.10.10/24` | 4 Go | `CC-LAN` |
| `CC-W11-01` | Windows 11 Pro, poste métier | `10.77.10.100/24` | 4 Go | `CC-LAN` |
| `CC-KALI01` | Kali Linux, audit contrôlé | `10.77.20.50/24` | 2 Go | `CC-AUDIT` |

Domaine : `ad.cybercorp.test` ; NetBIOS : `CYBERCORP`. Les comptes métier figurent dans [config/comptes.csv](config/comptes.csv). Les adresses, passerelles et DNS détaillés figurent dans [config/infrastructure.csv](config/infrastructure.csv). Cet inventaire reste la référence à comparer à l’état constaté avant chaque changement.

## Entreprise et site vitrine

- [Fiche d’entreprise et identité visuelle](docs/entreprise.md) : mission, offres, valeurs et charte de marque.
- [Organigramme](docs/organigramme.md) : 25 fonctions et leurs comptes métier.
- [Site vitrine](website/dist/index.html) : pages statiques responsive, logo SVG dans `website/dist/assets/`, et manifeste d’hébergement dans `website/.openai/hosting.json`.

Le site ne collecte aucune donnée. Pour un aperçu local : `python -m http.server 8765 --directory website/dist`, puis ouvrir `http://127.0.0.1:8765/`. `site/` est une copie locale de publication ignorée par Git ; les modifications durables se font dans `website/`.

Version hébergée privée : [CyberCorp — site vitrine](https://cybercorp-vitrine.fabled-haven-3189.chatgpt.site).

Le [tableau de bord du projet](https://cybercorp-vitrine.fabled-haven-3189.chatgpt.site/tableau-de-bord) affiche le dernier relevé de l’hôte, les VM, les commutateurs et l’avancement. Voir le [guide de collecte](docs/suivi-site.md) pour le fonctionnement, les droits Hyper-V et l’actualisation automatique.

## Statut

- [x] Noms, rôles, profils mémoire et plan IP documentés
- [x] Comptes et secrets initiaux proposés localement
- [x] Pack de cinq outils de sécurité sélectionné et documenté
- [x] VM, commutateurs privés et règles pfSense de base créés et documentés
- [x] Essais bornés Nmap/Ndiff, Sysmon/Hayabusa et GPOZaurr consignés
- [x] Conftest/OPA exécuté les 01 et 06/11/2026 : export réel PASS, cinq copies fautives FAIL ; [contrôle et limites](docs/controle-topologie.md)
- [x] Dossier `CL-2026-014\Livraison` créé ; deux collectes M03 réalisées sur `CC-DC01` les 01–02/11/2026
- [x] JSON M03 rapatriés et inscrits au registre le 05/11/2026 ; SHA-256 source/copie vérifiés, état `False → True` et captures C02–C04 conservées hors Git et OneDrive
- [x] Rapport GPOZaurr et capture C05 archivés et enregistrés le 06/11/2026 ; empreintes et référence croisée contrôlées
- [x] C07–C09 et C10–C12 conservées dans le coffre ; contrôles des copies communiqués, avec détail et limites dans les documents de contrôle
- [ ] Réconcilier le registre accessible avec les inscriptions du 6 novembre ; enregistrer le dernier export C12
- [ ] Qualification finale M03, C06 (`gpresult`) et complément des essais métier / T08–T09
- [ ] Mandat M-CLIENT-01 assemblé et décidé
- [ ] Recette T01–T15 exécutée et preuves conservées

Les fichiers DOCX et PDF à la racine sont des documents sources non suivis par Git. Leur contenu n’est pas modifié ici.
