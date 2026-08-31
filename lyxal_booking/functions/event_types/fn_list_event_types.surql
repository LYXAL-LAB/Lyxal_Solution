-- ============================================================================
-- LYXAL OS — BOOKING EVENT TYPES
-- ============================================================================
-- Fichier  : functions/event_types/fn_list_event_types.surql
-- Fonction : fn::booking_list_event_types
-- Version  : 1.0.0
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::booking_list_event_types($params: object) {
    LET $user_id = $params.user_id;

    LET $event_types = SELECT * FROM booking_event_type ORDER BY title ASC;

    RETURN array::map($event_types, |$et| {
        RETURN {
            id: string::concat("", $et.id),
            title: $et.title,
            slug: $et.slug,
            duration_minutes: IF $et.length != NONE { type::int($et.length) } ELSE IF $et.duration_minutes != NONE { type::int($et.duration_minutes) } ELSE { 30 },
            description: $et.description,
            active: IF $et.hidden != NONE { !$et.hidden } ELSE { true }
        };
    });
};
