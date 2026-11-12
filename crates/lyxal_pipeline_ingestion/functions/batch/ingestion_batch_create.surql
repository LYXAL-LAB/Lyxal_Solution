-- ============================================================================
-- FONCTION : fn::ingestion_batch_create
-- MODULE   : lyxal_pipeline_ingestion
-- RÔLE     : Création d'un lot d'ingestion (état initial RECEIVED) sur un fichier de lyxal_storage
-- APPEL    : une fois par lot, après l'envoi du fichier ; entrées contrôlées par le moteur de lyxal_core
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::ingestion_batch_create($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            id: { pipeline: [{ rule: "record", options: { expected_table: "ingestion_batch" } }] },
            source_type: { pipeline: [{ rule: "enum", options: { allowed: ["FAB_DIS", "CSV", "XML", "JSON"], case_sensitive: false } }], required: true },
            source_object: { pipeline: [{ rule: "record", options: { expected_table: "storage_object" } }], required: true },
            fournisseur_id: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 128 } }], required: true },
            source_format_version: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 64 } }], default: "1.0" },
            source_encoding: { pipeline: [{ rule: "enum", options: { allowed: ["UTF-8", "WINDOWS-1252", "ISO-8859-1"], case_sensitive: false } }], default: "UTF-8" },
            chunk_size: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 100000 } }], default: 500 },
            provenance_details: { pipeline: [{ rule: "is_object" }], default: {} },
            commercial_proof: { pipeline: [{ rule: "is_object" }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        LET $fields = object::keys($report.by_field);
        LET $code = IF "source_type" IN $fields OR "source_object" IN $fields OR "source_encoding" IN $fields { "INGESTION_SOURCE_INVALID" }
            ELSE IF "fournisseur_id" IN $fields { "INGESTION_MANUFACTURER_REF_MISSING" }
            ELSE { "INGESTION_INVALID_PARAMETERS" };
        RETURN fn::error_result($code, IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    -- Codes de format et d'encodage normalisés par lyxal_core
    LET $p = fn::sanitize_object_execute($report.value, {
        fields: { source_type: { pipeline: [{ rule: "uppercase" }] }, source_encoding: { pipeline: [{ rule: "uppercase" }] } },
        unknown_keys: "keep"
    }, 10);
    -- Identifiant fourni, sinon UUID v7 en clé texte (même forme que les identifiants fournis)
    LET $id = $p.id ?? type::record("ingestion_batch", <string> rand::uuid::v7());

    -- Fichier source : fiche lue par la fonction publique de lyxal_storage, sous les droits de
    -- l'appelant ; seul un fichier disponible est accepté. Son nom, sa taille et son empreinte
    -- viennent de la fiche.
    LET $file = fn::storage_object_get({ object: <string> $p.source_object });
    IF !$file.ok OR $file.data.state != "available" {
        RETURN fn::error_result("INGESTION_SOURCE_NOT_AVAILABLE", $p.language, {
            source_object: <string> $p.source_object,
            cause: IF $file.ok { $file.data.state } ELSE { $file.error.code }
        });
    };

    -- Idempotence : un même fichier (format + empreinte) ou un même identifiant n'est reçu qu'une fois
    LET $hash = $file.data.blake3;
    LET $source = $p.source_type;
    LET $existing = (SELECT VALUE id FROM ingestion_batch WHERE (source_type = $source AND file_hash_blake3 = $hash) OR id = $id LIMIT 1);
    IF array::len($existing) > 0 {
        RETURN fn::error_result("INGESTION_BATCH_DUPLICATE", $p.language, { batch_id: <string> record::id($existing[0]), file_hash_blake3: $hash });
    };

    LET $operator = fn::ingestion_operator({});
    LET $created = (CREATE ONLY $id CONTENT {
        source_type: $source,
        source_format_version: $p.source_format_version,
        source_encoding: $p.source_encoding,
        fournisseur_id: $p.fournisseur_id,
        source_object: $p.source_object,
        commercial_proof: $p.commercial_proof,
        nom_fichier: $file.data.filename,
        file_hash_blake3: $hash,
        taille_octets: $file.data.size,
        statut: "RECEIVED",
        chunk_size: $p.chunk_size,
        provenance_details: $p.provenance_details,
        transitions: [{ from_state: NONE, to_state: "RECEIVED", triggered_by: $operator, reason: "Réception du fichier", transitioned_at: time::now() }],
        last_checkpoint_at: time::now()
    });
    IF $created == NONE {
        RETURN fn::error_result("INGESTION_WRITE_FORBIDDEN", $p.language, { table: "ingestion_batch" });
    };

    RETURN fn::result_ok(<string> record::id($created.id));
} COMMENT "Crée un lot d'ingestion à l'état RECEIVED sur un fichier conservé par lyxal_storage ({ source_object, source_type, fournisseur_id, id, source_format_version, source_encoding (UTF-8 par défaut, WINDOWS-1252, ISO-8859-1), chunk_size, provenance_details, commercial_proof }) : le nom, la taille et l'empreinte BLAKE3 sont lus sur la fiche du fichier, qui doit être disponible (INGESTION_SOURCE_NOT_AVAILABLE) ; un fichier déjà reçu (format et empreinte) ou un identifiant déjà pris est refusé (INGESTION_BATCH_DUPLICATE). Droits : ingestion.batch.write, et lecture du fichier dans lyxal_storage";
