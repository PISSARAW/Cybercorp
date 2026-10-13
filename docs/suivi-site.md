# Suivi du laboratoire sur le site privé

Le tableau de bord est accessible à l’adresse `https://cybercorp-vitrine.fabled-haven-3189.chatgpt.site/tableau-de-bord`. Le site reste privé et demande une connexion ChatGPT autorisée. Il montre le **dernier relevé reçu**, avec date et indicateur de fraîcheur, puis actualise l’affichage toutes les minutes.

## Circuit des données

```mermaid
flowchart LR
  H[Hôte Windows / Hyper-V] -->|PowerShell lecture seule, toutes les 5 min| C[Collecteur local]
  J[Journal de déploiement et recette.csv] --> C
  C -->|HTTPS sortant, relevé limité| S[Site privé CyberCorp]
  S -->|Stockage du dernier relevé| R[R2]
  R -->|Lecture seule| D[Tableau de bord]
```

Le collecteur `scripts/collect-dashboard.ps1` lit uniquement les VM CyberCorp et les commutateurs nommés dans sa liste blanche. Il envoie l’état, la mémoire affectée et le nombre de points de contrôle, la mémoire disponible de l’hôte, les dix étapes du journal et le nombre de tests marqués `Validé` dans `config/recette.csv`. Il n’envoie pas les IP personnelles, journaux Windows, noms de compte, contenus des disques ou secrets. Le site ne propose aucune commande de démarrage, d’arrêt ou de configuration des VM.

L’API `POST /api/telemetry` vérifie une clé propre au collecteur, refuse les VM inconnues et stocke seulement les champs prévus. L’accès au site privé ajoute une seconde barrière pour les appels sans navigateur. Les deux jetons du collecteur sont protégés par DPAPI dans `%LOCALAPPDATA%\CyberCorp\dashboard-collector.dpapi.json`, pour le compte Windows qui exécute la tâche. Ils ne sont pas dans Git ni dans le code du site. Le secret de validation côté site est une variable d’environnement protégée.

## Actualisation

L’agent local `scripts/dashboard-agent.ps1` lance le collecteur toutes les cinq minutes sous le compte Windows courant. Il démarre à l’ouverture de session via l’entrée utilisateur `CyberCorpDashboardCollector` et écrit le résultat du dernier passage dans `%LOCALAPPDATA%\CyberCorp\collector-last-run.log`. Une collecte manuelle se lance avec `pwsh -File scripts/collect-dashboard.ps1` depuis la racine du dépôt ; `-DryRun` affiche le relevé sans l’envoyer. La page indique « relevé ancien » après dix minutes sans mise à jour. Pour arrêter durablement la collecte automatique, supprimer l’entrée utilisateur `CyberCorpDashboardCollector` puis arrêter le processus PowerShell de l’agent.

Le compte courant ne dispose actuellement pas des droits de lecture Hyper-V. Dans ce cas, l’envoi continue pour la mémoire de l’hôte et l’avancement, mais les listes de VM et de commutateurs restent indisponibles. Pour compléter ces données, faire exécuter la tâche par un compte autorisé à lire Hyper-V, puis vérifier avec `Get-VM` et `Get-VMSwitch` avant de considérer les valeurs affichées comme complètes. Ne pas ouvrir les réseaux privés des VM vers le site.

Le suivi des tests est volontairement explicite : mettre à jour `config/recette.csv` après chaque recette vérifiée, avec un lien ou une référence de preuve non sensible. L’état d’avancement provient du tableau « État des étapes » du journal. Les données ne sont pas mises à jour lorsque l’hôte est éteint ou la session du compte fermée.
