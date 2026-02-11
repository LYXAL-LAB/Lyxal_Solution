-- Batch 8: 20 services Lyxal

-- Service 141: GSuiteAdmin
CREATE service:gsuiteadmin SET
    identity = {
        name: "GSuiteAdmin",
        slug: "gsuiteadmin",
        display_name_i18n: i18n_key:service_gsuiteadmin_name,
        description_i18n: i18n_key:service_gsuiteadmin_desc,
        aliases: ["GSuiteAdmin"]
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

-- Service 142: GooglePerspective
CREATE service:googleperspective SET
    identity = {
        name: "GooglePerspective",
        slug: "googleperspective",
        display_name_i18n: i18n_key:service_googleperspective_name,
        description_i18n: i18n_key:service_googleperspective_desc,
        aliases: ["GooglePerspective"]
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

-- Service 143: GoogleSheets
CREATE service:googlesheets SET
    identity = {
        name: "GoogleSheets",
        slug: "googlesheets",
        display_name_i18n: i18n_key:service_googlesheets_name,
        description_i18n: i18n_key:service_googlesheets_desc,
        aliases: ["GoogleSheets"]
    },
    presentation = {
        icon: NONE,
        color: "#4285F4",
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
    provider_id: provider:google,
    category_id: NONE,
    is_active: true;

-- Service 144: GoogleSheetsV1
CREATE service:googlesheetsv1 SET
    identity = {
        name: "GoogleSheetsV1",
        slug: "googlesheetsv1",
        display_name_i18n: i18n_key:service_googlesheetsv1_name,
        description_i18n: i18n_key:service_googlesheetsv1_desc,
        aliases: ["GoogleSheetsV1"]
    },
    presentation = {
        icon: NONE,
        color: "#4285F4",
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
    provider_id: provider:google,
    category_id: NONE,
    is_active: true;

-- Service 145: GoogleSheetsV2
CREATE service:googlesheetsv2 SET
    identity = {
        name: "GoogleSheetsV2",
        slug: "googlesheetsv2",
        display_name_i18n: i18n_key:service_googlesheetsv2_name,
        description_i18n: i18n_key:service_googlesheetsv2_desc,
        aliases: ["GoogleSheetsV2"]
    },
    presentation = {
        icon: NONE,
        color: "#4285F4",
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
    provider_id: provider:google,
    category_id: NONE,
    is_active: true;

-- Service 146: GoogleSlides
CREATE service:googleslides SET
    identity = {
        name: "GoogleSlides",
        slug: "googleslides",
        display_name_i18n: i18n_key:service_googleslides_name,
        description_i18n: i18n_key:service_googleslides_desc,
        aliases: ["GoogleSlides"]
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

-- Service 147: GoogleTasks
CREATE service:googletasks SET
    identity = {
        name: "GoogleTasks",
        slug: "googletasks",
        display_name_i18n: i18n_key:service_googletasks_name,
        description_i18n: i18n_key:service_googletasks_desc,
        aliases: ["GoogleTasks"]
    },
    presentation = {
        icon: NONE,
        color: "#4285F4",
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
    provider_id: provider:google,
    category_id: NONE,
    is_active: true;

-- Service 148: GoogleTranslate
CREATE service:googletranslate SET
    identity = {
        name: "GoogleTranslate",
        slug: "googletranslate",
        display_name_i18n: i18n_key:service_googletranslate_name,
        description_i18n: i18n_key:service_googletranslate_desc,
        aliases: ["GoogleTranslate"]
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

-- Service 149: YouTube
CREATE service:youtube SET
    identity = {
        name: "YouTube",
        slug: "youtube",
        display_name_i18n: i18n_key:service_youtube_name,
        description_i18n: i18n_key:service_youtube_desc,
        aliases: ["YouTube"]
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

-- Service 150: Gotify
CREATE service:gotify SET
    identity = {
        name: "Gotify",
        slug: "gotify",
        display_name_i18n: i18n_key:service_gotify_name,
        description_i18n: i18n_key:service_gotify_desc,
        aliases: ["Gotify"]
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
    provider_id: provider:gotify,
    category_id: NONE,
    is_active: true;

-- Service 151: GoToWebinar
CREATE service:gotowebinar SET
    identity = {
        name: "GoToWebinar",
        slug: "gotowebinar",
        display_name_i18n: i18n_key:service_gotowebinar_name,
        description_i18n: i18n_key:service_gotowebinar_desc,
        aliases: ["GoToWebinar"]
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
    provider_id: provider:gotowebinar,
    category_id: NONE,
    is_active: true;

-- Service 152: Grafana
CREATE service:grafana SET
    identity = {
        name: "Grafana",
        slug: "grafana",
        display_name_i18n: i18n_key:service_grafana_name,
        description_i18n: i18n_key:service_grafana_desc,
        aliases: ["Grafana"]
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
    provider_id: provider:grafana,
    category_id: NONE,
    is_active: true;

-- Service 153: GraphQL
CREATE service:graphql SET
    identity = {
        name: "GraphQL",
        slug: "graphql",
        display_name_i18n: i18n_key:service_graphql_name,
        description_i18n: i18n_key:service_graphql_desc,
        aliases: ["GraphQL"]
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
    provider_id: provider:graphql,
    category_id: NONE,
    is_active: true;

-- Service 154: Grist
CREATE service:grist SET
    identity = {
        name: "Grist",
        slug: "grist",
        display_name_i18n: i18n_key:service_grist_name,
        description_i18n: i18n_key:service_grist_desc,
        aliases: ["Grist"]
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
    provider_id: provider:grist,
    category_id: NONE,
    is_active: true;

-- Service 155: HackerNews
CREATE service:hackernews SET
    identity = {
        name: "HackerNews",
        slug: "hackernews",
        display_name_i18n: i18n_key:service_hackernews_name,
        description_i18n: i18n_key:service_hackernews_desc,
        aliases: ["HackerNews"]
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
    provider_id: provider:hackernews,
    category_id: NONE,
    is_active: true;

-- Service 156: HaloPSA
CREATE service:halopsa SET
    identity = {
        name: "HaloPSA",
        slug: "halopsa",
        display_name_i18n: i18n_key:service_halopsa_name,
        description_i18n: i18n_key:service_halopsa_desc,
        aliases: ["HaloPSA"]
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
    provider_id: provider:halopsa,
    category_id: NONE,
    is_active: true;

-- Service 157: Harvest
CREATE service:harvest SET
    identity = {
        name: "Harvest",
        slug: "harvest",
        display_name_i18n: i18n_key:service_harvest_name,
        description_i18n: i18n_key:service_harvest_desc,
        aliases: ["Harvest"]
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
    provider_id: provider:harvest,
    category_id: NONE,
    is_active: true;

-- Service 158: HelpScout
CREATE service:helpscout SET
    identity = {
        name: "HelpScout",
        slug: "helpscout",
        display_name_i18n: i18n_key:service_helpscout_name,
        description_i18n: i18n_key:service_helpscout_desc,
        aliases: ["HelpScout"]
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
    provider_id: provider:helpscout,
    category_id: NONE,
    is_active: true;

-- Service 159: HighLevel
CREATE service:highlevel SET
    identity = {
        name: "HighLevel",
        slug: "highlevel",
        display_name_i18n: i18n_key:service_highlevel_name,
        description_i18n: i18n_key:service_highlevel_desc,
        aliases: ["HighLevel"]
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
    provider_id: provider:highlevel,
    category_id: NONE,
    is_active: true;

-- Service 160: HighLevelV1
CREATE service:highlevelv1 SET
    identity = {
        name: "HighLevelV1",
        slug: "highlevelv1",
        display_name_i18n: i18n_key:service_highlevelv1_name,
        description_i18n: i18n_key:service_highlevelv1_desc,
        aliases: ["HighLevelV1"]
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
    provider_id: provider:highlevel,
    category_id: NONE,
    is_active: true;

