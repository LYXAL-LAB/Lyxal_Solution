# Inventaire complet — YouTube API (Phase S1)

Sources officielles : YouTube Data API v3, YouTube Live Streaming API, PubSubHubbub/Notifications, OAuth scopes (https://developers.google.com/youtube). 1 endpoint = 1 entrée. Aucun code.

## Auth / OAuth2
- OAuth consent (Google) + API key (lecture publique). Endpoints :
  - `GET https://accounts.google.com/o/oauth2/auth`
  - `POST https://oauth2.googleapis.com/token`
- Scopes principaux :
  - Lecture : `https://www.googleapis.com/auth/youtube.readonly`
  - Gestion chaîne : `https://www.googleapis.com/auth/youtube`
  - Upload : `https://www.googleapis.com/auth/youtube.upload`
  - Analytics : `https://www.googleapis.com/auth/yt-analytics.readonly`
  - Partner/Content ID : scopes spécifiques (hors périmètre standard)
- Quotas : budget de requêtes (unités par endpoint) ; 403 quotaExceeded si dépassé.

## Channels / Subscriptions
- `GET /youtube/v3/channels` (mine or by id/forUsername; parts: snippet, contentDetails, statistics, status, brandingSettings, topicDetails)
- `GET /youtube/v3/subscriptions` (list subscriptions of a channel; pagination pageToken, maxResults)
- `POST /youtube/v3/subscriptions` (subscribe)
- `DELETE /youtube/v3/subscriptions` (unsubscribe)
- Permissions : scope read/write selon action.

## Videos
- `GET /youtube/v3/videos` (by id, chart=mostPopular; parts: snippet, contentDetails, statistics, status, player, recordingDetails, topicDetails)
- `POST /youtube/v3/videos` (upload; multipart/ resumable)
- `PUT /youtube/v3/videos` (update metadata/status)
- `DELETE /youtube/v3/videos`
- `GET /youtube/v3/captions` / `POST /youtube/v3/captions` / `PUT /youtube/v3/captions` / `DELETE /youtube/v3/captions`
- `GET /youtube/v3/thumbnails/set` (upload thumbnail)
- Pagination : pageToken/maxResults.
- Rate: upload and write-heavy endpoints consume more quota units.

## Playlists
- `GET /youtube/v3/playlists` (channel playlists)
- `POST /youtube/v3/playlists` (create)
- `PUT /youtube/v3/playlists` (update)
- `DELETE /youtube/v3/playlists`
- Playlist items :
  - `GET /youtube/v3/playlistItems`
  - `POST /youtube/v3/playlistItems`
  - `PUT /youtube/v3/playlistItems`
  - `DELETE /youtube/v3/playlistItems`
- Pagination via pageToken/maxResults.

## Search / Discover
- `GET /youtube/v3/search` (q, type, channelId, publishedAfter/before, order, regionCode; pagination pageToken)
- Quota: higher cost than simple get; subject to 403 quotaExceeded.

## Comments / Live Chat
- Comments (V3) :
  - `GET /youtube/v3/commentThreads` (videoId/channelId, order, pageToken)
  - `POST /youtube/v3/commentThreads` (create top-level)
  - `GET /youtube/v3/comments` (list replies)
  - `POST /youtube/v3/comments` (insert reply)
  - `PUT /youtube/v3/comments` (update)
  - `DELETE /youtube/v3/comments`
  - `POST /youtube/v3/comments/setModerationStatus`
  - `POST /youtube/v3/comments/markAsSpam`
  - `POST /youtube/v3/comments/insert` (legacy)
- LiveChat :
  - `GET /youtube/v3/liveChat/messages`
  - `POST /youtube/v3/liveChat/messages` (send message)
  - `POST /youtube/v3/liveChat/messages/delete`
  - `POST /youtube/v3/liveChat/bans`
  - `POST /youtube/v3/liveChat/moderators`
  - Pagination via pageToken.

## Ratings / Likes
- `POST /youtube/v3/videos/rate` (like/dislike/none)
- `GET /youtube/v3/videos/getRating`

## Live Streaming
- Live Broadcasts :
  - `GET /youtube/v3/liveBroadcasts`
  - `POST /youtube/v3/liveBroadcasts` (insert)
  - `PUT /youtube/v3/liveBroadcasts` (update/transition testing→live→completed)
  - `DELETE /youtube/v3/liveBroadcasts`
- Live Streams :
  - `GET /youtube/v3/liveStreams`
  - `POST /youtube/v3/liveStreams` (insert)
  - `PUT /youtube/v3/liveStreams`
  - `DELETE /youtube/v3/liveStreams`
- Bind :
  - `POST /youtube/v3/liveBroadcasts/bind` (associate stream + broadcast)
- Live chat endpoints : cf. section comments/live chat.

## Analytics / Reports
- YouTube Analytics API :
  - `GET https://youtubeanalytics.googleapis.com/v2/reports` (metrics/dimensions filters, ids=channel=={id}; startDate/endDate; pagination via `pageToken` if supported)
  - `GET https://youtubeanalytics.googleapis.com/v2/groupItems` (if groups)
  - `GET https://youtubeanalytics.googleapis.com/v2/groups`
- YouTube Reporting API (bulk reports async) :
  - `GET /v1/jobs`
  - `POST /v1/jobs`
  - `GET /v1/jobs/{id}`
  - `GET /v1/jobs/{id}/reports`
  - `GET /v1/reports` (list available report downloads)
- Scopes : `yt-analytics.readonly`, `yt-analytics-monetary.readonly` (monetary metrics), etc.

## Channel Sections / Branding
- `GET /youtube/v3/channelSections`
- `POST /youtube/v3/channelSections`
- `PUT /youtube/v3/channelSections`
- `DELETE /youtube/v3/channelSections`
- `PUT /youtube/v3/watermarks/set` / `watermarks/unset`
- `PUT /youtube/v3/channels` (brandingSettings)

## Memberships / Sponsors (si autorisé)
- `GET /youtube/v3/members` (beta/approved channels)
- Scopes/availability restreints.

## Abuse / Moderation
- `POST /youtube/v3/comments/markAsSpam`
- `POST /youtube/v3/comments/setModerationStatus`
- Live chat bans/moderators endpoints (cf. Live Chat)

## Webhooks / Notifications (PubSubHubbub)
- Topic per channel feed : `https://www.youtube.com/xml/feeds/videos.xml?channel_id={id}`
- `POST https://pubsubhubbub.appspot.com/subscribe` (hub.mode=subscribe/unsubscribe, hub.callback, hub.topic, hub.verify=async/sync, hub.secret)
- Notifications : XML payload via callback on new video; verify token + HMAC (X-Hub-Signature).
- No push for comments/likes (only uploads).

## Pagination / filtres
- Standard `pageToken`, `maxResults` pour toutes les listes (videos, search, playlists, comments, subs).
- Filtres spécifiques par endpoint (q, type, order, publishedAfter, regionCode, videoCategoryId, etc.).

## Rate limits / quotas
- Quota unit system ; exemples : search=100 units, videos.list=1, upload=1600.
- 403 quotaExceeded si dépassement ; reset quotidien.
- Certaines routes (uploads, live) plus coûteuses.

## Erreurs typiques
- 400 badRequest (invalid parameter), 401 authError (invalidCredentials), 403 quotaExceeded / insufficientPermissions, 404 notFound, 409 conflict (live transitions), 429 rare, 500/503 backendError.
- Erreurs détaillées dans `errors[0].reason` (ex: `quotaExceeded`, `forbidden`, `liveBroadcastBindingConflict`).

## Permissions / scopes (rappel)
- Lecture : `youtube.readonly`
- Gestion chaîne : `youtube`
- Upload : `youtube.upload`
- Analytics : `yt-analytics.readonly`, `yt-analytics-monetary.readonly`
- Livestream : inclus dans `youtube` (manip broadcasts/streams)

## Notes de conformité
- HTTPS obligatoire; OAuth Google ; API key possible pour lecture publique.
- Respecter quota et backoff; ne pas logguer tokens; suivre politiques YouTube/Google API Services.  

