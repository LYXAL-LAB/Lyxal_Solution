---- Table des statuts des utilisateurs ----

DEFINE TABLE IF NOT EXISTS user_status 
    SCHEMAFULL
    TYPE NORMAL
    COMMENT "Table des statuts des utilisateurs";

---- Fields de la table ----

DEFINE FIELD IF NOT EXISTS name ON TABLE user_status
    TYPE string
    COMMENT "Nom du statut";

DEFINE FIELD IF NOT EXISTS description ON TABLE user_status
    TYPE string
    COMMENT "Description du statut";

DEFINE FIELD IF NOT EXISTS is_enabled ON TABLE user_status
    TYPE bool
    DEFAULT true
    COMMENT "Indique si le statut est actif";

---- Indexes de la table ----

DEFINE INDEX IF NOT EXISTS idx_user_status_name ON TABLE user_status
    FIELDS name
    UNIQUE
    COMMENT "Index unique sur le nom";

---- Valeurs des seeds ----
CREATE user_status:active CONTENT {
	name: 'active',
    description: 'Active',
    is_enabled: true,
};

CREATE user_status:inactive CONTENT {
	name: 'inactive',
    description: 'Inactive',
    is_enabled: true,
};

CREATE user_status:suspended CONTENT {
	name: 'suspended',
    description: 'Suspended',
    is_enabled: true,
};

CREATE user_status:banned CONTENT {
	name: 'banned',
    description: 'Banned',
    is_enabled: true,
};

CREATE user_status:locked CONTENT {
	name: 'locked',
    description: 'Locked',
    is_enabled: true,
};

