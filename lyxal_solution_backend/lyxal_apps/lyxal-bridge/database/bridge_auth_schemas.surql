DEFINE TABLE IF NOT EXISTS bridge_auth_schemas 
    SCHEMAFULL
    TYPE RELATION 
    IN bridge_providers
    OUT bridge_auth_methods
    PERMISSIONS NONE
    COMMENT "Schémas de configuration d'authentification par provider";


    DEFINE FIELD IF NOT EXISTS configuration ON TABLE bridge_auth_schemas 
        TYPE object
        DEFAULT {}
        COMMENT "Configuration dynamique du formulaire d'auth";

        DEFINE FIELD IF NOT EXISTS configuration.fields ON TABLE bridge_auth_schemas 
            TYPE array
            DEFAULT []
            COMMENT "Tableau d'objets JSON définissant les champs (name, label, type, required)";

        DEFINE FIELD IF NOT EXISTS configuration.is_default ON TABLE bridge_auth_schemas 
            TYPE boolean
            DEFAULT true
            COMMENT "Définit si c'est la méthode d'auth prioritaire pour ce provider";

    DEFINE FIELD IF NOT EXISTS status ON TABLE bridge_auth_schemas 
        TYPE object
        DEFAULT {}
        COMMENT "Status du schéma";

        DEFINE FIELD IF NOT EXISTS status.is_active ON TABLE bridge_auth_schemas 
            TYPE boolean
            DEFAULT true;

    DEFINE FIELD IF NOT EXISTS timestamp ON TABLE bridge_auth_schemas 
        TYPE object
        DEFAULT {}
        COMMENT "Timestamp du schéma";

        DEFINE FIELD IF NOT EXISTS timestamp.created_at ON TABLE bridge_auth_schemas 
            TYPE datetime
            READONLY
            DEFAULT time::now();

        DEFINE FIELD IF NOT EXISTS timestamp.updated_at ON TABLE bridge_auth_schemas 
            TYPE datetime
            READONLY
            DEFAULT ALWAYS time::now();

    -- Index pour retrouver rapidement les méthodes d'un provider spécifique
    DEFINE INDEX IF NOT EXISTS provider_auth_idx ON TABLE bridge_auth_schemas 
        FIELDS relations.provider_id;