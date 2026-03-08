---- Table des methodes d'identifiants de connexion ----

DEFINE TABLE IF NOT EXISTS sign_in_sign_up_identifier
    SCHEMAFULL
    TYPE NORMAL
    PERMISSIONS NONE
    COMMENT "Methode d'identifiant de connexion";

---- Fields de la table ----

DEFINE FIELD IF NOT EXISTS name ON TABLE sign_in_sign_up_identifier 
    TYPE string 
    COMMENT "Nom de la methode";

DEFINE FIELD IF NOT EXISTS connector ON TABLE sign_in_sign_up_identifier 
    TYPE record(connector) 
    COMMENT "Connecteur utilisé";

DEFINE FIELD IF NOT EXISTS enabled ON TABLE sign_in_sign_up_identifier 
    TYPE bool 
    DEFAULT true
    COMMENT "Methode activée/désactivée";

DEFINE FIELD IF NOT EXISTS icon ON TABLE sign_in_sign_up_identifier 
    TYPE string 
    ASSERT $value.is_url()
    DEFAULT none
    COMMENT "url de l'icône de la methode";

DEFINE FIELD IF NOT EXISTS description ON TABLE sign_in_sign_up_identifier 
    TYPE string 
    COMMENT "Description de la methode";

DEFINE FIELD IF NOT EXISTS configuration ON TABLE sign_in_sign_up_identifier 
    TYPE object FLEXIBLE 
    DEFAULT {}
    COMMENT "Configuration de la methode";

DEFINE FIELD IF NOT EXISTS configuration.* ON TABLE sign_in_sign_up_identifier 
    TYPE string 
    COMMENT "Configuration de la methode";