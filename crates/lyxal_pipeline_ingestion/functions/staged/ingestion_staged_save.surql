-- ============================================================================
-- FONCTION : fn::ingestion_staged_save
-- MODULE   : lyxal_pipeline_ingestion
-- RÔLE     : Enregistrement d'un bloc d'articles normalisés et qualifiés en zone de staging
-- APPEL    : interne (worker, par bloc) : paramètres du bloc par le moteur de lyxal_core, articles par primitives
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::ingestion_staged_save($params: object) {
    -- 1. Paramètres du bloc, contrôlés une fois par le moteur de lyxal_core
    LET $report = fn::validation_object_execute($params, {
        fields: {
            batch_id: { pipeline: [{ rule: "record", options: { expected_table: "ingestion_batch" } }], required: true },
            rules_version: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 64 } }], required: true },
            items: { pipeline: [{ rule: "array_objects", options: { allow_empty_objects: false } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 10);
    IF !$report.valid {
        RETURN fn::error_result("INGESTION_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $batch = { value: $report.value.batch_id };
    LET $rules_version = { value: $report.value.rules_version };
    LET $items = { value: $report.value.items };
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
        -- Contrôles par primitive, article par article (appel ligne à ligne : option B)
        LET $ligne = fn::validation_integer($item.ligne_numero, 1, NONE);
        IF !$ligne.valid { RETURN fn::error_result("INGESTION_INVALID_PARAMETERS", NONE, { field: "ligne_numero", reason: $ligne.code }); };
        LET $fingerprint = fn::validation_required_string($item.canonical_fingerprint, 64, 64);
        IF !$fingerprint.valid { RETURN fn::error_result("INGESTION_INVALID_PARAMETERS", NONE, { field: "canonical_fingerprint", reason: $fingerprint.code }); };
        LET $libelle = fn::validation_required_string($item.libelle_commercial, 1, 500);
        IF !$libelle.valid { RETURN fn::error_result("INGESTION_INVALID_PARAMETERS", NONE, { field: "libelle_commercial", reason: $libelle.code }); };
        -- Unité absente tant qu'elle n'est pas résolue (anomalie consignée par le worker)
        LET $unite = IF $item.unite_reference != NONE { fn::validation_required_string($item.unite_reference, 1, 32) } ELSE { { valid: true, value: NONE } };
        IF !$unite.valid { RETURN fn::error_result("INGESTION_INVALID_PARAMETERS", NONE, { field: "unite_reference", reason: $unite.code }); };
        LET $type_item = fn::validation_enum($item.type_item ?? "PRODUIT", ["PRODUIT", "SERVICE", "OUVRAGE", "RESSOURCE", "ENSEMBLE"], false);
        IF !$type_item.valid { RETURN fn::error_result("INGESTION_INVALID_PARAMETERS", NONE, { field: "type_item", reason: $type_item.code }); };
        LET $qualif = fn::validation_enum($item.qualification ?? "TO_CONFIRM", ["VERIFIED", "TO_CONFIRM", "REJECTED"], false);
        IF !$qualif.valid { RETURN fn::error_result("INGESTION_INVALID_PARAMETERS", NONE, { field: "qualification", reason: $qualif.code }); };
        LET $action = fn::validation_enum($item.publication_action ?? "INSERT", ["INSERT", "UPDATE", "UNCHANGED", "DEPRECATE"], false);
        IF !$action.valid { RETURN fn::error_result("INGESTION_INVALID_PARAMETERS", NONE, { field: "publication_action", reason: $action.code }); };
        LET $marque = IF $item.marque != NONE { fn::validation_optional_string($item.marque, 1, 255) } ELSE { { valid: true } };
        IF !$marque.valid { RETURN fn::error_result("INGESTION_INVALID_PARAMETERS", NONE, { field: "marque", reason: $marque.code }); };
        LET $description = IF $item.description_technique != NONE { fn::validation_optional_string($item.description_technique, 1, 4000) } ELSE { { valid: true } };
        IF !$description.valid { RETURN fn::error_result("INGESTION_INVALID_PARAMETERS", NONE, { field: "description_technique", reason: $description.code }); };
        LET $motif = IF $item.qualification_reason != NONE { fn::validation_optional_string($item.qualification_reason, 1, 2000) } ELSE { { valid: true } };
        IF !$motif.valid { RETURN fn::error_result("INGESTION_INVALID_PARAMETERS", NONE, { field: "qualification_reason", reason: $motif.code }); };
        IF !type::is_object($item.conditionnement) { RETURN fn::error_result("INGESTION_INVALID_PARAMETERS", NONE, { field: "conditionnement", reason: "CORE_VALIDATION_TYPE" }); };
        IF ($item.commercial_proof != NONE AND !type::is_object($item.commercial_proof)) OR ($item.diff_payload != NONE AND !type::is_object($item.diff_payload)) {
            RETURN fn::error_result("INGESTION_INVALID_PARAMETERS", NONE, { field: IF $item.diff_payload != NONE AND !type::is_object($item.diff_payload) { "diff_payload" } ELSE { "commercial_proof" }, reason: "CORE_VALIDATION_TYPE" });
        };

        LET $line = $ligne.value;
        LET $qualification = string::uppercase($qualif.value);
        LET $reason = $motif.value;
        LET $content = {
            -- Ligne brute de l'article : même convention que fn::ingestion_raw_records_save
            raw_record: type::record("ingestion_raw_record", string::concat($batch_key, "_", <string> $line)),
            ligne_numero: $line,
            canonical_fingerprint: $fingerprint.value,
            rules_version: $rules_version.value,
            marque: $marque.value,
            code_barre_gtin: $gtin.value,
            libelle_commercial: $libelle.value,
            description_technique: $description.value,
            type_item: $type_item.value,
            unite_reference: $unite.value,
            conditionnement: $item.conditionnement,
            qualification: $qualification,
            qualification_reason: $reason,
            commercial_proof: $item.commercial_proof,
            publication_action: $action.value,
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
