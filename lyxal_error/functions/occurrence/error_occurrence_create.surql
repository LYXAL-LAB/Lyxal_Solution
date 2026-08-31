-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::error_occurrence_create                                             │
-- │  Enregistrement append-only d'une occurrence d'erreur technique          │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION IF NOT EXISTS fn::error_occurrence_create(
    $code: option<string>,
    $source_module: option<string>,
    $operation: option<string>,
    $source: option<record>,
    $actor: option<record>,
    $technical_message: option<string>,
    $context: option<object>,
    $trace_id: option<string>,
    $correlation_id: option<string>,
    $environment: option<string>
) {
    LET $occ = fn::error_log(
        $code,
        $source_module,
        $operation,
        $source,
        $actor,
        $technical_message,
        $context,
        $trace_id,
        $correlation_id,
        $environment
    );

    IF $occ == NONE {
        RETURN fn::result_ok({ logged: false });
    };

    RETURN fn::result_ok($occ);
} COMMENT "Enregistre une occurrence d'erreur immuable (append-only) au format universel LyxalResult";
