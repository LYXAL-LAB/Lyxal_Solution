-- ============================================================================
-- FONCTIONS : versions et étiquettes
-- MODULE    : lyxal_secrets
-- ============================================================================
-- Une version porte une valeur scellée par le service Rust (lot 2) pour un numéro précis : le
-- numéro fait partie du contexte de scellement. Une écriture concurrente est donc refusée
-- (SECRETS_VERSION_CONFLICT) plutôt que d'en écraser une autre. Étiquettes : current (lue par
-- défaut), previous (posée quand current change), pending (rotation) et étiquettes libres.

-- ----------------------------------------------------------------------------
-- fn::secrets_version_create_refusal (interne, garde de création)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_version_create_refusal($after: object) -> option<string> {
    LET $secret = (SELECT tenant, state, latest_version FROM ONLY $after.secret);
    IF $secret == NONE { RETURN "SECRETS_SECRET_NOT_FOUND"; };
    IF $secret.state = "deleted" { RETURN "SECRETS_SECRET_DELETED"; };
    IF $after.tenant != $secret.tenant OR $after.state != "enabled" OR $after.envelope IS NONE
        OR $after.destroyed_at IS NOT NONE OR $after.resealed_at IS NOT NONE {
        RETURN "SECRETS_VERSION_STATE_INVALID";
    };
    IF $after.number != $secret.latest_version + 1 { RETURN "SECRETS_VERSION_CONFLICT"; };
    LET $caller = fn::secrets_caller();
    IF !$caller.system AND ($after.created_by != $caller.identity OR $after.created_by_application != $caller.application) {
        RETURN "SECRETS_PERMISSION_DENIED";
    };
    -- Scellée par la clé active de l'organisation : une clé retirée ou détruite entre-temps est refusée
    IF !fn::secrets_key_is_active($after.scope_key, $after.key_id) { RETURN "SECRETS_TENANT_KEY_CONFLICT"; };
    RETURN NONE;
} COMMENT "Interne : refus de création d'une version ($after) : secret existant et non supprimé, même organisation, version active avec enveloppe, numéro = dernière version + 1, auteur = appelant, scellée par la clé active de l'organisation. NONE ou code d'erreur";

-- ----------------------------------------------------------------------------
-- fn::secrets_version_update_refusal (interne, garde de modification)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_version_update_refusal($before: object, $after: object) -> option<string> {
    LET $system = fn::auth_session_valid({}).system;
    LET $tenant = $before.tenant;
    LET $secret = (SELECT labels, state FROM ONLY $before.secret);
    -- Auteur et noms de clés figés (sauf effacement de l'auteur par la suppression de son identité)
    LET $author_moved = ($before.created_by != $after.created_by AND !($after.created_by IS NONE AND $before.created_by IS NOT NONE AND !record::exists($before.created_by)))
        OR ($before.created_by_application != $after.created_by_application AND !($after.created_by_application IS NONE AND $before.created_by_application IS NOT NONE AND !record::exists($before.created_by_application)));
    IF $author_moved OR $before.keys != $after.keys { RETURN "SECRETS_PERMISSION_DENIED"; };
    -- Effacement de l'auteur par la suppression de son identité ou de son application : permis quel que soit l'état
    LET $sealed = ["state", "envelope", "key_id", "destroyed_at", "resealed_at"];
    IF array::all($sealed, |$f| $before[$f] = $after[$f]) { RETURN NONE; };
    IF $before.state = "destroyed" { RETURN "SECRETS_VERSION_STATE_INVALID"; };
    LET $sealed_changed = $before.envelope != $after.envelope OR $before.key_id != $after.key_id;
    -- Rescellement (même valeur) : permis aussi pour un secret supprimé, vers la clé active seulement
    IF ($sealed_changed OR $before.resealed_at != $after.resealed_at) AND $after.state = $before.state AND $after.envelope IS NOT NONE {
        IF !$system AND !fn::secrets_can({ action: "worker", tenant: $tenant }) { RETURN "SECRETS_PERMISSION_DENIED"; };
        IF $after.resealed_at IS NONE { RETURN "SECRETS_VERSION_STATE_INVALID"; };
        RETURN IF fn::secrets_key_is_active($before.scope_key, $after.key_id) { NONE } ELSE { "SECRETS_TENANT_KEY_CONFLICT" };
    };
    IF $secret.state = "deleted" { RETURN "SECRETS_SECRET_DELETED"; };
    IF $after.state = "destroyed" {
        IF $after.envelope IS NOT NONE OR $after.destroyed_at IS NONE { RETURN "SECRETS_VERSION_STATE_INVALID"; };
        IF $before.number INSIDE object::values($secret.labels) { RETURN "SECRETS_VERSION_LABELED"; };
        IF fn::secrets_can({ action: "delete", tenant: $tenant }) OR fn::secrets_can({ action: "worker", tenant: $tenant }) { RETURN NONE; };
        -- Conservation : un rédacteur détruit la plus ancienne version sans étiquette au-delà du nombre conservé
        LET $max = fn::secrets_settings_effective({ tenant: $tenant }).max_versions;
        LET $live = (SELECT VALUE number FROM secrets_version WHERE secret = $before.secret AND state != "destroyed");
        RETURN IF fn::secrets_can({ action: "write", tenant: $tenant }) AND array::len($live) >= $max { NONE } ELSE { "SECRETS_PERMISSION_DENIED" };
    };
    IF $before.destroyed_at != $after.destroyed_at { RETURN "SECRETS_VERSION_STATE_INVALID"; };
    IF $sealed_changed OR $before.resealed_at != $after.resealed_at {
        -- Rescellement après rotation de clé : session système ou worker, enveloppe et clé ensemble, état inchangé
        IF !$system AND !fn::secrets_can({ action: "worker", tenant: $tenant }) { RETURN "SECRETS_PERMISSION_DENIED"; };
        RETURN IF $after.envelope IS NONE OR $after.state != $before.state OR $after.resealed_at IS NONE { "SECRETS_VERSION_STATE_INVALID" } ELSE { NONE };
    };
    IF $before.state != $after.state AND !fn::secrets_can({ action: "write", tenant: $tenant }) { RETURN "SECRETS_PERMISSION_DENIED"; };
    RETURN NONE;
} COMMENT "Interne : refus d'une modification de version ($before, $after) : auteur et noms de clés figés ; version détruite intouchable ; destruction (enveloppe effacée) refusée sur une version étiquetée, permise à la suppression, au worker, ou au rédacteur au-delà du nombre de versions conservées ; enveloppe remplacée seulement par le rescellement de la session système ou du worker ; enabled ↔ disabled par l'écriture. NONE ou code d'erreur";

-- ----------------------------------------------------------------------------
-- fn::secrets_version_view (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_version_view($secret: record<secrets_secret>, $number: int) -> option<object> {
    RETURN (SELECT id, secret, number, state, key_id, keys, created_by, created_by_application, created_at, destroyed_at, resealed_at
        FROM ONLY secrets_version WHERE secret = $secret AND number = $number LIMIT 1);
} COMMENT "Interne : une version sans son enveloppe";

-- ----------------------------------------------------------------------------
-- fn::secrets_version_add
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_version_add($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            secret: { pipeline: [{ rule: "record", options: { expected_table: "secrets_secret" } }], required: true },
            number: { pipeline: [{ rule: "integer", options: { min_value: 1 } }], required: true },
            envelope: { pipeline: [{ rule: "required_string", options: { min_length: 8, max_length: 1398211 } }, { rule: "starts_with", options: { prefixes: ["enc:v2:"], case_sensitive: true, trim_value: false } }], required: true },
            key_id: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 64 } }], required: true },
            keys: { pipeline: [{ rule: "array_of_strings", options: { allow_empty: true } }, { rule: "array_length", options: { max_length: 200 } }, { rule: "each", options: { pipeline: [{ rule: "optional_string", options: { min_length: 1, max_length: 128 } }] } }] },
            stage: { pipeline: [{ rule: "enum", options: { allowed: ["current", "pending"], case_sensitive: true } }], default: "current" },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 60);
    IF !$report.valid {
        RETURN fn::error_result("SECRETS_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF string::split($p.envelope, ":")[2] != $p.key_id { RETURN fn::error_result("SECRETS_ENVELOPE_INVALID", $p.language, { key_id: $p.key_id }); };
    LET $secret = (SELECT * FROM ONLY $p.secret);
    IF $secret == NONE { RETURN fn::error_result("SECRETS_SECRET_NOT_FOUND", $p.language, { secret: <string> $p.secret }); };
    IF !fn::secrets_can({ action: "write", tenant: $secret.tenant }) { RETURN fn::error_result("SECRETS_PERMISSION_DENIED", $p.language, {}); };
    IF $secret.state = "deleted" { RETURN fn::error_result("SECRETS_SECRET_DELETED", $p.language, { secret: <string> $secret.id }); };
    IF $p.number != $secret.latest_version + 1 {
        RETURN fn::error_result("SECRETS_VERSION_CONFLICT", $p.language, { expected: $secret.latest_version + 1, number: $p.number });
    };
    IF !fn::secrets_key_is_active($secret.scope_key, $p.key_id) {
        RETURN fn::error_result("SECRETS_TENANT_KEY_CONFLICT", $p.language, { key_id: $p.key_id });
    };
    LET $caller = fn::secrets_caller();
    LET $inserted = (INSERT IGNORE INTO secrets_version {
        secret: $secret.id,
        tenant: $secret.tenant,
        number: $p.number,
        envelope: $p.envelope,
        key_id: $p.key_id,
        keys: $p.keys,
        created_by: $caller.identity,
        created_by_application: $caller.application
    });
    -- Index (secret, number) : une écriture concurrente a pris ce numéro
    IF array::len($inserted) = 0 {
        RETURN fn::error_result("SECRETS_VERSION_CONFLICT", $p.language, { expected: $secret.latest_version + 1, number: $p.number });
    };
    LET $labels = IF $p.stage = "pending" {
        object::extend($secret.labels, { pending: $p.number })
    } ELSE IF $secret.labels.current IS NONE {
        object::extend($secret.labels, { current: $p.number })
    } ELSE {
        object::extend($secret.labels, { current: $p.number, previous: $secret.labels.current })
    };
    LET $updated = (UPDATE ONLY $secret.id SET
        latest_version = $p.number,
        labels = $labels,
        next_rotation_at = IF $p.stage = "current" AND rotation_period IS NOT NONE { time::now() + rotation_period } ELSE { next_rotation_at });
    IF $updated == NONE { RETURN fn::error_result("SECRETS_WRITE_FORBIDDEN", $p.language, { table: "secrets_secret" }); };
    -- Conservation : au-delà du nombre de versions, les plus anciennes sans étiquette sont détruites
    LET $max = fn::secrets_settings_effective({ tenant: $secret.tenant }).max_versions;
    LET $live = (SELECT VALUE number FROM secrets_version WHERE secret = $secret.id AND state != "destroyed" ORDER BY number ASC);
    LET $excess = array::len($live) - $max;
    LET $labeled = object::values($labels);
    LET $doomed = IF $excess > 0 { array::slice(array::filter($live, |$n| $n NOTINSIDE $labeled), 0, $excess) } ELSE { [] };
    FOR $n IN $doomed {
        UPDATE secrets_version SET state = "destroyed", envelope = NONE, key_id = NONE, destroyed_at = time::now()
            WHERE secret = $secret.id AND number = $n;
    };
    RETURN fn::result_ok({
        version: fn::secrets_version_view($secret.id, $p.number),
        labels: $labels,
        destroyed: $doomed
    });
} COMMENT "Ajoute une version scellée ({ secret, number (suivant attendu), envelope (enc:v2:<key_id>:…), key_id, keys (noms des clés d'une valeur JSON), stage : current (défaut, l'ancienne current devient previous) ou pending }). Numéro différent du suivant : SECRETS_VERSION_CONFLICT ; clé qui n'est plus la clé active de l'organisation : SECRETS_TENANT_KEY_CONFLICT (le service relit et rescelle). Au-delà du nombre de versions conservées, les plus anciennes sans étiquette sont détruites. Appelée par le service Rust, qui seul scelle. Droit : écriture";

-- ----------------------------------------------------------------------------
-- fn::secrets_version_list
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_version_list($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            secret: { pipeline: [{ rule: "record", options: { expected_table: "secrets_secret" } }], required: true },
            state: { pipeline: [{ rule: "enum", options: { allowed: ["enabled", "disabled", "destroyed"], case_sensitive: true } }] },
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
    LET $secret = (SELECT id, tenant FROM ONLY $p.secret);
    IF $secret == NONE { RETURN fn::error_result("SECRETS_SECRET_NOT_FOUND", $p.language, { secret: <string> $p.secret }); };
    IF !fn::secrets_can({ action: "list", tenant: $secret.tenant }) { RETURN fn::error_result("SECRETS_PERMISSION_DENIED", $p.language, {}); };
    LET $all = (SELECT number, state, key_id, keys, created_by, created_by_application, created_at, destroyed_at, resealed_at
        FROM secrets_version WHERE secret = $secret.id AND ($p.state IS NONE OR state = $p.state) ORDER BY number DESC);
    RETURN fn::result_ok({ items: array::slice($all, $p.start, $p.start + $p.limit), total: array::len($all) });
} COMMENT "Versions d'un secret, les plus récentes d'abord ({ secret, state, limit (100 au plus), start }), sans enveloppe : { items, total }. Droit : liste";

-- ----------------------------------------------------------------------------
-- fn::secrets_version_label
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_version_label($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            secret: { pipeline: [{ rule: "record", options: { expected_table: "secrets_secret" } }], required: true },
            label: { pipeline: [{ rule: "slug", options: { max_length: 32 } }], required: true },
            number: { pipeline: [{ rule: "integer", options: { min_value: 1 } }] },
            remove: { pipeline: [{ rule: "boolean" }], default: false },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid OR ($params.remove != true AND $params.number IS NONE) {
        RETURN fn::error_result("SECRETS_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field ?? { number: { code: "CORE_VALIDATION_REQUIRED" } } });
    };
    LET $p = $report.value;
    LET $secret = (SELECT * FROM ONLY $p.secret);
    IF $secret == NONE { RETURN fn::error_result("SECRETS_SECRET_NOT_FOUND", $p.language, { secret: <string> $p.secret }); };
    IF !fn::secrets_can({ action: "write", tenant: $secret.tenant }) { RETURN fn::error_result("SECRETS_PERMISSION_DENIED", $p.language, {}); };
    IF $secret.state = "deleted" { RETURN fn::error_result("SECRETS_SECRET_DELETED", $p.language, { secret: <string> $secret.id }); };
    LET $labels = IF $p.remove {
        IF $p.label = "current" OR $secret.labels[$p.label] IS NONE { NONE } ELSE { object::remove($secret.labels, $p.label) }
    } ELSE {
        LET $version = fn::secrets_version_view($secret.id, $p.number);
        IF $version == NONE OR $version.state = "destroyed" { NONE }
        ELSE IF $p.label = "current" AND $secret.labels.current IS NOT NONE AND $secret.labels.current != $p.number {
            object::extend($secret.labels, { current: $p.number, previous: $secret.labels.current })
        } ELSE { object::extend($secret.labels, object::from_entries([[$p.label, $p.number]])) }
    };
    IF $labels IS NONE {
        LET $code = IF $p.remove { "SECRETS_LABEL_INVALID" } ELSE { "SECRETS_VERSION_NOT_FOUND" };
        RETURN fn::error_result($code, $p.language, { label: $p.label, number: $p.number });
    };
    IF array::len(object::keys($labels)) > 20 { RETURN fn::error_result("SECRETS_LABEL_INVALID", $p.language, { label: $p.label, max_labels: 20 }); };
    LET $updated = (UPDATE ONLY $secret.id SET labels = $labels);
    IF $updated == NONE { RETURN fn::error_result("SECRETS_WRITE_FORBIDDEN", $p.language, { table: "secrets_secret" }); };
    RETURN fn::result_ok({ labels: $updated.labels });
} COMMENT "Pose une étiquette sur une version non détruite, ou la retire ({ secret, label, number, remove }). Déplacer current pose previous sur l'ancienne current (retour arrière : current sur une version antérieure). current ne se retire pas ; 20 étiquettes au plus. Droit : écriture";

-- ----------------------------------------------------------------------------
-- fn::secrets_version_state (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_version_state($params: object, $to: string) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            secret: { pipeline: [{ rule: "record", options: { expected_table: "secrets_secret" } }], required: true },
            number: { pipeline: [{ rule: "integer", options: { min_value: 1 } }], required: true },
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
    LET $action = IF $to = "destroyed" { "delete" } ELSE { "write" };
    IF !fn::secrets_can({ action: $action, tenant: $secret.tenant }) { RETURN fn::error_result("SECRETS_PERMISSION_DENIED", $p.language, {}); };
    IF $secret.state = "deleted" { RETURN fn::error_result("SECRETS_SECRET_DELETED", $p.language, { secret: <string> $secret.id }); };
    LET $version = fn::secrets_version_view($secret.id, $p.number);
    IF $version == NONE { RETURN fn::error_result("SECRETS_VERSION_NOT_FOUND", $p.language, { number: $p.number }); };
    LET $from = { enabled: ["disabled"], disabled: ["enabled"], destroyed: ["enabled", "disabled"] }[$to];
    IF $version.state NOTINSIDE $from { RETURN fn::error_result("SECRETS_VERSION_STATE_INVALID", $p.language, { state: $version.state }); };
    IF $to = "destroyed" AND $p.number INSIDE object::values($secret.labels) {
        RETURN fn::error_result("SECRETS_VERSION_LABELED", $p.language, { number: $p.number, labels: $secret.labels });
    };
    LET $updated = IF $to = "destroyed" {
        (UPDATE ONLY $version.id SET state = "destroyed", envelope = NONE, key_id = NONE, destroyed_at = time::now())
    } ELSE {
        (UPDATE ONLY $version.id SET state = $to)
    };
    IF $updated == NONE { RETURN fn::error_result("SECRETS_WRITE_FORBIDDEN", $p.language, { table: "secrets_version" }); };
    RETURN fn::result_ok(fn::secrets_version_view($secret.id, $p.number));
} COMMENT "Interne : changement d'état d'une version ($params : { secret, number } ; $to : enabled, disabled, destroyed)";

-- ----------------------------------------------------------------------------
-- fn::secrets_version_disable, _enable, _destroy
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_version_disable($params: object) {
    RETURN fn::secrets_version_state($params, "disabled");
} COMMENT "Désactive une version ({ secret, number }) : sa lecture est refusée, réversible. Désactiver la version courante coupe toute lecture par défaut (geste d'incident). Droit : écriture";

DEFINE FUNCTION OVERWRITE fn::secrets_version_enable($params: object) {
    RETURN fn::secrets_version_state($params, "enabled");
} COMMENT "Réactive une version désactivée ({ secret, number }). Droit : écriture";

DEFINE FUNCTION OVERWRITE fn::secrets_version_destroy($params: object) {
    RETURN fn::secrets_version_state($params, "destroyed");
} COMMENT "Détruit une version ({ secret, number }) : enveloppe effacée, irréversible ; refusé sur une version étiquetée (SECRETS_VERSION_LABELED : déplacer l'étiquette d'abord). Droit : suppression";

-- ----------------------------------------------------------------------------
-- fn::secrets_version_reseal
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_version_reseal($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            secret: { pipeline: [{ rule: "record", options: { expected_table: "secrets_secret" } }], required: true },
            number: { pipeline: [{ rule: "integer", options: { min_value: 1 } }], required: true },
            expected_key_id: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 64 } }], required: true },
            envelope: { pipeline: [{ rule: "required_string", options: { min_length: 8, max_length: 1398211 } }, { rule: "starts_with", options: { prefixes: ["enc:v2:"], case_sensitive: true, trim_value: false } }], required: true },
            key_id: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 64 } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid {
        RETURN fn::error_result("SECRETS_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF string::split($p.envelope, ":")[2] != $p.key_id { RETURN fn::error_result("SECRETS_ENVELOPE_INVALID", $p.language, { key_id: $p.key_id }); };
    LET $secret = (SELECT id, tenant, state FROM ONLY $p.secret);
    IF $secret == NONE { RETURN fn::error_result("SECRETS_SECRET_NOT_FOUND", $p.language, { secret: <string> $p.secret }); };
    IF !fn::auth_session_valid({}).system AND !fn::secrets_can({ action: "worker", tenant: $secret.tenant }) {
        RETURN fn::error_result("SECRETS_PERMISSION_DENIED", $p.language, {});
    };
    LET $version = fn::secrets_version_view($secret.id, $p.number);
    IF $version == NONE { RETURN fn::error_result("SECRETS_VERSION_NOT_FOUND", $p.language, { number: $p.number }); };
    IF $version.state = "destroyed" { RETURN fn::error_result("SECRETS_VERSION_STATE_INVALID", $p.language, { state: $version.state }); };
    -- Rescellement concurrent : une autre clé a déjà été posée
    IF $version.key_id != $p.expected_key_id {
        RETURN fn::error_result("SECRETS_VERSION_CONFLICT", $p.language, { key_id: $version.key_id, expected_key_id: $p.expected_key_id });
    };
    IF !fn::secrets_key_is_active((SELECT VALUE scope_key FROM ONLY $secret.id), $p.key_id) {
        RETURN fn::error_result("SECRETS_TENANT_KEY_CONFLICT", $p.language, { key_id: $p.key_id });
    };
    LET $updated = (UPDATE ONLY $version.id SET envelope = $p.envelope, key_id = $p.key_id, resealed_at = time::now() WHERE key_id = $p.expected_key_id);
    IF $updated == NONE { RETURN fn::error_result("SECRETS_VERSION_CONFLICT", $p.language, { expected_key_id: $p.expected_key_id }); };
    RETURN fn::result_ok({ resealed: true, number: $p.number, key_id: $p.key_id });
} COMMENT "Rescelle une version après une rotation de clé ({ secret, number, expected_key_id, envelope, key_id }) : enveloppe et identifiant de clé remplacés ensemble, même valeur et même contexte ; refusé si la clé n'est plus celle attendue (SECRETS_VERSION_CONFLICT), si la nouvelle clé n'est pas la clé active de l'organisation (SECRETS_TENANT_KEY_CONFLICT) ou si la version est détruite ; permis pour un secret supprimé (la valeur ne change pas). Session système ou worker seulement";
