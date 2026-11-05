-- ============================================================================
-- FONCTION : fn::ingestion_quarantine_log
-- MODULE   : lyxal_pipeline_ingestion
-- RÔLE     : Consignation d'une anomalie typée dans la table de quarantaine
-- APPEL    : interne (worker, pour chaque anomalie), entrées contrôlées par le moteur de lyxal_core
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::ingestion_quarantine_log($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            batch_id: { pipeline: [{ rule: "record", options: { expected_table: "ingestion_batch" } }], required: true },
            ligne_numero: { pipeline: [{ rule: "integer", options: { min_value: 1 } }], required: true },
            code_erreur: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 128 } }], required: true },
            severite: { pipeline: [{ rule: "enum", options: { allowed: ["CRITICAL", "ERROR", "WARNING"], case_sensitive: false } }], default: "ERROR" },
            champ_concerne: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 128 } }], required: true },
            valeur_fautive: { pipeline: [] },
            cause_detaillee: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 4000 } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("INGESTION_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = fn::sanitize_object_execute($report.value, {
        fields: { code_erreur: { pipeline: [{ rule: "trim" }, { rule: "uppercase" }] }, severite: { pipeline: [{ rule: "uppercase" }] } },
        unknown_keys: "keep"
    }, 10);
    LET $batch = { value: $p.batch_id };

    -- Ligne brute concernée : même convention que fn::ingestion_raw_records_save
    LET $raw = { value: type::record("ingestion_raw_record", string::concat(<string> record::id($batch.value), "_", <string> $p.ligne_numero)) };

    -- Rejeu d'une ligne (reprise après incident) : l'anomalie ouverte déjà consignée est conservée
    LET $code = $p.code_erreur;
    LET $open = (SELECT VALUE id FROM ONLY ingestion_quarantine_record WHERE raw_record = $raw.value AND code_erreur = $code AND is_resolved = false LIMIT 1);
    IF $open != NONE {
        RETURN fn::result_ok(<string> record::id($open));
    };

    LET $created = (CREATE ONLY ingestion_quarantine_record CONTENT {
        batch: $batch.value,
        raw_record: $raw.value,
        ligne_numero: $p.ligne_numero,
        code_erreur: $code,
        severite: $p.severite,
        champ_concerne: $p.champ_concerne,
        valeur_fautive: $p.valeur_fautive,
        cause_detaillee: $p.cause_detaillee
    });
    IF $created == NONE {
        RETURN fn::error_result("INGESTION_WRITE_FORBIDDEN", $p.language, { table: "ingestion_quarantine_record" });
    };

    RETURN fn::result_ok(<string> record::id($created.id));
} COMMENT "Consigne une anomalie typée (lot, numéro de ligne, code, sévérité, champ, valeur fautive, cause) en quarantaine ; rejouable : une anomalie ouverte de même ligne et de même code n'est pas dupliquée";
