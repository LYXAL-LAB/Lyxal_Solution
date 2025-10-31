-- ================================================================================================
-- 🔐 LYXAL SURREAL - PERMISSIONS MONITORING GRANULAIRES
-- ================================================================================================
-- Module : lyxal-surreal
-- Description : Système de permissions granulaires pour monitoring bicéphale
-- Version : 1.0.0
-- Architecture : Isolation complète INVESTOR/DEVELOPER avec permissions cross-namespace
-- ================================================================================================

-- ================================================================================================
-- 👥 DÉFINITION DES RÔLES UTILISATEUR
-- ================================================================================================

-- Rôle: Platform Administrator (Super Admin)
-- Niveau: GLOBAL - Accès complet à tous les namespaces
DEFINE SCOPE platform_admin SESSION 7d
    SIGNUP (
        CREATE user SET
            email = $email,
            password = crypto::argon2::generate($password),
            role = 'platform_admin',
            level = 'platform_admin',
            permissions = ['global_read', 'global_write', 'global_admin'],
            created_at = time::now(),
            namespace_access = ['*']
    )
    SIGNIN (
        SELECT * FROM user WHERE email = $email 
        AND crypto::argon2::compare(password, $password) 
        AND role = 'platform_admin'
    );

-- Rôle: Investor (Lecture seule INVESTOR_LEVEL)
-- Niveau: INVESTOR_LEVEL - Accès lecture aux métriques globales
DEFINE SCOPE investor SESSION 30d
    SIGNUP (
        CREATE user SET
            email = $email,
            password = crypto::argon2::generate($password),
            role = 'investor',
            level = 'investor',
            permissions = ['global_read', 'analytics_read'],
            created_at = time::now(),
            namespace_access = ['catalog']
    )
    SIGNIN (
        SELECT * FROM user WHERE email = $email 
        AND crypto::argon2::compare(password, $password) 
        AND role = 'investor'
    );

-- Rôle: SaaS Administrator (Admin SaaS spécifique)
-- Niveau: DEVELOPER_LEVEL - Accès complet sur son SaaS
DEFINE SCOPE saas_admin SESSION 7d
    SIGNUP (
        CREATE user SET
            email = $email,
            password = crypto::argon2::generate($password),
            role = 'saas_admin',
            level = 'saas_admin',
            saas_namespace = $saas_namespace,
            permissions = ['saas_read', 'saas_write', 'saas_admin'],
            created_at = time::now(),
            namespace_access = [$saas_namespace]
    )
    SIGNIN (
        SELECT * FROM user WHERE email = $email 
        AND crypto::argon2::compare(password, $password) 
        AND role = 'saas_admin'
        AND saas_namespace = $saas_namespace
    );

-- Rôle: SaaS Developer (Développeur SaaS)
-- Niveau: DEVELOPER_LEVEL - Accès lecture/écriture limité
DEFINE SCOPE saas_developer SESSION 7d
    SIGNUP (
        CREATE user SET
            email = $email,
            password = crypto::argon2::generate($password),
            role = 'saas_developer',
            level = 'saas_developer',
            saas_namespace = $saas_namespace,
            permissions = ['saas_read', 'metrics_write'],
            created_at = time::now(),
            namespace_access = [$saas_namespace]
    )
    SIGNIN (
        SELECT * FROM user WHERE email = $email 
        AND crypto::argon2::compare(password, $password) 
        AND role = 'saas_developer'
        AND saas_namespace = $saas_namespace
    );

-- Rôle: Workspace Manager (Gestionnaire workspace)
-- Niveau: DEVELOPER_LEVEL - Accès limité aux workspaces
DEFINE SCOPE workspace_manager SESSION 7d
    SIGNUP (
        CREATE user SET
            email = $email,
            password = crypto::argon2::generate($password),
            role = 'workspace_manager',
            level = 'workspace_manager',
            saas_namespace = $saas_namespace,
            workspace_names = $workspace_names,
            permissions = ['workspace_read', 'workspace_write'],
            created_at = time::now(),
            namespace_access = [$saas_namespace]
    )
    SIGNIN (
        SELECT * FROM user WHERE email = $email 
        AND crypto::argon2::compare(password, $password) 
        AND role = 'workspace_manager'
        AND saas_namespace = $saas_namespace
    );

-- Rôle: System Monitor (Système automatique)
-- Niveau: CROSS-LEVEL - Accès système pour monitoring
DEFINE SCOPE system_monitor SESSION 365d
    SIGNUP (
        CREATE user SET
            email = $email,
            password = crypto::argon2::generate($password),
            role = 'system',
            level = 'system',
            permissions = ['system_read', 'system_write', 'metrics_create'],
            created_at = time::now(),
            namespace_access = ['*']
    )
    SIGNIN (
        SELECT * FROM user WHERE email = $email 
        AND crypto::argon2::compare(password, $password) 
        AND role = 'system'
    );

-- ================================================================================================
-- 🏛️ INVESTOR_LEVEL - PERMISSIONS TABLES GLOBALES
-- ================================================================================================

-- Permissions: global_system_metrics
-- Accès: Lecture pour investors/admins, écriture pour système
DEFINE TABLE global_system_metrics PERMISSIONS
    FOR select WHERE 
        $auth.level = 'platform_admin' OR 
        $auth.level = 'investor' OR
        ($auth.level = 'saas_admin' AND 'global_read' IN $auth.permissions)
    FOR create WHERE 
        $auth.level = 'system' OR
        $auth.level = 'platform_admin'
    FOR update WHERE 
        $auth.level = 'platform_admin'
    FOR delete WHERE 
        $auth.level = 'platform_admin';

-- Permissions: global_saas_health
-- Accès: Lecture pour investors/admins, écriture pour système et SaaS concerné
DEFINE TABLE global_saas_health PERMISSIONS
    FOR select WHERE 
        $auth.level = 'platform_admin' OR 
        $auth.level = 'investor' OR
        ($auth.level = 'saas_admin' AND (saas_namespace = $auth.saas_namespace OR '*' IN $auth.namespace_access))
    FOR create WHERE 
        $auth.level = 'system' OR
        $auth.level = 'platform_admin' OR
        ($auth.level = 'saas_admin' AND saas_namespace = $auth.saas_namespace)
    FOR update WHERE 
        $auth.level = 'platform_admin' OR
        ($auth.level = 'saas_admin' AND saas_namespace = $auth.saas_namespace)
    FOR delete WHERE 
        $auth.level = 'platform_admin';

-- Permissions: cross_saas_analytics
-- Accès: Lecture pour investors/admins uniquement
DEFINE TABLE cross_saas_analytics PERMISSIONS
    FOR select WHERE 
        $auth.level = 'platform_admin' OR 
        $auth.level = 'investor'
    FOR create WHERE 
        $auth.level = 'system' OR
        $auth.level = 'platform_admin'
    FOR update WHERE 
        $auth.level = 'platform_admin'
    FOR delete WHERE 
        $auth.level = 'platform_admin';

-- Permissions: global_alerts
-- Accès: Lecture pour investors/admins, acquittement pour admins
DEFINE TABLE global_alerts PERMISSIONS
    FOR select WHERE 
        $auth.level = 'platform_admin' OR 
        $auth.level = 'investor' OR
        ($auth.level = 'saas_admin' AND (affected_saas = $auth.saas_namespace OR affected_saas IS NULL))
    FOR create WHERE 
        $auth.level = 'system' OR
        $auth.level = 'platform_admin'
    FOR update WHERE 
        $auth.level = 'platform_admin' OR
        ($auth.level = 'saas_admin' AND affected_saas = $auth.saas_namespace AND 
         (acknowledged = false OR acknowledged_by = $auth.email))
    FOR delete WHERE 
        $auth.level = 'platform_admin';

-- ================================================================================================
-- 🏢 DEVELOPER_LEVEL - PERMISSIONS TABLES SAAS
-- ================================================================================================

-- Permissions: saas_system_metrics
-- Accès: Isolation par namespace SaaS
DEFINE TABLE saas_system_metrics PERMISSIONS
    FOR select WHERE 
        $auth.level = 'platform_admin' OR
        ($auth.level IN ['saas_admin', 'saas_developer'] AND saas_namespace = $auth.saas_namespace) OR
        ($auth.level = 'investor' AND 'global_read' IN $auth.permissions)
    FOR create WHERE 
        $auth.level = 'system' OR
        $auth.level = 'platform_admin' OR
        ($auth.level IN ['saas_admin', 'saas_developer'] AND saas_namespace = $auth.saas_namespace)
    FOR update WHERE 
        $auth.level = 'platform_admin' OR
        ($auth.level = 'saas_admin' AND saas_namespace = $auth.saas_namespace)
    FOR delete WHERE 
        $auth.level = 'platform_admin' OR
        ($auth.level = 'saas_admin' AND saas_namespace = $auth.saas_namespace);

-- Permissions: saas_query_metrics
-- Accès: Isolation stricte par namespace + données sensibles
DEFINE TABLE saas_query_metrics PERMISSIONS
    FOR select WHERE 
        $auth.level = 'platform_admin' OR
        ($auth.level IN ['saas_admin', 'saas_developer'] AND saas_namespace = $auth.saas_namespace)
    FOR create WHERE 
        $auth.level = 'system' OR
        $auth.level = 'platform_admin' OR
        ($auth.level IN ['saas_admin', 'saas_developer'] AND saas_namespace = $auth.saas_namespace)
    FOR update WHERE 
        $auth.level = 'platform_admin' OR
        ($auth.level = 'saas_admin' AND saas_namespace = $auth.saas_namespace)
    FOR delete WHERE 
        $auth.level = 'platform_admin' OR
        ($auth.level = 'saas_admin' AND saas_namespace = $auth.saas_namespace AND created_at < (time::now() - 7d));

-- Permissions: saas_alerts
-- Accès: Gestion d'alertes par équipe SaaS
DEFINE TABLE saas_alerts PERMISSIONS
    FOR select WHERE 
        $auth.level = 'platform_admin' OR
        ($auth.level IN ['saas_admin', 'saas_developer'] AND saas_namespace = $auth.saas_namespace) OR
        ($auth.level = 'workspace_manager' AND saas_namespace = $auth.saas_namespace AND 
         (workspace_affected IS NULL OR workspace_affected IN $auth.workspace_names))
    FOR create WHERE 
        $auth.level = 'system' OR
        $auth.level = 'platform_admin' OR
        ($auth.level IN ['saas_admin', 'saas_developer'] AND saas_namespace = $auth.saas_namespace)
    FOR update WHERE 
        $auth.level = 'platform_admin' OR
        ($auth.level = 'saas_admin' AND saas_namespace = $auth.saas_namespace) OR
        ($auth.level IN ['saas_developer', 'workspace_manager'] AND saas_namespace = $auth.saas_namespace AND 
         (acknowledged = false OR acknowledged_by = $auth.email))
    FOR delete WHERE 
        $auth.level = 'platform_admin' OR
        ($auth.level = 'saas_admin' AND saas_namespace = $auth.saas_namespace);

-- Permissions: workspace_metrics
-- Accès: Isolation par workspace spécifique
DEFINE TABLE workspace_metrics PERMISSIONS
    FOR select WHERE 
        $auth.level = 'platform_admin' OR
        ($auth.level IN ['saas_admin', 'saas_developer'] AND meta::tb(id).namespace = $auth.saas_namespace) OR
        ($auth.level = 'workspace_manager' AND meta::tb(id).namespace = $auth.saas_namespace AND 
         workspace_name IN $auth.workspace_names)
    FOR create WHERE 
        $auth.level = 'system' OR
        $auth.level = 'platform_admin' OR
        ($auth.level IN ['saas_admin', 'saas_developer'] AND meta::tb(id).namespace = $auth.saas_namespace) OR
        ($auth.level = 'workspace_manager' AND meta::tb(id).namespace = $auth.saas_namespace AND 
         workspace_name IN $auth.workspace_names)
    FOR update WHERE 
        $auth.level = 'platform_admin' OR
        ($auth.level IN ['saas_admin', 'workspace_manager'] AND meta::tb(id).namespace = $auth.saas_namespace AND 
         ($auth.level = 'saas_admin' OR workspace_name IN $auth.workspace_names))
    FOR delete WHERE 
        $auth.level = 'platform_admin' OR
        ($auth.level = 'saas_admin' AND meta::tb(id).namespace = $auth.saas_namespace);

-- ================================================================================================
-- 🔧 PERMISSIONS TABLES UTILITAIRES
-- ================================================================================================

-- Permissions: monitoring_config
-- Accès: Configuration par niveau d'autorisation
DEFINE TABLE monitoring_config PERMISSIONS
    FOR select WHERE 
        $auth.level = 'platform_admin' OR
        ($auth.level IN ['saas_admin', 'investor'] AND (config_level = 'GLOBAL' OR config_level = 'SAAS')) OR
        ($auth.level IN ['saas_developer', 'workspace_manager'] AND config_level IN ['SAAS', 'WORKSPACE'] AND 
         (saas_namespace IS NULL OR saas_namespace = $auth.saas_namespace))
    FOR create WHERE 
        $auth.level = 'platform_admin' OR
        ($auth.level = 'saas_admin' AND config_level IN ['SAAS', 'WORKSPACE'] AND saas_namespace = $auth.saas_namespace)
    FOR update WHERE 
        $auth.level = 'platform_admin' OR
        ($auth.level = 'saas_admin' AND config_level IN ['SAAS', 'WORKSPACE'] AND saas_namespace = $auth.saas_namespace)
    FOR delete WHERE 
        $auth.level = 'platform_admin';

-- ================================================================================================
-- 🎯 PERMISSIONS FONCTIONS AVANCÉES
-- ================================================================================================

-- Permissions fonction: fn::calculate_global_health
-- Accès: Investors, Platform Admins, Système
DEFINE FUNCTION fn::calculate_global_health() PERMISSIONS
    FOR execute WHERE 
        $auth.level = 'platform_admin' OR 
        $auth.level = 'investor' OR
        $auth.level = 'system';

-- Permissions fonction: fn::cross_saas_performance_ranking
-- Accès: Investors, Platform Admins uniquement
DEFINE FUNCTION fn::cross_saas_performance_ranking($period: string) PERMISSIONS
    FOR execute WHERE 
        $auth.level = 'platform_admin' OR 
        $auth.level = 'investor';

-- Permissions fonction: fn::predict_platform_scaling
-- Accès: Platform Admins, Investors avec restrictions
DEFINE FUNCTION fn::predict_platform_scaling($forecast_days: int) PERMISSIONS
    FOR execute WHERE 
        $auth.level = 'platform_admin' OR 
        ($auth.level = 'investor' AND $forecast_days <= 90);

-- Permissions fonction: fn::calculate_saas_performance
-- Accès: Isolation par SaaS namespace
DEFINE FUNCTION fn::calculate_saas_performance($saas_namespace: string, $hours: int) PERMISSIONS
    FOR execute WHERE 
        $auth.level = 'platform_admin' OR
        ($auth.level IN ['saas_admin', 'saas_developer'] AND $saas_namespace = $auth.saas_namespace) OR
        $auth.level = 'system';

-- Permissions fonction: fn::detect_slow_queries
-- Accès: Équipes SaaS pour leur namespace
DEFINE FUNCTION fn::detect_slow_queries($saas_namespace: string, $threshold_ms: float, $limit: int) PERMISSIONS
    FOR execute WHERE 
        $auth.level = 'platform_admin' OR
        ($auth.level IN ['saas_admin', 'saas_developer'] AND $saas_namespace = $auth.saas_namespace) OR
        $auth.level = 'system';

-- Permissions fonction: fn::workspace_health_check
-- Accès: Gestionnaires workspace + admins SaaS
DEFINE FUNCTION fn::workspace_health_check($workspace_name: string, $saas_namespace: string) PERMISSIONS
    FOR execute WHERE 
        $auth.level = 'platform_admin' OR
        ($auth.level IN ['saas_admin', 'saas_developer'] AND $saas_namespace = $auth.saas_namespace) OR
        ($auth.level = 'workspace_manager' AND $saas_namespace = $auth.saas_namespace AND 
         $workspace_name IN $auth.workspace_names);

-- Permissions fonction: fn::calculate_cost_optimization
-- Accès: Selon le niveau d'analyse demandé
DEFINE FUNCTION fn::calculate_cost_optimization($level: string, $namespace: option<string>) PERMISSIONS
    FOR execute WHERE 
        $auth.level = 'platform_admin' OR
        ($auth.level = 'investor' AND $level = 'GLOBAL') OR
        ($auth.level = 'saas_admin' AND $level = 'SAAS' AND $namespace = $auth.saas_namespace);

-- ================================================================================================
-- 🛡️ POLITIQUES DE SÉCURITÉ AVANCÉES
-- ================================================================================================

-- Politique: Anonymisation des données sensibles
-- Application: Requêtes et informations utilisateur
DEFINE ANALYZER anonymize_sensitive AS {
    FILTERS: [
        {
            FILTER: "query_text",
            TOKENIZER: "blank",
            TRANSFORM: |$text| {
                string::replace(string::replace($text, /\b\d{4}\b/g, "****"), /\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b/g, "***@***.***")
            }
        },
        {
            FILTER: "user_id", 
            TOKENIZER: "blank",
            TRANSFORM: |$id| {
                IF $auth.level NOT IN ['platform_admin', 'system'] THEN
                    "user_" + crypto::md5($id)[0:8]
                ELSE
                    $id
                END
            }
        }
    ]
};

-- Politique: Limitation des requêtes par utilisateur
-- Application: Prévention des abus
DEFINE TABLE rate_limiting SCHEMAFULL PERMISSIONS
    FOR select WHERE $auth.level = 'platform_admin'
    FOR create WHERE $auth.level = 'system'
    FOR update WHERE $auth.level = 'system'
    FOR delete WHERE $auth.level = 'platform_admin';

DEFINE FIELD user_id ON rate_limiting TYPE string;
DEFINE FIELD request_count ON rate_limiting TYPE int DEFAULT 0;
DEFINE FIELD last_request ON rate_limiting TYPE datetime DEFAULT time::now();
DEFINE FIELD daily_limit ON rate_limiting TYPE int DEFAULT 10000;

-- Event de contrôle de taux
DEFINE EVENT rate_limit_check ON TABLE rate_limiting WHEN $event = "CREATE" OR $event = "UPDATE" THEN {
    IF $after.request_count > $after.daily_limit THEN {
        INSERT INTO security_alerts {
            alert_type: "SECURITY",
            severity: "HIGH",
            user_id: $after.user_id,
            message: "Limite de requêtes quotidienne dépassée",
            current_value: $after.request_count,
            threshold_value: $after.daily_limit,
            timestamp: time::now()
        };
    };
};

-- Politique: Audit des accès sensibles
-- Application: Traçabilité complète
DEFINE TABLE access_audit SCHEMAFULL PERMISSIONS
    FOR select WHERE $auth.level = 'platform_admin'
    FOR create WHERE $auth.level = 'system'
    FOR update WHERE false
    FOR delete WHERE $auth.level = 'platform_admin' AND created_at < (time::now() - 365d);

DEFINE FIELD user_id ON access_audit TYPE string;
DEFINE FIELD user_level ON access_audit TYPE string;
DEFINE FIELD action ON access_audit TYPE string;
DEFINE FIELD resource ON access_audit TYPE string;
DEFINE FIELD namespace_accessed ON access_audit TYPE option<string>;
DEFINE FIELD ip_address ON access_audit TYPE option<string>;
DEFINE FIELD user_agent ON access_audit TYPE option<string>;
DEFINE FIELD success ON access_audit TYPE bool;
DEFINE FIELD timestamp ON access_audit TYPE datetime DEFAULT time::now();

-- Politique: Encryption des données sensibles en transit
-- Application: Chiffrement automatique
DEFINE FIELD encrypted_data ON saas_query_metrics TYPE option<string> 
    VALUE crypto::encrypt::aes("query_encryption_key", query_text) 
    PERMISSIONS FOR select WHERE $auth.level IN ['platform_admin', 'system'];

-- ================================================================================================
-- 🔐 POLITIQUES DE RÉTENTION ET ARCHIVAGE
-- ================================================================================================

-- Politique: Rétention différentielle des données
DEFINE TABLE data_retention_policy SCHEMAFULL;
DEFINE FIELD table_name ON data_retention_policy TYPE string;
DEFINE FIELD retention_days ON data_retention_policy TYPE int;
DEFINE FIELD archive_after_days ON data_retention_policy TYPE int;
DEFINE FIELD compression_enabled ON data_retention_policy TYPE bool DEFAULT true;

-- Politique par défaut
INSERT INTO data_retention_policy [
    { table_name: "saas_query_metrics", retention_days: 90, archive_after_days: 30 },
    { table_name: "saas_system_metrics", retention_days: 365, archive_after_days: 90 },
    { table_name: "workspace_metrics", retention_days: 180, archive_after_days: 60 },
    { table_name: "global_system_metrics", retention_days: 1095, archive_after_days: 365 },
    { table_name: "saas_alerts", retention_days: 365, archive_after_days: 90 },
    { table_name: "global_alerts", retention_days: 1095, archive_after_days: 365 }
];

-- Event d'archivage automatique
DEFINE EVENT automated_archival ON TABLE data_retention_policy WHEN $event = "CREATE" OR $event = "UPDATE" THEN {
    -- Déclenché par le système de maintenance
    IF $after.table_name = "trigger_archival" THEN {
        FOR $policy IN (SELECT * FROM data_retention_policy) {
            LET $archive_date = time::now() - duration::from::days($policy.archive_after_days);
            LET $delete_date = time::now() - duration::from::days($policy.retention_days);
            
            -- Archivage des données anciennes
            CREATE archive_log SET {
                table_name: $policy.table_name,
                archive_date: time::now(),
                archived_records: count(
                    QUERY "SELECT * FROM " + $policy.table_name + " WHERE created_at < " + $archive_date + " AND archived != true"
                ),
                deleted_records: count(
                    QUERY "DELETE FROM " + $policy.table_name + " WHERE created_at < " + $delete_date
                )
            };
        };
    };
};

-- ================================================================================================
-- 🎯 FIN DES PERMISSIONS MONITORING GRANULAIRES
-- ================================================================================================

-- Total : 6 scopes utilisateur + Permissions complètes sur 8 tables + 7 fonctions
-- Sécurité : Isolation namespace, anonymisation, audit, rate limiting, encryption
-- Compliance : Rétention GDPR, archivage automatique, traçabilité complète
-- Architecture : Support complet bicéphale avec permissions cross-namespace sécurisées 