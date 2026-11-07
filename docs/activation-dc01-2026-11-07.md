# CC-DC01 activé et confinement rétabli — 7 novembre 2026

**Suivi à 11:42 Europe/Paris :** [registre rapproché, AUDIT réactivé et incohérence GPO corrigée](reprise-registre-audit-gpo-2026-11-07.md). Les quatre sources autonomes ont été retrouvées ; registre actif de 38 lignes vérifiées. W11 est actif avec le DC, mais ses identifiants locaux sont refusés. Les états et points ouverts ci-dessous décrivent la clôture de la maintenance à 10:49.

CC-DC01 est activé en **évaluation**, `LicenseStatus=1`. L'unique tentative `/ato` autorisée a réussi à 09:43:53–09:43:58 UTC, soit 10:43 Europe/Paris. Windows a affiché 259 200 minutes restantes, soit 180 jours, et `/xpr` indique une expiration au **6 mai 2027**. La valeur sentinelle `EvaluationEndDate` de 1601 reste inexploitable ; le résultat repose sur l'état de licence et `/xpr`.

Le WAN et le NAT temporaires sont fermés, le DNS du DC et les règles initiales de pfSense sont restaurés. Seul le DC reste actif. La marge mémoire de l'hôte est respectée.

## Surveillance avant maintenance

Après le [réarmement explicitement autorisé](rearmement-dc01-2026-11-07.md) et le redémarrage du seul DC, la surveillance s'est achevée à 09:17:59 UTC :

- 3 902 secondes de fonctionnement invité, soit plus de 65 minutes ;
- 124 relevés, tous à l'état Running, aucune erreur de lecture ;
- aucun événement System 1074 depuis l'amorçage ;
- aucune mesure de RAM libre sous 1,5 Gio ; minimum relevé : 2,326 Gio.

La mesure démontre cette fenêtre de disponibilité. Elle ne constitue pas une garantie de disponibilité future ni une validation complète de la recette.

## Maintenance autorisée et activation

L'utilisateur a autorisé le [périmètre de maintenance](preparation-activation-dc01-2026-11-07.md), puis validé localement l'élévation UAC nécessaire au WinNAT. L'auxiliaire élevé est resté en attente tant que la surveillance et le filtrage n'étaient pas vérifiés.

Kali a conservé son état enregistré et sa carte a été temporairement déconnectée. pfSense seul a été repris en complément du DC, WAN d'abord déconnecté. Les paramètres mémoire des VM n'ont pas été modifiés. La sauvegarde complète pfSense avant intervention a été chiffrée avec DPAPI CurrentUser sur l'hôte ; son déchiffrement a été vérifié sans afficher son contenu.

Le filtrage temporaire comprenait neuf règles et trois alias : administration privée depuis le DC, DNS vers `1.1.1.1`, HTTP/HTTPS vers les adresses des services Microsoft et de leurs dépendances PKI, blocage des destinations non publiques et du reste des sorties. Les règles actives et les tables ont été lues avant ouverture. Les alias reposaient sur des résolutions DNS contemporaines, avec leur limite habituelle : une adresse peut correspondre à un hébergement partagé et ne filtre pas le chemin d'une URL.

La première application a écrit la configuration sans produire le résultat structuré attendu ni activer les règles dans le noyau. L'état réel a été lu avant toute nouvelle action ; le rechargement normal par événement pfSense a ensuite été demandé et vérifié. Les règles de sortie temporaires ont reçu `disablereplyto`, afin de conserver le routage normal de ces flux sortants. Le WAN est resté déconnecté pendant cette préparation.

Le redirecteur temporaire `1.1.1.1` a été ajouté au serveur DNS du DC ; le DNS client est resté `127.0.0.1` / `::1`.

| Événement | UTC | Europe/Paris |
| --- | --- | --- |
| Ouverture WAN sur CC-WAN-MAINT | 09:28:20.6175940 | 10:28:20 |
| Contrôle TLS avec révocation réussi | 09:43:52.2636568 | 10:43:52 |
| Début de l'unique `/ato` | 09:43:52.9906341 | 10:43:52 |
| Retour `/ato`, code 0, produit activé | 09:43:58.2138080 | 10:43:58 |
| WAN déconnecté et clôture demandée | 09:43:58.6359178 environ | 10:43:58 |
| NAT dédié supprimé par l'auxiliaire | 09:43:59.0012834 | 10:43:59 |

La fenêtre WAN a duré environ **15 minutes 38 secondes**, sous la limite de 20 minutes. Le WinNAT créé et supprimé était uniquement `CC-MAINT-ACTIVATION-20261107`, pour `172.31.250.0/24`. Aucun raccordement au Default Switch ou à un commutateur externe n'a été effectué.

### Dépendances PKI et connexion d'administration

La résolution externe a d'abord réussi, mais le contrôle TLS avec révocation signalait `RevocationStatusUnknown` et `OfflineRevocation`. Les journaux de refus et les résolutions DNS ont identifié notamment `ctldl.windowsupdate.com`, service de distribution des listes de confiance Microsoft, parmi les dépendances manquantes. Les adresses contemporaines des services PKI ont été ajoutées au filtrage borné. Le contrôle TLS strict avec révocation a ensuite réussi avant `/ato`. Microsoft décrit le rôle des [listes de confiance et de certificats non fiables](https://learn.microsoft.com/en-us/windows-server/identity/ad-cs/certificate-trust).

Une connexion PowerShell Direct a été interrompue pendant les diagnostics, puis la qualification NetBIOS a été refusée. Le même compte a fonctionné au format UPN `Administrateur@ad.cybercorp.test`, sans modification d'identifiant ni nouveau redémarrage. La cause précise du refus NetBIOS n'est pas établie. Les opérations suivantes et les contrôles finaux ont utilisé l'UPN.

## Retour vérifié à l'état initial

- WAN pfSense MAC `00155D013C0E` déconnecté, sans commutateur ; aucun WinNAT résiduel.
- Neuf règles et trois alias temporaires supprimés ; empreintes des sections règles et alias identiques à celles d'avant intervention. Aucune règle temporaire encore active dans le noyau.
- Redirecteur `1.1.1.1` retiré ; aucun redirecteur initial, indications de racine actives, délai 3 secondes ; DNS client local inchangé.
- pfSense replacé dans l'état Saved, Kali toujours Saved et sa carte rétablie sur CC-AUDIT ; W11 Off.
- DC Running ; mémoire libre de l'hôte au relevé de retour : **3,252 Gio**.
- Sauvegarde pfSense après restauration chiffrée et déchiffrement vérifié. La comparaison d'identité porte sur les sections règles/alias ; la révision globale de configuration a normalement évolué.

## Contrôles finaux

À 09:49:19 UTC, le DC indique plus de 96 minutes de fonctionnement depuis l'amorçage vers 08:12:57 UTC, sans événement 1074 depuis celui-ci. Les lectures CIM du temps d'amorçage peuvent varier de quelques millisecondes ; aucune nouvelle séquence d'amorçage n'a été observée.

- Licence toujours activée, `LicenseStatus=1`, échéance `/xpr` au 6 mai 2027 ; zéro réinitialisation restante.
- `dcdiag /test:Advertising /test:SysVolCheck /test:NetLogons /q` : code 0, aucune erreur affichée.
- Services AD/DNS, SYSVOL/NETLOGON et SRV AD présents et opérationnels lors du relevé.
- Export Hyper-V après restauration : **PASS Conftest réel et cinq FAIL attendus**, 18 règles exécutées par cas. Ce contrôle statique ne valide pas les flux pfSense.

## Preuves conservées

Les pièces restent dans le coffre `M-CLIENT-01`, hors dépôt et OneDrive. **51 fichiers** ont été copiés sans écrasement dans `brut`, avec comparaison des tailles et SHA-256. Les configurations complètes pfSense sont conservées uniquement sous forme chiffrée DPAPI ; les mots de passe, cookies et clés produit n'ont pas été affichés ou versionnés.

Manifeste : `transfert/manifest-activation-dc01-20261107T095142708Z.json`, SHA-256 `9F8B03A8BDD09812F9E98345A6A493E1D8D377428BF606DCE0D4F80133C8AAF5`.

| Pièce principale dans `transfert` | SHA-256 ou référence |
| --- | --- |
| `surveillance-dc01-rearm-20261107.final.json` | Résultat final et empreinte du journal de mesures dans le manifeste |
| `activation-dc01-20261107.result.json` | Sortie exacte de l'unique `/ato`, état de licence et `/xpr` |
| `activation-dc01-20261107.health-final.json` | État invité après retour au confinement |
| `activation-maintenance-20261107.restored.json` | VM, RAM, WAN, absence de NAT, restauration Kali et filtrage |
| `M-CLIENT-01_M02_Conftest_20261107T094745329Z.json` | `D0DB6E3773CA075C708ECF31D18861EC07552AE01401E8917DD20D442531977E` |
| `topologie-apres-activation-20261107T094742473Z.json` | `76880D0F7FE28310B907AF6D6B335DAC0DA848B7C58EC9B41E7EE399FC5B76DF` |

Le registre divergent reste **inchangé**, SHA-256 `05FF3BB292B17D14F21A55EA576501AE73DB083E6DF6AA5D3471AE8D72FEC122`. Les nouvelles pièces sont conservées avec un manifeste séparé, sans inscription en bloc ni reconstruction de l'ancienne version à 27 lignes.

## Points restant ouverts

La règle explicite de blocage AUDIT est marquée désactivée dans la configuration lue avant intervention. Cet état préexistant a été préservé ; le refus par défaut demeure distinct de cette règle explicite. Qualifier ce constat avant une nouvelle recette réseau, sans présenter le PASS Conftest comme une validation des règles pfSense.

La divergence de disponibilité du registre reste à résoudre. C06, C12 et les deux captures WAN historiques ont été retrouvés et recopiés avec des empreintes conformes ; les quatre anciennes pièces autonomes et le registre historique à 27 lignes ne sont pas encore retrouvés dans ce chemin. Les validations GPO et métier sur W11, le transfert Kali, la sauvegarde indépendante et la décision M-CLIENT-01 restent à poursuivre.
