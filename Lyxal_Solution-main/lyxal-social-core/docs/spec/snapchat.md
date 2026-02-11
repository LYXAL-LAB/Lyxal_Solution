# Spec Snapchat — Primitives endpoint-level (Phase 2)

Convention : `social::snapchat::<domaine>::<action>`. Snap Kit + Ads API. 1 primitive = 1 endpoint. Pas de logique métier.

## Auth / scopes
- OAuth2 : Login Kit scopes `user.display_name`, `user.external_id`, `user.bitmoji.avatar`. Ads API scopes via business access. Story/Display requires partner approval.

## Identity / Bitmoji
- social::snapchat::users::me (GET /me via SDK)  
- social::snapchat::bitmoji::avatar (GET /bitmoji/avatar)

## Creative / Share Kit (client-side flow)
- social::snapchat::share::send (SDK mobile; pas d’endpoint serveur — référencé pour mapping, aucun appel HTTP)

## Story / Display (partenaires)
- social::snapchat::stories::list_public (GET /public_stories) — si autorisé
- social::snapchat::stories::list_publisher (GET /publisher_stories) — si autorisé

## Ads API (Marketing)
- Accounts/Orgs :
  - social::snapchat::ads::list_accounts (GET /v1/adaccounts)
  - social::snapchat::ads::get_account (GET /v1/adaccounts/{id})
  - social::snapchat::ads::list_organizations (GET /v1/organizations)
- Campaign hierarchy :
  - social::snapchat::ads::list_campaigns (GET /v1/adaccounts/{id}/campaigns)
  - social::snapchat::ads::create_campaign (POST /v1/adaccounts/{id}/campaigns)
  - social::snapchat::ads::update_campaign (PATCH /v1/adaccounts/{id}/campaigns/{cid})
  - social::snapchat::ads::list_adsets (GET /v1/adaccounts/{id}/adsets)
  - social::snapchat::ads::create_adset (POST /v1/adaccounts/{id}/adsets)
  - social::snapchat::ads::update_adset (PATCH /v1/adaccounts/{id}/adsets/{asid})
  - social::snapchat::ads::list_ads (GET /v1/adaccounts/{id}/ads)
  - social::snapchat::ads::create_ad (POST /v1/adaccounts/{id}/ads)
  - social::snapchat::ads::update_ad (PATCH /v1/adaccounts/{id}/ads/{adid})
- Creatives / Media :
  - social::snapchat::ads::list_creatives (GET /v1/adaccounts/{id}/creatives)
  - social::snapchat::ads::create_creative (POST /v1/adaccounts/{id}/creatives)
  - social::snapchat::ads::update_creative (PATCH /v1/adaccounts/{id}/creatives/{cid})
  - social::snapchat::ads::upload_asset (media upload endpoints per Ads doc)
- Audiences / Catalogs :
  - social::snapchat::ads::list_audiences (GET /v1/adaccounts/{id}/audiences)
  - social::snapchat::ads::create_audience (POST /v1/adaccounts/{id}/audiences)
  - social::snapchat::ads::list_catalogs (GET /v1/adaccounts/{id}/catalogs)
  - social::snapchat::ads::create_catalog (POST /v1/adaccounts/{id}/catalogs)
- Conversions / Pixels :
  - social::snapchat::ads::create_pixel (POST /v1/adaccounts/{id}/pixels)
  - social::snapchat::ads::list_conversions (GET /v1/adaccounts/{id}/conversions)
  - social::snapchat::ads::post_conversions (POST /v1/adaccounts/{id}/conversions)
- Reporting :
  - social::snapchat::ads::reports (GET /v1/adaccounts/{id}/reports)
- Rate/pagination : `limit`/`offset`; 429 with Retry-After.

## Webhooks / Conversions
- social::snapchat::webhooks::subscribe (POST /v1/adaccounts/{id}/conversions) — server-to-server events ingestion (payload event)
- social::snapchat::webhooks::status (GET /v1/adaccounts/{id}/conversions) — verify ingestion status
- CRC/secret : selon config Ads; Snap Kit webhooks pour login/bitmoji limited.

## Errors (norme)
- INVALID_ARGUMENT, PERMISSION_DENIED, RATE_LIMITED, PROVIDER_ERROR

## Pagination
- Ads listings : `limit`, `offset`; reports async (request_id → poll).

## Rate limit meta
- Ads API : contract/tier; 429 Retry-After.

