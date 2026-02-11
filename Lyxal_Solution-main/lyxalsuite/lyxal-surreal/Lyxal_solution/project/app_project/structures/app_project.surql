-- ======================================================================
-- TABLE : APP_PROJECT - CONFIGURATION COMPLÈTE
-- ======================================================================
DEFINE TABLE app_project SCHEMAFULL
    COMMENT "Configuration complète de l'application projet";

-- Champs principaux

DEFINE FIELD created_on ON app_project TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON app_project TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON app_project TYPE int DEFAULT 0;

-- ========== CONFIGURATION MÉTIER ==========
DEFINE FIELD full_name_groovy_formula ON app_project TYPE string;
DEFINE FIELD project_label ON app_project TYPE string;
DEFINE FIELD resource_management ON app_project TYPE bool DEFAULT false;
DEFINE FIELD check_resource_availability ON app_project TYPE bool DEFAULT false;
DEFINE FIELD is_enable_signature ON app_project TYPE bool DEFAULT false;
DEFINE FIELD is_enable_per_project_task_sequence ON app_project TYPE bool DEFAULT false;
DEFINE FIELD generate_project_sequence ON app_project TYPE bool DEFAULT false;
DEFINE FIELD select_auto_progress_on_project_task ON app_project TYPE bool DEFAULT false;
DEFINE FIELD enable_status_management_by_task_category ON app_project TYPE bool DEFAULT false;

-- Relations
DEFINE FIELD completed_project_status_id ON app_project TYPE option<record<project_status>>;
DEFINE FIELD canceled_project_status_id ON app_project TYPE option<record<project_status>>;
DEFINE FIELD completed_task_status_id ON app_project TYPE option<record<task_status>>;
DEFINE FIELD default_task_status_set ON app_project TYPE array<record<task_status>>;
DEFINE FIELD default_priority_set ON app_project TYPE array<record<project_priority>>;

-- ========== CONFIGURATION SYSTÈME ==========
DEFINE FIELD enable_multi_company ON app_project TYPE bool DEFAULT false;
DEFINE FIELD enable_advanced_import ON app_project TYPE bool DEFAULT false;
DEFINE FIELD enable_data_backup ON app_project TYPE bool DEFAULT false;
DEFINE FIELD default_timezone ON app_project TYPE string;
DEFINE FIELD default_language ON app_project TYPE string;

-- ========== CONFIGURATION INTERFACE ==========
DEFINE FIELD enable_kanban_view ON app_project TYPE bool DEFAULT false;
DEFINE FIELD enable_gantt_view ON app_project TYPE bool DEFAULT false;
DEFINE FIELD enable_calendar_view ON app_project TYPE bool DEFAULT false;
DEFINE FIELD enable_timeline_view ON app_project TYPE bool DEFAULT false;

-- ========== INTÉGRATIONS ==========
DEFINE FIELD enable_git_integration ON app_project TYPE bool DEFAULT false;
DEFINE FIELD enable_email_integration ON app_project TYPE bool DEFAULT false;
DEFINE FIELD enable_chat_integration ON app_project TYPE bool DEFAULT false;