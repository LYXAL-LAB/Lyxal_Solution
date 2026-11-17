-- ============================================================================
-- FONCTIONS : déclenchement d'un parcours, envoi groupé, annulation, envoi de test
-- MODULE    : lyxal_notification
-- ============================================================================
-- `to` désigne un abonné (`{ subscriber_id, email, … }`, créé ou mis à jour à la volée), une
-- liste de 100 abonnés au plus, un sujet (`{ topic }`) ou tous les abonnés de la portée
-- (`{ all: true }`). Un sujet ou « tous » est une diffusion, traitée par le worker
-- (fn::notification_broadcast_*). L'auteur de l'action (`actor`, un subscriber_id) n'est pas
-- prévenu, sauf `exclude_actor` faux. Les étapes du parcours s'exécutent ensuite dans l'ordre
-- (fn::notification_run_advance).

-- ----------------------------------------------------------------------------
-- fn::notification_settings_effective : réglages de l'organisation sur ceux de l'installation
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_settings_effective($params: object) -> object {
    LET $base = (SELECT * FROM ONLY notification_settings WHERE scope_key = "installation" LIMIT 1) ?? {};
    LET $own = IF $params.tenant IS NONE { {} } ELSE {
        (SELECT * FROM ONLY notification_settings WHERE scope_key = <string> record::id($params.tenant) LIMIT 1) ?? {}
    };
    RETURN {
        timezone: $own.timezone ?? $base.timezone,
        max_attempts: $own.max_attempts ?? $base.max_attempts ?? 8,
        retention_days_runs: $own.retention_days_runs ?? $base.retention_days_runs ?? 90,
        retention_days_log: $own.retention_days_log ?? $base.retention_days_log ?? 30,
        retention_days_inbox: $own.retention_days_inbox ?? $base.retention_days_inbox ?? 90,
        max_wait_days: $own.max_wait_days ?? $base.max_wait_days ?? 30,
        -- Installation seulement (décision E3)
        allowed_hosts: $base.allowed_hosts ?? []
    };
} COMMENT "Réglages effectifs ({ tenant }) : organisation sur installation, valeurs par défaut sinon ; allowed_hosts : réglage de l'installation (vide : tout hôte public)";

-- ----------------------------------------------------------------------------
-- fn::notification_channel_address : adresse d'un abonné pour un canal
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_channel_address($params: object) -> option<string> {
    IF $params.type = "email" { RETURN $params.address.email; };
    IF $params.type = "sms" { RETURN $params.address.phone; };
    IF $params.type IN ["chat", "webhook", "push"] AND $params.subscriber IS NOT NONE {
        LET $active = count(SELECT VALUE id FROM notification_endpoint WHERE subscriber = $params.subscriber AND channel = $params.type AND active = true);
        RETURN IF $active > 0 { $params.type } ELSE { NONE };
    };
    -- Fil : seulement pour un abonné lié à un compte lyxal_auth (un invité n'a pas de fil, F2)
    IF $params.type = "in_app" AND $params.subscriber IS NOT NONE {
        RETURN IF (SELECT VALUE identity FROM ONLY $params.subscriber) IS NONE { NONE } ELSE { "in_app" };
    };
    RETURN NONE;
} COMMENT "Interne : adresse d'un abonné pour un canal ({ type, address : { email, phone }, subscriber }) : e-mail, téléphone E.164, le nom du canal si l'abonné a une adresse de messagerie ou web ou un appareil push actif, in_app si l'abonné est lié à un compte (fil) ; NONE sans adresse";

-- ----------------------------------------------------------------------------
-- fn::notification_run_create : déclenchement pour un abonné
-- ----------------------------------------------------------------------------
-- { tenant, workflow (parcours), subscriber (abonné), idempotency_key, event_id, payload,
-- secret, expires_at, settings, actor, broadcast, overrides, test } → { status : created,
-- duplicate, skipped, no_address ou forbidden ; run_id, skip_reason, job_ids }. Une adresse
-- supprimée arrête le déclenchement (un parcours critique n'est arrêté que par un rejet définitif
-- ou un blocage manuel) ; sinon les premières étapes sont engagées (fn::notification_run_advance).
-- Idempotent par (portée, clé).

DEFINE FUNCTION OVERWRITE fn::notification_run_create($params: object) -> object {
    LET $workflow = $params.workflow;
    LET $subscriber = $params.subscriber;
    LET $scope = IF $params.tenant IS NONE { "installation" } ELSE { <string> record::id($params.tenant) };
    -- Étapes de canal que l'abonné peut recevoir (adresse e-mail, téléphone, adresses de messagerie ou web)
    LET $reachable = array::filter(
        array::map(array::filter($workflow.steps, |$step| $step.type IN fn::notification_channels({})), |$step| {
            type: $step.type, address: fn::notification_channel_address({ type: $step.type, address: $subscriber, subscriber: $subscriber.id })
        }),
        |$entry| $entry.address IS NOT NONE);
    IF array::len($reachable) = 0 {
        RETURN { status: "no_address", run_id: NONE, skip_reason: "no_address", job_ids: [] };
    };
    -- Liste de suppression : le déclenchement n'est arrêté que si toutes ses adresses sont
    -- supprimées ; une étape dont seule l'adresse est supprimée est écartée à son tour
    -- (motif suppressed:<motif>)
    LET $blocking = array::map($reachable, |$entry| fn::notification_suppression_reason({ scope: $scope, channel: $entry.type, address: $entry.address, critical: $workflow.critical }));
    LET $skip = IF array::all($blocking, |$reason| $reason IS NOT NONE) { string::concat("suppressed:", $blocking[0]) } ELSE { NONE };
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
        cursor: 0,
        steps: $workflow.steps,
        overrides: $params.overrides ?? {},
        test: $params.test ?? false,
        expires_at: $params.expires_at ?? IF $params.secret IS NONE { NONE } ELSE { time::now() + 7d },
        purge_after: time::now() + duration::from_days($params.settings.retention_days_runs)
    });
    IF array::len($inserted) = 0 {
        LET $existing = (SELECT VALUE id FROM ONLY notification_run WHERE scope_key = $scope AND idempotency_key = $params.idempotency_key LIMIT 1);
        IF $existing IS NONE { RETURN { status: "forbidden", run_id: NONE, skip_reason: NONE, job_ids: [] }; };
        RETURN { status: "duplicate", run_id: $existing, skip_reason: NONE, job_ids: (SELECT VALUE id FROM notification_job WHERE run = $existing) };
    };
    IF $skip IS NONE { fn::notification_run_advance({ run: $rid }); };
    LET $run = (SELECT status, skip_reason FROM ONLY $rid);
    RETURN {
        status: IF $run.status = "skipped" { "skipped" } ELSE { "created" },
        run_id: $rid,
        skip_reason: IF $run.status = "skipped" { $run.skip_reason } ELSE { NONE },
        job_ids: (SELECT VALUE id FROM notification_job WHERE run = $rid)
    };
} COMMENT "Crée le déclenchement d'un abonné ({ tenant, workflow, subscriber, idempotency_key, event_id, payload, secret, expires_at, settings, actor, broadcast, overrides, test }) et engage ses premières étapes ; adresses par canal et liste de suppression appliquées ; idempotent par (portée, clé). Renvoie { status, run_id, skip_reason, job_ids }";

-- ----------------------------------------------------------------------------
-- fn::notification_trigger_target : destinataire(s) validé(s) de `to`
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_trigger_target($params: object) -> object {
    LET $to = $params.to;
    LET $subscriber_schema = { fields: fn::notification_subscriber_fields({}), unknown_keys: "reject" };
    IF type::is_array($to) {
        LET $bounds = fn::validation_array_length($to, 1, 100);
        IF !$bounds.valid { RETURN { valid: false, by_field: { to: [$bounds.code] } }; };
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
-- fn::notification_trigger_workflow : parcours visé (organisation, puis installation)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_trigger_workflow($params: object) -> object {
    LET $scope = IF $params.tenant IS NONE { "installation" } ELSE { <string> record::id($params.tenant) };
    LET $candidates = (SELECT * FROM notification_workflow WHERE scope_key IN [$scope, "installation"]
        AND (($params.workflow_key IS NOT NONE AND key = $params.workflow_key) OR ($params.workflow_key IS NONE AND trigger_event = $params.trigger_event)));
    LET $usable = |$w| !$params.active_only OR $w.status = "active";
    LET $workflow = array::find($candidates, |$w| $w.scope_key = $scope AND $usable($w))
        ?? array::find($candidates, |$w| $w.scope_key = "installation" AND $usable($w));
    IF $workflow == NONE {
        RETURN { code: IF array::len($candidates) = 0 { "NOTIFICATION_WORKFLOW_NOT_FOUND" } ELSE { "NOTIFICATION_WORKFLOW_INACTIVE" }, workflow: NONE };
    };
    RETURN { code: NONE, workflow: $workflow };
} COMMENT "Interne : parcours d'une portée ({ tenant, workflow_key ou trigger_event, active_only }), sinon de l'installation ; { code (NOTIFICATION_WORKFLOW_NOT_FOUND, NOTIFICATION_WORKFLOW_INACTIVE), workflow }";

-- ----------------------------------------------------------------------------
-- fn::notification_trigger_one : déclenchement pour un abonné de `to`
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_trigger_one($params: object) -> object {
    LET $input = $params.input;
    -- Un identifiant seul désigne un abonné existant ; sinon il est créé ou mis à jour à la volée
    LET $saved = fn::notification_subscriber_save({ tenant: $params.tenant, input: $input, must_exist: array::len(array::filter(object::values($input), |$v| $v IS NOT NONE)) = 1 });
    IF $saved.code IS NOT NONE { RETURN { subscriber_id: $input.subscriber_id, status: "rejected", code: $saved.code, details: $saved.details }; };
    IF $params.exclude_actor AND $params.actor IS NOT NONE AND $params.actor = $input.subscriber_id {
        RETURN { subscriber_id: $input.subscriber_id, subscriber: $saved.subscriber.id, status: "skipped", skip_reason: "actor", run_id: NONE, job_ids: [] };
    };
    LET $run = fn::notification_run_create({
        tenant: $params.tenant, workflow: $params.workflow, subscriber: $saved.subscriber, idempotency_key: $params.idempotency_key,
        event_id: $params.event_id, payload: $params.payload, secret: $params.secret, expires_at: $params.expires_at,
        settings: $params.settings, actor: $params.actor, broadcast: NONE, overrides: $params.overrides, test: $params.test
    });
    RETURN object::extend($run, { subscriber_id: $input.subscriber_id, subscriber: $saved.subscriber.id });
} COMMENT "Interne : déclenchement pour un abonné ({ tenant, workflow, input, idempotency_key, event_id, payload, secret, expires_at, settings, actor, exclude_actor, overrides, test }) : abonné créé ou mis à jour à la volée, auteur exclu ; issue de fn::notification_run_create avec subscriber_id et subscriber, ou rejected (code, details)";

-- ----------------------------------------------------------------------------
-- fn::notification_trigger_single : réponse d'un déclenchement pour un seul abonné
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_trigger_single($params: object) -> object {
    LET $result = $params.result;
    IF $result.status = "rejected" { RETURN fn::error_result($result.code, $params.language, $result.details ?? {}); };
    LET $channels = array::distinct(array::filter($params.workflow.steps.type, |$type| $type IN fn::notification_channels({})));
    -- Parcours qui n'envoie que des SMS : l'abonné n'a pas de téléphone
    IF $result.status = "no_address" AND $channels == ["sms"] { RETURN fn::error_result("NOTIFICATION_SUBSCRIBER_NO_PHONE", $params.language, { channels: $channels }); };
    IF $result.status = "no_address" { RETURN fn::error_result("NOTIFICATION_SUBSCRIBER_NO_ADDRESS", $params.language, { channels: $channels }); };
    IF $result.status = "forbidden" { RETURN fn::error_result("NOTIFICATION_WRITE_FORBIDDEN", $params.language, { table: "notification_run" }); };
    RETURN fn::result_ok(object::extend(object::remove($result, ["subscriber_id"]), { kind: "subscriber" }));
} COMMENT "Interne : résultat LyxalResult du déclenchement d'un abonné ({ result, workflow, language })";

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
            overrides: { pipeline: [{ rule: "is_object" }], default: {} },
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
    LET $found = fn::notification_trigger_workflow({ tenant: $p.tenant, workflow_key: $p.workflow_key, trigger_event: $p.trigger_event, active_only: true });
    IF $found.code IS NOT NONE { RETURN fn::error_result($found.code, $p.language, {}); };
    LET $workflow = $found.workflow;
    IF $workflow.payload_schema IS NOT NONE {
        LET $checked = fn::validation_object_execute($p.payload, $workflow.payload_schema, 80);
        IF !$checked.valid { RETURN fn::error_result("NOTIFICATION_PAYLOAD_INVALID", $p.language, { fields: $checked.by_field }); };
    };
    LET $settings = fn::notification_settings_effective({ tenant: $p.tenant });
    -- Surcharges : étapes connues, réglages permis pour leur type, durées bornées
    LET $overrides = fn::notification_override_check({ overrides: $p.overrides, workflow: $workflow, max_wait_days: $settings.max_wait_days });
    IF $overrides.code IS NOT NONE { RETURN fn::error_result($overrides.code, $p.language, $overrides.details); };
    -- Sujet ou tous : diffusion enregistrée, traitée par le worker (idempotente par portée et clé)
    IF $target.kind IN ["topic", "all"] {
        LET $topic = IF $target.kind = "topic" { fn::notification_topic_find({ tenant: $p.tenant, key: $target.topic }) } ELSE { NONE };
        IF $target.kind = "topic" AND $topic IS NONE { RETURN fn::error_result("NOTIFICATION_TOPIC_NOT_FOUND", $p.language, { key: $target.topic }); };
        LET $inserted = (INSERT IGNORE INTO notification_broadcast {
            tenant: $p.tenant, workflow: $workflow.id, idempotency_key: $p.idempotency_key, event_id: $p.event_id,
            topic: $topic.id, to_all: $target.kind = "all", actor: $p.actor, exclude_actor: $p.exclude_actor, payload: $p.payload,
            overrides: $overrides.overrides,
            purge_after: time::now() + duration::from_days($settings.retention_days_runs)
        });
        IF array::len($inserted) > 0 { RETURN fn::result_ok({ kind: "broadcast", broadcast_id: $inserted[0].id, status: "created" }); };
        LET $existing = (SELECT VALUE id FROM ONLY notification_broadcast WHERE scope_key = $scope AND idempotency_key = $p.idempotency_key LIMIT 1);
        IF $existing IS NONE { RETURN fn::error_result("NOTIFICATION_WRITE_FORBIDDEN", $p.language, { table: "notification_broadcast" }); };
        RETURN fn::result_ok({ kind: "broadcast", broadcast_id: $existing, status: "duplicate" });
    };
    -- Un abonné ou une liste : abonnés créés ou mis à jour à la volée (un identifiant seul doit exister)
    LET $context = {
        tenant: $p.tenant, workflow: $workflow, event_id: $p.event_id, payload: $p.payload, secret: $p.secret,
        expires_at: $p.expires_at, settings: $settings, actor: $p.actor, exclude_actor: $p.exclude_actor,
        overrides: $overrides.overrides, test: false
    };
    IF $target.kind = "subscriber" {
        LET $result = fn::notification_trigger_one(object::extend($context, { input: $target.subscriber, idempotency_key: $p.idempotency_key }));
        RETURN fn::notification_trigger_single({ result: $result, workflow: $workflow, language: $p.language });
    };
    RETURN fn::result_ok({
        kind: "list",
        runs: array::map($target.subscribers, |$input| fn::notification_trigger_one(object::extend($context, {
            input: $input, idempotency_key: string::concat($p.idempotency_key, "/", $input.subscriber_id)
        })))
    });
} COMMENT "Déclenche un parcours actif (workflow_key ou trigger_event ; organisation puis installation) ({ tenant, idempotency_key, event_id, to, actor, exclude_actor, payload, overrides : { steps : { <clé> : { skip, amount, unit, window } } }, secret enc:v2 (un seul abonné), expires_at }). to : abonné { subscriber_id, email, phone, first_name, last_name, locale, timezone, data, identity } créé ou mis à jour à la volée, liste de 100 abonnés au plus (clé <clé>/<subscriber_id> par abonné), { topic } ou { all: true } (diffusion asynchrone). Idempotent ; préférences, adresses et liste de suppression appliquées ; auteur exclu sauf exclude_actor faux ; étapes exécutées dans l'ordre. Permission notification.send";

-- ----------------------------------------------------------------------------
-- fn::notification_trigger_bulk : envoi groupé
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_trigger_bulk($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            events: { pipeline: [{ rule: "array_objects", options: { allow_empty_objects: false } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $bounds = fn::validation_array_length($p.events, 1, 100);
    IF !$bounds.valid { RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", $p.language, { fields: { events: [$bounds.code] } }); };
    -- Chaque déclenchement est contrôlé et exécuté comme fn::notification_trigger
    RETURN fn::result_ok({
        results: array::map($p.events, |$event, $index| {
            LET $result = fn::notification_trigger(object::extend($event, { language: $p.language }));
            RETURN {
                index: $index,
                ok: $result.ok,
                data: $result.data,
                error: IF $result.ok { NONE } ELSE { { code: $result.error.code, details: $result.error.details } }
            };
        })
    });
} COMMENT "Envoi groupé ({ events : 1 à 100 déclenchements de la forme de fn::notification_trigger }) : chaque déclenchement est contrôlé, autorisé et exécuté séparément ; rapport par entrée { index, ok, data, error : { code, details } }. Permission notification.send";

-- ----------------------------------------------------------------------------
-- fn::notification_cancel : annulation des déclenchements en cours d'une clé
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_cancel($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            idempotency_key: { pipeline: [{ rule: "idempotency_key", options: { min_length: 1, max_length: 128 } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::notification_can({ action: "send", tenant: $p.tenant }) { RETURN fn::error_result("NOTIFICATION_PERMISSION_DENIED", $p.language, {}); };
    LET $scope = IF $p.tenant IS NONE { "installation" } ELSE { <string> record::id($p.tenant) };
    -- Déclenchement de la clé, ou de chaque abonné d'une liste ou d'une diffusion (<clé>/…)
    LET $runs = (SELECT VALUE id FROM notification_run WHERE scope_key = $scope AND status IN ["pending", "waiting"]
        AND (idempotency_key = $p.idempotency_key OR string::starts_with(idempotency_key, string::concat($p.idempotency_key, "/"))));
    IF array::len($runs) = 0 { RETURN fn::error_result("NOTIFICATION_RUN_NOT_FOUND", $p.language, { idempotency_key: $p.idempotency_key }); };
    LET $canceled = array::map($runs, |$run| {
        -- Un envoi déjà parti (ou en cours) n'est pas rappelé ; les étapes en attente sont annulées
        UPDATE notification_job SET status = "canceled", skip_reason = "canceled", locked_until = NONE, claim_token = NONE
            WHERE run = $run AND status IN ["queued", "waiting"];
        -- Regroupement porté : refermé sans envoi
        UPDATE notification_digest SET status = "closed", open_slot = NONE, closed_at = time::now() WHERE carrier = $run AND status = "open";
        RETURN (UPDATE ONLY $run SET status = "canceled", skip_reason = "canceled", secret = NONE WHERE status IN ["pending", "waiting"]);
    });
    IF array::any($canceled, |$run| $run == NONE) { RETURN fn::error_result("NOTIFICATION_WRITE_FORBIDDEN", $p.language, { table: "notification_run" }); };
    RETURN fn::result_ok({ canceled: array::len($canceled), runs: $canceled.id });
} COMMENT "Annule les déclenchements en cours ou en attente d'une clé ({ tenant, idempotency_key }) : celui de la clé et ceux de chaque abonné d'une liste ou d'une diffusion (<clé>/…) ; étapes en file ou en attente annulées, regroupement porté refermé sans envoi, secret effacé ; un envoi déjà parti n'est pas rappelé ; NOTIFICATION_RUN_NOT_FOUND si aucun. Renvoie { canceled, runs }. Permission notification.send";

-- ----------------------------------------------------------------------------
-- fn::notification_test_send : envoi de test d'un parcours
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_test_send($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            workflow_key: { pipeline: [{ rule: "snake_case_name", options: { min_length: 1, max_length: 64 } }], required: true },
            to: { pipeline: [{ rule: "is_object" }], required: true },
            payload: { pipeline: [{ rule: "is_object" }], default: {} },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    -- Un seul abonné (ni sujet, ni tous)
    LET $target = fn::notification_trigger_target({ to: $p.to });
    IF !$target.valid OR $target.kind != "subscriber" {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", $p.language, { fields: $target.by_field ?? { to: ["CORE_VALIDATION_NOT_ALLOWED"] } });
    };
    IF !fn::notification_can({ action: "manage", tenant: $p.tenant }) { RETURN fn::error_result("NOTIFICATION_PERMISSION_DENIED", $p.language, {}); };
    -- Parcours de la portée ou de l'installation, quel que soit son état (brouillon compris)
    LET $found = fn::notification_trigger_workflow({ tenant: $p.tenant, workflow_key: $p.workflow_key, active_only: false });
    IF $found.code IS NOT NONE { RETURN fn::error_result($found.code, $p.language, {}); };
    IF $found.workflow.payload_schema IS NOT NONE {
        LET $checked = fn::validation_object_execute($p.payload, $found.workflow.payload_schema, 80);
        IF !$checked.valid { RETURN fn::error_result("NOTIFICATION_PAYLOAD_INVALID", $p.language, { fields: $checked.by_field }); };
    };
    LET $result = fn::notification_trigger_one({
        tenant: $p.tenant, workflow: $found.workflow, input: $target.subscriber,
        idempotency_key: string::concat("test/", <string> rand::uuid::v7()), event_id: NONE, payload: $p.payload,
        secret: NONE, expires_at: NONE, settings: fn::notification_settings_effective({ tenant: $p.tenant }),
        actor: NONE, exclude_actor: false, overrides: {}, test: true
    });
    RETURN fn::notification_trigger_single({ result: $result, workflow: $found.workflow, language: $p.language });
} COMMENT "Envoi de test d'un parcours ({ tenant, workflow_key, to : un abonné, payload }), quel que soit son état : déclenchement test (clé test/<uuid>) qui ignore attentes, regroupements et limitations ; liste de suppression et préférences appliquées. Renvoie le résultat de fn::notification_trigger pour un abonné. Permission notification.manage";
