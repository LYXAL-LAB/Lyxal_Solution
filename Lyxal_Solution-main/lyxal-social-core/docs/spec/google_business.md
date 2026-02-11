# Spec Google Business Profile — Primitives endpoint-level (Phase 2)

Convention : `social::google_business::<domaine>::<action>`. 1 primitive = 1 endpoint officiel Business Profile / Business Information / Performance / Notifications. Pas de logique métier.

## Auth / scopes
- OAuth Google scope principal : `https://www.googleapis.com/auth/business.manage`.

## Accounts / Locations
- social::google_business::accounts::list (GET /v1/accounts)
- social::google_business::accounts::get (GET /v1/{name=accounts/*})
- social::google_business::locations::list (GET /v1/accounts/{accountId}/locations)
- social::google_business::locations::get (GET /v1/{name=locations/*})
- social::google_business::locations::create (POST /v1/accounts/{accountId}/locations)
- social::google_business::locations::update (PATCH /v1/{name=locations/*})
- social::google_business::locations::delete (POST /v1/{name=locations/*}:delete)
- social::google_business::locations::undelete (POST /v1/{name=locations/*}:undelete)
- social::google_business::locations::transfer (POST /v1/{name=locations/*}:transfer)
- social::google_business::locations::verify (POST /v1/{name=locations/*}:verify)
- social::google_business::locations::clear_association (POST /v1/{name=locations/*}:clearLocationAssociation)

## Admins
- social::google_business::locations::list_admins (GET /v1/{name=locations/*}/admins)
- social::google_business::locations::add_admin (POST /v1/{name=locations/*}/admins)
- social::google_business::locations::remove_admin (DELETE /v1/{name=locations/*}/admins/{adminId})
- social::google_business::accounts::list_admins (GET /v1/{name=accounts/*}/admins)
- social::google_business::accounts::add_admin (POST /v1/{name=accounts/*}/admins)
- social::google_business::accounts::remove_admin (DELETE /v1/{name=accounts/*}/admins/{adminId})

## Attributes / Metadata
- social::google_business::locations::list_attributes (GET /v1/{name=locations/*}/attributes)
- social::google_business::locations::get_google_updates (GET /v1/{name=locations/*}/googleUpdated)

## Posts (Local Posts)
- social::google_business::posts::create (POST /v1/{parent=locations/*}/localPosts)
- social::google_business::posts::list (GET /v1/{parent=locations/*}/localPosts)
- social::google_business::posts::get (GET /v1/{name=locations/*/localPosts/*})
- social::google_business::posts::update (PATCH /v1/{name=locations/*/localPosts/*})
- social::google_business::posts::delete (DELETE /v1/{name=locations/*/localPosts/*})

## Reviews
- social::google_business::reviews::list (GET /v1/{name=locations/*}/reviews)
- social::google_business::reviews::get (GET /v1/{name=locations/*/reviews/*})
- social::google_business::reviews::reply (PATCH /v1/{name=locations/*/reviews/*}) — répondre/éditer réponse

## Questions & Answers
- social::google_business::questions::list (GET /v1/{name=locations/*}/questions)
- social::google_business::questions::create (POST /v1/{parent=locations/*}/questions)
- social::google_business::questions::get (GET /v1/{name=locations/*/questions/*})
- social::google_business::answers::list (GET /v1/{name=locations/*/questions/*}/answers)
- social::google_business::answers::create (POST /v1/{parent=locations/*/questions/*}/answers)
- social::google_business::answers::update (PATCH /v1/{name=locations/*/questions/*/answers/*})
- social::google_business::answers::delete (DELETE /v1/{name=locations/*/questions/*/answers/*})

## Media
- social::google_business::media::upload (POST /upload/v1/{parent=locations/*}/media)
- social::google_business::media::create (POST /v1/{parent=locations/*}/media)
- social::google_business::media::get (GET /v1/{name=locations/*/media/*})
- social::google_business::media::delete (DELETE /v1/{name=locations/*/media/*})
- social::google_business::media::list (GET /v1/{parent=locations/*}/media)

## Place Actions
- social::google_business::place_actions::list (GET /v1/{name=locations/*}/placeActionLinks)
- social::google_business::place_actions::create (POST /v1/{parent=locations/*}/placeActionLinks)
- social::google_business::place_actions::update (PATCH /v1/{name=locations/*/placeActionLinks/*})
- social::google_business::place_actions::delete (DELETE /v1/{name=locations/*/placeActionLinks/*})

## Performance / Insights
- social::google_business::insights::search_keywords (GET /v1/{name=locations/*}/searchkeywords/insights)
- social::google_business::insights::place_actions (GET /v1/{name=locations/*}/placeAction/insights)
- social::google_business::insights::local_posts (GET /v1/{name=locations/*}/localPost/insights)
- social::google_business::insights::reviews (GET /v1/{name=locations/*}/reviews/insights)
- social::google_business::insights::media (GET /v1/{name=locations/*}/media/insights)

## Notifications / Webhooks
- social::google_business::notifications::subscribe (POST /v1/notifications:subscribe)
- social::google_business::notifications::unsubscribe (POST /v1/notifications:unsubscribe)
- social::google_business::notifications::list (GET /v1/notifications)

## Verifications
- social::google_business::verifications::start (POST /v1/{name=locations/*}:verify)
- social::google_business::verifications::status (GET /v1/{name=locations/*}/verification)
- social::google_business::verifications::confirm (POST /v1/{name=locations/*}:confirm)

## Pagination
- `pageSize`, `pageToken` pour listes (locations, posts, reviews, questions, media).

## Rate limit meta
- Quota GCP : 429 RESOURCE_EXHAUSTED / 403 rateLimitExceeded.

## Errors (norme)
- INVALID_ARGUMENT, PERMISSION_DENIED, RATE_LIMITED, PROVIDER_ERROR

