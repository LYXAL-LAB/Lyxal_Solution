-- Définition de la table

DEFINE TABLE IF NOT EXISTS bridge_parameter_locations 
    SCHEMAFULL
    TYPE NORMAL
    PERMISSIONS NONE
    COMMENT "Emplacements autorisés pour les paramètres API (Query, Header, Path, etc.)";

-- Définition des champs de la table

DEFINE FIELD IF NOT EXISTS identity ON TABLE bridge_parameter_locations 
    TYPE object 
    DEFAULT {}
    COMMENT"";

    DEFINE FIELD IF NOT EXISTS identity.name ON TABLE bridge_parameter_locations 
        TYPE string
        COMMENT"Nom du parametre ex : query, header"; 

DEFINE FIELD IF NOT EXISTS affichage ON TABLE bridge_parameter_locations 
    TYPE object 
    DEFAULT {}
    COMMENT"Paramètres d\affichage";

    DEFINE FIELD IF NOT EXISTS affichage.display_name ON TABLE bridge_parameter_locations 
        TYPE string
        COMMENT"Nom d'Affichage du parametre ex : URL Query, HTTP Header";

DEFINE FIELD IF NOT EXISTS status ON TABLE bridge_parameter_locations 
    TYPE object 
    DEFAULT {}
    COMMENT"Paramètres de Status";
        
    DEFINE FIELD IF NOT EXISTS status.status ON TABLE bridge_parameter_locations 
        TYPE record(bridge_status) 
        DEFAULT bridge_status:active
        COMMENT"Status du parametre";

-- Définition des index de la table

DEFINE INDEX IF NOT EXISTS loc_name_idx ON TABLE bridge_parameter_locations 
    FIELDS identity.name 
    UNIQUE
    COMMENT"Index sur le nom du parametre";