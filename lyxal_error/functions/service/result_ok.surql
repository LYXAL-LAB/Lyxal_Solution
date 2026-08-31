-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::result_ok                                                           │
-- │  Construit la réponse de succès conforme au contrat universel LyxalResult│
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION IF NOT EXISTS fn::result_ok(
    $data: any
) {
    RETURN {
        ok: true,
        data: $data,
        error: NONE
    };
} COMMENT "Construit directement le résultat de succès conforme au contrat universel";
