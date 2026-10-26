-- ============================================================================
-- FONCTION : fn::ingestion_staged_save
-- MODULE   : lyxal_pipeline_ingestion
-- RÔLE     : Enregistrement d'un article normalisé et qualifié en zone de staging
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::ingestion_staged_save($params: object) {
    LET $batch_id = <string> $params.batch_id;
    LET $raw_record_id = IF $params.raw_record_id != NONE { <string> $params.raw_record_id } ELSE { NONE };
    LET $ligne_numero = <int> $params.ligne_numero;
    LET $canonical_fingerprint = <string> $params.canonical_fingerprint;
    LET $rules_version = IF $params.rules_version != NONE { <string> $params.rules_version } ELSE { "1.0" };
    LET $fabricant = <string> $params.fabricant;
    LET $marque = IF $params.marque != NONE { <string> $params.marque } ELSE { NONE };
    LET $reference_fabricant = <string> $params.reference_fabricant;
    LET $code_barre_gtin = IF $params.code_barre_gtin != NONE { <string> $params.code_barre_gtin } ELSE { NONE };
    LET $libelle_commercial = <string> $params.libelle_commercial;
    LET $description_technique = IF $params.description_technique != NONE { <string> $params.description_technique } ELSE { NONE };
    LET $type_item = IF $params.type_item != NONE { <string> $params.type_item } ELSE { "PRODUIT" };
    LET $unite_reference = <string> $params.unite_reference;
    LET $conditionnement = IF $params.conditionnement != NONE { $params.conditionnement } ELSE { NONE };
    LET $qualification = IF $params.qualification != NONE { <string> $params.qualification } ELSE { "ToConfirm" };
    LET $publication_action = IF $params.publication_action != NONE { <string> $params.publication_action } ELSE { "Insert" };
    LET $diff_payload = IF $params.diff_payload != NONE { $params.diff_payload } ELSE { NONE };
    LET $transitions = IF $params.transitions != NONE { $params.transitions } ELSE { [] };
    LET $is_approved = IF $params.is_approved != NONE { <bool> $params.is_approved } ELSE { false };
    LET $approved_by = IF $params.approved_by != NONE { <string> $params.approved_by } ELSE { NONE };
    LET $approved_at = IF $params.approved_at != NONE { <datetime> $params.approved_at } ELSE { NONE };
    LET $language = IF $params.language != NONE { $params.language } ELSE { "fr" };

    IF string::len($fabricant) == 0 {
        RETURN fn::error_result("INGESTION_MANUFACTURER_REF_MISSING", $language, { champ: "fabricant" });
    };

    IF string::len($reference_fabricant) == 0 {
        RETURN fn::error_result("INGESTION_MANUFACTURER_REF_MISSING", $language, { champ: "reference_fabricant" });
    };

    LET $batch_rec = <record> string::concat('ingestion_batch:', $batch_id);
    LET $raw_rec = IF $raw_record_id != NONE { <record> string::concat('ingestion_raw_record:', $raw_record_id) } ELSE { NONE };

    LET $existing = (SELECT id FROM ingestion_staged_item WHERE batch = $batch_rec AND reference_fabricant = $reference_fabricant);
    IF array::len($existing) > 0 {
        LET $target_id = $existing[0].id;
        UPDATE $target_id SET
            raw_record = $raw_rec,
            ligne_numero = $ligne_numero,
            canonical_fingerprint = $canonical_fingerprint,
            rules_version = $rules_version,
            fabricant = $fabricant,
            marque = $marque,
            code_barre_gtin = $code_barre_gtin,
            libelle_commercial = $libelle_commercial,
            description_technique = $description_technique,
            type_item = $type_item,
            unite_reference = $unite_reference,
            conditionnement = $conditionnement,
            qualification = $qualification,
            publication_action = $publication_action,
            diff_payload = $diff_payload,
            transitions = $transitions,
            is_approved = $is_approved,
            approved_by = $approved_by,
            approved_at = $approved_at;
        RETURN fn::result_ok(<string> $target_id);
    } ELSE {
        LET $created = (CREATE ingestion_staged_item CONTENT {
            batch: $batch_rec,
            raw_record: $raw_rec,
            ligne_numero: $ligne_numero,
            canonical_fingerprint: $canonical_fingerprint,
            rules_version: $rules_version,
            fabricant: $fabricant,
            marque: $marque,
            reference_fabricant: $reference_fabricant,
            code_barre_gtin: $code_barre_gtin,
            libelle_commercial: $libelle_commercial,
            description_technique: $description_technique,
            type_item: $type_item,
            unite_reference: $unite_reference,
            conditionnement: $conditionnement,
            qualification: $qualification,
            publication_action: $publication_action,
            diff_payload: $diff_payload,
            transitions: $transitions,
            is_approved: $is_approved,
            approved_by: $approved_by,
            approved_at: $approved_at
        });
        RETURN fn::result_ok(<string> $created[0].id);
    };
} COMMENT "Enregistre un article en staging de façon idempotente avec ses métadonnées de qualification et son empreinte canonique";
