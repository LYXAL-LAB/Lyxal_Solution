-- ============================================================================
-- FONCTION : fn::ingestion_batch_pending_list
-- MODULE   : lyxal_pipeline_ingestion
-- RÔLE     : Lots à traiter par le worker (la file de travail est dans la base)
-- APPEL    : interne (worker, à chaque passage), entrées contrôlées par le moteur de lyxal_core
-- ============================================================================
-- Un lot est à traiter s'il est reçu ou en cours (RECEIVED, PARSING, VALIDATING) et qu'aucune
-- exécution ne le réserve : après un arrêt du serveur, un lot interrompu réapparaît ici dès que
-- sa réservation a expiré, et reprend à son dernier point de reprise. Un lot en échec (FAILED)
-- n'est repris qu'après sa remise à RECEIVED (fn::ingestion_batch_transition).

DEFINE FUNCTION OVERWRITE fn::ingestion_batch_pending_list($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            limit: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 1000 } }], default: 20 },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 10);
    IF !$report.valid {
        RETURN fn::error_result("INGESTION_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::auth_has_permission({ permission: "ingestion.batch.write" }) {
        RETURN fn::error_result("INGESTION_UNAUTHORIZED", $p.language, { permission: "ingestion.batch.write" });
    };
    LET $now = time::now();
    LET $rows = (SELECT id, created_at FROM ingestion_batch
        WHERE statut IN ["RECEIVED", "PARSING", "VALIDATING"]
            AND (claim_owner IS NONE OR claim_until IS NONE OR claim_until <= $now)
        ORDER BY created_at, id LIMIT $p.limit);
    RETURN fn::result_ok({ items: $rows.map(|$row| <string> record::id($row.id)) });
} COMMENT "Lots à traiter ({ limit (20) }) : reçus ou en cours (RECEIVED, PARSING, VALIDATING) sans réservation en cours, du plus ancien au plus récent ; { items: [identifiants] }. Droit : ingestion.batch.write";
