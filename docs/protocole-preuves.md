# Chaîne de preuves — M-CLIENT-01

## Coffre et accès

Les nouveaux exports sont conservés dans `C:\Users\pissa\AppData\Local\CyberCorp\preuves\M-CLIENT-01`, hors du dépôt Git et hors du dossier OneDrive. Le dossier racine possède des droits explicites : compte `pissa`, `SYSTEM` et administrateurs locaux en contrôle total ; l'héritage est désactivé. `brut/` contient les originaux copiés, `extraits-expurges/` les versions relues destinées à la remise et `registre.csv` le registre interne. Ce coffre n'est **pas** une sauvegarde indépendante : prévoir une copie chiffrée sur support distinct selon la politique de sauvegarde.

Le répertoire historique `preuves/S01/artifacts/` reste à son emplacement actuel dans le dossier OneDrive pour préserver la traçabilité de S01. Il est exclu de Git, mais **n'est pas** le coffre des nouvelles preuves. Ne pas y ajouter de nouveaux exports sensibles. Les pièces historiques et l'absence du premier XML bloqué sont décrites dans le [journal de déploiement](journal-deploiement.md).

## Convention et registre

Le script [enregistrer-preuve.ps1](../scripts/enregistrer-preuve.ps1) copie chaque pièce sans écraser un fichier existant et vérifie son SHA-256 avant d'ajouter une ligne au registre. Le nom suit le format `M-CLIENT-01_<étape>_<AAAAmmjjTHHMMSSfffZ>_<source>_<outil>.<extension>`. Le registre contient l'identifiant, la source, l'outil, l'action ou la commande décrite, l'opérateur, l'heure de collecte UTC, l'heure de l'événement si connue, le nom d'origine, la taille, le chemin relatif et l'empreinte. Une heure inconnue reste vide : ne pas la déduire de la date de copie.

Exemple, depuis PowerShell sur l'hôte après extraction contrôlée d'un export :

```powershell
.\scripts\enregistrer-preuve.ps1 -Fichier 'C:\chemin\vers\blocked-before.xml' -Etape avant -Source CC-KALI01 -Outil Nmap -Action 'Scan borné TCP 53,88,389,445 vers 10.77.10.10 avant exception'
```

Pour un extrait, expurger les secrets et données non nécessaires **avant** l'enregistrement. Une seconde personne relit le résultat ; son identité est obligatoire :

```powershell
.\scripts\enregistrer-preuve.ps1 -Fichier 'C:\chemin\vers\rapport-expurge.txt' -Etape analyse -Source CC-W11-01 -Outil Hayabusa -Action 'Extrait de chronologie M-CLIENT-01' -Type ExtraitExpurge -RelecteurExpurgation 'Nom du relecteur'
```

La commande `-Action` ne doit contenir aucun secret, jeton, chemin personnel inutile ou contenu métier. Le script n'expurge pas automatiquement : l'extrait n'est prêt pour la remise qu'après relecture humaine. Un rapport, une capture ou une alerte seule ne valide pas une tâche ; la [fiche de décision](fiche-m-client-01.md) relie les identifiants des pièces aux constats et limites.

## Contrôle avant remise

1. Recalculer le SHA-256 des pièces citées et comparer au registre.
2. Vérifier source, heure, périmètre autorisé et action pour chaque pièce.
3. Contrôler que les extraits ne contiennent ni secret, donnée personnelle superflue, chemin privé ou contenu métier non nécessaire.
4. Référencer les pièces par leur identifiant dans la fiche M-CLIENT-01 ; déclarer explicitement toute preuve absente ou incomplète.
