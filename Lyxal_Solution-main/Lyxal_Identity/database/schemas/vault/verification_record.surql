-- ============================================================
-- TABLE: verification_record (PREUVES DE VÉRIFICATION)
-- Namespace: NS_IDENTITY_{UUID} (Vault Privé)
-- ============================================================

DEFINE IF NOT EXISTS TABLE verification_record TYPE NORMAL SCHEMAFULL
COMMENT "Historique des vérifications réussies (Email/Phone)"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS identifier ON TABLE verification_record 
    TYPE string 
    COMMENT "L'identifiant vérifié (email ou téléphone)";

DEFINE FIELD IF NOT EXISTS type ON TABLE verification_record 
    TYPE string 
    ASSERT $value INSIDE ['email', 'sms', 'whatsapp']
    COMMENT "Type de vérification";

DEFINE FIELD IF NOT EXISTS verified_at ON TABLE verification_record 
    TYPE datetime 
    DEFAULT time::now()
    READONLY
    COMMENT "Date de la vérification";

DEFINE FIELD IF NOT EXISTS method ON TABLE verification_record 
    TYPE string 
    DEFAULT 'code'
    COMMENT "Méthode utilisée (code, link, admin)";
