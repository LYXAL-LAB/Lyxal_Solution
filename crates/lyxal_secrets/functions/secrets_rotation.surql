-- ============================================================================
-- FONCTIONS : rotation d'un secret en quatre étapes
-- MODULE    : lyxal_secrets
-- ============================================================================
-- Modèle AWS : création (le rotateur produit la nouvelle valeur, écrite en version pending),
-- installation (activée chez le service extérieur), test, bascule (current passe sur la nouvelle
-- version, l'ancienne devient previous). La version courante reste en service jusqu'à la bascule.
-- Un échec est réessayé 3 fois (1 min, 10 min, 1 h) puis la rotation échoue. Le service Rust
-- (rotateurs, worker) déroule les étapes ; les fonctions tiennent l'état et ses règles.

-- ----------------------------------------------------------------------------
-- fn::secrets_rotation_started (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_rotation_started($secret: record<secrets_secret>) -> bool {
    RETURN (SELECT VALUE id FROM ONLY secrets_rotation WHERE secret = $secret AND state = "started" LIMIT 1) IS NOT NONE;
} COMMENT "Interne : vrai si une rotation du secret attend sa nouvelle valeur (étape started)";

-- ----------------------------------------------------------------------------
-- fn::secrets_rotation_view (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_rotation_view($id: record<secrets_rotation>) -> option<object> {
    RETURN (SELECT id, secret, tenant, state, emergency, reason, pending_number, previous_number, attempts, next_attempt_at,
        locked_until, last_error, started_by, started_at, updated_at, finished_at FROM ONLY $id);
} COMMENT "Interne : une rotation (sans champ technique)";

-- ----------------------------------------------------------------------------
-- fn::secrets_rotation_refusal (interne, garde)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_rotation_refusal($event: string, $before: option<object>, $after: object) -> option<string> {
    LET $tenant = $after.tenant;
    LET $worker = fn::secrets_can({ action: "worker", tenant: $tenant });
    LET $writer = fn::secrets_can({ action: "write", tenant: $tenant });
    IF $event = "CREATE" {
        LET $secret = (SELECT tenant, state FROM ONLY $after.secret);
        IF $secret == NONE { RETURN "SECRETS_SECRET_NOT_FOUND"; };
        IF $secret.state = "deleted" { RETURN "SECRETS_SECRET_DELETED"; };
        IF $after.tenant != $secret.tenant OR $after.state != "started" OR $after.attempts != 0 OR $after.pending_number IS NOT NONE
            OR $after.finished_at IS NOT NONE OR $after.last_error IS NOT NONE {
            RETURN "SECRETS_ROTATION_STATE_INVALID";
        };
        RETURN IF $writer OR $worker { NONE } ELSE { "SECRETS_PERMISSION_DENIED" };
    };
    LET $terminal = ["succeeded", "failed", "cancelled"];
    IF $before.state INSIDE $terminal { RETURN "SECRETS_ROTATION_STATE_INVALID"; };
    -- Annulation : écriture ou worker ; tout le reste (étapes, essais, réservation) : worker ou session système
    IF $after.state = "cancelled" {
        RETURN IF !$writer AND !$worker { "SECRETS_PERMISSION_DENIED" } ELSE IF $after.finished_at IS NONE { "SECRETS_ROTATION_STATE_INVALID" } ELSE { NONE };
    };
    IF !$worker { RETURN "SECRETS_PERMISSION_DENIED"; };
    IF $after.state = $before.state {
        -- Essai planifié ou réservation : la nouvelle version ne change pas, les essais ne reculent pas
        RETURN IF $after.pending_number != $before.pending_number OR $after.attempts < $before.attempts { "SECRETS_ROTATION_STATE_INVALID" } ELSE { NONE };
    };
    IF $after.state = "failed" { RETURN IF $after.finished_at IS NONE { "SECRETS_ROTATION_STATE_INVALID" } ELSE { NONE }; };
    LET $next = { started: "created", created: "installed", installed: "tested", tested: "succeeded" }[$before.state];
    IF $after.state != $next { RETURN "SECRETS_ROTATION_STATE_INVALID"; };
    IF $after.state = "created" { RETURN IF $after.pending_number IS NONE { "SECRETS_ROTATION_STATE_INVALID" } ELSE { NONE }; };
    IF $after.pending_number != $before.pending_number { RETURN "SECRETS_ROTATION_STATE_INVALID"; };
    RETURN IF $after.state = "succeeded" AND $after.finished_at IS NONE { "SECRETS_ROTATION_STATE_INVALID" } ELSE { NONE };
} COMMENT "Interne : refus d'une écriture de rotation ($event, $before, $after) : création à l'étape started par l'écriture ou le worker sur un secret non supprimé ; étapes dans l'ordre started → created (nouvelle version posée) → installed → tested → succeeded, échec et nouveaux essais par le worker ou la session système ; annulation par l'écriture ; rotation terminée intouchable. NONE ou code d'erreur";

-- ----------------------------------------------------------------------------
-- fn::secrets_rotation_load (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_rotation_load($params: object, $fields: object) -> object {
    LET $report = fn::validation_object_execute($params, {
        fields: object::extend({
            rotation: { pipeline: [{ rule: "record", options: { expected_table: "secrets_rotation" } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        }, $fields),
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN { error: fn::error_result("SECRETS_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field }) };
    };
    LET $p = $report.value;
    LET $rotation = (SELECT * FROM ONLY $p.rotation);
    IF $rotation == NONE { RETURN { error: fn::error_result("SECRETS_ROTATION_NOT_FOUND", $p.language, { rotation: <string> $p.rotation }) }; };
    LET $secret = (SELECT id, tenant, path, state, labels, rotation_period FROM ONLY $rotation.secret);
    RETURN { p: $p, rotation: $rotation, secret: $secret };
} COMMENT "Interne : valide { rotation, language } et les champs $fields, charge la rotation et son secret : { p, rotation, secret } ou { error }";

-- ----------------------------------------------------------------------------
-- fn::secrets_rotation_begin
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_rotation_begin($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            secret: { pipeline: [{ rule: "record", options: { expected_table: "secrets_secret" } }], required: true },
            emergency: { pipeline: [{ rule: "boolean" }], default: false },
            reason: { pipeline: [{ rule: "optional_string", options: { max_length: 512 } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("SECRETS_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $secret = (SELECT id, tenant, state, labels FROM ONLY $p.secret);
    IF $secret == NONE { RETURN fn::error_result("SECRETS_SECRET_NOT_FOUND", $p.language, { secret: <string> $p.secret }); };
    LET $writer = fn::secrets_can({ action: "write", tenant: $secret.tenant });
    -- Urgence : décision humaine (écriture) ; rotation planifiée : écriture ou worker
    IF !$writer AND ($p.emergency OR !fn::secrets_can({ action: "worker", tenant: $secret.tenant })) {
        RETURN fn::error_result("SECRETS_PERMISSION_DENIED", $p.language, {});
    };
    IF $secret.state = "deleted" { RETURN fn::error_result("SECRETS_SECRET_DELETED", $p.language, { secret: <string> $secret.id }); };
    IF $secret.state != "active" { RETURN fn::error_result("SECRETS_SECRET_STATE_INVALID", $p.language, { state: $secret.state }); };
    LET $caller = fn::secrets_caller();
    -- Urgence demandée par une personne : niveau d'assurance le plus haut et récent
    IF $p.emergency AND $caller.kind = "interactive" {
        LET $assurance = fn::auth_assurance_check({ min_aal: "highest_available", fresh: true });
        IF !$assurance.ok { RETURN fn::error_result($assurance.error.code, $p.language, $assurance.error.details ?? {}); };
    };
    LET $running = (SELECT VALUE id FROM ONLY secrets_rotation WHERE secret = $secret.id AND active_slot = "active" LIMIT 1);
    IF $running IS NOT NONE { RETURN fn::error_result("SECRETS_ROTATION_IN_PROGRESS", $p.language, { rotation: <string> $running }); };
    -- Urgence : la version courante est coupée tout de suite, avant toute autre étape
    IF $p.emergency AND $secret.labels.current IS NOT NONE {
        UPDATE secrets_version SET state = "disabled" WHERE secret = $secret.id AND number = $secret.labels.current AND state = "enabled";
        IF (SELECT VALUE state FROM ONLY secrets_version WHERE secret = $secret.id AND number = $secret.labels.current LIMIT 1) = "enabled" {
            RETURN fn::error_result("SECRETS_WRITE_FORBIDDEN", $p.language, { table: "secrets_version" });
        };
    };
    LET $inserted = (INSERT IGNORE INTO secrets_rotation {
        secret: $secret.id,
        tenant: $secret.tenant,
        emergency: $p.emergency,
        reason: $p.reason,
        previous_number: $secret.labels.current,
        started_by: IF $caller.identity IS NOT NONE { <string> $caller.identity } ELSE IF $caller.application IS NOT NONE { <string> $caller.application } ELSE { NONE }
    });
    -- Index (secret, active_slot) : une rotation concurrente a démarré
    IF array::len($inserted) = 0 { RETURN fn::error_result("SECRETS_ROTATION_IN_PROGRESS", $p.language, { secret: <string> $secret.id }); };
    -- Une étiquette pending d'une écriture antérieure n'appartient pas à cette rotation
    IF $secret.labels.pending IS NOT NONE {
        LET $cleared = (UPDATE ONLY $secret.id SET labels = object::remove(labels, "pending"));
        IF $cleared == NONE { RETURN fn::error_result("SECRETS_WRITE_FORBIDDEN", $p.language, { table: "secrets_secret" }); };
    };
    RETURN fn::result_ok(fn::secrets_rotation_view($inserted[0].id));
} COMMENT "Démarre la rotation d'un secret actif ({ secret, emergency, reason }) : une seule en cours par secret (SECRETS_ROTATION_IN_PROGRESS). Urgence : la version courante est désactivée tout de suite ; décision d'une personne (droit d'écriture, assurance la plus haute et récente) ou d'un programme ayant le droit d'écriture. Le worker déroule ensuite les étapes. Droit : écriture, ou worker (rotation planifiée)";

-- ----------------------------------------------------------------------------
-- fn::secrets_rotation_step
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_rotation_step($params: object) {
    LET $l = fn::secrets_rotation_load($params, {
        step: { pipeline: [{ rule: "enum", options: { allowed: ["created", "installed", "tested"], case_sensitive: true } }], required: true },
        pending_number: { pipeline: [{ rule: "integer", options: { min_value: 1 } }] }
    });
    IF $l.error IS NOT NONE { RETURN $l.error; };
    LET $p = $l.p;
    IF !fn::secrets_can({ action: "worker", tenant: $l.rotation.tenant }) { RETURN fn::error_result("SECRETS_PERMISSION_DENIED", $p.language, {}); };
    LET $from = { created: "started", installed: "created", tested: "installed" }[$p.step];
    IF $l.rotation.state != $from { RETURN fn::error_result("SECRETS_ROTATION_STATE_INVALID", $p.language, { state: $l.rotation.state, step: $p.step }); };
    -- Création : la nouvelle valeur est la version pending du secret
    IF $p.step = "created" AND ($p.pending_number IS NONE OR $l.secret.labels.pending != $p.pending_number) {
        RETURN fn::error_result("SECRETS_ROTATION_STATE_INVALID", $p.language, { pending_number: $p.pending_number, labels: $l.secret.labels });
    };
    LET $updated = (UPDATE ONLY $l.rotation.id SET state = $p.step, pending_number = IF $p.step = "created" { $p.pending_number } ELSE { pending_number }
        WHERE state = $from);
    IF $updated == NONE { RETURN fn::error_result("SECRETS_ROTATION_STATE_INVALID", $p.language, { step: $p.step }); };
    RETURN fn::result_ok(fn::secrets_rotation_view($l.rotation.id));
} COMMENT "Enregistre l'étape franchie par une rotation ({ rotation, step : created (avec pending_number, la version pending écrite), installed, tested }), dans l'ordre (SECRETS_ROTATION_STATE_INVALID sinon). Droit : worker ou session système";

-- ----------------------------------------------------------------------------
-- fn::secrets_rotation_finish
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_rotation_finish($params: object) {
    LET $l = fn::secrets_rotation_load($params, {});
    IF $l.error IS NOT NONE { RETURN $l.error; };
    LET $p = $l.p;
    IF !fn::secrets_can({ action: "worker", tenant: $l.rotation.tenant }) { RETURN fn::error_result("SECRETS_PERMISSION_DENIED", $p.language, {}); };
    IF $l.rotation.state != "tested" { RETURN fn::error_result("SECRETS_ROTATION_STATE_INVALID", $p.language, { state: $l.rotation.state }); };
    IF $l.secret.state = "deleted" { RETURN fn::error_result("SECRETS_SECRET_DELETED", $p.language, { secret: <string> $l.secret.id }); };
    LET $n = $l.rotation.pending_number;
    IF $l.secret.labels.pending != $n { RETURN fn::error_result("SECRETS_ROTATION_STATE_INVALID", $p.language, { pending_number: $n, labels: $l.secret.labels }); };
    -- Bascule : current sur la nouvelle version, previous sur l'ancienne, pending retirée
    LET $labels = object::extend(object::remove($l.secret.labels, "pending"),
        IF $l.secret.labels.current IS NONE { { current: $n } } ELSE { { current: $n, previous: $l.secret.labels.current } });
    LET $switched = (UPDATE ONLY $l.secret.id SET
        labels = $labels,
        last_rotated_at = time::now(),
        next_rotation_at = IF rotation_period IS NONE { NONE } ELSE { time::now() + rotation_period },
        rotation_notified_at = NONE);
    IF $switched == NONE { RETURN fn::error_result("SECRETS_WRITE_FORBIDDEN", $p.language, { table: "secrets_secret" }); };
    LET $updated = (UPDATE ONLY $l.rotation.id SET state = "succeeded", finished_at = time::now(), locked_until = NONE, next_attempt_at = NONE WHERE state = "tested");
    IF $updated == NONE { RETURN fn::error_result("SECRETS_ROTATION_STATE_INVALID", $p.language, {}); };
    RETURN fn::result_ok(object::extend(fn::secrets_rotation_view($l.rotation.id), { labels: $labels }));
} COMMENT "Termine une rotation testée ({ rotation }) : current passe sur la nouvelle version, l'ancienne devient previous, pending est retirée ; dernière rotation et prochaine date posées, rappel remis à zéro. Droit : worker ou session système";

-- ----------------------------------------------------------------------------
-- fn::secrets_rotation_close (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_rotation_close($l: object, $state: string, $code: option<string>) {
    LET $updated = (UPDATE ONLY $l.rotation.id SET state = $state, finished_at = time::now(), locked_until = NONE, next_attempt_at = NONE,
        last_error = $code ?? last_error, attempts = IF $state = "failed" { math::min([attempts + 1, 4]) } ELSE { attempts }
        WHERE active_slot = "active");
    IF $updated == NONE { RETURN fn::error_result("SECRETS_ROTATION_STATE_INVALID", $l.p.language, { state: $l.rotation.state }); };
    -- La nouvelle valeur n'est pas mise en service : son étiquette est retirée, la version courante reste
    IF $l.rotation.pending_number IS NOT NONE AND $l.secret.labels.pending = $l.rotation.pending_number AND $l.secret.state != "deleted" {
        LET $cleared = (UPDATE ONLY $l.secret.id SET labels = object::remove(labels, "pending"));
        IF $cleared == NONE { RETURN fn::error_result("SECRETS_WRITE_FORBIDDEN", $l.p.language, { table: "secrets_secret" }); };
    };
    RETURN fn::result_ok(fn::secrets_rotation_view($l.rotation.id));
} COMMENT "Interne : termine une rotation en cours en échec ou annulée ($l chargé par fn::secrets_rotation_load, $state, $code) et retire l'étiquette pending de sa nouvelle version";

-- ----------------------------------------------------------------------------
-- fn::secrets_rotation_fail
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_rotation_fail($params: object) {
    LET $l = fn::secrets_rotation_load($params, {
        code: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 128 } }], required: true },
        retry: { pipeline: [{ rule: "boolean" }], default: true }
    });
    IF $l.error IS NOT NONE { RETURN $l.error; };
    LET $p = $l.p;
    IF !fn::secrets_can({ action: "worker", tenant: $l.rotation.tenant }) { RETURN fn::error_result("SECRETS_PERMISSION_DENIED", $p.language, {}); };
    IF $l.rotation.active_slot != "active" { RETURN fn::error_result("SECRETS_ROTATION_STATE_INVALID", $p.language, { state: $l.rotation.state }); };
    LET $attempts = $l.rotation.attempts + 1;
    -- Trois nouveaux essais au plus, espacés de 1 min, 10 min, 1 h ; l'étape atteinte est reprise
    IF $p.retry AND $attempts <= 3 {
        LET $updated = (UPDATE ONLY $l.rotation.id SET attempts = $attempts, last_error = $p.code, locked_until = NONE,
            next_attempt_at = time::now() + [1m, 10m, 1h][$attempts - 1] WHERE active_slot = "active");
        IF $updated == NONE { RETURN fn::error_result("SECRETS_ROTATION_STATE_INVALID", $p.language, {}); };
        RETURN fn::result_ok(fn::secrets_rotation_view($l.rotation.id));
    };
    RETURN fn::secrets_rotation_close($l, "failed", $p.code);
} COMMENT "Enregistre l'échec d'une étape ({ rotation, code (code d'erreur, jamais de valeur), retry (défaut vrai) }) : nouvel essai planifié (1 min, 10 min, 1 h ; 3 au plus), sinon rotation en échec, étiquette pending retirée, version courante inchangée. Droit : worker ou session système";

-- ----------------------------------------------------------------------------
-- fn::secrets_rotation_cancel
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_rotation_cancel($params: object) {
    LET $l = fn::secrets_rotation_load($params, {});
    IF $l.error IS NOT NONE { RETURN $l.error; };
    LET $p = $l.p;
    IF !fn::secrets_can({ action: "write", tenant: $l.rotation.tenant }) AND !fn::secrets_can({ action: "worker", tenant: $l.rotation.tenant }) {
        RETURN fn::error_result("SECRETS_PERMISSION_DENIED", $p.language, {});
    };
    IF $l.rotation.active_slot != "active" { RETURN fn::error_result("SECRETS_ROTATION_STATE_INVALID", $p.language, { state: $l.rotation.state }); };
    RETURN fn::secrets_rotation_close($l, "cancelled", NONE);
} COMMENT "Annule une rotation en cours ({ rotation }) : étiquette pending retirée, version courante inchangée (une version coupée par une urgence reste coupée). Droit : écriture";

-- ----------------------------------------------------------------------------
-- fn::secrets_rotation_get
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_rotation_get($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            secret: { pipeline: [{ rule: "record", options: { expected_table: "secrets_secret" } }], required: true },
            limit: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 100 } }], default: 20 },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("SECRETS_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $secret = (SELECT id, tenant FROM ONLY $p.secret);
    IF $secret == NONE { RETURN fn::error_result("SECRETS_SECRET_NOT_FOUND", $p.language, { secret: <string> $p.secret }); };
    IF !fn::secrets_can({ action: "list", tenant: $secret.tenant }) AND !fn::secrets_can({ action: "worker", tenant: $secret.tenant }) {
        RETURN fn::error_result("SECRETS_PERMISSION_DENIED", $p.language, {});
    };
    LET $ids = (SELECT VALUE id FROM secrets_rotation WHERE secret = $secret.id ORDER BY started_at DESC LIMIT $p.limit);
    LET $items = array::map($ids, |$id| fn::secrets_rotation_view($id));
    RETURN fn::result_ok({
        active: array::filter($items, |$r| $r.state INSIDE ["started", "created", "installed", "tested"])[0],
        items: $items
    });
} COMMENT "Rotations d'un secret, les plus récentes d'abord ({ secret, limit (100 au plus) }) : { active (rotation en cours ou NONE), items }. Droit : liste";

-- ----------------------------------------------------------------------------
-- fn::secrets_rotation_claim
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_rotation_claim($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            rotation: { pipeline: [{ rule: "record", options: { expected_table: "secrets_rotation" } }] },
            limit: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 100 } }], default: 10 },
            lease_seconds: { pipeline: [{ rule: "integer", options: { min_value: 10, max_value: 3600 } }], default: 300 },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("SECRETS_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::secrets_can({ action: "worker" }) { RETURN fn::error_result("SECRETS_PERMISSION_DENIED", $p.language, {}); };
    LET $now = time::now();
    -- Rotation nommée (démarrée à l'instant) ou rotations en cours dont l'essai est échu
    LET $candidates = IF $p.rotation IS NOT NONE { [$p.rotation] } ELSE {
        (SELECT VALUE id FROM secrets_rotation WHERE active_slot = "active" AND (next_attempt_at IS NONE OR next_attempt_at <= $now)
            AND (locked_until IS NONE OR locked_until <= $now) ORDER BY started_at ASC LIMIT $p.limit)
    };
    LET $claimed = array::filter(array::map($candidates, |$id| (UPDATE ONLY $id SET locked_until = $now + duration::from_secs($p.lease_seconds)
        WHERE active_slot = "active" AND (next_attempt_at IS NONE OR next_attempt_at <= $now) AND (locked_until IS NONE OR locked_until <= $now))),
        |$r| $r IS NOT NONE);
    RETURN fn::result_ok({ items: array::map($claimed, |$r| fn::secrets_rotation_view($r.id)) });
} COMMENT "Réserve des rotations à faire avancer ({ rotation (une rotation précise), limit (100 au plus), lease_seconds (10 à 3600, défaut 300) }) : rotations en cours dont l'essai est échu et qu'aucun worker ne tient ; une rotation reprend à l'étape atteinte. { items }. Droit : worker ou session système";

-- ----------------------------------------------------------------------------
-- fn::secrets_rotation_check_record
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_rotation_check_record($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            secret: { pipeline: [{ rule: "record", options: { expected_table: "secrets_secret" } }], required: true },
            ok: { pipeline: [{ rule: "boolean" }], required: true },
            code: { pipeline: [{ rule: "optional_string", options: { min_length: 1, max_length: 128 } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("SECRETS_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $secret = (SELECT id, tenant, state FROM ONLY $p.secret);
    IF $secret == NONE { RETURN fn::error_result("SECRETS_SECRET_NOT_FOUND", $p.language, { secret: <string> $p.secret }); };
    IF !fn::secrets_can({ action: "worker", tenant: $secret.tenant }) { RETURN fn::error_result("SECRETS_PERMISSION_DENIED", $p.language, {}); };
    IF $secret.state = "deleted" { RETURN fn::error_result("SECRETS_SECRET_DELETED", $p.language, { secret: <string> $secret.id }); };
    -- Le résultat est posé sur la fiche ; l'événement de journal le trace et le publie
    LET $updated = (UPDATE ONLY $secret.id SET last_check_at = time::now(), last_check_ok = $p.ok,
        last_check_code = IF $p.ok { NONE } ELSE { $p.code });
    IF $updated == NONE { RETURN fn::error_result("SECRETS_WRITE_FORBIDDEN", $p.language, { table: "secrets_secret" }); };
    RETURN fn::result_ok({ checked_at: $updated.last_check_at, ok: $updated.last_check_ok, code: $updated.last_check_code });
} COMMENT "Enregistre le résultat d'un essai sans bascule ({ secret, ok, code (code d'erreur si échec, jamais de valeur) }) : le rotateur a testé la valeur en service sans rien changer ; résultat posé sur la fiche, entrée de journal rotation.check et événement secrets.rotation.checked. { checked_at, ok, code }. Droit : worker ou session système";
