-- ============================================================================
-- FONCTIONS : abonnés
-- MODULE    : lyxal_notification
-- ============================================================================
-- Un abonné est désigné par son `subscriber_id` dans une portée (`tenant` : organisation, ou
-- NONE pour l'installation). Lecture : notification.read ; gestion : notification.manage ;
-- création et mise à jour à la volée au déclenchement : notification.send (décision B2).

-- ----------------------------------------------------------------------------
-- fn::notification_subscriber_fields : schéma lyxal_core d'un abonné reçu
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_subscriber_fields($params: object) -> object {
    RETURN {
        subscriber_id: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 264 } }], required: true },
        email: { pipeline: [{ rule: "email", options: { max_length: 254 } }] },
        phone: { pipeline: [{ rule: "phone" }] },
        first_name: { pipeline: [{ rule: "optional_string", options: { max_length: 64 } }] },
        last_name: { pipeline: [{ rule: "optional_string", options: { max_length: 64 } }] },
        locale: { pipeline: [{ rule: "locale", options: { require_region: false } }] },
        timezone: { pipeline: [{ rule: "timezone", options: { allow_utc: true } }] },
        data: { pipeline: [{ rule: "is_object" }] },
        identity: { pipeline: [{ rule: "record", options: { expected_table: "auth_identity" } }] }
    };
} COMMENT "Champs lyxal_core d'un abonné reçu : subscriber_id, email, phone (E.164), first_name, last_name, locale, timezone, data, identity";

-- ----------------------------------------------------------------------------
-- fn::notification_subscriber_save : création ou mise à jour d'un abonné validé
-- ----------------------------------------------------------------------------
-- { tenant, input (validé par fn::notification_subscriber_fields), must_exist } →
-- { code, details, subscriber, created, changed } ; code NONE en cas de succès. Un nouvel abonné
-- auth:<identité> reprend les préférences de l'abonné email:<adresse> de la même portée
-- (personne invitée qui crée son compte, décision B1).

DEFINE FUNCTION OVERWRITE fn::notification_subscriber_save($params: object) -> object {
    LET $input = $params.input;
    LET $scope = IF $params.tenant IS NONE { "installation" } ELSE { <string> record::id($params.tenant) };
    IF $input.identity IS NOT NONE AND $input.subscriber_id != string::concat("auth:", <string> record::id($input.identity)) {
        RETURN { code: "NOTIFICATION_INVALID_INPUT", details: { fields: { identity: ["NOTIFICATION_SUBSCRIBER_IDENTITY_MISMATCH"] } } };
    };
    IF $input.data IS NOT NONE AND string::len(<string> $input.data) > 8192 {
        RETURN { code: "NOTIFICATION_INVALID_INPUT", details: { fields: { data: ["CORE_VALIDATION_TOO_LONG"] } } };
    };
    LET $email = IF $input.email IS NONE { NONE } ELSE { fn::sanitize_pipeline_execute($input.email, [{ rule: "email" }], 5) };
    LET $changes = object::from_entries(array::filter([
        ["email", $email], ["phone", $input.phone], ["first_name", $input.first_name], ["last_name", $input.last_name],
        ["locale", $input.locale], ["timezone", $input.timezone], ["data", $input.data]
    ], |$entry| $entry[1] IS NOT NONE));
    LET $existing = (SELECT * FROM ONLY notification_subscriber WHERE scope_key = $scope AND subscriber_id = $input.subscriber_id LIMIT 1);
    IF $existing IS NOT NONE {
        IF !array::any(object::entries($changes), |$entry| $existing[$entry[0]] != $entry[1]) {
            RETURN { code: NONE, subscriber: $existing, created: false, changed: false };
        };
        LET $updated = (UPDATE ONLY $existing.id MERGE $changes);
        IF $updated == NONE { RETURN { code: "NOTIFICATION_WRITE_FORBIDDEN", details: { table: "notification_subscriber" } }; };
        RETURN { code: NONE, subscriber: $updated, created: false, changed: true };
    };
    IF $params.must_exist { RETURN { code: "NOTIFICATION_SUBSCRIBER_NOT_FOUND", details: {} }; };
    LET $rid = type::record("notification_subscriber", string::replace(<string> rand::uuid::v7(), "-", ""));
    LET $inserted = (INSERT IGNORE INTO notification_subscriber object::extend($changes, {
        id: $rid, tenant: $params.tenant, subscriber_id: $input.subscriber_id, identity: $input.identity
    }));
    IF array::len($inserted) = 0 {
        -- Créé entre-temps par un autre appel (index unique), sinon écriture refusée
        LET $raced = (SELECT * FROM ONLY notification_subscriber WHERE scope_key = $scope AND subscriber_id = $input.subscriber_id LIMIT 1);
        IF $raced IS NONE { RETURN { code: "NOTIFICATION_WRITE_FORBIDDEN", details: { table: "notification_subscriber" } }; };
        RETURN { code: NONE, subscriber: $raced, created: false, changed: false };
    };
    IF string::starts_with($input.subscriber_id, "auth:") AND $email IS NOT NONE {
        LET $guest = (SELECT VALUE id FROM ONLY notification_subscriber WHERE scope_key = $scope AND subscriber_id = string::concat("email:", $email) LIMIT 1);
        IF $guest IS NOT NONE {
            FOR $preference IN (SELECT * FROM notification_preference WHERE subscriber = $guest) {
                INSERT IGNORE INTO notification_preference {
                    tenant: $preference.tenant, level: $preference.level, subscriber: $rid, workflow: $preference.workflow,
                    category: $preference.category, channels: $preference.channels, quiet_hours: $preference.quiet_hours
                };
            };
        };
    };
    RETURN { code: NONE, subscriber: $inserted[0], created: true, changed: true };
} COMMENT "Crée ou met à jour un abonné validé ({ tenant, input, must_exist }) ; adresse normalisée, data de 8 Kio au plus ; un nouvel abonné auth:<identité> reprend les préférences de l'abonné email:<adresse> de la portée. Renvoie { code, details, subscriber, created, changed }";

-- ----------------------------------------------------------------------------
-- fn::notification_subscriber_upsert
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_subscriber_upsert($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: object::extend(fn::notification_subscriber_fields({}), {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        }),
        unknown_keys: "reject"
    }, 60);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::notification_can({ action: "manage", tenant: $p.tenant }) { RETURN fn::error_result("NOTIFICATION_PERMISSION_DENIED", $p.language, {}); };
    LET $saved = fn::notification_subscriber_save({ tenant: $p.tenant, input: object::remove($p, ["tenant", "language"]), must_exist: false });
    IF $saved.code IS NOT NONE { RETURN fn::error_result($saved.code, $p.language, $saved.details); };
    RETURN fn::result_ok({ subscriber: $saved.subscriber, created: $saved.created, changed: $saved.changed });
} COMMENT "Crée ou met à jour un abonné ({ tenant, subscriber_id, email, phone, first_name, last_name, locale, timezone, data, identity }) ; seuls les champs fournis changent. Permission notification.manage";

-- ----------------------------------------------------------------------------
-- fn::notification_subscriber_find : abonné d'une portée par son identifiant
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_subscriber_find($params: object) -> any {
    LET $scope = IF $params.tenant IS NONE { "installation" } ELSE { <string> record::id($params.tenant) };
    RETURN (SELECT * FROM ONLY notification_subscriber WHERE scope_key = $scope AND subscriber_id = $params.subscriber_id LIMIT 1);
} COMMENT "Abonné ({ tenant, subscriber_id }) ou NONE";

-- ----------------------------------------------------------------------------
-- fn::notification_subscriber_get
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_subscriber_get($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            subscriber_id: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 264 } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::notification_can({ action: "read", tenant: $p.tenant }) { RETURN fn::error_result("NOTIFICATION_PERMISSION_DENIED", $p.language, {}); };
    LET $subscriber = fn::notification_subscriber_find({ tenant: $p.tenant, subscriber_id: $p.subscriber_id });
    IF $subscriber IS NONE { RETURN fn::error_result("NOTIFICATION_SUBSCRIBER_NOT_FOUND", $p.language, {}); };
    RETURN fn::result_ok(object::extend($subscriber, {
        topics: (SELECT VALUE topic.key FROM notification_topic_member WHERE subscriber = $subscriber.id ORDER BY topic.key)
    }));
} COMMENT "Abonné ({ tenant, subscriber_id }) avec les clés de ses sujets. Permission notification.read";

-- ----------------------------------------------------------------------------
-- fn::notification_subscriber_list
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_subscriber_list($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            search: { pipeline: [{ rule: "optional_string", options: { max_length: 128 } }] },
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
    LET $search = IF $p.search IS NONE OR $p.search = "" { NONE } ELSE { fn::sanitize_pipeline_execute($p.search, [{ rule: "trim" }, { rule: "lowercase" }], 5) };
    RETURN fn::result_ok(SELECT * FROM notification_subscriber
        WHERE scope_key = $scope AND ($search IS NONE
            OR string::contains(string::lowercase(subscriber_id), $search)
            OR string::contains(email ?? "", $search)
            OR string::contains(string::lowercase(first_name ?? ""), $search)
            OR string::contains(string::lowercase(last_name ?? ""), $search))
        ORDER BY subscriber_id LIMIT $p.limit START $p.start);
} COMMENT "Abonnés d'une portée ({ tenant, search : dans l'identifiant, l'adresse ou le nom, limit, start }), triés par identifiant. Permission notification.read";

-- ----------------------------------------------------------------------------
-- fn::notification_subscriber_delete
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_subscriber_delete($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            subscriber_id: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 264 } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::notification_can({ action: "manage", tenant: $p.tenant }) { RETURN fn::error_result("NOTIFICATION_PERMISSION_DENIED", $p.language, {}); };
    LET $subscriber = fn::notification_subscriber_find({ tenant: $p.tenant, subscriber_id: $p.subscriber_id });
    IF $subscriber IS NONE { RETURN fn::error_result("NOTIFICATION_SUBSCRIBER_NOT_FOUND", $p.language, {}); };
    LET $deleted = (DELETE $subscriber.id RETURN BEFORE);
    IF array::len($deleted) = 0 { RETURN fn::error_result("NOTIFICATION_WRITE_FORBIDDEN", $p.language, { table: "notification_subscriber" }); };
    RETURN fn::result_ok({ deleted: $subscriber.id });
} COMMENT "Supprime un abonné ({ tenant, subscriber_id }) avec ses préférences et ses abonnements ; ses déclenchements gardent l'adresse utilisée jusqu'à leur purge. Permission notification.manage";

-- ----------------------------------------------------------------------------
-- fn::notification_subscriber_import
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_subscriber_import($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            subscribers: { pipeline: [{ rule: "array" }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF array::len($p.subscribers) > 500 { RETURN fn::error_result("NOTIFICATION_IMPORT_TOO_LARGE", $p.language, { max: 500, received: array::len($p.subscribers) }); };
    IF !fn::notification_can({ action: "manage", tenant: $p.tenant }) { RETURN fn::error_result("NOTIFICATION_PERMISSION_DENIED", $p.language, {}); };
    LET $schema = { fields: fn::notification_subscriber_fields({}), unknown_keys: "reject" };
    -- Une ligne refusée n'arrête pas l'import : rapport par ligne
    LET $lines = array::map($p.subscribers, |$line, $index| {
        LET $checked = fn::validation_object_execute($line, $schema, 60);
        IF !$checked.valid {
            RETURN { index: $index, status: "rejected", code: "NOTIFICATION_INVALID_INPUT", fields: $checked.by_field };
        };
        LET $saved = fn::notification_subscriber_save({ tenant: $p.tenant, input: $checked.value, must_exist: false });
        IF $saved.code IS NOT NONE {
            RETURN { index: $index, status: "rejected", code: $saved.code, fields: $saved.details.fields };
        };
        RETURN { index: $index, status: IF $saved.created { "created" } ELSE IF $saved.changed { "updated" } ELSE { "unchanged" } };
    });
    RETURN fn::result_ok({
        created: array::len(array::filter($lines, |$line| $line.status = "created")),
        updated: array::len(array::filter($lines, |$line| $line.status = "updated")),
        unchanged: array::len(array::filter($lines, |$line| $line.status = "unchanged")),
        rejected: array::filter($lines, |$line| $line.status = "rejected")
    });
} COMMENT "Importe jusqu'à 500 abonnés ({ tenant, subscribers : [{ subscriber_id, email, … }] }) : créés ou mis à jour ; une ligne invalide est refusée sans arrêter l'import (rapport { created, updated, unchanged, rejected : [{ index, code, fields }] }). Permission notification.manage";
