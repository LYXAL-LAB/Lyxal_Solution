---- Table des méthodes de mot de passe oublié ----

DEFINE TABLE IF NOT EXISTS forgot_password_method
    SCHEMAFULL
    TYPE NORMAL
    PERMISSIONS NONE
    COMMENT "Methode mot de passe oublié";

---- Fields de la table ----

DEFINE FIELD IF NOT EXISTS name ON TABLE forgot_password_method 
    TYPE string 
    COMMENT "Nom de la méthode";

DEFINE FIELD IF NOT EXISTS connector ON TABLE forgot_password_method 
    TYPE record(connector) 
    COMMENT "Connecteur utilisé";

DEFINE FIELD IF NOT EXISTS enabled ON TABLE forgot_password_method 
    TYPE bool 
    DEFAULT true
    COMMENT "Méthode activée/désactivée";

DEFINE FIELD IF NOT EXISTS icon ON TABLE forgot_password_method 
    TYPE string 
    ASSERT $value.is_url()
    DEFAULT none
    COMMENT "url de l'icône de la méthode";

DEFINE FIELD IF NOT EXISTS description ON TABLE forgot_password_method 
    TYPE string 
    COMMENT "Description de la méthode";

DEFINE FIELD IF NOT EXISTS configuration ON TABLE forgot_password_method 
    TYPE object FLEXIBLE 
    DEFAULT {}
    COMMENT "Configuration de la méthode";

DEFINE FIELD IF NOT EXISTS configuration.* ON TABLE forgot_password_method 
    TYPE string 
    COMMENT "Configuration de la méthode";
