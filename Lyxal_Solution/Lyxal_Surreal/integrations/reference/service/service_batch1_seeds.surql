-- =============================================================================================
-- |
-- | Fichier : service_batch1_seeds.surql
-- | Module : integrations > reference > service
-- | Description : Seeds pour les services (Batch 1 : 20 services)
-- |
-- | Batch 1: 20 services Lyxal
-- | Total : 20 services
-- |
-- =============================================================================================

-- Service 1: Action Network
CREATE service:action_network SET
    identity = {
        name: "actionNetwork",
        slug: "action-network",
        display_name_i18n: i18n_key:service_action_network_name,
        description_i18n: i18n_key:service_action_network_desc,
        aliases: ["ActionNetwork"]
    },
    presentation = {
        icon: NONE,
        color: "#1E88E5",
        display_order: 0,
        category_slug: "marketing",
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
        tags: ["marketing", "activism"],
        popularity_score: NONE,
        last_updated_by: NONE,
        custom_data: NONE
    },
    provider_id: provider:actionnetwork,
    category_id: NONE,
    is_active: true;

-- Service 2: ActiveCampaign
CREATE service:activecampaign SET
    identity = {
        name: "activeCampaign",
        slug: "activecampaign",
        display_name_i18n: i18n_key:service_activecampaign_name,
        description_i18n: i18n_key:service_activecampaign_desc,
        aliases: ["ActiveCampaign"]
    },
    presentation = {
        icon: logo_brand:activecampaign,
        color: "#356AE6",
        display_order: 0,
        category_slug: "marketing",
        tooltip_i18n: NONE,
        badge_text: "Popular",
        badge_color: "#4CAF50"
    },
    config = {
        version: {
            current: "1.0",
            is_default_version: true,
            supported_versions: ["1.0"]
        },
        capabilities: {
            is_trigger: true,
            is_polling: false,
            is_webhook: true,
            is_action: true,
            supports_batch: false
        },
        api: {
            base_url: NONE,
            version: "v3",
            protocol: "REST"
        },
        rate_limits: NONE
    },
    documentation = NONE,
    metadata = {
        tags: ["marketing", "email", "crm"],
        popularity_score: 75,
        last_updated_by: NONE,
        custom_data: NONE
    },
    provider_id: provider:activecampaign,
    category_id: NONE,
    is_active: true;

-- Service 3: Adalo
CREATE service:adalo SET
    identity = {
        name: "adalo",
        slug: "adalo",
        display_name_i18n: i18n_key:service_adalo_name,
        description_i18n: i18n_key:service_adalo_desc,
        aliases: ["Adalo"]
    },
    presentation = {
        icon: logo_brand:adalo,
        color: "#5C6AC4",
        display_order: 0,
        category_slug: "development",
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
        tags: ["no-code", "app-builder"],
        popularity_score: NONE,
        last_updated_by: NONE,
        custom_data: NONE
    },
    provider_id: provider:adalo,
    category_id: NONE,
    is_active: true;

-- Service 4: Affinity
CREATE service:affinity SET
    identity = {
        name: "affinity",
        slug: "affinity",
        display_name_i18n: i18n_key:service_affinity_name,
        description_i18n: i18n_key:service_affinity_desc,
        aliases: ["Affinity"]
    },
    presentation = {
        icon: logo_brand:affinity,
        color: "#2D3E50",
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
        tags: ["crm", "relationships"],
        popularity_score: NONE,
        last_updated_by: NONE,
        custom_data: NONE
    },
    provider_id: provider:affinity,
    category_id: NONE,
    is_active: true;

-- Service 5: Agile CRM
CREATE service:agile_crm SET
    identity = {
        name: "agileCrm",
        slug: "agile-crm",
        display_name_i18n: i18n_key:service_agile_crm_name,
        description_i18n: i18n_key:service_agile_crm_desc,
        aliases: ["AgileCRM"]
    },
    presentation = {
        icon: logo_brand:agilecrm,
        color: "#F05A28",
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
        tags: ["crm", "sales"],
        popularity_score: NONE,
        last_updated_by: NONE,
        custom_data: NONE
    },
    provider_id: provider:agilecrm,
    category_id: NONE,
    is_active: true;

-- Service 6: Airtable
CREATE service:airtable SET
    identity = {
        name: "airtable",
        slug: "airtable",
        display_name_i18n: i18n_key:service_airtable_name,
        description_i18n: i18n_key:service_airtable_desc,
        aliases: ["Airtable"]
    },
    presentation = {
        icon: logo_brand:airtable,
        color: "#FCBD24",
        display_order: 10,
        category_slug: "data-storage",
        tooltip_i18n: NONE,
        badge_text: "Popular",
        badge_color: "#4CAF50"
    },
    config = {
        version: {
            current: "2.1",
            is_default_version: true,
            supported_versions: ["2.1", "2.0", "1.0"]
        },
        capabilities: {
            is_trigger: true,
            is_polling: true,
            is_webhook: false,
            is_action: true,
            supports_batch: true
        },
        api: {
            base_url: "https://api.airtable.com",
            version: "v0",
            protocol: "REST"
        },
        rate_limits: {
            requests_per_minute: 5,
            requests_per_day: NONE
        }
    },
    documentation = {
        main_url: "https://airtable.com/developers/web/api/introduction",
        api_reference_url: "https://airtable.com/developers/web/api/introduction",
        credential_setup_url: NONE,
        video_tutorial_url: NONE,
        changelog_url: NONE
    },
    metadata = {
        tags: ["database", "spreadsheet", "collaboration"],
        popularity_score: 90,
        last_updated_by: NONE,
        custom_data: NONE
    },
    provider_id: provider:airtable,
    category_id: NONE,
    is_active: true;

-- Service 7: Airtable V1
CREATE service:airtable_v1 SET
    identity = {
        name: "airtableV1",
        slug: "airtable-v1",
        display_name_i18n: i18n_key:service_airtable_v1_name,
        description_i18n: i18n_key:service_airtable_v1_desc,
        aliases: ["AirtableV1"]
    },
    presentation = {
        icon: logo_brand:airtable,
        color: "#FCBD24",
        display_order: 100,
        category_slug: "data-storage",
        tooltip_i18n: NONE,
        badge_text: "Legacy",
        badge_color: "#FF9800"
    },
    config = {
        version: {
            current: "1.0",
            is_default_version: false,
            supported_versions: ["1.0"]
        },
        capabilities: {
            is_trigger: true,
            is_polling: true,
            is_webhook: false,
            is_action: true,
            supports_batch: false
        },
        api: {
            base_url: "https://api.airtable.com",
            version: "v0",
            protocol: "REST"
        },
        rate_limits: NONE
    },
    documentation = NONE,
    metadata = {
        tags: ["database", "spreadsheet", "legacy"],
        popularity_score: 20,
        last_updated_by: NONE,
        custom_data: { deprecated: true }
    },
    provider_id: provider:airtable,
    category_id: NONE,
    is_active: false;

-- Service 8: Airtable V2
CREATE service:airtable_v2 SET
    identity = {
        name: "airtableV2",
        slug: "airtable-v2",
        display_name_i18n: i18n_key:service_airtable_v2_name,
        description_i18n: i18n_key:service_airtable_v2_desc,
        aliases: ["AirtableV2"]
    },
    presentation = {
        icon: logo_brand:airtable,
        color: "#FCBD24",
        display_order: 99,
        category_slug: "data-storage",
        tooltip_i18n: NONE,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        version: {
            current: "1.0",
            is_default_version: false,
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
            base_url: "https://api.airtable.com",
            version: "v0",
            protocol: "REST"
        },
        rate_limits: NONE
    },
    documentation = NONE,
    metadata = {
        tags: ["database", "spreadsheet"],
        popularity_score: 60,
        last_updated_by: NONE,
        custom_data: NONE
    },
    provider_id: provider:airtable,
    category_id: NONE,
    is_active: true;

-- Service 9: Airtop
CREATE service:airtop SET
    identity = {
        name: "airtop",
        slug: "airtop",
        display_name_i18n: i18n_key:service_airtop_name,
        description_i18n: i18n_key:service_airtop_desc,
        aliases: ["Airtop"]
    },
    presentation = {
        icon: NONE,
        color: "#5C6AC4",
        display_order: 0,
        category_slug: "automation",
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
        tags: ["automation"],
        popularity_score: NONE,
        last_updated_by: NONE,
        custom_data: NONE
    },
    provider_id: provider:airtop,
    category_id: NONE,
    is_active: true;

-- Service 10: AI Transform
CREATE service:ai_transform SET
    identity = {
        name: "aiTransform",
        slug: "ai-transform",
        display_name_i18n: i18n_key:service_ai_transform_name,
        description_i18n: i18n_key:service_ai_transform_desc,
        aliases: ["AiTransform"]
    },
    presentation = {
        icon: NONE,
        color: "#8B5CF6",
        display_order: 0,
        category_slug: "ai",
        tooltip_i18n: NONE,
        badge_text: "AI",
        badge_color: "#9C27B0"
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
            protocol: "Custom"
        },
        rate_limits: NONE
    },
    documentation = NONE,
    metadata = {
        tags: ["ai", "transform", "data"],
        popularity_score: NONE,
        last_updated_by: NONE,
        custom_data: NONE
    },
    provider_id: NONE,
    category_id: NONE,
    is_active: true;

-- Service 11: AMQP Sender
CREATE service:amqp SET
    identity = {
        name: "amqp",
        slug: "amqp",
        display_name_i18n: i18n_key:service_amqp_name,
        description_i18n: i18n_key:service_amqp_desc,
        aliases: ["AMQP", "RabbitMQ"]
    },
    presentation = {
        icon: NONE,
        color: "#FF6600",
        display_order: 0,
        category_slug: "messaging",
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
            protocol: "AMQP"
        },
        rate_limits: NONE
    },
    documentation = NONE,
    metadata = {
        tags: ["messaging", "queue"],
        popularity_score: NONE,
        last_updated_by: NONE,
        custom_data: NONE
    },
    provider_id: NONE,
    category_id: NONE,
    is_active: true;

-- Service 12: APITemplate.io
CREATE service:apitemplateio SET
    identity = {
        name: "apiTemplateIo",
        slug: "apitemplateio",
        display_name_i18n: i18n_key:service_apitemplateio_name,
        description_i18n: i18n_key:service_apitemplateio_desc,
        aliases: ["APITemplate.io"]
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
        tags: ["template", "document-generation"],
        popularity_score: NONE,
        last_updated_by: NONE,
        custom_data: NONE
    },
    provider_id: provider:apitemplateio,
    category_id: NONE,
    is_active: true;

-- Service 13: Asana
CREATE service:asana SET
    identity = {
        name: "asana",
        slug: "asana",
        display_name_i18n: i18n_key:service_asana_name,
        description_i18n: i18n_key:service_asana_desc,
        aliases: ["Asana"]
    },
    presentation = {
        icon: logo_brand:asana,
        color: "#F06A6A",
        display_order: 15,
        category_slug: "project-management",
        tooltip_i18n: NONE,
        badge_text: "Popular",
        badge_color: "#4CAF50"
    },
    config = {
        version: {
            current: "1.0",
            is_default_version: true,
            supported_versions: ["1.0"]
        },
        capabilities: {
            is_trigger: true,
            is_polling: false,
            is_webhook: true,
            is_action: true,
            supports_batch: false
        },
        api: {
            base_url: "https://app.asana.com/api",
            version: "1.0",
            protocol: "REST"
        },
        rate_limits: {
            requests_per_minute: 60,
            requests_per_day: NONE
        }
    },
    documentation = {
        main_url: "https://developers.asana.com/docs",
        api_reference_url: "https://developers.asana.com/reference/rest-api-reference",
        credential_setup_url: NONE,
        video_tutorial_url: NONE,
        changelog_url: NONE
    },
    metadata = {
        tags: ["project-management", "tasks", "collaboration"],
        popularity_score: 85,
        last_updated_by: NONE,
        custom_data: NONE
    },
    provider_id: provider:asana,
    category_id: NONE,
    is_active: true;

-- Service 14: Automizy
CREATE service:automizy SET
    identity = {
        name: "automizy",
        slug: "automizy",
        display_name_i18n: i18n_key:service_automizy_name,
        description_i18n: i18n_key:service_automizy_desc,
        aliases: ["Automizy"]
    },
    presentation = {
        icon: NONE,
        color: "#5C6AC4",
        display_order: 0,
        category_slug: "marketing",
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
        tags: ["marketing", "email"],
        popularity_score: NONE,
        last_updated_by: NONE,
        custom_data: NONE
    },
    provider_id: provider:automizy,
    category_id: NONE,
    is_active: true;

-- Service 15: Autopilot
CREATE service:autopilot SET
    identity = {
        name: "autopilot",
        slug: "autopilot",
        display_name_i18n: i18n_key:service_autopilot_name,
        description_i18n: i18n_key:service_autopilot_desc,
        aliases: ["Autopilot"]
    },
    presentation = {
        icon: NONE,
        color: "#5C6AC4",
        display_order: 0,
        category_slug: "marketing",
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
        tags: ["marketing", "automation"],
        popularity_score: NONE,
        last_updated_by: NONE,
        custom_data: NONE
    },
    provider_id: provider:autopilot,
    category_id: NONE,
    is_active: true;

-- Service 16: AWS Lambda
CREATE service:aws_lambda SET
    identity = {
        name: "awsLambda",
        slug: "aws-lambda",
        display_name_i18n: i18n_key:service_aws_lambda_name,
        description_i18n: i18n_key:service_aws_lambda_desc,
        aliases: ["Lambda", "AWS Lambda"]
    },
    presentation = {
        icon: logo_brand:aws,
        color: "#FF9900",
        display_order: 20,
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
        tags: ["serverless", "cloud", "compute"],
        popularity_score: 80,
        last_updated_by: NONE,
        custom_data: NONE
    },
    provider_id: provider:aws,
    category_id: NONE,
    is_active: true;

-- Service 17: AWS SNS
CREATE service:aws_sns SET
    identity = {
        name: "awsSns",
        slug: "aws-sns",
        display_name_i18n: i18n_key:service_aws_sns_name,
        description_i18n: i18n_key:service_aws_sns_desc,
        aliases: ["SNS", "AWS SNS", "Simple Notification Service"]
    },
    presentation = {
        icon: logo_brand:aws,
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
        tags: ["messaging", "cloud", "notifications"],
        popularity_score: 70,
        last_updated_by: NONE,
        custom_data: NONE
    },
    provider_id: provider:aws,
    category_id: NONE,
    is_active: true;

-- Service 18: AWS Certificate Manager
CREATE service:aws_certificate_manager SET
    identity = {
        name: "awsCertificateManager",
        slug: "aws-certificate-manager",
        display_name_i18n: i18n_key:service_aws_certificate_manager_name,
        description_i18n: i18n_key:service_aws_certificate_manager_desc,
        aliases: ["ACM", "AWS Certificate Manager"]
    },
    presentation = {
        icon: logo_brand:aws,
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
        tags: ["cloud", "security", "certificates"],
        popularity_score: 60,
        last_updated_by: NONE,
        custom_data: NONE
    },
    provider_id: provider:aws,
    category_id: NONE,
    is_active: true;

-- Service 19: AWS Cognito
CREATE service:aws_cognito SET
    identity = {
        name: "awsCognito",
        slug: "aws-cognito",
        display_name_i18n: i18n_key:service_aws_cognito_name,
        description_i18n: i18n_key:service_aws_cognito_desc,
        aliases: ["Cognito", "AWS Cognito"]
    },
    presentation = {
        icon: logo_brand:aws,
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
        tags: ["cloud", "auth", "identity"],
        popularity_score: 75,
        last_updated_by: NONE,
        custom_data: NONE
    },
    provider_id: provider:aws,
    category_id: NONE,
    is_active: true;

-- Service 20: AWS Comprehend
CREATE service:aws_comprehend SET
    identity = {
        name: "awsComprehend",
        slug: "aws-comprehend",
        display_name_i18n: i18n_key:service_aws_comprehend_name,
        description_i18n: i18n_key:service_aws_comprehend_desc,
        aliases: ["Comprehend", "AWS Comprehend"]
    },
    presentation = {
        icon: logo_brand:aws,
        color: "#FF9900",
        display_order: 0,
        category_slug: "cloud",
        tooltip_i18n: NONE,
        badge_text: "AI",
        badge_color: "#9C27B0"
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
        tags: ["cloud", "ai", "nlp", "text-analysis"],
        popularity_score: 65,
        last_updated_by: NONE,
        custom_data: NONE
    },
    provider_id: provider:aws,
    category_id: NONE,
    is_active: true;


