-- ============================================================================
-- FONCTIONS : mises en page et gabarits
-- MODULE    : lyxal_notification
-- ============================================================================
-- Le HTML est nettoyé à l'enregistrement par lyxal_core (scripts, iframes et gestionnaires
-- d'événement retirés). Les gabarits sont des modèles MiniJinja rendus par le worker, en bac à
-- sable, avec échappement HTML automatique. Un gabarit existe en une seule version : ses phrases
-- sont des clés lyxal_i18n appelées par t("clé"), déclarées dans keys. Fil dans l'application
-- (décision F3) : titre, texte, avatar, lien de redirection, deux boutons au plus et données ;
-- chaque lien est contrôlé à l'enregistrement (partie fixe du gabarit) et au rendu
-- (fn::notification_link_valid : chemin de l'application ou adresse HTTPS).

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
        IF $params.keys IS NONE { NONE } ELSE { ["keys", array::distinct($params.keys)] },
        IF $params.avatar IS NONE { NONE } ELSE { ["avatar", $params.avatar] },
        IF $params.redirect IS NONE { NONE } ELSE { ["redirect", $params.redirect] },
        IF $params.actions IS NONE { NONE } ELSE { ["actions", $params.actions] },
        IF $params.data IS NONE { NONE } ELSE { ["data", $params.data] }
    ], |$e| $e IS NOT NONE);
    RETURN object::from_entries($fields);
} COMMENT "Champs de contenu fournis ({ subject, html_body, text_body, keys, avatar, redirect, actions, data }), nettoyés : objet sans caractère de contrôle, HTML nettoyé, clés sans doublon ; champs du fil repris tels quels (contrôlés par fn::notification_template_channel_refusal)";

-- ----------------------------------------------------------------------------
-- fn::notification_template_action_fields (interne) : boutons d'un gabarit du fil
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_template_action_fields($params: object) -> object {
    RETURN { pipeline: [{ rule: "array_objects", options: { allow_empty_objects: false } }, { rule: "array_length", options: { max_length: 2 } },
        { rule: "each", options: { pipeline: [{ rule: "object", options: { schema: {
            fields: {
                kind: { pipeline: [{ rule: "enum", options: { allowed: ["primary", "secondary"], case_sensitive: true } }], required: true },
                label: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 512 } }], required: true },
                url: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 2048 } }] }
            },
            unknown_keys: "reject"
        } } }] } }] };
} COMMENT "Interne : schéma lyxal_core des boutons d'un gabarit du fil (deux au plus : { kind : primary ou secondary, label, url }, gabarits MiniJinja)";

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
-- fn::notification_sms_segments : parties d'un SMS (décision E5)
-- ----------------------------------------------------------------------------
-- Alphabet GSM 03.38 : jeu de base (1 unité) et extension (2 unités : échappement + caractère) ;
-- un seul caractère hors de cet alphabet fait passer tout le texte en UCS-2 (unités UTF-16 : un
-- caractère hors du plan de base, comme un emoji, en compte 2). Même calcul que SmsSegments (Rust),
-- appliqué au texte rendu juste avant l'envoi.

DEFINE FUNCTION OVERWRITE fn::notification_sms_segments($text: string) -> object {
    -- Au-delà de 1 530 caractères, plus de 10 parties dans tous les cas
    IF string::len($text) > 1530 { RETURN { encoding: "ucs2", units: string::len($text), parts: 11 }; };
    LET $basic = "@£$¥èéùìòÇ\nØø\rÅåΔ_ΦΓΛΩΠΨΣΘΞÆæßÉ !\"#¤%&'()*+,-./0123456789:;<=>?¡ABCDEFGHIJKLMNOPQRSTUVWXYZÄÖÑÜ§¿abcdefghijklmnopqrstuvwxyzäöñüà";
    LET $extended = "^{}\\[~]|€";
    LET $chars = array::filter(string::split($text, ""), |$c| $c != "");
    LET $gsm = array::all($chars, |$c| string::contains($basic, $c) OR string::contains($extended, $c));
    LET $units = IF $gsm {
        array::fold($chars, 0, |$n, $c| $n + IF string::contains($extended, $c) { 2 } ELSE { 1 })
    } ELSE {
        array::fold($chars, 0, |$n, $c| $n + IF bytes::len(<bytes> $c) = 4 { 2 } ELSE { 1 })
    };
    LET $single = IF $gsm { 160 } ELSE { 70 };
    LET $part = IF $gsm { 153 } ELSE { 67 };
    RETURN {
        encoding: IF $gsm { "gsm7" } ELSE { "ucs2" },
        units: $units,
        parts: IF $units <= $single { 1 } ELSE { <int> math::ceil(<float> $units / $part) }
    };
} COMMENT "Parties d'un SMS ($text) : { encoding : gsm7 ou ucs2, units, parts } (GSM-7 : 160 unités, 153 par partie au-delà ; UCS-2 : 70, 67 par partie)";

-- ----------------------------------------------------------------------------
-- fn::notification_template_channel_refusal (interne) : contenu propre au canal (E5)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_template_channel_refusal($params: object) -> option<object> {
    LET $t = $params.template;
    -- Avatar, lien, boutons et données : fil seulement
    IF $params.channel != "in_app" {
        LET $feed_only = array::filter(["avatar", "redirect", "actions", "data"], |$f| $t[$f] IS NOT NONE);
        IF array::len($feed_only) > 0 {
            RETURN { code: "NOTIFICATION_INVALID_INPUT", details: { fields: object::from_entries(array::map($feed_only, |$f| [$f, ["CORE_VALIDATION_NOT_ALLOWED"]])) } };
        };
    };
    IF $params.channel = "in_app" { RETURN fn::notification_template_feed_refusal($t); };
    IF $params.channel = "email" {
        LET $missing = array::filter(["subject", "html_body", "text_body"], |$f| $t[$f] IS NONE);
        RETURN IF array::len($missing) = 0 { NONE } ELSE {
            { code: "NOTIFICATION_INVALID_INPUT", details: { fields: object::from_entries(array::map($missing, |$f| [$f, ["CORE_VALIDATION_REQUIRED"]])) } }
        };
    };
    -- SMS, messagerie, adresse web : texte seul, titre facultatif, ni HTML ni mise en page
    LET $extra = array::filter(["html_body", "layout"], |$f| $t[$f] IS NOT NONE);
    IF array::len($extra) > 0 {
        RETURN { code: "NOTIFICATION_INVALID_INPUT", details: { fields: object::from_entries(array::map($extra, |$f| [$f, ["CORE_VALIDATION_NOT_ALLOWED"]])) } };
    };
    IF $t.text_body IS NONE { RETURN { code: "NOTIFICATION_INVALID_INPUT", details: { fields: { text_body: ["CORE_VALIDATION_REQUIRED"] } } }; };
    IF $params.channel = "sms" {
        -- Texte du gabarit tel qu'écrit (le texte rendu est recompté avant l'envoi)
        LET $segments = fn::notification_sms_segments($t.text_body);
        IF $segments.parts > 10 { RETURN { code: "NOTIFICATION_SMS_TOO_LONG", details: $segments }; };
    };
    RETURN NONE;
} COMMENT "Interne : refus du contenu d'un gabarit selon le canal de son étape ({ channel, template : subject, html_body, text_body, layout, avatar, redirect, actions, data }) : e-mail : objet, HTML et texte requis ; SMS, messagerie, adresse web : texte requis, ni HTML ni mise en page ; SMS : 10 parties au plus (NOTIFICATION_SMS_TOO_LONG) ; fil : fn::notification_template_feed_refusal ; avatar, lien, boutons et données : fil seulement. { code, details } ou NONE";

-- ----------------------------------------------------------------------------
-- fn::notification_template_feed_refusal (interne) : contenu d'un gabarit du fil (F3)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_template_feed_refusal($t: object) -> option<object> {
    LET $extra = array::filter(["html_body", "layout"], |$f| $t[$f] IS NOT NONE);
    IF array::len($extra) > 0 {
        RETURN { code: "NOTIFICATION_INVALID_INPUT", details: { fields: object::from_entries(array::map($extra, |$f| [$f, ["CORE_VALIDATION_NOT_ALLOWED"]])) } };
    };
    LET $missing = array::filter(["subject", "text_body"], |$f| $t[$f] IS NONE);
    IF array::len($missing) > 0 {
        RETURN { code: "NOTIFICATION_INVALID_INPUT", details: { fields: object::from_entries(array::map($missing, |$f| [$f, ["CORE_VALIDATION_REQUIRED"]])) } };
    };
    -- Liens : la partie fixe du gabarit (avant la première variable) est déjà un chemin de
    -- l'application ou une adresse HTTPS complète ; le lien rendu est contrôlé à nouveau
    LET $links = array::concat(
        [["avatar", $t.avatar], ["redirect", $t.redirect]],
        array::map($t.actions ?? [], |$a| [string::concat("actions.", $a.kind), $a.url])
    );
    LET $bad = array::filter($links, |$l| $l[1] IS NOT NONE AND !fn::notification_link_valid({ value: $l[1], template: true }));
    IF array::len($bad) > 0 {
        RETURN { code: "NOTIFICATION_INVALID_INPUT", details: { fields: object::from_entries(array::map($bad, |$l| [$l[0], ["CORE_VALIDATION_FORMAT"]])) } };
    };
    IF !fn::validation_pipeline_execute(($t.actions ?? []).kind, [{ rule: "array_unique" }], 5).valid {
        RETURN { code: "NOTIFICATION_INVALID_INPUT", details: { fields: { actions: ["CORE_VALIDATION_DUPLICATE"] } } };
    };
    -- Données : gabarits textuels, 8 Kio au plus
    IF $t.data IS NOT NONE AND (!fn::validation_object_values_type($t.data, "string", true, NONE).valid OR !fn::validation_max_length(<string> $t.data, 8192).valid) {
        RETURN { code: "NOTIFICATION_INVALID_INPUT", details: { fields: { data: ["CORE_VALIDATION_FORMAT"] } } };
    };
    RETURN NONE;
} COMMENT "Interne : refus du contenu d'un gabarit du fil (décision F3) : titre (subject) et texte requis, ni HTML ni mise en page ; avatar, lien de redirection et lien de chaque bouton : partie fixe du gabarit déjà valide (fn::notification_link_valid) ; boutons de types distincts ; données : textes (gabarits), 8 Kio au plus. { code, details } ou NONE";

-- ----------------------------------------------------------------------------
-- fn::notification_template_create
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_template_create($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            workflow: { pipeline: [{ rule: "record", options: { expected_table: "notification_workflow" } }], required: true },
            step_key: { pipeline: [{ rule: "snake_case_name", options: { min_length: 1, max_length: 64 } }], required: true },
            subject: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 998 } }] },
            html_body: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 200000 } }] },
            text_body: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 100000 } }] },
            keys: { pipeline: [{ rule: "array_of_strings", options: { allow_empty: true } }, { rule: "array_length", options: { max_length: 100 } }, { rule: "each", options: { pipeline: [{ rule: "max_length", options: { max_length: 193 } }, { rule: "lyxal_event_name", options: { min_segments: 2, max_segments: 9 } }] } }], default: [] },
            layout: { pipeline: [{ rule: "record", options: { expected_table: "notification_layout" } }] },
            avatar: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 2048 } }] },
            redirect: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 2048 } }] },
            actions: fn::notification_template_action_fields({}),
            data: { pipeline: [{ rule: "is_object" }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $workflow = (SELECT * FROM ONLY $p.workflow);
    IF $workflow == NONE { RETURN fn::error_result("NOTIFICATION_WORKFLOW_NOT_FOUND", $p.language, {}); };
    IF !fn::notification_can({ action: "manage", tenant: $workflow.tenant }) { RETURN fn::error_result("NOTIFICATION_PERMISSION_DENIED", $p.language, {}); };
    -- Un gabarit pour une étape de canal seulement, de forme propre au canal (E5)
    LET $step = array::find($workflow.steps, |$s| $s.key = $p.step_key AND $s.type IN fn::notification_channels({}));
    IF $step IS NONE {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", $p.language, { fields: { step_key: "unknown channel step" } });
    };
    LET $shape = fn::notification_template_channel_refusal({ channel: $step.type, template: $p });
    IF $shape IS NOT NONE { RETURN fn::error_result($shape.code, $p.language, $shape.details); };
    -- Mise en page de la même portée que le parcours, ou de l'installation
    IF $p.layout IS NOT NONE AND (SELECT VALUE scope_key FROM ONLY $p.layout) NOT IN [$workflow.scope_key, "installation"] {
        RETURN fn::error_result("NOTIFICATION_NOT_FOUND", $p.language, { resource: "layout" });
    };
    LET $content = fn::notification_template_content({ subject: $p.subject, html_body: $p.html_body, text_body: $p.text_body, keys: $p.keys,
        avatar: $p.avatar, redirect: $p.redirect, actions: $p.actions, data: $p.data });
    LET $check = fn::notification_template_unknown_keys({ keys: $content.keys });
    IF $check.error IS NOT NONE OR array::len($check.unknown) > 0 {
        RETURN fn::error_result("NOTIFICATION_TEMPLATE_KEY_UNKNOWN", $p.language, { keys: $check.unknown, cause: $check.error });
    };
    LET $inserted = (INSERT IGNORE INTO notification_template object::extend($content, {
        tenant: $workflow.tenant, workflow: $workflow.id, step_key: $p.step_key, layout: $p.layout
    }));
    IF array::len($inserted) = 0 { RETURN fn::error_result("NOTIFICATION_TEMPLATE_EXISTS", $p.language, { step_key: $p.step_key }); };
    RETURN fn::result_ok($inserted[0]);
} COMMENT "Crée le gabarit d'une étape ({ workflow, step_key, subject, html_body, text_body, keys, layout, avatar, redirect, actions, data }) ; un seul par étape ; e-mail : objet, HTML et texte ; SMS, messagerie, adresse web : texte seul (objet facultatif, ni HTML ni mise en page), SMS de 10 parties au plus (NOTIFICATION_SMS_TOO_LONG) ; fil : titre (subject) et texte, avatar, lien, deux boutons et données, liens contrôlés (chemin de l'application ou adresse HTTPS) ; objet sans caractère de contrôle, HTML nettoyé ; keys : clés lyxal_i18n appelées par t(\"clé\"), toutes déclarées (NOTIFICATION_TEMPLATE_KEY_UNKNOWN) ; mise en page de la portée du parcours ou de l'installation. Permission notification.manage";

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
            avatar: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 2048 } }], nullable: true },
            redirect: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 2048 } }], nullable: true },
            actions: object::extend(fn::notification_template_action_fields({}), { nullable: true }),
            data: { pipeline: [{ rule: "is_object" }], nullable: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
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
    -- Contenu après modification, contrôlé selon le canal de l'étape (E5)
    LET $channel = array::find((SELECT VALUE steps FROM ONLY $template.workflow) ?? [], |$s| $s.key = $template.step_key).type;
    -- Champs du fil : valeur fournie, null efface, absente garde la valeur actuelle
    LET $feed = object::from_entries(array::map(["avatar", "redirect", "actions", "data"], |$f| [$f,
        IF $p[$f] IS NONE { $template[$f] } ELSE IF type::is_null($p[$f]) { NONE } ELSE { $p[$f] }]));
    LET $shape = fn::notification_template_channel_refusal({ channel: $channel, template: object::extend({
        subject: $p.subject ?? $template.subject, html_body: $p.html_body ?? $template.html_body, text_body: $p.text_body ?? $template.text_body,
        layout: IF $p.clear_layout { NONE } ELSE { $p.layout ?? $template.layout }
    }, $feed) });
    IF $shape IS NOT NONE { RETURN fn::error_result($shape.code, $p.language, $shape.details); };
    LET $content = fn::notification_template_content({ subject: $p.subject, html_body: $p.html_body, text_body: $p.text_body, keys: $p.keys });
    LET $check = fn::notification_template_unknown_keys({ keys: $content.keys ?? [] });
    IF $check.error IS NOT NONE OR array::len($check.unknown) > 0 {
        RETURN fn::error_result("NOTIFICATION_TEMPLATE_KEY_UNKNOWN", $p.language, { keys: $check.unknown, cause: $check.error });
    };
    LET $updated = (UPDATE ONLY $template.id MERGE object::extend($content, {
        layout: IF $p.clear_layout { NONE } ELSE { $p.layout ?? $template.layout }
    }));
    -- Champs du fil remplacés en entier (null efface, absent garde la valeur actuelle)
    LET $updated = IF $updated == NONE { NONE } ELSE {
        (UPDATE ONLY $template.id SET avatar = $feed.avatar, redirect = $feed.redirect, actions = $feed.actions, data = $feed.data)
    };
    IF $updated == NONE { RETURN fn::error_result("NOTIFICATION_WRITE_FORBIDDEN", $p.language, { table: "notification_template" }); };
    RETURN fn::result_ok($updated);
} COMMENT "Modifie un gabarit ({ template, subject, html_body, text_body, keys, layout, clear_layout, avatar, redirect, actions, data : null efface un champ du fil }) ; seuls les champs fournis changent ; mêmes contrôles qu'à la création, forme propre au canal de l'étape et longueur d'un SMS comprises. Permission notification.manage";

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

-- ----------------------------------------------------------------------------
-- fn::notification_step_preview : données de l'aperçu d'une étape (rendu par Rust)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_step_preview($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            workflow: { pipeline: [{ rule: "record", options: { expected_table: "notification_workflow" } }], required: true },
            step_key: { pipeline: [{ rule: "snake_case_name", options: { min_length: 1, max_length: 64 } }], required: true },
            payload: { pipeline: [{ rule: "is_object" }], default: {} },
            locale: { pipeline: [{ rule: "locale", options: { require_region: false } }] },
            digest: { pipeline: [{ rule: "is_object" }, { rule: "object", options: { schema: {
                fields: {
                    count: { pipeline: [{ rule: "integer", options: { min_value: 0, max_value: 1000000 } }], required: true },
                    events: { pipeline: [{ rule: "array_objects", options: { allow_empty_objects: true } }, { rule: "array_length", options: { min_length: 0, max_length: 100 } }], default: [] }
                },
                unknown_keys: "reject"
            } } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $workflow = (SELECT * FROM ONLY $p.workflow);
    IF $workflow == NONE { RETURN fn::error_result("NOTIFICATION_WORKFLOW_NOT_FOUND", $p.language, {}); };
    -- Parcours de l'installation : lisible comme sa configuration (repli de toute organisation)
    IF !fn::notification_can({ action: IF $workflow.tenant IS NONE { "read_config" } ELSE { "read" }, tenant: $workflow.tenant }) {
        RETURN fn::error_result("NOTIFICATION_PERMISSION_DENIED", $p.language, {});
    };
    LET $step = array::find($workflow.steps, |$s| $s.key = $p.step_key);
    IF $step IS NONE OR $step.type NOT IN fn::notification_channels({}) { RETURN fn::error_result("NOTIFICATION_NOT_FOUND", $p.language, { resource: "step" }); };
    LET $template = (SELECT * FROM ONLY notification_template WHERE workflow = $workflow.id AND step_key = $p.step_key LIMIT 1);
    IF $template == NONE { RETURN fn::error_result("NOTIFICATION_TEMPLATE_REQUIRED", $p.language, { steps: [$p.step_key] }); };
    -- Langue demandée, sinon celle de l'organisation du parcours, sinon celle de l'installation
    LET $organization = IF $workflow.tenant IS NONE { NONE } ELSE { (SELECT name, locale FROM ONLY $workflow.tenant) };
    LET $chosen = fn::i18n_locale_resolve({ candidates: array::filter([$p.locale, $organization.locale], |$l| $l IS NOT NONE) });
    LET $locale = IF $chosen.ok { $chosen.data.locale } ELSE { NONE };
    LET $texts = IF $locale IS NONE OR array::len($template.keys ?? []) = 0 { { ok: true, data: [] } } ELSE {
        fn::i18n_resolve_many({ keys: $template.keys, locale: $locale, tenant: IF $workflow.tenant IS NONE { NONE } ELSE { <string> $workflow.tenant } })
    };
    LET $layout = IF $template.layout IS NONE { NONE } ELSE { (SELECT html, text FROM ONLY $template.layout) };
    RETURN fn::result_ok({
        workflow: $workflow.id,
        step_key: $p.step_key,
        channel: $step.type,
        locale: $locale,
        recipient_locale: $p.locale,
        organization_name: $organization.name,
        subject: $template.subject,
        html_body: $template.html_body,
        text_body: $template.text_body,
        texts: IF $texts.ok { $texts.data } ELSE { [] },
        texts_error: IF $chosen.ok { IF $texts.ok { NONE } ELSE { $texts.error.code } } ELSE { $chosen.error.code },
        layout_html: $layout.html,
        layout_text: $layout.text,
        payload: $p.payload,
        digest: $p.digest
    });
} COMMENT "Données de l'aperçu d'une étape de canal ({ workflow, step_key, payload : données d'exemple, locale, digest : { count, events } d'exemple }) : gabarit, langue (demandée, sinon de l'organisation, sinon de l'installation), textes des clés dans cette langue, mise en page ; aucune écriture, aucun secret. Rendu par le moteur Rust (NotificationPreview). Permission notification.read (parcours de l'installation : lecture de sa configuration)";
