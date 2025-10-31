-- Batch 7: 20 services Lyxal

-- Service 121: GoogleAnalyticsV2
CREATE service:googleanalyticsv2 SET
    identity = {
        name: "GoogleAnalyticsV2",
        slug: "googleanalyticsv2",
        display_name_i18n: i18n_key:service_googleanalyticsv2_name,
        description_i18n: i18n_key:service_googleanalyticsv2_desc,
        aliases: ["GoogleAnalyticsV2"]
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

-- Service 122: GoogleBigQuery
CREATE service:googlebigquery SET
    identity = {
        name: "GoogleBigQuery",
        slug: "googlebigquery",
        display_name_i18n: i18n_key:service_googlebigquery_name,
        description_i18n: i18n_key:service_googlebigquery_desc,
        aliases: ["GoogleBigQuery"]
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

-- Service 123: GoogleBigQueryV1
CREATE service:googlebigqueryv1 SET
    identity = {
        name: "GoogleBigQueryV1",
        slug: "googlebigqueryv1",
        display_name_i18n: i18n_key:service_googlebigqueryv1_name,
        description_i18n: i18n_key:service_googlebigqueryv1_desc,
        aliases: ["GoogleBigQueryV1"]
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

-- Service 124: GoogleBigQueryV2
CREATE service:googlebigqueryv2 SET
    identity = {
        name: "GoogleBigQueryV2",
        slug: "googlebigqueryv2",
        display_name_i18n: i18n_key:service_googlebigqueryv2_name,
        description_i18n: i18n_key:service_googlebigqueryv2_desc,
        aliases: ["GoogleBigQueryV2"]
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

-- Service 125: GoogleBooks
CREATE service:googlebooks SET
    identity = {
        name: "GoogleBooks",
        slug: "googlebooks",
        display_name_i18n: i18n_key:service_googlebooks_name,
        description_i18n: i18n_key:service_googlebooks_desc,
        aliases: ["GoogleBooks"]
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

-- Service 126: GoogleBusinessProfile
CREATE service:googlebusinessprofile SET
    identity = {
        name: "GoogleBusinessProfile",
        slug: "googlebusinessprofile",
        display_name_i18n: i18n_key:service_googlebusinessprofile_name,
        description_i18n: i18n_key:service_googlebusinessprofile_desc,
        aliases: ["GoogleBusinessProfile"]
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

-- Service 127: GoogleCalendar
CREATE service:googlecalendar SET
    identity = {
        name: "GoogleCalendar",
        slug: "googlecalendar",
        display_name_i18n: i18n_key:service_googlecalendar_name,
        description_i18n: i18n_key:service_googlecalendar_desc,
        aliases: ["GoogleCalendar"]
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

-- Service 128: GoogleChat
CREATE service:googlechat SET
    identity = {
        name: "GoogleChat",
        slug: "googlechat",
        display_name_i18n: i18n_key:service_googlechat_name,
        description_i18n: i18n_key:service_googlechat_desc,
        aliases: ["GoogleChat"]
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

-- Service 129: GoogleCloudNaturalLanguage
CREATE service:googlecloudnaturallanguage SET
    identity = {
        name: "GoogleCloudNaturalLanguage",
        slug: "googlecloudnaturallanguage",
        display_name_i18n: i18n_key:service_googlecloudnaturallanguage_name,
        description_i18n: i18n_key:service_googlecloudnaturallanguage_desc,
        aliases: ["GoogleCloudNaturalLanguage"]
    },
    presentation = {
        icon: NONE,
        color: "#4285F4",
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
    provider_id: provider:google,
    category_id: NONE,
    is_active: true;

-- Service 130: GoogleCloudStorage
CREATE service:googlecloudstorage SET
    identity = {
        name: "GoogleCloudStorage",
        slug: "googlecloudstorage",
        display_name_i18n: i18n_key:service_googlecloudstorage_name,
        description_i18n: i18n_key:service_googlecloudstorage_desc,
        aliases: ["GoogleCloudStorage"]
    },
    presentation = {
        icon: NONE,
        color: "#4285F4",
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
    provider_id: provider:google,
    category_id: NONE,
    is_active: true;

-- Service 131: GoogleContacts
CREATE service:googlecontacts SET
    identity = {
        name: "GoogleContacts",
        slug: "googlecontacts",
        display_name_i18n: i18n_key:service_googlecontacts_name,
        description_i18n: i18n_key:service_googlecontacts_desc,
        aliases: ["GoogleContacts"]
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

-- Service 132: GoogleDocs
CREATE service:googledocs SET
    identity = {
        name: "GoogleDocs",
        slug: "googledocs",
        display_name_i18n: i18n_key:service_googledocs_name,
        description_i18n: i18n_key:service_googledocs_desc,
        aliases: ["GoogleDocs"]
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

-- Service 133: GoogleDrive
CREATE service:googledrive SET
    identity = {
        name: "GoogleDrive",
        slug: "googledrive",
        display_name_i18n: i18n_key:service_googledrive_name,
        description_i18n: i18n_key:service_googledrive_desc,
        aliases: ["GoogleDrive"]
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

-- Service 134: GoogleDriveV1
CREATE service:googledrivev1 SET
    identity = {
        name: "GoogleDriveV1",
        slug: "googledrivev1",
        display_name_i18n: i18n_key:service_googledrivev1_name,
        description_i18n: i18n_key:service_googledrivev1_desc,
        aliases: ["GoogleDriveV1"]
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

-- Service 135: GoogleDriveV2
CREATE service:googledrivev2 SET
    identity = {
        name: "GoogleDriveV2",
        slug: "googledrivev2",
        display_name_i18n: i18n_key:service_googledrivev2_name,
        description_i18n: i18n_key:service_googledrivev2_desc,
        aliases: ["GoogleDriveV2"]
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

-- Service 136: GoogleFirebaseCloudFirestore
CREATE service:googlefirebasecloudfirestore SET
    identity = {
        name: "GoogleFirebaseCloudFirestore",
        slug: "googlefirebasecloudfirestore",
        display_name_i18n: i18n_key:service_googlefirebasecloudfirestore_name,
        description_i18n: i18n_key:service_googlefirebasecloudfirestore_desc,
        aliases: ["GoogleFirebaseCloudFirestore"]
    },
    presentation = {
        icon: NONE,
        color: "#4285F4",
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
    provider_id: provider:google,
    category_id: NONE,
    is_active: true;

-- Service 137: GoogleFirebaseRealtimeDatabase
CREATE service:googlefirebaserealtimedatabase SET
    identity = {
        name: "GoogleFirebaseRealtimeDatabase",
        slug: "googlefirebaserealtimedatabase",
        display_name_i18n: i18n_key:service_googlefirebaserealtimedatabase_name,
        description_i18n: i18n_key:service_googlefirebaserealtimedatabase_desc,
        aliases: ["GoogleFirebaseRealtimeDatabase"]
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

-- Service 138: Gmail
CREATE service:gmail SET
    identity = {
        name: "Gmail",
        slug: "gmail",
        display_name_i18n: i18n_key:service_gmail_name,
        description_i18n: i18n_key:service_gmail_desc,
        aliases: ["Gmail"]
    },
    presentation = {
        icon: NONE,
        color: "#4285F4",
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
    provider_id: provider:google,
    category_id: NONE,
    is_active: true;

-- Service 139: GmailV1
CREATE service:gmailv1 SET
    identity = {
        name: "GmailV1",
        slug: "gmailv1",
        display_name_i18n: i18n_key:service_gmailv1_name,
        description_i18n: i18n_key:service_gmailv1_desc,
        aliases: ["GmailV1"]
    },
    presentation = {
        icon: NONE,
        color: "#4285F4",
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
    provider_id: provider:google,
    category_id: NONE,
    is_active: true;

-- Service 140: GmailV2
CREATE service:gmailv2 SET
    identity = {
        name: "GmailV2",
        slug: "gmailv2",
        display_name_i18n: i18n_key:service_gmailv2_name,
        description_i18n: i18n_key:service_gmailv2_desc,
        aliases: ["GmailV2"]
    },
    presentation = {
        icon: NONE,
        color: "#4285F4",
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
    provider_id: provider:google,
    category_id: NONE,
    is_active: true;

