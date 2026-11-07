# Infrastructure, DNS et Active Directory

## CONV-001 — Tableau de bord pfSense

Capture transcrite : `codex-clipboard-b2552e17-595f-4971-a250-a593153fd526.png`.

- Hôte : `cc-pfs01.ad.cybercorp.test`
- Plateforme : machine virtuelle Hyper-V
- Version : pfSense CE `2.9.0-RELEASE (amd64)`
- LAN : `10.77.10.1`, interface active
- AUDIT : `10.77.20.1`, interface active
- WAN : `172.31.250.2`, interface affichée inactive

Conclusion : les interfaces LAN et AUDIT correspondent au plan d'adressage. Cette capture ne prouve pas à elle seule les règles de filtrage.

## CONV-002 — Inventaire initial des zones DNS

Capture transcrite : `codex-clipboard-eee0378b-1f3e-45ea-b61c-4d1da6991640.png`.

Zones visibles : `_msdcs.ad.cybercorp.test`, `ad.cybercorp.test`, `0.in-addr.arpa`, `127.in-addr.arpa`, `255.in-addr.arpa` et `TrustAnchors`. Les zones AD sont intégrées à l'annuaire et utilisent les mises à jour dynamiques sécurisées.

## CONV-003 — Zone inversée du LAN

Capture transcrite : `codex-clipboard-6c49e7f2-09bd-494a-a67b-0f7bcab68722.png`.

```text
ZoneName            : 10.77.10.in-addr.arpa
ZoneType            : Primary
IsDsIntegrated      : True
IsReverseLookupZone : True
DynamicUpdate       : Secure
ReplicationScope    : Domain
```

## CONV-004 — Enregistrements A

Capture transcrite : `codex-clipboard-c87d9e96-4852-4169-b298-b2d5ec1eeb90.png`.

```text
HostName   IPv4Address
cc-dc01    10.77.10.10
CC-W11-01  10.77.10.100
```

## CONV-005 — Résolution inverse

Capture transcrite : `codex-clipboard-c079327e-2529-42ef-ab60-7fc49d5beb11.png`.

```text
10.10.77.10.in-addr.arpa   PTR   cc-dc01.ad.cybercorp.test
100.10.77.10.in-addr.arpa  PTR   cc-w11-01.ad.cybercorp.test
```

## CONV-006 — Enregistrement SRV du contrôleur de domaine

Capture transcrite : `codex-clipboard-188388d9-d373-4dc7-9f18-f27de9ef4a74.png`.

```text
Name       : _ldap._tcp.dc._msdcs.ad.cybercorp.test
Type       : SRV
NameTarget : cc-dc01.ad.cybercorp.test
Priority   : 0
Weight     : 100
Port       : 389
IPv4Address: 10.77.10.10
```

## CONV-007 — Structure d'OU initiale

Capture transcrite : `codex-clipboard-64b90437-af0a-4f3d-a035-57eb6e2e04b6.png`. `OU=CyberCorp` et `OU=Postes,OU=CyberCorp` apparaissent protégées contre la suppression accidentelle.

## CONV-008 — Création des OU principales

Capture transcrite : `codex-clipboard-b9e75f13-119f-4674-ac88-6fc3f6a25123.png`. Sous `OU=CyberCorp`, `Admins`, `Desactives`, `Groupes`, `Postes`, `Tests` et `Utilisateurs` apparaissent protégées.

## CONV-009 — OU des services

```text
Name         ProtectedFromAccidentalDeletion
Commercial                              True
Direction                               True
Finance                                 True
Informatique                            True
RH                                      True
Technique                               True
```

Ces OU ont été créées sous `OU=Utilisateurs,OU=CyberCorp,DC=ad,DC=cybercorp,DC=test`.
