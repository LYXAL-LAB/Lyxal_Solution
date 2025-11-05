-- =============================================================================================
-- | Fichier : credential_type_batch21_seeds.surql (SEED DATA)
-- | Batch 21 : Diverse APIs - Logistics, Security, Events & Email (11 credentials)
-- =============================================================================================

-- 1. DHL API (1120)
CREATE credential_type:dhl_api SET
    name = "dhlApi", slug = "dhl-api", is_active = true,
    identity = { display_name_i18n: i18n_key:credential_type_dhl_api_name, description_i18n: i18n_key:credential_type_dhl_api_description },
    presentation = { icon: icon:dhl, color_type: theme_color_type:warning, tooltip_i18n: i18n_key:credential_type_dhl_api_tooltip, display_order: 1120 },
    auth_type = auth_type:api_key, provider = provider:dhl,
    config = { oauth2: NONE, oauth1: NONE, required_fields: [{ name: "apiKey", display_name: "API Key", type: "string", is_secret: true, required: true }], metadata: { logistics: true, shipping: true } },
    documentation = { url: url:dhl_docs, use_cases_i18n: NONE };

-- 2. DROPCONTACT API (1121)
CREATE credential_type:dropcontact_api SET
    name = "dropcontactApi", slug = "dropcontact-api", is_active = true,
    identity = { display_name_i18n: i18n_key:credential_type_dropcontact_api_name, description_i18n: i18n_key:credential_type_dropcontact_api_description },
    presentation = { icon: icon:dropcontact, color_type: theme_color_type:info, tooltip_i18n: i18n_key:credential_type_dropcontact_api_tooltip, display_order: 1121 },
    auth_type = auth_type:custom, provider = provider:dropcontact,
    config = { oauth2: NONE, oauth1: NONE, required_fields: [{ name: "apiKey", display_name: "API Key", type: "string", is_secret: true, required: true }], metadata: { email_enrichment: true, data_quality: true, custom_header: "X-Access-Token" } },
    documentation = { url: url:dropcontact_docs, use_cases_i18n: NONE };

-- 3. DYNATRACE API (1122)
CREATE credential_type:dynatrace_api SET
    name = "dynatraceApi", slug = "dynatrace-api", is_active = true,
    identity = { display_name_i18n: i18n_key:credential_type_dynatrace_api_name, description_i18n: i18n_key:credential_type_dynatrace_api_description },
    presentation = { icon: icon:dynatrace, color_type: theme_color_type:info, tooltip_i18n: i18n_key:credential_type_dynatrace_api_tooltip, display_order: 1122 },
    auth_type = auth_type:custom, provider = provider:dynatrace,
    config = { oauth2: NONE, oauth1: NONE, required_fields: [{ name: "apiKey", display_name: "API Key", type: "string", is_secret: true, required: true }], metadata: { apm: true, observability: true, monitoring: true, custom_header: "Api-Token" } },
    documentation = { url: url:dynatrace_docs, use_cases_i18n: NONE };

-- 4. ELASTIC SECURITY API (1123)
CREATE credential_type:elastic_security_api SET
    name = "elasticSecurityApi", slug = "elastic-security-api", is_active = true,
    identity = { display_name_i18n: i18n_key:credential_type_elastic_security_api_name, description_i18n: i18n_key:credential_type_elastic_security_api_description },
    presentation = { icon: icon:elastic, color_type: theme_color_type:warning, tooltip_i18n: i18n_key:credential_type_elastic_security_api_tooltip, display_order: 1123 },
    auth_type = auth_type:basic, provider = provider:elastic,
    config = { oauth2: NONE, oauth1: NONE, required_fields: [{ name: "baseUrl", display_name: "Base URL", type: "string", is_secret: false, required: true }, { name: "username", display_name: "Username", type: "string", is_secret: false, required: false }, { name: "password", display_name: "Password", type: "string", is_secret: true, required: false }, { name: "apiKey", display_name: "API Key", type: "string", is_secret: true, required: false }], metadata: { security: true, siem: true, endpoint_protection: true } },
    documentation = { url: url:elastic_security_docs, use_cases_i18n: NONE };

-- 5. EMELIA API (1124)
CREATE credential_type:emelia_api SET
    name = "emeliaApi", slug = "emelia-api", is_active = true,
    identity = { display_name_i18n: i18n_key:credential_type_emelia_api_name, description_i18n: i18n_key:credential_type_emelia_api_description },
    presentation = { icon: icon:emelia, color_type: theme_color_type:secondary, tooltip_i18n: i18n_key:credential_type_emelia_api_tooltip, display_order: 1124 },
    auth_type = auth_type:api_key, provider = provider:emelia,
    config = { oauth2: NONE, oauth1: NONE, required_fields: [{ name: "apiKey", display_name: "API Key", type: "string", is_secret: true, required: true }], metadata: { email_automation: true, cold_emailing: true } },
    documentation = { url: url:emelia_docs, use_cases_i18n: NONE };

-- 6. EVENTBRITE API (1125)
CREATE credential_type:eventbrite_api SET
    name = "eventbriteApi", slug = "eventbrite-api", is_active = true,
    identity = { display_name_i18n: i18n_key:credential_type_eventbrite_api_name, description_i18n: i18n_key:credential_type_eventbrite_api_description },
    presentation = { icon: icon:eventbrite, color_type: theme_color_type:primary, tooltip_i18n: i18n_key:credential_type_eventbrite_api_tooltip, display_order: 1125 },
    auth_type = auth_type:bearer_token, provider = provider:eventbrite,
    config = { oauth2: NONE, oauth1: NONE, required_fields: [{ name: "apiKey", display_name: "Private Key", type: "string", is_secret: true, required: true }], metadata: { events: true, ticketing: true, very_popular: true } },
    documentation = { url: url:eventbrite_docs, use_cases_i18n: NONE };

-- 7. EVENTBRITE OAUTH2 API (1126)
CREATE credential_type:eventbrite_oauth2_api SET
    name = "eventbriteOAuth2Api", slug = "eventbrite-oauth2-api", is_active = true,
    identity = { display_name_i18n: i18n_key:credential_type_eventbrite_oauth2_api_name, description_i18n: i18n_key:credential_type_eventbrite_oauth2_api_description },
    presentation = { icon: icon:eventbrite, color_type: theme_color_type:primary, tooltip_i18n: i18n_key:credential_type_eventbrite_oauth2_api_tooltip, display_order: 1126 },
    auth_type = auth_type:oauth2, provider = provider:eventbrite,
    config = { oauth2: { grant_type: "authorization_code", auth_url: "https://www.eventbrite.com/oauth/authorize", access_token_url: "https://www.eventbrite.com/oauth/token", scope: "", authentication: "body" }, oauth1: NONE, required_fields: [], metadata: { oauth_recommended: true } },
    documentation = { url: url:eventbrite_oauth2_docs, use_cases_i18n: NONE };

-- 8. F5 BIG-IP API (1127)
CREATE credential_type:f5_big_ip_api SET
    name = "f5BigIpApi", slug = "f5-big-ip-api", is_active = true,
    identity = { display_name_i18n: i18n_key:credential_type_f5_big_ip_api_name, description_i18n: i18n_key:credential_type_f5_big_ip_api_description },
    presentation = { icon: icon:f5, color_type: theme_color_type:neutral, tooltip_i18n: i18n_key:credential_type_f5_big_ip_api_tooltip, display_order: 1127 },
    auth_type = auth_type:basic, provider = provider:f5,
    config = { oauth2: NONE, oauth1: NONE, required_fields: [{ name: "url", display_name: "URL", type: "string", is_secret: false, required: true }, { name: "username", display_name: "Username", type: "string", is_secret: false, required: true }, { name: "password", display_name: "Password", type: "string", is_secret: true, required: true }], metadata: { load_balancer: true, network_security: true } },
    documentation = { url: url:f5_docs, use_cases_i18n: NONE };

-- 9. FILEMAKER (1128)
CREATE credential_type:file_maker SET
    name = "fileMaker", slug = "file-maker", is_active = true,
    identity = { display_name_i18n: i18n_key:credential_type_file_maker_name, description_i18n: i18n_key:credential_type_file_maker_description },
    presentation = { icon: icon:filemaker, color_type: theme_color_type:neutral, tooltip_i18n: i18n_key:credential_type_file_maker_tooltip, display_order: 1128 },
    auth_type = auth_type:basic, provider = provider:filemaker,
    config = { oauth2: NONE, oauth1: NONE, required_fields: [{ name: "host", display_name: "Host", type: "string", is_secret: false, required: true }, { name: "database", display_name: "Database", type: "string", is_secret: false, required: true }, { name: "username", display_name: "Username", type: "string", is_secret: false, required: true }, { name: "password", display_name: "Password", type: "string", is_secret: true, required: true }], metadata: { database: true, low_code: true } },
    documentation = { url: url:filemaker_docs, use_cases_i18n: NONE };

-- 10. FILESCAN API (1129)
CREATE credential_type:filescan_api SET
    name = "filescanApi", slug = "filescan-api", is_active = true,
    identity = { display_name_i18n: i18n_key:credential_type_filescan_api_name, description_i18n: i18n_key:credential_type_filescan_api_description },
    presentation = { icon: icon:filescan, color_type: theme_color_type:neutral, tooltip_i18n: i18n_key:credential_type_filescan_api_tooltip, display_order: 1129 },
    auth_type = auth_type:api_key, provider = provider:filescan,
    config = { oauth2: NONE, oauth1: NONE, required_fields: [{ name: "apiKey", display_name: "API Key", type: "string", is_secret: true, required: true }], metadata: { file_scanning: true, malware_detection: true, security: true } },
    documentation = { url: url:filescan_docs, use_cases_i18n: NONE };

-- 11. FLOW API (1130)
CREATE credential_type:flow_api SET
    name = "flowApi", slug = "flow-api", is_active = true,
    identity = { display_name_i18n: i18n_key:credential_type_flow_api_name, description_i18n: i18n_key:credential_type_flow_api_description },
    presentation = { icon: icon:flow, color_type: theme_color_type:neutral, tooltip_i18n: i18n_key:credential_type_flow_api_tooltip, display_order: 1130 },
    auth_type = auth_type:api_key, provider = provider:flow,
    config = { oauth2: NONE, oauth1: NONE, required_fields: [{ name: "organizationId", display_name: "Organization ID", type: "string", is_secret: false, required: true }, { name: "accessToken", display_name: "Access Token", type: "string", is_secret: true, required: true }], metadata: { project_management: true, task_management: true } },
    documentation = { url: url:flow_docs, use_cases_i18n: NONE };

-- =============================================================================================
-- ✅ Batch 21: 11 credentials créés (display_order: 1120-1130)
-- Logistics (1), Email/Data (2), Monitoring/Security (3), Events (2), Network (1), Database (1), Security Scan (1), Project Mgmt (1)
-- =============================================================================================

