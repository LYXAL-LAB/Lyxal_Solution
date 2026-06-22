---- Table users (Identity central) ----

DEFINE TABLE IF NOT EXISTS users 
    SCHEMAFULL
    TYPE NORMAL
    COMMENT "Liste des utilisateurs";

---- Fields de la table ----

-- Identity --

DEFINE FIELD IF NOT EXISTS identity ON TABLE users 
    TYPE object
    DEFAULT {}
    COMMENT "Identité de l\'utilisateur";

    DEFINE FIELD IF NOT EXISTS identity.username ON TABLE users 
        TYPE string
        COMMENT "Identifiant de l\'utilisateur";

    DEFINE FIELD IF NOT EXISTS identity.name ON TABLE users 
        TYPE option<string>
        COMMENT "Nom de l\'utilisateur";

-- Application --

DEFINE FIELD IF NOT EXISTS application ON TABLE users 
    TYPE object
    DEFAULT {}
    COMMENT "Application de l\'utilisateur";

    DEFINE FIELD IF NOT EXISTS application.lyxal_identity ON TABLE users 
        TYPE record<lyxal_identity>
        REFERENCE ON DELETE CASCADE
        COMMENT "Application lyxal_identity";

    DEFINE FIELD IF NOT EXISTS application.application ON TABLE users 
        TYPE record<application>
        REFERENCE ON DELETE CASCADE
        COMMENT "Application via laquelle l\'utilisateur s\'est inscrit ou s\'est connecté pour la première fois";

-- Status --

DEFINE FIELD IF NOT EXISTS status ON TABLE users 
    TYPE object
    DEFAULT {}
    COMMENT "Statut de l\'utilisateur";

    DEFINE FIELD IF NOT EXISTS status.last_status ON TABLE users 
        TYPE record<user_status>
        REFERENCE ON DELETE REJECT
        COMMENT "Statut actuel de l\'utilisateur";

    DEFINE FIELD IF NOT EXISTS status.last_status_at ON TABLE users 
        TYPE datetime 
        VALUE time::now()
        READONLY
        COMMENT "Date de mise à jour du statut";
    
    DEFINE FIELD IF NOT EXISTS status.reason ON TABLE users 
        TYPE record<user_status_reason>
        REFERENCE ON DELETE REJECT
        COMMENT "Raison du statut";
    
    DEFINE FIELD IF NOT EXISTS status.reason_at ON TABLE users 
        TYPE datetime 
        VALUE time::now()
        READONLY
        COMMENT "Date de mise à jour de la raison";

-- Authentification --

DEFINE FIELD IF NOT EXISTS authentification ON TABLE users 
    TYPE object
    DEFAULT {}
    COMMENT "Authentification de l\'utilisateur";

    DEFINE FIELD IF NOT EXISTS authentification.primary_email ON TABLE users 
        TYPE option<string>
        COMMENT "Email principal pour l\'authentification";

    DEFINE FIELD IF NOT EXISTS authentification.primary_phone ON TABLE users 
        TYPE option<string>
        COMMENT "Téléphone principal pour l\'authentification";

    DEFINE FIELD IF NOT EXISTS authentification.is_email_verified ON TABLE users 
        TYPE bool
        DEFAULT false
        COMMENT "Email vérifié pour l\'authentification";

    DEFINE FIELD IF NOT EXISTS authentification.is_phone_verified ON TABLE users 
        TYPE bool
        DEFAULT false
        COMMENT "Téléphone vérifié pour l\'authentification";
    
    DEFINE FIELD IF NOT EXISTS authentification.password_hash ON TABLE users 
        TYPE string
        COMMENT "Mot de passe hash";

    DEFINE FIELD IF NOT EXISTS authentification.password_encryption_method ON TABLE users 
        TYPE record<password_encryption_method>
        REFERENCE ON DELETE REJECT
        COMMENT "Méthode de chiffrement du mot de passe";
    
-- Profile --

DEFINE FIELD IF NOT EXISTS profile ON TABLE users 
    TYPE object
    DEFAULT {}
    COMMENT "Profil de l'utilisateur";

    DEFINE FIELD profile.avatar ON TABLE users 
        TYPE option<string>
        ASSERT $value.is_url()
        COMMENT "Photo de l'avatar"

    DEFINE FIELD profile.familyName ON TABLE users 
        TYPE option<string>
        COMMENT "Nom de famille"

    DEFINE FIELD profile.givenName ON TABLE users 
        TYPE option<string>
        COMMENT "Prénom"

    DEFINE FIELD profile.middleName ON TABLE users 
        TYPE option<string>
        COMMENT "Deuxième prénom"

    DEFINE FIELD profile.nickname ON TABLE users 
        TYPE option<string>
        COMMENT "Surnom"

    DEFINE FIELD profile.preferredUsername ON TABLE users 
        TYPE option<string>
        COMMENT "Nom d'utilisateur préféré"

    DEFINE FIELD profile.profile ON TABLE users 
        TYPE option<string>
        COMMENT "Profil de l'utilisateur"

    DEFINE FIELD profile.website ON TABLE users 
        TYPE option<string>
        COMMENT "Site web"

    DEFINE FIELD profile.gender ON TABLE users 
        TYPE option<string>
        COMMENT "Genre"

    DEFINE FIELD profile.birthdate ON TABLE users 
        TYPE option<string>
        COMMENT "Date de naissance"

    DEFINE FIELD profile.zoneinfo ON TABLE users 
        TYPE option<string>
        COMMENT "Fuseau horaire"

    DEFINE FIELD profile.locale ON TABLE users 
        TYPE option<string>
        COMMENT "Langue"

    DEFINE FIELD profile.address ON TABLE users 
        TYPE object 
        DEFAULT {}
        COMMENT "Adresse"

        DEFINE FIELD profile.address.formatted ON TABLE users 
            TYPE option<string>
            COMMENT "Adresse formatée"

        DEFINE FIELD profile.address.streetAddress ON TABLE users 
            TYPE option<string>
            COMMENT "Adresse postale"

        DEFINE FIELD profile.address.locality ON TABLE users 
            TYPE option<string>
            COMMENT "Localité"

        DEFINE FIELD profile.address.region ON TABLE users 
            TYPE option<string>
            COMMENT "Région"

        DEFINE FIELD profile.address.postalCode ON TABLE users 
            TYPE option<string>
            COMMENT "Code postal"

        DEFINE FIELD profile.address.country ON TABLE users 
            TYPE option<string>
            COMMENT "Pays"

-- Identities Connector --

DEFINE FIELD IF NOT EXISTS identities_connectors ON TABLE users 
    TYPE array<object> 
    DEFAULT []
    COMMENT "Identités utilisateur des connecteurs sociales";
    
    DEFINE FIELD IF NOT EXISTS identities_connectors.*.connector ON TABLE users 
        TYPE record<connectors>
        COMMENT "Type du connecteur";
    
    DEFINE FIELD IF NOT EXISTS identities_connectors.*.userId ON TABLE users 
        TYPE string
        COMMENT "Identifiant de l'utilisateur";
    
    DEFINE FIELD IF NOT EXISTS identities_connectors.*.details ON TABLE users 
        TYPE object FLEXIBLE 
        DEFAULT {}
        COMMENT "Détails de l'utilisateur";

-- Multi Facteur Authentification --

DEFINE FIELD IF NOT EXISTS mfa_verifications ON TABLE users 
    TYPE array<object> 
    DEFAULT []
    COMMENT "Identités utilisateur des connecteurs sociales";
    
    DEFINE FIELD IF NOT EXISTS mfa_verifications.*.mfa_factor ON TABLE users 
        TYPE record<mfa_factors>
        COMMENT "Type du facteur de mfa";
    
    DEFINE FIELD IF NOT EXISTS mfa_verifications.*.details ON TABLE users 
        TYPE object FLEXIBLE 
        DEFAULT {}
        COMMENT "Détails de la verification";

-- Timestamp --

DEFINE FIELD IF NOT EXISTS timestamp ON TABLE users 
    TYPE object
    DEFAULT {}
    COMMENT "Metadonnées timestamp";

    DEFINE FIELD timestamp.created_at ON TABLE users 
        TYPE datetime 
        DEFAULT time::now()
        READONLY
        COMMENT "Date de creation du profil";

    DEFINE FIELD timestamp.updated_at ON TABLE users 
        TYPE datetime 
        VALUE time::now()
        READONLY
        COMMENT "Date de modification du profil";

    DEFINE FIELD timestamp.last_sign_in_at ON TABLE users 
        TYPE datetime
        COMMENT "Date de dernière connexion";

-- Security --

DEFINE FIELD IF NOT EXISTS security ON TABLE users 
    TYPE object
    DEFAULT {}
    COMMENT "Sécurité de l'utilisateur";

    DEFINE FIELD IF NOT EXISTS security.last_location ON TABLE users 
        TYPE option<point>
        ASSERT $value IS NONE OR geo::is_point($value)
        COMMENT "Dernières coordonnées GPS connues (Geo-velocity check)";

    DEFINE FIELD IF NOT EXISTS security.last_ip ON TABLE users 
        TYPE option<string>
        ASSERT $value IS NONE OR string::is_ip($value)
        COMMENT "Dernière adresse IP connue";

    DEFINE FIELD IF NOT EXISTS security.last_user_agent ON TABLE users 
        TYPE option<string>
        COMMENT "Dernier user agent connu";

    DEFINE FIELD IF NOT EXISTS security.known_countries ON TABLE users 
        TYPE array<object>
        DEFAULT []
        COMMENT "Dernier pays d'inscription";

        DEFINE FIELD IF NOT EXISTS security.known_countries.*.country ON TABLE users 
            TYPE string
            ASSERT $value != NONE
            COMMENT "Pays d'inscription";

        DEFINE FIELD IF NOT EXISTS security.known_countries.*.last_sign_in_at ON TABLE users 
            TYPE datetime
            ASSERT $value != NONE
            COMMENT "Date de dernière connexion";

-- Données personnalisées --

DEFINE FIELD IF NOT EXISTS custom_data ON TABLE users 
    TYPE object FLEXIBLE 
    DEFAULT {}
    COMMENT "Données personnalisées";

-- Configuration de Lyxal Identity --

DEFINE FIELD IF NOT EXISTS lyxal_identity_config ON TABLE users 
    TYPE object FLEXIBLE 
    DEFAULT {}
    COMMENT "Configuration de Lyxal Identity";

-- Indexes --

DEFINE INDEX IF NOT EXISTS idx_user_username ON TABLE users 
    FIELDS identity.username, application.lyxal_identity
    UNIQUE
    COMMENT "Index unique sur le username et l'application";

DEFINE INDEX IF NOT EXISTS idx_user_email ON TABLE users 
    FIELDS authentification.primary_email, application.lyxal_identity
    UNIQUE
    COMMENT "Index unique sur le primary_email et l'application";

DEFINE INDEX IF NOT EXISTS idx_user_phone ON TABLE users 
    FIELDS authentification.primary_phone, application.lyxal_identity
    UNIQUE
    COMMENT "Index unique sur le primary_phone et l'application";

DEFINE INDEX idx_user_mfa_id ON TABLE users 
    FIELDS mfa_verifications.*.mfa_id
    COMMENT "Permet de retrouver un utilisateur instantanément via sa clé Passkey ou son MFA ID";