-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  booking_resource_allocation                                            │
-- │  Relation Graph d'affectation des ressources - Version SurrealDB Graph   │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE TABLE IF NOT EXISTS booking_resource_allocation TYPE RELATION 
    IN booking_resource OUT booking SCHEMAFULL
    COMMENT "Relation Graph d'affectation des ressources physiques (salles/équipements) aux réservations"
    PERMISSIONS
        FOR select WHERE true
        FOR create, update, delete WHERE out.event_type.account = $auth.id OR $auth.role = 'admin';

-- ----------------------------------------------------------------------------
-- PROPRIÉTÉS ET PLAGE TEMPORELLE D'ALLOCATION
-- ----------------------------------------------------------------------------

DEFINE FIELD IF NOT EXISTS start_at
    ON TABLE booking_resource_allocation
    TYPE datetime
    COMMENT "Date et heure de début d'occupation de la ressource";

DEFINE FIELD IF NOT EXISTS end_at
    ON TABLE booking_resource_allocation
    TYPE datetime
    ASSERT $value > start_at
    COMMENT "Date et heure de fin d'occupation de la ressource (doit être > start_at)";

-- ----------------------------------------------------------------------------
-- INDEX GRAPH ET TEMPOREL
-- ----------------------------------------------------------------------------

DEFINE INDEX IF NOT EXISTS idx_res_alloc_in_dates
    ON TABLE booking_resource_allocation
    FIELDS in, start_at, end_at;
