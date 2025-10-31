-- =============================================================================================
-- |
-- | Fichier : transmission_method.surql (SEED DATA)
-- | Module : integrations > reference > credentials
-- | Description : Données de référence initiales pour transmission_method.
-- |
-- | Ce fichier contient les 4 méthodes de transmission HTTP standards :
-- | • header (RECOMMANDÉ) - Authorization header, Bearer tokens
-- | • body - Request body, formulaires, payloads JSON
-- | • query - URL query parameters (ATTENTION : sécurité faible)
-- | • custom - Méthodes propriétaires non-standard
-- |
-- | Structure des données :
-- | • Tous les textes utilisent i18n_key pour le multilingue
-- | • Structure groupée (identity, presentation, quality, config)
-- | • ETag et timestamps générés automatiquement par les events
-- |
-- =============================================================================================

-- =====================================================
-- 1. HEADER (RECOMMANDÉ - Sécurité: 4/5)
-- =====================================================

CREATE transmission_method:header SET
    -- Champs à plat
    name = "header",
    slug = "header",
    is_active = true,
    
    -- Identity
    identity = {
        display_name_i18n: i18n_key:transmission_method_header_name,
        description_i18n: i18n_key:transmission_method_header_description
    },
    
    -- Presentation (UI)
    presentation = {
        icon: icon:shield_check,
        color_daisy: "success",
        display_order: 1,
        tooltip_i18n: i18n_key:transmission_method_header_tooltip
    },
    
    -- Quality (IA)
    quality = {
        security_level: 4,
        security_concerns_i18n: [
            i18n_key:transmission_method_header_concern_proxy,
            i18n_key:transmission_method_header_concern_logs,
            i18n_key:transmission_method_header_concern_cache
        ],
        best_use_cases_i18n: [
            i18n_key:transmission_method_header_usecase_bearer,
            i18n_key:transmission_method_header_usecase_apikey,
            i18n_key:transmission_method_header_usecase_oauth,
            i18n_key:transmission_method_header_usecase_sensitive
        ],
        avoid_use_cases_i18n: [
            i18n_key:transmission_method_header_avoid_large_payload
        ]
    },
    
    -- Config
    config = {
        technical_details: {
            location: "HTTP Header",
            format: "Key: Value",
            example: "Authorization: Bearer eyJhbGciOiJIUzI1NiIs...",
            standard: "RFC 7235 (HTTP Authentication)",
            common_headers: ["Authorization", "X-API-Key", "X-Auth-Token"]
        },
        is_recommended: true,
        requires_https: true
    };

-- =====================================================
-- 2. BODY (Sécurité: 4/5)
-- =====================================================

CREATE transmission_method:body SET
    -- Champs à plat
    name = "body",
    slug = "body",
    is_active = true,
    
    -- Identity
    identity = {
        display_name_i18n: i18n_key:transmission_method_body_name,
        description_i18n: i18n_key:transmission_method_body_description
    },
    
    -- Presentation (UI)
    presentation = {
        icon: icon:file_json,
        color_daisy: "info",
        display_order: 2,
        tooltip_i18n: i18n_key:transmission_method_body_tooltip
    },
    
    -- Quality (IA)
    quality = {
        security_level: 4,
        security_concerns_i18n: [
            i18n_key:transmission_method_body_concern_parsing,
            i18n_key:transmission_method_body_concern_content_type
        ],
        best_use_cases_i18n: [
            i18n_key:transmission_method_body_usecase_complex,
            i18n_key:transmission_method_body_usecase_multipart,
            i18n_key:transmission_method_body_usecase_certificate,
            i18n_key:transmission_method_body_usecase_login
        ],
        avoid_use_cases_i18n: [
            i18n_key:transmission_method_body_avoid_simple_key,
            i18n_key:transmission_method_body_avoid_get_request
        ]
    },
    
    -- Config
    config = {
        technical_details: {
            location: "HTTP Request Body",
            format: "JSON, XML, Form-data, Multipart",
            example: '{"username": "user", "password": "pass", "grant_type": "password"}',
            standard: "RFC 7231 (HTTP Semantics)",
            content_types: ["application/json", "application/x-www-form-urlencoded", "multipart/form-data"]
        },
        is_recommended: false,
        requires_https: true
    };

-- =====================================================
-- 3. QUERY (ATTENTION - Sécurité: 2/5)
-- =====================================================

CREATE transmission_method:query SET
    -- Champs à plat
    name = "query",
    slug = "query",
    is_active = true,
    
    -- Identity
    identity = {
        display_name_i18n: i18n_key:transmission_method_query_name,
        description_i18n: i18n_key:transmission_method_query_description
    },
    
    -- Presentation (UI)
    presentation = {
        icon: icon:link,
        color_daisy: "warning",
        display_order: 3,
        tooltip_i18n: i18n_key:transmission_method_query_warning
    },
    
    -- Quality (IA)
    quality = {
        security_level: 2,
        security_concerns_i18n: [
            i18n_key:transmission_method_query_concern_url_visible,
            i18n_key:transmission_method_query_concern_browser_history,
            i18n_key:transmission_method_query_concern_server_logs,
            i18n_key:transmission_method_query_concern_copy_paste,
            i18n_key:transmission_method_query_concern_referrer,
            i18n_key:transmission_method_query_concern_cdn_cache
        ],
        best_use_cases_i18n: [
            i18n_key:transmission_method_query_usecase_public_key,
            i18n_key:transmission_method_query_usecase_temporary_token,
            i18n_key:transmission_method_query_usecase_webhook_signature
        ],
        avoid_use_cases_i18n: [
            i18n_key:transmission_method_query_avoid_password,
            i18n_key:transmission_method_query_avoid_secret,
            i18n_key:transmission_method_query_avoid_private_key,
            i18n_key:transmission_method_query_avoid_longlived
        ]
    },
    
    -- Config
    config = {
        technical_details: {
            location: "URL Query String",
            format: "?param=value&param2=value2",
            example: "https://api.example.com/data?api_key=abc123&timestamp=1234567890",
            standard: "RFC 3986 (URI Syntax)",
            encoding: "URL-encoded (percent-encoding)"
        },
        is_recommended: false,
        requires_https: true
    };

-- =====================================================
-- 4. CUSTOM (Sécurité: 3/5)
-- =====================================================

CREATE transmission_method:custom SET
    -- Champs à plat
    name = "custom",
    slug = "custom",
    is_active = true,
    
    -- Identity
    identity = {
        display_name_i18n: i18n_key:transmission_method_custom_name,
        description_i18n: i18n_key:transmission_method_custom_description
    },
    
    -- Presentation (UI)
    presentation = {
        icon: icon:code,
        color_daisy: "neutral",
        display_order: 4,
        tooltip_i18n: i18n_key:transmission_method_custom_tooltip
    },
    
    -- Quality (IA)
    quality = {
        security_level: 3,
        security_concerns_i18n: [
            i18n_key:transmission_method_custom_concern_nonstandard,
            i18n_key:transmission_method_custom_concern_validation,
            i18n_key:transmission_method_custom_concern_tooling
        ],
        best_use_cases_i18n: [
            i18n_key:transmission_method_custom_usecase_proprietary,
            i18n_key:transmission_method_custom_usecase_legacy,
            i18n_key:transmission_method_custom_usecase_specialized
        ],
        avoid_use_cases_i18n: [
            i18n_key:transmission_method_custom_avoid_rest,
            i18n_key:transmission_method_custom_avoid_public
        ]
    },
    
    -- Config
    config = {
        technical_details: {
            location: "Custom (varies)",
            format: "Implementation specific",
            example: "Proprietary signature in custom header + encrypted body",
            standard: "None (non-standard)",
            notes: "Requires custom implementation and validation logic"
        },
        is_recommended: false,
        requires_https: false
    };

-- =====================================================
-- VÉRIFICATION DES DONNÉES INSÉRÉES
-- =====================================================

-- Afficher toutes les méthodes créées
/*
SELECT 
    id,
    name,
    identity.display_name_i18n AS display_name,
    presentation.color_daisy AS color,
    presentation.display_order AS order,
    quality.security_level AS security,
    config.is_recommended AS recommended,
    etag,
    created_at
FROM transmission_method
ORDER BY presentation.display_order ASC;
*/

-- =====================================================
-- NOTES D'UTILISATION
-- =====================================================
--
-- Clés i18n à créer (liste complète) :
--
-- HEADER:
-- • transmission_method_header_name
-- • transmission_method_header_description
-- • transmission_method_header_tooltip
-- • transmission_method_header_concern_proxy
-- • transmission_method_header_concern_logs
-- • transmission_method_header_concern_cache
-- • transmission_method_header_usecase_bearer
-- • transmission_method_header_usecase_apikey
-- • transmission_method_header_usecase_oauth
-- • transmission_method_header_usecase_sensitive
-- • transmission_method_header_avoid_large_payload
--
-- BODY:
-- • transmission_method_body_name
-- • transmission_method_body_description
-- • transmission_method_body_tooltip
-- • transmission_method_body_concern_parsing
-- • transmission_method_body_concern_content_type
-- • transmission_method_body_usecase_complex
-- • transmission_method_body_usecase_multipart
-- • transmission_method_body_usecase_certificate
-- • transmission_method_body_usecase_login
-- • transmission_method_body_avoid_simple_key
-- • transmission_method_body_avoid_get_request
--
-- QUERY:
-- • transmission_method_query_name
-- • transmission_method_query_description
-- • transmission_method_query_warning
-- • transmission_method_query_concern_url_visible
-- • transmission_method_query_concern_browser_history
-- • transmission_method_query_concern_server_logs
-- • transmission_method_query_concern_copy_paste
-- • transmission_method_query_concern_referrer
-- • transmission_method_query_concern_cdn_cache
-- • transmission_method_query_usecase_public_key
-- • transmission_method_query_usecase_temporary_token
-- • transmission_method_query_usecase_webhook_signature
-- • transmission_method_query_avoid_password
-- • transmission_method_query_avoid_secret
-- • transmission_method_query_avoid_private_key
-- • transmission_method_query_avoid_longlived
--
-- CUSTOM:
-- • transmission_method_custom_name
-- • transmission_method_custom_description
-- • transmission_method_custom_tooltip
-- • transmission_method_custom_concern_nonstandard
-- • transmission_method_custom_concern_validation
-- • transmission_method_custom_concern_tooling
-- • transmission_method_custom_usecase_proprietary
-- • transmission_method_custom_usecase_legacy
-- • transmission_method_custom_usecase_specialized
-- • transmission_method_custom_avoid_rest
-- • transmission_method_custom_avoid_public
--
-- Icônes à créer/vérifier :
-- • icon:shield_check (pour header - sécurité)
-- • icon:file_json (pour body - données JSON)
-- • icon:link (pour query - URL)
-- • icon:code (pour custom - code personnalisé)
--
-- =============================================================================================

