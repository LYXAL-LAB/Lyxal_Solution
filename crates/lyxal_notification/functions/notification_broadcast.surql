-- ============================================================================
-- FONCTIONS : diffusions (worker)
-- MODULE    : lyxal_notification
-- ============================================================================
-- Une diffusion (sujet ou tous les abonnés) est réservée par un worker, puis traitée par paquets
-- triés par identifiant (`cursor`). Chaque paquet est une seule transaction : déclenchements
-- créés et curseur avancé ensemble. Une réservation perdue ou un arrêt ne renvoie rien deux fois
-- (clé <clé de la diffusion>/<subscriber_id>, index unique). Permission notification.worker
-- (ou session système).

-- ----------------------------------------------------------------------------
-- fn::notification_broadcast_claim
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_broadcast_claim($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            worker_id: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 128 } }], required: true },
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
    LET $candidate = (SELECT VALUE id FROM ONLY notification_broadcast
        WHERE status IN ["queued", "running"] AND (locked_until IS NONE OR locked_until < $now) ORDER BY created_at LIMIT 1);
    IF $candidate IS NONE { RETURN fn::result_ok(NONE); };
    -- Réservation conditionnelle : prise entre-temps par un autre worker, rien n'est réservé
    LET $claim = <string> rand::uuid::v7();
    LET $claimed = (UPDATE ONLY $candidate SET status = "running", locked_until = $now + duration::from_secs($p.lease_seconds),
        claim_token = $claim, worker_id = $p.worker_id
        WHERE status IN ["queued", "running"] AND (locked_until IS NONE OR locked_until < $now));
    IF $claimed == NONE { RETURN fn::result_ok(NONE); };
    RETURN fn::result_ok({ broadcast_id: $claimed.id, claim_token: $claim });
} COMMENT "Réserve la plus ancienne diffusion à traiter ({ worker_id, lease_seconds }) : { broadcast_id, claim_token }, ou NONE s'il n'y en a pas ; une réservation expirée est reprise. Permission notification.worker";

-- ----------------------------------------------------------------------------
-- fn::notification_broadcast_step
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_broadcast_step($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            broadcast_id: { pipeline: [{ rule: "record", options: { expected_table: "notification_broadcast" } }], required: true },
            claim_token: { pipeline: [{ rule: "uuid_v7", options: { allow_string: true } }], required: true },
            size: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 500 } }], default: 500 },
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
    LET $broadcast = (SELECT * FROM ONLY $p.broadcast_id);
    IF $broadcast == NONE OR $broadcast.status != "running" OR $broadcast.claim_token != <string> $p.claim_token {
        RETURN fn::error_result("NOTIFICATION_JOB_CLAIM_LOST", $p.language, {});
    };
    IF $broadcast.exhausted { RETURN fn::result_ok({ processed: 0, created: 0, skipped: 0, done: true }); };
    LET $workflow = (SELECT * FROM ONLY $broadcast.workflow);
    LET $settings = fn::notification_settings_effective({ tenant: $broadcast.tenant });
    LET $cursor = $broadcast.cursor;
    -- Paquet suivant : abonnements du sujet, ou abonnés de la portée, après le curseur
    LET $batch = IF $broadcast.topic IS NOT NONE {
        (SELECT id, condition, subscriber FROM notification_topic_member
            WHERE topic = $broadcast.topic AND ($cursor IS NONE OR id > $cursor) ORDER BY id LIMIT $p.size FETCH subscriber)
    } ELSE IF $broadcast.to_all {
        array::map((SELECT * FROM notification_subscriber WHERE scope_key = $broadcast.scope_key AND ($cursor IS NONE OR id > $cursor) ORDER BY id LIMIT $p.size),
            |$subscriber| { id: $subscriber.id, condition: NONE, subscriber: $subscriber })
    } ELSE { [] };
    LET $outcomes = array::map($batch, |$item| {
        LET $subscriber = $item.subscriber;
        IF $broadcast.exclude_actor AND $broadcast.actor IS NOT NONE AND $subscriber.subscriber_id = $broadcast.actor { RETURN "skipped"; };
        IF $item.condition IS NOT NONE AND !fn::utils_condition_evaluate({
            subscriber: { subscriber_id: $subscriber.subscriber_id, locale: $subscriber.locale, timezone: $subscriber.timezone, data: $subscriber.data },
            payload: $broadcast.payload
        }, $item.condition, NONE).matched { RETURN "skipped"; };
        LET $run = fn::notification_run_create({
            tenant: $broadcast.tenant, workflow: $workflow, subscriber: $subscriber,
            idempotency_key: string::concat($broadcast.idempotency_key, "/", $subscriber.subscriber_id),
            event_id: $broadcast.event_id, payload: $broadcast.payload, secret: NONE, expires_at: NONE,
            settings: $settings, actor: $broadcast.actor, broadcast: $broadcast.id
        });
        RETURN $run.status;
    });
    IF array::any($outcomes, |$o| $o = "forbidden") { RETURN fn::error_result("NOTIFICATION_WRITE_FORBIDDEN", $p.language, { table: "notification_run" }); };
    LET $count = array::len($batch);
    LET $created = array::len(array::filter($outcomes, |$o| $o = "created"));
    LET $skipped = array::len(array::filter($outcomes, |$o| $o IN ["skipped", "no_address"]));
    -- Curseur avancé sous la réservation ; perdue entre-temps : le paquet sera repris sans doublon
    LET $updated = (UPDATE ONLY $broadcast.id SET
        cursor = IF $count = 0 { $cursor } ELSE { $batch[$count - 1].id },
        processed += $count, created += $created, skipped += $skipped,
        exhausted = $count < $p.size,
        locked_until = time::now() + duration::from_secs($p.lease_seconds)
        WHERE status = "running" AND claim_token = <string> $p.claim_token);
    IF $updated == NONE { RETURN fn::error_result("NOTIFICATION_JOB_CLAIM_LOST", $p.language, {}); };
    RETURN fn::result_ok({ processed: $count, created: $created, skipped: $skipped, done: $updated.exhausted });
} COMMENT "Traite le paquet suivant d'une diffusion réservée ({ broadcast_id, claim_token, size : 500 au plus, lease_seconds }) : auteur exclu, condition d'abonnement évaluée, un déclenchement par abonné (préférences, adresses et suppression appliquées) ; curseur avancé et réservation renouvelée. Renvoie { processed, created, skipped, done }. Permission notification.worker";

-- ----------------------------------------------------------------------------
-- fn::notification_broadcast_complete
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_broadcast_complete($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            broadcast_id: { pipeline: [{ rule: "record", options: { expected_table: "notification_broadcast" } }], required: true },
            claim_token: { pipeline: [{ rule: "uuid_v7", options: { allow_string: true } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::notification_can({ action: "worker" }) { RETURN fn::error_result("NOTIFICATION_PERMISSION_DENIED", $p.language, {}); };
    LET $broadcast = (SELECT * FROM ONLY $p.broadcast_id);
    IF $broadcast == NONE OR $broadcast.status != "running" OR $broadcast.claim_token != <string> $p.claim_token {
        RETURN fn::error_result("NOTIFICATION_JOB_CLAIM_LOST", $p.language, {});
    };
    IF !$broadcast.exhausted { RETURN fn::error_result("NOTIFICATION_BROADCAST_INCOMPLETE", $p.language, { processed: $broadcast.processed }); };
    LET $completed = (UPDATE ONLY $broadcast.id SET status = "completed", completed_at = time::now(), locked_until = NONE, claim_token = NONE
        WHERE status = "running" AND claim_token = <string> $p.claim_token);
    IF $completed == NONE { RETURN fn::error_result("NOTIFICATION_JOB_CLAIM_LOST", $p.language, {}); };
    RETURN fn::result_ok({ status: "completed", processed: $completed.processed, created: $completed.created, skipped: $completed.skipped });
} COMMENT "Termine une diffusion réservée dont tous les destinataires ont été traités ({ broadcast_id, claim_token }) ; NOTIFICATION_BROADCAST_INCOMPLETE sinon. Renvoie { status, processed, created, skipped }. Permission notification.worker";
