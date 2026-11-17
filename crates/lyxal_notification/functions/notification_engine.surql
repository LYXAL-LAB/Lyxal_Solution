-- ============================================================================
-- FONCTIONS : moteur d'étapes des parcours
-- MODULE    : lyxal_notification
-- ============================================================================
-- Les étapes d'un déclenchement s'exécutent dans l'ordre : une étape n'est créée qu'à la fin de
-- la précédente. Une seule fonction fait avancer un déclenchement
-- (fn::notification_run_advance) ; elle est appelée au déclenchement, à la fin de chaque envoi et
-- à la fin de chaque attente, et elle est idempotente (index unique (déclenchement, étape)).
--
--   canal (email)  : étape en file, envoyée par le worker du canal, puis advance ;
--   attente (delay): étape en file avec sa fin (wait_until) ; le worker d'étapes la confie à
--                    lyxal_scheduler (fn::scheduler_run_enqueue, tâche notification.run_resume),
--                    qui appelle fn::notification_run_resume à l'échéance ;
--   regroupement   : regroupement ouvert pour la clé ? le déclenchement le rejoint (merged) ;
--                    sinon il l'ouvre et attend la fin de la fenêtre comme une attente ;
--   limitation     : compteur de la fenêtre au-delà de la limite ? fin (motif throttled).
--
-- Une condition fausse ou une surcharge `skip` saute l'étape (skipped). Un envoi de test ignore
-- attentes, regroupements et limitations. Les fonctions de ce fichier sont internes, sauf
-- fn::notification_wait_schedule (worker) et fn::notification_run_resume (planificateur).

-- ----------------------------------------------------------------------------
-- fn::notification_job_add : étape engagée (idempotente)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_job_add($params: object) -> object {
    LET $inserted = (INSERT IGNORE INTO notification_job {
        run: $params.run,
        step_key: $params.step_key,
        type: $params.type,
        status: $params.status,
        skip_reason: $params.skip_reason,
        wait_until: $params.wait_until,
        last_error: $params.last_error,
        max_attempts: $params.max_attempts ?? 8
    });
    -- Rien d'inséré : étape déjà engagée (rejeu), sinon écriture refusée par les permissions
    IF array::len($inserted) = 0 AND count(SELECT VALUE id FROM notification_job WHERE run = $params.run AND step_key = $params.step_key) = 0 {
        THROW "NOTIFICATION_WRITE_FORBIDDEN";
    };
    RETURN { job: $inserted[0].id, status: $params.status };
} COMMENT "Interne : engage une étape ({ run, step_key, type, status, skip_reason, wait_until, last_error, max_attempts }) ; une étape déjà engagée n'est pas recréée (index unique)";

-- ----------------------------------------------------------------------------
-- fn::notification_step_context : valeur évaluée par les conditions d'étape
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_step_context($params: object) -> object {
    LET $run = $params.run;
    LET $subscriber = IF $run.subscriber IS NONE { NONE } ELSE { (SELECT subscriber_id, locale, timezone, data FROM ONLY $run.subscriber) };
    LET $jobs = (SELECT step_key, status FROM notification_job WHERE run = $run.id);
    RETURN {
        payload: $run.payload,
        subscriber: {
            subscriber_id: $subscriber.subscriber_id,
            locale: $subscriber.locale,
            timezone: $subscriber.timezone,
            data: $subscriber.data ?? {}
        },
        steps: object::from_entries(array::map($jobs, |$job| [$job.step_key, { status: $job.status }]))
    };
} COMMENT "Interne : contexte des conditions d'étape ({ run }) : { payload, subscriber : { subscriber_id, locale, timezone, data }, steps : { <clé> : { status } } } ; jamais le secret";

-- ----------------------------------------------------------------------------
-- fn::notification_wait_due : fin d'une attente ou d'une fenêtre de regroupement
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_wait_due($params: object) -> object {
    LET $step = $params.step;
    LET $override = $params.override ?? {};
    LET $now = time::now();
    LET $max = fn::notification_settings_effective({ tenant: $params.run.tenant }).max_wait_days;
    LET $span = IF $step.type = "digest" { $override.window ?? $step.window }
        ELSE IF $override.amount IS NOT NONE { { amount: $override.amount, unit: $override.unit } }
        ELSE IF $step.until IS NONE { { amount: $step.amount, unit: $step.unit } }
        ELSE { NONE };
    LET $until = IF $span IS NOT NONE { $now + duration::from_secs(fn::notification_duration_seconds($span)) } ELSE {
        -- Date lue dans les données (RFC 3339), décalée de offset
        LET $raw = fn::utils_object_get_path($params.context, string::split($step.until, "."), NONE);
        LET $date = IF type::is_datetime($raw) { $raw } ELSE IF fn::validation_datetime_string($raw, NONE).valid { <datetime> $raw } ELSE { NONE };
        LET $shift = IF $step.offset IS NONE { 0 } ELSE { fn::notification_duration_seconds($step.offset) };
        IF $date IS NONE { NONE } ELSE IF $shift >= 0 { $date + duration::from_secs($shift) } ELSE { $date - duration::from_secs(math::abs($shift)) }
    };
    IF $until IS NONE { RETURN { code: "NOTIFICATION_PAYLOAD_INVALID", detail: string::concat("date absente ou illisible : ", $step.until), until: NONE }; };
    IF $until > $now + duration::from_days($max) {
        RETURN { code: "NOTIFICATION_WAIT_TOO_LONG", detail: string::concat("au-delà de max_wait_days (", <string> $max, " jours)"), until: NONE };
    };
    RETURN { code: NONE, detail: NONE, until: $until };
} COMMENT "Interne : fin d'une attente ({ run, step, override, context }) : durée (amount + unit, surchargée au déclenchement), ou date lue dans les données au chemin until, décalée de offset ; fenêtre d'un regroupement (window, surchargée). { code (NOTIFICATION_PAYLOAD_INVALID : date absente ou illisible ; NOTIFICATION_WAIT_TOO_LONG : au-delà de max_wait_days), detail, until }";

-- ----------------------------------------------------------------------------
-- fn::notification_group_key : clé de regroupement ou de limitation lue dans les données
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_group_key($params: object) -> string {
    IF $params.step.group_by IS NONE { RETURN ""; };
    LET $value = fn::utils_object_get_path($params.context, string::split($params.step.group_by, "."), NONE);
    RETURN IF $value IS NONE OR type::is_null($value) { "" } ELSE { <string> $value };
} COMMENT "Interne : clé lue dans le contexte au chemin group_by de l'étape ({ step, context }) ; vide sans group_by ou valeur absente";

-- ----------------------------------------------------------------------------
-- fn::notification_digest_merge : déclenchement qui rejoint un regroupement ouvert
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_digest_merge($params: object) -> object {
    LET $event = { run: $params.run.id, payload: $params.run.payload, at: time::now() };
    LET $updated = (UPDATE ONLY $params.digest SET count += 1,
        events = IF array::len(events) < 100 { array::append(events, $event) } ELSE { events }
        WHERE status = "open");
    IF $updated == NONE { THROW "NOTIFICATION_WRITE_FORBIDDEN"; };
    LET $job = fn::notification_job_add({ run: $params.run.id, step_key: $params.step.key, type: "digest", status: "merged" });
    UPDATE $params.run.id SET status = "merged", digest = $params.digest, secret = NONE;
    RETURN $job;
} COMMENT "Interne : le déclenchement ({ run, step, digest }) rejoint le regroupement ouvert : nombre et données (100 premiers) mis à jour, étape et déclenchement merged (secret effacé)";

-- ----------------------------------------------------------------------------
-- fn::notification_digest_join : étape de regroupement
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_digest_join($params: object) -> object {
    LET $run = $params.run;
    LET $step = $params.step;
    LET $group = fn::notification_group_key({ step: $step, context: $params.context });
    LET $slot = string::concat($run.scope_key, "/", <string> $run.workflow, "/", IF $run.subscriber IS NONE { "-" } ELSE { <string> $run.subscriber }, "/", $step.key, "/", $group);
    LET $open = (SELECT VALUE id FROM ONLY notification_digest WHERE open_slot = $slot LIMIT 1);
    IF $open IS NOT NONE { RETURN fn::notification_digest_merge({ run: $run, step: $step, digest: $open }); };
    -- Recul : rien n'est arrivé pour cette clé depuis lookback, le message part tout de suite
    -- (regroupement d'un seul événement, fermé aussitôt, qui marque l'arrivée)
    LET $now = time::now();
    LET $immediate = $step.lookback IS NOT NONE AND count(SELECT VALUE id FROM notification_digest
        WHERE slot = $slot AND created_at > $now - duration::from_secs(fn::notification_duration_seconds($step.lookback))) = 0;
    LET $retention = fn::notification_settings_effective({ tenant: $run.tenant }).retention_days_runs;
    LET $inserted = (INSERT IGNORE INTO notification_digest {
        tenant: $run.tenant,
        workflow: $run.workflow,
        subscriber: $run.subscriber,
        step_key: $step.key,
        group_key: $group,
        slot: $slot,
        open_slot: IF $immediate { NONE } ELSE { $slot },
        carrier: $run.id,
        status: IF $immediate { "closed" } ELSE { "open" },
        ends_at: IF $immediate { $now } ELSE { $params.until },
        count: 1,
        events: [{ run: $run.id, payload: $run.payload, at: $now }],
        closed_at: IF $immediate { $now } ELSE { NONE },
        purge_after: $params.until + duration::from_days($retention)
    });
    IF array::len($inserted) = 0 {
        -- Ouvert entre-temps par un autre déclenchement de la même clé : rejoint
        LET $raced = (SELECT VALUE id FROM ONLY notification_digest WHERE open_slot = $slot LIMIT 1);
        IF $raced IS NONE { THROW "NOTIFICATION_WRITE_FORBIDDEN"; };
        RETURN fn::notification_digest_merge({ run: $run, step: $step, digest: $raced });
    };
    UPDATE $run.id SET digest = $inserted[0].id;
    RETURN fn::notification_job_add(object::extend({ run: $run.id, step_key: $step.key, type: "digest" },
        IF $immediate { { status: "completed" } } ELSE { { status: "queued", wait_until: $params.until } }));
} COMMENT "Interne : étape de regroupement ({ run, step, context, until : fin de la fenêtre }) : clé (portée, parcours, abonné, étape, valeur au chemin group_by) ; regroupement ouvert : rejoint (merged) ; sinon ouvert par ce déclenchement, porteur, qui attend la fin de la fenêtre ; avec lookback et aucune arrivée récente pour la clé : le message part tout de suite";

-- ----------------------------------------------------------------------------
-- fn::notification_throttle_hit : étape de limitation
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_throttle_hit($params: object) -> object {
    LET $run = $params.run;
    LET $step = $params.step;
    LET $job = |$fields| fn::notification_job_add(object::extend({ run: $run.id, step_key: $step.key, type: "throttle" }, $fields));
    -- Un parcours critique n'est jamais limité
    IF $params.workflow.critical { RETURN $job({ status: "completed" }); };
    LET $seconds = fn::notification_duration_seconds($step.window);
    LET $start = time::floor(time::now(), duration::from_secs($seconds));
    LET $group = fn::notification_group_key({ step: $step, context: $params.context });
    LET $counter = type::record("notification_rate_limit", [$run.scope_key, <string> $run.workflow,
        IF $run.subscriber IS NONE { "-" } ELSE { <string> $run.subscriber }, $step.key, $group, $start]);
    -- Compté atomiquement : au-delà de la limite, le déclenchement s'arrête (rien n'attend)
    LET $hit = (UPSERT ONLY $counter SET tenant = $run.tenant, workflow = $run.workflow, subscriber = $run.subscriber,
        step_key = $step.key, group_key = $group, window_start = $start, count = (count ?? 0) + 1,
        purge_after = $start + duration::from_secs($seconds) RETURN AFTER);
    IF $hit == NONE { THROW "NOTIFICATION_WRITE_FORBIDDEN"; };
    IF $hit.count > $step.limit {
        LET $result = $job({ status: "skipped", skip_reason: "throttled" });
        fn::notification_run_finalize({ run: $run.id, reason: "throttled" });
        RETURN $result;
    };
    RETURN $job({ status: "completed" });
} COMMENT "Interne : étape de limitation ({ run, workflow, step, context }) : au plus limit messages par fenêtre fixe (window), par abonné, parcours et clé lue au chemin group_by ; au-delà, étape skipped et déclenchement terminé (motif throttled) ; jamais pour un parcours critique";

-- ----------------------------------------------------------------------------
-- fn::notification_step_enter : engage l'étape suivante d'un déclenchement
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_step_enter($params: object) -> object {
    LET $run = $params.run;
    LET $step = $params.step;
    LET $override = $run.overrides.steps[$step.key] ?? {};
    LET $job = |$fields| fn::notification_job_add(object::extend({ run: $run.id, step_key: $step.key, type: $step.type }, $fields));
    UPDATE $run.id SET cursor = $params.index + 1;
    IF $override.skip = true { RETURN $job({ status: "skipped", skip_reason: "override" }); };
    LET $context = fn::notification_step_context({ run: $run });
    IF $step.condition IS NOT NONE AND !fn::utils_condition_evaluate($context, $step.condition, NONE).matched {
        RETURN $job({ status: "skipped", skip_reason: "condition" });
    };
    -- Canal : adresse, préférences de l'abonné (relues à la réservation) et liste de suppression
    IF $step.type IN fn::notification_channels({}) {
        LET $subscriber = IF $run.subscriber IS NONE { NONE } ELSE { (SELECT * FROM ONLY $run.subscriber) };
        LET $choice = fn::notification_preference_resolve({ tenant: $run.tenant, workflow: $params.workflow, subscriber: $subscriber }).channels[$step.type];
        LET $address = fn::notification_channel_address({ type: $step.type, address: $run.address, subscriber: $run.subscriber });
        LET $suppressed = fn::notification_suppression_reason({ scope: $run.scope_key, channel: $step.type, address: $address, critical: $params.workflow.critical });
        RETURN IF $address IS NONE { $job({ status: "skipped", skip_reason: string::concat("no_address:", $step.type) }) }
            ELSE IF !$choice.allowed { $job({ status: "skipped", skip_reason: string::concat("preference:", $choice.level) }) }
            ELSE IF $suppressed IS NOT NONE { $job({ status: "skipped", skip_reason: string::concat("suppressed:", $suppressed) }) }
            ELSE { $job({ status: "queued", max_attempts: fn::notification_settings_effective({ tenant: $run.tenant }).max_attempts }) };
    };
    -- Envoi de test : ni attente, ni regroupement, ni limitation
    IF $run.test { RETURN $job({ status: "skipped", skip_reason: "test" }); };
    IF $step.type = "throttle" { RETURN fn::notification_throttle_hit({ run: $run, workflow: $params.workflow, step: $step, context: $context }); };
    LET $due = fn::notification_wait_due({ run: $run, step: $step, override: $override, context: $context });
    IF $due.code IS NOT NONE { RETURN $job({ status: "failed", last_error: { class: "permanent", code: $due.code, detail: $due.detail } }); };
    IF $step.type = "digest" { RETURN fn::notification_digest_join({ run: $run, step: $step, context: $context, until: $due.until }); };
    RETURN IF $due.until <= time::now() { $job({ status: "completed" }) } ELSE { $job({ status: "queued", wait_until: $due.until }) };
} COMMENT "Interne : engage l'étape ({ run, workflow, step, index }) : surcharge skip ou condition fausse : skipped ; canal : en file, ou skipped (no_address:<canal>, preference:<niveau>, suppressed:<motif> pour un e-mail ou un numéro supprimé) ; attente : en file jusqu'à sa fin (date passée : terminée) ; regroupement ; limitation ; envoi de test : skipped (test). Date d'attente illisible ou trop lointaine : étape failed";

-- ----------------------------------------------------------------------------
-- fn::notification_run_finalize : état final d'un déclenchement
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_run_finalize($params: object) -> object {
    LET $jobs = (SELECT type, status, skip_reason, created_at FROM notification_job WHERE run = $params.run ORDER BY created_at);
    IF array::any($jobs, |$job| $job.status IN ["queued", "running", "waiting"]) { RETURN { status: (SELECT VALUE status FROM ONLY $params.run) }; };
    LET $channels = fn::notification_channels({});
    LET $sends = array::filter($jobs, |$job| $job.type IN $channels);
    LET $final = IF array::any($jobs, |$job| $job.status = "failed") { "failed" }
        ELSE IF array::any($sends, |$job| $job.status = "completed") { "completed" }
        ELSE { "skipped" };
    LET $reason = $params.reason ?? IF $final != "skipped" { NONE }
        ELSE { array::find($sends, |$job| $job.skip_reason IS NOT NONE).skip_reason ?? array::find($jobs, |$job| $job.skip_reason IS NOT NONE).skip_reason };
    LET $updated = (UPDATE ONLY $params.run SET status = $final, skip_reason = $reason, secret = NONE WHERE status IN ["pending", "waiting"]);
    RETURN { status: $updated.status ?? (SELECT VALUE status FROM ONLY $params.run) };
} COMMENT "Interne : termine un déclenchement ({ run, reason }) dont aucune étape n'est en cours : failed si une étape a échoué, completed si un message est parti, skipped sinon (motif reason, sinon celui de la première étape de canal écartée) ; secret effacé. Un déclenchement annulé ou fusionné garde son état. { status }";

-- ----------------------------------------------------------------------------
-- fn::notification_run_advance : fait avancer un déclenchement
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_run_advance($params: object) -> object {
    LET $first = (SELECT * FROM ONLY $params.run);
    IF $first == NONE { RETURN { status: NONE }; };
    IF $first.status NOT IN ["pending", "waiting"] { RETURN { status: $first.status }; };
    LET $workflow = (SELECT * FROM ONLY $first.workflow);
    -- Étapes copiées au déclenchement : un parcours modifié depuis ne décale pas le curseur
    FOR $index IN <array>($first.cursor..array::len($first.steps)) {
        LET $run = (SELECT * FROM ONLY $params.run);
        -- Arrêt : déclenchement terminé (fusionné, limité, annulé), étape en cours ou en échec
        IF $run.status NOT IN ["pending", "waiting"] { BREAK; };
        LET $jobs = (SELECT step_key, status FROM notification_job WHERE run = $run.id);
        IF array::any($jobs, |$job| $job.status IN ["queued", "running", "waiting", "failed"]) { BREAK; };
        LET $step = $first.steps[$index];
        IF !array::any($jobs, |$job| $job.step_key = $step.key) {
            fn::notification_step_enter({ run: $run, workflow: $workflow, step: $step, index: $index });
        };
    };
    LET $run = (SELECT status FROM ONLY $params.run);
    IF $run.status NOT IN ["pending", "waiting"] { RETURN { status: $run.status }; };
    LET $active = (SELECT type FROM notification_job WHERE run = $params.run AND status IN ["queued", "running", "waiting"]);
    IF array::len($active) = 0 { RETURN fn::notification_run_finalize({ run: $params.run }); };
    LET $status = IF array::any($active, |$job| $job.type IN ["delay", "digest"]) { "waiting" } ELSE { "pending" };
    IF $status != $run.status { UPDATE $params.run SET status = $status; };
    RETURN { status: $status };
} COMMENT "Interne : fait avancer un déclenchement ({ run }) depuis son étape courante (cursor) jusqu'à la première étape qui attend (canal en file, attente, regroupement) ; fin du parcours : fn::notification_run_finalize. Idempotente : rejouée, elle ne crée rien de plus. { status }";

-- ----------------------------------------------------------------------------
-- fn::notification_wait_end : fin d'une attente
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_wait_end($params: object) -> object {
    LET $job = (SELECT * FROM ONLY notification_job WHERE run = $params.run AND step_key = $params.step_key LIMIT 1);
    -- Rejeu, déclenchement annulé ou purgé entre-temps : rien à faire
    IF $job == NONE OR $job.status NOT IN ["queued", "waiting"] OR $job.type NOT IN ["delay", "digest"] { RETURN { status: "ignored", run_status: NONE }; };
    IF (SELECT VALUE status FROM ONLY $params.run) NOT IN ["pending", "waiting"] { RETURN { status: "ignored", run_status: NONE }; };
    IF $job.type = "digest" {
        UPDATE notification_digest SET status = "closed", open_slot = NONE, closed_at = time::now()
            WHERE carrier = $params.run AND step_key = $params.step_key AND status = "open";
    };
    LET $done = (UPDATE ONLY $job.id SET status = "completed" WHERE status IN ["queued", "waiting"]);
    IF $done == NONE { RETURN { status: "ignored", run_status: NONE }; };
    RETURN { status: "resumed", run_status: fn::notification_run_advance({ run: $params.run }).status };
} COMMENT "Interne : termine l'attente ou le regroupement ({ run, step_key }) et fait avancer le déclenchement ; un regroupement porté est fermé. Rejouée, ou pour un déclenchement annulé : { status : ignored }. { status, run_status }";

-- ----------------------------------------------------------------------------
-- fn::notification_wait_schedule : attentes confiées au planificateur (worker)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_wait_schedule($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            limit: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 500 } }], default: 100 },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::notification_can({ action: "worker" }) { RETURN fn::error_result("NOTIFICATION_PERMISSION_DENIED", $p.language, {}); };
    LET $jobs = (SELECT id, run, step_key, wait_until FROM notification_job
        WHERE type IN ["delay", "digest"] AND status = "queued" ORDER BY wait_until LIMIT $p.limit);
    LET $outcomes = array::map($jobs, |$job| {
        -- Échue (ou presque) : reprise tout de suite, sans passer par le planificateur
        IF $job.wait_until IS NONE OR $job.wait_until <= time::now() + 1s {
            fn::notification_wait_end({ run: $job.run, step_key: $job.step_key });
            RETURN "resumed";
        };
        LET $enqueued = fn::scheduler_run_enqueue({
            task: "notification.run_resume",
            args: { run: <string> $job.run, step_key: $job.step_key },
            run_at: $job.wait_until,
            unique_key: string::concat(<string> $job.run, "/", $job.step_key),
            language: $p.language
        });
        IF !$enqueued.ok { RETURN $enqueued.error.code; };
        LET $updated = (UPDATE ONLY $job.id SET status = "waiting", scheduler_run = <string> $enqueued.data.id WHERE status = "queued");
        RETURN IF $updated == NONE { "skipped" } ELSE { "scheduled" };
    });
    LET $refused = array::filter($outcomes, |$o| $o NOT IN ["resumed", "scheduled", "skipped"]);
    RETURN fn::result_ok({
        scheduled: array::len(array::filter($outcomes, |$o| $o = "scheduled")),
        resumed: array::len(array::filter($outcomes, |$o| $o = "resumed")),
        failed: array::len($refused),
        codes: array::distinct($refused),
        more: array::len($jobs) = $p.limit
    });
} COMMENT "Confie à lyxal_scheduler les attentes et regroupements en file ({ limit : 500 au plus }) : exécution différée de la tâche notification.run_resume à leur fin (fn::scheduler_run_enqueue, unique par déclenchement et étape), étape waiting ; une attente déjà échue reprend tout de suite. Une exécution refusée par le planificateur laisse l'étape en file (codes). Renvoie { scheduled, resumed, failed, codes, more }. Permission notification.worker (session système de l'hôte)";

-- ----------------------------------------------------------------------------
-- fn::notification_run_resume : reprise d'un déclenchement (planificateur)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_run_resume($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            args: { pipeline: [{ rule: "is_object" }, { rule: "object", options: { schema: {
                fields: {
                    run: { pipeline: [{ rule: "record", options: { expected_table: "notification_run" } }], required: true },
                    step_key: { pipeline: [{ rule: "snake_case_name", options: { min_length: 1, max_length: 64 } }], required: true }
                },
                unknown_keys: "reject"
            } } }], required: true },
            run: { pipeline: [{ rule: "record_id", options: { allowed_tables: ["scheduler_run"] } }] },
            tenant: { pipeline: [{ rule: "record_id", options: { allowed_tables: ["auth_organization"] } }] },
            scheduled_for: { pipeline: [{ rule: "datetime" }] },
            attempt: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 100 } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 30);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::notification_can({ action: "worker" }) { RETURN fn::error_result("NOTIFICATION_PERMISSION_DENIED", $p.language, {}); };
    RETURN fn::result_ok(fn::notification_wait_end({ run: $p.args.run, step_key: $p.args.step_key }));
} COMMENT "Reprise d'un déclenchement à la fin d'une attente ou d'un regroupement, appelée par lyxal_scheduler (tâche notification.run_resume, exécuteur function) : { args : { run, step_key }, run, tenant, scheduled_for, attempt }. Étape terminée, regroupement porté fermé, déclenchement avancé ; rejouée, ou déclenchement annulé entre-temps : rien (status ignored). Renvoie { status, run_status }. Permission notification.worker (session système du moteur)";
