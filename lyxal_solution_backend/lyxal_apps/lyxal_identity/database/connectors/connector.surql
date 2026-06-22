---- Table des connecteurs ----

DEFINE TABLE IF NOT EXISTS connector
    SCHEMAFULL
    TYPE NORMAL
    PERMISSIONS NONE
    COMMENT "Connector";

    DEFINE FIELD IF NOT EXISTS name ON TABLE connector
        TYPE string
        COMMENT "Nom du connecteur";

    DEFINE FIELD IF NOT EXISTS type ON TABLE connector
        TYPE string
        COMMENT "Type du connecteur";

    DEFINE FIELD IF NOT EXISTS enabled ON TABLE connector
        TYPE bool
        DEFAULT true
        COMMENT "Connecteur activé/désactivé";

    DEFINE FIELD IF NOT EXISTS icon ON TABLE connector
        TYPE string
        ASSERT $value.is_url()
        DEFAULT none
        COMMENT "url de l'icône du connecteur";

    DEFINE FIELD IF NOT EXISTS description ON TABLE connector
        TYPE string
        COMMENT "Description du connecteur";

    DEFINE FIELD IF NOT EXISTS configuration ON TABLE connector
        TYPE object FLEXIBLE
        DEFAULT {}
        COMMENT "Configuration du connecteur";

    DEFINE FIELD IF NOT EXISTS configuration.* ON TABLE connector
        TYPE string
        COMMENT "Configuration du connecteur";