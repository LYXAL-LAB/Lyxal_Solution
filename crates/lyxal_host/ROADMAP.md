# Feuille de route — `lyxal_host`

Évolutions prévues de la bibliothèque des hôtes. L'état actuel est décrit dans le
[`README.md`](README.md). Aucune étape ne démarre sans ordre du CTO et `implementation_plan.md`
validé (`.agents/AGENTS.md` §3).

| Étape | Thème | Dépendances |
| :--- | :--- | :--- |
| 1 | Port HTTP de `lyxal-groupware` derrière PROXY ou TLS | lot 3 du programme courrier (3c) |

---

## 1. Port HTTP de `lyxal-groupware` derrière PROXY ou TLS

Plan : `apps/lyxal-groupware/implementation_plan.md` (lot 3 du programme courrier, demande de
fusion 3c). `lyxal-groupware` démarre déjà par `lyxal_host` comme `lyxal-server`
(`load_layered` au préfixe `LYXAL_GROUPWARE`, `connect_database`, `install_foundation` avec les
définitions `GROUPWARE_*`, `health_routes`, `serve`, `shutdown`, `telemetry`,
`build::embed_modules`, `net::log_network`).

Critères d'acceptation :

- [ ] `serve_connection` sert le port HTTP de l'hôte sur un flux déjà passé par PROXY ou TLS ;
- [ ] aucun code porté AGPL ou GPL dans ce crate (relecture ; le contrôle de CI
      `scripts/ci/check_agpl_isolation.py` garantit déjà qu'il ne dépend d'aucun paquet AGPL).
