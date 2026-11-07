# CyberCorp — clôture documentaire avec réserves

**Version 1.0 — 7 novembre 2026.** Périmètre : laboratoire CyberCorp et mandat M-CLIENT-01. Les constats sont arrêtés sur les preuves disponibles. Aucune nouvelle opération invitée ou mesure réseau n'a été exécutée pour cette clôture.

## Conclusion proposée

Le socle est déployé : quatre VM, réseaux isolés, domaine AD/DNS, comptes, groupes, partages et ACL. La topologie statique est validée. Le DC est activé en évaluation jusqu'au 6 mai 2027, avec une surveillance bornée sans arrêt et des contrôles AD ciblés conformes. La cohérence native des quatre GPO est démontrée après correction ; l'application actuelle complète sur W11 reste partielle.

La recette finale comporte **2 contrôles validés, 6 partiellement démontrés et 7 non démontrés**. Ces catégories décrivent la couverture des preuves, pas un pourcentage de réalisation technique. Aucun critère n'a été supprimé pour obtenir une validation.

**Recommandation technique : remettre le dossier de constats avec ses réserves, en suspendant l'acceptation technique globale du mandat.** L'approbation nominative de cette remise, le destinataire et le canal restent à renseigner par le responsable. Cette proposition n'est ni une signature, ni une autorisation d'audit, ni une certification de mise en production.

## Recette finale

| Tests | Statut | Réserve |
| --- | --- | --- |
| T01–T02 | Validés | Configuration statique datée ; à rafraîchir avant nouvelle exception |
| T03–T04 | Partiellement démontrés | Configuration et observations historiques ; refus corrélés et fermeture complète M04 non démontrés |
| T05 | Non démontré | Pas de profil métier conforme sur dix minutes ; reprise W11 interrompue sous la marge mémoire |
| T06–T07 | Partiellement démontrés | DNS historique et santé AD ciblée ; série complète fraîche et authentification poste non établies |
| T08 | Partiellement démontré | Finance historique et Clients positif/négatif observés ; matrice et traces fraîches incomplètes |
| T09 | Non démontré | Lecture seule Direction configurée, sans test effectif |
| T10 | Partiellement démontré | C06 historique et cohérence GPO native ; état endpoint courant incomplet |
| T11 | Non démontré | Revue RDP/Tailscale et routage avec contre-test absente |
| T12–T13 | Non démontrés pour le mandat | Essais Sysmon/Hayabusa historiques sans chaîne complète du scénario |
| T14–T15 | Non démontrés | Pas de restauration contrôlée indépendante ; RTO/RPO non mesurés |

La [recette CSV](../config/recette.csv) conserve les objectifs et précise les résultats retenus. « Partiellement démontré » ne vaut pas recette acceptée.

## Registre rapproché

Le coffre reste `C:\Users\pissa\AppData\Local\CyberCorp\preuves\M-CLIENT-01`, hors Git et OneDrive. Le registre actif de 27 lignes a été comparé à la sauvegarde de 42 lignes. Leurs 19 identifiants communs ont des métadonnées identiques. Les huit autres inscriptions actives correspondent chacune à un contenu unique déjà référencé dans la sauvegarde, par SHA-256.

Les huit correspondances sont conservées dans `rapprochement-cloture-20261107T162640072Z.json`. L'ancien actif est sauvegardé sous `registre-avant-cloture-20261107T162640072Z.csv`. Les sources ne sont pas supprimées. La base de 42 lignes a été installée après contrôle des fichiers, tailles et empreintes.

La pièce W11 existait, mais sa ligne historique `M-CLIENT-01_poste_20261107T143053385Z_MONNOKOELOBA_HyperV` n'a pas été retrouvée. Le JSON source a été réinscrit sans reconstituer les métadonnées historiques : nouvel identifiant `M-CLIENT-01_poste_20261107T162640679Z_MONNOKOELOBA_HyperV`, événement natif `2026-11-07T14:27:08.6926345Z`, inscription réelle du 7 novembre à 16:26:40 UTC. SHA-256 : `27A0A32F77789165DB4A2046358B78F5BF4C54028668F81098CC77616AADCF70`.

Le registre final compte **43 lignes, 43 identifiants et 43 contenus distincts**. SHA-256 : `4D7860F21D5C457231F0BA843A3FE055BE05CA4A40CFFB553B00B0D5A45B03CE`. La cause du retour à l'ancienne version active reste inconnue. Les 90 annexes sont distinctes des pièces principales et ont été contrôlées dans le [lot autonome précédent](controle-final-autonome-2026-11-07.md).

## Preuves retenues

- [Conftest et contrôle du coffre](controle-final-autonome-2026-11-07.md) : export `…140849846Z…HyperV`, rapport `…140849862Z…Conftest`, PASS réel et cinq refus attendus. Portée statique seulement.
- [Activation du DC](activation-dc01-2026-11-07.md) : évaluation activée, surveillance bornée et retour au confinement. Aucune disponibilité passée lors du scan ni restauration déduite.
- [AUDIT et GPO natives](reprise-registre-audit-gpo-2026-11-07.md) : blocage IPv4 journalisé chargé et quatre GPO cohérentes. Les erreurs historiques GPOZaurr restent une limite de l'outil.
- [C06 et accès Clients](controle-gpo-clients.md) : rapport du 6 novembre, succès usr.com01 et refus usr.fin02 ; [Finance et Commun](preuves-conversation/03-partages-acl-tests.md) : essais du 18 octobre. Résultats historiques et circonscrits.
- [Reprise W11 interrompue](reprise-powershell-metier-2026-11-07.md) : 1,251 Gio libres, retour Saved et aucune authentification pendant cet essai. La nouvelle inscription ci-dessus remplace sa référence de registre introuvable.

## Réserves de remise

1. **Réseau :** nouvelle fenêtre M04 non approuvée, triplet Nmap/Ndiff et journaux corrélés incomplets ; disponibilité du DC lors du scan du 6 novembre non établie. La fermeture de maintenance d'activation ne remplace pas M04.
2. **Poste :** mémoire insuffisante au dernier essai ; licence W11 et accès local-admin à clarifier ; pas de collecte endpoint actuelle complète après reprise.
3. **Accès :** tests Direction et matrice complète des accès non démontrés.
4. **Détection :** chaîne d'événements du mandat absente ; aucune conclusion d'absence d'exfiltration.
5. **Reprise :** restauration indépendante fichier/DC non démontrée ; aucun engagement RTO/RPO.
6. **Diffusion :** PDF métier CL-2026-014 et son empreinte, destinataire, canal, relecture humaine des extraits et signature non établis. Le présent dossier de constats ne se substitue pas au livrable métier.

## Décision à faire enregistrer

Proposition : **clôture documentaire avec réserves ; acceptation technique globale suspendue**. La [fiche de décision](fiche-m-client-01.md) conserve la validation humaine, les responsables et les échéances à attribuer. Aucun accord n'est attribué aux personnes proposées dans le mandat. Le rapport principal Google reprend les mêmes résultats et réserves.
