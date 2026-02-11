-- Batch 2: 20 services Lyxal

-- Service 21: AwsDynamoDB
CREATE service:awsdynamodb SET
    identity = {
        name: "AwsDynamoDB",
        slug: "awsdynamodb",
        display_name_i18n: i18n_key:service_awsdynamodb_name,
        description_i18n: i18n_key:service_awsdynamodb_desc,
        aliases: ["AwsDynamoDB"]
    },
    presentation = {
        icon: NONE,
        color: "#FF9900",
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
    provider_id: provider:aws,
    category_id: NONE,
    is_active: true;

-- Service 22: AwsElb
CREATE service:awselb SET
    identity = {
        name: "AwsElb",
        slug: "awselb",
        display_name_i18n: i18n_key:service_awselb_name,
        description_i18n: i18n_key:service_awselb_desc,
        aliases: ["AwsElb"]
    },
    presentation = {
        icon: NONE,
        color: "#FF9900",
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
    provider_id: provider:aws,
    category_id: NONE,
    is_active: true;

-- Service 23: AwsIam
CREATE service:awsiam SET
    identity = {
        name: "AwsIam",
        slug: "awsiam",
        display_name_i18n: i18n_key:service_awsiam_name,
        description_i18n: i18n_key:service_awsiam_desc,
        aliases: ["AwsIam"]
    },
    presentation = {
        icon: NONE,
        color: "#FF9900",
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
    provider_id: provider:aws,
    category_id: NONE,
    is_active: true;

-- Service 24: AwsRekognition
CREATE service:awsrekognition SET
    identity = {
        name: "AwsRekognition",
        slug: "awsrekognition",
        display_name_i18n: i18n_key:service_awsrekognition_name,
        description_i18n: i18n_key:service_awsrekognition_desc,
        aliases: ["AwsRekognition"]
    },
    presentation = {
        icon: NONE,
        color: "#FF9900",
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
    provider_id: provider:aws,
    category_id: NONE,
    is_active: true;

-- Service 25: AwsS3
CREATE service:awss3 SET
    identity = {
        name: "AwsS3",
        slug: "awss3",
        display_name_i18n: i18n_key:service_awss3_name,
        description_i18n: i18n_key:service_awss3_desc,
        aliases: ["AwsS3"]
    },
    presentation = {
        icon: NONE,
        color: "#FF9900",
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
    provider_id: provider:aws,
    category_id: NONE,
    is_active: true;

-- Service 26: AwsS3V1
CREATE service:awss3v1 SET
    identity = {
        name: "AwsS3V1",
        slug: "awss3v1",
        display_name_i18n: i18n_key:service_awss3v1_name,
        description_i18n: i18n_key:service_awss3v1_desc,
        aliases: ["AwsS3V1"]
    },
    presentation = {
        icon: NONE,
        color: "#FF9900",
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
    provider_id: provider:aws,
    category_id: NONE,
    is_active: true;

-- Service 27: AwsS3V2
CREATE service:awss3v2 SET
    identity = {
        name: "AwsS3V2",
        slug: "awss3v2",
        display_name_i18n: i18n_key:service_awss3v2_name,
        description_i18n: i18n_key:service_awss3v2_desc,
        aliases: ["AwsS3V2"]
    },
    presentation = {
        icon: NONE,
        color: "#FF9900",
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
    provider_id: provider:aws,
    category_id: NONE,
    is_active: true;

-- Service 28: AwsSes
CREATE service:awsses SET
    identity = {
        name: "AwsSes",
        slug: "awsses",
        display_name_i18n: i18n_key:service_awsses_name,
        description_i18n: i18n_key:service_awsses_desc,
        aliases: ["AwsSes"]
    },
    presentation = {
        icon: NONE,
        color: "#FF9900",
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
    provider_id: provider:aws,
    category_id: NONE,
    is_active: true;

-- Service 29: AwsSqs
CREATE service:awssqs SET
    identity = {
        name: "AwsSqs",
        slug: "awssqs",
        display_name_i18n: i18n_key:service_awssqs_name,
        description_i18n: i18n_key:service_awssqs_desc,
        aliases: ["AwsSqs"]
    },
    presentation = {
        icon: NONE,
        color: "#FF9900",
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
    provider_id: provider:aws,
    category_id: NONE,
    is_active: true;

-- Service 30: AwsTextract
CREATE service:awstextract SET
    identity = {
        name: "AwsTextract",
        slug: "awstextract",
        display_name_i18n: i18n_key:service_awstextract_name,
        description_i18n: i18n_key:service_awstextract_desc,
        aliases: ["AwsTextract"]
    },
    presentation = {
        icon: NONE,
        color: "#FF9900",
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
    provider_id: provider:aws,
    category_id: NONE,
    is_active: true;

-- Service 31: AwsTranscribe
CREATE service:awstranscribe SET
    identity = {
        name: "AwsTranscribe",
        slug: "awstranscribe",
        display_name_i18n: i18n_key:service_awstranscribe_name,
        description_i18n: i18n_key:service_awstranscribe_desc,
        aliases: ["AwsTranscribe"]
    },
    presentation = {
        icon: NONE,
        color: "#FF9900",
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
    provider_id: provider:aws,
    category_id: NONE,
    is_active: true;

-- Service 32: BambooHr
CREATE service:bamboohr SET
    identity = {
        name: "BambooHr",
        slug: "bamboohr",
        display_name_i18n: i18n_key:service_bamboohr_name,
        description_i18n: i18n_key:service_bamboohr_desc,
        aliases: ["BambooHr"]
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
    provider_id: provider:bamboohr,
    category_id: NONE,
    is_active: true;

-- Service 33: Bannerbear
CREATE service:bannerbear SET
    identity = {
        name: "Bannerbear",
        slug: "bannerbear",
        display_name_i18n: i18n_key:service_bannerbear_name,
        description_i18n: i18n_key:service_bannerbear_desc,
        aliases: ["Bannerbear"]
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
    provider_id: provider:bannerbear,
    category_id: NONE,
    is_active: true;

-- Service 34: Baserow
CREATE service:baserow SET
    identity = {
        name: "Baserow",
        slug: "baserow",
        display_name_i18n: i18n_key:service_baserow_name,
        description_i18n: i18n_key:service_baserow_desc,
        aliases: ["Baserow"]
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
    provider_id: provider:baserow,
    category_id: NONE,
    is_active: true;

-- Service 35: Beeminder
CREATE service:beeminder SET
    identity = {
        name: "Beeminder",
        slug: "beeminder",
        display_name_i18n: i18n_key:service_beeminder_name,
        description_i18n: i18n_key:service_beeminder_desc,
        aliases: ["Beeminder"]
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
    provider_id: provider:beeminder,
    category_id: NONE,
    is_active: true;

-- Service 36: Bitly
CREATE service:bitly SET
    identity = {
        name: "Bitly",
        slug: "bitly",
        display_name_i18n: i18n_key:service_bitly_name,
        description_i18n: i18n_key:service_bitly_desc,
        aliases: ["Bitly"]
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
    provider_id: provider:bitly,
    category_id: NONE,
    is_active: true;

-- Service 37: Bitwarden
CREATE service:bitwarden SET
    identity = {
        name: "Bitwarden",
        slug: "bitwarden",
        display_name_i18n: i18n_key:service_bitwarden_name,
        description_i18n: i18n_key:service_bitwarden_desc,
        aliases: ["Bitwarden"]
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
    provider_id: provider:bitwarden,
    category_id: NONE,
    is_active: true;

-- Service 38: Box
CREATE service:box SET
    identity = {
        name: "Box",
        slug: "box",
        display_name_i18n: i18n_key:service_box_name,
        description_i18n: i18n_key:service_box_desc,
        aliases: ["Box"]
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
    provider_id: provider:box,
    category_id: NONE,
    is_active: true;

-- Service 39: Brandfetch
CREATE service:brandfetch SET
    identity = {
        name: "Brandfetch",
        slug: "brandfetch",
        display_name_i18n: i18n_key:service_brandfetch_name,
        description_i18n: i18n_key:service_brandfetch_desc,
        aliases: ["Brandfetch"]
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
    provider_id: provider:brandfetch,
    category_id: NONE,
    is_active: true;

-- Service 40: Brevo
CREATE service:brevo SET
    identity = {
        name: "Brevo",
        slug: "brevo",
        display_name_i18n: i18n_key:service_brevo_name,
        description_i18n: i18n_key:service_brevo_desc,
        aliases: ["Brevo"]
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
    provider_id: provider:brevo,
    category_id: NONE,
    is_active: true;

