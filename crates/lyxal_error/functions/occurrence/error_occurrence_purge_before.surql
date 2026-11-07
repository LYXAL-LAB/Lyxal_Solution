-- ============================================================================
-- LYXAL OS — LYXAL_ERROR
-- ============================================================================
-- Fichier  : crates/lyxal_error/functions/occurrence/error_occurrence_purge_before.surql
-- Fonction : fn::error_occurrence_purge_before
--
-- Supprime les occurrences antérieures à une date (rétention technique) et
-- renvoie leur nombre.
--
-- Paramètres
--   before_date (requis, datetime), language
--
-- Valeur renvoyée : fn::result_ok({ before, count })
--
-- Erreurs
--   ERROR_INVALID_INPUT : entrée invalide (details.fields)
--   ERROR_WRITE_FORBIDDEN : écriture refusée par les permissions (details.table)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::error_occurrence_purge_before(
    $params: object
) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
        before_date: { pipeline: [{ rule: "datetime" }], required: true },
        language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("ERROR_INVALID_INPUT", $params.language, { fields: $report.by_field });
    };
    LET $p = $report.value;
    -- Le journal est invisible et non modifiable pour toute identité d'accès (méthode d'accès
    -- $session.ac ou utilisateur $auth) : une purge hors session système ne supprimerait rien en
    -- silence, elle est refusée.
    IF $session.ac != NONE OR $auth != NONE {
        RETURN fn::error_result("ERROR_WRITE_FORBIDDEN", $p.language, { table: "error_occurrence" });
    };
    LET $deleted = DELETE error_occurrence WHERE occurred_at < $p.before_date RETURN BEFORE;
    RETURN fn::result_ok({ before: $p.before_date, count: array::len($deleted) });
}
COMMENT "Supprime les occurrences antérieures à une date (rétention technique) et renvoie leur nombre."
PERMISSIONS FULL;
