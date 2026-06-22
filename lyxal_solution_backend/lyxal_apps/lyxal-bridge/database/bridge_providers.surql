---- Table des providers ----

DEFINE TABLE IF NOT EXISTS bridge_providers 
    SCHEMAFULL
    TYPE NORMAL
    COMMENT "Liste des providers services externes";

---- Fields de la table ----

    DEFINE FIELD IF NOT EXISTS identity ON TABLE bridge_providers 
        TYPE object
        DEFAULT {}
        COMMENT "Identité du provider";

        DEFINE FIELD IF NOT EXISTS identity.name ON TABLE bridge_providers 
            TYPE string
            COMMENT "Nom interne du provider";

         DEFINE FIELD IF NOT EXISTS identity.description ON TABLE bridge_providers 
            TYPE string
            COMMENT "Description du provider";       

    DEFINE FIELD IF NOT EXISTS affichage ON TABLE bridge_providers 
        TYPE object
        DEFAULT {}
        COMMENT "Affichage du provider";

        DEFINE FIELD IF NOT EXISTS affichage.display_name ON TABLE bridge_providers 
            TYPE string
            COMMENT "Nom d'affichage du provider";

        DEFINE FIELD IF NOT EXISTS affichage.icon_url_dark ON TABLE bridge_providers 
            TYPE string
            ASSERT string::is_url($value)
            COMMENT "URL de l'icône du provider en mode sombre";

        DEFINE FIELD IF NOT EXISTS affichage.icon_url_light ON TABLE bridge_providers 
            TYPE string
            ASSERT string::is_url($value)
            COMMENT "URL de l'icône du provider en mode clair";

    DEFINE FIELD IF NOT EXISTS configuration ON TABLE bridge_providers 
        TYPE object
        DEFAULT {}
        COMMENT "Configuration du provider";
        
        DEFINE FIELD IF NOT EXISTS configuration.category ON TABLE bridge_providers 
            TYPE string
            COMMENT "Catégorie du provider";

        DEFINE FIELD IF NOT EXISTS configuration.documentation_url ON TABLE bridge_providers 
            TYPE string
            COMMENT "URL de documentation du provider";

        DEFINE FIELD IF NOT EXISTS configuration.endpoint_base_url ON TABLE bridge_providers 
            TYPE string
            ASSERT string::is_url($value)
            COMMENT "URL racine de l'API (ex: https://api.airtable.com)";

    DEFINE FIELD IF NOT EXISTS status ON TABLE bridge_providers 
        TYPE object
        DEFAULT {}
        COMMENT "Status du provider";

        DEFINE FIELD IF NOT EXISTS status.status ON TABLE bridge_providers 
            TYPE record<bridge_status>
            DEFAULT bridge_status:active
            COMMENT "Status du provider";

        DEFINE FIELD IF NOT EXISTS status.etag ON TABLE bridge_providers 
            TYPE uuid
            DEFAULT uuid::rand()
            COMMENT "Etag du provider";

        DEFINE FIELD IF NOT EXISTS status.version ON TABLE bridge_providers 
            TYPE string
            DEFAULT "1.0.0"
            COMMENT "Version du provider";
        
    DEFINE FIELD IF NOT EXISTS timestamp ON TABLE bridge_providers 
        TYPE object
        DEFAULT {}
        COMMENT "Timestamp du provider";

        DEFINE FIELD IF NOT EXISTS timestamp.created_at ON TABLE bridge_providers 
            TYPE datetime
            READONLY
            DEFAULT time::now()
            COMMENT "Date de création du provider";

        DEFINE FIELD IF NOT EXISTS timestamp.updated_at ON TABLE bridge_providers 
            TYPE datetime
            READONLY
            DEFAULT ALWAYS time::now()
            COMMENT "Date de mise à jour du provider";

---- Indexes de la table ----

    DEFINE INDEX IF NOT EXISTS provider_name_idx ON TABLE bridge_providers 
        FIELDS identity.name 
        UNIQUE
        COMMENT "Index sur le nom du provider";