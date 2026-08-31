-- ============================================================================
-- LYXAL OS — BOOKING EVENT TYPES
-- ============================================================================
-- Fichier  : functions/event_types/fn_get_event_type.surql
-- Fonction : fn::booking_get_event_type
-- Version  : 1.0.0
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::booking_get_event_type($params: object) {
    LET $event_type_id = $params.event_type_id;

    IF $event_type_id IS NONE {
        THROW "BOOKING_INVALID_PARAMS: event_type_id est obligatoire";
    };

    LET $res = SELECT * FROM $event_type_id LIMIT 1;
    IF array::len($res) = 0 {
        THROW "BOOKING_EVENT_TYPE_NOT_FOUND: Type d'événement introuvable";
    };

    LET $et = $res[0];
    RETURN {
        id: string::concat("", $et.id),
        title: $et.title,
        slug: $et.slug,
        duration_minutes: IF $et.length != NONE { type::int($et.length) } ELSE IF $et.duration_minutes != NONE { type::int($et.duration_minutes) } ELSE { 30 },
        description: $et.description,
        active: IF $et.hidden != NONE { !$et.hidden } ELSE { true }
    };
};
