-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::booking_delete_resource                                            │
-- │  Suppression d'une ressource et nettoyage de ses affectations           │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::booking_delete_resource($params: object) {
    LET $resource_id = IF $params.resource_id != NONE { $params.resource_id } ELSE { $params.id };
    LET $language = IF $params.language != NONE { $params.language } ELSE { "fr" };
    IF $resource_id == NONE {
        RETURN fn::result_error("BOOKING_RESOURCE_ID_REQUIRED", $language, { field: "resource_id" });
    };

    LET $record_id = type::record(type::string($resource_id));

    DELETE booking_resource_allocation WHERE in = $record_id;
    DELETE $record_id;

    RETURN fn::result_ok({
        resource_id: $record_id,
        deleted: true
    });
} COMMENT "Supprime une ressource physique et ses affectations de réservation associées";
