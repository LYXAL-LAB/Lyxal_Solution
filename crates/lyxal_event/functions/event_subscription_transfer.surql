-- ============================================================================
-- Function   : fn::event_subscription_transfer
-- Module     : lyxal_event
-- Description: Fonction d'exploitation : change l'hôte d'un abonnement et de ses livraisons non
--              soldées. Refusée tant que le chef des événements de l'ancien hôte est vivant.
-- Contrat    : Retourne fn::result_ok({ name, previous_host, host, deliveries })
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::event_subscription_transfer(
    $params: object
) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            name: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 128 } }, { rule: "regex", options: { pattern: "^[a-z][a-z0-9_]*$" } }], required: true },
            host: { pipeline: [{ rule: "regex", options: { pattern: "^[a-z][a-z0-9_]{0,63}$" } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("EVENT_INVALID_PARAMETERS", $params.language, { fields: $report.by_field });
    };
    LET $p = $report.value;

    -- Tables en PERMISSIONS NONE : une session d'accès (utilisateur, jeton) ne voit aucune ligne et
    -- ses écritures seraient filtrées sans erreur ; elle est refusée au lieu d'annoncer un succès
    IF $access != NONE {
        RETURN fn::error_result("EVENT_WRITE_FORBIDDEN", $p.language, { table: "event_subscription" });
    };

    LET $subscription = (SELECT * FROM event_subscription WHERE name = $p.name)[0];
    IF $subscription == NONE {
        RETURN fn::error_result("EVENT_SUBSCRIPTION_NOT_FOUND", $p.language, { name: $p.name });
    };
    LET $previous_host = $subscription.host;
    IF $previous_host == $p.host {
        RETURN fn::result_ok({ name: $p.name, previous_host: $previous_host, host: $p.host, deliveries: 0 });
    };

    -- Le chef de l'ancien hôte détient peut-être des livraisons en mémoire : tant que son bail
    -- est vivant (à l'heure de la base), le changement d'hôte ferait deux écrivains
    LET $now = time::now();
    LET $lease = (SELECT * FROM ONLY type::record("event_stream_lease", $previous_host));
    IF $lease != NONE AND $lease.is_released == false AND $lease.expires_at >= $now {
        RETURN fn::error_result("EVENT_HOST_ACTIVE", $p.language, {
            name: $p.name,
            host: $previous_host,
            leader_node: $lease.owner_node_id,
            expires_at: $lease.expires_at
        });
    };

    UPDATE $subscription.id SET host = $p.host;
    -- Livraisons non soldées (en attente, en cours, en retry) : elles suivent leur abonnement ;
    -- les livraisons soldées gardent l'hôte qui les a traitées (un rejeu de dead letter reprend
    -- l'hôte courant de l'abonnement, fn::event_dead_letter_replay)
    LET $moved = (
        UPDATE event_delivery SET host = $p.host
        WHERE subscription = $subscription.id
          AND ["pending", "processing", "failed"] CONTAINS status
        RETURN AFTER
    );

    RETURN fn::result_ok({
        name: $p.name,
        previous_host: $previous_host,
        host: $p.host,
        deliveries: array::len($moved)
    });
} COMMENT "Fonction d'exploitation ({ name, host }) : change l'hôte d'un abonnement et de ses livraisons non soldées (pending, processing, failed), curseur et numéros conservés. { name, previous_host, host, deliveries }. Refus : EVENT_HOST_ACTIVE tant que le bail de l'ancien hôte est vivant, EVENT_SUBSCRIPTION_NOT_FOUND, EVENT_WRITE_FORBIDDEN hors de la session système."
PERMISSIONS FULL;
