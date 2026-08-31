-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::booking_get_calendar_by_href                                       │
-- │  Récupère un calendrier et son token de synchronisation par href        │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::booking_get_calendar_by_href($params: object) {
    LET $source_id = $params.source_id;
    LET $calendar_href = $params.calendar_href;

    IF $source_id == NONE OR $calendar_href == NONE {
        THROW "Parameters 'source_id' and 'calendar_href' are required";
    };

    LET $cal = SELECT id, href, sync_state FROM ONLY booking_calendar WHERE source == $source_id AND href == $calendar_href;

    RETURN $cal;
} COMMENT "Recherche un calendrier et son sync-token RFC 6578 rattaché à une source";
