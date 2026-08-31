-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  booking_event_type                                                     │
-- │  Types d'événements / Liens publics de RDV - Version SurrealDB Enterprise│
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE TABLE IF NOT EXISTS booking_event_type TYPE NORMAL SCHEMAFULL
    COMMENT "Types d'événements et liens de réservation publics (individuels ou d'équipe)"
    PERMISSIONS FOR select, create, update, delete WHERE true;

-- ----------------------------------------------------------------------------
-- RELATIONS ET PROPRIÉTAIRE EXCLUSIF XOR (ACCOUNT OU TEAM)
-- ----------------------------------------------------------------------------

DEFINE FIELD IF NOT EXISTS account
    ON TABLE booking_event_type
    TYPE option<record<booking_account>>
    ASSERT ($value != NONE AND team = NONE) OR ($value = NONE AND team != NONE)
    COMMENT "Compte hôte propriétaire (si événement individuel - Mutuellement exclusif avec team)";

DEFINE FIELD IF NOT EXISTS team
    ON TABLE booking_event_type
    TYPE option<record<booking_team>>
    COMMENT "Équipe propriétaire (si événement d'équipe / collectif / Round-Robin - Mutuellement exclusif avec account)";

DEFINE FIELD IF NOT EXISTS schedule
    ON TABLE booking_event_type
    TYPE option<record<booking_schedule>>
    COMMENT "Planning réutilisable d'horaires et de disponibilités rattaché";

DEFINE FIELD IF NOT EXISTS slug
    ON TABLE booking_event_type
    TYPE string
    VALUE string::lowercase(string::trim($value))
    ASSERT string::len($value) > 0
    COMMENT "Slug d'URL unique (ex: 30min, consultation)";

DEFINE FIELD IF NOT EXISTS title
    ON TABLE booking_event_type
    TYPE string
    VALUE string::trim($value)
    ASSERT string::len($value) > 0
    COMMENT "Titre du rendez-vous";

DEFINE FIELD IF NOT EXISTS description
    ON TABLE booking_event_type
    TYPE option<string>
    VALUE {
        IF $value != NONE 
        { string::trim($value) }
     ELSE { NONE }
    }
    COMMENT "Description détaillée ou instructions";

DEFINE FIELD IF NOT EXISTS duration_min
    ON TABLE booking_event_type
    TYPE int
    ASSERT $value > 0
    COMMENT "Durée du rendez-vous en minutes";

-- ----------------------------------------------------------------------------
-- CONFIGURATION DU LIEU ET PARAMÈTRES DE CRÉNEAUX
-- ----------------------------------------------------------------------------

DEFINE FIELD IF NOT EXISTS location_type
    ON TABLE booking_event_type
    TYPE string
    DEFAULT 'link'
    VALUE string::lowercase(string::trim($value))
    ASSERT $value IN ['link', 'in_person', 'phone', 'google_meet', 'jitsi']
    COMMENT "Type de lieu : link | in_person | phone | google_meet | jitsi";

DEFINE FIELD IF NOT EXISTS location_value
    ON TABLE booking_event_type
    TYPE option<string>
    VALUE {
        IF $value != NONE 
        { string::trim($value) }
     ELSE { NONE }
    }
    COMMENT "Adresse physique ou URL de visio-conférence";

DEFINE FIELD IF NOT EXISTS buffer_before
    ON TABLE booking_event_type
    TYPE int
    DEFAULT 0
    ASSERT $value >= 0
    COMMENT "Temps de préparation avant en minutes";

DEFINE FIELD IF NOT EXISTS buffer_after
    ON TABLE booking_event_type
    TYPE int
    DEFAULT 0
    ASSERT $value >= 0
    COMMENT "Temps de préparation après en minutes";

DEFINE FIELD IF NOT EXISTS min_notice_min
    ON TABLE booking_event_type
    TYPE int
    DEFAULT 60
    ASSERT $value >= 0
    COMMENT "Préavis minimum de réservation en minutes";

DEFINE FIELD IF NOT EXISTS slot_interval
    ON TABLE booking_event_type
    TYPE option<int>
    COMMENT "Intervalle entre les créneaux proposés (en minutes)";

DEFINE FIELD IF NOT EXISTS requires_confirmation
    ON TABLE booking_event_type
    TYPE bool
    DEFAULT false
    COMMENT "Si vrai, la réservation nécessite la confirmation manuelle de l'hôte";

DEFINE FIELD IF NOT EXISTS enabled
    ON TABLE booking_event_type
    TYPE bool
    DEFAULT true
    COMMENT "Activer ou désactiver la prise de RDV sur ce lien";

DEFINE FIELD IF NOT EXISTS created_at
    ON TABLE booking_event_type
    TYPE datetime
    DEFAULT time::now()
    VALUE $before OR time::now()
    COMMENT "Date de création du type d'événement";

-- ----------------------------------------------------------------------------
-- INDEX D'UNICITÉ ET DE RECHERCHE
-- ----------------------------------------------------------------------------

DEFINE INDEX IF NOT EXISTS idx_event_type_account_slug
    ON TABLE booking_event_type
    FIELDS account, slug UNIQUE;

DEFINE INDEX IF NOT EXISTS idx_event_type_team_slug
    ON TABLE booking_event_type
    FIELDS team, slug UNIQUE;

DEFINE INDEX IF NOT EXISTS idx_event_type_schedule
    ON TABLE booking_event_type
    FIELDS schedule;
