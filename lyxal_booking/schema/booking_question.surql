-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  booking_question                                                       │
-- │  Questions personnalisées dynamiques de réservation par type d'événement│
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE TABLE IF NOT EXISTS booking_question TYPE NORMAL SCHEMAFULL
    COMMENT "Questions personnalisées dynamiques configurables par type d'événement"
    PERMISSIONS
        FOR select WHERE true
        FOR create, update, delete WHERE event_type.account = $auth.id OR event_type.team = $auth.id OR $auth.role = 'admin';

-- ----------------------------------------------------------------------------
-- PROPRIÉTÉS ET CONFIGURATION DU CHAMP DYNAMIQUE
-- ----------------------------------------------------------------------------

DEFINE FIELD IF NOT EXISTS event_type
    ON TABLE booking_question
    TYPE record<booking_event_type>
    COMMENT "Type d'événement rattaché";

DEFINE FIELD IF NOT EXISTS key
    ON TABLE booking_question
    TYPE string
    VALUE string::lowercase(string::trim($value))
    ASSERT string::len($value) > 0
    COMMENT "Clé unique d'identification du champ dans le formulaire (ex: budget, project_type)";

DEFINE FIELD IF NOT EXISTS label
    ON TABLE booking_question
    TYPE string
    VALUE string::trim($value)
    ASSERT string::len($value) > 0
    COMMENT "Libellé de la question affiché au client (ex: Quel est votre budget ?)";

DEFINE FIELD IF NOT EXISTS field_type
    ON TABLE booking_question
    TYPE string
    DEFAULT 'text'
    VALUE string::lowercase(string::trim($value))
    ASSERT $value IN ['text', 'textarea', 'number', 'select', 'checkbox', 'radio', 'phone']
    COMMENT "Type de champ de saisie : text | textarea | number | select | checkbox | radio | phone";

DEFINE FIELD IF NOT EXISTS required
    ON TABLE booking_question
    TYPE bool
    DEFAULT false
    COMMENT "Si vrai, la réponse à cette question est obligatoire pour réserver";

DEFINE FIELD IF NOT EXISTS position
    ON TABLE booking_question
    TYPE int
    DEFAULT 0
    ASSERT $value >= 0
    COMMENT "Ordre d'affichage de la question dans le formulaire";

DEFINE FIELD IF NOT EXISTS options
    ON TABLE booking_question
    TYPE option<array<string>>
    COMMENT "Liste des choix possibles (pour les champs de type select, checkbox ou radio)";

DEFINE FIELD IF NOT EXISTS enabled
    ON TABLE booking_question
    TYPE bool
    DEFAULT true
    COMMENT "Activer ou désactiver cette question";

-- ----------------------------------------------------------------------------
-- INDEX
-- ----------------------------------------------------------------------------

DEFINE INDEX IF NOT EXISTS idx_booking_question_event_type_key
    ON TABLE booking_question
    FIELDS event_type, key UNIQUE;
