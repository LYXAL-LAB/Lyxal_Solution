-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  booking_team_member                                                    │
-- │  Relation Graph d'appartenance aux équipes - Version SurrealDB Graph    │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE TABLE IF NOT EXISTS booking_team_member TYPE RELATION 
    IN booking_account OUT booking_team SCHEMAFULL
    COMMENT "Relation Graph d'appartenance des membres aux équipes et pondération Round-Robin"
    PERMISSIONS FOR select, create, update, delete WHERE true;

-- ----------------------------------------------------------------------------
-- PROPRIÉTÉS DE LA RELATION GRAPH
-- ----------------------------------------------------------------------------

DEFINE FIELD IF NOT EXISTS role
    ON TABLE booking_team_member
    TYPE string
    DEFAULT 'member'
    VALUE string::lowercase(string::trim($value))
    ASSERT $value IN ['owner', 'admin', 'member']
    COMMENT "Rôle du membre dans l'équipe : owner | admin | member";

DEFINE FIELD IF NOT EXISTS source
    ON TABLE booking_team_member
    TYPE string
    DEFAULT 'direct'
    VALUE string::lowercase(string::trim($value))
    ASSERT $value IN ['direct', 'group']
    COMMENT "Source de membre : direct (ajouté directement) | group (issu d'un groupe OIDC)";

DEFINE FIELD IF NOT EXISTS weight
    ON TABLE booking_team_member
    TYPE int
    DEFAULT 100
    ASSERT $value >= 0 AND $value <= 100
    COMMENT "Pondération / poids du membre pour la distribution Round-Robin (0-100)";

DEFINE FIELD IF NOT EXISTS created_at
    ON TABLE booking_team_member
    TYPE datetime
    DEFAULT time::now()
    VALUE $before OR time::now()
    COMMENT "Date d'ajout du membre à l'équipe";

-- ----------------------------------------------------------------------------
-- INDEX GRAPH UNIQUE (in, out)
-- ----------------------------------------------------------------------------

DEFINE INDEX IF NOT EXISTS idx_team_member_unique
    ON TABLE booking_team_member
    FIELDS in, out UNIQUE;
