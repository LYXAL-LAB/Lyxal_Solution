-- =============================================================================================
-- | Fichier : credential_type_batch26_seeds.surql (SEED DATA)
-- | Batch 26 : Productivity, Email, Messaging & Directory APIs (11 credentials)
-- =============================================================================================

-- 1. KITEMAKER API (1220)
CREATE credential_type:kitemaker_api SET
    name = "kitemakerApi", slug = "kitemaker-api", is_active = true,
    identity = { display_name_i18n: i18n_key:credential_type_kitemaker_api_name, description_i18n: i18n_key:credential_type_kitemaker_api_description },
    presentation = { icon: icon:kitemaker, color: "#5850EC", color_daisy: "secondary", tooltip_i18n: i18n_key:credential_type_kitemaker_api_tooltip, display_order: 1220 },
    auth_type = auth_type:bearer_token, provider = provider:kitemaker,
    config = { oauth2: NONE, oauth1: NONE, required_fields: [{ name: "personalAccessToken", display_name: "Personal Access Token", type: "string", is_secret: true, required: true }], metadata: { project_management: true, issue_tracking: true } },
    documentation = { url: url:kitemaker_docs, use_cases_i18n: NONE };

-- 2. KOBO TOOLBOX API (1221)
CREATE credential_type:ko_bo_toolbox_api SET
    name = "koBoToolboxApi", slug = "ko-bo-toolbox-api", is_active = true,
    identity = { display_name_i18n: i18n_key:credential_type_ko_bo_toolbox_api_name, description_i18n: i18n_key:credential_type_ko_bo_toolbox_api_description },
    presentation = { icon: icon:kobotoolbox, color: "#28A2A3", color_daisy: "success", tooltip_i18n: i18n_key:credential_type_ko_bo_toolbox_api_tooltip, display_order: 1221 },
    auth_type = auth_type:bearer_token, provider = provider:kobotoolbox,
    config = { oauth2: NONE, oauth1: NONE, required_fields: [{ name: "URL", display_name: "URL", type: "string", is_secret: false, required: true, default: "https://kf.kobotoolbox.org" }, { name: "token", display_name: "Token", type: "string", is_secret: true, required: true }], metadata: { data_collection: true, surveys: true, humanitarian: true } },
    documentation = { url: url:kobotoolbox_docs, use_cases_i18n: NONE };

-- 3. LDAP (1222)
CREATE credential_type:ldap SET
    name = "ldap", slug = "ldap", is_active = true,
    identity = { display_name_i18n: i18n_key:credential_type_ldap_name, description_i18n: i18n_key:credential_type_ldap_description },
    presentation = { icon: icon:ldap, color: "#00758F", color_daisy: "info", tooltip_i18n: i18n_key:credential_type_ldap_tooltip, display_order: 1222 },
    auth_type = auth_type:basic, provider = provider:ldap,
    config = { oauth2: NONE, oauth1: NONE, required_fields: [{ name: "hostname", display_name: "Hostname", type: "string", is_secret: false, required: true }, { name: "port", display_name: "Port", type: "number", is_secret: false, required: true, default: 389 }, { name: "bindDN", display_name: "Bind DN", type: "string", is_secret: false, required: true }, { name: "bindPassword", display_name: "Bind Password", type: "string", is_secret: true, required: true }], metadata: { directory_service: true, authentication: true, enterprise: true, very_popular: true } },
    documentation = { url: url:ldap_docs, use_cases_i18n: NONE };

-- 4. LINE NOTIFY OAUTH2 API (1223)
CREATE credential_type:line_notify_oauth2_api SET
    name = "lineNotifyOAuth2Api", slug = "line-notify-oauth2-api", is_active = true,
    identity = { display_name_i18n: i18n_key:credential_type_line_notify_oauth2_api_name, description_i18n: i18n_key:credential_type_line_notify_oauth2_api_description },
    presentation = { icon: icon:line, color: "#00C300", color_daisy: "success", tooltip_i18n: i18n_key:credential_type_line_notify_oauth2_api_tooltip, display_order: 1223 },
    auth_type = auth_type:oauth2, provider = provider:line,
    config = { oauth2: { grant_type: "authorization_code", auth_url: "https://notify-bot.line.me/oauth/authorize", access_token_url: "https://notify-bot.line.me/oauth/token", scope: "notify", authentication: "body" }, oauth1: NONE, required_fields: [], metadata: { messaging: true, notifications: true, japan: true } },
    documentation = { url: url:line_notify_docs, use_cases_i18n: NONE };

-- 5. LINGVANEX API (1224)
CREATE credential_type:lingva_nex_api SET
    name = "lingvaNexApi", slug = "lingva-nex-api", is_active = true,
    identity = { display_name_i18n: i18n_key:credential_type_lingva_nex_api_name, description_i18n: i18n_key:credential_type_lingva_nex_api_description },
    presentation = { icon: icon:lingvanex, color: "#4A90E2", color_daisy: "info", tooltip_i18n: i18n_key:credential_type_lingva_nex_api_tooltip, display_order: 1224 },
    auth_type = auth_type:bearer_token, provider = provider:lingvanex,
    config = { oauth2: NONE, oauth1: NONE, required_fields: [{ name: "apiKey", display_name: "API Key", type: "string", is_secret: true, required: true }], metadata: { translation: true, ai: true, nlp: true } },
    documentation = { url: url:lingvanex_docs, use_cases_i18n: NONE };

-- 6. LINKEDIN COMMUNITY MANAGEMENT OAUTH2 API (1225)
CREATE credential_type:linked_in_community_management_oauth2_api SET
    name = "linkedInCommunityManagementOAuth2Api", slug = "linked-in-community-management-oauth2-api", is_active = true,
    identity = { display_name_i18n: i18n_key:credential_type_linked_in_community_management_oauth2_api_name, description_i18n: i18n_key:credential_type_linked_in_community_management_oauth2_api_description },
    presentation = { icon: icon:linkedin, color: "#0A66C2", color_daisy: "info", tooltip_i18n: i18n_key:credential_type_linked_in_community_management_oauth2_api_tooltip, display_order: 1225 },
    auth_type = auth_type:oauth2, provider = provider:linkedin,
    config = { oauth2: { grant_type: "authorization_code", auth_url: "https://www.linkedin.com/oauth/v2/authorization", access_token_url: "https://www.linkedin.com/oauth/v2/accessToken", scope: "r_organization_social w_organization_social", authentication: "body" }, oauth1: NONE, required_fields: [], metadata: { social_media: true, community_management: true, very_popular: true } },
    documentation = { url: url:linkedin_community_docs, use_cases_i18n: NONE };

-- 7. LINKEDIN OAUTH2 API (1226)
CREATE credential_type:linked_in_oauth2_api SET
    name = "linkedInOAuth2Api", slug = "linked-in-oauth2-api", is_active = true,
    identity = { display_name_i18n: i18n_key:credential_type_linked_in_oauth2_api_name, description_i18n: i18n_key:credential_type_linked_in_oauth2_api_description },
    presentation = { icon: icon:linkedin, color: "#0A66C2", color_daisy: "accent", tooltip_i18n: i18n_key:credential_type_linked_in_oauth2_api_tooltip, display_order: 1226 },
    auth_type = auth_type:oauth2, provider = provider:linkedin,
    config = { oauth2: { grant_type: "authorization_code", auth_url: "https://www.linkedin.com/oauth/v2/authorization", access_token_url: "https://www.linkedin.com/oauth/v2/accessToken", scope: "r_liteprofile r_emailaddress w_member_social", authentication: "body" }, oauth1: NONE, required_fields: [], metadata: { social_media: true, professional_network: true, very_popular: true } },
    documentation = { url: url:linkedin_docs, use_cases_i18n: NONE };

-- 8. LONESCALE API (1227)
CREATE credential_type:lone_scale_api SET
    name = "loneScaleApi", slug = "lone-scale-api", is_active = true,
    identity = { display_name_i18n: i18n_key:credential_type_lone_scale_api_name, description_i18n: i18n_key:credential_type_lone_scale_api_description },
    presentation = { icon: icon:lonescale, color: "#6C5CE7", color_daisy: "secondary", tooltip_i18n: i18n_key:credential_type_lone_scale_api_tooltip, display_order: 1227 },
    auth_type = auth_type:bearer_token, provider = provider:lonescale,
    config = { oauth2: NONE, oauth1: NONE, required_fields: [{ name: "apiToken", display_name: "API Token", type: "string", is_secret: true, required: true }], metadata: { time_tracking: true, freelancing: true } },
    documentation = { url: url:lonescale_docs, use_cases_i18n: NONE };

-- 9. MAGENTO2 API (1228)
CREATE credential_type:magento2_api SET
    name = "magento2Api", slug = "magento2-api", is_active = true,
    identity = { display_name_i18n: i18n_key:credential_type_magento2_api_name, description_i18n: i18n_key:credential_type_magento2_api_description },
    presentation = { icon: icon:magento, color: "#EE672F", color_daisy: "error", tooltip_i18n: i18n_key:credential_type_magento2_api_tooltip, display_order: 1228 },
    auth_type = auth_type:bearer_token, provider = provider:magento,
    config = { oauth2: NONE, oauth1: NONE, required_fields: [{ name: "host", display_name: "Host", type: "string", is_secret: false, required: true }, { name: "accessToken", display_name: "Access Token", type: "string", is_secret: true, required: true }], metadata: { ecommerce: true, platform: true, very_popular: true } },
    documentation = { url: url:magento_docs, use_cases_i18n: NONE };

-- 10. MAILCHECK API (1229)
CREATE credential_type:mailcheck_api SET
    name = "mailcheckApi", slug = "mailcheck-api", is_active = true,
    identity = { display_name_i18n: i18n_key:credential_type_mailcheck_api_name, description_i18n: i18n_key:credential_type_mailcheck_api_description },
    presentation = { icon: icon:mailcheck, color: "#4A90E2", color_daisy: "info", tooltip_i18n: i18n_key:credential_type_mailcheck_api_tooltip, display_order: 1229 },
    auth_type = auth_type:api_key, provider = provider:mailcheck,
    config = { oauth2: NONE, oauth1: NONE, required_fields: [{ name: "apiKey", display_name: "API Key", type: "string", is_secret: true, required: true }], metadata: { email_verification: true, data_quality: true } },
    documentation = { url: url:mailcheck_docs, use_cases_i18n: NONE };

-- 11. MAILERLITE API (1230)
CREATE credential_type:mailer_lite_api SET
    name = "mailerLiteApi", slug = "mailer-lite-api", is_active = true,
    identity = { display_name_i18n: i18n_key:credential_type_mailer_lite_api_name, description_i18n: i18n_key:credential_type_mailer_lite_api_description },
    presentation = { icon: icon:mailerlite, color: "#09C269", color_daisy: "success", tooltip_i18n: i18n_key:credential_type_mailer_lite_api_tooltip, display_order: 1230 },
    auth_type = auth_type:api_key, provider = provider:mailerlite,
    config = { oauth2: NONE, oauth1: NONE, required_fields: [{ name: "apiKey", display_name: "API Key", type: "string", is_secret: true, required: true }], metadata: { email_marketing: true, newsletters: true, very_popular: true } },
    documentation = { url: url:mailerlite_docs, use_cases_i18n: NONE };

-- =============================================================================================
-- ✅ Batch 26: 11 credentials créés (display_order: 1220-1230)
-- Project Mgmt (1), Data Collection (1), Directory (1), Messaging (2), Translation (1), Social Media (2), Time Tracking (1), E-commerce (1), Email (2)
-- =============================================================================================

