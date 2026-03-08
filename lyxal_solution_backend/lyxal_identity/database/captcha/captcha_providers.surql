-- Table captcha_providers
DEFINE TABLE IF NOT EXISTS captcha_providers 
    SCHEMAFULL
    TYPE NORMAL
    PERMISSIONS NONE
    COMMENT "Table des fournisseurs de CAPTCHA";

---- Fields ----

-- Identity --

DEFINE FIELD IF NOT EXISTS name ON TABLE captcha_providers 
    TYPE string
    ASSERT $value != '' AND $value != NONE
    COMMENT "Nom du Captcha";

DEFINE FIELD IF NOT EXISTS description ON TABLE captcha_providers 
    TYPE string
    ASSERT $value != '' AND $value != NONE
    COMMENT "Description du Captcha";

DEFINE FIELD IF NOT EXISTS config ON TABLE captcha_providers 
    TYPE object
    FLEXIBLE
    DEFAULT {}
    COMMENT "Configuration du Captcha";

-- Status --

DEFINE FIELD IF NOT EXISTS status ON TABLE captcha_providers 
    TYPE object
    DEFAULT {}
    COMMENT "Statut du fournisseur";

    DEFINE FIELD IF NOT EXISTS status.is_enabled ON TABLE captcha_providers 
        TYPE bool
        DEFAULT true
        COMMENT "Indique si le fournisseur est actif";

-- Timestamp --

DEFINE FIELD IF NOT EXISTS timestamp ON TABLE captcha_providers 
    TYPE object
    DEFAULT {}
    COMMENT "Timestamp";

    DEFINE FIELD timestamp.created_at ON TABLE captcha_providers 
        TYPE datetime 
        DEFAULT time::now()
        READONLY
        COMMENT "Date de creation du Captcha";

    DEFINE FIELD timestamp.updated_at ON TABLE captcha_providers 
        TYPE datetime 
        VALUE time::now()
        READONLY
        COMMENT "Date de modification du Captcha";

---- Indexes ----
                                                                         
DEFINE INDEX idx_captcha_id ON TABLE captcha_providers 
    FIELDS name 
    UNIQUE                                                                                                                                                      
    COMMENT "Index unique sur le nom";                                                                                                                                                                    