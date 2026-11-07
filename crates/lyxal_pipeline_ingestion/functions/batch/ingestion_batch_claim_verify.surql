-- ============================================================================
-- FONCTION : fn::ingestion_batch_claim_verify
-- MODULE   : lyxal_pipeline_ingestion
-- RÔLE     : Cloisonnement des écritures du traitement : le lot doit être réservé par cette
--            exécution (jeton et génération), réservation non expirée
-- APPEL    : interne (fonctions d'écriture du traitement, dans la même requête que leur
--            écriture, après validation de leurs paramètres), contrôles par primitives de lyxal_core
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::ingestion_batch_claim_verify($params: object) {
    LET $owner = fn::validation_required_string($params.claim.owner, 1, 128);
    IF !$owner.valid {
        RETURN fn::error_result("INGESTION_INVALID_PARAMETERS", $params.language, { fields: { "claim.owner": [$owner.code] } });
    };
    LET $generation = fn::validation_integer($params.claim.generation, 1, NONE);
    IF !$generation.valid {
        RETURN fn::error_result("INGESTION_INVALID_PARAMETERS", $params.language, { fields: { "claim.generation": [$generation.code] } });
    };
    LET $batch = (SELECT claim_owner, claim_generation, claim_until FROM ONLY $params.batch_id);
    IF $batch == NONE {
        RETURN fn::error_result("INGESTION_BATCH_NOT_FOUND", $params.language, { batch_id: <string> record::id($params.batch_id) });
    };
    IF $batch.claim_owner != $owner.value OR $batch.claim_generation != $generation.value OR $batch.claim_until == NONE OR $batch.claim_until <= time::now() {
        RETURN fn::error_result("INGESTION_BATCH_CLAIM_LOST", $params.language, { batch_id: <string> record::id($params.batch_id) });
    };
    RETURN fn::result_ok(true);
} COMMENT "Vérifie que le lot est réservé par l'exécution claim { owner, generation } et que la réservation n'a pas expiré ; sinon INGESTION_BATCH_CLAIM_LOST (l'écriture appelante n'a pas lieu)";
