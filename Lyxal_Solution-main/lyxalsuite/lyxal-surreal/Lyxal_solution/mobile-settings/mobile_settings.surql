-- ======================================================================
-- MIGRATION MODULE AXELOR-MOBILE-SETTINGS VERS SURREALDB
-- ======================================================================
-- Module : axelor-mobile-settings
-- Description : Configuration et gestion des paramètres pour applications mobiles
-- Date : 2024
-- Entités : 12 entités migrées
-- ======================================================================

-- Nettoyage des tables existantes
REMOVE TABLE IF EXISTS app_mobile_settings;
REMOVE TABLE IF EXISTS mobile_config;
REMOVE TABLE IF EXISTS mobile_menu;
REMOVE TABLE IF EXISTS mobile_dashboard;
REMOVE TABLE IF EXISTS mobile_dashboard_line;
REMOVE TABLE IF EXISTS mobile_shortcut;
REMOVE TABLE IF EXISTS mobile_screen;
REMOVE TABLE IF EXISTS mobile_chart;
REMOVE TABLE IF EXISTS mobile_web_view;
REMOVE TABLE IF EXISTS user_mobile_extension;
REMOVE TABLE IF EXISTS app_mobile_extension;
REMOVE TABLE IF EXISTS meta_json_field_mobile;

-- ======================================================================
-- 1. TABLE : APP_MOBILE_SETTINGS
-- ======================================================================
DEFINE TABLE app_mobile_settings SCHEMAFULL
    COMMENT "Configuration principale des paramètres mobiles pour applications";

-- Champs principaux
DEFINE FIELD id ON app_mobile_settings TYPE record<app_mobile_settings>;
DEFINE FIELD app_id ON app_mobile_settings TYPE option<record<app>>;
DEFINE FIELD created_on ON app_mobile_settings TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON app_mobile_settings TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON app_mobile_settings TYPE int DEFAULT 0;

-- Applications activées
DEFINE FIELD is_stock_app_enabled ON app_mobile_settings TYPE bool DEFAULT false;
DEFINE FIELD is_production_app_enabled ON app_mobile_settings TYPE bool DEFAULT false;
DEFINE FIELD is_crm_app_enabled ON app_mobile_settings TYPE bool DEFAULT false;
DEFINE FIELD is_helpdesk_app_enabled ON app_mobile_settings TYPE bool DEFAULT false;
DEFINE FIELD is_hr_app_enabled ON app_mobile_settings TYPE bool DEFAULT false;
DEFINE FIELD is_quality_app_enabled ON app_mobile_settings TYPE bool DEFAULT false;
DEFINE FIELD is_intervention_app_enabled ON app_mobile_settings TYPE bool DEFAULT false;
DEFINE FIELD is_sale_app_enabled ON app_mobile_settings TYPE bool DEFAULT false;
DEFINE FIELD is_project_app_enabled ON app_mobile_settings TYPE bool DEFAULT false;
DEFINE FIELD is_dms_app_enabled ON app_mobile_settings TYPE bool DEFAULT false;
DEFINE FIELD is_purchase_app_enabled ON app_mobile_settings TYPE bool DEFAULT false;

-- Configuration QR Code
DEFINE FIELD qr_code_id ON app_mobile_settings TYPE option<record<meta_file>>;
DEFINE FIELD is_login_user_qrcode_enabled ON app_mobile_settings TYPE bool DEFAULT false;

-- Configuration transporteur
DEFINE FIELD manage_carrier_option ON app_mobile_settings TYPE bool DEFAULT false;

-- Configuration validations
DEFINE FIELD is_inventory_validation_enabled ON app_mobile_settings TYPE bool DEFAULT false;
DEFINE FIELD is_stock_correction_validation_enabled ON app_mobile_settings TYPE bool DEFAULT false;
DEFINE FIELD is_customer_delivery_line_addition_enabled ON app_mobile_settings TYPE bool DEFAULT false;
DEFINE FIELD is_supplier_arrival_line_addition_enabled ON app_mobile_settings TYPE bool DEFAULT false;

-- Configuration version mobile
DEFINE FIELD minimal_required_mobile_app_version ON app_mobile_settings TYPE string;
DEFINE FIELD current_apk_file_id ON app_mobile_settings TYPE option<record<meta_file>>;

-- Configuration messages tracker
DEFINE FIELD is_tracker_message_enabled ON app_mobile_settings TYPE bool DEFAULT false;

-- Configuration vérification lignes stock
DEFINE FIELD is_verify_customer_delivery_line_enabled ON app_mobile_settings TYPE bool DEFAULT false;
DEFINE FIELD is_verify_supplier_arrival_line_enabled ON app_mobile_settings TYPE bool DEFAULT false;
DEFINE FIELD is_verify_internal_move_line_enabled ON app_mobile_settings TYPE bool DEFAULT false;
DEFINE FIELD is_verify_inventory_line_enabled ON app_mobile_settings TYPE bool DEFAULT false;

-- Configuration multi-devises et projets
DEFINE FIELD is_multi_currency_enabled ON app_mobile_settings TYPE bool DEFAULT false;
DEFINE FIELD is_expense_project_invoicing_enabled ON app_mobile_settings TYPE bool DEFAULT false;
DEFINE FIELD is_kilometric_expense_line_allowed ON app_mobile_settings TYPE bool DEFAULT false;
DEFINE FIELD is_manual_creation_of_expense_allowed ON app_mobile_settings TYPE bool DEFAULT false;
DEFINE FIELD is_line_creation_of_expense_details_allowed ON app_mobile_settings TYPE bool DEFAULT false;

-- Configuration timesheet
DEFINE FIELD is_manual_creation_of_timesheet_allowed ON app_mobile_settings TYPE bool DEFAULT false;
DEFINE FIELD is_line_creation_of_timesheet_details_allowed ON app_mobile_settings TYPE bool DEFAULT false;
DEFINE FIELD is_edition_of_date_allowed ON app_mobile_settings TYPE bool DEFAULT false;
DEFINE FIELD is_timesheet_project_invoicing_enabled ON app_mobile_settings TYPE bool DEFAULT false;
DEFINE FIELD fields_to_show_on_timesheet ON app_mobile_settings TYPE string;

-- Configuration stock location
DEFINE FIELD is_stock_location_management_enabled ON app_mobile_settings TYPE bool DEFAULT false;

-- Configuration rôles autorisés
DEFINE FIELD inventory_validation_roles ON app_mobile_settings TYPE array<record<role>>;
DEFINE FIELD stock_correction_validation_roles ON app_mobile_settings TYPE array<record<role>>;
DEFINE FIELD verify_customer_delivery_line_roles ON app_mobile_settings TYPE array<record<role>>;
DEFINE FIELD verify_supplier_arrival_line_roles ON app_mobile_settings TYPE array<record<role>>;
DEFINE FIELD verify_internal_move_line_roles ON app_mobile_settings TYPE array<record<role>>;
DEFINE FIELD verify_inventory_line_roles ON app_mobile_settings TYPE array<record<role>>;
DEFINE FIELD customer_delivery_line_addition_roles ON app_mobile_settings TYPE array<record<role>>;
DEFINE FIELD supplier_arrival_line_addition_roles ON app_mobile_settings TYPE array<record<role>>;

-- Configuration raccourcis
DEFINE FIELD is_one_line_shortcut ON app_mobile_settings TYPE bool DEFAULT false;

-- Configuration produits
DEFINE FIELD is_generic_product_shown ON app_mobile_settings TYPE bool DEFAULT false;
DEFINE FIELD is_configurator_product_shown ON app_mobile_settings TYPE bool DEFAULT false;
DEFINE FIELD product_types_to_display_select ON app_mobile_settings TYPE string;
DEFINE FIELD reporting_types_to_display_select ON app_mobile_settings TYPE string;

-- Configuration DMS
DEFINE FIELD default_dms_root_id ON app_mobile_settings TYPE option<record<dms_file>>;
DEFINE FIELD is_favorites_management_enabled ON app_mobile_settings TYPE bool DEFAULT false;
DEFINE FIELD is_download_allowed ON app_mobile_settings TYPE bool DEFAULT false;
DEFINE FIELD is_renaming_allowed ON app_mobile_settings TYPE bool DEFAULT false;
DEFINE FIELD is_folder_creation_allowed ON app_mobile_settings TYPE bool DEFAULT false;
DEFINE FIELD is_file_creation_allowed ON app_mobile_settings TYPE bool DEFAULT false;
DEFINE FIELD is_file_deletion_allowed ON app_mobile_settings TYPE bool DEFAULT false;

-- Index
DEFINE INDEX idx_app_mobile_settings_app ON app_mobile_settings COLUMNS app_id;

-- ======================================================================
-- 2. TABLE : MOBILE_CONFIG
-- ======================================================================
DEFINE TABLE mobile_config SCHEMAFULL
    COMMENT "Configuration des applications mobiles";

-- Champs principaux
DEFINE FIELD id ON mobile_config TYPE record<mobile_config>;
DEFINE FIELD created_on ON mobile_config TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON mobile_config TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON mobile_config TYPE int DEFAULT 0;

-- Configuration application
DEFINE FIELD sequence ON mobile_config TYPE string;
DEFINE FIELD is_app_enabled ON mobile_config TYPE bool DEFAULT false;
DEFINE FIELD is_customize_menu_enabled ON mobile_config TYPE bool DEFAULT false;
DEFINE FIELD authorized_roles ON mobile_config TYPE array<record<role>>;

-- Index
DEFINE INDEX idx_mobile_config_sequence ON mobile_config COLUMNS sequence UNIQUE;

-- ======================================================================
-- 3. TABLE : MOBILE_MENU
-- ======================================================================
DEFINE TABLE mobile_menu SCHEMAFULL
    COMMENT "Gestion des menus pour applications mobiles";

-- Champs principaux
DEFINE FIELD id ON mobile_menu TYPE record<mobile_menu>;
DEFINE FIELD created_on ON mobile_menu TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON mobile_menu TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON mobile_menu TYPE int DEFAULT 0;

-- Configuration menu
DEFINE FIELD technical_name ON mobile_menu TYPE string;
DEFINE FIELD name ON mobile_menu TYPE string;
DEFINE FIELD menu_order ON mobile_menu TYPE int;
DEFINE FIELD parent_application ON mobile_menu TYPE string;
DEFINE FIELD menu_type ON mobile_menu TYPE string;
DEFINE FIELD parent_menu_name ON mobile_menu TYPE string;
DEFINE FIELD authorized_roles ON mobile_menu TYPE array<record<role>>;
DEFINE FIELD mobile_config_id ON mobile_menu TYPE option<record<mobile_config>>;

-- Index
DEFINE INDEX idx_mobile_menu_technical_name ON mobile_menu COLUMNS technical_name UNIQUE;
DEFINE INDEX idx_mobile_menu_parent_application ON mobile_menu COLUMNS parent_application;

-- ======================================================================
-- 4. TABLE : MOBILE_DASHBOARD
-- ======================================================================
DEFINE TABLE mobile_dashboard SCHEMAFULL
    COMMENT "Tableaux de bord pour applications mobiles";

-- Champs principaux
DEFINE FIELD id ON mobile_dashboard TYPE record<mobile_dashboard>;
DEFINE FIELD created_on ON mobile_dashboard TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON mobile_dashboard TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON mobile_dashboard TYPE int DEFAULT 0;

-- Configuration dashboard
DEFINE FIELD name ON mobile_dashboard TYPE string;
DEFINE FIELD app_name ON mobile_dashboard TYPE string;
DEFINE FIELD is_custom ON mobile_dashboard TYPE bool DEFAULT false;
DEFINE FIELD menu_title ON mobile_dashboard TYPE string;
DEFINE FIELD icon_name ON mobile_dashboard TYPE string;
DEFINE FIELD menu_order ON mobile_dashboard TYPE option<int>;
DEFINE FIELD app_mobile_settings_id ON mobile_dashboard TYPE option<record<app_mobile_settings>>;
DEFINE FIELD authorized_roles ON mobile_dashboard TYPE array<record<role>>;

-- Index
DEFINE INDEX idx_mobile_dashboard_app_name ON mobile_dashboard COLUMNS app_name;

-- ======================================================================
-- 5. TABLE : MOBILE_DASHBOARD_LINE
-- ======================================================================
DEFINE TABLE mobile_dashboard_line SCHEMAFULL
    COMMENT "Lignes de tableau de bord mobiles";

-- Champs principaux
DEFINE FIELD id ON mobile_dashboard_line TYPE record<mobile_dashboard_line>;
DEFINE FIELD created_on ON mobile_dashboard_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON mobile_dashboard_line TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON mobile_dashboard_line TYPE int DEFAULT 0;

-- Configuration ligne dashboard
DEFINE FIELD name ON mobile_dashboard_line TYPE string;
DEFINE FIELD mobile_chart_1_id ON mobile_dashboard_line TYPE option<record<mobile_chart>>;
DEFINE FIELD mobile_chart_2_id ON mobile_dashboard_line TYPE option<record<mobile_chart>>;
DEFINE FIELD mobile_chart_3_id ON mobile_dashboard_line TYPE option<record<mobile_chart>>;
DEFINE FIELD mobile_chart_4_id ON mobile_dashboard_line TYPE option<record<mobile_chart>>;
DEFINE FIELD mobile_dashboard_id ON mobile_dashboard_line TYPE option<record<mobile_dashboard>>;

-- Index
DEFINE INDEX idx_mobile_dashboard_line_dashboard ON mobile_dashboard_line COLUMNS mobile_dashboard_id;

-- ======================================================================
-- 6. TABLE : MOBILE_SHORTCUT
-- ======================================================================
DEFINE TABLE mobile_shortcut SCHEMAFULL
    COMMENT "Raccourcis pour applications mobiles";

-- Champs principaux
DEFINE FIELD id ON mobile_shortcut TYPE record<mobile_shortcut>;
DEFINE FIELD created_on ON mobile_shortcut TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON mobile_shortcut TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON mobile_shortcut TYPE int DEFAULT 0;

-- Configuration raccourci
DEFINE FIELD name ON mobile_shortcut TYPE string;
DEFINE FIELD icon_name ON mobile_shortcut TYPE string;
DEFINE FIELD mobile_screen_id ON mobile_shortcut TYPE option<record<mobile_screen>>;
DEFINE FIELD authorized_roles ON mobile_shortcut TYPE array<record<role>>;
DEFINE FIELD app_mobile_settings_id ON mobile_shortcut TYPE option<record<app_mobile_settings>>;

-- Index
DEFINE INDEX idx_mobile_shortcut_screen ON mobile_shortcut COLUMNS mobile_screen_id;

-- ======================================================================
-- 7. TABLE : MOBILE_SCREEN
-- ======================================================================
DEFINE TABLE mobile_screen SCHEMAFULL
    COMMENT "Écrans pour applications mobiles";

-- Champs principaux
DEFINE FIELD id ON mobile_screen TYPE record<mobile_screen>;
DEFINE FIELD created_on ON mobile_screen TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON mobile_screen TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON mobile_screen TYPE int DEFAULT 0;

-- Configuration écran
DEFINE FIELD technical_name ON mobile_screen TYPE string;
DEFINE FIELD name ON mobile_screen TYPE string;
DEFINE FIELD is_usable_on_shortcut ON mobile_screen TYPE bool DEFAULT false;

-- Index
DEFINE INDEX idx_mobile_screen_technical_name ON mobile_screen COLUMNS technical_name UNIQUE;

-- ======================================================================
-- 8. TABLE : MOBILE_CHART
-- ======================================================================
DEFINE TABLE mobile_chart SCHEMAFULL
    COMMENT "Graphiques pour applications mobiles";

-- Champs principaux
DEFINE FIELD id ON mobile_chart TYPE record<mobile_chart>;
DEFINE FIELD created_on ON mobile_chart TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON mobile_chart TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON mobile_chart TYPE int DEFAULT 0;

-- Configuration graphique
DEFINE FIELD name ON mobile_chart TYPE string;
DEFINE FIELD query ON mobile_chart TYPE string;
DEFINE FIELD chart_type_select ON mobile_chart TYPE string;
DEFINE FIELD is_custom_chart ON mobile_chart TYPE bool DEFAULT false;
DEFINE FIELD chart_meta_action_id ON mobile_chart TYPE option<record<meta_action>>;

-- Index
DEFINE INDEX idx_mobile_chart_name ON mobile_chart COLUMNS name;

-- ======================================================================
-- 9. TABLE : MOBILE_WEB_VIEW
-- ======================================================================
DEFINE TABLE mobile_web_view SCHEMAFULL
    COMMENT "Vues web pour applications mobiles";

-- Champs principaux
DEFINE FIELD id ON mobile_web_view TYPE record<mobile_web_view>;
DEFINE FIELD created_on ON mobile_web_view TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON mobile_web_view TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON mobile_web_view TYPE int DEFAULT 0;

-- Configuration vue web
DEFINE FIELD name ON mobile_web_view TYPE string;
DEFINE FIELD menu_title ON mobile_web_view TYPE string;
DEFINE FIELD app_name ON mobile_web_view TYPE string;
DEFINE FIELD icon_name ON mobile_web_view TYPE string;
DEFINE FIELD menu_order ON mobile_web_view TYPE option<int>;
DEFINE FIELD authorized_roles ON mobile_web_view TYPE array<record<role>>;
DEFINE FIELD is_aos_web_view ON mobile_web_view TYPE bool DEFAULT false;
DEFINE FIELD url ON mobile_web_view TYPE string;
DEFINE FIELD meta_action_id ON mobile_web_view TYPE option<record<meta_action>>;

-- Index
DEFINE INDEX idx_mobile_web_view_app_name ON mobile_web_view COLUMNS app_name;

-- ======================================================================
-- 10. TABLE : USER_MOBILE_EXTENSION
-- ======================================================================
DEFINE TABLE user_mobile_extension SCHEMAFULL
    COMMENT "Extension des utilisateurs pour mobile";

-- Champs principaux
DEFINE FIELD id ON user_mobile_extension TYPE record<user_mobile_extension>;
DEFINE FIELD user_id ON user_mobile_extension TYPE record<user>;
DEFINE FIELD created_on ON user_mobile_extension TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON user_mobile_extension TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON user_mobile_extension TYPE int DEFAULT 0;

-- Configuration utilisateur mobile
DEFINE FIELD qr_code_id ON user_mobile_extension TYPE option<record<meta_file>>;
DEFINE FIELD dms_root_id ON user_mobile_extension TYPE option<record<dms_file>>;
DEFINE FIELD favourite_folders ON user_mobile_extension TYPE array<record<dms_file>>;
DEFINE FIELD favourite_files ON user_mobile_extension TYPE array<record<dms_file>>;

-- Index
DEFINE INDEX idx_user_mobile_extension_user ON user_mobile_extension COLUMNS user_id UNIQUE;

-- ======================================================================
-- 11. TABLE : APP_MOBILE_EXTENSION
-- ======================================================================
DEFINE TABLE app_mobile_extension SCHEMAFULL
    COMMENT "Extension des applications pour mobile";

-- Champs principaux
DEFINE FIELD id ON app_mobile_extension TYPE record<app_mobile_extension>;
DEFINE FIELD app_id ON app_mobile_extension TYPE record<app>;
DEFINE FIELD created_on ON app_mobile_extension TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON app_mobile_extension TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON app_mobile_extension TYPE int DEFAULT 0;

-- Configuration application mobile
DEFINE FIELD app_mobile_settings_id ON app_mobile_extension TYPE option<record<app_mobile_settings>>;

-- Index
DEFINE INDEX idx_app_mobile_extension_app ON app_mobile_extension COLUMNS app_id UNIQUE;

-- ======================================================================
-- 12. TABLE : META_JSON_FIELD_MOBILE
-- ======================================================================
DEFINE TABLE meta_json_field_mobile SCHEMAFULL
    COMMENT "Extension des champs JSON pour mobile";

-- Champs principaux
DEFINE FIELD id ON meta_json_field_mobile TYPE record<meta_json_field_mobile>;
DEFINE FIELD meta_json_field_id ON meta_json_field_mobile TYPE record<meta_json_field>;
DEFINE FIELD created_on ON meta_json_field_mobile TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON meta_json_field_mobile TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON meta_json_field_mobile TYPE int DEFAULT 0;

-- Configuration champ JSON mobile
DEFINE FIELD is_visible_in_mobile_app ON meta_json_field_mobile TYPE bool DEFAULT false;

-- Index
DEFINE INDEX idx_meta_json_field_mobile_field ON meta_json_field_mobile COLUMNS meta_json_field_id UNIQUE;

-- ======================================================================
-- RELATIONS ET CONTRAINTES
-- ======================================================================

-- Relations One-to-Many
DEFINE FIELD mobile_dashboard_list ON app_mobile_settings TYPE array<record<mobile_dashboard>>;
DEFINE FIELD mobile_shortcut_list ON app_mobile_settings TYPE array<record<mobile_shortcut>>;
DEFINE FIELD mobile_menu_list ON mobile_config TYPE array<record<mobile_menu>>;
DEFINE FIELD mobile_dashboard_line_list ON mobile_dashboard TYPE array<record<mobile_dashboard_line>>;

-- ======================================================================
-- FONCTIONS UTILITAIRES
-- ======================================================================

-- Fonction pour récupérer la configuration mobile par séquence
DEFINE FUNCTION fn::get_mobile_config_by_sequence($sequence: string) {
    RETURN SELECT * FROM mobile_config WHERE sequence = $sequence;
};

-- Fonction pour récupérer les menus par application parente
DEFINE FUNCTION fn::get_mobile_menus_by_parent_app($parent_app: string) {
    RETURN SELECT * FROM mobile_menu WHERE parent_application = $parent_app ORDER BY menu_order;
};

-- Fonction pour récupérer les tableaux de bord par application
DEFINE FUNCTION fn::get_mobile_dashboards_by_app($app_name: string) {
    RETURN SELECT * FROM mobile_dashboard WHERE app_name = $app_name ORDER BY menu_order;
};

-- Fonction pour récupérer les écrans utilisables en raccourci
DEFINE FUNCTION fn::get_usable_screens_for_shortcut() {
    RETURN SELECT * FROM mobile_screen WHERE is_usable_on_shortcut = true;
};

-- Fonction pour récupérer les raccourcis par paramètres mobile
DEFINE FUNCTION fn::get_shortcuts_by_mobile_settings($settings_id: record<app_mobile_settings>) {
    RETURN SELECT * FROM mobile_shortcut WHERE app_mobile_settings_id = $settings_id;
};

-- ======================================================================
-- ÉVÉNEMENTS ET TRIGGERS
-- ======================================================================

-- Trigger pour mettre à jour la date de modification
DEFINE EVENT mobile_settings_updated ON TABLE app_mobile_settings WHEN $event = "UPDATE" THEN {
    UPDATE app_mobile_settings SET updated_on = time::now() WHERE id = $after.id;
};

DEFINE EVENT mobile_config_updated ON TABLE mobile_config WHEN $event = "UPDATE" THEN {
    UPDATE mobile_config SET updated_on = time::now() WHERE id = $after.id;
};

-- ======================================================================
-- DONNÉES DE RÉFÉRENCE
-- ======================================================================

-- Constantes pour les types de menus
LET $MOBILE_MENU_TYPE_MENU = "menu";
LET $MOBILE_MENU_TYPE_SEPARATOR = "separator";
LET $MOBILE_MENU_TYPE_SUBMENU = "submenu";

-- Constantes pour les séquences d'applications
LET $APP_SEQUENCE_STOCK = "app-stock";
LET $APP_SEQUENCE_MANUFACTURING = "app-manufacturing";
LET $APP_SEQUENCE_CRM = "app-crm";
LET $APP_SEQUENCE_HELPDESK = "app-helpdesk";
LET $APP_SEQUENCE_HR = "app-hr";
LET $APP_SEQUENCE_QUALITY = "app-quality";
LET $APP_SEQUENCE_INTERVENTION = "app-intervention";
LET $APP_SEQUENCE_SALE = "app-sale";
LET $APP_SEQUENCE_PROJECT = "app-project";
LET $APP_SEQUENCE_DMS = "app-dms";
LET $APP_SEQUENCE_PURCHASE = "app-purchase";

-- Constantes pour les imputations timesheet
LET $IMPUTATION_ON_PROJECT = "project";
LET $IMPUTATION_ON_PROJECT_TASK = "projectTask";
LET $IMPUTATION_ON_MANUF_ORDER = "manufOrder";
LET $IMPUTATION_ON_OPERATION_ORDER = "operationOrder";
LET $IMPUTATION_ON_ACTIVITY = "product";

-- Constantes pour les types de reporting
LET $REPORTING_TYPE_DISPLAY_INDICATORS = "indicators";
LET $REPORTING_TYPE_DISPLAY_ACTIVITIES = "activities";
LET $REPORTING_TYPE_DISPLAY_NONE = "none";

-- ======================================================================
-- VUES ET REQUÊTES COMPLEXES
-- ======================================================================

-- Vue pour les configurations mobile complètes
DEFINE TABLE mobile_config_complete AS SELECT 
    mc.*,
    array::group(mm) AS menus,
    array::length(mm) AS menu_count
FROM mobile_config mc
LEFT JOIN mobile_menu mm ON mm.mobile_config_id = mc.id
GROUP BY mc.id;

-- Vue pour les tableaux de bord avec leurs lignes
DEFINE TABLE mobile_dashboard_complete AS SELECT 
    md.*,
    array::group(mdl) AS dashboard_lines,
    array::length(mdl) AS line_count
FROM mobile_dashboard md
LEFT JOIN mobile_dashboard_line mdl ON mdl.mobile_dashboard_id = md.id
GROUP BY md.id;

-- Vue pour les paramètres mobiles avec comptes
DEFINE TABLE mobile_settings_summary AS SELECT 
    ams.*,
    array::length(ams.mobile_dashboard_list) AS dashboard_count,
    array::length(ams.mobile_shortcut_list) AS shortcut_count
FROM app_mobile_settings ams;

-- ======================================================================
-- COMMENTAIRES ET DOCUMENTATION
-- ======================================================================

/*
MIGRATION AXELOR-MOBILE-SETTINGS VERS SURREALDB

Ce fichier contient la migration complète du module axelor-mobile-settings vers SurrealDB.

ENTITÉS MIGRÉES (12/12):
1. AppMobileSettings - Configuration principale des paramètres mobiles
2. App - Extension de l'entité App  
3. MobileConfig - Configuration des applications mobiles
4. MobileMenu - Gestion des menus mobiles
5. MobileDashboard - Tableaux de bord mobiles
6. MobileDashboardLine - Lignes de tableau de bord
7. MobileShortcut - Raccourcis mobiles
8. MobileScreen - Écrans mobiles
9. MobileChart - Graphiques mobiles
10. MobileWebView - Vues web mobiles
11. User - Extension utilisateur pour mobile
12. MetaJsonField - Extension champs JSON pour mobile

FONCTIONNALITÉS CLÉS:
- Configuration des applications mobiles activées
- Gestion des menus et raccourcis
- Tableaux de bord et graphiques
- Configuration des rôles et permissions
- Gestion des fichiers DMS favoris
- Configuration QR Code
- Paramètres de validation stock
- Configuration multi-devises
- Gestion timesheet mobile

RELATIONS:
- App 1:1 AppMobileSettings
- AppMobileSettings 1:N MobileDashboard
- AppMobileSettings 1:N MobileShortcut
- MobileConfig 1:N MobileMenu
- MobileDashboard 1:N MobileDashboardLine
- MobileScreen 1:N MobileShortcut
- User 1:1 UserMobileExtension
- MetaJsonField 1:1 MetaJsonFieldMobile

PERFORMANCE:
- Index sur les relations principales
- Fonctions utilitaires pour requêtes fréquentes
- Vues pré-calculées pour données complexes
- Triggers pour mise à jour automatique
*/ 