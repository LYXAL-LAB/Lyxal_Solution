-- ============================================================================
-- FONCTIONS : moteur — réservation sous bail, battement, fin, reprise, élagage
-- MODULE    : lyxal_scheduler
-- ============================================================================
-- Appelées par les exécuteurs Rust (lot 3), sous la session système ou un compte de service
-- scheduler.worker. Chaque fin de tentative (complete, fail, rescue) exige le jeton du bail en
-- cours (garde de génération) : un nœud qui a perdu son bail n'écrit plus rien. Places tenues
-- par deux compteurs à écriture conditionnelle (T3) : file (running < concurrency) et
-- organisation dans la file (scheduler_slot, réglage tenant_concurrency).

-- ----------------------------------------------------------------------------
-- fn::scheduler_lease_margin (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_lease_margin() -> duration {
    RETURN 1m;
} COMMENT "Interne : marge ajoutée au délai maximal de la tâche pour l'échéance du bail (1 min)";

-- ----------------------------------------------------------------------------
-- fn::scheduler_slot_record (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_slot_record($queue: record<scheduler_queue>, $scope_key: string) -> record<scheduler_slot> {
    RETURN type::record("scheduler_slot", [record::id($queue), $scope_key]);
} COMMENT "Interne : compteur de places d'une portée dans une file (scheduler_slot:[file, portée])";

-- ----------------------------------------------------------------------------
-- fn::scheduler_run_claim_one (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_run_claim_one($candidate: object, $node: string, $now: datetime) -> object {
    -- Place de la file : écriture conditionnelle (aucun dépassement entre deux nœuds)
    LET $queue = (UPDATE ONLY $candidate.queue SET running += 1 WHERE running < concurrency AND paused = false);
    IF $queue == NONE { RETURN { full: true, run: NONE }; };
    -- Place de l'organisation dans la file : une organisation pleine laisse passer les autres
    LET $limit = fn::scheduler_settings_effective({ tenant: $candidate.tenant }).tenant_concurrency;
    LET $slot_id = fn::scheduler_slot_record($candidate.queue, $candidate.scope_key);
    IF !record::exists($slot_id) { CREATE $slot_id CONTENT { queue: $candidate.queue, tenant: $candidate.tenant, running: 0 }; };
    LET $slot = (UPDATE ONLY $slot_id SET running += 1 WHERE running < $limit);
    IF $slot == NONE {
        UPDATE ONLY $candidate.queue SET running = math::max([running - 1, 0]);
        RETURN { full: false, run: NONE };
    };
    LET $task = (SELECT timeout, executor, target FROM ONLY $candidate.task);
    LET $timeout = $task.timeout;
    LET $run = (UPDATE ONLY $candidate.id SET
        state = "running",
        attempt += 1,
        lease = <string> rand::uuid::v7(),
        lease_node = $node,
        locked_until = $now + $timeout + fn::scheduler_lease_margin(),
        started_at = $now
        WHERE state IN ["queued", "retrying"] AND available_at <= $now);
    IF $run == NONE {
        UPDATE ONLY $candidate.queue SET running = math::max([running - 1, 0]);
        UPDATE ONLY $slot_id SET running = math::max([running - 1, 0]);
        RETURN { full: false, run: NONE };
    };
    RETURN { full: false, run: {
        id: $run.id, lease: $run.lease, lease_node: $run.lease_node, locked_until: $run.locked_until, timeout: $timeout,
        executor: $task.executor, target: $task.target, cancel_requested: $run.cancel_requested,
        tenant: $run.tenant, schedule: $run.schedule, task: $run.task, args: $run.args, origin: $run.origin,
        scheduled_for: $run.scheduled_for, attempt: $run.attempt, max_attempts: $run.max_attempts
    } };
} COMMENT "Interne : réserve une exécution candidate ($candidate, $node, $now) : place de la file, place de l'organisation, puis passage à running avec un bail nouveau (tentative suivante, échéance = maintenant + délai de la tâche + marge) ; une étape refusée rend les places prises. { full (file pleine ou en pause), run }";

-- ----------------------------------------------------------------------------
-- fn::scheduler_run_claim
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_run_claim($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            queue: { pipeline: [{ rule: "slug", options: { max_length: 64 } }], required: true },
            node: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 128 } }], required: true },
            limit: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 100 } }], default: 10 },
            handlers: { pipeline: [{ rule: "array" }, { rule: "array_length", options: { max_length: 1000 } }, { rule: "each", options: { pipeline: [{ rule: "lyxal_event_name", options: { min_segments: 2, max_segments: 2 } }] } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid { RETURN fn::scheduler_invalid($params, $report.by_field); };
    LET $p = $report.value;
    IF !fn::scheduler_can({ action: "worker" }) { RETURN fn::error_result("SCHEDULER_PERMISSION_DENIED", $p.language, {}); };
    LET $queue = (SELECT * FROM ONLY fn::scheduler_queue_record($p.queue));
    IF $queue == NONE { RETURN fn::error_result("SCHEDULER_QUEUE_NOT_FOUND", $p.language, { queue: $p.queue }); };
    -- Handlers de ce nœud pour la sonde de santé (un handler manquant ici peut exister ailleurs)
    IF $p.handlers IS NOT NONE {
        UPSERT type::record("scheduler_node", [$p.node, $p.queue]) SET node = $p.node, queue = $queue.id, handlers = array::distinct($p.handlers);
    };
    IF $queue.paused { RETURN fn::result_ok({ items: [], paused: true }); };
    LET $now = time::now();
    LET $disabled = (SELECT VALUE id FROM scheduler_task WHERE state = "disabled");
    -- Tâches handler dont ce nœud n'a pas le code : laissées à un nœud qui l'a, sauf celles qui
    -- attendent depuis plus que leur délai maximal (réservées puis terminées en échec
    -- SCHEDULER_HANDLER_NOT_FOUND par l'exécuteur)
    LET $foreign = IF $p.handlers IS NONE { [] } ELSE {
        (SELECT VALUE id FROM scheduler_task WHERE executor = "handler" AND target NOTINSIDE $p.handlers)
    };
    -- Organisations déjà pleines dans cette file : écartées avant la sélection, pour que leurs
    -- exécutions en attente ne masquent jamais celles des autres organisations
    LET $full = array::filter((SELECT tenant, scope_key, running FROM scheduler_slot WHERE queue = $queue.id AND running > 0), |$slot|
        $slot.running >= fn::scheduler_settings_effective({ tenant: $slot.tenant }).tenant_concurrency).scope_key;
    -- Priorité puis date ; des candidats en surnombre pour les réservations perdues entre deux nœuds
    LET $candidates = (SELECT id, queue, tenant, scope_key, task, priority, available_at FROM scheduler_run
        WHERE queue = $queue.id AND state IN ["queued", "retrying"] AND available_at <= $now AND task NOTINSIDE $disabled
            AND scope_key NOTINSIDE $full
            AND (task NOTINSIDE $foreign OR available_at + task.timeout <= $now)
        ORDER BY priority ASC, available_at ASC LIMIT $p.limit * 10);
    LET $outcome = array::fold($candidates, { items: [], full: false }, |$acc, $candidate| {
        IF $acc.full OR array::len($acc.items) >= $p.limit { RETURN $acc; };
        LET $claimed = fn::scheduler_run_claim_one($candidate, $p.node, $now);
        RETURN IF $claimed.full { { items: $acc.items, full: true } }
            ELSE IF $claimed.run IS NONE { $acc }
            ELSE { { items: array::append($acc.items, $claimed.run), full: false } };
    });
    RETURN fn::result_ok({ items: $outcome.items, paused: false });
} COMMENT "Moteur : réserve les exécutions disponibles d'une file ({ queue, node, limit (100 au plus), handlers : noms des tâches handler dont le nœud a le code, absent : toutes }) par priorité puis date, dans les places de la file et de chaque organisation (une organisation pleine laisse passer les autres) ; file en pause : aucune ; tâches désactivées ignorées ; handlers du nœud enregistrés pour la sonde de santé (scheduler_node) ; une tâche handler absente de handlers n'est réservée qu'après avoir attendu plus que son délai maximal (l'exécuteur la termine alors en échec SCHEDULER_HANDLER_NOT_FOUND). Chaque exécution réservée porte son jeton de bail (lease), à rendre à chaque battement et à la fin, son exécuteur et sa cible. { items, paused }. Droit : session système ou scheduler.worker";

-- ----------------------------------------------------------------------------
-- fn::scheduler_run_leased (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_run_leased($run: record<scheduler_run>, $lease: string) -> object {
    LET $found = (SELECT * FROM ONLY $run);
    IF $found == NONE { RETURN { code: "SCHEDULER_RUN_NOT_FOUND", run: NONE }; };
    IF $found.state != "running" OR $found.lease != $lease { RETURN { code: "SCHEDULER_LEASE_LOST", run: NONE }; };
    RETURN { code: NONE, run: $found };
} COMMENT "Interne : exécution en cours dont le bail est $lease ({ code : NONE, SCHEDULER_RUN_NOT_FOUND ou SCHEDULER_LEASE_LOST ; run })";

-- ----------------------------------------------------------------------------
-- fn::scheduler_run_heartbeat
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_run_heartbeat($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            run: { pipeline: fn::scheduler_ref("scheduler_run"), required: true },
            lease: { pipeline: [{ rule: "required_string", options: { min_length: 36, max_length: 36 } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid { RETURN fn::scheduler_invalid($params, $report.by_field); };
    LET $p = $report.value;
    IF !fn::scheduler_can({ action: "worker" }) { RETURN fn::error_result("SCHEDULER_PERMISSION_DENIED", $p.language, {}); };
    LET $lease = <string> $p.lease;
    LET $leased = fn::scheduler_run_leased($p.run, $lease);
    IF $leased.code IS NOT NONE { RETURN fn::error_result($leased.code, $p.language, { run: <string> $p.run }); };
    LET $timeout = (SELECT VALUE timeout FROM ONLY $leased.run.task);
    LET $updated = (UPDATE ONLY $p.run SET locked_until = time::now() + $timeout + fn::scheduler_lease_margin() WHERE state = "running" AND lease = $lease);
    IF $updated == NONE { RETURN fn::error_result("SCHEDULER_LEASE_LOST", $p.language, { run: <string> $p.run }); };
    RETURN fn::result_ok({ run: $updated.id, locked_until: $updated.locked_until, cancel_requested: $updated.cancel_requested });
} COMMENT "Moteur : prolonge le bail d'une exécution en cours ({ run, lease }) et indique si son annulation est demandée : { run, locked_until, cancel_requested }. Bail perdu : SCHEDULER_LEASE_LOST. Droit : session système ou scheduler.worker";

-- ----------------------------------------------------------------------------
-- fn::scheduler_retry_delay (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_retry_delay($policy: object, $attempt: int, $factor: float) -> duration {
    LET $initial = duration::millis($policy.initial_delay);
    LET $raw = IF $policy.strategy = "fixed" { $initial }
        ELSE IF $policy.strategy = "linear" { $initial * $attempt }
        ELSE { $initial * math::pow(2, $attempt - 1) };
    LET $capped = math::min([$raw, duration::millis($policy.max_delay)]);
    RETURN duration::from_millis(<int> math::round($capped * $factor));
} COMMENT "Interne : délai avant la tentative suivante ($policy de la tâche, $attempt : tentative qui vient d'échouer, $factor : gigue entre 0 et 1, rand::float() en service) : fixe (initial), linéaire (initial × tentative) ou exponentiel (initial × 2^(tentative−1)), plafonné par max_delay, puis multiplié par la gigue (gigue complète)";

-- ----------------------------------------------------------------------------
-- fn::scheduler_run_end (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_run_end($run: object, $lease: string, $outcome: object) -> option<object> {
    LET $now = time::now();
    LET $terminal = $outcome.state IN ["completed", "dead", "cancelled"];
    LET $updated = (UPDATE ONLY $run.id SET
        state = $outcome.state,
        lease = NONE,
        lease_node = NONE,
        locked_until = NONE,
        duration_ms = IF started_at IS NONE OR started_at > $now { NONE } ELSE { duration::millis($now - started_at) },
        result = $outcome.result ?? result,
        error = $outcome.error ?? error,
        available_at = $outcome.available_at ?? available_at,
        finished_at = IF $terminal { $now } ELSE { NONE }
        WHERE state = "running" AND lease = $lease);
    IF $updated == NONE { RETURN NONE; };
    -- Places rendues
    UPDATE ONLY $run.queue SET running = math::max([running - 1, 0]);
    UPDATE ONLY fn::scheduler_slot_record($run.queue, $run.scope_key) SET running = math::max([running - 1, 0]);
    IF $run.schedule IS NOT NONE {
        UPDATE $run.schedule SET last_state = $outcome.state WHERE last_run = $run.id;
        -- Pause sur échec
        IF $outcome.state = "dead" {
            UPDATE $run.schedule SET paused = true, paused_reason = "failure", next_fire_at = NONE
                WHERE pause_on_failure AND !paused AND state != "completed";
        };
        -- Une exécution en attente prend la place
        IF $outcome.state != "retrying" { fn::scheduler_run_release($run.schedule); };
    };
    RETURN $updated;
} COMMENT "Interne : termine la tentative d'une exécution sous son bail ($run, $lease, $outcome : { state : completed, retrying, dead, cancelled ; result ; error ; available_at }) : bail rendu, durée, fin ; places de la file et de l'organisation rendues ; dernier état de la planification ; pause sur échec (dead) ; libération d'une exécution en attente. NONE si le bail n'est plus le sien";

-- ----------------------------------------------------------------------------
-- fn::scheduler_run_complete
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_run_complete($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            run: { pipeline: fn::scheduler_ref("scheduler_run"), required: true },
            lease: { pipeline: [{ rule: "required_string", options: { min_length: 36, max_length: 36 } }], required: true },
            result: { pipeline: [{ rule: "is_object" }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid { RETURN fn::scheduler_invalid($params, $report.by_field); };
    LET $p = $report.value;
    IF $p.result IS NOT NONE AND bytes::len(<bytes> <string> $p.result) > 4096 {
        RETURN fn::scheduler_invalid($params, { result: [{ code: "CORE_VALIDATION_TOO_LARGE", details: { max_bytes: 4096 } }] });
    };
    IF !fn::scheduler_can({ action: "worker" }) { RETURN fn::error_result("SCHEDULER_PERMISSION_DENIED", $p.language, {}); };
    LET $lease = <string> $p.lease;
    LET $leased = fn::scheduler_run_leased($p.run, $lease);
    IF $leased.code IS NOT NONE { RETURN fn::error_result($leased.code, $p.language, { run: <string> $p.run }); };
    LET $updated = fn::scheduler_run_end($leased.run, $lease, { state: "completed", result: $p.result });
    IF $updated == NONE { RETURN fn::error_result("SCHEDULER_LEASE_LOST", $p.language, { run: <string> $p.run }); };
    RETURN fn::result_ok($updated);
} COMMENT "Moteur : termine avec succès une exécution en cours ({ run, lease, result : résultat court de 4 Kio au plus }) : completed, places rendues, exécution en attente de la planification libérée. Bail perdu : SCHEDULER_LEASE_LOST. Droit : session système ou scheduler.worker";

-- ----------------------------------------------------------------------------
-- fn::scheduler_run_publish
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_run_publish($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            run: { pipeline: fn::scheduler_ref("scheduler_run"), required: true },
            lease: { pipeline: [{ rule: "required_string", options: { min_length: 36, max_length: 36 } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid { RETURN fn::scheduler_invalid($params, $report.by_field); };
    LET $p = $report.value;
    IF !fn::scheduler_can({ action: "worker" }) { RETURN fn::error_result("SCHEDULER_PERMISSION_DENIED", $p.language, {}); };
    LET $lease = <string> $p.lease;
    LET $leased = fn::scheduler_run_leased($p.run, $lease);
    IF $leased.code IS NOT NONE { RETURN fn::error_result($leased.code, $p.language, { run: <string> $p.run }); };
    LET $run = $leased.run;
    LET $task = (SELECT module, executor, target FROM ONLY $run.task);
    IF $task.executor != "event" {
        RETURN fn::scheduler_invalid($params, { run: [{ code: "CORE_VALIDATION_NOT_ALLOWED", details: { executor: $task.executor, allowed: ["event"] } }] });
    };
    LET $event_id = rand::uuid::v7();
    -- Fin de l'exécution d'abord : un bail perdu n'écrit rien et ne publie rien
    LET $updated = fn::scheduler_run_end($run, $lease, { state: "completed", result: { event_id: <string> $event_id, event_type: $task.target } });
    IF $updated == NONE { RETURN fn::error_result("SCHEDULER_LEASE_LOST", $p.language, { run: <string> $p.run }); };
    -- Même transaction : une publication refusée annule la fin de l'exécution (W5)
    LET $published = fn::event_publish({
        event_id: $event_id,
        event_type: $task.target,
        producer: $task.module,
        source: $run.id,
        payload: $run.args,
        metadata: { scheduled_for: <string> $run.scheduled_for, attempt: $run.attempt, tenant: fn::scheduler_tenant_string($run.tenant) }
    });
    IF !$published.ok { THROW $published.error.code; };
    RETURN fn::result_ok($updated);
} COMMENT "Moteur : exécute une tâche event réservée ({ run, lease }) : publie l'événement déclaré par la tâche (fn::event_publish : type = cible de la tâche, producteur = module de la tâche, source = l'exécution, charge = arguments de l'exécution, métadonnées { scheduled_for, attempt, tenant }) et termine l'exécution (completed, résultat { event_id, event_type }) dans la même transaction (W5) : une publication refusée annule la fin (erreur du bus), un bail perdu ne publie rien (SCHEDULER_LEASE_LOST). Tâche qui n'est pas event : SCHEDULER_INVALID_PARAMETERS. Droit : session système (seule autorisée à publier sur le bus)";

-- ----------------------------------------------------------------------------
-- fn::scheduler_run_fail
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_run_fail($params: object) {
    -- Message d'erreur du programme : tronqué à 1 000 caractères plutôt que refusé (la tentative doit se terminer)
    LET $input = IF type::is_object($params.error) AND type::is_string($params.error.message) {
        object::extend($params, { error: object::extend($params.error, { message: string::slice($params.error.message, 0, 1000) }) })
    } ELSE { $params };
    LET $report = fn::validation_object_execute($input, {
        fields: {
            run: { pipeline: fn::scheduler_ref("scheduler_run"), required: true },
            lease: { pipeline: [{ rule: "required_string", options: { min_length: 36, max_length: 36 } }], required: true },
            error: { pipeline: [{ rule: "object", options: { schema: {
                fields: {
                    code: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 128 } }], required: true },
                    message: { pipeline: [{ rule: "optional_string", options: { max_length: 1000 } }] }
                },
                unknown_keys: "reject"
            } } }], required: true },
            retryable: { pipeline: [{ rule: "boolean" }], default: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid { RETURN fn::scheduler_invalid($params, $report.by_field); };
    LET $p = $report.value;
    IF !fn::scheduler_can({ action: "worker" }) { RETURN fn::error_result("SCHEDULER_PERMISSION_DENIED", $p.language, {}); };
    LET $lease = <string> $p.lease;
    LET $leased = fn::scheduler_run_leased($p.run, $lease);
    IF $leased.code IS NOT NONE { RETURN fn::error_result($leased.code, $p.language, { run: <string> $p.run }); };
    LET $outcome = fn::scheduler_failure_outcome($leased.run, { code: $p.error.code, message: $p.error.message, retryable: $p.retryable });
    LET $updated = fn::scheduler_run_end($leased.run, $lease, $outcome);
    IF $updated == NONE { RETURN fn::error_result("SCHEDULER_LEASE_LOST", $p.language, { run: <string> $p.run }); };
    RETURN fn::result_ok($updated);
} COMMENT "Moteur : termine en échec la tentative d'une exécution en cours ({ run, lease, error : { code, message (tronqué à 1000 caractères) }, retryable (défaut true) }) : cancelled si son annulation est demandée ; retrying après un délai (stratégie de la tâche, plafond, gigue complète) s'il reste des tentatives et que l'erreur est retentable ; sinon dead (pause de la planification si pause_on_failure). Bail perdu : SCHEDULER_LEASE_LOST. Droit : session système ou scheduler.worker";

-- ----------------------------------------------------------------------------
-- fn::scheduler_failure_outcome (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_failure_outcome($run: object, $error: object) -> object {
    IF $run.cancel_requested { RETURN { state: "cancelled", error: $error }; };
    IF $error.retryable AND $run.attempt < $run.max_attempts {
        LET $policy = (SELECT VALUE retry FROM ONLY $run.task);
        RETURN { state: "retrying", error: $error, available_at: time::now() + fn::scheduler_retry_delay($policy, $run.attempt, rand::float(0, 1)) };
    };
    RETURN { state: "dead", error: $error };
} COMMENT "Interne : issue d'une tentative en échec ($run, $error { code, message, retryable }) : cancelled (annulation demandée), retrying avec la date de la tentative suivante, ou dead";

-- ----------------------------------------------------------------------------
-- fn::scheduler_run_rescue
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_run_rescue($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: object::extend(fn::scheduler_leader_fields(), {
            limit: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 1000 } }], default: 100 },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        }),
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid { RETURN fn::scheduler_invalid($params, $report.by_field); };
    LET $p = $report.value;
    IF !fn::scheduler_can({ action: "worker" }) { RETURN fn::error_result("SCHEDULER_PERMISSION_DENIED", $p.language, {}); };
    LET $fenced = fn::scheduler_leader_fenced($p);
    IF $fenced IS NOT NONE { RETURN $fenced; };
    -- locked_until NONE se compare comme inférieur à toute date : condition explicite
    LET $expired = (SELECT * FROM scheduler_run WHERE state = "running" AND locked_until IS NOT NONE AND locked_until < time::now()
        ORDER BY locked_until ASC LIMIT $p.limit);
    LET $rescued = array::fold($expired, [], |$acc, $run| {
        LET $outcome = fn::scheduler_failure_outcome($run, { code: "SCHEDULER_LEASE_LOST", message: "Bail expiré sans fin de tentative", retryable: true });
        LET $updated = fn::scheduler_run_end($run, $run.lease, $outcome);
        RETURN IF $updated == NONE { $acc } ELSE { array::append($acc, { id: $updated.id, state: $updated.state }) };
    });
    RETURN fn::result_ok({ rescued: $rescued, reconciled: fn::scheduler_counters_reconcile() });
} COMMENT "Moteur (planificateur) : reprend les exécutions dont le bail a expiré ({ node, generation : garde de génération du bail du planificateur ; limit (1000 au plus) }) : retrying s'il reste des tentatives, cancelled si l'annulation était demandée, sinon dead ; erreur SCHEDULER_LEASE_LOST ; places rendues ; puis recale les compteurs de places sur les exécutions réellement en cours (places d'exécutions disparues avec leur organisation). { rescued, reconciled }. Bail du planificateur perdu : SCHEDULER_LEADER_FENCED. Droit : session système (seule à lire le bail)";

-- ----------------------------------------------------------------------------
-- fn::scheduler_counters_reconcile (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_counters_reconcile() -> int {
    LET $queues = (SELECT id, running FROM scheduler_queue);
    LET $fixed_queues = array::filter($queues, |$q| {
        LET $actual = count(SELECT VALUE id FROM scheduler_run WHERE queue = $q.id AND state = "running");
        IF $actual == $q.running { RETURN false; };
        UPDATE ONLY $q.id SET running = $actual;
        RETURN true;
    });
    LET $slots = (SELECT id, queue, scope_key, running FROM scheduler_slot WHERE running > 0);
    LET $fixed_slots = array::filter($slots, |$slot| {
        LET $actual = count(SELECT VALUE id FROM scheduler_run WHERE queue = $slot.queue AND scope_key = $slot.scope_key AND state = "running");
        IF $actual == $slot.running { RETURN false; };
        UPDATE ONLY $slot.id SET running = $actual;
        RETURN true;
    });
    RETURN array::len($fixed_queues) + array::len($fixed_slots);
} COMMENT "Interne : recale le compteur de chaque file et de chaque organisation dans une file sur le nombre d'exécutions réellement en cours (une organisation supprimée emporte ses exécutions sans passer par leur fin). Nombre de compteurs corrigés";

-- ----------------------------------------------------------------------------
-- fn::scheduler_run_prunable (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_run_prunable($id: record<scheduler_run>, $tenant: option<record<auth_organization>>, $schedule: option<record<scheduler_schedule>>, $scheduled_for: datetime, $finished_at: datetime, $now: datetime) -> bool {
    LET $settings = fn::scheduler_settings_effective({ tenant: $tenant });
    IF $finished_at >= $now - $settings.run_retention { RETURN false; };
    IF $schedule IS NONE { RETURN true; };
    -- Toujours les N dernières exécutions terminées de chaque planification (S7)
    LET $newer = count(SELECT VALUE id FROM scheduler_run WHERE schedule = $schedule AND state IN ["completed", "dead", "cancelled", "skipped"]
        AND (scheduled_for > $scheduled_for OR (scheduled_for = $scheduled_for AND id > $id)) LIMIT $settings.keep_last_runs);
    RETURN $newer >= $settings.keep_last_runs;
} COMMENT "Interne : une exécution terminée peut-elle être élaguée ? Plus vieille que la conservation de sa portée et, pour une planification, hors de ses keep_last_runs dernières exécutions terminées (S7)";

-- ----------------------------------------------------------------------------
-- fn::scheduler_run_prune
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_run_prune($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: object::extend(fn::scheduler_leader_fields(), {
            limit: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 10000 } }], default: 1000 },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        }),
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid { RETURN fn::scheduler_invalid($params, $report.by_field); };
    LET $p = $report.value;
    IF !fn::scheduler_can({ action: "worker" }) { RETURN fn::error_result("SCHEDULER_PERMISSION_DENIED", $p.language, {}); };
    LET $fenced = fn::scheduler_leader_fenced($p);
    IF $fenced IS NOT NONE { RETURN $fenced; };
    LET $now = time::now();
    -- Conservation minimale d'un jour ; l'éligibilité (conservation de la portée, N dernières de
    -- chaque planification) est évaluée avant la limite, pour qu'un lot d'exécutions gardées ne
    -- bloque jamais l'élagage des suivantes
    LET $doomed = (SELECT id FROM scheduler_run
        WHERE state IN ["completed", "dead", "cancelled", "skipped"] AND finished_at IS NOT NONE AND finished_at < $now - 1d
            AND fn::scheduler_run_prunable(id, tenant, schedule, scheduled_for, finished_at, $now)
        ORDER BY finished_at ASC LIMIT $p.limit);
    LET $ids = $doomed.id;
    DELETE scheduler_run WHERE id IN $ids;
    -- Exécuteurs sans réservation depuis un jour (nœud arrêté)
    DELETE scheduler_node WHERE seen_at < $now - 1d;
    RETURN fn::result_ok({ deleted: array::len($ids) });
} COMMENT "Moteur (planificateur) : élague les exécutions terminées plus vieilles que la conservation de leur portée ({ node, generation : garde de génération du bail du planificateur ; limit (10000 au plus) }), en gardant toujours les keep_last_runs dernières de chaque planification (S7) ; oublie les exécuteurs sans réservation depuis un jour. { deleted }. Bail du planificateur perdu : SCHEDULER_LEADER_FENCED. Droit : session système (seule à lire le bail)";

-- ----------------------------------------------------------------------------
-- fn::scheduler_health
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::scheduler_health($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            late_after: { pipeline: [{ rule: "duration", options: { min_value: 1s, max_value: 1d } }], default: 5m },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid { RETURN fn::scheduler_invalid($params, $report.by_field); };
    LET $p = $report.value;
    IF !fn::scheduler_can({ action: "worker" }) { RETURN fn::error_result("SCHEDULER_PERMISSION_DENIED", $p.language, {}); };
    LET $limit = time::now() - $p.late_after;
    RETURN fn::result_ok({
        queues: array::map((SELECT id, paused FROM scheduler_queue ORDER BY id ASC), |$q| { name: <string> record::id($q.id), paused: $q.paused }),
        late: count(SELECT VALUE id FROM scheduler_run WHERE state IN ["queued", "retrying"] AND available_at < $limit),
        handler_tasks: (SELECT VALUE target FROM scheduler_task WHERE executor = "handler" AND state = "active" ORDER BY target ASC),
        handlers_served: array::sort::asc(array::distinct(array::flatten(SELECT VALUE handlers FROM scheduler_node WHERE seen_at >= time::now() - 1m)))
    });
} COMMENT "Moteur (sonde de santé) : files { name, paused }, nombre d'exécutions réservables qui attendent depuis plus de late_after (5 min par défaut, 1 j au plus) au-delà de leur date de disponibilité, tâches handler actives (handler_tasks), tâches handler inscrites sur au moins un nœud qui a réservé dans la dernière minute (handlers_served). Aucune donnée d'organisation. Droit : session système ou scheduler.worker";
