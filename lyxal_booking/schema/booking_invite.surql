-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  booking_invite                                                         │
-- │  Invitations privées éphémères - Version SurrealDB Avancée               │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE TABLE IF NOT EXISTS booking_invite TYPE NORMAL SCHEMAFULL
    COMMENT "Invitations privées et liens de réservation éphémères à usage unique"
    PERMISSIONS FOR select, create, update, delete WHERE true;

-- ----------------------------------------------------------------------------
-- PROPRIÉTÉS ET JETONS D'INVITATION
-- ----------------------------------------------------------------------------

DEFINE FIELD IF NOT EXISTS event_type
    ON TABLE booking_invite
    TYPE record<booking_event_type>
    COMMENT "Type d'événement rattaché";

DEFINE FIELD IF NOT EXISTS token
    ON TABLE booking_invite
    TYPE string
    VALUE string::trim($value)
    ASSERT string::len($value) > 0
    COMMENT "Jeton d'accès unique";

DEFINE FIELD IF NOT EXISTS email
    ON TABLE booking_invite
    TYPE option<string>
    VALUE IF $value != NONE THEN string::lowercase(string::trim($value)) ELSE NONE END
    COMMENT "Adresse email ciblée (optionnel)";

DEFINE FIELD IF NOT EXISTS is_reusable
    ON TABLE booking_invite
    TYPE bool
    DEFAULT false
    COMMENT "Si vrai, le lien peut être réutilisé plusieurs fois";

DEFINE FIELD IF NOT EXISTS max_uses
    ON TABLE booking_invite
    TYPE option<int>
    COMMENT "Nombre maximal d'utilisations autorisées";

DEFINE FIELD IF NOT EXISTS uses_count
    ON TABLE booking_invite
    TYPE int
    DEFAULT 0
    ASSERT $value >= 0
    COMMENT "Nombre d'utilisations effectuées";

DEFINE FIELD IF NOT EXISTS expires_at
    ON TABLE booking_invite
    TYPE option<datetime>
    COMMENT "Date d'expiration de l'invitation";

DEFINE FIELD IF NOT EXISTS created_at
    ON TABLE booking_invite
    TYPE datetime
    DEFAULT time::now()
    VALUE $before OR time::now()
    COMMENT "Date de création de l'invitation";

-- ----------------------------------------------------------------------------
-- INDEX D'UNICITÉ
-- ----------------------------------------------------------------------------

DEFINE INDEX IF NOT EXISTS idx_booking_invite_token
    ON TABLE booking_invite
    FIELDS token UNIQUE;
