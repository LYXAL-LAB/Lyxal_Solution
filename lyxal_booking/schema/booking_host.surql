-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  booking_host                                                            │
-- │  Relation Graph d'affectation des hôtes et co-hôtes aux réservations    │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE TABLE IF NOT EXISTS booking_host TYPE RELATION 
    IN booking_account OUT booking SCHEMAFULL
    COMMENT "Relation Graph d'attribution des hôtes principaux et co-hôtes aux réservations (notamment collectives)"
    PERMISSIONS
        FOR select WHERE true
        FOR create, update, delete WHERE out.event_type.account = $auth.id OR out.event_type.team = $auth.id OR in = $auth.id OR $auth.role = 'admin';

-- ----------------------------------------------------------------------------
-- PROPRIÉTÉS ET RÔLE DE L'HÔTE SUR LE RENDEZ-VOUS
-- ----------------------------------------------------------------------------

DEFINE FIELD IF NOT EXISTS is_primary
    ON TABLE booking_host
    TYPE bool
    DEFAULT false
    COMMENT "Indique si ce membre est l'hôte principal (lead) du rendez-vous";

DEFINE FIELD IF NOT EXISTS assignment_method
    ON TABLE booking_host
    TYPE string
    DEFAULT 'fixed'
    VALUE string::lowercase(string::trim($value))
    ASSERT $value IN ['fixed', 'round_robin', 'manual', 'collective']
    COMMENT "Méthode d'affectation : fixed | round_robin | manual | collective";

DEFINE FIELD IF NOT EXISTS created_at
    ON TABLE booking_host
    TYPE datetime
    DEFAULT time::now()
    VALUE $before OR time::now()
    COMMENT "Horodatage d'attribution de l'hôte au rendez-vous";

-- ----------------------------------------------------------------------------
-- INDEX GRAPH (in, out)
-- ----------------------------------------------------------------------------

DEFINE INDEX IF NOT EXISTS idx_booking_host_unique
    ON TABLE booking_host
    FIELDS in, out UNIQUE;
