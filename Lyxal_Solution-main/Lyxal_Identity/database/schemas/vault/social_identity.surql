-- ============================================================
-- TABLE: social_identity (COMPTES LIÉS)
-- Namespace: NS_IDENTITY_{UUID} (Vault Privé)
-- ============================================================

DEFINE IF NOT EXISTS TABLE social_identity TYPE NORMAL SCHEMAFULL
COMMENT "Identités sociales liées (Google, GitHub, etc.)"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS provider ON TABLE social_identity 
    TYPE string 
    ASSERT $value INSIDE ['google', 'github', 'facebook', 'microsoft', 'apple', 'twitter']
    COMMENT "Fournisseur d'identité sociale";

DEFINE FIELD IF NOT EXISTS provider_user_id ON TABLE social_identity 
    TYPE string 
    COMMENT "ID de l'utilisateur chez le provider";

DEFINE FIELD IF NOT EXISTS email ON TABLE social_identity 
    TYPE option<string>
    COMMENT "Email récupéré du provider";

DEFINE FIELD IF NOT EXISTS profile_data ON TABLE social_identity 
    TYPE object
    DEFAULT {}
    COMMENT "Données du profil social (nom, avatar, etc.)";

DEFINE FIELD IF NOT EXISTS access_token ON TABLE social_identity 
    TYPE option<string>
    COMMENT "Token d'accès (chiffré si stockage activé)";

DEFINE FIELD IF NOT EXISTS refresh_token ON TABLE social_identity 
    TYPE option<string>
    COMMENT "Token de rafraîchissement (chiffré)";

DEFINE FIELD IF NOT EXISTS token_expires_at ON TABLE social_identity 
    TYPE option<datetime>
    COMMENT "Date d'expiration du token";

DEFINE FIELD IF NOT EXISTS created_at ON TABLE social_identity 
    TYPE datetime 
    DEFAULT time::now()
    READONLY;

DEFINE FIELD IF NOT EXISTS updated_at ON TABLE social_identity 
    TYPE datetime 
    DEFAULT ALWAYS time::now()
    READONLY;

-- INDEX

DEFINE INDEX IF NOT EXISTS idx_provider ON TABLE social_identity 
    FIELDS provider, provider_user_id UNIQUE
    COMMENT "Un utilisateur ne peut lier qu'une seule fois un compte provider";
