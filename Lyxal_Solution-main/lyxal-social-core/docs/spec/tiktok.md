# Spec TikTok — Primitives endpoint-level (Phase 2)

Convention : `social::tiktok::<domaine>::<action>`. 1 primitive = 1 endpoint officiel (TikTok for Developers : Content Posting API, Login/Display, Research, Comments, Analytics, Webhooks, Data Portability, Commercial Content). Pas de logique métier.

## Auth / scopes
- OAuth2 (authorization_code + refresh). Scopes selon produit : `video.upload`, `video.publish`, `video.list`, `video.delete`, `comment.list`, `comment.manage`, `user.info.basic`, `video.analytics`, `user.analytics`, `research.*`, `display.*`, `embed.*`, `data.portability.*`, `commercial_content.*`. Tokens : access_token, refresh_token, expires_in.

## Primitives

### Content Posting (Upload / Publish)
- primitive: social::tiktok::videos::init_upload  
  endpoint: POST /v2/video/init_upload/  
  inputs: { file_size: int, chunk_count?: int }  
  outputs: { upload_url: string, video_id: string, expires_at: timestamp }  
  pagination: none  
  rate_limit: per-app/per-user  
  errors: INVALID_ARGUMENT, PERMISSION_DENIED, RATE_LIMITED, PROVIDER_ERROR  

- primitive: social::tiktok::videos::upload  
  endpoint: POST /v2/video/upload/  
  inputs: { upload_url: string, file: binary }  
  outputs: { video_id: string }  
  pagination: none  
  rate_limit: per-app/per-user  
  errors: ...  
  notes: multipart upload

- primitive: social::tiktok::videos::publish  
  endpoint: POST /v2/video/publish/  
  inputs: { video_id, caption?, cover_time?, disable_comment?, allow_duet?, allow_stitch?, privacy_level?, schedule_time? }  
  outputs: { video_id, share_url?, status }  
  pagination: none  
  rate_limit: per-app/per-user  
  errors: ...  

- primitive: social::tiktok::videos::status  
  endpoint: GET /v2/video/query/  
  inputs: { video_id }  
  outputs: { video_id, status, error_code?, error_msg? }  
  pagination: none  
  rate_limit: per-app/per-user  
  errors: ...  

- primitive: social::tiktok::videos::list  
  endpoint: GET /v2/video/list/  
  inputs: { cursor?: string, max_count?: int, filters?: { start_time?, end_time?, status? } }  
  outputs: { videos: [], cursor: string, has_more: bool }  
  pagination: cursor  
  rate_limit: per-app/per-user  
  errors: ...  

- primitive: social::tiktok::videos::delete  
  endpoint: DELETE /v2/video/delete/  
  inputs: { video_id }  
  outputs: { video_id, deleted: bool }  
  pagination: none  
  rate_limit: per-app/per-user  
  errors: ...  

### Media (cover/photo) — si exposé
- primitive: social::tiktok::media::upload_cover  
  endpoint: POST /v2/video/cover/upload/  
  inputs: { video_id, file: binary }  
  outputs: { cover_url }  
  pagination: none  
  rate_limit: per-app/per-user  
  errors: ...  

### User Info / Login Kit
- primitive: social::tiktok::users::get_me  
  endpoint: GET /user/info/  
  inputs: none  
  outputs: { open_id, avatar, display_name, region, union_id? }  
  pagination: none  
  rate_limit: per-user  
  errors: ...  
  notes: scope user.info.basic

### Comments
- primitive: social::tiktok::comments::list  
  endpoint: GET /v2/video/comment/list/  
  inputs: { video_id, cursor?: string, max_count?: int }  
  outputs: { comments: [], cursor, has_more }  
  pagination: cursor  
  rate_limit: per-app/per-user  
  errors: ...  

- primitive: social::tiktok::comments::reply  
  endpoint: POST /v2/video/comment/reply/  
  inputs: { comment_id, text }  
  outputs: { reply_id }  
  pagination: none  
  rate_limit: per-app/per-user  
  errors: ...  

- primitive: social::tiktok::comments::like  
  endpoint: POST /v2/video/comment/like/  
  inputs: { comment_id, action: enum(like|unlike) }  
  outputs: empty  
  pagination: none  
  rate_limit: per-app/per-user  
  errors: ...  

- primitive: social::tiktok::comments::pin  
  endpoint: POST /v2/video/comment/pin/  
  inputs: { comment_id, action: enum(pin|unpin) }  
  outputs: empty  
  pagination: none  
  rate_limit: per-app/per-user  
  errors: ...  

### Analytics / Insights
- primitive: social::tiktok::videos::insights  
  endpoint: GET /v2/video/insights/  
  inputs: { video_id }  
  outputs: { metrics: { views, likes, comments, shares, watch_time, ... } }  
  pagination: none  
  rate_limit: per-app/per-user  
  errors: ...  

- primitive: social::tiktok::users::insights  
  endpoint: GET /v2/user/insights/  
  inputs: { time_range?: { start_time, end_time }, metrics?: [] }  
  outputs: { metrics: [] }  
  pagination: none  
  rate_limit: per-app/per-user  
  errors: ...  

### Display / Embed
- primitive: social::tiktok::display::get_video  
  endpoint: GET /v1/display/video/  
  inputs: { video_id }  
  outputs: { video }  
  pagination: none  
  rate_limit: per-app/per-user  
  errors: ...  

- primitive: social::tiktok::display::get_creator  
  endpoint: GET /v1/display/creator/  
  inputs: { creator_id }  
  outputs: { profile }  
  pagination: none  
  rate_limit: per-app/per-user  
  errors: ...  

- primitive: social::tiktok::embed::oembed  
  endpoint: GET https://www.tiktok.com/oembed  
  inputs: { url }  
  outputs: { html, author_name, author_url, thumbnail_url, title }  
  pagination: none  
  rate_limit: global  
  errors: ...  

### Research API (accès approuvé)
- primitive: social::tiktok::research::video_info  
  endpoint: GET /v2/research/video/info/  
  inputs: { video_ids: [] }  
  outputs: { items: [] }  
  pagination: none  
  rate_limit: per-app (research)  
  errors: ...  

- primitive: social::tiktok::research::video_comments  
  endpoint: GET /v2/research/video/comment/list/  
  inputs: { video_id, cursor?: string, max_count?: int }  
  outputs: { comments: [], cursor, has_more }  
  pagination: cursor  
  rate_limit: research tier  
  errors: ...  

- primitive: social::tiktok::research::video_search  
  endpoint: GET /v2/research/video/search/  
  inputs: { query, start_time?, end_time?, cursor?, max_count? }  
  outputs: { videos: [], cursor, has_more }  
  pagination: cursor  
  rate_limit: research tier  
  errors: ...  

- primitive: social::tiktok::research::user_info  
  endpoint: GET /v2/research/user/info/  
  inputs: { user_ids: [] }  
  outputs: { users: [] }  
  pagination: none  
  rate_limit: research tier  
  errors: ...  

- primitive: social::tiktok::research::hashtag_info  
  endpoint: GET /v2/research/hashtag/info/  
  inputs: { hashtag_ids: [] }  
  outputs: { hashtags: [] }  
  pagination: none  
  rate_limit: research tier  
  errors: ...  

- primitive: social::tiktok::research::hashtag_videos  
  endpoint: GET /v2/research/hashtag/video/list/  
  inputs: { hashtag_id, cursor?: string, max_count?: int }  
  outputs: { videos: [], cursor, has_more }  
  pagination: cursor  
  rate_limit: research tier  
  errors: ...  

### Data Portability (EEA/UK)
- primitive: social::tiktok::data_portability::add_request  
  endpoint: POST /v1/data_portability/add_data_request  
  inputs: { user_id, data_types: [] }  
  outputs: { request_id, status }  
  pagination: none  
  rate_limit: per-user  
  errors: ...  

- primitive: social::tiktok::data_portability::check_status  
  endpoint: GET /v1/data_portability/check_data_request_status  
  inputs: { request_id }  
  outputs: { status, download_url?, expires_at? }  
  pagination: none  
  rate_limit: per-user  
  errors: ...  

- primitive: social::tiktok::data_portability::cancel_request  
  endpoint: POST /v1/data_portability/cancel_data_request  
  inputs: { request_id }  
  outputs: { status }  
  pagination: none  
  rate_limit: per-user  
  errors: ...  

### Commercial Content API (Ads/Commercial)
- primitive: social::tiktok::commercial::search  
  endpoint: GET /commercial_content/search  
  inputs: { query, page?, page_size? }  
  outputs: { items: [], page, total_pages }  
  pagination: page-based  
  rate_limit: per-app  
  errors: ...  

- primitive: social::tiktok::commercial::detail  
  endpoint: GET /commercial_content/detail  
  inputs: { id }  
  outputs: { item }  
  pagination: none  
  rate_limit: per-app  
  errors: ...  

### Webhooks
- primitive: social::tiktok::webhooks::subscribe  
  endpoint: POST /webhooks/subscribe (per doc product)  
  inputs: { callback_url, events: [], secret? }  
  outputs: { subscription_id }  
  pagination: none  
  rate_limit: per-app  
  errors: ...  

- primitive: social::tiktok::webhooks::unsubscribe  
  endpoint: POST /webhooks/unsubscribe  
  inputs: { subscription_id }  
  outputs: { status }  
  pagination: none  
  rate_limit: per-app  
  errors: ...  

### Errors (norme)
- INVALID_ARGUMENT, PERMISSION_DENIED, RATE_LIMITED, PROVIDER_ERROR

### Pagination
- cursor/has_more pour list endpoints ; page/page_size pour commercial_content search.

### Rate limit meta
- scope: per-app/per-user depending endpoint; headers may include log_id, retry info.

