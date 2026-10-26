-- ============================================================================
-- TABLE  : ingestion_raw_record
-- MODULE : lyxal_pipeline_ingestion
-- RÔLE   : Zone tampon brute immuable garantissant la traçabilité intégrale
-- ============================================================================

DEFINE TABLE OVERWRITE ingestion_raw_record
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE (
            ($token != NONE AND ($token.role IN ["ingestion_agent", "qualification_agent", "steward_admin"]))
            OR ($auth != NONE AND ($auth.role IN ["ingestion_agent", "qualification_agent", "steward_admin"]))
        )
        FOR create WHERE (
            ($token != NONE AND $token.role = "ingestion_agent" AND "ingestion:batch:write" IN $token.scope)
            OR ($auth != NONE AND $auth.role = "ingestion_agent" AND "ingestion:batch:write" IN $auth.permissions)
        )
        FOR update, delete NONE
    COMMENT "Enregistrements bruts extraits de la source, scellés et immuables";

DEFINE FIELD OVERWRITE batch ON TABLE ingestion_raw_record
    TYPE record<ingestion_batch>
    REFERENCE
    COMMENT "Lot d'ingestion parent";

DEFINE FIELD OVERWRITE ligne_numero ON TABLE ingestion_raw_record
    TYPE int
    ASSERT $value >= 1
    COMMENT "Numéro d'index de ligne dans le fichier source d'origine";

DEFINE FIELD OVERWRITE row_hash ON TABLE ingestion_raw_record
    TYPE string
    VALUE string::lowercase(string::trim($value))
    ASSERT string::len($value) = 64
    COMMENT "Empreinte BLAKE3 de la ligne source brute";

DEFINE FIELD OVERWRITE payload_brut ON TABLE ingestion_raw_record
    TYPE object FLEXIBLE
    COMMENT "Contenu JSON brut avant toute transformation";

DEFINE FIELD OVERWRITE created_at ON TABLE ingestion_raw_record
    TYPE datetime
    VALUE time::now()
    COMMENT "Date d'ingestion de la ligne brute";

-- ----------------------------------------------------------------------------
-- INDEX D'IDEMPOTENCE ET TRAÇABILITÉ
-- ----------------------------------------------------------------------------
-- Unicité stricte du numéro de ligne par lot
DEFINE INDEX OVERWRITE idx_raw_batch_line ON TABLE ingestion_raw_record FIELDS batch, ligne_numero UNIQUE;

-- Recherche par empreinte de ligne
DEFINE INDEX OVERWRITE idx_raw_batch_row_hash ON TABLE ingestion_raw_record FIELDS batch, row_hash;
