# Inventaire complet — Discord API (Phase S1)

Source unique : documentation officielle Discord API (https://discord.com/developers/docs et https://github.com/discord/discord-api-docs).

Principes : 1 endpoint officiel = 1 entrée. Pas de code. Pas de logique. Nommage stable pour futur binding.

## Auth / OAuth2
- `GET /oauth2/authorize` — Authorize URL (scopes, redirect_uri, response_type, state).
- `POST /oauth2/token` — Exchange code ↔ token (authorization_code / refresh_token / client_credentials).
- `POST /oauth2/token/revoke` — Revoke token.
- Scopes : `identify`, `email`, `connections`, `guilds`, `guilds.join`, `gdm.join`, `rpc`, `rpc.*`, `activities.read|write`, `applications.commands`, `applications.commands.update`, `webhook.incoming`, `bot` (adds bot user), etc.
- Rate limit : standard route limits ; 401/403 on invalid client/secret; 429 with `retry_after`.

## Users & Connections
- `GET /users/@me`
- `GET /users/@me/guilds` (pagination `before/after`, `limit`)
- `GET /users/@me/guilds/{guild_id}/member`
- `PATCH /users/@me` (username/avatar)
- `GET /users/@me/connections`
- `GET /users/@me/channels` (DMs)
- `POST /users/@me/channels` (Create DM/Group DM)
- Rate limit : per-route; 401/403 invalid token; 429 retry headers.

## Guilds
- `POST /guilds` (create)
- `GET /guilds/{guild_id}`
- `PATCH /guilds/{guild_id}`
- `DELETE /guilds/{guild_id}`
- `GET /guilds/{guild_id}/preview`
- `GET /guilds/{guild_id}/channels`
- `POST /guilds/{guild_id}/channels`
- `PATCH /guilds/{guild_id}/channels` (bulk reorder)
- `GET /guilds/{guild_id}/members` (pagination `limit`, `after`)
- `GET /guilds/{guild_id}/members/{user_id}`
- `PUT /guilds/{guild_id}/members/{user_id}`
- `PATCH /guilds/{guild_id}/members/@me`
- `PATCH /guilds/{guild_id}/members/{user_id}`
- `PUT /guilds/{guild_id}/members/{user_id}/roles/{role_id}`
- `DELETE /guilds/{guild_id}/members/{user_id}/roles/{role_id}`
- `DELETE /guilds/{guild_id}/members/{user_id}` (kick)
- `PUT /guilds/{guild_id}/bans/{user_id}` / `DELETE /guilds/{guild_id}/bans/{user_id}`
- `GET /guilds/{guild_id}/bans` (pagination `before/after`, `limit`)
- `GET /guilds/{guild_id}/bans/{user_id}`
- `GET /guilds/{guild_id}/roles`
- `POST /guilds/{guild_id}/roles`
- `PATCH /guilds/{guild_id}/roles` (reorder)
- `PATCH /guilds/{guild_id}/roles/{role_id}`
- `DELETE /guilds/{guild_id}/roles/{role_id}`
- `GET /guilds/{guild_id}/prune` / `POST /guilds/{guild_id}/prune`
- `GET /guilds/{guild_id}/voice-states/@me`
- `GET /guilds/{guild_id}/regions`
- `GET /guilds/{guild_id}/invites`
- `GET /guilds/{guild_id}/integrations`
- `DELETE /guilds/{guild_id}/integrations/{id}`
- `GET /guilds/{guild_id}/widget`
- `PATCH /guilds/{guild_id}/widget`
- `GET /guilds/{guild_id}/welcome-screen`
- `PATCH /guilds/{guild_id}/welcome-screen`
- `GET /guilds/{guild_id}/onboarding`
- `GET /guilds/{guild_id}/safety-alerts-channel`
- Rate limits : route-based; some admin routes stricter.

## Channels / Messages / Threads
- `GET /channels/{channel_id}`
- `PATCH /channels/{channel_id}`
- `DELETE /channels/{channel_id}`
- `GET /channels/{channel_id}/messages` (pagination `around`, `before`, `after`, `limit`)
- `GET /channels/{channel_id}/messages/{message_id}`
- `POST /channels/{channel_id}/messages` (send message; supports embeds/components/attachments)
- `PATCH /channels/{channel_id}/messages/{message_id}`
- `DELETE /channels/{channel_id}/messages/{message_id}`
- `POST /channels/{channel_id}/messages/bulk-delete`
- Reactions :
  - `PUT /channels/{channel_id}/messages/{message_id}/reactions/{emoji}/@me`
  - `DELETE /channels/{channel_id}/messages/{message_id}/reactions/{emoji}/@me`
  - `DELETE /channels/{channel_id}/messages/{message_id}/reactions/{emoji}/{user_id}`
  - `GET /channels/{channel_id}/messages/{message_id}/reactions/{emoji}` (pagination `after`, `limit`)
  - `DELETE /channels/{channel_id}/messages/{message_id}/reactions`
- Pins :
  - `GET /channels/{channel_id}/pins`
  - `PUT /channels/{channel_id}/pins/{message_id}`
  - `DELETE /channels/{channel_id}/pins/{message_id}`
- Threads :
  - `POST /channels/{channel_id}/messages/{message_id}/threads` (start)
  - `POST /channels/{channel_id}/threads` (start without message)
  - `POST /channels/{channel_id}/threads/archived/public|private`
  - `GET /channels/{channel_id}/threads/archived/public|private`
  - `GET /channels/{channel_id}/threads/archived/private`
  - `GET /channels/{channel_id}/threads/active`
  - `PUT /channels/{channel_id}/thread-members/@me`
  - `DELETE /channels/{channel_id}/thread-members/@me`
  - `GET /channels/{channel_id}/thread-members/{user_id}`
- Webhooks :
  - `POST /channels/{channel_id}/webhooks`
  - `GET /channels/{channel_id}/webhooks`
  - `GET /webhooks/{webhook_id}`
  - `PATCH /webhooks/{webhook_id}`
  - `DELETE /webhooks/{webhook_id}`
  - `POST /webhooks/{webhook_id}/{token}` (execute)
  - `PATCH /webhooks/{webhook_id}/{token}`
  - `DELETE /webhooks/{webhook_id}/{token}`
  - `POST /webhooks/{webhook_id}/{token}/messages/{message_id}`
  - `PATCH /webhooks/{webhook_id}/{token}/messages/{message_id}`
  - `DELETE /webhooks/{webhook_id}/{token}/messages/{message_id}`
- Rate limits : route-based; messages typically 5/5s; bulk-delete limited; reactions limited; 429 with retry headers.

## Attachments / Upload
- Message creation support `attachments` (multipart), size limits par tier ; CDN upload via message create.

## Guild Scheduled Events
- `GET /guilds/{guild_id}/scheduled-events`
- `POST /guilds/{guild_id}/scheduled-events`
- `GET /guilds/{guild_id}/scheduled-events/{event_id}`
- `PATCH /guilds/{guild_id}/scheduled-events/{event_id}`
- `DELETE /guilds/{guild_id}/scheduled-events/{event_id}`
- `GET /guilds/{guild_id}/scheduled-events/{event_id}/users` (pagination `before/after`, `limit`)

## Stage Instances
- `POST /stage-instances`
- `GET /stage-instances/{channel_id}`
- `PATCH /stage-instances/{channel_id}`
- `DELETE /stage-instances/{channel_id}`

## Stickers / Emojis
- Emojis (guild) :
  - `GET /guilds/{guild_id}/emojis`
  - `GET /guilds/{guild_id}/emojis/{emoji_id}`
  - `POST /guilds/{guild_id}/emojis`
  - `PATCH /guilds/{guild_id}/emojis/{emoji_id}`
  - `DELETE /guilds/{guild_id}/emojis/{emoji_id}`
- Stickers (guild) :
  - `GET /guilds/{guild_id}/stickers`
  - `GET /guilds/{guild_id}/stickers/{sticker_id}`
  - `POST /guilds/{guild_id}/stickers`
  - `PATCH /guilds/{guild_id}/stickers/{sticker_id}`
  - `DELETE /guilds/{guild_id}/stickers/{sticker_id}`
- Nitro/Sticker Packs :
  - `GET /sticker-packs`

## Invites
- `GET /invites/{invite_code}` (with counts/expiration optional)
- `DELETE /invites/{invite_code}`
- `POST /channels/{channel_id}/invites`
- `GET /guilds/{guild_id}/invites`

## Voice
- `GET /voice/regions`
- `GET /guilds/{guild_id}/voice-states/{user_id}`
- `PATCH /guilds/{guild_id}/voice-states/@me`
- `PATCH /guilds/{guild_id}/voice-states/{user_id}`

## Interactions / Application Commands
- Application commands (global) :
  - `GET /applications/{application_id}/commands`
  - `POST /applications/{application_id}/commands`
  - `GET /applications/{application_id}/commands/{command_id}`
  - `PATCH /applications/{application_id}/commands/{command_id}`
  - `DELETE /applications/{application_id}/commands/{command_id}`
  - `PUT /applications/{application_id}/commands` (bulk overwrite)
- Application commands (guild) :
  - `GET /applications/{application_id}/guilds/{guild_id}/commands`
  - `POST /applications/{application_id}/guilds/{guild_id}/commands`
  - `GET /applications/{application_id}/guilds/{guild_id}/commands/{command_id}`
  - `PATCH /applications/{application_id}/guilds/{guild_id}/commands/{command_id}`
  - `DELETE /applications/{application_id}/guilds/{guild_id}/commands/{command_id}`
  - `PUT /applications/{application_id}/guilds/{guild_id}/commands` (bulk overwrite)
- Command permissions (deprecated v10; check current status).
- Interaction responses :
  - `POST /interactions/{interaction_id}/{token}/callback`
  - `PATCH /webhooks/{application_id}/{interaction_token}/messages/@original`
  - `DELETE /webhooks/{application_id}/{interaction_token}/messages/{message_id|@original}`
  - `POST /webhooks/{application_id}/{interaction_token}` (follow-up)
- Rate limits : per-route; 429 with retry.

## Auto Moderation
- `GET /guilds/{guild_id}/auto-moderation/rules`
- `GET /guilds/{guild_id}/auto-moderation/rules/{rule_id}`
- `POST /guilds/{guild_id}/auto-moderation/rules`
- `PATCH /guilds/{guild_id}/auto-moderation/rules/{rule_id}`
- `DELETE /guilds/{guild_id}/auto-moderation/rules/{rule_id}`

## Audit Log
- `GET /guilds/{guild_id}/audit-logs` (filters: `user_id`, `action_type`, `before`, `limit`)

## Templates
- `GET /guilds/templates/{code}`
- `POST /guilds/templates/{code}`
- `GET /guilds/{guild_id}/templates`
- `POST /guilds/{guild_id}/templates`
- `PUT /guilds/{guild_id}/templates/{code}`
- `PATCH /guilds/{guild_id}/templates/{code}`
- `DELETE /guilds/{guild_id}/templates/{code}`

## Polls (messages)
- Via message creation with `poll` object (fields: question, answers, duration, allow_multiselect…).

## Permissions / Overwrites
- Channel overwrites in `PATCH /channels/{channel_id}` payload.
- Role & member permission overwrites creation via channel create/update.

## Rate Limits / Quotas
- Rate limits par route + global ; 429 avec `retry_after` et `X-RateLimit-*`.
- Webhook execute a ses propres limites ; bulk-delete limité à 2/jour par channel (historique).

## Webhooks / Events (Gateway)
- Événements (non exhaustif) : `MESSAGE_CREATE`, `MESSAGE_UPDATE`, `MESSAGE_DELETE`, `MESSAGE_REACTION_*`, `GUILD_CREATE/UPDATE/DELETE`, `CHANNEL_*`, `THREAD_*`, `TYPING_START`, `WEBHOOKS_UPDATE`, `INTERACTION_CREATE`, `VOICE_STATE_UPDATE`, `GUILD_SCHEDULED_EVENT_*`, `AUTO_MODERATION_*`.
- Auth Gateway via `OP 2 Identify` (intents).
- Rate limit Identify par shard.

## Pagination / filtres (exemples)
- Messages : `around`, `before`, `after`, `limit` (<=100).
- Guild members : `after`, `limit` (<=1000).
- Bans : `before/after`, `limit`.
- Scheduled event users : `before/after`, `limit`.
- Reactions : `after`, `limit`.

## Erreurs spécifiques / statuts
- 400: invalid form body / validation error.
- 401/403: token invalide, scopes/permissions manquants.
- 404: ressource inconnue ou non visible.
- 429: rate limited (respect `retry_after`; possible global).
- 500/502/504: erreurs serveur Discord, réessai conseillé.

## Permissions (authZ)
- Bot token : privilégier les permissions via intents + permissions de bot (guild permissions) ; scope `bot` ajoute le bot.
- OAuth user token : permissions basées sur scopes + rôle utilisateur ; `webhook.incoming` pour créer/exécuter un webhook.

## Notes de conformité
- Toutes les routes utilisent HTTPS.
- Pas de GET sans auth (sauf CDN public pour pièces jointes/stickers packs).
- Respecter intents pour Gateway.
- Ne pas logguer les tokens ni les payloads sensibles.

## Statut d’inventaire
- Discord : couvert endpoint par endpoint (v10) selon la doc officielle. Toute mise à jour de la doc doit entraîner une mise à jour de ce fichier avant implémentation.

