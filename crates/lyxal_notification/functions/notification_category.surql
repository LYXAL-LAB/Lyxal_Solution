-- ============================================================================
-- FONCTIONS : catégories de désabonnement
-- MODULE    : lyxal_notification
-- ============================================================================
-- Une catégorie regroupe des parcours pour le désabonnement (« Actualités », « Rappels »…). Les
-- catégories de l'installation servent à toutes les organisations. Une catégorie utilisée par un
-- parcours ne peut pas être supprimée. Lecture : notification.read ; gestion :
-- notification.manage.

-- ----------------------------------------------------------------------------
-- fn::notification_category_find : catégorie de la portée, sinon de l'installation
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_category_find($params: object) -> any {
    LET $scope = IF $params.tenant IS NONE { "installation" } ELSE { <string> record::id($params.tenant) };
    LET $scopes = IF $params.own_only { [$scope] } ELSE { array::distinct([$scope, "installation"]) };
    LET $found = (SELECT * FROM notification_category WHERE scope_key IN $scopes AND key = $params.key);
    RETURN array::find($found, |$c| $c.scope_key = $scope) ?? array::find($found, |$c| $c.scope_key = "installation");
} COMMENT "Catégorie ({ tenant, key, own_only }) de la portée, sinon de l'installation (sauf own_only), ou NONE";

-- ----------------------------------------------------------------------------
-- fn::notification_category_create
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_category_create($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            key: { pipeline: [{ rule: "snake_case_name", options: { min_length: 1, max_length: 64 } }], required: true },
            name: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 128 } }], required: true },
            description: { pipeline: [{ rule: "optional_string", options: { max_length: 512 } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 30);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::notification_can({ action: "manage", tenant: $p.tenant }) { RETURN fn::error_result("NOTIFICATION_PERMISSION_DENIED", $p.language, {}); };
    IF fn::notification_category_find({ tenant: $p.tenant, key: $p.key, own_only: true }) IS NOT NONE {
        RETURN fn::error_result("NOTIFICATION_CATEGORY_KEY_TAKEN", $p.language, { key: $p.key });
    };
    LET $created = (INSERT IGNORE INTO notification_category { tenant: $p.tenant, key: $p.key, name: $p.name, description: $p.description });
    IF array::len($created) = 0 { RETURN fn::error_result("NOTIFICATION_WRITE_FORBIDDEN", $p.language, { table: "notification_category" }); };
    RETURN fn::result_ok($created[0]);
} COMMENT "Crée une catégorie de désabonnement ({ tenant, key, name, description }) ; clé unique dans sa portée. Permission notification.manage";

-- ----------------------------------------------------------------------------
-- fn::notification_category_update
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_category_update($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            key: { pipeline: [{ rule: "snake_case_name", options: { min_length: 1, max_length: 64 } }], required: true },
            name: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 128 } }] },
            description: { pipeline: [{ rule: "optional_string", options: { max_length: 512 } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 30);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::notification_can({ action: "manage", tenant: $p.tenant }) { RETURN fn::error_result("NOTIFICATION_PERMISSION_DENIED", $p.language, {}); };
    LET $category = fn::notification_category_find({ tenant: $p.tenant, key: $p.key, own_only: true });
    IF $category IS NONE { RETURN fn::error_result("NOTIFICATION_CATEGORY_NOT_FOUND", $p.language, { key: $p.key }); };
    LET $changes = object::from_entries(array::filter(array::map(["name", "description"], |$f| [$f, $p[$f]]), |$e| $e[1] IS NOT NONE));
    LET $updated = (UPDATE ONLY $category.id MERGE $changes);
    IF $updated == NONE { RETURN fn::error_result("NOTIFICATION_WRITE_FORBIDDEN", $p.language, { table: "notification_category" }); };
    RETURN fn::result_ok($updated);
} COMMENT "Modifie une catégorie de sa portée ({ tenant, key, name, description }). Permission notification.manage";

-- ----------------------------------------------------------------------------
-- fn::notification_category_list
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_category_list($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::notification_can({ action: "read_config", tenant: $p.tenant }) AND !fn::notification_can({ action: "member", tenant: $p.tenant }) {
        RETURN fn::error_result("NOTIFICATION_PERMISSION_DENIED", $p.language, {});
    };
    LET $scope = IF $p.tenant IS NONE { "installation" } ELSE { <string> record::id($p.tenant) };
    RETURN fn::result_ok(SELECT * FROM notification_category WHERE scope_key IN array::distinct([$scope, "installation"]) ORDER BY scope_key, key);
} COMMENT "Catégories d'une portée et de l'installation ({ tenant }). Permission notification.read (toute personne connectée de la portée, pour régler ses préférences)";

-- ----------------------------------------------------------------------------
-- fn::notification_category_delete
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_category_delete($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            key: { pipeline: [{ rule: "snake_case_name", options: { min_length: 1, max_length: 64 } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::notification_can({ action: "manage", tenant: $p.tenant }) { RETURN fn::error_result("NOTIFICATION_PERMISSION_DENIED", $p.language, {}); };
    LET $category = fn::notification_category_find({ tenant: $p.tenant, key: $p.key, own_only: true });
    IF $category IS NONE { RETURN fn::error_result("NOTIFICATION_CATEGORY_NOT_FOUND", $p.language, { key: $p.key }); };
    -- Parcours visibles de l'appelant ; un parcours d'une autre organisation qui utiliserait une
    -- catégorie de l'installation la perd (REFERENCE ON DELETE UNSET)
    LET $users = (SELECT VALUE key FROM notification_workflow WHERE category = $category.id LIMIT 10);
    IF array::len($users) > 0 { RETURN fn::error_result("NOTIFICATION_CATEGORY_IN_USE", $p.language, { workflows: $users }); };
    LET $deleted = (DELETE $category.id RETURN BEFORE);
    IF array::len($deleted) = 0 { RETURN fn::error_result("NOTIFICATION_WRITE_FORBIDDEN", $p.language, { table: "notification_category" }); };
    RETURN fn::result_ok({ deleted: $category.id });
} COMMENT "Supprime une catégorie de sa portée ({ tenant, key }) ; refusée si un parcours l'utilise (NOTIFICATION_CATEGORY_IN_USE). Permission notification.manage";
