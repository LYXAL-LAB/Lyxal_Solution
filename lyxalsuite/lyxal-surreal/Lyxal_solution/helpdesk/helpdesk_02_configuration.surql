-- ================================================================================
-- LYXAL SURREAL - AXELOR HELPDESK - MODULE 2 : CONFIGURATION & EXTENSIONS
-- ================================================================================
-- Entités : AppHelpdesk, Project, Sequence, App
-- ================================================================================

-- Configuration Application Helpdesk (AppHelpdesk.xml - 1255 bytes)
DEFINE TABLE app_helpdesk SCHEMAFULL;
DEFINE FIELD app ON app_helpdesk TYPE record<app> UNIQUE;
DEFINE FIELD is_sla ON app_helpdesk TYPE bool DEFAULT false;
DEFINE FIELD manage_timer ON app_helpdesk TYPE bool DEFAULT false;
DEFINE FIELD resolved_ticket_status ON app_helpdesk TYPE record<ticket_status>;
DEFINE FIELD closed_ticket_status ON app_helpdesk TYPE record<ticket_status>;
DEFINE FIELD default_ticket_status ON app_helpdesk TYPE record<ticket_status>;
DEFINE FIELD default_ticket_type ON app_helpdesk TYPE record<ticket_type>;
DEFINE FIELD default_team ON app_helpdesk TYPE record<team>;
DEFINE FIELD default_sla ON app_helpdesk TYPE record<sla>;
DEFINE FIELD default_priority ON app_helpdesk TYPE int DEFAULT 2; -- 1:Low, 2:Normal, 3:High, 4:Urgent, 5:Critical
DEFINE FIELD auto_assignment_enabled ON app_helpdesk TYPE bool DEFAULT false;
DEFINE FIELD auto_assignment_rule ON app_helpdesk TYPE string;
DEFINE FIELD email_integration_enabled ON app_helpdesk TYPE bool DEFAULT false;
DEFINE FIELD email_account ON app_helpdesk TYPE record<email_account>;
DEFINE FIELD notification_enabled ON app_helpdesk TYPE bool DEFAULT true;
DEFINE FIELD notification_template ON app_helpdesk TYPE record<message_template>;
DEFINE FIELD customer_notification_enabled ON app_helpdesk TYPE bool DEFAULT true;
DEFINE FIELD customer_notification_template ON app_helpdesk TYPE record<message_template>;
DEFINE FIELD escalation_enabled ON app_helpdesk TYPE bool DEFAULT false;
DEFINE FIELD escalation_rule ON app_helpdesk TYPE string;
DEFINE FIELD satisfaction_survey_enabled ON app_helpdesk TYPE bool DEFAULT false;
DEFINE FIELD satisfaction_survey_template ON app_helpdesk TYPE record<message_template>;
DEFINE FIELD knowledge_base_enabled ON app_helpdesk TYPE bool DEFAULT false;
DEFINE FIELD knowledge_base_url ON app_helpdesk TYPE string;
DEFINE FIELD portal_access_enabled ON app_helpdesk TYPE bool DEFAULT false;
DEFINE FIELD portal_url ON app_helpdesk TYPE string;
DEFINE FIELD time_tracking_enabled ON app_helpdesk TYPE bool DEFAULT true;
DEFINE FIELD billing_enabled ON app_helpdesk TYPE bool DEFAULT false;
DEFINE FIELD default_billing_rate ON app_helpdesk TYPE decimal DEFAULT 0.0;
DEFINE FIELD reporting_enabled ON app_helpdesk TYPE bool DEFAULT true;
DEFINE FIELD dashboard_enabled ON app_helpdesk TYPE bool DEFAULT true;
DEFINE FIELD analytics_enabled ON app_helpdesk TYPE bool DEFAULT false;
DEFINE FIELD analytics_api_key ON app_helpdesk TYPE string;
DEFINE FIELD max_tickets_per_user ON app_helpdesk TYPE int DEFAULT 100;
DEFINE FIELD ticket_number_prefix ON app_helpdesk TYPE string DEFAULT "HD";
DEFINE FIELD ticket_number_sequence ON app_helpdesk TYPE record<sequence>;
DEFINE FIELD attachment_max_size_mb ON app_helpdesk TYPE int DEFAULT 10;
DEFINE FIELD allowed_file_types ON app_helpdesk TYPE array<string> DEFAULT ["pdf", "doc", "docx", "xls", "xlsx", "png", "jpg", "jpeg"];
DEFINE FIELD backup_enabled ON app_helpdesk TYPE bool DEFAULT false;
DEFINE FIELD backup_frequency ON app_helpdesk TYPE int DEFAULT 1; -- 1:Daily, 2:Weekly, 3:Monthly
DEFINE FIELD backup_retention_days ON app_helpdesk TYPE int DEFAULT 30;
DEFINE FIELD audit_trail_enabled ON app_helpdesk TYPE bool DEFAULT true;
DEFINE FIELD audit_retention_days ON app_helpdesk TYPE int DEFAULT 365;
DEFINE FIELD api_access_enabled ON app_helpdesk TYPE bool DEFAULT false;
DEFINE FIELD api_key ON app_helpdesk TYPE string;
DEFINE FIELD webhook_enabled ON app_helpdesk TYPE bool DEFAULT false;
DEFINE FIELD webhook_url ON app_helpdesk TYPE string;
DEFINE FIELD webhook_events ON app_helpdesk TYPE array<string>;
DEFINE FIELD business_hours_enabled ON app_helpdesk TYPE bool DEFAULT true;
DEFINE FIELD business_hours_start ON app_helpdesk TYPE time DEFAULT '09:00:00';
DEFINE FIELD business_hours_end ON app_helpdesk TYPE time DEFAULT '17:00:00';
DEFINE FIELD working_days ON app_helpdesk TYPE array<int> DEFAULT [1,2,3,4,5];
DEFINE FIELD holiday_calendar ON app_helpdesk TYPE record<holiday_calendar>;
DEFINE FIELD timezone ON app_helpdesk TYPE string DEFAULT "UTC";
DEFINE FIELD language ON app_helpdesk TYPE string DEFAULT "en";
DEFINE FIELD theme ON app_helpdesk TYPE string DEFAULT "default";
DEFINE FIELD logo ON app_helpdesk TYPE record<meta_file>;
DEFINE FIELD custom_fields_enabled ON app_helpdesk TYPE bool DEFAULT false;
DEFINE FIELD workflow_enabled ON app_helpdesk TYPE bool DEFAULT false;
DEFINE FIELD approval_workflow_enabled ON app_helpdesk TYPE bool DEFAULT false;
DEFINE FIELD integration_settings ON app_helpdesk TYPE string;
DEFINE FIELD custom_scripts ON app_helpdesk TYPE string;
DEFINE FIELD maintenance_mode ON app_helpdesk TYPE bool DEFAULT false;
DEFINE FIELD maintenance_message ON app_helpdesk TYPE string;
DEFINE FIELD created_at ON app_helpdesk TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON app_helpdesk TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON app_helpdesk TYPE int DEFAULT 0;

-- Extension Projet (Project.xml - 543 bytes)
DEFINE TABLE project_helpdesk SCHEMAFULL;
DEFINE FIELD project ON project_helpdesk TYPE record<project>;
DEFINE FIELD helpdesk_enabled ON project_helpdesk TYPE bool DEFAULT false;
DEFINE FIELD default_ticket_type ON project_helpdesk TYPE record<ticket_type>;
DEFINE FIELD default_ticket_status ON project_helpdesk TYPE record<ticket_status>;
DEFINE FIELD default_priority ON project_helpdesk TYPE int DEFAULT 2;
DEFINE FIELD default_assigned_user ON project_helpdesk TYPE record<user>;
DEFINE FIELD default_team ON project_helpdesk TYPE record<team>;
DEFINE FIELD auto_assignment_enabled ON project_helpdesk TYPE bool DEFAULT false;
DEFINE FIELD auto_assignment_rule ON project_helpdesk TYPE string;
DEFINE FIELD sla ON project_helpdesk TYPE record<sla>;
DEFINE FIELD notification_enabled ON project_helpdesk TYPE bool DEFAULT true;
DEFINE FIELD customer_access_enabled ON project_helpdesk TYPE bool DEFAULT false;
DEFINE FIELD ticket_prefix ON project_helpdesk TYPE string;
DEFINE FIELD ticket_sequence ON project_helpdesk TYPE record<sequence>;
DEFINE FIELD billing_enabled ON project_helpdesk TYPE bool DEFAULT false;
DEFINE FIELD billing_rate ON project_helpdesk TYPE decimal DEFAULT 0.0;
DEFINE FIELD time_tracking_enabled ON project_helpdesk TYPE bool DEFAULT true;
DEFINE FIELD workflow_template ON project_helpdesk TYPE record<workflow_template>;
DEFINE FIELD custom_fields ON project_helpdesk TYPE string;
DEFINE FIELD integration_settings ON project_helpdesk TYPE string;
DEFINE FIELD created_at ON project_helpdesk TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON project_helpdesk TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON project_helpdesk TYPE int DEFAULT 0;

-- Séquence Helpdesk (Sequence.xml - 543 bytes)
DEFINE TABLE sequence_helpdesk SCHEMAFULL;
DEFINE FIELD sequence ON sequence_helpdesk TYPE record<sequence>;
DEFINE FIELD helpdesk_module ON sequence_helpdesk TYPE string;
DEFINE FIELD entity_name ON sequence_helpdesk TYPE string;
DEFINE FIELD prefix ON sequence_helpdesk TYPE string DEFAULT "HD";
DEFINE FIELD suffix ON sequence_helpdesk TYPE string;
DEFINE FIELD padding ON sequence_helpdesk TYPE int DEFAULT 4;
DEFINE FIELD increment ON sequence_helpdesk TYPE int DEFAULT 1;
DEFINE FIELD current_value ON sequence_helpdesk TYPE int DEFAULT 1;
DEFINE FIELD reset_annually ON sequence_helpdesk TYPE bool DEFAULT false;
DEFINE FIELD reset_monthly ON sequence_helpdesk TYPE bool DEFAULT false;
DEFINE FIELD date_format ON sequence_helpdesk TYPE string;
DEFINE FIELD company ON sequence_helpdesk TYPE record<company>;
DEFINE FIELD is_active ON sequence_helpdesk TYPE bool DEFAULT true;
DEFINE FIELD last_reset_date ON sequence_helpdesk TYPE date;
DEFINE FIELD next_reset_date ON sequence_helpdesk TYPE date;
DEFINE FIELD usage_count ON sequence_helpdesk TYPE int DEFAULT 0;
DEFINE FIELD max_usage ON sequence_helpdesk TYPE int;
DEFINE FIELD custom_format ON sequence_helpdesk TYPE string;
DEFINE FIELD validation_pattern ON sequence_helpdesk TYPE string;
DEFINE FIELD created_at ON sequence_helpdesk TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON sequence_helpdesk TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON sequence_helpdesk TYPE int DEFAULT 0;

-- Extension App (App.xml - 516 bytes)
DEFINE TABLE app_helpdesk_extension SCHEMAFULL;
DEFINE FIELD app ON app_helpdesk_extension TYPE record<app>;
DEFINE FIELD helpdesk_module_version ON app_helpdesk_extension TYPE string DEFAULT "1.0.0";
DEFINE FIELD is_helpdesk_enabled ON app_helpdesk_extension TYPE bool DEFAULT false;
DEFINE FIELD license_type ON app_helpdesk_extension TYPE string DEFAULT "basic";
DEFINE FIELD max_users ON app_helpdesk_extension TYPE int DEFAULT 10;
DEFINE FIELD max_tickets ON app_helpdesk_extension TYPE int DEFAULT 1000;
DEFINE FIELD features_enabled ON app_helpdesk_extension TYPE array<string>;
DEFINE FIELD integrations_enabled ON app_helpdesk_extension TYPE array<string>;
DEFINE FIELD custom_branding_enabled ON app_helpdesk_extension TYPE bool DEFAULT false;
DEFINE FIELD api_calls_limit ON app_helpdesk_extension TYPE int DEFAULT 10000;
DEFINE FIELD storage_limit_gb ON app_helpdesk_extension TYPE decimal DEFAULT 1.0;
DEFINE FIELD backup_enabled ON app_helpdesk_extension TYPE bool DEFAULT false;
DEFINE FIELD support_level ON app_helpdesk_extension TYPE string DEFAULT "community";
DEFINE FIELD subscription_start_date ON app_helpdesk_extension TYPE date;
DEFINE FIELD subscription_end_date ON app_helpdesk_extension TYPE date;
DEFINE FIELD last_license_check ON app_helpdesk_extension TYPE datetime;
DEFINE FIELD license_status ON app_helpdesk_extension TYPE string DEFAULT "active";
DEFINE FIELD usage_statistics ON app_helpdesk_extension TYPE string;
DEFINE FIELD performance_metrics ON app_helpdesk_extension TYPE string;
DEFINE FIELD created_at ON app_helpdesk_extension TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON app_helpdesk_extension TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON app_helpdesk_extension TYPE int DEFAULT 0;

-- Tables de support et configuration avancée
DEFINE TABLE helpdesk_dashboard_config SCHEMAFULL;
DEFINE FIELD name ON helpdesk_dashboard_config TYPE string ASSERT $value != NONE;
DEFINE FIELD user ON helpdesk_dashboard_config TYPE record<user>;
DEFINE FIELD team ON helpdesk_dashboard_config TYPE record<team>;
DEFINE FIELD is_default ON helpdesk_dashboard_config TYPE bool DEFAULT false;
DEFINE FIELD layout_config ON helpdesk_dashboard_config TYPE string;
DEFINE FIELD widgets_config ON helpdesk_dashboard_config TYPE string;
DEFINE FIELD filters_config ON helpdesk_dashboard_config TYPE string;
DEFINE FIELD refresh_interval ON helpdesk_dashboard_config TYPE int DEFAULT 300; -- secondes
DEFINE FIELD is_public ON helpdesk_dashboard_config TYPE bool DEFAULT false;
DEFINE FIELD permissions ON helpdesk_dashboard_config TYPE array<string>;
DEFINE FIELD created_at ON helpdesk_dashboard_config TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON helpdesk_dashboard_config TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON helpdesk_dashboard_config TYPE int DEFAULT 0;

DEFINE TABLE helpdesk_notification_rule SCHEMAFULL;
DEFINE FIELD name ON helpdesk_notification_rule TYPE string ASSERT $value != NONE;
DEFINE FIELD is_active ON helpdesk_notification_rule TYPE bool DEFAULT true;
DEFINE FIELD trigger_event ON helpdesk_notification_rule TYPE string ASSERT $value != NONE;
DEFINE FIELD conditions ON helpdesk_notification_rule TYPE string;
DEFINE FIELD recipient_type ON helpdesk_notification_rule TYPE int DEFAULT 1; -- 1:Assigned User, 2:Reporter, 3:Team, 4:Custom
DEFINE FIELD custom_recipients ON helpdesk_notification_rule TYPE array<record<user>>;
DEFINE FIELD message_template ON helpdesk_notification_rule TYPE record<message_template>;
DEFINE FIELD notification_method ON helpdesk_notification_rule TYPE int DEFAULT 1; -- 1:Email, 2:SMS, 3:Push, 4:In-App
DEFINE FIELD delay_minutes ON helpdesk_notification_rule TYPE int DEFAULT 0;
DEFINE FIELD frequency_limit ON helpdesk_notification_rule TYPE int; -- Max notifications per day
DEFINE FIELD priority_threshold ON helpdesk_notification_rule TYPE int;
DEFINE FIELD team ON helpdesk_notification_rule TYPE record<team>;
DEFINE FIELD ticket_type ON helpdesk_notification_rule TYPE record<ticket_type>;
DEFINE FIELD execution_count ON helpdesk_notification_rule TYPE int DEFAULT 0;
DEFINE FIELD last_execution ON helpdesk_notification_rule TYPE datetime;
DEFINE FIELD created_at ON helpdesk_notification_rule TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON helpdesk_notification_rule TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON helpdesk_notification_rule TYPE int DEFAULT 0;

DEFINE TABLE helpdesk_automation_rule SCHEMAFULL;
DEFINE FIELD name ON helpdesk_automation_rule TYPE string ASSERT $value != NONE;
DEFINE FIELD is_active ON helpdesk_automation_rule TYPE bool DEFAULT true;
DEFINE FIELD trigger_event ON helpdesk_automation_rule TYPE string ASSERT $value != NONE;
DEFINE FIELD conditions ON helpdesk_automation_rule TYPE string;
DEFINE FIELD actions ON helpdesk_automation_rule TYPE string ASSERT $value != NONE;
DEFINE FIELD execution_order ON helpdesk_automation_rule TYPE int DEFAULT 100;
DEFINE FIELD team ON helpdesk_automation_rule TYPE record<team>;
DEFINE FIELD ticket_type ON helpdesk_automation_rule TYPE record<ticket_type>;
DEFINE FIELD run_frequency ON helpdesk_automation_rule TYPE int DEFAULT 1; -- 1:Immediate, 2:Hourly, 3:Daily
DEFINE FIELD last_run ON helpdesk_automation_rule TYPE datetime;
DEFINE FIELD next_run ON helpdesk_automation_rule TYPE datetime;
DEFINE FIELD execution_count ON helpdesk_automation_rule TYPE int DEFAULT 0;
DEFINE FIELD success_count ON helpdesk_automation_rule TYPE int DEFAULT 0;
DEFINE FIELD failure_count ON helpdesk_automation_rule TYPE int DEFAULT 0;
DEFINE FIELD last_error ON helpdesk_automation_rule TYPE string;
DEFINE FIELD created_by ON helpdesk_automation_rule TYPE record<user>;
DEFINE FIELD created_at ON helpdesk_automation_rule TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON helpdesk_automation_rule TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON helpdesk_automation_rule TYPE int DEFAULT 0;

DEFINE TABLE helpdesk_knowledge_article SCHEMAFULL;
DEFINE FIELD title ON helpdesk_knowledge_article TYPE string ASSERT $value != NONE;
DEFINE FIELD content ON helpdesk_knowledge_article TYPE string ASSERT $value != NONE;
DEFINE FIELD summary ON helpdesk_knowledge_article TYPE string;
DEFINE FIELD category ON helpdesk_knowledge_article TYPE string;
DEFINE FIELD tags ON helpdesk_knowledge_article TYPE array<string>;
DEFINE FIELD ticket_types ON helpdesk_knowledge_article TYPE array<record<ticket_type>>;
DEFINE FIELD is_published ON helpdesk_knowledge_article TYPE bool DEFAULT false;
DEFINE FIELD is_public ON helpdesk_knowledge_article TYPE bool DEFAULT false;
DEFINE FIELD author ON helpdesk_knowledge_article TYPE record<user>;
DEFINE FIELD reviewer ON helpdesk_knowledge_article TYPE record<user>;
DEFINE FIELD review_date ON helpdesk_knowledge_article TYPE datetime;
DEFINE FIELD published_date ON helpdesk_knowledge_article TYPE datetime;
DEFINE FIELD expiry_date ON helpdesk_knowledge_article TYPE datetime;
DEFINE FIELD view_count ON helpdesk_knowledge_article TYPE int DEFAULT 0;
DEFINE FIELD helpful_count ON helpdesk_knowledge_article TYPE int DEFAULT 0;
DEFINE FIELD not_helpful_count ON helpdesk_knowledge_article TYPE int DEFAULT 0;
DEFINE FIELD rating ON helpdesk_knowledge_article TYPE decimal DEFAULT 0.0;
DEFINE FIELD attachments ON helpdesk_knowledge_article TYPE array<record<meta_file>>;
DEFINE FIELD related_articles ON helpdesk_knowledge_article TYPE array<record<helpdesk_knowledge_article>>;
DEFINE FIELD related_tickets ON helpdesk_knowledge_article TYPE array<record<ticket>>;
DEFINE FIELD search_keywords ON helpdesk_knowledge_article TYPE string;
DEFINE FIELD language ON helpdesk_knowledge_article TYPE string DEFAULT "en";
DEFINE FIELD version_number ON helpdesk_knowledge_article TYPE string DEFAULT "1.0";
DEFINE FIELD change_log ON helpdesk_knowledge_article TYPE string;
DEFINE FIELD created_at ON helpdesk_knowledge_article TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON helpdesk_knowledge_article TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON helpdesk_knowledge_article TYPE int DEFAULT 0;

-- Index d'optimisation
DEFINE INDEX idx_app_helpdesk_app ON app_helpdesk FIELDS app;
DEFINE INDEX idx_app_helpdesk_sla ON app_helpdesk FIELDS is_sla;
DEFINE INDEX idx_app_helpdesk_timer ON app_helpdesk FIELDS manage_timer;
DEFINE INDEX idx_app_helpdesk_auto_assign ON app_helpdesk FIELDS auto_assignment_enabled;
DEFINE INDEX idx_app_helpdesk_email_integration ON app_helpdesk FIELDS email_integration_enabled;
DEFINE INDEX idx_app_helpdesk_notification ON app_helpdesk FIELDS notification_enabled;
DEFINE INDEX idx_app_helpdesk_escalation ON app_helpdesk FIELDS escalation_enabled;
DEFINE INDEX idx_app_helpdesk_portal ON app_helpdesk FIELDS portal_access_enabled;
DEFINE INDEX idx_app_helpdesk_time_tracking ON app_helpdesk FIELDS time_tracking_enabled;
DEFINE INDEX idx_app_helpdesk_billing ON app_helpdesk FIELDS billing_enabled;

DEFINE INDEX idx_project_helpdesk_project ON project_helpdesk FIELDS project;
DEFINE INDEX idx_project_helpdesk_enabled ON project_helpdesk FIELDS helpdesk_enabled;
DEFINE INDEX idx_project_helpdesk_auto_assign ON project_helpdesk FIELDS auto_assignment_enabled;
DEFINE INDEX idx_project_helpdesk_billing ON project_helpdesk FIELDS billing_enabled;
DEFINE INDEX idx_project_helpdesk_time_tracking ON project_helpdesk FIELDS time_tracking_enabled;

DEFINE INDEX idx_sequence_helpdesk_sequence ON sequence_helpdesk FIELDS sequence;
DEFINE INDEX idx_sequence_helpdesk_module ON sequence_helpdesk FIELDS helpdesk_module;
DEFINE INDEX idx_sequence_helpdesk_entity ON sequence_helpdesk FIELDS entity_name;
DEFINE INDEX idx_sequence_helpdesk_active ON sequence_helpdesk FIELDS is_active;
DEFINE INDEX idx_sequence_helpdesk_company ON sequence_helpdesk FIELDS company;

DEFINE INDEX idx_app_helpdesk_ext_app ON app_helpdesk_extension FIELDS app;
DEFINE INDEX idx_app_helpdesk_ext_enabled ON app_helpdesk_extension FIELDS is_helpdesk_enabled;
DEFINE INDEX idx_app_helpdesk_ext_license ON app_helpdesk_extension FIELDS license_type;
DEFINE INDEX idx_app_helpdesk_ext_status ON app_helpdesk_extension FIELDS license_status;

DEFINE INDEX idx_dashboard_config_name ON helpdesk_dashboard_config FIELDS name;
DEFINE INDEX idx_dashboard_config_user ON helpdesk_dashboard_config FIELDS user;
DEFINE INDEX idx_dashboard_config_team ON helpdesk_dashboard_config FIELDS team;
DEFINE INDEX idx_dashboard_config_default ON helpdesk_dashboard_config FIELDS is_default;
DEFINE INDEX idx_dashboard_config_public ON helpdesk_dashboard_config FIELDS is_public;

DEFINE INDEX idx_notification_rule_name ON helpdesk_notification_rule FIELDS name;
DEFINE INDEX idx_notification_rule_active ON helpdesk_notification_rule FIELDS is_active;
DEFINE INDEX idx_notification_rule_event ON helpdesk_notification_rule FIELDS trigger_event;
DEFINE INDEX idx_notification_rule_team ON helpdesk_notification_rule FIELDS team;
DEFINE INDEX idx_notification_rule_type ON helpdesk_notification_rule FIELDS ticket_type;

DEFINE INDEX idx_automation_rule_name ON helpdesk_automation_rule FIELDS name;
DEFINE INDEX idx_automation_rule_active ON helpdesk_automation_rule FIELDS is_active;
DEFINE INDEX idx_automation_rule_event ON helpdesk_automation_rule FIELDS trigger_event;
DEFINE INDEX idx_automation_rule_team ON helpdesk_automation_rule FIELDS team;
DEFINE INDEX idx_automation_rule_next_run ON helpdesk_automation_rule FIELDS next_run;
DEFINE INDEX idx_automation_rule_created_by ON helpdesk_automation_rule FIELDS created_by;

DEFINE INDEX idx_knowledge_article_title ON helpdesk_knowledge_article FIELDS title;
DEFINE INDEX idx_knowledge_article_category ON helpdesk_knowledge_article FIELDS category;
DEFINE INDEX idx_knowledge_article_published ON helpdesk_knowledge_article FIELDS is_published;
DEFINE INDEX idx_knowledge_article_public ON helpdesk_knowledge_article FIELDS is_public;
DEFINE INDEX idx_knowledge_article_author ON helpdesk_knowledge_article FIELDS author;
DEFINE INDEX idx_knowledge_article_rating ON helpdesk_knowledge_article FIELDS rating;
DEFINE INDEX idx_knowledge_article_language ON helpdesk_knowledge_article FIELDS language; 