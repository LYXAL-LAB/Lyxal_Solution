-- ============================================================================
-- FONCTIONS : déclenchement d'un parcours
-- MODULE    : lyxal_notification
-- ============================================================================

-- ----------------------------------------------------------------------------
-- fn::notification_settings_effective : réglages de l'organisation sur ceux de l'installation
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_settings_effective($params: object) -> object {
    LET $base = (SELECT * FROM ONLY notification_settings WHERE scope_key = "installation" LIMIT 1) ?? {};
    LET $own = IF $params.tenant IS NONE { {} } ELSE {
        (SELECT * FROM ONLY notification_settings WHERE scope_key = <string> record::id($params.tenant) LIMIT 1) ?? {}
    };
    RETURN {
        from_name: $own.from_name ?? $base.from_name,
        reply_to: $own.reply_to ?? $base.reply_to,
        max_attempts: $own.max_attempts ?? $base.max_attempts ?? 8,
        retention_days_runs: $own.retention_days_runs ?? $base.retention_days_runs ?? 90,
        retention_days_log: $own.retention_days_log ?? $base.retention_days_log ?? 30
    };
} COMMENT "Réglages effectifs ({ tenant }) : organisation sur installation, valeurs par défaut sinon";

-- ----------------------------------------------------------------------------
-- fn::notification_trigger
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_trigger($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            workflow_key: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 64 } }] },
            trigger_event: { pipeline: [{ rule: "lyxal_event_name", options: { min_segments: 2, max_segments: 6 } }] },
            idempotency_key: { pipeline: [{ rule: "idempotency_key", options: { min_length: 1, max_length: 128 } }], required: true },
            event_id: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 128 } }] },
            recipient: { pipeline: [{ rule: "is_object" }, { rule: "object", options: { schema: {
                fields: {
                    email: { pipeline: [{ rule: "email", options: { max_length: 254 } }], required: true },
                    locale: { pipeline: [{ rule: "locale", options: { require_region: false } }] },
                    name: { pipeline: [{ rule: "optional_string", options: { max_length: 128 } }] }
                },
                unknown_keys: "reject"
            } } }], required: true },
            payload: { pipeline: [{ rule: "is_object" }], default: {} },
            secret: { pipeline: [{ rule: "required_string", options: { min_length: 16, max_length: 8192 } }, { rule: "starts_with", options: { prefixes: ["enc:v2:"], case_sensitive: true, trim_value: false } }] },
            expires_at: { pipeline: [{ rule: "future_datetime", options: { allow_equal: false } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 80);
    IF !$report.valid OR ($report.value.workflow_key IS NONE AND $report.value.trigger_event IS NONE) {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::notification_can({ action: "send", tenant: $p.tenant }) {
        RETURN fn::error_result("NOTIFICATION_PERMISSION_DENIED", $p.language, {});
    };
    LET $scope = IF $p.tenant IS NONE { "installation" } ELSE { <string> record::id($p.tenant) };
    -- Parcours actif de l'organisation, sinon de l'installation
    LET $own = IF $p.tenant IS NONE { NONE } ELSE {
        (SELECT * FROM ONLY notification_workflow WHERE scope_key = $scope AND status = "active"
            AND (($p.workflow_key IS NOT NONE AND key = $p.workflow_key) OR ($p.workflow_key IS NONE AND trigger_event = $p.trigger_event)) LIMIT 1)
    };
    LET $workflow = $own ?? (SELECT * FROM ONLY notification_workflow WHERE scope_key = "installation" AND status = "active"
        AND (($p.workflow_key IS NOT NONE AND key = $p.workflow_key) OR ($p.workflow_key IS NONE AND trigger_event = $p.trigger_event)) LIMIT 1);
    IF $workflow == NONE {
        LET $known = (SELECT VALUE id FROM notification_workflow WHERE scope_key IN [$scope, "installation"]
            AND (($p.workflow_key IS NOT NONE AND key = $p.workflow_key) OR ($p.workflow_key IS NONE AND trigger_event = $p.trigger_event)) LIMIT 1);
        RETURN fn::error_result(IF array::len($known) = 0 { "NOTIFICATION_WORKFLOW_NOT_FOUND" } ELSE { "NOTIFICATION_WORKFLOW_INACTIVE" }, $p.language, {});
    };
    IF $workflow.payload_schema IS NOT NONE {
        LET $checked = fn::validation_object_execute($p.payload, $workflow.payload_schema, 80);
        IF !$checked.valid { RETURN fn::error_result("NOTIFICATION_PAYLOAD_INVALID", $p.language, { fields: $checked.by_field }); };
    };
    LET $email = fn::sanitize_pipeline_execute($p.recipient.email, [{ rule: "email" }], 5);
    LET $settings = fn::notification_settings_effective({ tenant: $p.tenant });
    -- Adresse supprimée : un rejet définitif ou un blocage manuel arrête tout parcours ; une
    -- plainte ou un désabonnement n'arrête pas un parcours critique
    LET $reasons = (SELECT VALUE reason FROM notification_suppression
        WHERE scope_key IN [$scope, "installation"] AND channel = "email" AND address = $email
            AND (keep_until IS NONE OR keep_until > time::now()));
    LET $blocking = IF $workflow.critical {
        array::filter($reasons, |$r| $r IN ["hard_bounce", "manual"])
    } ELSE { $reasons };
    LET $skip = IF array::len($blocking) = 0 { NONE } ELSE { string::concat("suppressed:", array::sort($blocking)[0]) };
    LET $rid = type::record("notification_run", string::replace(<string> rand::uuid::v7(), "-", ""));
    -- Idempotence par l'index unique (portée, clé) : un rejeu n'insère rien
    LET $inserted = (INSERT IGNORE INTO notification_run {
        id: $rid,
        tenant: $p.tenant,
        workflow: $workflow.id,
        idempotency_key: $p.idempotency_key,
        event_id: $p.event_id,
        recipient: { email: $email, locale: $p.recipient.locale, name: $p.recipient.name },
        payload: $p.payload,
        secret: IF $skip IS NONE { $p.secret } ELSE { NONE },
        status: IF $skip IS NONE { "pending" } ELSE { "skipped" },
        skip_reason: $skip,
        expires_at: $p.expires_at ?? (time::now() + 7d),
        purge_after: time::now() + duration::from_days($settings.retention_days_runs)
    });
    IF array::len($inserted) = 0 {
        LET $existing = (SELECT VALUE id FROM ONLY notification_run WHERE scope_key = $scope AND idempotency_key = $p.idempotency_key LIMIT 1);
        RETURN fn::result_ok({ run_id: $existing, status: "duplicate", skip_reason: NONE, job_ids: (SELECT VALUE id FROM notification_job WHERE run = $existing) });
    };
    LET $jobs = array::map($workflow.steps, |$step| (CREATE ONLY notification_job CONTENT {
        run: $rid,
        step_key: $step.key,
        channel: $step.channel,
        status: IF $skip IS NONE { "queued" } ELSE { "skipped" },
        max_attempts: $settings.max_attempts
    }));
    IF array::any($jobs, |$j| $j == NONE) { THROW "NOTIFICATION_WRITE_FORBIDDEN"; };
    RETURN fn::result_ok({
        run_id: $rid,
        status: IF $skip IS NONE { "created" } ELSE { "skipped" },
        skip_reason: $skip,
        job_ids: $jobs.id
    });
} COMMENT "Déclenche un parcours actif (workflow_key ou trigger_event ; organisation puis installation) pour un destinataire ({ tenant, idempotency_key, event_id, recipient, payload, secret enc:v2, expires_at }) ; idempotent par (portée, clé) ; adresse supprimée (rejet définitif ou blocage manuel ; plainte et désabonnement seulement hors parcours critique) : déclenchement abandonné. Permission notification.send";
