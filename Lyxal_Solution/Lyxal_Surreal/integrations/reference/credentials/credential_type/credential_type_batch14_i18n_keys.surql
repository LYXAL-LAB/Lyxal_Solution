-- =============================================================================================
-- |
-- | Fichier : credential_type_batch14_i18n_keys.surql (SEED DATA)
-- | Module : integrations > reference > credentials > credential_type
-- | Description : Clés i18n pour le Batch 14 des credential types.
-- |
-- | Batch 14 : No-Code, Analytics & Security Tools (11 credentials)
-- | Providers : Baserow, NocoDB, Grafana, Metabase, PostHog, Coda, Gong, Okta, Auth0
-- |
-- | Total : 33 clés i18n (11 credentials × 3 clés chacun)
-- |
-- =============================================================================================

-- =====================================================
-- BASEROW API (3 clés)
-- =====================================================

CREATE i18n_key:credential_type_baserow_api_name SET
    description = "Nom affiché du credential type Baserow API";

CREATE i18n_key:credential_type_baserow_api_description SET
    description = "Description complète de Baserow API pour credentials";

CREATE i18n_key:credential_type_baserow_api_tooltip SET
    description = "Tooltip d'aide pour Baserow API credentials";

-- =====================================================
-- NOCODB (3 clés)
-- =====================================================

CREATE i18n_key:credential_type_nocodb_name SET
    description = "Nom affiché du credential type NocoDB";

CREATE i18n_key:credential_type_nocodb_description SET
    description = "Description complète de NocoDB pour credentials";

CREATE i18n_key:credential_type_nocodb_tooltip SET
    description = "Tooltip d'aide pour NocoDB credentials";

-- =====================================================
-- NOCODB API TOKEN (3 clés)
-- =====================================================

CREATE i18n_key:credential_type_nocodb_api_token_name SET
    description = "Nom affiché du credential type NocoDB API Token";

CREATE i18n_key:credential_type_nocodb_api_token_description SET
    description = "Description complète de NocoDB API Token pour credentials";

CREATE i18n_key:credential_type_nocodb_api_token_tooltip SET
    description = "Tooltip d'aide pour NocoDB API Token credentials";

-- =====================================================
-- GRAFANA API (3 clés)
-- =====================================================

CREATE i18n_key:credential_type_grafana_api_name SET
    description = "Nom affiché du credential type Grafana API";

CREATE i18n_key:credential_type_grafana_api_description SET
    description = "Description complète de Grafana API pour credentials";

CREATE i18n_key:credential_type_grafana_api_tooltip SET
    description = "Tooltip d'aide pour Grafana API credentials";

-- =====================================================
-- METABASE API (3 clés)
-- =====================================================

CREATE i18n_key:credential_type_metabase_api_name SET
    description = "Nom affiché du credential type Metabase API";

CREATE i18n_key:credential_type_metabase_api_description SET
    description = "Description complète de Metabase API pour credentials";

CREATE i18n_key:credential_type_metabase_api_tooltip SET
    description = "Tooltip d'aide pour Metabase API credentials";

-- =====================================================
-- POSTHOG API (3 clés)
-- =====================================================

CREATE i18n_key:credential_type_posthog_api_name SET
    description = "Nom affiché du credential type PostHog API";

CREATE i18n_key:credential_type_posthog_api_description SET
    description = "Description complète de PostHog API pour credentials";

CREATE i18n_key:credential_type_posthog_api_tooltip SET
    description = "Tooltip d'aide pour PostHog API credentials";

-- =====================================================
-- CODA API (3 clés)
-- =====================================================

CREATE i18n_key:credential_type_coda_api_name SET
    description = "Nom affiché du credential type Coda API";

CREATE i18n_key:credential_type_coda_api_description SET
    description = "Description complète de Coda API pour credentials";

CREATE i18n_key:credential_type_coda_api_tooltip SET
    description = "Tooltip d'aide pour Coda API credentials";

-- =====================================================
-- GONG API (3 clés)
-- =====================================================

CREATE i18n_key:credential_type_gong_api_name SET
    description = "Nom affiché du credential type Gong API";

CREATE i18n_key:credential_type_gong_api_description SET
    description = "Description complète de Gong API pour credentials";

CREATE i18n_key:credential_type_gong_api_tooltip SET
    description = "Tooltip d'aide pour Gong API credentials";

-- =====================================================
-- GONG OAUTH2 API (3 clés)
-- =====================================================

CREATE i18n_key:credential_type_gong_oauth2_api_name SET
    description = "Nom affiché du credential type Gong OAuth2 API";

CREATE i18n_key:credential_type_gong_oauth2_api_description SET
    description = "Description complète de Gong OAuth2 API pour credentials";

CREATE i18n_key:credential_type_gong_oauth2_api_tooltip SET
    description = "Tooltip d'aide pour Gong OAuth2 API credentials";

-- =====================================================
-- OKTA API (3 clés)
-- =====================================================

CREATE i18n_key:credential_type_okta_api_name SET
    description = "Nom affiché du credential type Okta API";

CREATE i18n_key:credential_type_okta_api_description SET
    description = "Description complète de Okta API pour credentials";

CREATE i18n_key:credential_type_okta_api_tooltip SET
    description = "Tooltip d'aide pour Okta API credentials";

-- =====================================================
-- AUTH0 MANAGEMENT API (3 clés)
-- =====================================================

CREATE i18n_key:credential_type_auth0_management_api_name SET
    description = "Nom affiché du credential type Auth0 Management API";

CREATE i18n_key:credential_type_auth0_management_api_description SET
    description = "Description complète de Auth0 Management API pour credentials";

CREATE i18n_key:credential_type_auth0_management_api_tooltip SET
    description = "Tooltip d'aide pour Auth0 Management API credentials";

-- =====================================================
-- RÉSUMÉ BATCH 14 - CLÉS I18N
-- =====================================================
--
-- ✅ 33 clés i18n créées pour 11 credential types (3 clés × 11 credentials)
--
-- No-Code Database Platforms (9 clés) :
--  1. baserow_api (name, description, tooltip)
--  2. nocodb (name, description, tooltip)
--  3. nocodb_api_token (name, description, tooltip)
--
-- Analytics & BI Platforms (9 clés) :
--  4. grafana_api (name, description, tooltip)
--  5. metabase_api (name, description, tooltip)
--  6. posthog_api (name, description, tooltip)
--
-- Productivity & Collaboration (3 clés) :
--  7. coda_api (name, description, tooltip)
--
-- Revenue Intelligence (6 clés) :
--  8. gong_api (name, description, tooltip)
--  9. gong_oauth2_api (name, description, tooltip)
--
-- Identity & Security (6 clés) :
-- 10. okta_api (name, description, tooltip)
-- 11. auth0_management_api (name, description, tooltip)
--
-- =============================================================================================

