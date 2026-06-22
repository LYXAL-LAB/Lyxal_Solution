---- Table proxy_ingress : Les Frontends, Stocke les points d'entrée publics (domaines, ports, SSL). ----

DEFINE TABLE IF NOT EXISTS proxy_ingress
    SCHEMAFULL
    TYPE NORMAL
    COMMENT "Liste des points d'entrée public";

---- Fields ----


-- Application --

DEFINE FIELD IF NOT EXISTS application ON TABLE proxy_ingress 
    TYPE object
    DEFAULT {}
    COMMENT "Application de l\'utilisateur";

    DEFINE FIELD IF NOT EXISTS application.lyxal_proxy ON TABLE proxy_ingress 
        TYPE record<lyxal_proxy>
        REFERENCE ON DELETE CASCADE
        COMMENT "Application lyxal_proxy";

-- Configuration--

DEFINE FIELD IF NOT EXISTS configuration ON TABLE proxy_ingress
    TYPE object
    DEFAULT {}
    COMMENT "Configuration du point d'entrée ";

    DEFINE FIELD IF NOT EXISTS configuration.hostname ON TABLE proxy_ingress
        TYPE string
        ASSERT  string::is_domain($value)
        COMMENT "hotsname du point d\'entrée";

    DEFINE FIELD IF NOT EXISTS configuration.port ON TABLE proxy_ingress 
        TYPE numbers
        ASSERT $value > 0 AND $value < 65535
        COMMENT "Port du point d\'entrée";

    DEFINE FIELD IF NOT EXISTS configuration.cluster ON TABLE proxy_ingress
        TYPE record<proxy_cluster>
        REFERENCE ON DELETE REJECT
        COMMENT "Cluster auquel est le point d\'entrée";

-- Certificat ssl --

DEFINE FIELD IF NOT EXISTS certificat ON TABLE proxy_ingress
    TYPE object
    DEFAULT {}
    COMMENT "Certificat du point d'entrée ";

    DEFINE FIELD IF NOT EXISTS certificat.ssl_enable ON TABLE proxy_ingress 
        TYPE boolean
        DEFAULT true
        COMMENT "Active/Désactive ssl"; 

    DEFINE FIELD IF NOT EXISTS certificat.certificat_id ON TABLE proxy_ingress 
        TYPE option<record<proxy_certificate_ssl>>
        REFERENCE ON DELETE REJECT
        ASSERT $value != NONE OR certificat.ssl_enable == false
        COMMENT "Certificat ssl du point d\entrée"; 

-- Status --

DEFINE FIELD IF NOT EXISTS status ON TABLE proxy_ingress
    TYPE object
    DEFAULT {}
    COMMENT "Status du point d\entrée ";

    DEFINE FIELD IF NOT EXISTS status.status ON TABLE proxy_ingress
        TYPE record<proxy_ingress_status>
        REFERENCE ON DELETE REJECT
        COMMENT "Etat du point d\'entrée";   

-- Timestamp --

DEFINE FIELD IF NOT EXISTS timestamp ON TABLE proxy_ingress 
    TYPE object
    DEFAULT {}
    COMMENT "Metadonnées timestamp";

    DEFINE FIELD timestamp.created_at ON TABLE proxy_ingress 
        TYPE datetime 
        DEFAULT time::now()
        READONLY
        COMMENT "Date de creation du profil";

    DEFINE FIELD timestamp.updated_at ON TABLE proxy_ingress
        TYPE datetime 
        VALUE time::now()
        READONLY
        COMMENT "Date de modification du profil";

---- Indexes ----

-- Contrainte d'unicité stricte : Un domaine + Un port = Un seul enregistrement --
DEFINE INDEX unique_route ON TABLE proxy_ingress 
    FIELDS configuration.hostname, configuration.port
    UNIQUE
    COMMENT "Contrainte d'unicité stricte : Un domaine + Un port = Un seul enregistrement";

-- Index de performance pour le moteur de routage --
DEFINE INDEX idx_cluster ON TABLE proxy_ingress 
    FIELDS configuration.cluster
    COMMENT "Index de performance pour le moteur de routage";

-- Index de performance pour la gestion multi-tenant --
DEFINE INDEX idx_application ON TABLE proxy_ingress 
    FIELDS application.lyxal_proxy
    COMMENT "Index de performance pour la gestion multi-tenant";

-- Index sur le statut pour des dashboards rapides --
DEFINE INDEX idx_status ON TABLE proxy_ingress 
    FIELDS status.status
    COMMENT "Index de performance pour des dashboards rapides";