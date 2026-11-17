-- ============================================================================
-- FONCTIONS : appareils push (Web Push, Firebase Cloud Messaging, Apple Push Notification service)
-- MODULE    : lyxal_notification
-- ============================================================================
-- Un appareil est une adresse de l'abonné du canal `push` (décision G1, table
-- notification_endpoint), inscrite par la personne elle-même depuis son navigateur ou son
-- application (session lyxal_auth) : 10 au plus par personne et par portée. Le jeton de
-- l'appareil (Web Push : l'adresse du service push donnée par le navigateur) et, pour Web Push,
-- les clés du navigateur (p256dh, auth) n'entrent en base que SCELLÉS par l'hôte (enc:v2, contexte
-- with_tenant(<organisation> ?? "lyxal_installation", "lyxal_notification",
-- "notification_endpoint", <empreinte du jeton>, "token" | "p256dh" | "auth")) ; la fonction reçoit
-- les valeurs en clair SEULEMENT pour les contrôler par lyxal_core (adresse HTTPS d'un service push
-- connu, forme du jeton et des clés) et n'enregistre que les valeurs scellées. L'empreinte
-- (SHA-256 du jeton, calculée par l'hôte avec lyxal_crypto) retrouve une inscription renvoyée :
-- l'appareil existant est mis à jour au lieu d'en créer un autre. Un gestionnaire ne voit que le
-- type d'appareil et sa date d'inscription ; le worker retire un appareil que le service déclare
-- invalide (décision G5, événement notification.endpoint.removed).

-- ----------------------------------------------------------------------------
-- fn::notification_device_fields (interne) : champs d'une inscription
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_device_fields($params: object) -> object {
    LET $sealed = { pipeline: [{ rule: "required_string", options: { min_length: 16, max_length: 8192 } }, { rule: "starts_with", options: { prefixes: ["enc:v2:"], case_sensitive: true, trim_value: false } }] };
    RETURN {
        tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
        device: { pipeline: [{ rule: "uuid_v7", options: { allow_string: true } }] },
        provider: { pipeline: [{ rule: "enum", options: { allowed: ["webpush", "fcm", "apns"], case_sensitive: true } }], required: true },
        platform: { pipeline: [{ rule: "enum", options: { allowed: ["web", "android", "ios"], case_sensitive: true } }] },
        name: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 128 } }] },
        -- En clair, contrôlés seulement : adresse Web Push, jeton FCM ou APNs, clés du navigateur
        -- (point P-256 non compressé et secret de 16 octets, en Base64url sans remplissage)
        url: { pipeline: [{ rule: "max_length", options: { max_length: 2048 } }, { rule: "http_url", options: { allow_http: false, allow_https: true } }] },
        token: { pipeline: [{ rule: "regex", options: { pattern: "^[A-Za-z0-9_:-]{32,4096}$" } }] },
        p256dh: { pipeline: [{ rule: "regex", options: { pattern: "^B[A-Za-z0-9_-]{86}$" } }] },
        auth: { pipeline: [{ rule: "regex", options: { pattern: "^[A-Za-z0-9_-]{22}$" } }] },
        fingerprint: { pipeline: [{ rule: "hexadecimal", options: { min_length: 64, max_length: 64, allow_prefix: false } }], required: true },
        -- Valeurs scellées par l'hôte : seules enregistrées
        sealed_token: object::extend($sealed, { required: true }),
        sealed_p256dh: $sealed,
        sealed_auth: $sealed,
        language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
    };
} COMMENT "Interne : champs contrôlés par lyxal_core d'une inscription d'appareil ({ tenant, device (clé UUID v7 choisie par l'hôte), provider : webpush, fcm, apns ; platform : web, android, ios ; name ; url (Web Push), token (FCM, APNs), p256dh, auth (Web Push) : en clair, contrôlés seulement ; fingerprint : SHA-256 du jeton en hexadécimal ; sealed_token, sealed_p256dh, sealed_auth : enc:v2 })";

-- ----------------------------------------------------------------------------
-- fn::notification_device_shape (interne) : forme propre au service, hôte et plateforme
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_device_shape($p: object) -> object {
    LET $invalid = |$reason| { code: "NOTIFICATION_DEVICE_INVALID", details: { reason: $reason } };
    LET $web = $p.provider = "webpush";
    -- Web Push : adresse du service push et clés du navigateur, en clair et scellées ; FCM, APNs :
    -- jeton seul
    LET $web_fields = [$p.url, $p.p256dh, $p.auth, $p.sealed_p256dh, $p.sealed_auth];
    IF $web AND (array::any($web_fields, |$v| $v IS NONE) OR $p.token IS NOT NONE) { RETURN $invalid("webpush_subscription"); };
    IF !$web AND ($p.token IS NONE OR array::any($web_fields, |$v| $v IS NOT NONE)) { RETURN $invalid("token"); };
    -- APNs : jeton hexadécimal (64 caractères aujourd'hui, davantage permis)
    IF $p.provider = "apns" AND !fn::validation_hexadecimal($p.token, 64, 200, false).valid { RETURN $invalid("token"); };
    -- Plateforme : web pour Web Push, ios pour APNs, android (par défaut) ou ios pour FCM
    LET $platforms = { webpush: ["web"], fcm: ["android", "ios"], apns: ["ios"] };
    LET $platform = $p.platform ?? $platforms[$p.provider][0];
    IF $platform NOT IN $platforms[$p.provider] { RETURN $invalid("platform"); };
    -- Hôte : celui du service push (Web Push : hôte de l'adresse, parmi les services connus)
    LET $host = IF $web { parse::url::host($p.url) } ELSE IF $p.provider = "fcm" { "fcm.googleapis.com" } ELSE { "api.push.apple.com" };
    LET $refusal = IF $host IS NONE { "host" } ELSE IF $web { fn::notification_endpoint_host_refusal({ provider: "webpush", host: $host }) } ELSE { NONE };
    IF $refusal IS NOT NONE { RETURN { code: "NOTIFICATION_DEVICE_INVALID", details: { reason: $refusal, host: $host } }; };
    RETURN { code: NONE, host: $host, platform: $platform };
} COMMENT "Interne : forme d'une inscription ($p : champs contrôlés) propre à son service (Web Push : adresse et clés du navigateur ; FCM, APNs : jeton seul, hexadécimal pour APNs), plateforme (web ; android par défaut ou ios pour FCM ; ios) et hôte (Web Push : service push connu, fn::notification_endpoint_host_refusal) : { code : NONE, host, platform } ou { code : NOTIFICATION_DEVICE_INVALID, details : { reason } }";

-- ----------------------------------------------------------------------------
-- fn::notification_device_view (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_device_view($params: object) -> object {
    LET $d = $params.device;
    RETURN IF $params.mine {
        $d.{ id, provider, platform, name, host, active, registered_at, created_at, last_result }
    } ELSE {
        $d.{ id, provider, platform, registered_at }
    };
} COMMENT "Interne : vue d'un appareil ({ device, mine }) : pour la personne, service, plateforme, nom, hôte du service, état, dates et dernier résultat ; pour un gestionnaire, le type (service et plateforme) et la date d'inscription seulement ; jamais le jeton, les clés ni l'empreinte";

-- ----------------------------------------------------------------------------
-- fn::notification_device_write (interne) : inscription ou mise à jour
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_device_write($params: object) -> object {
    LET $p = $params.p;
    LET $subscriber = $params.subscriber;
    -- Même jeton déjà inscrit : l'appareil est mis à jour (nouvelles valeurs scellées)
    LET $existing = (SELECT * FROM ONLY notification_endpoint WHERE subscriber = $subscriber.id AND channel = "push" AND fingerprint = $p.fingerprint LIMIT 1);
    IF $existing IS NOT NONE {
        IF $existing.provider != $p.provider { RETURN { code: "NOTIFICATION_DEVICE_INVALID", details: { reason: "provider" } }; };
        LET $updated = (UPDATE ONLY $existing.id SET token = $p.sealed_token, p256dh = $p.sealed_p256dh, auth = $p.sealed_auth,
            platform = $params.platform, name = $p.name ?? name, active = true, registered_at = time::now(), last_result = NONE);
        RETURN IF $updated == NONE { { code: "NOTIFICATION_WRITE_FORBIDDEN", details: { table: "notification_endpoint" } } }
            ELSE { { code: NONE, created: false, device: fn::notification_device_view({ device: $updated, mine: true }) } };
    };
    -- Dix appareils au plus par personne et par portée
    IF count(SELECT VALUE id FROM notification_endpoint WHERE subscriber = $subscriber.id AND channel = "push") >= 10 {
        RETURN { code: "NOTIFICATION_DEVICE_LIMIT", details: { max: 10 } };
    };
    LET $names = { web: "Navigateur", android: "Android", ios: "iOS" };
    LET $key = $p.device ?? string::replace(<string> rand::uuid::v7(), "-", "");
    LET $created = (INSERT IGNORE INTO notification_endpoint {
        id: type::record("notification_endpoint", string::replace(<string> $key, "-", "")),
        tenant: $subscriber.tenant, subscriber: $subscriber.id, channel: "push", provider: $p.provider,
        platform: $params.platform, name: $p.name ?? $names[$params.platform], host: $params.host,
        fingerprint: $p.fingerprint, token: $p.sealed_token, p256dh: $p.sealed_p256dh, auth: $p.sealed_auth,
        registered_at: time::now(), active: true
    });
    IF array::len($created) = 0 {
        -- Inscription concurrente du même appareil (index unique) : elle a gagné
        LET $raced = (SELECT * FROM ONLY notification_endpoint WHERE subscriber = $subscriber.id AND channel = "push" AND fingerprint = $p.fingerprint LIMIT 1);
        RETURN IF $raced IS NONE { { code: "NOTIFICATION_WRITE_FORBIDDEN", details: { table: "notification_endpoint" } } }
            ELSE { { code: NONE, created: false, device: fn::notification_device_view({ device: $raced, mine: true }) } };
    };
    RETURN { code: NONE, created: true, device: fn::notification_device_view({ device: $created[0], mine: true }) };
} COMMENT "Interne : inscrit un appareil ({ p : champs contrôlés, subscriber, host, platform }) ou met à jour celui de même empreinte (jeton et clés scellés, plateforme, nom fourni, actif, date d'inscription) ; 10 appareils au plus (NOTIFICATION_DEVICE_LIMIT) ; écritures vérifiées. { code, details, created, device }";

-- ----------------------------------------------------------------------------
-- fn::notification_my_device_register
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_my_device_register($params: object) {
    LET $report = fn::validation_object_execute($params, { fields: fn::notification_device_fields({}), unknown_keys: "reject" }, 60);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_DEVICE_INVALID", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $shape = fn::notification_device_shape($p);
    IF $shape.code IS NOT NONE { RETURN fn::error_result($shape.code, $p.language, $shape.details); };
    LET $mine = fn::notification_my_subscriber({ tenant: $p.tenant, create: true });
    IF $mine.code IS NOT NONE { RETURN fn::error_result($mine.code, $p.language, {}); };
    LET $written = fn::notification_device_write({ p: $p, subscriber: $mine.subscriber, host: $shape.host, platform: $shape.platform });
    IF $written.code IS NOT NONE { RETURN fn::error_result($written.code, $p.language, $written.details); };
    RETURN fn::result_ok({ created: $written.created, device: $written.device });
} COMMENT "Inscrit un appareil de la personne connectée ({ tenant : NONE ou son organisation active ; device, provider : webpush, fcm, apns ; platform, name ; url, p256dh, auth (Web Push) ou token (FCM, APNs) en clair, contrôlés seulement ; fingerprint : SHA-256 du jeton ; sealed_token, sealed_p256dh, sealed_auth : scellés par l'hôte }) pour son abonné auth:<identité>, créé au besoin ; une inscription de même empreinte met l'appareil à jour (created faux). Rend { created, device } sans jeton ni clé. Route POST /api/v1/notification/my/devices de l'hôte (scellement). Sans permission (session lyxal_auth d'une personne)";

-- ----------------------------------------------------------------------------
-- fn::notification_my_device_list, _delete
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_my_device_list($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
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
    LET $rows = (SELECT * FROM notification_endpoint WHERE subscriber = $mine.subscriber.id AND channel = "push" ORDER BY created_at ASC);
    RETURN fn::result_ok(array::map($rows, |$d| fn::notification_device_view({ device: $d, mine: true })));
} COMMENT "Appareils push de la personne connectée ({ tenant }), sans jeton ni clé. Sans permission (session lyxal_auth d'une personne)";

DEFINE FUNCTION OVERWRITE fn::notification_my_device_delete($params: object) {
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
    LET $changed = fn::notification_my_endpoint_change({ action: "delete", p: $report.value, push: true });
    RETURN IF $changed.code IS NONE { fn::result_ok($changed.data) } ELSE { fn::error_result($changed.code, $report.value.language, $changed.details) };
} COMMENT "Retire un appareil push de la personne connectée ({ tenant, endpoint }) ; celui d'une autre personne est introuvable (NOTIFICATION_DEVICE_NOT_FOUND). Sans permission (session lyxal_auth d'une personne)";

-- ----------------------------------------------------------------------------
-- fn::notification_device_list (gestion)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_device_list($params: object) {
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
    IF $subscriber IS NONE { RETURN fn::error_result("NOTIFICATION_SUBSCRIBER_NOT_FOUND", $p.language, { subscriber_id: $p.subscriber_id }); };
    LET $rows = (SELECT * FROM notification_endpoint WHERE subscriber = $subscriber.id AND channel = "push" ORDER BY created_at ASC);
    RETURN fn::result_ok(array::map($rows, |$d| fn::notification_device_view({ device: $d, mine: false })));
} COMMENT "Appareils push d'un abonné ({ tenant, subscriber_id }) : type (service, plateforme) et date d'inscription seulement. Permission notification.read";

-- ----------------------------------------------------------------------------
-- fn::notification_device_remove (worker) : appareil déclaré invalide par le service (G5)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_device_remove($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            endpoint: { pipeline: [{ rule: "record", options: { expected_table: "notification_endpoint" } }], required: true },
            reason: { pipeline: [{ rule: "enum", options: { allowed: ["expired", "invalid"], case_sensitive: true } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::notification_can({ action: "worker" }) { RETURN fn::error_result("NOTIFICATION_PERMISSION_DENIED", $p.language, {}); };
    LET $device = (SELECT id, channel FROM ONLY $p.endpoint);
    IF $device == NONE OR $device.channel != "push" { RETURN fn::error_result("NOTIFICATION_DEVICE_NOT_FOUND", $p.language, {}); };
    -- Motif posé avant la suppression : l'événement publié est notification.endpoint.removed
    LET $marked = (UPDATE ONLY $device.id SET removed_reason = $p.reason);
    IF $marked == NONE { RETURN fn::error_result("NOTIFICATION_WRITE_FORBIDDEN", $p.language, { table: "notification_endpoint" }); };
    LET $deleted = (DELETE $device.id RETURN BEFORE);
    IF array::len($deleted) = 0 { RETURN fn::error_result("NOTIFICATION_WRITE_FORBIDDEN", $p.language, { table: "notification_endpoint" }); };
    RETURN fn::result_ok({ removed: $device.id, reason: $p.reason });
} COMMENT "Retire un appareil push que son service déclare invalide ({ endpoint, reason : expired (Web Push 404 ou 410, FCM UNREGISTERED, APNs 410), invalid (FCM INVALID_ARGUMENT sur le jeton, APNs BadDeviceToken) }) : événement notification.endpoint.removed (identifiants seulement). Un appareil déjà retiré : NOTIFICATION_DEVICE_NOT_FOUND. Permission notification.worker";

-- ----------------------------------------------------------------------------
-- fn::notification_push_links_check (worker) : liens rendus d'un message push
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_push_links_check($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            link: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 2048 } }] },
            icon: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 2048 } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::notification_can({ action: "worker" }) { RETURN fn::error_result("NOTIFICATION_PERMISSION_DENIED", $p.language, {}); };
    -- Règles des liens du fil (décision F3) : chemin de l'application ou adresse HTTPS
    RETURN fn::result_ok({ refused: array::filter(["link", "icon"], |$f| $p[$f] IS NOT NONE AND !fn::notification_link_valid({ value: $p[$f], template: false })) });
} COMMENT "Contrôle les liens rendus d'un message push ({ link, icon }) avant l'envoi, par les règles des liens du fil (fn::notification_link_valid : chemin de l'application, jamais // ni /\\, ou adresse HTTPS ; javascript:, data: et tout autre schéma refusés) : { refused : champs refusés }. Un lien refusé fait échouer l'étape sans envoi. Permission notification.worker";

-- ----------------------------------------------------------------------------
-- fn::notification_push_vapid_key (hôte) : clé publique VAPID d'une portée
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_push_vapid_key($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::notification_can({ action: "worker" }) { RETURN fn::error_result("NOTIFICATION_PERMISSION_DENIED", $p.language, {}); };
    -- Intégration Web Push active de l'organisation, sinon de l'installation : la principale
    -- d'abord, puis par priorité (ordre D1, sans condition : aucun envoi n'est encore connu)
    LET $find = |$scope: string| (SELECT * FROM notification_integration
        WHERE scope_key = $scope AND channel = "push" AND provider = "webpush" AND active = true AND settings.vapid_public_key IS NOT NONE
        ORDER BY primary DESC, priority ASC, key ASC LIMIT 1);
    LET $own = IF $p.tenant IS NONE { [] } ELSE { $find(<string> record::id($p.tenant)) };
    LET $installation = $find("installation");
    LET $chosen = IF array::len($own) > 0 { $own[0] } ELSE { $installation[0] };
    IF $chosen IS NONE { RETURN fn::error_result("NOTIFICATION_INTEGRATION_UNAVAILABLE", $p.language, { channel: "push", provider: "webpush" }); };
    RETURN fn::result_ok({ public_key: $chosen.settings.vapid_public_key, integration: $chosen.id });
} COMMENT "Clé publique VAPID donnée aux navigateurs ({ tenant : organisation active de la personne ou NONE }) : celle de l'intégration Web Push active de l'organisation, sinon de l'installation (principale d'abord, puis par priorité) ; aucune : NOTIFICATION_INTEGRATION_UNAVAILABLE. Appelée par la route GET /api/v1/notification/push/vapid-key de l'hôte après le contrôle de la personne. Session système de l'hôte (notification.worker)";
