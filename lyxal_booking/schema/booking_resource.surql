-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  booking_resource                                                       │
-- │  Ressources partagées (salles, équipements) - Version SurrealDB Avancée  │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE TABLE IF NOT EXISTS booking_resource TYPE NORMAL SCHEMAFULL
    COMMENT "Ressources physiques ou virtuelles réservables (salles de réunion, matériels)"
    PERMISSIONS FOR select, create, update, delete WHERE true;

-- ----------------------------------------------------------------------------
-- PROPRIÉTÉS DE LA RESSOURCE
-- ----------------------------------------------------------------------------

DEFINE FIELD IF NOT EXISTS name
    ON TABLE booking_resource
    TYPE string
    VALUE string::trim($value)
    ASSERT string::len($value) > 0
    COMMENT "Nom de la ressource (ex: Salle Paris, Projecteur A)";

DEFINE FIELD IF NOT EXISTS description
    ON TABLE booking_resource
    TYPE option<string>
    VALUE IF $value != NONE { string::trim($value) } ELSE { NONE }
    COMMENT "Description de la ressource";

DEFINE FIELD IF NOT EXISTS capacity
    ON TABLE booking_resource
    TYPE option<int>
    ASSERT $value == NONE OR $value > 0
    COMMENT "Capacité maximale d'accueil de la ressource";

DEFINE FIELD IF NOT EXISTS location
    ON TABLE booking_resource
    TYPE option<string>
    VALUE IF $value != NONE { string::trim($value) } ELSE { NONE }
    COMMENT "Emplacement physique ou virtuel";

DEFINE FIELD IF NOT EXISTS enabled
    ON TABLE booking_resource
    TYPE bool
    DEFAULT true
    COMMENT "Activer ou désactiver la réservation de cette ressource";

DEFINE FIELD IF NOT EXISTS created_at
    ON TABLE booking_resource
    TYPE datetime
    DEFAULT time::now()
    VALUE $before OR time::now()
    COMMENT "Date de création de la ressource";
