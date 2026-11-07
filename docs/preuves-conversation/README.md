# Preuves issues de la conversation de déploiement

Ce dossier conserve, sous une forme versionnable et expurgée, les preuves communiquées pendant la construction du laboratoire CyberCorp. Il complète le [journal de déploiement](../journal-deploiement.md) et ne remplace pas le coffre défini dans le [protocole de preuves](../protocole-preuves.md).

## Portée et niveau de preuve

- **Sortie textuelle** : résultat PowerShell copié directement dans la conversation.
- **Capture transcrite** : information lue sur une capture jointe à la conversation. Le nom du fichier temporaire est conservé dans `registre.csv`.
- **Original retrouvé** : les 34 fichiers temporaires `codex-clipboard-*.png` n'étaient plus présents dans `%LOCALAPPDATA%\Temp`, mais leurs originaux Windows ont été retrouvés dans `C:\Users\pissa\OneDrive\Images\Screenshots`. Leur contenu et leur heure correspondent aux pièces de la conversation. Des copies versionnables sont conservées dans [`captures/`](captures/README.md), avec leur correspondance et leur SHA-256.
- **Constat déclaré** : résultat décrit et accepté dans la conversation, mais sans sortie brute encore disponible dans le projet.

Une transcription n'est pas présentée comme un original numérique. Pour une remise formelle, les contrôles importants doivent être rejoués et enregistrés avec `scripts/enregistrer-preuve.ps1` dans le coffre prévu par le protocole.

## Contenu

- [Infrastructure, DNS et Active Directory](01-infrastructure-dns-ad.md)
- [Comptes et groupes](02-comptes-groupes.md)
- [Partages, ACL et tests fonctionnels](03-partages-acl-tests.md)
- [Stratégies de groupe](04-gpo.md)
- [`registre.csv`](registre.csv) : index de toutes les pièces et sorties identifiées ; les colonnes de référence temporaire décrivent les anciens fichiers `codex-clipboard`, tandis que `captures/` contient les originaux Windows retrouvés
- [`captures/README.md`](captures/README.md) et [`captures/SHA256SUMS.txt`](captures/SHA256SUMS.txt) : correspondance des 34 captures retrouvées et contrôle d'intégrité

## Exclusions volontaires

- Aucun mot de passe, secret, jeton, export pfSense ou fichier de secrets n'est reproduit.
- Le contenu des fichiers métier de démonstration est limité aux chaînes explicitement visibles dans les tests.
- Les résultats non exécutés sont listés comme manquants et ne sont pas transformés en preuves.
