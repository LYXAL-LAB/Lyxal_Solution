-- Batch 9: 20 services Lyxal

-- Service 161: HighLevelV2
CREATE service:highlevelv2 SET
    identity = {
        name: "HighLevelV2",
        slug: "highlevelv2",
        display_name_i18n: i18n_key:service_highlevelv2_name,
        description_i18n: i18n_key:service_highlevelv2_desc,
        aliases: ["HighLevelV2"]
    },
    presentation = {
        icon: NONE,
        color: "#5C6AC4",
        display_order: 0,
        category_slug: "productivity",
        tooltip_i18n: NONE,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        version: {
            current: "1.0",
            is_default_version: true,
            supported_versions: ["1.0"]
        },
        capabilities: {
            is_trigger: false,
            is_polling: false,
            is_webhook: false,
            is_action: true,
            supports_batch: false
        },
        api: {
            base_url: NONE,
            version: NONE,
            protocol: "REST"
        },
        rate_limits: NONE
    },
    documentation = NONE,
    metadata = {
        tags: ["productivity"],
        popularity_score: NONE,
        last_updated_by: NONE,
        custom_data: NONE
    },
    provider_id: provider:highlevel,
    category_id: NONE,
    is_active: true;

-- Service 162: HomeAssistant
CREATE service:homeassistant SET
    identity = {
        name: "HomeAssistant",
        slug: "homeassistant",
        display_name_i18n: i18n_key:service_homeassistant_name,
        description_i18n: i18n_key:service_homeassistant_desc,
        aliases: ["HomeAssistant"]
    },
    presentation = {
        icon: NONE,
        color: "#5C6AC4",
        display_order: 0,
        category_slug: "productivity",
        tooltip_i18n: NONE,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        version: {
            current: "1.0",
            is_default_version: true,
            supported_versions: ["1.0"]
        },
        capabilities: {
            is_trigger: false,
            is_polling: false,
            is_webhook: false,
            is_action: true,
            supports_batch: false
        },
        api: {
            base_url: NONE,
            version: NONE,
            protocol: "REST"
        },
        rate_limits: NONE
    },
    documentation = NONE,
    metadata = {
        tags: ["productivity"],
        popularity_score: NONE,
        last_updated_by: NONE,
        custom_data: NONE
    },
    provider_id: provider:homeassistant,
    category_id: NONE,
    is_active: true;

-- Service 163: Html
CREATE service:html SET
    identity = {
        name: "Html",
        slug: "html",
        display_name_i18n: i18n_key:service_html_name,
        description_i18n: i18n_key:service_html_desc,
        aliases: ["Html"]
    },
    presentation = {
        icon: NONE,
        color: "#5C6AC4",
        display_order: 0,
        category_slug: "ai",
        tooltip_i18n: NONE,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        version: {
            current: "1.0",
            is_default_version: true,
            supported_versions: ["1.0"]
        },
        capabilities: {
            is_trigger: false,
            is_polling: false,
            is_webhook: false,
            is_action: true,
            supports_batch: false
        },
        api: {
            base_url: NONE,
            version: NONE,
            protocol: "REST"
        },
        rate_limits: NONE
    },
    documentation = NONE,
    metadata = {
        tags: ["ai"],
        popularity_score: NONE,
        last_updated_by: NONE,
        custom_data: NONE
    },
    provider_id: provider:html,
    category_id: NONE,
    is_active: true;

-- Service 164: HtmlExtract
CREATE service:htmlextract SET
    identity = {
        name: "HtmlExtract",
        slug: "htmlextract",
        display_name_i18n: i18n_key:service_htmlextract_name,
        description_i18n: i18n_key:service_htmlextract_desc,
        aliases: ["HtmlExtract"]
    },
    presentation = {
        icon: NONE,
        color: "#5C6AC4",
        display_order: 0,
        category_slug: "ai",
        tooltip_i18n: NONE,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        version: {
            current: "1.0",
            is_default_version: true,
            supported_versions: ["1.0"]
        },
        capabilities: {
            is_trigger: false,
            is_polling: false,
            is_webhook: false,
            is_action: true,
            supports_batch: false
        },
        api: {
            base_url: NONE,
            version: NONE,
            protocol: "REST"
        },
        rate_limits: NONE
    },
    documentation = NONE,
    metadata = {
        tags: ["ai"],
        popularity_score: NONE,
        last_updated_by: NONE,
        custom_data: NONE
    },
    provider_id: provider:htmlextract,
    category_id: NONE,
    is_active: true;

-- Service 165: HttpRequest
CREATE service:httprequest SET
    identity = {
        name: "HttpRequest",
        slug: "httprequest",
        display_name_i18n: i18n_key:service_httprequest_name,
        description_i18n: i18n_key:service_httprequest_desc,
        aliases: ["HttpRequest"]
    },
    presentation = {
        icon: NONE,
        color: "#5C6AC4",
        display_order: 0,
        category_slug: "productivity",
        tooltip_i18n: NONE,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        version: {
            current: "1.0",
            is_default_version: true,
            supported_versions: ["1.0"]
        },
        capabilities: {
            is_trigger: false,
            is_polling: false,
            is_webhook: false,
            is_action: true,
            supports_batch: false
        },
        api: {
            base_url: NONE,
            version: NONE,
            protocol: "REST"
        },
        rate_limits: NONE
    },
    documentation = NONE,
    metadata = {
        tags: ["productivity"],
        popularity_score: NONE,
        last_updated_by: NONE,
        custom_data: NONE
    },
    provider_id: provider:httprequest,
    category_id: NONE,
    is_active: true;

-- Service 166: HttpRequestV1
CREATE service:httprequestv1 SET
    identity = {
        name: "HttpRequestV1",
        slug: "httprequestv1",
        display_name_i18n: i18n_key:service_httprequestv1_name,
        description_i18n: i18n_key:service_httprequestv1_desc,
        aliases: ["HttpRequestV1"]
    },
    presentation = {
        icon: NONE,
        color: "#5C6AC4",
        display_order: 0,
        category_slug: "productivity",
        tooltip_i18n: NONE,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        version: {
            current: "1.0",
            is_default_version: true,
            supported_versions: ["1.0"]
        },
        capabilities: {
            is_trigger: false,
            is_polling: false,
            is_webhook: false,
            is_action: true,
            supports_batch: false
        },
        api: {
            base_url: NONE,
            version: NONE,
            protocol: "REST"
        },
        rate_limits: NONE
    },
    documentation = NONE,
    metadata = {
        tags: ["productivity"],
        popularity_score: NONE,
        last_updated_by: NONE,
        custom_data: NONE
    },
    provider_id: provider:httprequest,
    category_id: NONE,
    is_active: true;

-- Service 167: HttpRequestV2
CREATE service:httprequestv2 SET
    identity = {
        name: "HttpRequestV2",
        slug: "httprequestv2",
        display_name_i18n: i18n_key:service_httprequestv2_name,
        description_i18n: i18n_key:service_httprequestv2_desc,
        aliases: ["HttpRequestV2"]
    },
    presentation = {
        icon: NONE,
        color: "#5C6AC4",
        display_order: 0,
        category_slug: "productivity",
        tooltip_i18n: NONE,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        version: {
            current: "1.0",
            is_default_version: true,
            supported_versions: ["1.0"]
        },
        capabilities: {
            is_trigger: false,
            is_polling: false,
            is_webhook: false,
            is_action: true,
            supports_batch: false
        },
        api: {
            base_url: NONE,
            version: NONE,
            protocol: "REST"
        },
        rate_limits: NONE
    },
    documentation = NONE,
    metadata = {
        tags: ["productivity"],
        popularity_score: NONE,
        last_updated_by: NONE,
        custom_data: NONE
    },
    provider_id: provider:httprequest,
    category_id: NONE,
    is_active: true;

-- Service 168: HttpRequestV3
CREATE service:httprequestv3 SET
    identity = {
        name: "HttpRequestV3",
        slug: "httprequestv3",
        display_name_i18n: i18n_key:service_httprequestv3_name,
        description_i18n: i18n_key:service_httprequestv3_desc,
        aliases: ["HttpRequestV3"]
    },
    presentation = {
        icon: NONE,
        color: "#5C6AC4",
        display_order: 0,
        category_slug: "productivity",
        tooltip_i18n: NONE,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        version: {
            current: "1.0",
            is_default_version: true,
            supported_versions: ["1.0"]
        },
        capabilities: {
            is_trigger: false,
            is_polling: false,
            is_webhook: false,
            is_action: true,
            supports_batch: false
        },
        api: {
            base_url: NONE,
            version: NONE,
            protocol: "REST"
        },
        rate_limits: NONE
    },
    documentation = NONE,
    metadata = {
        tags: ["productivity"],
        popularity_score: NONE,
        last_updated_by: NONE,
        custom_data: NONE
    },
    provider_id: provider:httprequest,
    category_id: NONE,
    is_active: true;

-- Service 169: Hubspot
CREATE service:hubspot SET
    identity = {
        name: "Hubspot",
        slug: "hubspot",
        display_name_i18n: i18n_key:service_hubspot_name,
        description_i18n: i18n_key:service_hubspot_desc,
        aliases: ["Hubspot"]
    },
    presentation = {
        icon: NONE,
        color: "#5C6AC4",
        display_order: 0,
        category_slug: "productivity",
        tooltip_i18n: NONE,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        version: {
            current: "1.0",
            is_default_version: true,
            supported_versions: ["1.0"]
        },
        capabilities: {
            is_trigger: false,
            is_polling: false,
            is_webhook: false,
            is_action: true,
            supports_batch: false
        },
        api: {
            base_url: NONE,
            version: NONE,
            protocol: "REST"
        },
        rate_limits: NONE
    },
    documentation = NONE,
    metadata = {
        tags: ["productivity"],
        popularity_score: NONE,
        last_updated_by: NONE,
        custom_data: NONE
    },
    provider_id: provider:hubspot,
    category_id: NONE,
    is_active: true;

-- Service 170: HubspotV1
CREATE service:hubspotv1 SET
    identity = {
        name: "HubspotV1",
        slug: "hubspotv1",
        display_name_i18n: i18n_key:service_hubspotv1_name,
        description_i18n: i18n_key:service_hubspotv1_desc,
        aliases: ["HubspotV1"]
    },
    presentation = {
        icon: NONE,
        color: "#5C6AC4",
        display_order: 0,
        category_slug: "productivity",
        tooltip_i18n: NONE,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        version: {
            current: "1.0",
            is_default_version: true,
            supported_versions: ["1.0"]
        },
        capabilities: {
            is_trigger: false,
            is_polling: false,
            is_webhook: false,
            is_action: true,
            supports_batch: false
        },
        api: {
            base_url: NONE,
            version: NONE,
            protocol: "REST"
        },
        rate_limits: NONE
    },
    documentation = NONE,
    metadata = {
        tags: ["productivity"],
        popularity_score: NONE,
        last_updated_by: NONE,
        custom_data: NONE
    },
    provider_id: provider:hubspot,
    category_id: NONE,
    is_active: true;

-- Service 171: HubspotV2
CREATE service:hubspotv2 SET
    identity = {
        name: "HubspotV2",
        slug: "hubspotv2",
        display_name_i18n: i18n_key:service_hubspotv2_name,
        description_i18n: i18n_key:service_hubspotv2_desc,
        aliases: ["HubspotV2"]
    },
    presentation = {
        icon: NONE,
        color: "#5C6AC4",
        display_order: 0,
        category_slug: "productivity",
        tooltip_i18n: NONE,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        version: {
            current: "1.0",
            is_default_version: true,
            supported_versions: ["1.0"]
        },
        capabilities: {
            is_trigger: false,
            is_polling: false,
            is_webhook: false,
            is_action: true,
            supports_batch: false
        },
        api: {
            base_url: NONE,
            version: NONE,
            protocol: "REST"
        },
        rate_limits: NONE
    },
    documentation = NONE,
    metadata = {
        tags: ["productivity"],
        popularity_score: NONE,
        last_updated_by: NONE,
        custom_data: NONE
    },
    provider_id: provider:hubspot,
    category_id: NONE,
    is_active: true;

-- Service 172: HumanticAi
CREATE service:humanticai SET
    identity = {
        name: "HumanticAi",
        slug: "humanticai",
        display_name_i18n: i18n_key:service_humanticai_name,
        description_i18n: i18n_key:service_humanticai_desc,
        aliases: ["HumanticAi"]
    },
    presentation = {
        icon: NONE,
        color: "#5C6AC4",
        display_order: 0,
        category_slug: "ai",
        tooltip_i18n: NONE,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        version: {
            current: "1.0",
            is_default_version: true,
            supported_versions: ["1.0"]
        },
        capabilities: {
            is_trigger: false,
            is_polling: false,
            is_webhook: false,
            is_action: true,
            supports_batch: false
        },
        api: {
            base_url: NONE,
            version: NONE,
            protocol: "REST"
        },
        rate_limits: NONE
    },
    documentation = NONE,
    metadata = {
        tags: ["ai"],
        popularity_score: NONE,
        last_updated_by: NONE,
        custom_data: NONE
    },
    provider_id: provider:humanticai,
    category_id: NONE,
    is_active: true;

-- Service 173: Hunter
CREATE service:hunter SET
    identity = {
        name: "Hunter",
        slug: "hunter",
        display_name_i18n: i18n_key:service_hunter_name,
        description_i18n: i18n_key:service_hunter_desc,
        aliases: ["Hunter"]
    },
    presentation = {
        icon: NONE,
        color: "#5C6AC4",
        display_order: 0,
        category_slug: "productivity",
        tooltip_i18n: NONE,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        version: {
            current: "1.0",
            is_default_version: true,
            supported_versions: ["1.0"]
        },
        capabilities: {
            is_trigger: false,
            is_polling: false,
            is_webhook: false,
            is_action: true,
            supports_batch: false
        },
        api: {
            base_url: NONE,
            version: NONE,
            protocol: "REST"
        },
        rate_limits: NONE
    },
    documentation = NONE,
    metadata = {
        tags: ["productivity"],
        popularity_score: NONE,
        last_updated_by: NONE,
        custom_data: NONE
    },
    provider_id: provider:hunter,
    category_id: NONE,
    is_active: true;

-- Service 174: ICalendar
CREATE service:icalendar SET
    identity = {
        name: "ICalendar",
        slug: "icalendar",
        display_name_i18n: i18n_key:service_icalendar_name,
        description_i18n: i18n_key:service_icalendar_desc,
        aliases: ["ICalendar"]
    },
    presentation = {
        icon: NONE,
        color: "#5C6AC4",
        display_order: 0,
        category_slug: "productivity",
        tooltip_i18n: NONE,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        version: {
            current: "1.0",
            is_default_version: true,
            supported_versions: ["1.0"]
        },
        capabilities: {
            is_trigger: false,
            is_polling: false,
            is_webhook: false,
            is_action: true,
            supports_batch: false
        },
        api: {
            base_url: NONE,
            version: NONE,
            protocol: "REST"
        },
        rate_limits: NONE
    },
    documentation = NONE,
    metadata = {
        tags: ["productivity"],
        popularity_score: NONE,
        last_updated_by: NONE,
        custom_data: NONE
    },
    provider_id: provider:icalendar,
    category_id: NONE,
    is_active: true;

-- Service 175: If
CREATE service:if SET
    identity = {
        name: "If",
        slug: "if",
        display_name_i18n: i18n_key:service_if_name,
        description_i18n: i18n_key:service_if_desc,
        aliases: ["If"]
    },
    presentation = {
        icon: NONE,
        color: "#5C6AC4",
        display_order: 0,
        category_slug: "productivity",
        tooltip_i18n: NONE,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        version: {
            current: "1.0",
            is_default_version: true,
            supported_versions: ["1.0"]
        },
        capabilities: {
            is_trigger: false,
            is_polling: false,
            is_webhook: false,
            is_action: true,
            supports_batch: false
        },
        api: {
            base_url: NONE,
            version: NONE,
            protocol: "REST"
        },
        rate_limits: NONE
    },
    documentation = NONE,
    metadata = {
        tags: ["productivity"],
        popularity_score: NONE,
        last_updated_by: NONE,
        custom_data: NONE
    },
    provider_id: provider:if,
    category_id: NONE,
    is_active: true;

-- Service 176: IfV1
CREATE service:ifv1 SET
    identity = {
        name: "IfV1",
        slug: "ifv1",
        display_name_i18n: i18n_key:service_ifv1_name,
        description_i18n: i18n_key:service_ifv1_desc,
        aliases: ["IfV1"]
    },
    presentation = {
        icon: NONE,
        color: "#5C6AC4",
        display_order: 0,
        category_slug: "productivity",
        tooltip_i18n: NONE,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        version: {
            current: "1.0",
            is_default_version: true,
            supported_versions: ["1.0"]
        },
        capabilities: {
            is_trigger: false,
            is_polling: false,
            is_webhook: false,
            is_action: true,
            supports_batch: false
        },
        api: {
            base_url: NONE,
            version: NONE,
            protocol: "REST"
        },
        rate_limits: NONE
    },
    documentation = NONE,
    metadata = {
        tags: ["productivity"],
        popularity_score: NONE,
        last_updated_by: NONE,
        custom_data: NONE
    },
    provider_id: provider:if,
    category_id: NONE,
    is_active: true;

-- Service 177: IfV2
CREATE service:ifv2 SET
    identity = {
        name: "IfV2",
        slug: "ifv2",
        display_name_i18n: i18n_key:service_ifv2_name,
        description_i18n: i18n_key:service_ifv2_desc,
        aliases: ["IfV2"]
    },
    presentation = {
        icon: NONE,
        color: "#5C6AC4",
        display_order: 0,
        category_slug: "productivity",
        tooltip_i18n: NONE,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        version: {
            current: "1.0",
            is_default_version: true,
            supported_versions: ["1.0"]
        },
        capabilities: {
            is_trigger: false,
            is_polling: false,
            is_webhook: false,
            is_action: true,
            supports_batch: false
        },
        api: {
            base_url: NONE,
            version: NONE,
            protocol: "REST"
        },
        rate_limits: NONE
    },
    documentation = NONE,
    metadata = {
        tags: ["productivity"],
        popularity_score: NONE,
        last_updated_by: NONE,
        custom_data: NONE
    },
    provider_id: provider:if,
    category_id: NONE,
    is_active: true;

-- Service 178: Intercom
CREATE service:intercom SET
    identity = {
        name: "Intercom",
        slug: "intercom",
        display_name_i18n: i18n_key:service_intercom_name,
        description_i18n: i18n_key:service_intercom_desc,
        aliases: ["Intercom"]
    },
    presentation = {
        icon: NONE,
        color: "#5C6AC4",
        display_order: 0,
        category_slug: "productivity",
        tooltip_i18n: NONE,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        version: {
            current: "1.0",
            is_default_version: true,
            supported_versions: ["1.0"]
        },
        capabilities: {
            is_trigger: false,
            is_polling: false,
            is_webhook: false,
            is_action: true,
            supports_batch: false
        },
        api: {
            base_url: NONE,
            version: NONE,
            protocol: "REST"
        },
        rate_limits: NONE
    },
    documentation = NONE,
    metadata = {
        tags: ["productivity"],
        popularity_score: NONE,
        last_updated_by: NONE,
        custom_data: NONE
    },
    provider_id: provider:intercom,
    category_id: NONE,
    is_active: true;

-- Service 179: Interval
CREATE service:interval SET
    identity = {
        name: "Interval",
        slug: "interval",
        display_name_i18n: i18n_key:service_interval_name,
        description_i18n: i18n_key:service_interval_desc,
        aliases: ["Interval"]
    },
    presentation = {
        icon: NONE,
        color: "#5C6AC4",
        display_order: 0,
        category_slug: "productivity",
        tooltip_i18n: NONE,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        version: {
            current: "1.0",
            is_default_version: true,
            supported_versions: ["1.0"]
        },
        capabilities: {
            is_trigger: false,
            is_polling: false,
            is_webhook: false,
            is_action: true,
            supports_batch: false
        },
        api: {
            base_url: NONE,
            version: NONE,
            protocol: "REST"
        },
        rate_limits: NONE
    },
    documentation = NONE,
    metadata = {
        tags: ["productivity"],
        popularity_score: NONE,
        last_updated_by: NONE,
        custom_data: NONE
    },
    provider_id: provider:interval,
    category_id: NONE,
    is_active: true;

-- Service 180: InvoiceNinja
CREATE service:invoiceninja SET
    identity = {
        name: "InvoiceNinja",
        slug: "invoiceninja",
        display_name_i18n: i18n_key:service_invoiceninja_name,
        description_i18n: i18n_key:service_invoiceninja_desc,
        aliases: ["InvoiceNinja"]
    },
    presentation = {
        icon: NONE,
        color: "#5C6AC4",
        display_order: 0,
        category_slug: "productivity",
        tooltip_i18n: NONE,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        version: {
            current: "1.0",
            is_default_version: true,
            supported_versions: ["1.0"]
        },
        capabilities: {
            is_trigger: false,
            is_polling: false,
            is_webhook: false,
            is_action: true,
            supports_batch: false
        },
        api: {
            base_url: NONE,
            version: NONE,
            protocol: "REST"
        },
        rate_limits: NONE
    },
    documentation = NONE,
    metadata = {
        tags: ["productivity"],
        popularity_score: NONE,
        last_updated_by: NONE,
        custom_data: NONE
    },
    provider_id: provider:invoiceninja,
    category_id: NONE,
    is_active: true;

