-- ============================================================================
-- FONCTIONS : fil de notifications dans l'application (canal in_app, décisions F1 à F8)
-- MODULE    : lyxal_notification
-- ============================================================================
-- Le fil d'une personne est celui de son abonné auth:<identité> dans son organisation active
-- (l'installation sans organisation active) : seule sa session lyxal_auth le lit et le modifie
-- (décision F2, fn::notification_can action self, appliquée aussi par les PERMISSIONS de
-- notification_inbox). Un message d'une autre personne, ou absent, reçoit la même réponse
-- (NOTIFICATION_FEED_ITEM_NOT_FOUND). Un message en sommeil est caché jusqu'à sa fin, puis de
-- nouveau visible, non lu (calculé à la lecture, sans worker de réveil). Les compteurs sont
-- calculés à la demande. Le message est écrit par le worker du canal in_app
-- (fn::notification_inbox_deliver), qui contrôle à nouveau les liens rendus.

-- ----------------------------------------------------------------------------
-- fn::notification_link_valid (interne) : lien du fil (avatar, redirection, bouton)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_link_valid($params: object) -> bool {
    IF !type::is_string($params.value) { RETURN false; };
    -- Gabarit : la partie fixe, avant la première variable ou instruction MiniJinja
    LET $value = IF $params.template = true { string::split(string::split($params.value, "{{")[0], "{%")[0] } ELSE { $params.value };
    IF $value = "" { RETURN false; };
    -- Aucun caractère de contrôle (un navigateur retire tabulations et retours à la ligne)
    IF fn::sanitize_remove_control_chars($value, false) != $value { RETURN false; };
    IF fn::validation_http_url($value, false, true).valid { RETURN true; };
    -- Chemin de l'application : « /… », jamais « // » ni « /\ » ni un schéma
    RETURN fn::sanitize_safe_redirect($value, "/") == $value AND !fn::security_detect_open_redirect($value).detected;
} COMMENT "Interne : lien du fil ({ value, template }) acceptable : adresse HTTPS (fn::validation_http_url) ou chemin de l'application commençant par « / » (fn::sanitize_safe_redirect, sans « // » ni « /\\ », fn::security_detect_open_redirect), sans caractère de contrôle ; javascript:, data: et tout autre schéma refusés. template : seule la partie fixe d'un gabarit, avant la première variable, est contrôlée (le lien rendu l'est à la livraison)";

-- ----------------------------------------------------------------------------
-- fn::notification_feed_scope (interne) : fil de la personne connectée
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_feed_scope($params: object) -> object {
    LET $context = fn::auth_context({});
    IF !$context.ok OR $context.data.identity IS NONE { RETURN { code: "NOTIFICATION_FEED_NO_ACCOUNT" }; };
    LET $tenant = $context.data.organization;
    LET $subscriber = fn::notification_subscriber_find({ tenant: $tenant, subscriber_id: string::concat("auth:", <string> record::id($context.data.identity)) });
    IF $subscriber IS NONE OR $subscriber.identity != $context.data.identity { RETURN { code: "NOTIFICATION_FEED_NO_ACCOUNT" }; };
    RETURN { code: NONE, identity: $context.data.identity, tenant: $tenant, subscriber: $subscriber.id };
} COMMENT "Interne : fil de la personne connectée : son abonné auth:<identité> lié à son compte, dans son organisation active (l'installation sans organisation active). { code (NOTIFICATION_FEED_NO_ACCOUNT : session sans compte ou sans abonné), identity, tenant, subscriber }";

-- ----------------------------------------------------------------------------
-- fn::notification_feed_filter_fields (interne) : filtres d'onglet (décision F5)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_feed_filter_fields($params: object) -> object {
    RETURN { pipeline: [{ rule: "is_object" }, { rule: "object", options: { schema: {
        fields: {
            tags: { pipeline: [{ rule: "array_of_strings", options: { allow_empty: true } }, { rule: "array_length", options: { max_length: 20 } }, { rule: "each", options: { pipeline: [{ rule: "snake_case_name", options: { min_length: 1, max_length: 64 } }] } }] },
            severity: { pipeline: [{ rule: "array_of_strings", options: { allow_empty: true } }, { rule: "array_unique" }, { rule: "each", options: { pipeline: [{ rule: "enum", options: { allowed: ["high", "medium", "low", "none"], case_sensitive: true } }] } }] },
            data: { pipeline: [{ rule: "object_values_type", options: { expected_type: "string", allow_empty: true, max_length: 256 } }] },
            archived: { pipeline: [{ rule: "boolean" }], default: false },
            read: { pipeline: [{ rule: "boolean" }] }
        },
        unknown_keys: "reject"
    } } }], default: {} };
} COMMENT "Interne : schéma lyxal_core du filtre d'un onglet : { tags : une étiquette au moins en commun, severity : gravités, data : { clé : valeur } toutes égales, archived (faux par défaut : messages non archivés), read : lus ou non lus }";

-- ----------------------------------------------------------------------------
-- fn::notification_feed_match (interne) : message visible dans un onglet
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_feed_match($params: object) -> bool {
    LET $item = $params.item;
    LET $f = $params.filter ?? {};
    RETURN ($item.snoozed_until IS NONE OR $item.snoozed_until <= $params.now)
        AND (IF $f.archived = true { $item.archived_at IS NOT NONE } ELSE { $item.archived_at IS NONE })
        AND ($f.read IS NONE OR $f.read = ($item.read_at IS NOT NONE))
        AND (array::len($f.tags ?? []) = 0 OR array::len(array::intersect($item.tags, $f.tags)) > 0)
        AND (array::len($f.severity ?? []) = 0 OR $item.severity IN $f.severity)
        AND ($f.data IS NONE OR array::all(object::entries($f.data), |$e| $item.data[$e[0]] = $e[1]));
} COMMENT "Interne : vrai si le message ({ item, filter, now }) est visible (pas en sommeil à now) et remplit le filtre d'onglet (archivé ou non, lu, étiquettes, gravité, données)";

-- ----------------------------------------------------------------------------
-- fn::notification_feed_view (interne) : message tel que la personne le voit
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_feed_view($item: object) -> object {
    RETURN {
        id: $item.id,
        workflow: $item.workflow_key,
        step_key: $item.step_key,
        title: $item.title,
        text: $item.text,
        avatar: $item.avatar,
        redirect: $item.redirect,
        actions: array::map($item.actions ?? [], |$a| { kind: $a.kind, label: $a.label, url: $a.url, status: $item.action_status[$a.kind] ?? "pending" }),
        data: $item.data ?? {},
        tags: $item.tags ?? [],
        severity: $item.severity,
        seen: $item.seen_at IS NOT NONE,
        read: $item.read_at IS NOT NONE,
        archived: $item.archived_at IS NOT NONE,
        seen_at: $item.seen_at,
        read_at: $item.read_at,
        archived_at: $item.archived_at,
        snoozed_until: $item.snoozed_until,
        created_at: $item.created_at
    };
} COMMENT "Interne : vue d'un message du fil : { id, workflow, step_key, title, text, avatar, redirect, actions : [{ kind, label, url, status }], data, tags, severity, seen, read, archived, seen_at, read_at, archived_at, snoozed_until, created_at } (ni abonné, ni compte, ni déclenchement)";

-- ----------------------------------------------------------------------------
-- fn::notification_feed_mine (interne) : messages désignés de la personne
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_feed_mine($params: object) -> array {
    RETURN IF $params.all = true {
        (SELECT VALUE id FROM notification_inbox WHERE subscriber = $params.subscriber
            AND fn::notification_feed_match({ item: $this, filter: $params.filter, now: $params.now }))
    } ELSE {
        (SELECT VALUE id FROM notification_inbox WHERE subscriber = $params.subscriber AND id IN $params.ids)
    };
} COMMENT "Interne : identifiants des messages de l'abonné ({ subscriber, ids, all, filter, now }) : ceux de la liste ids, ou tous ceux du filtre d'onglet (all)";

-- ----------------------------------------------------------------------------
-- fn::notification_feed_targets (interne) : contrôle commun d'une action sur des messages
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_feed_targets($params: object) -> object {
    IF ($params.ids IS NONE) = ($params.all != true) {
        RETURN { code: "NOTIFICATION_INVALID_INPUT", details: { fields: { ids: ["CORE_VALIDATION_REQUIRED"], all: ["CORE_VALIDATION_REQUIRED"] } } };
    };
    LET $scope = fn::notification_feed_scope({});
    IF $scope.code IS NOT NONE { RETURN { code: $scope.code, details: {} }; };
    LET $ids = array::distinct($params.ids ?? []);
    LET $found = fn::notification_feed_mine({ subscriber: $scope.subscriber, ids: $ids, all: $params.all, filter: $params.filter, now: time::now() });
    -- Message absent ou d'une autre personne : même réponse
    IF $params.all != true AND array::len($found) < array::len($ids) {
        RETURN { code: "NOTIFICATION_FEED_ITEM_NOT_FOUND", details: {} };
    };
    RETURN { code: NONE, details: {}, scope: $scope, ids: $found };
} COMMENT "Interne : messages visés par une action de la personne ({ ids ou all, filter }) : { code (NOTIFICATION_INVALID_INPUT sans ids ni all ou avec les deux, NOTIFICATION_FEED_NO_ACCOUNT, NOTIFICATION_FEED_ITEM_NOT_FOUND si un identifiant n'est pas un de ses messages), details, scope, ids }";

-- ----------------------------------------------------------------------------
-- fn::notification_feed_list
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_feed_list($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            filter: fn::notification_feed_filter_fields({}),
            cursor: { pipeline: [{ rule: "record", options: { expected_table: "notification_inbox" } }] },
            limit: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 100 } }], default: 20 },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $scope = fn::notification_feed_scope({});
    IF $scope.code IS NOT NONE { RETURN fn::error_result($scope.code, $p.language, {}); };
    LET $now = time::now();
    -- Identifiants croissants dans le temps (UUID v7) : le curseur est le dernier message reçu
    LET $rows = IF $p.cursor IS NONE {
        (SELECT * FROM notification_inbox WHERE subscriber = $scope.subscriber
            AND fn::notification_feed_match({ item: $this, filter: $p.filter, now: $now })
            ORDER BY id DESC LIMIT $p.limit + 1)
    } ELSE {
        (SELECT * FROM notification_inbox WHERE subscriber = $scope.subscriber AND id < $p.cursor
            AND fn::notification_feed_match({ item: $this, filter: $p.filter, now: $now })
            ORDER BY id DESC LIMIT $p.limit + 1)
    };
    LET $page = array::slice($rows, 0, $p.limit);
    RETURN fn::result_ok({
        items: array::map($page, |$item| fn::notification_feed_view($item)),
        next_cursor: IF array::len($rows) > $p.limit { $page[array::len($page) - 1].id } ELSE { NONE }
    });
} COMMENT "Fil de la personne connectée ({ filter : onglet { tags, severity, data, archived, read }, cursor : dernier message reçu, limit : 1 à 100, 20 par défaut }), du plus récent au plus ancien, sans les messages en sommeil : { items, next_cursor }. Session lyxal_auth de la personne (NOTIFICATION_FEED_NO_ACCOUNT sans compte ou sans abonné)";

-- ----------------------------------------------------------------------------
-- fn::notification_feed_counts
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_feed_counts($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            filter: fn::notification_feed_filter_fields({}),
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 30);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $scope = fn::notification_feed_scope({});
    IF $scope.code IS NOT NONE { RETURN fn::error_result($scope.code, $p.language, {}); };
    LET $now = time::now();
    LET $rows = (SELECT seen_at, read_at FROM notification_inbox WHERE subscriber = $scope.subscriber
        AND fn::notification_feed_match({ item: $this, filter: $p.filter, now: $now }));
    RETURN fn::result_ok({
        unseen: array::len(array::filter($rows, |$r| $r.seen_at IS NONE)),
        unread: array::len(array::filter($rows, |$r| $r.read_at IS NONE)),
        total: array::len($rows)
    });
} COMMENT "Compteurs du fil de la personne connectée pour un onglet ({ filter }), calculés à la demande (rien n'est stocké) : { unseen, unread, total } ; un message en sommeil n'est compté qu'à sa fin. Session lyxal_auth de la personne";

-- ----------------------------------------------------------------------------
-- fn::notification_feed_mark
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_feed_mark($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            ids: { pipeline: [{ rule: "array_length", options: { min_length: 1, max_length: 100 } }, { rule: "each", options: { pipeline: [{ rule: "record", options: { expected_table: "notification_inbox" } }] } }] },
            all: { pipeline: [{ rule: "boolean" }] },
            filter: fn::notification_feed_filter_fields({}),
            state: { pipeline: [{ rule: "enum", options: { allowed: ["seen", "read", "unread", "archived", "unarchived"], case_sensitive: true } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $targets = fn::notification_feed_targets({ ids: $p.ids, all: $p.all, filter: $p.filter });
    IF $targets.code IS NOT NONE { RETURN fn::error_result($targets.code, $p.language, $targets.details); };
    LET $ids = $targets.ids;
    LET $now = time::now();
    LET $updated = IF array::len($ids) = 0 { [] }
        ELSE IF $p.state = "seen" { (UPDATE $ids SET seen_at = seen_at ?? $now RETURN id) }
        ELSE IF $p.state = "read" { (UPDATE $ids SET seen_at = seen_at ?? $now, read_at = read_at ?? $now RETURN id) }
        ELSE IF $p.state = "unread" { (UPDATE $ids SET read_at = NONE RETURN id) }
        ELSE IF $p.state = "archived" { (UPDATE $ids SET archived_at = archived_at ?? $now RETURN id) }
        ELSE { (UPDATE $ids SET archived_at = NONE RETURN id) };
    IF array::len($updated) < array::len($ids) { RETURN fn::error_result("NOTIFICATION_WRITE_FORBIDDEN", $p.language, { table: "notification_inbox" }); };
    RETURN fn::result_ok({ state: $p.state, updated: array::len($updated) });
} COMMENT "Change l'état de messages du fil de la personne connectée ({ ids : 100 au plus, ou all avec filter d'onglet ; state : seen, read (vu aussi), unread, archived, unarchived }) ; actions groupées : tout marquer vu, tout marquer lu, archiver tous les lus (filter { read : true }). Un message absent ou d'une autre personne : NOTIFICATION_FEED_ITEM_NOT_FOUND. Renvoie { state, updated }. Session lyxal_auth de la personne";

-- ----------------------------------------------------------------------------
-- fn::notification_feed_snooze
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_feed_snooze($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            id: { pipeline: [{ rule: "record", options: { expected_table: "notification_inbox" } }], required: true },
            until: { pipeline: [{ rule: "datetime" }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    -- Sommeil de 3 minutes à 90 jours (décision F4)
    LET $bounds = fn::validation_future_datetime($p.until, NONE, false, 3m, 90d);
    IF !$bounds.valid { RETURN fn::error_result("NOTIFICATION_SNOOZE_INVALID", $p.language, { fields: { until: [$bounds.code] } }); };
    LET $targets = fn::notification_feed_targets({ ids: [$p.id] });
    IF $targets.code IS NOT NONE { RETURN fn::error_result($targets.code, $p.language, $targets.details); };
    -- À son réveil, le message réapparaît comme non vu et non lu
    LET $updated = (UPDATE ONLY $p.id SET snoozed_until = $p.until, seen_at = NONE, read_at = NONE);
    IF $updated == NONE { RETURN fn::error_result("NOTIFICATION_WRITE_FORBIDDEN", $p.language, { table: "notification_inbox" }); };
    RETURN fn::result_ok(fn::notification_feed_view($updated));
} COMMENT "Met en sommeil un message du fil de la personne connectée ({ id, until : 3 minutes à 90 jours, sinon NOTIFICATION_SNOOZE_INVALID }) : caché jusqu'à until, puis de nouveau visible, non vu et non lu (calculé à la lecture). Session lyxal_auth de la personne";

-- ----------------------------------------------------------------------------
-- fn::notification_feed_unsnooze
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_feed_unsnooze($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            id: { pipeline: [{ rule: "record", options: { expected_table: "notification_inbox" } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $targets = fn::notification_feed_targets({ ids: [$p.id] });
    IF $targets.code IS NOT NONE { RETURN fn::error_result($targets.code, $p.language, $targets.details); };
    LET $updated = (UPDATE ONLY $p.id SET snoozed_until = NONE);
    IF $updated == NONE { RETURN fn::error_result("NOTIFICATION_WRITE_FORBIDDEN", $p.language, { table: "notification_inbox" }); };
    RETURN fn::result_ok(fn::notification_feed_view($updated));
} COMMENT "Réveille tout de suite un message en sommeil du fil de la personne connectée ({ id }) ; il reste non lu. Session lyxal_auth de la personne";

-- ----------------------------------------------------------------------------
-- fn::notification_feed_delete
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_feed_delete($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            id: { pipeline: [{ rule: "record", options: { expected_table: "notification_inbox" } }] },
            all: { pipeline: [{ rule: "boolean" }] },
            filter: fn::notification_feed_filter_fields({}),
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 30);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $targets = fn::notification_feed_targets({ ids: IF $p.id IS NONE { NONE } ELSE { [$p.id] }, all: $p.all, filter: $p.filter });
    IF $targets.code IS NOT NONE { RETURN fn::error_result($targets.code, $p.language, $targets.details); };
    LET $deleted = IF array::len($targets.ids) = 0 { [] } ELSE { (DELETE $targets.ids RETURN BEFORE) };
    IF array::len($deleted) < array::len($targets.ids) { RETURN fn::error_result("NOTIFICATION_WRITE_FORBIDDEN", $p.language, { table: "notification_inbox" }); };
    RETURN fn::result_ok({ deleted: array::len($deleted) });
} COMMENT "Supprime définitivement un message du fil de la personne connectée ({ id }), ou tous ceux d'un onglet ({ all : true, filter }). Renvoie { deleted }. Session lyxal_auth de la personne";

-- ----------------------------------------------------------------------------
-- fn::notification_feed_action
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_feed_action($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            id: { pipeline: [{ rule: "record", options: { expected_table: "notification_inbox" } }], required: true },
            action: { pipeline: [{ rule: "enum", options: { allowed: ["primary", "secondary"], case_sensitive: true } }], required: true },
            status: { pipeline: [{ rule: "enum", options: { allowed: ["done", "reverted"], case_sensitive: true } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $targets = fn::notification_feed_targets({ ids: [$p.id] });
    IF $targets.code IS NOT NONE { RETURN fn::error_result($targets.code, $p.language, $targets.details); };
    LET $item = (SELECT actions FROM ONLY $p.id);
    IF !array::any($item.actions ?? [], |$a| $a.kind = $p.action) { RETURN fn::error_result("NOTIFICATION_FEED_ACTION_INVALID", $p.language, { action: $p.action }); };
    LET $updated = (UPDATE ONLY $p.id SET action_status = object::extend(action_status ?? {}, object::from_entries([[$p.action, $p.status]])));
    IF $updated == NONE { RETURN fn::error_result("NOTIFICATION_WRITE_FORBIDDEN", $p.language, { table: "notification_inbox" }); };
    RETURN fn::result_ok(fn::notification_feed_view($updated));
} COMMENT "Enregistre l'état d'un bouton d'un message du fil de la personne connectée ({ id, action : primary ou secondary, status : done ou reverted }) ; bouton absent : NOTIFICATION_FEED_ACTION_INVALID ; publie notification.inbox.action (identifiants seulement). Session lyxal_auth de la personne";

-- ----------------------------------------------------------------------------
-- fn::notification_inbox_deliver (worker)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_inbox_deliver($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            job_id: { pipeline: [{ rule: "record", options: { expected_table: "notification_job" } }], required: true },
            claim_token: { pipeline: [{ rule: "uuid_v7", options: { allow_string: true } }], required: true },
            title: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 512 } }], required: true },
            text: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 20000 } }], required: true },
            avatar: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 2048 } }] },
            redirect: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 2048 } }] },
            actions: { pipeline: [{ rule: "array_length", options: { max_length: 2 } }, { rule: "each", options: { pipeline: [{ rule: "object", options: { schema: {
                fields: {
                    kind: { pipeline: [{ rule: "enum", options: { allowed: ["primary", "secondary"], case_sensitive: true } }], required: true },
                    label: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 128 } }], required: true },
                    url: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 2048 } }] }
                },
                unknown_keys: "reject"
            } } }] } }], default: [] },
            data: { pipeline: [{ rule: "object_values_type", options: { expected_type: "string", allow_empty: true } }], default: {} },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 60);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::notification_can({ action: "worker" }) { RETURN fn::error_result("NOTIFICATION_PERMISSION_DENIED", $p.language, {}); };
    -- Liens rendus contrôlés à nouveau (une variable ne peut pas en faire un lien dangereux)
    LET $links = array::concat([["avatar", $p.avatar], ["redirect", $p.redirect]], array::map($p.actions, |$a| [string::concat("actions.", $a.kind), $a.url]));
    LET $bad = array::filter($links, |$l| $l[1] IS NOT NONE AND !fn::notification_link_valid({ value: $l[1], template: false }));
    IF array::len($bad) > 0 {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", $p.language, { fields: object::from_entries(array::map($bad, |$l| [$l[0], ["CORE_VALIDATION_FORMAT"]])) });
    };
    IF !fn::validation_pipeline_execute($p.actions.kind, [{ rule: "array_unique" }], 5).valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", $p.language, { fields: { actions: ["CORE_VALIDATION_DUPLICATE"] } });
    };
    IF !fn::validation_max_length(<string> $p.data, 8192).valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", $p.language, { fields: { data: ["CORE_VALIDATION_TOO_LONG"] } });
    };
    LET $check = fn::notification_job_check({ job: $p.job_id, claim_token: <string> $p.claim_token });
    IF $check.code IS NOT NONE { RETURN fn::error_result($check.code, $p.language, {}); };
    LET $job = $check.job;
    IF $job.type != "in_app" { RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", $p.language, { fields: { job_id: ["CORE_VALIDATION_NOT_ALLOWED"] } }); };
    LET $run = (SELECT * FROM ONLY $job.run);
    LET $settings = fn::notification_settings_effective({ tenant: $run.tenant });
    LET $subscriber = IF $run.subscriber IS NONE { NONE } ELSE { (SELECT id, identity, subscriber_id FROM ONLY $run.subscriber) };
    -- Abonné supprimé ou délié de son compte depuis le déclenchement : plus de fil, étape écartée
    IF $subscriber.identity IS NONE {
        UPDATE $job.id SET status = "skipped", skip_reason = "no_address:in_app", locked_until = NONE, claim_token = NONE;
        CREATE notification_delivery_log CONTENT {
            run: $run.id, job: $job.id, attempt: $job.attempts, status: "skipped", code: "no_address:in_app",
            purge_after: time::now() + duration::from_days($settings.retention_days_log)
        };
        LET $next = fn::notification_run_advance({ run: $run.id });
        RETURN fn::result_ok({ item: NONE, messages: [], status: "skipped", run_status: IF $next.status IN ["completed", "failed", "skipped", "canceled", "merged"] { $next.status } ELSE { NONE } });
    };
    LET $workflow = (SELECT id, key, tags, severity FROM ONLY $run.workflow);
    LET $rid = type::record("notification_inbox", string::replace(<string> rand::uuid::v7(), "-", ""));
    -- Un message au plus par étape (index unique) : une livraison rejouée n'en crée pas un second
    LET $inserted = (INSERT IGNORE INTO notification_inbox {
        id: $rid,
        tenant: $run.tenant,
        subscriber: $subscriber.id,
        identity: $subscriber.identity,
        run: $run.id,
        job: $job.id,
        step_key: $job.step_key,
        workflow: $workflow.id,
        workflow_key: $workflow.key,
        tags: $workflow.tags ?? [],
        severity: $workflow.severity ?? "none",
        title: $p.title,
        text: $p.text,
        avatar: $p.avatar,
        redirect: $p.redirect,
        actions: $p.actions,
        action_status: object::from_entries(array::map($p.actions, |$a| [$a.kind, "pending"])),
        data: $p.data,
        purge_after: time::now() + duration::from_days($settings.retention_days_inbox)
    });
    LET $item = IF array::len($inserted) > 0 { $inserted[0].id } ELSE { (SELECT VALUE id FROM ONLY notification_inbox WHERE job = $job.id LIMIT 1) };
    IF $item IS NONE { RETURN fn::error_result("NOTIFICATION_WRITE_FORBIDDEN", $p.language, { table: "notification_inbox" }); };
    -- Trace de l'envoi pour le journal des gestionnaires : l'abonné, jamais le contenu (F1, F2)
    IF count(SELECT VALUE id FROM notification_message WHERE job = $job.id) = 0 {
        LET $message = (CREATE ONLY notification_message CONTENT {
            run: $run.id, job: $job.id, channel: "in_app", to: $subscriber.subscriber_id, status: "sent"
        });
        IF $message == NONE { RETURN fn::error_result("NOTIFICATION_WRITE_FORBIDDEN", $p.language, { table: "notification_message" }); };
    };
    CREATE notification_delivery_log CONTENT {
        run: $run.id, job: $job.id, attempt: $job.attempts, status: "sent",
        purge_after: time::now() + duration::from_days($settings.retention_days_log)
    };
    UPDATE $job.id SET status = "completed", locked_until = NONE, claim_token = NONE, last_error = NONE;
    LET $next = fn::notification_run_advance({ run: $run.id });
    RETURN fn::result_ok({
        item: $item,
        messages: (SELECT VALUE id FROM notification_message WHERE job = $job.id),
        status: "completed",
        run_status: IF $next.status IN ["completed", "failed", "skipped", "canceled", "merged"] { $next.status } ELSE { NONE }
    });
} COMMENT "Livre le message rendu d'une étape in_app réservée ({ job_id, claim_token, title, text, avatar, redirect, actions : [{ kind, label, url }] deux au plus, data : textes, 8 Kio au plus }) : liens rendus contrôlés (chemin de l'application ou adresse HTTPS, sinon NOTIFICATION_INVALID_INPUT), message du fil de l'abonné (étiquettes et gravité du parcours, conservation retention_days_inbox ; un seul par étape), trace d'envoi sans contenu (notification_message, canal in_app), journal, étape terminée puis étape suivante du déclenchement ; abonné supprimé ou sans compte : étape écartée (no_address:in_app). Renvoie { item, messages, status, run_status }. Permission notification.worker";
