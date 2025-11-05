-- =============================================================================================
-- |
-- | Fichier : credential_type_batch1_seeds.surql (SEED DATA)
-- | Module : integrations > reference > credentials > credential_type
-- | Description : Seeds pour le Batch 1 des credential types (9 credentials fondamentaux).
-- |
-- | Batch 1 : Credentials fondamentaux (9 types)
-- | • HTTP génériques (7) : BasicAuth, BearerAuth, CustomAuth, DigestAuth, HeaderAuth, QueryAuth, SslAuth
-- | • OAuth génériques (2) : OAuth1Api, OAuth2Api
-- |
-- | Ces credentials sont génériques (provider = NONE) et servent de base pour tous les autres.
-- |
-- =============================================================================================

-- =====================================================
-- 1. HTTP BASIC AUTH
-- =====================================================

CREATE credential_type:http_basic_auth SET
    name = "httpBasicAuth",
    slug = "http-basic-auth",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_http_basic_auth_name,
        description_i18n: i18n_key:credential_type_http_basic_auth_description
    },
    
    presentation = {
        icon: icon:lock_open,
        color_type: theme_color_type:error,
        tooltip_i18n: i18n_key:credential_type_http_basic_auth_tooltip,
        display_order: 20
    },
    
    auth_type = auth_type:basic_auth,
    provider = NONE,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "username",
                display_name: "Username",
                type: "string",
                is_secret: false,
                required: true,
                description: "Username for HTTP Basic Authentication"
            },
            {
                name: "password",
                display_name: "Password",
                type: "string",
                is_secret: true,
                required: true,
                description: "Password for HTTP Basic Authentication"
            }
        ],
        metadata: {
            encoding: "base64",
            header_format: "Authorization: Basic {base64(username:password)}"
        }
    },
    
    documentation = {
        url: url:basic_auth_rfc7617,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 2. HTTP BEARER AUTH
-- =====================================================

CREATE credential_type:http_bearer_auth SET
    name = "httpBearerAuth",
    slug = "http-bearer-auth",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_http_bearer_auth_name,
        description_i18n: i18n_key:credential_type_http_bearer_auth_description
    },
    
    presentation = {
        icon: icon:badge_check,
        color_type: theme_color_type:info,
        tooltip_i18n: i18n_key:credential_type_http_bearer_auth_tooltip,
        display_order: 10
    },
    
    auth_type = auth_type:bearer_token,
    provider = NONE,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "token",
                display_name: "Bearer Token",
                type: "string",
                is_secret: true,
                required: true,
                description: "Bearer token for authentication (often JWT)"
            }
        ],
        metadata: {
            header_format: "Authorization: Bearer {token}",
            supports_jwt: true
        }
    },
    
    documentation = {
        url: url:bearer_token_rfc6750,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 3. HTTP CUSTOM AUTH
-- =====================================================

CREATE credential_type:http_custom_auth SET
    name = "httpCustomAuth",
    slug = "http-custom-auth",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_http_custom_auth_name,
        description_i18n: i18n_key:credential_type_http_custom_auth_description
    },
    
    presentation = {
        icon: icon:code,
        color_type: theme_color_type:neutral,
        tooltip_i18n: i18n_key:credential_type_http_custom_auth_tooltip,
        display_order: 40
    },
    
    auth_type = auth_type:custom,
    provider = NONE,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "json",
                display_name: "JSON",
                type: "json",
                is_secret: false,
                required: false,
                description: "Custom JSON configuration"
            },
            {
                name: "headers",
                display_name: "Headers",
                type: "json",
                is_secret: false,
                required: false,
                description: "Custom HTTP headers"
            },
            {
                name: "queryParameters",
                display_name: "Query Parameters",
                type: "json",
                is_secret: false,
                required: false,
                description: "Custom query parameters"
            }
        ],
        metadata: {
            flexible: true,
            supports_headers: true,
            supports_query: true,
            supports_body: true
        }
    },
    
    documentation = {
        url: NONE,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 4. HTTP DIGEST AUTH
-- =====================================================

CREATE credential_type:http_digest_auth SET
    name = "httpDigestAuth",
    slug = "http-digest-auth",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_http_digest_auth_name,
        description_i18n: i18n_key:credential_type_http_digest_auth_description
    },
    
    presentation = {
        icon: icon:fingerprint,
        color_type: theme_color_type:neutral,
        tooltip_i18n: i18n_key:credential_type_http_digest_auth_tooltip,
        display_order: 50
    },
    
    auth_type = auth_type:digest_auth,
    provider = NONE,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "username",
                display_name: "Username",
                type: "string",
                is_secret: false,
                required: true,
                description: "Username for HTTP Digest Authentication"
            },
            {
                name: "password",
                display_name: "Password",
                type: "string",
                is_secret: true,
                required: true,
                description: "Password for HTTP Digest Authentication"
            }
        ],
        metadata: {
            algorithm: "MD5",
            qop: "auth"
        }
    },
    
    documentation = {
        url: url:digest_auth_rfc7616,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 5. HTTP HEADER AUTH
-- =====================================================

CREATE credential_type:http_header_auth SET
    name = "httpHeaderAuth",
    slug = "http-header-auth",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_http_header_auth_name,
        description_i18n: i18n_key:credential_type_http_header_auth_description
    },
    presentation = {
        icon: icon:settings,
        color_type: theme_color_type:neutral,
        tooltip_i18n: i18n_key:credential_type_http_header_auth_tooltip,
        display_order: 30
    },
    
    auth_type = auth_type:header_auth,
    provider = NONE,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "name",
                display_name: "Header Name",
                type: "string",
                is_secret: false,
                required: true,
                description: "Name of the header (e.g., X-API-Key, X-Auth-Token)",
                placeholder: "X-API-Key"
            },
            {
                name: "value",
                display_name: "Header Value",
                type: "string",
                is_secret: true,
                required: true,
                description: "Value of the header"
            }
        ],
        metadata: {
            common_headers: ["X-API-Key", "X-Auth-Token", "X-API-Token", "X-Custom-Auth"]
        }
    },
    
    documentation = {
        url: NONE,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 6. HTTP QUERY AUTH
-- =====================================================

CREATE credential_type:http_query_auth SET
    name = "httpQueryAuth",
    slug = "http-query-auth",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_http_query_auth_name,
        description_i18n: i18n_key:credential_type_http_query_auth_description
    },
    
    presentation = {
        icon: icon:link,
        color_type: theme_color_type:warning,
        tooltip_i18n: i18n_key:credential_type_http_query_auth_tooltip,
        display_order: 60
    },
    
    auth_type = auth_type:query_auth,
    provider = NONE,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "name",
                display_name: "Parameter Name",
                type: "string",
                is_secret: false,
                required: true,
                description: "Name of the query parameter (e.g., api_key, token)",
                placeholder: "api_key"
            },
            {
                name: "value",
                display_name: "Parameter Value",
                type: "string",
                is_secret: true,
                required: true,
                description: "Value of the query parameter"
            }
        ],
        metadata: {
            security_warning: "Credentials visible in URL and logs",
            common_params: ["api_key", "token", "key", "apiKey"]
        }
    },
    
    documentation = {
        url: NONE,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 7. HTTP SSL AUTH
-- =====================================================

CREATE credential_type:http_ssl_auth SET
    name = "httpSslAuth",
    slug = "http-ssl-auth",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_http_ssl_auth_name,
        description_i18n: i18n_key:credential_type_http_ssl_auth_description
    },
    
    presentation = {
        icon: icon:shield_check,
        color_type: theme_color_type:success,
        tooltip_i18n: i18n_key:credential_type_http_ssl_auth_tooltip,
        display_order: 35
    },
    
    auth_type = auth_type:custom,
    provider = NONE,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "ca",
                display_name: "CA Certificate",
                type: "string",
                is_secret: false,
                required: false,
                description: "Certificate Authority certificate (PEM format)"
            },
            {
                name: "cert",
                display_name: "Client Certificate",
                type: "string",
                is_secret: false,
                required: false,
                description: "Client certificate (PEM format)"
            },
            {
                name: "key",
                display_name: "Client Key",
                type: "string",
                is_secret: true,
                required: false,
                description: "Client private key (PEM format)"
            },
            {
                name: "passphrase",
                display_name: "Passphrase",
                type: "string",
                is_secret: true,
                required: false,
                description: "Passphrase for encrypted private key"
            }
        ],
        metadata: {
            supports_mtls: true,
            format: "PEM"
        }
    },
    
    documentation = {
        url: NONE,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 8. OAUTH1 API
-- =====================================================

CREATE credential_type:oauth1_api SET
    name = "oAuth1Api",
    slug = "oauth1-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_oauth1_api_name,
        description_i18n: i18n_key:credential_type_oauth1_api_description
    },
    
    presentation = {
        icon: icon:shield,
        color_type: theme_color_type:warning,
        tooltip_i18n: i18n_key:credential_type_oauth1_api_tooltip,
        display_order: 2
    },
    
    auth_type = auth_type:oauth1,
    provider = NONE,
    
    config = {
        oauth2: NONE,
        oauth1: {
            signature_method: "HMAC-SHA1",
            version: "1.0"
        },
        required_fields: [
            {
                name: "consumer_key",
                display_name: "Consumer Key",
                type: "string",
                is_secret: false,
                required: true,
                description: "OAuth 1.0a Consumer Key"
            },
            {
                name: "consumer_secret",
                display_name: "Consumer Secret",
                type: "string",
                is_secret: true,
                required: true,
                description: "OAuth 1.0a Consumer Secret"
            },
            {
                name: "request_token_url",
                display_name: "Request Token URL",
                type: "string",
                is_secret: false,
                required: true,
                description: "URL to request OAuth token"
            },
            {
                name: "authorization_url",
                display_name: "Authorization URL",
                type: "string",
                is_secret: false,
                required: true,
                description: "URL for user authorization"
            },
            {
                name: "access_token_url",
                display_name: "Access Token URL",
                type: "string",
                is_secret: false,
                required: true,
                description: "URL to exchange for access token"
            }
        ],
        metadata: {
            deprecated: true,
            prefer_oauth2: true
        }
    },
    
    documentation = {
        url: url:oauth1_rfc5849,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 9. OAUTH2 API
-- =====================================================

CREATE credential_type:oauth2_api SET
    name = "oAuth2Api",
    slug = "oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_oauth2_api_name,
        description_i18n: i18n_key:credential_type_oauth2_api_description
    },
    
    presentation = {
        icon: icon:shield_check,
        color_type: theme_color_type:primary,
        tooltip_i18n: i18n_key:credential_type_oauth2_api_tooltip,
        display_order: 1
    },
    
    auth_type = auth_type:oauth2,
    provider = NONE,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "={{$parameter.accessTokenUrl}}",
            authorization_url: "={{$parameter.authUrl}}",
            authentication_method: "body"
        },
        oauth1: NONE,
        required_fields: [
            {
                name: "client_id",
                display_name: "Client ID",
                type: "string",
                is_secret: false,
                required: true,
                description: "OAuth 2.0 Client ID"
            },
            {
                name: "client_secret",
                display_name: "Client Secret",
                type: "string",
                is_secret: true,
                required: true,
                description: "OAuth 2.0 Client Secret"
            },
            {
                name: "auth_url",
                display_name: "Authorization URL",
                type: "string",
                is_secret: false,
                required: true,
                description: "OAuth 2.0 Authorization URL"
            },
            {
                name: "access_token_url",
                display_name: "Access Token URL",
                type: "string",
                is_secret: false,
                required: true,
                description: "OAuth 2.0 Access Token URL"
            },
            {
                name: "scope",
                display_name: "Scope",
                type: "string",
                is_secret: false,
                required: false,
                description: "OAuth 2.0 scopes (space-separated)"
            }
        ],
        metadata: {
            supports_refresh_token: true,
            supports_pkce: true
        }
    },
    
    documentation = {
        url: url:oauth2_rfc6749,
        use_cases_i18n: NONE
    };

-- =====================================================
-- VÉRIFICATION
-- =====================================================

/*
SELECT 
    id,
    name,
    slug,
    identity.display_name_i18n AS display_name,
    presentation.color_daisy AS color,
    presentation.display_order AS order,
    auth_type.name AS auth_type_name,
    provider AS provider_id
FROM credential_type
ORDER BY presentation.display_order ASC;
*/

-- =====================================================
-- RÉSUMÉ BATCH 1
-- =====================================================
--
-- ✅ 9 credentials fondamentaux créés :
--
-- HTTP Génériques (7) :
--  1. http_basic_auth (display_order: 20)
--  2. http_bearer_auth (display_order: 10)
--  3. http_custom_auth (display_order: 40)
--  4. http_digest_auth (display_order: 50)
--  5. http_header_auth (display_order: 30)
--  6. http_query_auth (display_order: 60)
--  7. http_ssl_auth (display_order: 35)
--
-- OAuth Génériques (2) :
--  8. oauth1_api (display_order: 2)
--  9. oauth2_api (display_order: 1) ✅ RECOMMANDÉ
--
-- Tous avec provider = NONE (génériques)
-- Structure complète : identity, presentation, config, documentation
--
-- =============================================================================================

