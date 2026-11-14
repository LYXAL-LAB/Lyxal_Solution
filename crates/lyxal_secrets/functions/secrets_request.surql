-- ============================================================================
-- FONCTIONS : demandes d'accès et de changement, approbations
-- MODULE    : lyxal_secrets
-- ============================================================================
-- Demande d'accès : accordée (accès créé) dès que le nombre d'approbations requis est atteint.
-- Demande de changement d'un secret protégé : approuvée, puis appliquée par son auteur avec ses
-- propres droits (fn::secrets_request_apply). Un seul refus clôt une demande ; on n'approuve
-- jamais sa propre demande ; une demande sans réponse expire (réglage request_ttl).

-- ----------------------------------------------------------------------------
-- fn::secrets_request_view (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_request_view($id: record<secrets_request>) -> option<object> {
    RETURN (SELECT * OMIT open_slot FROM ONLY $id);
} COMMENT "Interne : une demande (sans champ technique)";

-- ----------------------------------------------------------------------------
-- fn::secrets_request_insert (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_request_insert($request: object) -> option<record<secrets_request>> {
    LET $caller = fn::secrets_caller();
    LET $inserted = (INSERT IGNORE INTO secrets_request object::extend($request, {
        requested_identity: $caller.identity,
        requested_application: IF $caller.identity IS NONE { $caller.application } ELSE { NONE },
        expires_at: time::now() + fn::secrets_settings_effective({ tenant: $request.tenant }).request_ttl
    }));
    RETURN $inserted[0].id;
} COMMENT "Interne : crée une demande au nom de l'appelant, avec son échéance ; NONE si une demande de changement est déjà ouverte sur le secret ou si la création est filtrée par les droits";

-- ----------------------------------------------------------------------------
-- fn::secrets_request_access
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_request_access($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }], required: true },
            path: { pipeline: [{ rule: "lyxal_storage_path", options: { allow_file_extension: true, max_length: 256 } }], required: true },
            folder: { pipeline: [{ rule: "boolean" }], default: false },
            actions: { pipeline: [{ rule: "array_of_strings", options: { allow_empty: false } }, { rule: "array_length", options: { max_length: 4 } }, { rule: "each", options: { pipeline: [{ rule: "enum", options: { allowed: ["list", "read_value", "write", "delete"], case_sensitive: true } }] } }], required: true },
            duration: { pipeline: [{ rule: "duration", options: { min_value: 5m, max_value: 90d } }] },
            reason: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 512 } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid {
        RETURN fn::error_result("SECRETS_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    -- Membre de l'organisation : la demande se fait depuis une session de cette organisation
    LET $caller = fn::secrets_caller();
    IF $caller.system OR !$caller.valid OR (SELECT VALUE organization FROM ONLY $caller.session) != $p.tenant {
        RETURN fn::error_result("SECRETS_PERMISSION_DENIED", $p.language, {});
    };
    LET $d = fn::secrets_grant_duration({ tenant: $p.tenant, path: $p.path, folder: $p.folder, duration: $p.duration });
    IF !$d.valid { RETURN fn::error_result("SECRETS_GRANT_INVALID", $p.language, { reason: "duration", max_duration: $d.max }); };
    LET $settings = fn::secrets_settings_effective({ tenant: $p.tenant });
    LET $id = fn::secrets_request_insert({
        tenant: $p.tenant,
        kind: "access",
        path: $p.path,
        folder: $p.folder,
        actions: array::distinct($p.actions),
        duration: $d.duration,
        reason: $p.reason,
        required_approvals: math::max([$settings.access_request_approvals, $d.policy.required_approvals])
    });
    IF $id IS NONE { RETURN fn::error_result("SECRETS_WRITE_FORBIDDEN", $p.language, { table: "secrets_request" }); };
    RETURN fn::result_ok(fn::secrets_request_view($id));
} COMMENT "Demande un accès temporaire pour soi ({ tenant, path, folder, actions, duration (bornée par les réglages et la protection du chemin), reason }) ; approbations requises : réglage access_request_approvals ou protection du chemin, la plus exigeante. Droit : membre de l'organisation (session de l'organisation)";

-- ----------------------------------------------------------------------------
-- fn::secrets_request_change
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_request_change($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            secret: { pipeline: [{ rule: "record", options: { expected_table: "secrets_secret" } }], required: true },
            operation: { pipeline: [{ rule: "enum", options: { allowed: ["value", "rollback", "disable", "delete", "destroy"], case_sensitive: true } }], required: true },
            number: { pipeline: [{ rule: "integer", options: { min_value: 1 } }] },
            reason: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 512 } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("SECRETS_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $secret = (SELECT id, tenant, path, state, labels FROM ONLY $p.secret);
    IF $secret == NONE { RETURN fn::error_result("SECRETS_SECRET_NOT_FOUND", $p.language, { secret: <string> $p.secret }); };
    LET $action = IF $p.operation IN ["delete", "destroy"] { "delete" } ELSE { "write" };
    IF !fn::secrets_can({ action: $action, tenant: $secret.tenant, path: $secret.path }) { RETURN fn::error_result("SECRETS_PERMISSION_DENIED", $p.language, {}); };
    IF $secret.state = "deleted" { RETURN fn::error_result("SECRETS_SECRET_DELETED", $p.language, { secret: <string> $secret.id }); };
    LET $policy = fn::secrets_policy_for({ tenant: $secret.tenant, path: $secret.path });
    IF $secret.tenant IS NONE OR $p.operation NOTINSIDE $policy.operations {
        RETURN fn::error_result("SECRETS_POLICY_NOT_FOUND", $p.language, { path: $secret.path, operation: $p.operation });
    };
    -- Version visée : proposée par l'appelant (value), existante non détruite (rollback, destroy)
    IF $p.operation IN ["value", "rollback", "destroy"] {
        LET $version = IF $p.number IS NONE { NONE } ELSE { fn::secrets_version_view($secret.id, $p.number) };
        IF $version == NONE OR $version.state = "destroyed" { RETURN fn::error_result("SECRETS_VERSION_NOT_FOUND", $p.language, { number: $p.number }); };
        LET $caller = fn::secrets_caller();
        IF $p.operation = "value" AND ($secret.labels.proposed != $p.number OR $version.created_by != $caller.identity
            OR $version.created_by_application != $caller.application) {
            RETURN fn::error_result("SECRETS_REQUEST_STATE_INVALID", $p.language, { reason: "proposed", number: $p.number });
        };
    };
    LET $id = fn::secrets_request_insert({
        tenant: $secret.tenant,
        kind: "change",
        path: $secret.path,
        secret: $secret.id,
        operation: $p.operation,
        number: IF $p.operation IN ["value", "rollback", "destroy"] { $p.number } ELSE { NONE },
        reason: $p.reason,
        required_approvals: $policy.required_approvals
    });
    IF $id IS NONE { RETURN fn::error_result("SECRETS_CHANGE_IN_PROGRESS", $p.language, { secret: <string> $secret.id }); };
    RETURN fn::result_ok(fn::secrets_request_view($id));
} COMMENT "Demande un changement d'un secret protégé ({ secret, operation : value (number : version proposée par l'appelant, étiquette proposed), rollback (number : version à remettre en service), disable, delete, destroy (number), reason }) ; une demande ouverte par secret (SECRETS_CHANGE_IN_PROGRESS) ; opération non protégée : SECRETS_POLICY_NOT_FOUND. Droit : écriture (suppression pour delete et destroy) sur le secret";

-- ----------------------------------------------------------------------------
-- fn::secrets_request_load (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_request_load($params: object, $fields: object) -> object {
    LET $report = fn::validation_object_execute($params, {
        fields: object::extend({
            request: { pipeline: [{ rule: "record", options: { expected_table: "secrets_request" } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        }, $fields),
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN { error: fn::error_result("SECRETS_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field }) };
    };
    LET $p = $report.value;
    LET $r = (SELECT * FROM ONLY $p.request);
    IF $r == NONE { RETURN { error: fn::error_result("SECRETS_REQUEST_NOT_FOUND", $p.language, { request: <string> $p.request }) }; };
    LET $caller = fn::secrets_caller();
    LET $mine = ($r.requested_identity IS NOT NONE AND $r.requested_identity = $caller.identity)
        OR ($r.requested_identity IS NONE AND $r.requested_application IS NOT NONE AND $r.requested_application = $caller.application);
    RETURN { p: $p, request: $r, caller: $caller, mine: $mine, expired: $r.state = "pending" AND $r.expires_at <= time::now() };
} COMMENT "Interne : valide { request, language } et $fields, charge la demande : { p, request, caller, mine (l'appelant en est l'auteur), expired } ou { error }";

-- ----------------------------------------------------------------------------
-- fn::secrets_request_approve
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_request_approve($params: object) {
    LET $l = fn::secrets_request_load($params, { comment: { pipeline: [{ rule: "optional_string", options: { max_length: 512 } }] } });
    IF $l.error IS NOT NONE { RETURN $l.error; };
    LET $p = $l.p;
    LET $r = $l.request;
    IF !fn::secrets_can({ action: "access", tenant: $r.tenant }) { RETURN fn::error_result("SECRETS_PERMISSION_DENIED", $p.language, {}); };
    IF $l.mine { RETURN fn::error_result("SECRETS_REQUEST_SELF_APPROVAL", $p.language, {}); };
    IF $r.state != "pending" OR $l.expired { RETURN fn::error_result("SECRETS_REQUEST_ALREADY_DECIDED", $p.language, { state: IF $l.expired { "expired" } ELSE { $r.state } }); };
    LET $actor = fn::secrets_actor();
    IF $actor INSIDE $r.approvals.by { RETURN fn::error_result("SECRETS_REQUEST_ALREADY_DECIDED", $p.language, { reason: "already_approved" }); };
    LET $approvals = array::append($r.approvals, { by: $actor, at: time::now(), comment: $p.comment });
    LET $final = array::len($approvals) >= $r.required_approvals;
    -- Demande d'accès approuvée : l'accès est créé par l'approbateur final
    LET $grant = IF $final AND $r.kind = "access" {
        LET $now = time::now();
        fn::secrets_grant_insert({
            tenant: $r.tenant,
            subject_identity: $r.requested_identity,
            subject_application: $r.requested_application,
            path: $r.path,
            folder: $r.folder,
            actions: $r.actions,
            starts_at: $now,
            expires_at: $now + $r.duration,
            reason: $r.reason,
            granted_by: $actor,
            request: $r.id
        })
    } ELSE { NONE };
    IF $final AND $r.kind = "access" AND $grant IS NONE { RETURN fn::error_result("SECRETS_WRITE_FORBIDDEN", $p.language, { table: "secrets_grant" }); };
    LET $updated = (UPDATE ONLY $r.id SET approvals = $approvals,
        state = IF $final { "approved" } ELSE { "pending" },
        decided_at = IF $final { time::now() } ELSE { NONE },
        grant = $grant
        WHERE state = "pending");
    IF $updated == NONE { RETURN fn::error_result("SECRETS_REQUEST_ALREADY_DECIDED", $p.language, {}); };
    RETURN fn::result_ok(fn::secrets_request_view($r.id));
} COMMENT "Approuve une demande en attente ({ request, comment }) ; au nombre d'approbations requis, elle passe à approved (demande d'accès : l'accès est créé). On n'approuve jamais sa propre demande (SECRETS_REQUEST_SELF_APPROVAL) ni deux fois la même. Droit : secrets.access.manage";

-- ----------------------------------------------------------------------------
-- fn::secrets_request_reject
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_request_reject($params: object) {
    LET $l = fn::secrets_request_load($params, { reason: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 512 } }], required: true } });
    IF $l.error IS NOT NONE { RETURN $l.error; };
    LET $p = $l.p;
    LET $r = $l.request;
    IF !fn::secrets_can({ action: "access", tenant: $r.tenant }) { RETURN fn::error_result("SECRETS_PERMISSION_DENIED", $p.language, {}); };
    IF $l.mine { RETURN fn::error_result("SECRETS_REQUEST_SELF_APPROVAL", $p.language, {}); };
    IF $r.state != "pending" OR $l.expired { RETURN fn::error_result("SECRETS_REQUEST_ALREADY_DECIDED", $p.language, { state: IF $l.expired { "expired" } ELSE { $r.state } }); };
    LET $updated = (UPDATE ONLY $r.id SET state = "rejected", decided_at = time::now(), decided_by = fn::secrets_actor(), decision_reason = $p.reason WHERE state = "pending");
    IF $updated == NONE { RETURN fn::error_result("SECRETS_REQUEST_ALREADY_DECIDED", $p.language, {}); };
    RETURN fn::result_ok(fn::secrets_request_view($r.id));
} COMMENT "Refuse une demande en attente ({ request, reason }) : un seul refus la clôt. Droit : secrets.access.manage, pas l'auteur";

-- ----------------------------------------------------------------------------
-- fn::secrets_request_cancel
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_request_cancel($params: object) {
    LET $l = fn::secrets_request_load($params, {});
    IF $l.error IS NOT NONE { RETURN $l.error; };
    LET $p = $l.p;
    LET $r = $l.request;
    IF !$l.mine { RETURN fn::error_result("SECRETS_PERMISSION_DENIED", $p.language, {}); };
    IF $r.state NOTINSIDE ["pending", "approved"] OR ($r.kind = "access" AND $r.state = "approved") {
        RETURN fn::error_result("SECRETS_REQUEST_STATE_INVALID", $p.language, { state: $r.state });
    };
    LET $updated = (UPDATE ONLY $r.id SET state = "cancelled", decided_at = time::now() WHERE state IN ["pending", "approved"]);
    IF $updated == NONE { RETURN fn::error_result("SECRETS_REQUEST_STATE_INVALID", $p.language, {}); };
    RETURN fn::result_ok(fn::secrets_request_view($r.id));
} COMMENT "Annule sa propre demande en attente, ou son changement approuvé pas encore appliqué ({ request }). Droit : auteur de la demande";

-- ----------------------------------------------------------------------------
-- fn::secrets_request_perform (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_request_perform($r: object, $language: string) {
    LET $s = <string> $r.secret;
    RETURN IF $r.operation = "value" {
        LET $labels = (SELECT VALUE labels FROM ONLY $r.secret);
        LET $moved = fn::secrets_version_label({ secret: $s, label: "current", number: $r.number, language: $language });
        IF !$moved.ok { $moved } ELSE IF $labels.proposed = $r.number {
            fn::secrets_version_label({ secret: $s, label: "proposed", remove: true, language: $language })
        } ELSE { $moved }
    } ELSE IF $r.operation = "rollback" {
        fn::secrets_version_label({ secret: $s, label: "current", number: $r.number, language: $language })
    } ELSE IF $r.operation = "disable" {
        fn::secrets_secret_disable({ secret: $s, language: $language })
    } ELSE IF $r.operation = "delete" {
        fn::secrets_secret_delete({ secret: $s, language: $language })
    } ELSE {
        fn::secrets_version_destroy({ secret: $s, number: $r.number, language: $language })
    };
} COMMENT "Interne : exécute le changement d'une demande ($r) avec les droits de l'appelant : value (current sur la version proposée, étiquette proposed retirée), rollback, disable, delete, destroy ; renvoie le résultat de la fonction appelée";

-- ----------------------------------------------------------------------------
-- fn::secrets_request_apply
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_request_apply($params: object) {
    LET $l = fn::secrets_request_load($params, {
        emergency: { pipeline: [{ rule: "boolean" }], default: false },
        reason: { pipeline: [{ rule: "optional_string", options: { min_length: 1, max_length: 512 } }] }
    });
    IF $l.error IS NOT NONE { RETURN $l.error; };
    LET $p = $l.p;
    LET $r = $l.request;
    IF !$l.mine { RETURN fn::error_result("SECRETS_PERMISSION_DENIED", $p.language, {}); };
    IF $r.kind != "change" { RETURN fn::error_result("SECRETS_REQUEST_STATE_INVALID", $p.language, { kind: $r.kind }); };
    -- Urgence : avant les approbations, avec le droit d'urgence, un motif et l'assurance la plus haute et récente
    IF $p.emergency {
        IF $r.state != "pending" OR $l.expired { RETURN fn::error_result("SECRETS_REQUEST_STATE_INVALID", $p.language, { state: $r.state }); };
        IF !fn::secrets_can({ action: "emergency", tenant: $r.tenant }) { RETURN fn::error_result("SECRETS_PERMISSION_DENIED", $p.language, {}); };
        IF $p.reason IS NONE { RETURN fn::error_result("SECRETS_INVALID_PARAMETERS", $p.language, { fields: { reason: { code: "CORE_VALIDATION_REQUIRED" } } }); };
        IF $l.caller.kind = "interactive" {
            LET $assurance = fn::auth_assurance_check({ min_aal: "highest_available", fresh: true });
            IF !$assurance.ok { RETURN fn::error_result($assurance.error.code, $p.language, $assurance.error.details ?? {}); };
        };
    } ELSE IF $r.state != "approved" OR $r.expires_at <= time::now() {
        RETURN fn::error_result("SECRETS_REQUEST_STATE_INVALID", $p.language, { state: IF $r.state = "approved" OR $l.expired { "expired" } ELSE { $r.state } });
    };
    LET $from = $r.state;
    -- applying : les gardes laissent passer cette opération sur ce secret pendant l'application
    LET $applying = (UPDATE ONLY $r.id SET state = "applying", emergency = $p.emergency,
        decision_reason = IF $p.emergency { $p.reason } ELSE { decision_reason } WHERE state = $from);
    IF $applying == NONE { RETURN fn::error_result("SECRETS_REQUEST_STATE_INVALID", $p.language, {}); };
    LET $done = fn::secrets_request_perform($r, $p.language);
    IF !$done.ok {
        UPDATE ONLY $r.id SET state = $from, emergency = false;
        RETURN $done;
    };
    LET $applied = (UPDATE ONLY $r.id SET state = "applied", applied_at = time::now(), decided_at = decided_at ?? time::now() WHERE state = "applying");
    IF $applied == NONE { RETURN fn::error_result("SECRETS_WRITE_FORBIDDEN", $p.language, { table: "secrets_request" }); };
    RETURN fn::result_ok(fn::secrets_request_view($r.id));
} COMMENT "Applique son changement approuvé ({ request }), ou, en urgence, avant les approbations ({ request, emergency: true, reason } : droit secrets.access.emergency, assurance la plus haute et récente ; journalisé et publié). Le changement est exécuté avec les droits de l'auteur, une seule fois, sur la version approuvée ; une demande échue ne s'applique plus ; en cas d'échec, la demande revient à son état. Droit : auteur de la demande";

-- ----------------------------------------------------------------------------
-- fn::secrets_request_get
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_request_get($params: object) {
    LET $l = fn::secrets_request_load($params, {});
    IF $l.error IS NOT NONE { RETURN $l.error; };
    RETURN fn::result_ok(fn::secrets_request_view($l.request.id));
} COMMENT "Une demande ({ request }) ; visible de son auteur et du gestionnaire des accès";

-- ----------------------------------------------------------------------------
-- fn::secrets_request_list
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_request_list($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }], required: true },
            state: { pipeline: [{ rule: "enum", options: { allowed: ["pending", "approved", "rejected", "cancelled", "expired", "applying", "applied"], case_sensitive: true } }] },
            kind: { pipeline: [{ rule: "enum", options: { allowed: ["access", "change"], case_sensitive: true } }] },
            mine: { pipeline: [{ rule: "boolean" }], default: false },
            limit: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 100 } }], default: 50 },
            start: { pipeline: [{ rule: "integer", options: { min_value: 0 } }], default: 0 },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("SECRETS_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $caller = fn::secrets_caller();
    -- Sans le droit de gérer les accès, les droits de la table ne montrent que ses demandes
    LET $ids = (SELECT VALUE id FROM secrets_request
        WHERE tenant = $p.tenant
            AND ($p.state IS NONE OR state = $p.state)
            AND ($p.kind IS NONE OR kind = $p.kind)
            AND (!$p.mine OR (requested_identity IS NOT NONE AND requested_identity = $caller.identity)
                OR (requested_identity IS NONE AND requested_application = $caller.application))
        ORDER BY created_at DESC);
    RETURN fn::result_ok({
        items: array::map(array::slice($ids, $p.start, $p.start + $p.limit), |$id| fn::secrets_request_view($id)),
        total: array::len($ids)
    });
} COMMENT "Demandes d'une organisation, les plus récentes d'abord ({ tenant, state, kind, mine, limit (100 au plus), start }) : { items, total }. Le gestionnaire des accès voit tout ; chacun voit les siennes";

-- ----------------------------------------------------------------------------
-- fn::secrets_access_due
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_access_due($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            limit: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 1000 } }], default: 100 },
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
    -- Demandes sans réponse : expirées (un changement approuvé non appliqué expire aussi)
    LET $expired = array::filter(array::map(
        (SELECT VALUE id FROM secrets_request WHERE state IN ["pending", "approved"] AND expires_at <= $now ORDER BY expires_at ASC LIMIT $p.limit),
        |$id| (UPDATE ONLY $id SET state = "expired", decided_at = $now WHERE state IN ["pending", "approved"] AND expires_at <= $now)),
        |$r| $r IS NOT NONE);
    -- Accès finis depuis plus de 30 jours : retirés (leur trace reste au journal)
    -- revoked_at IS NOT NONE : NONE se compare comme inférieur à toute date
    LET $removed = (DELETE secrets_grant WHERE expires_at <= $now - 30d OR (revoked_at IS NOT NONE AND revoked_at <= $now - 30d) RETURN BEFORE);
    RETURN fn::result_ok({ requests_expired: array::len($expired), grants_removed: array::len($removed) });
} COMMENT "Fait expirer les demandes sans réponse et retire les accès finis ou retirés depuis plus de 30 jours ({ limit (1000 au plus) }) : { requests_expired, grants_removed }. Droit : worker";

-- ----------------------------------------------------------------------------
-- fn::secrets_request_refusal (interne, garde)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_request_refusal($event: string, $before: option<object>, $after: object) -> option<string> {
    LET $system = fn::auth_session_valid({}).system;
    LET $caller = fn::secrets_caller();
    LET $actor = fn::secrets_actor();
    LET $by_requester = ($after.requested_identity IS NOT NONE AND $after.requested_identity = $caller.identity)
        OR ($after.requested_identity IS NONE AND $after.requested_application IS NOT NONE AND $after.requested_application = $caller.application);
    LET $manager = fn::secrets_can({ action: "access", tenant: $after.tenant });
    IF $event = "CREATE" {
        IF $after.state != "pending" OR array::len($after.approvals) > 0 OR $after.grant IS NOT NONE OR $after.emergency
            OR $after.decided_at IS NOT NONE OR $after.applied_at IS NOT NONE { RETURN "SECRETS_REQUEST_STATE_INVALID"; };
        IF ($after.kind = "access") != ($after.secret IS NONE) OR ($after.kind = "access" AND (array::len($after.actions) = 0 OR $after.duration IS NONE))
            OR ($after.kind = "change" AND $after.operation IS NONE) { RETURN "SECRETS_REQUEST_STATE_INVALID"; };
        IF $system { RETURN NONE; };
        IF !$by_requester { RETURN "SECRETS_PERMISSION_DENIED"; };
        -- Approbations requises : jamais moins que la protection du chemin (ni, pour un accès, que le réglage)
        LET $policy = fn::secrets_policy_for({ tenant: $after.tenant, path: $after.path, folder: $after.folder });
        LET $minimum = IF $after.kind = "access" { math::max([fn::secrets_settings_effective({ tenant: $after.tenant }).access_request_approvals, $policy.required_approvals]) } ELSE { $policy.required_approvals };
        RETURN IF $after.required_approvals < $minimum { "SECRETS_REQUEST_STATE_INVALID" } ELSE { NONE };
    };
    IF $before.state IN ["rejected", "cancelled", "expired", "applied"] { RETURN "SECRETS_REQUEST_STATE_INVALID"; };
    IF $system { RETURN NONE; };
    LET $approved = array::len($after.approvals) >= $after.required_approvals;
    -- Approbations : ajoutées une à une par un gestionnaire des accès qui n'est pas le demandeur
    IF $after.approvals != $before.approvals {
        IF !$manager OR $by_requester OR $before.state != "pending" { RETURN "SECRETS_PERMISSION_DENIED"; };
        IF array::len($after.approvals) != array::len($before.approvals) + 1 OR array::slice($after.approvals, 0, array::len($before.approvals)) != $before.approvals
            OR array::last($after.approvals).by != $actor OR $actor INSIDE $before.approvals.by { RETURN "SECRETS_REQUEST_STATE_INVALID"; };
    };
    -- Pendant l'application, seule la consommation de l'autorisation (garde d'écriture) change la demande
    IF $after.state = "applying" AND $before.state = "applying" {
        RETURN IF $by_requester AND $before.consumed_at IS NONE AND $after.consumed_at IS NOT NONE
            AND $after.number = $before.number AND $after.emergency = $before.emergency { NONE } ELSE { "SECRETS_REQUEST_STATE_INVALID" };
    };
    IF $after.consumed_at != $before.consumed_at { RETURN "SECRETS_REQUEST_STATE_INVALID"; };
    IF $after.state = $before.state { RETURN IF $after.state = "pending" AND $approved { "SECRETS_REQUEST_STATE_INVALID" } ELSE { NONE }; };
    LET $transition = $before.state + ">" + $after.state;
    RETURN IF $transition = "pending>approved" {
        IF $manager AND !$by_requester AND $approved { NONE } ELSE { "SECRETS_REQUEST_STATE_INVALID" }
    } ELSE IF $transition = "pending>rejected" {
        IF $manager AND !$by_requester { NONE } ELSE { "SECRETS_PERMISSION_DENIED" }
    } ELSE IF $transition IN ["pending>cancelled", "approved>cancelled"] {
        IF $by_requester AND ($after.kind = "change" OR $before.state = "pending") { NONE } ELSE { "SECRETS_PERMISSION_DENIED" }
    } ELSE IF $transition IN ["pending>expired", "approved>expired"] {
        IF fn::secrets_can({ action: "worker", tenant: $after.tenant }) AND $after.expires_at <= time::now() { NONE } ELSE { "SECRETS_PERMISSION_DENIED" }
    } ELSE IF $transition = "approved>applying" {
        IF !$by_requester OR $after.kind != "change" { "SECRETS_PERMISSION_DENIED" }
        ELSE IF $after.expires_at <= time::now() OR $after.consumed_at IS NOT NONE { "SECRETS_REQUEST_STATE_INVALID" } ELSE { NONE }
    } ELSE IF $transition = "pending>applying" {
        -- Urgence : droit d'urgence et, pour une personne, assurance la plus haute et récente
        IF !$by_requester OR $after.kind != "change" OR !$after.emergency OR !fn::secrets_can({ action: "emergency", tenant: $after.tenant }) { "SECRETS_PERMISSION_DENIED" }
        ELSE IF $after.expires_at <= time::now() OR $after.consumed_at IS NOT NONE OR $after.decision_reason IS NONE { "SECRETS_REQUEST_STATE_INVALID" }
        ELSE IF $caller.kind = "interactive" AND !fn::auth_assurance_check({ min_aal: "highest_available", fresh: true }).ok { "SECRETS_PERMISSION_DENIED" }
        ELSE { NONE }
    } ELSE IF $transition = "applying>applied" {
        IF $by_requester { NONE } ELSE { "SECRETS_PERMISSION_DENIED" }
    } ELSE IF $transition IN ["applying>approved", "applying>pending"] {
        -- Retour après un échec : seulement si aucun changement n'a été exécuté
        IF !$by_requester { "SECRETS_PERMISSION_DENIED" } ELSE IF $before.consumed_at IS NOT NONE { "SECRETS_REQUEST_STATE_INVALID" } ELSE { NONE }
    } ELSE { "SECRETS_REQUEST_STATE_INVALID" };
} COMMENT "Interne : refus d'une écriture de demande ($event, $before, $after) : création en attente par le demandeur, approbations requises jamais sous la protection du chemin ; approbations ajoutées une à une par un gestionnaire des accès autre que le demandeur ; transitions : approbation finale et refus (gestionnaire), annulation (demandeur), expiration (worker, échéance passée), application d'un changement non échu (demandeur ; avant approbation seulement en urgence avec le droit d'urgence, un motif et, pour une personne, l'assurance la plus haute et récente) ; pendant l'application, seule la consommation de l'autorisation change la demande, et le retour en arrière n'est permis que si rien n'a été exécuté ; demande close intouchable. NONE ou code d'erreur";
