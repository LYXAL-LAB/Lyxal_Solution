-- ============================================================================
-- FONCTION : fn::ingestion_batch_create
-- MODULE   : lyxal_pipeline_ingestion
-- RÔLE     : Création d'un lot d'ingestion (état initial RECEIVED)
-- APPEL    : interne (worker), entrées contrôlées par les primitives de lyxal_core
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::ingestion_batch_create($params: object) {
    LET $id = IF $params.id != NONE { fn::validation_record($params.id, "ingestion_batch") } ELSE { { valid: true, value: type::record("ingestion_batch", rand::uuid::v7()) } };
    IF !$id.valid { RETURN fn::error_result("INGESTION_INVALID_PARAMETERS", NONE, { field: "id", reason: $id.code }); };
    LET $source_type = fn::validation_enum($params.source_type, ["FAB_DIS", "CSV", "XML", "JSON"], false);
    IF !$source_type.valid { RETURN fn::error_result("INGESTION_SOURCE_INVALID", NONE, { field: "source_type", reason: $source_type.code }); };
    LET $file_hash = fn::validation_required_string($params.file_hash_blake3, 64, 64);
    IF !$file_hash.valid { RETURN fn::error_result("INGESTION_SOURCE_INVALID", NONE, { field: "file_hash_blake3", reason: $file_hash.code }); };
    LET $fournisseur = fn::validation_required_string($params.fournisseur_id, 1, 128);
    IF !$fournisseur.valid { RETURN fn::error_result("INGESTION_MANUFACTURER_REF_MISSING", NONE, { field: "fournisseur_id", reason: $fournisseur.code }); };
    LET $nom_fichier = fn::validation_required_string($params.nom_fichier, 1, 255);
    IF !$nom_fichier.valid { RETURN fn::error_result("INGESTION_INVALID_PARAMETERS", NONE, { field: "nom_fichier", reason: $nom_fichier.code }); };
    LET $version = fn::validation_optional_string($params.source_format_version, 1, 64);
    IF !$version.valid { RETURN fn::error_result("INGESTION_INVALID_PARAMETERS", NONE, { field: "source_format_version", reason: $version.code }); };
    LET $taille = IF $params.taille_octets != NONE { fn::validation_integer($params.taille_octets, 0, NONE) } ELSE { { valid: true, value: 0 } };
    IF !$taille.valid { RETURN fn::error_result("INGESTION_INVALID_PARAMETERS", NONE, { field: "taille_octets", reason: $taille.code }); };
    LET $chunk_size = IF $params.chunk_size != NONE { fn::validation_integer($params.chunk_size, 1, 100000) } ELSE { { valid: true, value: 500 } };
    IF !$chunk_size.valid { RETURN fn::error_result("INGESTION_INVALID_PARAMETERS", NONE, { field: "chunk_size", reason: $chunk_size.code }); };
    IF $params.provenance_details != NONE AND !type::is_object($params.provenance_details) {
        RETURN fn::error_result("INGESTION_INVALID_PARAMETERS", NONE, { field: "provenance_details", reason: "CORE_VALIDATION_TYPE" });
    };

    -- Idempotence : un même fichier (format + empreinte) ou un même identifiant n'est reçu qu'une fois
    LET $hash = string::lowercase($file_hash.value);
    LET $source = string::uppercase($source_type.value);
    LET $existing = (SELECT VALUE id FROM ingestion_batch WHERE (source_type = $source AND file_hash_blake3 = $hash) OR id = $id.value LIMIT 1);
    IF array::len($existing) > 0 {
        RETURN fn::error_result("INGESTION_BATCH_DUPLICATE", NONE, { batch_id: <string> record::id($existing[0]), file_hash_blake3: $hash });
    };

    LET $who = fn::ingestion_session_identity({});
    LET $created = (CREATE ONLY $id.value CONTENT {
        source_type: $source,
        source_format_version: $version.value ?? "1.0",
        fournisseur_id: $fournisseur.value,
        nom_fichier: $nom_fichier.value,
        file_hash_blake3: $hash,
        taille_octets: $taille.value,
        statut: "RECEIVED",
        chunk_size: $chunk_size.value,
        provenance_details: $params.provenance_details ?? {},
        transitions: [{ from_state: NONE, to_state: "RECEIVED", triggered_by: $who.operator, reason: "Réception du fichier", transitioned_at: time::now() }],
        last_checkpoint_at: time::now()
    });
    IF $created == NONE {
        RETURN fn::error_result("INGESTION_WRITE_FORBIDDEN", NONE, { table: "ingestion_batch" });
    };

    RETURN fn::result_ok(<string> record::id($created.id));
} COMMENT "Crée un lot d'ingestion à l'état RECEIVED ; un fichier déjà reçu (format et empreinte BLAKE3) ou un identifiant existant renvoie INGESTION_BATCH_DUPLICATE";
