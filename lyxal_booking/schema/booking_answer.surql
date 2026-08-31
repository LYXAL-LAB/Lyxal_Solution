-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  booking_answer                                                         │
-- │  Réponses fournies par l'invité aux questions personnalisées             │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE TABLE IF NOT EXISTS booking_answer TYPE NORMAL SCHEMAFULL
    COMMENT "Réponses enregistrées lors d'une réservation aux questions personnalisées du formulaire"
    PERMISSIONS
        FOR select WHERE true
        FOR create WHERE true
        FOR update, delete WHERE booking.event_type.account = $auth.id OR $auth.role = 'admin';

-- ----------------------------------------------------------------------------
-- PROPRIÉTÉS ET RÉPONSE
-- ----------------------------------------------------------------------------

DEFINE FIELD IF NOT EXISTS booking
    ON TABLE booking_answer
    TYPE record<booking>
    COMMENT "Réservation associée";

DEFINE FIELD IF NOT EXISTS question
    ON TABLE booking_answer
    TYPE record<booking_question>
    COMMENT "Question personnalisée rattachée";

DEFINE FIELD IF NOT EXISTS value
    ON TABLE booking_answer
    TYPE string
    VALUE string::trim($value)
    COMMENT "Valeur de la réponse fournie (texte, choix sélectionné, JSON stringifié si multiple)";

DEFINE FIELD IF NOT EXISTS created_at
    ON TABLE booking_answer
    TYPE datetime
    DEFAULT time::now()
    VALUE $before OR time::now()
    COMMENT "Horodatage d'enregistrement de la réponse";

-- ----------------------------------------------------------------------------
-- INDEX
-- ----------------------------------------------------------------------------

DEFINE INDEX IF NOT EXISTS idx_booking_answer_booking_question
    ON TABLE booking_answer
    FIELDS booking, question UNIQUE;
