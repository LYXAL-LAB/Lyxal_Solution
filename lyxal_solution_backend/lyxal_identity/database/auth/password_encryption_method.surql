---- Table de la methode utilisée pour le password ----

DEFINE TABLE IF NOT EXISTS password_encryption_method 
    SCHEMAFULL
    TYPE NORMAL
    COMMENT "Table de la methode utilisée pour le password";

---- Fields de la table ----

DEFINE FIELD IF NOT EXISTS name ON TABLE password_encryption_method
    TYPE string
    COMMENT "Nom de la methode";

DEFINE FIELD IF NOT EXISTS description ON TABLE password_encryption_method
    TYPE string
    COMMENT "Description de la methode";

DEFINE FIELD IF NOT EXISTS is_enabled ON TABLE password_encryption_method
    TYPE bool
    DEFAULT true
    COMMENT "Indique si la methode est active";

---- Indexes de la table ----

DEFINE INDEX IF NOT EXISTS idx_password_encryption_method_name ON TABLE password_encryption_method
    FIELDS name
    UNIQUE
    COMMENT "Index unique sur le nom";

---- Valeurs des seeds ----
CREATE password_encryption_method:Argon2i CONTENT {
	name: 'Argon2i',
    description: 'Argon2i',
    is_enabled: true,
};

CREATE password_encryption_method:Argon2id CONTENT {
	name: 'Argon2id',
    description: 'Argon2id',
    is_enabled: true,
};

CREATE password_encryption_method:Argon2d CONTENT {
	name: 'Argon2d',
    description: 'Argon2d',
    is_enabled: true,
};

CREATE password_encryption_method:SHA1 CONTENT {
	name: 'SHA1',
    description: 'SHA1',
    is_enabled: true,
};

CREATE password_encryption_method:SHA256 CONTENT {
	name: 'SHA256',
    description: 'SHA256',
    is_enabled: true,
};

CREATE password_encryption_method:MD5 CONTENT {
	name: 'MD5',
    description: 'MD5',
    is_enabled: true,
};

CREATE password_encryption_method:Bcrypt CONTENT {
	name: 'Bcrypt',
    description: 'Bcrypt',
    is_enabled: true,
};

CREATE password_encryption_method:Legacy CONTENT {
	name: 'Legacy',
    description: 'Legacy',
    is_enabled: true,
};