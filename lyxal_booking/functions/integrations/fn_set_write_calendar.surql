-- ============================================================================
-- LYXAL OS — BOOKING INTEGRATIONS
-- ============================================================================
-- Fichier  : functions/integrations/fn_set_write_calendar.surql
-- Fonction : fn::booking_set_write_calendar
-- Version  : 1.0.0
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::booking_set_write_calendar($params: object) {
    LET $user_id = $params.user_id;
    LET $source_id = $params.source_id;
    LET $write_calendar_href = $params.write_calendar_href;

    IF $user_id IS NONE OR $source_id IS NONE OR $write_calendar_href IS NONE {
        THROW "BOOKING_INVALID_PARAMS: user_id, source_id et write_calendar_href sont obligatoires";
    };

    -- Mise à jour atomique de l'agenda d'écriture
    UPDATE $source_id SET write_calendar_href = $write_calendar_href WHERE user_id = $user_id;

    RETURN {
        source_id: string::concat("", $source_id),
        write_calendar_href: $write_calendar_href,
        updated: true
    };
};
