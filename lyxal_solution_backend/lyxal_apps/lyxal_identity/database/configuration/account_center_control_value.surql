---- Table des valeur account center control ----

DEFINE TABLE IF NOT EXISTS account_center_control_value
    SCHEMAFULL
    TYPE NORMAL
    PERMISSIONS NONE
    COMMENT "Account center control value";

---- Fields de la table ----

DEFINE FIELD IF NOT EXISTS name ON TABLE account_center_control_value 
    TYPE string 
    COMMENT "Nom de valeur";

---- Index de la table ----

DEFINE INDEX idx_name ON TABLE account_center_control_value 
    FIELDS name 
    UNIQUE
    COMMENT "Index unique sur le nom";

---- Valeurs des seeds ----
CREATE account_center_control_value:Edit CONTENT {
	name: 'Edit',
};

CREATE account_center_control_value:ReadOnly CONTENT {
	name: 'Read Only',
};

CREATE account_center_control_value:Off CONTENT {
	name: 'Off',
};