-- ============================================================================
-- FONCTION : fn::ingestion_raw_records_save
-- MODULE   : lyxal_pipeline_ingestion
-- RÔLE     : Enregistrement d'un bloc de lignes brutes d'un lot (zone tampon immuable)
-- APPEL    : interne (worker, par bloc) : paramètres du bloc par le moteur de lyxal_core, lignes par primitives
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::ingestion_raw_records_save($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            batch_id: { pipeline: [{ rule: "record", options: { expected_table: "ingestion_batch" } }], required: true },
            records: { pipeline: [{ rule: "array_objects", options: { allow_empty_objects: false } }], required: true },
            claim: { pipeline: [{ rule: "is_object" }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 10);
    IF !$report.valid {
        RETURN fn::error_result("INGESTION_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $batch = { value: $report.value.batch_id };
    LET $records = { value: $report.value.records };
    LET $batch_key = <string> record::id($batch.value);

    -- Cloisonnement : seule l'exécution qui détient la réservation du lot écrit
    LET $held = fn::ingestion_batch_claim_verify({ batch_id: $batch.value, claim: $report.value.claim, language: $report.value.language });
    IF !$held.ok { RETURN $held; };

    FOR $record IN $records.value {
        LET $line = fn::validation_integer($record.ligne_numero, 1, NONE);
        IF !$line.valid { RETURN fn::error_result("INGESTION_INVALID_PARAMETERS", NONE, { field: "records.ligne_numero", reason: $line.code }); };
        LET $row_hash = fn::validation_required_string($record.row_hash, 64, 64);
        IF !$row_hash.valid { RETURN fn::error_result("INGESTION_INVALID_PARAMETERS", NONE, { field: "records.row_hash", ligne_numero: $line.value, reason: $row_hash.code }); };
        IF !type::is_object($record.payload_brut) {
            RETURN fn::error_result("INGESTION_INVALID_PARAMETERS", NONE, { field: "records.payload_brut", ligne_numero: $line.value, reason: "CORE_VALIDATION_TYPE" });
        };
    };

    -- Ligne immuable : une ligne déjà enregistrée (reprise après incident) est conservée telle quelle
    LET $rows = $records.value.map(|$r| {
        id: type::record("ingestion_raw_record", string::concat($batch_key, "_", <string> $r.ligne_numero)),
        batch: $batch.value,
        ligne_numero: $r.ligne_numero,
        row_hash: $r.row_hash,
        payload_brut: $r.payload_brut
    });
    LET $existing = (SELECT VALUE id FROM $rows.map(|$r| $r.id));
    LET $new = $rows.filter(|$r| $r.id NOT IN $existing);
    IF array::len($new) > 0 {
        LET $created = (INSERT INTO ingestion_raw_record $new);
        IF array::len($created) != array::len($new) {
            RETURN fn::error_result("INGESTION_WRITE_FORBIDDEN", NONE, { table: "ingestion_raw_record" });
        };
    };

    RETURN fn::result_ok(array::len($new));
} COMMENT "Enregistre un bloc de lignes brutes ({ batch_id, records: [{ ligne_numero, row_hash, payload_brut }] }) ; identifiant <lot>_<ligne>, une ligne existante n'est jamais réécrite ; renvoie le nombre de lignes créées ; écriture réservée à l'exécution qui détient le lot (claim { owner, generation }, sinon INGESTION_BATCH_CLAIM_LOST)";
