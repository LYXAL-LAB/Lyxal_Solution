-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::error_result                                                        │
-- │  Construit la réponse d'échec conforme au contrat universel LyxalResult  │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION IF NOT EXISTS fn::error_result(
    $code: option<string>,
    $language: option<string>,
    $details: option<object>
) {
    LET $err = fn::error_resolve($code, $language, $details);

    RETURN {
        ok: false,
        data: NONE,
        error: $err
    };
} COMMENT "Construit directement le résultat d'échec conforme au contrat universel";
