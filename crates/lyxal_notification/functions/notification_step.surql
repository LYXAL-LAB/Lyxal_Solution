-- ============================================================================
-- FONCTIONS : forme des étapes d'un parcours et surcharges d'un déclenchement
-- MODULE    : lyxal_notification
-- ============================================================================
-- Une étape a un type : un canal (`email`, `sms`, `chat`, `webhook`), une
-- attente (`delay` : amount + unit, ou until : chemin d'une date dans les données, avec un
-- décalage offset facultatif), un regroupement (`digest` : window, group_by, lookback) ou une
-- limitation (`throttle` : limit, window, group_by). Champs communs : `key` (unique dans le
-- parcours) et `condition` facultative (forme K2 de lyxal_core). Toutes les durées sont bornées
-- par le réglage max_wait_days. Les entrées sont contrôlées par le moteur de lyxal_core.

-- ----------------------------------------------------------------------------
-- fn::notification_duration_seconds : durée { amount, unit } en secondes
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_duration_seconds($span: object) -> int {
    LET $factors = { seconds: 1, minutes: 60, hours: 3600, days: 86400, weeks: 604800 };
    RETURN $span.amount * $factors[$span.unit];
} COMMENT "Durée { amount, unit : seconds, minutes, hours, days, weeks } en secondes (amount signé pour un décalage)";

-- ----------------------------------------------------------------------------
-- fn::notification_step_fields : schémas lyxal_core des champs d'une étape
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_step_fields($params: object) -> object {
    LET $units = ["seconds", "minutes", "hours", "days", "weeks"];
    LET $span = { pipeline: [{ rule: "is_object" }, { rule: "object", options: { schema: {
        fields: {
            amount: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 1000000 } }], required: true },
            unit: { pipeline: [{ rule: "enum", options: { allowed: $units, case_sensitive: true } }], required: true }
        },
        unknown_keys: "reject"
    } } }] };
    LET $path = { pipeline: [{ rule: "surql_field_path", options: { allow_array_wildcard: false, allow_numeric_index: false, max_segments: 8 } }] };
    RETURN {
        span: $span,
        common: {
            key: { pipeline: [{ rule: "snake_case_name", options: { min_length: 1, max_length: 64 } }], required: true },
            type: { pipeline: [{ rule: "enum", options: { allowed: ["email", "sms", "chat", "webhook", "delay", "digest", "throttle"], case_sensitive: true } }], required: true },
            condition: { pipeline: [{ rule: "is_object" }] }
        },
        email: {},
        sms: {},
        chat: {},
        webhook: {},
        delay: {
            amount: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 1000000 } }] },
            unit: { pipeline: [{ rule: "enum", options: { allowed: $units, case_sensitive: true } }] },
            until: $path,
            offset: { pipeline: [{ rule: "is_object" }, { rule: "object", options: { schema: {
                fields: {
                    amount: { pipeline: [{ rule: "integer", options: { min_value: -1000000, max_value: 1000000 } }], required: true },
                    unit: { pipeline: [{ rule: "enum", options: { allowed: $units, case_sensitive: true } }], required: true }
                },
                unknown_keys: "reject"
            } } }] }
        },
        digest: { window: object::extend($span, { required: true }), group_by: $path, lookback: $span },
        throttle: {
            limit: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 1000 } }], required: true },
            window: object::extend($span, { required: true }),
            group_by: $path
        }
    };
} COMMENT "Schémas lyxal_core des champs d'une étape : { span (durée amount + unit), common, email, sms, chat, webhook, delay, digest, throttle }";

-- ----------------------------------------------------------------------------
-- fn::notification_step_check : contrôle des étapes d'un parcours
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_step_check($params: object) -> object {
    LET $fields = fn::notification_step_fields({});
    LET $types = ["email", "sms", "chat", "webhook", "delay", "digest", "throttle"];
    LET $reports = array::map($params.steps, |$step| fn::validation_object_execute($step, {
        fields: object::extend($fields.common, IF $step.type IN $types { $fields[$step.type] } ELSE { {} }),
        unknown_keys: "reject"
    }, 60));
    LET $invalid = array::filter(array::map($reports, |$report, $index| [<string> $index, $report]), |$entry| !$entry[1].valid);
    IF array::len($invalid) > 0 {
        RETURN { code: "NOTIFICATION_STEP_INVALID", details: { fields: object::from_entries(array::map($invalid, |$entry| [$entry[0], $entry[1].by_field])) } };
    };
    LET $steps = $reports.value;
    IF !fn::validation_pipeline_execute($steps.key, [{ rule: "array_unique" }], 5).valid {
        RETURN { code: "NOTIFICATION_STEP_INVALID", details: { reason: "duplicate_key" } };
    };
    -- Attente : une durée (amount et unit), ou une date des données (until) avec son décalage
    LET $bad_delay = array::find($steps, |$step| $step.type = "delay" AND !(
        ($step.amount IS NOT NONE AND $step.unit IS NOT NONE AND $step.until IS NONE AND $step.offset IS NONE)
        OR ($step.until IS NOT NONE AND $step.amount IS NONE AND $step.unit IS NONE)));
    IF $bad_delay IS NOT NONE { RETURN { code: "NOTIFICATION_STEP_INVALID", details: { step: $bad_delay.key, reason: "delay_form" } }; };
    LET $channels = fn::notification_channels({});
    IF !array::any($steps, |$step| $step.type IN $channels) {
        RETURN { code: "NOTIFICATION_STEP_INVALID", details: { reason: "no_channel_step" } };
    };
    -- Un regroupement ou une limitation précède au moins une étape de canal
    LET $orphan = array::find(array::map($steps, |$step, $index| { step: $step, index: $index }), |$entry|
        $entry.step.type IN ["digest", "throttle"]
        AND !array::any(array::slice($steps, $entry.index + 1), |$next| $next.type IN $channels));
    IF $orphan IS NOT NONE { RETURN { code: "NOTIFICATION_STEP_INVALID", details: { step: $orphan.step.key, reason: "no_channel_after" } }; };
    LET $conditions = array::map(array::filter($steps, |$step| $step.condition IS NOT NONE), |$step| {
        step: $step.key, check: fn::utils_condition_check($step.condition, NONE)
    });
    LET $bad_condition = array::find($conditions, |$entry| !$entry.check.valid);
    IF $bad_condition IS NOT NONE {
        RETURN { code: "NOTIFICATION_CONDITION_INVALID", details: object::extend($bad_condition.check.details, { step: $bad_condition.step }) };
    };
    -- Durées bornées par max_wait_days (réglage de la portée du parcours)
    LET $max = fn::notification_settings_effective({ tenant: $params.tenant }).max_wait_days;
    LET $spans = array::flatten(array::map($steps, |$step| array::filter([
        IF $step.type = "delay" AND $step.amount IS NOT NONE { { amount: $step.amount, unit: $step.unit } } ELSE { NONE },
        $step.offset, $step.window, $step.lookback
    ], |$span| $span IS NOT NONE).map(|$span| { step: $step.key, seconds: math::abs(fn::notification_duration_seconds($span)) })));
    LET $too_long = array::find($spans, |$span| $span.seconds > $max * 86400);
    IF $too_long IS NOT NONE { RETURN { code: "NOTIFICATION_WAIT_TOO_LONG", details: { step: $too_long.step, max_days: $max } }; };
    RETURN { code: NONE, details: {}, steps: $steps };
} COMMENT "Contrôle les étapes d'un parcours ({ steps, tenant }) : forme de chaque type (NOTIFICATION_STEP_INVALID, détail par étape et par champ), clés uniques, attente par durée ou par date des données, au moins une étape de canal, regroupement et limitation suivis d'une étape de canal, conditions (NOTIFICATION_CONDITION_INVALID), durées bornées par max_wait_days (NOTIFICATION_WAIT_TOO_LONG). { code, details, steps (normalisées) }";

-- ----------------------------------------------------------------------------
-- fn::notification_override_check : surcharges d'un déclenchement
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_override_check($params: object) -> object {
    LET $overrides = $params.overrides ?? {};
    LET $shape = fn::validation_object_execute($overrides, {
        fields: { steps: { pipeline: [{ rule: "is_object" }], default: {} } },
        unknown_keys: "reject"
    }, 10);
    IF !$shape.valid { RETURN { code: "NOTIFICATION_OVERRIDE_INVALID", details: { fields: $shape.by_field } }; };
    LET $fields = fn::notification_step_fields({});
    LET $entries = array::map(object::entries($shape.value.steps), |$entry| {
        LET $step = array::find($params.workflow.steps, |$s| $s.key = $entry[0]);
        IF $step IS NONE { RETURN { step: $entry[0], code: "NOTIFICATION_OVERRIDE_INVALID", details: { step: $entry[0], reason: "unknown_step" } }; };
        -- Sauter : toute étape ; durée : une attente ; fenêtre : un regroupement
        LET $allowed = object::extend({ skip: { pipeline: [{ rule: "boolean" }] } },
            IF $step.type = "delay" { { amount: $fields.delay.amount, unit: $fields.delay.unit } }
            ELSE IF $step.type = "digest" { { window: $fields.span } }
            ELSE { {} });
        LET $report = fn::validation_object_execute($entry[1], { fields: $allowed, unknown_keys: "reject" }, 20);
        IF !$report.valid { RETURN { step: $entry[0], code: "NOTIFICATION_OVERRIDE_INVALID", details: { step: $entry[0], fields: $report.by_field } }; };
        IF ($report.value.amount IS NONE) != ($report.value.unit IS NONE) {
            RETURN { step: $entry[0], code: "NOTIFICATION_OVERRIDE_INVALID", details: { step: $entry[0], reason: "delay_form" } };
        };
        LET $span = IF $report.value.amount IS NOT NONE { { amount: $report.value.amount, unit: $report.value.unit } } ELSE { $report.value.window };
        IF $span IS NOT NONE AND fn::notification_duration_seconds($span) > $params.max_wait_days * 86400 {
            RETURN { step: $entry[0], code: "NOTIFICATION_WAIT_TOO_LONG", details: { step: $entry[0], max_days: $params.max_wait_days } };
        };
        RETURN { step: $entry[0], code: NONE, value: $report.value };
    });
    LET $refused = array::find($entries, |$entry| $entry.code IS NOT NONE);
    IF $refused IS NOT NONE { RETURN { code: $refused.code, details: $refused.details }; };
    RETURN { code: NONE, details: {}, overrides: { steps: object::from_entries(array::map($entries, |$entry| [$entry.step, $entry.value])) } };
} COMMENT "Contrôle les surcharges d'un déclenchement ({ overrides : { steps : { <clé> : { skip, amount, unit, window } } }, workflow, max_wait_days }) : étape connue du parcours, skip pour toute étape, amount et unit pour une attente, window pour un regroupement (NOTIFICATION_OVERRIDE_INVALID), durées bornées par max_wait_days (NOTIFICATION_WAIT_TOO_LONG). { code, details, overrides (normalisées) }";
