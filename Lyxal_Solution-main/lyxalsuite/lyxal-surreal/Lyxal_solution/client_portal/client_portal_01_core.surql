-- ================================================================================
-- LYXAL SURREAL - AXELOR CLIENT PORTAL - MODULE 1 : ENTITÉS PRINCIPALES
-- ================================================================================
-- Entités : AppPortal, OnlinePaymentMethod, App (extension)
-- ================================================================================

-- Configuration du portail client (AppPortal.xml - 2033 bytes)
DEFINE TABLE app_portal SCHEMAFULL;
DEFINE FIELD app ON app_portal TYPE record<app> UNIQUE;
DEFINE FIELD manage_sale_orders ON app_portal TYPE bool DEFAULT false;
DEFINE FIELD manage_invoices ON app_portal TYPE bool DEFAULT false;
DEFINE FIELD manage_deliveries ON app_portal TYPE bool DEFAULT false;
DEFINE FIELD manage_quotations ON app_portal TYPE bool DEFAULT false;
DEFINE FIELD manage_projects ON app_portal TYPE bool DEFAULT false;
DEFINE FIELD manage_tickets ON app_portal TYPE bool DEFAULT false;
DEFINE FIELD manage_tasks ON app_portal TYPE bool DEFAULT false;
DEFINE FIELD enable_online_payment ON app_portal TYPE bool DEFAULT false;
DEFINE FIELD enable_electronic_signature ON app_portal TYPE bool DEFAULT false;
DEFINE FIELD portal_url ON app_portal TYPE string;
DEFINE FIELD portal_title ON app_portal TYPE string DEFAULT "Client Portal";
DEFINE FIELD portal_logo ON app_portal TYPE record<meta_file>;
DEFINE FIELD default_language ON app_portal TYPE string DEFAULT "en";
DEFINE FIELD allow_registration ON app_portal TYPE bool DEFAULT false;
DEFINE FIELD email_template_registration ON app_portal TYPE record<template>;
DEFINE FIELD email_template_password ON app_portal TYPE record<template>;
DEFINE FIELD portal_theme ON app_portal TYPE string DEFAULT "default";
DEFINE FIELD enable_notifications ON app_portal TYPE bool DEFAULT true;
DEFINE FIELD session_timeout ON app_portal TYPE int DEFAULT 30;
DEFINE FIELD max_file_upload_size ON app_portal TYPE int DEFAULT 10;
DEFINE FIELD allowed_file_types ON app_portal TYPE array<string>;
DEFINE FIELD custom_css ON app_portal TYPE string;
DEFINE FIELD custom_javascript ON app_portal TYPE string;
DEFINE FIELD footer_text ON app_portal TYPE string;
DEFINE FIELD contact_email ON app_portal TYPE string;
DEFINE FIELD support_phone ON app_portal TYPE string;
DEFINE FIELD terms_conditions_url ON app_portal TYPE string;
DEFINE FIELD privacy_policy_url ON app_portal TYPE string;
DEFINE FIELD maintenance_mode ON app_portal TYPE bool DEFAULT false;
DEFINE FIELD maintenance_message ON app_portal TYPE string;
DEFINE FIELD created_at ON app_portal TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON app_portal TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON app_portal TYPE int DEFAULT 0;

-- Méthodes de paiement en ligne (OnlinePaymentMethod.xml - 569 bytes)
DEFINE TABLE online_payment_method SCHEMAFULL;
DEFINE FIELD name ON online_payment_method TYPE string ASSERT $value != NONE;
DEFINE FIELD code ON online_payment_method TYPE string UNIQUE;
DEFINE FIELD is_active ON online_payment_method TYPE bool DEFAULT true;
DEFINE FIELD payment_provider ON online_payment_method TYPE string;
DEFINE FIELD provider_config ON online_payment_method TYPE object;
DEFINE FIELD supported_currencies ON online_payment_method TYPE array<string>;
DEFINE FIELD min_amount ON online_payment_method TYPE decimal DEFAULT 0.0;
DEFINE FIELD max_amount ON online_payment_method TYPE decimal;
DEFINE FIELD transaction_fee_percentage ON online_payment_method TYPE decimal DEFAULT 0.0;
DEFINE FIELD transaction_fee_fixed ON online_payment_method TYPE decimal DEFAULT 0.0;
DEFINE FIELD description ON online_payment_method TYPE string;
DEFINE FIELD icon_url ON online_payment_method TYPE string;
DEFINE FIELD display_order ON online_payment_method TYPE int DEFAULT 1;
DEFINE FIELD enable_recurring ON online_payment_method TYPE bool DEFAULT false;
DEFINE FIELD enable_refunds ON online_payment_method TYPE bool DEFAULT true;
DEFINE FIELD webhook_url ON online_payment_method TYPE string;
DEFINE FIELD api_key ON online_payment_method TYPE string;
DEFINE FIELD secret_key ON online_payment_method TYPE string;
DEFINE FIELD test_mode ON online_payment_method TYPE bool DEFAULT true;
DEFINE FIELD success_redirect_url ON online_payment_method TYPE string;
DEFINE FIELD cancel_redirect_url ON online_payment_method TYPE string;
DEFINE FIELD created_at ON online_payment_method TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON online_payment_method TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON online_payment_method TYPE int DEFAULT 0;

-- Extension Application (App.xml - 512 bytes)
DEFINE TABLE app_client_portal SCHEMAFULL;
DEFINE FIELD app ON app_client_portal TYPE record<app>;
DEFINE FIELD app_portal ON app_client_portal TYPE record<app_portal>;
DEFINE FIELD is_portal_enabled ON app_client_portal TYPE bool DEFAULT false;
DEFINE FIELD portal_access_roles ON app_client_portal TYPE array<record<role>>;
DEFINE FIELD default_portal_user_group ON app_client_portal TYPE record<group>;
DEFINE FIELD portal_registration_enabled ON app_client_portal TYPE bool DEFAULT false;
DEFINE FIELD portal_auto_approve_users ON app_client_portal TYPE bool DEFAULT false;
DEFINE FIELD portal_domain_restrictions ON app_client_portal TYPE array<string>;
DEFINE FIELD portal_ip_restrictions ON app_client_portal TYPE array<string>;
DEFINE FIELD enable_portal_analytics ON app_client_portal TYPE bool DEFAULT true;
DEFINE FIELD portal_analytics_config ON app_client_portal TYPE object;
DEFINE FIELD created_at ON app_client_portal TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON app_client_portal TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON app_client_portal TYPE int DEFAULT 0;

-- Configuration des sélections pour le portail client
DEFINE TABLE client_portal_selection SCHEMAFULL;
DEFINE FIELD name ON client_portal_selection TYPE string UNIQUE;
DEFINE FIELD title ON client_portal_selection TYPE string;
DEFINE FIELD options ON client_portal_selection TYPE array<object>;
DEFINE FIELD is_active ON client_portal_selection TYPE bool DEFAULT true;
DEFINE FIELD created_at ON client_portal_selection TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON client_portal_selection TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON client_portal_selection TYPE int DEFAULT 0;

-- Transactions de paiement en ligne
DEFINE TABLE online_payment_transaction SCHEMAFULL;
DEFINE FIELD transaction_id ON online_payment_transaction TYPE string UNIQUE;
DEFINE FIELD payment_method ON online_payment_transaction TYPE record<online_payment_method>;
DEFINE FIELD partner ON online_payment_transaction TYPE record<partner>;
DEFINE FIELD sale_order ON online_payment_transaction TYPE record<sale_order>;
DEFINE FIELD invoice ON online_payment_transaction TYPE record<invoice>;
DEFINE FIELD amount ON online_payment_transaction TYPE decimal ASSERT $value > 0.0;
DEFINE FIELD currency ON online_payment_transaction TYPE record<currency>;
DEFINE FIELD status ON online_payment_transaction TYPE int DEFAULT 1; -- 1:Pending, 2:Success, 3:Failed, 4:Cancelled
DEFINE FIELD provider_transaction_id ON online_payment_transaction TYPE string;
DEFINE FIELD provider_response ON online_payment_transaction TYPE object;
DEFINE FIELD transaction_date ON online_payment_transaction TYPE datetime DEFAULT time::now();
DEFINE FIELD success_date ON online_payment_transaction TYPE datetime;
DEFINE FIELD failure_reason ON online_payment_transaction TYPE string;
DEFINE FIELD refund_amount ON online_payment_transaction TYPE decimal DEFAULT 0.0;
DEFINE FIELD refund_date ON online_payment_transaction TYPE datetime;
DEFINE FIELD webhook_received ON online_payment_transaction TYPE bool DEFAULT false;
DEFINE FIELD created_at ON online_payment_transaction TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON online_payment_transaction TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON online_payment_transaction TYPE int DEFAULT 0;

-- Index pour optimisation
DEFINE INDEX idx_app_portal_app ON app_portal FIELDS app;
DEFINE INDEX idx_app_portal_manage_sale_orders ON app_portal FIELDS manage_sale_orders;
DEFINE INDEX idx_app_portal_enable_online_payment ON app_portal FIELDS enable_online_payment;
DEFINE INDEX idx_app_portal_maintenance_mode ON app_portal FIELDS maintenance_mode;

DEFINE INDEX idx_online_payment_method_code ON online_payment_method FIELDS code;
DEFINE INDEX idx_online_payment_method_is_active ON online_payment_method FIELDS is_active;
DEFINE INDEX idx_online_payment_method_provider ON online_payment_method FIELDS payment_provider;
DEFINE INDEX idx_online_payment_method_display_order ON online_payment_method FIELDS display_order;

DEFINE INDEX idx_app_client_portal_app ON app_client_portal FIELDS app;
DEFINE INDEX idx_app_client_portal_is_enabled ON app_client_portal FIELDS is_portal_enabled;
DEFINE INDEX idx_app_client_portal_registration ON app_client_portal FIELDS portal_registration_enabled;

DEFINE INDEX idx_online_payment_transaction_id ON online_payment_transaction FIELDS transaction_id;
DEFINE INDEX idx_online_payment_transaction_method ON online_payment_transaction FIELDS payment_method;
DEFINE INDEX idx_online_payment_transaction_partner ON online_payment_transaction FIELDS partner;
DEFINE INDEX idx_online_payment_transaction_status ON online_payment_transaction FIELDS status;
DEFINE INDEX idx_online_payment_transaction_date ON online_payment_transaction FIELDS transaction_date;