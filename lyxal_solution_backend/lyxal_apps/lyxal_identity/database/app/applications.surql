-- Table applications
-- La table de l'application ne contient qu'une seule application

DEFINE TABLE IF NOT EXISTS application TYPE SCHEMAFULL
COMMENT "table de l\'application";

DEFINE FIELD IF NOT EXISTS name ON TABLE applications 
TYPE string
COMMENT "Nom de l\'application";

DEFINE FIELD IF NOT EXISTS secret ON TABLE applications TYPE string;

DEFINE FIELD IF NOT EXISTS description ON TABLE applications 
TYPE option<string>
COMMENT "Description de l'\application";

DEFINE FIELD IF NOT EXISTS redirect_uris ON TABLE applications 
TYPE array<string> DEFAULT [];

DEFINE FIELD IF NOT EXISTS post_logout_redirect_uris ON TABLE applications TYPE array<string> 
DEFAULT [];

DEFINE FIELD IF NOT EXISTS sign_in_experiences ON TABLE applications 
    TYPE object FLEXIBLE
    COMMENT "Champs de sign_in_experiences";

    


DEFINE FIELD IF NOT EXISTS timestamps ON TABLE applications 
    TYPE object FLEXIBLE
    COMMENT "Champs de timestamps";

        DEFINE FIELD IF NOT EXISTS timestamps.created_at ON TABLE applications 
            READONLY
            VALUE time::now()
            COMMENT "Date de creéation de l\'application";

        DEFINE FIELD IF NOT EXISTS timestamps.updated_at ON TABLE applications 
            TYPE datetime
            READONLY 
            DEFAULT time::now()
            COMMENT "Date de modification de l'application";