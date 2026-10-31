-- ============================================================================
-- Function   : fn::event_dead_letter_list
-- Module     : lyxal_event
-- Description: Liste les enregistrements de dead-letter ordonnés par date d'épuisement décroissante.
-- Contrat    : Retourne fn::result_ok(Vec<EventDeadLetter>)
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::event_dead_letter_list(
    $params: object
) {
    LET $limit = IF $params.limit != NONE AND $params.limit != NULL THEN <number> $params.limit ELSE 100 END;
    LET $delivery = IF $params.delivery != NONE AND $params.delivery != NULL THEN <record<event_delivery>> $params.delivery ELSE NONE END;

    LET $items = IF $delivery != NONE {
        (SELECT * FROM event_dead_letter WHERE delivery = $delivery ORDER BY exhausted_at DESC LIMIT $limit)
    } ELSE {
        (SELECT * FROM event_dead_letter ORDER BY exhausted_at DESC LIMIT $limit)
    };

    RETURN fn::result_ok($items);
} COMMENT "Liste les enregistrements en quarantaine dead-letter";

