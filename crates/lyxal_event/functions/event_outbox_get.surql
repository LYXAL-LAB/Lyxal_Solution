-- ============================================================================
-- Function   : fn::event_outbox_get
-- Module     : lyxal_event
-- Description: Récupère un enregistrement outbox par son identifiant.
-- Contrat    : Retourne fn::result_ok($event) ou fn::result_ok(NONE)
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::event_outbox_get(
    $params: object
) {
    IF $params.id == NONE OR $params.id == NULL {
        RETURN fn::error_result("EVENT_INVALID_PARAMETERS", "fr", { message: "id is mandatory" });
    };

    LET $id = <record<event_outbox>> $params.id;
    LET $event = (SELECT * FROM ONLY $id);

    RETURN fn::result_ok($event);
} COMMENT "Récupère un événement outbox par son identifiant";

