-- =============================================================================================
-- |
-- | Fichier : credential_type_batch15_i18n_keys.surql (SEED DATA)
-- | Module : integrations > reference > credentials > credential_type
-- | Description : Clés i18n pour le Batch 15 des credential types.
-- |
-- | Batch 15 : CMS, ERP & Database Management (11 credentials)
-- | Providers : Contentful, Strapi, Storyblok, Odoo, ERPNext, Grist, SeaTable, QuickBase, Stackby
-- |
-- | Total : 33 clés i18n (11 credentials × 3 clés chacun)
-- |
-- =============================================================================================

-- =====================================================
-- CONTENTFUL API (3 clés)
-- =====================================================

CREATE i18n_key:credential_type_contentful_api_name SET
    description = "Nom affiché du credential type Contentful API";

CREATE i18n_key:credential_type_contentful_api_description SET
    description = "Description complète de Contentful API pour credentials";

CREATE i18n_key:credential_type_contentful_api_tooltip SET
    description = "Tooltip d'aide pour Contentful API credentials";

-- =====================================================
-- STRAPI API (3 clés)
-- =====================================================

CREATE i18n_key:credential_type_strapi_api_name SET
    description = "Nom affiché du credential type Strapi API";

CREATE i18n_key:credential_type_strapi_api_description SET
    description = "Description complète de Strapi API pour credentials";

CREATE i18n_key:credential_type_strapi_api_tooltip SET
    description = "Tooltip d'aide pour Strapi API credentials";

-- =====================================================
-- STRAPI TOKEN API (3 clés)
-- =====================================================

CREATE i18n_key:credential_type_strapi_token_api_name SET
    description = "Nom affiché du credential type Strapi Token API";

CREATE i18n_key:credential_type_strapi_token_api_description SET
    description = "Description complète de Strapi Token API pour credentials";

CREATE i18n_key:credential_type_strapi_token_api_tooltip SET
    description = "Tooltip d'aide pour Strapi Token API credentials";

-- =====================================================
-- STORYBLOK CONTENT API (3 clés)
-- =====================================================

CREATE i18n_key:credential_type_storyblok_content_api_name SET
    description = "Nom affiché du credential type Storyblok Content API";

CREATE i18n_key:credential_type_storyblok_content_api_description SET
    description = "Description complète de Storyblok Content API pour credentials";

CREATE i18n_key:credential_type_storyblok_content_api_tooltip SET
    description = "Tooltip d'aide pour Storyblok Content API credentials";

-- =====================================================
-- STORYBLOK MANAGEMENT API (3 clés)
-- =====================================================

CREATE i18n_key:credential_type_storyblok_management_api_name SET
    description = "Nom affiché du credential type Storyblok Management API";

CREATE i18n_key:credential_type_storyblok_management_api_description SET
    description = "Description complète de Storyblok Management API pour credentials";

CREATE i18n_key:credential_type_storyblok_management_api_tooltip SET
    description = "Tooltip d'aide pour Storyblok Management API credentials";

-- =====================================================
-- ODOO API (3 clés)
-- =====================================================

CREATE i18n_key:credential_type_odoo_api_name SET
    description = "Nom affiché du credential type Odoo API";

CREATE i18n_key:credential_type_odoo_api_description SET
    description = "Description complète de Odoo API pour credentials";

CREATE i18n_key:credential_type_odoo_api_tooltip SET
    description = "Tooltip d'aide pour Odoo API credentials";

-- =====================================================
-- ERPNEXT API (3 clés)
-- =====================================================

CREATE i18n_key:credential_type_erpnext_api_name SET
    description = "Nom affiché du credential type ERPNext API";

CREATE i18n_key:credential_type_erpnext_api_description SET
    description = "Description complète de ERPNext API pour credentials";

CREATE i18n_key:credential_type_erpnext_api_tooltip SET
    description = "Tooltip d'aide pour ERPNext API credentials";

-- =====================================================
-- GRIST API (3 clés)
-- =====================================================

CREATE i18n_key:credential_type_grist_api_name SET
    description = "Nom affiché du credential type Grist API";

CREATE i18n_key:credential_type_grist_api_description SET
    description = "Description complète de Grist API pour credentials";

CREATE i18n_key:credential_type_grist_api_tooltip SET
    description = "Tooltip d'aide pour Grist API credentials";

-- =====================================================
-- SEATABLE API (3 clés)
-- =====================================================

CREATE i18n_key:credential_type_seatable_api_name SET
    description = "Nom affiché du credential type SeaTable API";

CREATE i18n_key:credential_type_seatable_api_description SET
    description = "Description complète de SeaTable API pour credentials";

CREATE i18n_key:credential_type_seatable_api_tooltip SET
    description = "Tooltip d'aide pour SeaTable API credentials";

-- =====================================================
-- QUICKBASE API (3 clés)
-- =====================================================

CREATE i18n_key:credential_type_quickbase_api_name SET
    description = "Nom affiché du credential type QuickBase API";

CREATE i18n_key:credential_type_quickbase_api_description SET
    description = "Description complète de QuickBase API pour credentials";

CREATE i18n_key:credential_type_quickbase_api_tooltip SET
    description = "Tooltip d'aide pour QuickBase API credentials";

-- =====================================================
-- STACKBY API (3 clés)
-- =====================================================

CREATE i18n_key:credential_type_stackby_api_name SET
    description = "Nom affiché du credential type Stackby API";

CREATE i18n_key:credential_type_stackby_api_description SET
    description = "Description complète de Stackby API pour credentials";

CREATE i18n_key:credential_type_stackby_api_tooltip SET
    description = "Tooltip d'aide pour Stackby API credentials";

-- =====================================================
-- RÉSUMÉ BATCH 15 - CLÉS I18N
-- =====================================================
--
-- ✅ 33 clés i18n créées pour 11 credential types (3 clés × 11 credentials)
--
-- Headless CMS Platforms (15 clés) :
--  1. contentful_api (name, description, tooltip)
--  2. strapi_api (name, description, tooltip)
--  3. strapi_token_api (name, description, tooltip)
--  4. storyblok_content_api (name, description, tooltip)
--  5. storyblok_management_api (name, description, tooltip)
--
-- ERP Systems (6 clés) :
--  6. odoo_api (name, description, tooltip)
--  7. erpnext_api (name, description, tooltip)
--
-- Spreadsheet & Database Platforms (12 clés) :
--  8. grist_api (name, description, tooltip)
--  9. seatable_api (name, description, tooltip)
-- 10. quickbase_api (name, description, tooltip)
-- 11. stackby_api (name, description, tooltip)
--
-- =============================================================================================

