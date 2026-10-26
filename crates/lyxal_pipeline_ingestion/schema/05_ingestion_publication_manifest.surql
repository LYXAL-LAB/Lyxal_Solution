-- ============================================================================
-- TABLE  : ingestion_publication_manifest
-- MODULE : lyxal_pipeline_ingestion
-- RÔLE   : Manifestes de publication scellés, versionnés et soumis à approbation formelle
-- ============================================================================

DEFINE TABLE OVERWRITE ingestion_publication_manifest
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE (
            ($token != NONE AND ($token.role IN ["steward_admin", "catalogue_sync_agent"]))
            OR ($auth != NONE AND ($auth.role IN ["steward_admin", "catalogue_sync_agent"]))
        )
        FOR create WHERE (
            ($token != NONE AND $token.role = "steward_admin" AND "ingestion:manifest:approve" IN $token.scope)
            OR ($auth != NONE AND $auth.role = "steward_admin" AND "ingestion:manifest:approve" IN $auth.permissions)
        )
        FOR update WHERE (
            ($token != NONE AND (
                ($token.role = "steward_admin" AND "ingestion:manifest:approve" IN $token.scope)
                OR ($token.role = "catalogue_sync_agent" AND "catalogue:sync:write" IN $token.scope)
            ))
            OR ($auth != NONE AND (
                ($auth.role = "steward_admin" AND "ingestion:manifest:approve" IN $auth.permissions)
                OR ($auth.role = "catalogue_sync_agent" AND "catalogue:sync:write" IN $auth.permissions)
            ))
        )
        FOR delete NONE
    COMMENT "Manifeste de publication scellé par BLAKE3, approuvé par le Data Steward et exécuté par l'agent de synchronisation";

-- ----------------------------------------------------------------------------
-- IDENTIFICATION ET SCELLEMENT CRYPTOGRAPHIQUE
-- ----------------------------------------------------------------------------
DEFINE FIELD OVERWRITE batch ON TABLE ingestion_publication_manifest
    TYPE record<ingestion_batch>
    REFERENCE
    COMMENT "Lot parent dont sont issus les articles";

DEFINE FIELD OVERWRITE manifest_ref ON TABLE ingestion_publication_manifest
    TYPE string
    VALUE string::trim($value)
    ASSERT string::len($value) >= 1
    COMMENT "Référence unique du manifeste (ex: MANIF-2026-PLACO-001)";

DEFINE FIELD OVERWRITE manifest_version ON TABLE ingestion_publication_manifest
    TYPE int
    DEFAULT 1
    ASSERT $value >= 1
    COMMENT "Version incrémentale du manifeste pour le lot";

DEFINE FIELD OVERWRITE seal_hash ON TABLE ingestion_publication_manifest
    TYPE string
    VALUE string::lowercase(string::trim($value))
    ASSERT string::len($value) = 64
    COMMENT "Empreinte de scellement BLAKE3 calculée sur l'ensemble ordonné des empreintes canoniques approuvées";

DEFINE FIELD OVERWRITE is_sealed ON TABLE ingestion_publication_manifest
    TYPE bool
    DEFAULT false
    COMMENT "Verrou de scellement : interdit toute modification des articles du manifeste";

-- ----------------------------------------------------------------------------
-- MACHINE À ÉTATS DU MANIFESTE
-- ----------------------------------------------------------------------------
DEFINE FIELD OVERWRITE statut ON TABLE ingestion_publication_manifest
    TYPE string
    DEFAULT "DRAFT"
    VALUE string::uppercase(string::trim($value))
    ASSERT $value IN ["DRAFT", "SEALED", "APPROVED", "EXECUTING", "COMMITTED", "FAILED"]
    COMMENT "État du manifeste : DRAFT -> SEALED -> APPROVED -> EXECUTING -> COMMITTED";

-- ----------------------------------------------------------------------------
-- APPROBATION EXPLICITE (ZÉRO AUTO-APPROBATION EN V1)
-- ----------------------------------------------------------------------------
DEFINE FIELD OVERWRITE approved_by ON TABLE ingestion_publication_manifest
    TYPE option<string>
    COMMENT "Identité du Data Steward ayant formellement approuvé la publication";

DEFINE FIELD OVERWRITE approved_at ON TABLE ingestion_publication_manifest
    TYPE option<datetime>
    COMMENT "Horodatage de l'approbation formelle";

DEFINE FIELD OVERWRITE approver_role ON TABLE ingestion_publication_manifest
    TYPE option<string>
    COMMENT "Rôle de l'approbateur (doit être steward_admin)";

-- ----------------------------------------------------------------------------
-- MÉTRIQUES ET TRAÇABILITÉ D'EXÉCUTION
-- ----------------------------------------------------------------------------
DEFINE FIELD OVERWRITE nb_articles_insert ON TABLE ingestion_publication_manifest
    TYPE int
    DEFAULT 0
    ASSERT $value >= 0
    COMMENT "Nombre d'articles prévus en création (INSERT)";

DEFINE FIELD OVERWRITE nb_articles_update ON TABLE ingestion_publication_manifest
    TYPE int
    DEFAULT 0
    ASSERT $value >= 0
    COMMENT "Nombre d'articles prévus en mise à jour (UPDATE)";

DEFINE FIELD OVERWRITE items_committed ON TABLE ingestion_publication_manifest
    TYPE int
    DEFAULT 0
    ASSERT $value >= 0
    COMMENT "Nombre d'articles effectivement injectés avec succès dans le Master Catalogue";

DEFINE FIELD OVERWRITE items_failed ON TABLE ingestion_publication_manifest
    TYPE int
    DEFAULT 0
    ASSERT $value >= 0
    COMMENT "Nombre d'articles ayant échoué lors de l'exécution";

DEFINE FIELD OVERWRITE execution_items ON TABLE ingestion_publication_manifest
    TYPE option<array<object>> FLEXIBLE
    DEFAULT []
    COMMENT "Journal d'audit détaillé de l'exécution ligne par ligne";

DEFINE FIELD OVERWRITE transitions ON TABLE ingestion_publication_manifest
    TYPE option<array<object>> FLEXIBLE
    DEFAULT []
    COMMENT "Journal d'audit des transitions d'état du manifeste";

DEFINE FIELD OVERWRITE created_at ON TABLE ingestion_publication_manifest
    TYPE datetime
    VALUE time::now()
    COMMENT "Date de création du manifeste";

DEFINE FIELD OVERWRITE executed_at ON TABLE ingestion_publication_manifest
    TYPE option<datetime>
    COMMENT "Date d'achèvement de l'exécution dans le Master Catalogue";

-- ----------------------------------------------------------------------------
-- INDEX D'IDEMPOTENCE ET TRAÇABILITÉ
-- ----------------------------------------------------------------------------
DEFINE INDEX OVERWRITE idx_manifest_batch_version ON TABLE ingestion_publication_manifest FIELDS batch, manifest_version UNIQUE;
DEFINE INDEX OVERWRITE idx_manifest_ref ON TABLE ingestion_publication_manifest FIELDS manifest_ref UNIQUE;
DEFINE INDEX OVERWRITE idx_manifest_statut ON TABLE ingestion_publication_manifest FIELDS statut;

-- ----------------------------------------------------------------------------
-- GARDIEN MOTEUR : Validation des transitions de manifeste et contrôles de sécurité
-- ----------------------------------------------------------------------------
DEFINE EVENT OVERWRITE evt_manifest_guard ON TABLE ingestion_publication_manifest
WHEN $event = "UPDATE"
THEN {
    -- 1. Validation de la machine à états
    IF $before.statut != $after.statut {
        LET $valid_m_trans = (
            ($before.statut = "DRAFT" AND ($after.statut = "SEALED" OR $after.statut = "FAILED"))
            OR ($before.statut = "SEALED" AND ($after.statut = "APPROVED" OR $after.statut = "DRAFT" OR $after.statut = "FAILED"))
            OR ($before.statut = "APPROVED" AND ($after.statut = "EXECUTING" OR $after.statut = "FAILED"))
            OR ($before.statut = "EXECUTING" AND ($after.statut = "COMMITTED" OR $after.statut = "FAILED"))
            OR ($before.statut = "FAILED" AND ($after.statut = "APPROVED" OR $after.statut = "DRAFT"))
        );

        IF $valid_m_trans != true {
            THROW "INGESTION_MANIFEST_ILLEGAL_STATE_TRANSITION: Transition de statut de manifeste interdite de " + $before.statut + " vers " + $after.statut + ".";
        };

        -- 2. Transition vers APPROVED : exige le scellement effectif et l'approbation explicite d'un steward_admin
        IF $after.statut = "APPROVED" {
            IF $after.is_sealed != true OR $after.seal_hash == NONE {
                THROW "INGESTION_MANIFEST_SEAL_REQUIRED: L'approbation requiert obligatoirement un manifeste préalablement scellé avec son empreinte BLAKE3.";
            };
            IF $after.approved_by == NONE OR $after.approver_role != "steward_admin" {
                THROW "INGESTION_MANIFEST_APPROVAL_REQUIRES_STEWARD: L'approbation d'un manifeste requiert formellement l'identité steward_admin (auto-approbation interdite).";
            };
        };

        -- 3. Transition vers EXECUTING / COMMITTED : réservée exclusivement à catalogue_sync_agent
        IF $after.statut = "EXECUTING" OR $after.statut = "COMMITTED" {
            LET $caller_role = IF $token != NONE AND $token.role != NONE { string::trim($token.role) } ELSE IF $auth != NONE AND $auth.role != NONE { string::trim($auth.role) } ELSE { NONE };
            IF $caller_role != "catalogue_sync_agent" {
                THROW "INGESTION_MANIFEST_EXECUTION_UNAUTHORIZED: Seul le service catalogue_sync_agent est habilité à exécuter la publication vers le Master Catalogue.";
            };
        };
    };
};
