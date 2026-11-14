-- ============================================================================
-- FONCTIONS : accès temporaires, accès d'urgence, protections
-- MODULE    : lyxal_secrets
-- ============================================================================
-- Un accès (secrets_grant) donne un droit en plus de ceux de lyxal_auth, pour un chemin, des
-- opérations et une durée ; il ne vaut que dans une session de son organisation (contrôle par
-- fn::secrets_grant_covers). Une protection (secrets_policy) soumet des changements d'un chemin
-- à une demande approuvée (secrets_request_*).

-- ----------------------------------------------------------------------------
-- fn::secrets_actor (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_actor() -> option<string> {
    LET $caller = fn::secrets_caller();
    RETURN IF $caller.identity IS NOT NONE { <string> $caller.identity } ELSE IF $caller.application IS NOT NONE { <string> $caller.application } ELSE { NONE };
} COMMENT "Interne : identité ou application de l'appelant sous forme de chaîne (NONE : session système)";

-- ----------------------------------------------------------------------------
-- fn::secrets_policy_for (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_policy_for($params: object) -> object {
    -- Protections qui couvrent le chemin ; pour un dossier demandé, aussi celles posées dessous
    LET $found = (SELECT required_approvals, operations, max_grant_duration FROM secrets_policy
        WHERE tenant = $params.tenant
            AND (path = $params.path OR (folder AND string::starts_with($params.path, path + "/"))
                OR ($params.folder = true AND string::starts_with(path, $params.path + "/"))));
    IF array::len($found) = 0 { RETURN { protected: false, required_approvals: 0, operations: [], max_grant_duration: NONE }; };
    LET $limits = array::filter($found.max_grant_duration, |$d| $d IS NOT NONE);
    RETURN {
        protected: true,
        required_approvals: math::max($found.required_approvals),
        operations: array::distinct(array::flatten($found.operations)),
        max_grant_duration: IF array::len($limits) = 0 { NONE } ELSE { array::sort($limits)[0] }
    };
} COMMENT "Interne : protection effective d'un chemin ({ tenant, path, folder }) : la plus exigeante de celles qui le couvrent (approbations les plus nombreuses, opérations réunies, durée d'accès la plus courte) : { protected, required_approvals, operations, max_grant_duration }";

-- ----------------------------------------------------------------------------
-- fn::secrets_change_refusal (interne, gardes)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_change_refusal($params: object) -> option<string> {
    IF $params.tenant IS NONE { RETURN NONE; };
    -- Session système et worker (rotation automatique) : non soumis
    IF fn::secrets_can({ action: "worker", tenant: $params.tenant }) { RETURN NONE; };
    LET $policy = fn::secrets_policy_for({ tenant: $params.tenant, path: $params.path });
    IF $params.operation NOTINSIDE $policy.operations { RETURN NONE; };
    -- Application d'une demande approuvée (ou d'urgence) de cette opération sur ce secret
    LET $applying = (SELECT VALUE id FROM secrets_request
        WHERE secret = $params.secret AND state = "applying" AND operation = $params.operation LIMIT 1);
    RETURN IF array::len($applying) > 0 { NONE } ELSE { "SECRETS_APPROVAL_REQUIRED" };
} COMMENT "Interne : refus d'une opération protégée ({ tenant, path, secret, operation : value, rollback, disable, delete, destroy }) hors de l'application d'une demande approuvée ; la session système et le worker ne sont pas soumis. NONE ou SECRETS_APPROVAL_REQUIRED";

-- ----------------------------------------------------------------------------
-- fn::secrets_change_open (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_change_open($secret: record<secrets_secret>) -> bool {
    RETURN array::len(SELECT VALUE id FROM secrets_request WHERE secret = $secret AND kind = "change" AND state IN ["pending", "approved"] LIMIT 1) > 0;
} COMMENT "Interne : vrai si une demande de changement attend une décision ou son application sur le secret (sa version proposée est alors figée)";

-- ----------------------------------------------------------------------------
-- fn::secrets_grant_view (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_grant_view($id: record<secrets_grant>) -> option<object> {
    LET $g = (SELECT * FROM ONLY $id);
    IF $g == NONE { RETURN NONE; };
    LET $now = time::now();
    RETURN object::extend($g, { active: $g.revoked_at IS NONE AND $g.starts_at <= $now AND $g.expires_at > $now });
} COMMENT "Interne : un accès et son état en cours (active)";

-- ----------------------------------------------------------------------------
-- fn::secrets_grant_insert (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_grant_insert($grant: object) -> option<record<secrets_grant>> {
    LET $created = (CREATE ONLY secrets_grant CONTENT $grant);
    RETURN $created.id;
} COMMENT "Interne : crée un accès (contenu déjà validé) et renvoie son identifiant (NONE si la création est filtrée par les droits)";

-- ----------------------------------------------------------------------------
-- fn::secrets_grant_duration (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_grant_duration($params: object) -> object {
    LET $settings = fn::secrets_settings_effective({ tenant: $params.tenant });
    LET $policy = fn::secrets_policy_for({ tenant: $params.tenant, path: $params.path, folder: $params.folder });
    -- Durées : array::sort (math::min ne prend pas de durées en 3.3.4)
    LET $max = IF $policy.max_grant_duration IS NONE { $settings.grant_max_duration } ELSE { array::sort([$policy.max_grant_duration, $settings.grant_max_duration])[0] };
    LET $duration = $params.duration ?? array::sort([$settings.grant_default_duration, $max])[0];
    RETURN { duration: $duration, max: $max, valid: $duration <= $max, policy: $policy };
} COMMENT "Interne : durée d'un accès ({ tenant, path, folder, duration }) : demandée, sinon celle des réglages ; bornée par les réglages et la protection du chemin : { duration, max, valid, policy }";

-- ----------------------------------------------------------------------------
-- fn::secrets_grant_create
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_grant_create($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }], required: true },
            identity: { pipeline: [{ rule: "record", options: { expected_table: "auth_identity" } }] },
            application: { pipeline: [{ rule: "record", options: { expected_table: "auth_application" } }] },
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
    IF !fn::secrets_can({ action: "access", tenant: $p.tenant }) { RETURN fn::error_result("SECRETS_PERMISSION_DENIED", $p.language, {}); };
    -- Un seul bénéficiaire : une identité ou une application
    IF ($p.identity IS NONE) = ($p.application IS NONE) {
        RETURN fn::error_result("SECRETS_GRANT_INVALID", $p.language, { reason: "subject" });
    };
    LET $d = fn::secrets_grant_duration({ tenant: $p.tenant, path: $p.path, folder: $p.folder, duration: $p.duration });
    IF !$d.valid { RETURN fn::error_result("SECRETS_GRANT_INVALID", $p.language, { reason: "duration", max_duration: $d.max }); };
    LET $now = time::now();
    LET $id = fn::secrets_grant_insert({
        tenant: $p.tenant,
        subject_identity: $p.identity,
        subject_application: $p.application,
        path: $p.path,
        folder: $p.folder,
        actions: array::distinct($p.actions),
        starts_at: $now,
        expires_at: $now + $d.duration,
        reason: $p.reason,
        granted_by: fn::secrets_actor()
    });
    IF $id IS NONE { RETURN fn::error_result("SECRETS_WRITE_FORBIDDEN", $p.language, { table: "secrets_grant" }); };
    RETURN fn::result_ok(fn::secrets_grant_view($id));
} COMMENT "Accorde un accès temporaire ({ tenant, identity ou application, path, folder (dossier : couvre <path>/…), actions (list, read_value, write, delete), duration (défaut et maximum : réglages et protection du chemin), reason }). L'accès ne vaut que dans une session de l'organisation. Droit : secrets.access.manage";

-- ----------------------------------------------------------------------------
-- fn::secrets_grant_revoke
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_grant_revoke($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            grant: { pipeline: [{ rule: "record", options: { expected_table: "secrets_grant" } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("SECRETS_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $g = (SELECT id, tenant, revoked_at FROM ONLY $p.grant);
    IF $g == NONE { RETURN fn::error_result("SECRETS_GRANT_NOT_FOUND", $p.language, { grant: <string> $p.grant }); };
    IF !fn::secrets_can({ action: "access", tenant: $g.tenant }) { RETURN fn::error_result("SECRETS_PERMISSION_DENIED", $p.language, {}); };
    IF $g.revoked_at IS NOT NONE { RETURN fn::error_result("SECRETS_GRANT_INVALID", $p.language, { reason: "revoked" }); };
    LET $updated = (UPDATE ONLY $g.id SET revoked_at = time::now(), revoked_by = fn::secrets_actor() WHERE revoked_at IS NONE);
    IF $updated == NONE { RETURN fn::error_result("SECRETS_WRITE_FORBIDDEN", $p.language, { table: "secrets_grant" }); };
    RETURN fn::result_ok(fn::secrets_grant_view($g.id));
} COMMENT "Retire un accès tout de suite ({ grant }). Droit : secrets.access.manage";

-- ----------------------------------------------------------------------------
-- fn::secrets_grant_list
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_grant_list($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }], required: true },
            identity: { pipeline: [{ rule: "record", options: { expected_table: "auth_identity" } }] },
            application: { pipeline: [{ rule: "record", options: { expected_table: "auth_application" } }] },
            active_only: { pipeline: [{ rule: "boolean" }], default: true },
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
    LET $now = time::now();
    -- Sans le droit de gérer les accès, les droits de la table ne montrent que les siens
    LET $ids = (SELECT VALUE id FROM secrets_grant
        WHERE tenant = $p.tenant
            AND ($p.identity IS NONE OR subject_identity = $p.identity)
            AND ($p.application IS NONE OR subject_application = $p.application)
            AND (!$p.active_only OR (revoked_at IS NONE AND expires_at > $now))
        ORDER BY created_at DESC);
    RETURN fn::result_ok({
        items: array::map(array::slice($ids, $p.start, $p.start + $p.limit), |$id| fn::secrets_grant_view($id)),
        total: array::len($ids)
    });
} COMMENT "Accès d'une organisation, les plus récents d'abord ({ tenant, identity, application, active_only (défaut vrai), limit (100 au plus), start }) : { items, total }. Le gestionnaire des accès voit tout ; chacun voit les siens";

-- ----------------------------------------------------------------------------
-- fn::secrets_access_emergency
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_access_emergency($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }], required: true },
            path: { pipeline: [{ rule: "lyxal_storage_path", options: { allow_file_extension: true, max_length: 256 } }], required: true },
            folder: { pipeline: [{ rule: "boolean" }], default: false },
            actions: { pipeline: [{ rule: "array_of_strings", options: { allow_empty: false } }, { rule: "array_length", options: { max_length: 4 } }, { rule: "each", options: { pipeline: [{ rule: "enum", options: { allowed: ["list", "read_value", "write", "delete"], case_sensitive: true } }] } }], required: true },
            duration: { pipeline: [{ rule: "duration", options: { min_value: 5m, max_value: 1h } }], default: 1h },
            reason: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 512 } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid {
        RETURN fn::error_result("SECRETS_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::secrets_can({ action: "emergency", tenant: $p.tenant }) { RETURN fn::error_result("SECRETS_PERMISSION_DENIED", $p.language, {}); };
    LET $caller = fn::secrets_caller();
    IF $caller.system OR ($caller.identity IS NONE AND $caller.application IS NONE) { RETURN fn::error_result("SECRETS_GRANT_INVALID", $p.language, { reason: "subject" }); };
    -- Une personne : niveau d'assurance le plus haut et récent
    IF $caller.kind = "interactive" {
        LET $assurance = fn::auth_assurance_check({ min_aal: "highest_available", fresh: true });
        IF !$assurance.ok { RETURN fn::error_result($assurance.error.code, $p.language, $assurance.error.details ?? {}); };
    };
    LET $now = time::now();
    LET $id = fn::secrets_grant_insert({
        tenant: $p.tenant,
        subject_identity: $caller.identity,
        subject_application: IF $caller.identity IS NONE { $caller.application } ELSE { NONE },
        path: $p.path,
        folder: $p.folder,
        actions: array::distinct($p.actions),
        starts_at: $now,
        expires_at: $now + $p.duration,
        reason: $p.reason,
        granted_by: fn::secrets_actor(),
        emergency: true
    });
    IF $id IS NONE { RETURN fn::error_result("SECRETS_WRITE_FORBIDDEN", $p.language, { table: "secrets_grant" }); };
    RETURN fn::result_ok(fn::secrets_grant_view($id));
} COMMENT "Accès d'urgence que l'appelant s'accorde lui-même, sans approbation ({ tenant, path, folder, actions, duration (1 h au plus, défaut 1 h), reason }) : journalisé (access.emergency) et publié (secrets.access.emergency) pour prévenir les responsables. Droit : secrets.access.emergency ; une personne doit avoir l'assurance la plus haute et récente";

-- ----------------------------------------------------------------------------
-- fn::secrets_policy_set
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_policy_set($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }], required: true },
            path: { pipeline: [{ rule: "lyxal_storage_path", options: { allow_file_extension: true, max_length: 256 } }], required: true },
            folder: { pipeline: [{ rule: "boolean" }], default: false },
            required_approvals: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 5 } }], default: 1 },
            operations: { pipeline: [{ rule: "array_of_strings", options: { allow_empty: true } }, { rule: "array_length", options: { max_length: 5 } }, { rule: "each", options: { pipeline: [{ rule: "enum", options: { allowed: ["value", "rollback", "disable", "delete", "destroy"], case_sensitive: true } }] } }], default: ["value", "rollback", "disable", "delete", "destroy"] },
            max_grant_duration: { pipeline: [{ rule: "duration", options: { min_value: 5m, max_value: 90d } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid {
        RETURN fn::error_result("SECRETS_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::secrets_can({ action: "access", tenant: $p.tenant }) { RETURN fn::error_result("SECRETS_PERMISSION_DENIED", $p.language, {}); };
    LET $existing = (SELECT VALUE id FROM ONLY secrets_policy WHERE tenant = $p.tenant AND path = $p.path AND folder = $p.folder LIMIT 1);
    LET $values = {
        required_approvals: $p.required_approvals,
        operations: array::distinct($p.operations),
        max_grant_duration: $p.max_grant_duration,
        updated_by: fn::secrets_actor()
    };
    LET $saved = IF $existing IS NONE {
        (CREATE ONLY secrets_policy CONTENT object::extend($values, { tenant: $p.tenant, path: $p.path, folder: $p.folder }))
    } ELSE {
        (UPDATE ONLY $existing SET required_approvals = $values.required_approvals, operations = $values.operations,
            max_grant_duration = $values.max_grant_duration, updated_by = $values.updated_by)
    };
    IF $saved == NONE { RETURN fn::error_result("SECRETS_WRITE_FORBIDDEN", $p.language, { table: "secrets_policy" }); };
    RETURN fn::result_ok($saved);
} COMMENT "Pose ou remplace la protection d'un secret ou d'un dossier ({ tenant, path, folder, required_approvals (1 à 5, défaut 1), operations (value, rollback, disable, delete, destroy ; défaut : toutes), max_grant_duration }) : les opérations protégées passent par une demande de changement approuvée. Droit : secrets.access.manage";

-- ----------------------------------------------------------------------------
-- fn::secrets_policy_delete
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_policy_delete($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            policy: { pipeline: [{ rule: "record", options: { expected_table: "secrets_policy" } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("SECRETS_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $policy = (SELECT id, tenant FROM ONLY $p.policy);
    IF $policy == NONE { RETURN fn::error_result("SECRETS_POLICY_NOT_FOUND", $p.language, { policy: <string> $p.policy }); };
    IF !fn::secrets_can({ action: "access", tenant: $policy.tenant }) { RETURN fn::error_result("SECRETS_PERMISSION_DENIED", $p.language, {}); };
    LET $deleted = (DELETE ONLY $policy.id RETURN BEFORE);
    IF $deleted == NONE { RETURN fn::error_result("SECRETS_WRITE_FORBIDDEN", $p.language, { table: "secrets_policy" }); };
    RETURN fn::result_ok({ deleted: true, path: $deleted.path, folder: $deleted.folder });
} COMMENT "Retire une protection ({ policy }). Droit : secrets.access.manage";

-- ----------------------------------------------------------------------------
-- fn::secrets_policy_list
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_policy_list($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }], required: true },
            path: { pipeline: [{ rule: "lyxal_storage_path", options: { allow_file_extension: true, max_length: 256 } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("SECRETS_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $items = (SELECT * FROM secrets_policy WHERE tenant = $p.tenant ORDER BY path ASC);
    RETURN fn::result_ok({
        items: $items,
        effective: IF $p.path IS NONE { NONE } ELSE { fn::secrets_policy_for({ tenant: $p.tenant, path: $p.path }) }
    });
} COMMENT "Protections d'une organisation ({ tenant, path }) : { items, effective (protection effective du chemin donné) }. Visibles des membres de l'organisation";

-- ----------------------------------------------------------------------------
-- fn::secrets_grant_refusal (interne, garde)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_grant_refusal($event: string, $before: option<object>, $after: object) -> option<string> {
    IF $event = "CREATE" {
        IF ($after.subject_identity IS NONE) = ($after.subject_application IS NONE) OR $after.expires_at <= $after.starts_at
            OR $after.revoked_at IS NOT NONE OR $after.starts_at > time::now() + 1m {
            RETURN "SECRETS_GRANT_INVALID";
        };
        IF fn::auth_session_valid({}).system { RETURN NONE; };
        -- Urgence : pour soi, une heure au plus
        IF $after.emergency {
            LET $caller = fn::secrets_caller();
            IF ($after.subject_identity IS NOT NONE AND $after.subject_identity != $caller.identity)
                OR ($after.subject_application IS NOT NONE AND ($caller.identity IS NOT NONE OR $after.subject_application != $caller.application)) {
                RETURN "SECRETS_PERMISSION_DENIED";
            };
            RETURN IF $after.expires_at - $after.starts_at > 1h { "SECRETS_GRANT_INVALID" } ELSE { NONE };
        };
        -- Durée bornée par les réglages et la protection du chemin
        LET $d = fn::secrets_grant_duration({ tenant: $after.tenant, path: $after.path, folder: $after.folder, duration: $after.expires_at - $after.starts_at });
        RETURN IF $d.valid { NONE } ELSE { "SECRETS_GRANT_INVALID" };
    };
    -- Seul le retrait change un accès, une seule fois
    IF $before.revoked_at IS NOT NONE OR $after.revoked_at IS NONE { RETURN "SECRETS_GRANT_INVALID"; };
    RETURN NONE;
} COMMENT "Interne : refus d'une écriture d'accès ($event, $before, $after) : un seul bénéficiaire, fin après le début, durée bornée (urgence : pour soi, 1 h au plus) ; seul le retrait modifie un accès, une fois. NONE ou code d'erreur";
