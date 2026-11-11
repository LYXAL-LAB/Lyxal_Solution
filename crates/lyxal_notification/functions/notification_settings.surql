-- ============================================================================
-- FONCTIONS : réglages, liste de suppression, activité
-- MODULE    : lyxal_notification
-- ============================================================================

-- ----------------------------------------------------------------------------
-- fn::notification_settings_get
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_settings_get($params: object) {
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
    IF !fn::notification_can({ action: "read", tenant: $p.tenant }) { RETURN fn::error_result("NOTIFICATION_PERMISSION_DENIED", $p.language, {}); };
    LET $scope = IF $p.tenant IS NONE { "installation" } ELSE { <string> record::id($p.tenant) };
    RETURN fn::result_ok({
        own: (SELECT * FROM ONLY notification_settings WHERE scope_key = $scope LIMIT 1),
        effective: fn::notification_settings_effective({ tenant: $p.tenant })
    });
} COMMENT "Réglages d'une portée ({ tenant }) : { own, effective } (organisation sur installation, valeurs par défaut sinon). Permission notification.read";

-- ----------------------------------------------------------------------------
-- fn::notification_settings_set
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_settings_set($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            from_name: { pipeline: [{ rule: "display_name", options: { min_length: 1, max_length: 128, allow_emoji: false } }] },
            reply_to: { pipeline: [{ rule: "email", options: { max_length: 254 } }] },
            max_attempts: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 20 } }] },
            retention_days_runs: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 3650 } }] },
            retention_days_log: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 3650 } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::notification_can({ action: "manage", tenant: $p.tenant }) { RETURN fn::error_result("NOTIFICATION_PERMISSION_DENIED", $p.language, {}); };
    LET $scope = IF $p.tenant IS NONE { "installation" } ELSE { <string> record::id($p.tenant) };
    LET $changes = object::from_entries(array::filter(
        array::map(["from_name", "reply_to", "max_attempts", "retention_days_runs", "retention_days_log"], |$f| [$f, $p[$f]]),
        |$e| $e[1] IS NOT NONE
    ));
    LET $changes = IF $changes.reply_to IS NONE { $changes } ELSE {
        object::extend($changes, { reply_to: fn::sanitize_pipeline_execute($changes.reply_to, [{ rule: "email" }], 5) })
    };
    LET $existing = (SELECT VALUE id FROM ONLY notification_settings WHERE scope_key = $scope LIMIT 1);
    LET $saved = IF $existing IS NONE {
        (CREATE ONLY type::record("notification_settings", $scope) CONTENT object::extend($changes, { tenant: $p.tenant }))
    } ELSE {
        (UPDATE ONLY $existing MERGE $changes)
    };
    IF $saved == NONE { RETURN fn::error_result("NOTIFICATION_WRITE_FORBIDDEN", $p.language, { table: "notification_settings" }); };
    RETURN fn::result_ok($saved);
} COMMENT "Enregistre les réglages d'une portée ({ tenant, from_name, reply_to, max_attempts, retention_days_runs, retention_days_log }) ; seuls les champs fournis changent. Permission notification.manage";

-- ----------------------------------------------------------------------------
-- fn::notification_suppression_add
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_suppression_add($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            address: { pipeline: [{ rule: "email", options: { max_length: 254 } }], required: true },
            reason: { pipeline: [{ rule: "enum", options: { allowed: ["hard_bounce", "complaint", "unsubscribe", "manual"], case_sensitive: true } }], default: "manual" },
            source: { pipeline: [{ rule: "optional_string", options: { max_length: 256 } }] },
            keep_until: { pipeline: [{ rule: "future_datetime", options: { allow_equal: false } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::notification_can({ action: "manage", tenant: $p.tenant }) { RETURN fn::error_result("NOTIFICATION_PERMISSION_DENIED", $p.language, {}); };
    LET $scope = IF $p.tenant IS NONE { "installation" } ELSE { <string> record::id($p.tenant) };
    LET $address = fn::sanitize_pipeline_execute($p.address, [{ rule: "email" }], 5);
    LET $existing = (SELECT VALUE id FROM ONLY notification_suppression WHERE scope_key = $scope AND channel = "email" AND address = $address LIMIT 1);
    LET $saved = IF $existing IS NONE {
        (CREATE ONLY notification_suppression CONTENT {
            tenant: $p.tenant, channel: "email", address: $address, reason: $p.reason, source: $p.source, keep_until: $p.keep_until
        })
    } ELSE {
        (UPDATE ONLY $existing SET reason = $p.reason, source = $p.source, keep_until = $p.keep_until)
    };
    IF $saved == NONE { RETURN fn::error_result("NOTIFICATION_WRITE_FORBIDDEN", $p.language, { table: "notification_suppression" }); };
    RETURN fn::result_ok($saved);
} COMMENT "Ajoute ou remplace une adresse de la liste de suppression ({ tenant, address, reason, source, keep_until }). Permission notification.manage";

-- ----------------------------------------------------------------------------
-- fn::notification_suppression_remove
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_suppression_remove($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            address: { pipeline: [{ rule: "email", options: { max_length: 254 } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::notification_can({ action: "manage", tenant: $p.tenant }) { RETURN fn::error_result("NOTIFICATION_PERMISSION_DENIED", $p.language, {}); };
    LET $scope = IF $p.tenant IS NONE { "installation" } ELSE { <string> record::id($p.tenant) };
    LET $address = fn::sanitize_pipeline_execute($p.address, [{ rule: "email" }], 5);
    LET $existing = (SELECT VALUE id FROM ONLY notification_suppression WHERE scope_key = $scope AND channel = "email" AND address = $address LIMIT 1);
    IF $existing IS NONE { RETURN fn::error_result("NOTIFICATION_NOT_FOUND", $p.language, { resource: "suppression" }); };
    LET $deleted = (DELETE $existing RETURN BEFORE);
    IF array::len($deleted) = 0 { RETURN fn::error_result("NOTIFICATION_WRITE_FORBIDDEN", $p.language, { table: "notification_suppression" }); };
    RETURN fn::result_ok({ deleted: $existing });
} COMMENT "Retire une adresse de la liste de suppression ({ tenant, address }). Permission notification.manage";

-- ----------------------------------------------------------------------------
-- fn::notification_suppression_list
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_suppression_list($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            reason: { pipeline: [{ rule: "enum", options: { allowed: ["hard_bounce", "complaint", "unsubscribe", "manual"], case_sensitive: true } }] },
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
    LET $rows = IF $p.reason IS NONE {
        (SELECT * FROM notification_suppression WHERE scope_key = $scope ORDER BY address LIMIT $p.limit START $p.start)
    } ELSE {
        (SELECT * FROM notification_suppression WHERE scope_key = $scope AND reason = $p.reason ORDER BY address LIMIT $p.limit START $p.start)
    };
    RETURN fn::result_ok($rows);
} COMMENT "Adresses supprimées d'une portée ({ tenant, reason, limit, start }), triées par adresse. Permission notification.read";

-- ----------------------------------------------------------------------------
-- fn::notification_run_get
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_run_get($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            run: { pipeline: [{ rule: "record", options: { expected_table: "notification_run" } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $run = (SELECT * OMIT secret FROM ONLY $p.run);
    IF $run == NONE { RETURN fn::error_result("NOTIFICATION_NOT_FOUND", $p.language, { resource: "run" }); };
    RETURN fn::result_ok(object::extend($run, {
        jobs: (SELECT * OMIT claim_token FROM notification_job WHERE run = $run.id ORDER BY created_at),
        messages: (SELECT * FROM notification_message WHERE run = $run.id ORDER BY sent_at),
        log: (SELECT * FROM notification_delivery_log WHERE run = $run.id ORDER BY at)
    }));
} COMMENT "Déclenchement ({ run }) avec ses étapes, messages et journal ; jamais de secret. Permission notification.read (ou notification.send pour qui l'a déclenché)";

-- ----------------------------------------------------------------------------
-- fn::notification_run_list
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_run_list($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            status: { pipeline: [{ rule: "enum", options: { allowed: ["pending", "completed", "failed", "skipped"], case_sensitive: true } }] },
            workflow: { pipeline: [{ rule: "record", options: { expected_table: "notification_workflow" } }] },
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
    RETURN fn::result_ok(SELECT * OMIT secret FROM notification_run
        WHERE scope_key = $scope AND ($p.status IS NONE OR status = $p.status) AND ($p.workflow IS NONE OR workflow = $p.workflow)
        ORDER BY created_at DESC LIMIT $p.limit START $p.start);
} COMMENT "Déclenchements d'une portée ({ tenant, status, workflow, limit, start }), du plus récent au plus ancien ; jamais de secret. Permission notification.read";
