-- Batch 10: 20 services Lyxal

-- Service 181: ItemLists
CREATE service:itemlists SET
    identity = {
        name: "ItemLists",
        slug: "itemlists",
        display_name_i18n: i18n_key:service_itemlists_name,
        description_i18n: i18n_key:service_itemlists_desc,
        aliases: ["ItemLists"]
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
    provider_id: provider:itemlists,
    category_id: NONE,
    is_active: true;

-- Service 182: ItemListsV1
CREATE service:itemlistsv1 SET
    identity = {
        name: "ItemListsV1",
        slug: "itemlistsv1",
        display_name_i18n: i18n_key:service_itemlistsv1_name,
        description_i18n: i18n_key:service_itemlistsv1_desc,
        aliases: ["ItemListsV1"]
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
    provider_id: provider:itemlists,
    category_id: NONE,
    is_active: true;

-- Service 183: ItemListsV2
CREATE service:itemlistsv2 SET
    identity = {
        name: "ItemListsV2",
        slug: "itemlistsv2",
        display_name_i18n: i18n_key:service_itemlistsv2_name,
        description_i18n: i18n_key:service_itemlistsv2_desc,
        aliases: ["ItemListsV2"]
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
    provider_id: provider:itemlists,
    category_id: NONE,
    is_active: true;

-- Service 184: ItemListsV3
CREATE service:itemlistsv3 SET
    identity = {
        name: "ItemListsV3",
        slug: "itemlistsv3",
        display_name_i18n: i18n_key:service_itemlistsv3_name,
        description_i18n: i18n_key:service_itemlistsv3_desc,
        aliases: ["ItemListsV3"]
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
    provider_id: provider:itemlists,
    category_id: NONE,
    is_active: true;

-- Service 185: Iterable
CREATE service:iterable SET
    identity = {
        name: "Iterable",
        slug: "iterable",
        display_name_i18n: i18n_key:service_iterable_name,
        description_i18n: i18n_key:service_iterable_desc,
        aliases: ["Iterable"]
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
    provider_id: provider:iterable,
    category_id: NONE,
    is_active: true;

-- Service 186: Jenkins
CREATE service:jenkins SET
    identity = {
        name: "Jenkins",
        slug: "jenkins",
        display_name_i18n: i18n_key:service_jenkins_name,
        description_i18n: i18n_key:service_jenkins_desc,
        aliases: ["Jenkins"]
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
    provider_id: provider:jenkins,
    category_id: NONE,
    is_active: true;

-- Service 187: JinaAi
CREATE service:jinaai SET
    identity = {
        name: "JinaAi",
        slug: "jinaai",
        display_name_i18n: i18n_key:service_jinaai_name,
        description_i18n: i18n_key:service_jinaai_desc,
        aliases: ["JinaAi"]
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
    provider_id: provider:jinaai,
    category_id: NONE,
    is_active: true;

-- Service 188: Jira
CREATE service:jira SET
    identity = {
        name: "Jira",
        slug: "jira",
        display_name_i18n: i18n_key:service_jira_name,
        description_i18n: i18n_key:service_jira_desc,
        aliases: ["Jira"]
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
    provider_id: provider:jira,
    category_id: NONE,
    is_active: true;

-- Service 189: Jwt
CREATE service:jwt SET
    identity = {
        name: "Jwt",
        slug: "jwt",
        display_name_i18n: i18n_key:service_jwt_name,
        description_i18n: i18n_key:service_jwt_desc,
        aliases: ["Jwt"]
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
    provider_id: provider:jwt,
    category_id: NONE,
    is_active: true;

-- Service 190: Kafka
CREATE service:kafka SET
    identity = {
        name: "Kafka",
        slug: "kafka",
        display_name_i18n: i18n_key:service_kafka_name,
        description_i18n: i18n_key:service_kafka_desc,
        aliases: ["Kafka"]
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
    provider_id: provider:kafka,
    category_id: NONE,
    is_active: true;

-- Service 191: Keap
CREATE service:keap SET
    identity = {
        name: "Keap",
        slug: "keap",
        display_name_i18n: i18n_key:service_keap_name,
        description_i18n: i18n_key:service_keap_desc,
        aliases: ["Keap"]
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
    provider_id: provider:keap,
    category_id: NONE,
    is_active: true;

-- Service 192: Kitemaker
CREATE service:kitemaker SET
    identity = {
        name: "Kitemaker",
        slug: "kitemaker",
        display_name_i18n: i18n_key:service_kitemaker_name,
        description_i18n: i18n_key:service_kitemaker_desc,
        aliases: ["Kitemaker"]
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
    provider_id: provider:kitemaker,
    category_id: NONE,
    is_active: true;

-- Service 193: KoBoToolbox
CREATE service:kobotoolbox SET
    identity = {
        name: "KoBoToolbox",
        slug: "kobotoolbox",
        display_name_i18n: i18n_key:service_kobotoolbox_name,
        description_i18n: i18n_key:service_kobotoolbox_desc,
        aliases: ["KoBoToolbox"]
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
    provider_id: provider:kobotoolbox,
    category_id: NONE,
    is_active: true;

-- Service 194: Ldap
CREATE service:ldap SET
    identity = {
        name: "Ldap",
        slug: "ldap",
        display_name_i18n: i18n_key:service_ldap_name,
        description_i18n: i18n_key:service_ldap_desc,
        aliases: ["Ldap"]
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
    provider_id: provider:ldap,
    category_id: NONE,
    is_active: true;

-- Service 195: Lemlist
CREATE service:lemlist SET
    identity = {
        name: "Lemlist",
        slug: "lemlist",
        display_name_i18n: i18n_key:service_lemlist_name,
        description_i18n: i18n_key:service_lemlist_desc,
        aliases: ["Lemlist"]
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
    provider_id: provider:lemlist,
    category_id: NONE,
    is_active: true;

-- Service 196: LemlistV1
CREATE service:lemlistv1 SET
    identity = {
        name: "LemlistV1",
        slug: "lemlistv1",
        display_name_i18n: i18n_key:service_lemlistv1_name,
        description_i18n: i18n_key:service_lemlistv1_desc,
        aliases: ["LemlistV1"]
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
    provider_id: provider:lemlist,
    category_id: NONE,
    is_active: true;

-- Service 197: LemlistV2
CREATE service:lemlistv2 SET
    identity = {
        name: "LemlistV2",
        slug: "lemlistv2",
        display_name_i18n: i18n_key:service_lemlistv2_name,
        description_i18n: i18n_key:service_lemlistv2_desc,
        aliases: ["LemlistV2"]
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
    provider_id: provider:lemlist,
    category_id: NONE,
    is_active: true;

-- Service 198: Line
CREATE service:line SET
    identity = {
        name: "Line",
        slug: "line",
        display_name_i18n: i18n_key:service_line_name,
        description_i18n: i18n_key:service_line_desc,
        aliases: ["Line"]
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
    provider_id: provider:line,
    category_id: NONE,
    is_active: true;

-- Service 199: Linear
CREATE service:linear SET
    identity = {
        name: "Linear",
        slug: "linear",
        display_name_i18n: i18n_key:service_linear_name,
        description_i18n: i18n_key:service_linear_desc,
        aliases: ["Linear"]
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
    provider_id: provider:linear,
    category_id: NONE,
    is_active: true;

-- Service 200: LingvaNex
CREATE service:lingvanex SET
    identity = {
        name: "LingvaNex",
        slug: "lingvanex",
        display_name_i18n: i18n_key:service_lingvanex_name,
        description_i18n: i18n_key:service_lingvanex_desc,
        aliases: ["LingvaNex"]
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
    provider_id: provider:lingvanex,
    category_id: NONE,
    is_active: true;

