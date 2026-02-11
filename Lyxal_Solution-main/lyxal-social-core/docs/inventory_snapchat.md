# Inventaire complet — Snapchat API (Phase S1)

Sources officielles : Snap Kit / Snapchat for Developers (https://developers.snap.com). 1 endpoint = 1 entrée. Aucun code.

## Auth / OAuth2
- `GET https://accounts.snapchat.com/login/oauth2/authorize`
- `POST https://accounts.snapchat.com/login/oauth2/token`
- Scopes (exemples) :
  - Login Kit : `user.display_name`, `user.bitmoji.avatar`, `user.external_id`
  - Creative/Share Kit : permissions d’import média (mobile SDK)
  - Marketing (Ads API) : `snapchat-marketing-api` scopes pour ad accounts, campaigns, reports
  - Story Kit (Display): accès public stories (avec autorisations Snap)
- Tokens : access_token, refresh_token (selon app type). PKCE pour mobile.

## Creative / Share Kit (Mobile SDK, pas d’endpoint serveur direct)
- Partage direct depuis l’app : envoi de media (image/video/sticker) vers Snapchat app.
- Pas de route HTTP publique pour publier sur un compte depuis serveur ; flux passe par SDK mobile + client.
- Erreurs : côté SDK (capteurs, compatibilité media). Non pertinent pour backend direct.

## Bitmoji (via Snap Kit)
- `GET /bitmoji/avatar` (via SDK ; endpoints internes Snap Kit, récupérés avec user token)
- Scopes : `user.bitmoji.avatar`
- Quotas : standard API Snap Kit ; 429 si dépassement.

## Login Kit / Identity
- `GET /me` (avec fields projection via SDK GraphQL) — display_name, external_id
- Scopes : `user.display_name`, `user.external_id`, `user.bitmoji.avatar`
- Erreurs : 401 token, 403 scope, 429 rate, 5xx.

## Story Kit / Display (Embeds/Public content)
- Endpoints server-side selon approbation :
  - `GET /public_stories` (filter by map tile/geo/topic) — si autorisé
  - `GET /publisher_stories` (approved partners)
- Embeds : Snap codes/links ; non standard pour tous les devs.
- Quotas : partenariats seulement, rate limit contractuel.

## Marketing API (Ads)
- Auth : même OAuth base mais scopes ads + role sur ad account.
- Core resources :
  - `GET /v1/adaccounts` — lister ad accounts
  - `GET /v1/adaccounts/{id}`
  - `GET /v1/adaccounts/{id}/campaigns` / `POST` / `PATCH`
  - `GET /v1/adaccounts/{id}/adsets` / `POST` / `PATCH`
  - `GET /v1/adaccounts/{id}/ads` / `POST` / `PATCH`
  - `GET /v1/adaccounts/{id}/creatives` / `POST` / `PATCH`
  - `GET /v1/adaccounts/{id}/catalogs` / `POST` / `PATCH`
  - `GET /v1/adaccounts/{id}/audiences` / `POST` / `PATCH`
  - `GET /v1/adaccounts/{id}/conversions` (Snap Pixel/SDK)
  - `GET /v1/adaccounts/{id}/reports` — reporting (impressions, clicks, spend, swipe ups, eCPI)
  - `POST /v1/adaccounts/{id}/pixels` — create pixel
  - `GET /v1/organizations` — orgs/roles
- Upload media :
  - `POST /v1/adaccounts/{id}/creatives` with media reference
  - Media upload endpoints (asset upload) selon doc Ads (multipart)
- Rate limits : contractuels, 429 with `Retry-After`; Ads API has per-app and per-entity throttles.
- Errors : 400 validation, 401/403 auth/role, 404 resource, 429 rate, 5xx.

## Webhooks / Events
- Snap Kit Webhooks : subscription for Login/Bitmoji updates (limited); configured in dev console.
- Ads API Webhooks : conversions/offline events ingestion (server-to-server pixel-like); event post endpoints (e.g., `POST /v1/adaccounts/{id}/conversions`) ; optional callbacks for status.
- Verification : secret/signature (per product).

## Insights / Analytics
- Ads Reporting : `GET /v1/adaccounts/{id}/reports` with breakdowns (time, geo, device), metrics (impressions, spend, clicks, swipe ups, installs if SKAdNetwork), pagination via cursor/offset+limit.
- Story Kit (if approved) : aggregated story views metrics (partner-only).

## Pagination / filtres
- Ads API : `limit`, `offset`, filters by status/date; reports often async with `request_id` then `GET /reports/{request_id}`.
- Collections listing (campaigns/ads/creatives) use pagination params; 100 max typical.

## Rate limits / quotas
- Snap Kit : per-app throttles; 429 with retry.
- Ads API : contract-based; 429 with `Retry-After`; daily quotas on writes.

## Permissions / scopes
- Snap Kit: `user.display_name`, `user.external_id`, `user.bitmoji.avatar`.
- Ads: requires business approval and roles on ad accounts.
- Story/Display: requires partner approval; not open.

## Erreurs typiques
- 400 invalid request / validation error.
- 401/403 invalid token, insufficient permission/role.
- 404 resource not found or not visible.
- 429 rate limit exceeded.
- 500/503 server errors.

## Notes de conformité
- HTTPS obligatoire.
- Aucune API publique pour publier directement sur un compte utilisateur depuis serveur (hors Ads). Les partages utilisateurs passent par le SDK mobile (Share/Creative Kit).
- Vérifier conditions d’accès (Snap Kit app review, Ads business approval). Mettre à jour cet inventaire à chaque révision de la doc Snap.

