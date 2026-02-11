-- Batch 18: 20 services Lyxal

-- Service 341: SplitInBatchesV3
CREATE service:splitinbatchesv3 SET
    identity = {
        name: "SplitInBatchesV3",
        slug: "splitinbatchesv3",
        display_name_i18n: i18n_key:service_splitinbatchesv3_name,
        description_i18n: i18n_key:service_splitinbatchesv3_desc,
        aliases: ["SplitInBatchesV3"]
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
    provider_id: provider:splitinbatches,
    category_id: NONE,
    is_active: true;

-- Service 342: Splunk
CREATE service:splunk SET
    identity = {
        name: "Splunk",
        slug: "splunk",
        display_name_i18n: i18n_key:service_splunk_name,
        description_i18n: i18n_key:service_splunk_desc,
        aliases: ["Splunk"]
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
    provider_id: provider:splunk,
    category_id: NONE,
    is_active: true;

-- Service 343: SplunkV1
CREATE service:splunkv1 SET
    identity = {
        name: "SplunkV1",
        slug: "splunkv1",
        display_name_i18n: i18n_key:service_splunkv1_name,
        description_i18n: i18n_key:service_splunkv1_desc,
        aliases: ["SplunkV1"]
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
    provider_id: provider:splunk,
    category_id: NONE,
    is_active: true;

-- Service 344: SplunkV2
CREATE service:splunkv2 SET
    identity = {
        name: "SplunkV2",
        slug: "splunkv2",
        display_name_i18n: i18n_key:service_splunkv2_name,
        description_i18n: i18n_key:service_splunkv2_desc,
        aliases: ["SplunkV2"]
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
    provider_id: provider:splunk,
    category_id: NONE,
    is_active: true;

-- Service 345: Spontit
CREATE service:spontit SET
    identity = {
        name: "Spontit",
        slug: "spontit",
        display_name_i18n: i18n_key:service_spontit_name,
        description_i18n: i18n_key:service_spontit_desc,
        aliases: ["Spontit"]
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
    provider_id: provider:spontit,
    category_id: NONE,
    is_active: true;

-- Service 346: Spotify
CREATE service:spotify SET
    identity = {
        name: "Spotify",
        slug: "spotify",
        display_name_i18n: i18n_key:service_spotify_name,
        description_i18n: i18n_key:service_spotify_desc,
        aliases: ["Spotify"]
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
    provider_id: provider:spotify,
    category_id: NONE,
    is_active: true;

-- Service 347: SpreadsheetFile
CREATE service:spreadsheetfile SET
    identity = {
        name: "SpreadsheetFile",
        slug: "spreadsheetfile",
        display_name_i18n: i18n_key:service_spreadsheetfile_name,
        description_i18n: i18n_key:service_spreadsheetfile_desc,
        aliases: ["SpreadsheetFile"]
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
    provider_id: provider:spreadsheetfile,
    category_id: NONE,
    is_active: true;

-- Service 348: SpreadsheetFileV1
CREATE service:spreadsheetfilev1 SET
    identity = {
        name: "SpreadsheetFileV1",
        slug: "spreadsheetfilev1",
        display_name_i18n: i18n_key:service_spreadsheetfilev1_name,
        description_i18n: i18n_key:service_spreadsheetfilev1_desc,
        aliases: ["SpreadsheetFileV1"]
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
    provider_id: provider:spreadsheetfile,
    category_id: NONE,
    is_active: true;

-- Service 349: SpreadsheetFileV2
CREATE service:spreadsheetfilev2 SET
    identity = {
        name: "SpreadsheetFileV2",
        slug: "spreadsheetfilev2",
        display_name_i18n: i18n_key:service_spreadsheetfilev2_name,
        description_i18n: i18n_key:service_spreadsheetfilev2_desc,
        aliases: ["SpreadsheetFileV2"]
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
    provider_id: provider:spreadsheetfile,
    category_id: NONE,
    is_active: true;

-- Service 350: Ssh
CREATE service:ssh SET
    identity = {
        name: "Ssh",
        slug: "ssh",
        display_name_i18n: i18n_key:service_ssh_name,
        description_i18n: i18n_key:service_ssh_desc,
        aliases: ["Ssh"]
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
    provider_id: provider:ssh,
    category_id: NONE,
    is_active: true;

-- Service 351: Stackby
CREATE service:stackby SET
    identity = {
        name: "Stackby",
        slug: "stackby",
        display_name_i18n: i18n_key:service_stackby_name,
        description_i18n: i18n_key:service_stackby_desc,
        aliases: ["Stackby"]
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
    provider_id: provider:stackby,
    category_id: NONE,
    is_active: true;

-- Service 352: Start
CREATE service:start SET
    identity = {
        name: "Start",
        slug: "start",
        display_name_i18n: i18n_key:service_start_name,
        description_i18n: i18n_key:service_start_desc,
        aliases: ["Start"]
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
    provider_id: provider:start,
    category_id: NONE,
    is_active: true;

-- Service 353: StickyNote
CREATE service:stickynote SET
    identity = {
        name: "StickyNote",
        slug: "stickynote",
        display_name_i18n: i18n_key:service_stickynote_name,
        description_i18n: i18n_key:service_stickynote_desc,
        aliases: ["StickyNote"]
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
    provider_id: provider:stickynote,
    category_id: NONE,
    is_active: true;

-- Service 354: StopAndError
CREATE service:stopanderror SET
    identity = {
        name: "StopAndError",
        slug: "stopanderror",
        display_name_i18n: i18n_key:service_stopanderror_name,
        description_i18n: i18n_key:service_stopanderror_desc,
        aliases: ["StopAndError"]
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
    provider_id: provider:stopanderror,
    category_id: NONE,
    is_active: true;

-- Service 355: Storyblok
CREATE service:storyblok SET
    identity = {
        name: "Storyblok",
        slug: "storyblok",
        display_name_i18n: i18n_key:service_storyblok_name,
        description_i18n: i18n_key:service_storyblok_desc,
        aliases: ["Storyblok"]
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
    provider_id: provider:storyblok,
    category_id: NONE,
    is_active: true;

-- Service 356: Strapi
CREATE service:strapi SET
    identity = {
        name: "Strapi",
        slug: "strapi",
        display_name_i18n: i18n_key:service_strapi_name,
        description_i18n: i18n_key:service_strapi_desc,
        aliases: ["Strapi"]
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
    provider_id: provider:strapi,
    category_id: NONE,
    is_active: true;

-- Service 357: Strava
CREATE service:strava SET
    identity = {
        name: "Strava",
        slug: "strava",
        display_name_i18n: i18n_key:service_strava_name,
        description_i18n: i18n_key:service_strava_desc,
        aliases: ["Strava"]
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
    provider_id: provider:strava,
    category_id: NONE,
    is_active: true;

-- Service 358: Stripe
CREATE service:stripe SET
    identity = {
        name: "Stripe",
        slug: "stripe",
        display_name_i18n: i18n_key:service_stripe_name,
        description_i18n: i18n_key:service_stripe_desc,
        aliases: ["Stripe"]
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
    provider_id: provider:stripe,
    category_id: NONE,
    is_active: true;

-- Service 359: Supabase
CREATE service:supabase SET
    identity = {
        name: "Supabase",
        slug: "supabase",
        display_name_i18n: i18n_key:service_supabase_name,
        description_i18n: i18n_key:service_supabase_desc,
        aliases: ["Supabase"]
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
    provider_id: provider:supabase,
    category_id: NONE,
    is_active: true;

-- Service 360: Switch
CREATE service:switch SET
    identity = {
        name: "Switch",
        slug: "switch",
        display_name_i18n: i18n_key:service_switch_name,
        description_i18n: i18n_key:service_switch_desc,
        aliases: ["Switch"]
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

