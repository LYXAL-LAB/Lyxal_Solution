-- Batch 21: 19 services Lyxal

-- Service 401: Wait
CREATE service:wait SET
    identity = {
        name: "Wait",
        slug: "wait",
        display_name_i18n: i18n_key:service_wait_name,
        description_i18n: i18n_key:service_wait_desc,
        aliases: ["Wait"]
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
    provider_id: provider:wait,
    category_id: NONE,
    is_active: true;

-- Service 402: Webflow
CREATE service:webflow SET
    identity = {
        name: "Webflow",
        slug: "webflow",
        display_name_i18n: i18n_key:service_webflow_name,
        description_i18n: i18n_key:service_webflow_desc,
        aliases: ["Webflow"]
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
    provider_id: provider:webflow,
    category_id: NONE,
    is_active: true;

-- Service 403: WebflowV1
CREATE service:webflowv1 SET
    identity = {
        name: "WebflowV1",
        slug: "webflowv1",
        display_name_i18n: i18n_key:service_webflowv1_name,
        description_i18n: i18n_key:service_webflowv1_desc,
        aliases: ["WebflowV1"]
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
    provider_id: provider:webflow,
    category_id: NONE,
    is_active: true;

-- Service 404: WebflowV2
CREATE service:webflowv2 SET
    identity = {
        name: "WebflowV2",
        slug: "webflowv2",
        display_name_i18n: i18n_key:service_webflowv2_name,
        description_i18n: i18n_key:service_webflowv2_desc,
        aliases: ["WebflowV2"]
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
    provider_id: provider:webflow,
    category_id: NONE,
    is_active: true;

-- Service 405: Webhook
CREATE service:webhook SET
    identity = {
        name: "Webhook",
        slug: "webhook",
        display_name_i18n: i18n_key:service_webhook_name,
        description_i18n: i18n_key:service_webhook_desc,
        aliases: ["Webhook"]
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
    provider_id: provider:webhook,
    category_id: NONE,
    is_active: true;

-- Service 406: Wekan
CREATE service:wekan SET
    identity = {
        name: "Wekan",
        slug: "wekan",
        display_name_i18n: i18n_key:service_wekan_name,
        description_i18n: i18n_key:service_wekan_desc,
        aliases: ["Wekan"]
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
    provider_id: provider:wekan,
    category_id: NONE,
    is_active: true;

-- Service 407: WhatsApp
CREATE service:whatsapp SET
    identity = {
        name: "WhatsApp",
        slug: "whatsapp",
        display_name_i18n: i18n_key:service_whatsapp_name,
        description_i18n: i18n_key:service_whatsapp_desc,
        aliases: ["WhatsApp"]
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
    provider_id: provider:whatsapp,
    category_id: NONE,
    is_active: true;

-- Service 408: Wise
CREATE service:wise SET
    identity = {
        name: "Wise",
        slug: "wise",
        display_name_i18n: i18n_key:service_wise_name,
        description_i18n: i18n_key:service_wise_desc,
        aliases: ["Wise"]
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
    provider_id: provider:wise,
    category_id: NONE,
    is_active: true;

-- Service 409: WooCommerce
CREATE service:woocommerce SET
    identity = {
        name: "WooCommerce",
        slug: "woocommerce",
        display_name_i18n: i18n_key:service_woocommerce_name,
        description_i18n: i18n_key:service_woocommerce_desc,
        aliases: ["WooCommerce"]
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
    provider_id: provider:woocommerce,
    category_id: NONE,
    is_active: true;

-- Service 410: Wordpress
CREATE service:wordpress SET
    identity = {
        name: "Wordpress",
        slug: "wordpress",
        display_name_i18n: i18n_key:service_wordpress_name,
        description_i18n: i18n_key:service_wordpress_desc,
        aliases: ["Wordpress"]
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
    provider_id: provider:wordpress,
    category_id: NONE,
    is_active: true;

-- Service 411: WriteBinaryFile
CREATE service:writebinaryfile SET
    identity = {
        name: "WriteBinaryFile",
        slug: "writebinaryfile",
        display_name_i18n: i18n_key:service_writebinaryfile_name,
        description_i18n: i18n_key:service_writebinaryfile_desc,
        aliases: ["WriteBinaryFile"]
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
    provider_id: provider:writebinaryfile,
    category_id: NONE,
    is_active: true;

-- Service 412: Xero
CREATE service:xero SET
    identity = {
        name: "Xero",
        slug: "xero",
        display_name_i18n: i18n_key:service_xero_name,
        description_i18n: i18n_key:service_xero_desc,
        aliases: ["Xero"]
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
    provider_id: provider:xero,
    category_id: NONE,
    is_active: true;

-- Service 413: Xml
CREATE service:xml SET
    identity = {
        name: "Xml",
        slug: "xml",
        display_name_i18n: i18n_key:service_xml_name,
        description_i18n: i18n_key:service_xml_desc,
        aliases: ["Xml"]
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
    provider_id: provider:xml,
    category_id: NONE,
    is_active: true;

-- Service 414: Yourls
CREATE service:yourls SET
    identity = {
        name: "Yourls",
        slug: "yourls",
        display_name_i18n: i18n_key:service_yourls_name,
        description_i18n: i18n_key:service_yourls_desc,
        aliases: ["Yourls"]
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
    provider_id: provider:yourls,
    category_id: NONE,
    is_active: true;

-- Service 415: Zammad
CREATE service:zammad SET
    identity = {
        name: "Zammad",
        slug: "zammad",
        display_name_i18n: i18n_key:service_zammad_name,
        description_i18n: i18n_key:service_zammad_desc,
        aliases: ["Zammad"]
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
    provider_id: provider:zammad,
    category_id: NONE,
    is_active: true;

-- Service 416: Zendesk
CREATE service:zendesk SET
    identity = {
        name: "Zendesk",
        slug: "zendesk",
        display_name_i18n: i18n_key:service_zendesk_name,
        description_i18n: i18n_key:service_zendesk_desc,
        aliases: ["Zendesk"]
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
    provider_id: provider:zendesk,
    category_id: NONE,
    is_active: true;

-- Service 417: ZohoCrm
CREATE service:zohocrm SET
    identity = {
        name: "ZohoCrm",
        slug: "zohocrm",
        display_name_i18n: i18n_key:service_zohocrm_name,
        description_i18n: i18n_key:service_zohocrm_desc,
        aliases: ["ZohoCrm"]
    },
    presentation = {
        icon: NONE,
        color: "#5C6AC4",
        display_order: 0,
        category_slug: "crm",
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
        tags: ["crm"],
        popularity_score: NONE,
        last_updated_by: NONE,
        custom_data: NONE
    },
    provider_id: provider:zoho,
    category_id: NONE,
    is_active: true;

-- Service 418: Zoom
CREATE service:zoom SET
    identity = {
        name: "Zoom",
        slug: "zoom",
        display_name_i18n: i18n_key:service_zoom_name,
        description_i18n: i18n_key:service_zoom_desc,
        aliases: ["Zoom"]
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
    provider_id: provider:zoom,
    category_id: NONE,
    is_active: true;

-- Service 419: Zulip
CREATE service:zulip SET
    identity = {
        name: "Zulip",
        slug: "zulip",
        display_name_i18n: i18n_key:service_zulip_name,
        description_i18n: i18n_key:service_zulip_desc,
        aliases: ["Zulip"]
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
    provider_id: provider:zulip,
    category_id: NONE,
    is_active: true;

