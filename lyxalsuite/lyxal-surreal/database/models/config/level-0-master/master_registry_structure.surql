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