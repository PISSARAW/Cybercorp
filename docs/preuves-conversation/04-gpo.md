# Stratégies de groupe

## CONV-031 — Inventaire initial

Seules `Default Domain Policy` et `Default Domain Controllers Policy` existaient initialement. Les liaisons natives ont été observées à la racine du domaine et sur l'OU `Domain Controllers`. Les OU `Postes` et `Tests` ne possédaient aucune liaison directe CyberCorp.

## CONV-032 — Liaison de `CC-Domaine-Comptes`

```text
DisplayName           Enabled Enforced Order
CC-Domaine-Comptes       True    False     1
Default Domain Policy    True    False     2
```

## CONV-033 — Première configuration non persistée

Les captures `codex-clipboard-f5e8495d-a4f0-45c7-b208-610a89d51113.png` et `codex-clipboard-fe7ef4b7-2e61-43ca-a0c6-97738d117fb5.png` semblaient montrer longueur 14, historique 24, complexité active, seuil 5 et durées de 15 minutes. Les contrôles canoniques suivants ont démontré que ces valeurs n'avaient pas été enregistrées. Elles constituent une preuve de diagnostic, pas la validation finale.

## CONV-034 — État effectif incorrect avant correction

Capture transcrite : `codex-clipboard-0839f2d4-7461-4c6f-97b9-784d2515fc3b.png`.

```text
ComplexityEnabled        : True
MinPasswordLength        : 8
PasswordHistoryCount     : 20
LockoutThreshold         : 0
LockoutDuration          : 00:15:00
LockoutObservationWindow : 00:15:00
MinPasswordAge           : 50.00:00:00
MaxPasswordAge           : 51.00:00:00
```

## CONV-035 — Application confirmée pendant le diagnostic

```text
Objets Stratégie de groupe appliqués
Default Domain Controllers Policy
CC-Domaine-Comptes
Default Domain Policy
```

Ce `gpresult` prouvait que le problème venait du contenu enregistré, et non du lien ou du filtrage.

## CONV-036 — Rapport XML avant correction

```text
MinimumPasswordLength : 8
PasswordComplexity    : true
PasswordHistorySize   : 20
LockoutBadCount       : ABSENT
LockoutDuration       : ABSENT
ResetLockoutCount     : ABSENT
```

## CONV-037 — Métadonnées de `CC-Domaine-Comptes`

```text
DisplayName      : CC-Domaine-Comptes
Id               : 298f55fa-3cc2-4bb8-97be-d4051ee2ad18
GpoStatus        : AllSettingsEnabled
CreationTime     : 18/10/2026 22:26:29
ModificationTime : 19/10/2026 12:16:06
```

## CONV-038 — Mot de passe enregistré après correction

Capture transcrite : `codex-clipboard-865549b5-43c1-4029-b960-b660271f103b.png`.

- historique : 24 mots de passe
- complexité : activée
- longueur minimale : 14 caractères
- durées minimale et maximale : non définies dans cette GPO

La capture `codex-clipboard-dbbc3d3c-5f0e-4ca1-b682-148988d40c79.png` conserve l'état erroné précédent : historique 20, âges 50/51 jours et longueur 8.

## CONV-039 — Verrouillage avant et après correction

Avant réglage, `codex-clipboard-607d8b5a-e377-4d2e-97c5-8fb648204993.png` montre les quatre paramètres non définis.

Après réglage, `codex-clipboard-884bb143-95e2-4e66-a008-7f75266b65ba.png` montre :

- verrouillage du compte Administrateur : non défini
- durée : 15 minutes
- remise à zéro du compteur : 15 minutes
- seuil : 5 tentatives

## CONV-040 — Rapport XML canonique après correction

```text
MinimumPasswordLength = 14
PasswordComplexity    = true
PasswordHistorySize   = 24
LockoutBadCount       = 5
LockoutDuration       = 15
ResetLockoutCount     = 15
```

## CONV-041 — Politique effective finale

Après `gpupdate.exe /target:computer /force`, la mise à jour s'est terminée sans erreur :

```text
ComplexityEnabled        : True
MinPasswordLength        : 14
PasswordHistoryCount     : 24
LockoutThreshold         : 5
LockoutDuration          : 00:15:00
LockoutObservationWindow : 00:15:00
MinPasswordAge           : 1.00:00:00
MaxPasswordAge           : 42.00:00:00
```

Les âges de 1 et 42 jours proviennent de la stratégie de domaine existante.

## CONV-042 — Création et liaison de `CC-Postes-Securite`

```text
GpoId       : 3015c53f-bc8e-429d-a136-e6da096924ce
DisplayName : CC-Postes-Securite
Enabled     : True
Enforced    : False
Target      : OU=Postes,OU=CyberCorp,DC=ad,DC=cybercorp,DC=test
Order       : 1
```

Contrôle :

```text
DisplayName        Enabled Enforced Order
CC-Postes-Securite    True    False     1
```

Aucune preuve archivée ici ne confirme encore la configuration effective du pare-feu, de Defender, du verrouillage d'écran, de SMBv1 ou de l'accès invité SMB dans cette GPO.
