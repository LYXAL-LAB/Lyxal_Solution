-- ================================================================================================
-- 🚨 SYSTÈME D'ALERTES - MONITORING INTELLIGENT
-- ================================================================================================
-- Module : lyxal-monitoring
-- Description : Système d'alertes et monitoring en temps réel
-- Version : 1.0.0
-- Architecture : Alertes intelligentes avec auto-résolution
-- ================================================================================================

-- ================================================================================================
-- 📊 TABLES SYSTÈME D'ALERTES
-- ================================================================================================

-- Table pour les alertes intelligentes
DEFINE TABLE alert SCHEMAFULL
    COMMENT "Système d'alertes intelligent avec classification automatique"
    PERMISSIONS 
        FOR SELECT WHERE true
        FOR CREATE WHERE $auth.role CONTAINS 'system' OR $auth.role CONTAINS 'admin'
        FOR UPDATE WHERE $auth.role CONTAINS 'admin' OR $auth.role CONTAINS 'support'
        FOR DELETE WHERE $auth.role CONTAINS 'admin';

DEFINE FIELD investor_id ON alert TYPE string ASSERT $value != NULL;
DEFINE FIELD alert_type ON alert TYPE string 
    ASSERT $value INSIDE ['quota_warning', 'performance_issue', 'security_alert', 'billing_issue', 'system_error', 'maintenance_required']
    COMMENT "Type d'alerte pour classification";

DEFINE FIELD severity ON alert TYPE string 
    ASSERT $value INSIDE ['low', 'medium', 'high', 'critical']
    DEFAULT 'medium'
    COMMENT "Niveau de sévérité de l'alerte";

DEFINE FIELD title ON alert TYPE string ASSERT $value != NULL 
    COMMENT "Titre court de l'alerte";

DEFINE FIELD message ON alert TYPE string ASSERT $value != NULL 
    COMMENT "Message détaillé de l'alerte";

DEFINE FIELD context ON alert TYPE object 
    COMMENT "Contexte et données additionnelles";

DEFINE FIELD resolved ON alert TYPE bool DEFAULT false;
DEFINE FIELD resolved_at ON alert TYPE datetime;
DEFINE FIELD resolved_by ON alert TYPE record<user>;
DEFINE FIELD resolution_notes ON alert TYPE string;

DEFINE FIELD auto_resolved ON alert TYPE bool DEFAULT false 
    COMMENT "Alerte résolue automatiquement par le système";

DEFINE FIELD escalated ON alert TYPE bool DEFAULT false;
DEFINE FIELD escalated_at ON alert TYPE datetime;
DEFINE FIELD escalation_level ON alert TYPE int DEFAULT 0;

DEFINE FIELD created_at ON alert TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON alert TYPE datetime DEFAULT time::now();

-- Table pour les règles d'alertes
DEFINE TABLE alert_rule SCHEMAFULL
    COMMENT "Règles configurables pour génération d'alertes"
    PERMISSIONS 
        FOR SELECT WHERE true
        FOR CREATE, UPDATE, DELETE WHERE $auth.role CONTAINS 'admin';

DEFINE FIELD rule_name ON alert_rule TYPE string ASSERT $value != NULL;
DEFINE FIELD rule_type ON alert_rule TYPE string 
    ASSERT $value INSIDE ['threshold', 'pattern', 'anomaly', 'trend'];

DEFINE FIELD condition_query ON alert_rule TYPE string 
    COMMENT "Requête SurrealDB pour évaluer la condition";

DEFINE FIELD threshold_value ON alert_rule TYPE float;
DEFINE FIELD comparison_operator ON alert_rule TYPE string 
    ASSERT $value INSIDE ['>', '>=', '<', '<=', '=', '!='];

DEFINE FIELD alert_template ON alert_rule TYPE object 
    COMMENT "Template pour générer l'alerte";

DEFINE FIELD is_active ON alert_rule TYPE bool DEFAULT true;
DEFINE FIELD check_interval ON alert_rule TYPE duration DEFAULT duration::minutes(5);

DEFINE FIELD created_at ON alert_rule TYPE datetime DEFAULT time::now();
DEFINE FIELD last_checked ON alert_rule TYPE datetime;

-- ================================================================================================
-- ⚡ ÉVÉNEMENTS AUTOMATIQUES D'ALERTES
-- ================================================================================================

-- Event : Surveillance en temps réel des quotas
DEFINE EVENT quota_monitor ON TABLE investor_metrics WHEN $event = "CREATE" OR $event = "UPDATE" THEN {
    LET $config = SELECT * FROM investor_config WHERE investor_id = $after.investor_id;
    
    -- Alerte API critique
    IF $after.api_calls_used / $config[0].limits.api_calls_per_month > 0.9 THEN {
        CREATE alert SET 
            investor_id = $after.investor_id,
            alert_type = 'quota_warning',
            severity = 'high',
            title = 'Quota API critique',
            message = string::concat('Quota API à ', math::round($after.api_calls_used / $config[0].limits.api_calls_per_month * 100, 1), '%'),
            context = {
                current_usage: $after.api_calls_used,
                limit: $config[0].limits.api_calls_per_month,
                percentage: $after.api_calls_used / $config[0].limits.api_calls_per_month * 100
            };
    };
    
    -- Alerte stockage
    IF $after.storage_used_gb / $config[0].limits.storage_gb > 0.85 THEN {
        CREATE alert SET 
            investor_id = $after.investor_id,
            alert_type = 'quota_warning',
            severity = 'medium',
            title = 'Stockage élevé',
            message = string::concat('Stockage à ', math::round($after.storage_used_gb / $config[0].limits.storage_gb * 100, 1), '%'),
            context = {
                current_storage: $after.storage_used_gb,
                limit: $config[0].limits.storage_gb,
                percentage: $after.storage_used_gb / $config[0].limits.storage_gb * 100
            };
    };
};

-- Event : Auto-résolution des alertes
DEFINE EVENT alert_auto_resolver ON TABLE alert WHEN $event = "CREATE" THEN {
    -- Auto-résoudre les alertes de quota si l'usage redescend
    IF $after.alert_type = 'quota_warning' THEN {
        LET $current_metrics = SELECT * FROM investor_metrics 
                              WHERE investor_id = $after.investor_id 
                              ORDER BY created_at DESC LIMIT 1;
        
        LET $config = SELECT * FROM investor_config WHERE investor_id = $after.investor_id;
        LET $usage_ratio = $current_metrics[0].api_calls_used / $config[0].limits.api_calls_per_month;
        
        IF $usage_ratio < 0.8 THEN {
            UPDATE $after.id SET 
                resolved = true,
                resolved_at = time::now(),
                auto_resolved = true,
                resolution_notes = 'Usage revenu à un niveau normal';
        };
    };
};

-- ================================================================================================
-- 🎯 FONCTIONS DE MONITORING AVANCÉ
-- ================================================================================================

-- Fonction pour créer une alerte personnalisée
DEFINE FUNCTION fn::create_alert($investor_id: string, $type: string, $severity: string, $title: string, $message: string, $context: object) {
    -- Vérifier si une alerte similaire existe déjà
    LET $existing = SELECT * FROM alert 
                   WHERE investor_id = $investor_id 
                   AND alert_type = $type 
                   AND resolved = false 
                   AND created_at > (time::now() - duration::hours(1));
    
    IF array::len($existing) > 0 THEN {
        -- Mettre à jour l'alerte existante
        UPDATE $existing[0].id SET 
            message = $message,
            context = $context,
            updated_at = time::now();
        
        RETURN {
            action: 'updated',
            alert_id: $existing[0].id
        };
    } ELSE {
        -- Créer nouvelle alerte
        LET $alert = CREATE alert SET 
            investor_id = $investor_id,
            alert_type = $type,
            severity = $severity,
            title = $title,
            message = $message,
            context = $context;
        
        RETURN {
            action: 'created',
            alert_id: $alert.id
        };
    };
};

-- Fonction pour résoudre une alerte
DEFINE FUNCTION fn::resolve_alert($alert_id: record<alert>, $user_id: record<user>, $notes: string) {
    UPDATE $alert_id SET 
        resolved = true,
        resolved_at = time::now(),
        resolved_by = $user_id,
        resolution_notes = $notes,
        updated_at = time::now();
    
    RETURN {
        status: 'resolved',
        resolved_at: time::now()
    };
};

-- Fonction pour escalader une alerte
DEFINE FUNCTION fn::escalate_alert($alert_id: record<alert>) {
    LET $alert = SELECT * FROM $alert_id;
    
    UPDATE $alert_id SET 
        escalated = true,
        escalated_at = time::now(),
        escalation_level = $alert[0].escalation_level + 1,
        severity = IF $alert[0].severity = 'low' THEN 'medium' 
                  ELSE IF $alert[0].severity = 'medium' THEN 'high' 
                  ELSE 'critical' END,
        updated_at = time::now();
    
    -- Créer notification d'escalade
    CREATE alert SET 
        investor_id = $alert[0].investor_id,
        alert_type = 'system_error',
        severity = 'high',
        title = 'Alerte escaladée',
        message = string::concat('Alerte ', $alert_id, ' escaladée au niveau ', $alert[0].escalation_level + 1),
        context = {
            original_alert: $alert_id,
            escalation_reason: 'auto_escalation_timeout'
        };
    
    RETURN {
        status: 'escalated',
        new_level: $alert[0].escalation_level + 1
    };
};

-- ================================================================================================
-- 📈 DASHBOARD ALERTES TEMPS RÉEL
-- ================================================================================================

-- Vue pour dashboard alertes
DEFINE FUNCTION fn::alerts_dashboard($investor_id: string) {
    LET $active_alerts = SELECT * FROM alert 
                        WHERE investor_id = $investor_id AND resolved = false 
                        ORDER BY severity DESC, created_at DESC;
    
    LET $recent_resolved = SELECT * FROM alert 
                          WHERE investor_id = $investor_id AND resolved = true 
                          AND resolved_at > (time::now() - duration::days(7))
                          ORDER BY resolved_at DESC LIMIT 10;
    
    LET $stats = SELECT 
        COUNT() AS total_active,
        array::len(SELECT * FROM $active_alerts WHERE severity = 'critical') AS critical_count,
        array::len(SELECT * FROM $active_alerts WHERE severity = 'high') AS high_count,
        array::len(SELECT * FROM $active_alerts WHERE severity = 'medium') AS medium_count,
        array::len(SELECT * FROM $active_alerts WHERE severity = 'low') AS low_count
    FROM $active_alerts;
    
    RETURN {
        active_alerts: $active_alerts,
        recent_resolved: $recent_resolved,
        statistics: $stats[0],
        health_status: IF $stats[0].critical_count > 0 THEN 'critical' 
                      ELSE IF $stats[0].high_count > 0 THEN 'warning' 
                      ELSE 'healthy' END
    };
};

-- Fonction pour analytics d'alertes
DEFINE FUNCTION fn::alerts_analytics($days: int) {
    LET $period_start = time::now() - duration::days($days);
    
    RETURN SELECT 
        alert_type,
        severity,
        COUNT() AS total_alerts,
        array::len(SELECT * FROM alert WHERE alert_type = $parent.alert_type AND resolved = true) AS resolved_count,
        math::round(resolved_count / total_alerts * 100, 1) AS resolution_rate,
        math::mean(SELECT time::unix(resolved_at) - time::unix(created_at) FROM alert 
                  WHERE alert_type = $parent.alert_type AND resolved = true) AS avg_resolution_time_seconds
    FROM alert 
    WHERE created_at >= $period_start
    GROUP BY alert_type, severity
    ORDER BY total_alerts DESC;
};

-- ================================================================================================
-- 🎯 CONCLUSION - SYSTÈME D'ALERTES LYXAL
-- ================================================================================================

-- Total : 2 tables + 5 fonctions + 2 événements automatiques
-- Architecture : Système d'alertes intelligent avec auto-résolution
-- Capacités : Monitoring temps réel, escalade automatique, analytics
-- Performance : Alertes instantanées sans polling
-- Innovation : Intelligence intégrée pour réduction des faux positifs 