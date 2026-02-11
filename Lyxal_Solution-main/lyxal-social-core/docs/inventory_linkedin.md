# Inventaire complet — LinkedIn API (Phase S1)

Sources officielles : LinkedIn Marketing Developer Platform / Consumer Solutions (https://learn.microsoft.com/linkedin/). 1 endpoint = 1 entrée. Aucun code.

## Auth / OAuth2
- `GET https://www.linkedin.com/oauth/v2/authorization` (auth code)
- `POST https://www.linkedin.com/oauth/v2/accessToken` (code→token, refresh_token for long-lived if enabled)
- Scopes (exemples) :
  - Auth de base : `r_liteprofile`, `r_emailaddress`
  - Partage/UGC : `w_member_social`
  - Pages : `rw_organization_admin`, `r_organization_social`, `w_organization_social`
  - Ads/Marketing : `r_ads`, `r_ads_reporting`, `rw_ads`
  - Marketing Dev Platform : `r_organization_admin`, `r_1st_connections_size`, `rw_organization_admin`, `rw_organization_social`, `r_organization_social`
- Erreurs : 401/403 scope manquant, 429 rate limit, invalid_token, etc.

## Profils / Identité
- `GET /v2/me` — profil membre (URN, localizedFirstName, localizedLastName)
- `GET /v2/emailAddress?q=members&projection=(elements*(handle~))` — email
- Pagination : non applicable pour me/email ; headers de limite applicables.

## Organisations (Pages)
- `GET /v2/organizations/{org}` — détails organisation
- `GET /v2/organizationAcls?q=roleAssignee&role=ADMINISTRATOR&state=APPROVED&assignee=urn:li:person:{id}` — listes des orgs administrées
- `GET /v2/organizationAcls?q=organization&organization=urn:li:organization:{id}` — ACLs
- Permissions : `rw_organization_admin`, `r_organization_admin`

## Partage de contenu (UGC / Posts)
- UGC Posts (recommandé) :
  - `POST /v2/ugcPosts` — créer un post (author=urn:li:person|organization, lifecycleState=PUBLISHED, specificContent, visibility)
  - `GET /v2/ugcPosts/{id}`
  - `DELETE /v2/ugcPosts/{id}`
- Shares (legacy) :
  - `POST /v2/shares` — créer un partage (commentary + content)
  - `GET /v2/shares?q=owners&owners=urn:li:organization:{id}` — lister les shares d’un owner
- Articles (documentation spécifique, publication via shares/ugcPosts avec content.article)
- Supports media :
  - `POST /v2/assets?action=registerUpload` — init upload (image/video)
  - upload via URL retournée
  - `POST /v2/assets/{asset}/action=complete` — compléter
  - asset URN référencé dans `ugcPosts`/`shares`
- Permissions : `w_member_social` (personne), `w_organization_social` (page)
- Rate limits : global + par ressource (429)

## Commentaires / Réactions
- Réactions :
  - `POST /v2/reactions` (object + actor)
  - `DELETE /v2/reactions/(actor,object)`
  - `GET /v2/reactions/(object)` — liste (pagination start/count)
- Commentaires :
  - `POST /v2/socialActions/{urn}/comments`
  - `GET /v2/socialActions/{urn}/comments` (pagination start/count)
  - `DELETE /v2/comments/{id}`
- Social actions URN typiquement `urn:li:ugcPost:{id}` ou `urn:li:share:{id}`
- Permissions : même que post (w_member_social / w_organization_social)

## Social Stream / Organization Feed
- `GET /v2/socialActions/urn:li:organization:{id}/shares` (selon doc)
- `GET /v2/socialActions/{urn}/insights` (si exposé)
- `GET /v2/organizationalEntityShareStatistics?q=organizationalEntity&organizationalEntity=urn:li:organization:{id}&timeIntervals=(timeRange:(start,end),timeGranularityType:DAY)` — stats posts org

## Analytics / Statistics
- Posts :
  - `GET /v2/organizationalEntityShareStatistics` (per post via URN ou par org)
  - `GET /v2/networkSizes/urn:li:organization:{id}?edgeType=CompanyFollowedBy` — followers count
- Ads (si autorisé) :
  - `GET /v2/adAnalytics` (impressions, clicks, spend) — Marketing API
  - `GET /v2/campaignGroups`, `GET /v2/campaigns`, `GET /v2/adAccounts`
- Permissions : `r_ads`, `r_ads_reporting` pour Ads.

## Messaging (limitations)
- `POST /v2/messages` — envoyer message (person → connections) sous conditions strictes (scope `w_member_social` et restrictions d’usage). Non destiné au mass messaging.
- `GET /v2/messages` — lecture limitée (deprecated pour certains cas).
- Non central pour ce module, mais listé pour exhaustivité.

## Webhooks / Notifications
- REST Hook (JavaScript SDK / server) via “Notifications” (legacy) — non largement documenté pour posts; aujourd’hui privilégié : “Webhooks” Marketing Developer Platform
- Marketing Webhooks :
  - `POST /resthooks` (subscribe) / `DELETE /resthooks/{id}`
  - Événements : `adCampaign.changeState`, `adAccount.change`, `adCreative.change`, etc. (selon doc Marketing)
- Security : validation de secret, signature (selon doc)

## Permissions / Scopes (rappel)
- Identité : `r_liteprofile`, `r_emailaddress`
- Social : `w_member_social`, `r_organization_social`, `w_organization_social`, `rw_organization_admin`
- Organizations : `r_organization_admin`
- Ads : `r_ads`, `r_ads_reporting`, `rw_ads`

## Rate limits / quotas
- En-têtes : `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `Retry-After` (en secondes) sur 429.
- Quotas par application et par ressource ; usage marketing plus strict.

## Pagination / filtres
- Pagination standard : `start`, `count`
- Certains endpoints : filtres par `q=owners`, `q=roleAssignee`, `timeIntervals` pour stats, `owners=urn:li:organization:{id}`

## Erreurs typiques
- 401 invalid/expired token
- 403 insufficient scope/permission or member not admin
- 404 resource not found or hidden
- 429 rate limit exceeded (respect `Retry-After`)
- 400 invalid payload/field violations
- 500/503 server errors

## Notes de conformité
- HTTPS obligatoire.
- Ne pas stocker ni logguer tokens.
- Publication requiert la complétion d’upload d’asset avant UGC/shares.
- Vérifier l’éligibilité app (Marketing Developer Platform) pour endpoints Ads/Marketing.

