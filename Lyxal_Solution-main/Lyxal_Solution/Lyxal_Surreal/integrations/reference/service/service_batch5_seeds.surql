-- Batch 5: 20 services Lyxal

-- Service 81: Egoi
CREATE service:egoi SET
    identity = {
        name: "Egoi",
        slug: "egoi",
        display_name_i18n: i18n_key:service_egoi_name,
        description_i18n: i18n_key:service_egoi_desc,
        aliases: ["Egoi"]
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
    provider_id: provider:egoi,
    category_id: NONE,
    is_active: true;

-- Service 82: Elasticsearch
CREATE service:elasticsearch SET
    identity = {
        name: "Elasticsearch",
        slug: "elasticsearch",
        display_name_i18n: i18n_key:service_elasticsearch_name,
        description_i18n: i18n_key:service_elasticsearch_desc,
        aliases: ["Elasticsearch"]
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
    provider_id: provider:elastic,
    category_id: NONE,
    is_active: true;

-- Service 83: ElasticSecurity
CREATE service:elasticsecurity SET
    identity = {
        name: "ElasticSecurity",
        slug: "elasticsecurity",
        display_name_i18n: i18n_key:service_elasticsecurity_name,
        description_i18n: i18n_key:service_elasticsecurity_desc,
        aliases: ["ElasticSecurity"]
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
    provider_id: provider:elastic,
    category_id: NONE,
    is_active: true;

-- Service 84: EmailReadImap
CREATE service:emailreadimap SET
    identity = {
        name: "EmailReadImap",
        slug: "emailreadimap",
        display_name_i18n: i18n_key:service_emailreadimap_name,
        description_i18n: i18n_key:service_emailreadimap_desc,
        aliases: ["EmailReadImap"]
    },
    presentation = {
        icon: NONE,
        color: "#5C6AC4",
        display_order: 0,
        category_slug: "communication",
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
        tags: ["communication"],
        popularity_score: NONE,
        last_updated_by: NONE,
        custom_data: NONE
    },
    provider_id: provider:emailreadimap,
    category_id: NONE,
    is_active: true;

-- Service 85: EmailReadImapV1
CREATE service:emailreadimapv1 SET
    identity = {
        name: "EmailReadImapV1",
        slug: "emailreadimapv1",
        display_name_i18n: i18n_key:service_emailreadimapv1_name,
        description_i18n: i18n_key:service_emailreadimapv1_desc,
        aliases: ["EmailReadImapV1"]
    },
    presentation = {
        icon: NONE,
        color: "#5C6AC4",
        display_order: 0,
        category_slug: "communication",
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
        tags: ["communication"],
        popularity_score: NONE,
        last_updated_by: NONE,
        custom_data: NONE
    },
    provider_id: provider:emailreadimap,
    category_id: NONE,
    is_active: true;

-- Service 86: EmailReadImapV2
CREATE service:emailreadimapv2 SET
    identity = {
        name: "EmailReadImapV2",
        slug: "emailreadimapv2",
        display_name_i18n: i18n_key:service_emailreadimapv2_name,
        description_i18n: i18n_key:service_emailreadimapv2_desc,
        aliases: ["EmailReadImapV2"]
    },
    presentation = {
        icon: NONE,
        color: "#5C6AC4",
        display_order: 0,
        category_slug: "communication",
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
        tags: ["communication"],
        popularity_score: NONE,
        last_updated_by: NONE,
        custom_data: NONE
    },
    provider_id: provider:emailreadimap,
    category_id: NONE,
    is_active: true;

-- Service 87: EmailSend
CREATE service:emailsend SET
    identity = {
        name: "EmailSend",
        slug: "emailsend",
        display_name_i18n: i18n_key:service_emailsend_name,
        description_i18n: i18n_key:service_emailsend_desc,
        aliases: ["EmailSend"]
    },
    presentation = {
        icon: NONE,
        color: "#5C6AC4",
        display_order: 0,
        category_slug: "communication",
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
        tags: ["communication"],
        popularity_score: NONE,
        last_updated_by: NONE,
        custom_data: NONE
    },
    provider_id: provider:emailsend,
    category_id: NONE,
    is_active: true;

-- Service 88: EmailSendV1
CREATE service:emailsendv1 SET
    identity = {
        name: "EmailSendV1",
        slug: "emailsendv1",
        display_name_i18n: i18n_key:service_emailsendv1_name,
        description_i18n: i18n_key:service_emailsendv1_desc,
        aliases: ["EmailSendV1"]
    },
    presentation = {
        icon: NONE,
        color: "#5C6AC4",
        display_order: 0,
        category_slug: "communication",
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
        tags: ["communication"],
        popularity_score: NONE,
        last_updated_by: NONE,
        custom_data: NONE
    },
    provider_id: provider:emailsend,
    category_id: NONE,
    is_active: true;

-- Service 89: EmailSendV2
CREATE service:emailsendv2 SET
    identity = {
        name: "EmailSendV2",
        slug: "emailsendv2",
        display_name_i18n: i18n_key:service_emailsendv2_name,
        description_i18n: i18n_key:service_emailsendv2_desc,
        aliases: ["EmailSendV2"]
    },
    presentation = {
        icon: NONE,
        color: "#5C6AC4",
        display_order: 0,
        category_slug: "communication",
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
        tags: ["communication"],
        popularity_score: NONE,
        last_updated_by: NONE,
        custom_data: NONE
    },
    provider_id: provider:emailsend,
    category_id: NONE,
    is_active: true;

-- Service 90: Emelia
CREATE service:emelia SET
    identity = {
        name: "Emelia",
        slug: "emelia",
        display_name_i18n: i18n_key:service_emelia_name,
        description_i18n: i18n_key:service_emelia_desc,
        aliases: ["Emelia"]
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
    provider_id: provider:emelia,
    category_id: NONE,
    is_active: true;

-- Service 91: ERPNext
CREATE service:erpnext SET
    identity = {
        name: "ERPNext",
        slug: "erpnext",
        display_name_i18n: i18n_key:service_erpnext_name,
        description_i18n: i18n_key:service_erpnext_desc,
        aliases: ["ERPNext"]
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
    provider_id: provider:erpnext,
    category_id: NONE,
    is_active: true;

-- Service 92: Description
CREATE service:description SET
    identity = {
        name: "Description",
        slug: "description",
        display_name_i18n: i18n_key:service_description_name,
        description_i18n: i18n_key:service_description_desc,
        aliases: ["Description"]
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
    provider_id: provider:evaluation,
    category_id: NONE,
    is_active: true;

-- Service 93: ExecuteCommand
CREATE service:executecommand SET
    identity = {
        name: "ExecuteCommand",
        slug: "executecommand",
        display_name_i18n: i18n_key:service_executecommand_name,
        description_i18n: i18n_key:service_executecommand_desc,
        aliases: ["ExecuteCommand"]
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
    provider_id: provider:executecommand,
    category_id: NONE,
    is_active: true;

-- Service 94: ExecuteWorkflow
CREATE service:executeworkflow SET
    identity = {
        name: "ExecuteWorkflow",
        slug: "executeworkflow",
        display_name_i18n: i18n_key:service_executeworkflow_name,
        description_i18n: i18n_key:service_executeworkflow_desc,
        aliases: ["ExecuteWorkflow"]
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
    provider_id: provider:executeworkflow,
    category_id: NONE,
    is_active: true;

-- Service 95: ExecutionData
CREATE service:executiondata SET
    identity = {
        name: "ExecutionData",
        slug: "executiondata",
        display_name_i18n: i18n_key:service_executiondata_name,
        description_i18n: i18n_key:service_executiondata_desc,
        aliases: ["ExecutionData"]
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
    provider_id: provider:executiondata,
    category_id: NONE,
    is_active: true;

-- Service 96: FacebookGraphApi
CREATE service:facebookgraphapi SET
    identity = {
        name: "FacebookGraphApi",
        slug: "facebookgraphapi",
        display_name_i18n: i18n_key:service_facebookgraphapi_name,
        description_i18n: i18n_key:service_facebookgraphapi_desc,
        aliases: ["FacebookGraphApi"]
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
    provider_id: provider:facebook,
    category_id: NONE,
    is_active: true;

-- Service 97: FileMaker
CREATE service:filemaker SET
    identity = {
        name: "FileMaker",
        slug: "filemaker",
        display_name_i18n: i18n_key:service_filemaker_name,
        description_i18n: i18n_key:service_filemaker_desc,
        aliases: ["FileMaker"]
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
    provider_id: provider:filemaker,
    category_id: NONE,
    is_active: true;

-- Service 98: ConvertToFile
CREATE service:converttofile SET
    identity = {
        name: "ConvertToFile",
        slug: "converttofile",
        display_name_i18n: i18n_key:service_converttofile_name,
        description_i18n: i18n_key:service_converttofile_desc,
        aliases: ["ConvertToFile"]
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
    provider_id: provider:files,
    category_id: NONE,
    is_active: true;

-- Service 99: ExtractFromFile
CREATE service:extractfromfile SET
    identity = {
        name: "ExtractFromFile",
        slug: "extractfromfile",
        display_name_i18n: i18n_key:service_extractfromfile_name,
        description_i18n: i18n_key:service_extractfromfile_desc,
        aliases: ["ExtractFromFile"]
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
    provider_id: provider:files,
    category_id: NONE,
    is_active: true;

-- Service 100: ReadWriteFile
CREATE service:readwritefile SET
    identity = {
        name: "ReadWriteFile",
        slug: "readwritefile",
        display_name_i18n: i18n_key:service_readwritefile_name,
        description_i18n: i18n_key:service_readwritefile_desc,
        aliases: ["ReadWriteFile"]
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
    provider_id: provider:files,
    category_id: NONE,
    is_active: true;

