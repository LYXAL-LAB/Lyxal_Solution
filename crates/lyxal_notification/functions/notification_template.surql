-- ============================================================================
-- FONCTIONS : mises en page et gabarits
-- MODULE    : lyxal_notification
-- ============================================================================
-- Le HTML est nettoyé à l'enregistrement par lyxal_core (scripts, iframes et gestionnaires
-- d'événement retirés). Les gabarits sont des modèles MiniJinja rendus par le worker, en bac à
-- sable, avec échappement HTML automatique.

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
-- fn::notification_template_create
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_template_create($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            workflow: { pipeline: [{ rule: "record", options: { expected_table: "notification_workflow" } }], required: true },
            step_key: { pipeline: [{ rule: "snake_case_name", options: { min_length: 1, max_length: 64 } }], required: true },
            default_locale: { pipeline: [{ rule: "locale", options: { require_region: false } }], required: true },
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
    LET $inserted = (INSERT IGNORE INTO notification_template {
        tenant: $workflow.tenant, workflow: $workflow.id, step_key: $p.step_key, default_locale: $p.default_locale, layout: $p.layout
    });
    IF array::len($inserted) = 0 { RETURN fn::error_result("NOTIFICATION_TEMPLATE_EXISTS", $p.language, { step_key: $p.step_key }); };
    RETURN fn::result_ok($inserted[0]);
} COMMENT "Crée le gabarit d'une étape ({ workflow, step_key, default_locale, layout }) ; un seul par étape ; mise en page de la portée du parcours ou de l'installation. Permission notification.manage";

-- ----------------------------------------------------------------------------
-- fn::notification_template_update
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_template_update($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            template: { pipeline: [{ rule: "record", options: { expected_table: "notification_template" } }], required: true },
            default_locale: { pipeline: [{ rule: "locale", options: { require_region: false } }] },
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
    LET $template = (SELECT *, workflow.scope_key AS scope_key, workflow.status AS workflow_status FROM ONLY $p.template);
    IF $template == NONE { RETURN fn::error_result("NOTIFICATION_NOT_FOUND", $p.language, { resource: "template" }); };
    IF !fn::notification_can({ action: "manage", tenant: $template.tenant }) { RETURN fn::error_result("NOTIFICATION_PERMISSION_DENIED", $p.language, {}); };
    IF $p.layout IS NOT NONE AND (SELECT VALUE scope_key FROM ONLY $p.layout) NOT IN [$template.scope_key, "installation"] {
        RETURN fn::error_result("NOTIFICATION_NOT_FOUND", $p.language, { resource: "layout" });
    };
    -- Gabarit d'un parcours actif : la nouvelle langue par défaut doit déjà avoir sa version
    IF $p.default_locale IS NOT NONE AND $template.workflow_status = "active"
        AND array::len(SELECT VALUE id FROM notification_template_locale WHERE template = $template.id AND locale = $p.default_locale) = 0 {
        RETURN fn::error_result("NOTIFICATION_TEMPLATE_DEFAULT_LOCALE_REQUIRED", $p.language, { locale: $p.default_locale });
    };
    LET $updated = (UPDATE ONLY $template.id SET
        default_locale = $p.default_locale ?? default_locale,
        layout = IF $p.clear_layout { NONE } ELSE { $p.layout ?? layout });
    IF $updated == NONE { RETURN fn::error_result("NOTIFICATION_WRITE_FORBIDDEN", $p.language, { table: "notification_template" }); };
    RETURN fn::result_ok($updated);
} COMMENT "Modifie un gabarit ({ template, default_locale, layout, clear_layout }). Permission notification.manage";

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
    LET $locales = (SELECT locale, subject, html_body, text_body, updated_at FROM notification_template_locale WHERE template = $template.id ORDER BY locale);
    RETURN fn::result_ok(object::extend($template, { locales: $locales }));
} COMMENT "Gabarit ({ template }) avec ses versions par langue. Permission notification.read";

-- ----------------------------------------------------------------------------
-- fn::notification_template_locale_set
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_template_locale_set($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            template: { pipeline: [{ rule: "record", options: { expected_table: "notification_template" } }], required: true },
            locale: { pipeline: [{ rule: "locale", options: { require_region: false } }], required: true },
            subject: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 998 } }], required: true },
            html_body: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 200000 } }], required: true },
            text_body: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 100000 } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $template = (SELECT * FROM ONLY $p.template);
    IF $template == NONE { RETURN fn::error_result("NOTIFICATION_NOT_FOUND", $p.language, { resource: "template" }); };
    IF !fn::notification_can({ action: "manage", tenant: $template.tenant }) { RETURN fn::error_result("NOTIFICATION_PERMISSION_DENIED", $p.language, {}); };
    -- Objet sur une seule ligne (aucun caractère de contrôle : pas d'injection d'en-tête)
    LET $subject = fn::sanitize_pipeline_execute($p.subject, [{ rule: "remove_control_chars" }, { rule: "trim" }], 5);
    LET $content = { subject: $subject, html_body: fn::notification_html_clean({ html: $p.html_body }), text_body: $p.text_body };
    LET $existing = (SELECT VALUE id FROM ONLY notification_template_locale WHERE template = $template.id AND locale = $p.locale LIMIT 1);
    LET $saved = IF $existing IS NONE {
        (CREATE ONLY notification_template_locale CONTENT object::extend($content, { template: $template.id, locale: $p.locale }))
    } ELSE {
        (UPDATE ONLY $existing MERGE $content)
    };
    IF $saved == NONE { RETURN fn::error_result("NOTIFICATION_WRITE_FORBIDDEN", $p.language, { table: "notification_template_locale" }); };
    RETURN fn::result_ok($saved);
} COMMENT "Crée ou remplace la version d'un gabarit dans une langue ({ template, locale, subject, html_body, text_body }) ; objet sans caractère de contrôle, HTML nettoyé. Permission notification.manage";

-- ----------------------------------------------------------------------------
-- fn::notification_template_locale_delete
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_template_locale_delete($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            template: { pipeline: [{ rule: "record", options: { expected_table: "notification_template" } }], required: true },
            locale: { pipeline: [{ rule: "locale", options: { require_region: false } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $template = (SELECT * FROM ONLY $p.template);
    IF $template == NONE { RETURN fn::error_result("NOTIFICATION_NOT_FOUND", $p.language, { resource: "template" }); };
    IF !fn::notification_can({ action: "manage", tenant: $template.tenant }) { RETURN fn::error_result("NOTIFICATION_PERMISSION_DENIED", $p.language, {}); };
    IF $p.locale = $template.default_locale { RETURN fn::error_result("NOTIFICATION_TEMPLATE_DEFAULT_LOCALE_REQUIRED", $p.language, { locale: $p.locale }); };
    LET $existing = (SELECT VALUE id FROM ONLY notification_template_locale WHERE template = $template.id AND locale = $p.locale LIMIT 1);
    IF $existing IS NONE { RETURN fn::error_result("NOTIFICATION_TEMPLATE_LOCALE_MISSING", $p.language, { locale: $p.locale }); };
    LET $deleted = (DELETE $existing RETURN BEFORE);
    IF array::len($deleted) = 0 { RETURN fn::error_result("NOTIFICATION_WRITE_FORBIDDEN", $p.language, { table: "notification_template_locale" }); };
    RETURN fn::result_ok({ deleted: $existing });
} COMMENT "Supprime la version d'un gabarit dans une langue ({ template, locale }) ; la langue par défaut ne peut pas être supprimée. Permission notification.manage";
