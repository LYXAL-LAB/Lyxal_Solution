-- ============================================================================
-- LYXAL OS — LYXAL_ERROR
-- ============================================================================
-- Fichier  : crates/lyxal_error/functions/service/error_map_external.surql
-- Fonction : fn::error_map_external
--
-- Convertit une erreur d'un fournisseur externe en erreur canonique Lyxal :
-- parcourt les correspondances actives du fournisseur par priorité
-- croissante (exact, prefix, contains, http_status) ; un service absent d'un
-- côté ou de l'autre ne restreint pas la recherche.
--
-- Paramètres
--   provider (requis), external_code (requis), service, http_status (statut HTTP reçu), language
--
-- Valeur renvoyée : fn::result_ok({ mapping, definition, definition_code, retryable_override } | NONE)
--
-- Erreurs
--   ERROR_INVALID_INPUT : entrée invalide (details.fields)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::error_map_external(
    $params: object
) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
        provider: { pipeline: [{ rule: "required_string", options: { min_length: 2, max_length: 64 } }, { rule: "regex", options: { pattern: "^[a-z][a-z0-9_-]+$" } }], required: true },
        service: { pipeline: [{ rule: "required_string", options: { min_length: 2, max_length: 64 } }, { rule: "regex", options: { pattern: "^[a-z][a-z0-9_-]+$" } }] },
        external_code: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 500 } }], required: true },
        http_status: { pipeline: [{ rule: "integer", options: { min_value: 100, max_value: 599 } }] },
        language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("ERROR_INVALID_INPUT", $params.language, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $candidates = SELECT * FROM error_external_mapping WHERE provider = $p.provider AND enabled = true ORDER BY priority ASC;
    LET $match = array::find($candidates, |$m|
        ($p.service IS NONE OR $m.service IS NONE OR $m.service == $p.service)
        AND (
            ($m.matcher == "exact" AND $p.external_code == $m.external_code)
            OR ($m.matcher == "prefix" AND string::starts_with($p.external_code, $m.external_code))
            OR ($m.matcher == "contains" AND string::contains($p.external_code, $m.external_code))
            OR ($m.matcher == "http_status" AND $p.http_status IS NOT NONE AND <string> $p.http_status == $m.external_code)
        )
    );
    RETURN fn::result_ok(IF $match IS NONE { NONE } ELSE {
        { mapping: $match.id, definition: $match.definition, definition_code: $match.definition.code, retryable_override: $match.retryable_override }
    });
}
COMMENT "Convertit une erreur d'un fournisseur externe en erreur canonique Lyxal : parcourt les correspondances actives du fournisseur par priorité croissante (exact, prefix, contains, http_status) ; un service absent d'un côté ou de l'autre ne restreint pas la recherche."
PERMISSIONS FULL;
