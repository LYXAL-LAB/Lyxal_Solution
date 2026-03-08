-- Table captcha
DEFINE TABLE IF NOT EXISTS captcha 
    SCHEMAFULL
    TYPE NORMAL
    COMMENT "Table des configurations de CAPTCHA";

---- Fields ----

DEFINE FIELD IF NOT EXISTS lyxal_identity ON TABLE captcha 
    TYPE record(lyxal_identity)
    REFERENCE ON DELETE CASCADE
    COMMENT "Application lyxal_identity";

-- Configuration --

DEFINE FIELD IF NOT EXISTS config ON TABLE captcha 
    TYPE object
    DEFAULT {}
    COMMENT "Configuration";

    DEFINE FIELD IF NOT EXISTS config.sitekey ON TABLE captcha 
        TYPE string
        COMMENT "Site key";

    DEFINE FIELD IF NOT EXISTS config.name ON TABLE captcha 
        TYPE string
        COMMENT "Name";

    DEFINE FIELD IF NOT EXISTS config.duration ON TABLE captcha 
        TYPE numbers
        DEFAULT 30
        COMMENT "Duration en minutes";

-- Statuts --

DEFINE FIELD IF NOT EXISTS status ON TABLE captcha 
    TYPE object
    DEFAULT {}
    COMMENT "Statut";

    DEFINE FIELD IF NOT EXISTS status.is_enabled ON TABLE captcha 
        TYPE bool
        DEFAULT false
        COMMENT "Is enabled";

-- level --

DEFINE FIELD IF NOT EXISTS level ON TABLE captcha 
    TYPE array<object>
    DEFAULT []
    COMMENT "Level";

    DEFINE FIELD IF NOT EXISTS level.difficulty_factor ON TABLE captcha 
        TYPE numbers
        DEFAULT 1
        COMMENT "facteur de difficulté";

    DEFINE FIELD IF NOT EXISTS level.visitor_threshold ON TABLE captcha 
        TYPE numbers
        DEFAULT 1
        COMMENT "Nombre minimum de visiteurs";

-- Timestamp --

DEFINE FIELD IF NOT EXISTS timestamp ON TABLE captcha 
    TYPE object
    DEFAULT {}
    COMMENT "Timestamp";

    DEFINE FIELD timestamp.created_at ON TABLE captcha 
        TYPE datetime 
        DEFAULT time::now()
        READONLY
        COMMENT "Date de creation du Captcha";

    DEFINE FIELD timestamp.updated_at ON TABLE captcha 
        TYPE datetime 
        VALUE time::now()
        READONLY
        COMMENT "Date de modification du Captcha";

-- Indexes --

DEFINE INDEX sitekey_idx ON TABLE captcha 
    FIELDS config.sitekey 
    UNIQUE 
    COMMENT "Index unique sur le sitekey";

-- Table pour stocker les clés privées/publiques de l'émetteur Privacy Pass (Lyxal)
DEFINE TABLE IF NOT EXISTS privacy_pass_keys SCHEMAFULL;
DEFINE FIELD IF NOT EXISTS public_key ON TABLE privacy_pass_keys TYPE string;
DEFINE FIELD IF NOT EXISTS private_key ON TABLE privacy_pass_keys TYPE string; -- Chiffrée
DEFINE FIELD IF NOT EXISTS rotation_date ON TABLE privacy_pass_keys TYPE datetime;

-- Table pour stocker les signatures déjà échangées (pour empêcher le "double-spend" d'un token)
DEFINE TABLE IF NOT EXISTS privacy_pass_spent_tokens SCHEMAFULL;
DEFINE FIELD IF NOT EXISTS signature_hash ON TABLE privacy_pass_spent_tokens TYPE string;
DEFINE INDEX spent_token_idx ON TABLE privacy_pass_spent_tokens FIELDS signature_hash UNIQUE;

