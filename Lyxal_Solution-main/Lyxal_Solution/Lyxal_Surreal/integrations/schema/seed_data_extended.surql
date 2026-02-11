-- =====================================================
-- SEED DATA ÉTENDU POUR MODULE D'INTÉGRATION
-- Exemples supplémentaires de providers populaires
-- =====================================================

-- =====================================================
-- PROVIDER: Facebook
-- =====================================================

LET $facebook_provider = CREATE provider SET
    name = "Facebook",
    display_name = "Facebook",
    slug = "facebook",
    description = "Réseau social et plateforme publicitaire",
    icon_light = "facebook.svg",
    icon_dark = "facebook-dark.svg",
    website_url = "https://facebook.com",
    documentation_url = "https://developers.facebook.com",
    api_base_url = "https://graph.facebook.com",
    support_oauth2 = true,
    tags = ["social-media", "marketing", "popular"];

-- Service: Facebook Lead Ads
LET $facebook_leadads = CREATE service SET
    name = "facebookLeadAds",
    display_name = "Facebook Lead Ads",
    slug = "facebook-lead-ads",
    description = "Récupérer et gérer les leads des campagnes Facebook",
    icon = "facebook-lead-ads.svg",
    provider_id = $facebook_provider.id,
    version = "1.0",
    categories = ["Marketing", "Sales"],
    is_active = true,
    is_trigger = true;

-- Resources
LET $lead_resource = CREATE resource SET
    name = "lead",
    display_name = "Lead",
    slug = "lead",
    service_id = $facebook_leadads.id;

-- Tools
CREATE tool SET
    name = "getLeads",
    display_name = "Get Leads",
    slug = "get-leads",
    description = "Retrieve leads from a form",
    resource_id = $lead_resource.id,
    operation_type = "list",
    http_method = "GET",
    api_endpoint = "/{formId}/leads",
    supports_pagination = true;

-- Credential
CREATE credential_type SET
    name = "facebookLeadAdsOAuth2Api",
    display_name = "Facebook Lead Ads OAuth2",
    slug = "facebook-lead-ads-oauth2",
    auth_type = "oauth2",
    provider_id = $facebook_provider.id,
    oauth2_config = {
        auth_url: "https://www.facebook.com/v17.0/dialog/oauth",
        token_url: "https://graph.facebook.com/v17.0/oauth/access_token",
        scope: "leads_retrieval pages_show_list pages_read_engagement",
        grant_type: "authorization_code"
    };

-- =====================================================
-- PROVIDER: Microsoft
-- =====================================================

LET $microsoft_provider = CREATE provider SET
    name = "Microsoft",
    display_name = "Microsoft",
    slug = "microsoft",
    description = "Suite de productivité et services cloud Microsoft",
    icon_light = "microsoft.svg",
    website_url = "https://microsoft.com",
    documentation_url = "https://docs.microsoft.com",
    api_base_url = "https://graph.microsoft.com",
    support_oauth2 = true,
    tags = ["productivity", "cloud", "enterprise", "popular"];

-- Service: Microsoft Teams
LET $teams_service = CREATE service SET
    name = "microsoftTeams",
    display_name = "Microsoft Teams",
    slug = "microsoft-teams",
    description = "Collaboration et communication d'équipe",
    icon = "microsoft-teams.svg",
    provider_id = $microsoft_provider.id,
    version = "1.0",
    categories = ["Communication", "Collaboration"],
    is_active = true;

-- Resources pour Teams
LET $teams_channel = CREATE resource SET
    name = "channel",
    display_name = "Channel",
    slug = "channel",
    service_id = $teams_service.id;

LET $teams_message = CREATE resource SET
    name = "message",
    display_name = "Message",
    slug = "message",
    service_id = $teams_service.id;

-- Tools pour Teams
CREATE tool SET
    name = "postMessage",
    display_name = "Post Message",
    slug = "post-message",
    resource_id = $teams_message.id,
    operation_type = "create",
    http_method = "POST",
    api_endpoint = "/teams/{teamId}/channels/{channelId}/messages";

CREATE tool SET
    name = "listChannels",
    display_name = "List Channels",
    slug = "list-channels",
    resource_id = $teams_channel.id,
    operation_type = "list",
    http_method = "GET",
    api_endpoint = "/teams/{teamId}/channels",
    supports_pagination = true;

-- Service: Microsoft Excel
LET $excel_service = CREATE service SET
    name = "microsoftExcel",
    display_name = "Microsoft Excel",
    slug = "microsoft-excel",
    description = "Manipuler des fichiers Excel en ligne",
    icon = "microsoft-excel.svg",
    provider_id = $microsoft_provider.id,
    version = "1.0",
    categories = ["Data & Storage", "Productivity"],
    is_active = true;

-- Service: Microsoft Outlook
LET $outlook_service = CREATE service SET
    name = "microsoftOutlook",
    display_name = "Microsoft Outlook",
    slug = "microsoft-outlook",
    description = "Gestion des emails et calendrier",
    icon = "microsoft-outlook.svg",
    provider_id = $microsoft_provider.id,
    version = "1.0",
    categories = ["Communication", "Productivity"],
    is_active = true;

-- Credential Microsoft
CREATE credential_type SET
    name = "microsoftOAuth2Api",
    display_name = "Microsoft OAuth2 API",
    slug = "microsoft-oauth2",
    auth_type = "oauth2",
    provider_id = $microsoft_provider.id,
    oauth2_config = {
        auth_url: "https://login.microsoftonline.com/common/oauth2/v2.0/authorize",
        token_url: "https://login.microsoftonline.com/common/oauth2/v2.0/token",
        scope: "offline_access User.ReadWrite.All Mail.ReadWrite Mail.Send",
        grant_type: "authorization_code"
    };

-- =====================================================
-- PROVIDER: Stripe
-- =====================================================

LET $stripe_provider = CREATE provider SET
    name = "Stripe",
    display_name = "Stripe",
    slug = "stripe",
    description = "Plateforme de paiement en ligne",
    icon_light = "stripe.svg",
    website_url = "https://stripe.com",
    documentation_url = "https://stripe.com/docs/api",
    api_base_url = "https://api.stripe.com/v1",
    support_oauth2 = true,
    support_api_key = true,
    tags = ["payment", "ecommerce", "finance", "popular"];

LET $stripe_service = CREATE service SET
    name = "stripe",
    display_name = "Stripe",
    slug = "stripe",
    description = "Accept payments and manage customers",
    icon = "stripe.svg",
    provider_id = $stripe_provider.id,
    version = "1.0",
    categories = ["Payment", "Finance"],
    is_active = true,
    is_trigger = true,
    is_webhook = true;

-- Resources Stripe
LET $customer_stripe = CREATE resource SET
    name = "customer",
    display_name = "Customer",
    slug = "customer",
    service_id = $stripe_service.id;

LET $charge_stripe = CREATE resource SET
    name = "charge",
    display_name = "Charge",
    slug = "charge",
    service_id = $stripe_service.id;

LET $invoice_stripe = CREATE resource SET
    name = "invoice",
    display_name = "Invoice",
    slug = "invoice",
    service_id = $stripe_service.id;

-- Tools Stripe
CREATE tool SET
    name = "create",
    display_name = "Create Customer",
    slug = "create",
    resource_id = $customer_stripe.id,
    operation_type = "create",
    http_method = "POST",
    api_endpoint = "/customers";

CREATE tool SET
    name = "createCharge",
    display_name = "Create Charge",
    slug = "create-charge",
    resource_id = $charge_stripe.id,
    operation_type = "create",
    http_method = "POST",
    api_endpoint = "/charges";

CREATE tool SET
    name = "listInvoices",
    display_name = "List Invoices",
    slug = "list-invoices",
    resource_id = $invoice_stripe.id,
    operation_type = "list",
    http_method = "GET",
    api_endpoint = "/invoices",
    supports_pagination = true;

-- Credentials Stripe
CREATE credential_type SET
    name = "stripeApi",
    display_name = "Stripe API",
    slug = "stripe-api",
    auth_type = "apiKey",
    provider_id = $stripe_provider.id,
    required_fields = [
        {name: "api_key", display_name: "API Key", type: "string", is_secret: true}
    ];

-- =====================================================
-- PROVIDER: Trello
-- =====================================================

LET $trello_provider = CREATE provider SET
    name = "Trello",
    display_name = "Trello",
    slug = "trello",
    description = "Outil de gestion de projet visuel",
    icon_light = "trello.svg",
    website_url = "https://trello.com",
    documentation_url = "https://developer.atlassian.com/cloud/trello",
    api_base_url = "https://api.trello.com/1",
    support_oauth2 = true,
    support_api_key = true,
    tags = ["productivity", "project-management", "popular"];

LET $trello_service = CREATE service SET
    name = "trello",
    display_name = "Trello",
    slug = "trello",
    description = "Manage boards, lists, and cards",
    icon = "trello.svg",
    provider_id = $trello_provider.id,
    version = "1.0",
    categories = ["Productivity", "Project Management"],
    is_active = true,
    is_trigger = true,
    is_webhook = true;

-- Resources Trello
LET $board_trello = CREATE resource SET
    name = "board",
    display_name = "Board",
    slug = "board",
    service_id = $trello_service.id;

LET $card_trello = CREATE resource SET
    name = "card",
    display_name = "Card",
    slug = "card",
    service_id = $trello_service.id;

LET $list_trello = CREATE resource SET
    name = "list",
    display_name = "List",
    slug = "list",
    service_id = $trello_service.id;

-- Tools Trello
CREATE tool SET
    name = "createCard",
    display_name = "Create Card",
    slug = "create-card",
    resource_id = $card_trello.id,
    operation_type = "create",
    http_method = "POST",
    api_endpoint = "/cards";

CREATE tool SET
    name = "updateCard",
    display_name = "Update Card",
    slug = "update-card",
    resource_id = $card_trello.id,
    operation_type = "update",
    http_method = "PUT",
    api_endpoint = "/cards/{id}";

CREATE tool SET
    name = "getCard",
    display_name = "Get Card",
    slug = "get-card",
    resource_id = $card_trello.id,
    operation_type = "read",
    http_method = "GET",
    api_endpoint = "/cards/{id}";

-- =====================================================
-- PROVIDER: Notion
-- =====================================================

LET $notion_provider = CREATE provider SET
    name = "Notion",
    display_name = "Notion",
    slug = "notion",
    description = "Workspace tout-en-un pour notes et collaboration",
    icon_light = "notion.svg",
    icon_dark = "notion-dark.svg",
    website_url = "https://notion.so",
    documentation_url = "https://developers.notion.com",
    api_base_url = "https://api.notion.com/v1",
    support_oauth2 = true,
    support_api_key = true,
    tags = ["productivity", "notes", "database", "popular"];

LET $notion_service = CREATE service SET
    name = "notion",
    display_name = "Notion",
    slug = "notion",
    description = "Consume Notion API",
    icon = "notion.svg",
    provider_id = $notion_provider.id,
    version = "1.0",
    categories = ["Productivity", "Data & Storage"],
    is_active = true;

-- Resources Notion
LET $database_notion = CREATE resource SET
    name = "database",
    display_name = "Database",
    slug = "database",
    service_id = $notion_service.id;

LET $page_notion = CREATE resource SET
    name = "page",
    display_name = "Page",
    slug = "page",
    service_id = $notion_service.id;

-- Tools Notion
CREATE tool SET
    name = "createPage",
    display_name = "Create Page",
    slug = "create-page",
    resource_id = $page_notion.id,
    operation_type = "create",
    http_method = "POST",
    api_endpoint = "/pages";

CREATE tool SET
    name = "queryDatabase",
    display_name = "Query Database",
    slug = "query-database",
    resource_id = $database_notion.id,
    operation_type = "search",
    http_method = "POST",
    api_endpoint = "/databases/{database_id}/query",
    supports_pagination = true,
    supports_filtering = true,
    supports_sorting = true;

-- =====================================================
-- PROVIDER: Airtable
-- =====================================================

LET $airtable_provider = CREATE provider SET
    name = "Airtable",
    display_name = "Airtable",
    slug = "airtable",
    description = "Base de données collaborative en feuille de calcul",
    icon_light = "airtable.svg",
    website_url = "https://airtable.com",
    documentation_url = "https://airtable.com/developers/web/api/introduction",
    api_base_url = "https://api.airtable.com/v0",
    support_oauth2 = true,
    support_api_key = true,
    tags = ["database", "productivity", "popular"];

LET $airtable_service = CREATE service SET
    name = "airtable",
    display_name = "Airtable",
    slug = "airtable",
    description = "Work with Airtable bases",
    icon = "airtable.svg",
    provider_id = $airtable_provider.id,
    version = "1.0",
    categories = ["Data & Storage", "Productivity"],
    is_active = true;

-- Resources Airtable
LET $record_airtable = CREATE resource SET
    name = "record",
    display_name = "Record",
    slug = "record",
    service_id = $airtable_service.id;

-- Tools Airtable
CREATE tool SET
    name = "create",
    display_name = "Create Record",
    slug = "create",
    resource_id = $record_airtable.id,
    operation_type = "create",
    http_method = "POST",
    api_endpoint = "/{baseId}/{tableName}";

CREATE tool SET
    name = "list",
    display_name = "List Records",
    slug = "list",
    resource_id = $record_airtable.id,
    operation_type = "list",
    http_method = "GET",
    api_endpoint = "/{baseId}/{tableName}",
    supports_pagination = true,
    supports_filtering = true,
    supports_sorting = true;

-- =====================================================
-- PROVIDER: Mailchimp
-- =====================================================

LET $mailchimp_provider = CREATE provider SET
    name = "Mailchimp",
    display_name = "Mailchimp",
    slug = "mailchimp",
    description = "Plateforme de marketing par email",
    icon_light = "mailchimp.svg",
    website_url = "https://mailchimp.com",
    documentation_url = "https://mailchimp.com/developer",
    api_base_url = "https://{dc}.api.mailchimp.com/3.0",
    support_oauth2 = true,
    support_api_key = true,
    tags = ["marketing", "email", "popular"];

LET $mailchimp_service = CREATE service SET
    name = "mailchimp",
    display_name = "Mailchimp",
    slug = "mailchimp",
    description = "Email marketing automation",
    icon = "mailchimp.svg",
    provider_id = $mailchimp_provider.id,
    version = "1.0",
    categories = ["Marketing", "Communication"],
    is_active = true;

-- Resources Mailchimp
LET $list_mailchimp = CREATE resource SET
    name = "list",
    display_name = "List",
    slug = "list",
    service_id = $mailchimp_service.id;

LET $member_mailchimp = CREATE resource SET
    name = "member",
    display_name = "Member",
    slug = "member",
    service_id = $mailchimp_service.id;

LET $campaign_mailchimp = CREATE resource SET
    name = "campaign",
    display_name = "Campaign",
    slug = "campaign",
    service_id = $mailchimp_service.id;

-- Tools Mailchimp
CREATE tool SET
    name = "addMember",
    display_name = "Add Member",
    slug = "add-member",
    resource_id = $member_mailchimp.id,
    operation_type = "create",
    http_method = "POST",
    api_endpoint = "/lists/{listId}/members";

CREATE tool SET
    name = "createCampaign",
    display_name = "Create Campaign",
    slug = "create-campaign",
    resource_id = $campaign_mailchimp.id,
    operation_type = "create",
    http_method = "POST",
    api_endpoint = "/campaigns";

-- =====================================================
-- PROVIDER: Twilio
-- =====================================================

LET $twilio_provider = CREATE provider SET
    name = "Twilio",
    display_name = "Twilio",
    slug = "twilio",
    description = "Plateforme de communication cloud (SMS, Voix, WhatsApp)",
    icon_light = "twilio.svg",
    website_url = "https://twilio.com",
    documentation_url = "https://www.twilio.com/docs/api",
    api_base_url = "https://api.twilio.com/2010-04-01",
    support_api_key = true,
    support_basic_auth = true,
    tags = ["communication", "sms", "voice", "popular"];

LET $twilio_service = CREATE service SET
    name = "twilio",
    display_name = "Twilio",
    slug = "twilio",
    description = "Send SMS and make calls",
    icon = "twilio.svg",
    provider_id = $twilio_provider.id,
    version = "1.0",
    categories = ["Communication"],
    is_active = true;

-- Resources Twilio
LET $sms_twilio = CREATE resource SET
    name = "sms",
    display_name = "SMS",
    slug = "sms",
    service_id = $twilio_service.id;

-- Tools Twilio
CREATE tool SET
    name = "send",
    display_name = "Send SMS",
    slug = "send",
    resource_id = $sms_twilio.id,
    operation_type = "create",
    http_method = "POST",
    api_endpoint = "/Accounts/{AccountSid}/Messages.json",
    rate_limit_requests = 100,
    rate_limit_period = "1s";

-- =====================================================
-- PROVIDER: HubSpot
-- =====================================================

LET $hubspot_provider = CREATE provider SET
    name = "HubSpot",
    display_name = "HubSpot",
    slug = "hubspot",
    description = "CRM et plateforme de marketing automation",
    icon_light = "hubspot.svg",
    website_url = "https://hubspot.com",
    documentation_url = "https://developers.hubspot.com/docs/api/overview",
    api_base_url = "https://api.hubapi.com",
    support_oauth2 = true,
    support_api_key = true,
    tags = ["crm", "marketing", "sales", "popular"];

LET $hubspot_service = CREATE service SET
    name = "hubspot",
    display_name = "HubSpot",
    slug = "hubspot",
    description = "CRM and marketing automation",
    icon = "hubspot.svg",
    provider_id = $hubspot_provider.id,
    version = "1.0",
    categories = ["Marketing", "Sales", "CRM"],
    is_active = true;

-- Resources HubSpot
LET $contact_hubspot = CREATE resource SET
    name = "contact",
    display_name = "Contact",
    slug = "contact",
    service_id = $hubspot_service.id;

LET $company_hubspot = CREATE resource SET
    name = "company",
    display_name = "Company",
    slug = "company",
    service_id = $hubspot_service.id;

LET $deal_hubspot = CREATE resource SET
    name = "deal",
    display_name = "Deal",
    slug = "deal",
    service_id = $hubspot_service.id;

-- Tools HubSpot
CREATE tool SET
    name = "create",
    display_name = "Create Contact",
    slug = "create",
    resource_id = $contact_hubspot.id,
    operation_type = "create",
    http_method = "POST",
    api_endpoint = "/crm/v3/objects/contacts";

CREATE tool SET
    name = "createDeal",
    display_name = "Create Deal",
    slug = "create-deal",
    resource_id = $deal_hubspot.id,
    operation_type = "create",
    http_method = "POST",
    api_endpoint = "/crm/v3/objects/deals";

-- =====================================================
-- PROVIDER: Salesforce
-- =====================================================

LET $salesforce_provider = CREATE provider SET
    name = "Salesforce",
    display_name = "Salesforce",
    slug = "salesforce",
    description = "CRM cloud leader",
    icon_light = "salesforce.svg",
    website_url = "https://salesforce.com",
    documentation_url = "https://developer.salesforce.com/docs/apis",
    api_base_url = "https://[instance].salesforce.com/services/data/v58.0",
    support_oauth2 = true,
    tags = ["crm", "enterprise", "sales", "popular"];

LET $salesforce_service = CREATE service SET
    name = "salesforce",
    display_name = "Salesforce",
    slug = "salesforce",
    description = "Enterprise CRM platform",
    icon = "salesforce.svg",
    provider_id = $salesforce_provider.id,
    version = "1.0",
    categories = ["CRM", "Sales"],
    is_active = true;

-- Resources Salesforce
LET $lead_salesforce = CREATE resource SET
    name = "lead",
    display_name = "Lead",
    slug = "lead",
    service_id = $salesforce_service.id;

LET $account_salesforce = CREATE resource SET
    name = "account",
    display_name = "Account",
    slug = "account",
    service_id = $salesforce_service.id;

LET $opportunity_salesforce = CREATE resource SET
    name = "opportunity",
    display_name = "Opportunity",
    slug = "opportunity",
    service_id = $salesforce_service.id;

-- Tools Salesforce
CREATE tool SET
    name = "create",
    display_name = "Create Lead",
    slug = "create",
    resource_id = $lead_salesforce.id,
    operation_type = "create",
    http_method = "POST",
    api_endpoint = "/sobjects/Lead";

CREATE tool SET
    name = "search",
    display_name = "Search",
    slug = "search",
    resource_id = $lead_salesforce.id,
    operation_type = "search",
    http_method = "GET",
    api_endpoint = "/query",
    supports_filtering = true;

-- =====================================================
-- GESTION D'ERREURS COMMUNES
-- =====================================================

-- Error mappings pour Google
CREATE error_mapping SET
    service_id = service:google_sheets,
    http_status_code = 401,
    normalized_message = "Authentification échouée. Veuillez vérifier vos credentials.",
    severity = "error",
    is_retryable = false,
    recommended_action = "Vérifiez que vos tokens OAuth2 sont valides et non expirés";

CREATE error_mapping SET
    service_id = service:google_sheets,
    http_status_code = 403,
    normalized_message = "Permissions insuffisantes",
    severity = "error",
    is_retryable = false,
    recommended_action = "Vérifiez les scopes OAuth2 et les permissions du document";

CREATE error_mapping SET
    service_id = service:google_sheets,
    http_status_code = 404,
    normalized_message = "Document ou feuille non trouvé(e)",
    severity = "error",
    is_retryable = false,
    recommended_action = "Vérifiez que l'ID du document/feuille est correct";

CREATE error_mapping SET
    service_id = service:google_sheets,
    http_status_code = 429,
    api_error_code = "RATE_LIMIT_EXCEEDED",
    normalized_message = "Limite de taux dépassée",
    severity = "warning",
    is_retryable = true,
    recommended_action = "Attendez 60 secondes puis réessayez avec backoff exponentiel";

CREATE error_mapping SET
    service_id = service:google_sheets,
    http_status_code = 500,
    normalized_message = "Erreur serveur Google",
    severity = "error",
    is_retryable = true,
    recommended_action = "Réessayez après quelques secondes";

-- Error mappings pour Slack
CREATE error_mapping SET
    service_id = service:slack,
    http_status_code = 429,
    normalized_message = "Trop de requêtes",
    severity = "warning",
    is_retryable = true,
    recommended_action = "Respectez le header Retry-After";

CREATE error_mapping SET
    service_id = service:slack,
    api_error_code = "channel_not_found",
    normalized_message = "Canal non trouvé",
    severity = "error",
    is_retryable = false,
    recommended_action = "Vérifiez que le canal existe et que le bot y a accès";

CREATE error_mapping SET
    service_id = service:slack,
    api_error_code = "not_in_channel",
    normalized_message = "Bot pas dans le canal",
    severity = "error",
    is_retryable = false,
    recommended_action = "Invitez le bot dans le canal";

-- =====================================================
-- WEBHOOKS CONFIGURATION
-- =====================================================

-- Webhook pour GitHub
CREATE webhook_config SET
    service_id = service:github,
    name = "push",
    display_name = "Push Event",
    event_type = "push",
    http_method = "POST",
    signature_config = {
        header: "X-Hub-Signature-256",
        algorithm: "sha256"
    },
    required_headers = ["X-GitHub-Event", "X-Hub-Signature-256"];

CREATE webhook_config SET
    service_id = service:github,
    name = "pull_request",
    display_name = "Pull Request Event",
    event_type = "pull_request",
    http_method = "POST",
    signature_config = {
        header: "X-Hub-Signature-256",
        algorithm: "sha256"
    };

-- Webhook pour Slack
CREATE webhook_config SET
    service_id = service:slack,
    name = "message",
    display_name = "Message Event",
    event_type = "message",
    http_method = "POST",
    validation_config = {
        challenge_parameter: "challenge"
    };

-- Webhook pour Stripe
CREATE webhook_config SET
    service_id = $stripe_service.id,
    name = "payment_intent",
    display_name = "Payment Intent Event",
    event_type = "payment_intent.succeeded",
    http_method = "POST",
    signature_config = {
        header: "Stripe-Signature",
        algorithm: "sha256"
    };

-- =====================================================
-- TAGS GLOBAUX
-- =====================================================

CREATE tag SET name = "Popular", slug = "popular", color = "#FF6B6B";
CREATE tag SET name = "Enterprise", slug = "enterprise", color = "#4ECDC4";
CREATE tag SET name = "Communication", slug = "communication", color = "#45B7D1";
CREATE tag SET name = "Productivity", slug = "productivity", color = "#FFA07A";
CREATE tag SET name = "Marketing", slug = "marketing", color = "#98D8C8";
CREATE tag SET name = "Development", slug = "development", color = "#A8E6CF";
CREATE tag SET name = "Payment", slug = "payment", color = "#FFD93D";
CREATE tag SET name = "CRM", slug = "crm", color = "#6BCF7F";
CREATE tag SET name = "Social Media", slug = "social-media", color = "#FF8FB1";
CREATE tag SET name = "Cloud", slug = "cloud", color = "#C7CEEA";

-- =====================================================
-- FIN DES SEED DATA
-- =====================================================

