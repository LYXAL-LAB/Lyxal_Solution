-- =============================================================================================
-- |
-- | Fichier : auth_type_seeds.surql (SEED DATA)
-- | Module : integrations > reference > credentials > auth_type
-- | Description : Données de référence initiales pour auth_type.
-- |
-- | Ce fichier contient les 9 types d'authentification standards :
-- | 1. oauth2 (OAuth 2.0) - ✅ Recommandé
-- | 2. oauth1 (OAuth 1.0a) - ⚠️ Legacy
-- | 3. api_key (API Key) - ✅ Populaire
-- | 4. basic_auth (Basic Authentication) - ⚠️ Faible sécurité
-- | 5. bearer_token (Bearer Token) - ✅ Standard moderne
-- | 6. digest_auth (Digest Authentication) - Peu populaire
-- | 7. header_auth (Custom Header) - Flexible
-- | 8. query_auth (Query Parameter) - ⚠️ Faible sécurité
-- | 9. custom (Custom Authentication) - Flexible
-- |
-- | Structure des données :
-- | • Tous les textes utilisent i18n_key pour le multilingue
-- | • Structure groupée (identity, presentation, quality, config, http, behavior, documentation)
-- | • ETag et timestamps générés automatiquement (DEFAULT)
-- | • REFERENCE ON DELETE REJECT sur tous les records
-- |
-- =============================================================================================

-- =====================================================
-- 1. OAUTH2 (OAuth 2.0) - Recommandé
-- =====================================================

CREATE auth_type:oauth2 SET
    -- Champs à plat
    name = "oauth2",
    slug = "oauth2",
    is_active = true,
    
    -- Identity
    identity = {
        display_name_i18n: i18n_key:auth_type_oauth2_name,
        description_i18n: i18n_key:auth_type_oauth2_description
    },
    
    -- Presentation (UI)
    presentation = {
        icon: icon:shield_check,
        color_type: theme_color_type:primary,
        tooltip: i18n_key:auth_type_oauth2_tooltip,
        display_order: 1
    },
    
    -- Quality (IA)
    quality = {
        security_level: 5,
        popularity_score: 95,
        implementation_complexity: 4
    },
    
    -- Config
    config = {
        schema: {
            fields: ["auth_url", "token_url", "scope", "client_id", "client_secret"],
            required: ["auth_url", "token_url", "client_id", "client_secret"]
        },
        template: {
            grant_type: "authorization_code",
            response_type: "code"
        },
        credential_fields_template: [
            {name: "client_id", display_name: "Client ID", type: "string", is_secret: false, required: true},
            {name: "client_secret", display_name: "Client Secret", type: "string", is_secret: true, required: true},
            {name: "auth_url", display_name: "Authorization URL", type: "url", is_secret: false, required: true},
            {name: "token_url", display_name: "Token URL", type: "url", is_secret: false, required: true},
            {name: "scope", display_name: "Scope", type: "string", is_secret: false, required: false}
        ]
    },
    
    -- HTTP
    http = {
        typical_headers: {
            "Authorization": "Bearer {access_token}",
            "Content-Type": "application/json"
        },
        transmission_method: transmission_method:header
    },
    
    -- Behavior
    behavior = {
        supports_refresh: true,
        requires_user_interaction: true,
        typical_validity_duration: 3600
    },
    
    -- Documentation
    documentation = {
        url: url:oauth2_rfc6749,
        example_providers: [provider:google, provider:facebook, provider:github],
        use_cases_i18n: [
            i18n_key:auth_type_oauth2_usecase_user_auth,
            i18n_key:auth_type_oauth2_usecase_third_party
        ],
        advantages_i18n: [
            i18n_key:auth_type_oauth2_advantage_secure,
            i18n_key:auth_type_oauth2_advantage_standard
        ],
        disadvantages_i18n: [
            i18n_key:auth_type_oauth2_disadvantage_complex,
            i18n_key:auth_type_oauth2_disadvantage_implementation
        ]
    };

-- =====================================================
-- 2. OAUTH1 (OAuth 1.0a) - Legacy
-- =====================================================

CREATE auth_type:oauth1 SET
    name = "oauth1",
    slug = "oauth1",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:auth_type_oauth1_name,
        description_i18n: i18n_key:auth_type_oauth1_description
    },
    
    presentation = {
        icon: icon:shield,
        color_type: theme_color_type:warning,
        tooltip: i18n_key:auth_type_oauth1_tooltip,
        display_order: 7
    },
    
    quality = {
        security_level: 4,
        popularity_score: 30,
        implementation_complexity: 5
    },
    
    config = {
        schema: {
            fields: ["consumer_key", "consumer_secret", "request_token_url", "access_token_url", "authorize_url"],
            required: ["consumer_key", "consumer_secret", "request_token_url", "access_token_url", "authorize_url"]
        },
        template: {
            signature_method: "HMAC-SHA1"
        },
        credential_fields_template: [
            {name: "consumer_key", display_name: "Consumer Key", type: "string", is_secret: false, required: true},
            {name: "consumer_secret", display_name: "Consumer Secret", type: "string", is_secret: true, required: true}
        ]
    },
    
    http = {
        typical_headers: {
            "Authorization": "OAuth oauth_consumer_key=\"{key}\", oauth_signature=\"{signature}\"",
            "Content-Type": "application/x-www-form-urlencoded"
        },
        transmission_method: transmission_method:header
    },
    
    behavior = {
        supports_refresh: false,
        requires_user_interaction: true,
        typical_validity_duration: NONE
    },
    
    documentation = {
        url: url:oauth1_rfc5849,
        example_providers: [provider:twitter, provider:trello],
        use_cases_i18n: [
            i18n_key:auth_type_oauth1_usecase_legacy,
            i18n_key:auth_type_oauth1_usecase_signature
        ],
        advantages_i18n: [
            i18n_key:auth_type_oauth1_advantage_secure
        ],
        disadvantages_i18n: [
            i18n_key:auth_type_oauth1_disadvantage_complex,
            i18n_key:auth_type_oauth1_disadvantage_deprecated
        ]
    };

-- =====================================================
-- 3. API_KEY (API Key) - Populaire
-- =====================================================

CREATE auth_type:api_key SET
    name = "api_key",
    slug = "api-key",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:auth_type_api_key_name,
        description_i18n: i18n_key:auth_type_api_key_description
    },
    
    presentation = {
        icon: icon:key,
        color_type: theme_color_type:success,
        tooltip: i18n_key:auth_type_api_key_tooltip,
        display_order: 2
    },
    
    quality = {
        security_level: 3,
        popularity_score: 85,
        implementation_complexity: 1
    },
    
    config = {
        schema: {
            fields: ["api_key"],
            required: ["api_key"]
        },
        template: {
            header_name: "X-API-Key"
        },
        credential_fields_template: [
            {name: "api_key", display_name: "API Key", type: "string", is_secret: true, required: true}
        ]
    },
    
    http = {
        typical_headers: {
            "X-API-Key": "{api_key}"
        },
        transmission_method: transmission_method:header
    },
    
    behavior = {
        supports_refresh: false,
        requires_user_interaction: false,
        typical_validity_duration: NONE
    },
    
    documentation = {
        url: url:api_key_best_practices,
        example_providers: [provider:openweather, provider:google_maps, provider:stripe],
        use_cases_i18n: [
            i18n_key:auth_type_api_key_usecase_simple,
            i18n_key:auth_type_api_key_usecase_automation
        ],
        advantages_i18n: [
            i18n_key:auth_type_api_key_advantage_simple,
            i18n_key:auth_type_api_key_advantage_popular
        ],
        disadvantages_i18n: [
            i18n_key:auth_type_api_key_disadvantage_security,
            i18n_key:auth_type_api_key_disadvantage_rotation
        ]
    };

-- =====================================================
-- 4. BASIC_AUTH (Basic Authentication) - Faible sécurité
-- =====================================================

CREATE auth_type:basic_auth SET
    name = "basic_auth",
    slug = "basic-auth",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:auth_type_basic_auth_name,
        description_i18n: i18n_key:auth_type_basic_auth_description
    },
    
    presentation = {
        icon: icon:lock_open,
        color_type: theme_color_type:error,
        tooltip: i18n_key:auth_type_basic_auth_tooltip,
        display_order: 6
    },
    
    quality = {
        security_level: 2,
        popularity_score: 60,
        implementation_complexity: 1
    },
    
    config = {
        schema: {
            fields: ["username", "password"],
            required: ["username", "password"]
        },
        template: {},
        credential_fields_template: [
            {name: "username", display_name: "Username", type: "string", is_secret: false, required: true},
            {name: "password", display_name: "Password", type: "string", is_secret: true, required: true}
        ]
    },
    
    http = {
        typical_headers: {
            "Authorization": "Basic {base64(username:password)}"
        },
        transmission_method: transmission_method:header
    },
    
    behavior = {
        supports_refresh: false,
        requires_user_interaction: false,
        typical_validity_duration: NONE
    },
    
    documentation = {
        url: url:basic_auth_rfc7617,
        example_providers: [provider:jenkins, provider:nexus],
        use_cases_i18n: [
            i18n_key:auth_type_basic_auth_usecase_internal,
            i18n_key:auth_type_basic_auth_usecase_dev
        ],
        advantages_i18n: [
            i18n_key:auth_type_basic_auth_advantage_simple
        ],
        disadvantages_i18n: [
            i18n_key:auth_type_basic_auth_disadvantage_security,
            i18n_key:auth_type_basic_auth_disadvantage_https
        ]
    };

-- =====================================================
-- 5. BEARER_TOKEN (Bearer Token) - Standard moderne
-- =====================================================

CREATE auth_type:bearer_token SET
    name = "bearer_token",
    slug = "bearer-token",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:auth_type_bearer_token_name,
        description_i18n: i18n_key:auth_type_bearer_token_description
    },
    
    presentation = {
        icon: icon:badge_check,
        color_type: theme_color_type:info,
        tooltip: i18n_key:auth_type_bearer_token_tooltip,
        display_order: 3
    },
    
    quality = {
        security_level: 3,
        popularity_score: 70,
        implementation_complexity: 2
    },
    
    config = {
        schema: {
            fields: ["token"],
            required: ["token"]
        },
        template: {
            token_type: "Bearer"
        },
        credential_fields_template: [
            {name: "token", display_name: "Bearer Token", type: "string", is_secret: true, required: true}
        ]
    },
    
    http = {
        typical_headers: {
            "Authorization": "Bearer {token}"
        },
        transmission_method: transmission_method:header
    },
    
    behavior = {
        supports_refresh: false,
        requires_user_interaction: false,
        typical_validity_duration: 3600
    },
    
    documentation = {
        url: url:bearer_token_rfc6750,
        example_providers: [provider:github, provider:gitlab, provider:digitalocean],
        use_cases_i18n: [
            i18n_key:auth_type_bearer_token_usecase_jwt,
            i18n_key:auth_type_bearer_token_usecase_session
        ],
        advantages_i18n: [
            i18n_key:auth_type_bearer_token_advantage_simple,
            i18n_key:auth_type_bearer_token_advantage_stateless
        ],
        disadvantages_i18n: [
            i18n_key:auth_type_bearer_token_disadvantage_expiration,
            i18n_key:auth_type_bearer_token_disadvantage_theft
        ]
    };

-- =====================================================
-- 6. DIGEST_AUTH (Digest Authentication) - Peu populaire
-- =====================================================

CREATE auth_type:digest_auth SET
    name = "digest_auth",
    slug = "digest-auth",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:auth_type_digest_auth_name,
        description_i18n: i18n_key:auth_type_digest_auth_description
    },
    
    presentation = {
        icon: icon:fingerprint,
        color_type: theme_color_type:neutral,
        tooltip: i18n_key:auth_type_digest_auth_tooltip,
        display_order: 8
    },
    
    quality = {
        security_level: 3,
        popularity_score: 20,
        implementation_complexity: 3
    },
    
    config = {
        schema: {
            fields: ["username", "password", "realm", "algorithm"],
            required: ["username", "password"]
        },
        template: {
            algorithm: "MD5"
        },
        credential_fields_template: [
            {name: "username", display_name: "Username", type: "string", is_secret: false, required: true},
            {name: "password", display_name: "Password", type: "string", is_secret: true, required: true},
            {name: "realm", display_name: "Realm", type: "string", is_secret: false, required: false}
        ]
    },
    
    http = {
        typical_headers: {
            "Authorization": "Digest username=\"{username}\", realm=\"{realm}\", nonce=\"{nonce}\", uri=\"{uri}\", response=\"{response}\""
        },
        transmission_method: transmission_method:header
    },
    
    behavior = {
        supports_refresh: false,
        requires_user_interaction: false,
        typical_validity_duration: NONE
    },
    
    documentation = {
        url: url:digest_auth_rfc7616,
        example_providers: [],
        use_cases_i18n: [
            i18n_key:auth_type_digest_auth_usecase_legacy,
            i18n_key:auth_type_digest_auth_usecase_http
        ],
        advantages_i18n: [
            i18n_key:auth_type_digest_auth_advantage_secure
        ],
        disadvantages_i18n: [
            i18n_key:auth_type_digest_auth_disadvantage_unpopular,
            i18n_key:auth_type_digest_auth_disadvantage_complex
        ]
    };

-- =====================================================
-- 7. HEADER_AUTH (Custom Header Authentication) - Flexible
-- =====================================================

CREATE auth_type:header_auth SET
    name = "header_auth",
    slug = "header-auth",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:auth_type_header_auth_name,
        description_i18n: i18n_key:auth_type_header_auth_description
    },
    
    presentation = {
        icon: icon:settings,
        color: "#9AA0A6",
        color_daisy: "accent",
        tooltip: i18n_key:auth_type_header_auth_tooltip,
        display_order: 5
    },
    
    quality = {
        security_level: 3,
        popularity_score: 65,
        implementation_complexity: 2
    },
    
    config = {
        schema: {
            fields: ["header_name", "header_value"],
            required: ["header_name", "header_value"]
        },
        template: {
            header_name: "X-Auth-Token"
        },
        credential_fields_template: [
            {name: "header_name", display_name: "Header Name", type: "string", is_secret: false, required: true},
            {name: "header_value", display_name: "Header Value", type: "string", is_secret: true, required: true}
        ]
    },
    
    http = {
        typical_headers: {
            "{header_name}": "{header_value}"
        },
        transmission_method: transmission_method:header
    },
    
    behavior = {
        supports_refresh: false,
        requires_user_interaction: false,
        typical_validity_duration: NONE
    },
    
    documentation = {
        url: NONE,
        example_providers: [provider:cloudflare, provider:akamai],
        use_cases_i18n: [
            i18n_key:auth_type_header_auth_usecase_proprietary,
            i18n_key:auth_type_header_auth_usecase_custom
        ],
        advantages_i18n: [
            i18n_key:auth_type_header_auth_advantage_flexible
        ],
        disadvantages_i18n: [
            i18n_key:auth_type_header_auth_disadvantage_nonstandard,
            i18n_key:auth_type_header_auth_disadvantage_documentation
        ]
    };

-- =====================================================
-- 8. QUERY_AUTH (Query Parameter Authentication) - Faible sécurité
-- =====================================================

CREATE auth_type:query_auth SET
    name = "query_auth",
    slug = "query-auth",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:auth_type_query_auth_name,
        description_i18n: i18n_key:auth_type_query_auth_description
    },
    
    presentation = {
        icon: icon:link,
        color_type: theme_color_type:warning,
        tooltip: i18n_key:auth_type_query_auth_tooltip,
        display_order: 9
    },
    
    quality = {
        security_level: 2,
        popularity_score: 50,
        implementation_complexity: 1
    },
    
    config = {
        schema: {
            fields: ["parameter_name", "parameter_value"],
            required: ["parameter_name", "parameter_value"]
        },
        template: {
            parameter_name: "api_key"
        },
        credential_fields_template: [
            {name: "parameter_name", display_name: "Parameter Name", type: "string", is_secret: false, required: true},
            {name: "parameter_value", display_name: "Parameter Value", type: "string", is_secret: true, required: true}
        ]
    },
    
    http = {
        typical_headers: {},
        transmission_method: transmission_method:query
    },
    
    behavior = {
        supports_refresh: false,
        requires_user_interaction: false,
        typical_validity_duration: NONE
    },
    
    documentation = {
        url: NONE,
        example_providers: [provider:youtube, provider:flickr],
        use_cases_i18n: [
            i18n_key:auth_type_query_auth_usecase_public,
            i18n_key:auth_type_query_auth_usecase_embed
        ],
        advantages_i18n: [
            i18n_key:auth_type_query_auth_advantage_simple
        ],
        disadvantages_i18n: [
            i18n_key:auth_type_query_auth_disadvantage_security,
            i18n_key:auth_type_query_auth_disadvantage_logs
        ]
    };

-- =====================================================
-- 9. CUSTOM (Custom Authentication) - Flexible
-- =====================================================

CREATE auth_type:custom SET
    name = "custom",
    slug = "custom",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:auth_type_custom_name,
        description_i18n: i18n_key:auth_type_custom_description
    },
    
    presentation = {
        icon: icon:code,
        color_type: theme_color_type:neutral,
        tooltip: i18n_key:auth_type_custom_tooltip,
        display_order: 10
    },
    
    quality = {
        security_level: 3,
        popularity_score: 40,
        implementation_complexity: 5
    },
    
    config = {
        schema: {
            fields: [],
            required: []
        },
        template: {},
        credential_fields_template: []
    },
    
    http = {
        typical_headers: {},
        transmission_method: transmission_method:custom
    },
    
    behavior = {
        supports_refresh: false,
        requires_user_interaction: false,
        typical_validity_duration: NONE
    },
    
    documentation = {
        url: NONE,
        example_providers: [],
        use_cases_i18n: [
            i18n_key:auth_type_custom_usecase_proprietary,
            i18n_key:auth_type_custom_usecase_specialized
        ],
        advantages_i18n: [
            i18n_key:auth_type_custom_advantage_flexible
        ],
        disadvantages_i18n: [
            i18n_key:auth_type_custom_disadvantage_implementation,
            i18n_key:auth_type_custom_disadvantage_maintenance
        ]
    };

-- =====================================================
-- VÉRIFICATION DES DONNÉES INSÉRÉES
-- =====================================================

/*
SELECT 
    id,
    name,
    identity.display_name_i18n AS display_name,
    presentation.color_daisy AS color,
    presentation.display_order AS order,
    quality.security_level AS security,
    quality.popularity_score AS popularity,
    created_at
FROM auth_type
ORDER BY presentation.display_order ASC;
*/

-- =====================================================
-- NOTES D'UTILISATION
-- =====================================================
--
-- Ordre d'affichage recommandé (display_order) :
--  1. oauth2 (OAuth 2.0) - Le plus recommandé
--  2. api-key (API Key) - Très populaire et simple
--  3. bearer-token (Bearer Token) - Standard moderne
--  4. api_key (API Key variant)
--  5. header-auth (Custom Header) - Flexible
--  6. basic-auth (Basic Auth) - Simple mais faible sécurité
--  7. oauth1 (OAuth 1.0a) - Legacy
--  8. digest-auth (Digest Auth) - Peu populaire
--  9. query-auth (Query Parameter) - Faible sécurité
-- 10. custom (Custom) - Pour cas spéciaux
--
-- Références externes à créer :
-- • icon:shield_check, icon:shield, icon:key, icon:lock_open, icon:badge_check,
--   icon:fingerprint, icon:settings, icon:link, icon:code
-- • provider:google, provider:facebook, provider:github, provider:twitter,
--   provider:trello, provider:openweather, provider:google_maps, provider:stripe,
--   provider:jenkins, provider:nexus, provider:gitlab, provider:digitalocean,
--   provider:cloudflare, provider:akamai, provider:youtube, provider:flickr
-- • url:oauth2_rfc6749, url:oauth1_rfc5849, url:api_key_best_practices,
--   url:basic_auth_rfc7617, url:bearer_token_rfc6750, url:digest_auth_rfc7616
-- • transmission_method:header, transmission_method:query, transmission_method:custom
-- • i18n_key:auth_type_*_* (75 clés créées dans auth_type_i18n_keys.surql)
--
-- =============================================================================================

