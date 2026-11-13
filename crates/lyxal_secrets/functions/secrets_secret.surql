-- ============================================================================
-- FONCTIONS : fiches de secrets
-- MODULE    : lyxal_secrets
-- ============================================================================
-- Une fiche ne contient jamais de valeur. États : active ↔ disabled ; active ou disabled →
-- deleted (suppression douce) → état d'avant (restauration) ou purge. Les gardes
-- (fn::secrets_secret_create_refusal, _update_refusal, _delete_refusal) valent aussi pour une
-- écriture directe dans la table.

-- ----------------------------------------------------------------------------
-- fn::secrets_secret_create_refusal (interne, garde de création)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_secret_create_refusal($after: object) -> option<string> {
    LET $caller = fn::secrets_caller();
    IF $after.state != "active" OR $after.latest_version != 0 OR array::len(object::keys($after.labels)) > 0
        OR $after.deleted_at IS NOT NONE OR $after.purge_at IS NOT NONE OR $after.state_before_delete IS NOT NONE {
        RETURN "SECRETS_SECRET_STATE_INVALID";
    };
    -- Propriétaire : l'appelant lui-même (la session système peut le fixer)
    IF !$caller.system AND ($after.owner != $caller.identity OR $after.owner_application != $caller.application) {
        RETURN "SECRETS_PERMISSION_DENIED";
    };
    RETURN NONE;
} COMMENT "Interne : refus de création d'une fiche ($after) : état initial imposé (active, sans version ni étiquette) ; propriétaire = appelant hors session système. NONE ou code d'erreur";

-- ----------------------------------------------------------------------------
-- fn::secrets_secret_update_refusal (interne, garde de modification)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_secret_update_refusal($before: object, $after: object) -> option<string> {
    LET $system = fn::auth_session_valid({}).system;
    LET $tenant = $before.tenant;
    -- Propriétaire figé, sauf effacement par la suppression de l'identité ou de l'application
    LET $owner_moved = ($before.owner != $after.owner AND !($after.owner IS NONE AND $before.owner IS NOT NONE AND !record::exists($before.owner)))
        OR ($before.owner_application != $after.owner_application AND !($after.owner_application IS NONE AND $before.owner_application IS NOT NONE AND !record::exists($before.owner_application)));
    IF $owner_moved AND !$system { RETURN "SECRETS_PERMISSION_DENIED"; };
    LET $meta = ["kind", "description", "contact", "consumers", "tags", "metadata", "visibility", "expires_at", "rotation_period", "next_rotation_at"];
    LET $meta_changed = array::any($meta, |$f| $before[$f] != $after[$f]);
    LET $versions_changed = $before.labels != $after.labels OR $before.latest_version != $after.latest_version;
    LET $deletion_changed = $before.deleted_at != $after.deleted_at OR $before.purge_at != $after.purge_at OR $before.state_before_delete != $after.state_before_delete;
    IF $before.state = $after.state {
        IF $before.state = "deleted" AND ($meta_changed OR $versions_changed OR ($deletion_changed AND !$system)) { RETURN "SECRETS_SECRET_DELETED"; };
        IF $deletion_changed AND !$system { RETURN "SECRETS_SECRET_STATE_INVALID"; };
        IF ($meta_changed OR $versions_changed) AND !fn::secrets_can({ action: "write", tenant: $tenant }) { RETURN "SECRETS_PERMISSION_DENIED"; };
        IF $versions_changed {
            -- Dernière version : la suivante seulement, et elle doit exister
            IF $after.latest_version != $before.latest_version AND ($after.latest_version != $before.latest_version + 1
                OR (SELECT VALUE id FROM ONLY secrets_version WHERE secret = $before.id AND number = $after.latest_version LIMIT 1) IS NONE) {
                RETURN "SECRETS_VERSION_CONFLICT";
            };
            -- Étiquettes : sur des versions existantes et non détruites ; current ne disparaît pas
            IF $before.labels.current IS NOT NONE AND $after.labels.current IS NONE { RETURN "SECRETS_LABEL_INVALID"; };
            LET $targets = array::distinct(object::values($after.labels));
            LET $live = (SELECT VALUE number FROM secrets_version WHERE secret = $before.id AND number IN $targets AND state != "destroyed");
            IF array::len($live) != array::len($targets) { RETURN "SECRETS_LABEL_INVALID"; };
        };
        RETURN NONE;
    };
    IF $meta_changed OR $versions_changed { RETURN "SECRETS_SECRET_STATE_INVALID"; };
    LET $allowed = { active: ["disabled", "deleted"], disabled: ["active", "deleted"], deleted: ["active", "disabled"] }[$before.state];
    IF $after.state NOTINSIDE $allowed { RETURN "SECRETS_SECRET_STATE_INVALID"; };
    IF $after.state = "deleted" {
        IF !fn::secrets_can({ action: "delete", tenant: $tenant }) { RETURN "SECRETS_PERMISSION_DENIED"; };
        RETURN IF $after.deleted_at IS NONE OR $after.purge_at IS NONE OR $after.state_before_delete != $before.state { "SECRETS_SECRET_STATE_INVALID" } ELSE { NONE };
    };
    IF $before.state = "deleted" {
        IF !fn::secrets_can({ action: "restore", tenant: $tenant }) { RETURN "SECRETS_PERMISSION_DENIED"; };
        RETURN IF $after.state != $before.state_before_delete OR $after.deleted_at IS NOT NONE OR $after.purge_at IS NOT NONE OR $after.state_before_delete IS NOT NONE { "SECRETS_SECRET_STATE_INVALID" } ELSE { NONE };
    };
    IF $deletion_changed { RETURN "SECRETS_SECRET_STATE_INVALID"; };
    RETURN IF fn::secrets_can({ action: "write", tenant: $tenant }) { NONE } ELSE { "SECRETS_PERMISSION_DENIED" };
} COMMENT "Interne : refus d'une modification de fiche ($before, $after) : propriétaire figé ; fiche supprimée intouchable (la session système peut seulement avancer ou reculer sa date de purge) ; transitions active ↔ disabled (écriture), → deleted (suppression, date de purge posée), deleted → état d'avant (restauration) ; dernière version : la suivante, existante ; étiquettes sur des versions non détruites. NONE ou code d'erreur";

-- ----------------------------------------------------------------------------
-- fn::secrets_secret_delete_refusal (interne, garde de purge)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_secret_delete_refusal($before: object) -> option<string> {
    -- Suppression de l'organisation : ses secrets partent avec elle
    IF $before.tenant IS NOT NONE AND !record::exists($before.tenant) { RETURN NONE; };
    IF $before.state != "deleted" { RETURN "SECRETS_SECRET_STATE_INVALID"; };
    IF $before.purge_at > time::now() {
        IF !fn::secrets_can({ action: "purge", tenant: $before.tenant }) { RETURN "SECRETS_PERMISSION_DENIED"; };
        IF fn::secrets_settings_effective({ tenant: $before.tenant }).purge_protection { RETURN "SECRETS_PURGE_PROTECTED"; };
    };
    RETURN NONE;
} COMMENT "Interne : refus d'une purge ($before) : seul un secret supprimé se purge ; avant la date de purge, permission de purge et pas de protection contre la purge (même pour la session système). La suppression d'une organisation emporte ses secrets. NONE ou code d'erreur";

-- ----------------------------------------------------------------------------
-- fn::secrets_secret_view (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_secret_view($id: record<secrets_secret>) -> option<object> {
    LET $secret = (SELECT * FROM ONLY $id);
    IF $secret == NONE { RETURN NONE; };
    RETURN object::extend($secret, {
        versions: (SELECT number, state, key_id, keys, created_at, destroyed_at, resealed_at FROM secrets_version
            WHERE secret = $id ORDER BY number DESC LIMIT 100)
    });
} COMMENT "Interne : fiche et ses 100 dernières versions (numéro, état, clé, noms des clés, dates), jamais d'enveloppe";

-- ----------------------------------------------------------------------------
-- fn::secrets_secret_create
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_secret_create($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            path: { pipeline: [{ rule: "lyxal_storage_path", options: { allow_file_extension: true, max_length: 256 } }], required: true },
            kind: { pipeline: [{ rule: "enum", options: { allowed: ["api_key", "password", "token", "oauth_client", "certificate", "private_key", "signing_key", "connection_string", "generic"], case_sensitive: true } }], required: true },
            description: { pipeline: [{ rule: "optional_string", options: { max_length: 1024 } }] },
            contact: { pipeline: [{ rule: "optional_string", options: { max_length: 254 } }] },
            consumers: { pipeline: [{ rule: "array_of_strings", options: { allow_empty: true } }, { rule: "array_length", options: { max_length: 20 } }, { rule: "each", options: { pipeline: [{ rule: "optional_string", options: { min_length: 1, max_length: 128 } }] } }], default: [] },
            tags: { pipeline: [{ rule: "array_of_strings", options: { allow_empty: true } }, { rule: "array_length", options: { max_length: 20 } }, { rule: "each", options: { pipeline: [{ rule: "slug", options: { max_length: 64 } }] } }], default: [] },
            metadata: { pipeline: [{ rule: "is_object" }], default: {} },
            visibility: { pipeline: [{ rule: "enum", options: { allowed: ["restricted", "revealable"], case_sensitive: true } }] },
            expires_at: { pipeline: [{ rule: "future_datetime", options: { allow_equal: false } }] },
            rotation_period: { pipeline: [{ rule: "duration", options: { min_value: 1h, max_value: 3650d } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 60);
    IF !$report.valid {
        RETURN fn::error_result("SECRETS_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::validation_array_length(object::keys($p.metadata), NONE, 32).valid {
        RETURN fn::error_result("SECRETS_INVALID_PARAMETERS", $p.language, { fields: { metadata: { code: "CORE_VALIDATION_TOO_LONG", details: { max_length: 32 } } } });
    };
    IF !fn::secrets_can({ action: "write", tenant: $p.tenant }) { RETURN fn::error_result("SECRETS_PERMISSION_DENIED", $p.language, {}); };
    LET $caller = fn::secrets_caller();
    LET $inserted = (INSERT IGNORE INTO secrets_secret {
        tenant: $p.tenant,
        path: $p.path,
        kind: $p.kind,
        description: $p.description,
        owner: $caller.identity,
        owner_application: $caller.application,
        contact: $p.contact,
        consumers: array::distinct($p.consumers),
        tags: array::distinct($p.tags),
        metadata: $p.metadata,
        visibility: $p.visibility ?? fn::secrets_settings_effective({ tenant: $p.tenant }).default_visibility,
        expires_at: $p.expires_at,
        rotation_period: $p.rotation_period
    });
    IF array::len($inserted) = 0 { RETURN fn::error_result("SECRETS_SECRET_EXISTS", $p.language, { path: $p.path }); };
    RETURN fn::result_ok(fn::secrets_secret_view($inserted[0].id));
} COMMENT "Crée la fiche d'un secret, sans valeur ({ path, kind, tenant, description, contact, consumers, tags, metadata, visibility, expires_at, rotation_period }) ; chemin unique dans sa portée (SECRETS_SECRET_EXISTS) ; visibilité par défaut : celle des réglages. La valeur s'ajoute par fn::secrets_version_add. Droit : écriture";

-- ----------------------------------------------------------------------------
-- fn::secrets_secret_update
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_secret_update($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            secret: { pipeline: [{ rule: "record", options: { expected_table: "secrets_secret" } }], required: true },
            kind: { pipeline: [{ rule: "enum", options: { allowed: ["api_key", "password", "token", "oauth_client", "certificate", "private_key", "signing_key", "connection_string", "generic"], case_sensitive: true } }] },
            description: { pipeline: [{ rule: "optional_string", options: { max_length: 1024 } }] },
            contact: { pipeline: [{ rule: "optional_string", options: { max_length: 254 } }] },
            consumers: { pipeline: [{ rule: "array_of_strings", options: { allow_empty: true } }, { rule: "array_length", options: { max_length: 20 } }, { rule: "each", options: { pipeline: [{ rule: "optional_string", options: { min_length: 1, max_length: 128 } }] } }] },
            tags: { pipeline: [{ rule: "array_of_strings", options: { allow_empty: true } }, { rule: "array_length", options: { max_length: 20 } }, { rule: "each", options: { pipeline: [{ rule: "slug", options: { max_length: 64 } }] } }] },
            metadata: { pipeline: [{ rule: "is_object" }] },
            visibility: { pipeline: [{ rule: "enum", options: { allowed: ["restricted", "revealable"], case_sensitive: true } }] },
            expires_at: { pipeline: [{ rule: "future_datetime", options: { allow_equal: false } }] },
            rotation_period: { pipeline: [{ rule: "duration", options: { min_value: 1h, max_value: 3650d } }] },
            clear: { pipeline: [{ rule: "array_of_strings", options: { allow_empty: true } }, { rule: "each", options: { pipeline: [{ rule: "enum", options: { allowed: ["description", "contact", "expires_at", "rotation_period"], case_sensitive: true } }] } }], default: [] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 60);
    IF !$report.valid {
        RETURN fn::error_result("SECRETS_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF $p.metadata IS NOT NONE AND !fn::validation_array_length(object::keys($p.metadata), NONE, 32).valid {
        RETURN fn::error_result("SECRETS_INVALID_PARAMETERS", $p.language, { fields: { metadata: { code: "CORE_VALIDATION_TOO_LONG", details: { max_length: 32 } } } });
    };
    LET $secret = (SELECT * FROM ONLY $p.secret);
    IF $secret == NONE { RETURN fn::error_result("SECRETS_SECRET_NOT_FOUND", $p.language, { secret: <string> $p.secret }); };
    IF !fn::secrets_can({ action: "write", tenant: $secret.tenant }) { RETURN fn::error_result("SECRETS_PERMISSION_DENIED", $p.language, {}); };
    IF $secret.state = "deleted" { RETURN fn::error_result("SECRETS_SECRET_DELETED", $p.language, { secret: <string> $secret.id }); };
    LET $period = IF "rotation_period" IN $p.clear { NONE } ELSE { $p.rotation_period ?? $secret.rotation_period };
    -- Prochaine rotation : date de la version courante (sinon maintenant) plus la période
    LET $current_at = IF $secret.labels.current IS NONE { NONE } ELSE {
        (SELECT VALUE created_at FROM ONLY secrets_version WHERE secret = $secret.id AND number = $secret.labels.current LIMIT 1)
    };
    LET $updated = (UPDATE ONLY $secret.id SET
        kind = $p.kind ?? kind,
        description = IF "description" IN $p.clear { NONE } ELSE { $p.description ?? description },
        contact = IF "contact" IN $p.clear { NONE } ELSE { $p.contact ?? contact },
        consumers = IF $p.consumers IS NONE { consumers } ELSE { array::distinct($p.consumers) },
        tags = IF $p.tags IS NONE { tags } ELSE { array::distinct($p.tags) },
        metadata = $p.metadata ?? metadata,
        visibility = $p.visibility ?? visibility,
        expires_at = IF "expires_at" IN $p.clear { NONE } ELSE { $p.expires_at ?? expires_at },
        rotation_period = $period,
        next_rotation_at = IF $period IS NONE OR $secret.labels.current IS NONE { NONE } ELSE { ($current_at ?? time::now()) + $period });
    IF $updated == NONE { RETURN fn::error_result("SECRETS_WRITE_FORBIDDEN", $p.language, { table: "secrets_secret" }); };
    RETURN fn::result_ok(fn::secrets_secret_view($secret.id));
} COMMENT "Modifie la fiche d'un secret ({ secret, kind, description, contact, consumers, tags, metadata, visibility, expires_at, rotation_period, clear }) : un champ absent est conservé, clear (description, contact, expires_at, rotation_period) efface ; le chemin ne change pas ; prochaine rotation recalculée. Fiche supprimée : SECRETS_SECRET_DELETED. Droit : écriture";

-- ----------------------------------------------------------------------------
-- fn::secrets_secret_get
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_secret_get($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            secret: { pipeline: [{ rule: "record", options: { expected_table: "secrets_secret" } }] },
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            path: { pipeline: [{ rule: "lyxal_storage_path", options: { allow_file_extension: true, max_length: 256 } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid OR ($params.secret IS NONE AND $params.path IS NONE) {
        RETURN fn::error_result("SECRETS_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field ?? {} });
    };
    LET $p = $report.value;
    LET $scope = IF $p.tenant IS NONE { "installation" } ELSE { <string> record::id($p.tenant) };
    LET $id = $p.secret ?? (SELECT VALUE id FROM ONLY secrets_secret WHERE scope_key = $scope AND path = $p.path LIMIT 1);
    LET $view = IF $id IS NONE { NONE } ELSE { fn::secrets_secret_view($id) };
    IF $view == NONE { RETURN fn::error_result("SECRETS_SECRET_NOT_FOUND", $p.language, { secret: IF $p.secret IS NONE { NONE } ELSE { <string> $p.secret }, path: $p.path }); };
    RETURN fn::result_ok($view);
} COMMENT "Fiche d'un secret et ses 100 dernières versions, sans valeur ({ secret } ou { tenant, path }). Droit : liste (ou lecture de valeur)";

-- ----------------------------------------------------------------------------
-- fn::secrets_secret_list
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_secret_list($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            prefix: { pipeline: [{ rule: "lyxal_storage_path", options: { allow_file_extension: true, max_length: 256 } }] },
            state: { pipeline: [{ rule: "enum", options: { allowed: ["active", "disabled", "deleted"], case_sensitive: true } }] },
            tag: { pipeline: [{ rule: "slug", options: { max_length: 64 } }] },
            limit: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 100 } }], default: 50 },
            start: { pipeline: [{ rule: "integer", options: { min_value: 0 } }], default: 0 },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid {
        RETURN fn::error_result("SECRETS_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::secrets_can({ action: "list", tenant: $p.tenant }) { RETURN fn::error_result("SECRETS_PERMISSION_DENIED", $p.language, {}); };
    LET $scope = IF $p.tenant IS NONE { "installation" } ELSE { <string> record::id($p.tenant) };
    -- Par défaut, les secrets supprimés sont exclus ; un préfixe désigne un chemin et tout ce qu'il contient
    LET $all = (SELECT * FROM secrets_secret
        WHERE scope_key = $scope
            AND (IF $p.state IS NONE { state != "deleted" } ELSE { state = $p.state })
            AND ($p.prefix IS NONE OR path = $p.prefix OR string::starts_with(path, $p.prefix + "/"))
            AND ($p.tag IS NONE OR $p.tag IN tags)
        ORDER BY path ASC);
    RETURN fn::result_ok({ items: array::slice($all, $p.start, $p.start + $p.limit), total: array::len($all) });
} COMMENT "Fiches d'une portée ({ tenant, prefix, state, tag, limit (100 au plus), start }), triées par chemin, sans valeur : { items, total }. Sans state, les secrets supprimés sont exclus. Droit : liste";

-- ----------------------------------------------------------------------------
-- fn::secrets_secret_transition (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_secret_transition($params: object, $to: string) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            secret: { pipeline: [{ rule: "record", options: { expected_table: "secrets_secret" } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("SECRETS_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $secret = (SELECT * FROM ONLY $p.secret);
    IF $secret == NONE { RETURN fn::error_result("SECRETS_SECRET_NOT_FOUND", $p.language, { secret: <string> $p.secret }); };
    LET $action = { disable: "write", enable: "write", delete: "delete", restore: "restore" }[$to];
    IF !fn::secrets_can({ action: $action, tenant: $secret.tenant }) { RETURN fn::error_result("SECRETS_PERMISSION_DENIED", $p.language, {}); };
    LET $from = { disable: ["active"], enable: ["disabled"], delete: ["active", "disabled"], restore: ["deleted"] }[$to];
    IF $secret.state NOTINSIDE $from {
        RETURN fn::error_result(IF $secret.state = "deleted" { "SECRETS_SECRET_DELETED" } ELSE { "SECRETS_SECRET_STATE_INVALID" }, $p.language, { state: $secret.state });
    };
    LET $updated = IF $to = "disable" {
        (UPDATE ONLY $secret.id SET state = "disabled")
    } ELSE IF $to = "enable" {
        (UPDATE ONLY $secret.id SET state = "active")
    } ELSE IF $to = "delete" {
        LET $days = fn::secrets_settings_effective({ tenant: $secret.tenant }).deleted_retention_days;
        (UPDATE ONLY $secret.id SET state = "deleted", state_before_delete = $secret.state, deleted_at = time::now(), purge_at = time::now() + duration::from_days($days))
    } ELSE {
        (UPDATE ONLY $secret.id SET state = $secret.state_before_delete ?? "active", state_before_delete = NONE, deleted_at = NONE, purge_at = NONE)
    };
    IF $updated == NONE { RETURN fn::error_result("SECRETS_WRITE_FORBIDDEN", $p.language, { table: "secrets_secret" }); };
    RETURN fn::result_ok(fn::secrets_secret_view($secret.id));
} COMMENT "Interne : changement d'état d'une fiche ($params : { secret } ; $to : disable, enable, delete, restore) avec contrôle des droits et des états de départ";

-- ----------------------------------------------------------------------------
-- fn::secrets_secret_disable, _enable, _delete, _restore
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_secret_disable($params: object) {
    RETURN fn::secrets_secret_transition($params, "disable");
} COMMENT "Désactive un secret actif ({ secret }) : toute lecture de valeur est refusée (geste immédiat en cas d'incident), réversible par fn::secrets_secret_enable. Droit : écriture";

DEFINE FUNCTION OVERWRITE fn::secrets_secret_enable($params: object) {
    RETURN fn::secrets_secret_transition($params, "enable");
} COMMENT "Réactive un secret désactivé ({ secret }). Droit : écriture";

DEFINE FUNCTION OVERWRITE fn::secrets_secret_delete($params: object) {
    RETURN fn::secrets_secret_transition($params, "delete");
} COMMENT "Supprime un secret (suppression douce, { secret }) : plus aucune lecture ; purge à la date posée (réglage deleted_retention_days, 30 jours par défaut) ; restaurable d'ici là. Droit : suppression";

DEFINE FUNCTION OVERWRITE fn::secrets_secret_restore($params: object) {
    RETURN fn::secrets_secret_transition($params, "restore");
} COMMENT "Restaure un secret supprimé dans son état d'avant ({ secret }). Droit : restauration";

-- ----------------------------------------------------------------------------
-- fn::secrets_secret_purge
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_secret_purge($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            secret: { pipeline: [{ rule: "record", options: { expected_table: "secrets_secret" } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("SECRETS_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $secret = (SELECT * FROM ONLY $p.secret);
    IF $secret == NONE { RETURN fn::error_result("SECRETS_SECRET_NOT_FOUND", $p.language, { secret: <string> $p.secret }); };
    IF !fn::secrets_can({ action: "purge", tenant: $secret.tenant }) { RETURN fn::error_result("SECRETS_PERMISSION_DENIED", $p.language, {}); };
    -- Mêmes règles que la garde secrets_secret_delete_guard (qui, elle, voit aussi la suppression d'une organisation)
    IF $secret.state != "deleted" { RETURN fn::error_result("SECRETS_SECRET_STATE_INVALID", $p.language, { state: $secret.state }); };
    IF $secret.purge_at > time::now() AND fn::secrets_settings_effective({ tenant: $secret.tenant }).purge_protection {
        RETURN fn::error_result("SECRETS_PURGE_PROTECTED", $p.language, { purge_at: $secret.purge_at });
    };
    LET $deleted = (DELETE ONLY $secret.id RETURN BEFORE);
    IF $deleted == NONE { RETURN fn::error_result("SECRETS_WRITE_FORBIDDEN", $p.language, { table: "secrets_secret" }); };
    RETURN fn::result_ok({ purged: true, secret: <string> $secret.id, path: $secret.path });
} COMMENT "Purge un secret supprimé avant sa date de purge ({ secret }) : fiche et versions effacées définitivement. Refusé si l'organisation ou l'installation a activé la protection contre la purge (SECRETS_PURGE_PROTECTED). Droit : purge";
