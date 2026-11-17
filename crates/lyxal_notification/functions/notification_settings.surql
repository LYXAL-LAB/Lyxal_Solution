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
            timezone: { pipeline: [{ rule: "timezone", options: { allow_utc: true } }] },
            max_attempts: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 20 } }] },
            retention_days_runs: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 3650 } }] },
            retention_days_log: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 3650 } }] },
            retention_days_inbox: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 365 } }] },
            max_wait_days: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 366 } }] },
            allowed_hosts: { pipeline: [{ rule: "array_of_strings", options: { allow_empty: true } }, { rule: "array_length", options: { max_length: 100 } }, { rule: "each", options: { pipeline: [{ rule: "hostname", options: { allow_single_label: false } }] } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 60);
    IF !$report.valid OR ($params.tenant IS NOT NONE AND $params.allowed_hosts IS NOT NONE) {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, {
            fields: object::extend($report.by_field ?? {}, IF $params.tenant IS NOT NONE AND $params.allowed_hosts IS NOT NONE { { allowed_hosts: ["CORE_VALIDATION_NOT_ALLOWED"] } } ELSE { {} })
        });
    };
    -- Hôtes autorisés (installation) : rendus en minuscules par la règle hostname, sans doublon
    LET $p = IF $report.value.allowed_hosts IS NONE { $report.value } ELSE {
        object::extend($report.value, { allowed_hosts: fn::sanitize_pipeline_execute($report.value.allowed_hosts, [{ rule: "array_unique" }], 5) })
    };
    IF !fn::notification_can({ action: "manage", tenant: $p.tenant }) { RETURN fn::error_result("NOTIFICATION_PERMISSION_DENIED", $p.language, {}); };
    LET $scope = IF $p.tenant IS NONE { "installation" } ELSE { <string> record::id($p.tenant) };
    LET $changes = object::from_entries(array::filter(
        array::map(["timezone", "max_attempts", "retention_days_runs", "retention_days_log", "retention_days_inbox", "max_wait_days", "allowed_hosts"], |$f| [$f, $p[$f]]),
        |$e| $e[1] IS NOT NONE
    ));
    LET $existing = (SELECT VALUE id FROM ONLY notification_settings WHERE scope_key = $scope LIMIT 1);
    LET $saved = IF $existing IS NONE {
        (CREATE ONLY type::record("notification_settings", $scope) CONTENT object::extend($changes, { tenant: $p.tenant }))
    } ELSE {
        (UPDATE ONLY $existing MERGE $changes)
    };
    IF $saved == NONE { RETURN fn::error_result("NOTIFICATION_WRITE_FORBIDDEN", $p.language, { table: "notification_settings" }); };
    RETURN fn::result_ok($saved);
} COMMENT "Enregistre les réglages d'une portée ({ tenant, timezone, max_attempts, retention_days_runs, retention_days_log, retention_days_inbox : conservation des messages du fil, 1 à 365 jours, 90 par défaut ; max_wait_days : durée maximale des attentes, 1 à 366 jours ; allowed_hosts : installation seulement, hôtes autorisés des adresses web et Mattermost, vide : tout hôte public }) ; seuls les champs fournis changent. Permission notification.manage";

-- ----------------------------------------------------------------------------
-- fn::notification_suppression_address (interne) : adresse contrôlée selon le canal
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_suppression_address($params: object) -> option<string> {
    IF $params.channel = "sms" {
        IF !fn::validation_pipeline_execute($params.address, [{ rule: "phone" }], 5).valid { RETURN NONE; };
        RETURN fn::sanitize_pipeline_execute($params.address, [{ rule: "e164" }], 5);
    };
    IF !fn::validation_pipeline_execute($params.address, [{ rule: "email", options: { max_length: 254 } }], 5).valid { RETURN NONE; };
    RETURN fn::sanitize_pipeline_execute($params.address, [{ rule: "email" }], 5);
} COMMENT "Interne : adresse d'une liste de suppression ({ channel, address }) contrôlée par lyxal_core : e-mail normalisé, ou numéro E.164 pour le canal sms ; NONE si invalide";

-- ----------------------------------------------------------------------------
-- fn::notification_suppression_reason (interne) : motif de suppression d'une adresse
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_suppression_reason($params: object) -> option<string> {
    IF $params.channel NOT IN ["email", "sms"] OR $params.address IS NONE { RETURN NONE; };
    LET $reasons = (SELECT VALUE reason FROM notification_suppression
        WHERE scope_key IN [$params.scope, "installation"] AND channel = $params.channel AND address = $params.address
            AND (keep_until IS NONE OR keep_until > time::now()));
    -- Un parcours critique n'est arrêté que par un rejet définitif ou un blocage manuel
    LET $blocking = IF $params.critical { array::filter($reasons, |$r| $r IN ["hard_bounce", "manual"]) } ELSE { $reasons };
    RETURN IF array::len($blocking) = 0 { NONE } ELSE { array::sort($blocking)[0] };
} COMMENT "Interne : motif qui bloque une adresse ({ scope, channel : email ou sms, address, critical }) dans la liste de l'organisation ou de l'installation (parcours critique : rejet définitif ou blocage manuel seulement), sinon NONE";

-- ----------------------------------------------------------------------------
-- fn::notification_suppression_add
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_suppression_add($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            channel: { pipeline: [{ rule: "enum", options: { allowed: ["email", "sms"], case_sensitive: true } }], default: "email" },
            address: { pipeline: [{ rule: "required_string", options: { min_length: 3, max_length: 254 } }], required: true },
            reason: { pipeline: [{ rule: "enum", options: { allowed: ["hard_bounce", "complaint", "manual"], case_sensitive: true } }], default: "manual" },
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
    LET $address = fn::notification_suppression_address({ channel: $p.channel, address: $p.address });
    IF $address IS NONE { RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", $p.language, { fields: { address: ["CORE_VALIDATION_FORMAT"] } }); };
    LET $existing = (SELECT VALUE id FROM ONLY notification_suppression WHERE scope_key = $scope AND channel = $p.channel AND address = $address LIMIT 1);
    LET $saved = IF $existing IS NONE {
        (CREATE ONLY notification_suppression CONTENT {
            tenant: $p.tenant, channel: $p.channel, address: $address, reason: $p.reason, source: $p.source, keep_until: $p.keep_until
        })
    } ELSE {
        (UPDATE ONLY $existing SET reason = $p.reason, source = $p.source, keep_until = $p.keep_until)
    };
    IF $saved == NONE { RETURN fn::error_result("NOTIFICATION_WRITE_FORBIDDEN", $p.language, { table: "notification_suppression" }); };
    RETURN fn::result_ok($saved);
} COMMENT "Ajoute ou remplace une adresse de la liste de suppression ({ tenant, channel : email (défaut) ou sms ; address : e-mail, ou numéro E.164 pour sms ; reason, source, keep_until }). Permission notification.manage";

-- ----------------------------------------------------------------------------
-- fn::notification_suppression_remove
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_suppression_remove($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            channel: { pipeline: [{ rule: "enum", options: { allowed: ["email", "sms"], case_sensitive: true } }], default: "email" },
            address: { pipeline: [{ rule: "required_string", options: { min_length: 3, max_length: 254 } }], required: true },
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
    LET $address = fn::notification_suppression_address({ channel: $p.channel, address: $p.address });
    IF $address IS NONE { RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", $p.language, { fields: { address: ["CORE_VALIDATION_FORMAT"] } }); };
    LET $existing = (SELECT VALUE id FROM ONLY notification_suppression WHERE scope_key = $scope AND channel = $p.channel AND address = $address LIMIT 1);
    IF $existing IS NONE { RETURN fn::error_result("NOTIFICATION_NOT_FOUND", $p.language, { resource: "suppression" }); };
    LET $deleted = (DELETE $existing RETURN BEFORE);
    IF array::len($deleted) = 0 { RETURN fn::error_result("NOTIFICATION_WRITE_FORBIDDEN", $p.language, { table: "notification_suppression" }); };
    RETURN fn::result_ok({ deleted: $existing });
} COMMENT "Retire une adresse de la liste de suppression ({ tenant, channel : email (défaut) ou sms ; address }). Permission notification.manage";

-- ----------------------------------------------------------------------------
-- fn::notification_suppression_list
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_suppression_list($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            reason: { pipeline: [{ rule: "enum", options: { allowed: ["hard_bounce", "complaint", "manual"], case_sensitive: true } }] },
            channel: { pipeline: [{ rule: "enum", options: { allowed: ["email", "sms"], case_sensitive: true } }] },
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
    LET $rows = (SELECT * FROM notification_suppression
        WHERE scope_key = $scope AND ($p.reason IS NONE OR reason = $p.reason) AND ($p.channel IS NONE OR channel = $p.channel)
        ORDER BY address LIMIT $p.limit START $p.start);
    RETURN fn::result_ok($rows);
} COMMENT "Adresses et numéros supprimés d'une portée ({ tenant, reason, channel, limit, start }), triés par adresse. Permission notification.read";

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
            status: { pipeline: [{ rule: "enum", options: { allowed: ["pending", "waiting", "completed", "failed", "skipped", "canceled", "merged"], case_sensitive: true } }] },
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
