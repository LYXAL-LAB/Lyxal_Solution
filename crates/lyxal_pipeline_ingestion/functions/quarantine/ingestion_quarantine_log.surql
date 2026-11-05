-- ============================================================================
-- FONCTION : fn::ingestion_quarantine_log
-- MODULE   : lyxal_pipeline_ingestion
-- RÔLE     : Consignation d'une anomalie typée dans la table de quarantaine
-- APPEL    : interne (worker, ligne à ligne), entrées contrôlées par les primitives de lyxal_core
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::ingestion_quarantine_log($params: object) {
    LET $batch = fn::validation_record($params.batch_id, "ingestion_batch");
    IF !$batch.valid { RETURN fn::error_result("INGESTION_INVALID_PARAMETERS", NONE, { field: "batch_id", reason: $batch.code }); };
    LET $checks = {
        ligne_numero: fn::validation_integer($params.ligne_numero, 1, NONE),
        code_erreur: fn::validation_required_string($params.code_erreur, 1, 128),
        severite: fn::validation_enum($params.severite ?? "ERROR", ["CRITICAL", "ERROR", "WARNING"], false),
        champ_concerne: fn::validation_required_string($params.champ_concerne, 1, 128),
        cause_detaillee: fn::validation_required_string($params.cause_detaillee, 1, 4000)
    };
    FOR $entry IN object::entries($checks) {
        IF !$entry[1].valid { RETURN fn::error_result("INGESTION_INVALID_PARAMETERS", NONE, { field: $entry[0], reason: $entry[1].code }); };
    };

    -- Ligne brute concernée : même convention que fn::ingestion_raw_records_save
    LET $raw = { value: type::record("ingestion_raw_record", string::concat(<string> record::id($batch.value), "_", <string> $checks.ligne_numero.value)) };

    -- Rejeu d'une ligne (reprise après incident) : l'anomalie ouverte déjà consignée est conservée
    LET $code = string::uppercase(string::trim($checks.code_erreur.value));
    LET $open = (SELECT VALUE id FROM ONLY ingestion_quarantine_record WHERE raw_record = $raw.value AND code_erreur = $code AND is_resolved = false LIMIT 1);
    IF $open != NONE {
        RETURN fn::result_ok(<string> record::id($open));
    };

    LET $created = (CREATE ONLY ingestion_quarantine_record CONTENT {
        batch: $batch.value,
        raw_record: $raw.value,
        ligne_numero: $checks.ligne_numero.value,
        code_erreur: $code,
        severite: $checks.severite.value,
        champ_concerne: $checks.champ_concerne.value,
        valeur_fautive: $params.valeur_fautive,
        cause_detaillee: $checks.cause_detaillee.value
    });
    IF $created == NONE {
        RETURN fn::error_result("INGESTION_WRITE_FORBIDDEN", NONE, { table: "ingestion_quarantine_record" });
    };

    RETURN fn::result_ok(<string> record::id($created.id));
} COMMENT "Consigne une anomalie typée (lot, numéro de ligne, code, sévérité, champ, valeur fautive, cause) en quarantaine ; rejouable : une anomalie ouverte de même ligne et de même code n'est pas dupliquée";
