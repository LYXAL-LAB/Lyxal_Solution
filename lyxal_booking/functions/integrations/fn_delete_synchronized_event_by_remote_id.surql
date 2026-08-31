-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::booking_delete_synchronized_event_by_remote_id                     │
-- │  Suppression d'un événement synchronisé par son remote_id ou son UID   │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::booking_delete_synchronized_event_by_remote_id($params: object) {
    LET $source_id = $params.source_id;
    LET $calendar_id = $params.calendar_id;
    LET $remote_id = $params.remote_id;
    LET $uid = $params.uid;

    IF $source_id == NONE OR $calendar_id == NONE {
        THROW "Parameters 'source_id' and 'calendar_id' are required";
    };

    IF $remote_id != NONE {
        DELETE booking_event WHERE source == $source_id AND calendar_id == $calendar_id AND remote_id == $remote_id;
    } ELSE IF $uid != NONE {
        DELETE booking_event WHERE source == $source_id AND calendar_id == $calendar_id AND (remote_id == $uid OR uid == $uid);
    };

    RETURN { deleted: true };
} COMMENT "Suppression fiable d'un événement synchronisé par remote_id avec fallback sur UID";
