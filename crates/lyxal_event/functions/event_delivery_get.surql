-- ============================================================================
-- Function   : fn::event_delivery_get
-- Module     : lyxal_event
-- Description: Récupère un enregistrement de livraison par son identifiant.
-- Contrat    : Retourne fn::result_ok($delivery) ou fn::result_ok(NONE)
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::event_delivery_get(
    $params: object
) {
    IF $params.id == NONE OR $params.id == NULL {
        RETURN fn::error_result("EVENT_INVALID_PARAMETERS", "fr", { message: "id is mandatory" });
    };

    LET $id = <record<event_delivery>> $params.id;
    LET $delivery = (SELECT * FROM ONLY $id);

    RETURN fn::result_ok($delivery);
} COMMENT "Récupère un enregistrement de livraison par son identifiant";

