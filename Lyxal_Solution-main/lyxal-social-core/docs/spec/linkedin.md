# Spec LinkedIn — Primitives endpoint-level (Phase 2)

Convention : `social::linkedin::<domaine>::<action>`. 1 primitive = 1 endpoint (UGC/Share, Assets, Orgs, Reactions, Comments, Analytics, Ads). Pas de logique métier.

## Auth / scopes
- OAuth2. Scopes : `r_liteprofile`, `r_emailaddress`, `w_member_social`, `r_organization_social`, `w_organization_social`, `rw_organization_admin`, ads scopes (`r_ads`, `r_ads_reporting`, `rw_ads`).

## Profils / Email
- social::linkedin::users::me (GET /v2/me)
- social::linkedin::users::email (GET /v2/emailAddress?q=members&projection=...)

## Organisations (Pages)
- social::linkedin::orgs::get (GET /v2/organizations/{id})
- social::linkedin::orgs::list_admin (GET /v2/organizationAcls?q=roleAssignee&role=ADMINISTRATOR&assignee=urn:li:person:{id})
- social::linkedin::orgs::list_acls (GET /v2/organizationAcls?q=organization&organization=urn:li:organization:{id})

## Assets (upload)
- social::linkedin::assets::register_upload (POST /v2/assets?action=registerUpload)
- social::linkedin::assets::complete (POST /v2/assets/{asset}/action=complete)

## Contenu — UGC Posts
- social::linkedin::ugc::create (POST /v2/ugcPosts)
- social::linkedin::ugc::get (GET /v2/ugcPosts/{id})
- social::linkedin::ugc::delete (DELETE /v2/ugcPosts/{id})

## Contenu — Shares (legacy)
- social::linkedin::shares::create (POST /v2/shares)
- social::linkedin::shares::list_owner (GET /v2/shares?q=owners&owners=urn:li:organization:{id})

## Réactions
- social::linkedin::reactions::create (POST /v2/reactions)
- social::linkedin::reactions::delete (DELETE /v2/reactions/(actor,object))
- social::linkedin::reactions::list (GET /v2/reactions/(object))

## Commentaires
- social::linkedin::comments::create (POST /v2/socialActions/{urn}/comments)
- social::linkedin::comments::list (GET /v2/socialActions/{urn}/comments)
- social::linkedin::comments::delete (DELETE /v2/comments/{id})

## Social Actions / Stats
- social::linkedin::stats::org_entity_share (GET /v2/organizationalEntityShareStatistics?q=organizationalEntity&organizationalEntity=urn:li:organization:{id}&timeIntervals=...)
- social::linkedin::stats::network_size (GET /v2/networkSizes/urn:li:organization:{id}?edgeType=CompanyFollowedBy)

## Ads / Marketing (référence)
- social::linkedin::ads::list_accounts (GET /v2/adAccounts)
- social::linkedin::ads::list_campaigns (GET /v2/adAccounts/{id}/campaigns)
- social::linkedin::ads::list_creatives (GET /v2/adCreatives?q=account&account=urn:li:sponsoredAccount:{id})
- social::linkedin::ads::analytics (GET /v2/adAnalytics)

## Messaging (limité)
- social::linkedin::messages::send (POST /v2/messages) — restrictions fortes
- social::linkedin::messages::list (GET /v2/messages) — si autorisé

## Webhooks / Resthooks (Marketing)
- social::linkedin::webhooks::subscribe (POST /resthooks)
- social::linkedin::webhooks::delete (DELETE /resthooks/{id})
- events : adAccount/adCampaign/adCreative changes (selon doc)

## Errors (norme)
- INVALID_ARGUMENT, PERMISSION_DENIED, RATE_LIMITED, PROVIDER_ERROR

## Pagination
- `start`, `count` pour listes (comments, reactions, shares).

## Rate limit meta
- Headers : `X-RestLi-Reset`, `X-RestLi-Limit`, `X-RestLi-Remaining`; 429 si dépassement.

