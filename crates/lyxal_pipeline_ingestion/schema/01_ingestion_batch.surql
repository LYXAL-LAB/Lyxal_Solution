-- ============================================================================
-- TABLE  : ingestion_batch
-- MODULE : lyxal_pipeline_ingestion
-- RÔLE   : Métadonnées, traçabilité et machine à états des lots d'ingestion fabricants
-- ============================================================================

DEFINE TABLE OVERWRITE ingestion_batch
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE (
            ($token != NONE AND ($token.role IN ["ingestion_agent", "qualification_agent", "steward_admin", "catalogue_sync_agent"]))
            OR ($auth != NONE AND ($auth.role IN ["ingestion_agent", "qualification_agent", "steward_admin", "catalogue_sync_agent"]))
        )
        FOR create WHERE (
            ($token != NONE AND $token.role = "ingestion_agent" AND "ingestion:batch:write" IN $token.scope)
            OR ($auth != NONE AND $auth.role = "ingestion_agent" AND "ingestion:batch:write" IN $auth.permissions)
        )
        FOR update WHERE (
            ($token != NONE AND (
                ($token.role = "ingestion_agent" AND "ingestion:batch:write" IN $token.scope)
                OR ($token.role = "qualification_agent" AND "ingestion:staged:qualify" IN $token.scope)
                OR ($token.role = "steward_admin" AND "ingestion:manifest:approve" IN $token.scope)
            ))
            OR ($auth != NONE AND (
                ($auth.role = "ingestion_agent" AND "ingestion:batch:write" IN $auth.permissions)
                OR ($auth.role = "qualification_agent" AND "ingestion:staged:qualify" IN $auth.permissions)
                OR ($auth.role = "steward_admin" AND "ingestion:manifest:approve" IN $auth.permissions)
            ))
        )
        FOR delete NONE
    COMMENT "Lots d'ingestion fabricants avec traçabilité, empreinte globale et checkpointing";

-- ----------------------------------------------------------------------------
-- PROVENANCE & IDENTIFICATION DU FLUX
-- ----------------------------------------------------------------------------
DEFINE FIELD OVERWRITE source_type ON TABLE ingestion_batch
    TYPE string
    VALUE string::uppercase(string::trim($value))
    ASSERT $value IN ["FAB_DIS", "CSV", "XML", "JSON"]
    COMMENT "Type de format source";

DEFINE FIELD OVERWRITE source_format_version ON TABLE ingestion_batch
    TYPE string
    VALUE string::trim($value)
    COMMENT "Version déclarée du format source (ex: FAB-DIS 3.0, BMEcat 2005)";

DEFINE FIELD OVERWRITE provenance_details ON TABLE ingestion_batch
    TYPE option<object> FLEXIBLE
    DEFAULT {}
    COMMENT "Détails techniques d'origine (headers, encodage, URI ou webhook source)";

DEFINE FIELD OVERWRITE fournisseur_id ON TABLE ingestion_batch
    TYPE string
    VALUE string::trim($value)
    ASSERT string::len($value) >= 1
    COMMENT "Identifiant canonique de l'émetteur ou du fabricant (ex: SAINT_GOBAIN_PLACO)";

DEFINE FIELD OVERWRITE nom_fichier ON TABLE ingestion_batch
    TYPE string
    VALUE string::trim($value)
    COMMENT "Nom d'origine du fichier importé";

DEFINE FIELD OVERWRITE file_hash_blake3 ON TABLE ingestion_batch
    TYPE string
    VALUE string::lowercase(string::trim($value))
    ASSERT string::len($value) = 64
    COMMENT "Empreinte cryptographique BLAKE3 du fichier brut assurant l'idempotence globale";

DEFINE FIELD OVERWRITE taille_octets ON TABLE ingestion_batch
    TYPE int
    ASSERT $value >= 0
    COMMENT "Taille en octets du flux ou fichier reçu";

-- ----------------------------------------------------------------------------
-- MACHINE À ÉTATS & CHECKPOINTING
-- ----------------------------------------------------------------------------
DEFINE FIELD OVERWRITE statut ON TABLE ingestion_batch
    TYPE string
    DEFAULT "RECEIVED"
    VALUE string::uppercase(string::trim($value))
    ASSERT $value IN ["RECEIVED", "PARSING", "VALIDATING", "STAGED", "PUBLISHED", "FAILED"]
    COMMENT "État du lot dans la machine à états d'ingestion";

DEFINE FIELD OVERWRITE cursor_offset ON TABLE ingestion_batch
    TYPE int
    DEFAULT 0
    ASSERT $value >= 0
    COMMENT "Offset de streaming pour reprise idempotente sur interruption";

DEFINE FIELD OVERWRITE chunk_size ON TABLE ingestion_batch
    TYPE int
    DEFAULT 500
    ASSERT $value >= 1
    COMMENT "Taille des blocs transactionnels de traitement";

DEFINE FIELD OVERWRITE last_checkpoint_at ON TABLE ingestion_batch
    TYPE option<datetime>
    COMMENT "Horodatage du dernier checkpoint validé";

-- ----------------------------------------------------------------------------
-- MÉTRIQUES DE QUALIFICATION DU LOT
-- ----------------------------------------------------------------------------
DEFINE FIELD OVERWRITE total_lignes ON TABLE ingestion_batch
    TYPE int
    DEFAULT 0
    ASSERT $value >= 0
    COMMENT "Nombre total de lignes extraites";

DEFINE FIELD OVERWRITE lignes_verifiees ON TABLE ingestion_batch
    TYPE int
    DEFAULT 0
    ASSERT $value >= 0
    COMMENT "Nombre d'articles qualifiés VERIFIED";

DEFINE FIELD OVERWRITE lignes_a_confirmer ON TABLE ingestion_batch
    TYPE int
    DEFAULT 0
    ASSERT $value >= 0
    COMMENT "Nombre d'articles orientés en TO_CONFIRM";

DEFINE FIELD OVERWRITE lignes_rejetees ON TABLE ingestion_batch
    TYPE int
    DEFAULT 0
    ASSERT $value >= 0
    COMMENT "Nombre d'articles rejetés en quarantaine";

DEFINE FIELD OVERWRITE transitions ON TABLE ingestion_batch
    TYPE option<array<object>> FLEXIBLE
    DEFAULT []
    COMMENT "Journal d'audit horodaté des transitions d'état du lot";

DEFINE FIELD OVERWRITE created_at ON TABLE ingestion_batch
    TYPE datetime
    VALUE time::now()
    COMMENT "Date de réception du lot";

DEFINE FIELD OVERWRITE completed_at ON TABLE ingestion_batch
    TYPE option<datetime>
    COMMENT "Date d'achèvement de l'ingestion ou du staging";

-- ----------------------------------------------------------------------------
-- INDEX D'IDEMPOTENCE ET DE RECHERCHE
-- ----------------------------------------------------------------------------
-- Idempotence absolue : un même fichier pour un même format ne peut être réimporté en doublon
DEFINE INDEX OVERWRITE idx_batch_source_file_hash ON TABLE ingestion_batch FIELDS source_type, file_hash_blake3 UNIQUE;

-- Recherche par fournisseur et statut
DEFINE INDEX OVERWRITE idx_batch_fournisseur_statut ON TABLE ingestion_batch FIELDS fournisseur_id, statut;

-- ----------------------------------------------------------------------------
-- GARDIEN MOTEUR : Validation des transitions de la machine à états de lot
-- ----------------------------------------------------------------------------
DEFINE EVENT OVERWRITE evt_batch_guard ON TABLE ingestion_batch
WHEN $event = "UPDATE"
THEN {
    IF $before.statut != $after.statut {
        LET $is_valid_trans = (
            ($before.statut = "RECEIVED" AND ($after.statut = "PARSING" OR $after.statut = "FAILED"))
            OR ($before.statut = "PARSING" AND ($after.statut = "VALIDATING" OR $after.statut = "FAILED"))
            OR ($before.statut = "VALIDATING" AND ($after.statut = "STAGED" OR $after.statut = "FAILED"))
            OR ($before.statut = "STAGED" AND ($after.statut = "PUBLISHED" OR $after.statut = "FAILED"))
            OR ($before.statut = "FAILED" AND ($after.statut = "RECEIVED" OR $after.statut = "PARSING"))
        );

        IF $is_valid_trans != true {
            THROW "INGESTION_BATCH_ILLEGAL_STATE_TRANSITION: Transition de statut de lot interdite de " + $before.statut + " vers " + $after.statut + ".";
        };
    };
};
