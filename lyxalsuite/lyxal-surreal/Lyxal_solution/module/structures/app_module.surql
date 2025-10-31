-- =====================================================================
-- TABLE : app_module - Système intelligent de gestion des modules Lyxal Suite
-- =====================================================================

DEFINE TABLE app_module SCHEMAFULL;
    COMMENT "Système de gestion intelligente des modules avec activation dynamique";

-- Identification du module
DEFINE FIELD code ON app_module TYPE string ASSERT $value != NONE;
DEFINE FIELD name ON app_module TYPE string ASSERT $value != NONE;
DEFINE FIELD description ON app_module TYPE string;
DEFINE FIELD version ON app_module TYPE string DEFAULT "1.0.0";

-- Activation et contrôle
DEFINE FIELD is_active ON app_module TYPE bool DEFAULT false;
DEFINE FIELD is_core_module ON app_module TYPE bool DEFAULT false; -- Modules core non désactivables
DEFINE FIELD is_licensed ON app_module TYPE bool DEFAULT true; -- Contrôle de licence
DEFINE FIELD license_type ON app_module TYPE string DEFAULT "STANDARD"; -- STANDARD, PREMIUM, ENTERPRISE

-- Dépendances et compatibilité
DEFINE FIELD dependencies ON app_module TYPE array<string>; -- Modules requis
DEFINE FIELD conflicts_with ON app_module TYPE array<string>; -- Modules incompatibles
DEFINE FIELD min_platform_version ON app_module TYPE string; -- Version minimale plateforme
DEFINE FIELD max_platform_version ON app_module TYPE string; -- Version maximale plateforme

-- Configuration d'installation
DEFINE FIELD install_order ON app_module TYPE int DEFAULT 100; -- Ordre d'installation
DEFINE FIELD auto_install ON app_module TYPE bool DEFAULT false; -- Installation automatique
DEFINE FIELD requires_restart ON app_module TYPE bool DEFAULT false; -- Redémarrage requis
DEFINE FIELD install_script ON app_module TYPE string; -- Script d'installation
DEFINE FIELD uninstall_script ON app_module TYPE string; -- Script de désinstallation

-- Métadonnées techniques
DEFINE FIELD database_tables ON app_module TYPE array<string>; -- Tables créées par le module
DEFINE FIELD api_endpoints ON app_module TYPE array<string>; -- Endpoints API exposés
DEFINE FIELD ui_components ON app_module TYPE array<string>; -- Composants UI
DEFINE FIELD permissions ON app_module TYPE array<string>; -- Permissions requises
DEFINE FIELD config_keys ON app_module TYPE array<string>; -- Clés de configuration

-- Informations développeur
DEFINE FIELD author ON app_module TYPE string;
DEFINE FIELD maintainer ON app_module TYPE string;
DEFINE FIELD repository_url ON app_module TYPE string;
DEFINE FIELD documentation_url ON app_module TYPE string;
DEFINE FIELD support_email ON app_module TYPE string;

-- Statistiques et monitoring
DEFINE FIELD install_count ON app_module TYPE int DEFAULT 0;
DEFINE FIELD last_used ON app_module TYPE datetime;
DEFINE FIELD performance_score ON app_module TYPE float; -- Score de performance 0-100
DEFINE FIELD error_count ON app_module TYPE int DEFAULT 0;
DEFINE FIELD health_status ON app_module TYPE string DEFAULT "HEALTHY"; -- HEALTHY, WARNING, ERROR

-- Dates de cycle de vie
DEFINE FIELD created_on ON app_module TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON app_module TYPE datetime DEFAULT time::now();
DEFINE FIELD installed_on ON app_module TYPE datetime;
DEFINE FIELD last_activated ON app_module TYPE datetime;
DEFINE FIELD last_deactivated ON app_module TYPE datetime;

-- Index d'optimisation
DEFINE INDEX idx_app_module_code ON app_module COLUMNS code UNIQUE;
DEFINE INDEX idx_app_module_active ON app_module COLUMNS is_active;
DEFINE INDEX idx_app_module_core ON app_module COLUMNS is_core_module;
DEFINE INDEX idx_app_module_install_order ON app_module COLUMNS install_order;
DEFINE INDEX idx_app_module_health ON app_module COLUMNS health_status;