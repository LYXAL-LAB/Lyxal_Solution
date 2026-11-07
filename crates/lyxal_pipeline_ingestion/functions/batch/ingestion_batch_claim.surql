-- ============================================================================
-- FONCTION : fn::ingestion_batch_claim
-- MODULE   : lyxal_pipeline_ingestion
-- RÔLE     : Réservation d'un lot par une exécution de traitement (exclusion entre exécutions,
--            workers et instances)
-- APPEL    : interne (worker, au début de chaque traitement), entrées contrôlées par le moteur de lyxal_core
-- ============================================================================
-- La réservation n'est prise que si le lot est libre ou si la réservation précédente a expiré :
-- une réservation active est refusée, même présentée avec le même jeton (la prise n'est jamais
-- un renouvellement). La génération est incrémentée : une exécution écartée ne peut plus rien
-- écrire (fn::ingestion_batch_claim_verify). Échéances calculées avec l'heure de la base.

DEFINE FUNCTION OVERWRITE fn::ingestion_batch_claim($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            id: { pipeline: [{ rule: "record", options: { expected_table: "ingestion_batch" } }], required: true },
            owner: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 128 } }], required: true },
            ttl_seconds: { pipeline: [{ rule: "integer", options: { min_value: 5, max_value: 600 } }], default: 60 },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 10);
    IF !$report.valid {
        RETURN fn::error_result("INGESTION_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $now = time::now();
    LET $ttl = <duration> string::concat(<string> $p.ttl_seconds, "s");

    LET $current = (SELECT claim_owner, claim_generation, claim_until FROM ONLY $p.id);
    IF $current == NONE {
        RETURN fn::error_result("INGESTION_BATCH_NOT_FOUND", $p.language, { batch_id: <string> record::id($p.id) });
    };
    IF $current.claim_owner != NONE AND $current.claim_until != NONE AND $current.claim_until > $now {
        RETURN fn::error_result("INGESTION_BATCH_ALREADY_CLAIMED", $p.language, { batch_id: <string> record::id($p.id), until: $current.claim_until });
    };

    -- Prise conditionnelle : échoue si une autre exécution a pris le lot entre-temps
    LET $generation = $current.claim_generation + 1;
    LET $claimed = (UPDATE ONLY $p.id SET
        claim_owner = $p.owner,
        claim_generation = $generation,
        claim_until = $now + $ttl,
        claim_ttl = $ttl
        WHERE claim_generation = $current.claim_generation);
    IF $claimed == NONE {
        LET $after = (SELECT VALUE claim_generation FROM ONLY $p.id);
        RETURN IF $after != $current.claim_generation {
            fn::error_result("INGESTION_BATCH_ALREADY_CLAIMED", $p.language, { batch_id: <string> record::id($p.id) })
        } ELSE {
            fn::error_result("INGESTION_WRITE_FORBIDDEN", $p.language, { table: "ingestion_batch" })
        };
    };
    RETURN fn::result_ok({ generation: $generation, until: $claimed.claim_until });
} COMMENT "Réserve un lot pour une exécution de traitement (owner : jeton propre à l'exécution) si le lot est libre ou si la réservation précédente a expiré ; une réservation active est refusée même avec le même jeton (INGESTION_BATCH_ALREADY_CLAIMED) ; renvoie { generation, until }";
