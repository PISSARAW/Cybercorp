# Complément de validation GPOZaurr, Sysmon et Hayabusa — 7 novembre 2026

**Périmètre.** Ce compte rendu réunit l’audit GPOZaurr en lecture seule sur `CC-DC01`, les actions Sysmon bénignes effectuées sur `CC-W11-01` sous `CYBERCORP\usr.com01`, puis l’analyse hors ligne de l’EVTX avec Hayabusa. Les heures des événements sont en UTC ; l’heure locale de la session est Europe/Paris. Les pièces brutes, empreintes et inscriptions au registre demeurent dans le coffre local `M-CLIENT-01`, hors du dépôt.

Ce complément actualise les états historiques de [l’audit complémentaire](audit-complementaire-2026-11-07.md) et de [l’annexe technique](annexe-technique-m-client-01.md). Il ne transforme pas les captures de conversation en originaux numériques : seules les pièces et captures inscrites au registre sont référencées comme fichiers archivés.

## GPOZaurr — contre-audit C05

Le 7 novembre vers 17:37 UTC, GPOZaurr **1.1.13** a produit un rapport en lecture seule depuis `CC-DC01`, dans le dossier daté `GPOZaurr-20261107T173727447Z`. Il a été comparé au rapport du 5 novembre, SHA-256 `8CDA26993471BC692A85F8F46D77C0F5E8C2A388DFC0FA03FE72CA4035864314`. Aucun paramètre, lien, propriétaire ou droit GPO n’a été modifié pendant cette collecte.

| GPO | Cohérence avant → après | Propriétaire AD / SYSVOL après | Versions AD/SYSVOL | Lien inchangé |
| --- | --- | --- | --- | --- |
| `CC-Domaine-Comptes` | True/True → true/true | `CYBERCORP\Admins du domaine` / même groupe | 80/80 | Oui |
| `CC-Postes-Securite` | True/True → true/true | `CYBERCORP\Admins du domaine` / même groupe | 33/33 | Oui |
| `Default Domain Controllers Policy` | False/False → true/true | `CYBERCORP\Admins du domaine` / `BUILTIN\Administrateurs` | 1/1 | Oui |
| `Default Domain Policy` | False/False → true/true | `CYBERCORP\Admins du domaine` / `BUILTIN\Administrateurs` | 3/3 | Oui |

Les 20 lignes de permissions comparées sont inchangées. Le contre-contrôle natif indique les quatre ACL cohérentes après la correction antérieure, les versions AD/SYSVOL concordantes et aucune ACE d’écriture non administrative dans le périmètre examiné. Les deux alertes de propriétaire GPOZaurr persistent sur les stratégies par défaut parce que leurs propriétaires AD et SYSVOL sont des groupes administratifs différents ; elles ne sont pas présentées comme des droits d’écriture non administratifs.

Huit erreurs de conversion SID→GUID persistent dans le rapport GPOZaurr, réparties sur cinq SID distincts. Elles restent une limite de traitement de l’outil ; elles ne sont pas déclarées corrigées. Les permissions, liens et contrôles natifs apportent un contre-examen, sans rendre ces lignes GPOZaurr valides.

Le comparatif C05 et sa capture ont été archivés. La capture C05 montre les quatre GPO et les huit erreurs persistantes.

## Sysmon — actions contrôlées et collecte

Les trois actions ont été réalisées une seule fois sur `CC-W11-01` sous le compte métier non élevé `CYBERCORP\usr.com01`, dans le dossier de contrôle dédié `M-CLIENT-01-Sysmon-20261107T180606722Z` :

1. `whoami.exe` à `18:06:07.4878776Z`, résultat `cybercorp\usr.com01`.
2. Connexion TCP réussie vers `10.77.10.10:445` à `18:06:07.5195540Z`, point de terminaison local `10.77.10.100:53744`.
3. Modification de l’heure de création du fichier de contrôle à `18:06:07.5434551Z`, de `2026-11-07T18:06:07.4367158Z` à `2026-11-05T18:06:07.4367158Z`.

Le SHA-256 du contenu du fichier est identique avant et après : `8D69DCF16C40335E23653B1C04CCE41951741BAFB801136FCDAFD1055A9B73D1`. Le journal des actions indique le compte, l’identité non élevée, les heures, commandes, résultats et empreinte du script de contrôle (`6E3EB3D75B0147BC97B2FDC670C3F073A593CB36C7E0C44E58AB54115D9E497C`).

La configuration affichée sur W11 indique Sysmon **15.22**, configuration de règles **4.90**, connexions réseau activées, création de processus filtrée sur `powershell.exe`, `cmd.exe` et `whoami.exe`, et `NetworkConnect` filtré sur la destination `10.77.10.10`. Une session locale d’administration distincte a servi à exporter les événements protégés ; le compte métier n’a pas été élevé pour réaliser les actions.

L’EVTX filtré sur la fenêtre de contrôle et les IDs 1, 2 et 3 fait 69 632 octets. Son SHA-256 source et copie est `06B4699C50B26927FC7ED31BC0897A1324E7DAC240804E75692923BE5358348`.

## Hayabusa — détections et corrélation aux événements source

Hayabusa **4.2.0** a analysé cet EVTX hors ligne avec le paquet local de règles, révision Git `cde84eef71b2093dc2733b919ff958d409df940c`. SHA-256 de l’exécutable : `9F3F47CE0A0CD0289FA812F04F4009CA4147B6982797F9DDF22BEF923F248642`. Commande exécutée depuis le répertoire du paquet :

```powershell
hayabusa-4.2.0-win-x64.exe dfir-timeline -f <EVTX> -w -o <CSV> -O
```

L’exécution a lu 63 événements et produit 70 détections issues de cinq règles distinctes. Elle contient deux détections *Possible Timestomping* (niveau low), une *Local Accounts Discovery* (low) sur le processus `whoami.exe`, ainsi que les détections informatives de processus et connexions réseau.

| EventID / RecordID | Observation | Règle Hayabusa | Qualification |
| --- | --- | --- | --- |
| 1 / `11152` | `whoami.exe`, utilisateur `CYBERCORP\usr.com01`, horodatage de chronologie `18:06:07.503923Z` | `Proc Exec` (info) et `Local Accounts Discovery` (low) | **attendu** — exécution prévue de `whoami.exe` |
| 3 / `11160` | TCP `10.77.10.100:53744` → `10.77.10.10:445`, horodatage d’en-tête/chronologie `18:06:09.064583Z` | `Net Conn` (info) | **attendu** — adresse, port source et destination correspondent exactement à l’action réussie |
| 2 / `11154` | Heure de création du fichier témoin modifiée, horodatage `18:06:07.547706Z` | `Possible Timestomping`, ID `f03e34c4-6432-4a30-9ae2-76ae6329399a`, low/stable | **attendu** — action volontaire prévue par le contrôle |
| 2 / `11176` | Événement distinct sur un fichier temporaire Microsoft Edge à `18:07:07.240742Z` | `Possible Timestomping`, même règle | **indéterminé** — aucun lien avec les actions du contrôle n’a été établi |

Une première recherche de l’ID 3 sur le champ `UtcTime` de Sysmon n’avait rien trouvé. La chronologie Hayabusa et le `RecordID 11160` ont ensuite révélé l’événement : son `TimeCreated` dans l’en-tête EVTX correspond à `18:06:09Z`, mais son champ de données Sysmon `UtcTime` vaut `13:35:32.143`. L’écart est conservé comme anomalie d’horodatage ; la corrélation au test repose sur le RecordID, l’heure d’en-tête et le tuple réseau exact. La conclusion antérieure « ID 3 absent » est donc rectifiée.

La règle Sysmon `Sysmon_2_Low_PossibleTimestomping.yml` cible le canal Sysmon et EventID 2. Le signal 11154 est attendu dans le contexte du contrôle ; la règle seule ne qualifie pas une intention malveillante. Le signal 11176 demeure indéterminé faute de contexte de processus et d’action qui permettrait de l’expliquer.

### Limites de visibilité

La configuration observée ne couvre les créations de processus que pour les trois images nommées ci-dessus et les connexions réseau que vers `10.77.10.10`. Cette collecte ne montre pas toutes les connexions, lectures ou copies de fichiers, ni le contenu réseau. L’absence d’événement dans cet EVTX ne prouve pas l’absence d’activité ou d’exfiltration. Le fichier de contrôle dont le contenu reste inchangé ne constitue pas une preuve de non-lecture.

## Captures et chaîne de preuve

C22 est une capture de la présentation HTML issue de la ligne Hayabusa du `RecordID 11154`. C23 est une capture de la présentation du XML source du même événement, extrait de l’EVTX. Les présentations sont des vues dérivées ; les originaux de référence restent le CSV Hayabusa et l’EVTX inscrit au registre. Les captures C22/C23 ont été sauvegardées par l’opérateur et inscrites au coffre. La capture C05 est également inscrite. Aucune capture PNG C20/C21 distincte n’apparaît dans les inscriptions relevées ; les actions, la configuration observée et l’EVTX fournissent les éléments documentaires disponibles.

Le premier JSON de synthèse Hayabusa, inscrit sous `M-CLIENT-01_analyse_20261107T210936747Z_CC-W11-01_AnalyseHayabusa` (SHA-256 `FF39C50C80AF09BAF42AE5BA5FB7C7344CD836C41CB5848E6D0CAD4089E78752`), est conservé. La synthèse corrigée et complétée qui suit est la référence : `M-CLIENT-01_analyse_20261107T211054191Z_CC-W11-01_AnalyseHayabusaRev1`.

| Pièce de référence | Identifiant registre | SHA-256 |
| --- | --- | --- |
| Rapport GPOZaurr M03, 7 novembre | `M-CLIENT-01_gpo_20261107T175719127Z_CC-DC01_GPOZaurr` | `FC698DF1AE479066414BE8C593645A4F7B5968F4FB1E83359A5C2BCFC402CE61` |
| Comparaison GPO avant/après | `M-CLIENT-01_gpo_20261107T175719823Z_CC-DC01_Comparaison` | `883DE5824E0F33D9C30BCB300933FA4EEB0D4A7FF399305009E84B8ABE76EB19` |
| Contre-contrôle GroupPolicy natif | `M-CLIENT-01_gpo_20261107T175719861Z_CC-DC01_GroupPolicy` | `0520D910DCA1A8B1A0FD77845CE9C3981FE926AFE3FDFA75B98ED795192972C6` |
| Manifeste audit GPO | `M-CLIENT-01_gpo_20261107T175719886Z_CC-DC01_Manifeste` | `B4B8542C71B28E6D2FDE45EAE8F42491C346977AE4B4B2FA2AF087229B5BC32C` |
| Capture C05 | `M-CLIENT-01_gpo_20261107T180009026Z_CC-DC01_CaptureC05` | `075091A101BBF4A76FBD55124FF872256A4FA47ED9D6CD2B133C1BC484D5651D` |
| Journal des actions Sysmon | `M-CLIENT-01_poste_20261107T181114974Z_CC-W11-01_SysmonActions` | `EC3796CAD13AA67FC14B3436EE8EAD63CD20B0AD5DB11C65B50EFDB941825DDD` |
| Fichier de contrôle | `M-CLIENT-01_poste_20261107T181115029Z_CC-W11-01_FichierControle` | `8D69DCF16C40335E23653B1C04CCE41951741BAFB801136FCDAFD1055A9B73D1` |
| Export EVTX Sysmon | `M-CLIENT-01_poste_20261107T210936659Z_CC-W11-01_SysmonEVTX` | `06B4699C50B26927FC7ED31BC0897A1324E7DAC240804E75692923BE5358348` |
| Chronologie Hayabusa CSV | `M-CLIENT-01_analyse_20261107T210936717Z_CC-W11-01_Hayabusa` | `1EAA793174EA8A0371D3248327A8E54AB35BC9DE6879DD3F860679623A65D7E0` |
| Règle locale Possible Timestomping | `M-CLIENT-01_analyse_20261107T210936777Z_hote_RegleHayabusa` | `8B30D5EEC86DECD1289EBFAE1A678CD12EB002FBF8B62F3DDBC7B690EE742200` |
| Synthèse Hayabusa corrigée Rev1 | `M-CLIENT-01_analyse_20261107T211054191Z_CC-W11-01_AnalyseHayabusaRev1` | `FB8B33968E3E8D64439A9DBF1631E0B23BF8EEFFDBD9007708F04ED9159C0F14` |
| Capture C22 | `M-CLIENT-01_analyse_20261107T213241608Z_CC-W11-01_CaptureC22` | `EBAB5CA5523811624EAB4A3E4AB931405852196FBCC4EEF28FCFEFEF5363571E` |
| Capture C23 | `M-CLIENT-01_analyse_20261107T213241659Z_CC-W11-01_CaptureC23` | `556D25DD6257F949925480656837D725ED8E1187C2F74D740014B5F342710C10` |
