-- Batch 11: 20 services Lyxal

-- Service 201: LinkedIn
CREATE service:linkedin SET
    identity = {
        name: "LinkedIn",
        slug: "linkedin",
        display_name_i18n: i18n_key:service_linkedin_name,
        description_i18n: i18n_key:service_linkedin_desc,
        aliases: ["LinkedIn"]
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
    provider_id: provider:linkedin,
    category_id: NONE,
    is_active: true;

-- Service 202: LoneScale
CREATE service:lonescale SET
    identity = {
        name: "LoneScale",
        slug: "lonescale",
        display_name_i18n: i18n_key:service_lonescale_name,
        description_i18n: i18n_key:service_lonescale_desc,
        aliases: ["LoneScale"]
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
    provider_id: provider:lonescale,
    category_id: NONE,
    is_active: true;

-- Service 203: Magento2
CREATE service:magento2 SET
    identity = {
        name: "Magento2",
        slug: "magento2",
        display_name_i18n: i18n_key:service_magento2_name,
        description_i18n: i18n_key:service_magento2_desc,
        aliases: ["Magento2"]
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
    provider_id: provider:magento,
    category_id: NONE,
    is_active: true;

-- Service 204: Mailcheck
CREATE service:mailcheck SET
    identity = {
        name: "Mailcheck",
        slug: "mailcheck",
        display_name_i18n: i18n_key:service_mailcheck_name,
        description_i18n: i18n_key:service_mailcheck_desc,
        aliases: ["Mailcheck"]
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
    provider_id: provider:mailcheck,
    category_id: NONE,
    is_active: true;

-- Service 205: Mailchimp
CREATE service:mailchimp SET
    identity = {
        name: "Mailchimp",
        slug: "mailchimp",
        display_name_i18n: i18n_key:service_mailchimp_name,
        description_i18n: i18n_key:service_mailchimp_desc,
        aliases: ["Mailchimp"]
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
    provider_id: provider:mailchimp,
    category_id: NONE,
    is_active: true;

-- Service 206: MailerLite
CREATE service:mailerlite SET
    identity = {
        name: "MailerLite",
        slug: "mailerlite",
        display_name_i18n: i18n_key:service_mailerlite_name,
        description_i18n: i18n_key:service_mailerlite_desc,
        aliases: ["MailerLite"]
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
    provider_id: provider:mailerlite,
    category_id: NONE,
    is_active: true;

-- Service 207: MailerLiteV1
CREATE service:mailerlitev1 SET
    identity = {
        name: "MailerLiteV1",
        slug: "mailerlitev1",
        display_name_i18n: i18n_key:service_mailerlitev1_name,
        description_i18n: i18n_key:service_mailerlitev1_desc,
        aliases: ["MailerLiteV1"]
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
    provider_id: provider:mailerlite,
    category_id: NONE,
    is_active: true;

-- Service 208: MailerLiteV2
CREATE service:mailerlitev2 SET
    identity = {
        name: "MailerLiteV2",
        slug: "mailerlitev2",
        display_name_i18n: i18n_key:service_mailerlitev2_name,
        description_i18n: i18n_key:service_mailerlitev2_desc,
        aliases: ["MailerLiteV2"]
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
    provider_id: provider:mailerlite,
    category_id: NONE,
    is_active: true;

-- Service 209: Mailgun
CREATE service:mailgun SET
    identity = {
        name: "Mailgun",
        slug: "mailgun",
        display_name_i18n: i18n_key:service_mailgun_name,
        description_i18n: i18n_key:service_mailgun_desc,
        aliases: ["Mailgun"]
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
    provider_id: provider:mailgun,
    category_id: NONE,
    is_active: true;

-- Service 210: Mailjet
CREATE service:mailjet SET
    identity = {
        name: "Mailjet",
        slug: "mailjet",
        display_name_i18n: i18n_key:service_mailjet_name,
        description_i18n: i18n_key:service_mailjet_desc,
        aliases: ["Mailjet"]
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
    provider_id: provider:mailjet,
    category_id: NONE,
    is_active: true;

-- Service 211: Mandrill
CREATE service:mandrill SET
    identity = {
        name: "Mandrill",
        slug: "mandrill",
        display_name_i18n: i18n_key:service_mandrill_name,
        description_i18n: i18n_key:service_mandrill_desc,
        aliases: ["Mandrill"]
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
    provider_id: provider:mandrill,
    category_id: NONE,
    is_active: true;

-- Service 212: Markdown
CREATE service:markdown SET
    identity = {
        name: "Markdown",
        slug: "markdown",
        display_name_i18n: i18n_key:service_markdown_name,
        description_i18n: i18n_key:service_markdown_desc,
        aliases: ["Markdown"]
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
    provider_id: provider:markdown,
    category_id: NONE,
    is_active: true;

-- Service 213: Marketstack
CREATE service:marketstack SET
    identity = {
        name: "Marketstack",
        slug: "marketstack",
        display_name_i18n: i18n_key:service_marketstack_name,
        description_i18n: i18n_key:service_marketstack_desc,
        aliases: ["Marketstack"]
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
    provider_id: provider:marketstack,
    category_id: NONE,
    is_active: true;

-- Service 214: Matrix
CREATE service:matrix SET
    identity = {
        name: "Matrix",
        slug: "matrix",
        display_name_i18n: i18n_key:service_matrix_name,
        description_i18n: i18n_key:service_matrix_desc,
        aliases: ["Matrix"]
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
    provider_id: provider:matrix,
    category_id: NONE,
    is_active: true;

-- Service 215: Mattermost
CREATE service:mattermost SET
    identity = {
        name: "Mattermost",
        slug: "mattermost",
        display_name_i18n: i18n_key:service_mattermost_name,
        description_i18n: i18n_key:service_mattermost_desc,
        aliases: ["Mattermost"]
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
    provider_id: provider:mattermost,
    category_id: NONE,
    is_active: true;

-- Service 216: MattermostV1
CREATE service:mattermostv1 SET
    identity = {
        name: "MattermostV1",
        slug: "mattermostv1",
        display_name_i18n: i18n_key:service_mattermostv1_name,
        description_i18n: i18n_key:service_mattermostv1_desc,
        aliases: ["MattermostV1"]
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
    provider_id: provider:mattermost,
    category_id: NONE,
    is_active: true;

-- Service 217: Mautic
CREATE service:mautic SET
    identity = {
        name: "Mautic",
        slug: "mautic",
        display_name_i18n: i18n_key:service_mautic_name,
        description_i18n: i18n_key:service_mautic_desc,
        aliases: ["Mautic"]
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
    provider_id: provider:mautic,
    category_id: NONE,
    is_active: true;

-- Service 218: Medium
CREATE service:medium SET
    identity = {
        name: "Medium",
        slug: "medium",
        display_name_i18n: i18n_key:service_medium_name,
        description_i18n: i18n_key:service_medium_desc,
        aliases: ["Medium"]
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
    provider_id: provider:medium,
    category_id: NONE,
    is_active: true;

-- Service 219: Merge
CREATE service:merge SET
    identity = {
        name: "Merge",
        slug: "merge",
        display_name_i18n: i18n_key:service_merge_name,
        description_i18n: i18n_key:service_merge_desc,
        aliases: ["Merge"]
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

-- Service 220: MergeV1
CREATE service:mergev1 SET
    identity = {
        name: "MergeV1",
        slug: "mergev1",
        display_name_i18n: i18n_key:service_mergev1_name,
        description_i18n: i18n_key:service_mergev1_desc,
        aliases: ["MergeV1"]
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

