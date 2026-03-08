-- Table users_roles (Relation)
DEFINE TABLE users_roles 
    SCHEMAFULL
    TYPE RELATION
    IN users
    OUT roles
    COMMENT "Table des rôles des utilisateurs";

---- Fields de la table ----

DEFINE FIELD IF NOT EXISTS lyxal_identity ON TABLE users_roles 
    TYPE record<lyxal_identity>
    REFERENCE ON DELETE CASCADE
    COMMENT "Application lyxal_identity";

DEFINE FIELD created_at ON TABLE users_roles 
    TYPE datetime 
    VALUE time::now()
    COMMENT "Date de création";

---- Indexes de la table ----

DEFINE INDEX idx_user_role ON TABLE users_roles 
    FIELDS in, out, lyxal_identity 
    UNIQUE
    COMMENT "Index unique sur l'utilisateur, le rôle et l'application";