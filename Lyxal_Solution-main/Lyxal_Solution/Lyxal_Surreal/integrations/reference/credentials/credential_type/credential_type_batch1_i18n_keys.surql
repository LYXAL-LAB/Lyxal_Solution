-- =============================================================================================
-- |
-- | Fichier : credential_type_batch1_i18n_keys.surql (SEED DATA)
-- | Module : integrations > reference > credentials > credential_type
-- | Description : Clés i18n pour le Batch 1 des credential types.
-- |
-- | Batch 1 : Credentials fondamentaux (9 types)
-- | • HTTP génériques (7) : BasicAuth, BearerAuth, CustomAuth, DigestAuth, HeaderAuth, QueryAuth, SslAuth
-- | • OAuth génériques (2) : OAuth1Api, OAuth2Api
-- |
-- | Total : 27 clés i18n (9 credentials × 3 clés chacun)
-- |
-- =============================================================================================

-- =====================================================
-- HTTP BASIC AUTH (3 clés)
-- =====================================================

CREATE i18n_key:credential_type_http_basic_auth_name SET
    description = "Nom affiché du credential type HTTP Basic Authentication";

CREATE i18n_key:credential_type_http_basic_auth_description SET
    description = "Description complète de HTTP Basic Authentication pour credentials";

CREATE i18n_key:credential_type_http_basic_auth_tooltip SET
    description = "Tooltip d'aide pour HTTP Basic Auth credentials";

-- =====================================================
-- HTTP BEARER AUTH (3 clés)
-- =====================================================

CREATE i18n_key:credential_type_http_bearer_auth_name SET
    description = "Nom affiché du credential type HTTP Bearer Authentication";

CREATE i18n_key:credential_type_http_bearer_auth_description SET
    description = "Description complète de HTTP Bearer Authentication pour credentials";

CREATE i18n_key:credential_type_http_bearer_auth_tooltip SET
    description = "Tooltip d'aide pour HTTP Bearer Auth credentials";

-- =====================================================
-- HTTP CUSTOM AUTH (3 clés)
-- =====================================================

CREATE i18n_key:credential_type_http_custom_auth_name SET
    description = "Nom affiché du credential type HTTP Custom Authentication";

CREATE i18n_key:credential_type_http_custom_auth_description SET
    description = "Description complète de HTTP Custom Authentication pour credentials";

CREATE i18n_key:credential_type_http_custom_auth_tooltip SET
    description = "Tooltip d'aide pour HTTP Custom Auth credentials";

-- =====================================================
-- HTTP DIGEST AUTH (3 clés)
-- =====================================================

CREATE i18n_key:credential_type_http_digest_auth_name SET
    description = "Nom affiché du credential type HTTP Digest Authentication";

CREATE i18n_key:credential_type_http_digest_auth_description SET
    description = "Description complète de HTTP Digest Authentication pour credentials";

CREATE i18n_key:credential_type_http_digest_auth_tooltip SET
    description = "Tooltip d'aide pour HTTP Digest Auth credentials";

-- =====================================================
-- HTTP HEADER AUTH (3 clés)
-- =====================================================

CREATE i18n_key:credential_type_http_header_auth_name SET
    description = "Nom affiché du credential type HTTP Header Authentication";

CREATE i18n_key:credential_type_http_header_auth_description SET
    description = "Description complète de HTTP Header Authentication pour credentials";

CREATE i18n_key:credential_type_http_header_auth_tooltip SET
    description = "Tooltip d'aide pour HTTP Header Auth credentials";

-- =====================================================
-- HTTP QUERY AUTH (3 clés)
-- =====================================================

CREATE i18n_key:credential_type_http_query_auth_name SET
    description = "Nom affiché du credential type HTTP Query Authentication";

CREATE i18n_key:credential_type_http_query_auth_description SET
    description = "Description complète de HTTP Query Authentication pour credentials";

CREATE i18n_key:credential_type_http_query_auth_tooltip SET
    description = "Tooltip d'aide pour HTTP Query Auth credentials";

-- =====================================================
-- HTTP SSL AUTH (3 clés)
-- =====================================================

CREATE i18n_key:credential_type_http_ssl_auth_name SET
    description = "Nom affiché du credential type HTTP SSL Certificate Authentication";

CREATE i18n_key:credential_type_http_ssl_auth_description SET
    description = "Description complète de HTTP SSL Certificate Authentication pour credentials";

CREATE i18n_key:credential_type_http_ssl_auth_tooltip SET
    description = "Tooltip d'aide pour HTTP SSL Auth credentials";

-- =====================================================
-- OAUTH1 API (3 clés)
-- =====================================================

CREATE i18n_key:credential_type_oauth1_api_name SET
    description = "Nom affiché du credential type OAuth 1.0a Generic API";

CREATE i18n_key:credential_type_oauth1_api_description SET
    description = "Description complète de OAuth 1.0a Generic API pour credentials";

CREATE i18n_key:credential_type_oauth1_api_tooltip SET
    description = "Tooltip d'aide pour OAuth 1.0a API credentials";

-- =====================================================
-- OAUTH2 API (3 clés)
-- =====================================================

CREATE i18n_key:credential_type_oauth2_api_name SET
    description = "Nom affiché du credential type OAuth 2.0 Generic API";

CREATE i18n_key:credential_type_oauth2_api_description SET
    description = "Description complète de OAuth 2.0 Generic API pour credentials";

CREATE i18n_key:credential_type_oauth2_api_tooltip SET
    description = "Tooltip d'aide pour OAuth 2.0 API credentials";

-- =====================================================
-- VÉRIFICATION
-- =====================================================

/*
SELECT 
    id,
    description
FROM i18n_key
WHERE string::starts_with(meta::id(id), 'credential_type_')
  AND (
    string::contains(meta::id(id), 'http_') 
    OR string::contains(meta::id(id), 'oauth')
  )
ORDER BY id ASC;
*/

-- =============================================================================================

