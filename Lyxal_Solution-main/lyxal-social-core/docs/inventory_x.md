# Inventaire complet — X (Twitter) API (Phase S1)

Sources officielles : X/Twitter API (v2 principalement, v1.1 pour media/upload, webhooks Account Activity), docs developer.twitter.com. 1 endpoint = 1 entrée. Aucun code.

## Auth
- OAuth 2.0 (User context) : `GET api.twitter.com/oauth2/authorize`, `POST api.twitter.com/oauth2/token` (code→token, refresh). Scopes : `tweet.read`, `tweet.write`, `users.read`, `follows.read|write`, `like.read|write`, `list.read|write`, `dm.read|write`, `offline.access`, `block.read|write`, `mute.read|write`, `space.read`, `media.read|write`, `bookmark.read|write`, `tweet.moderate.write`, `compliance.read`.
- OAuth 2.0 (App-only / bearer) : `POST oauth2/token` (client_credentials) — lecture publique.
- OAuth 1.0a (user context) : request_token, authenticate/authorize, access_token. Toujours requis pour certains webhooks/AAA v1.1 et uploads v1.1.

## Rate limits / tiers
- Limites par tier (Essential/Basic/Pro/Enterprise) et par endpoint ; 429 sur dépassement, headers `x-rate-limit-limit`, `x-rate-limit-remaining`, `x-rate-limit-reset`.
- Streaming : limites de connexions simultanées et backoff exponentiel.

## Tweets (v2)
- `GET /2/tweets` (by ids)
- `GET /2/tweets/:id`
- `POST /2/tweets` (create)
- `DELETE /2/tweets/:id`
- `POST /2/tweets/:id/hidden` (moderate replies)
- `POST /2/tweets/:id/liking_users` ? (liste) [actuel : GET liking_users/liked_tweets, POST likes separate]
- `POST /2/users/:id/likes` / `DELETE /2/users/:id/likes/:tweet_id`
- `POST /2/users/:id/retweets` / `DELETE /2/users/:id/retweets/:source_tweet_id`
- `GET /2/tweets/:id/liking_users`
- `GET /2/tweets/:id/retweeted_by`
- `POST /2/tweets/:id/bookmark` / `DELETE /2/users/:id/bookmarks/:tweet_id`
- Pagination : `pagination_token`, `max_results`.

## Timelines / Feeds
- `GET /2/users/:id/tweets`
- `GET /2/users/:id/mentions`
- `GET /2/users/:id/liked_tweets`
- `GET /2/users/:id/bookmarks`
- `GET /2/lists/:id/tweets`
- Pagination via `pagination_token`.

## Search / Filtering
- `GET /2/tweets/search/recent` (query, start_time, end_time, expansions, pagination)
- `GET /2/tweets/search/all` (Academic/Enterprise)
- Filtered stream :
  - `GET /2/tweets/search/stream`
  - `GET /2/tweets/search/stream/rules`
  - `POST /2/tweets/search/stream/rules` (add/del)
- Sample stream :
  - `GET /2/tweets/sample/stream` (optionnel filtered)
- Rate/connexions : limites strictes par tier; backoff sur 429/420/503.

## Users / Follows / Blocks / Mutes
- `GET /2/users` (by usernames)
- `GET /2/users/:id`
- `GET /2/users/by/username/:username`
- Follows :
  - `GET /2/users/:id/following`
  - `GET /2/users/:id/followers`
  - `POST /2/users/:id/following`
  - `DELETE /2/users/:source_user_id/following/:target_user_id`
- Blocks :
  - `GET /2/users/:id/blocking`
  - `POST /2/users/:id/blocking`
  - `DELETE /2/users/:source_user_id/blocking/:target_user_id`
- Mutes :
  - `GET /2/users/:id/muting`
  - `POST /2/users/:id/muting`
  - `DELETE /2/users/:source_user_id/muting/:target_user_id`
- Lists :
  - `GET /2/lists/:id`
  - `GET /2/lists/:id/followers`
  - `GET /2/lists/:id/members`
  - `POST /2/lists` (create)
  - `DELETE /2/lists/:id`
  - `PUT /2/lists/:id` (update title/desc/private)
  - `POST /2/lists/:id/members`
  - `DELETE /2/lists/:id/members/:user_id`
  - `POST /2/users/:id/followed_lists`
  - `DELETE /2/users/:id/followed_lists/:list_id`
- Pagination via `pagination_token`.

## Media
- v1.1 Upload API (toujours d’actualité) :
  - `POST media/upload` (chunked INIT/APPEND/FINALIZE)
  - `GET media/upload` (STATUS)
- v2 media endpoints (meta) : `POST /2/media` (init) selon doc si dispo.
- Scopes : `media.write`, OAuth 1.0a user.
- Rate : limites de taille/fichier et appels upload.

## Direct Messages (v2 modern)
- `GET /2/dm_conversations/with/:participant_id/dm_events`
- `GET /2/dm_conversations/:conversation_id/dm_events`
- `POST /2/dm_conversations/with/:participant_id/messages`
- `POST /2/dm_conversations/:conversation_id/messages`
- Attachments : via media upload v1.1 puis media_id.
- Permissions : `dm.read`, `dm.write`, `dm.participants.read`.
- Pagination : `pagination_token`.

## Spaces (Audio)
- `GET /2/spaces/:id`
- `GET /2/spaces` (by creator_ids)
- `GET /2/spaces/search` (query, state)
- `GET /2/spaces/:id/buyers` (ticketed)
- `GET /2/spaces/:id/tweets`
- Scopes : `space.read`.

## Bookmarks
- `GET /2/users/:id/bookmarks`
- `POST /2/users/:id/bookmarks`
- `DELETE /2/users/:id/bookmarks/:tweet_id`

## Compliance
- `POST /2/compliance/jobs` (type=tweets|users)
- `GET /2/compliance/jobs`
- `GET /2/compliance/jobs/:id`
- Webhook delivery (callback) si configuré pour compliance events (selon tier).

## Account Activity API (Webhooks, v1.1)
- Webhook registration :
  - `POST /1.1/account_activity/all/:env/webhooks.json`
  - `GET /1.1/account_activity/all/webhooks.json`
  - CRC challenge (GET with crc_token → respond with HMAC)
- Subscriptions :
  - `POST /1.1/account_activity/all/:env/subscriptions.json`
  - `GET /1.1/account_activity/all/:env/subscriptions/list.json`
- Events livrés : Tweet create/delete, favorite, follow/unfollow, DM events, typing, read receipts, blocks, mutes.
- Permissions : OAuth 1.0a user context requis ; droits adaptés aux événements.

## Webhooks Events (v2 pour certaines features)
- Compliance/Rules (stream) livrent events via streaming, pas webhooks.
- DM/AAA restent v1.1 ; pour v2, webhooks limités/entreprise.

## Pagination / filtres
- `pagination_token`, `max_results` pour listes v2 (tweets, users, lists, DMs).
- Streams : pas de pagination ; flux continu.

## Rate limits / quotas
- Headers `x-rate-limit-*`; 429 si dépassé; backoff recommandé.
- Streams : limites de connexions, 420 enhance your calm, backoff exponentiel.
- Différences par tier (Essential/Basic/Pro/Enterprise) sur accès search/all, volume stream, DMs.

## Erreurs typiques
- HTTP 400 (invalid_request), 401 (unauthorized), 403 (forbidden/insufficient permission), 404 (not found), 409 (conflict, e.g., duplicate rules), 420 (rate/connection), 429 (too many requests), 500/503 (server).
- Corps v2 : `errors[].code/message`; v1.1 : `errors: [{code, message}]`.

## Permissions / scopes (rappel)
- Lecture : `tweet.read`, `users.read`, `follows.read`, `like.read`, `list.read`, `bookmark.read`, `dm.read`.
- Écriture : `tweet.write`, `follows.write`, `like.write`, `list.write`, `bookmark.write`, `dm.write`, `tweet.moderate.write`, `media.write`.
- Offline : `offline.access` pour refresh.
- Webhooks AAA : OAuth 1.0a user tokens.

## Notes de conformité
- HTTPS obligatoire.
- Respecter les politiques de developer agreement, affichage et consentement.
- Ne pas logguer tokens; gérer backoff 429/420; mettre à jour l’inventaire selon les évolutions de tiers/pricing.  

