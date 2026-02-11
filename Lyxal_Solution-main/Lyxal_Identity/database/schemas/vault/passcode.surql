-- ============================================================
-- TABLE: passcode (CODES OTP)
-- Namespace: NS_IDENTITY_{UUID} (Vault Privé)
-- ============================================================

DEFINE IF NOT EXISTS TABLE passcode TYPE NORMAL SCHEMAFULL
COMMENT "Codes à usage unique pour vérification (Email/SMS)"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS code ON TABLE passcode 
    TYPE string 
    COMMENT "Code haché (Bcrypt/Argon2) ou brut selon politique";

DEFINE FIELD IF NOT EXISTS type ON TABLE passcode 
    TYPE string 
    ASSERT $value INSIDE ['email', 'sms', 'whatsapp']
    COMMENT "Canal de transmission";

DEFINE FIELD IF NOT EXISTS identifier ON TABLE passcode 
    TYPE string 
    COMMENT "La cible (email ou téléphone)";

DEFINE FIELD IF NOT EXISTS attempts ON TABLE passcode 
    TYPE int 
    DEFAULT 0
    COMMENT "Nombre de tentatives échouées";

DEFINE FIELD IF NOT EXISTS expires_at ON TABLE passcode 
    TYPE datetime 
    COMMENT "Date d'expiration du code";

DEFINE FIELD IF NOT EXISTS created_at ON TABLE passcode 
    TYPE datetime 
    DEFAULT time::now()
    READONLY;
