-- ============================================================================
-- FONCTION : fn::ingestion_staged_save
-- MODULE   : lyxal_pipeline_ingestion
-- RÔLE     : Enregistrement d'un bloc d'articles normalisés et qualifiés en zone de staging
-- APPEL    : interne (worker, par bloc), entrées contrôlées par les primitives de lyxal_core
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::ingestion_staged_save($params: object) {
    -- 1. Contexte commun au bloc, contrôlé une fois
    LET $batch = fn::validation_record($params.batch_id, "ingestion_batch");
    IF !$batch.valid { RETURN fn::error_result("INGESTION_INVALID_PARAMETERS", NONE, { field: "batch_id", reason: $batch.code }); };
    LET $rules_version = fn::validation_required_string($params.rules_version, 1, 64);
    IF !$rules_version.valid { RETURN fn::error_result("INGESTION_INVALID_PARAMETERS", NONE, { field: "rules_version", reason: $rules_version.code }); };
    LET $items = fn::validation_array_objects($params.items, false);
    IF !$items.valid { RETURN fn::error_result("INGESTION_INVALID_PARAMETERS", NONE, { field: "items", reason: $items.code }); };
    LET $batch_key = <string> record::id($batch.value);
    LET $operator = fn::ingestion_session_identity({}).operator;
    LET $now = time::now();

    -- 2. Chaque article : un refus (code-barres, champ) n'interrompt pas le bloc, son résultat
    -- porte l'erreur, que le worker consigne en quarantaine
    LET $results = $items.value.map(|$item| {
        LET $fabricant = fn::validation_required_string($item.fabricant, 1, 128);
        IF !$fabricant.valid { RETURN fn::error_result("INGESTION_MANUFACTURER_REF_MISSING", NONE, { field: "fabricant", reason: $fabricant.code }); };
        LET $reference = fn::validation_required_string($item.reference_fabricant, 1, 255);
        IF !$reference.valid { RETURN fn::error_result("INGESTION_MANUFACTURER_REF_MISSING", NONE, { field: "reference_fabricant", reason: $reference.code }); };
        LET $gtin = IF $item.code_barre_gtin != NONE { fn::validation_gtin($item.code_barre_gtin) } ELSE { { valid: true, value: NONE } };
        IF !$gtin.valid {
            RETURN fn::error_result("INGESTION_GTIN_INVALID", NONE, { field: "code_barre_gtin", value: $item.code_barre_gtin, reason: $gtin.code, details: $gtin.details });
        };
        LET $checks = {
            ligne_numero: fn::validation_integer($item.ligne_numero, 1, NONE),
            canonical_fingerprint: fn::validation_required_string($item.canonical_fingerprint, 64, 64),
            libelle_commercial: fn::validation_required_string($item.libelle_commercial, 1, 500),
            unite_reference: fn::validation_required_string($item.unite_reference, 1, 32),
            type_item: fn::validation_enum($item.type_item ?? "PRODUIT", ["PRODUIT", "SERVICE", "OUVRAGE", "RESSOURCE", "ENSEMBLE"], false),
            qualification: fn::validation_enum($item.qualification ?? "TO_CONFIRM", ["VERIFIED", "TO_CONFIRM", "REJECTED"], false),
            publication_action: fn::validation_enum($item.publication_action ?? "INSERT", ["INSERT", "UPDATE", "UNCHANGED", "DEPRECATE"], false),
            marque: IF $item.marque != NONE { fn::validation_optional_string($item.marque, 1, 255) } ELSE { { valid: true } },
            description_technique: IF $item.description_technique != NONE { fn::validation_optional_string($item.description_technique, 1, 4000) } ELSE { { valid: true } },
            qualification_reason: IF $item.qualification_reason != NONE { fn::validation_optional_string($item.qualification_reason, 1, 2000) } ELSE { { valid: true } }
        };
        LET $invalid = object::entries($checks).find(|$entry| !$entry[1].valid);
        IF $invalid != NONE { RETURN fn::error_result("INGESTION_INVALID_PARAMETERS", NONE, { field: $invalid[0], reason: $invalid[1].code }); };
        IF !type::is_object($item.conditionnement) { RETURN fn::error_result("INGESTION_INVALID_PARAMETERS", NONE, { field: "conditionnement", reason: "CORE_VALIDATION_TYPE" }); };
        IF ($item.commercial_proof != NONE AND !type::is_object($item.commercial_proof)) OR ($item.diff_payload != NONE AND !type::is_object($item.diff_payload)) {
            RETURN fn::error_result("INGESTION_INVALID_PARAMETERS", NONE, { field: IF $item.diff_payload != NONE AND !type::is_object($item.diff_payload) { "diff_payload" } ELSE { "commercial_proof" }, reason: "CORE_VALIDATION_TYPE" });
        };

        LET $line = $checks.ligne_numero.value;
        LET $qualification = string::uppercase($checks.qualification.value);
        LET $reason = $checks.qualification_reason.value;
        LET $content = {
            -- Ligne brute de l'article : même convention que fn::ingestion_raw_records_save
            raw_record: type::record("ingestion_raw_record", string::concat($batch_key, "_", <string> $line)),
            ligne_numero: $line,
            canonical_fingerprint: $checks.canonical_fingerprint.value,
            rules_version: $rules_version.value,
            marque: $checks.marque.value,
            code_barre_gtin: $gtin.value,
            libelle_commercial: $checks.libelle_commercial.value,
            description_technique: $checks.description_technique.value,
            type_item: $checks.type_item.value,
            unite_reference: $checks.unite_reference.value,
            conditionnement: $item.conditionnement,
            qualification: $qualification,
            qualification_reason: $reason,
            commercial_proof: $item.commercial_proof,
            publication_action: $checks.publication_action.value,
            diff_payload: $item.diff_payload
        };
        LET $transition = { to_state: $qualification, triggered_by: $operator, reason: $reason ?? "Qualification automatique", transitioned_at: $now };

        -- Clé métier unique (index idx_staged_business_id) : lot, fabricant, référence fabricant
        LET $existing = (SELECT id, qualification, transitions FROM ONLY ingestion_staged_item WHERE batch = $batch.value AND fabricant = $fabricant.value AND reference_fabricant = $reference.value LIMIT 1);
        IF $existing != NONE {
            LET $transitions = IF $existing.qualification != $qualification {
                array::append($existing.transitions ?? [], object::extend($transition, { from_state: $existing.qualification }))
            } ELSE { $existing.transitions ?? [] };
            LET $updated = (UPDATE ONLY $existing.id MERGE object::extend($content, { transitions: $transitions }));
            RETURN IF $updated == NONE { fn::error_result("INGESTION_WRITE_FORBIDDEN", NONE, { table: "ingestion_staged_item" }) } ELSE { fn::result_ok(<string> record::id($existing.id)) };
        };
        LET $created = (CREATE ONLY ingestion_staged_item CONTENT object::extend($content, {
            batch: $batch.value,
            fabricant: $fabricant.value,
            reference_fabricant: $reference.value,
            transitions: [object::extend($transition, { from_state: NONE })],
            is_approved: false
        }));
        RETURN IF $created == NONE { fn::error_result("INGESTION_WRITE_FORBIDDEN", NONE, { table: "ingestion_staged_item" }) } ELSE { fn::result_ok(<string> record::id($created.id)) };
    });

    -- 3. Une écriture interdite concerne tout le bloc et l'arrête
    LET $forbidden = $results.find(|$r| !$r.ok AND $r.error.code == "INGESTION_WRITE_FORBIDDEN");
    IF $forbidden != NONE {
        RETURN $forbidden;
    };
    RETURN fn::result_ok($results.map(|$r| { ok: $r.ok, id: $r.data, error: $r.error }));
} COMMENT "Enregistre un bloc d'articles d'un lot ({ batch_id, rules_version, items }) de façon idempotente (clé : lot, fabricant, référence) ; code-barres contrôlé par fn::validation_gtin (INGESTION_GTIN_INVALID) ; renvoie dans l'ordre le résultat de chaque article ({ ok, id, error }) ; une écriture interdite arrête le bloc (INGESTION_WRITE_FORBIDDEN)";
