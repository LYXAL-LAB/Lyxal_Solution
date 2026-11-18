-- ============================================================================
-- FONCTIONS : calendriers d'exceptions
-- MODULE    : lyxal_scheduler
-- ============================================================================
-- Les règles sont contrôlées ici (forme et valeurs) ; elles sont évaluées par le calcul des
-- dates en Rust (lot 2). Les gardes valent aussi pour une écriture directe dans la table.

-- ----------------------------------------------------------------------------
-- fn::scheduler_calendar_rules_check (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_calendar_rules_check($rules: any) -> object {
    LET $time = "([01][0-9]|2[0-3]):[0-5][0-9]";
    LET $values = { rule: "when", options: { field: "kind", equals: "dates",
        then: [{ rule: "each", options: { pipeline: [{ rule: "date_string" }] } }],
        else: [{ rule: "when", options: { field: "kind", equals: "annual",
            then: [{ rule: "each", options: { pipeline: [{ rule: "regex", options: { pattern: "^(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$" } }] } }],
            else: [{ rule: "when", options: { field: "kind", equals: "weekdays",
                then: [{ rule: "each", options: { pipeline: [{ rule: "weekday" }] } }],
                else: [{ rule: "when", options: { field: "kind", equals: "monthdays",
                    then: [{ rule: "each", options: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 31 } }] } }],
                    else: [{ rule: "each", options: { pipeline: [{ rule: "regex", options: { pattern: "^" + $time + "-" + $time + "$" } }] } }]
                } }]
            } }]
        } }]
    } };
    LET $report = fn::validation_object_execute({ rules: $rules }, {
        fields: {
            rules: {
                pipeline: [
                    { rule: "array" },
                    { rule: "array_length", options: { min_length: 1, max_length: 100 } },
                    { rule: "each", options: { pipeline: [{ rule: "object", options: { schema: {
                        fields: {
                            mode: { pipeline: [{ rule: "enum", options: { allowed: ["include", "exclude"], case_sensitive: true } }], required: true },
                            kind: { pipeline: [{ rule: "enum", options: { allowed: ["dates", "annual", "weekdays", "monthdays", "time_range"], case_sensitive: true } }], required: true },
                            values: { pipeline: [{ rule: "array" }, { rule: "array_length", options: { min_length: 1, max_length: 400 } }, $values], required: true }
                        },
                        unknown_keys: "reject"
                    } } }] } }
                ],
                required: true
            }
        },
        unknown_keys: "reject"
    }, 200);
    RETURN { valid: $report.valid, value: $report.value.rules, by_field: $report.by_field };
} COMMENT "Interne : contrôle les règles d'un calendrier par le moteur du Core : 1 à 100 règles { mode : include | exclude, kind, values (1 à 400) } ; dates « AAAA-MM-JJ », annual « MM-JJ », weekdays 1 à 7, monthdays 1 à 31, time_range « HH:MM-HH:MM ». { valid, value, by_field }";

-- ----------------------------------------------------------------------------
-- fn::scheduler_calendar_write_refusal (interne, garde de création et de modification)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_calendar_write_refusal($before: option<object>, $after: object) -> option<string> {
    IF !fn::scheduler_calendar_rules_check($after.rules).valid { RETURN "SCHEDULER_INVALID_PARAMETERS"; };
    LET $caller = fn::scheduler_caller();
    IF $before == NONE {
        RETURN IF !$caller.system AND $after.created_by != $caller.identity { "SCHEDULER_PERMISSION_DENIED" } ELSE { NONE };
    };
    -- Auteur figé, sauf effacement par la suppression de l'identité
    IF $before.created_by != $after.created_by AND !($after.created_by IS NONE AND $before.created_by IS NOT NONE AND !record::exists($before.created_by)) {
        RETURN "SCHEDULER_PERMISSION_DENIED";
    };
    RETURN NONE;
} COMMENT "Interne : refus d'une écriture de calendrier ($before : NONE à la création, $after) : règles valides ; auteur = appelant à la création (hors session système), figé ensuite. NONE ou code d'erreur";

-- ----------------------------------------------------------------------------
-- fn::scheduler_calendar_delete_refusal (interne, garde de suppression)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_calendar_delete_refusal($before: object) -> option<string> {
    -- Suppression de l'organisation : ses calendriers partent avec elle
    IF $before.tenant IS NOT NONE AND !record::exists($before.tenant) { RETURN NONE; };
    LET $used = (SELECT VALUE id FROM scheduler_schedule WHERE calendars CONTAINS $before.id LIMIT 1);
    RETURN IF array::len($used) > 0 { "SCHEDULER_CALENDAR_IN_USE" } ELSE { NONE };
} COMMENT "Interne : refus de suppression d'un calendrier utilisé par une planification (SCHEDULER_CALENDAR_IN_USE) ; la suppression d'une organisation emporte ses calendriers. NONE ou code d'erreur";

-- ----------------------------------------------------------------------------
-- fn::scheduler_calendar_create
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_calendar_create($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: fn::scheduler_ref("auth_organization") },
            name: { pipeline: [{ rule: "slug", options: { max_length: 64 } }], required: true },
            description: { pipeline: [{ rule: "optional_string", options: { max_length: 1024 } }] },
            rules: { pipeline: [{ rule: "array" }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid { RETURN fn::scheduler_invalid($params, $report.by_field); };
    LET $p = $report.value;
    LET $rules = fn::scheduler_calendar_rules_check($p.rules);
    IF !$rules.valid { RETURN fn::scheduler_invalid($params, $rules.by_field); };
    IF !fn::scheduler_can({ action: "calendar", tenant: $p.tenant }) { RETURN fn::error_result("SCHEDULER_PERMISSION_DENIED", $p.language, {}); };
    LET $inserted = (INSERT IGNORE INTO scheduler_calendar {
        tenant: $p.tenant,
        name: $p.name,
        description: $p.description,
        rules: $rules.value,
        created_by: fn::scheduler_caller().identity
    });
    IF array::len($inserted) = 0 {
        -- Doublon de nom, ou écriture filtrée par les permissions de la table
        LET $existing = (SELECT VALUE id FROM scheduler_calendar WHERE scope_key = fn::scheduler_scope_key($p.tenant) AND name = $p.name LIMIT 1);
        RETURN IF array::len($existing) > 0 { fn::error_result("SCHEDULER_CALENDAR_EXISTS", $p.language, { name: $p.name }) }
            ELSE { fn::error_result("SCHEDULER_WRITE_FORBIDDEN", $p.language, { table: "scheduler_calendar" }) };
    };
    RETURN fn::result_ok($inserted[0]);
} COMMENT "Crée un calendrier d'exceptions ({ name, rules, tenant, description }) ; nom unique dans sa portée (SCHEDULER_CALENDAR_EXISTS) ; règles contrôlées par fn::scheduler_calendar_rules_check. Droit : calendriers";

-- ----------------------------------------------------------------------------
-- fn::scheduler_calendar_update
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_calendar_update($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            calendar: { pipeline: fn::scheduler_ref("scheduler_calendar"), required: true },
            description: { pipeline: [{ rule: "optional_string", options: { max_length: 1024 } }] },
            rules: { pipeline: [{ rule: "array" }] },
            clear: { pipeline: [{ rule: "array_of_strings", options: { allow_empty: true } }, { rule: "each", options: { pipeline: [{ rule: "enum", options: { allowed: ["description"], case_sensitive: true } }] } }], default: [] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid { RETURN fn::scheduler_invalid($params, $report.by_field); };
    LET $p = $report.value;
    LET $rules = IF $p.rules IS NONE { NONE } ELSE { fn::scheduler_calendar_rules_check($p.rules) };
    IF $rules IS NOT NONE AND !$rules.valid { RETURN fn::scheduler_invalid($params, $rules.by_field); };
    LET $calendar = (SELECT * FROM ONLY $p.calendar);
    IF $calendar == NONE { RETURN fn::error_result("SCHEDULER_CALENDAR_NOT_FOUND", $p.language, { calendar: <string> $p.calendar }); };
    IF !fn::scheduler_can({ action: "calendar", tenant: $calendar.tenant }) { RETURN fn::error_result("SCHEDULER_PERMISSION_DENIED", $p.language, {}); };
    LET $updated = (UPDATE ONLY $calendar.id SET
        description = IF "description" IN $p.clear { NONE } ELSE { $p.description ?? description },
        rules = $rules.value ?? rules);
    IF $updated == NONE { RETURN fn::error_result("SCHEDULER_WRITE_FORBIDDEN", $p.language, { table: "scheduler_calendar" }); };
    -- Les planifications qui l'utilisent recalculent leur prochaine échéance
    IF $rules IS NOT NONE {
        UPDATE scheduler_schedule SET next_fire_at = NONE WHERE calendars CONTAINS $calendar.id AND state = "active";
    };
    RETURN fn::result_ok($updated);
} COMMENT "Modifie un calendrier ({ calendar, rules, description, clear : [description] }) ; le nom ne change pas. Des règles nouvelles remettent à calculer la prochaine échéance des planifications actives qui l'utilisent. Droit : calendriers";

-- ----------------------------------------------------------------------------
-- fn::scheduler_calendar_get
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_calendar_get($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            calendar: { pipeline: fn::scheduler_ref("scheduler_calendar"), required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid { RETURN fn::scheduler_invalid($params, $report.by_field); };
    LET $p = $report.value;
    LET $calendar = (SELECT * FROM ONLY $p.calendar);
    IF $calendar == NONE { RETURN fn::error_result("SCHEDULER_CALENDAR_NOT_FOUND", $p.language, { calendar: <string> $p.calendar }); };
    RETURN fn::result_ok(object::extend($calendar, {
        schedules: (SELECT VALUE id FROM scheduler_schedule WHERE calendars CONTAINS $calendar.id ORDER BY name ASC, id ASC LIMIT 100)
    }));
} COMMENT "Calendrier et planifications lisibles qui l'utilisent (100 au plus, par nom puis identifiant : ordre total). Un calendrier illisible est introuvable (SCHEDULER_CALENDAR_NOT_FOUND). Droit : lecture";

-- ----------------------------------------------------------------------------
-- fn::scheduler_calendar_list
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_calendar_list($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: fn::scheduler_ref("auth_organization") },
            limit: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 500 } }], default: 100 },
            start: { pipeline: [{ rule: "integer", options: { min_value: 0 } }], default: 0 },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid { RETURN fn::scheduler_invalid($params, $report.by_field); };
    LET $p = $report.value;
    IF !fn::scheduler_can({ action: "read", tenant: $p.tenant }) { RETURN fn::error_result("SCHEDULER_PERMISSION_DENIED", $p.language, {}); };
    LET $all = (SELECT * FROM scheduler_calendar WHERE scope_key = fn::scheduler_scope_key($p.tenant) ORDER BY name ASC);
    RETURN fn::result_ok({ items: array::slice($all, $p.start, $p.start + $p.limit), total: array::len($all) });
} COMMENT "Calendriers d'une portée ({ tenant, limit (500 au plus), start }), par nom : { items, total }. Droit : lecture";

-- ----------------------------------------------------------------------------
-- fn::scheduler_calendar_delete
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_calendar_delete($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            calendar: { pipeline: fn::scheduler_ref("scheduler_calendar"), required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid { RETURN fn::scheduler_invalid($params, $report.by_field); };
    LET $p = $report.value;
    LET $calendar = (SELECT * FROM ONLY $p.calendar);
    IF $calendar == NONE { RETURN fn::error_result("SCHEDULER_CALENDAR_NOT_FOUND", $p.language, { calendar: <string> $p.calendar }); };
    IF !fn::scheduler_can({ action: "calendar", tenant: $calendar.tenant }) { RETURN fn::error_result("SCHEDULER_PERMISSION_DENIED", $p.language, {}); };
    LET $used = (SELECT VALUE id FROM scheduler_schedule WHERE calendars CONTAINS $calendar.id LIMIT 1);
    IF array::len($used) > 0 { RETURN fn::error_result("SCHEDULER_CALENDAR_IN_USE", $p.language, { calendar: <string> $calendar.id }); };
    LET $deleted = (DELETE ONLY $calendar.id RETURN BEFORE);
    IF $deleted == NONE { RETURN fn::error_result("SCHEDULER_WRITE_FORBIDDEN", $p.language, { table: "scheduler_calendar" }); };
    RETURN fn::result_ok({ deleted: <string> $calendar.id });
} COMMENT "Supprime un calendrier ({ calendar }) ; refusé tant qu'une planification l'utilise (SCHEDULER_CALENDAR_IN_USE). Droit : calendriers";
