# Spec X (Twitter) — Primitives endpoint-level (Phase 2)

Convention : `social::x::<domaine>::<action>`. 1 primitive = 1 endpoint officiel (v2 sauf upload/media v1.1, AAA webhooks). Pas de logique métier.

## Auth / scopes
- OAuth2 user context (scopes : tweet.read/write, users.read, follows.read/write, like.read/write, list.read/write, dm.read/write, space.read, media.write, bookmark.read/write, offline.access).
- OAuth1.0a user context (uploads v1.1, Account Activity webhooks).

## Tweets / Engagement
- social::x::tweets::get (GET /2/tweets/{id})
- social::x::tweets::batch_get (GET /2/tweets)
- social::x::tweets::create (POST /2/tweets)
- social::x::tweets::delete (DELETE /2/tweets/{id})
- social::x::tweets::hide_reply (POST /2/tweets/{id}/hidden)
- social::x::tweets::liking_users (GET /2/tweets/{id}/liking_users)
- social::x::tweets::retweeted_by (GET /2/tweets/{id}/retweeted_by)
- social::x::likes::create (POST /2/users/{id}/likes)
- social::x::likes::delete (DELETE /2/users/{id}/likes/{tweet_id})
- social::x::retweets::create (POST /2/users/{id}/retweets)
- social::x::retweets::delete (DELETE /2/users/{source_user_id}/retweets/{tweet_id})
- social::x::bookmarks::create (POST /2/users/{id}/bookmarks)
- social::x::bookmarks::delete (DELETE /2/users/{id}/bookmarks/{tweet_id})

## Timelines / Lists
- social::x::timelines::user_tweets (GET /2/users/{id}/tweets)
- social::x::timelines::mentions (GET /2/users/{id}/mentions)
- social::x::timelines::liked (GET /2/users/{id}/liked_tweets)
- social::x::timelines::bookmarks (GET /2/users/{id}/bookmarks)
- social::x::lists::get (GET /2/lists/{id})
- social::x::lists::list_followers (GET /2/lists/{id}/followers)
- social::x::lists::list_members (GET /2/lists/{id}/members)
- social::x::lists::create (POST /2/lists)
- social::x::lists::delete (DELETE /2/lists/{id})
- social::x::lists::update (PUT /2/lists/{id})
- social::x::lists::add_member (POST /2/lists/{id}/members)
- social::x::lists::remove_member (DELETE /2/lists/{id}/members/{user_id})
- social::x::lists::follow (POST /2/users/{id}/followed_lists)
- social::x::lists::unfollow (DELETE /2/users/{id}/followed_lists/{list_id})

## Search / Stream
- social::x::search::recent (GET /2/tweets/search/recent)
- social::x::search::all (GET /2/tweets/search/all) — tier supérieur
- social::x::stream::filtered (GET /2/tweets/search/stream)
- social::x::stream::rules::list (GET /2/tweets/search/stream/rules)
- social::x::stream::rules::update (POST /2/tweets/search/stream/rules)
- social::x::stream::sample (GET /2/tweets/sample/stream)

## Users / Follows / Blocks / Mutes
- social::x::users::lookup (GET /2/users/{id})
- social::x::users::lookup_batch (GET /2/users)
- social::x::users::by_username (GET /2/users/by/username/{username})
- social::x::follows::list_following (GET /2/users/{id}/following)
- social::x::follows::list_followers (GET /2/users/{id}/followers)
- social::x::follows::create (POST /2/users/{id}/following)
- social::x::follows::delete (DELETE /2/users/{source_user_id}/following/{target_user_id})
- social::x::blocks::list (GET /2/users/{id}/blocking)
- social::x::blocks::create (POST /2/users/{id}/blocking)
- social::x::blocks::delete (DELETE /2/users/{source_user_id}/blocking/{target_user_id})
- social::x::mutes::list (GET /2/users/{id}/muting)
- social::x::mutes::create (POST /2/users/{id}/muting)
- social::x::mutes::delete (DELETE /2/users/{source_user_id}/muting/{target_user_id})

## Media
- social::x::media::init_upload (POST /1.1/media/upload INIT)
- social::x::media::append_upload (POST /1.1/media/upload APPEND)
- social::x::media::finalize_upload (POST /1.1/media/upload FINALIZE)
- social::x::media::status (GET /1.1/media/upload STATUS)

## Direct Messages (v2)
- social::x::dm::list_with (GET /2/dm_conversations/with/{participant_id}/dm_events)
- social::x::dm::list (GET /2/dm_conversations/{conversation_id}/dm_events)
- social::x::dm::send_to (POST /2/dm_conversations/with/{participant_id}/messages)
- social::x::dm::send (POST /2/dm_conversations/{conversation_id}/messages)

## Spaces
- social::x::spaces::get (GET /2/spaces/{id})
- social::x::spaces::list_by_creators (GET /2/spaces)
- social::x::spaces::search (GET /2/spaces/search)
- social::x::spaces::buyers (GET /2/spaces/{id}/buyers)
- social::x::spaces::tweets (GET /2/spaces/{id}/tweets)

## Compliance
- social::x::compliance::create_job (POST /2/compliance/jobs)
- social::x::compliance::list_jobs (GET /2/compliance/jobs)
- social::x::compliance::get_job (GET /2/compliance/jobs/{id})

## Account Activity API (v1.1 webhooks)
- social::x::aaa::register_webhook (POST /1.1/account_activity/all/{env}/webhooks.json)
- social::x::aaa::list_webhooks (GET /1.1/account_activity/all/webhooks.json)
- social::x::aaa::delete_webhook (DELETE /1.1/account_activity/all/{env}/webhooks/{id}.json) [if supported]
- social::x::aaa::subscribe (POST /1.1/account_activity/all/{env}/subscriptions.json)
- social::x::aaa::list_subscriptions (GET /1.1/account_activity/all/{env}/subscriptions/list.json)
- CRC challenge via GET on webhook URL avec crc_token → réponse HMAC (hors primitive HTTP)

## Pagination
- `pagination_token` + `max_results` pour la plupart des listes v2.

## Rate limit meta
- Headers `x-rate-limit-limit`, `remaining`, `reset`; 429 sur dépassement. Streams : 420/backoff.

## Errors (norme)
- INVALID_ARGUMENT, PERMISSION_DENIED, RATE_LIMITED, PROVIDER_ERROR

