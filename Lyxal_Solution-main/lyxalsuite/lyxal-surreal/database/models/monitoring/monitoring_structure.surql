-- ================================================================================================
-- 🚀 LYXAL SURREAL - STRUCTURE MONITORING BICÉPHALE
-- ================================================================================================
-- Module : lyxal-surreal
-- Description : Tables de monitoring SurrealDB avec architecture INVESTOR/DEVELOPER
-- Version : 1.0.0
-- Architecture : Bicéphale avec isolation native par namespace
-- ================================================================================================

-- ================================================================================================
-- 🏛️ INVESTOR_LEVEL - MONITORING GLOBAL (Namespace: catalog)
-- ================================================================================================

-- Table: global_system_metrics
-- Usage: Métriques système globales de tous les SaaS
-- Namespace: catalog, Database: monitoring
DEFINE TABLE global_system_metrics SCHEMAFULL
    COMMENT "Métriques système globales tous SaaS - INVESTOR_LEVEL"
    PERMISSIONS
        FOR select WHERE $auth.level = 'platform_admin' OR $auth.level = 'investor'
        FOR create WHERE $auth.level = 'system'
        FOR update, delete WHERE $auth.level = 'platform_admin';

DEFINE FIELD timestamp ON global_system_metrics TYPE datetime DEFAULT time::now()
    COMMENT "Horodatage de la métrique";

DEFINE FIELD total_saas_count ON global_system_metrics TYPE int 
    ASSERT $value >= 0
    COMMENT "Nombre total de SaaS actifs";

DEFINE FIELD total_active_connections ON global_system_metrics TYPE int
    ASSERT $value >= 0
    COMMENT "Connexions actives sur toute la plateforme";

DEFINE FIELD total_queries_per_second ON global_system_metrics TYPE float
    ASSERT $value >= 0.0
    COMMENT "Requêtes par seconde globales";

DEFINE FIELD global_cpu_usage ON global_system_metrics TYPE float
    ASSERT $value >= 0.0 AND $value <= 100.0
    COMMENT "Utilisation CPU globale (%)";

DEFINE FIELD global_memory_usage ON global_system_metrics TYPE float
    ASSERT $value >= 0.0 AND $value <= 100.0
    COMMENT "Utilisation mémoire globale (%)";

DEFINE FIELD global_disk_usage ON global_system_metrics TYPE float
    ASSERT $value >= 0.0 AND $value <= 100.0
    COMMENT "Utilisation disque globale (%)";

DEFINE FIELD total_storage_used ON global_system_metrics TYPE float
    ASSERT $value >= 0.0
    COMMENT "Stockage total utilisé (GB)";

DEFINE FIELD global_cache_hit_ratio ON global_system_metrics TYPE float
    ASSERT $value >= 0.0 AND $value <= 100.0
    COMMENT "Ratio cache hit global (%)";

DEFINE FIELD platform_health_score ON global_system_metrics TYPE float
    ASSERT $value >= 0.0 AND $value <= 100.0
    COMMENT "Score de santé plateforme (0-100)";

-- Métadonnées
DEFINE FIELD created_at ON global_system_metrics TYPE datetime DEFAULT time::now();
DEFINE FIELD created_by ON global_system_metrics TYPE string DEFAULT 'system';

-- ------------------------------------------------------------------------------------------------

-- Table: global_saas_health
-- Usage: Santé individuelle de chaque SaaS pour vue d'ensemble
-- Namespace: catalog, Database: monitoring
DEFINE TABLE global_saas_health SCHEMAFULL
    COMMENT "Santé individuelle de chaque SaaS - INVESTOR_LEVEL"
    PERMISSIONS
        FOR select WHERE $auth.level = 'platform_admin' OR $auth.level = 'investor'
        FOR create WHERE $auth.level = 'system'
        FOR update WHERE $auth.level = 'platform_admin';

DEFINE FIELD timestamp ON global_saas_health TYPE datetime DEFAULT time::now()
    COMMENT "Horodatage de la métrique";

DEFINE FIELD saas_namespace ON global_saas_health TYPE string
    ASSERT $value != "" AND string::len($value) >= 2
    COMMENT "Namespace du SaaS";

DEFINE FIELD saas_name ON global_saas_health TYPE string
    ASSERT $value != "" AND string::len($value) >= 2
    COMMENT "Nom d'affichage du SaaS";

DEFINE FIELD health_score ON global_saas_health TYPE float
    ASSERT $value >= 0.0 AND $value <= 100.0
    COMMENT "Score de santé du SaaS (0-100)";

DEFINE FIELD active_users ON global_saas_health TYPE int
    ASSERT $value >= 0
    COMMENT "Utilisateurs actifs du SaaS";

DEFINE FIELD total_workspaces ON global_saas_health TYPE int
    ASSERT $value >= 0
    COMMENT "Nombre de workspaces du SaaS";

DEFINE FIELD queries_per_minute ON global_saas_health TYPE float
    ASSERT $value >= 0.0
    COMMENT "Requêtes par minute du SaaS";

DEFINE FIELD avg_response_time ON global_saas_health TYPE float
    ASSERT $value >= 0.0
    COMMENT "Temps de réponse moyen (ms)";

DEFINE FIELD error_rate ON global_saas_health TYPE float
    ASSERT $value >= 0.0 AND $value <= 100.0
    COMMENT "Taux d'erreur (%)";

DEFINE FIELD storage_usage ON global_saas_health TYPE float
    ASSERT $value >= 0.0
    COMMENT "Utilisation stockage (GB)";

DEFINE FIELD last_activity ON global_saas_health TYPE datetime
    COMMENT "Dernière activité du SaaS";

-- Données IA de prédiction
DEFINE FIELD ai_insights ON global_saas_health TYPE object VALUE {
    performance_trend: "stable",
    growth_prediction: 0.0,
    resource_forecast: {},
    risk_assessment: 0.0,
    optimization_opportunities: []
}
COMMENT "Insights IA pour le SaaS";

-- Métadonnées
DEFINE FIELD created_at ON global_saas_health TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON global_saas_health TYPE datetime DEFAULT time::now();

-- ------------------------------------------------------------------------------------------------

-- Table: cross_saas_analytics
-- Usage: Analytics comparatives entre SaaS pour insights investisseurs
-- Namespace: catalog, Database: monitoring
DEFINE TABLE cross_saas_analytics SCHEMAFULL
    COMMENT "Analytics comparatives entre SaaS - INVESTOR_LEVEL"
    PERMISSIONS
        FOR select WHERE $auth.level = 'platform_admin' OR $auth.level = 'investor'
        FOR create WHERE $auth.level = 'system'
        FOR update WHERE $auth.level = 'platform_admin';

DEFINE FIELD analysis_period ON cross_saas_analytics TYPE string
    ASSERT $value INSIDE ['hourly', 'daily', 'weekly', 'monthly']
    COMMENT "Période d'analyse";

DEFINE FIELD period_start ON cross_saas_analytics TYPE datetime
    COMMENT "Début de la période analysée";

DEFINE FIELD period_end ON cross_saas_analytics TYPE datetime
    COMMENT "Fin de la période analysée";

DEFINE FIELD top_performing_saas ON cross_saas_analytics TYPE array
    COMMENT "SaaS les plus performants";

DEFINE FIELD resource_usage_ranking ON cross_saas_analytics TYPE array
    COMMENT "Classement par utilisation des ressources";

DEFINE FIELD growth_trends ON cross_saas_analytics TYPE object
    COMMENT "Tendances de croissance par SaaS";

DEFINE FIELD performance_benchmarks ON cross_saas_analytics TYPE object VALUE {
    avg_response_time: 0.0,
    avg_error_rate: 0.0,
    avg_uptime: 0.0,
    avg_user_satisfaction: 0.0
}
COMMENT "Benchmarks de performance";

DEFINE FIELD scaling_recommendations ON cross_saas_analytics TYPE array
    COMMENT "Recommandations de scaling par SaaS";

DEFINE FIELD market_insights ON cross_saas_analytics TYPE object VALUE {
    total_market_value: 0.0,
    growth_rate: 0.0,
    competitive_positioning: {},
    investment_opportunities: []
}
COMMENT "Insights marché pour investisseurs";

-- Métadonnées
DEFINE FIELD created_at ON cross_saas_analytics TYPE datetime DEFAULT time::now();
DEFINE FIELD analysis_confidence ON cross_saas_analytics TYPE float DEFAULT 85.0;

-- ------------------------------------------------------------------------------------------------

-- Table: global_alerts
-- Usage: Alertes système globales pour monitoring plateforme
-- Namespace: catalog, Database: monitoring
DEFINE TABLE global_alerts SCHEMAFULL
    COMMENT "Alertes système globales - INVESTOR_LEVEL"
    PERMISSIONS
        FOR select WHERE $auth.level = 'platform_admin' OR $auth.level = 'investor'
        FOR create WHERE $auth.level = 'system'
        FOR update WHERE $auth.level = 'platform_admin';

DEFINE FIELD alert_id ON global_alerts TYPE uuid DEFAULT rand::uuid()
    COMMENT "Identifiant unique de l'alerte";

DEFINE FIELD timestamp ON global_alerts TYPE datetime DEFAULT time::now()
    COMMENT "Horodatage de l'alerte";

DEFINE FIELD alert_type ON global_alerts TYPE string
    ASSERT $value INSIDE ['PLATFORM', 'PERFORMANCE', 'SECURITY', 'CAPACITY', 'BUSINESS']
    COMMENT "Type d'alerte";

DEFINE FIELD severity ON global_alerts TYPE string
    ASSERT $value INSIDE ['LOW', 'MEDIUM', 'HIGH', 'CRITICAL']
    COMMENT "Niveau de sévérité";

DEFINE FIELD affected_saas ON global_alerts TYPE option<string>
    COMMENT "SaaS affecté (null si global)";

DEFINE FIELD metric_name ON global_alerts TYPE string
    COMMENT "Nom de la métrique en alerte";

DEFINE FIELD current_value ON global_alerts TYPE float
    COMMENT "Valeur actuelle de la métrique";

DEFINE FIELD threshold_value ON global_alerts TYPE float
    COMMENT "Seuil de déclenchement";

DEFINE FIELD message ON global_alerts TYPE string
    ASSERT string::len($value) >= 10
    COMMENT "Message d'alerte détaillé";

DEFINE FIELD ai_recommendation ON global_alerts TYPE option<string>
    COMMENT "Recommandation IA pour résolution";

DEFINE FIELD business_impact ON global_alerts TYPE object VALUE {
    revenue_risk: 0.0,
    user_impact: 0.0,
    operational_impact: 0.0,
    reputation_risk: 0.0
}
COMMENT "Impact business estimé";

DEFINE FIELD acknowledged ON global_alerts TYPE bool DEFAULT false
    COMMENT "Alerte acquittée";

DEFINE FIELD acknowledged_by ON global_alerts TYPE option<string>
    COMMENT "Utilisateur ayant acquitté";

DEFINE FIELD acknowledged_at ON global_alerts TYPE option<datetime>
    COMMENT "Date d'acquittement";

DEFINE FIELD resolved ON global_alerts TYPE bool DEFAULT false
    COMMENT "Alerte résolue";

DEFINE FIELD resolution_time ON global_alerts TYPE option<datetime>
    COMMENT "Date de résolution";

-- Métadonnées
DEFINE FIELD created_at ON global_alerts TYPE datetime DEFAULT time::now();
DEFINE FIELD priority_score ON global_alerts TYPE float DEFAULT 50.0;

-- ================================================================================================
-- 🏢 DEVELOPER_LEVEL - MONITORING SAAS (Namespace: {saas_id})
-- ================================================================================================

-- Table: saas_system_metrics
-- Usage: Métriques système pour un SaaS spécifique
-- Namespace: {saas_id}, Database: monitoring
DEFINE TABLE saas_system_metrics SCHEMAFULL
    COMMENT "Métriques système pour ce SaaS uniquement - DEVELOPER_LEVEL"
    PERMISSIONS
        FOR select WHERE $auth.ns = $this.saas_namespace OR $auth.level = 'platform_admin'
        FOR create WHERE $auth.level = 'system'
        FOR update WHERE $auth.level CONTAINS 'saas_admin' OR $auth.level = 'platform_admin';

DEFINE FIELD timestamp ON saas_system_metrics TYPE datetime DEFAULT time::now()
    COMMENT "Horodatage de la métrique";

DEFINE FIELD saas_namespace ON saas_system_metrics TYPE string
    ASSERT $value != "" AND string::len($value) >= 2
    COMMENT "Namespace du SaaS";

DEFINE FIELD cpu_usage ON saas_system_metrics TYPE float
    ASSERT $value >= 0.0 AND $value <= 100.0
    COMMENT "Utilisation CPU du SaaS (%)";

DEFINE FIELD memory_usage ON saas_system_metrics TYPE float
    ASSERT $value >= 0.0 AND $value <= 100.0
    COMMENT "Utilisation mémoire du SaaS (%)";

DEFINE FIELD disk_usage ON saas_system_metrics TYPE float
    ASSERT $value >= 0.0 AND $value <= 100.0
    COMMENT "Utilisation disque du SaaS (%)";

DEFINE FIELD connection_count ON saas_system_metrics TYPE int
    ASSERT $value >= 0
    COMMENT "Nombre de connexions actives";

DEFINE FIELD active_sessions ON saas_system_metrics TYPE int
    ASSERT $value >= 0
    COMMENT "Sessions utilisateur actives";

DEFINE FIELD cache_hit_ratio ON saas_system_metrics TYPE float
    ASSERT $value >= 0.0 AND $value <= 100.0
    COMMENT "Ratio cache hit du SaaS (%)";

DEFINE FIELD avg_query_time ON saas_system_metrics TYPE float
    ASSERT $value >= 0.0
    COMMENT "Temps de requête moyen (ms)";

DEFINE FIELD slow_queries_count ON saas_system_metrics TYPE int
    ASSERT $value >= 0
    COMMENT "Nombre de requêtes lentes";

DEFINE FIELD throughput_qps ON saas_system_metrics TYPE float
    ASSERT $value >= 0.0
    COMMENT "Débit en requêtes par seconde";

-- Analytics business
DEFINE FIELD business_metrics ON saas_system_metrics TYPE object VALUE {
    active_users_count: 0,
    business_operations_per_hour: 0.0,
    revenue_operations_count: 0,
    customer_interactions_count: 0
}
COMMENT "Métriques business du SaaS";

-- Métadonnées
DEFINE FIELD created_at ON saas_system_metrics TYPE datetime DEFAULT time::now();
DEFINE FIELD source ON saas_system_metrics TYPE string DEFAULT 'surrealdb_monitor';

-- ------------------------------------------------------------------------------------------------

-- Table: saas_query_metrics
-- Usage: Détail des requêtes pour analyse performance SaaS
-- Namespace: {saas_id}, Database: monitoring
DEFINE TABLE saas_query_metrics SCHEMAFULL
    COMMENT "Détail des requêtes pour ce SaaS - DEVELOPER_LEVEL"
    PERMISSIONS
        FOR select WHERE $auth.ns = $this.saas_namespace OR $auth.level = 'platform_admin'
        FOR create WHERE $auth.level = 'system'
        FOR update WHERE $auth.level CONTAINS 'saas_admin';

DEFINE FIELD query_id ON saas_query_metrics TYPE uuid DEFAULT rand::uuid()
    COMMENT "Identifiant unique de la requête";

DEFINE FIELD timestamp ON saas_query_metrics TYPE datetime DEFAULT time::now()
    COMMENT "Horodatage de la requête";

DEFINE FIELD saas_namespace ON saas_query_metrics TYPE string
    ASSERT $value != "" AND string::len($value) >= 2
    COMMENT "Namespace du SaaS";

DEFINE FIELD database_name ON saas_query_metrics TYPE string
    COMMENT "Nom de la database";

DEFINE FIELD query_text ON saas_query_metrics TYPE string
    COMMENT "Texte de la requête (anonymisé)";

DEFINE FIELD query_type ON saas_query_metrics TYPE string
    ASSERT $value INSIDE ['SELECT', 'INSERT', 'UPDATE', 'DELETE', 'CREATE', 'DEFINE', 'LIVE', 'KILL']
    COMMENT "Type de requête";

DEFINE FIELD duration_ms ON saas_query_metrics TYPE float
    ASSERT $value >= 0.0
    COMMENT "Durée d'exécution (ms)";

DEFINE FIELD rows_affected ON saas_query_metrics TYPE int
    ASSERT $value >= 0
    COMMENT "Nombre de lignes affectées";

DEFINE FIELD user_id ON saas_query_metrics TYPE option<string>
    COMMENT "ID utilisateur (anonymisé)";

DEFINE FIELD is_slow_query ON saas_query_metrics TYPE bool DEFAULT false
    COMMENT "Marquée comme requête lente";

DEFINE FIELD error_message ON saas_query_metrics TYPE option<string>
    COMMENT "Message d'erreur si échec";

DEFINE FIELD execution_plan ON saas_query_metrics TYPE option<object>
    COMMENT "Plan d'exécution (si disponible)";

-- Analytics de la requête
DEFINE FIELD query_analytics ON saas_query_metrics TYPE object VALUE {
    complexity_score: 0.0,
    optimization_potential: 0.0,
    resource_usage: {},
    performance_impact: 0.0
}
COMMENT "Analytics de performance de la requête";

-- Métadonnées
DEFINE FIELD created_at ON saas_query_metrics TYPE datetime DEFAULT time::now();
DEFINE FIELD retention_days ON saas_query_metrics TYPE int DEFAULT 30;

-- ------------------------------------------------------------------------------------------------

-- Table: saas_alerts
-- Usage: Alertes spécifiques au SaaS pour équipes dev/ops
-- Namespace: {saas_id}, Database: monitoring
DEFINE TABLE saas_alerts SCHEMAFULL
    COMMENT "Alertes spécifiques au SaaS - DEVELOPER_LEVEL"
    PERMISSIONS
        FOR select WHERE $auth.ns = $this.saas_namespace OR $auth.level = 'platform_admin'
        FOR create WHERE $auth.level = 'system'
        FOR update WHERE $auth.level CONTAINS 'saas_admin';

DEFINE FIELD alert_id ON saas_alerts TYPE uuid DEFAULT rand::uuid()
    COMMENT "Identifiant unique de l'alerte";

DEFINE FIELD timestamp ON saas_alerts TYPE datetime DEFAULT time::now()
    COMMENT "Horodatage de l'alerte";

DEFINE FIELD saas_namespace ON saas_alerts TYPE string
    ASSERT $value != "" AND string::len($value) >= 2
    COMMENT "Namespace du SaaS";

DEFINE FIELD alert_type ON saas_alerts TYPE string
    ASSERT $value INSIDE ['PERFORMANCE', 'SECURITY', 'CAPACITY', 'BUSINESS', 'USER_EXPERIENCE']
    COMMENT "Type d'alerte SaaS";

DEFINE FIELD severity ON saas_alerts TYPE string
    ASSERT $value INSIDE ['LOW', 'MEDIUM', 'HIGH', 'CRITICAL']
    COMMENT "Niveau de sévérité";

DEFINE FIELD workspace_affected ON saas_alerts TYPE option<string>
    COMMENT "Workspace affecté (null si SaaS global)";

DEFINE FIELD metric_name ON saas_alerts TYPE string
    COMMENT "Nom de la métrique en alerte";

DEFINE FIELD current_value ON saas_alerts TYPE float
    COMMENT "Valeur actuelle";

DEFINE FIELD threshold_value ON saas_alerts TYPE float
    COMMENT "Seuil configuré";

DEFINE FIELD message ON saas_alerts TYPE string
    ASSERT string::len($value) >= 10
    COMMENT "Message d'alerte";

DEFINE FIELD ai_recommendation ON saas_alerts TYPE option<string>
    COMMENT "Recommandation IA";

DEFINE FIELD user_impact ON saas_alerts TYPE object VALUE {
    affected_users_count: 0,
    business_operations_impacted: 0,
    estimated_downtime: 0.0,
    revenue_impact: 0.0
}
COMMENT "Impact utilisateur/business";

DEFINE FIELD acknowledged ON saas_alerts TYPE bool DEFAULT false;
DEFINE FIELD acknowledged_by ON saas_alerts TYPE option<string>;
DEFINE FIELD acknowledged_at ON saas_alerts TYPE option<datetime>;
DEFINE FIELD resolved ON saas_alerts TYPE bool DEFAULT false;
DEFINE FIELD resolution_time ON saas_alerts TYPE option<datetime>;

-- Métadonnées
DEFINE FIELD created_at ON saas_alerts TYPE datetime DEFAULT time::now();
DEFINE FIELD escalation_level ON saas_alerts TYPE int DEFAULT 1;

-- ------------------------------------------------------------------------------------------------

-- Table: workspace_metrics
-- Usage: Métriques spécifiques aux workspaces
-- Namespace: {saas_id}, Database: workspace_{id}
DEFINE TABLE workspace_metrics SCHEMAFULL
    COMMENT "Métriques spécifiques au workspace - DEVELOPER_LEVEL"
    PERMISSIONS
        FOR select WHERE $auth.ns = $this.saas_namespace
        FOR create WHERE $auth.level = 'system'
        FOR update WHERE $auth.level CONTAINS 'workspace_admin';

DEFINE FIELD timestamp ON workspace_metrics TYPE datetime DEFAULT time::now()
    COMMENT "Horodatage de la métrique";

DEFINE FIELD workspace_name ON workspace_metrics TYPE string
    ASSERT $value != "" AND string::len($value) >= 2
    COMMENT "Nom du workspace";

DEFINE FIELD active_users_count ON workspace_metrics TYPE int
    ASSERT $value >= 0
    COMMENT "Utilisateurs actifs dans le workspace";

DEFINE FIELD total_records ON workspace_metrics TYPE int
    ASSERT $value >= 0
    COMMENT "Nombre total d'enregistrements";

DEFINE FIELD total_tables ON workspace_metrics TYPE int
    ASSERT $value >= 0
    COMMENT "Nombre total de tables";

DEFINE FIELD data_size_mb ON workspace_metrics TYPE float
    ASSERT $value >= 0.0
    COMMENT "Taille des données (MB)";

DEFINE FIELD queries_per_minute ON workspace_metrics TYPE float
    ASSERT $value >= 0.0
    COMMENT "Requêtes par minute du workspace";

DEFINE FIELD business_operations_count ON workspace_metrics TYPE int
    ASSERT $value >= 0
    COMMENT "Opérations business par heure";

-- Usage des modules installés
DEFINE FIELD module_usage_stats ON workspace_metrics TYPE object VALUE {
    installed_modules: [],
    module_activity: {},
    most_used_features: [],
    performance_by_module: {}
}
COMMENT "Statistiques d'usage des modules";

-- Analytics business du workspace
DEFINE FIELD business_analytics ON workspace_metrics TYPE object VALUE {
    revenue_operations: 0,
    customer_interactions: 0,
    document_processing: 0,
    workflow_completions: 0,
    api_calls: 0
}
COMMENT "Analytics business du workspace";

-- Métadonnées
DEFINE FIELD created_at ON workspace_metrics TYPE datetime DEFAULT time::now();
DEFINE FIELD workspace_health_score ON workspace_metrics TYPE float DEFAULT 100.0;

-- ================================================================================================
-- 🔧 TABLES UTILITAIRES COMMUNES
-- ================================================================================================

-- Table: monitoring_config
-- Usage: Configuration du système de monitoring
DEFINE TABLE monitoring_config SCHEMAFULL
    COMMENT "Configuration du système de monitoring"
    PERMISSIONS
        FOR select WHERE $auth.level = 'platform_admin' OR $auth.level CONTAINS 'saas_admin'
        FOR create, update WHERE $auth.level = 'platform_admin'
        FOR delete WHERE $auth.level = 'platform_admin';

DEFINE FIELD config_key ON monitoring_config TYPE string
    ASSERT $value != ""
    COMMENT "Clé de configuration";

DEFINE FIELD config_value ON monitoring_config TYPE flexible
    COMMENT "Valeur de configuration";

DEFINE FIELD config_level ON monitoring_config TYPE string
    ASSERT $value INSIDE ['GLOBAL', 'SAAS', 'WORKSPACE']
    COMMENT "Niveau de configuration";

DEFINE FIELD saas_namespace ON monitoring_config TYPE option<string>
    COMMENT "Namespace SaaS (si config SaaS)";

DEFINE FIELD description ON monitoring_config TYPE string
    COMMENT "Description de la configuration";

DEFINE FIELD created_at ON monitoring_config TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON monitoring_config TYPE datetime DEFAULT time::now();

-- ================================================================================================
-- 🎯 FIN DE LA STRUCTURE MONITORING BICÉPHALE
-- ================================================================================================

-- Total : 8 tables principales + 1 table config
-- Architecture : Bicéphale INVESTOR/DEVELOPER avec isolation native
-- Capabilities : Real-time monitoring, IA analytics, multi-tenant, performance optimization
-- Permissions : Granulaires par niveau d'accès et namespace 