-- Table users_sso_identities (Relation)
DEFINE TABLE IF NOT EXISTS users_sso_identities 
    SCHEMAFULL
    TYPE RELATION
    IN users
    OUT sso_connectors
    COMMENT "Table des identités SSO des utilisateurs";

---- Fields de la table ----

DEFINE FIELD IF NOT EXISTS lyxal_identity ON TABLE users_sso_identities 
    TYPE record<lyxal_identity>
    REFERENCE ON DELETE CASCADE                                                                                                                                                                                                                                                                   
    COMMENT "Application lyxal_identity";

DEFINE FIELD IF NOT EXISTS issuer ON TABLE users_sso_identities 
    TYPE string 
    ASSERT $value != NONE AND string::is::url($value) 
    COMMENT "Issuer de l'identité SSO";

DEFINE FIELD IF NOT EXISTS identity_id ON TABLE users_sso_identities 
    TYPE string                                                                                 
    ASSERT $value != NONE
    COMMENT "ID de l'identité SSO";

-- Détails -- 

DEFINE FIELD IF NOT EXISTS details ON TABLE users_sso_identities 
    TYPE object
    DEFAULT {}
    COMMENT "Détails de l'identité SSO";

    DEFINE FIELD IF NOT EXISTS details.id ON TABLE users_sso_identities 
        TYPE string
        ASSERT $value != NONE
        COMMENT "ID de l'identité SSO";

    DEFINE FIELD IF NOT EXISTS details.name ON TABLE users_sso_identities 
        TYPE string
        ASSERT $value != NONE
        COMMENT "Nom de l'identité SSO";

    DEFINE FIELD IF NOT EXISTS details.email ON TABLE users_sso_identities 
        TYPE string
        ASSERT $value != NONE AND string::is::email($value) 
        COMMENT "Email de l'identité SSO";
                                                                    
    DEFINE FIELD IF NOT EXISTS details.avatar ON TABLE users_sso_identities 
        TYPE string
        COMMENT "Avatar de l'identité SSO";

    DEFINE FIELD IF NOT EXISTS details.raw_data ON TABLE users_sso_identities 
        TYPE object
        FLEXIBLE
        DEFAULT {}
        COMMENT "Payload complet et non-modifié du fournisseur (pour audit)";

--Timestamp --

DEFINE FIELD IF NOT EXISTS timestamp ON TABLE users_sso_identities 
    TYPE object
    DEFAULT {}
    COMMENT "timestamps";

    DEFINE FIELD IF NOT EXISTS timestamp.created_at ON TABLE users_sso_identities 
        TYPE datetime 
        DEFAULT time::now()
        READONLY
        COMMENT "Date de création";

    DEFINE FIELD IF NOT EXISTS timestamp.updated_at ON TABLE users_sso_identities 
        TYPE datetime 
        VALUE time::now()
        READONLY
        COMMENT "Date de modification";

---- Indexes de la table ----

DEFINE INDEX IF NOT EXISTS idx_user_sso_identities ON TABLE users_sso_identities 
    FIELDS lyxal_identity, issuer, identity_id 
    UNIQUE
    COMMENT "Index unique sur l'utilisateur, l'émetteur et l'ID de l'identité";