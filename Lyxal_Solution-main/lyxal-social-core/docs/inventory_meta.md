# Inventaire complet — Meta (Facebook + Instagram) API (Phase S1)

Sources officielles : Meta for Developers — Graph API / Marketing API / Webhooks / Permissions (https://developers.facebook.com/docs/). 1 endpoint = 1 entrée. Aucun code.

## Auth / OAuth2 (Facebook Login)
- `GET https://www.facebook.com/v{v}/dialog/oauth` (auth code)
- `GET https://graph.facebook.com/v{v}/oauth/access_token` (code→token)
- `GET https://graph.facebook.com/v{v}/oauth/access_token` (refresh long-lived page/IG tokens)
- `GET https://graph.facebook.com/debug_token` (inspect token)
- Scopes (exemples) : `pages_show_list`, `pages_manage_metadata`, `pages_manage_posts`, `pages_manage_engagement`, `pages_read_engagement`, `instagram_basic`, `instagram_content_publish`, `instagram_manage_comments`, `instagram_manage_insights`, `instagram_manage_messages`, `business_management`, `ads_management`, `public_profile`, `email`.
- Erreurs : 190 invalid token, 10 permission denied, 4 rate limit, 17 user checkpoint, etc.

## Facebook Pages — Contenu
- `GET /{page-id}?fields=name,id,fan_count,...`
- `GET /{page-id}/feed` — liste des posts (pagination cursors)
- `POST /{page-id}/feed` — créer post (message, link, attached_media, scheduled_publish_time)
- `DELETE /{post-id}`
- `GET /{post-id}` — détails
- `POST /{post-id}` — update (message)
- `GET /{post-id}/insights`
- `GET /{page-id}/videos` — liste vidéos
- `POST /{page-id}/videos` — upload vidéo (upload phase start, transfer, finish)
- `GET /{video-id}` / `DELETE /{video-id}` / `POST /{video-id}` (update)
- `GET /{video-id}/insights`
- `GET /{page-id}/photos` / `POST /{page-id}/photos`
- `GET /{page-id}/published_posts` (pagination)
- `GET /{page-id}/scheduled_posts`
- `POST /{page-id}/scheduled_posts` (scheduled publish)
- `GET /{page-id}/statuses`

## Facebook Pages — Engagement
- `GET /{object-id}/comments`
- `POST /{object-id}/comments` — créer commentaire
- `DELETE /{comment-id}`
- `GET /{comment-id}`
- `POST /{comment-id}` — update (message)
- `GET /{object-id}/likes`
- `POST /{object-id}/likes`
- `DELETE /{object-id}/likes`
- `GET /{object-id}/reactions`
- `POST /{object-id}/reactions` (type)
- `DELETE /{object-id}/reactions`

## Facebook Pages — Messaging (Page Inbox)
- `GET /{page-id}/conversations` (pagination)
- `GET /{conversation-id}/messages`
- `POST /{page-id}/messages` (send text/attachment to user)
- Webhooks : `messages`, `messaging_postbacks`, `message_deliveries`, `message_reads`, `messaging_handovers`.
- Permissions : `pages_messaging`, `pages_manage_metadata`, `pages_read_engagement`.

## Facebook Pages — Insights / Analytics
- `GET /{page-id}/insights` (metrics: page_impressions, page_fans, etc., with period/day/week/month)
- `GET /{post-id}/insights` (post engagement, reach)
- `GET /{video-id}/insights`
- Pagination via `since/until`, `period`, cursors.

## Instagram Graph API — Comptes professionnels
- `GET /{ig-user-id}` — champs : followers_count, follows_count, media_count, profile_pic, etc.
- `GET /{ig-user-id}/media` — liste médias (pagination cursors)
- `GET /{ig-media-id}` — détails (caption, media_type, media_url, thumbnail_url, permalink, timestamp, owner)
- `GET /{ig-media-id}/children` (pour albums)
- `POST /{ig-user-id}/media` — conteneur (image_url, video_url, caption, location_id, user_tags)
- `POST /{ig-user-id}/media_publish` — publier conteneur
- `POST /{ig-user-id}/reels` — conteneur reel (si doc v18+)
- `POST /{ig-user-id}/reels_publish` — publier reel
- `DELETE /{ig-media-id}`
- `GET /{ig-user-id}/content_publishing_limit`

## Instagram — Commentaires / Mentions / Replies
- `GET /{ig-media-id}/comments`
- `POST /{ig-media-id}/comments` (message)
- `DELETE /{ig-comment-id}`
- `GET /{ig-comment-id}/replies`
- `POST /{ig-comment-id}/replies`
- Mentions : `GET /ig_hashtag_search`, `GET /{ig-hashtag-id}/recent_media|top_media` (si autorisé pour business)

## Instagram — Insights
- `GET /{ig-user-id}/insights` (metrics : impressions, reach, profile_views, follower_count; periods day, lifetime)
- `GET /{ig-media-id}/insights` (metrics : impressions, reach, engagement, saves, video_views)
- `GET /{ig-reel-id}/insights` (reel metrics : plays, reach, likes, comments, shares, saves)

## Instagram — Messaging (IG Business Messaging)
- Cloud API endpoints (shared with WhatsApp infra) :
  - `POST /v{v}/{phone-number-id}/messages` (si WhatsApp) — non IG; pour IG Business Messaging via Graph : 
  - `POST /{ig-user-id}/messages` (send) — (selon docs IG Messaging Beta)
  - `GET /{ig-user-id}/conversations`
  - `GET /{ig-conversation-id}/messages`
- Webhooks IG : `messages`, `message_deliveries`, `message_reads`.
- Permissions : `instagram_manage_messages`.

## Instagram — Stories (limité)
- Lecture : `GET /{ig-user-id}/stories` (token de courte durée) — accès restreint; non disponible pour contenu d’autres utilisateurs.
- Pas de publication de story via Graph API (au moment de cette doc).

## Webhooks Meta
- Subscription par app : `GET|POST /{app-id}/subscriptions`
- Products : `page`, `instagram`, `ads`, `permissions`, `user`.
- Topics principaux :
  - Page : `feed`, `conversations`, `messages`, `ratings`, `live_videos`, `mention`, `standby`, `leadgen`.
  - Instagram : `comments`, `mentions`, `story_insights`, `messages`.
- Vérification : `hub.mode`, `hub.challenge`, `hub.verify_token`.
- Livraison : batched JSON avec `object`, `entry`, `changes`.

## Permissions / Scopes clés
- Facebook Pages : `pages_show_list`, `pages_read_engagement`, `pages_manage_metadata`, `pages_manage_posts`, `pages_manage_engagement`, `pages_messaging`.
- Instagram : `instagram_basic`, `instagram_content_publish`, `instagram_manage_comments`, `instagram_manage_insights`, `instagram_manage_messages`, `pages_show_list`, `business_management`.
- Ads/Commercial : `ads_read`, `ads_management`, `business_management`.

## Rate limits / quotas
- Limites par app/user/page : `x-app-usage`, `x-page-usage`, `x-ad-account-usage` dans headers.
- 4xx : 4 rate limit, 10 permission, 190 token; 200 OK avec body error possible.
- Backoff recommandé sur 4, surveiller `x-business-use-case-usage`.

## Pagination / filtres
- Cursor-based : `limit`, `after`, `before`.
- Time-based : `since`, `until`.
- Fields param : `?fields=...` pour sélectionner les champs.

## Erreurs typiques
- 190 invalid/expired token.
- 10 permission denied/missing scope.
- 4 rate limit reached.
- 100 param invalid.
- 200 deprecation / permissions.
- 613 call limit reached.
- 1 unknown; 2 service temporarily unavailable.

## Notes de conformité
- HTTPS obligatoire (Graph API).
- Ne pas logguer tokens ni données utilisateurs sensibles.
- Vérifier statut de l’app (Live vs Dev) et review pour scopes sensibles.
- Mettre à jour cet inventaire à chaque release de la doc Meta avant implémentation.

