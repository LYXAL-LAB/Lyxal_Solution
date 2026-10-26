-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::error_definition_update                                            │
-- │  Mise à jour des métadonnées d'une définition d'erreur canonique        │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION IF NOT EXISTS fn::error_definition_update(
    $code_or_id: option<string>,
    $message: option<string>,
    $category: option<string>,
    $severity: option<string>,
    $http_status: option<int>,
    $translations: option<object>
) {
    IF $code_or_id == NONE OR string::len(string::trim($code_or_id)) == 0 {
        RETURN fn::result_error("CORE_ERROR_DEFINITION_NOT_FOUND", "fr", { field: "code_or_id" });
    };

    LET $val = string::trim($code_or_id);
    LET $existing = SELECT * FROM error_definition WHERE id = $val OR code = string::uppercase($val) LIMIT 1;

    IF array::len($existing) == 0 {
        RETURN fn::result_error("CORE_ERROR_DEFINITION_NOT_FOUND", "fr", { id: $val });
    };

    LET $cur = $existing[0];
    LET $clean_msg = IF $message != NONE AND string::len(string::trim($message)) > 0 { string::trim($message) } ELSE { $cur.message };
    LET $cat = IF $category != NONE { string::lowercase(string::trim($category)) } ELSE { $cur.category };
    LET $sev = IF $severity != NONE { string::lowercase(string::trim($severity)) } ELSE { $cur.severity };
    LET $status = IF $http_status != NONE { $http_status } ELSE { $cur.http_status };
    LET $trans = IF $translations != NONE { $translations } ELSE { $cur.translations };

    UPDATE $cur.id MERGE {
        message: $clean_msg,
        category: $cat,
        severity: $sev,
        http_status: $status,
        translations: $trans,
        updated_at: time::now()
    };

    LET $updated = SELECT * FROM $cur.id;
    RETURN fn::result_ok($updated[0]);
} COMMENT "Met à jour le message, la catégorie, la sévérité ou les traductions d'une erreur";
