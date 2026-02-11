-- Batch 17: 20 services Lyxal

-- Service 321: SecurityScorecard
CREATE service:securityscorecard SET
    identity = {
        name: "SecurityScorecard",
        slug: "securityscorecard",
        display_name_i18n: i18n_key:service_securityscorecard_name,
        description_i18n: i18n_key:service_securityscorecard_desc,
        aliases: ["SecurityScorecard"]
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
    provider_id: provider:securityscorecard,
    category_id: NONE,
    is_active: true;

-- Service 322: Segment
CREATE service:segment SET
    identity = {
        name: "Segment",
        slug: "segment",
        display_name_i18n: i18n_key:service_segment_name,
        description_i18n: i18n_key:service_segment_desc,
        aliases: ["Segment"]
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
    provider_id: provider:segment,
    category_id: NONE,
    is_active: true;

-- Service 323: SendGrid
CREATE service:sendgrid SET
    identity = {
        name: "SendGrid",
        slug: "sendgrid",
        display_name_i18n: i18n_key:service_sendgrid_name,
        description_i18n: i18n_key:service_sendgrid_desc,
        aliases: ["SendGrid"]
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
    provider_id: provider:sendgrid,
    category_id: NONE,
    is_active: true;

-- Service 324: Sendy
CREATE service:sendy SET
    identity = {
        name: "Sendy",
        slug: "sendy",
        display_name_i18n: i18n_key:service_sendy_name,
        description_i18n: i18n_key:service_sendy_desc,
        aliases: ["Sendy"]
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
    provider_id: provider:sendy,
    category_id: NONE,
    is_active: true;

-- Service 325: SentryIo
CREATE service:sentryio SET
    identity = {
        name: "SentryIo",
        slug: "sentryio",
        display_name_i18n: i18n_key:service_sentryio_name,
        description_i18n: i18n_key:service_sentryio_desc,
        aliases: ["SentryIo"]
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
    provider_id: provider:sentryio,
    category_id: NONE,
    is_active: true;

-- Service 326: ServiceNow
CREATE service:servicenow SET
    identity = {
        name: "ServiceNow",
        slug: "servicenow",
        display_name_i18n: i18n_key:service_servicenow_name,
        description_i18n: i18n_key:service_servicenow_desc,
        aliases: ["ServiceNow"]
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
    provider_id: provider:servicenow,
    category_id: NONE,
    is_active: true;

-- Service 327: Set
CREATE service:set SET
    identity = {
        name: "Set",
        slug: "set",
        display_name_i18n: i18n_key:service_set_name,
        description_i18n: i18n_key:service_set_desc,
        aliases: ["Set"]
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
    provider_id: provider:set,
    category_id: NONE,
    is_active: true;

-- Service 328: SetV1
CREATE service:setv1 SET
    identity = {
        name: "SetV1",
        slug: "setv1",
        display_name_i18n: i18n_key:service_setv1_name,
        description_i18n: i18n_key:service_setv1_desc,
        aliases: ["SetV1"]
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
    provider_id: provider:set,
    category_id: NONE,
    is_active: true;

-- Service 329: SetV2
CREATE service:setv2 SET
    identity = {
        name: "SetV2",
        slug: "setv2",
        display_name_i18n: i18n_key:service_setv2_name,
        description_i18n: i18n_key:service_setv2_desc,
        aliases: ["SetV2"]
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
    provider_id: provider:set,
    category_id: NONE,
    is_active: true;

-- Service 330: Shopify
CREATE service:shopify SET
    identity = {
        name: "Shopify",
        slug: "shopify",
        display_name_i18n: i18n_key:service_shopify_name,
        description_i18n: i18n_key:service_shopify_desc,
        aliases: ["Shopify"]
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
    provider_id: provider:shopify,
    category_id: NONE,
    is_active: true;

-- Service 331: Signl4
CREATE service:signl4 SET
    identity = {
        name: "Signl4",
        slug: "signl4",
        display_name_i18n: i18n_key:service_signl4_name,
        description_i18n: i18n_key:service_signl4_desc,
        aliases: ["Signl4"]
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
    provider_id: provider:signl4,
    category_id: NONE,
    is_active: true;

-- Service 332: Simulate
CREATE service:simulate SET
    identity = {
        name: "Simulate",
        slug: "simulate",
        display_name_i18n: i18n_key:service_simulate_name,
        description_i18n: i18n_key:service_simulate_desc,
        aliases: ["Simulate"]
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
    provider_id: provider:simulate,
    category_id: NONE,
    is_active: true;

-- Service 333: Slack
CREATE service:slack SET
    identity = {
        name: "Slack",
        slug: "slack",
        display_name_i18n: i18n_key:service_slack_name,
        description_i18n: i18n_key:service_slack_desc,
        aliases: ["Slack"]
    },
    presentation = {
        icon: NONE,
        color: "#4A154B",
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
    provider_id: provider:slack,
    category_id: NONE,
    is_active: true;

-- Service 334: SlackV1
CREATE service:slackv1 SET
    identity = {
        name: "SlackV1",
        slug: "slackv1",
        display_name_i18n: i18n_key:service_slackv1_name,
        description_i18n: i18n_key:service_slackv1_desc,
        aliases: ["SlackV1"]
    },
    presentation = {
        icon: NONE,
        color: "#4A154B",
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
    provider_id: provider:slack,
    category_id: NONE,
    is_active: true;

-- Service 335: SlackV2
CREATE service:slackv2 SET
    identity = {
        name: "SlackV2",
        slug: "slackv2",
        display_name_i18n: i18n_key:service_slackv2_name,
        description_i18n: i18n_key:service_slackv2_desc,
        aliases: ["SlackV2"]
    },
    presentation = {
        icon: NONE,
        color: "#4A154B",
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
    provider_id: provider:slack,
    category_id: NONE,
    is_active: true;

-- Service 336: Sms77
CREATE service:sms77 SET
    identity = {
        name: "Sms77",
        slug: "sms77",
        display_name_i18n: i18n_key:service_sms77_name,
        description_i18n: i18n_key:service_sms77_desc,
        aliases: ["Sms77"]
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
    provider_id: provider:sms77,
    category_id: NONE,
    is_active: true;

-- Service 337: Snowflake
CREATE service:snowflake SET
    identity = {
        name: "Snowflake",
        slug: "snowflake",
        display_name_i18n: i18n_key:service_snowflake_name,
        description_i18n: i18n_key:service_snowflake_desc,
        aliases: ["Snowflake"]
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
    provider_id: provider:snowflake,
    category_id: NONE,
    is_active: true;

-- Service 338: SplitInBatches
CREATE service:splitinbatches SET
    identity = {
        name: "SplitInBatches",
        slug: "splitinbatches",
        display_name_i18n: i18n_key:service_splitinbatches_name,
        description_i18n: i18n_key:service_splitinbatches_desc,
        aliases: ["SplitInBatches"]
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
    provider_id: provider:splitinbatches,
    category_id: NONE,
    is_active: true;

-- Service 339: SplitInBatchesV1
CREATE service:splitinbatchesv1 SET
    identity = {
        name: "SplitInBatchesV1",
        slug: "splitinbatchesv1",
        display_name_i18n: i18n_key:service_splitinbatchesv1_name,
        description_i18n: i18n_key:service_splitinbatchesv1_desc,
        aliases: ["SplitInBatchesV1"]
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
    provider_id: provider:splitinbatches,
    category_id: NONE,
    is_active: true;

-- Service 340: SplitInBatchesV2
CREATE service:splitinbatchesv2 SET
    identity = {
        name: "SplitInBatchesV2",
        slug: "splitinbatchesv2",
        display_name_i18n: i18n_key:service_splitinbatchesv2_name,
        description_i18n: i18n_key:service_splitinbatchesv2_desc,
        aliases: ["SplitInBatchesV2"]
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
    provider_id: provider:splitinbatches,
    category_id: NONE,
    is_active: true;

