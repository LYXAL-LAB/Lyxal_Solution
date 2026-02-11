-- =================================================================================================
-- TEMPLATE: IDENTITY PASSWORD RESET
-- Namespace: NS_IDENTITY_{UUID} / Database: MAIN
-- Ce schéma est appliqué dans le namespace privé de chaque identité.
-- =================================================================================================

DEFINE TABLE IF NOT EXISTS pwreset TYPE NORMAL SCHEMAFULL
    COMMENT 'Stocke les tokens pour la réinitialisation des mots de passe.'
    PERMISSIONS NONE;

    DEFINE FIELD IF NOT EXISTS expires_at ON pwreset 
        TYPE datetime
        COMMENT 'Date d\'expiration absolue.';

    DEFINE FIELD IF NOT EXISTS token_hash ON pwreset 
        TYPE string
        COMMENT 'Hash du token (Argon2 ou SHA256).';

    DEFINE FIELD IF NOT EXISTS created_at ON pwreset 
        TYPE datetime DEFAULT time::now();

    -- Index unique sur le hash du token
    DEFINE INDEX IF NOT EXISTS idx_token_hash ON pwreset FIELDS token_hash UNIQUE;
