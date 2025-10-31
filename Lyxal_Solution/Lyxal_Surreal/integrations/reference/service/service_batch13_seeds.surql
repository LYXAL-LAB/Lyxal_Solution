-- Batch 13: 20 services Lyxal

-- Service 241: MicrosoftTeamsV2
CREATE service:microsoftteamsv2 SET
    identity = {
        name: "MicrosoftTeamsV2",
        slug: "microsoftteamsv2",
        display_name_i18n: i18n_key:service_microsoftteamsv2_name,
        description_i18n: i18n_key:service_microsoftteamsv2_desc,
        aliases: ["MicrosoftTeamsV2"]
    },
    presentation = {
        icon: NONE,
        color: "#00A4EF",
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
    provider_id: provider:microsoft,
    category_id: NONE,
    is_active: true;

-- Service 242: MicrosoftToDo
CREATE service:microsofttodo SET
    identity = {
        name: "MicrosoftToDo",
        slug: "microsofttodo",
        display_name_i18n: i18n_key:service_microsofttodo_name,
        description_i18n: i18n_key:service_microsofttodo_desc,
        aliases: ["MicrosoftToDo"]
    },
    presentation = {
        icon: NONE,
        color: "#00A4EF",
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
    provider_id: provider:microsoft,
    category_id: NONE,
    is_active: true;

-- Service 243: Mindee
CREATE service:mindee SET
    identity = {
        name: "Mindee",
        slug: "mindee",
        display_name_i18n: i18n_key:service_mindee_name,
        description_i18n: i18n_key:service_mindee_desc,
        aliases: ["Mindee"]
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
    provider_id: provider:mindee,
    category_id: NONE,
    is_active: true;

-- Service 244: Misp
CREATE service:misp SET
    identity = {
        name: "Misp",
        slug: "misp",
        display_name_i18n: i18n_key:service_misp_name,
        description_i18n: i18n_key:service_misp_desc,
        aliases: ["Misp"]
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
    provider_id: provider:misp,
    category_id: NONE,
    is_active: true;

-- Service 245: MistralAi
CREATE service:mistralai SET
    identity = {
        name: "MistralAi",
        slug: "mistralai",
        display_name_i18n: i18n_key:service_mistralai_name,
        description_i18n: i18n_key:service_mistralai_desc,
        aliases: ["MistralAi"]
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
    provider_id: provider:mistralai,
    category_id: NONE,
    is_active: true;

-- Service 246: Mocean
CREATE service:mocean SET
    identity = {
        name: "Mocean",
        slug: "mocean",
        display_name_i18n: i18n_key:service_mocean_name,
        description_i18n: i18n_key:service_mocean_desc,
        aliases: ["Mocean"]
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
    provider_id: provider:mocean,
    category_id: NONE,
    is_active: true;

-- Service 247: MondayCom
CREATE service:mondaycom SET
    identity = {
        name: "MondayCom",
        slug: "mondaycom",
        display_name_i18n: i18n_key:service_mondaycom_name,
        description_i18n: i18n_key:service_mondaycom_desc,
        aliases: ["MondayCom"]
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
    provider_id: provider:mondaycom,
    category_id: NONE,
    is_active: true;

-- Service 248: MongoDb
CREATE service:mongodb SET
    identity = {
        name: "MongoDb",
        slug: "mongodb",
        display_name_i18n: i18n_key:service_mongodb_name,
        description_i18n: i18n_key:service_mongodb_desc,
        aliases: ["MongoDb"]
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
    provider_id: provider:mongodb,
    category_id: NONE,
    is_active: true;

-- Service 249: MonicaCrm
CREATE service:monicacrm SET
    identity = {
        name: "MonicaCrm",
        slug: "monicacrm",
        display_name_i18n: i18n_key:service_monicacrm_name,
        description_i18n: i18n_key:service_monicacrm_desc,
        aliases: ["MonicaCrm"]
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
    provider_id: provider:monicacrm,
    category_id: NONE,
    is_active: true;

-- Service 250: MoveBinaryData
CREATE service:movebinarydata SET
    identity = {
        name: "MoveBinaryData",
        slug: "movebinarydata",
        display_name_i18n: i18n_key:service_movebinarydata_name,
        description_i18n: i18n_key:service_movebinarydata_desc,
        aliases: ["MoveBinaryData"]
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
    provider_id: provider:movebinarydata,
    category_id: NONE,
    is_active: true;

-- Service 251: Mqtt
CREATE service:mqtt SET
    identity = {
        name: "Mqtt",
        slug: "mqtt",
        display_name_i18n: i18n_key:service_mqtt_name,
        description_i18n: i18n_key:service_mqtt_desc,
        aliases: ["Mqtt"]
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
    provider_id: provider:mqtt,
    category_id: NONE,
    is_active: true;

-- Service 252: Msg91
CREATE service:msg91 SET
    identity = {
        name: "Msg91",
        slug: "msg91",
        display_name_i18n: i18n_key:service_msg91_name,
        description_i18n: i18n_key:service_msg91_desc,
        aliases: ["Msg91"]
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
    provider_id: provider:msg91,
    category_id: NONE,
    is_active: true;

-- Service 253: MySql
CREATE service:mysql SET
    identity = {
        name: "MySql",
        slug: "mysql",
        display_name_i18n: i18n_key:service_mysql_name,
        description_i18n: i18n_key:service_mysql_desc,
        aliases: ["MySql"]
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
    provider_id: provider:mysql,
    category_id: NONE,
    is_active: true;

-- Service 254: MySqlV1
CREATE service:mysqlv1 SET
    identity = {
        name: "MySqlV1",
        slug: "mysqlv1",
        display_name_i18n: i18n_key:service_mysqlv1_name,
        description_i18n: i18n_key:service_mysqlv1_desc,
        aliases: ["MySqlV1"]
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
    provider_id: provider:mysql,
    category_id: NONE,
    is_active: true;

-- Service 255: MySqlV2
CREATE service:mysqlv2 SET
    identity = {
        name: "MySqlV2",
        slug: "mysqlv2",
        display_name_i18n: i18n_key:service_mysqlv2_name,
        description_i18n: i18n_key:service_mysqlv2_desc,
        aliases: ["MySqlV2"]
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
    provider_id: provider:mysql,
    category_id: NONE,
    is_active: true;

-- Service 256: N8n
CREATE service:n8n SET
    identity = {
        name: "N8n",
        slug: "n8n",
        display_name_i18n: i18n_key:service_n8n_name,
        description_i18n: i18n_key:service_n8n_desc,
        aliases: ["N8n"]
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
    provider_id: provider:n8n,
    category_id: NONE,
    is_active: true;

-- Service 257: N8nTrainingCustomerDatastore
CREATE service:n8ntrainingcustomerdatastore SET
    identity = {
        name: "N8nTrainingCustomerDatastore",
        slug: "n8ntrainingcustomerdatastore",
        display_name_i18n: i18n_key:service_n8ntrainingcustomerdatastore_name,
        description_i18n: i18n_key:service_n8ntrainingcustomerdatastore_desc,
        aliases: ["N8nTrainingCustomerDatastore"]
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
    provider_id: provider:n8ntrainingcustomerdatastore,
    category_id: NONE,
    is_active: true;

-- Service 258: N8nTrainingCustomerMessenger
CREATE service:n8ntrainingcustomermessenger SET
    identity = {
        name: "N8nTrainingCustomerMessenger",
        slug: "n8ntrainingcustomermessenger",
        display_name_i18n: i18n_key:service_n8ntrainingcustomermessenger_name,
        description_i18n: i18n_key:service_n8ntrainingcustomermessenger_desc,
        aliases: ["N8nTrainingCustomerMessenger"]
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
    provider_id: provider:n8ntrainingcustomermessenger,
    category_id: NONE,
    is_active: true;

-- Service 259: Nasa
CREATE service:nasa SET
    identity = {
        name: "Nasa",
        slug: "nasa",
        display_name_i18n: i18n_key:service_nasa_name,
        description_i18n: i18n_key:service_nasa_desc,
        aliases: ["Nasa"]
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
    provider_id: provider:nasa,
    category_id: NONE,
    is_active: true;

-- Service 260: Netlify
CREATE service:netlify SET
    identity = {
        name: "Netlify",
        slug: "netlify",
        display_name_i18n: i18n_key:service_netlify_name,
        description_i18n: i18n_key:service_netlify_desc,
        aliases: ["Netlify"]
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
    provider_id: provider:netlify,
    category_id: NONE,
    is_active: true;

