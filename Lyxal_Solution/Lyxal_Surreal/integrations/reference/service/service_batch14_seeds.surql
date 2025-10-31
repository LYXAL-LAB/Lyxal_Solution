-- Batch 14: 20 services Lyxal

-- Service 261: NetscalerAdc
CREATE service:netscaleradc SET
    identity = {
        name: "NetscalerAdc",
        slug: "netscaleradc",
        display_name_i18n: i18n_key:service_netscaleradc_name,
        description_i18n: i18n_key:service_netscaleradc_desc,
        aliases: ["NetscalerAdc"]
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
    provider_id: provider:netscaler,
    category_id: NONE,
    is_active: true;

-- Service 262: NextCloud
CREATE service:nextcloud SET
    identity = {
        name: "NextCloud",
        slug: "nextcloud",
        display_name_i18n: i18n_key:service_nextcloud_name,
        description_i18n: i18n_key:service_nextcloud_desc,
        aliases: ["NextCloud"]
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
    provider_id: provider:nextcloud,
    category_id: NONE,
    is_active: true;

-- Service 263: NocoDB
CREATE service:nocodb SET
    identity = {
        name: "NocoDB",
        slug: "nocodb",
        display_name_i18n: i18n_key:service_nocodb_name,
        description_i18n: i18n_key:service_nocodb_desc,
        aliases: ["NocoDB"]
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
    provider_id: provider:nocodb,
    category_id: NONE,
    is_active: true;

-- Service 264: NoOp
CREATE service:noop SET
    identity = {
        name: "NoOp",
        slug: "noop",
        display_name_i18n: i18n_key:service_noop_name,
        description_i18n: i18n_key:service_noop_desc,
        aliases: ["NoOp"]
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
    provider_id: provider:noop,
    category_id: NONE,
    is_active: true;

-- Service 265: Notion
CREATE service:notion SET
    identity = {
        name: "Notion",
        slug: "notion",
        display_name_i18n: i18n_key:service_notion_name,
        description_i18n: i18n_key:service_notion_desc,
        aliases: ["Notion"]
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
    provider_id: provider:notion,
    category_id: NONE,
    is_active: true;

-- Service 266: NotionV1
CREATE service:notionv1 SET
    identity = {
        name: "NotionV1",
        slug: "notionv1",
        display_name_i18n: i18n_key:service_notionv1_name,
        description_i18n: i18n_key:service_notionv1_desc,
        aliases: ["NotionV1"]
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
    provider_id: provider:notion,
    category_id: NONE,
    is_active: true;

-- Service 267: NotionV2
CREATE service:notionv2 SET
    identity = {
        name: "NotionV2",
        slug: "notionv2",
        display_name_i18n: i18n_key:service_notionv2_name,
        description_i18n: i18n_key:service_notionv2_desc,
        aliases: ["NotionV2"]
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
    provider_id: provider:notion,
    category_id: NONE,
    is_active: true;

-- Service 268: Npm
CREATE service:npm SET
    identity = {
        name: "Npm",
        slug: "npm",
        display_name_i18n: i18n_key:service_npm_name,
        description_i18n: i18n_key:service_npm_desc,
        aliases: ["Npm"]
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
    provider_id: provider:npm,
    category_id: NONE,
    is_active: true;

-- Service 269: Odoo
CREATE service:odoo SET
    identity = {
        name: "Odoo",
        slug: "odoo",
        display_name_i18n: i18n_key:service_odoo_name,
        description_i18n: i18n_key:service_odoo_desc,
        aliases: ["Odoo"]
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
    provider_id: provider:odoo,
    category_id: NONE,
    is_active: true;

-- Service 270: Okta
CREATE service:okta SET
    identity = {
        name: "Okta",
        slug: "okta",
        display_name_i18n: i18n_key:service_okta_name,
        description_i18n: i18n_key:service_okta_desc,
        aliases: ["Okta"]
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
    provider_id: provider:okta,
    category_id: NONE,
    is_active: true;

-- Service 271: OneSimpleApi
CREATE service:onesimpleapi SET
    identity = {
        name: "OneSimpleApi",
        slug: "onesimpleapi",
        display_name_i18n: i18n_key:service_onesimpleapi_name,
        description_i18n: i18n_key:service_onesimpleapi_desc,
        aliases: ["OneSimpleApi"]
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
    provider_id: provider:onesimpleapi,
    category_id: NONE,
    is_active: true;

-- Service 272: Onfleet
CREATE service:onfleet SET
    identity = {
        name: "Onfleet",
        slug: "onfleet",
        display_name_i18n: i18n_key:service_onfleet_name,
        description_i18n: i18n_key:service_onfleet_desc,
        aliases: ["Onfleet"]
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
    provider_id: provider:onfleet,
    category_id: NONE,
    is_active: true;

-- Service 273: OpenAi
CREATE service:openai SET
    identity = {
        name: "OpenAi",
        slug: "openai",
        display_name_i18n: i18n_key:service_openai_name,
        description_i18n: i18n_key:service_openai_desc,
        aliases: ["OpenAi"]
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
    provider_id: provider:openai,
    category_id: NONE,
    is_active: true;

-- Service 274: OpenThesaurus
CREATE service:openthesaurus SET
    identity = {
        name: "OpenThesaurus",
        slug: "openthesaurus",
        display_name_i18n: i18n_key:service_openthesaurus_name,
        description_i18n: i18n_key:service_openthesaurus_desc,
        aliases: ["OpenThesaurus"]
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
    provider_id: provider:openthesaurus,
    category_id: NONE,
    is_active: true;

-- Service 275: OpenWeatherMap
CREATE service:openweathermap SET
    identity = {
        name: "OpenWeatherMap",
        slug: "openweathermap",
        display_name_i18n: i18n_key:service_openweathermap_name,
        description_i18n: i18n_key:service_openweathermap_desc,
        aliases: ["OpenWeatherMap"]
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
    provider_id: provider:openweathermap,
    category_id: NONE,
    is_active: true;

-- Service 276: OracleSql
CREATE service:oraclesql SET
    identity = {
        name: "OracleSql",
        slug: "oraclesql",
        display_name_i18n: i18n_key:service_oraclesql_name,
        description_i18n: i18n_key:service_oraclesql_desc,
        aliases: ["OracleSql"]
    },
    presentation = {
        icon: NONE,
        color: "#5C6AC4",
        display_order: 0,
        category_slug: "data-storage",
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
        tags: ["data-storage"],
        popularity_score: NONE,
        last_updated_by: NONE,
        custom_data: NONE
    },
    provider_id: provider:oracle,
    category_id: NONE,
    is_active: true;

-- Service 277: Orbit
CREATE service:orbit SET
    identity = {
        name: "Orbit",
        slug: "orbit",
        display_name_i18n: i18n_key:service_orbit_name,
        description_i18n: i18n_key:service_orbit_desc,
        aliases: ["Orbit"]
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
    provider_id: provider:orbit,
    category_id: NONE,
    is_active: true;

-- Service 278: Oura
CREATE service:oura SET
    identity = {
        name: "Oura",
        slug: "oura",
        display_name_i18n: i18n_key:service_oura_name,
        description_i18n: i18n_key:service_oura_desc,
        aliases: ["Oura"]
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
    provider_id: provider:oura,
    category_id: NONE,
    is_active: true;

-- Service 279: Paddle
CREATE service:paddle SET
    identity = {
        name: "Paddle",
        slug: "paddle",
        display_name_i18n: i18n_key:service_paddle_name,
        description_i18n: i18n_key:service_paddle_desc,
        aliases: ["Paddle"]
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
    provider_id: provider:paddle,
    category_id: NONE,
    is_active: true;

-- Service 280: PagerDuty
CREATE service:pagerduty SET
    identity = {
        name: "PagerDuty",
        slug: "pagerduty",
        display_name_i18n: i18n_key:service_pagerduty_name,
        description_i18n: i18n_key:service_pagerduty_desc,
        aliases: ["PagerDuty"]
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
    provider_id: provider:pagerduty,
    category_id: NONE,
    is_active: true;

