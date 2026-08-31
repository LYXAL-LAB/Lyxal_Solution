-- ============================================================================
-- LYXAL OS — BOOKING INTEGRATIONS
-- ============================================================================
-- Fichier  : functions/integrations/fn_get_calendar_source.surql
-- Fonction : fn::booking_get_calendar_source
-- Version  : 1.0.0
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::booking_get_calendar_source($params: object) {
    LET $user_id = $params.user_id;
    LET $source_id = $params.source_id;

    IF $user_id IS NONE OR $source_id IS NONE {
        THROW "BOOKING_INVALID_PARAMS: user_id et source_id sont obligatoires";
    };

    LET $source = SELECT * FROM $source_id WHERE user_id = $user_id LIMIT 1;
    IF array::len($source) = 0 {
        THROW "BOOKING_CALENDAR_SOURCE_NOT_FOUND: Source de calendrier introuvable";
    };

    LET $s = $source[0];
    RETURN {
        id: string::concat("", $s.id),
        name: $s.name,
        provider_type: $s.provider_type,
        auth_type: $s.auth_type,
        server_url: $s.server_url,
        username: $s.username,
        active: $s.status = "active",
        status: $s.status,
        last_synced_at: $s.last_synced_at
    };
};
