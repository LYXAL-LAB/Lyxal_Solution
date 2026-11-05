-- ============================================================================
-- FONCTION : fn::ingestion_raw_records_save
-- MODULE   : lyxal_pipeline_ingestion
-- RÔLE     : Enregistrement d'un bloc de lignes brutes d'un lot (zone tampon immuable)
-- APPEL    : interne (worker, par bloc), entrées contrôlées par les primitives de lyxal_core
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::ingestion_raw_records_save($params: object) {
    LET $batch = fn::validation_record($params.batch_id, "ingestion_batch");
    IF !$batch.valid { RETURN fn::error_result("INGESTION_INVALID_PARAMETERS", NONE, { field: "batch_id", reason: $batch.code }); };
    LET $records = fn::validation_array_objects($params.records, false);
    IF !$records.valid { RETURN fn::error_result("INGESTION_INVALID_PARAMETERS", NONE, { field: "records", reason: $records.code }); };
    LET $batch_key = <string> record::id($batch.value);

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
} COMMENT "Enregistre un bloc de lignes brutes ({ batch_id, records: [{ ligne_numero, row_hash, payload_brut }] }) ; identifiant <lot>_<ligne>, une ligne existante n'est jamais réécrite ; renvoie le nombre de lignes créées";
