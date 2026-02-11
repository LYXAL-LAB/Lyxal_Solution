-- Batch 19: 20 services Lyxal

-- Service 361: SwitchV1
CREATE service:switchv1 SET
    identity = {
        name: "SwitchV1",
        slug: "switchv1",
        display_name_i18n: i18n_key:service_switchv1_name,
        description_i18n: i18n_key:service_switchv1_desc,
        aliases: ["SwitchV1"]
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
    provider_id: provider:switch,
    category_id: NONE,
    is_active: true;

-- Service 362: SwitchV2
CREATE service:switchv2 SET
    identity = {
        name: "SwitchV2",
        slug: "switchv2",
        display_name_i18n: i18n_key:service_switchv2_name,
        description_i18n: i18n_key:service_switchv2_desc,
        aliases: ["SwitchV2"]
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
    provider_id: provider:switch,
    category_id: NONE,
    is_active: true;

-- Service 363: SwitchV3
CREATE service:switchv3 SET
    identity = {
        name: "SwitchV3",
        slug: "switchv3",
        display_name_i18n: i18n_key:service_switchv3_name,
        description_i18n: i18n_key:service_switchv3_desc,
        aliases: ["SwitchV3"]
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
    provider_id: provider:switch,
    category_id: NONE,
    is_active: true;

-- Service 364: SyncroMsp
CREATE service:syncromsp SET
    identity = {
        name: "SyncroMsp",
        slug: "syncromsp",
        display_name_i18n: i18n_key:service_syncromsp_name,
        description_i18n: i18n_key:service_syncromsp_desc,
        aliases: ["SyncroMsp"]
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
    provider_id: provider:syncromsp,
    category_id: NONE,
    is_active: true;

-- Service 365: SyncroMspV1
CREATE service:syncromspv1 SET
    identity = {
        name: "SyncroMspV1",
        slug: "syncromspv1",
        display_name_i18n: i18n_key:service_syncromspv1_name,
        description_i18n: i18n_key:service_syncromspv1_desc,
        aliases: ["SyncroMspV1"]
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
    provider_id: provider:syncromsp,
    category_id: NONE,
    is_active: true;

-- Service 366: Taiga
CREATE service:taiga SET
    identity = {
        name: "Taiga",
        slug: "taiga",
        display_name_i18n: i18n_key:service_taiga_name,
        description_i18n: i18n_key:service_taiga_desc,
        aliases: ["Taiga"]
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
    provider_id: provider:taiga,
    category_id: NONE,
    is_active: true;

-- Service 367: Tapfiliate
CREATE service:tapfiliate SET
    identity = {
        name: "Tapfiliate",
        slug: "tapfiliate",
        display_name_i18n: i18n_key:service_tapfiliate_name,
        description_i18n: i18n_key:service_tapfiliate_desc,
        aliases: ["Tapfiliate"]
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
    provider_id: provider:tapfiliate,
    category_id: NONE,
    is_active: true;

-- Service 368: Telegram
CREATE service:telegram SET
    identity = {
        name: "Telegram",
        slug: "telegram",
        display_name_i18n: i18n_key:service_telegram_name,
        description_i18n: i18n_key:service_telegram_desc,
        aliases: ["Telegram"]
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
    provider_id: provider:telegram,
    category_id: NONE,
    is_active: true;

-- Service 369: TheHive
CREATE service:thehive SET
    identity = {
        name: "TheHive",
        slug: "thehive",
        display_name_i18n: i18n_key:service_thehive_name,
        description_i18n: i18n_key:service_thehive_desc,
        aliases: ["TheHive"]
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
    provider_id: provider:thehive,
    category_id: NONE,
    is_active: true;

-- Service 370: TheHiveProject
CREATE service:thehiveproject SET
    identity = {
        name: "TheHiveProject",
        slug: "thehiveproject",
        display_name_i18n: i18n_key:service_thehiveproject_name,
        description_i18n: i18n_key:service_thehiveproject_desc,
        aliases: ["TheHiveProject"]
    },
    presentation = {
        icon: NONE,
        color: "#5C6AC4",
        display_order: 0,
        category_slug: "project-management",
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
        tags: ["project-management"],
        popularity_score: NONE,
        last_updated_by: NONE,
        custom_data: NONE
    },
    provider_id: provider:thehiveproject,
    category_id: NONE,
    is_active: true;

-- Service 371: TimescaleDb
CREATE service:timescaledb SET
    identity = {
        name: "TimescaleDb",
        slug: "timescaledb",
        display_name_i18n: i18n_key:service_timescaledb_name,
        description_i18n: i18n_key:service_timescaledb_desc,
        aliases: ["TimescaleDb"]
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
    provider_id: provider:timescaledb,
    category_id: NONE,
    is_active: true;

-- Service 372: Todoist
CREATE service:todoist SET
    identity = {
        name: "Todoist",
        slug: "todoist",
        display_name_i18n: i18n_key:service_todoist_name,
        description_i18n: i18n_key:service_todoist_desc,
        aliases: ["Todoist"]
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
    provider_id: provider:todoist,
    category_id: NONE,
    is_active: true;

-- Service 373: TodoistV1
CREATE service:todoistv1 SET
    identity = {
        name: "TodoistV1",
        slug: "todoistv1",
        display_name_i18n: i18n_key:service_todoistv1_name,
        description_i18n: i18n_key:service_todoistv1_desc,
        aliases: ["TodoistV1"]
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
    provider_id: provider:todoist,
    category_id: NONE,
    is_active: true;

-- Service 374: TodoistV2
CREATE service:todoistv2 SET
    identity = {
        name: "TodoistV2",
        slug: "todoistv2",
        display_name_i18n: i18n_key:service_todoistv2_name,
        description_i18n: i18n_key:service_todoistv2_desc,
        aliases: ["TodoistV2"]
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
    provider_id: provider:todoist,
    category_id: NONE,
    is_active: true;

-- Service 375: Totp
CREATE service:totp SET
    identity = {
        name: "Totp",
        slug: "totp",
        display_name_i18n: i18n_key:service_totp_name,
        description_i18n: i18n_key:service_totp_desc,
        aliases: ["Totp"]
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
    provider_id: provider:totp,
    category_id: NONE,
    is_active: true;

-- Service 376: Aggregate
CREATE service:aggregate SET
    identity = {
        name: "Aggregate",
        slug: "aggregate",
        display_name_i18n: i18n_key:service_aggregate_name,
        description_i18n: i18n_key:service_aggregate_desc,
        aliases: ["Aggregate"]
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

-- Service 377: Limit
CREATE service:limit SET
    identity = {
        name: "Limit",
        slug: "limit",
        display_name_i18n: i18n_key:service_limit_name,
        description_i18n: i18n_key:service_limit_desc,
        aliases: ["Limit"]
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

-- Service 378: RemoveDuplicates
CREATE service:removeduplicates SET
    identity = {
        name: "RemoveDuplicates",
        slug: "removeduplicates",
        display_name_i18n: i18n_key:service_removeduplicates_name,
        description_i18n: i18n_key:service_removeduplicates_desc,
        aliases: ["RemoveDuplicates"]
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

-- Service 379: RemoveDuplicatesV1
CREATE service:removeduplicatesv1 SET
    identity = {
        name: "RemoveDuplicatesV1",
        slug: "removeduplicatesv1",
        display_name_i18n: i18n_key:service_removeduplicatesv1_name,
        description_i18n: i18n_key:service_removeduplicatesv1_desc,
        aliases: ["RemoveDuplicatesV1"]
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

-- Service 380: RemoveDuplicatesV2
CREATE service:removeduplicatesv2 SET
    identity = {
        name: "RemoveDuplicatesV2",
        slug: "removeduplicatesv2",
        display_name_i18n: i18n_key:service_removeduplicatesv2_name,
        description_i18n: i18n_key:service_removeduplicatesv2_desc,
        aliases: ["RemoveDuplicatesV2"]
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

