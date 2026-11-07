-- ============================================================================
-- LYXAL OS — LYXAL_ERROR
-- ============================================================================
-- Fichier  : crates/lyxal_error/functions/service/error_log.surql
-- Fonction : fn::error_log
--
-- Journalise une occurrence d'erreur dans error_occurrence (append-only). Si
-- la définition du code existe et désactive la journalisation
-- (log_occurrence = false), rien n'est écrit (logged = false). La sévérité
-- de la définition prime sur celle transmise.
--
-- Paramètres
--   code (requis), source_module (requis)
--   operation, source (record), actor (record), technical_message, context (objet)
--   request_id, trace_id, correlation_id, fingerprint
--   environment (development | test | staging | production, défaut production)
--   severity (info | warning | error | critical, utilisée si le code n'a pas de définition)
--   language
--
-- Valeur renvoyée : fn::result_ok({ logged: true, occurrence })
--                   ou fn::result_ok({ logged: false, occurrence: NONE })
--
-- Erreurs
--   ERROR_INVALID_INPUT : entrée invalide (details.fields)
--   ERROR_WRITE_FORBIDDEN : écriture refusée par les permissions (details.table)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::error_log(
    $params: object
) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
        code: { pipeline: [{ rule: "required_string", options: { min_length: 3, max_length: 128 } }, { rule: "regex", options: { pattern: "^[A-Z][A-Z0-9_]+$" } }], required: true },
        source_module: { pipeline: [{ rule: "required_string", options: { min_length: 2, max_length: 64 } }, { rule: "regex", options: { pattern: "^[a-z][a-z0-9_-]+$" } }], required: true },
        operation: { pipeline: [{ rule: "optional_string", options: { max_length: 255 } }] },
        source: { pipeline: [{ rule: "record_id" }] },
        actor: { pipeline: [{ rule: "record_id" }] },
        technical_message: { pipeline: [{ rule: "optional_string", options: { max_length: 8000 } }] },
        context: { pipeline: [{ rule: "is_object" }], default: {} },
        request_id: { pipeline: [{ rule: "optional_string", options: { max_length: 255 } }] },
        trace_id: { pipeline: [{ rule: "optional_string", options: { max_length: 255 } }] },
        correlation_id: { pipeline: [{ rule: "optional_string", options: { max_length: 255 } }] },
        fingerprint: { pipeline: [{ rule: "optional_string", options: { max_length: 255 } }] },
        environment: { pipeline: [{ rule: "enum", options: { allowed: ["development", "test", "staging", "production"], case_sensitive: false } }], default: "production" },
        severity: { pipeline: [{ rule: "enum", options: { allowed: ["info", "warning", "error", "critical"], case_sensitive: false } }] },
        language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("ERROR_INVALID_INPUT", $params.language, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $definition = (SELECT * FROM error_definition WHERE code = $p.code AND enabled = true LIMIT 1)[0];
    IF $definition IS NOT NONE AND $definition.log_occurrence == false {
        RETURN fn::result_ok({ logged: false, occurrence: NONE });
    };
    LET $occurrence = CREATE ONLY error_occurrence CONTENT {
        definition: $definition.id,
        code: $p.code,
        source_module: $p.source_module,
        operation: $p.operation,
        source: $p.source,
        actor: $p.actor,
        request_id: $p.request_id,
        trace_id: $p.trace_id,
        correlation_id: $p.correlation_id,
        technical_message: $p.technical_message,
        context: $p.context,
        fingerprint: $p.fingerprint,
        environment: $p.environment,
        severity: $definition.severity ?? $p.severity ?? "error"
    };
    IF $occurrence IS NONE { RETURN fn::error_result("ERROR_WRITE_FORBIDDEN", $p.language, { table: "error_occurrence" }); };
    RETURN fn::result_ok({ logged: true, occurrence: $occurrence });
}
COMMENT "Journalise une occurrence d'erreur dans error_occurrence (append-only) : { logged: true, occurrence }. Si la définition du code désactive la journalisation (log_occurrence = false), rien n'est écrit : { logged: false, occurrence: NONE }. Écriture refusée : ERROR_WRITE_FORBIDDEN. La sévérité de la définition prime sur celle transmise."
PERMISSIONS FULL;
