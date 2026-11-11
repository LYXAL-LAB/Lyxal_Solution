-- ============================================================================
-- FONCTIONS : parcours
-- MODULE    : lyxal_notification
-- ============================================================================
-- Un parcours n'est jamais supprimé : il passe à l'état `inactive`. Il ne peut être activé que si
-- chaque étape a un gabarit.

-- ----------------------------------------------------------------------------
-- fn::notification_workflow_missing_templates : étapes sans gabarit
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_workflow_missing_templates($params: object) -> array {
    RETURN array::filter($params.steps.key, |$step| {
        RETURN array::len(SELECT VALUE id FROM notification_template WHERE workflow = $params.workflow AND step_key = $step) = 0;
    });
} COMMENT "Clés des étapes ({ workflow, steps }) sans gabarit";

-- ----------------------------------------------------------------------------
-- fn::notification_workflow_create
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_workflow_create($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            key: { pipeline: [{ rule: "snake_case_name", options: { min_length: 1, max_length: 64 } }], required: true },
            name: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 128 } }], required: true },
            trigger_event: { pipeline: [{ rule: "lyxal_event_name", options: { min_segments: 2, max_segments: 6 } }] },
            critical: { pipeline: [{ rule: "boolean" }], default: false },
            sensitive: { pipeline: [{ rule: "boolean" }], default: false },
            payload_schema: { pipeline: [{ rule: "is_object" }] },
            steps: { pipeline: [{ rule: "array_objects", options: { allow_empty_objects: false } }, { rule: "array_non_empty" }, { rule: "each", options: { pipeline: [{ rule: "object", options: { schema: {
                fields: {
                    key: { pipeline: [{ rule: "snake_case_name", options: { min_length: 1, max_length: 64 } }], required: true },
                    channel: { pipeline: [{ rule: "enum", options: { allowed: ["email"], case_sensitive: true } }], required: true }
                },
                unknown_keys: "reject"
            } } }] } }], required: true },
            tags: { pipeline: [{ rule: "array_of_strings", options: { allow_empty: true } }, { rule: "array_unique" }, { rule: "each", options: { pipeline: [{ rule: "snake_case_name", options: { min_length: 1, max_length: 64 } }] } }], default: [] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 80);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::validation_pipeline_execute($p.steps.key, [{ rule: "array_unique" }], 5).valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", $p.language, { fields: { steps: "duplicate step key" } });
    };
    IF !fn::notification_can({ action: "manage", tenant: $p.tenant }) { RETURN fn::error_result("NOTIFICATION_PERMISSION_DENIED", $p.language, {}); };
    -- Un schéma de variables invalide est refusé par lyxal_core (CORE_INVALID_ARGUMENT)
    IF $p.payload_schema IS NOT NONE { fn::validation_object_execute({}, $p.payload_schema, 80); };
    LET $inserted = (INSERT IGNORE INTO notification_workflow {
        tenant: $p.tenant,
        key: $p.key,
        name: $p.name,
        trigger_event: $p.trigger_event,
        status: "draft",
        critical: $p.critical,
        sensitive: $p.sensitive,
        payload_schema: $p.payload_schema,
        steps: $p.steps,
        tags: $p.tags
    });
    IF array::len($inserted) = 0 { RETURN fn::error_result("NOTIFICATION_WORKFLOW_KEY_TAKEN", $p.language, { key: $p.key }); };
    RETURN fn::result_ok($inserted[0]);
} COMMENT "Crée un parcours à l'état brouillon ({ tenant, key, name, trigger_event, critical, sensitive, payload_schema, steps : [{ key, channel }], tags }) ; clé unique dans sa portée. Permission notification.manage (notification.installation.manage sans tenant)";

-- ----------------------------------------------------------------------------
-- fn::notification_workflow_update
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_workflow_update($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            workflow: { pipeline: [{ rule: "record", options: { expected_table: "notification_workflow" } }], required: true },
            name: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 128 } }] },
            trigger_event: { pipeline: [{ rule: "lyxal_event_name", options: { min_segments: 2, max_segments: 6 } }] },
            critical: { pipeline: [{ rule: "boolean" }] },
            sensitive: { pipeline: [{ rule: "boolean" }] },
            payload_schema: { pipeline: [{ rule: "is_object" }] },
            steps: { pipeline: [{ rule: "array_objects", options: { allow_empty_objects: false } }, { rule: "array_non_empty" }, { rule: "each", options: { pipeline: [{ rule: "object", options: { schema: {
                fields: {
                    key: { pipeline: [{ rule: "snake_case_name", options: { min_length: 1, max_length: 64 } }], required: true },
                    channel: { pipeline: [{ rule: "enum", options: { allowed: ["email"], case_sensitive: true } }], required: true }
                },
                unknown_keys: "reject"
            } } }] } }] },
            tags: { pipeline: [{ rule: "array_of_strings", options: { allow_empty: true } }, { rule: "array_unique" }, { rule: "each", options: { pipeline: [{ rule: "snake_case_name", options: { min_length: 1, max_length: 64 } }] } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 80);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF $p.steps IS NOT NONE AND !fn::validation_pipeline_execute($p.steps.key, [{ rule: "array_unique" }], 5).valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", $p.language, { fields: { steps: "duplicate step key" } });
    };
    LET $workflow = (SELECT * FROM ONLY $p.workflow);
    IF $workflow == NONE { RETURN fn::error_result("NOTIFICATION_WORKFLOW_NOT_FOUND", $p.language, {}); };
    IF !fn::notification_can({ action: "manage", tenant: $workflow.tenant }) { RETURN fn::error_result("NOTIFICATION_PERMISSION_DENIED", $p.language, {}); };
    IF $p.payload_schema IS NOT NONE { fn::validation_object_execute({}, $p.payload_schema, 80); };
    -- Un parcours actif garde un gabarit prêt pour chaque étape
    IF $workflow.status = "active" AND $p.steps IS NOT NONE {
        LET $missing = fn::notification_workflow_missing_templates({ workflow: $workflow.id, steps: $p.steps });
        IF array::len($missing) > 0 { RETURN fn::error_result("NOTIFICATION_TEMPLATE_REQUIRED", $p.language, { steps: $missing }); };
    };
    LET $changes = object::from_entries(array::filter(
        array::map(["name", "trigger_event", "critical", "sensitive", "payload_schema", "steps", "tags"], |$f| [$f, $p[$f]]),
        |$e| $e[1] IS NOT NONE
    ));
    LET $updated = (UPDATE ONLY $workflow.id MERGE $changes);
    IF $updated == NONE { RETURN fn::error_result("NOTIFICATION_WRITE_FORBIDDEN", $p.language, { table: "notification_workflow" }); };
    RETURN fn::result_ok($updated);
} COMMENT "Modifie un parcours ({ workflow, name, trigger_event, critical, sensitive, payload_schema, steps, tags }) ; seuls les champs fournis changent ; un parcours actif garde un gabarit prêt par étape. Permission notification.manage";

-- ----------------------------------------------------------------------------
-- fn::notification_workflow_get
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_workflow_get($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            workflow: { pipeline: [{ rule: "record", options: { expected_table: "notification_workflow" } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $workflow = (SELECT * FROM ONLY $p.workflow);
    IF $workflow == NONE { RETURN fn::error_result("NOTIFICATION_WORKFLOW_NOT_FOUND", $p.language, {}); };
    LET $templates = (SELECT id, step_key, layout, keys
        FROM notification_template WHERE workflow = $workflow.id ORDER BY step_key);
    RETURN fn::result_ok(object::extend($workflow, { templates: $templates }));
} COMMENT "Parcours ({ workflow }) avec ses gabarits et leurs clés. Permission notification.read";

-- ----------------------------------------------------------------------------
-- fn::notification_workflow_list
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_workflow_list($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            status: { pipeline: [{ rule: "enum", options: { allowed: ["draft", "active", "inactive"], case_sensitive: true } }] },
            limit: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 1000 } }], default: 100 },
            start: { pipeline: [{ rule: "integer", options: { min_value: 0 } }], default: 0 },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::notification_can({ action: "read", tenant: $p.tenant }) { RETURN fn::error_result("NOTIFICATION_PERMISSION_DENIED", $p.language, {}); };
    LET $scope = IF $p.tenant IS NONE { "installation" } ELSE { <string> record::id($p.tenant) };
    LET $rows = IF $p.status IS NONE {
        (SELECT * FROM notification_workflow WHERE scope_key = $scope ORDER BY key LIMIT $p.limit START $p.start)
    } ELSE {
        (SELECT * FROM notification_workflow WHERE scope_key = $scope AND status = $p.status ORDER BY key LIMIT $p.limit START $p.start)
    };
    RETURN fn::result_ok($rows);
} COMMENT "Parcours d'une portée ({ tenant : organisation ou NONE pour l'installation, status, limit, start }), triés par clé. Permission notification.read";

-- ----------------------------------------------------------------------------
-- fn::notification_workflow_set_status
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_workflow_set_status($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            workflow: { pipeline: [{ rule: "record", options: { expected_table: "notification_workflow" } }], required: true },
            status: { pipeline: [{ rule: "enum", options: { allowed: ["draft", "active", "inactive"], case_sensitive: true } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $workflow = (SELECT * FROM ONLY $p.workflow);
    IF $workflow == NONE { RETURN fn::error_result("NOTIFICATION_WORKFLOW_NOT_FOUND", $p.language, {}); };
    IF !fn::notification_can({ action: "manage", tenant: $workflow.tenant }) { RETURN fn::error_result("NOTIFICATION_PERMISSION_DENIED", $p.language, {}); };
    IF $p.status = "active" {
        LET $missing = fn::notification_workflow_missing_templates({ workflow: $workflow.id, steps: $workflow.steps });
        IF array::len($missing) > 0 { RETURN fn::error_result("NOTIFICATION_TEMPLATE_REQUIRED", $p.language, { steps: $missing }); };
    };
    LET $updated = (UPDATE ONLY $workflow.id SET status = $p.status);
    IF $updated == NONE { RETURN fn::error_result("NOTIFICATION_WRITE_FORBIDDEN", $p.language, { table: "notification_workflow" }); };
    RETURN fn::result_ok($updated);
} COMMENT "Change l'état d'un parcours ({ workflow, status : draft, active, inactive }) ; activation seulement si chaque étape a un gabarit et sa version dans la langue par défaut. Permission notification.manage";
