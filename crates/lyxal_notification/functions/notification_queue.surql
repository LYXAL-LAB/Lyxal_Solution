-- ============================================================================
-- FONCTIONS : file d'envoi (worker)
-- MODULE    : lyxal_notification
-- ============================================================================
-- Réservation par `locked_until` et `claim_token` : plusieurs workers se partagent la file sans
-- envoyer deux fois la même étape ; une réservation expirée est reprise. Le délai avant une
-- nouvelle tentative est calculé par le worker (attente exponentielle avec gigue, comme
-- lyxal_event) ; la base décide de la nouvelle tentative ou de l'échec définitif. Permission
-- notification.worker (ou session système).

-- ----------------------------------------------------------------------------
-- fn::notification_run_finalize : état d'un déclenchement quand ses étapes sont terminées ;
-- le secret est alors effacé
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_run_finalize($params: object) -> object {
    LET $statuses = (SELECT VALUE status FROM notification_job WHERE run = $params.run);
    IF array::any($statuses, |$s| $s IN ["queued", "running"]) { RETURN { finalized: false }; };
    LET $final = IF array::any($statuses, |$s| $s = "failed") { "failed" }
        ELSE IF array::all($statuses, |$s| $s IN ["skipped", "canceled"]) { "skipped" }
        ELSE { "completed" };
    UPDATE $params.run SET status = $final, secret = NONE;
    RETURN { finalized: true, status: $final };
} COMMENT "Termine un déclenchement ({ run }) quand toutes ses étapes sont terminées : état final, secret effacé";

-- ----------------------------------------------------------------------------
-- fn::notification_job_claim
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_job_claim($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            worker_id: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 128 } }], required: true },
            limit: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 100 } }], default: 10 },
            lease_seconds: { pipeline: [{ rule: "integer", options: { min_value: 10, max_value: 3600 } }], default: 120 },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::notification_can({ action: "worker" }) { RETURN fn::error_result("NOTIFICATION_PERMISSION_DENIED", $p.language, {}); };
    LET $now = time::now();
    -- Étapes dont le secret a expiré : annulées, jamais envoyées en retard
    LET $expired = (SELECT VALUE id FROM notification_job
        WHERE status IN ["queued", "running"] AND run.expires_at <= $now AND (locked_until IS NONE OR locked_until < $now));
    FOR $job IN $expired {
        UPDATE $job SET status = "canceled", locked_until = NONE, claim_token = NONE,
            last_error = { class: "permanent", code: "NOTIFICATION_RUN_EXPIRED", detail: "secret expiré avant l'envoi" };
        fn::notification_run_finalize({ run: (SELECT VALUE run FROM ONLY $job) });
    };
    -- Réservation expirée après la dernière tentative (worker arrêté pendant l'envoi) : échec définitif
    LET $abandoned = (SELECT VALUE id FROM notification_job
        WHERE status = "running" AND locked_until < $now AND attempts >= max_attempts);
    FOR $job IN $abandoned {
        UPDATE $job SET status = "failed", locked_until = NONE, claim_token = NONE,
            last_error = { class: "transient", code: "NOTIFICATION_JOB_LEASE_EXPIRED", detail: "réservation expirée après la dernière tentative" };
        fn::notification_run_finalize({ run: (SELECT VALUE run FROM ONLY $job) });
    };
    LET $due = (SELECT VALUE id FROM notification_job
        WHERE status IN ["queued", "running"] AND attempts < max_attempts AND next_retry_at <= $now AND (locked_until IS NONE OR locked_until < $now)
        ORDER BY next_retry_at LIMIT $p.limit);
    -- Réservation conditionnelle : si un autre worker l'a prise entre-temps, l'étape est ignorée
    LET $token = <string> rand::uuid::v7();
    FOR $job IN $due {
        UPDATE $job SET status = "running", locked_until = $now + duration::from_secs($p.lease_seconds),
            claim_token = $token, worker_id = $p.worker_id, attempts += 1
            WHERE status IN ["queued", "running"] AND attempts < max_attempts AND (locked_until IS NONE OR locked_until < $now);
    };
    LET $claimed = (SELECT * FROM notification_job WHERE claim_token = $token ORDER BY next_retry_at);
    RETURN fn::result_ok(array::map($claimed, |$job| fn::notification_job_payload({ job: $job })));
} COMMENT "Réserve jusqu'à limit étapes dues ({ worker_id, limit, lease_seconds }) et renvoie tout le nécessaire au rendu ; les étapes dont le secret a expiré sont annulées. Permission notification.worker";

-- ----------------------------------------------------------------------------
-- fn::notification_job_payload : données de rendu d'une étape réservée (langue résolue)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_job_payload($params: object) -> object {
    LET $job = $params.job;
    LET $run = (SELECT * FROM ONLY $job.run);
    LET $workflow = (SELECT * FROM ONLY $run.workflow);
    LET $template = (SELECT * FROM ONLY notification_template WHERE workflow = $workflow.id AND step_key = $job.step_key LIMIT 1);
    LET $settings = fn::notification_settings_effective({ tenant: $run.tenant });
    LET $requested = $run.recipient.locale;
    LET $candidates = array::filter(array::distinct([
        $requested,
        IF $requested IS NONE { NONE } ELSE { string::split($requested, "-")[0] },
        $template.default_locale,
        $settings.default_locale
    ]), |$l| $l IS NOT NONE);
    LET $versions = (SELECT * FROM notification_template_locale WHERE template = $template.id);
    LET $locale = array::find($candidates, |$c| array::any($versions, |$v| $v.locale = $c));
    LET $version = array::find($versions, |$v| $v.locale = $locale);
    LET $layout = IF $template.layout IS NONE { NONE } ELSE { (SELECT html, text FROM ONLY $template.layout) };
    RETURN {
        job_id: $job.id,
        claim_token: $job.claim_token,
        run_id: $run.id,
        tenant: $run.tenant,
        idempotency_key: $run.idempotency_key,
        attempt: $job.attempts,
        recipient: $run.recipient,
        locale: $locale,
        subject: $version.subject,
        html_body: $version.html_body,
        text_body: $version.text_body,
        layout_html: $layout.html,
        layout_text: $layout.text,
        payload: $run.payload,
        secret: $run.secret,
        sensitive: $workflow.sensitive,
        from_name: $settings.from_name,
        reply_to: $settings.reply_to
    };
} COMMENT "Données de rendu d'une étape réservée ({ job }) : gabarit dans la langue résolue (exacte, langue seule, défaut du gabarit, défaut des réglages), mise en page, réglages, secret scellé";

-- ----------------------------------------------------------------------------
-- fn::notification_job_check : réservation encore détenue ?
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_job_check($params: object) -> object {
    LET $job = (SELECT * FROM ONLY $params.job);
    IF $job == NONE { RETURN { code: "NOTIFICATION_NOT_FOUND", job: NONE }; };
    IF $job.status != "running" OR $job.claim_token != $params.claim_token { RETURN { code: "NOTIFICATION_JOB_CLAIM_LOST", job: NONE }; };
    RETURN { code: NONE, job: $job };
} COMMENT "Vérifie qu'une étape ({ job, claim_token }) est encore réservée par ce jeton ; { code, job }";

-- ----------------------------------------------------------------------------
-- fn::notification_job_complete
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_job_complete($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            job_id: { pipeline: [{ rule: "record", options: { expected_table: "notification_job" } }], required: true },
            claim_token: { pipeline: [{ rule: "uuid_v7", options: { allow_string: true } }], required: true },
            provider_message_id: { pipeline: [{ rule: "optional_string", options: { max_length: 512 } }] },
            smtp_code: { pipeline: [{ rule: "integer", options: { min_value: 200, max_value: 599 } }] },
            subject: { pipeline: [{ rule: "optional_string", options: { max_length: 998 } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::notification_can({ action: "worker" }) { RETURN fn::error_result("NOTIFICATION_PERMISSION_DENIED", $p.language, {}); };
    LET $check = fn::notification_job_check({ job: $p.job_id, claim_token: <string> $p.claim_token });
    IF $check.code IS NOT NONE { RETURN fn::error_result($check.code, $p.language, {}); };
    LET $job = $check.job;
    LET $run = (SELECT * FROM ONLY $job.run);
    LET $sensitive = (SELECT VALUE sensitive FROM ONLY $run.workflow);
    LET $settings = fn::notification_settings_effective({ tenant: $run.tenant });
    LET $message = (CREATE ONLY notification_message CONTENT {
        run: $run.id,
        job: $job.id,
        channel: $job.channel,
        to: $run.recipient.email,
        subject: IF $sensitive { NONE } ELSE { $p.subject },
        provider_message_id: $p.provider_message_id,
        status: "sent"
    });
    IF $message == NONE { RETURN fn::error_result("NOTIFICATION_WRITE_FORBIDDEN", $p.language, { table: "notification_message" }); };
    CREATE notification_delivery_log CONTENT {
        run: $run.id, job: $job.id, attempt: $job.attempts, status: "sent",
        code: IF $p.smtp_code IS NONE { NONE } ELSE { <string> $p.smtp_code },
        purge_after: time::now() + duration::from_days($settings.retention_days_log)
    };
    UPDATE $job.id SET status = "completed", locked_until = NONE, claim_token = NONE, last_error = NONE;
    LET $final = fn::notification_run_finalize({ run: $run.id });
    RETURN fn::result_ok({ message: $message.id, status: "completed", run_status: $final.status });
} COMMENT "Termine une étape envoyée ({ job_id, claim_token, provider_message_id, smtp_code, subject }) : message (objet omis si sensible), journal, déclenchement terminé et secret effacé si c'était la dernière étape. Permission notification.worker";

-- ----------------------------------------------------------------------------
-- fn::notification_job_fail
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_job_fail($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            job_id: { pipeline: [{ rule: "record", options: { expected_table: "notification_job" } }], required: true },
            claim_token: { pipeline: [{ rule: "uuid_v7", options: { allow_string: true } }], required: true },
            class: { pipeline: [{ rule: "enum", options: { allowed: ["transient", "permanent", "recipient_rejected"], case_sensitive: true } }], required: true },
            code: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 64 } }], required: true },
            detail: { pipeline: [{ rule: "optional_string", options: { max_length: 512 } }], default: "" },
            retry_delay_seconds: { pipeline: [{ rule: "integer", options: { min_value: 0, max_value: 86400 } }], default: 60 },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::notification_can({ action: "worker" }) { RETURN fn::error_result("NOTIFICATION_PERMISSION_DENIED", $p.language, {}); };
    LET $check = fn::notification_job_check({ job: $p.job_id, claim_token: <string> $p.claim_token });
    IF $check.code IS NOT NONE { RETURN fn::error_result($check.code, $p.language, {}); };
    LET $job = $check.job;
    LET $run = (SELECT * FROM ONLY $job.run);
    LET $settings = fn::notification_settings_effective({ tenant: $run.tenant });
    LET $retry = $p.class = "transient" AND $job.attempts < $job.max_attempts;
    LET $next = time::now() + duration::from_secs($p.retry_delay_seconds);
    LET $error = { class: $p.class, code: $p.code, detail: $p.detail ?? "" };
    IF $retry {
        UPDATE $job.id SET status = "queued", next_retry_at = $next, locked_until = NONE, claim_token = NONE, last_error = $error;
    } ELSE {
        UPDATE $job.id SET status = "failed", locked_until = NONE, claim_token = NONE, last_error = $error;
    };
    CREATE notification_delivery_log CONTENT {
        run: $run.id, job: $job.id, attempt: $job.attempts, status: IF $retry { "retry" } ELSE { "failed" },
        code: $p.code, detail: $p.detail,
        purge_after: time::now() + duration::from_days($settings.retention_days_log)
    };
    IF $p.class = "recipient_rejected" {
        INSERT IGNORE INTO notification_suppression {
            tenant: $run.tenant, channel: "email", address: $run.recipient.email,
            reason: "hard_bounce", source: $p.code
        };
    };
    LET $final = IF $retry { { finalized: false } } ELSE { fn::notification_run_finalize({ run: $run.id }) };
    RETURN fn::result_ok({
        status: IF $retry { "queued" } ELSE { "failed" },
        next_retry_at: IF $retry { $next } ELSE { NONE },
        run_status: $final.status
    });
} COMMENT "Enregistre l'échec d'une étape ({ job_id, claim_token, class : transient, permanent, recipient_rejected ; code, detail, retry_delay_seconds }) : nouvelle tentative tant que attempts < max_attempts pour un échec temporaire, sinon échec définitif ; destinataire refusé : adresse supprimée (hard_bounce). Permission notification.worker";

-- ----------------------------------------------------------------------------
-- fn::notification_purge
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_purge($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            limit: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 10000 } }], default: 500 },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::notification_can({ action: "worker" }) { RETURN fn::error_result("NOTIFICATION_PERMISSION_DENIED", $p.language, {}); };
    LET $now = time::now();
    LET $secrets = (UPDATE notification_run SET secret = NONE WHERE secret IS NOT NONE AND expires_at <= $now RETURN id);
    LET $log_ids = (SELECT VALUE id FROM notification_delivery_log WHERE purge_after <= $now LIMIT $p.limit);
    LET $logs = IF array::len($log_ids) = 0 { [] } ELSE { (DELETE $log_ids RETURN BEFORE) };
    LET $run_ids = (SELECT VALUE id FROM notification_run WHERE purge_after <= $now AND status != "pending" LIMIT $p.limit);
    LET $runs = IF array::len($run_ids) = 0 { [] } ELSE { (DELETE $run_ids RETURN BEFORE) };
    RETURN fn::result_ok({ secrets_cleared: array::len($secrets), log_entries: array::len($logs), runs: array::len($runs) });
} COMMENT "Purge par paquets ({ limit }) : secrets expirés effacés, journal et déclenchements terminés au-delà de leur durée de conservation supprimés (étapes et messages avec eux). Permission notification.worker";
