# Gap Analysis (Logto vs Lyxal)

Ce document recense les champs ou fonctionnalités de Logto identifiés lors de l'analyse mais volontairement mis de côté pour une implémentation ultérieure.

## Applications

| Champ Logto | Fichier Logto | Statut Lyxal | Notes |
|---|---|---|---|
| `cors_allowed_origins` | `applications.sql` | ⏳ À faire | Sécurité AJAX. À ajouter dans `vault_app/oidc` ou `vault_app/security`. |
| `id_token_ttl` | `applications.sql` | ⏳ À faire | Durée de vie des tokens. À ajouter dans `vault_app/policy`. |
| `access_token_ttl` | `applications.sql` | ⏳ À faire | Idem. |
| `refresh_token_ttl` | `applications.sql` | ⏳ À faire | Idem. |
| `rotate_refresh_token` | `applications.sql` | ⏳ À faire | Politique de rotation. |
| `slug` | `applications.sql` | ⏳ À faire | URL friendly pour l'app ? |

## Core Identity

*(Rien pour l'instant, couverture 100%)*
