-- =============================================================================================
-- | Fichier : credential_type_batch24_seeds.surql (SEED DATA)
-- | Batch 24 : DevOps, Networking & Productivity APIs (11 credentials)
-- =============================================================================================

-- 1. CIRCLECI API (1180)
CREATE credential_type:circle_ci_api SET
    name = "circleCiApi", slug = "circle-ci-api", is_active = true,
    identity = { display_name_i18n: i18n_key:credential_type_circle_ci_api_name, description_i18n: i18n_key:credential_type_circle_ci_api_description },
    presentation = { icon: icon:circleci, color: "#343434", color_daisy: "neutral", tooltip_i18n: i18n_key:credential_type_circle_ci_api_tooltip, display_order: 1180 },
    auth_type = auth_type:bearer_token, provider = provider:circleci,
    config = { oauth2: NONE, oauth1: NONE, required_fields: [{ name: "apiKey", display_name: "API Key", type: "string", is_secret: true, required: true }], metadata: { ci_cd: true, devops: true, very_popular: true } },
    documentation = { url: url:circleci_docs, use_cases_i18n: NONE };

-- 2. CISCO MERAKI API (1181)
CREATE credential_type:cisco_meraki_api SET
    name = "ciscoMerakiApi", slug = "cisco-meraki-api", is_active = true,
    identity = { display_name_i18n: i18n_key:credential_type_cisco_meraki_api_name, description_i18n: i18n_key:credential_type_cisco_meraki_api_description },
    presentation = { icon: icon:cisco, color: "#049FD9", color_daisy: "info", tooltip_i18n: i18n_key:credential_type_cisco_meraki_api_tooltip, display_order: 1181 },
    auth_type = auth_type:api_key, provider = provider:cisco,
    config = { oauth2: NONE, oauth1: NONE, required_fields: [{ name: "apiKey", display_name: "API Key", type: "string", is_secret: true, required: true }], metadata: { networking: true, cloud_managed: true, cisco: true } },
    documentation = { url: url:cisco_meraki_docs, use_cases_i18n: NONE };

-- 3. CISCO SECURE ENDPOINT API (1182)
CREATE credential_type:cisco_secure_endpoint_api SET
    name = "ciscoSecureEndpointApi", slug = "cisco-secure-endpoint-api", is_active = true,
    identity = { display_name_i18n: i18n_key:credential_type_cisco_secure_endpoint_api_name, description_i18n: i18n_key:credential_type_cisco_secure_endpoint_api_description },
    presentation = { icon: icon:cisco, color: "#049FD9", color_daisy: "info", tooltip_i18n: i18n_key:credential_type_cisco_secure_endpoint_api_tooltip, display_order: 1182 },
    auth_type = auth_type:basic, provider = provider:cisco,
    config = { oauth2: NONE, oauth1: NONE, required_fields: [{ name: "clientId", display_name: "Client ID", type: "string", is_secret: false, required: true }, { name: "clientSecret", display_name: "Client Secret", type: "string", is_secret: true, required: true }], metadata: { endpoint_security: true, threat_defense: true, cisco: true } },
    documentation = { url: url:cisco_secure_endpoint_docs, use_cases_i18n: NONE };

-- 4. CISCO UMBRELLA API (1183)
CREATE credential_type:cisco_umbrella_api SET
    name = "ciscoUmbrellaApi", slug = "cisco-umbrella-api", is_active = true,
    identity = { display_name_i18n: i18n_key:credential_type_cisco_umbrella_api_name, description_i18n: i18n_key:credential_type_cisco_umbrella_api_description },
    presentation = { icon: icon:cisco, color: "#049FD9", color_daisy: "info", tooltip_i18n: i18n_key:credential_type_cisco_umbrella_api_tooltip, display_order: 1183 },
    auth_type = auth_type:bearer_token, provider = provider:cisco,
    config = { oauth2: NONE, oauth1: NONE, required_fields: [{ name: "apiKey", display_name: "API Key", type: "string", is_secret: true, required: true }, { name: "apiSecret", display_name: "API Secret", type: "string", is_secret: true, required: true }], metadata: { dns_security: true, cloud_security: true, cisco: true } },
    documentation = { url: url:cisco_umbrella_docs, use_cases_i18n: NONE };

-- 5. CISCO WEBEX OAUTH2 API (1184)
CREATE credential_type:cisco_webex_oauth2_api SET
    name = "ciscoWebexOAuth2Api", slug = "cisco-webex-oauth2-api", is_active = true,
    identity = { display_name_i18n: i18n_key:credential_type_cisco_webex_oauth2_api_name, description_i18n: i18n_key:credential_type_cisco_webex_oauth2_api_description },
    presentation = { icon: icon:webex, color: "#06C", color_daisy: "info", tooltip_i18n: i18n_key:credential_type_cisco_webex_oauth2_api_tooltip, display_order: 1184 },
    auth_type = auth_type:oauth2, provider = provider:cisco,
    config = { oauth2: { grant_type: "authorization_code", auth_url: "https://webexapis.com/v1/authorize", access_token_url: "https://webexapis.com/v1/access_token", scope: "spark:all", authentication: "body" }, oauth1: NONE, required_fields: [], metadata: { collaboration: true, video_conferencing: true, very_popular: true } },
    documentation = { url: url:webex_docs, use_cases_i18n: NONE };

-- 6. CLICKUP API (1185)
CREATE credential_type:click_up_api SET
    name = "clickUpApi", slug = "click-up-api", is_active = true,
    identity = { display_name_i18n: i18n_key:credential_type_click_up_api_name, description_i18n: i18n_key:credential_type_click_up_api_description },
    presentation = { icon: icon:clickup, color: "#7B68EE", color_daisy: "secondary", tooltip_i18n: i18n_key:credential_type_click_up_api_tooltip, display_order: 1185 },
    auth_type = auth_type:bearer_token, provider = provider:clickup,
    config = { oauth2: NONE, oauth1: NONE, required_fields: [{ name: "accessToken", display_name: "Access Token", type: "string", is_secret: true, required: true }], metadata = { project_management: true, productivity: true, very_popular: true } },
    documentation = { url: url:clickup_docs, use_cases_i18n: NONE };

-- 7. CLICKUP OAUTH2 API (1186)
CREATE credential_type:click_up_oauth2_api SET
    name = "clickUpOAuth2Api", slug = "click-up-oauth2-api", is_active = true,
    identity = { display_name_i18n: i18n_key:credential_type_click_up_oauth2_api_name, description_i18n: i18n_key:credential_type_click_up_oauth2_api_description },
    presentation = { icon: icon:clickup, color: "#7B68EE", color_daisy: "accent", tooltip_i18n: i18n_key:credential_type_click_up_oauth2_api_tooltip, display_order: 1186 },
    auth_type = auth_type:oauth2, provider = provider:clickup,
    config = { oauth2: { grant_type: "authorization_code", auth_url: "https://app.clickup.com/api", access_token_url: "https://app.clickup.com/api/v2/oauth/token", scope: "", authentication: "body" }, oauth1: NONE, required_fields: [], metadata: { oauth_recommended: true } },
    documentation = { url: url:clickup_oauth2_docs, use_cases_i18n: NONE };

-- 8. COCKPIT API (1187)
CREATE credential_type:cockpit_api SET
    name = "cockpitApi", slug = "cockpit-api", is_active = true,
    identity = { display_name_i18n: i18n_key:credential_type_cockpit_api_name, description_i18n: i18n_key:credential_type_cockpit_api_description },
    presentation = { icon: icon:cockpit, color: "#FF6600", color_daisy: "warning", tooltip_i18n: i18n_key:credential_type_cockpit_api_tooltip, display_order: 1187 },
    auth_type = auth_type:api_key, provider = provider:cockpit,
    config = { oauth2: NONE, oauth1: NONE, required_fields: [{ name: "url", display_name: "URL", type: "string", is_secret: false, required: true }, { name: "accessToken", display_name: "Access Token", type: "string", is_secret: true, required: true }], metadata: { cms: true, headless_cms: true } },
    documentation = { url: url:cockpit_docs, use_cases_i18n: NONE };

-- 9. CONVERT API (1188)
CREATE credential_type:convert_api SET
    name = "convertApi", slug = "convert-api", is_active = true,
    identity = { display_name_i18n: i18n_key:credential_type_convert_api_name, description_i18n: i18n_key:credential_type_convert_api_description },
    presentation = { icon: icon:convert, color: "#00C4B3", color_daisy: "success", tooltip_i18n: i18n_key:credential_type_convert_api_tooltip, display_order: 1188 },
    auth_type = auth_type:api_key, provider = provider:convert,
    config = { oauth2: NONE, oauth1: NONE, required_fields: [{ name: "secret", display_name: "Secret", type: "string", is_secret: true, required: true }], metadata: { file_conversion: true, document_processing: true } },
    documentation = { url: url:convert_docs, use_cases_i18n: NONE };

-- 10. CONVERTKIT API (1189)
CREATE credential_type:convert_kit_api SET
    name = "convertKitApi", slug = "convert-kit-api", is_active = true,
    identity = { display_name_i18n: i18n_key:credential_type_convert_kit_api_name, description_i18n: i18n_key:credential_type_convert_kit_api_description },
    presentation = { icon: icon:convertkit, color: "#FB6970", color_daisy: "error", tooltip_i18n: i18n_key:credential_type_convert_kit_api_tooltip, display_order: 1189 },
    auth_type = auth_type:api_key, provider = provider:convertkit,
    config = { oauth2: NONE, oauth1: NONE, required_fields: [{ name: "apiSecret", display_name: "API Secret", type: "string", is_secret: true, required: true }], metadata: { email_marketing: true, creators: true, newsletters: true } },
    documentation = { url: url:convertkit_docs, use_cases_i18n: NONE };

-- 11. CORTEX API (1190)
CREATE credential_type:cortex_api SET
    name = "cortexApi", slug = "cortex-api", is_active = true,
    identity = { display_name_i18n: i18n_key:credential_type_cortex_api_name, description_i18n: i18n_key:credential_type_cortex_api_description },
    presentation = { icon: icon:cortex, color: "#4A90E2", color_daisy: "info", tooltip_i18n: i18n_key:credential_type_cortex_api_tooltip, display_order: 1190 },
    auth_type = auth_type:bearer_token, provider = provider:cortex,
    config = { oauth2: NONE, oauth1: NONE, required_fields: [{ name: "url", display_name: "URL", type: "string", is_secret: false, required: true }, { name: "apiKey", display_name: "API Key", type: "string", is_secret: true, required: true }], metadata: { security: true, threat_intelligence: true, incident_response: true } },
    documentation = { url: url:cortex_docs, use_cases_i18n: NONE };

-- =============================================================================================
-- ✅ Batch 24: 11 credentials créés (display_order: 1180-1190)
-- DevOps/CI-CD (1), Networking (3), Collaboration (1), Project Mgmt (2), CMS (1), Conversion (1), Email Mktg (1), Security (1)
-- =============================================================================================

