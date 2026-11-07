# Partages, ACL et tests fonctionnels

## CONV-020 — Volume de données et état initial

Capture transcrite : `codex-clipboard-e1e8448b-7ea1-4f58-ac9d-7d01ca8eb494.png`.

- Lecteur `E:`, étiquette `DATA`, NTFS, état `Healthy`, environ 32 Gio
- `E:\Partages` absent au contrôle initial
- aucun partage métier visible avant création

## CONV-021 — Arborescence créée

Capture transcrite : `codex-clipboard-4cf39303-1b6e-43b4-bfed-116f1d04711f.png`.

```text
Clients    E:\Partages\Clients
Commun     E:\Partages\Commun
Finance    E:\Partages\Finance
RH         E:\Partages\RH
Syntheses  E:\Partages\Syntheses
Technique  E:\Partages\Technique
```

## CONV-022 — Application des ACL NTFS

Capture transcrite : `codex-clipboard-94c2f4c0-b31c-425d-b4e7-0cba17c287fd.png`. Les sept chemins contrôlés affichent `Protected=True` et `Inherited=0`, puis :

```text
ACL NTFS appliquées. Aucun partage SMB n'a été créé.
```

## CONV-023 — Export détaillé des ACL

Capture transcrite : `codex-clipboard-ff49e763-5e8a-4d91-80af-2efa4a718aa1.png`.

- `AUTORITE NT\Système` : `FullControl`
- `BUILTIN\Administrateurs` : `FullControl`
- groupe `CYBERCORP\DL_*_MODIFY` correspondant : `Modify, Synchronize`
- groupes de lecture Commun et Syntheses : `ReadAndExecute, Synchronize`
- toutes les entrées affichées avec `Heritee=False`

## CONV-024 — Création des partages SMB

Capture transcrite : `codex-clipboard-a22656f2-5786-4ac2-b8b8-bed683834d3a.png`.

Les partages `Commun`, `Finance`, `RH`, `Clients`, `Technique` et `Syntheses` affichent `AccessBased=True` et `NoCache=True`. Message final : `Partages SMB créés et contrôlés.`

## CONV-025 — Droits de partage SMB

Capture transcrite : `codex-clipboard-af101738-e0cc-4609-88cb-b40553bd5e0d.png`.

- Administrateurs : `Full`, `Allow`
- groupes `DL_*_MODIFY` : `Change`, `Allow`
- groupes de lecture Commun et Syntheses : `Read`, `Allow`
- aucune entrée `Everyone` visible

## CONV-026 — Refus RDP attendu

Capture transcrite : `codex-clipboard-5b92462c-7725-4b8e-b7e1-366693051093.png`. La session améliorée Hyper-V indique que le compte métier n'est pas autorisé à utiliser les Services Bureau à distance. Aucun droit RDP n'a été ajouté.

## CONV-027 — Identité de la session locale

Capture transcrite : `codex-clipboard-ab013bf5-836a-4e81-96fe-b8e62ec7b86f.png`.

```text
whoami
cybercorp\usr.fin01
```

La capture `codex-clipboard-e4c8e584-9772-4220-a24d-088cd6ff12ef.png` contient des erreurs de copie du prompt PowerShell, sans défaut AD démontré.

## CONV-028 — Modification autorisée dans Finance

Capture transcrite : `codex-clipboard-0ae489f9-dd4b-4423-9ed3-66bb23704a96.png`.

`cybercorp\usr.fin01` a créé puis relu `\\CC-DC01\Finance\T08_usr.fin01.txt`. Contenu relu :

```text
Test ACL Finance reussi par cybercorp\usr.fin01
```

## CONV-029 — Refus interservice Clients

Constat déclaré : la lecture de `\\CC-DC01\Clients\_DONNEES-FICTIVES.txt` par `usr.fin01` a été refusée. La capture originale n'est plus disponible localement.

## CONV-030 — Lecture seule sur Commun

Capture transcrite : `codex-clipboard-429c2a53-9ec6-4849-837f-d9e53b94da45.png`.

- lecture de `\\CC-DC01\Commun\_DONNEES-FICTIVES.txt` réussie
- création de `T08_usr.fin01-interdit.txt` refusée
- message visible : accès au chemin refusé

Le contre-test `usr.com01` vers `Finance` était alors explicitement reporté et n'est pas déclaré réussi ici.
