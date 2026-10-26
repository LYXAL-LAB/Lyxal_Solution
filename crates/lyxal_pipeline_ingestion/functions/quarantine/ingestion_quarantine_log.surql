-- ============================================================================
-- FONCTION : fn::ingestion_quarantine_log
-- MODULE   : lyxal_pipeline_ingestion
-- RÔLE     : Consignation d'une anomalie typée dans la table de quarantaine
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::ingestion_quarantine_log($params: object) {
    LET $batch_id = <string> $params.batch_id;
    LET $raw_record_id = IF $params.raw_record_id != NONE { <string> $params.raw_record_id } ELSE { NONE };
    LET $code_erreur = <string> $params.code_erreur;
    LET $severite = IF $params.severite != NONE { <string> $params.severite } ELSE { "Error" };
    LET $champ_concerne = <string> $params.champ_concerne;
    LET $valeur_fautive = $params.valeur_fautive;
    LET $cause_detaillee = <string> $params.cause_detaillee;
    LET $language = IF $params.language != NONE { $params.language } ELSE { "fr" };

    LET $batch_rec = <record> string::concat('ingestion_batch:', $batch_id);
    LET $raw_rec = IF $raw_record_id != NONE { <record> string::concat('ingestion_raw_record:', $raw_record_id) } ELSE { NONE };

    LET $created = (CREATE ingestion_quarantine_record CONTENT {
        batch: $batch_rec,
        raw_record: $raw_rec,
        code_erreur: $code_erreur,
        severite: $severite,
        champ_concerne: $champ_concerne,
        valeur_fautive: $valeur_fautive,
        cause_detaillee: $cause_detaillee,
        created_at: time::now()
    });

    RETURN fn::result_ok(<string> $created[0].id);
} COMMENT "Consigne une anomalie typée avec sévérité, valeur fautive et cause détaillée en quarantaine";
