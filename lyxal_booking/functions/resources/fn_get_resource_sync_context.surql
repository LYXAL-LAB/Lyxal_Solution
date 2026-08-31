-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::booking_get_resource_sync_context                                 │
-- │  Lecture du contexte de synchronisation d'une ressource               │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::booking_get_resource_sync_context($params: object) {
    LET $record_id = $params.record_id;
    LET $language = IF $params.language != NONE { $params.language } ELSE { "fr" };

    IF $record_id == NONE {
        RETURN fn::result_error("BOOKING_INVALID_PARAMS", $language, { field: "record_id" });
    };

    LET $res = SELECT id, feed_url, last_synced_at, enabled FROM ONLY $record_id;
    IF $res == NONE {
        RETURN fn::result_error("BOOKING_NOT_FOUND", $language, { record_id: $record_id });
    };

    RETURN fn::result_ok({
        record_id: $res.id,
        feed_url: IF $res.feed_url != NONE { $res.feed_url } ELSE { "" },
        last_synced_at: $res.last_synced_at,
        enabled: IF $res.enabled != NONE { $res.enabled } ELSE { true }
    });
} COMMENT "Lecture typée du contexte de synchronisation ICS pour ressource";
