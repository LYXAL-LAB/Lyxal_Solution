-- ================================================================================================
-- 📊 MASTER REGISTRY - INDEX OPTIMISÉS
-- ================================================================================================

-- Index de performance pour les tables registry du niveau master
-- Namespace: lyxal_master | Database: main

-- ================================================================================================
-- INDEX PRIMAIRES
-- ================================================================================================

-- Index primaires pour performance
DEFINE INDEX investor_id_idx ON investor_registry FIELDS investor_id UNIQUE;
DEFINE INDEX business_id_idx ON business_registry FIELDS business_id UNIQUE;
DEFINE INDEX developer_id_idx ON developer_registry FIELDS developer_id UNIQUE;
DEFINE INDEX contractor_id_idx ON contractor_registry FIELDS contractor_id UNIQUE;

-- ================================================================================================
-- INDEX HIÉRARCHIQUES
-- ================================================================================================

-- Index hiérarchiques pour jointures rapides
DEFINE INDEX business_parent_idx ON business_registry FIELDS parent_investor_id;
DEFINE INDEX developer_parent_idx ON developer_registry FIELDS parent_business_id, parent_investor_id;
DEFINE INDEX contractor_parent_idx ON contractor_registry FIELDS parent_developer_id, parent_business_id, parent_investor_id;

-- ================================================================================================
-- INDEX ANALYTICS
-- ================================================================================================

-- Index pour analytics et métriques
DEFINE INDEX metrics_timestamp_idx ON global_metrics FIELDS timestamp;
DEFINE INDEX revenue_date_idx ON revenue_distribution FIELDS date;

-- ================================================================================================
-- INDEX RECHERCHES FRÉQUENTES
-- ================================================================================================

-- Index pour recherches fréquentes
DEFINE INDEX investor_status_idx ON investor_registry FIELDS status;
DEFINE INDEX business_status_idx ON business_registry FIELDS status;
DEFINE INDEX developer_industry_idx ON developer_registry FIELDS industry;
DEFINE INDEX developer_template_idx ON developer_registry FIELDS saas_template;
DEFINE INDEX contractor_status_idx ON contractor_registry FIELDS status;

-- Index composites pour requêtes complexes
DEFINE INDEX investor_plan_status_idx ON investor_registry FIELDS plan, status;
DEFINE INDEX business_investor_status_idx ON business_registry FIELDS parent_investor_id, status;
DEFINE INDEX developer_business_industry_idx ON developer_registry FIELDS parent_business_id, industry;
DEFINE INDEX contractor_developer_status_idx ON contractor_registry FIELDS parent_developer_id, status; 