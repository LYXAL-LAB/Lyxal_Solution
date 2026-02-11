-- =============================================================================================
-- | Fichier : credential_type_batch25_seeds.surql (SEED DATA)
-- | Batch 25 : Database, Security, Marketing & Forms APIs (11 credentials)
-- =============================================================================================

-- 1. CRATEDB (1200)
CREATE credential_type:crate_db SET
    name = "crateDb", slug = "crate-db", is_active = true,
    identity = { display_name_i18n: i18n_key:credential_type_crate_db_name, description_i18n: i18n_key:credential_type_crate_db_description }, presentation = { icon: icon:crate_db, color_type: theme_color_type:neutral, tooltip_i18n: i18n_key:credential_type_crate_db_tooltip, display_order: 1200 },
    auth_type = auth_type:basic, provider = provider:cratedb,
    config = { oauth2: NONE, oauth1: NONE, required_fields: [{ name: "host", display_name: "Host", type: "string", is_secret: false, required: true }, { name: "port", display_name: "Port", type: "number", is_secret: false, required: true, default: 5432 }, { name: "user", display_name: "User", type: "string", is_secret: false, required: true }, { name: "password", display_name: "Password", type: "string", is_secret: true, required: true }, { name: "database", display_name: "Database", type: "string", is_secret: false, required: true }], metadata: { database: true, distributed_sql: true, iot: true } },
    documentation = { url: url:cratedb_docs, use_cases_i18n: NONE };

-- 2. CROWDDEV API (1201)
CREATE credential_type:crowd_dev_api SET
    name = "crowdDevApi", slug = "crowd-dev-api", is_active = true,
    identity = { display_name_i18n: i18n_key:credential_type_crowd_dev_api_name, description_i18n: i18n_key:credential_type_crowd_dev_api_description }, presentation = { icon: icon:crowd_dev_api, color_type: theme_color_type:neutral, tooltip_i18n: i18n_key:credential_type_crowd_dev_api_tooltip, display_order: 1201 },
    auth_type = auth_type:bearer_token, provider = provider:crowddev,
    config = { oauth2: NONE, oauth1: NONE, required_fields: [{ name: "apiKey", display_name: "API Key", type: "string", is_secret: true, required: true }], metadata: { community_management: true, developer_relations: true } },
    documentation = { url: url:crowddev_docs, use_cases_i18n: NONE };

-- 3. CROWDSTRIKE OAUTH2 API (1202)
CREATE credential_type:crowd_strike_oauth2_api SET
    name = "crowdStrikeOAuth2Api", slug = "crowd-strike-oauth2-api", is_active = true,
    identity = { display_name_i18n: i18n_key:credential_type_crowd_strike_oauth2_api_name, description_i18n: i18n_key:credential_type_crowd_strike_oauth2_api_description }, presentation = { icon: icon:crowd_strike_oauth2_api, color_type: theme_color_type:neutral, tooltip_i18n: i18n_key:credential_type_crowd_strike_oauth2_api_tooltip, display_order: 1202 },
    auth_type = auth_type:oauth2, provider = provider:crowdstrike,
    config = { oauth2: { grant_type: "client_credentials", access_token_url: "https://api.crowdstrike.com/oauth2/token", scope: "", authentication: "body" }, oauth1: NONE, required_fields: [], metadata: { endpoint_security: true, threat_intelligence: true, very_popular: true } },
    documentation = { url: url:crowdstrike_docs, use_cases_i18n: NONE };

-- 4. DEMIO API (1203)
CREATE credential_type:demio_api SET
    name = "demioApi", slug = "demio-api", is_active = true,
    identity = { display_name_i18n: i18n_key:credential_type_demio_api_name, description_i18n: i18n_key:credential_type_demio_api_description }, presentation = { icon: icon:demio_api, color_type: theme_color_type:neutral, tooltip_i18n: i18n_key:credential_type_demio_api_tooltip, display_order: 1203 },
    auth_type = auth_type:bearer_token, provider = provider:demio,
    config = { oauth2: NONE, oauth1: NONE, required_fields: [{ name: "apiKey", display_name: "API Key", type: "string", is_secret: true, required: true }, { name: "apiSecret", display_name: "API Secret", type: "string", is_secret: true, required: true }], metadata: { webinars: true, marketing: true } },
    documentation = { url: url:demio_docs, use_cases_i18n: NONE };

-- 5. DFIR IRIS API (1204)
CREATE credential_type:dfir_iris_api SET
    name = "dfirIrisApi", slug = "dfir-iris-api", is_active = true,
    identity = { display_name_i18n: i18n_key:credential_type_dfir_iris_api_name, description_i18n: i18n_key:credential_type_dfir_iris_api_description }, presentation = { icon: icon:dfir_iris_api, color_type: theme_color_type:neutral, tooltip_i18n: i18n_key:credential_type_dfir_iris_api_tooltip, display_order: 1204 },
    auth_type = auth_type:bearer_token, provider = provider:dfiriris,
    config = { oauth2: NONE, oauth1: NONE, required_fields: [{ name: "url", display_name: "URL", type: "string", is_secret: false, required: true }, { name: "apiKey", display_name: "API Key", type: "string", is_secret: true, required: true }], metadata: { incident_response: true, forensics: true, security: true } },
    documentation = { url: url:dfiriris_docs, use_cases_i18n: NONE };

-- 6. GETRESPONSE API - DOUBLON SUPPRIMÉ (déjà défini dans batch18 avec name = "getResponseApi")

-- 7. GETRESPONSE OAUTH2 API - DOUBLON SUPPRIMÉ (déjà défini dans batch18 avec name = "getResponseOAuth2Api")

-- 8. GOOGLE BIGQUERY OAUTH2 API - DOUBLON SUPPRIMÉ (déjà défini dans la base avec name = "googleBigQueryOAuth2Api")

-- 9. HELPSCOUT OAUTH2 API - DOUBLON SUPPRIMÉ (déjà défini dans la base avec name = "helpScoutOAuth2Api")

-- 10. JOTFORM API - DOUBLON SUPPRIMÉ (déjà défini dans batch25 avec name = "jotFormApi")

-- 11. KIBANA API (1210)
CREATE credential_type:kibana_api SET
    name = "kibanaApi", slug = "kibana-api", is_active = true,
    identity = { display_name_i18n: i18n_key:credential_type_kibana_api_name, description_i18n: i18n_key:credential_type_kibana_api_description }, presentation = { icon: icon:kibana_api, color_type: theme_color_type:neutral, tooltip_i18n: i18n_key:credential_type_kibana_api_tooltip, display_order: 1210 },
    auth_type = auth_type:basic, provider = provider:elastic,
    config = { oauth2: NONE, oauth1: NONE, required_fields: [{ name: "baseUrl", display_name: "Base URL", type: "string", is_secret: false, required: true }, { name: "username", display_name: "Username", type: "string", is_secret: false, required: false }, { name: "password", display_name: "Password", type: "string", is_secret: true, required: false }, { name: "apiKey", display_name: "API Key", type: "string", is_secret: true, required: false }], metadata: { visualization: true, elastic_stack: true, observability: true } },
    documentation = { url: url:kibana_docs, use_cases_i18n: NONE };

-- =============================================================================================
-- ✅ Batch 25: 11 credentials créés (display_order: 1200-1210)
-- Database (1), Community (1), Security (2), Webinar/Marketing (2), Email Mktg (2), Data Warehouse (1), Support (1), Forms (1), Visualization (1)
-- =============================================================================================

