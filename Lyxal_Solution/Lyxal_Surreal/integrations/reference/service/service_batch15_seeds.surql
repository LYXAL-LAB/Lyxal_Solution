-- Batch 15: 20 services Lyxal

-- Service 281: PayPal
CREATE service:paypal SET
    identity = {
        name: "PayPal",
        slug: "paypal",
        display_name_i18n: i18n_key:service_paypal_name,
        description_i18n: i18n_key:service_paypal_desc,
        aliases: ["PayPal"]
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
    provider_id: provider:paypal,
    category_id: NONE,
    is_active: true;

-- Service 282: Peekalink
CREATE service:peekalink SET
    identity = {
        name: "Peekalink",
        slug: "peekalink",
        display_name_i18n: i18n_key:service_peekalink_name,
        description_i18n: i18n_key:service_peekalink_desc,
        aliases: ["Peekalink"]
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
    provider_id: provider:peekalink,
    category_id: NONE,
    is_active: true;

-- Service 283: Perplexity
CREATE service:perplexity SET
    identity = {
        name: "Perplexity",
        slug: "perplexity",
        display_name_i18n: i18n_key:service_perplexity_name,
        description_i18n: i18n_key:service_perplexity_desc,
        aliases: ["Perplexity"]
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
    provider_id: provider:perplexity,
    category_id: NONE,
    is_active: true;

-- Service 284: Phantombuster
CREATE service:phantombuster SET
    identity = {
        name: "Phantombuster",
        slug: "phantombuster",
        display_name_i18n: i18n_key:service_phantombuster_name,
        description_i18n: i18n_key:service_phantombuster_desc,
        aliases: ["Phantombuster"]
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
    provider_id: provider:phantombuster,
    category_id: NONE,
    is_active: true;

-- Service 285: PhilipsHue
CREATE service:philipshue SET
    identity = {
        name: "PhilipsHue",
        slug: "philipshue",
        display_name_i18n: i18n_key:service_philipshue_name,
        description_i18n: i18n_key:service_philipshue_desc,
        aliases: ["PhilipsHue"]
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
    provider_id: provider:philipshue,
    category_id: NONE,
    is_active: true;

-- Service 286: Pipedrive
CREATE service:pipedrive SET
    identity = {
        name: "Pipedrive",
        slug: "pipedrive",
        display_name_i18n: i18n_key:service_pipedrive_name,
        description_i18n: i18n_key:service_pipedrive_desc,
        aliases: ["Pipedrive"]
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
    provider_id: provider:pipedrive,
    category_id: NONE,
    is_active: true;

-- Service 287: Plivo
CREATE service:plivo SET
    identity = {
        name: "Plivo",
        slug: "plivo",
        display_name_i18n: i18n_key:service_plivo_name,
        description_i18n: i18n_key:service_plivo_desc,
        aliases: ["Plivo"]
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
    provider_id: provider:plivo,
    category_id: NONE,
    is_active: true;

-- Service 288: PostBin
CREATE service:postbin SET
    identity = {
        name: "PostBin",
        slug: "postbin",
        display_name_i18n: i18n_key:service_postbin_name,
        description_i18n: i18n_key:service_postbin_desc,
        aliases: ["PostBin"]
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
    provider_id: provider:postbin,
    category_id: NONE,
    is_active: true;

-- Service 289: Postgres
CREATE service:postgres SET
    identity = {
        name: "Postgres",
        slug: "postgres",
        display_name_i18n: i18n_key:service_postgres_name,
        description_i18n: i18n_key:service_postgres_desc,
        aliases: ["Postgres"]
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
    provider_id: provider:postgres,
    category_id: NONE,
    is_active: true;

-- Service 290: PostgresV1
CREATE service:postgresv1 SET
    identity = {
        name: "PostgresV1",
        slug: "postgresv1",
        display_name_i18n: i18n_key:service_postgresv1_name,
        description_i18n: i18n_key:service_postgresv1_desc,
        aliases: ["PostgresV1"]
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
    provider_id: provider:postgres,
    category_id: NONE,
    is_active: true;

-- Service 291: PostgresV2
CREATE service:postgresv2 SET
    identity = {
        name: "PostgresV2",
        slug: "postgresv2",
        display_name_i18n: i18n_key:service_postgresv2_name,
        description_i18n: i18n_key:service_postgresv2_desc,
        aliases: ["PostgresV2"]
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
    provider_id: provider:postgres,
    category_id: NONE,
    is_active: true;

-- Service 292: PostHog
CREATE service:posthog SET
    identity = {
        name: "PostHog",
        slug: "posthog",
        display_name_i18n: i18n_key:service_posthog_name,
        description_i18n: i18n_key:service_posthog_desc,
        aliases: ["PostHog"]
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
    provider_id: provider:posthog,
    category_id: NONE,
    is_active: true;

-- Service 293: ProfitWell
CREATE service:profitwell SET
    identity = {
        name: "ProfitWell",
        slug: "profitwell",
        display_name_i18n: i18n_key:service_profitwell_name,
        description_i18n: i18n_key:service_profitwell_desc,
        aliases: ["ProfitWell"]
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
    provider_id: provider:profitwell,
    category_id: NONE,
    is_active: true;

-- Service 294: Pushbullet
CREATE service:pushbullet SET
    identity = {
        name: "Pushbullet",
        slug: "pushbullet",
        display_name_i18n: i18n_key:service_pushbullet_name,
        description_i18n: i18n_key:service_pushbullet_desc,
        aliases: ["Pushbullet"]
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
    provider_id: provider:pushbullet,
    category_id: NONE,
    is_active: true;

-- Service 295: Pushcut
CREATE service:pushcut SET
    identity = {
        name: "Pushcut",
        slug: "pushcut",
        display_name_i18n: i18n_key:service_pushcut_name,
        description_i18n: i18n_key:service_pushcut_desc,
        aliases: ["Pushcut"]
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
    provider_id: provider:pushcut,
    category_id: NONE,
    is_active: true;

-- Service 296: Pushover
CREATE service:pushover SET
    identity = {
        name: "Pushover",
        slug: "pushover",
        display_name_i18n: i18n_key:service_pushover_name,
        description_i18n: i18n_key:service_pushover_desc,
        aliases: ["Pushover"]
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
    provider_id: provider:pushover,
    category_id: NONE,
    is_active: true;

-- Service 297: QuestDb
CREATE service:questdb SET
    identity = {
        name: "QuestDb",
        slug: "questdb",
        display_name_i18n: i18n_key:service_questdb_name,
        description_i18n: i18n_key:service_questdb_desc,
        aliases: ["QuestDb"]
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
    provider_id: provider:questdb,
    category_id: NONE,
    is_active: true;

-- Service 298: QuickBase
CREATE service:quickbase SET
    identity = {
        name: "QuickBase",
        slug: "quickbase",
        display_name_i18n: i18n_key:service_quickbase_name,
        description_i18n: i18n_key:service_quickbase_desc,
        aliases: ["QuickBase"]
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
    provider_id: provider:quickbase,
    category_id: NONE,
    is_active: true;

-- Service 299: QuickBooks
CREATE service:quickbooks SET
    identity = {
        name: "QuickBooks",
        slug: "quickbooks",
        display_name_i18n: i18n_key:service_quickbooks_name,
        description_i18n: i18n_key:service_quickbooks_desc,
        aliases: ["QuickBooks"]
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
    provider_id: provider:quickbooks,
    category_id: NONE,
    is_active: true;

-- Service 300: QuickChart
CREATE service:quickchart SET
    identity = {
        name: "QuickChart",
        slug: "quickchart",
        display_name_i18n: i18n_key:service_quickchart_name,
        description_i18n: i18n_key:service_quickchart_desc,
        aliases: ["QuickChart"]
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
    provider_id: provider:quickchart,
    category_id: NONE,
    is_active: true;

