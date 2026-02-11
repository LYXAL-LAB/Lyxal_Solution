-- ================================================================================================
-- 🏛️ LYXAL - STRUCTURE COMPLÈTE
-- ================================================================================================

-- ################################################################################################
-- PARTIE 1 : CONFIGURATION SYSTÈME 
-- ################################################################################################

-- ================================================================================================
-- ⚙️ CONFIGURATION SYSTÈME - LYXAL SURREAL
-- ================================================================================================
-- 
-- Ce fichier contient toutes les tables de configuration système
-- 
-- Tables incluses:
-- - system_identity: Configuration identité plateforme LYXAL
-- - system_infrastructure: Configuration infrastructure technique LYXAL
-- - app_configuration: Configuration app
-- - locale_configuration: Configuration locale
-- - period_configuration: Configuration period
-- - notification_configuration: Configuration notification
-- - import_configuration: Configuration import
-- 
-- Date de migration: 2025-06-26T15:30:31.009Z
-- Date ajout MASTER: 2025-01-27T10:00:00.000Z
-- ================================================================================================

-- ================================================================================
-- SYSTEM_IDENTITY - CONFIGURATION IDENTITÉ PLATEFORME LYXAL
-- ================================================================================

DEFINE TABLE system_identity SCHEMAFULL
    COMMENT "Configuration identité application Lyxal - Modifiable à chaud"
    PERMISSIONS
        FOR select WHERE true
        FOR create, update WHERE $auth.role CONTAINS 'admin'
        FOR delete WHERE $auth.role CONTAINS 'admin';

DEFINE FIELD platform_name ON system_identity TYPE string
    ASSERT $value != NULL AND string::len($value) > 0
    VALUE $value OR "LYXAL"
    COMMENT "Nom officiel de la plateforme";

DEFINE FIELD environment ON system_identity TYPE string
    ASSERT $value INSIDE ["dev", "staging", "production"]
    VALUE $value OR "production"
    COMMENT "Environnement de déploiement actuel";

DEFINE FIELD platform_version ON system_identity TYPE string
    ASSERT $value != NULL AND string::len($value) > 0
    VALUE $value OR "1.0.0"
    COMMENT "Version actuelle de la plateforme";

DEFINE FIELD annee_construction ON system_identity TYPE string
    ASSERT $value != NULL AND string::len($value) = 4
    VALUE $value OR "2025"
    COMMENT "Année de construction de la plateforme";

DEFINE FIELD theme_par_defaut ON system_identity TYPE string
    ASSERT $value INSIDE [
        "light", "dark", "cupcake", "bumblebee", "emerald", "corporate", "synthwave", "retro",
        "cyberpunk", "valentine", "halloween", "garden", "forest", "aqua", "lofi", "pastel",
        "fantasy", "wireframe", "black", "luxury", "dracula", "cmyk", "autumn", "business",
        "acid", "lemonade", "night", "coffee", "winter", "dim", "nord", "sunset"
    ]
    VALUE $value OR "luxury"
    COMMENT "Thème par défaut de l'application";

DEFINE FIELD theme_website ON system_identity TYPE string
    ASSERT $value INSIDE [
        "light", "dark", "cupcake", "bumblebee", "emerald", "corporate", "synthwave", "retro",
        "cyberpunk", "valentine", "halloween", "garden", "forest", "aqua", "lofi", "pastel",
        "fantasy", "wireframe", "black", "luxury", "dracula", "cmyk", "autumn", "business",
        "acid", "lemonade", "night", "coffee", "winter", "dim", "nord", "sunset"
    ]
    VALUE $value OR "luxury"
    COMMENT "Thème du site marketing";

-- Métadonnées
DEFINE FIELD createdAt ON system_identity TYPE datetime DEFAULT time::now();
DEFINE FIELD updatedAt ON system_identity TYPE datetime DEFAULT time::now();
DEFINE FIELD createdBy ON system_identity TYPE option<record<user>>;

-- ================================================================================
-- SYSTEM_INFRASTRUCTURE - CONFIGURATION INFRASTRUCTURE TECHNIQUE LYXAL
-- ================================================================================

DEFINE TABLE system_infrastructure SCHEMAFULL
    COMMENT "Configuration infrastructure technique Lyxal - Modifiable à chaud"
    PERMISSIONS
        FOR select WHERE true
        FOR create, update WHERE $auth.role CONTAINS 'admin'
        FOR delete WHERE $auth.role CONTAINS 'admin';

DEFINE FIELD surreal_db_url ON system_infrastructure TYPE string
    ASSERT $value != NULL AND (string::starts_with($value, "ws://") OR string::starts_with($value, "wss://"))
    VALUE $value OR "wss://lyxal-06bsd9k399ou7e5fa4tblm6b3g.aws-euw1.surreal.cloud"
    COMMENT "URL de connexion à l'instance SurrealDB";

DEFINE FIELD surreal_token ON system_infrastructure TYPE string
    ASSERT $value != NULL AND string::len($value) > 0
    VALUE $value OR "eyJhbGciOiJQUzI1NiIsImtpZCI6IjFkNmViYjAyLWM5ZjEtNDg4Zi1iNjhjLWNlMzMzMzU4YzgyOCIsInR5cCI6IkpXVCJ9.eyJhYyI6ImNsb3VkIiwiYXVkIjoiMDZic2Q5azM5OW91N2U1ZmE0dGJsbTZiM2ciLCJleHAiOjE3NTEzODQ2NDYsImlhdCI6MTc1MTM4NDU4NiwicmwiOlsiT3duZXIiXX0.AQLLiSPy4tSTUDrcKhdljjUsX8FSExNUdiC16ywsmAh7wTLAwX2_-FbN5BCb9buzy6TTwW6fzFQEBDrWYBukpoC8k_VaY8nkPmnYSgBqoeUP8LM6moHA2Bcz-frSfUd0uGSr-bop5QaqtrTn0EgaXhyUU6L9RpzgZsKsMDaOjaxRLWnEfJFc8reljhHtZCfcpon9qobNYt07DxVqsT5tYh5ui0PsULaP7MeOwYDId2tPQTi8m4k9jtLGqoCpLwnmuDRjJGe53VdzN2jPXgNtw-FNvqpUGnxxSec2f8OeFoI2IL0CHkHDk9Dl2fPKfUiKKZNFvHsTIfuVU0GjVWKkGw"
    COMMENT "Token JWT SurrealDB pour l'authentification";

DEFINE FIELD surreal_namespace ON system_infrastructure TYPE string
    ASSERT $value != NULL AND string::len($value) > 0
    VALUE $value OR "lyxal_central_gateway"
    COMMENT "Namespace SurrealDB pour la plateforme";

DEFINE FIELD surreal_database ON system_infrastructure TYPE string
    ASSERT $value != NULL AND string::len($value) > 0
    VALUE $value OR "main_gateway"
    COMMENT "Database SurrealDB";

DEFINE FIELD surreal_username ON system_infrastructure TYPE string
    ASSERT $value != NULL AND string::len($value) > 0
    VALUE $value OR "admin"
    COMMENT "Nom d'utilisateur SurrealDB";

DEFINE FIELD surreal_password ON system_infrastructure TYPE string
    ASSERT $value != NULL AND string::len($value) > 0
    VALUE $value OR "admin"
    COMMENT "Mot de passe SurrealDB";

DEFINE FIELD logto_master_endpoint ON system_infrastructure TYPE string
    ASSERT $value != NULL AND string::starts_with($value, "https://")
    VALUE $value OR "https://lyxal-master.logto.cloud"
    COMMENT "Endpoint Logto pour l'authentification";

DEFINE FIELD logto_admin_app_id ON system_infrastructure TYPE string
    ASSERT $value != NULL AND string::len($value) > 0
    VALUE $value OR "lyxal-admin-console"
    COMMENT "App ID Logto pour la console d'administration";

-- Métadonnées
DEFINE FIELD createdAt ON system_infrastructure TYPE datetime DEFAULT time::now();
DEFINE FIELD updatedAt ON system_infrastructure TYPE datetime DEFAULT time::now();
DEFINE FIELD createdBy ON system_infrastructure TYPE option<record<user>>;

-- Index pour les requêtes fréquentes
DEFINE INDEX idx_surreal_namespace ON system_infrastructure COLUMNS surreal_namespace;

-- ================================================================================
-- SYSTEM_CONFIG_METADATA - HISTORIQUE DES MODIFICATIONS (A VERIFIER)
-- ================================================================================

DEFINE TABLE system_config_metadata SCHEMAFULL
    COMMENT "Métadonnées et historique des modifications de configuration système"
    PERMISSIONS
        FOR select WHERE true
        FOR create WHERE $auth.role CONTAINS 'admin'
        FOR update, delete WHERE false;

DEFINE FIELD table_name ON system_config_metadata TYPE string
    ASSERT $value INSIDE ["system_identity", "system_infrastructure"]
    COMMENT "Nom de la table modifiée";

DEFINE FIELD field_name ON system_config_metadata TYPE string
    ASSERT $value != NULL AND string::len($value) > 0
    COMMENT "Nom du champ modifié";

DEFINE FIELD old_value ON system_config_metadata TYPE string
    COMMENT "Ancienne valeur";

DEFINE FIELD new_value ON system_config_metadata TYPE string
    COMMENT "Nouvelle valeur";

DEFINE FIELD changed_by ON system_config_metadata TYPE string
    VALUE $value OR "system"
    COMMENT "Utilisateur ayant effectué la modification";

DEFINE FIELD changed_at ON system_config_metadata TYPE datetime
    VALUE $value OR time::now()
    COMMENT "Date et heure de la modification";

DEFINE FIELD change_reason ON system_config_metadata TYPE string
    VALUE $value OR "Configuration update"
    COMMENT "Raison de la modification";

-- Métadonnées
DEFINE FIELD createdAt ON system_config_metadata TYPE datetime DEFAULT time::now();

-- Index pour l'historique
DEFINE INDEX idx_config_history ON system_config_metadata COLUMNS table_name, field_name, changed_at;

-- ================================================================================
-- APP_CONFIGURATION
-- ================================================================================

DEFINE TABLE app_configuration SCHEMAFULL
    COMMENT "Configuration plateforme Lyxal autonome"
    PERMISSIONS
        FOR select WHERE true
        FOR create, update WHERE $auth.role CONTAINS 'admin'
        FOR delete WHERE $auth.role CONTAINS 'admin';

DEFINE FIELD name ON app_configuration TYPE string
    ASSERT $value != NULL AND string::len($value) >= 2
    VALUE $value OR "lyxal_main_config"
    COMMENT "Nom de la configuration";

-- Paramètres système autonomes
DEFINE FIELD systemParameters ON app_configuration TYPE object VALUE {
    sessionTimeout: 3600,
    backupFrequency: 24,
    logRetention: 90,
    cacheSize: 512,
    performanceMode: 'AUTONOMOUS'
};

-- Intelligence IA système pour autonomie complète
DEFINE FIELD systemAI ON app_configuration TYPE object VALUE {
    performanceOptimization: {
        queryOptimization: true,
        autoIndexing: true,
        adaptiveCache: true
    },
    selfHealing: {
        autoRestart: true,
        errorRecovery: true,
        resourceRebalancing: true
    },
    predictiveAnalytics: {
        loadForecasting: true,
        healthPrediction: true,
        anomalyDetection: true
    },
    autoTuning: true
};

-- Analytics autonomes
DEFINE FIELD systemAnalytics ON app_configuration TYPE object VALUE {
    realTimeMetrics: true,
    autonomousReporting: true,
    predictiveAlerts: true,
    selfOptimization: true
};

-- Métadonnées
DEFINE FIELD createdAt ON app_configuration TYPE datetime DEFAULT time::now();
DEFINE FIELD updatedAt ON app_configuration TYPE datetime DEFAULT time::now();
DEFINE FIELD createdBy ON app_configuration TYPE option<record<user>>;


-- ================================================================================
-- PERIOD_CONFIGURATION
-- A terminer en fin de structure complete des tables
-- Chaque template de SAAS doit avoir sa propre configuration de période
-- ================================================================================

DEFINE TABLE period_configuration SCHEMAFULL
    COMMENT "Configuration des périodes avec IA de planification"
    PERMISSIONS
        FOR select WHERE true
        FOR create, update WHERE $auth.role CONTAINS 'admin' OR $auth.role CONTAINS 'planning_manager'
        FOR delete WHERE $auth.role CONTAINS 'admin';

DEFINE FIELD code ON period_configuration TYPE string
    ASSERT $value != NULL AND string::len($value) >= 1
    COMMENT "Code période";

DEFINE FIELD name ON period_configuration TYPE string
    ASSERT $value != NULL AND string::len($value) >= 2
    COMMENT "Nom de la période";

DEFINE FIELD periodType ON period_configuration TYPE string
    ASSERT $value INSIDE ['YEAR', 'QUARTER', 'MONTH', 'WEEK', 'DAY', 'CUSTOM']
    VALUE $value OR 'MONTH'
    COMMENT "Type de période";

DEFINE FIELD startDate ON period_configuration TYPE date
    COMMENT "Date de début";

DEFINE FIELD endDate ON period_configuration TYPE date
    COMMENT "Date de fin";

DEFINE FIELD isDefault ON period_configuration TYPE bool DEFAULT false
    COMMENT "Période par défaut";

DEFINE FIELD isActive ON period_configuration TYPE bool DEFAULT true
    COMMENT "Période active";

-- Intelligence IA de planification
DEFINE FIELD planningAI ON period_configuration TYPE object VALUE {
    demandForecasting: {},
    seasonalAdjustments: {},
    capacityPlanning: {},
    resourceOptimization: {},
    performancePredictions: {}
};

-- Analytics périodiques
DEFINE FIELD periodAnalytics ON period_configuration TYPE object VALUE {
    periodPerformance: {},
    comparisonMetrics: {},
    trendAnalysis: {},
    varianceAnalysis: {},
    forecastAccuracy: 0.0
};

-- Métadonnées
DEFINE FIELD createdAt ON period_configuration TYPE datetime DEFAULT time::now();
DEFINE FIELD updatedAt ON period_configuration TYPE datetime DEFAULT time::now();
DEFINE FIELD createdBy ON period_configuration TYPE option<record<user>>;
DEFINE FIELD archived ON period_configuration TYPE bool DEFAULT false;

-- ================================================================================
-- NOTIFICATION_CONFIGURATION
-- A terminer en fin de structure complete des tables
-- Chaque template de SAAS doit avoir sa propre configuration de notification
-- ================================================================================

DEFINE TABLE notification_configuration SCHEMAFULL
    COMMENT "Configuration notifications avec IA de personnalisation"
    PERMISSIONS
        FOR select WHERE true
        FOR create, update WHERE $auth.role CONTAINS 'admin' OR $auth.role CONTAINS 'notification_manager'
        FOR delete WHERE $auth.role CONTAINS 'admin';

DEFINE FIELD code ON notification_configuration TYPE string
    ASSERT $value != NULL AND string::len($value) >= 1
    COMMENT "Code notification unique";

DEFINE FIELD name ON notification_configuration TYPE string
    ASSERT $value != NULL AND string::len($value) >= 2
    COMMENT "Nom de la notification";

DEFINE FIELD eventType ON notification_configuration TYPE string
    ASSERT $value != NULL
    COMMENT "Type d'événement déclencheur";

DEFINE FIELD channelType ON notification_configuration TYPE string
    ASSERT $value INSIDE ['EMAIL', 'SMS', 'PUSH', 'WEBHOOK', 'SLACK', 'TEAMS', 'CUSTOM']
    VALUE $value OR 'EMAIL'
    COMMENT "Canal de notification";

DEFINE FIELD template ON notification_configuration TYPE string
    COMMENT "Template de message";

DEFINE FIELD isActive ON notification_configuration TYPE bool DEFAULT true
    COMMENT "Notification active";

DEFINE FIELD priority ON notification_configuration TYPE string
    ASSERT $value INSIDE ['LOW', 'NORMAL', 'HIGH', 'CRITICAL']
    VALUE $value OR 'NORMAL'
    COMMENT "Priorité de la notification";

-- Intelligence IA de notification
DEFINE FIELD notificationAI ON notification_configuration TYPE object VALUE {
    personalizedContent: {},
    optimalTiming: {},
    channelOptimization: {},
    engagementPrediction: 0.0,
    contentOptimization: {},
    recipientSegmentation: {}
};

-- Analytics de performance
DEFINE FIELD notificationAnalytics ON notification_configuration TYPE object VALUE {
    deliveryRate: 0.0,
    openRate: 0.0,
    clickRate: 0.0,
    responseRate: 0.0,
    unsubscribeRate: 0.0,
    effectivenessScore: 0.0
};

-- Métadonnées
DEFINE FIELD createdAt ON notification_configuration TYPE datetime DEFAULT time::now();
DEFINE FIELD updatedAt ON notification_configuration TYPE datetime DEFAULT time::now();
DEFINE FIELD createdBy ON notification_configuration TYPE option<record<user>>;
DEFINE FIELD archived ON notification_configuration TYPE bool DEFAULT false;

-- ================================================================================
-- IMPORT_CONFIGURATION
-- A terminer en fin de structure complete des tables
-- Chaque template de SAAS doit avoir sa propre configuration d'import
-- ================================================================================

DEFINE TABLE import_configuration SCHEMAFULL
    COMMENT "Configuration d'import avec IA de validation et nettoyage"
    PERMISSIONS
        FOR select WHERE true
        FOR create, update WHERE $auth.role CONTAINS 'admin' OR $auth.role CONTAINS 'data_manager'
        FOR delete WHERE $auth.role CONTAINS 'admin';

DEFINE FIELD code ON import_configuration TYPE string
    ASSERT $value != NULL AND string::len($value) >= 1
    COMMENT "Code configuration import";

DEFINE FIELD name ON import_configuration TYPE string
    ASSERT $value != NULL AND string::len($value) >= 2
    COMMENT "Nom de la configuration";

DEFINE FIELD sourceType ON import_configuration TYPE string
    ASSERT $value INSIDE ['CSV', 'EXCEL', 'JSON', 'XML', 'API', 'DATABASE', 'CUSTOM']
    VALUE $value OR 'CSV'
    COMMENT "Type de source de données";

DEFINE FIELD targetEntity ON import_configuration TYPE string
    ASSERT $value != NULL
    COMMENT "Entité cible de l'import";

DEFINE FIELD mappingRules ON import_configuration TYPE object
    COMMENT "Règles de mapping des champs";

DEFINE FIELD validationRules ON import_configuration TYPE object
    COMMENT "Règles de validation des données";

DEFINE FIELD isActive ON import_configuration TYPE bool DEFAULT true
    COMMENT "Configuration active";

-- Intelligence IA d'import
DEFINE FIELD importAI ON import_configuration TYPE object VALUE {
    dataQualityScore: 0.0,
    autoCorrection: {},
    duplicateDetection: {},
    anomalyDetection: {},
    smartMapping: {},
    qualityPrediction: 0.0
};

-- Analytics d'import
DEFINE FIELD importAnalytics ON import_configuration TYPE object VALUE {
    successRate: 0.0,
    errorRate: 0.0,
    processingTime: 0.0,
    recordsProcessed: 0,
    dataQualityMetrics: {},
    performanceHistory: []
};

-- Métadonnées
DEFINE FIELD createdAt ON import_configuration TYPE datetime DEFAULT time::now();
DEFINE FIELD updatedAt ON import_configuration TYPE datetime DEFAULT time::now();
DEFINE FIELD createdBy ON import_configuration TYPE option<record<user>>;
DEFINE FIELD archived ON import_configuration TYPE bool DEFAULT false;

-- ################################################################################################
-- PARTIE 2 : REGISTRE HIÉRARCHIQUE UNIFIÉ
-- ################################################################################################

-- ================================================================================================
-- 🏛️ REGISTRE HIÉRARCHIQUE - TABLE UNIQUE MINIMALE
-- ================================================================================================
-- 
-- Registre unique pour toute la hiérarchie LyxalSuite
-- 
-- Tables incluses:
-- - entity_registry: Registre unifié de toutes les entités (master/investor/business/developer/contractor)
-- - hierarchy_types: Types hiérarchiques dynamiques

-- Date création: 2025-01-27
-- ================================================================================================

-- ================================================================================================
-- 📊 HIERARCHY_TYPES - Types hiérarchiques dynamiques
-- ================================================================================================

DEFINE TABLE hierarchy_types SCHEMAFULL
    COMMENT "Types hiérarchiques configurables"
    PERMISSIONS
        FOR select WHERE true
        FOR create, update WHERE $auth.role CONTAINS 'admin'
        FOR delete WHERE $auth.role CONTAINS 'admin';

DEFINE FIELD name ON hierarchy_types TYPE string
    ASSERT $value != NULL AND string::len($value) >= 3
    COMMENT "Nom du type hiérarchique";

DEFINE FIELD level ON hierarchy_types TYPE int
    ASSERT $value >= 0 AND $value <= 5
    COMMENT "Niveau hiérarchique (0=master, 1=investor, 2=business, 3=developer, 4=contractor, 5=customers)";

DEFINE FIELD description ON hierarchy_types TYPE string
    COMMENT "Description du niveau";

-- Métadonnées
DEFINE FIELD created_at ON hierarchy_types TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON hierarchy_types TYPE datetime DEFAULT time::now();

-- Index unique sur name et level
DEFINE INDEX hierarchy_name_idx ON hierarchy_types FIELDS name UNIQUE;
DEFINE INDEX hierarchy_level_idx ON hierarchy_types FIELDS level UNIQUE;

-- ================================================================================================
-- 🏛️ ENTITY_REGISTRY - Registre unifié de toutes les entités
-- ================================================================================================

DEFINE TABLE entity_registry SCHEMAFULL
    COMMENT "Registre unique hiérarchique - Qui existe où dans la hiérarchie"
    PERMISSIONS
        FOR select WHERE $auth.role CONTAINS 'admin'
        FOR create, update WHERE $auth.role CONTAINS 'admin'
        FOR delete WHERE $auth.role CONTAINS 'admin';

-- Hiérarchie pure
DEFINE FIELD parent_id ON entity_registry TYPE option<record(entity_registry)>
    COMMENT "Parent dans la hiérarchie (NULL = niveau master)";

DEFINE FIELD type_hierarchique ON entity_registry TYPE record(hierarchy_types)
    COMMENT "Type hiérarchique (master/investor/business/developer/contractor)";

DEFINE FIELD namespace ON entity_registry TYPE string
    ASSERT $value != NULL AND string::len($value) >= 3
    COMMENT "Namespace SurrealDB dédié";

DEFINE FIELD status ON entity_registry TYPE string
    ASSERT $value INSIDE ['active', 'suspended', 'trial', 'expired']
    VALUE $value OR 'active'
    COMMENT "Statut de l'entité";

-- Métadonnées minimales
DEFINE FIELD created_at ON entity_registry TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON entity_registry TYPE datetime DEFAULT time::now();

-- Index pour performance
DEFINE INDEX entity_parent_idx ON entity_registry FIELDS parent_id;
DEFINE INDEX entity_type_idx ON entity_registry FIELDS type_hierarchique;
DEFINE INDEX entity_namespace_idx ON entity_registry FIELDS namespace UNIQUE;
DEFINE INDEX entity_status_idx ON entity_registry FIELDS status;

-- ================================================================================================
-- 🎯 ANALYTICS GLOBALES - 
-- utiliser des fonctions SurrealDB
-- Métriques temps réel globales
-- ================================================================================================
;

-- ================================================================================================
-- 🎯 INDEX OPTIMISÉS - Uniquement pour les tables existantes
-- ================================================================================================

-- Index pour analytics
DEFINE INDEX metrics_timestamp_idx ON global_metrics FIELDS timestamp;
