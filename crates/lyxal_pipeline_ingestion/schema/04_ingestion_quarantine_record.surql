-- ============================================================================
-- TABLE  : ingestion_quarantine_record
-- MODULE : lyxal_pipeline_ingestion
-- RÔLE   : Zone de quarantaine et journal d'audit des anomalies rejetées
-- ============================================================================

DEFINE TABLE OVERWRITE ingestion_quarantine_record
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE (
            ($token != NONE AND ($token.role IN ["qualification_agent", "steward_admin"]))
            OR ($auth != NONE AND ($auth.role IN ["qualification_agent", "steward_admin"]))
        )
        FOR create WHERE (
            ($token != NONE AND $token.role = "qualification_agent" AND "ingestion:staged:qualify" IN $token.scope)
            OR ($auth != NONE AND $auth.role = "qualification_agent" AND "ingestion:staged:qualify" IN $auth.permissions)
        )
        FOR update WHERE (
            ($token != NONE AND $token.role = "steward_admin")
            OR ($auth != NONE AND $auth.role = "steward_admin")
        )
        FOR delete NONE
    COMMENT "Journal d'audit scellé des anomalies et rejets de qualification en quarantaine avec traçabilité d'arbitrage Data Steward";


DEFINE FIELD OVERWRITE batch ON TABLE ingestion_quarantine_record
    TYPE record<ingestion_batch>
    REFERENCE
    COMMENT "Lot parent propriétaire";

DEFINE FIELD OVERWRITE raw_record ON TABLE ingestion_quarantine_record
    TYPE record<ingestion_raw_record>
    REFERENCE
    COMMENT "Ligne brute source incriminée";

DEFINE FIELD OVERWRITE ligne_numero ON TABLE ingestion_quarantine_record
    TYPE int
    ASSERT $value >= 1
    COMMENT "Numéro d'index de ligne dans le fichier source";

DEFINE FIELD OVERWRITE code_erreur ON TABLE ingestion_quarantine_record
    TYPE string
    VALUE string::uppercase(string::trim($value))
    COMMENT "Code standardisé lyxal_error (ex: INGESTION_GTIN_INVALID, INGESTION_UNIT_UNRESOLVED)";

DEFINE FIELD OVERWRITE severite ON TABLE ingestion_quarantine_record
    TYPE string
    VALUE string::uppercase(string::trim($value))
    ASSERT $value IN ["CRITICAL", "ERROR", "WARNING"]
    COMMENT "Niveau de sévérité de l'anomalie";

DEFINE FIELD OVERWRITE champ_concerne ON TABLE ingestion_quarantine_record
    TYPE string
    VALUE string::trim($value)
    COMMENT "Nom de la colonne ou propriété fautive (ex: code_barre_gtin, unite_vente)";

DEFINE FIELD OVERWRITE valeur_fautive ON TABLE ingestion_quarantine_record
    TYPE any
    COMMENT "Valeur brute ou structurée ayant provoqué l'échec de validation";

DEFINE FIELD OVERWRITE cause_detaillee ON TABLE ingestion_quarantine_record
    TYPE string
    VALUE string::trim($value)
    COMMENT "Explication technique détaillée du motif de rejet en quarantaine";

DEFINE FIELD OVERWRITE created_at ON TABLE ingestion_quarantine_record
    TYPE datetime
    VALUE time::now()
    COMMENT "Horodatage de mise en quarantaine";

DEFINE FIELD OVERWRITE is_resolved ON TABLE ingestion_quarantine_record
    TYPE bool
    DEFAULT false
    COMMENT "Indicateur de résolution d'anomalie par le Data Steward";

DEFINE FIELD OVERWRITE resolved_by ON TABLE ingestion_quarantine_record
    TYPE option<string>
    COMMENT "Identifiant du Data Steward ayant résolu l'anomalie";

DEFINE FIELD OVERWRITE resolved_at ON TABLE ingestion_quarantine_record
    TYPE option<datetime>
    COMMENT "Date et heure de la résolution de l'anomalie";

DEFINE FIELD OVERWRITE resolution_comment ON TABLE ingestion_quarantine_record
    TYPE option<string>
    COMMENT "Justification formelle de l'arbitrage du Data Steward";


-- ----------------------------------------------------------------------------
-- INDEX DE RECHERCHE ET SUPERVISION
-- ----------------------------------------------------------------------------
DEFINE INDEX OVERWRITE idx_quarantine_batch_severite ON TABLE ingestion_quarantine_record FIELDS batch, severite;
DEFINE INDEX OVERWRITE idx_quarantine_code ON TABLE ingestion_quarantine_record FIELDS code_erreur;
