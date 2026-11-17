-- ============================================================================
-- FONCTIONS : adresses des abonnés pour la messagerie (chat) et l'adresse web (webhook)
-- MODULE    : lyxal_notification
-- ============================================================================
-- Une adresse de webhook ou une adresse web est un secret (décision E2) : l'hôte la scelle
-- (enc:v2, contexte with_tenant(<organisation>, "lyxal_notification", "notification_endpoint",
-- <clé de l'adresse>, "url")) AVANT l'appel ; la fonction reçoit l'adresse en clair seulement
-- pour la contrôler par lyxal_core (HTTPS, hôte du service) et n'enregistre que la valeur
-- scellée et l'hôte. La clé de signature d'une adresse web est tirée et scellée de même par
-- l'hôte (champ "signing_secret"), montrée une seule fois. Telegram : identifiant du salon seul.
-- Hôtes (décision E3) : Slack, Teams, Discord et Google Chat sur leurs hôtes officiels ;
-- Mattermost et adresse web sur tout hôte public (ni adresse IP, ni nom local), dans la liste
-- allowed_hosts de l'installation si elle est réglée. L'hôte est revérifié après résolution à
-- chaque envoi (worker). Droits : notification.manage (gestion) ou la personne connectée pour ses
-- propres adresses (notification_my_endpoint_*, comme ses préférences).

-- ----------------------------------------------------------------------------
-- fn::notification_endpoint_official_hosts (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_endpoint_official_hosts($provider: string) -> option<object> {
    RETURN IF $provider = "slack" { { exact: ["hooks.slack.com"], suffixes: [] } }
        -- Teams : connecteurs Office 365 (<locataire>.webhook.office.com) et flux de travail
        -- Power Automate (prod-<n>.<région>.logic.azure.com, <environnement>.environment.api.powerplatform.com)
        ELSE IF $provider = "teams" { { exact: [], suffixes: [".webhook.office.com", ".logic.azure.com", ".environment.api.powerplatform.com"] } }
        ELSE IF $provider = "discord" { { exact: ["discord.com", "discordapp.com"], suffixes: [] } }
        ELSE IF $provider = "google_chat" { { exact: ["chat.googleapis.com"], suffixes: [] } }
        ELSE IF $provider = "telegram" { { exact: ["api.telegram.org"], suffixes: [] } }
        ELSE { NONE };
} COMMENT "Interne : hôtes officiels d'un service ({ exact, suffixes }) ; NONE : tout hôte public (mattermost, webhook)";

-- ----------------------------------------------------------------------------
-- fn::notification_endpoint_host_refusal (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_endpoint_host_refusal($params: object) -> option<string> {
    LET $host = $params.host;
    -- Ni adresse IP, ni nom local : seul un nom est accepté, résolu et vérifié à chaque envoi
    IF fn::validation_ip(string::replace(string::replace($host, "[", ""), "]", ""), NONE).valid { RETURN "ip_address"; };
    IF $host = "localhost" OR fn::validation_ends_with($host, [".localhost", ".local", ".internal", ".lan", ".home.arpa"], false, false).valid {
        RETURN "local_host";
    };
    IF !fn::validation_hostname($host, false).valid { RETURN "host"; };
    LET $official = fn::notification_endpoint_official_hosts($params.provider);
    IF $official IS NOT NONE {
        LET $suffix = array::len($official.suffixes) > 0 AND fn::validation_ends_with($host, $official.suffixes, false, false).valid;
        RETURN IF $host IN $official.exact OR $suffix { NONE } ELSE { "unofficial_host" };
    };
    -- Tout hôte public, dans la liste de l'installation si elle est réglée
    LET $allowed = fn::notification_settings_effective({}).allowed_hosts;
    RETURN IF array::len($allowed) = 0 OR $host IN $allowed { NONE } ELSE { "host_not_allowed" };
} COMMENT "Interne : NONE si l'hôte ({ provider, host }) convient au service (hôtes officiels de Slack, Teams, Discord, Google Chat ; tout hôte public pour Mattermost et l'adresse web, dans allowed_hosts de l'installation si réglée) ; sinon le motif (ip_address, host, local_host, unofficial_host, host_not_allowed)";

-- ----------------------------------------------------------------------------
-- fn::notification_endpoint_fields (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_endpoint_fields($create: bool) -> object {
    LET $sealed = { pipeline: [{ rule: "required_string", options: { min_length: 16, max_length: 8192 } }, { rule: "starts_with", options: { prefixes: ["enc:v2:"], case_sensitive: true, trim_value: false } }] };
    RETURN IF $create {
        {
            endpoint: { pipeline: [{ rule: "uuid_v7", options: { allow_string: true } }] },
            channel: { pipeline: [{ rule: "enum", options: { allowed: ["chat", "webhook"], case_sensitive: true } }], required: true },
            provider: { pipeline: [{ rule: "enum", options: { allowed: ["slack", "teams", "discord", "mattermost", "google_chat", "telegram", "webhook"], case_sensitive: true } }], required: true },
            name: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 128 } }], required: true },
            url: { pipeline: [{ rule: "max_length", options: { max_length: 2048 } }, { rule: "http_url", options: { allow_http: false, allow_https: true } }] },
            sealed_url: $sealed,
            signing_secret: $sealed,
            chat_id: { pipeline: [{ rule: "regex", options: { pattern: "^(-?[0-9]{1,20}|@[A-Za-z][A-Za-z0-9_]{4,31})$" } }] },
            active: { pipeline: [{ rule: "boolean" }], default: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        }
    } ELSE {
        {
            endpoint: { pipeline: [{ rule: "record", options: { expected_table: "notification_endpoint" } }], required: true },
            name: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 128 } }] },
            chat_id: { pipeline: [{ rule: "regex", options: { pattern: "^(-?[0-9]{1,20}|@[A-Za-z][A-Za-z0-9_]{4,31})$" } }] },
            active: { pipeline: [{ rule: "boolean" }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        }
    };
} COMMENT "Interne : champs contrôlés par lyxal_core pour la création ($create : endpoint (clé UUID v7 choisie par l'hôte), channel, provider, name, url (en clair, contrôlée seulement), sealed_url et signing_secret (enc:v2), chat_id, active) ou la modification (endpoint, name, chat_id, active)";

-- ----------------------------------------------------------------------------
-- fn::notification_endpoint_view (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_endpoint_view($endpoint: object) -> object {
    RETURN object::extend($endpoint.{ id, tenant, subscriber, channel, provider, name, host, chat_id, active, last_result, created_at, updated_at }, {
        signed: $endpoint.secret_rotated_at IS NOT NONE,
        secret_rotated_at: $endpoint.secret_rotated_at
    });
} COMMENT "Interne : vue d'une adresse (hôte, jamais l'adresse complète ni la clé de signature)";

-- ----------------------------------------------------------------------------
-- fn::notification_endpoint_write (interne) : création d'une adresse contrôlée
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_endpoint_write($params: object) -> object {
    LET $p = $params.p;
    LET $subscriber = $params.subscriber;
    LET $invalid = |$reason| { code: "NOTIFICATION_ENDPOINT_INVALID", details: { reason: $reason } };
    -- Service propre au canal ; Telegram : identifiant du salon seul ; sinon adresse scellée
    LET $chat_providers = ["slack", "teams", "discord", "mattermost", "google_chat", "telegram"];
    IF ($p.channel = "chat" AND $p.provider NOT IN $chat_providers) OR ($p.channel = "webhook" AND $p.provider != "webhook") {
        RETURN $invalid("provider");
    };
    LET $telegram = $p.provider = "telegram";
    IF $telegram AND ($p.chat_id IS NONE OR $p.url IS NOT NONE OR $p.sealed_url IS NOT NONE) { RETURN $invalid("telegram_chat_id"); };
    IF !$telegram AND ($p.chat_id IS NOT NONE OR $p.url IS NONE OR $p.sealed_url IS NONE) { RETURN $invalid("sealed_url"); };
    IF ($p.channel = "webhook") != ($p.signing_secret IS NOT NONE) { RETURN $invalid("signing_secret"); };
    LET $host = IF $telegram { "api.telegram.org" } ELSE { parse::url::host($p.url) };
    LET $refusal = IF $host IS NONE { "host" } ELSE { fn::notification_endpoint_host_refusal({ provider: $p.provider, host: $host }) };
    IF $refusal IS NOT NONE { RETURN { code: "NOTIFICATION_ENDPOINT_INVALID", details: { reason: $refusal, host: $host } }; };
    -- Dix adresses au plus par abonné et par canal
    IF count(SELECT VALUE id FROM notification_endpoint WHERE subscriber = $subscriber.id AND channel = $p.channel) >= 10 {
        RETURN $invalid("limit");
    };
    LET $key = $p.endpoint ?? string::replace(<string> rand::uuid::v7(), "-", "");
    LET $created = (INSERT IGNORE INTO notification_endpoint {
        id: type::record("notification_endpoint", string::replace(<string> $key, "-", "")),
        tenant: $subscriber.tenant, subscriber: $subscriber.id, channel: $p.channel, provider: $p.provider,
        name: $p.name, host: $host, url: $p.sealed_url, chat_id: $p.chat_id,
        signing_secret: $p.signing_secret,
        secret_rotated_at: IF $p.signing_secret IS NONE { NONE } ELSE { time::now() },
        active: $p.active ?? true
    });
    IF array::len($created) = 0 {
        RETURN { code: "NOTIFICATION_WRITE_FORBIDDEN", details: { table: "notification_endpoint" } };
    };
    RETURN { code: NONE, endpoint: fn::notification_endpoint_view($created[0]) };
} COMMENT "Interne : crée l'adresse ({ p : champs contrôlés de création, subscriber }) après les contrôles propres au service (Telegram : chat_id seul ; autres : adresse scellée et en clair contrôlée ; adresse web : clé de signature scellée), l'hôte (fn::notification_endpoint_host_refusal) et la limite de 10 adresses par canal. { code, details, endpoint }";

-- ----------------------------------------------------------------------------
-- fn::notification_endpoint_find (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_endpoint_find($params: object) -> any {
    LET $endpoint = (SELECT * FROM ONLY $params.endpoint);
    IF $endpoint == NONE { RETURN NONE; };
    -- Gestion : adresse de la portée demandée ; personne connectée : adresse de son abonné
    IF $params.subscriber IS NOT NONE { RETURN IF $endpoint.subscriber = $params.subscriber { $endpoint } ELSE { NONE }; };
    RETURN IF $endpoint.tenant = $params.tenant { $endpoint } ELSE { NONE };
} COMMENT "Interne : adresse ({ endpoint, tenant } ou { endpoint, subscriber }) de cette portée ou de cet abonné, sinon NONE";

-- ----------------------------------------------------------------------------
-- fn::notification_endpoint_change (interne) : modification, suppression, nouvelle clé
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_endpoint_change($params: object) -> object {
    LET $current = $params.endpoint;
    LET $p = $params.p;
    IF $params.action = "delete" {
        LET $deleted = (DELETE $current.id RETURN BEFORE);
        RETURN IF array::len($deleted) = 0 { { code: "NOTIFICATION_WRITE_FORBIDDEN", details: { table: "notification_endpoint" } } } ELSE { { code: NONE, data: { deleted: $current.id } } };
    };
    IF $params.action = "rotate" {
        IF $current.channel != "webhook" { RETURN { code: "NOTIFICATION_ENDPOINT_INVALID", details: { reason: "signing_secret" } }; };
        LET $rotated = (UPDATE ONLY $current.id SET signing_secret = $p.signing_secret, secret_rotated_at = time::now());
        RETURN IF $rotated == NONE { { code: "NOTIFICATION_WRITE_FORBIDDEN", details: { table: "notification_endpoint" } } } ELSE { { code: NONE, data: fn::notification_endpoint_view($rotated) } };
    };
    IF $p.chat_id IS NOT NONE AND $current.provider != "telegram" { RETURN { code: "NOTIFICATION_ENDPOINT_INVALID", details: { reason: "telegram_chat_id" } }; };
    LET $updated = (UPDATE ONLY $current.id SET name = $p.name ?? name, active = $p.active ?? active, chat_id = $p.chat_id ?? chat_id);
    RETURN IF $updated == NONE { { code: "NOTIFICATION_WRITE_FORBIDDEN", details: { table: "notification_endpoint" } } } ELSE { { code: NONE, data: fn::notification_endpoint_view($updated) } };
} COMMENT "Interne : modifie ({ action : update ; p : name, active, chat_id }), supprime (delete) ou renouvelle la clé de signature d'une adresse web (rotate ; p.signing_secret scellée par l'hôte) ; écritures vérifiées. { code, details, data }";

-- ----------------------------------------------------------------------------
-- fn::notification_endpoint_create
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_endpoint_create($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: object::extend(fn::notification_endpoint_fields(true), {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            subscriber_id: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 264 } }], required: true }
        }),
        unknown_keys: "reject"
    }, 60);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::notification_can({ action: "manage", tenant: $p.tenant }) { RETURN fn::error_result("NOTIFICATION_PERMISSION_DENIED", $p.language, {}); };
    LET $subscriber = fn::notification_subscriber_find({ tenant: $p.tenant, subscriber_id: $p.subscriber_id });
    IF $subscriber IS NONE { RETURN fn::error_result("NOTIFICATION_SUBSCRIBER_NOT_FOUND", $p.language, { subscriber_id: $p.subscriber_id }); };
    LET $written = fn::notification_endpoint_write({ p: $p, subscriber: $subscriber });
    IF $written.code IS NOT NONE { RETURN fn::error_result($written.code, $p.language, $written.details); };
    RETURN fn::result_ok($written.endpoint);
} COMMENT "Crée une adresse de messagerie ou web d'un abonné ({ tenant, subscriber_id, endpoint, channel : chat, webhook ; provider : slack, teams, discord, mattermost, google_chat, telegram, webhook ; name, url (en clair, contrôlée seulement : HTTPS, hôte du service), sealed_url (enc:v2, scellée par l'hôte), signing_secret (adresse web, enc:v2), chat_id (Telegram), active }) : seules la valeur scellée et l'hôte sont enregistrés. Appelée par la route POST /api/v1/notification/endpoints de l'hôte (Telegram : directement). Permission notification.manage";

-- ----------------------------------------------------------------------------
-- fn::notification_endpoint_update, _delete, _rotate_secret
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_endpoint_update($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: object::extend(fn::notification_endpoint_fields(false), {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] }
        }),
        unknown_keys: "reject"
    }, 30);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::notification_can({ action: "manage", tenant: $p.tenant }) { RETURN fn::error_result("NOTIFICATION_PERMISSION_DENIED", $p.language, {}); };
    LET $current = fn::notification_endpoint_find({ endpoint: $p.endpoint, tenant: $p.tenant });
    IF $current IS NONE { RETURN fn::error_result("NOTIFICATION_ENDPOINT_NOT_FOUND", $p.language, {}); };
    LET $changed = fn::notification_endpoint_change({ action: "update", endpoint: $current, p: $p });
    RETURN IF $changed.code IS NONE { fn::result_ok($changed.data) } ELSE { fn::error_result($changed.code, $p.language, $changed.details) };
} COMMENT "Modifie une adresse ({ tenant, endpoint, name, active, chat_id (Telegram) }) ; l'adresse elle-même ne change pas (en créer une autre). Permission notification.manage";

DEFINE FUNCTION OVERWRITE fn::notification_endpoint_delete($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            endpoint: { pipeline: [{ rule: "record", options: { expected_table: "notification_endpoint" } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::notification_can({ action: "manage", tenant: $p.tenant }) { RETURN fn::error_result("NOTIFICATION_PERMISSION_DENIED", $p.language, {}); };
    LET $current = fn::notification_endpoint_find({ endpoint: $p.endpoint, tenant: $p.tenant });
    IF $current IS NONE { RETURN fn::error_result("NOTIFICATION_ENDPOINT_NOT_FOUND", $p.language, {}); };
    LET $changed = fn::notification_endpoint_change({ action: "delete", endpoint: $current, p: $p });
    RETURN IF $changed.code IS NONE { fn::result_ok($changed.data) } ELSE { fn::error_result($changed.code, $p.language, $changed.details) };
} COMMENT "Supprime une adresse ({ tenant, endpoint }) ; ses messages gardent l'hôte. Permission notification.manage";

DEFINE FUNCTION OVERWRITE fn::notification_endpoint_rotate_secret($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            endpoint: { pipeline: [{ rule: "record", options: { expected_table: "notification_endpoint" } }], required: true },
            signing_secret: object::extend(fn::notification_endpoint_fields(true).signing_secret, { required: true }),
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::notification_can({ action: "manage", tenant: $p.tenant }) { RETURN fn::error_result("NOTIFICATION_PERMISSION_DENIED", $p.language, {}); };
    LET $current = fn::notification_endpoint_find({ endpoint: $p.endpoint, tenant: $p.tenant });
    IF $current IS NONE { RETURN fn::error_result("NOTIFICATION_ENDPOINT_NOT_FOUND", $p.language, {}); };
    LET $changed = fn::notification_endpoint_change({ action: "rotate", endpoint: $current, p: $p });
    RETURN IF $changed.code IS NONE { fn::result_ok($changed.data) } ELSE { fn::error_result($changed.code, $p.language, $changed.details) };
} COMMENT "Remplace la clé de signature d'une adresse web ({ tenant, endpoint, signing_secret : nouvelle clé scellée par l'hôte, montrée une seule fois par lui }). Route POST /api/v1/notification/endpoints/{adresse}/rotate de l'hôte. Permission notification.manage";

-- ----------------------------------------------------------------------------
-- fn::notification_endpoint_list
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_endpoint_list($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            subscriber_id: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 264 } }] },
            channel: { pipeline: [{ rule: "enum", options: { allowed: ["chat", "webhook"], case_sensitive: true } }] },
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
    LET $subscriber = IF $p.subscriber_id IS NONE { NONE } ELSE { fn::notification_subscriber_find({ tenant: $p.tenant, subscriber_id: $p.subscriber_id }) };
    IF $p.subscriber_id IS NOT NONE AND $subscriber IS NONE { RETURN fn::error_result("NOTIFICATION_SUBSCRIBER_NOT_FOUND", $p.language, { subscriber_id: $p.subscriber_id }); };
    LET $rows = (SELECT * FROM notification_endpoint
        WHERE scope_key = $scope AND ($subscriber IS NONE OR subscriber = $subscriber.id) AND ($p.channel IS NONE OR channel = $p.channel)
        ORDER BY created_at ASC);
    RETURN fn::result_ok(array::map($rows, |$e| fn::notification_endpoint_view($e)));
} COMMENT "Adresses d'une portée ({ tenant, subscriber_id, channel }), sans l'adresse complète ni la clé de signature (hôte seulement). Permission notification.read";

-- ----------------------------------------------------------------------------
-- fn::notification_my_endpoint_* : la personne connectée gère ses propres adresses
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_my_endpoint_create($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: object::extend(fn::notification_endpoint_fields(true), {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] }
        }),
        unknown_keys: "reject"
    }, 60);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $mine = fn::notification_my_subscriber({ tenant: $p.tenant, create: true });
    IF $mine.code IS NOT NONE { RETURN fn::error_result($mine.code, $p.language, {}); };
    LET $written = fn::notification_endpoint_write({ p: $p, subscriber: $mine.subscriber });
    IF $written.code IS NOT NONE { RETURN fn::error_result($written.code, $p.language, $written.details); };
    RETURN fn::result_ok($written.endpoint);
} COMMENT "Crée une adresse de la personne connectée ({ tenant : NONE ou son organisation active ; mêmes champs que notification_endpoint_create, sans subscriber_id }) pour son abonné auth:<identité>, créé au besoin. Route POST /api/v1/notification/my/endpoints de l'hôte (scellement). Sans permission (session lyxal_auth d'une personne)";

DEFINE FUNCTION OVERWRITE fn::notification_my_endpoint_list($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            channel: { pipeline: [{ rule: "enum", options: { allowed: ["chat", "webhook"], case_sensitive: true } }] },
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
    IF $mine.subscriber IS NONE { RETURN fn::result_ok([]); };
    LET $rows = (SELECT * FROM notification_endpoint WHERE subscriber = $mine.subscriber.id AND ($p.channel IS NONE OR channel = $p.channel) ORDER BY created_at ASC);
    RETURN fn::result_ok(array::map($rows, |$e| fn::notification_endpoint_view($e)));
} COMMENT "Adresses de la personne connectée ({ tenant, channel }), hôte seulement. Sans permission (session lyxal_auth d'une personne)";

DEFINE FUNCTION OVERWRITE fn::notification_my_endpoint_change($params: object) -> object {
    LET $mine = fn::notification_my_subscriber({ tenant: $params.p.tenant, create: false });
    IF $mine.code IS NOT NONE { RETURN { code: $mine.code, details: {} }; };
    LET $current = IF $mine.subscriber IS NONE { NONE } ELSE { fn::notification_endpoint_find({ endpoint: $params.p.endpoint, subscriber: $mine.subscriber.id }) };
    IF $current IS NONE { RETURN { code: "NOTIFICATION_ENDPOINT_NOT_FOUND", details: {} }; };
    RETURN fn::notification_endpoint_change({ action: $params.action, endpoint: $current, p: $params.p });
} COMMENT "Interne : modification, suppression ou nouvelle clé ({ action, p }) d'une adresse de la personne connectée ; une adresse d'un autre abonné est introuvable";

DEFINE FUNCTION OVERWRITE fn::notification_my_endpoint_update($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: object::extend(fn::notification_endpoint_fields(false), {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] }
        }),
        unknown_keys: "reject"
    }, 30);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $changed = fn::notification_my_endpoint_change({ action: "update", p: $report.value });
    RETURN IF $changed.code IS NONE { fn::result_ok($changed.data) } ELSE { fn::error_result($changed.code, $report.value.language, $changed.details) };
} COMMENT "Modifie une adresse de la personne connectée ({ tenant, endpoint, name, active, chat_id }). Sans permission (session lyxal_auth d'une personne)";

DEFINE FUNCTION OVERWRITE fn::notification_my_endpoint_delete($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            endpoint: { pipeline: [{ rule: "record", options: { expected_table: "notification_endpoint" } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $changed = fn::notification_my_endpoint_change({ action: "delete", p: $report.value });
    RETURN IF $changed.code IS NONE { fn::result_ok($changed.data) } ELSE { fn::error_result($changed.code, $report.value.language, $changed.details) };
} COMMENT "Supprime une adresse de la personne connectée ({ tenant, endpoint }). Sans permission (session lyxal_auth d'une personne)";

DEFINE FUNCTION OVERWRITE fn::notification_my_endpoint_rotate_secret($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            endpoint: { pipeline: [{ rule: "record", options: { expected_table: "notification_endpoint" } }], required: true },
            signing_secret: object::extend(fn::notification_endpoint_fields(true).signing_secret, { required: true }),
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $changed = fn::notification_my_endpoint_change({ action: "rotate", p: $report.value });
    RETURN IF $changed.code IS NONE { fn::result_ok($changed.data) } ELSE { fn::error_result($changed.code, $report.value.language, $changed.details) };
} COMMENT "Remplace la clé de signature d'une adresse web de la personne connectée ({ tenant, endpoint, signing_secret scellée par l'hôte }). Route POST /api/v1/notification/my/endpoints/{adresse}/rotate. Sans permission (session lyxal_auth d'une personne)";

-- ----------------------------------------------------------------------------
-- fn::notification_endpoint_resolve (hôte) : adresse scellée pour l'essai d'une intégration
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_endpoint_resolve($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            integration: { pipeline: [{ rule: "record", options: { expected_table: "notification_integration" } }], required: true },
            endpoint: { pipeline: [{ rule: "record", options: { expected_table: "notification_endpoint" } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::notification_can({ action: "worker" }) { RETURN fn::error_result("NOTIFICATION_PERMISSION_DENIED", $p.language, {}); };
    LET $integration = (SELECT * FROM ONLY $p.integration);
    LET $endpoint = (SELECT * FROM ONLY $p.endpoint);
    -- Même canal et même service ; une adresse de l'organisation de l'intégration, ou toute
    -- adresse pour une intégration de l'installation (repli de toutes les organisations)
    IF $integration == NONE OR $endpoint == NONE OR $endpoint.channel != $integration.channel OR $endpoint.provider != $integration.provider
        OR ($integration.tenant IS NOT NONE AND $endpoint.tenant != $integration.tenant) {
        RETURN fn::error_result("NOTIFICATION_ENDPOINT_NOT_FOUND", $p.language, {});
    };
    RETURN fn::result_ok(fn::notification_endpoint_payload({ endpoint: $endpoint, integration: $integration }));
} COMMENT "Adresse scellée d'un essai d'intégration de messagerie ou web ({ integration, endpoint } : même canal, même service, même organisation) remise à l'hôte après le contrôle de l'essai au nom de l'appelant (fn::notification_integration_test). Session système de l'hôte (notification.worker)";

-- ----------------------------------------------------------------------------
-- fn::notification_endpoint_payload (interne) : adresse remise au worker
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_endpoint_payload($params: object) -> object {
    LET $e = $params.endpoint;
    RETURN {
        id: $e.id,
        tenant_key: IF $e.tenant IS NONE { NONE } ELSE { <string> record::id($e.tenant) },
        provider: $e.provider,
        host: $e.host,
        url: $e.url,
        chat_id: $e.chat_id,
        signing_secret: $e.signing_secret,
        integration: fn::notification_integration_payload($params.integration)
    };
} COMMENT "Interne : adresse remise au worker ({ endpoint, integration }) : service, hôte, adresse et clé de signature scellées (ouvertes en mémoire par le worker seulement), identifiant du salon Telegram, intégration de l'envoi";
