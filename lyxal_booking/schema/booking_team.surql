-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  booking_team                                                           │
-- │  Équipes et organisations d'hôtes - Version SurrealDB Avancée          │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE TABLE IF NOT EXISTS booking_team TYPE NORMAL SCHEMAFULL
    COMMENT "Équipes et organisations d'hôtes pour la prise de RDV collective"
    PERMISSIONS
        FOR select WHERE true
        FOR create WHERE $auth.id != NONE
        FOR update, delete WHERE created_by = $auth.id OR $auth.role = 'admin';

-- ----------------------------------------------------------------------------
-- CHAMPS OBLIGATOIRES AVEC AUTO-FORMATAGE ET ASSERTIONS
-- ----------------------------------------------------------------------------

DEFINE FIELD IF NOT EXISTS name
    ON TABLE booking_team
    TYPE string
    VALUE string::trim($value)
    ASSERT string::len($value) > 0 AND string::len($value) <= 255
    COMMENT "Nom de l'équipe / entreprise";

DEFINE FIELD IF NOT EXISTS slug
    ON TABLE booking_team
    TYPE string
    VALUE string::lowercase(string::trim($value))
    ASSERT string::len($value) > 0 AND $value ~ "^[a-z0-9-]+$"
    COMMENT "Slug unique de l'équipe pour les URLs d'équipe";

-- ----------------------------------------------------------------------------
-- CHAMPS OPTIONNELS NETTOYÉS AUTOMATIQUEMENT
-- ----------------------------------------------------------------------------

DEFINE FIELD IF NOT EXISTS description
    ON TABLE booking_team
    TYPE option<string>
    VALUE {
        IF $value != NONE 
        { string::trim($value) }
     ELSE { NONE }
    }
    COMMENT "Description de l'équipe";

DEFINE FIELD IF NOT EXISTS logo_url
    ON TABLE booking_team
    TYPE option<string>
    VALUE {
        IF $value != NONE 
        { string::trim($value) }
     ELSE { NONE }
    }
    COMMENT "URL du logo de l'équipe";

DEFINE FIELD IF NOT EXISTS visibility
    ON TABLE booking_team
    TYPE string
    DEFAULT 'public'
    VALUE string::lowercase(string::trim($value))
    ASSERT $value IN ['public', 'private']
    COMMENT "Visibilité de l'équipe (public, private)";

DEFINE FIELD IF NOT EXISTS invite_token
    ON TABLE booking_team
    TYPE option<string>
    VALUE {
        IF $value != NONE 
        { string::trim($value) }
     ELSE { NONE }
    }
    COMMENT "Jeton d'invitation privée pour rejoindre l'équipe";

DEFINE FIELD IF NOT EXISTS created_by
    ON TABLE booking_team
    TYPE option<record<booking_account>>
    COMMENT "Créateur / administrateur principal de l'équipe";

-- ----------------------------------------------------------------------------
-- HORODATAGES AUTOMATIQUES
-- ----------------------------------------------------------------------------

DEFINE FIELD IF NOT EXISTS created_at
    ON TABLE booking_team
    TYPE datetime
    DEFAULT time::now()
    VALUE $before OR time::now()
    COMMENT "Date de création de l'équipe (immuable)";

-- ----------------------------------------------------------------------------
-- INDEX D'UNICITÉ
-- ----------------------------------------------------------------------------

DEFINE INDEX IF NOT EXISTS idx_booking_team_slug
    ON TABLE booking_team
    FIELDS slug UNIQUE;

DEFINE INDEX IF NOT EXISTS idx_booking_team_invite_token
    ON TABLE booking_team
    FIELDS invite_token UNIQUE;
