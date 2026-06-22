---- Table proxy_metrics : L'Observation, Données Time-Series et statistiques sur le trafic. ----

DEFINE TABLE IF NOT EXISTS proxy_metrics
    SCHEMAFULL
    TYPE NORMAL
    COMMENT "Métriques de trafic et santé à des fins d'observation et d'analyse IA";

---- Fields ----

-- Application --

DEFINE FIELD IF NOT EXISTS application ON TABLE proxy_metrics 
    TYPE object
    DEFAULT {}
    COMMENT "Application propriétaire";

    DEFINE FIELD IF NOT EXISTS application.lyxal_proxy ON TABLE proxy_metrics 
        TYPE record<lyxal_proxy>
        REFERENCE ON DELETE CASCADE
        COMMENT "Application lyxal_proxy propriétaire des métriques";

-- Target (La ressource observée) --

DEFINE FIELD IF NOT EXISTS target ON TABLE proxy_metrics
    TYPE object
    DEFAULT {}
    COMMENT "La ressource mesurée (soit un domaine d'entrée, soit un cluster global)";

    -- Dans Lyxal, on peut stocker un record dynamique qui match plusieurs types de tables (le polymorphisme !)
    DEFINE FIELD IF NOT EXISTS target.target_id ON TABLE proxy_metrics
        TYPE record<proxy_ingress | proxy_cluster>
        REFERENCE ON DELETE CASCADE
        COMMENT "ID du point d'entrée ou du cluster observé";

-- Telemetry --

DEFINE FIELD IF NOT EXISTS telemetry ON TABLE proxy_metrics
    TYPE object
    DEFAULT {}
    COMMENT "Données statistiques et compteurs réels";

    DEFINE FIELD IF NOT EXISTS telemetry.request_count ON TABLE proxy_metrics
        TYPE number
        DEFAULT 0
        COMMENT "Nombre total de requêtes HTTP/HTTPS traitées sur la période";

    DEFINE FIELD IF NOT EXISTS telemetry.error_rate ON TABLE proxy_metrics
        TYPE number
        DEFAULT 0.0
        COMMENT "Pourcentage d'erreurs (codes 4xx, 5xx) générées par la cible";

    DEFINE FIELD IF NOT EXISTS telemetry.latency_p99 ON TABLE proxy_metrics
        TYPE duration
        DEFAULT 0s
        COMMENT "Latence P99 (99% des requêtes sont servies plus rapidement que cette durée)";

-- Timestamp (Sert de clé temporelle pour le Time-Series) --

DEFINE FIELD IF NOT EXISTS timestamp ON TABLE proxy_metrics 
    TYPE object
    DEFAULT {}
    COMMENT "Référentiels temporels";

    DEFINE FIELD timestamp.last_update ON TABLE proxy_metrics 
        TYPE datetime 
        DEFAULT time::now()
        COMMENT "Date formelle de collecte de la métrique par le Proxy Daemon";

---- Indexes ----

-- Index de performance pour la gestion multi-tenant --
DEFINE INDEX idx_application ON TABLE proxy_metrics 
    FIELDS application.lyxal_proxy
    COMMENT "Index de performance pour la gestion multi-tenant et l'isolation des données";

-- Index pour accélérer la recherche des métriques par ressource pour un tenant donné --
DEFINE INDEX idx_metrics_target ON TABLE proxy_metrics 
    FIELDS target.target_id, application.lyxal_proxy
    COMMENT "Indexation primaire pour interroger les dashboards de monitoring d'un tenant";

-- Index temporel (Crucial pour de l'analyse Time-Series et purge des vieilles données) --
DEFINE INDEX idx_metrics_time ON TABLE proxy_metrics 
    FIELDS target.target_id, timestamp.last_update, application.lyxal_proxy
    COMMENT "Index composé cible+date+tenant pour ordonner et requêter les graphiques temporels (TSDB-like)";
