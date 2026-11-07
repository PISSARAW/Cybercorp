# CyberCorp

Infrastructure Windows de CyberCorp, société de conseil de 25 collaborateurs. Ce dépôt rassemble le [dossier de conception](CyberCorp_Dossier_Conception.pdf), la configuration, le journal de déploiement, les contrôles de sécurité et les preuves de validation. Le périmètre Hyper-V est opérationnel ; la recette complète et le mandat M-CLIENT-01 restent à clôturer.

## Démarrage

1. Lire [l’architecture et les règles de confinement](docs/architecture.md) avant toute modification des commutateurs Hyper-V.
2. Vérifier que les trois sous-réseaux de [l’inventaire](config/infrastructure.csv) ne chevauchent pas le réseau personnel, Tailscale, WSL, Docker ou un VPN. En cas de conflit, documenter les écarts et adapter les adresses avant une nouvelle intervention.
3. Importer les identifiants initiaux de `secrets/initial-passwords.csv` dans un gestionnaire de mots de passe, puis supprimer la copie CSV locale dès que l’import est vérifié. Ce fichier est ignoré par Git mais se trouve dans un dossier OneDrive. Changer les secrets après leur première utilisation, en particulier les comptes d’administration. Si le fichier manque avant le déploiement, le recréer avec `python scripts/generate_initial_passwords.py` ; le script refuse d’écraser un fichier existant. Ne pas utiliser ces valeurs pour un système réel.
4. Pour une reconstruction, préparer les VM hors ligne puis suivre la séquence du dossier de conception (p. 10). La carte WAN de pfSense doit rester déconnectée pendant les exercices d’audit.

## Mission de sécurité en cours

**Clôture documentaire avec réserves — 7 novembre 2026 :** [rapport final](docs/rapport-cloture-avec-reserves-2026-11-07.md). Recette : **2 validés, 6 partiellement démontrés, 7 non démontrés**. Registre actif rapproché à **43 pièces distinctes**, huit alias historiques conservés ; pièce W11 réinscrite sous `M-CLIENT-01_poste_20261107T162640679Z_MONNOKOELOBA_HyperV`. SHA-256 du registre final : `4D7860F21D5C457231F0BA843A3FE055BE05CA4A40CFFB553B00B0D5A45B03CE`. Proposition : remettre les constats avec réserves, acceptation technique globale suspendue, validation humaine en attente. Les états et références des bilans ci-dessous restent historiques.

**État documenté au 7 novembre 2026, 15 h 30 Europe/Paris :** [tentative de reprise W11 et pilotage métier depuis l'hôte](docs/reprise-powershell-metier-2026-11-07.md). W11 a été repris une fois puis remis immédiatement en état Saved : mémoire libre descendue à 1,251 Gio, sous la marge de 1,5 Gio. Aucun essai d'authentification ni test métier exécuté. DC actif, autres VM Saved ; 3,312 Gio libres au bilan de reprise. Le registre compte désormais **43 pièces principales contrôlées**.

Le [lot autonome précédent](docs/controle-final-autonome-2026-11-07.md) a vérifié 38 pièces et 90 annexes, puis ajouté quatre pièces ; Conftest frais donne PASS réel et cinq FAIL attendus, 18 règles par cas. WAN déconnecté et aucun WinNAT au contrôle. La reprise suivante n'a modifié aucun réseau.

La [recette](config/recette.csv) compte **2 tests validés, 1 à actualiser (T10) et 12 à faire**. L'activation du DC, la cohérence native des quatre GPO et le classement du dernier C12 sont acquis selon les preuves datées. Les essais métier peuvent avancer avec leurs comptes dédiés sans attendre local-admin ; l'accès Direct sous usr.com01 reste à tester après préparation de la mémoire. La licence W11, les contrôles administratifs et réseau, Sysmon/Hayabusa, la restauration indépendante et la décision restent ouverts. Aucun extrait de remise relu n'est encore présent au coffre.

### Historique des interventions

**Dernier suivi d'accès du 7 novembre 2026 :** [session usr.com01 ouverte et verrouillage local-admin constaté](docs/diagnostic-acces-w11-2026-11-07.md). Après guidage vers la console de base, `whoami` confirme le compte métier. Lecture CIM : compte local actif mais `Lockout=True` ; `net accounts` : cinq échecs, verrouillage de 15 minutes. Attente sans nouvelle tentative demandée, déverrouillage non confirmé. Le bureau signale aussi une évaluation W11 expirée, à diagnostiquer nativement. Nouveau gpresult et essais métier restent ouverts ; registre inchangé à 38 lignes.

**Dernier état, 7 novembre 2026, 11 h 42 Europe/Paris :** [registre rapproché, AUDIT réactivé et GPO cohérentes](docs/reprise-registre-audit-gpo-2026-11-07.md). Sources couvrant les 27 empreintes historiques ; registre actif de 38 pièces principales uniques, tailles/SHA-256 contrôlés, anciennes versions préservées. Blocage IPv4 AUDIT journalisé chargé ; WAN déconnecté et aucun NAT. Quatre GPO cohérentes après alignement natif des deux GPO par défaut, sans changement des fichiers de stratégie. [DC activé jusqu'au 6 mai 2027](docs/activation-dc01-2026-11-07.md), contrôles AD ciblés conformes. DC/W11 actifs, pfSense/Kali Saved, environ 1,95 Gio libres. Identifiants locaux W11 refusés : nouveau gpresult et essais métier bloqués. Les comptes Direction exigent leur premier changement de mot de passe.

**Bilan antérieur du 7 novembre 2026 :** [contrôles autonomes et C06 retrouvée](docs/avancement-autonome-2026-11-07.md). Le registre comptait 27 pièces contrôlées selon ce bilan. Conftest était conforme sur le dernier C12 et sur un export actuel ; les MAC Hyper-V étaient archivées. Le rapport C06 du 6 novembre était conservé et analysé. Activation du DC, transfert Kali et autres tests restaient ouverts. Les bilans datés plus anciens ci-dessous restent historiques.

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
- [x] Conftest/OPA réexécuté le 07/11/2026 à 14:08 UTC : export réel PASS, cinq copies fautives FAIL ; [contrôle et limites](docs/controle-final-autonome-2026-11-07.md)
- [x] Dossier `CL-2026-014\Livraison` créé ; deux collectes M03 réalisées sur `CC-DC01` les 01–02/11/2026
- [x] JSON M03 rapatriés et inscrits au registre le 05/11/2026 ; SHA-256 source/copie vérifiés, état `False → True` et captures C02–C04 conservées hors Git et OneDrive
- [x] Rapport GPOZaurr et capture C05 archivés et enregistrés le 06/11/2026 ; empreintes et référence croisée contrôlées
- [x] C07–C09 et C10–C12 conservées dans le coffre ; contrôles des copies communiqués, avec détail et limites dans les documents de contrôle
- [x] Registre rapproché, dernier C12 archivé ; 43 pièces principales contrôlées après le suivi de reprise W11 du 7 novembre
- [x] DC activé jusqu'au 6 mai 2027 ; quatre GPO cohérentes selon les contrôles natifs
- [ ] Reprise W11 avec marge mémoire et accès métier ; C06 actuelle, contrôles endpoint et complément des essais métier / T08–T09 ; accès administratif et licence à traiter séparément
- [ ] Contrôles de flux T03–T04 et scénario M04 sous nouvelle fenêtre approuvée
- [ ] Scénario Sysmon/Hayabusa T12–T13 et sauvegarde/restauration indépendante T14–T15
- [ ] Mandat M-CLIENT-01 assemblé et décidé
- [ ] Recette T01–T15 exécutée et preuves conservées

Les fichiers DOCX et PDF à la racine sont des documents sources non suivis par Git. Leur contenu n’est pas modifié ici.
