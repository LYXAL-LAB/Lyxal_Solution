-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  booking_schedule                                                       │
-- │  Plannings d'horaires réutilisables - Version SurrealDB Enterprise        │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE TABLE IF NOT EXISTS booking_schedule TYPE NORMAL SCHEMAFULL
    COMMENT "Plannings d'horaires de travail réutilisables par les comptes hôtes"
    PERMISSIONS
        FOR select WHERE true
        FOR create WHERE account = $auth.id OR $auth.role = 'admin'
        FOR update, delete WHERE account = $auth.id OR $auth.role = 'admin';

-- ----------------------------------------------------------------------------
-- PROPRIÉTÉS DU PLANNING
-- ----------------------------------------------------------------------------

DEFINE FIELD IF NOT EXISTS account
    ON TABLE booking_schedule
    TYPE record<booking_account>
    COMMENT "Compte hôte propriétaire du planning";

DEFINE FIELD IF NOT EXISTS name
    ON TABLE booking_schedule
    TYPE string
    VALUE string::trim($value)
    ASSERT string::len($value) > 0 AND string::len($value) <= 255
    COMMENT "Nom du planning (ex: Horaires de bureau, Astreinte soir, Planning été)";

DEFINE FIELD IF NOT EXISTS timezone
    ON TABLE booking_schedule
    TYPE string
    DEFAULT 'UTC'
    VALUE string::trim($value)
    COMMENT "Fuseau horaire de référence du planning";

DEFINE FIELD IF NOT EXISTS is_default
    ON TABLE booking_schedule
    TYPE bool
    DEFAULT false
    COMMENT "Indique s'il s'agit du planning principal/par défaut de l'hôte";

-- ----------------------------------------------------------------------------
-- HORODATAGES AUTOMATIQUES
-- ----------------------------------------------------------------------------

DEFINE FIELD IF NOT EXISTS created_at
    ON TABLE booking_schedule
    TYPE datetime
    DEFAULT time::now()
    VALUE $before OR time::now()
    COMMENT "Date de création du planning (immuable)";

DEFINE FIELD IF NOT EXISTS updated_at
    ON TABLE booking_schedule
    TYPE datetime
    DEFAULT time::now()
    VALUE time::now()
    COMMENT "Dernière mise à jour du planning";

-- ----------------------------------------------------------------------------
-- INDEX
-- ----------------------------------------------------------------------------

DEFINE INDEX IF NOT EXISTS idx_schedule_account
    ON TABLE booking_schedule
    FIELDS account;
