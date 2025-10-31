-- Batch 12: 20 services Lyxal

-- Service 221: MergeV2
CREATE service:mergev2 SET
    identity = {
        name: "MergeV2",
        slug: "mergev2",
        display_name_i18n: i18n_key:service_mergev2_name,
        description_i18n: i18n_key:service_mergev2_desc,
        aliases: ["MergeV2"]
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
    provider_id: provider:merge,
    category_id: NONE,
    is_active: true;

-- Service 222: MergeV3
CREATE service:mergev3 SET
    identity = {
        name: "MergeV3",
        slug: "mergev3",
        display_name_i18n: i18n_key:service_mergev3_name,
        description_i18n: i18n_key:service_mergev3_desc,
        aliases: ["MergeV3"]
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
    provider_id: provider:merge,
    category_id: NONE,
    is_active: true;

-- Service 223: MessageBird
CREATE service:messagebird SET
    identity = {
        name: "MessageBird",
        slug: "messagebird",
        display_name_i18n: i18n_key:service_messagebird_name,
        description_i18n: i18n_key:service_messagebird_desc,
        aliases: ["MessageBird"]
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
    provider_id: provider:messagebird,
    category_id: NONE,
    is_active: true;

-- Service 224: Metabase
CREATE service:metabase SET
    identity = {
        name: "Metabase",
        slug: "metabase",
        display_name_i18n: i18n_key:service_metabase_name,
        description_i18n: i18n_key:service_metabase_desc,
        aliases: ["Metabase"]
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
    provider_id: provider:metabase,
    category_id: NONE,
    is_active: true;

-- Service 225: AzureCosmosDb
CREATE service:azurecosmosdb SET
    identity = {
        name: "AzureCosmosDb",
        slug: "azurecosmosdb",
        display_name_i18n: i18n_key:service_azurecosmosdb_name,
        description_i18n: i18n_key:service_azurecosmosdb_desc,
        aliases: ["AzureCosmosDb"]
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

-- Service 226: MicrosoftDynamicsCrm
CREATE service:microsoftdynamicscrm SET
    identity = {
        name: "MicrosoftDynamicsCrm",
        slug: "microsoftdynamicscrm",
        display_name_i18n: i18n_key:service_microsoftdynamicscrm_name,
        description_i18n: i18n_key:service_microsoftdynamicscrm_desc,
        aliases: ["MicrosoftDynamicsCrm"]
    },
    presentation = {
        icon: NONE,
        color: "#00A4EF",
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
    provider_id: provider:microsoft,
    category_id: NONE,
    is_active: true;

-- Service 227: MicrosoftEntra
CREATE service:microsoftentra SET
    identity = {
        name: "MicrosoftEntra",
        slug: "microsoftentra",
        display_name_i18n: i18n_key:service_microsoftentra_name,
        description_i18n: i18n_key:service_microsoftentra_desc,
        aliases: ["MicrosoftEntra"]
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

-- Service 228: MicrosoftExcel
CREATE service:microsoftexcel SET
    identity = {
        name: "MicrosoftExcel",
        slug: "microsoftexcel",
        display_name_i18n: i18n_key:service_microsoftexcel_name,
        description_i18n: i18n_key:service_microsoftexcel_desc,
        aliases: ["MicrosoftExcel"]
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

-- Service 229: MicrosoftExcelV1
CREATE service:microsoftexcelv1 SET
    identity = {
        name: "MicrosoftExcelV1",
        slug: "microsoftexcelv1",
        display_name_i18n: i18n_key:service_microsoftexcelv1_name,
        description_i18n: i18n_key:service_microsoftexcelv1_desc,
        aliases: ["MicrosoftExcelV1"]
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

-- Service 230: MicrosoftExcelV2
CREATE service:microsoftexcelv2 SET
    identity = {
        name: "MicrosoftExcelV2",
        slug: "microsoftexcelv2",
        display_name_i18n: i18n_key:service_microsoftexcelv2_name,
        description_i18n: i18n_key:service_microsoftexcelv2_desc,
        aliases: ["MicrosoftExcelV2"]
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

-- Service 231: MicrosoftGraphSecurity
CREATE service:microsoftgraphsecurity SET
    identity = {
        name: "MicrosoftGraphSecurity",
        slug: "microsoftgraphsecurity",
        display_name_i18n: i18n_key:service_microsoftgraphsecurity_name,
        description_i18n: i18n_key:service_microsoftgraphsecurity_desc,
        aliases: ["MicrosoftGraphSecurity"]
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

-- Service 232: MicrosoftOneDrive
CREATE service:microsoftonedrive SET
    identity = {
        name: "MicrosoftOneDrive",
        slug: "microsoftonedrive",
        display_name_i18n: i18n_key:service_microsoftonedrive_name,
        description_i18n: i18n_key:service_microsoftonedrive_desc,
        aliases: ["MicrosoftOneDrive"]
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

-- Service 233: MicrosoftOutlook
CREATE service:microsoftoutlook SET
    identity = {
        name: "MicrosoftOutlook",
        slug: "microsoftoutlook",
        display_name_i18n: i18n_key:service_microsoftoutlook_name,
        description_i18n: i18n_key:service_microsoftoutlook_desc,
        aliases: ["MicrosoftOutlook"]
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

-- Service 234: MicrosoftOutlookV1
CREATE service:microsoftoutlookv1 SET
    identity = {
        name: "MicrosoftOutlookV1",
        slug: "microsoftoutlookv1",
        display_name_i18n: i18n_key:service_microsoftoutlookv1_name,
        description_i18n: i18n_key:service_microsoftoutlookv1_desc,
        aliases: ["MicrosoftOutlookV1"]
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

-- Service 235: MicrosoftOutlookV2
CREATE service:microsoftoutlookv2 SET
    identity = {
        name: "MicrosoftOutlookV2",
        slug: "microsoftoutlookv2",
        display_name_i18n: i18n_key:service_microsoftoutlookv2_name,
        description_i18n: i18n_key:service_microsoftoutlookv2_desc,
        aliases: ["MicrosoftOutlookV2"]
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

-- Service 236: MicrosoftSharePoint
CREATE service:microsoftsharepoint SET
    identity = {
        name: "MicrosoftSharePoint",
        slug: "microsoftsharepoint",
        display_name_i18n: i18n_key:service_microsoftsharepoint_name,
        description_i18n: i18n_key:service_microsoftsharepoint_desc,
        aliases: ["MicrosoftSharePoint"]
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

-- Service 237: MicrosoftSql
CREATE service:microsoftsql SET
    identity = {
        name: "MicrosoftSql",
        slug: "microsoftsql",
        display_name_i18n: i18n_key:service_microsoftsql_name,
        description_i18n: i18n_key:service_microsoftsql_desc,
        aliases: ["MicrosoftSql"]
    },
    presentation = {
        icon: NONE,
        color: "#00A4EF",
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
    provider_id: provider:microsoft,
    category_id: NONE,
    is_active: true;

-- Service 238: AzureStorage
CREATE service:azurestorage SET
    identity = {
        name: "AzureStorage",
        slug: "azurestorage",
        display_name_i18n: i18n_key:service_azurestorage_name,
        description_i18n: i18n_key:service_azurestorage_desc,
        aliases: ["AzureStorage"]
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

-- Service 239: MicrosoftTeams
CREATE service:microsoftteams SET
    identity = {
        name: "MicrosoftTeams",
        slug: "microsoftteams",
        display_name_i18n: i18n_key:service_microsoftteams_name,
        description_i18n: i18n_key:service_microsoftteams_desc,
        aliases: ["MicrosoftTeams"]
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

-- Service 240: MicrosoftTeamsV1
CREATE service:microsoftteamsv1 SET
    identity = {
        name: "MicrosoftTeamsV1",
        slug: "microsoftteamsv1",
        display_name_i18n: i18n_key:service_microsoftteamsv1_name,
        description_i18n: i18n_key:service_microsoftteamsv1_desc,
        aliases: ["MicrosoftTeamsV1"]
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

