-- ============================================================================
-- TABLE  : ingestion_staged_item
-- MODULE : lyxal_pipeline_ingestion
-- RÔLE   : Zone de staging des articles normalisés, qualifiés et préparés
-- ============================================================================

DEFINE TABLE OVERWRITE ingestion_staged_item
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE (
            ($token != NONE AND ($token.role IN ["qualification_agent", "steward_admin", "catalogue_sync_agent"]))
            OR ($auth != NONE AND ($auth.role IN ["qualification_agent", "steward_admin", "catalogue_sync_agent"]))
        )
        FOR create WHERE (
            ($token != NONE AND $token.role = "qualification_agent" AND "ingestion:staged:qualify" IN $token.scope)
            OR ($auth != NONE AND $auth.role = "qualification_agent" AND "ingestion:staged:qualify" IN $auth.permissions)
        )
        FOR update WHERE (
            ($token != NONE AND (
                ($token.role = "qualification_agent" AND "ingestion:staged:qualify" IN $token.scope)
                OR ($token.role = "steward_admin" AND "ingestion:manifest:approve" IN $token.scope)
            ))
            OR ($auth != NONE AND (
                ($auth.role = "qualification_agent" AND "ingestion:staged:qualify" IN $auth.permissions)
                OR ($auth.role = "steward_admin" AND "ingestion:manifest:approve" IN $auth.permissions)
            ))
        )
        FOR delete NONE
    COMMENT "Articles normalisés en staging avec triptyque de qualification et empreinte canonique";

-- ----------------------------------------------------------------------------
-- RATTACHEMENT ET TRAÇABILITÉ DE LOT
-- ----------------------------------------------------------------------------
DEFINE FIELD OVERWRITE batch ON TABLE ingestion_staged_item
    TYPE record<ingestion_batch>
    REFERENCE
    COMMENT "Lot parent propriétaire";

DEFINE FIELD OVERWRITE raw_record ON TABLE ingestion_staged_item
    TYPE record<ingestion_raw_record>
    REFERENCE
    COMMENT "Ligne brute source associée";

DEFINE FIELD OVERWRITE ligne_numero ON TABLE ingestion_staged_item
    TYPE int
    ASSERT $value >= 1
    COMMENT "Numéro de ligne d'origine";

-- ----------------------------------------------------------------------------
-- IDENTITÉ MÉTIER DU FABRICANT
-- ----------------------------------------------------------------------------
DEFINE FIELD OVERWRITE fabricant ON TABLE ingestion_staged_item
    TYPE string
    VALUE string::uppercase(string::trim($value))
    ASSERT string::len($value) >= 1 AND string::len($value) <= 128
    COMMENT "Nom normalisé du fabricant ou de la raison sociale";

DEFINE FIELD OVERWRITE marque ON TABLE ingestion_staged_item
    TYPE option<string>
    VALUE IF $value != NONE { string::uppercase(string::trim($value)) } ELSE { NONE }
    COMMENT "Marque commerciale éventuelle";

DEFINE FIELD OVERWRITE reference_fabricant ON TABLE ingestion_staged_item
    TYPE string
    VALUE string::uppercase(string::trim($value))
    ASSERT string::len($value) >= 1 AND string::len($value) <= 64
    COMMENT "Référence catalogue usine du fabricant";

DEFINE FIELD OVERWRITE code_barre_gtin ON TABLE ingestion_staged_item
    TYPE option<string>
    VALUE IF $value != NONE { string::trim($value) } ELSE { NONE }
    COMMENT "Code GTIN/EAN-13 mondial éventuel";

-- ----------------------------------------------------------------------------
-- SPÉCIFICATIONS TECHNIQUES & COMMERCIALES
-- ----------------------------------------------------------------------------
DEFINE FIELD OVERWRITE libelle_commercial ON TABLE ingestion_staged_item
    TYPE string
    VALUE string::trim($value)
    ASSERT string::len($value) >= 1 AND string::len($value) <= 256
    COMMENT "Désignation commerciale normalisée de l'article";

DEFINE FIELD OVERWRITE description_technique ON TABLE ingestion_staged_item
    TYPE option<string>
    VALUE IF $value != NONE { string::trim($value) } ELSE { NONE }
    COMMENT "Descriptif technique détaillé";

DEFINE FIELD OVERWRITE type_item ON TABLE ingestion_staged_item
    TYPE string
    DEFAULT "PRODUIT"
    VALUE string::uppercase(string::trim($value))
    ASSERT $value IN ["PRODUIT", "SERVICE", "OUVRAGE", "RESSOURCE", "ENSEMBLE"]
    COMMENT "Type fondamental de l'article";

DEFINE FIELD OVERWRITE unite_reference ON TABLE ingestion_staged_item
    TYPE string
    VALUE string::uppercase(string::trim($value))
    ASSERT string::len($value) >= 1 AND string::len($value) <= 32
    COMMENT "Code de l'unité de vente rapprochée de base_unite (ex: PCE, M2, ML)";

DEFINE FIELD OVERWRITE conditionnement ON TABLE ingestion_staged_item
    TYPE object FLEXIBLE
    COMMENT "Détails physiques normalisés du conditionnement (quantité, poids, dimensions)";

-- ----------------------------------------------------------------------------
-- EMPREINTE CANONIQUE & VERSION DES RÈGLES
-- ----------------------------------------------------------------------------
DEFINE FIELD OVERWRITE canonical_fingerprint ON TABLE ingestion_staged_item
    TYPE string
    VALUE string::lowercase(string::trim($value))
    ASSERT string::len($value) = 64
    COMMENT "Empreinte canonique BLAKE3 calculée sur les données normalisées";

DEFINE FIELD OVERWRITE rules_version ON TABLE ingestion_staged_item
    TYPE string
    DEFAULT "1.0.0"
    COMMENT "Version des règles de validation et de normalisation appliquées";

-- ----------------------------------------------------------------------------
-- TRIPTYQUE DE QUALIFICATION COMMERCIALE & TECHNIQUE
-- ----------------------------------------------------------------------------
DEFINE FIELD OVERWRITE qualification ON TABLE ingestion_staged_item
    TYPE string
    DEFAULT "TO_CONFIRM"
    VALUE string::uppercase(string::trim($value))
    ASSERT $value IN ["VERIFIED", "TO_CONFIRM", "REJECTED"]
    COMMENT "Triptyque : VERIFIED (100% conforme et provenance avérée), TO_CONFIRM (arbitrage requis), REJECTED";

DEFINE FIELD OVERWRITE qualification_reason ON TABLE ingestion_staged_item
    TYPE option<string>
    COMMENT "Motif explicatif de la qualification attribuée";

DEFINE FIELD OVERWRITE publication_action ON TABLE ingestion_staged_item
    TYPE string
    DEFAULT "INSERT"
    VALUE string::uppercase(string::trim($value))
    ASSERT $value IN ["INSERT", "UPDATE", "UNCHANGED", "DEPRECATE"]
    COMMENT "Action différentielle calculée par rapport au Master Catalogue";

DEFINE FIELD OVERWRITE diff_payload ON TABLE ingestion_staged_item
    TYPE option<object> FLEXIBLE
    COMMENT "Diff champ par champ si action = UPDATE";

DEFINE FIELD OVERWRITE transitions ON TABLE ingestion_staged_item
    TYPE option<array<object>> FLEXIBLE
    DEFAULT []
    COMMENT "Historique d'audit des changements de qualification";

DEFINE FIELD OVERWRITE commercial_proof ON TABLE ingestion_staged_item
    TYPE option<object> FLEXIBLE
    COMMENT "Preuve commerciale formelle authentifiée (CommercialProof) pour statut VERIFIED";


-- ----------------------------------------------------------------------------
-- APPROBATION DU DATA STEWARD (AUCUNE AUTO-APPROBATION EN V1)
-- ----------------------------------------------------------------------------
DEFINE FIELD OVERWRITE is_approved ON TABLE ingestion_staged_item
    TYPE bool
    DEFAULT false
    COMMENT "Indicateur d'approbation explicite par un Data Steward";

DEFINE FIELD OVERWRITE approved_by ON TABLE ingestion_staged_item
    TYPE option<string>
    COMMENT "Identifiant de l'approbateur (ex: steward_admin)";

DEFINE FIELD OVERWRITE approved_at ON TABLE ingestion_staged_item
    TYPE option<datetime>
    COMMENT "Date et heure de l'approbation formelle";

DEFINE FIELD OVERWRITE approver_role ON TABLE ingestion_staged_item
    TYPE option<string>
    COMMENT "Rôle de l'approbateur lors de la décision";

DEFINE FIELD OVERWRITE created_at ON TABLE ingestion_staged_item
    TYPE datetime
    VALUE time::now();

DEFINE FIELD OVERWRITE updated_at ON TABLE ingestion_staged_item
    TYPE datetime
    VALUE time::now();

-- ----------------------------------------------------------------------------
-- INDEX D'IDEMPOTENCE ET D'INTÉGRITÉ MÉTIER
-- ----------------------------------------------------------------------------
-- Unicité stricte du numéro de ligne par lot
DEFINE INDEX OVERWRITE idx_staged_batch_line ON TABLE ingestion_staged_item FIELDS batch, ligne_numero UNIQUE;

-- Unicité métier : un fabricant ne peut avoir deux fois la même référence usine dans un même lot
DEFINE INDEX OVERWRITE idx_staged_business_id ON TABLE ingestion_staged_item FIELDS batch, fabricant, reference_fabricant UNIQUE;

-- Recherche par empreinte canonique
DEFINE INDEX OVERWRITE idx_staged_fingerprint ON TABLE ingestion_staged_item FIELDS batch, canonical_fingerprint;

-- Filtrage par statut de qualification
DEFINE INDEX OVERWRITE idx_staged_qualif ON TABLE ingestion_staged_item FIELDS batch, qualification;

-- ----------------------------------------------------------------------------
-- GARDIEN MOTEUR : Validation des transitions de qualification et verrou d'approbation
-- ----------------------------------------------------------------------------
DEFINE EVENT OVERWRITE evt_staged_guard ON TABLE ingestion_staged_item
WHEN $event = "UPDATE"
THEN {
    -- 1. Contrôle des transitions de qualification
    IF $before.qualification != $after.qualification {
        LET $valid_q_trans = (
            ($before.qualification = "TO_CONFIRM" AND ($after.qualification = "VERIFIED" OR $after.qualification = "REJECTED"))
            OR ($before.qualification = "REJECTED" AND $after.qualification = "TO_CONFIRM")
            OR ($before.qualification = "VERIFIED" AND ($after.qualification = "TO_CONFIRM" OR $after.qualification = "REJECTED"))
        );
        IF $valid_q_trans != true {
            THROW "INGESTION_STAGED_ILLEGAL_QUALIFICATION_TRANSITION: Transition de qualification interdite de " + $before.qualification + " vers " + $after.qualification + ".";
        };
    };

    -- 2. Verrouillage d'approbation : seuls les articles VERIFIED peuvent être approuvés par un steward_admin
    IF $before.is_approved = false AND $after.is_approved = true {
        IF $after.qualification != "VERIFIED" {
            THROW "INGESTION_STAGED_CANNOT_APPROVE_NON_VERIFIED: Seul un article au statut VERIFIED peut être approuvé pour publication.";
        };
        IF $after.approved_by == NONE OR $after.approver_role != "steward_admin" {
            THROW "INGESTION_STAGED_APPROVAL_REQUIRES_STEWARD: L'approbation requiert formellement l'identité et le rôle steward_admin (auto-approbation interdite).";
        };
    };
};
