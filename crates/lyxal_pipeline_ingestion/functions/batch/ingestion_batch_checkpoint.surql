-- ============================================================================
-- FONCTION : fn::ingestion_batch_checkpoint
-- MODULE   : lyxal_pipeline_ingestion
-- RÔLE     : Point de reprise (checkpoint) du worker supervisé ; renouvelle la réservation du lot
-- APPEL    : interne (worker, une fois par bloc), entrées contrôlées par le moteur de lyxal_core
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::ingestion_batch_checkpoint($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            id: { pipeline: [{ rule: "record", options: { expected_table: "ingestion_batch" } }], required: true },
            cursor_offset: { pipeline: [{ rule: "integer", options: { min_value: 0 } }], required: true },
            total_lignes: { pipeline: [{ rule: "integer", options: { min_value: 0 } }], required: true },
            lignes_verifiees: { pipeline: [{ rule: "integer", options: { min_value: 0 } }], required: true },
            lignes_a_confirmer: { pipeline: [{ rule: "integer", options: { min_value: 0 } }], required: true },
            lignes_rejetees: { pipeline: [{ rule: "integer", options: { min_value: 0 } }], required: true },
            claim: { pipeline: [{ rule: "is_object" }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 10);
    IF !$report.valid {
        RETURN fn::error_result("INGESTION_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $id = { value: $p.id };

    -- Cloisonnement : seule l'exécution qui détient la réservation du lot écrit
    LET $held = fn::ingestion_batch_claim_verify({ batch_id: $id.value, claim: $report.value.claim, language: $p.language });
    IF !$held.ok { RETURN $held; };

    LET $updated = (UPDATE ONLY $id.value SET
        cursor_offset = $p.cursor_offset,
        total_lignes = $p.total_lignes,
        lignes_verifiees = $p.lignes_verifiees,
        lignes_a_confirmer = $p.lignes_a_confirmer,
        lignes_rejetees = $p.lignes_rejetees,
        last_checkpoint_at = time::now(),
        -- Renouvellement de la réservation : seulement pour le jeton et la génération en cours
        claim_until = time::now() + claim_ttl
        WHERE claim_owner = $p.claim.owner AND claim_generation = $p.claim.generation AND claim_until > time::now());
    IF $updated == NONE {
        RETURN fn::error_result("INGESTION_WRITE_FORBIDDEN", $p.language, { table: "ingestion_batch" });
    };

    RETURN fn::result_ok(true);
} COMMENT "Met à jour l'avancement d'un lot, horodate le point de reprise sur incident et renouvelle la réservation (claim { owner, generation } en cours, sinon INGESTION_BATCH_CLAIM_LOST)";
