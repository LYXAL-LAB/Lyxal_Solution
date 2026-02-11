# Inventaire complet — Google Business Profile API (Phase S1)

Sources officielles : Google Business Profile API (ex-Google My Business) sur developers.google.com (https://developers.google.com/my-business/reference/businessinformation, businessprofileperformance, accounts, notifications). 1 endpoint = 1 entrée. Aucun code.

## Auth / OAuth2
- OAuth Google : consent + `https://www.googleapis.com/auth/business.manage` (scope principal). Ancien scope lecture : `.../auth/business.manage` couvre lecture/écriture.
- Endpoints token : `https://accounts.google.com/o/oauth2/auth`, `https://oauth2.googleapis.com/token`.
- API Key possible pour certaines lectures publiques (limité).

## Comptes / Locations
- `GET /v1/accounts` — lister comptes de l’utilisateur
- `GET /v1/{name=accounts/*}` — détails compte
- `GET /v1/accounts/{accountId}/locations` — liste des établissements (pagination pageToken/pageSize)
- `GET /v1/{name=locations/*}` — détail
- `PATCH /v1/{name=locations/*}` — update (mask)
- `POST /v1/accounts/{accountId}/locations` — créer
- `POST /v1/locations:reportInsights` — insights legacy (superseded par performance API)
- `GET /v1/locations/{locationId}/admins` — admins
- `POST /v1/locations/{locationId}/admins` / `DELETE` — gestion admins
- `POST /v1/{name=locations/*}:transfer` — transfert d’établissement
- `POST /v1/{name=locations/*}:delete` — suppression
- `POST /v1/{name=locations/*}:undelete` — restauration
- `POST /v1/{name=locations/*}:verify` — vérification
- `POST /v1/{name=locations/*}:clearLocationAssociation` (comptes liés)
- Permissions : scope business.manage + rôle sur compte ; 403 si non autorisé.

## Business Information (nouvelles surfaces v1)
- `GET /v1/{name=locations/*}/attributes`
- `GET /v1/{name=locations/*}/attributes:search` (deprecated ?)
- `PATCH /v1/{name=locations/*}` (businessinformation API) — metadonnées établissement
- `GET /v1/locations/{locationId}/googleUpdated` — updates Google
- `PATCH /v1/{name=locations/*}/localPosts/{postId}` (selon doc posts API si exposé)

## Local Posts (Updates)
- `POST /v1/{parent=locations/*}/localPosts` — créer un post (event, offer, update)
- `GET /v1/{parent=locations/*}/localPosts`
- `GET /v1/{name=locations/*/localPosts/*}`
- `PATCH /v1/{name=locations/*/localPosts/*}`
- `DELETE /v1/{name=locations/*/localPosts/*}`
- Filtres : pagination pageSize/pageToken; état (live/expired).
- Media : upload via Media endpoints (voir section Media).

## Reviews
- `GET /v1/{name=locations/*}/reviews` — liste (pagination)
- `GET /v1/{name=locations/*/reviews/*}`
- `PATCH /v1/{name=locations/*/reviews/*}` — réponse propriétaire
- Permissions : `business.manage` et droits sur l’établissement.

## Questions / Answers
- `GET /v1/{name=locations/*}/questions`
- `POST /v1/{parent=locations/*}/questions`
- `POST /v1/{parent=locations/*/questions/*}/answers`
- `GET /v1/{name=locations/*/questions/*}`
- `GET /v1/{name=locations/*/questions/*}/answers`
- `PATCH /v1/{name=locations/*/questions/*/answers/*}`
- `DELETE /v1/{name=locations/*/questions/*/answers/*}`
- Pagination : pageToken/pageSize.

## Media (Photos / Videos / Logo / Cover)
- `POST /upload/v1/{parent=locations/*}/media` (resumable upload)
- `POST /v1/{parent=locations/*}/media` (create metadata)
- `GET /v1/{name=locations/*/media/*}`
- `DELETE /v1/{name=locations/*/media/*}`
- Media types : profile, cover, logo, additional; dimensions/size limits; video support.
- Pagination : list media via `GET /v1/{parent=locations/*}/media`

## Hours / Service Areas / Menus
- Inclus dans `PATCH /v1/{name=locations/*}` via fields mask :
  - `regularHours`, `specialHours`
  - `serviceArea`, `places`, `regionCode`
  - `labels`, `categories`, `profile`, `websiteUri`, `phoneNumbers`
  - Menus/food/links selon vertical si disponible (`mealService`, `menuUrl`, `orderUrl`, `deliveryUrl`)

## Notifications / Webhooks
- Les webhooks Business Profile sont limités : il existe un service Notifications (pub/sub Cloud Pub/Sub) pour certains événements (ex: updates de reviews, questions). Documentation Notifications API :
  - `POST /v1/notifications:subscribe`
  - `POST /v1/notifications:unsubscribe`
  - `GET /v1/notifications` (list subscriptions)
- Configuration sur Cloud Pub/Sub (topic, subscription). Payload JSON avec resourceName + eventType (e.g., REVIEW_UPDATE, QANDA).
- Permissions : nécessite configuration GCP + droits sur compte Business.

## Performance / Insights (Business Profile Performance API)
- `GET /v1/{name=locations/*}/searchkeywords/insights` — impressions par keyword
- `GET /v1/{name=locations/*}/placeAction/insights` — clics (calls, directions, website)
- `GET /v1/{name=locations/*}/localPost/insights` — vues/clics de posts
- `GET /v1/{name=locations/*}/reviews/insights` — agrégats reviews
- `GET /v1/{name=locations/*}/media/insights` — vues/clics media
- Paramètres : `dailyMetric`, `timeRange` (startTime/endTime), `dimensions` (AGGREGATED)

## Account Management (Admins, Links)
- `GET /v1/{name=accounts/*}/admins` / `POST` / `DELETE`
- `GET /v1/{name=locations/*}/admins` / `POST` / `DELETE`
- `POST /v1/{name=locations/*}:associate` (lier à un compte)
- `POST /v1/{name=locations/*}:clearAssociation`

## Verifications
- `POST /v1/{name=locations/*}:verify` — demande de vérification (methods: MAIL, PHONE, EMAIL, VIDEO)
- `GET /v1/{name=locations/*}/verification` — statut
- `POST /v1/{name=locations/*}:confirm` — confirmer code

## Place Actions / URLs
- `GET /v1/{name=locations/*}/placeActionLinks`
- `POST /v1/{parent=locations/*}/placeActionLinks`
- `PATCH /v1/{name=locations/*/placeActionLinks/*}`
- `DELETE /v1/{name=locations/*/placeActionLinks/*}`
- Champs : `uri`, `placeActionType` (APPOINTMENT, ORDER, RESERVE, etc.), `providerType`

## Batch / Async
- Certaines routes supportent batch via Google APIs batch endpoint (HTTP multipart/mixed) — non recommandé si noté; sinon, appels unitaires.

## Pagination / filtres
- `pageSize`, `pageToken` pour listes (locations, posts, media, reviews, Q&A).
- Filtres temporels pour insights (startTime/endTime).

## Rate limits / quotas
- Quotas par projet Google Cloud (API dashboard). `429 RESOURCE_EXHAUSTED` ou 403 avec reason `rateLimitExceeded`.
- Respecter limites d’upload media (taille/débit).

## Erreurs typiques
- 400 invalidArgument, 401/403 permissionDenied (scope manquant ou pas d’accès), 404 notFound (location/post/media), 409 conflict (verification en cours), 429 resourceExhausted (quota), 503 unavailable.
- Messages incluent `status`, `message`, `details` (FieldViolations).

## Permissions / scopes
- Principal : `https://www.googleapis.com/auth/business.manage`
- Lecture publique (limité) possible avec API key sur certaines ressources mais la majorité requiert OAuth.

## Notes de conformité
- HTTPS obligatoire. Tokens OAuth protégés. Vérification établissement requise pour certaines actions (posts, edits).
- Webhooks via Pub/Sub nécessitent projet GCP configuré. Mettre à jour l’inventaire à chaque évolution de la doc.  

