# CyberCorp — fiche d’entreprise

## Identité

- **Nom d’usage :** CyberCorp
- **Signature :** Le numérique mérite de la clarté.
- **Activité :** conseil et accompagnement numérique pour clients professionnels
- **Effectif :** 25 collaborateurs, répartis dans six services
- **Positionnement :** rendre les projets numériques lisibles, maîtrisables et sécurisés
- **Mission :** aider une organisation à prendre de meilleures décisions techniques, protéger ses données et maintenir ses services essentiels
- **Valeurs :** clarté, responsabilité, coopération, sobriété
- **Public visé :** PME et équipes qui ont besoin d’un accompagnement pragmatique

## Offres

1. **Conseil & feuille de route** — cadrage, priorités, choix techniques et accompagnement des décisions.
2. **Systèmes & exploitation** — architecture, identités, postes, documentation et continuité.
3. **Sécurité & résilience** — contrôle des accès, durcissement, sauvegarde, préparation aux incidents et vérification.

Les offres structurent les responsabilités des équipes et les exigences appliquées aux dossiers clients. Ce document ne revendique ni certification ni résultat d'audit non démontré.

## Mandat de sécurité M-CLIENT-01

Le mandat traite une difficulté concrète pour une petite équipe informatique : répondre à une demande client urgente tout en maîtrisant une exception d'audit et en expliquant un signal sur un poste. `M-CLIENT-01` doit produire un dossier de décision avec les accès autorisés, les mesures, les traces, les écarts et les limites. Les responsabilités et la justification de chaque outil figurent dans [la mission de sécurité](mission-securite.md).

## Organisation

| Service | Effectif | Responsabilité |
| --- | ---: | --- |
| Direction | 2 | Stratégie, arbitrage et qualité |
| Administration & RH | 3 | Vie interne et gestion du personnel |
| Finance | 3 | Budget, achats et suivi financier |
| Commercial | 7 | Relation clients et développement |
| Technique | 8 | Projets et documentation technique |
| Informatique | 2 | Support et administration du SI |
| **Total** | **25** | |

Les noms, postes et rattachements figurent dans [l’organigramme](organigramme.md). Les identifiants informatiques correspondants sont dans `config/comptes.csv` et restent distincts des comptes d’administration et de test.

## Identité visuelle

Le symbole associe deux arcs en « C » : le premier représente la continuité des services, le second la coopération entre métiers. La couleur bleu nuit porte la confiance ; le turquoise signale l’action et la lisibilité. Le logo est un dessin vectoriel original du projet, disponible dans `website/dist/assets/logo-mark.svg` et `website/dist/assets/logo-lockup.svg`.

| Usage | Couleur | Hex |
| --- | --- | --- |
| Fond sombre | Bleu nuit | `#0b1830` |
| Surface | Bleu ardoise | `#142540` |
| Accent | Turquoise | `#48e2d1` |
| Accent secondaire | Bleu clair | `#8cb8ff` |
| Texte clair | Ivoire froid | `#f5f8fc` |

Typographie du site : pile système pour limiter les dépendances externes. Garder une zone libre autour du logo égale à la moitié de la hauteur du symbole et ne pas le déformer.

## Usage du site

Le site vitrine présente l'activité, les offres et l'organisation. Il ne collecte aucune donnée et ne propose pas de formulaire de contact.
