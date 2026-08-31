-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::booking_delete_resource                                            │
-- │  Suppression d'une ressource et nettoyage de ses affectations           │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::booking_delete_resource($params: object) {
    LET $resource_id = IF $params.resource_id != NONE { $params.resource_id } ELSE { $params.id };
    IF $resource_id == NONE {
        THROW "Parameter 'resource_id' is required";
    };

    LET $record_id = type::record(type::string($resource_id));

    DELETE booking_resource_allocation WHERE in = $record_id;
    DELETE $record_id;

    RETURN {
        resource_id: $record_id,
        deleted: true
    };
} COMMENT "Supprime une ressource physique et ses affectations de réservation associées";
