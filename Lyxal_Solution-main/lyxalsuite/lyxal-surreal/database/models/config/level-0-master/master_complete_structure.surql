-- ================================================================================================
-- 🏛️ NIVEAU MASTER - STRUCTURE COMPLÈTE (FUSION)
-- ================================================================================================
-- 
-- Ce fichier est la fusion de :
-- - master_system_structure.surql (Configuration système)
-- - master_registry_structure.surql (Registres hiérarchiques)
-- 
-- Date de fusion: 2025-01-27
-- Aucune modification du contenu : fusion simple
-- ================================================================================================

-- ################################################################################################
-- PARTIE 1 : CONFIGURATION SYSTÈME (master_system_structure.surql)
-- ################################################################################################

-- ================================================================================================
-- ⚙️ CONFIGURATION SYSTÈME - LYXAL SURREAL
-- ================================================================================================
-- 
-- Ce fichier contient toutes les tables de configuration système
-- Migrées depuis lyxal-base pour une meilleure séparation des responsabilités
-- 
-- Tables incluses:
-- - system_identity: Configuration identité plateforme MASTER
-- - system_infrastructure: Configuration infrastructure technique MASTER
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
-- SYSTEM_IDENTITY - CONFIGURATION IDENTITÉ PLATEFORME MASTER
-- ================================================================================

DEFINE TABLE system_identity SCHEMAFULL
    COMMENT "Configuration identité plateforme MASTER - Modifiable à chaud pour solution commerciale"
    PERMISSIONS
        FOR select WHERE true
        FOR create, update WHERE $auth.role CONTAINS 'admin'
        FOR delete WHERE $auth.role CONTAINS 'admin';

DEFINE FIELD platform_name ON system_identity TYPE string
    ASSERT $value != NULL AND string::len($value) > 0
    VALUE $value OR "LYXAL"
    COMMENT "Nom officiel de la plateforme (modifiable à chaud)";

DEFINE FIELD platform_id ON system_identity TYPE string
    ASSERT $value != NULL AND string::len($value) > 0
    VALUE $value OR "lyxal-master-001"
    COMMENT "Identifiant unique de la plateforme (modifiable à chaud)";

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

DEFINE FIELD niveau_architectural ON system_identity TYPE int
    ASSERT $value INSIDE [0, 1, 2, 3, 4, 5]
    VALUE $value OR 0
    COMMENT "Niveau architectural (0=MASTER, 1=INVESTOR, 2=BUSINESS, 3=DEVELOPER, 4=CONTRACTOR, 5=END_USERS)";

DEFINE FIELD theme_par_defaut ON system_identity TYPE string
    ASSERT $value INSIDE [
        "light", "dark", "cupcake", "bumblebee", "emerald", "corporate", "synthwave", "retro",
        "cyberpunk", "valentine", "halloween", "garden", "forest", "aqua", "lofi", "pastel",
        "fantasy", "wireframe", "black", "luxury", "dracula", "cmyk", "autumn", "business",
        "acid", "lemonade", "night", "coffee", "winter", "dim", "nord", "sunset"
    ]
    VALUE $value OR "corporate"
    COMMENT "Thème par défaut de l'application (modifiable à chaud)";

DEFINE FIELD theme_website ON system_identity TYPE string
    ASSERT $value INSIDE [
        "light", "dark", "cupcake", "bumblebee", "emerald", "corporate", "synthwave", "retro",
        "cyberpunk", "valentine", "halloween", "garden", "forest", "aqua", "lofi", "pastel",
        "fantasy", "wireframe", "black", "luxury", "dracula", "cmyk", "autumn", "business",
        "acid", "lemonade", "night", "coffee", "winter", "dim", "nord", "sunset"
    ]
    VALUE $value OR "corporate"
    COMMENT "Thème fixe du site marketing (modifiable à chaud)";

DEFINE FIELD ultimate ON system_identity TYPE bool
    VALUE $value OR false
    COMMENT "Grade ultimate permettant la création d'autres masters (source de revenu)";

-- Métadonnées
DEFINE FIELD createdAt ON system_identity TYPE datetime DEFAULT time::now();
DEFINE FIELD updatedAt ON system_identity TYPE datetime DEFAULT time::now();
DEFINE FIELD createdBy ON system_identity TYPE option<record<user>>;

-- Index pour les requêtes fréquentes
DEFINE INDEX idx_platform_id ON system_identity COLUMNS platform_id UNIQUE;

-- ================================================================================
-- SYSTEM_INFRASTRUCTURE - CONFIGURATION INFRASTRUCTURE TECHNIQUE MASTER
-- ================================================================================

DEFINE TABLE system_infrastructure SCHEMAFULL
    COMMENT "Configuration infrastructure technique MASTER - Modifiable à chaud pour solution commerciale"
    PERMISSIONS
        FOR select WHERE true
        FOR create, update WHERE $auth.role CONTAINS 'admin'
        FOR delete WHERE $auth.role CONTAINS 'admin';

DEFINE FIELD surreal_db_url ON system_infrastructure TYPE string
    ASSERT $value != NULL AND (string::starts_with($value, "ws://") OR string::starts_with($value, "wss://"))
    VALUE $value OR "wss://accurate-horse-06bnu0f1k1tv1215mv54m347tc.aws-euw1.surreal.cloud/rpc"
    COMMENT "URL de connexion à l'instance SurrealDB (modifiable à chaud)";

DEFINE FIELD surreal_namespace ON system_infrastructure TYPE string
    ASSERT $value != NULL AND string::len($value) > 0
    VALUE $value OR "lyxal_master"
    COMMENT "Namespace SurrealDB pour la plateforme (modifiable à chaud)";

DEFINE FIELD surreal_database ON system_infrastructure TYPE string
    ASSERT $value != NULL AND string::len($value) > 0
    VALUE $value OR "platform_control"
    COMMENT "Database SurrealDB pour le contrôle plateforme (modifiable à chaud)";

DEFINE FIELD surreal_username ON system_infrastructure TYPE string
    ASSERT $value != NULL AND string::len($value) > 0
    VALUE $value OR "lyxal_app_user"
    COMMENT "Nom d'utilisateur SurrealDB (modifiable à chaud)";

DEFINE FIELD surreal_password ON system_infrastructure TYPE string
    ASSERT $value != NULL AND string::len($value) > 0
    VALUE $value OR "app_password_2025"
    COMMENT "Mot de passe SurrealDB (modifiable à chaud)";

DEFINE FIELD logto_master_endpoint ON system_infrastructure TYPE string
    ASSERT $value != NULL AND string::starts_with($value, "https://")
    VALUE $value OR "https://lyxal-master.logto.cloud"
    COMMENT "Endpoint Logto pour l'authentification (modifiable à chaud)";

DEFINE FIELD logto_admin_app_id ON system_infrastructure TYPE string
    ASSERT $value != NULL AND string::len($value) > 0
    VALUE $value OR "lyxal-admin-console"
    COMMENT "App ID Logto pour la console d'administration (modifiable à chaud)";

DEFINE FIELD api_base_url ON system_infrastructure TYPE string
    ASSERT $value != NULL AND string::starts_with($value, "https://")
    VALUE $value OR "https://api.lyxal.com"
    COMMENT "URL de base de l'API backend (modifiable à chaud)";

-- Métadonnées
DEFINE FIELD createdAt ON system_infrastructure TYPE datetime DEFAULT time::now();
DEFINE FIELD updatedAt ON system_infrastructure TYPE datetime DEFAULT time::now();
DEFINE FIELD createdBy ON system_infrastructure TYPE option<record<user>>;

-- Index pour les requêtes fréquentes
DEFINE INDEX idx_surreal_namespace ON system_infrastructure COLUMNS surreal_namespace;

-- ================================================================================
-- SYSTEM_CONFIG_METADATA - HISTORIQUE DES MODIFICATIONS
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
    COMMENT "Configuration application avec IA d'optimisation système"
    PERMISSIONS
        FOR select WHERE true
        FOR create, update WHERE $auth.role CONTAINS 'admin'
        FOR delete WHERE $auth.role CONTAINS 'admin';

DEFINE FIELD code ON app_configuration TYPE string
    ASSERT $value != NULL AND string::len($value) >= 1
    COMMENT "Code configuration";

DEFINE FIELD name ON app_configuration TYPE string
    ASSERT $value != NULL AND string::len($value) >= 2
    COMMENT "Nom de la configuration";

DEFINE FIELD version ON app_configuration TYPE string
    VALUE $value OR '1.0.0'
    COMMENT "Version de la configuration";

DEFINE FIELD isDefault ON app_configuration TYPE bool DEFAULT false
    COMMENT "Configuration par défaut";

DEFINE FIELD isActive ON app_configuration TYPE bool DEFAULT true
    COMMENT "Configuration active";

-- Paramètres système
DEFINE FIELD systemParameters ON app_configuration TYPE object VALUE {
    maxUsers: 1000,
    sessionTimeout: 3600,
    backupFrequency: 24,
    logRetention: 90,
    cacheSize: 256,
    performanceMode: 'STANDARD'
};

-- Intelligence IA système
DEFINE FIELD systemAI ON app_configuration TYPE object VALUE {
    performanceOptimization: {},
    resourceUtilization: {},
    predictionModels: {},
    autoTuning: false,
    healthMetrics: {},
    alertRules: []
};

-- Analytics système
DEFINE FIELD systemAnalytics ON app_configuration TYPE object VALUE {
    uptime: 100.0,
    responseTime: 0.0,
    throughput: 0.0,
    errorRate: 0.0,
    resourceUsage: {},
    userActivity: {}
};

-- Métadonnées
DEFINE FIELD createdAt ON app_configuration TYPE datetime DEFAULT time::now();
DEFINE FIELD updatedAt ON app_configuration TYPE datetime DEFAULT time::now();
DEFINE FIELD createdBy ON app_configuration TYPE option<record<user>>;

-- Table: locale_configuration (Configuration locale)

-- ================================================================================
-- LOCALE_CONFIGURATION
-- ================================================================================

DEFINE TABLE locale_configuration SCHEMAFULL
    COMMENT "Configuration locale avec IA d'adaptation culturelle"
    PERMISSIONS
        FOR select WHERE true
        FOR create, update WHERE $auth.role CONTAINS 'admin' OR $auth.role CONTAINS 'localization_manager'
        FOR delete WHERE $auth.role CONTAINS 'admin';

DEFINE FIELD code ON locale_configuration TYPE string
    ASSERT $value != NULL AND string::len($value) >= 2
    COMMENT "Code locale (ex: fr_FR, en_US)";

DEFINE FIELD name ON locale_configuration TYPE string
    ASSERT $value != NULL AND string::len($value) >= 2
    COMMENT "Nom de la locale";

DEFINE FIELD language ON locale_configuration TYPE string
    ASSERT $value != NULL AND string::len($value) = 2
    COMMENT "Code langue ISO 639-1";

DEFINE FIELD country ON locale_configuration TYPE record<country>
    COMMENT "Pays de la locale";

DEFINE FIELD isDefault ON locale_configuration TYPE bool DEFAULT false
    COMMENT "Locale par défaut";

-- Formats de données
DEFINE FIELD dataFormats ON locale_configuration TYPE object VALUE {
    dateFormat: 'DD/MM/YYYY',
    timeFormat: 'HH:mm',
    numberFormat: '#,##0.00',
    currencyFormat: '#,##0.00 ¤',
    decimalSeparator: '.',
    groupingSeparator: ','
};

-- Intelligence IA culturelle
DEFINE FIELD culturalAI ON locale_configuration TYPE object VALUE {
    culturalPatterns: {},
    businessPractices: {},
    communicationStyle: 'FORMAL',
    timeZoneBehavior: {},
    seasonalFactors: {},
    holidayCalendar: []
};

-- Analytics d'utilisation
DEFINE FIELD localeAnalytics ON locale_configuration TYPE object VALUE {
    userAdoption: 0.0,
    satisfactionScore: 0.0,
    translationAccuracy: 0.0,
    culturalCompliance: 0.0,
    usagePatterns: {}
};

-- Métadonnées
DEFINE FIELD createdAt ON locale_configuration TYPE datetime DEFAULT time::now();
DEFINE FIELD updatedAt ON locale_configuration TYPE datetime DEFAULT time::now();
DEFINE FIELD createdBy ON locale_configuration TYPE option<record<user>>;
DEFINE FIELD archived ON locale_configuration TYPE bool DEFAULT false;

-- Table: period_configuration (Configuration des périodes)

-- ================================================================================
-- PERIOD_CONFIGURATION
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
-- PARTIE 2 : REGISTRES HIÉRARCHIQUES (master_registry_structure.surql)
-- ################################################################################################

-- ================================================================================================
-- 🏛️ MASTER REGISTRY - TABLES NIVEAU MASTER (Niveau 0)
-- ================================================================================================
-- 
-- Ce fichier contient toutes les tables de registres du niveau master
-- pour la gestion hiérarchique complète de LyxalSuite
-- 
-- Tables incluses:
-- - investor_registry: Registre des investors (propriétaires infrastructure)
-- - business_registry: Registre des businesses (utilisateurs infrastructure)  
-- - developer_registry: Registre des developers (créateurs SaaS)
-- - contractor_registry: Registre des contractors (utilisateurs finaux SaaS)
-- - Relations hiérarchiques et analytics globales
-- 
-- Namespace: lyxal_master
-- Database: main
-- Date création: 2025-01-XX
-- ================================================================================================

-- ================================================================================================
-- 🏛️ INVESTOR_REGISTRY - Propriétaires Infrastructure
-- ================================================================================================

DEFINE TABLE investor_registry SCHEMAFULL
    COMMENT "Registre des investors - Propriétaires de l'infrastructure complète"
    PERMISSIONS
        FOR select WHERE $auth.level = 'master_admin' OR $auth.level = 'platform_admin'
        FOR create, update WHERE $auth.level = 'master_admin'
        FOR delete WHERE $auth.level = 'master_admin';

-- Identification
DEFINE FIELD investor_id ON investor_registry TYPE string
    ASSERT $value != NULL AND string::len($value) >= 3
    COMMENT "Identifiant unique investor";

DEFINE FIELD display_name ON investor_registry TYPE string
    ASSERT $value != NULL AND string::len($value) >= 2
    COMMENT "Nom d'affichage investor";

DEFINE FIELD namespace ON investor_registry TYPE string
    ASSERT $value != NULL AND string::len($value) >= 3
    COMMENT "Namespace SurrealDB dédié";

-- Infrastructure propriétaire
DEFINE FIELD infrastructure ON investor_registry TYPE object VALUE {
    surrealdb_instance: "",
    logto_tenant: "",
    hosting_provider: "",
    domain_root: "",
    ssl_certificates: [],
    backup_strategy: "",
    monitoring_endpoints: []
} COMMENT "Configuration infrastructure propriétaire";

-- Plan et facturation
DEFINE FIELD plan ON investor_registry TYPE string
    ASSERT $value INSIDE ['trial', 'starter', 'professional', 'enterprise']
    VALUE $value OR 'starter'
    COMMENT "Plan souscrit par l'investor";

DEFINE FIELD status ON investor_registry TYPE string
    ASSERT $value INSIDE ['active', 'suspended', 'trial', 'expired']
    VALUE $value OR 'active'
    COMMENT "Statut de l'investor";

-- Métriques business
DEFINE FIELD total_revenue ON investor_registry TYPE decimal DEFAULT 0.0
    COMMENT "Revenus totaux générés";

DEFINE FIELD business_count ON investor_registry TYPE int DEFAULT 0
    COMMENT "Nombre de businesses sous cet investor";

-- Contact et métadonnées
DEFINE FIELD contact ON investor_registry TYPE object VALUE {
    email: "",
    company: "",
    phone: "",
    address: {}
} COMMENT "Informations de contact";

DEFINE FIELD created_at ON investor_registry TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON investor_registry TYPE datetime DEFAULT time::now();

-- ================================================================================================
-- 🏢 BUSINESS_REGISTRY - Utilisateurs Infrastructure
-- ================================================================================================

DEFINE TABLE business_registry SCHEMAFULL
    COMMENT "Registre des businesses - Utilisateurs de l'infrastructure investor"
    PERMISSIONS
        FOR select WHERE $auth.level = 'master_admin' OR $auth.level = 'investor_admin'
        FOR create, update WHERE $auth.level = 'master_admin' OR $auth.level = 'investor_admin'
        FOR delete WHERE $auth.level = 'master_admin';

-- Identification et hiérarchie
DEFINE FIELD business_id ON business_registry TYPE string
    ASSERT $value != NULL AND string::len($value) >= 3
    COMMENT "Identifiant unique business";

DEFINE FIELD parent_investor_id ON business_registry TYPE string
    ASSERT $value != NULL
    COMMENT "ID de l'investor parent";

DEFINE FIELD display_name ON business_registry TYPE string
    ASSERT $value != NULL AND string::len($value) >= 2
    COMMENT "Nom d'affichage business";

DEFINE FIELD namespace ON business_registry TYPE string
    ASSERT $value != NULL AND string::len($value) >= 3
    COMMENT "Namespace dans l'instance investor";

-- Configuration business
DEFINE FIELD plan ON business_registry TYPE string
    ASSERT $value INSIDE ['starter', 'professional', 'enterprise']
    VALUE $value OR 'starter'
    COMMENT "Plan business souscrit";

DEFINE FIELD monthly_fee ON business_registry TYPE decimal DEFAULT 0.0
    COMMENT "Frais mensuels payés à l'investor";

DEFINE FIELD status ON business_registry TYPE string
    ASSERT $value INSIDE ['active', 'suspended', 'trial', 'expired']
    VALUE $value OR 'active'
    COMMENT "Statut du business";

-- Métriques
DEFINE FIELD developer_count ON business_registry TYPE int DEFAULT 0
    COMMENT "Nombre de developers créés";

DEFINE FIELD saas_count ON business_registry TYPE int DEFAULT 0
    COMMENT "Nombre de SaaS déployés";

-- Métadonnées
DEFINE FIELD created_at ON business_registry TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON business_registry TYPE datetime DEFAULT time::now();

-- ================================================================================================
-- 💼 DEVELOPER_REGISTRY - Créateurs SaaS
-- ================================================================================================

DEFINE TABLE developer_registry SCHEMAFULL
    COMMENT "Registre des developers - Créateurs et gestionnaires de SaaS"
    PERMISSIONS
        FOR select WHERE $auth.level IN ['master_admin', 'investor_admin', 'business_admin']
        FOR create, update WHERE $auth.level IN ['master_admin', 'investor_admin', 'business_admin']
        FOR delete WHERE $auth.level IN ['master_admin', 'business_admin'];

-- Identification et hiérarchie
DEFINE FIELD developer_id ON developer_registry TYPE string
    ASSERT $value != NULL AND string::len($value) >= 3
    COMMENT "Identifiant unique developer";

DEFINE FIELD parent_business_id ON developer_registry TYPE string
    ASSERT $value != NULL
    COMMENT "ID du business parent";

DEFINE FIELD parent_investor_id ON developer_registry TYPE string
    ASSERT $value != NULL
    COMMENT "ID de l'investor racine";

DEFINE FIELD display_name ON developer_registry TYPE string
    ASSERT $value != NULL AND string::len($value) >= 2
    COMMENT "Nom d'affichage developer";

DEFINE FIELD namespace ON developer_registry TYPE string
    ASSERT $value != NULL AND string::len($value) >= 3
    COMMENT "Namespace du SaaS";

-- Configuration SaaS
DEFINE FIELD industry ON developer_registry TYPE string
    ASSERT $value INSIDE ['restaurant', 'ecommerce', 'legal', 'medical', 'consulting', 'real_estate', 'automotive', 'education', 'finance', 'retail', 'other']
    COMMENT "Industrie du SaaS";

DEFINE FIELD saas_template ON developer_registry TYPE string
    ASSERT $value INSIDE ['restaurant-full', 'restaurant-lite', 'ecommerce-full', 'ecommerce-lite', 'legal-full', 'crm-basic', 'erp-full', 'custom']
    COMMENT "Template de SaaS utilisé";

DEFINE FIELD monthly_subscription ON developer_registry TYPE decimal DEFAULT 0.0
    COMMENT "Abonnement mensuel payé au business";

DEFINE FIELD status ON developer_registry TYPE string
    ASSERT $value INSIDE ['active', 'suspended', 'trial', 'maintenance']
    VALUE $value OR 'active'
    COMMENT "Statut du developer/SaaS";

-- Métriques utilisateurs
DEFINE FIELD contractor_count ON developer_registry TYPE int DEFAULT 0
    COMMENT "Nombre de contractors (utilisateurs finaux)";

DEFINE FIELD end_users_count ON developer_registry TYPE int DEFAULT 0
    COMMENT "Nombre total d'utilisateurs finaux";

-- Métadonnées
DEFINE FIELD created_at ON developer_registry TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON developer_registry TYPE datetime DEFAULT time::now();

-- ================================================================================================
-- 🏗️ CONTRACTOR_REGISTRY - Utilisateurs Finaux SaaS
-- ================================================================================================

DEFINE TABLE contractor_registry SCHEMAFULL
    COMMENT "Registre des contractors - Utilisateurs finaux des SaaS"
    PERMISSIONS
        FOR select WHERE $auth.level IN ['master_admin', 'investor_admin', 'business_admin', 'developer_admin']
        FOR create, update WHERE $auth.level IN ['master_admin', 'business_admin', 'developer_admin']
        FOR delete WHERE $auth.level IN ['master_admin', 'developer_admin'];

-- Identification et hiérarchie complète
DEFINE FIELD contractor_id ON contractor_registry TYPE string
    ASSERT $value != NULL AND string::len($value) >= 3
    COMMENT "Identifiant unique contractor";

DEFINE FIELD parent_developer_id ON contractor_registry TYPE string
    ASSERT $value != NULL
    COMMENT "ID du developer parent";

DEFINE FIELD parent_business_id ON contractor_registry TYPE string
    ASSERT $value != NULL
    COMMENT "ID du business racine";

DEFINE FIELD parent_investor_id ON contractor_registry TYPE string
    ASSERT $value != NULL
    COMMENT "ID de l'investor racine";

DEFINE FIELD display_name ON contractor_registry TYPE string
    ASSERT $value != NULL AND string::len($value) >= 2
    COMMENT "Nom d'affichage contractor";

-- Configuration SaaS final
DEFINE FIELD saas_type ON contractor_registry TYPE string
    COMMENT "Type de SaaS utilisé";

DEFINE FIELD domain ON contractor_registry TYPE string
    COMMENT "Domaine du SaaS contractor";

DEFINE FIELD monthly_subscription ON contractor_registry TYPE decimal DEFAULT 0.0
    COMMENT "Abonnement mensuel payé au developer";

DEFINE FIELD status ON contractor_registry TYPE string
    ASSERT $value INSIDE ['active', 'suspended', 'trial', 'churned']
    VALUE $value OR 'active'
    COMMENT "Statut du contractor";

-- Métriques d'usage
DEFINE FIELD active_users ON contractor_registry TYPE int DEFAULT 0
    COMMENT "Utilisateurs actifs du contractor";

DEFINE FIELD storage_used_gb ON contractor_registry TYPE float DEFAULT 0.0
    COMMENT "Stockage utilisé en GB";

-- Métadonnées
DEFINE FIELD created_at ON contractor_registry TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON contractor_registry TYPE datetime DEFAULT time::now();

-- ================================================================================================
-- 🔗 RELATIONS HIÉRARCHIQUES
-- ================================================================================================

-- Relation: Investor owns Business
DEFINE TABLE owns_business SCHEMAFULL
    COMMENT "Relation propriété investor -> business";

DEFINE FIELD in ON owns_business TYPE record(investor_registry);
DEFINE FIELD out ON owns_business TYPE record(business_registry);
DEFINE FIELD created_at ON owns_business TYPE datetime DEFAULT time::now();
DEFINE FIELD revenue_share_percentage ON owns_business TYPE float DEFAULT 30.0
    COMMENT "Pourcentage de revenus pour l'investor";

-- Relation: Business manages Developer
DEFINE TABLE manages_developer SCHEMAFULL
    COMMENT "Relation gestion business -> developer";

DEFINE FIELD in ON manages_developer TYPE record(business_registry);
DEFINE FIELD out ON manages_developer TYPE record(developer_registry);
DEFINE FIELD created_at ON manages_developer TYPE datetime DEFAULT time::now();
DEFINE FIELD commission_percentage ON manages_developer TYPE float DEFAULT 20.0
    COMMENT "Pourcentage de commission pour le business";

-- Relation: Developer serves Contractor
DEFINE TABLE serves_contractor SCHEMAFULL
    COMMENT "Relation service developer -> contractor";

DEFINE FIELD in ON serves_contractor TYPE record(developer_registry);
DEFINE FIELD out ON serves_contractor TYPE record(contractor_registry);
DEFINE FIELD created_at ON serves_contractor TYPE datetime DEFAULT time::now();
DEFINE FIELD service_level ON serves_contractor TYPE string
    ASSERT $value INSIDE ['basic', 'premium', 'enterprise']
    VALUE $value OR 'basic'
    COMMENT "Niveau de service fourni";

-- ================================================================================================
-- 📈 ANALYTICS GLOBALES
-- ================================================================================================

-- Métriques temps réel globales
DEFINE TABLE global_metrics SCHEMAFULL
    COMMENT "Métriques temps réel de la plateforme globale"
    PERMISSIONS
        FOR select WHERE $auth.level IN ['master_admin', 'platform_admin']
        FOR create WHERE $auth.level = 'system'
        FOR update, delete WHERE $auth.level = 'master_admin';

DEFINE FIELD timestamp ON global_metrics TYPE datetime DEFAULT time::now();
DEFINE FIELD total_investors ON global_metrics TYPE int DEFAULT 0;
DEFINE FIELD total_businesses ON global_metrics TYPE int DEFAULT 0;
DEFINE FIELD total_developers ON global_metrics TYPE int DEFAULT 0;
DEFINE FIELD total_contractors ON global_metrics TYPE int DEFAULT 0;
DEFINE FIELD total_end_users ON global_metrics TYPE int DEFAULT 0;
DEFINE FIELD total_revenue_daily ON global_metrics TYPE decimal DEFAULT 0.0;
DEFINE FIELD platform_health_score ON global_metrics TYPE float DEFAULT 100.0;

-- Distribution des revenus
DEFINE TABLE revenue_distribution SCHEMAFULL
    COMMENT "Distribution des revenus par niveau hiérarchique"
    PERMISSIONS
        FOR select WHERE $auth.level IN ['master_admin', 'platform_admin']
        FOR create WHERE $auth.level = 'system'
        FOR update, delete WHERE $auth.level = 'master_admin';

DEFINE FIELD date ON revenue_distribution TYPE datetime DEFAULT time::now();
DEFINE FIELD investor_revenue ON revenue_distribution TYPE decimal DEFAULT 0.0;
DEFINE FIELD business_revenue ON revenue_distribution TYPE decimal DEFAULT 0.0;
DEFINE FIELD developer_revenue ON revenue_distribution TYPE decimal DEFAULT 0.0;
DEFINE FIELD contractor_revenue ON revenue_distribution TYPE decimal DEFAULT 0.0;
DEFINE FIELD platform_commission ON revenue_distribution TYPE decimal DEFAULT 0.0;

-- ================================================================================================
-- 🎯 INDEX OPTIMISÉS
-- ================================================================================================

-- Index primaires pour performance
DEFINE INDEX investor_id_idx ON investor_registry FIELDS investor_id UNIQUE;
DEFINE INDEX business_id_idx ON business_registry FIELDS business_id UNIQUE;
DEFINE INDEX developer_id_idx ON developer_registry FIELDS developer_id UNIQUE;
DEFINE INDEX contractor_id_idx ON contractor_registry FIELDS contractor_id UNIQUE;

-- Index hiérarchiques pour jointures rapides
DEFINE INDEX business_parent_idx ON business_registry FIELDS parent_investor_id;
DEFINE INDEX developer_parent_idx ON developer_registry FIELDS parent_business_id, parent_investor_id;
DEFINE INDEX contractor_parent_idx ON contractor_registry FIELDS parent_developer_id, parent_business_id, parent_investor_id;

-- Index pour analytics
DEFINE INDEX metrics_timestamp_idx ON global_metrics FIELDS timestamp;
DEFINE INDEX revenue_date_idx ON revenue_distribution FIELDS date;

-- Index pour recherches fréquentes
DEFINE INDEX investor_status_idx ON investor_registry FIELDS status;
DEFINE INDEX business_status_idx ON business_registry FIELDS status;
DEFINE INDEX developer_industry_idx ON developer_registry FIELDS industry;
DEFINE INDEX contractor_status_idx ON contractor_registry FIELDS status;

-- ================================================================================================
-- 🎯 FIN STRUCTURE COMPLÈTE NIVEAU MASTER
-- ================================================================================================ 