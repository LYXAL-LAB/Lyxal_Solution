# Spec Meta (Facebook + Instagram) — Primitives endpoint-level (Phase 2)

Convention : `social::meta::<surface>::<domaine>::<action>`. 1 primitive = 1 endpoint Graph/Marketing officiel. Pas de logique métier.

## Auth / scopes
- OAuth2 Facebook Login. Scopes selon surface : pages (`pages_show_list`, `pages_manage_posts`, `pages_manage_engagement`, `pages_read_engagement`, `pages_manage_metadata`, `pages_messaging`), Instagram (`instagram_basic`, `instagram_content_publish`, `instagram_manage_comments`, `instagram_manage_insights`, `instagram_manage_messages`), business/ads (`business_management`, `ads_management`, `ads_read`).

## Facebook Pages — Contenu
- social::meta::facebook::pages::get (GET /{page-id})
- social::meta::facebook::pages::list_feed (GET /{page-id}/feed) — pagination cursor
- social::meta::facebook::pages::create_post (POST /{page-id}/feed)
- social::meta::facebook::pages::get_post (GET /{post-id})
- social::meta::facebook::pages::update_post (POST /{post-id})
- social::meta::facebook::pages::delete_post (DELETE /{post-id})
- social::meta::facebook::pages::list_photos (GET /{page-id}/photos)
- social::meta::facebook::pages::create_photo (POST /{page-id}/photos)
- social::meta::facebook::pages::list_videos (GET /{page-id}/videos)
- social::meta::facebook::pages::create_video (POST /{page-id}/videos upload phases)
- social::meta::facebook::pages::get_video (GET /{video-id})
- social::meta::facebook::pages::delete_video (DELETE /{video-id})
- social::meta::facebook::pages::update_video (POST /{video-id})
- social::meta::facebook::pages::list_published_posts (GET /{page-id}/published_posts)
- social::meta::facebook::pages::list_scheduled_posts (GET /{page-id}/scheduled_posts)
- social::meta::facebook::pages::create_scheduled_post (POST /{page-id}/scheduled_posts)

## Facebook Pages — Engagement
- social::meta::facebook::comments::list (GET /{object-id}/comments) — pagination cursor
- social::meta::facebook::comments::create (POST /{object-id}/comments)
- social::meta::facebook::comments::delete (DELETE /{comment-id})
- social::meta::facebook::comments::get (GET /{comment-id})
- social::meta::facebook::comments::update (POST /{comment-id})
- social::meta::facebook::likes::list (GET /{object-id}/likes)
- social::meta::facebook::likes::add (POST /{object-id}/likes)
- social::meta::facebook::likes::remove (DELETE /{object-id}/likes)
- social::meta::facebook::reactions::list (GET /{object-id}/reactions)
- social::meta::facebook::reactions::set (POST /{object-id}/reactions)
- social::meta::facebook::reactions::clear (DELETE /{object-id}/reactions)

## Facebook Pages — Messaging
- social::meta::facebook::messages::list_conversations (GET /{page-id}/conversations) — pagination
- social::meta::facebook::messages::list (GET /{conversation-id}/messages)
- social::meta::facebook::messages::send (POST /{page-id}/messages)

## Facebook Pages — Insights
- social::meta::facebook::insights::page (GET /{page-id}/insights)
- social::meta::facebook::insights::post (GET /{post-id}/insights)
- social::meta::facebook::insights::video (GET /{video-id}/insights)

## Facebook Pages — Bans / Roles / Admins
- social::meta::facebook::admins::list (GET /{page-id}/admins)
- social::meta::facebook::admins::assign (POST /{page-id}/admins)
- social::meta::facebook::admins::remove (DELETE /{page-id}/admins)

## Instagram Graph — Media / Publishing
- social::meta::instagram::media::list (GET /{ig-user-id}/media) — pagination cursor
- social::meta::instagram::media::get (GET /{ig-media-id})
- social::meta::instagram::media::children (GET /{ig-media-id}/children)
- social::meta::instagram::media::create_container (POST /{ig-user-id}/media)
- social::meta::instagram::media::publish (POST /{ig-user-id}/media_publish)
- social::meta::instagram::reels::create_container (POST /{ig-user-id}/reels)
- social::meta::instagram::reels::publish (POST /{ig-user-id}/reels_publish)
- social::meta::instagram::media::delete (DELETE /{ig-media-id})
- social::meta::instagram::media::publishing_limit (GET /{ig-user-id}/content_publishing_limit)

## Instagram — Comments / Replies
- social::meta::instagram::comments::list (GET /{ig-media-id}/comments) — pagination
- social::meta::instagram::comments::create (POST /{ig-media-id}/comments)
- social::meta::instagram::comments::delete (DELETE /{ig-comment-id})
- social::meta::instagram::comments::list_replies (GET /{ig-comment-id}/replies)
- social::meta::instagram::comments::reply (POST /{ig-comment-id}/replies)

## Instagram — Insights
- social::meta::instagram::insights::user (GET /{ig-user-id}/insights)
- social::meta::instagram::insights::media (GET /{ig-media-id}/insights)
- social::meta::instagram::insights::reel (GET /{ig-reel-id}/insights)

## Instagram — Messaging (Business)
- social::meta::instagram::messages::list_conversations (GET /{ig-user-id}/conversations)
- social::meta::instagram::messages::list (GET /{ig-conversation-id}/messages)
- social::meta::instagram::messages::send (POST /{ig-user-id}/messages)

## Webhooks
- social::meta::webhooks::subscribe_app (POST /{app-id}/subscriptions)
- social::meta::webhooks::list_app (GET /{app-id}/subscriptions)
- social::meta::webhooks::delete_app (DELETE /{app-id}/subscriptions?object=...)  
  events: page feed/messages/mentions, instagram comments/mentions/messages, ads events.

## Ads / Marketing (référence)
- social::meta::ads::list_accounts (GET /act_<ad_account_id>/campaigns|adsets|ads)
- social::meta::ads::create_campaign (POST /act_<id>/campaigns)
- social::meta::ads::create_adset (POST /act_<id>/adsets)
- social::meta::ads::create_ad (POST /act_<id>/ads)
- social::meta::ads::insights (GET /act_<id>/insights)

## Errors (norme)
- INVALID_ARGUMENT, PERMISSION_DENIED, RATE_LIMITED, PROVIDER_ERROR

## Pagination
- cursor-based: `after`, `before`, `limit`.

## Rate limit meta
- headers: `X-App-Usage`, `X-Page-Usage`, `X-Business-Use-Case-Usage`; 429 or 4/613 codes.

