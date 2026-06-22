---- Table des statuts des providers ----

DEFINE TABLE IF NOT EXISTS bridge_status 
    SCHEMAFULL
    TYPE NORMAL
    COMMENT "Status du provider"
    PERMISSIONS NONE;

---- Fields de la table ----

    DEFINE FIELD IF NOT EXISTS name ON TABLE bridge_status 
        TYPE string
        COMMENT "Nom du status";

    DEFINE FIELD IF NOT EXISTS description ON TABLE bridge_status 
        TYPE string
        COMMENT "Description du status";

    DEFINE FIELD IF NOT EXISTS is_enabled ON TABLE bridge_status 
        TYPE boolean
        DEFAULT true
        COMMENT "Indique si le status est actif";

---- Indexes de la table ----

    DEFINE INDEX IF NOT EXISTS idx_bridge_status_name ON TABLE bridge_status 
        FIELDS name
        UNIQUE
        COMMENT "Index unique sur le nom";