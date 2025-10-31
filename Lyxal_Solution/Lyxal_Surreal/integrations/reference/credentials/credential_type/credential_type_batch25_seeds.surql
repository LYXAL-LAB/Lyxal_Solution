-- =============================================================================================
-- | Fichier : credential_type_batch25_seeds.surql (SEED DATA)
-- | Batch 25 : Database, Security, Marketing & Forms APIs (11 credentials)
-- =============================================================================================

-- 1. CRATEDB (1200)
CREATE credential_type:crate_db SET
    name = "crateDb", slug = "crate-db", is_active = true,
    identity = { display_name_i18n: i18n_key:credential_type_crate_db_name, description_i18n: i18n_key:credential_type_crate_db_description },
    presentation = { icon: icon:cratedb, color: "#009DC7", color_daisy: "info", tooltip_i18n: i18n_key:credential_type_crate_db_tooltip, display_order: 1200 },
    auth_type = auth_type:basic, provider = provider:cratedb,
    config = { oauth2: NONE, oauth1: NONE, required_fields: [{ name: "host", display_name: "Host", type: "string", is_secret: false, required: true }, { name: "port", display_name: "Port", type: "number", is_secret: false, required: true, default: 5432 }, { name: "user", display_name: "User", type: "string", is_secret: false, required: true }, { name: "password", display_name: "Password", type: "string", is_secret: true, required: true }, { name: "database", display_name: "Database", type: "string", is_secret: false, required: true }], metadata: { database: true, distributed_sql: true, iot: true } },
    documentation = { url: url:cratedb_docs, use_cases_i18n: NONE };

-- 2. CROWDDEV API (1201)
CREATE credential_type:crowd_dev_api SET
    name = "crowdDevApi", slug = "crowd-dev-api", is_active = true,
    identity = { display_name_i18n: i18n_key:credential_type_crowd_dev_api_name, description_i18n: i18n_key:credential_type_crowd_dev_api_description },
    presentation = { icon: icon:crowddev, color: "#E94F2E", color_daisy: "error", tooltip_i18n: i18n_key:credential_type_crowd_dev_api_tooltip, display_order: 1201 },
    auth_type = auth_type:bearer_token, provider = provider:crowddev,
    config = { oauth2: NONE, oauth1: NONE, required_fields: [{ name: "apiKey", display_name: "API Key", type: "string", is_secret: true, required: true }], metadata: { community_management: true, developer_relations: true } },
    documentation = { url: url:crowddev_docs, use_cases_i18n: NONE };

-- 3. CROWDSTRIKE OAUTH2 API (1202)
CREATE credential_type:crowd_strike_oauth2_api SET
    name = "crowdStrikeOAuth2Api", slug = "crowd-strike-oauth2-api", is_active = true,
    identity = { display_name_i18n: i18n_key:credential_type_crowd_strike_oauth2_api_name, description_i18n: i18n_key:credential_type_crowd_strike_oauth2_api_description },
    presentation = { icon: icon:crowdstrike, color: "#E01E27", color_daisy: "error", tooltip_i18n: i18n_key:credential_type_crowd_strike_oauth2_api_tooltip, display_order: 1202 },
    auth_type = auth_type:oauth2, provider = provider:crowdstrike,
    config = { oauth2: { grant_type: "client_credentials", access_token_url: "https://api.crowdstrike.com/oauth2/token", scope: "", authentication: "body" }, oauth1: NONE, required_fields: [], metadata: { endpoint_security: true, threat_intelligence: true, very_popular: true } },
    documentation = { url: url:crowdstrike_docs, use_cases_i18n: NONE };

-- 4. DEMIO API (1203)
CREATE credential_type:demio_api SET
    name = "demioApi", slug = "demio-api", is_active = true,
    identity = { display_name_i18n: i18n_key:credential_type_demio_api_name, description_i18n: i18n_key:credential_type_demio_api_description },
    presentation = { icon: icon:demio, color: "#4A6FF5", color_daisy: "info", tooltip_i18n: i18n_key:credential_type_demio_api_tooltip, display_order: 1203 },
    auth_type = auth_type:bearer_token, provider = provider:demio,
    config = { oauth2: NONE, oauth1: NONE, required_fields: [{ name: "apiKey", display_name: "API Key", type: "string", is_secret: true, required: true }, { name: "apiSecret", display_name: "API Secret", type: "string", is_secret: true, required: true }], metadata: { webinars: true, marketing: true } },
    documentation = { url: url:demio_docs, use_cases_i18n: NONE };

-- 5. DFIR IRIS API (1204)
CREATE credential_type:dfir_iris_api SET
    name = "dfirIrisApi", slug = "dfir-iris-api", is_active = true,
    identity = { display_name_i18n: i18n_key:credential_type_dfir_iris_api_name, description_i18n: i18n_key:credential_type_dfir_iris_api_description },
    presentation = { icon: icon:dfir, color: "#FF6B35", color_daisy: "error", tooltip_i18n: i18n_key:credential_type_dfir_iris_api_tooltip, display_order: 1204 },
    auth_type = auth_type:bearer_token, provider = provider:dfiriris,
    config = { oauth2: NONE, oauth1: NONE, required_fields: [{ name: "url", display_name: "URL", type: "string", is_secret: false, required: true }, { name: "apiKey", display_name: "API Key", type: "string", is_secret: true, required: true }], metadata: { incident_response: true, forensics: true, security: true } },
    documentation = { url: url:dfiriris_docs, use_cases_i18n: NONE };

-- 6. GETRESPONSE API (1205)
CREATE credential_type:get_response_api SET
    name = "getResponseApi", slug = "get-response-api", is_active = true,
    identity = { display_name_i18n: i18n_key:credential_type_get_response_api_name, description_i18n: i18n_key:credential_type_get_response_api_description },
    presentation = { icon: icon:getresponse, color: "#00BAFF", color_daisy: "info", tooltip_i18n: i18n_key:credential_type_get_response_api_tooltip, display_order: 1205 },
    auth_type = auth_type:api_key, provider = provider:getresponse,
    config = { oauth2: NONE, oauth1: NONE, required_fields: [{ name: "apiKey", display_name: "API Key", type: "string", is_secret: true, required: true }], metadata: { email_marketing: true, marketing_automation: true } },
    documentation = { url: url:getresponse_docs, use_cases_i18n: NONE };

-- 7. GETRESPONSE OAUTH2 API (1206)
CREATE credential_type:get_response_oauth2_api SET
    name = "getResponseOAuth2Api", slug = "get-response-oauth2-api", is_active = true,
    identity = { display_name_i18n: i18n_key:credential_type_get_response_oauth2_api_name, description_i18n: i18n_key:credential_type_get_response_oauth2_api_description },
    presentation = { icon: icon:getresponse, color: "#00BAFF", color_daisy: "accent", tooltip_i18n: i18n_key:credential_type_get_response_oauth2_api_tooltip, display_order: 1206 },
    auth_type = auth_type:oauth2, provider = provider:getresponse,
    config = { oauth2: { grant_type: "authorization_code", auth_url: "https://app.getresponse.com/oauth2_authorize.html", access_token_url: "https://api.getresponse.com/v3/token", scope: "", authentication: "body" }, oauth1: NONE, required_fields: [], metadata: { oauth_recommended: true } },
    documentation = { url: url:getresponse_oauth2_docs, use_cases_i18n: NONE };

-- 8. GOOGLE BIGQUERY OAUTH2 API (1207)
CREATE credential_type:google_big_query_oauth2_api SET
    name = "googleBigQueryOAuth2Api", slug = "google-big-query-oauth2-api", is_active = true,
    identity = { display_name_i18n: i18n_key:credential_type_google_big_query_oauth2_api_name, description_i18n: i18n_key:credential_type_google_big_query_oauth2_api_description },
    presentation = { icon: icon:googlebigquery, color: "#4285F4", color_daisy: "info", tooltip_i18n: i18n_key:credential_type_google_big_query_oauth2_api_tooltip, display_order: 1207 },
    auth_type = auth_type:oauth2, provider = provider:google,
    config = { oauth2: { grant_type: "authorization_code", auth_url: "https://accounts.google.com/o/oauth2/v2/auth", access_token_url: "https://oauth2.googleapis.com/token", scope: "https://www.googleapis.com/auth/bigquery", authentication: "body" }, oauth1: NONE, required_fields: [], metadata: { data_warehouse: true, analytics: true, google_cloud: true, very_popular: true } },
    documentation = { url: url:bigquery_docs, use_cases_i18n: NONE };

-- 9. HELPSCOUT OAUTH2 API (1208)
CREATE credential_type:help_scout_oauth2_api SET
    name = "helpScoutOAuth2Api", slug = "help-scout-oauth2-api", is_active = true,
    identity = { display_name_i18n: i18n_key:credential_type_help_scout_oauth2_api_name, description_i18n: i18n_key:credential_type_help_scout_oauth2_api_description },
    presentation = { icon: icon:helpscout, color: "#1292EE", color_daisy: "info", tooltip_i18n: i18n_key:credential_type_help_scout_oauth2_api_tooltip, display_order: 1208 },
    auth_type = auth_type:oauth2, provider = provider:helpscout,
    config = { oauth2: { grant_type: "authorization_code", auth_url: "https://secure.helpscout.net/authentication/authorizeClientApplication", access_token_url: "https://api.helpscout.net/v2/oauth2/token", scope: "", authentication: "body" }, oauth1: NONE, required_fields: [], metadata: { customer_support: true, helpdesk: true } },
    documentation = { url: url:helpscout_oauth2_docs, use_cases_i18n: NONE };

-- 10. JOTFORM API (1209)
CREATE credential_type:jot_form_api SET
    name = "jotFormApi", slug = "jot-form-api", is_active = true,
    identity = { display_name_i18n: i18n_key:credential_type_jot_form_api_name, description_i18n: i18n_key:credential_type_jot_form_api_description },
    presentation = { icon: icon:jotform, color: "#FF6100", color_daisy: "warning", tooltip_i18n: i18n_key:credential_type_jot_form_api_tooltip, display_order: 1209 },
    auth_type = auth_type:api_key, provider = provider:jotform,
    config = { oauth2: NONE, oauth1: NONE, required_fields: [{ name: "apiKey", display_name: "API Key", type: "string", is_secret: true, required: true }, { name: "apiDomain", display_name: "API Domain", type: "options", is_secret: false, required: true, options: [{ name: "api.jotform.com", value: "api.jotform.com" }, { name: "eu-api.jotform.com", value: "eu-api.jotform.com" }, { name: "hipaa-api.jotform.com", value: "hipaa-api.jotform.com" }], default: "api.jotform.com" }], metadata: { forms: true, data_collection: true, very_popular: true } },
    documentation = { url: url:jotform_docs, use_cases_i18n: NONE };

-- 11. KIBANA API (1210)
CREATE credential_type:kibana_api SET
    name = "kibanaApi", slug = "kibana-api", is_active = true,
    identity = { display_name_i18n: i18n_key:credential_type_kibana_api_name, description_i18n: i18n_key:credential_type_kibana_api_description },
    presentation = { icon: icon:kibana, color: "#FEC514", color_daisy: "warning", tooltip_i18n: i18n_key:credential_type_kibana_api_tooltip, display_order: 1210 },
    auth_type = auth_type:basic, provider = provider:elastic,
    config = { oauth2: NONE, oauth1: NONE, required_fields: [{ name: "baseUrl", display_name: "Base URL", type: "string", is_secret: false, required: true }, { name: "username", display_name: "Username", type: "string", is_secret: false, required: false }, { name: "password", display_name: "Password", type: "string", is_secret: true, required: false }, { name: "apiKey", display_name: "API Key", type: "string", is_secret: true, required: false }], metadata: { visualization: true, elastic_stack: true, observability: true } },
    documentation = { url: url:kibana_docs, use_cases_i18n: NONE };

-- =============================================================================================
-- ✅ Batch 25: 11 credentials créés (display_order: 1200-1210)
-- Database (1), Community (1), Security (2), Webinar/Marketing (2), Email Mktg (2), Data Warehouse (1), Support (1), Forms (1), Visualization (1)
-- =============================================================================================

