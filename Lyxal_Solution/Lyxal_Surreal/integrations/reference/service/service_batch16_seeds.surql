-- Batch 16: 20 services Lyxal

-- Service 301: RabbitMQ
CREATE service:rabbitmq SET
    identity = {
        name: "RabbitMQ",
        slug: "rabbitmq",
        display_name_i18n: i18n_key:service_rabbitmq_name,
        description_i18n: i18n_key:service_rabbitmq_desc,
        aliases: ["RabbitMQ"]
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
    provider_id: provider:rabbitmq,
    category_id: NONE,
    is_active: true;

-- Service 302: Raindrop
CREATE service:raindrop SET
    identity = {
        name: "Raindrop",
        slug: "raindrop",
        display_name_i18n: i18n_key:service_raindrop_name,
        description_i18n: i18n_key:service_raindrop_desc,
        aliases: ["Raindrop"]
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
    provider_id: provider:raindrop,
    category_id: NONE,
    is_active: true;

-- Service 303: ReadBinaryFile
CREATE service:readbinaryfile SET
    identity = {
        name: "ReadBinaryFile",
        slug: "readbinaryfile",
        display_name_i18n: i18n_key:service_readbinaryfile_name,
        description_i18n: i18n_key:service_readbinaryfile_desc,
        aliases: ["ReadBinaryFile"]
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
    provider_id: provider:readbinaryfile,
    category_id: NONE,
    is_active: true;

-- Service 304: ReadBinaryFiles
CREATE service:readbinaryfiles SET
    identity = {
        name: "ReadBinaryFiles",
        slug: "readbinaryfiles",
        display_name_i18n: i18n_key:service_readbinaryfiles_name,
        description_i18n: i18n_key:service_readbinaryfiles_desc,
        aliases: ["ReadBinaryFiles"]
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
    provider_id: provider:readbinaryfiles,
    category_id: NONE,
    is_active: true;

-- Service 305: ReadPDF
CREATE service:readpdf SET
    identity = {
        name: "ReadPDF",
        slug: "readpdf",
        display_name_i18n: i18n_key:service_readpdf_name,
        description_i18n: i18n_key:service_readpdf_desc,
        aliases: ["ReadPDF"]
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
    provider_id: provider:readpdf,
    category_id: NONE,
    is_active: true;

-- Service 306: Reddit
CREATE service:reddit SET
    identity = {
        name: "Reddit",
        slug: "reddit",
        display_name_i18n: i18n_key:service_reddit_name,
        description_i18n: i18n_key:service_reddit_desc,
        aliases: ["Reddit"]
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
    provider_id: provider:reddit,
    category_id: NONE,
    is_active: true;

-- Service 307: Redis
CREATE service:redis SET
    identity = {
        name: "Redis",
        slug: "redis",
        display_name_i18n: i18n_key:service_redis_name,
        description_i18n: i18n_key:service_redis_desc,
        aliases: ["Redis"]
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
    provider_id: provider:redis,
    category_id: NONE,
    is_active: true;

-- Service 308: RenameKeys
CREATE service:renamekeys SET
    identity = {
        name: "RenameKeys",
        slug: "renamekeys",
        display_name_i18n: i18n_key:service_renamekeys_name,
        description_i18n: i18n_key:service_renamekeys_desc,
        aliases: ["RenameKeys"]
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
    provider_id: provider:renamekeys,
    category_id: NONE,
    is_active: true;

-- Service 309: RespondToWebhook
CREATE service:respondtowebhook SET
    identity = {
        name: "RespondToWebhook",
        slug: "respondtowebhook",
        display_name_i18n: i18n_key:service_respondtowebhook_name,
        description_i18n: i18n_key:service_respondtowebhook_desc,
        aliases: ["RespondToWebhook"]
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
    provider_id: provider:respondtowebhook,
    category_id: NONE,
    is_active: true;

-- Service 310: Rocketchat
CREATE service:rocketchat SET
    identity = {
        name: "Rocketchat",
        slug: "rocketchat",
        display_name_i18n: i18n_key:service_rocketchat_name,
        description_i18n: i18n_key:service_rocketchat_desc,
        aliases: ["Rocketchat"]
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
    provider_id: provider:rocketchat,
    category_id: NONE,
    is_active: true;

-- Service 311: RssFeedRead
CREATE service:rssfeedread SET
    identity = {
        name: "RssFeedRead",
        slug: "rssfeedread",
        display_name_i18n: i18n_key:service_rssfeedread_name,
        description_i18n: i18n_key:service_rssfeedread_desc,
        aliases: ["RssFeedRead"]
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
    provider_id: provider:rssfeedread,
    category_id: NONE,
    is_active: true;

-- Service 312: Rundeck
CREATE service:rundeck SET
    identity = {
        name: "Rundeck",
        slug: "rundeck",
        display_name_i18n: i18n_key:service_rundeck_name,
        description_i18n: i18n_key:service_rundeck_desc,
        aliases: ["Rundeck"]
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
    provider_id: provider:rundeck,
    category_id: NONE,
    is_active: true;

-- Service 313: S3
CREATE service:s3 SET
    identity = {
        name: "S3",
        slug: "s3",
        display_name_i18n: i18n_key:service_s3_name,
        description_i18n: i18n_key:service_s3_desc,
        aliases: ["S3"]
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
    provider_id: provider:s3,
    category_id: NONE,
    is_active: true;

-- Service 314: Salesforce
CREATE service:salesforce SET
    identity = {
        name: "Salesforce",
        slug: "salesforce",
        display_name_i18n: i18n_key:service_salesforce_name,
        description_i18n: i18n_key:service_salesforce_desc,
        aliases: ["Salesforce"]
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
    provider_id: provider:salesforce,
    category_id: NONE,
    is_active: true;

-- Service 315: Salesmate
CREATE service:salesmate SET
    identity = {
        name: "Salesmate",
        slug: "salesmate",
        display_name_i18n: i18n_key:service_salesmate_name,
        description_i18n: i18n_key:service_salesmate_desc,
        aliases: ["Salesmate"]
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
    provider_id: provider:salesmate,
    category_id: NONE,
    is_active: true;

-- Service 316: SeaTable
CREATE service:seatable SET
    identity = {
        name: "SeaTable",
        slug: "seatable",
        display_name_i18n: i18n_key:service_seatable_name,
        description_i18n: i18n_key:service_seatable_desc,
        aliases: ["SeaTable"]
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
    provider_id: provider:seatable,
    category_id: NONE,
    is_active: true;

-- Service 317: SeaTable
CREATE service:seatable SET
    identity = {
        name: "SeaTable",
        slug: "seatable",
        display_name_i18n: i18n_key:service_seatable_name,
        description_i18n: i18n_key:service_seatable_desc,
        aliases: ["SeaTable"]
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
    provider_id: provider:seatable,
    category_id: NONE,
    is_active: true;

-- Service 318: SeaTableV1
CREATE service:seatablev1 SET
    identity = {
        name: "SeaTableV1",
        slug: "seatablev1",
        display_name_i18n: i18n_key:service_seatablev1_name,
        description_i18n: i18n_key:service_seatablev1_desc,
        aliases: ["SeaTableV1"]
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
    provider_id: provider:seatable,
    category_id: NONE,
    is_active: true;

-- Service 319: SeaTableV2
CREATE service:seatablev2 SET
    identity = {
        name: "SeaTableV2",
        slug: "seatablev2",
        display_name_i18n: i18n_key:service_seatablev2_name,
        description_i18n: i18n_key:service_seatablev2_desc,
        aliases: ["SeaTableV2"]
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
    provider_id: provider:seatable,
    category_id: NONE,
    is_active: true;

-- Service 320: SeaTable
CREATE service:seatable SET
    identity = {
        name: "SeaTable",
        slug: "seatable",
        display_name_i18n: i18n_key:service_seatable_name,
        description_i18n: i18n_key:service_seatable_desc,
        aliases: ["SeaTable"]
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
    provider_id: provider:seatable,
    category_id: NONE,
    is_active: true;

