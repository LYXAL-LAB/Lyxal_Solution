---- Table proxy_ingress_status : Status des points d'entrée public ----

DEFINE TABLE IF NOT EXISTS proxy_ingress_status
    SCHEMAFULL
    TYPE NORMAL
    COMMENT "Status des points d'entrée public";

---- Fields ----

-- Identity --

DEFINE FIELD IF NOT EXISTS identity ON TABLE proxy_ingress_status
    TYPE object
    DEFAULT {}
    COMMENT "Identité du status";

    DEFINE FIELD IF NOT EXISTS identity.name ON TABLE proxy_ingress_status
        TYPE string
        COMMENT "Nom du status";

    DEFINE FIELD IF NOT EXISTS identity.description ON TABLE proxy_ingress_status
        TYPE string
        COMMENT "Description du status";   

-- Status --

DEFINE FIELD IF NOT EXISTS status ON TABLE proxy_ingress_status
    TYPE object
    DEFAULT {}
    COMMENT "Status du point d\entrée ";

    DEFINE FIELD IF NOT EXISTS status.enabled ON TABLE proxy_ingress_status
        TYPE boolean
        DEFAULT true
        COMMENT "Etat du point d\entrée";

---- Indexes ----

DEFINE INDEX IF NOT EXISTS idx_status ON TABLE proxy_ingress_status 
    FIELDS status.enabled
    COMMENT "Index de performance pour des dashboards rapides";

DEFINE INDEX IF NOT EXISTS idx_identity ON TABLE proxy_ingress_status 
    FIELDS identity.name
    UNIQUE
    COMMENT "Index de performance pour des dashboards rapides";

---- Valeurs par défaut à créer ----

CREATE proxy_ingress_status:active CONTENT 
{
     identity.name = "active", 
     identity.description = "Point d'entrée actif", 
     status.enabled = true 
};

CREATE proxy_ingress_status:maintenance CONTENT 
{
     identity.name = "maintenance", 
     identity.description = "Point d'entrée en maintenance", 
     status.enabled = false 
};

CREATE proxy_ingress_status:disabled CONTENT 
{
     identity.name = "disabled", 
     identity.description = "Point d'entrée désactivé", 
     status.enabled = false 
};