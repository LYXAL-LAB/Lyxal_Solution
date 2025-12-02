-- =================================================================================================
-- TEMPLATE: REFRESH TOKEN
-- Namespace: NS_IDENTITY_{UUID} / Database: MAIN
-- Ce schéma est appliqué dans le namespace privé de chaque identité.
-- =================================================================================================

DEFINE TABLE IF NOT EXISTS refreshtoken TYPE NORMAL SCHEMAFULL
    COMMENT 'Stocke les jetons de rafraîchissement actifs.'
    PERMISSIONS NONE; -- Sécurité maximale

    -- Sécurité : On ne stocke jamais le token en clair, mais son hash.
    DEFINE FIELD IF NOT EXISTS token_hash ON refreshtoken 
        TYPE string 
        COMMENT 'Hash du token (Argon2 ou SHA256).';

    -- Contexte lié (Table future)
    DEFINE FIELD IF NOT EXISTS environmentid ON refreshtoken 
        TYPE record<environment>
        COMMENT 'Lien vers l\'environnement (si applicable).';

    DEFINE FIELD IF NOT EXISTS device ON refreshtoken 
        TYPE string
        COMMENT 'Infos sur l\'appareil (User-Agent).';

    DEFINE FIELD IF NOT EXISTS expires_at ON refreshtoken 
        TYPE datetime
        COMMENT 'Date d\'expiration absolue.';
        
    DEFINE FIELD IF NOT EXISTS created_at ON refreshtoken 
        TYPE datetime DEFAULT time::now();

    -- Index unique sur le hash pour la recherche
    DEFINE INDEX IF NOT EXISTS idx_token_hash ON refreshtoken FIELDS token_hash UNIQUE;
