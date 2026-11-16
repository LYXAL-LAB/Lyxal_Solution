-- ============================================================================
-- FONCTIONS : déclenchement d'un parcours
-- MODULE    : lyxal_notification
-- ============================================================================
-- `to` désigne un abonné (`{ subscriber_id, email, … }`, créé ou mis à jour à la volée), une
-- liste de 100 abonnés au plus, un sujet (`{ topic }`) ou tous les abonnés de la portée
-- (`{ all: true }`). Un sujet ou « tous » est une diffusion, traitée par le worker
-- (fn::notification_broadcast_*). L'auteur de l'action (`actor`, un subscriber_id) n'est pas
-- prévenu, sauf `exclude_actor` faux.

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
        timezone: $own.timezone ?? $base.timezone,
        max_attempts: $own.max_attempts ?? $base.max_attempts ?? 8,
        retention_days_runs: $own.retention_days_runs ?? $base.retention_days_runs ?? 90,
        retention_days_log: $own.retention_days_log ?? $base.retention_days_log ?? 30
    };
} COMMENT "Réglages effectifs ({ tenant }) : organisation sur installation, valeurs par défaut sinon";

-- ----------------------------------------------------------------------------
-- fn::notification_run_create : déclenchement pour un abonné
-- ----------------------------------------------------------------------------
-- { tenant, workflow (parcours), subscriber (abonné), idempotency_key, event_id, payload,
-- secret, expires_at, settings, actor, broadcast } → { status : created, duplicate, skipped ou
-- no_address ; run_id, skip_reason, job_ids }. Une étape sans adresse pour son canal ou refusée
-- par les préférences est écartée (`skipped`, motif no_address:<canal> ou preference:<niveau>) ;
-- une adresse supprimée arrête le déclenchement (un parcours critique n'est arrêté que par un
-- rejet définitif ou un blocage manuel). Idempotent par (portée, clé).

DEFINE FUNCTION OVERWRITE fn::notification_run_create($params: object) -> object {
    LET $workflow = $params.workflow;
    LET $subscriber = $params.subscriber;
    LET $scope = IF $params.tenant IS NONE { "installation" } ELSE { <string> record::id($params.tenant) };
    LET $has_address = |$channel| $channel = "email" AND $subscriber.email IS NOT NONE;
    IF !array::any($workflow.steps, |$step| $has_address($step.channel)) {
        RETURN { status: "no_address", run_id: NONE, skip_reason: "no_address", job_ids: [] };
    };
    LET $decision = fn::notification_preference_resolve({ tenant: $params.tenant, workflow: $workflow, subscriber: $subscriber });
    LET $steps = array::map($workflow.steps, |$step| {
        key: $step.key,
        channel: $step.channel,
        skip: IF !$has_address($step.channel) { string::concat("no_address:", $step.channel) }
            ELSE IF !$decision.channels[$step.channel].allowed { string::concat("preference:", $decision.channels[$step.channel].level) }
            ELSE { NONE }
    });
    LET $reasons = (SELECT VALUE reason FROM notification_suppression
        WHERE scope_key IN [$scope, "installation"] AND channel = "email" AND address = $subscriber.email
            AND (keep_until IS NONE OR keep_until > time::now()));
    LET $blocking = IF $workflow.critical { array::filter($reasons, |$r| $r IN ["hard_bounce", "manual"]) } ELSE { $reasons };
    LET $active = array::filter($steps, |$step| $step.skip IS NONE);
    LET $skip = IF array::len($blocking) > 0 { string::concat("suppressed:", array::sort($blocking)[0]) }
        ELSE IF array::len($active) = 0 { $steps[0].skip }
        ELSE { NONE };
    LET $rid = type::record("notification_run", string::replace(<string> rand::uuid::v7(), "-", ""));
    -- Idempotence par l'index unique (portée, clé) : un rejeu n'insère rien
    LET $inserted = (INSERT IGNORE INTO notification_run {
        id: $rid,
        tenant: $params.tenant,
        workflow: $workflow.id,
        subscriber: $subscriber.id,
        address: { email: $subscriber.email, phone: $subscriber.phone, locale: $subscriber.locale, name: $subscriber.first_name, timezone: $subscriber.timezone },
        broadcast: $params.broadcast,
        actor: $params.actor,
        idempotency_key: $params.idempotency_key,
        event_id: $params.event_id,
        payload: $params.payload,
        secret: IF $skip IS NONE { $params.secret } ELSE { NONE },
        status: IF $skip IS NONE { "pending" } ELSE { "skipped" },
        skip_reason: $skip,
        expires_at: $params.expires_at ?? (time::now() + 7d),
        purge_after: time::now() + duration::from_days($params.settings.retention_days_runs)
    });
    IF array::len($inserted) = 0 {
        LET $existing = (SELECT VALUE id FROM ONLY notification_run WHERE scope_key = $scope AND idempotency_key = $params.idempotency_key LIMIT 1);
        IF $existing IS NONE { RETURN { status: "forbidden", run_id: NONE, skip_reason: NONE, job_ids: [] }; };
        RETURN { status: "duplicate", run_id: $existing, skip_reason: NONE, job_ids: (SELECT VALUE id FROM notification_job WHERE run = $existing) };
    };
    LET $jobs = array::map($steps, |$step| (CREATE ONLY notification_job CONTENT {
        run: $rid,
        step_key: $step.key,
        channel: $step.channel,
        status: IF $skip IS NONE AND $step.skip IS NONE { "queued" } ELSE { "skipped" },
        skip_reason: IF $skip IS NONE { $step.skip } ELSE { $skip },
        max_attempts: $params.settings.max_attempts
    }));
    IF array::any($jobs, |$job| $job == NONE) { THROW "NOTIFICATION_WRITE_FORBIDDEN"; };
    RETURN { status: IF $skip IS NONE { "created" } ELSE { "skipped" }, run_id: $rid, skip_reason: $skip, job_ids: $jobs.id };
} COMMENT "Crée le déclenchement d'un abonné ({ tenant, workflow, subscriber, idempotency_key, event_id, payload, secret, expires_at, settings, actor, broadcast }) et ses étapes ; préférences, adresses par canal et liste de suppression appliquées ; idempotent par (portée, clé). Renvoie { status, run_id, skip_reason, job_ids }";

-- ----------------------------------------------------------------------------
-- fn::notification_trigger_target : destinataire(s) validé(s) de `to`
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_trigger_target($params: object) -> object {
    LET $to = $params.to;
    LET $subscriber_schema = { fields: fn::notification_subscriber_fields({}), unknown_keys: "reject" };
    IF type::is_array($to) {
        IF array::len($to) < 1 OR array::len($to) > 100 { RETURN { valid: false, by_field: { to: ["CORE_VALIDATION_TOO_LONG"] } }; };
        LET $items = array::map($to, |$item| fn::validation_object_execute(IF type::is_string($item) { { subscriber_id: $item } } ELSE { $item }, $subscriber_schema, 60));
        LET $invalid = array::filter(array::map($items, |$item, $index| [<string> $index, $item]), |$entry| !$entry[1].valid);
        IF array::len($invalid) > 0 { RETURN { valid: false, by_field: { to: object::from_entries(array::map($invalid, |$entry| [$entry[0], $entry[1].by_field])) } }; };
        RETURN { valid: true, kind: "list", subscribers: $items.value };
    };
    IF $to.topic IS NOT NONE {
        LET $checked = fn::validation_object_execute($to, { fields: { topic: { pipeline: [{ rule: "snake_case_name", options: { min_length: 1, max_length: 64 } }], required: true } }, unknown_keys: "reject" }, 10);
        RETURN IF $checked.valid { { valid: true, kind: "topic", topic: $checked.value.topic } } ELSE { { valid: false, by_field: { to: $checked.by_field } } };
    };
    IF $to.all IS NOT NONE {
        RETURN IF $to = { all: true } { { valid: true, kind: "all" } } ELSE { { valid: false, by_field: { to: { all: ["CORE_VALIDATION_NOT_ALLOWED"] } } } };
    };
    LET $checked = fn::validation_object_execute($to, $subscriber_schema, 60);
    RETURN IF $checked.valid { { valid: true, kind: "subscriber", subscriber: $checked.value } } ELSE { { valid: false, by_field: { to: $checked.by_field } } };
} COMMENT "Destinataire(s) d'un déclenchement ({ to }) : { valid, kind : subscriber, list, topic, all ; subscriber, subscribers, topic ; by_field }";

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
            to: { pipeline: [{ rule: "allowed_types", options: { allowed_types: ["object", "array"] } }], required: true },
            actor: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 128 } }] },
            exclude_actor: { pipeline: [{ rule: "boolean" }], default: true },
            payload: { pipeline: [{ rule: "is_object" }], default: {} },
            secret: { pipeline: [{ rule: "required_string", options: { min_length: 16, max_length: 8192 } }, { rule: "starts_with", options: { prefixes: ["enc:v2:"], case_sensitive: true, trim_value: false } }] },
            expires_at: { pipeline: [{ rule: "future_datetime", options: { allow_equal: false } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 80);
    LET $language = IF type::is_string($params.language) { $params.language } ELSE { NONE };
    IF !$report.valid OR ($report.value.workflow_key IS NONE AND $report.value.trigger_event IS NONE) {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", $language, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $target = fn::notification_trigger_target({ to: $p.to });
    IF !$target.valid { RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", $p.language, { fields: $target.by_field }); };
    -- Un secret (code, lien) est propre à une personne : jamais pour une liste ni une diffusion
    IF $p.secret IS NOT NONE AND $target.kind != "subscriber" {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", $p.language, { fields: { secret: ["CORE_VALIDATION_NOT_ALLOWED"] } });
    };
    IF !fn::notification_can({ action: "send", tenant: $p.tenant }) { RETURN fn::error_result("NOTIFICATION_PERMISSION_DENIED", $p.language, {}); };
    LET $scope = IF $p.tenant IS NONE { "installation" } ELSE { <string> record::id($p.tenant) };
    -- Parcours actif de l'organisation, sinon de l'installation
    LET $matches = |$w| ($p.workflow_key IS NOT NONE AND $w.key = $p.workflow_key) OR ($p.workflow_key IS NONE AND $w.trigger_event = $p.trigger_event);
    LET $candidates = (SELECT * FROM notification_workflow WHERE scope_key IN [$scope, "installation"]
        AND (($p.workflow_key IS NOT NONE AND key = $p.workflow_key) OR ($p.workflow_key IS NONE AND trigger_event = $p.trigger_event)));
    LET $workflow = array::find($candidates, |$w| $w.scope_key = $scope AND $w.status = "active" AND $matches($w))
        ?? array::find($candidates, |$w| $w.scope_key = "installation" AND $w.status = "active" AND $matches($w));
    IF $workflow == NONE {
        RETURN fn::error_result(IF array::len($candidates) = 0 { "NOTIFICATION_WORKFLOW_NOT_FOUND" } ELSE { "NOTIFICATION_WORKFLOW_INACTIVE" }, $p.language, {});
    };
    IF $workflow.payload_schema IS NOT NONE {
        LET $checked = fn::validation_object_execute($p.payload, $workflow.payload_schema, 80);
        IF !$checked.valid { RETURN fn::error_result("NOTIFICATION_PAYLOAD_INVALID", $p.language, { fields: $checked.by_field }); };
    };
    LET $settings = fn::notification_settings_effective({ tenant: $p.tenant });
    -- Sujet ou tous : diffusion enregistrée, traitée par le worker (idempotente par portée et clé)
    IF $target.kind IN ["topic", "all"] {
        LET $topic = IF $target.kind = "topic" { fn::notification_topic_find({ tenant: $p.tenant, key: $target.topic }) } ELSE { NONE };
        IF $target.kind = "topic" AND $topic IS NONE { RETURN fn::error_result("NOTIFICATION_TOPIC_NOT_FOUND", $p.language, { key: $target.topic }); };
        LET $inserted = (INSERT IGNORE INTO notification_broadcast {
            tenant: $p.tenant, workflow: $workflow.id, idempotency_key: $p.idempotency_key, event_id: $p.event_id,
            topic: $topic.id, to_all: $target.kind = "all", actor: $p.actor, exclude_actor: $p.exclude_actor, payload: $p.payload,
            purge_after: time::now() + duration::from_days($settings.retention_days_runs)
        });
        IF array::len($inserted) > 0 { RETURN fn::result_ok({ kind: "broadcast", broadcast_id: $inserted[0].id, status: "created" }); };
        LET $existing = (SELECT VALUE id FROM ONLY notification_broadcast WHERE scope_key = $scope AND idempotency_key = $p.idempotency_key LIMIT 1);
        IF $existing IS NONE { RETURN fn::error_result("NOTIFICATION_WRITE_FORBIDDEN", $p.language, { table: "notification_broadcast" }); };
        RETURN fn::result_ok({ kind: "broadcast", broadcast_id: $existing, status: "duplicate" });
    };
    -- Un abonné ou une liste : abonnés créés ou mis à jour à la volée (un identifiant seul doit exister)
    LET $deliver = |$input, $key| {
        LET $saved = fn::notification_subscriber_save({ tenant: $p.tenant, input: $input, must_exist: array::len(array::filter(object::values($input), |$v| $v IS NOT NONE)) = 1 });
        IF $saved.code IS NOT NONE { RETURN { subscriber_id: $input.subscriber_id, status: "rejected", code: $saved.code, details: $saved.details }; };
        IF $p.exclude_actor AND $p.actor IS NOT NONE AND $p.actor = $input.subscriber_id {
            RETURN { subscriber_id: $input.subscriber_id, subscriber: $saved.subscriber.id, status: "skipped", skip_reason: "actor", run_id: NONE, job_ids: [] };
        };
        LET $run = fn::notification_run_create({
            tenant: $p.tenant, workflow: $workflow, subscriber: $saved.subscriber, idempotency_key: $key, event_id: $p.event_id,
            payload: $p.payload, secret: $p.secret, expires_at: $p.expires_at, settings: $settings, actor: $p.actor, broadcast: NONE
        });
        RETURN object::extend($run, { subscriber_id: $input.subscriber_id, subscriber: $saved.subscriber.id });
    };
    IF $target.kind = "subscriber" {
        LET $result = $deliver($target.subscriber, $p.idempotency_key);
        IF $result.status = "rejected" { RETURN fn::error_result($result.code, $p.language, $result.details ?? {}); };
        IF $result.status = "no_address" { RETURN fn::error_result("NOTIFICATION_SUBSCRIBER_NO_ADDRESS", $p.language, { channels: array::distinct($workflow.steps.channel) }); };
        IF $result.status = "forbidden" { RETURN fn::error_result("NOTIFICATION_WRITE_FORBIDDEN", $p.language, { table: "notification_run" }); };
        RETURN fn::result_ok(object::extend(object::remove($result, ["subscriber_id"]), { kind: "subscriber" }));
    };
    RETURN fn::result_ok({
        kind: "list",
        runs: array::map($target.subscribers, |$input| $deliver($input, string::concat($p.idempotency_key, "/", $input.subscriber_id)))
    });
} COMMENT "Déclenche un parcours actif (workflow_key ou trigger_event ; organisation puis installation) ({ tenant, idempotency_key, event_id, to, actor, exclude_actor, payload, secret enc:v2 (un seul abonné), expires_at }). to : abonné { subscriber_id, email, phone, first_name, last_name, locale, timezone, data, identity } créé ou mis à jour à la volée, liste de 100 abonnés au plus (clé <clé>/<subscriber_id> par abonné), { topic } ou { all: true } (diffusion asynchrone). Idempotent ; préférences, adresses et liste de suppression appliquées ; auteur exclu sauf exclude_actor faux. Permission notification.send";
