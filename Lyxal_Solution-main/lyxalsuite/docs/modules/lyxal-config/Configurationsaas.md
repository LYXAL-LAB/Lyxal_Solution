Datatable : Base

1. account  Compte principal (créé lors de l’inscription)
Représente l’entité propriétaire du SaaS (entreprise ou particulier).

DEFINE TABLE account SCHEMAFUL;

-- Identité
DEFINE FIELD id ON account TYPE string;
DEFINE FIELD name ON account TYPE string ASSERT $value != NONE;
DEFINE FIELD email ON account TYPE string ASSERT string::matches($value, "^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$");
DEFINE FIELD slug ON account TYPE string ASSERT $value != NONE;

-- Typologie
DEFINE FIELD accountType ON account TYPE record(account_type);
DEFINE FIELD legalForm ON account TYPE record(account_legal_form);

-- Localisation
DEFINE FIELD country ON account TYPE record(account_country);
DEFINE FIELD language ON account TYPE record(account_language);
DEFINE FIELD currency ON account TYPE record(account_currency);

-- Branding
DEFINE FIELD logoUrl ON account TYPE string;
DEFINE FIELD theme ON account TYPE string;
DEFINE FIELD primaryColor ON account TYPE string;
DEFINE FIELD secondaryColor ON account TYPE string;

-- Statut
DEFINE FIELD isWhiteLabel ON account TYPE bool DEFAULT false;
DEFINE FIELD isActive ON account TYPE bool DEFAULT true;
DEFINE FIELD archived ON account TYPE bool DEFAULT false;

-- Extra
DEFINE FIELD tags ON account TYPE array;
DEFINE FIELD metadata ON account TYPE object;

-- Traces
DEFINE FIELD createdAt ON account TYPE datetime DEFAULT time::now();
DEFINE FIELD updatedAt ON account TYPE datetime DEFAULT time::now();
DEFINE FIELD createdBy ON account TYPE string;
DEFINE FIELD updatedBy ON account TYPE string;

-- Index
DEFINE INDEX account_email_idx ON account FIELDS email UNIQUE;
DEFINE INDEX account_slug_idx ON account FIELDS slug UNIQUE;
DEFINE INDEX account_name_idx ON account FIELDS name;

2. user — Représente une personne (collaborateur) du SaaS

DEFINE TABLE user SCHEMAFUL;

-- Identité
DEFINE FIELD id ON user TYPE string;
DEFINE FIELD email ON user TYPE string ASSERT string::matches($value, "^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$");
DEFINE FIELD firstName ON user TYPE string;
DEFINE FIELD lastName ON user TYPE string;
DEFINE FIELD fullName ON user TYPE string;

-- Authentification (optionnel selon le système utilisé)
DEFINE FIELD provider ON user TYPE string;         -- ex: 'logto', 'google', 'github'
DEFINE FIELD externalId ON user TYPE string;       -- ID externe (Logto, Google...)
DEFINE FIELD passwordHash ON user TYPE string;     -- si géré en local

-- Contact
DEFINE FIELD phone ON user TYPE string;
DEFINE FIELD avatarUrl ON user TYPE string;

-- Statut
DEFINE FIELD isVerified ON user TYPE bool DEFAULT false;
DEFINE FIELD isActive ON user TYPE bool DEFAULT true;
DEFINE FIELD isAdmin ON user TYPE bool DEFAULT false; -- dans le contexte global

-- Traces
DEFINE FIELD createdAt ON user TYPE datetime DEFAULT time::now();
DEFINE FIELD updatedAt ON user TYPE datetime DEFAULT time::now();

-- Index
DEFINE INDEX user_email_idx ON user FIELDS email UNIQUE;
DEFINE INDEX user_external_idx ON user FIELDS externalId;

3. workspace — Environnement de travail multi-utilisateur

DEFINE TABLE workspace SCHEMAFUL;

-- Identification
DEFINE FIELD id ON workspace TYPE string;
DEFINE FIELD name ON workspace TYPE string ASSERT $value != NONE;
DEFINE FIELD slug ON workspace TYPE string ASSERT $value != NONE;

-- Relation
DEFINE FIELD account ON workspace TYPE record(account) ASSERT $value != NONE;

-- Statut
DEFINE FIELD isActive ON workspace TYPE bool DEFAULT true;
DEFINE FIELD isDefault ON workspace TYPE bool DEFAULT false;
DEFINE FIELD archived ON workspace TYPE bool DEFAULT false;

-- Branding local (si surchargé)
DEFINE FIELD theme ON workspace TYPE string;
DEFINE FIELD logoUrl ON workspace TYPE string;

-- Traces
DEFINE FIELD createdAt ON workspace TYPE datetime DEFAULT time::now();
DEFINE FIELD updatedAt ON workspace TYPE datetime DEFAULT time::now();

-- Index
DEFINE INDEX workspace_slug_idx ON workspace FIELDS slug UNIQUE;
DEFINE INDEX workspace_account_idx ON workspace FIELDS account;
DEFINE INDEX workspace_name_idx ON workspace FIELDS name;

Relation 2 : account → workspace (environnements du compte)

DEFINE TABLE has_workspace SCHEMAFUL TYPE RELATION;

DEFINE FIELD in ON has_workspace TYPE record(account);     -- le compte principal
DEFINE FIELD out ON has_workspace TYPE record(workspace);  -- workspace rattaché

DEFINE FIELD isDefault ON has_workspace TYPE bool DEFAULT false;
DEFINE FIELD createdAt ON has_workspace TYPE datetime DEFAULT time::now();


user → account (propriétaire du compte)

DEFINE TABLE owns_account SCHEMAFUL TYPE RELATION;

DEFINE FIELD in ON owns_account TYPE record(user);       -- le créateur (propriétaire)
DEFINE FIELD out ON owns_account TYPE record(account);   -- le compte SaaS

DEFINE FIELD role ON owns_account TYPE string DEFAULT 'owner'; -- toujours "owner" ici
DEFINE FIELD grantedAt ON owns_account TYPE datetime DEFAULT time::now();



RELATION : user ↔ workspace (has_access)

DEFINE TABLE has_access SCHEMAFUL TYPE RELATION;

DEFINE FIELD in ON has_access TYPE record(user);        -- utilisateur
DEFINE FIELD out ON has_access TYPE record(workspace);  -- workspace

DEFINE FIELD role ON has_access TYPE string;            -- 'admin', 'editor', 'viewer'
DEFINE FIELD joinedAt ON has_access TYPE datetime DEFAULT time::now();
DEFINE FIELD isActive ON has_access TYPE bool DEFAULT true;



Tables de référence

-- Type de compte
DEFINE TABLE account_type SCHEMAFUL;
DEFINE FIELD code ON account_type TYPE string ASSERT $value != NONE;
DEFINE FIELD label ON account_type TYPE string;
DEFINE INDEX account_type_code_idx ON account_type FIELDS code UNIQUE;

-- Forme légale
DEFINE TABLE account_legal_form SCHEMAFUL;
DEFINE FIELD code ON account_legal_form TYPE string ASSERT $value != NONE;
DEFINE FIELD label ON account_legal_form TYPE string;
DEFINE INDEX account_legal_form_code_idx ON account_legal_form FIELDS code UNIQUE;

-- Pays
DEFINE TABLE account_country SCHEMAFUL;
DEFINE FIELD code ON account_country TYPE string ASSERT $value != NONE;
DEFINE FIELD name ON account_country TYPE string;
DEFINE FIELD phonePrefix ON account_country TYPE string;
DEFINE FIELD iso2 ON account_country TYPE string;
DEFINE FIELD iso3 ON account_country TYPE string;
DEFINE INDEX account_country_code_idx ON account_country FIELDS code UNIQUE;

-- Langue
DEFINE TABLE account_language SCHEMAFUL;
DEFINE FIELD code ON account_language TYPE string ASSERT $value != NONE;
DEFINE FIELD name ON account_language TYPE string;
DEFINE INDEX account_language_code_idx ON account_language FIELDS code UNIQUE;

-- Devise
DEFINE TABLE account_currency SCHEMAFUL;
DEFINE FIELD code ON account_currency TYPE string ASSERT $value != NONE;
DEFINE FIELD name ON account_currency TYPE string;
DEFINE FIELD symbol ON account_currency TYPE string;
DEFINE FIELD decimals ON account_currency TYPE number DEFAULT 2;
DEFINE INDEX account_currency_code_idx ON account_currency FIELDS code UNIQUE;

 Données d’exemple à injecter
-- account_type
CREATE account_type:1 SET code = 'INDIVIDUAL', label = 'Individu';
CREATE account_type:2 SET code = 'COMPANY', label = 'Société';

-- account_legal_form
CREATE account_legal_form:1 SET code = 'SAS', label = 'Société par Actions Simplifiée';
CREATE account_legal_form:2 SET code = 'AUTO', label = 'Auto-entrepreneur';

-- account_country
CREATE account_country:FR SET code = 'FR', name = 'France', iso2 = 'FR', iso3 = 'FRA', phonePrefix = '33';
CREATE account_country:US SET code = 'US', name = 'États-Unis', iso2 = 'US', iso3 = 'USA', phonePrefix = '1';

-- account_language
CREATE account_language:1 SET code = 'fr', name = 'Français';
CREATE account_language:2 SET code = 'en', name = 'Anglais';

-- account_currency
CREATE account_currency:EUR SET code = 'EUR', name = 'Euro', symbol = '€', decimals = 2;
CREATE account_currency:USD SET code = 'USD', name = 'Dollar', symbol = '$', decimals = 2;

générateur de slug

DEFINE EVENT account_slug_auto ON TABLE account 
WHEN $event = "CREATE" AND $after.slug = NONE THEN {
  LET $base = string::slug($after.name);
  LET $rand = string::rand(4, 'abcdefghijklmnopqrstuvwxyz0123456789');
  LET $slug = $base + "-" + $rand;
  UPDATE $this SET slug = $slug;
};

générer fullName + slug auto

-- user.fullName
DEFINE EVENT user_fullname_auto ON TABLE user 
WHEN $event = "CREATE" OR $event = "UPDATE" THEN {
  LET $full = ($after.firstName != NONE AND $after.lastName != NONE)
    ? $after.firstName + " " + $after.lastName
    : $after.firstName != NONE ? $after.firstName
    : $after.lastName != NONE ? $after.lastName
    : $after.email;
  UPDATE $this SET fullName = $full;
};

-- workspace.slug
DEFINE EVENT workspace_slug_auto ON TABLE workspace 
WHEN $event = "CREATE" AND $after.slug = NONE THEN {
  LET $base = string::slug($after.name);
  LET $rand = string::rand(4, 'abcdefghijklmnopqrstuvwxyz0123456789');
  LET $slug = $base + "-" + $rand;
  UPDATE $this SET slug = $slug;
};

