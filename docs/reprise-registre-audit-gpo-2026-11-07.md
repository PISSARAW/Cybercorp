# Reprise du registre, du blocage AUDIT et des GPO — 7 novembre 2026

À **11:42 Europe/Paris**, le registre actif contient **38 lignes uniques contrôlées**, le blocage AUDIT journalisé est réactivé et les quatre GPO sont cohérentes selon l'API native Microsoft. Les nouveaux essais sur W11 restent bloqués par le refus des identifiants du compte local de secours. Aucun nouveau `gpresult` ni essai métier n'est déclaré exécuté.

## Registre rapproché sur les sources

Les 12 lignes actives et les sept lignes historiques ont été comparées champ par champ au consolidé existant de 19 lignes. Métadonnées, chemins, tailles et empreintes concordent ; les 19 lignes ont été conservées sans modification de leurs champs.

Les quatre sources autonomes du matin ont été retrouvées dans `transfert/autonomie-20261107T073138986Z`, y compris les sous-dossiers Conftest. Leurs SHA-256 correspondent aux empreintes du [bilan autonome](avancement-autonome-2026-11-07.md). Avec C06, C12 et les deux PNG WAN déjà récupérés, les huit sources supplémentaires sont disponibles : **les empreintes couvrent les 27 pièces historiques**.

Ces huit pièces ont été copiées sans écrasement et inscrites avec des identifiants de récupération actuels. Les heures d'événement proviennent des champs UTC des JSON ; elles restent vides pour C06 et les PNG WAN, dont le fuseau ou l'heure exacte ne sont pas établis. Aucun ancien identifiant n'a été recréé depuis une capture. Le CSV historique exact à 27 lignes reste non retrouvé.

Trois manifestes antérieurs de diagnostic, réarmement et activation ont été référencés après vérification de leurs annexes, portant le registre à 30 lignes. Leurs mentions historiques `registered=false` restent intactes : l'inscription est ultérieure. Huit pièces principales de cette reprise ont ensuite été ajoutées : **38 lignes, identifiants et empreintes distincts**, sans anomalie de taille ou de SHA-256.

| Version | SHA-256 |
| --- | --- |
| Ancien actif de 12 lignes, préservé | `05FF3BB292B17D14F21A55EA576501AE73DB083E6DF6AA5D3471AE8D72FEC122` |
| Actif rapproché de 30 lignes | `783999F445BD94B48040E80A72720D3555FB61440339BA70FC42A2CCC37E7619` |
| Actif final de 38 lignes | `09B59BC57D56F8C5102F40F769E5F4BF0110CA3FED8256B6637B308F5530A171` |

Le candidat a été contrôlé avant remplacement atomique, avec sauvegarde `registre-avant-rapprochement-20261107T102056488Z.csv`. Les versions antérieures restent conservées. La cause de la réapparition de l'actif de 12 lignes demeure inconnue ; la disponibilité et la couverture des pièces sont rapprochées sans prétendre expliquer cette cause.

## Blocage AUDIT réactivé

pfSense a été repris seul en complément du DC, avec plus de 2,5 Gio libres avant reprise et plus de 1,5 Gio après. Kali est resté enregistré et W11 arrêté pendant cette intervention. Le WAN est resté déconnecté et aucun NAT n'a été créé.

Les configurations complètes avant/après sont chiffrées avec DPAPI CurrentUser sur l'hôte et leur déchiffrement vérifié. La seule modification des règles est le retrait de `disabled` sur le tracker **1792264179** : blocage IPv4 depuis AUDIT vers toute destination, journalisation conservée. Les trois autres règles et les alias sont inchangés.

Après rechargement normal, `pfctl -sr` montre `block drop in log quick on hn2 inet from <OPT1__NETWORK> to any`, tracker 1792264179. Cette lecture vérifie la [règle interprétée par PF](https://docs.netgate.com/pfsense/en/latest/firewall/pf-ruleset.html). Aucun paquet de test depuis Kali ni scénario d'exception n'a été exécuté ; T03/T04 restent non démontrés. La règle existante concerne IPv4, sans extension de sa portée à IPv6. pfSense a ensuite été remis en état Saved.

## Incohérence GPO corrigée et contre-contrôlée

Les lectures natives ont confirmé quatre GPO présentes dans AD et SYSVOL, versions concordantes. `IsAclConsistent()` retournait `False` sur les deux GPO par défaut et `True` sur les deux GPO CyberCorp. La différence de propriétaire ne suffisait donc pas à écarter cette incohérence.

Avant correction, les deux GPO natives ont été sauvegardées par `Backup-GPO`, leurs SDDL et les empreintes des fichiers SYSVOL relevées, puis les huit fichiers de sauvegarde copiés et vérifiés sur l'hôte. La méthode native [Gpo.MakeAclConsistent()](https://learn.microsoft.com/en-us/previous-versions/windows/desktop/wmi_v2/class-library/gpo-makeaclconsistent-method-microsoft-grouppolicy) a été exécutée sur ces deux GPO seulement. Microsoft décrit la [remise en cohérence des permissions SYSVOL avec AD](https://learn.microsoft.com/en-us/troubleshoot/windows-server/group-policy/permissions-this-gpo-inconsistent).

| GPO | Cohérence native après | Versions AD/SYSVOL | Propriétaire SYSVOL conservé |
| --- | --- | --- | --- |
| CC-Domaine-Comptes | `True` | Concordantes | Admins du domaine |
| CC-Postes-Securite | `True` | Concordantes | Admins du domaine |
| Default Domain Policy | `True` | Concordantes | Administrateurs intégrés |
| Default Domain Controllers Policy | `True` | Concordantes | Administrateurs intégrés |

Pour les deux GPO corrigées, **ACL AD, versions AD et SHA-256 de tous les fichiers de stratégie sont inchangés**. Les exports natifs finaux comprennent permissions, SDDL, ACL des fichiers et sous-dossiers, liens et membres des groupes administratifs. Aucune ACE Allow d'écriture vers un bénéficiaire non administratif n'a été détectée dans ce périmètre. `CREATOR OWNER` (`S-1-3-0`) est présenté séparément comme marqueur d'héritage, sans l'assimiler à un compte métier. Ce contrôle ne couvre pas toutes les délégations possibles du domaine.

Les huit erreurs SID/GUID du rapport GPOZaurr historique ne sont pas déclarées corrigées dans le logiciel : les permissions ont été vérifiées indépendamment avec les outils natifs. Après alignement, `dcdiag` Advertising/SysVolCheck/NetLogons retourne 0 sans erreur, SYSVOL/NETLOGON sont présents, la licence reste activée et aucun événement 1074 depuis l'amorçage n'est trouvé. Une nouvelle collecte M03 confirme le dossier Livraison.

## Poste et essais métier encore bloqués

Après remise de pfSense en état enregistré, W11 a été démarré seul en complément du DC. Mémoire libre après démarrage : **1,953 Gio**, au-dessus de la marge de 1,5 Gio. Kali/pfSense restent Saved ; WAN déconnecté et aucun WinNAT.

Deux premières tentatives PowerShell Direct avec `local-admin` ont été refusées. L'utilisateur a ensuite fourni un identifiant chiffré DPAPI hors dépôt ; cet essai a également été refusé après 11:46 Europe/Paris. Le fichier est lisible sous le compte hôte et la pulsation Hyper-V est normale. Aucun essai supplémentaire, réinitialisation de compte ou affaiblissement de GPO n'a été effectué. Une vérification de l'ouverture de session `.\local-admin` dans la console Hyper-V a été demandée pour distinguer compte et transport ; Microsoft décrit les [conditions et erreurs PowerShell Direct](https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v/powershell-direct). Le fichier d'identification n'est pas une preuve et n'est ni archivé ni versionné.

Les contrôles AD montrent `usr.fin02` et `usr.com01` actifs, non verrouillés et sans mot de passe expiré. Les deux comptes Direction exigent leur premier changement de mot de passe (`PasswordLastSet` absent, `PasswordExpired=True`). Leurs groupes accordent la lecture de Syntheses ; `DL_SYNTHESES_MODIFY` ne contient aucun membre récursif. Les ACL SMB/NTFS ont été inventoriées ; elles ne remplacent pas des essais d'accès.

Deux auxiliaires sont préparés dans le coffre : collecte W11 (`gpupdate`, `gpresult` HTML/XML, canal sécurisé, DNS, Defender, SMBv1, pare-feu), puis essais SMB sous des jetons métier frais. Leur syntaxe PowerShell est vérifiée ; **ils n'ont pas été exécutés sur W11**. Les essais prévus couvrent Finance autorisée, refus interservice Commercial/Finance et Finance/Clients, Clients autorisé, Direction/Syntheses en lecture seule. Seuls des fichiers synthétiques uniques sont prévus, avec suppression contrôlée.

L'application actuelle des GPO sur le poste, T08/T09 et l'authentification métier fraîche restent non démontrées. Aucune validation complète de recette ou décision de remise n'est prononcée.

## Preuves conservées

Les pièces restent dans le coffre M-CLIENT-01, hors Git et OneDrive. **33 fichiers** ont été copiés sous `brut`, tailles et SHA-256 comparés. Manifeste `transfert/manifest-reprise-20261107T104240038Z.json`, SHA-256 `60E3856D0A137BAF75A5D912AE700C63365B462C493CB4C4766D8F9CDA84D0F6`.

| Pièce principale inscrite | Identifiant |
| --- | --- |
| Rapprochement à 30 lignes | `M-CLIENT-01_autre_20261107T104240627Z_MONNOKOELOBA_Rapprochement` |
| AUDIT réactivé | `M-CLIENT-01_autre_20261107T104240674Z_CC-PFS01_pfSense` |
| Gouvernance après correction | `M-CLIENT-01_gpo_20261107T104240708Z_CC-DC01_PowerShell` |
| Alignement et comparaison avant/après | `M-CLIENT-01_gpo_20261107T104240735Z_CC-DC01_GroupPolicy` |
| Santé AD après correction | `M-CLIENT-01_gpo_20261107T104240760Z_CC-DC01_dcdiag` |
| M03 actualisée avant correction | `M-CLIENT-01_gpo_20261107T104240774Z_CC-DC01_PowerShell` |
| Accès W11 refusé | `M-CLIENT-01_poste_20261107T104240804Z_CC-W11-01_PowerShellDirect` |
| Manifeste des 33 annexes | `M-CLIENT-01_autre_20261107T104240813Z_MONNOKOELOBA_Manifeste` |

Les sauvegardes sur le même hôte ne constituent pas une sauvegarde indépendante pour T14/T15. La relecture des extraits de remise et la décision humaine restent distinctes de ces contrôles techniques.
