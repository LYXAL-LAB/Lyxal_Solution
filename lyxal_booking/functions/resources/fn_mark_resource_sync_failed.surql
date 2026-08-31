-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::booking_mark_resource_sync_failed                                 │
-- │  Enregistrement d'une erreur de synchronisation ressource sans purge    │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::booking_mark_resource_sync_failed($params: object) {
    LET $resource_id = $params.resource_id;
    LET $error_message = $params.error_message;
    LET $synced_at = $params.synced_at;
    LET $language = IF $params.language != NONE { $params.language } ELSE { "fr" };

    IF $resource_id == NONE {
        RETURN fn::result_error("BOOKING_INVALID_PARAMS", $language, { field: "resource_id" });
    };

    UPDATE ONLY $resource_id SET
        last_synced_at = IF $synced_at != NONE { $synced_at } ELSE { time::now() },
        last_sync_error = $error_message,
        updated_at = time::now();

    RETURN fn::result_ok({
        updated: true
    });
} COMMENT "Marquage de l'échec de synchronisation d'une ressource sans vider le cache d'événements";
