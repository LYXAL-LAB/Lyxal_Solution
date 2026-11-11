-- ============================================================================
-- FONCTIONS : mises en page et gabarits
-- MODULE    : lyxal_notification
-- ============================================================================
-- Le HTML est nettoyé à l'enregistrement par lyxal_core (scripts, iframes et gestionnaires
-- d'événement retirés). Les gabarits sont des modèles MiniJinja rendus par le worker, en bac à
-- sable, avec échappement HTML automatique. Un gabarit existe en une seule version : ses phrases
-- sont des clés lyxal_i18n appelées par t("clé"), déclarées dans keys.

-- ----------------------------------------------------------------------------
-- fn::notification_html_clean : nettoyage d'un HTML de gabarit
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_html_clean($params: object) -> string {
    RETURN fn::sanitize_pipeline_execute($params.html, [{ rule: "strip_scripts" }, { rule: "strip_iframes" }, { rule: "strip_event_handlers" }], 5);
} COMMENT "HTML ({ html }) nettoyé par lyxal_core : scripts, iframes et gestionnaires d'événement retirés";

-- ----------------------------------------------------------------------------
-- fn::notification_has_content_slot : la mise en page contient-elle {{ content }} ?
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_has_content_slot($params: object) -> bool {
    RETURN fn::validation_pipeline_execute($params.text, [{ rule: "contains", options: { needles: ["{{ content }}"], case_sensitive: true, trim_value: false } }], 5).valid;
} COMMENT "Vrai si le texte ({ text }) contient l'emplacement {{ content }}";

-- ----------------------------------------------------------------------------
-- fn::notification_layout_create
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_layout_create($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            key: { pipeline: [{ rule: "snake_case_name", options: { min_length: 1, max_length: 64 } }], required: true },
            name: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 128 } }], required: true },
            html: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 200000 } }], required: true },
            text: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 100000 } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::notification_can({ action: "manage", tenant: $p.tenant }) { RETURN fn::error_result("NOTIFICATION_PERMISSION_DENIED", $p.language, {}); };
    LET $html = fn::notification_html_clean({ html: $p.html });
    IF !fn::notification_has_content_slot({ text: $html }) OR !fn::notification_has_content_slot({ text: $p.text }) {
        RETURN fn::error_result("NOTIFICATION_LAYOUT_CONTENT_SLOT_MISSING", $p.language, {});
    };
    LET $inserted = (INSERT IGNORE INTO notification_layout { tenant: $p.tenant, key: $p.key, name: $p.name, html: $html, text: $p.text });
    IF array::len($inserted) = 0 { RETURN fn::error_result("NOTIFICATION_LAYOUT_KEY_TAKEN", $p.language, { key: $p.key }); };
    RETURN fn::result_ok($inserted[0]);
} COMMENT "Crée une mise en page ({ tenant, key, name, html, text }) ; html et text contiennent {{ content }} ; HTML nettoyé. Permission notification.manage";

-- ----------------------------------------------------------------------------
-- fn::notification_layout_update
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_layout_update($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            layout: { pipeline: [{ rule: "record", options: { expected_table: "notification_layout" } }], required: true },
            name: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 128 } }] },
            html: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 200000 } }] },
            text: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 100000 } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $layout = (SELECT * FROM ONLY $p.layout);
    IF $layout == NONE { RETURN fn::error_result("NOTIFICATION_NOT_FOUND", $p.language, { resource: "layout" }); };
    IF !fn::notification_can({ action: "manage", tenant: $layout.tenant }) { RETURN fn::error_result("NOTIFICATION_PERMISSION_DENIED", $p.language, {}); };
    LET $html = IF $p.html IS NONE { NONE } ELSE { fn::notification_html_clean({ html: $p.html }) };
    IF ($html IS NOT NONE AND !fn::notification_has_content_slot({ text: $html })) OR ($p.text IS NOT NONE AND !fn::notification_has_content_slot({ text: $p.text })) {
        RETURN fn::error_result("NOTIFICATION_LAYOUT_CONTENT_SLOT_MISSING", $p.language, {});
    };
    LET $changes = object::from_entries(array::filter([["name", $p.name], ["html", $html], ["text", $p.text]], |$e| $e[1] IS NOT NONE));
    LET $updated = (UPDATE ONLY $layout.id MERGE $changes);
    IF $updated == NONE { RETURN fn::error_result("NOTIFICATION_WRITE_FORBIDDEN", $p.language, { table: "notification_layout" }); };
    RETURN fn::result_ok($updated);
} COMMENT "Modifie une mise en page ({ layout, name, html, text }) ; seuls les champs fournis changent. Permission notification.manage";

-- ----------------------------------------------------------------------------
-- fn::notification_layout_get / fn::notification_layout_list
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_layout_get($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            layout: { pipeline: [{ rule: "record", options: { expected_table: "notification_layout" } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $layout = (SELECT * FROM ONLY $report.value.layout);
    IF $layout == NONE { RETURN fn::error_result("NOTIFICATION_NOT_FOUND", $report.value.language, { resource: "layout" }); };
    RETURN fn::result_ok($layout);
} COMMENT "Mise en page ({ layout }). Permission notification.read";

DEFINE FUNCTION OVERWRITE fn::notification_layout_list($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
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
    RETURN fn::result_ok(SELECT id, key, name, updated_at FROM notification_layout WHERE scope_key = $scope ORDER BY key LIMIT $p.limit START $p.start);
} COMMENT "Mises en page d'une portée ({ tenant, limit, start }), triées par clé. Permission notification.read";

-- ----------------------------------------------------------------------------
-- fn::notification_template_content : contenu nettoyé d'un gabarit
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_template_content($params: object) -> object {
    LET $fields = array::filter([
        -- Objet sur une seule ligne (aucun caractère de contrôle : pas d'injection d'en-tête)
        IF $params.subject IS NONE { NONE } ELSE { ["subject", fn::sanitize_pipeline_execute($params.subject, [{ rule: "remove_control_chars" }, { rule: "trim" }], 5)] },
        IF $params.html_body IS NONE { NONE } ELSE { ["html_body", fn::notification_html_clean({ html: $params.html_body })] },
        IF $params.text_body IS NONE { NONE } ELSE { ["text_body", $params.text_body] },
        IF $params.keys IS NONE { NONE } ELSE { ["keys", array::distinct($params.keys)] }
    ], |$e| $e IS NOT NONE);
    RETURN object::from_entries($fields);
} COMMENT "Champs de contenu fournis ({ subject, html_body, text_body, keys }), nettoyés : objet sans caractère de contrôle, HTML nettoyé, clés sans doublon";

-- ----------------------------------------------------------------------------
-- fn::notification_template_unknown_keys : clés non déclarées dans lyxal_i18n
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_template_unknown_keys($params: object) -> object {
    IF array::len($params.keys) = 0 { RETURN { error: NONE, unknown: [] }; };
    LET $resolved = fn::i18n_resolve_many({ keys: $params.keys, locale: "fr" });
    IF !$resolved.ok { RETURN { error: $resolved.error.code, unknown: [] }; };
    RETURN { error: NONE, unknown: array::filter($resolved.data, |$text| $text.missing).key };
} COMMENT "Clés ({ keys }) que lyxal_i18n ne connaît pas : { error (code I18N_* reçu), unknown }";

-- ----------------------------------------------------------------------------
-- fn::notification_template_create
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_template_create($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            workflow: { pipeline: [{ rule: "record", options: { expected_table: "notification_workflow" } }], required: true },
            step_key: { pipeline: [{ rule: "snake_case_name", options: { min_length: 1, max_length: 64 } }], required: true },
            subject: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 998 } }], required: true },
            html_body: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 200000 } }], required: true },
            text_body: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 100000 } }], required: true },
            keys: { pipeline: [{ rule: "array_of_strings", options: { allow_empty: true } }, { rule: "array_length", options: { max_length: 100 } }, { rule: "each", options: { pipeline: [{ rule: "max_length", options: { max_length: 193 } }, { rule: "lyxal_event_name", options: { min_segments: 2, max_segments: 9 } }] } }], default: [] },
            layout: { pipeline: [{ rule: "record", options: { expected_table: "notification_layout" } }] },
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
    IF $p.step_key NOT IN $workflow.steps.key { RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", $p.language, { fields: { step_key: "unknown step" } }); };
    -- Mise en page de la même portée que le parcours, ou de l'installation
    IF $p.layout IS NOT NONE AND (SELECT VALUE scope_key FROM ONLY $p.layout) NOT IN [$workflow.scope_key, "installation"] {
        RETURN fn::error_result("NOTIFICATION_NOT_FOUND", $p.language, { resource: "layout" });
    };
    LET $content = fn::notification_template_content({ subject: $p.subject, html_body: $p.html_body, text_body: $p.text_body, keys: $p.keys });
    LET $check = fn::notification_template_unknown_keys({ keys: $content.keys });
    IF $check.error IS NOT NONE OR array::len($check.unknown) > 0 {
        RETURN fn::error_result("NOTIFICATION_TEMPLATE_KEY_UNKNOWN", $p.language, { keys: $check.unknown, cause: $check.error });
    };
    LET $inserted = (INSERT IGNORE INTO notification_template object::extend($content, {
        tenant: $workflow.tenant, workflow: $workflow.id, step_key: $p.step_key, layout: $p.layout
    }));
    IF array::len($inserted) = 0 { RETURN fn::error_result("NOTIFICATION_TEMPLATE_EXISTS", $p.language, { step_key: $p.step_key }); };
    RETURN fn::result_ok($inserted[0]);
} COMMENT "Crée le gabarit d'une étape ({ workflow, step_key, subject, html_body, text_body, keys, layout }) ; un seul par étape ; objet sans caractère de contrôle, HTML nettoyé ; keys : clés lyxal_i18n appelées par t(\"clé\"), toutes déclarées (NOTIFICATION_TEMPLATE_KEY_UNKNOWN) ; mise en page de la portée du parcours ou de l'installation. Permission notification.manage";

-- ----------------------------------------------------------------------------
-- fn::notification_template_update
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_template_update($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            template: { pipeline: [{ rule: "record", options: { expected_table: "notification_template" } }], required: true },
            subject: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 998 } }] },
            html_body: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 200000 } }] },
            text_body: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 100000 } }] },
            keys: { pipeline: [{ rule: "array_of_strings", options: { allow_empty: true } }, { rule: "array_length", options: { max_length: 100 } }, { rule: "each", options: { pipeline: [{ rule: "max_length", options: { max_length: 193 } }, { rule: "lyxal_event_name", options: { min_segments: 2, max_segments: 9 } }] } }] },
            layout: { pipeline: [{ rule: "record", options: { expected_table: "notification_layout" } }] },
            clear_layout: { pipeline: [{ rule: "boolean" }], default: false },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $template = (SELECT *, workflow.scope_key AS scope_key FROM ONLY $p.template);
    IF $template == NONE { RETURN fn::error_result("NOTIFICATION_NOT_FOUND", $p.language, { resource: "template" }); };
    IF !fn::notification_can({ action: "manage", tenant: $template.tenant }) { RETURN fn::error_result("NOTIFICATION_PERMISSION_DENIED", $p.language, {}); };
    IF $p.layout IS NOT NONE AND (SELECT VALUE scope_key FROM ONLY $p.layout) NOT IN [$template.scope_key, "installation"] {
        RETURN fn::error_result("NOTIFICATION_NOT_FOUND", $p.language, { resource: "layout" });
    };
    LET $content = fn::notification_template_content({ subject: $p.subject, html_body: $p.html_body, text_body: $p.text_body, keys: $p.keys });
    LET $check = fn::notification_template_unknown_keys({ keys: $content.keys ?? [] });
    IF $check.error IS NOT NONE OR array::len($check.unknown) > 0 {
        RETURN fn::error_result("NOTIFICATION_TEMPLATE_KEY_UNKNOWN", $p.language, { keys: $check.unknown, cause: $check.error });
    };
    LET $updated = (UPDATE ONLY $template.id MERGE object::extend($content, {
        layout: IF $p.clear_layout { NONE } ELSE { $p.layout ?? $template.layout }
    }));
    IF $updated == NONE { RETURN fn::error_result("NOTIFICATION_WRITE_FORBIDDEN", $p.language, { table: "notification_template" }); };
    RETURN fn::result_ok($updated);
} COMMENT "Modifie un gabarit ({ template, subject, html_body, text_body, keys, layout, clear_layout }) ; seuls les champs fournis changent ; mêmes contrôles qu'à la création. Permission notification.manage";

-- ----------------------------------------------------------------------------
-- fn::notification_template_get
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_template_get($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            template: { pipeline: [{ rule: "record", options: { expected_table: "notification_template" } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $template = (SELECT * FROM ONLY $report.value.template);
    IF $template == NONE { RETURN fn::error_result("NOTIFICATION_NOT_FOUND", $report.value.language, { resource: "template" }); };
    RETURN fn::result_ok($template);
} COMMENT "Gabarit ({ template }) avec son contenu et ses clés. Permission notification.read";
