# Feuille de route — `lyxal_host`

Évolutions prévues de la bibliothèque des hôtes. L'état actuel est décrit dans le
[`README.md`](README.md). Aucune étape ne démarre sans ordre du CTO et `implementation_plan.md`
validé (`.agents/AGENTS.md` §3).

| Étape | Thème | Dépendances |
| :--- | :--- | :--- |
| 1 | Second hôte `lyxal-groupware` | lot 3 du programme courrier (3b, 3c) |

---

## 1. Second hôte `lyxal-groupware`

Plan : `apps/lyxal-groupware/implementation_plan.md` (lot 3 du programme courrier, demandes de
fusion 3b et 3c). `lyxal-groupware` démarre par `lyxal_host` comme `lyxal-server`.

Critères d'acceptation :

- [ ] `lyxal-groupware` utilise `load_layered` (préfixe `LYXAL_GROUPWARE`), `connect_database`,
      `install_foundation` (définitions `GROUPWARE_*`), `health_routes`, `serve`, `shutdown`,
      `telemetry` et `build::embed_modules`, sans recopie ;
- [ ] `serve_connection` sert le port HTTP de l'hôte sur un flux déjà passé par PROXY ou TLS ;
- [ ] `net::log_network` : adresse d'un client masquée à son réseau pour le journal (IPv4 `/24`,
      IPv6 `/48`), ajoutée avec son premier appelant ;
- [ ] aucun code porté AGPL ou GPL dans ce crate (relecture et contrôle de CI de l'isolement AGPL).
