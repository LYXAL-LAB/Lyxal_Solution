-- ============================================================================
-- FONCTIONS : préférences, heures calmes, désabonnement
-- MODULE    : lyxal_notification
-- ============================================================================
-- Ordre (décision B4), du plus général au plus précis, le dernier niveau qui s'exprime gagne :
-- défaut du parcours → organisation pour ce parcours (tenant_workflow) → choix global de
-- l'abonné → choix de l'abonné pour la catégorie → choix de l'abonné pour le parcours. Un
-- parcours critique ignore les choix de l'abonné ; un canal imposé par le parcours aussi. Seule
-- fn::notification_preference_resolve calcule le résultat.

-- ----------------------------------------------------------------------------
-- fn::notification_channels : canaux connus des préférences
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_channels($params: object) -> array<string> {
    RETURN ["email", "sms", "chat", "push", "in_app", "webhook"];
} COMMENT "Canaux des préférences : email, sms, chat, push, in_app, webhook";

-- ----------------------------------------------------------------------------
-- fn::notification_preference_key : cible unique d'une préférence
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_preference_key($params: object) -> string {
    RETURN string::concat(
        $params.level, "|",
        IF $params.tenant IS NONE { "installation" } ELSE { <string> record::id($params.tenant) }, "|",
        IF $params.subscriber IS NONE { "" } ELSE { <string> $params.subscriber }, "|",
        IF $params.workflow IS NONE { "" } ELSE { <string> $params.workflow }, "|",
        IF $params.category IS NONE { "" } ELSE { <string> $params.category }
    );
} COMMENT "Cible unique d'une préférence ({ level, tenant, subscriber, workflow, category }), valeur du champ target_key";

-- ----------------------------------------------------------------------------
-- fn::notification_preference_fields : schéma lyxal_core des canaux et des heures calmes
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_preference_fields($params: object) -> object {
    LET $choice = { pipeline: [{ rule: "boolean" }], nullable: true };
    RETURN {
        channels: { pipeline: [{ rule: "is_object" }, { rule: "object", options: { schema: {
            fields: { email: $choice, sms: $choice, chat: $choice, push: $choice, in_app: $choice, webhook: $choice },
            unknown_keys: "reject"
        } } }] },
        quiet_hours: { pipeline: [{ rule: "is_object" }, { rule: "object", options: { schema: {
            fields: {
                ranges: { pipeline: [{ rule: "array_objects", options: { allow_empty_objects: false } }, { rule: "array_length", options: { max_length: 14 } }, { rule: "each", options: { pipeline: [{ rule: "object", options: { schema: {
                    fields: {
                        days: { pipeline: [{ rule: "array_integers", options: { min_value: 1, max_value: 7 } }, { rule: "array_non_empty" }, { rule: "array_unique" }], required: true },
                        start: { pipeline: [{ rule: "time_of_day" }], required: true },
                        end: { pipeline: [{ rule: "time_of_day" }], required: true }
                    },
                    unknown_keys: "reject"
                } } }] } }], required: true }
            },
            unknown_keys: "reject"
        } } }], nullable: true }
    };
} COMMENT "Champs lyxal_core des préférences : channels ({ email, sms, chat, push, in_app, webhook } : true, false, ou null pour effacer) et quiet_hours ({ ranges : [{ days : 1 à 7, start, end : minutes depuis minuit }] }, null pour effacer)";

-- ----------------------------------------------------------------------------
-- fn::notification_preference_resolve : canaux autorisés pour un abonné et un parcours
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_preference_resolve($params: object) -> object {
    LET $workflow = $params.workflow;
    LET $subscriber = $params.subscriber;
    LET $tenant = $params.tenant;
    LET $find = |$level, $workflow_id, $category_id| (SELECT * FROM ONLY notification_preference
        WHERE target_key = fn::notification_preference_key({
            level: $level, tenant: $tenant,
            subscriber: IF $level = "tenant_workflow" { NONE } ELSE { $subscriber.id },
            workflow: $workflow_id, category: $category_id
        }) LIMIT 1);
    LET $global = IF $subscriber IS NONE { NONE } ELSE { $find("subscriber_global", NONE, NONE) };
    LET $layers = array::concat([
        { level: "workflow_default", channels: $workflow.preferences.channels ?? {}, personal: false },
        { level: "tenant_workflow", channels: ($find("tenant_workflow", $workflow.id, NONE)).channels ?? {}, personal: false }
    ], IF $subscriber IS NONE { [] } ELSE { [
        { level: "subscriber_global", channels: $global.channels ?? {}, personal: true },
        { level: "subscriber_category", channels: IF $workflow.category IS NONE { {} } ELSE { ($find("subscriber_category", NONE, $workflow.category)).channels ?? {} }, personal: true },
        { level: "subscriber_workflow", channels: ($find("subscriber_workflow", $workflow.id, NONE)).channels ?? {}, personal: true }
    ] });
    LET $enforced = $workflow.preferences.enforced ?? [];
    LET $channels = object::from_entries(array::map(fn::notification_channels({}), |$channel| [$channel,
        array::fold($layers, { allowed: true, level: "default" }, |$acc, $layer|
            IF ($layer.personal AND ($workflow.critical OR $channel IN $enforced)) OR $layer.channels[$channel] IS NONE { $acc }
            ELSE { { allowed: $layer.channels[$channel], level: $layer.level } })
    ]));
    LET $quiet = IF $workflow.critical OR $global.quiet_hours IS NONE OR array::len($global.quiet_hours.ranges ?? []) = 0 { NONE } ELSE {
        {
            timezone: $subscriber.timezone ?? fn::notification_settings_effective({ tenant: $tenant }).timezone ?? "UTC",
            ranges: $global.quiet_hours.ranges
        }
    };
    RETURN { critical: $workflow.critical, channels: $channels, quiet_hours: $quiet };
} COMMENT "Préférences calculées ({ tenant, workflow : parcours, subscriber : abonné ou NONE }) : { critical, channels : { <canal> : { allowed, level } }, quiet_hours : { timezone, ranges } ou NONE }. Ordre B4 ; parcours critique et canaux imposés ignorent les choix de l'abonné ; heures calmes absentes pour un parcours critique ; fuseau de l'abonné, sinon des réglages, sinon UTC";

-- ----------------------------------------------------------------------------
-- fn::notification_preference_write : enregistrement d'une préférence (sans contrôle)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_preference_write($params: object) -> any {
    LET $key = fn::notification_preference_key($params);
    LET $existing = (SELECT * FROM ONLY notification_preference WHERE target_key = $key LIMIT 1);
    LET $current = $existing.channels ?? {};
    LET $given = $params.channels ?? {};
    -- Canal fourni : remplacé (null l'efface) ; canal absent : gardé
    LET $channels = object::from_entries(array::filter(array::map(fn::notification_channels({}), |$channel| [$channel,
        IF $given[$channel] IS NONE { $current[$channel] } ELSE IF type::is_null($given[$channel]) { NONE } ELSE { $given[$channel] }
    ]), |$entry| $entry[1] IS NOT NONE));
    LET $quiet = IF $params.quiet_hours IS NONE { $existing.quiet_hours } ELSE IF type::is_null($params.quiet_hours) { NONE } ELSE { $params.quiet_hours };
    IF $existing IS NONE {
        LET $created = (INSERT IGNORE INTO notification_preference {
            tenant: $params.tenant, level: $params.level, subscriber: $params.subscriber, workflow: $params.workflow,
            category: $params.category, channels: $channels, quiet_hours: $quiet
        });
        RETURN $created[0];
    };
    RETURN (UPDATE ONLY $existing.id SET channels = $channels, quiet_hours = $quiet);
} COMMENT "Crée ou modifie une préférence ({ tenant, level, subscriber, workflow, category, channels, quiet_hours }) ; renvoie l'enregistrement, ou NONE si l'écriture est refusée";

-- ----------------------------------------------------------------------------
-- fn::notification_preference_apply : contrôle et enregistrement d'une préférence
-- ----------------------------------------------------------------------------
-- { tenant, level, subscriber (abonné), workflow (parcours), category (catégorie), channels,
-- quiet_hours, language } → fn::result_ok(préférence) ou fn::error_result.

DEFINE FUNCTION OVERWRITE fn::notification_preference_apply($params: object) -> object {
    LET $p = $params;
    LET $missing = array::filter([
        IF $p.level = "tenant_workflow" AND $p.workflow IS NONE { "workflow" } ELSE { NONE },
        IF $p.level != "tenant_workflow" AND $p.subscriber IS NONE { "subscriber_id" } ELSE { NONE },
        IF $p.level = "subscriber_category" AND $p.category IS NONE { "category" } ELSE { NONE },
        IF $p.level = "subscriber_workflow" AND $p.workflow IS NONE { "workflow" } ELSE { NONE }
    ], |$f| $f IS NOT NONE);
    IF array::len($missing) > 0 {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", $p.language, { fields: object::from_entries(array::map($missing, |$f| [$f, ["CORE_VALIDATION_REQUIRED"]])) });
    };
    IF $p.quiet_hours IS NOT NONE AND $p.level != "subscriber_global" {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", $p.language, { fields: { quiet_hours: ["CORE_VALIDATION_NOT_ALLOWED"] } });
    };
    IF $p.channels IS NONE AND $p.quiet_hours IS NONE {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", $p.language, { fields: { channels: ["CORE_VALIDATION_REQUIRED"] } });
    };
    -- Un canal imposé par le parcours, ou tout canal d'un parcours critique, ne se règle pas par abonné
    IF $p.level = "subscriber_workflow" {
        LET $given = object::keys($p.channels ?? {});
        LET $locked = IF $p.workflow.critical { $given } ELSE { array::intersect($given, $p.workflow.preferences.enforced ?? []) };
        IF array::len($locked) > 0 { RETURN fn::error_result("NOTIFICATION_PREFERENCE_ENFORCED", $p.language, { channels: $locked }); };
    };
    LET $saved = fn::notification_preference_write({
        tenant: $p.tenant, level: $p.level,
        subscriber: IF $p.level = "tenant_workflow" { NONE } ELSE { $p.subscriber.id },
        workflow: IF $p.level IN ["tenant_workflow", "subscriber_workflow"] { $p.workflow.id } ELSE { NONE },
        category: IF $p.level = "subscriber_category" { $p.category.id } ELSE { NONE },
        channels: $p.channels, quiet_hours: $p.quiet_hours
    });
    IF $saved == NONE { RETURN fn::error_result("NOTIFICATION_WRITE_FORBIDDEN", $p.language, { table: "notification_preference" }); };
    RETURN fn::result_ok($saved);
} COMMENT "Contrôle (cible du niveau, heures calmes au niveau global seulement, canal imposé ou parcours critique : NOTIFICATION_PREFERENCE_ENFORCED) puis enregistre une préférence ; fn::result_ok ou fn::error_result";

-- ----------------------------------------------------------------------------
-- fn::notification_preference_targets : parcours et catégorie désignés par l'appelant
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_preference_targets($params: object) -> object {
    LET $scope = IF $params.tenant IS NONE { "installation" } ELSE { <string> record::id($params.tenant) };
    LET $workflow = IF $params.workflow IS NONE { NONE } ELSE { (SELECT * FROM ONLY $params.workflow) };
    IF $params.workflow IS NOT NONE AND ($workflow IS NONE OR $workflow.scope_key NOT IN [$scope, "installation"]) {
        RETURN { code: "NOTIFICATION_WORKFLOW_NOT_FOUND" };
    };
    LET $category = IF $params.category IS NONE { NONE } ELSE { fn::notification_category_find({ tenant: $params.tenant, key: $params.category, own_only: false }) };
    IF $params.category IS NOT NONE AND $category IS NONE { RETURN { code: "NOTIFICATION_CATEGORY_NOT_FOUND" }; };
    RETURN { code: NONE, workflow: $workflow, category: $category };
} COMMENT "Parcours (record, de la portée ou de l'installation) et catégorie (clé) désignés ({ tenant, workflow, category }) : { code, workflow, category }";

-- ----------------------------------------------------------------------------
-- fn::notification_preference_view : préférences d'un abonné, par niveau
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_preference_view($params: object) -> object {
    LET $subscriber = $params.subscriber;
    LET $rows = IF $subscriber IS NONE { [] } ELSE { (SELECT * FROM notification_preference WHERE subscriber = $subscriber.id) };
    LET $global = array::find($rows, |$r| $r.level = "subscriber_global");
    RETURN {
        subscriber_id: $subscriber.subscriber_id,
        global: { channels: $global.channels ?? {}, quiet_hours: $global.quiet_hours },
        categories: array::map(array::filter($rows, |$r| $r.level = "subscriber_category"), |$r| { category: $r.category, key: $r.category.key, channels: $r.channels }),
        workflows: array::map(array::filter($rows, |$r| $r.level = "subscriber_workflow"), |$r| { workflow: $r.workflow, key: $r.workflow.key, channels: $r.channels }),
        resolved: IF $params.workflow IS NONE { NONE } ELSE {
            fn::notification_preference_resolve({ tenant: $params.tenant, workflow: $params.workflow, subscriber: $subscriber })
        }
    };
} COMMENT "Préférences d'un abonné par niveau ({ tenant, subscriber, workflow }) : { subscriber_id, global, categories, workflows, resolved (si un parcours est donné) }";

-- ----------------------------------------------------------------------------
-- fn::notification_preference_get
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_preference_get($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            subscriber_id: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 128 } }] },
            workflow: { pipeline: [{ rule: "record", options: { expected_table: "notification_workflow" } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::notification_can({ action: "read", tenant: $p.tenant }) { RETURN fn::error_result("NOTIFICATION_PERMISSION_DENIED", $p.language, {}); };
    LET $targets = fn::notification_preference_targets({ tenant: $p.tenant, workflow: $p.workflow });
    IF $targets.code IS NOT NONE { RETURN fn::error_result($targets.code, $p.language, {}); };
    -- Sans abonné : réglages de l'organisation par parcours
    IF $p.subscriber_id IS NONE {
        LET $scope = IF $p.tenant IS NONE { "installation" } ELSE { <string> record::id($p.tenant) };
        RETURN fn::result_ok({
            workflows: (SELECT workflow, workflow.key AS key, channels FROM notification_preference
                WHERE scope_key = $scope AND level = "tenant_workflow" ORDER BY key),
            resolved: IF $targets.workflow IS NONE { NONE } ELSE {
                fn::notification_preference_resolve({ tenant: $p.tenant, workflow: $targets.workflow, subscriber: NONE })
            }
        });
    };
    LET $subscriber = fn::notification_subscriber_find({ tenant: $p.tenant, subscriber_id: $p.subscriber_id });
    IF $subscriber IS NONE { RETURN fn::error_result("NOTIFICATION_SUBSCRIBER_NOT_FOUND", $p.language, {}); };
    RETURN fn::result_ok(fn::notification_preference_view({ tenant: $p.tenant, subscriber: $subscriber, workflow: $targets.workflow }));
} COMMENT "Préférences ({ tenant, subscriber_id, workflow }) : d'un abonné par niveau, avec le résultat calculé pour un parcours ; sans abonné, réglages de l'organisation par parcours. Permission notification.read";

-- ----------------------------------------------------------------------------
-- fn::notification_preference_set
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_preference_set($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: object::extend(fn::notification_preference_fields({}), {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            level: { pipeline: [{ rule: "enum", options: { allowed: ["tenant_workflow", "subscriber_global", "subscriber_category", "subscriber_workflow"], case_sensitive: true } }], required: true },
            subscriber_id: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 128 } }] },
            workflow: { pipeline: [{ rule: "record", options: { expected_table: "notification_workflow" } }] },
            category: { pipeline: [{ rule: "snake_case_name", options: { min_length: 1, max_length: 64 } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        }),
        unknown_keys: "reject"
    }, 80);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::notification_can({ action: "manage", tenant: $p.tenant }) { RETURN fn::error_result("NOTIFICATION_PERMISSION_DENIED", $p.language, {}); };
    IF $p.level = "tenant_workflow" AND ($p.subscriber_id IS NOT NONE OR $p.category IS NOT NONE) {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", $p.language, { fields: { subscriber_id: ["CORE_VALIDATION_NOT_ALLOWED"] } });
    };
    LET $targets = fn::notification_preference_targets({ tenant: $p.tenant, workflow: $p.workflow, category: $p.category });
    IF $targets.code IS NOT NONE { RETURN fn::error_result($targets.code, $p.language, {}); };
    LET $subscriber = IF $p.subscriber_id IS NONE { NONE } ELSE { fn::notification_subscriber_find({ tenant: $p.tenant, subscriber_id: $p.subscriber_id }) };
    IF $p.subscriber_id IS NOT NONE AND $subscriber IS NONE { RETURN fn::error_result("NOTIFICATION_SUBSCRIBER_NOT_FOUND", $p.language, {}); };
    RETURN fn::notification_preference_apply({
        tenant: $p.tenant, level: $p.level, subscriber: $subscriber, workflow: $targets.workflow, category: $targets.category,
        channels: $p.channels, quiet_hours: $p.quiet_hours, language: $p.language
    });
} COMMENT "Enregistre une préférence ({ tenant, level : tenant_workflow, subscriber_global, subscriber_category, subscriber_workflow ; subscriber_id, workflow, category (clé), channels, quiet_hours }) pour l'organisation ou un abonné ; canaux fournis remplacés (null efface). Permission notification.manage";

-- ----------------------------------------------------------------------------
-- fn::notification_my_subscriber : abonné de la personne connectée dans une portée
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_my_subscriber($params: object) -> object {
    LET $context = fn::auth_context({});
    IF !$context.ok OR $context.data.identity IS NONE { RETURN { code: "NOTIFICATION_PERMISSION_DENIED" }; };
    IF $params.tenant IS NOT NONE AND $params.tenant != $context.data.organization { RETURN { code: "NOTIFICATION_PERMISSION_DENIED" }; };
    LET $identity = $context.data.identity;
    LET $subscriber_id = string::concat("auth:", <string> record::id($identity));
    LET $existing = fn::notification_subscriber_find({ tenant: $params.tenant, subscriber_id: $subscriber_id });
    IF $existing IS NOT NONE OR !$params.create { RETURN { code: NONE, subscriber: $existing }; };
    -- Abonné créé pour régler ses préférences : adresse et langue de son compte
    LET $traits = (SELECT VALUE traits FROM ONLY $identity) ?? {};
    LET $saved = fn::notification_subscriber_save({
        tenant: $params.tenant,
        input: { subscriber_id: $subscriber_id, identity: $identity, email: $traits.email, locale: $traits.locale },
        must_exist: false
    });
    RETURN { code: $saved.code, subscriber: $saved.subscriber };
} COMMENT "Abonné auth:<identité> de la personne connectée ({ tenant : NONE ou son organisation active, create }) : { code, subscriber } ; créé à la demande avec l'adresse et la langue de son compte";

-- ----------------------------------------------------------------------------
-- fn::notification_my_preference_get
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_my_preference_get($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            workflow: { pipeline: [{ rule: "record", options: { expected_table: "notification_workflow" } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $mine = fn::notification_my_subscriber({ tenant: $p.tenant, create: false });
    IF $mine.code IS NOT NONE { RETURN fn::error_result($mine.code, $p.language, {}); };
    LET $targets = fn::notification_preference_targets({ tenant: $p.tenant, workflow: $p.workflow });
    IF $targets.code IS NOT NONE { RETURN fn::error_result($targets.code, $p.language, {}); };
    RETURN fn::result_ok(fn::notification_preference_view({ tenant: $p.tenant, subscriber: $mine.subscriber, workflow: $targets.workflow }));
} COMMENT "Préférences de la personne connectée ({ tenant : NONE ou son organisation active, workflow }) par niveau, avec le résultat calculé pour un parcours. Sans permission (session lyxal_auth d'une personne)";

-- ----------------------------------------------------------------------------
-- fn::notification_my_preference_set
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_my_preference_set($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: object::extend(fn::notification_preference_fields({}), {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            level: { pipeline: [{ rule: "enum", options: { allowed: ["subscriber_global", "subscriber_category", "subscriber_workflow"], case_sensitive: true } }], required: true },
            workflow: { pipeline: [{ rule: "record", options: { expected_table: "notification_workflow" } }] },
            category: { pipeline: [{ rule: "snake_case_name", options: { min_length: 1, max_length: 64 } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        }),
        unknown_keys: "reject"
    }, 80);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $targets = fn::notification_preference_targets({ tenant: $p.tenant, workflow: $p.workflow, category: $p.category });
    IF $targets.code IS NOT NONE { RETURN fn::error_result($targets.code, $p.language, {}); };
    LET $mine = fn::notification_my_subscriber({ tenant: $p.tenant, create: true });
    IF $mine.code IS NOT NONE { RETURN fn::error_result($mine.code, $p.language, {}); };
    RETURN fn::notification_preference_apply({
        tenant: $p.tenant, level: $p.level, subscriber: $mine.subscriber, workflow: $targets.workflow, category: $targets.category,
        channels: $p.channels, quiet_hours: $p.quiet_hours, language: $p.language
    });
} COMMENT "Règle une préférence de la personne connectée ({ tenant : NONE ou son organisation active, level : subscriber_global, subscriber_category, subscriber_workflow ; workflow, category (clé), channels, quiet_hours }) ; son abonné auth:<identité> est créé au besoin. Sans permission (session lyxal_auth d'une personne)";

-- ----------------------------------------------------------------------------
-- fn::notification_unsubscribe : lien de désabonnement en un clic (décision B6)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_unsubscribe($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            subscriber: { pipeline: [{ rule: "record", options: { expected_table: "notification_subscriber" } }], required: true },
            category: { pipeline: [{ rule: "record", options: { expected_table: "notification_category" } }] },
            workflow: { pipeline: [{ rule: "record", options: { expected_table: "notification_workflow" } }] },
            channel: { pipeline: [{ rule: "enum", options: { allowed: ["email", "sms", "chat", "push", "in_app", "webhook"], case_sensitive: true } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid OR ($report.value.category IS NONE) = ($report.value.workflow IS NONE) {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::notification_can({ action: "worker" }) { RETURN fn::error_result("NOTIFICATION_PERMISSION_DENIED", $p.language, {}); };
    -- Abonné, catégorie ou parcours supprimés depuis l'envoi : lien sans effet
    LET $subscriber = (SELECT * FROM ONLY $p.subscriber);
    LET $target = (SELECT id FROM ONLY ($p.category ?? $p.workflow));
    IF $subscriber IS NONE OR $target IS NONE { RETURN fn::error_result("NOTIFICATION_UNSUBSCRIBE_INVALID", $p.language, {}); };
    LET $level = IF $p.category IS NONE { "subscriber_workflow" } ELSE { "subscriber_category" };
    LET $saved = fn::notification_preference_write({
        tenant: $subscriber.tenant, level: $level, subscriber: $subscriber.id,
        workflow: $p.workflow, category: $p.category, channels: object::from_entries([[$p.channel, false]])
    });
    IF $saved == NONE { RETURN fn::error_result("NOTIFICATION_WRITE_FORBIDDEN", $p.language, { table: "notification_preference" }); };
    LET $published = fn::event_publish({
        event_id: rand::uuid::v7(),
        event_type: "notification.subscriber.unsubscribed",
        producer: "lyxal_notification",
        source: $subscriber.id,
        payload: {
            subscriber_id: <string> $subscriber.id,
            tenant: IF $subscriber.tenant IS NONE { NONE } ELSE { <string> $subscriber.tenant },
            category_id: IF $p.category IS NONE { NONE } ELSE { <string> $p.category },
            workflow_id: IF $p.workflow IS NONE { NONE } ELSE { <string> $p.workflow },
            channel: $p.channel
        },
        metadata: {}
    });
    IF !$published.ok { THROW $published.error.code; };
    RETURN fn::result_ok({ subscriber: $subscriber.id, level: $level, channel: $p.channel });
} COMMENT "Désabonnement par lien ({ subscriber, category ou workflow, channel }), appelé par l'hôte après vérification du jeton : coupe le canal pour la catégorie (ou le parcours) de l'abonné ; publie notification.subscriber.unsubscribed. Lien d'un abonné, d'une catégorie ou d'un parcours supprimés : NOTIFICATION_UNSUBSCRIBE_INVALID. Session système de l'hôte (ou notification.worker)";
