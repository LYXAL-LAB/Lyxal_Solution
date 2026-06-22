---- Table proxy_cluster : Le Routage, Définit comment le trafic est réparti vers les backends. ----

DEFINE TABLE IF NOT EXISTS proxy_cluster
    SCHEMAFULL
    TYPE NORMAL
    COMMENT "Configuration du routage et de la répartition de charge pour un groupe de backends";

---- Fields ----

-- Application --

DEFINE FIELD IF NOT EXISTS application ON TABLE proxy_cluster 
    TYPE object
    DEFAULT {}
    COMMENT "Application de l'utilisateur";

    DEFINE FIELD IF NOT EXISTS application.lyxal_proxy ON TABLE proxy_cluster 
        TYPE record<lyxal_proxy>
        REFERENCE ON DELETE CASCADE
        COMMENT "Application lyxal_proxy propriétaire du cluster";

-- Identity --

DEFINE FIELD IF NOT EXISTS identity ON TABLE proxy_cluster
    TYPE object
    DEFAULT {}
    COMMENT "Identité du cluster";

    DEFINE FIELD IF NOT EXISTS identity.name ON TABLE proxy_cluster
        TYPE string
        COMMENT "Nom ou ID unique du cluster";

-- Configuration --

DEFINE FIELD IF NOT EXISTS configuration ON TABLE proxy_cluster
    TYPE object
    DEFAULT {}
    COMMENT "Configuration du comportement de routage";

    DEFINE FIELD IF NOT EXISTS configuration.load_balancing ON TABLE proxy_cluster
        TYPE record<proxy_cluster_load_balancing>
        DEFAULT proxy_cluster_load_balancing:round_robin
        COMMENT "Algorithme de répartition de charge";

    DEFINE FIELD IF NOT EXISTS configuration.sticky_session ON TABLE proxy_cluster
        TYPE boolean
        DEFAULT false
        COMMENT "Si vrai, route les requêtes d'une même session vers le même backend";

-- Health Check --

DEFINE FIELD IF NOT EXISTS health_check ON TABLE proxy_cluster
    TYPE object
    DEFAULT {}
    COMMENT "Configuration de la vérification de santé des backends";

    DEFINE FIELD IF NOT EXISTS health_check.protocol ON TABLE proxy_cluster
        TYPE record<proxy_cluster_health_protocol>
        DEFAULT proxy_cluster_health_protocol:tcp
        COMMENT "Protocole utilisé pour vérifier la santé du backend";

    DEFINE FIELD IF NOT EXISTS health_check.path ON TABLE proxy_cluster
        TYPE option<string>
        ASSERT $value != NONE OR health_check.protocol.config_requirements.requires_path == false
        COMMENT "Chemin HTTP à interroger. Optionnel pour TCP, requis pour HTTP/HTTPS";

    DEFINE FIELD IF NOT EXISTS health_check.interval ON TABLE proxy_cluster
        TYPE duration
        DEFAULT 10s
        COMMENT "Intervalle entre chaque vérification de santé";

-- Timestamp --

DEFINE FIELD IF NOT EXISTS timestamp ON TABLE proxy_cluster 
    TYPE object
    DEFAULT {}
    COMMENT "Metadonnées horodatées";

    DEFINE FIELD timestamp.created_at ON TABLE proxy_cluster 
        TYPE datetime 
        DEFAULT time::now()
        READONLY
        COMMENT "Date de création du cluster";

    DEFINE FIELD timestamp.updated_at ON TABLE proxy_cluster
        TYPE datetime 
        VALUE time::now()
        READONLY
        COMMENT "Date de dernière modification du cluster";

---- Indexes ----

-- Contrainte d'unicité : Un nom de cluster doit être unique pour un tenant donné --
DEFINE INDEX idx_cluster_name ON TABLE proxy_cluster 
    FIELDS identity.name, application.lyxal_proxy
    UNIQUE
    COMMENT "Garantit que le nom du cluster est unique par tenant";

-- Index de performance pour la gestion multi-tenant --
DEFINE INDEX idx_application ON TABLE proxy_cluster 
    FIELDS application.lyxal_proxy
    COMMENT "Index de performance pour la gestion multi-tenant";
