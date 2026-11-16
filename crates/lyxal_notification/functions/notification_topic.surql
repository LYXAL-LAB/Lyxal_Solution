-- ============================================================================
-- FONCTIONS : sujets et abonnements aux sujets
-- MODULE    : lyxal_notification
-- ============================================================================
-- Un sujet est désigné par sa clé dans une portée. Un abonnement peut porter une condition
-- lyxal_core (fn::utils_condition_check à l'enregistrement, fn::utils_condition_evaluate à la
-- diffusion) sur { subscriber : { subscriber_id, locale, timezone, data }, payload }.
-- Lecture : notification.read ; gestion : notification.manage.

-- ----------------------------------------------------------------------------
-- fn::notification_topic_find : sujet d'une portée par sa clé
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_topic_find($params: object) -> any {
    LET $scope = IF $params.tenant IS NONE { "installation" } ELSE { <string> record::id($params.tenant) };
    RETURN (SELECT * FROM ONLY notification_topic WHERE scope_key = $scope AND key = $params.key LIMIT 1);
} COMMENT "Sujet ({ tenant, key }) ou NONE";

-- ----------------------------------------------------------------------------
-- fn::notification_topic_create
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_topic_create($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            key: { pipeline: [{ rule: "snake_case_name", options: { min_length: 1, max_length: 64 } }], required: true },
            name: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 128 } }], required: true },
            description: { pipeline: [{ rule: "optional_string", options: { max_length: 512 } }] },
            data: { pipeline: [{ rule: "is_object" }], default: {} },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 30);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::notification_can({ action: "manage", tenant: $p.tenant }) { RETURN fn::error_result("NOTIFICATION_PERMISSION_DENIED", $p.language, {}); };
    IF fn::notification_topic_find({ tenant: $p.tenant, key: $p.key }) IS NOT NONE {
        RETURN fn::error_result("NOTIFICATION_TOPIC_KEY_TAKEN", $p.language, { key: $p.key });
    };
    LET $created = (INSERT IGNORE INTO notification_topic { tenant: $p.tenant, key: $p.key, name: $p.name, description: $p.description, data: $p.data });
    IF array::len($created) = 0 {
        RETURN fn::error_result(IF fn::notification_topic_find({ tenant: $p.tenant, key: $p.key }) IS NONE { "NOTIFICATION_WRITE_FORBIDDEN" } ELSE { "NOTIFICATION_TOPIC_KEY_TAKEN" }, $p.language, { key: $p.key });
    };
    RETURN fn::result_ok($created[0]);
} COMMENT "Crée un sujet ({ tenant, key, name, description, data }) ; clé unique dans sa portée. Permission notification.manage";

-- ----------------------------------------------------------------------------
-- fn::notification_topic_update
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_topic_update($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            key: { pipeline: [{ rule: "snake_case_name", options: { min_length: 1, max_length: 64 } }], required: true },
            name: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 128 } }] },
            description: { pipeline: [{ rule: "optional_string", options: { max_length: 512 } }] },
            data: { pipeline: [{ rule: "is_object" }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 30);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::notification_can({ action: "manage", tenant: $p.tenant }) { RETURN fn::error_result("NOTIFICATION_PERMISSION_DENIED", $p.language, {}); };
    LET $topic = fn::notification_topic_find({ tenant: $p.tenant, key: $p.key });
    IF $topic IS NONE { RETURN fn::error_result("NOTIFICATION_TOPIC_NOT_FOUND", $p.language, { key: $p.key }); };
    LET $changes = object::from_entries(array::filter(
        array::map(["name", "description", "data"], |$f| [$f, $p[$f]]),
        |$e| $e[1] IS NOT NONE
    ));
    LET $updated = (UPDATE ONLY $topic.id MERGE $changes);
    IF $updated == NONE { RETURN fn::error_result("NOTIFICATION_WRITE_FORBIDDEN", $p.language, { table: "notification_topic" }); };
    RETURN fn::result_ok($updated);
} COMMENT "Modifie un sujet ({ tenant, key, name, description, data }) ; seuls les champs fournis changent. Permission notification.manage";

-- ----------------------------------------------------------------------------
-- fn::notification_topic_get
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_topic_get($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            key: { pipeline: [{ rule: "snake_case_name", options: { min_length: 1, max_length: 64 } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::notification_can({ action: "read", tenant: $p.tenant }) { RETURN fn::error_result("NOTIFICATION_PERMISSION_DENIED", $p.language, {}); };
    LET $topic = fn::notification_topic_find({ tenant: $p.tenant, key: $p.key });
    IF $topic IS NONE { RETURN fn::error_result("NOTIFICATION_TOPIC_NOT_FOUND", $p.language, { key: $p.key }); };
    RETURN fn::result_ok(object::extend($topic, { members: count(SELECT id FROM notification_topic_member WHERE topic = $topic.id) }));
} COMMENT "Sujet ({ tenant, key }) avec son nombre d'abonnés. Permission notification.read";

-- ----------------------------------------------------------------------------
-- fn::notification_topic_list
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_topic_list($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            limit: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 1000 } }], default: 100 },
            start: { pipeline: [{ rule: "integer", options: { min_value: 0 } }], default: 0 },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::notification_can({ action: "read", tenant: $p.tenant }) { RETURN fn::error_result("NOTIFICATION_PERMISSION_DENIED", $p.language, {}); };
    LET $scope = IF $p.tenant IS NONE { "installation" } ELSE { <string> record::id($p.tenant) };
    RETURN fn::result_ok(SELECT * FROM notification_topic WHERE scope_key = $scope ORDER BY key LIMIT $p.limit START $p.start);
} COMMENT "Sujets d'une portée ({ tenant, limit, start }), triés par clé. Permission notification.read";

-- ----------------------------------------------------------------------------
-- fn::notification_topic_delete
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_topic_delete($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            key: { pipeline: [{ rule: "snake_case_name", options: { min_length: 1, max_length: 64 } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::notification_can({ action: "manage", tenant: $p.tenant }) { RETURN fn::error_result("NOTIFICATION_PERMISSION_DENIED", $p.language, {}); };
    LET $topic = fn::notification_topic_find({ tenant: $p.tenant, key: $p.key });
    IF $topic IS NONE { RETURN fn::error_result("NOTIFICATION_TOPIC_NOT_FOUND", $p.language, { key: $p.key }); };
    LET $deleted = (DELETE $topic.id RETURN BEFORE);
    IF array::len($deleted) = 0 { RETURN fn::error_result("NOTIFICATION_WRITE_FORBIDDEN", $p.language, { table: "notification_topic" }); };
    RETURN fn::result_ok({ deleted: $topic.id });
} COMMENT "Supprime un sujet ({ tenant, key }) et ses abonnements. Permission notification.manage";

-- ----------------------------------------------------------------------------
-- fn::notification_topic_subscribe
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_topic_subscribe($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            key: { pipeline: [{ rule: "snake_case_name", options: { min_length: 1, max_length: 64 } }], required: true },
            subscribers: { pipeline: [{ rule: "array_of_strings", options: { allow_empty: false, min_length: 1, max_length: 128 } }, { rule: "array_non_empty" }, { rule: "array_unique" }, { rule: "array_length", options: { max_length: 100 } }], required: true },
            condition: { pipeline: [{ rule: "is_object" }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 30);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::notification_can({ action: "manage", tenant: $p.tenant }) { RETURN fn::error_result("NOTIFICATION_PERMISSION_DENIED", $p.language, {}); };
    IF $p.condition IS NOT NONE {
        LET $check = fn::utils_condition_check($p.condition, NONE);
        IF !$check.valid { RETURN fn::error_result("NOTIFICATION_CONDITION_INVALID", $p.language, $check.details); };
    };
    LET $topic = fn::notification_topic_find({ tenant: $p.tenant, key: $p.key });
    IF $topic IS NONE { RETURN fn::error_result("NOTIFICATION_TOPIC_NOT_FOUND", $p.language, { key: $p.key }); };
    LET $results = array::map($p.subscribers, |$subscriber_id| {
        LET $subscriber = fn::notification_subscriber_find({ tenant: $p.tenant, subscriber_id: $subscriber_id });
        IF $subscriber IS NONE { RETURN { subscriber_id: $subscriber_id, status: "not_found" }; };
        LET $member = (SELECT * FROM ONLY notification_topic_member WHERE topic = $topic.id AND subscriber = $subscriber.id LIMIT 1);
        IF $member IS NONE {
            LET $created = (INSERT IGNORE INTO notification_topic_member { topic: $topic.id, subscriber: $subscriber.id, condition: $p.condition });
            RETURN { subscriber_id: $subscriber_id, status: IF array::len($created) = 0 { "forbidden" } ELSE { "added" } };
        };
        IF $member.condition == $p.condition { RETURN { subscriber_id: $subscriber_id, status: "unchanged" }; };
        LET $updated = (UPDATE ONLY $member.id SET condition = $p.condition);
        RETURN { subscriber_id: $subscriber_id, status: IF $updated == NONE { "forbidden" } ELSE { "updated" } };
    });
    IF array::any($results, |$r| $r.status = "forbidden") { RETURN fn::error_result("NOTIFICATION_WRITE_FORBIDDEN", $p.language, { table: "notification_topic_member" }); };
    RETURN fn::result_ok({
        added: array::len(array::filter($results, |$r| $r.status = "added")),
        updated: array::len(array::filter($results, |$r| $r.status = "updated")),
        unchanged: array::len(array::filter($results, |$r| $r.status = "unchanged")),
        not_found: array::filter($results, |$r| $r.status = "not_found").subscriber_id
    });
} COMMENT "Abonne jusqu'à 100 abonnés existants à un sujet ({ tenant, key, subscribers : [subscriber_id], condition }) ; condition lyxal_core facultative sur { subscriber, payload }, remplacée pour un abonné déjà membre. Renvoie { added, updated, unchanged, not_found }. Permission notification.manage";

-- ----------------------------------------------------------------------------
-- fn::notification_topic_unsubscribe
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_topic_unsubscribe($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            key: { pipeline: [{ rule: "snake_case_name", options: { min_length: 1, max_length: 64 } }], required: true },
            subscribers: { pipeline: [{ rule: "array_of_strings", options: { allow_empty: false, min_length: 1, max_length: 128 } }, { rule: "array_non_empty" }, { rule: "array_unique" }, { rule: "array_length", options: { max_length: 100 } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 30);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::notification_can({ action: "manage", tenant: $p.tenant }) { RETURN fn::error_result("NOTIFICATION_PERMISSION_DENIED", $p.language, {}); };
    LET $topic = fn::notification_topic_find({ tenant: $p.tenant, key: $p.key });
    IF $topic IS NONE { RETURN fn::error_result("NOTIFICATION_TOPIC_NOT_FOUND", $p.language, { key: $p.key }); };
    LET $results = array::map($p.subscribers, |$subscriber_id| {
        LET $member = (SELECT VALUE id FROM ONLY notification_topic_member
            WHERE topic = $topic.id AND subscriber.subscriber_id = $subscriber_id LIMIT 1);
        IF $member IS NONE { RETURN { subscriber_id: $subscriber_id, status: "not_found" }; };
        LET $deleted = (DELETE $member RETURN BEFORE);
        RETURN { subscriber_id: $subscriber_id, status: IF array::len($deleted) = 0 { "forbidden" } ELSE { "removed" } };
    });
    IF array::any($results, |$r| $r.status = "forbidden") { RETURN fn::error_result("NOTIFICATION_WRITE_FORBIDDEN", $p.language, { table: "notification_topic_member" }); };
    RETURN fn::result_ok({
        removed: array::len(array::filter($results, |$r| $r.status = "removed")),
        not_found: array::filter($results, |$r| $r.status = "not_found").subscriber_id
    });
} COMMENT "Retire jusqu'à 100 abonnés d'un sujet ({ tenant, key, subscribers : [subscriber_id] }) ; renvoie { removed, not_found }. Permission notification.manage";

-- ----------------------------------------------------------------------------
-- fn::notification_topic_members
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_topic_members($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            key: { pipeline: [{ rule: "snake_case_name", options: { min_length: 1, max_length: 64 } }], required: true },
            limit: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 1000 } }], default: 100 },
            start: { pipeline: [{ rule: "integer", options: { min_value: 0 } }], default: 0 },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::notification_can({ action: "read", tenant: $p.tenant }) { RETURN fn::error_result("NOTIFICATION_PERMISSION_DENIED", $p.language, {}); };
    LET $topic = fn::notification_topic_find({ tenant: $p.tenant, key: $p.key });
    IF $topic IS NONE { RETURN fn::error_result("NOTIFICATION_TOPIC_NOT_FOUND", $p.language, { key: $p.key }); };
    RETURN fn::result_ok(SELECT subscriber.subscriber_id AS subscriber_id, condition, created_at FROM notification_topic_member
        WHERE topic = $topic.id ORDER BY subscriber_id LIMIT $p.limit START $p.start);
} COMMENT "Abonnés d'un sujet ({ tenant, key, limit, start }) : [{ subscriber_id, condition, created_at }], triés par identifiant. Permission notification.read";
