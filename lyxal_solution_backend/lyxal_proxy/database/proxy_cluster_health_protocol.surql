---- Table proxy_cluster_health_protocol : Protocoles de Health Check ----

DEFINE TABLE IF NOT EXISTS proxy_cluster_health_protocol
    SCHEMAFULL
    TYPE NORMAL
    COMMENT "Protocoles pris en charge pour vérifier la santé des backends";

---- Fields ----

-- Identity --

DEFINE FIELD IF NOT EXISTS identity ON TABLE proxy_cluster_health_protocol
    TYPE object
    DEFAULT {}
    COMMENT "Identité du protocole";

    DEFINE FIELD IF NOT EXISTS identity.name ON TABLE proxy_cluster_health_protocol
        TYPE string
        COMMENT "Nom technique du protocole (ex: tcp, http, https)";

    DEFINE FIELD IF NOT EXISTS identity.description ON TABLE proxy_cluster_health_protocol
        TYPE string
        COMMENT "Description de la méthode de vérification";

-- Config Requirements --

DEFINE FIELD IF NOT EXISTS config_requirements ON TABLE proxy_cluster_health_protocol
    TYPE object
    DEFAULT {}
    COMMENT "Exigences de configuration pour ce protocole";

    DEFINE FIELD IF NOT EXISTS config_requirements.requires_path ON TABLE proxy_cluster_health_protocol
        TYPE boolean
        DEFAULT false
        COMMENT "Définit si ce protocole nécessite obligatoirement un chemin de test (ex: /healthz)";

-- Status --

DEFINE FIELD IF NOT EXISTS status ON TABLE proxy_cluster_health_protocol
    TYPE object
    DEFAULT {}
    COMMENT "Statut de prise en charge";

    DEFINE FIELD IF NOT EXISTS status.enabled ON TABLE proxy_cluster_health_protocol
        TYPE boolean
        DEFAULT true
        COMMENT "Définit si ce protocole de health check est supporté par le proxy";

---- Indexes ----

DEFINE INDEX IF NOT EXISTS idx_status ON TABLE proxy_cluster_health_protocol 
    FIELDS status.enabled
    COMMENT "Index de performance pour des dashboards rapides";

DEFINE INDEX IF NOT EXISTS idx_identity ON TABLE proxy_cluster_health_protocol 
    FIELDS identity.name
    UNIQUE
    COMMENT "Index de performance pour l'unicité du nom";

---- Valeurs par défaut à créer ----

CREATE proxy_cluster_health_protocol:tcp CONTENT 
{
     identity.name = "tcp", 
     identity.description = "Vérification simple de l'ouverture de port (Fastest)", 
     config_requirements.requires_path = false,
     status.enabled = true 
};

CREATE proxy_cluster_health_protocol:http CONTENT 
{
     identity.name = "http", 
     identity.description = "Requête HTTP GET classique sur un chemin", 
     config_requirements.requires_path = true,
     status.enabled = true 
};

CREATE proxy_cluster_health_protocol:https CONTENT 
{
     identity.name = "https", 
     identity.description = "Requête HTTP GET chiffrée SSL/TLS sur un chemin", 
     config_requirements.requires_path = true,
     status.enabled = true 
};
