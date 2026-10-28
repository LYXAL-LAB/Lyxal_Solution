-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::error_occurrence_create                                             │
-- │  Enregistrement append-only d'une occurrence d'erreur technique          │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::error_occurrence_create(
    $params: object
) {
    LET $res = fn::error_log($params);
    RETURN $res;
} COMMENT "Enregistre une occurrence d'erreur immuable (append-only) au format universel LyxalResult";
