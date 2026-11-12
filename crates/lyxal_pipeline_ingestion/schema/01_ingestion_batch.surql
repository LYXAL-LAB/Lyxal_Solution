-- ============================================================================
-- TABLE  : ingestion_batch
-- MODULE : lyxal_pipeline_ingestion
-- RÔLE   : Métadonnées, traçabilité et machine à états des lots d'ingestion fabricants
-- ============================================================================

DEFINE TABLE OVERWRITE ingestion_batch
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE fn::auth_has_permission({ permission: "ingestion.read" })
        FOR create WHERE fn::auth_has_permission({ permission: "ingestion.batch.write" })
        FOR update WHERE fn::auth_has_permission({ permission: "ingestion.batch.write" }) OR fn::auth_has_permission({ permission: "ingestion.staged.qualify" }) OR fn::auth_has_permission({ permission: "ingestion.manifest.approve" })
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

DEFINE FIELD OVERWRITE source_encoding ON TABLE ingestion_batch
    TYPE string
    DEFAULT "UTF-8"
    ASSERT $value IN ["UTF-8", "WINDOWS-1252", "ISO-8859-1"]
    COMMENT "Encodage déclaré du fichier source (jamais deviné), transmis à lyxal_parsing";

DEFINE FIELD OVERWRITE provenance_details ON TABLE ingestion_batch
    TYPE option<object> FLEXIBLE
    DEFAULT {}
    COMMENT "Détails techniques d'origine (headers, encodage, URI ou webhook source)";

DEFINE FIELD OVERWRITE fournisseur_id ON TABLE ingestion_batch
    TYPE string
    VALUE string::trim($value)
    ASSERT string::len($value) >= 1
    COMMENT "Identifiant canonique de l'émetteur ou du fabricant (ex: SAINT_GOBAIN_PLACO)";

DEFINE FIELD OVERWRITE source_object ON TABLE ingestion_batch
    TYPE record<storage_object>
    REFERENCE ON DELETE REJECT
    READONLY
    COMMENT "Fichier source du lot, conservé par lyxal_storage : tant que le lot existe, il ne se supprime pas (STORAGE_OBJECT_IN_USE)";

DEFINE FIELD OVERWRITE commercial_proof ON TABLE ingestion_batch
    TYPE option<object> FLEXIBLE
    READONLY
    COMMENT "Preuve commerciale jointe au lot à sa création (CommercialProof), appliquée à ses articles par le worker";

DEFINE FIELD OVERWRITE nom_fichier ON TABLE ingestion_batch
    TYPE string
    VALUE string::trim($value)
    COMMENT "Nom d'origine du fichier importé, lu sur la fiche du fichier source";

DEFINE FIELD OVERWRITE file_hash_blake3 ON TABLE ingestion_batch
    TYPE string
    VALUE string::lowercase(string::trim($value))
    ASSERT string::len($value) = 64
    COMMENT "Empreinte BLAKE3 du fichier source, lue sur sa fiche : idempotence globale, et contrôle des octets relus par le worker";

DEFINE FIELD OVERWRITE taille_octets ON TABLE ingestion_batch
    TYPE int
    ASSERT $value >= 0
    COMMENT "Taille en octets du fichier source, lue sur sa fiche";

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

DEFINE FIELD OVERWRITE sealed_manifest ON TABLE ingestion_batch
    TYPE option<string>
    COMMENT "Référence du manifeste qui fige le contenu publié du lot (posée au scellement, retirée à la remise en brouillon par fn::ingestion_manifest_save) : ses articles ne se créent ni ne se modifient plus";

-- ----------------------------------------------------------------------------
-- RÉSERVATION DU TRAITEMENT (un seul traitement à la fois, toutes instances confondues)
-- ----------------------------------------------------------------------------
DEFINE FIELD OVERWRITE claim_owner ON TABLE ingestion_batch
    TYPE option<string>
    COMMENT "Jeton de l'exécution de traitement qui réserve le lot (fn::ingestion_batch_claim), NONE si libre";

DEFINE FIELD OVERWRITE claim_generation ON TABLE ingestion_batch
    TYPE int
    DEFAULT 0
    ASSERT $value >= 0
    COMMENT "Génération de la réservation, incrémentée à chaque prise : une exécution écartée ne peut plus écrire";

DEFINE FIELD OVERWRITE claim_until ON TABLE ingestion_batch
    TYPE option<datetime>
    COMMENT "Échéance de la réservation (heure de la base), prolongée à chaque point de reprise";

DEFINE FIELD OVERWRITE claim_ttl ON TABLE ingestion_batch
    TYPE option<duration>
    COMMENT "Durée de la réservation choisie à la prise, réappliquée à chaque renouvellement";

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
    -- La génération de réservation ne recule jamais (une exécution écartée ne revient pas)
    IF $after.claim_generation < $before.claim_generation {
        THROW "INGESTION_BATCH_CLAIM_LOST: La génération de réservation d'un lot ne recule jamais.";
    };

    -- Le verrou du contenu scellé n'est posé ou retiré qu'avec la permission ingestion.manifest.approve
    -- (ou par la session système), au scellement et à la remise en brouillon d'un manifeste
    IF $before.sealed_manifest != $after.sealed_manifest AND !fn::auth_has_permission({ permission: "ingestion.manifest.approve" }) {
        THROW "INGESTION_STAGED_ITEM_SEALED: Le verrou du contenu scellé d'un lot ne se modifie que par le scellement ou la remise en brouillon d'un manifeste.";
    };

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
