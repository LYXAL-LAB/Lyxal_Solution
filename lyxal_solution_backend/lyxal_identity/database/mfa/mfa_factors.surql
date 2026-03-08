---- Table des valeur mfa factors ----

DEFINE TABLE IF NOT EXISTS mfa_factors
    SCHEMAFULL
    TYPE NORMAL
    PERMISSIONS NONE
    COMMENT "MFA factors";

---- Fields de la table ----

DEFINE FIELD IF NOT EXISTS name ON TABLE mfa_factors 
    TYPE string 
    COMMENT "Nom de valeur";

DEFINE FIELD IF NOT EXISTS description ON TABLE mfa_factors 
    TYPE string 
    COMMENT "Description de valeur";

DEFINE FIELD IF NOT EXISTS icon ON TABLE mfa_factors 
    TYPE string 
    COMMENT "Icone de valeur";

DEFINE FIELD IF NOT EXISTS is_enabled ON TABLE mfa_factors 
    TYPE bool 
    DEFAULT true
    COMMENT "Indique si le facteur MFA est activé";

---- Index de la table ----

DEFINE INDEX idx_name ON TABLE mfa_factors 
    FIELDS name 
    UNIQUE
    COMMENT "Index unique sur le nom";

---- Valeurs des seeds ----
CREATE mfa_factors:Totp CONTENT {
	name: 'Totp',
    description: 'Time-based One-Time Password',
    icon: 'lock',
    is_enabled: true,
};

CREATE mfa_factors:WebAuthn CONTENT {
	name: 'WebAuthn',
    description: 'Web Authentication',
    icon: 'fingerprint',
    is_enabled: true,
};

CREATE mfa_factors:BackupCode CONTENT {
	name: 'BackupCode',
    description: 'Backup Code',
    icon: 'lock',
    is_enabled: true,
};

CREATE mfa_factors:EmailVerificationCode CONTENT {
	name: 'EmailVerificationCode',
    description: 'Email Verification Code',
    icon: 'lock',
    is_enabled: true,
};

CREATE mfa_factors:PhoneVerificationCode CONTENT {
	name: 'PhoneVerificationCode',
    description: 'Phone Verification Code',
    icon: 'lock',
    is_enabled: true,
};