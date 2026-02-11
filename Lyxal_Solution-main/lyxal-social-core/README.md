# lyxal-social-core

Librairie Rust indépendante pour un runtime Social Connect conforme aux règles suivantes :

- Aucun lien ni dépendance avec SurrealDB pour l’instant. SurrealDB n’intègre que du code finalisé, testé et figé.
- Architecture figée avant toute intégration : runtime commun, providers découplés, erreurs normalisées, capabilities explicites.
- Tests unitaires et mocks HTTP obligatoires, aucun appel réseau réel, aucune fuite de secrets.
- Providers V1 : Discord (pilote) et TikTok (business) ; Meta et LinkedIn sont des stubs.

## Arborescence cible

```
lyxal-social-core/
 ├─ Cargo.toml
 ├─ README.md
 ├─ src/
 │  ├─ lib.rs
 │  ├─ error.rs
 │  ├─ types.rs
 │  ├─ capabilities.rs
 │  ├─ events.rs
 │  ├─ runtime/
 │  │  ├─ mod.rs
 │  │  ├─ http.rs
 │  │  ├─ oauth.rs
 │  │  ├─ retry.rs
 │  │  ├─ rate_limit.rs
 │  │  └─ secret_store.rs
 │  ├─ providers/
 │  │  ├─ mod.rs
 │  │  ├─ discord.rs
 │  │  ├─ tiktok.rs
 │  │  ├─ meta.rs
 │  │  └─ linkedin.rs
 └─ tests/
    ├─ runtime_tests.rs
    ├─ discord_mock.rs
    └─ tiktok_mock.rs
```

## Principes clés

- Isolation : aucun lien SurrealDB tant que le module n’est pas figé. SurrealDB n’intègre que du code finalisé, testé et figé.
- Capabilities-based : aucune action sans capability explicite (publish/messages/comments/stats/scheduling).
- Erreurs normalisées : SOCIAL_* avec code, provider, action, message court, request_id optionnel ; zéro secret dans les erreurs.
- Sécurité runtime : HTTP TLS only, timeouts stricts, user-agent stable, pas de redirections libres, secret store abstrait (pas de fuite de tokens), rate-limit par provider/account, retry 429/5xx seulement.
- Tests : unitaires + mocks HTTP, aucun appel réseau réel, aucun secret dans les logs.

## Architecture fonctionnelle

- `runtime/` : clients HTTP/OAuth (traits), retry/backoff, rate-limit, secret store. Implémentations en mémoire (stubs sûrs) et noop.
- `providers/` :
  - Discord (bot token) : action supportée `send_message`. Capabilities : messages=true, publish/stats/comments/scheduling=false.
  - TikTok (OAuth2 + refresh) : actions `publish`, `fetch_stats` si scopes autorisés. Capabilities dynamiques selon scopes.
  - Meta, LinkedIn : stubs (capabilities none).
- `capabilities.rs` : structure Capabilities et presets (none, discord_messages_only, tiktok scoped).
- `error.rs` : SocialErrorCode, SocialError, SocialResult.
- `types.rs` : ProviderKind, SocialAction, types de payloads/messages/stats.
- `events.rs` : événements internes (message sent, stats fetched, published…).

## État actuel (implémenté)

- Discord : validation des arguments, rate-limit, mapping d’erreurs (401/403→PERMISSION_DENIED, 429→RATE_LIMITED, 4xx→INVALID_ARGUMENT, 5xx→PROVIDER_ERROR). Pas d’appel réseau en tests (mocks).
- TikTok : OAuth2 + refresh, capabilities par scopes, publish/fetch_stats, mapping d’erreurs (400/401/403/429/5xx), refresh token si expiré (mockable). Pas d’appel réseau en tests.
- Runtime : HTTP/Retry/RateLimit/SecretStore/OAuth en mémoire, aucun secret exposé.
- Tests : `cargo test` passe (0 warning) ; suites runtime/discord/tiktok 100 % mockées.

## Intégration moteur (glue optionnelle, non activée)

- Dépendance optionnelle dans SurrealDB : `lyxal-social-core` (feature non activée par défaut).  
- Bindings glue (social::providers/capabilities/send_message/publish/fetch_stats) : parsing args, appel crate, mapping erreurs, stubs HTTP/OAuth (zéro réseau, zéro secret). Aucune logique provider dans le moteur.  
- Le build global dépend encore des corrections iCal (géré par une autre équipe).

## Roadmap CTO (phases)

- S1 Inventaire exhaustif (par provider) : lister 100 % des endpoints officiels, auth, scopes, quotas, webhooks, permissions. Pas de nouveau code tant que S1 n’est pas complet.
- S2 Implémentation exhaustive : endpoint par endpoint + tests mockés pour chaque endpoint. Un provider n’est “done” que si l’inventaire est couvert à 100 %.
- S3 Bindings moteur exhaustifs : mapping 1–1 vers SurrealQL, zéro logique métier, zéro simplification.
- S4 Docs & contrats : doc technique, doc moteur, doc IA/contrats.

## Règles non négociables

- Pas de DEFINE FUNCTION, pas de tables CRUD, pas d’UI, pas de workflow, pas d’appels réseau réels en tests.
- Pas de fuite de token (secret store uniquement).
- Pas de dépendance SurrealQL/runtime avant validation CTO finale.

