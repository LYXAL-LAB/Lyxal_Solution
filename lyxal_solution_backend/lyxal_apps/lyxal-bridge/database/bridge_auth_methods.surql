---
-- Table de référence des méthodes d'authentification supportées par le Bridge
--

DEFINE TABLE IF NOT EXISTS bridge_auth_methods 
    SCHEMAFULL
    TYPE NORMAL
    COMMENT "Table de référence des méthodes d'authentification supportées par le Bridge"
    PERMISSIONS NONE;

---- Fields de la table ----

    DEFINE FIELD IF NOT EXISTS identity ON TABLE bridge_auth_methods 
        TYPE object
        DEFAULT {}
        COMMENT "Identité de la méthode";

        DEFINE FIELD IF NOT EXISTS identity.name ON TABLE bridge_auth_methods 
            TYPE string
            COMMENT "Nom interne (ex: api_key, oauth2, basic, bearer)";

    DEFINE FIELD IF NOT EXISTS affichage ON TABLE bridge_auth_methods 
        TYPE object
        DEFAULT {}
        COMMENT "Affichage de la méthode";

        DEFINE FIELD IF NOT EXISTS affichage.display_name ON TABLE bridge_auth_methods 
            TYPE string
            COMMENT "Nom public (ex: 'Clé API', 'OAuth 2.0')";

    DEFINE FIELD IF NOT EXISTS status ON TABLE bridge_auth_methods 
        TYPE object
        DEFAULT {}
        COMMENT "Status de la methode auth";

        DEFINE FIELD IF NOT EXISTS status.status ON TABLE bridge_auth_methods 
            TYPE record<bridge_status>
            DEFAULT bridge_status:active
            COMMENT "Status de la methode auth";

        DEFINE FIELD IF NOT EXISTS status.etag ON TABLE bridge_auth_methods 
            TYPE uuid
            DEFAULT uuid::rand()
            COMMENT "Etag de la methode auth";

        DEFINE FIELD IF NOT EXISTS status.version ON TABLE bridge_auth_methods 
            TYPE string
            DEFAULT "1.0.0"
            COMMENT "Version de la methode auth";

    DEFINE FIELD IF NOT EXISTS timestamp ON TABLE bridge_auth_methods 
        TYPE object
        DEFAULT {}
        COMMENT "Timestamp de la méthode";

        DEFINE FIELD IF NOT EXISTS timestamp.created_at ON TABLE bridge_auth_methods 
            TYPE datetime
            READONLY
            DEFAULT time::now();

        DEFINE FIELD IF NOT EXISTS timestamp.updated_at ON TABLE bridge_auth_methods 
            TYPE datetime
            READONLY
            DEFAULT ALWAYS time::now()
            COMMENT "Date de mise à jour du provider";

---- Indexes de la table ----

    DEFINE INDEX IF NOT EXISTS method_name_idx ON TABLE bridge_auth_methods 
        FIELDS identity.name
        UNIQUE
        COMMENT "Index sur le nom de la méthode auth";