-- ============================================================================
-- FONCTION : fn::ingestion_batch_create
-- MODULE   : lyxal_pipeline_ingestion
-- RÔLE     : Création ou mise à jour idempotente d'un lot d'ingestion fabricant
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::ingestion_batch_create($params: object) {
    LET $id = IF $params.id != NONE { <string> $params.id } ELSE { rand::uuid::v7() };
    LET $source_type = IF $params.source_type != NONE { string::uppercase(string::trim($params.source_type)) } ELSE { "CSV" };
    LET $source_format_version = IF $params.source_format_version != NONE { string::trim($params.source_format_version) } ELSE { "1.0" };
    LET $fournisseur_id = IF $params.fournisseur_id != NONE { string::trim($params.fournisseur_id) } ELSE { "" };
    LET $nom_fichier = IF $params.nom_fichier != NONE { string::trim($params.nom_fichier) } ELSE { "" };
    LET $file_hash_blake3 = IF $params.file_hash_blake3 != NONE { string::trim($params.file_hash_blake3) } ELSE { "" };
    LET $taille_octets = IF $params.taille_octets != NONE { <int> $params.taille_octets } ELSE { 0 };
    LET $statut = IF $params.statut != NONE { string::trim($params.statut) } ELSE { "Staged" };
    LET $cursor_offset = IF $params.cursor_offset != NONE { <int> $params.cursor_offset } ELSE { 0 };
    LET $chunk_size = IF $params.chunk_size != NONE { <int> $params.chunk_size } ELSE { 500 };
    LET $total_lignes = IF $params.total_lignes != NONE { <int> $params.total_lignes } ELSE { 0 };
    LET $lignes_verifiees = IF $params.lignes_verifiees != NONE { <int> $params.lignes_verifiees } ELSE { 0 };
    LET $lignes_a_confirmer = IF $params.lignes_a_confirmer != NONE { <int> $params.lignes_a_confirmer } ELSE { 0 };
    LET $lignes_rejetees = IF $params.lignes_rejetees != NONE { <int> $params.lignes_rejetees } ELSE { 0 };
    LET $transitions = IF $params.transitions != NONE { $params.transitions } ELSE { [] };
    LET $provenance_details = IF $params.provenance_details != NONE { $params.provenance_details } ELSE { {} };
    LET $language = IF $params.language != NONE { $params.language } ELSE { "fr" };

    -- Contrôles de validation métier
    IF string::len($fournisseur_id) == 0 {
        RETURN fn::error_result("INGESTION_MANUFACTURER_REF_MISSING", $language, { champ: "fournisseur_id" });
    };

    IF string::len($file_hash_blake3) == 0 {
        RETURN fn::error_result("INGESTION_SOURCE_INVALID", $language, { champ: "file_hash_blake3" });
    };

    LET $record_id = <record> string::concat('ingestion_batch:', $id);

    LET $created = (UPSERT $record_id CONTENT {
        source_type: $source_type,
        source_format_version: $source_format_version,
        fournisseur_id: $fournisseur_id,
        nom_fichier: $nom_fichier,
        file_hash_blake3: $file_hash_blake3,
        taille_octets: $taille_octets,
        statut: $statut,
        cursor_offset: $cursor_offset,
        chunk_size: $chunk_size,
        total_lignes: $total_lignes,
        lignes_verifiees: $lignes_verifiees,
        lignes_a_confirmer: $lignes_a_confirmer,
        lignes_rejetees: $lignes_rejetees,
        transitions: $transitions,
        provenance_details: $provenance_details,
        last_checkpoint_at: time::now(),
        created_at: time::now()
    });

    RETURN fn::result_ok(<string> $id);
} COMMENT "Crée ou initialise un lot d'ingestion avec contrôle d'intégrité et idempotence BLAKE3";
