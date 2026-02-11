# Inventaire complet — TikTok API (Phase S1)

Source officielle : [TikTok for Developers](https://developers.tiktok.com/) (Content Posting API, Login/Share Kits, Research/Display/Embed, Webhooks, Data Portability, Commercial Content API). 1 endpoint = 1 entrée. Aucun code.

## Auth / OAuth2
- Authorization Code Flow : `GET /authorize`, `POST /oauth/token` (grant authorization_code / refresh_token / client_credentials), `POST /oauth/revoke`. Scopes requis selon produit (ex : `video.upload`, `video.publish`, `video.list`, `user.info.basic`, `comment.list`, `comment.manage`, `research.*`, `display.*`, `embed.*`).
- Tokens : access_token, refresh_token, expires_in. PKCE recommandé mobile.
- Rate limit : retour 429 avec `x-tt-logid` et `x-tt-req-time`; backoff recommandé.

## Content Posting API (publish / media)
- `POST /v2/video/init_upload/` — init upload, renvoie upload_url, video_id, expire.
- `POST /v2/video/upload/` — upload binaire (multipart/form-data) vers upload_url.
- `POST /v2/video/publish/` — publie la vidéo (video_id, title/caption, disable_comment, allow_duet/stitch, cover_time, schedule_time, privacy_level).
- `GET /v2/video/query/` — statut de publication (processing, live).
- `GET /v2/video/list/` — liste des vidéos de l’utilisateur (pagination cursor/has_more, filters time/status).
- `DELETE /v2/video/delete/` — supprime une vidéo (video_id).
- `GET /v2/video/cover/upload/` — upload cover personnalisé (si supporté).
- Quotas : limites par app et par utilisateur (upload/publish), 429 sinon.
- Erreurs typiques : 400 (params), 401/403 (scope/token), 429 (quota), 500 (serveur).

## Login Kit / User Info
- `GET /user/info/` — infos basiques (open_id, avatar, display_name) selon scope `user.info.basic`.
- Scopes : `user.info.basic`, éventuellement `user.info.profile` (si disponible).
- Utilisé après login OAuth pour récupérer l’open_id et permissions.

## Share Kit / Client-side share
- Intent/app switch pour partager du contenu généré dans l’app vers TikTok (pas d’endpoint serveur).
- Métadonnées : media type (video/image), redirect back. Concerne mobile SDK (pas traité côté backend).

## Display API / Embed
- `GET /v1/display/video/` — récupérer metadonnées vidéo pour affichage (requires display scope).
- `GET /v1/display/creator/` — profil créateur.
- Embed : oEmbed `GET https://www.tiktok.com/oembed?url=...` (public, pas d’auth).
- Quotas : affichage rate-limited ; 429 possible.

## Research API (accès approuvé)
- `GET /v2/research/user/info/` — info utilisateur public.
- `GET /v2/research/user/following/list/` — following list (pagination cursor).
- `GET /v2/research/user/follower/list/` — followers (si autorisé).
- `GET /v2/research/user/video/list/` — liste vidéos utilisateur.
- `GET /v2/research/video/info/` — détails vidéo.
- `GET /v2/research/video/comment/list/` — commentaires d’une vidéo (pagination cursor).
- `GET /v2/research/video/search/` — recherche vidéos (query, time range, pagination).
- `GET /v2/research/hashtag/info/` — infos hashtag.
- `GET /v2/research/hashtag/video/list/` — vidéos par hashtag.
- Scopes : `research.video.info`, `research.video.list`, `research.video.search`, `research.comment.list`, etc. Accès restreint (approved researchers).
- Rate limits stricts ; 429 ; logsid dans headers.

## Comments / Inbox (si autorisé pour créateurs via content APIs)
- `GET /v2/video/comment/list/` — lister commentaires d’une vidéo (cursor/limit).
- `POST /v2/video/comment/reply/` — répondre à un commentaire (comment_id, text).
- `POST /v2/video/comment/like/` — like/unlike.
- `POST /v2/video/comment/pin/` — épingler/désépingler.
- Scopes : `comment.list`, `comment.manage`.
- Erreurs : 403 si scope manquant ou vidéo non autorisée ; 429 quotas ; 400 validation.

## Analytics / Insights
- `GET /v2/video/insights/` — métriques vidéo (views, likes, comments, shares, watch time).
- `GET /v2/user/insights/` — agrégats compte (followers, views, profile views) si exposé.
- Scopes : `video.analytics`, `user.analytics` (nomenclature peut varier selon doc courante).
- Pagination : fenêtres temporelles (start_time/end_time), limit sur nb de vidéos par requête.

## Webhooks
- Abonnement via console/developer settings ; livraison sur URL fournie.
- Événements typiques (si disponibles) : vidéo publiée, statut upload, commentaire reçu, mention.
- Signature : en-tête HMAC (ex: `TT-Signature`), timestamp, replay protection.
- Quotas : envoi best-effort ; retry backoff ; 429 possible côté récepteur si réponses lentes.

## Data Portability API (EEA/UK)
- Endpoints dédiés transfert de données utilisateur (sur demande) — liste complète dans la doc Data Portability (export packages, status, download links).
- Auth renforcée, scopes spécifiques.

## Commercial Content API (Ads / publicité)
- Recherche de contenus publicitaires/commerciaux : endpoints `commercial_content/search`, `commercial_content/detail`.
- Accès restreint (approved), quotas spécifiques.

## Error model commun
- Code HTTP + body JSON `error.code`, `error.message`, `log_id`.
- 400 validation, 401/403 auth/scope, 404 ressource, 429 rate limit/quota, 500/502/503 serveur.
- Retours incluent `log_id` pour support.

## Rate limits / quotas
- Par app et par utilisateur ; variantes selon produit (Content Posting, Research, Display).
- 429 avec attente recommandée (exponential backoff). Certains endpoints upload ont quotas journaliers.

## Pagination / filtres
- Modèle cursor/has_more/limit pour la plupart des listes (videos, comments, users).
- Filtres temporels (start_time/end_time) pour insights/search.

## Permissions / scopes (exemples courants)
- Publishing : `video.upload`, `video.publish`, `video.list`, `video.delete`.
- Comments : `comment.list`, `comment.manage`.
- User info : `user.info.basic`.
- Analytics : `video.analytics`, `user.analytics`.
- Research : `research.*` scopes selon ressource.
- Display/Embed : `display.*` ou public oEmbed (sans auth).

## Notes de conformité
- HTTPS obligatoire.
- Pas de stockage ni log de tokens en clair.
- Respect des politiques créateur et des limitations régionales (ex : Data Portability EEA/UK).
- Toute nouvelle révision de la doc officielle doit mettre à jour ce fichier avant implémentation.

