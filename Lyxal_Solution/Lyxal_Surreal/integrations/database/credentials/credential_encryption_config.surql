-- =============================================================================================
-- |
-- | Fichier : credential_encryption_config.surql
-- | Module : integrations > database > credentials
-- | Description : Configuration du chiffrement des credentials
-- |
-- | Cette table stocke la configuration de chiffrement pour les credentials.
-- | Similaire à n8n, tout le chiffrement est géré directement dans SurrealDB.
-- |
-- =============================================================================================

DEFINE TABLE IF NOT EXISTS credential_encryption_config TYPE NORMAL SCHEMAFULL
COMMENT 'Configuration du chiffrement des credentials (clé principale, algorithme, etc.)'
PERMISSIONS
    FOR SELECT WHERE $auth.role IN ["admin", "system"]
    FOR CREATE, UPDATE, DELETE WHERE $auth.role IN ["admin", "system"];

DEFINE FIELD IF NOT EXISTS is_active ON credential_encryption_config
    TYPE bool
    DEFAULT true
    COMMENT 'Indique si cette configuration est active.';

DEFINE FIELD IF NOT EXISTS algorithm ON credential_encryption_config
    TYPE string
    DEFAULT 'aes256'
    ASSERT $value IN ['aes256', 'aes128']
    COMMENT 'Algorithme de chiffrement utilisé (aes256 ou aes128).';

DEFINE FIELD IF NOT EXISTS encryption_key ON credential_encryption_config
    TYPE string
    ASSERT $value != NONE AND string::len($value) >= 32
    COMMENT 'Clé de chiffrement principale (minimum 32 caractères). DOIT être stockée de manière sécurisée.';

DEFINE FIELD IF NOT EXISTS key_version ON credential_encryption_config
    TYPE int
    DEFAULT 1
    COMMENT 'Version de la clé pour permettre la rotation.';

DEFINE FIELD IF NOT EXISTS created_at ON credential_encryption_config
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT 'Date de création de la configuration.';

DEFINE FIELD IF NOT EXISTS updated_at ON credential_encryption_config
    TYPE datetime
    DEFAULT ALWAYS time::now()
    READONLY
    COMMENT 'Date de dernière mise à jour.';

DEFINE INDEX IF NOT EXISTS credential_encryption_config_active_idx ON credential_encryption_config FIELDS is_active
    COMMENT 'Récupération rapide de la configuration active.';

-- =============================================================================================
-- FIN DU FICHIER credential_encryption_config.surql
-- =============================================================================================

