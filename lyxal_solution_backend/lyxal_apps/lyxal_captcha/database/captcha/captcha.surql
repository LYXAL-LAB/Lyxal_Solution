-- Table captcha
-- Note : La table user locale est SUPPRIMÉE.
-- L'authentification passe par lyxal_identity:users (table centralisée).
-- Le champ `owner` pointe vers le user propriétaire dans lyxal_identity.

DEFINE TABLE IF NOT EXISTS captcha 
    SCHEMAFULL
    TYPE NORMAL
    COMMENT "Table des configurations de CAPTCHA";

---- Fields ----

DEFINE FIELD IF NOT EXISTS lyxal_identity ON TABLE captcha 
    TYPE record(lyxal_identity)
    REFERENCE ON DELETE CASCADE
    COMMENT "Application lyxal_identity à laquelle appartient ce captcha";

DEFINE FIELD IF NOT EXISTS owner ON TABLE captcha 
    TYPE record(users)
    REFERENCE ON DELETE CASCADE
    COMMENT "Propriétaire du captcha (utilisateur lyxal_identity:users)";

-- Configuration --

DEFINE FIELD IF NOT EXISTS config ON TABLE captcha 
    TYPE object
    DEFAULT {}
    COMMENT "Configuration du captcha";

    DEFINE FIELD IF NOT EXISTS config.sitekey ON TABLE captcha 
        TYPE string
        COMMENT "Clé publique du captcha (intégrée côté frontend)";

    DEFINE FIELD IF NOT EXISTS config.verification_secret ON TABLE captcha 
        TYPE string
        DEFAULT rand::string(50)
        COMMENT "Clé secrète pour la vérification côté serveur (POST /siteverify)";

    DEFINE FIELD IF NOT EXISTS config.name ON TABLE captcha 
        TYPE string
        COMMENT "Nom descriptif du captcha";

    DEFINE FIELD IF NOT EXISTS config.duration ON TABLE captcha 
        TYPE int
        DEFAULT 30
        COMMENT "Durée de validité du challenge PoW en secondes";

-- Statuts --

DEFINE FIELD IF NOT EXISTS status ON TABLE captcha 
    TYPE object
    DEFAULT {}
    COMMENT "Statut du captcha";

    DEFINE FIELD IF NOT EXISTS status.is_enabled ON TABLE captcha 
        TYPE bool
        DEFAULT false
        COMMENT "Captcha activé ou désactivé";

-- Levels (niveaux de difficulté PoW) --

DEFINE FIELD IF NOT EXISTS level ON TABLE captcha 
    TYPE array<object>
    DEFAULT []
    COMMENT "Niveaux de difficulté PoW (inline, ordonnés par difficulty_factor croissant)";

    DEFINE FIELD IF NOT EXISTS level[*].difficulty_factor ON TABLE captcha 
        TYPE int
        DEFAULT 1
        COMMENT "Facteur de difficulté SHA-256 (nombre de zéros en tête du hash)";

    DEFINE FIELD IF NOT EXISTS level[*].visitor_threshold ON TABLE captcha 
        TYPE int
        DEFAULT 1
        COMMENT "Seuil de visiteurs simultanés qui déclenche ce niveau";

-- Timestamp --

DEFINE FIELD IF NOT EXISTS timestamp ON TABLE captcha 
    TYPE object
    DEFAULT {}
    COMMENT "Métadonnées temporelles";

    DEFINE FIELD timestamp.created_at ON TABLE captcha 
        TYPE datetime 
        DEFAULT time::now()
        READONLY
        COMMENT "Date de création du captcha";

    DEFINE FIELD timestamp.updated_at ON TABLE captcha 
        TYPE datetime 
        VALUE time::now()
        READONLY
        COMMENT "Date de dernière modification";

-- Indexes --

DEFINE INDEX IF NOT EXISTS sitekey_idx ON TABLE captcha 
    FIELDS config.sitekey 
    UNIQUE 
    COMMENT "Index unique sur le sitekey";

DEFINE INDEX IF NOT EXISTS secret_idx ON TABLE captcha 
    FIELDS config.verification_secret 
    UNIQUE 
    COMMENT "Index unique sur le secret de vérification";

-- ════════════════════════════════════════════════════
-- Privacy Pass (Lyxal) — tables associées
-- ════════════════════════════════════════════════════

-- Clés privées/publiques de l'émetteur Privacy Pass
DEFINE TABLE IF NOT EXISTS privacy_pass_keys SCHEMAFULL;
DEFINE FIELD IF NOT EXISTS public_key ON TABLE privacy_pass_keys TYPE string;
DEFINE FIELD IF NOT EXISTS private_key ON TABLE privacy_pass_keys TYPE string; -- Chiffrée
DEFINE FIELD IF NOT EXISTS rotation_date ON TABLE privacy_pass_keys TYPE datetime;

-- Signatures déjà échangées (anti double-spend)
DEFINE TABLE IF NOT EXISTS privacy_pass_spent_tokens SCHEMAFULL;
DEFINE FIELD IF NOT EXISTS signature_hash ON TABLE privacy_pass_spent_tokens TYPE string;
DEFINE INDEX spent_token_idx ON TABLE privacy_pass_spent_tokens FIELDS signature_hash UNIQUE;

