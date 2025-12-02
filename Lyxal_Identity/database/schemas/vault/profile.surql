-- ============================================================
-- TABLE: profile (PROFIL PUBLIC / OIDC)
-- Namespace: NS_IDENTITY_{UUID} (Vault Privé)
-- ============================================================

DEFINE IF NOT EXISTS TABLE profile TYPE NORMAL SCHEMAFULL
COMMENT "Profil utilisateur (Claims OIDC et données publiques)"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS OIDC STANDARD

DEFINE FIELD IF NOT EXISTS name ON TABLE profile 
    TYPE option<string>
    COMMENT "Nom complet d'affichage";

DEFINE FIELD IF NOT EXISTS given_name ON TABLE profile 
    TYPE option<string>
    COMMENT "Prénom";

DEFINE FIELD IF NOT EXISTS family_name ON TABLE profile 
    TYPE option<string>
    COMMENT "Nom de famille";

DEFINE FIELD IF NOT EXISTS middle_name ON TABLE profile 
    TYPE option<string>
    COMMENT "Deuxième prénom";

DEFINE FIELD IF NOT EXISTS nickname ON TABLE profile 
    TYPE option<string>
    COMMENT "Surnom";

DEFINE FIELD IF NOT EXISTS preferred_username ON TABLE profile 
    TYPE option<string>
    COMMENT "Nom d'utilisateur préféré";

DEFINE FIELD IF NOT EXISTS picture ON TABLE profile 
    TYPE option<string>
    ASSERT $value == NONE OR string::is::url($value)
    COMMENT "URL de l'avatar";

DEFINE FIELD IF NOT EXISTS website ON TABLE profile 
    TYPE option<string>
    ASSERT $value == NONE OR string::is::url($value)
    COMMENT "Site web personnel";

DEFINE FIELD IF NOT EXISTS gender ON TABLE profile 
    TYPE option<string>
    COMMENT "Genre";

DEFINE FIELD IF NOT EXISTS birthdate ON TABLE profile 
    TYPE option<string>
    COMMENT "Date de naissance (YYYY-MM-DD)";

DEFINE FIELD IF NOT EXISTS zoneinfo ON TABLE profile 
    TYPE option<string>
    DEFAULT 'Europe/Paris'
    COMMENT "Fuseau horaire";

DEFINE FIELD IF NOT EXISTS locale ON TABLE profile 
    TYPE option<string>
    DEFAULT 'fr-FR'
    COMMENT "Langue préférée";

-- CHAMPS ADDITIONNELS

DEFINE FIELD IF NOT EXISTS address ON TABLE profile 
    TYPE option<object>
    COMMENT "Adresse postale (OIDC format)";

DEFINE FIELD IF NOT EXISTS updated_at ON TABLE profile 
    TYPE datetime 
    DEFAULT ALWAYS time::now()
    READONLY;
