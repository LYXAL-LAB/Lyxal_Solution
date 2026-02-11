-- Batch 6: 20 services Lyxal

-- Service 101: Filter
CREATE service:filter SET
    identity = {
        name: "Filter",
        slug: "filter",
        display_name_i18n: i18n_key:service_filter_name,
        description_i18n: i18n_key:service_filter_desc,
        aliases: ["Filter"]
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
    provider_id: provider:filter,
    category_id: NONE,
    is_active: true;

-- Service 102: FilterV1
CREATE service:filterv1 SET
    identity = {
        name: "FilterV1",
        slug: "filterv1",
        display_name_i18n: i18n_key:service_filterv1_name,
        description_i18n: i18n_key:service_filterv1_desc,
        aliases: ["FilterV1"]
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
    provider_id: provider:filter,
    category_id: NONE,
    is_active: true;

-- Service 103: FilterV2
CREATE service:filterv2 SET
    identity = {
        name: "FilterV2",
        slug: "filterv2",
        display_name_i18n: i18n_key:service_filterv2_name,
        description_i18n: i18n_key:service_filterv2_desc,
        aliases: ["FilterV2"]
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
    provider_id: provider:filter,
    category_id: NONE,
    is_active: true;

-- Service 104: Flow
CREATE service:flow SET
    identity = {
        name: "Flow",
        slug: "flow",
        display_name_i18n: i18n_key:service_flow_name,
        description_i18n: i18n_key:service_flow_desc,
        aliases: ["Flow"]
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
    provider_id: provider:flow,
    category_id: NONE,
    is_active: true;

-- Service 105: Form
CREATE service:form SET
    identity = {
        name: "Form",
        slug: "form",
        display_name_i18n: i18n_key:service_form_name,
        description_i18n: i18n_key:service_form_desc,
        aliases: ["Form"]
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
    provider_id: provider:form,
    category_id: NONE,
    is_active: true;

-- Service 106: Freshdesk
CREATE service:freshdesk SET
    identity = {
        name: "Freshdesk",
        slug: "freshdesk",
        display_name_i18n: i18n_key:service_freshdesk_name,
        description_i18n: i18n_key:service_freshdesk_desc,
        aliases: ["Freshdesk"]
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
    provider_id: provider:freshdesk,
    category_id: NONE,
    is_active: true;

-- Service 107: Freshservice
CREATE service:freshservice SET
    identity = {
        name: "Freshservice",
        slug: "freshservice",
        display_name_i18n: i18n_key:service_freshservice_name,
        description_i18n: i18n_key:service_freshservice_desc,
        aliases: ["Freshservice"]
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
    provider_id: provider:freshservice,
    category_id: NONE,
    is_active: true;

-- Service 108: FreshworksCrm
CREATE service:freshworkscrm SET
    identity = {
        name: "FreshworksCrm",
        slug: "freshworkscrm",
        display_name_i18n: i18n_key:service_freshworkscrm_name,
        description_i18n: i18n_key:service_freshworkscrm_desc,
        aliases: ["FreshworksCrm"]
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
    provider_id: provider:freshworkscrm,
    category_id: NONE,
    is_active: true;

-- Service 109: Ftp
CREATE service:ftp SET
    identity = {
        name: "Ftp",
        slug: "ftp",
        display_name_i18n: i18n_key:service_ftp_name,
        description_i18n: i18n_key:service_ftp_desc,
        aliases: ["Ftp"]
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
    provider_id: provider:ftp,
    category_id: NONE,
    is_active: true;

-- Service 110: Function
CREATE service:function SET
    identity = {
        name: "Function",
        slug: "function",
        display_name_i18n: i18n_key:service_function_name,
        description_i18n: i18n_key:service_function_desc,
        aliases: ["Function"]
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
    provider_id: provider:function,
    category_id: NONE,
    is_active: true;

-- Service 111: FunctionItem
CREATE service:functionitem SET
    identity = {
        name: "FunctionItem",
        slug: "functionitem",
        display_name_i18n: i18n_key:service_functionitem_name,
        description_i18n: i18n_key:service_functionitem_desc,
        aliases: ["FunctionItem"]
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
    provider_id: provider:functionitem,
    category_id: NONE,
    is_active: true;

-- Service 112: GetResponse
CREATE service:getresponse SET
    identity = {
        name: "GetResponse",
        slug: "getresponse",
        display_name_i18n: i18n_key:service_getresponse_name,
        description_i18n: i18n_key:service_getresponse_desc,
        aliases: ["GetResponse"]
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
    provider_id: provider:getresponse,
    category_id: NONE,
    is_active: true;

-- Service 113: Ghost
CREATE service:ghost SET
    identity = {
        name: "Ghost",
        slug: "ghost",
        display_name_i18n: i18n_key:service_ghost_name,
        description_i18n: i18n_key:service_ghost_desc,
        aliases: ["Ghost"]
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
    provider_id: provider:ghost,
    category_id: NONE,
    is_active: true;

-- Service 114: Git
CREATE service:git SET
    identity = {
        name: "Git",
        slug: "git",
        display_name_i18n: i18n_key:service_git_name,
        description_i18n: i18n_key:service_git_desc,
        aliases: ["Git"]
    },
    presentation = {
        icon: NONE,
        color: "#5C6AC4",
        display_order: 0,
        category_slug: "development",
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
        tags: ["development"],
        popularity_score: NONE,
        last_updated_by: NONE,
        custom_data: NONE
    },
    provider_id: provider:git,
    category_id: NONE,
    is_active: true;

-- Service 115: Github
CREATE service:github SET
    identity = {
        name: "Github",
        slug: "github",
        display_name_i18n: i18n_key:service_github_name,
        description_i18n: i18n_key:service_github_desc,
        aliases: ["Github"]
    },
    presentation = {
        icon: NONE,
        color: "#181717",
        display_order: 0,
        category_slug: "development",
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
        tags: ["development"],
        popularity_score: NONE,
        last_updated_by: NONE,
        custom_data: NONE
    },
    provider_id: provider:github,
    category_id: NONE,
    is_active: true;

-- Service 116: Gitlab
CREATE service:gitlab SET
    identity = {
        name: "Gitlab",
        slug: "gitlab",
        display_name_i18n: i18n_key:service_gitlab_name,
        description_i18n: i18n_key:service_gitlab_desc,
        aliases: ["Gitlab"]
    },
    presentation = {
        icon: NONE,
        color: "#5C6AC4",
        display_order: 0,
        category_slug: "development",
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
        tags: ["development"],
        popularity_score: NONE,
        last_updated_by: NONE,
        custom_data: NONE
    },
    provider_id: provider:gitlab,
    category_id: NONE,
    is_active: true;

-- Service 117: Gong
CREATE service:gong SET
    identity = {
        name: "Gong",
        slug: "gong",
        display_name_i18n: i18n_key:service_gong_name,
        description_i18n: i18n_key:service_gong_desc,
        aliases: ["Gong"]
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
    provider_id: provider:gong,
    category_id: NONE,
    is_active: true;

-- Service 118: GoogleAds
CREATE service:googleads SET
    identity = {
        name: "GoogleAds",
        slug: "googleads",
        display_name_i18n: i18n_key:service_googleads_name,
        description_i18n: i18n_key:service_googleads_desc,
        aliases: ["GoogleAds"]
    },
    presentation = {
        icon: NONE,
        color: "#4285F4",
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
    provider_id: provider:google,
    category_id: NONE,
    is_active: true;

-- Service 119: GoogleAnalytics
CREATE service:googleanalytics SET
    identity = {
        name: "GoogleAnalytics",
        slug: "googleanalytics",
        display_name_i18n: i18n_key:service_googleanalytics_name,
        description_i18n: i18n_key:service_googleanalytics_desc,
        aliases: ["GoogleAnalytics"]
    },
    presentation = {
        icon: NONE,
        color: "#4285F4",
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
    provider_id: provider:google,
    category_id: NONE,
    is_active: true;

-- Service 120: GoogleAnalyticsV1
CREATE service:googleanalyticsv1 SET
    identity = {
        name: "GoogleAnalyticsV1",
        slug: "googleanalyticsv1",
        display_name_i18n: i18n_key:service_googleanalyticsv1_name,
        description_i18n: i18n_key:service_googleanalyticsv1_desc,
        aliases: ["GoogleAnalyticsV1"]
    },
    presentation = {
        icon: NONE,
        color: "#4285F4",
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
    provider_id: provider:google,
    category_id: NONE,
    is_active: true;

