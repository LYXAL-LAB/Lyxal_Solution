-- ============================================================
-- TABLE: verification_token
-- Namespace: LYXAL_IDENTITY / Database: CORE
-- Description: Codes OTP pour validation email ou reset password.
-- ============================================================

DEFINE TABLE IF NOT EXISTS verification_token TYPE NORMAL SCHEMAFULL
    PERMISSIONS NONE;

-- CHAMPS
DEFINE FIELD IF NOT EXISTS identifier ON TABLE verification_token 
    TYPE string 
    COMMENT "Email ou Téléphone cible";

DEFINE FIELD IF NOT EXISTS code_hash ON TABLE verification_token 
    TYPE string 
    COMMENT "Hash du code OTP (Argon2 ou SHA256 pour comparaison rapide)";

DEFINE FIELD IF NOT EXISTS type ON TABLE verification_token 
    TYPE string 
    ASSERT $value INSIDE ['email_verification', 'password_reset', 'login_otp'];

DEFINE FIELD IF NOT EXISTS expires_at ON TABLE verification_token 
    TYPE datetime;

DEFINE FIELD IF NOT EXISTS created_at ON TABLE verification_token 
    TYPE datetime 
    DEFAULT time::now();

-- INDEX
DEFINE INDEX IF NOT EXISTS idx_identifier_type ON TABLE verification_token COLUMNS identifier, type;

