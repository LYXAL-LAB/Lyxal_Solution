-- ============================================================================
-- FONCTION : fn::ingestion_batch_create
-- MODULE   : lyxal_pipeline_ingestion
-- RÔLE     : Création d'un lot d'ingestion (état initial RECEIVED)
-- APPEL    : interne (worker, une fois par lot), entrées contrôlées par le moteur de lyxal_core
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::ingestion_batch_create($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            id: { pipeline: [{ rule: "record", options: { expected_table: "ingestion_batch" } }] },
            source_type: { pipeline: [{ rule: "enum", options: { allowed: ["FAB_DIS", "CSV", "XML", "JSON"], case_sensitive: false } }], required: true },
            file_hash_blake3: { pipeline: [{ rule: "required_string", options: { min_length: 64, max_length: 64 } }], required: true },
            fournisseur_id: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 128 } }], required: true },
            nom_fichier: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 255 } }], required: true },
            source_format_version: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 64 } }], default: "1.0" },
            source_encoding: { pipeline: [{ rule: "enum", options: { allowed: ["UTF-8", "WINDOWS-1252", "ISO-8859-1"], case_sensitive: false } }], default: "UTF-8" },
            taille_octets: { pipeline: [{ rule: "integer", options: { min_value: 0 } }], default: 0 },
            chunk_size: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 100000 } }], default: 500 },
            provenance_details: { pipeline: [{ rule: "is_object" }], default: {} },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        LET $fields = object::keys($report.by_field);
        LET $code = IF "source_type" IN $fields OR "file_hash_blake3" IN $fields OR "source_encoding" IN $fields { "INGESTION_SOURCE_INVALID" }
            ELSE IF "fournisseur_id" IN $fields { "INGESTION_MANUFACTURER_REF_MISSING" }
            ELSE { "INGESTION_INVALID_PARAMETERS" };
        RETURN fn::error_result($code, IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    -- Identifiant fourni, sinon UUID v7 en clé texte (même forme que les identifiants fournis)
    LET $id = $p.id ?? type::record("ingestion_batch", <string> rand::uuid::v7());

    -- Idempotence : un même fichier (format + empreinte) ou un même identifiant n'est reçu qu'une fois
    LET $hash = string::lowercase(string::trim($p.file_hash_blake3));
    LET $source = string::uppercase($p.source_type);
    LET $existing = (SELECT VALUE id FROM ingestion_batch WHERE (source_type = $source AND file_hash_blake3 = $hash) OR id = $id LIMIT 1);
    IF array::len($existing) > 0 {
        RETURN fn::error_result("INGESTION_BATCH_DUPLICATE", $p.language, { batch_id: <string> record::id($existing[0]), file_hash_blake3: $hash });
    };

    LET $who = fn::ingestion_session_identity({});
    LET $created = (CREATE ONLY $id CONTENT {
        source_type: $source,
        source_format_version: $p.source_format_version,
        source_encoding: string::uppercase($p.source_encoding),
        fournisseur_id: $p.fournisseur_id,
        nom_fichier: $p.nom_fichier,
        file_hash_blake3: $hash,
        taille_octets: $p.taille_octets,
        statut: "RECEIVED",
        chunk_size: $p.chunk_size,
        provenance_details: $p.provenance_details,
        transitions: [{ from_state: NONE, to_state: "RECEIVED", triggered_by: $who.operator, reason: "Réception du fichier", transitioned_at: time::now() }],
        last_checkpoint_at: time::now()
    });
    IF $created == NONE {
        RETURN fn::error_result("INGESTION_WRITE_FORBIDDEN", $p.language, { table: "ingestion_batch" });
    };

    RETURN fn::result_ok(<string> record::id($created.id));
} COMMENT "Crée un lot d'ingestion à l'état RECEIVED avec l'encodage déclaré de sa source (UTF-8 par défaut, WINDOWS-1252, ISO-8859-1) ; un fichier déjà reçu (format et empreinte BLAKE3) ou un identifiant existant renvoie INGESTION_BATCH_DUPLICATE";
