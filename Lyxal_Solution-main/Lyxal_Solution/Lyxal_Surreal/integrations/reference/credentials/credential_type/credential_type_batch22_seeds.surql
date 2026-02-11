-- =============================================================================================
-- | Fichier : credential_type_batch22_seeds.surql (SEED DATA)
-- | Batch 22 : Forms, Security, CRM, Google & Communication APIs (11 credentials)
-- =============================================================================================

-- 1. FORM.IO API (1140)
CREATE credential_type:form_io_api SET
    name = "formIoApi", slug = "form-io-api", is_active = true,
    identity = { display_name_i18n: i18n_key:credential_type_form_io_api_name, description_i18n: i18n_key:credential_type_form_io_api_description }, presentation = { icon: icon:form_io_api, color_type: theme_color_type:neutral, tooltip_i18n: i18n_key:credential_type_form_io_api_tooltip, display_order: 1140 },
    auth_type = auth_type:bearer_token, provider = provider:formio,
    config = { oauth2: NONE, oauth1: NONE, required_fields: [{ name: "environment", display_name: "Environment", type: "string", is_secret: false, required: true }, { name: "accessToken", display_name: "Access Token", type: "string", is_secret: true, required: true }], metadata: { forms: true, data_collection: true } },
    documentation = { url: url:formio_docs, use_cases_i18n: NONE };

-- 2. FORTIGATE API (1141)
CREATE credential_type:forti_gate_api SET
    name = "fortiGateApi", slug = "forti-gate-api", is_active = true,
    identity = { display_name_i18n: i18n_key:credential_type_forti_gate_api_name, description_i18n: i18n_key:credential_type_forti_gate_api_description }, presentation = { icon: icon:forti_gate_api, color_type: theme_color_type:neutral, tooltip_i18n: i18n_key:credential_type_forti_gate_api_tooltip, display_order: 1141 },
    auth_type = auth_type:api_key, provider = provider:fortinet,
    config = { oauth2: NONE, oauth1: NONE, required_fields: [{ name: "url", display_name: "URL", type: "string", is_secret: false, required: true }, { name: "accessToken", display_name: "Access Token", type: "string", is_secret: true, required: true }], metadata: { firewall: true, network_security: true } },
    documentation = { url: url:fortigate_docs, use_cases_i18n: NONE };

-- 3. FRESHSERVICE API (1142)
CREATE credential_type:freshservice_api SET
    name = "freshserviceApi", slug = "freshservice-api", is_active = true,
    identity = { display_name_i18n: i18n_key:credential_type_freshservice_api_name, description_i18n: i18n_key:credential_type_freshservice_api_description }, presentation = { icon: icon:freshservice_api, color_type: theme_color_type:neutral, tooltip_i18n: i18n_key:credential_type_freshservice_api_tooltip, display_order: 1142 },
    auth_type = auth_type:basic, provider = provider:freshworks,
    config = { oauth2: NONE, oauth1: NONE, required_fields: [{ name: "domain", display_name: "Domain", type: "string", is_secret: false, required: true }, { name: "apiKey", display_name: "API Key", type: "string", is_secret: true, required: true }], metadata: { itsm: true, service_desk: true, helpdesk: true } },
    documentation = { url: url:freshservice_docs, use_cases_i18n: NONE };

-- 4. FRESHWORKS CRM API (1143)
CREATE credential_type:freshworks_crm_api SET
    name = "freshworksCrmApi", slug = "freshworks-crm-api", is_active = true,
    identity = { display_name_i18n: i18n_key:credential_type_freshworks_crm_api_name, description_i18n: i18n_key:credential_type_freshworks_crm_api_description }, presentation = { icon: icon:freshworks_crm_api, color_type: theme_color_type:neutral, tooltip_i18n: i18n_key:credential_type_freshworks_crm_api_tooltip, display_order: 1143 },
    auth_type = auth_type:bearer_token, provider = provider:freshworks,
    config = { oauth2: NONE, oauth1: NONE, required_fields: [{ name: "domain", display_name: "Domain", type: "string", is_secret: false, required: true }, { name: "apiKey", display_name: "API Key", type: "string", is_secret: true, required: true }], metadata: { crm: true, sales: true } },
    documentation = { url: url:freshworks_crm_docs, use_cases_i18n: NONE };

-- 5. G SUITE ADMIN OAUTH2 API (1144)
CREATE credential_type:g_suite_admin_oauth2_api SET
    name = "gSuiteAdminOAuth2Api", slug = "g-suite-admin-oauth2-api", is_active = true,
    identity = { display_name_i18n: i18n_key:credential_type_g_suite_admin_oauth2_api_name, description_i18n: i18n_key:credential_type_g_suite_admin_oauth2_api_description }, presentation = { icon: icon:g_suite_admin_oauth2_api, color_type: theme_color_type:neutral, tooltip_i18n: i18n_key:credential_type_g_suite_admin_oauth2_api_tooltip, display_order: 1144 },
    auth_type = auth_type:oauth2, provider = provider:google,
    config = { oauth2: { grant_type: "authorization_code", auth_url: "https://accounts.google.com/o/oauth2/v2/auth", access_token_url: "https://oauth2.googleapis.com/token", scope: "https://www.googleapis.com/auth/admin.directory.user", authentication: "body" }, oauth1: NONE, required_fields: [], metadata: { google_workspace: true, admin: true, very_popular: true } },
    documentation = { url: url:gsuite_admin_docs, use_cases_i18n: NONE };

-- 6. GIT PASSWORD (1145)
CREATE credential_type:git_password SET
    name = "gitPassword", slug = "git-password", is_active = true,
    identity = { display_name_i18n: i18n_key:credential_type_git_password_name, description_i18n: i18n_key:credential_type_git_password_description }, presentation = { icon: icon:git_password, color_type: theme_color_type:neutral, tooltip_i18n: i18n_key:credential_type_git_password_tooltip, display_order: 1145 },
    auth_type = auth_type:basic, provider = provider:git,
    config = { oauth2: NONE, oauth1: NONE, required_fields: [{ name: "username", display_name: "Username", type: "string", is_secret: false, required: true }, { name: "password", display_name: "Password / Token", type: "string", is_secret: true, required: true }], metadata: { git: true, version_control: true, very_popular: true } },
    documentation = { url: url:git_docs, use_cases_i18n: NONE };

-- 7. GMAIL OAUTH2 API (1146)
CREATE credential_type:gmail_oauth2_api SET
    name = "gmailOAuth2Api", slug = "gmail-oauth2-api", is_active = true,
    identity = { display_name_i18n: i18n_key:credential_type_gmail_oauth2_api_name, description_i18n: i18n_key:credential_type_gmail_oauth2_api_description }, presentation = { icon: icon:gmail_oauth2_api, color_type: theme_color_type:neutral, tooltip_i18n: i18n_key:credential_type_gmail_oauth2_api_tooltip, display_order: 1146 },
    auth_type = auth_type:oauth2, provider = provider:google,
    config = { oauth2: { grant_type: "authorization_code", auth_url: "https://accounts.google.com/o/oauth2/v2/auth", access_token_url: "https://oauth2.googleapis.com/token", scope: "https://www.googleapis.com/auth/gmail.compose https://www.googleapis.com/auth/gmail.send", authentication: "body" }, oauth1: NONE, required_fields: [], metadata: { email: true, google: true, very_popular: true } },
    documentation = { url: url:gmail_docs, use_cases_i18n: NONE };

-- 8. GOTO WEBINAR OAUTH2 API (1147)
CREATE credential_type:go_to_webinar_oauth2_api SET
    name = "goToWebinarOAuth2Api", slug = "go-to-webinar-oauth2-api", is_active = true,
    identity = { display_name_i18n: i18n_key:credential_type_go_to_webinar_oauth2_api_name, description_i18n: i18n_key:credential_type_go_to_webinar_oauth2_api_description }, presentation = { icon: icon:go_to_webinar_oauth2_api, color_type: theme_color_type:neutral, tooltip_i18n: i18n_key:credential_type_go_to_webinar_oauth2_api_tooltip, display_order: 1147 },
    auth_type = auth_type:oauth2, provider = provider:gotowebinar,
    config = { oauth2: { grant_type: "authorization_code", auth_url: "https://api.getgo.com/oauth/v2/authorize", access_token_url: "https://api.getgo.com/oauth/v2/token", scope: "", authentication: "body" }, oauth1: NONE, required_fields: [], metadata: { webinars: true, video_conferencing: true } },
    documentation = { url: url:gotowebinar_docs, use_cases_i18n: NONE };

-- 9. GOTIFY API (1148)
CREATE credential_type:gotify_api SET
    name = "gotifyApi", slug = "gotify-api", is_active = true,
    identity = { display_name_i18n: i18n_key:credential_type_gotify_api_name, description_i18n: i18n_key:credential_type_gotify_api_description }, presentation = { icon: icon:gotify_api, color_type: theme_color_type:neutral, tooltip_i18n: i18n_key:credential_type_gotify_api_tooltip, display_order: 1148 },
    auth_type = auth_type:api_key, provider = provider:gotify,
    config = { oauth2: NONE, oauth1: NONE, required_fields: [{ name: "appToken", display_name: "App Token", type: "string", is_secret: true, required: true }, { name: "url", display_name: "URL", type: "string", is_secret: false, required: true }], metadata: { notifications: true, self_hosted: true, open_source: true } },
    documentation = { url: url:gotify_docs, use_cases_i18n: NONE };

-- 10. GUMROAD API (1149)
CREATE credential_type:gumroad_api SET
    name = "gumroadApi", slug = "gumroad-api", is_active = true,
    identity = { display_name_i18n: i18n_key:credential_type_gumroad_api_name, description_i18n: i18n_key:credential_type_gumroad_api_description }, presentation = { icon: icon:gumroad_api, color_type: theme_color_type:neutral, tooltip_i18n: i18n_key:credential_type_gumroad_api_tooltip, display_order: 1149 },
    auth_type = auth_type:bearer_token, provider = provider:gumroad,
    config = { oauth2: NONE, oauth1: NONE, required_fields: [{ name: "accessToken", display_name: "Access Token", type: "string", is_secret: true, required: true }], metadata: { ecommerce: true, digital_products: true } },
    documentation = { url: url:gumroad_docs, use_cases_i18n: NONE };

-- 11. HALO PSA API (1150)
CREATE credential_type:halo_psa_api SET
    name = "haloPsaApi", slug = "halo-psa-api", is_active = true,
    identity = { display_name_i18n: i18n_key:credential_type_halo_psa_api_name, description_i18n: i18n_key:credential_type_halo_psa_api_description }, presentation = { icon: icon:halo_psa_api, color_type: theme_color_type:neutral, tooltip_i18n: i18n_key:credential_type_halo_psa_api_tooltip, display_order: 1150 },
    auth_type = auth_type:oauth2, provider = provider:halopsa,
    config = { oauth2: NONE, oauth1: NONE, required_fields: [{ name: "clientId", display_name: "Client ID", type: "string", is_secret: false, required: true }, { name: "clientSecret", display_name: "Client Secret", type: "string", is_secret: true, required: true }, { name: "url", display_name: "URL", type: "string", is_secret: false, required: true }], metadata: { psa: true, itsm: true, msp: true } },
    documentation = { url: url:halopsa_docs, use_cases_i18n: NONE };

-- =============================================================================================
-- ✅ Batch 22: 11 credentials créés (display_order: 1140-1150)
-- Forms (1), Security/Firewall (1), ITSM/CRM (2), Google (2), Git (1), Webinar (1), Notifications (1), Ecommerce (1), PSA (1)
-- =============================================================================================

