# Feuille de route — `lyxal_parsing`

Évolutions prévues. L'état actuel est décrit dans le [`README.md`](README.md). Aucune étape ne
démarre sans ordre du CTO et `implementation_plan.md` validé (`.agents/AGENTS.md` §3).

| Étape | Thème | Dépendances |
| :--- | :--- | :--- |
| 1 | Adaptateurs de `lyxal_pipeline_ingestion` sur `lyxal_parsing` (constat A05 de l'audit externe) | — |

D'autres formats (XLSX…) ou encodages déclarés n'entrent dans cette feuille de route que sur un
besoin produit validé par le CTO.

---

## 1. Adaptateurs de l'ingestion

Les adaptateurs CSV, JSON, XML et FAB-DIS de `lyxal_pipeline_ingestion` lisent aujourd'hui les
formats à la main. Ils passent sur les lecteurs de ce crate : la correspondance des colonnes et
balises reste dans l'ingestion, et chaque rejet `PARSING_*` y est consigné en quarantaine avec
sa position.
