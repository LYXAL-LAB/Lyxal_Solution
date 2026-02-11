-- Batch 20: 20 services Lyxal

-- Service 381: Sort
CREATE service:sort SET
    identity = {
        name: "Sort",
        slug: "sort",
        display_name_i18n: i18n_key:service_sort_name,
        description_i18n: i18n_key:service_sort_desc,
        aliases: ["Sort"]
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
    provider_id: provider:transform,
    category_id: NONE,
    is_active: true;

-- Service 382: SplitOut
CREATE service:splitout SET
    identity = {
        name: "SplitOut",
        slug: "splitout",
        display_name_i18n: i18n_key:service_splitout_name,
        description_i18n: i18n_key:service_splitout_desc,
        aliases: ["SplitOut"]
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
    provider_id: provider:transform,
    category_id: NONE,
    is_active: true;

-- Service 383: Summarize
CREATE service:summarize SET
    identity = {
        name: "Summarize",
        slug: "summarize",
        display_name_i18n: i18n_key:service_summarize_name,
        description_i18n: i18n_key:service_summarize_desc,
        aliases: ["Summarize"]
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
    provider_id: provider:transform,
    category_id: NONE,
    is_active: true;

-- Service 384: TravisCi
CREATE service:travisci SET
    identity = {
        name: "TravisCi",
        slug: "travisci",
        display_name_i18n: i18n_key:service_travisci_name,
        description_i18n: i18n_key:service_travisci_desc,
        aliases: ["TravisCi"]
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
    provider_id: provider:travisci,
    category_id: NONE,
    is_active: true;

-- Service 385: Trello
CREATE service:trello SET
    identity = {
        name: "Trello",
        slug: "trello",
        display_name_i18n: i18n_key:service_trello_name,
        description_i18n: i18n_key:service_trello_desc,
        aliases: ["Trello"]
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
    provider_id: provider:trello,
    category_id: NONE,
    is_active: true;

-- Service 386: Twake
CREATE service:twake SET
    identity = {
        name: "Twake",
        slug: "twake",
        display_name_i18n: i18n_key:service_twake_name,
        description_i18n: i18n_key:service_twake_desc,
        aliases: ["Twake"]
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
    provider_id: provider:twake,
    category_id: NONE,
    is_active: true;

-- Service 387: Twilio
CREATE service:twilio SET
    identity = {
        name: "Twilio",
        slug: "twilio",
        display_name_i18n: i18n_key:service_twilio_name,
        description_i18n: i18n_key:service_twilio_desc,
        aliases: ["Twilio"]
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
    provider_id: provider:twilio,
    category_id: NONE,
    is_active: true;

-- Service 388: Twist
CREATE service:twist SET
    identity = {
        name: "Twist",
        slug: "twist",
        display_name_i18n: i18n_key:service_twist_name,
        description_i18n: i18n_key:service_twist_desc,
        aliases: ["Twist"]
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
    provider_id: provider:twist,
    category_id: NONE,
    is_active: true;

-- Service 389: Twitter
CREATE service:twitter SET
    identity = {
        name: "Twitter",
        slug: "twitter",
        display_name_i18n: i18n_key:service_twitter_name,
        description_i18n: i18n_key:service_twitter_desc,
        aliases: ["Twitter"]
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
    provider_id: provider:twitter,
    category_id: NONE,
    is_active: true;

-- Service 390: TwitterV1
CREATE service:twitterv1 SET
    identity = {
        name: "TwitterV1",
        slug: "twitterv1",
        display_name_i18n: i18n_key:service_twitterv1_name,
        description_i18n: i18n_key:service_twitterv1_desc,
        aliases: ["TwitterV1"]
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
    provider_id: provider:twitter,
    category_id: NONE,
    is_active: true;

-- Service 391: TwitterV2
CREATE service:twitterv2 SET
    identity = {
        name: "TwitterV2",
        slug: "twitterv2",
        display_name_i18n: i18n_key:service_twitterv2_name,
        description_i18n: i18n_key:service_twitterv2_desc,
        aliases: ["TwitterV2"]
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
    provider_id: provider:twitter,
    category_id: NONE,
    is_active: true;

-- Service 392: UnleashedSoftware
CREATE service:unleashedsoftware SET
    identity = {
        name: "UnleashedSoftware",
        slug: "unleashedsoftware",
        display_name_i18n: i18n_key:service_unleashedsoftware_name,
        description_i18n: i18n_key:service_unleashedsoftware_desc,
        aliases: ["UnleashedSoftware"]
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
    provider_id: provider:unleashedsoftware,
    category_id: NONE,
    is_active: true;

-- Service 393: Uplead
CREATE service:uplead SET
    identity = {
        name: "Uplead",
        slug: "uplead",
        display_name_i18n: i18n_key:service_uplead_name,
        description_i18n: i18n_key:service_uplead_desc,
        aliases: ["Uplead"]
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
    provider_id: provider:uplead,
    category_id: NONE,
    is_active: true;

-- Service 394: UProc
CREATE service:uproc SET
    identity = {
        name: "UProc",
        slug: "uproc",
        display_name_i18n: i18n_key:service_uproc_name,
        description_i18n: i18n_key:service_uproc_desc,
        aliases: ["UProc"]
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
    provider_id: provider:uproc,
    category_id: NONE,
    is_active: true;

-- Service 395: UptimeRobot
CREATE service:uptimerobot SET
    identity = {
        name: "UptimeRobot",
        slug: "uptimerobot",
        display_name_i18n: i18n_key:service_uptimerobot_name,
        description_i18n: i18n_key:service_uptimerobot_desc,
        aliases: ["UptimeRobot"]
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
    provider_id: provider:uptimerobot,
    category_id: NONE,
    is_active: true;

-- Service 396: UrlScanIo
CREATE service:urlscanio SET
    identity = {
        name: "UrlScanIo",
        slug: "urlscanio",
        display_name_i18n: i18n_key:service_urlscanio_name,
        description_i18n: i18n_key:service_urlscanio_desc,
        aliases: ["UrlScanIo"]
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
    provider_id: provider:urlscanio,
    category_id: NONE,
    is_active: true;

-- Service 397: VenafiTlsProtectDatacenter
CREATE service:venafitlsprotectdatacenter SET
    identity = {
        name: "VenafiTlsProtectDatacenter",
        slug: "venafitlsprotectdatacenter",
        display_name_i18n: i18n_key:service_venafitlsprotectdatacenter_name,
        description_i18n: i18n_key:service_venafitlsprotectdatacenter_desc,
        aliases: ["VenafiTlsProtectDatacenter"]
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
    provider_id: provider:venafi,
    category_id: NONE,
    is_active: true;

-- Service 398: VenafiTlsProtectCloud
CREATE service:venafitlsprotectcloud SET
    identity = {
        name: "VenafiTlsProtectCloud",
        slug: "venafitlsprotectcloud",
        display_name_i18n: i18n_key:service_venafitlsprotectcloud_name,
        description_i18n: i18n_key:service_venafitlsprotectcloud_desc,
        aliases: ["VenafiTlsProtectCloud"]
    },
    presentation = {
        icon: NONE,
        color: "#5C6AC4",
        display_order: 0,
        category_slug: "cloud",
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
        tags: ["cloud"],
        popularity_score: NONE,
        last_updated_by: NONE,
        custom_data: NONE
    },
    provider_id: provider:venafi,
    category_id: NONE,
    is_active: true;

-- Service 399: Vero
CREATE service:vero SET
    identity = {
        name: "Vero",
        slug: "vero",
        display_name_i18n: i18n_key:service_vero_name,
        description_i18n: i18n_key:service_vero_desc,
        aliases: ["Vero"]
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
    provider_id: provider:vero,
    category_id: NONE,
    is_active: true;

-- Service 400: Vonage
CREATE service:vonage SET
    identity = {
        name: "Vonage",
        slug: "vonage",
        display_name_i18n: i18n_key:service_vonage_name,
        description_i18n: i18n_key:service_vonage_desc,
        aliases: ["Vonage"]
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
    provider_id: provider:vonage,
    category_id: NONE,
    is_active: true;

