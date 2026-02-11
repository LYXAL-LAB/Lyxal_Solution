# Spec YouTube — Primitives endpoint-level (Phase 2)

Convention : `social::youtube::<domaine>::<action>`. 1 primitive = 1 endpoint officiel (YouTube Data API v3, Live Streaming, Analytics/Reporting, PubSubHubbub). Pas de logique métier.

## Auth / scopes
- OAuth Google. Scopes : `youtube.readonly`, `youtube`, `youtube.upload`, `yt-analytics.readonly`, `yt-analytics-monetary.readonly`. API key possible pour lecture publique.

## Channels / Subscriptions
- social::youtube::channels::list (GET /youtube/v3/channels)
- social::youtube::subscriptions::list (GET /youtube/v3/subscriptions)
- social::youtube::subscriptions::insert (POST /youtube/v3/subscriptions)
- social::youtube::subscriptions::delete (DELETE /youtube/v3/subscriptions)

## Videos
- social::youtube::videos::list (GET /youtube/v3/videos)
- social::youtube::videos::insert (POST /youtube/v3/videos) — upload (multipart/resumable)
- social::youtube::videos::update (PUT /youtube/v3/videos)
- social::youtube::videos::delete (DELETE /youtube/v3/videos)
- social::youtube::captions::list (GET /youtube/v3/captions)
- social::youtube::captions::insert (POST /youtube/v3/captions)
- social::youtube::captions::update (PUT /youtube/v3/captions)
- social::youtube::captions::delete (DELETE /youtube/v3/captions)
- social::youtube::thumbnails::set (POST /youtube/v3/thumbnails/set)

## Playlists
- social::youtube::playlists::list (GET /youtube/v3/playlists)
- social::youtube::playlists::insert (POST /youtube/v3/playlists)
- social::youtube::playlists::update (PUT /youtube/v3/playlists)
- social::youtube::playlists::delete (DELETE /youtube/v3/playlists)
- social::youtube::playlist_items::list (GET /youtube/v3/playlistItems)
- social::youtube::playlist_items::insert (POST /youtube/v3/playlistItems)
- social::youtube::playlist_items::update (PUT /youtube/v3/playlistItems)
- social::youtube::playlist_items::delete (DELETE /youtube/v3/playlistItems)

## Search
- social::youtube::search::list (GET /youtube/v3/search)

## Comments / Live Chat
- social::youtube::comment_threads::list (GET /youtube/v3/commentThreads)
- social::youtube::comment_threads::insert (POST /youtube/v3/commentThreads)
- social::youtube::comments::list (GET /youtube/v3/comments)
- social::youtube::comments::insert (POST /youtube/v3/comments)
- social::youtube::comments::update (PUT /youtube/v3/comments)
- social::youtube::comments::delete (DELETE /youtube/v3/comments)
- social::youtube::comments::set_moderation_status (POST /youtube/v3/comments/setModerationStatus)
- social::youtube::comments::mark_spam (POST /youtube/v3/comments/markAsSpam)
- Live chat :
  - social::youtube::live_chat::list_messages (GET /youtube/v3/liveChat/messages)
  - social::youtube::live_chat::insert_message (POST /youtube/v3/liveChat/messages)
  - social::youtube::live_chat::delete_message (POST /youtube/v3/liveChat/messages/delete)
  - social::youtube::live_chat::bans (POST /youtube/v3/liveChat/bans)
  - social::youtube::live_chat::moderators (POST /youtube/v3/liveChat/moderators)

## Ratings
- social::youtube::videos::rate (POST /youtube/v3/videos/rate)
- social::youtube::videos::get_rating (GET /youtube/v3/videos/getRating)

## Live Streaming
- social::youtube::live_broadcasts::list (GET /youtube/v3/liveBroadcasts)
- social::youtube::live_broadcasts::insert (POST /youtube/v3/liveBroadcasts)
- social::youtube::live_broadcasts::update (PUT /youtube/v3/liveBroadcasts)
- social::youtube::live_broadcasts::delete (DELETE /youtube/v3/liveBroadcasts)
- social::youtube::live_broadcasts::bind (POST /youtube/v3/liveBroadcasts/bind)
- social::youtube::live_streams::list (GET /youtube/v3/liveStreams)
- social::youtube::live_streams::insert (POST /youtube/v3/liveStreams)
- social::youtube::live_streams::update (PUT /youtube/v3/liveStreams)
- social::youtube::live_streams::delete (DELETE /youtube/v3/liveStreams)

## Analytics / Reporting
- social::youtube::analytics::reports (GET https://youtubeanalytics.googleapis.com/v2/reports)
- social::youtube::analytics::groups (GET /v2/groups)
- social::youtube::analytics::group_items (GET /v2/groupItems)
- social::youtube::reporting::jobs_list (GET /v1/jobs)
- social::youtube::reporting::jobs_create (POST /v1/jobs)
- social::youtube::reporting::jobs_get (GET /v1/jobs/{id})
- social::youtube::reporting::jobs_reports (GET /v1/jobs/{id}/reports)
- social::youtube::reporting::reports_list (GET /v1/reports)

## Channel Sections / Branding
- social::youtube::channel_sections::list (GET /youtube/v3/channelSections)
- social::youtube::channel_sections::insert (POST /youtube/v3/channelSections)
- social::youtube::channel_sections::update (PUT /youtube/v3/channelSections)
- social::youtube::channel_sections::delete (DELETE /youtube/v3/channelSections)
- social::youtube::watermarks::set (POST /youtube/v3/watermarks/set)
- social::youtube::watermarks::unset (POST /youtube/v3/watermarks/unset)
- social::youtube::channels::update_branding (PUT /youtube/v3/channels)

## Memberships (si autorisé)
- social::youtube::members::list (GET /youtube/v3/members)

## PubSubHubbub / Notifications
- social::youtube::pubsub::subscribe (POST https://pubsubhubbub.appspot.com/subscribe)
- social::youtube::pubsub::unsubscribe (POST https://pubsubhubbub.appspot.com/subscribe with mode=unsubscribe)

## Errors (norme)
- INVALID_ARGUMENT, PERMISSION_DENIED, RATE_LIMITED(quotaExceeded), PROVIDER_ERROR

## Pagination
- `pageToken`, `maxResults` sur la majorité des listes (videos, search, comments, playlists, subs, live chat).

## Rate limit meta
- Quota units par endpoint ; 403 quotaExceeded ; pas d’en-têtes explicites, suivre dashboard. Uploads coûtent plus d’unités.  

