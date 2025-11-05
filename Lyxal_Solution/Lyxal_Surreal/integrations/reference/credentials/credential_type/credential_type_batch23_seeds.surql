-- =============================================================================================
-- | Fichier : credential_type_batch23_seeds.surql (SEED DATA)
-- | Batch 23 : Marketing, IoT, AI, Security & Email APIs (11 credentials)
-- =============================================================================================

-- 1. HIGH LEVEL API (1160)
CREATE credential_type:high_level_api SET
    name = "highLevelApi", slug = "high-level-api", is_active = true,
    identity = { display_name_i18n: i18n_key:credential_type_high_level_api_name, description_i18n: i18n_key:credential_type_high_level_api_description }, presentation = { icon: icon:high_level_api, color_type: theme_color_type:neutral, tooltip_i18n: i18n_key:credential_type_high_level_api_tooltip, display_order: 1160 },
    auth_type = auth_type:bearer_token, provider = provider:highlevel,
    config = { oauth2: NONE, oauth1: NONE, required_fields: [{ name: "apiKey", display_name: "API Key", type: "string", is_secret: true, required: true }], metadata: { marketing_automation: true, crm: true, agencies: true } },
    documentation = { url: url:highlevel_docs, use_cases_i18n: NONE };

-- 2. HIGH LEVEL OAUTH2 API (1161)
CREATE credential_type:high_level_oauth2_api SET
    name = "highLevelOAuth2Api", slug = "high-level-oauth2-api", is_active = true,
    identity = { display_name_i18n: i18n_key:credential_type_high_level_oauth2_api_name, description_i18n: i18n_key:credential_type_high_level_oauth2_api_description }, presentation = { icon: icon:high_level_oauth2_api, color_type: theme_color_type:neutral, tooltip_i18n: i18n_key:credential_type_high_level_oauth2_api_tooltip, display_order: 1161 },
    auth_type = auth_type:oauth2, provider = provider:highlevel,
    config = { oauth2: { grant_type: "authorization_code", auth_url: "https://marketplace.gohighlevel.com/oauth/chooselocation", access_token_url: "https://services.leadconnectorhq.com/oauth/token", scope: "", authentication: "body" }, oauth1: NONE, required_fields: [], metadata: { oauth_recommended: true } },
    documentation = { url: url:highlevel_oauth2_docs, use_cases_i18n: NONE };

-- 3. HOME ASSISTANT API (1162)
CREATE credential_type:home_assistant_api SET
    name = "homeAssistantApi", slug = "home-assistant-api", is_active = true,
    identity = { display_name_i18n: i18n_key:credential_type_home_assistant_api_name, description_i18n: i18n_key:credential_type_home_assistant_api_description }, presentation = { icon: icon:home_assistant_api, color_type: theme_color_type:neutral, tooltip_i18n: i18n_key:credential_type_home_assistant_api_tooltip, display_order: 1162 },
    auth_type = auth_type:bearer_token, provider = provider:homeassistant,
    config = { oauth2: NONE, oauth1: NONE, required_fields: [{ name: "host", display_name: "Host", type: "string", is_secret: false, required: true }, { name: "accessToken", display_name: "Access Token", type: "string", is_secret: true, required: true }], metadata: { iot: true, home_automation: true, open_source: true } },
    documentation = { url: url:homeassistant_docs, use_cases_i18n: NONE };

-- 4. HUMANTIC AI API (1163)
CREATE credential_type:humantic_ai_api SET
    name = "humanticAiApi", slug = "humantic-ai-api", is_active = true,
    identity = { display_name_i18n: i18n_key:credential_type_humantic_ai_api_name, description_i18n: i18n_key:credential_type_humantic_ai_api_description }, presentation = { icon: icon:humantic_ai_api, color_type: theme_color_type:neutral, tooltip_i18n: i18n_key:credential_type_humantic_ai_api_tooltip, display_order: 1163 },
    auth_type = auth_type:api_key, provider = provider:humantic,
    config = { oauth2: NONE, oauth1: NONE, required_fields: [{ name: "apiKey", display_name: "API Key", type: "string", is_secret: true, required: true }], metadata: { ai: true, personality_insights: true, sales_intelligence: true } },
    documentation = { url: url:humantic_docs, use_cases_i18n: NONE };

-- 5. HYBRID ANALYSIS API (1164)
CREATE credential_type:hybrid_analysis_api SET
    name = "hybridAnalysisApi", slug = "hybrid-analysis-api", is_active = true,
    identity = { display_name_i18n: i18n_key:credential_type_hybrid_analysis_api_name, description_i18n: i18n_key:credential_type_hybrid_analysis_api_description }, presentation = { icon: icon:hybrid_analysis_api, color_type: theme_color_type:neutral, tooltip_i18n: i18n_key:credential_type_hybrid_analysis_api_tooltip, display_order: 1164 },
    auth_type = auth_type:api_key, provider = provider:hybridanalysis,
    config = { oauth2: NONE, oauth1: NONE, required_fields: [{ name: "apiKey", display_name: "API Key", type: "string", is_secret: true, required: true }], metadata: { malware_analysis: true, threat_intelligence: true, security: true } },
    documentation = { url: url:hybridanalysis_docs, use_cases_i18n: NONE };

-- 6. IMAP (1165)
CREATE credential_type:imap SET
    name = "imap", slug = "imap", is_active = true,
    identity = { display_name_i18n: i18n_key:credential_type_imap_name, description_i18n: i18n_key:credential_type_imap_description }, presentation = { icon: icon:imap, color_type: theme_color_type:neutral, tooltip_i18n: i18n_key:credential_type_imap_tooltip, display_order: 1165 },
    auth_type = auth_type:basic, provider = provider:email,
    config = { oauth2: NONE, oauth1: NONE, required_fields: [{ name: "host", display_name: "Host", type: "string", is_secret: false, required: true }, { name: "port", display_name: "Port", type: "number", is_secret: false, required: true, default: 993 }, { name: "user", display_name: "User", type: "string", is_secret: false, required: true }, { name: "password", display_name: "Password", type: "string", is_secret: true, required: true }], metadata: { email: true, protocol: true, very_popular: true } },
    documentation = { url: url:imap_docs, use_cases_i18n: NONE };

-- 7. IMPERVA WAF API (1166)
CREATE credential_type:imperva_waf_api SET
    name = "impervaWafApi", slug = "imperva-waf-api", is_active = true,
    identity = { display_name_i18n: i18n_key:credential_type_imperva_waf_api_name, description_i18n: i18n_key:credential_type_imperva_waf_api_description }, presentation = { icon: icon:imperva_waf_api, color_type: theme_color_type:neutral, tooltip_i18n: i18n_key:credential_type_imperva_waf_api_tooltip, display_order: 1166 },
    auth_type = auth_type:api_key, provider = provider:imperva,
    config = { oauth2: NONE, oauth1: NONE, required_fields: [{ name: "apiId", display_name: "API ID", type: "string", is_secret: false, required: true }, { name: "apiKey", display_name: "API Key", type: "string", is_secret: true, required: true }], metadata: { waf: true, web_security: true, ddos_protection: true } },
    documentation = { url: url:imperva_docs, use_cases_i18n: NONE };

-- 8. ITERABLE API (1167)
CREATE credential_type:iterable_api SET
    name = "iterableApi", slug = "iterable-api", is_active = true,
    identity = { display_name_i18n: i18n_key:credential_type_iterable_api_name, description_i18n: i18n_key:credential_type_iterable_api_description }, presentation = { icon: icon:iterable_api, color_type: theme_color_type:neutral, tooltip_i18n: i18n_key:credential_type_iterable_api_tooltip, display_order: 1167 },
    auth_type = auth_type:api_key, provider = provider:iterable,
    config = { oauth2: NONE, oauth1: NONE, required_fields: [{ name: "apiKey", display_name: "API Key", type: "string", is_secret: true, required: true }], metadata: { marketing_automation: true, email_marketing: true, customer_engagement: true } },
    documentation = { url: url:iterable_docs, use_cases_i18n: NONE };

-- 9. JINA AI API (1168)
CREATE credential_type:jina_ai_api SET
    name = "jinaAiApi", slug = "jina-ai-api", is_active = true,
    identity = { display_name_i18n: i18n_key:credential_type_jina_ai_api_name, description_i18n: i18n_key:credential_type_jina_ai_api_description }, presentation = { icon: icon:jina_ai_api, color_type: theme_color_type:neutral, tooltip_i18n: i18n_key:credential_type_jina_ai_api_tooltip, display_order: 1168 },
    auth_type = auth_type:bearer_token, provider = provider:jina,
    config = { oauth2: NONE, oauth1: NONE, required_fields: [{ name: "apiKey", display_name: "API Key", type: "string", is_secret: true, required: true }], metadata: { ai: true, neural_search: true, embeddings: true } },
    documentation = { url: url:jina_docs, use_cases_i18n: NONE };

-- 10. JWT AUTH (1169)
CREATE credential_type:jwt_auth SET
    name = "jwtAuth", slug = "jwt-auth", is_active = true,
    identity = { display_name_i18n: i18n_key:credential_type_jwt_auth_name, description_i18n: i18n_key:credential_type_jwt_auth_description }, presentation = { icon: icon:jwt_auth, color_type: theme_color_type:neutral, tooltip_i18n: i18n_key:credential_type_jwt_auth_tooltip, display_order: 1169 },
    auth_type = auth_type:custom, provider = provider:generic,
    config = { oauth2: NONE, oauth1: NONE, required_fields: [{ name: "token", display_name: "JWT Token", type: "string", is_secret: true, required: true }], metadata: { authentication: true, token_based: true, very_popular: true } },
    documentation = { url: url:jwt_docs, use_cases_i18n: NONE };

-- 11. KEAP OAUTH2 API (1170)
CREATE credential_type:keap_oauth2_api SET
    name = "keapOAuth2Api", slug = "keap-oauth2-api", is_active = true,
    identity = { display_name_i18n: i18n_key:credential_type_keap_oauth2_api_name, description_i18n: i18n_key:credential_type_keap_oauth2_api_description }, presentation = { icon: icon:keap_oauth2_api, color_type: theme_color_type:neutral, tooltip_i18n: i18n_key:credential_type_keap_oauth2_api_tooltip, display_order: 1170 },
    auth_type = auth_type:oauth2, provider = provider:keap,
    config = { oauth2: { grant_type: "authorization_code", auth_url: "https://accounts.infusionsoft.com/app/oauth/authorize", access_token_url: "https://api.infusionsoft.com/token", scope: "full", authentication: "body" }, oauth1: NONE, required_fields: [], metadata: { crm: true, marketing_automation: true, sales: true } },
    documentation = { url: url:keap_docs, use_cases_i18n: NONE };

-- =============================================================================================
-- ✅ Batch 23: 11 credentials créés (display_order: 1160-1170)
-- Marketing/CRM (3), IoT (1), AI (2), Security/Malware (2), Email/Protocol (1), Auth (1), Sales (1)
-- =============================================================================================

