-- ============================================================================
-- FONCTIONS : intégrations (fournisseurs par canal) et retours des fournisseurs
-- MODULE    : lyxal_notification
-- ============================================================================
-- Une intégration choisit le fournisseur d'un canal pour une organisation ou pour
-- l'installation (repli de toutes les organisations). Elle ne garde que le chemin de ses secrets
-- dans lyxal_secrets (dossier `notification/` de sa portée) ; la valeur est lue par le worker,
-- par le chemin tracé du coffre-fort. Créer ou modifier une intégration exige, en plus de la
-- gestion des notifications, le droit de LIRE ce secret (décision D2) : secrets.value.read dans
-- l'organisation, ou secrets.installation.manage pour l'installation ; sinon un gestionnaire des
-- notifications pourrait faire envoyer un secret vers un serveur de son choix.
-- Choix pour un envoi (D1) : intégrations actives de l'organisation pour le canal dont la
-- condition (lyxal_core, sur { workflow, subscriber, payload }) est vraie, la principale
-- d'abord, puis par priorité croissante ; aucune : celles de l'installation, dans le même ordre ;
-- aucune : l'envoi attend en file. Bascule (D3) : après un échec temporaire, la tentative
-- suivante passe à l'intégration éligible suivante.

-- ----------------------------------------------------------------------------
-- fn::notification_integration_find (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_integration_find($params: object) -> any {
    IF $params.integration IS NOT NONE { RETURN (SELECT * FROM ONLY $params.integration); };
    LET $scope = IF $params.tenant IS NONE { "installation" } ELSE { <string> record::id($params.tenant) };
    RETURN (SELECT * FROM ONLY notification_integration WHERE scope_key = $scope AND key = $params.key LIMIT 1);
} COMMENT "Interne : intégration ({ integration } ou { tenant, key }) ou NONE";

-- ----------------------------------------------------------------------------
-- fn::notification_integration_secret_check (interne) : chemin, existence et droit de lecture
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_integration_secret_check($params: object) -> option<string> {
    IF !type::is_string($params.path) OR !string::starts_with($params.path, "notification/") { RETURN "NOTIFICATION_INTEGRATION_SECRET_INVALID"; };
    -- Droit de lire le secret (contrats publics de lyxal_auth et lyxal_secrets) ; la session
    -- système de l'hôte n'a pas de droit à prouver
    IF !fn::auth_session_valid({}).system {
        LET $allowed = IF $params.tenant IS NONE {
            fn::auth_has_permission({ permission: "secrets.installation.manage" })
        } ELSE {
            fn::auth_has_permission({ permission: "secrets.value.read", tenant: $params.tenant })
        };
        IF !$allowed { RETURN "NOTIFICATION_INTEGRATION_SECRET_INVALID"; };
    };
    -- Existence de la fiche, au nom de l'appelant (fiche invisible : absente)
    LET $secret = fn::secrets_secret_get({ tenant: IF $params.tenant IS NONE { NONE } ELSE { <string> $params.tenant }, path: $params.path });
    IF !$secret.ok OR $secret.data.state = "deleted" { RETURN "NOTIFICATION_INTEGRATION_SECRET_INVALID"; };
    -- Relais SMTP d'une organisation : le serveur est choisi par la personne, qui pourrait y
    -- recevoir le mot de passe ; le secret doit donc être de ceux qu'elle peut déjà voir
    -- (revealable), jamais un secret réservé aux programmes (restricted)
    IF $params.provider = "smtp" AND $params.tenant IS NOT NONE AND !fn::auth_session_valid({}).system
        AND $secret.data.visibility != "revealable" {
        RETURN "NOTIFICATION_INTEGRATION_SECRET_INVALID";
    };
    RETURN NONE;
} COMMENT "Interne : NONE si le secret ({ tenant, path, provider }) est sous notification/, existe dans la même portée (lyxal_secrets, fn::secrets_secret_get au nom de l'appelant) et peut être lu par l'appelant (secrets.value.read dans l'organisation, secrets.installation.manage pour l'installation ; session système dispensée du droit) ; identifiants d'un relais SMTP d'une organisation (provider smtp) : secret revealable seulement ; sinon NOTIFICATION_INTEGRATION_SECRET_INVALID";

-- ----------------------------------------------------------------------------
-- fn::notification_integration_settings_refusal (interne) : réglages propres au fournisseur
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_integration_settings_refusal($params: object) -> option<object> {
    LET $s = $params.settings ?? {};
    LET $smtp_fields = ["host", "port", "security"];
    LET $mailgun_fields = ["domain", "region"];
    LET $required = IF $params.provider = "smtp" { $smtp_fields } ELSE IF $params.provider = "mailgun" { ["domain"] } ELSE { [] };
    LET $allowed = array::concat(["from_address", "from_name", "reply_to"], IF $params.provider = "smtp" { $smtp_fields } ELSE IF $params.provider = "mailgun" { $mailgun_fields } ELSE { [] });
    LET $missing = array::filter($required, |$f| $s[$f] IS NONE);
    IF array::len($missing) > 0 { RETURN { field: $missing[0], code: "CORE_VALIDATION_REQUIRED" }; };
    LET $extra = array::filter(object::keys($s), |$f| $f NOTINSIDE $allowed AND $s[$f] IS NOT NONE);
    IF array::len($extra) > 0 { RETURN { field: $extra[0], code: "CORE_VALIDATION_NOT_ALLOWED" }; };
    -- Organisation : ni relais en clair, ni adresse IP ou hôte local (réservés à l'installation)
    IF $params.tenant IS NOT NONE AND $params.provider = "smtp" {
        IF $s.security = "local_plain" { RETURN { field: "security", code: "CORE_VALIDATION_NOT_ALLOWED" }; };
        IF fn::validation_ip($s.host, NONE).valid OR $s.host = "localhost" OR string::ends_with($s.host, ".localhost") {
            RETURN { field: "host", code: "CORE_VALIDATION_NOT_ALLOWED" };
        };
    };
    RETURN NONE;
} COMMENT "Interne : NONE si les réglages ({ provider, tenant, settings }) conviennent au fournisseur (SMTP : host, port, security ; Mailgun : domain, region facultative ; autres : expéditeur seulement) ; sinon { field, code }. Une organisation n'a ni relais SMTP en clair ni hôte IP ou local";

-- ----------------------------------------------------------------------------
-- fn::notification_integration_refusal (garde d'une écriture directe)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_integration_refusal($after: object) -> option<string> {
    IF fn::auth_session_valid({}).system { RETURN NONE; };
    IF fn::notification_integration_settings_refusal({ provider: $after.provider, tenant: $after.tenant, settings: $after.settings }) IS NOT NONE { RETURN "NOTIFICATION_INVALID_INPUT"; };
    LET $credentials = fn::notification_integration_secret_check({ tenant: $after.tenant, path: $after.credentials_path, provider: $after.provider });
    IF $credentials IS NOT NONE { RETURN $credentials; };
    IF $after.webhook_path IS NOT NONE { RETURN fn::notification_integration_secret_check({ tenant: $after.tenant, path: $after.webhook_path }); };
    RETURN NONE;
} COMMENT "Garde notification_integration_guard : code d'erreur si une écriture directe change où un secret est envoyé sans le droit de le lire (ou avec des réglages refusés) ; NONE sinon. Session système dispensée";

-- ----------------------------------------------------------------------------
-- fn::notification_integration_fields (interne) : schéma de validation des entrées
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_integration_fields($create: bool) -> object {
    LET $settings = {
        fields: {
            from_address: { pipeline: [{ rule: "email", options: { max_length: 254 } }], required: true },
            from_name: { pipeline: [{ rule: "display_name", options: { min_length: 1, max_length: 128, allow_emoji: false } }] },
            reply_to: { pipeline: [{ rule: "email", options: { max_length: 254 } }] },
            host: { pipeline: [{ rule: "hostname", options: { allow_single_label: true } }] },
            port: { pipeline: [{ rule: "port", options: { min_port: 1, max_port: 65535 } }] },
            security: { pipeline: [{ rule: "enum", options: { allowed: ["tls", "starttls", "local_plain"], case_sensitive: true } }] },
            domain: { pipeline: [{ rule: "domain", options: { allow_subdomains: true } }] },
            region: { pipeline: [{ rule: "enum", options: { allowed: ["us", "eu"], case_sensitive: true } }] }
        },
        unknown_keys: "reject"
    };
    LET $path = { pipeline: [{ rule: "lyxal_storage_path", options: { allow_file_extension: true, max_length: 256 } }] };
    RETURN {
        tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
        key: { pipeline: [{ rule: "snake_case_name", options: { min_length: 1, max_length: 64 } }], required: true },
        provider: { pipeline: [{ rule: "enum", options: { allowed: ["smtp", "brevo", "mailgun", "postmark", "resend"], case_sensitive: true } }], required: $create },
        channel: { pipeline: [{ rule: "enum", options: { allowed: ["email"], case_sensitive: true } }], default: "email" },
        name: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 128 } }], required: $create },
        active: { pipeline: [{ rule: "boolean" }] },
        primary: { pipeline: [{ rule: "boolean" }] },
        priority: { pipeline: [{ rule: "integer", options: { min_value: 0, max_value: 1000 } }] },
        condition: { pipeline: [{ rule: "is_object" }] },
        clear_condition: { pipeline: [{ rule: "boolean" }], default: false },
        settings: { pipeline: [{ rule: "is_object" }, { rule: "object", options: { schema: $settings } }], required: $create },
        credentials_path: object::extend($path, { required: $create }),
        webhook_path: $path,
        clear_webhook: { pipeline: [{ rule: "boolean" }], default: false },
        language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
    };
} COMMENT "Interne : champs contrôlés par fn::validation_object_execute pour la création ($create) ou la modification d'une intégration";

-- ----------------------------------------------------------------------------
-- fn::notification_integration_view (interne) : intégration sans réglage interne
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_integration_view($integration: object) -> object {
    RETURN $integration.{ id, tenant, key, channel, provider, name, active, primary, priority, condition, settings, credentials_path, webhook_path, last_test, created_at, updated_at };
} COMMENT "Interne : vue publique d'une intégration (chemins des secrets, jamais de valeur)";

-- ----------------------------------------------------------------------------
-- fn::notification_integration_checked (interne) : contrôles communs à la création et à la modification
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_integration_checked($params: object) -> option<object> {
    LET $p = $params.p;
    LET $settings_refusal = fn::notification_integration_settings_refusal({ provider: $params.provider, tenant: $p.tenant, settings: $params.settings });
    IF $settings_refusal IS NOT NONE {
        RETURN { code: "NOTIFICATION_INVALID_INPUT", details: { fields: { settings: { code: $settings_refusal.code, details: { field: $settings_refusal.field } } } } };
    };
    IF $p.condition IS NOT NONE {
        LET $check = fn::utils_condition_check($p.condition, NONE);
        IF !$check.valid { RETURN { code: "NOTIFICATION_CONDITION_INVALID", details: $check.details }; };
    };
    IF $params.credentials_path IS NOT NONE
        AND fn::notification_integration_secret_check({ tenant: $p.tenant, path: $params.credentials_path, provider: $params.provider }) IS NOT NONE {
        RETURN { code: "NOTIFICATION_INTEGRATION_SECRET_INVALID", details: { path: $params.credentials_path } };
    };
    IF $params.webhook_path IS NOT NONE AND fn::notification_integration_secret_check({ tenant: $p.tenant, path: $params.webhook_path }) IS NOT NONE {
        RETURN { code: "NOTIFICATION_INTEGRATION_SECRET_INVALID", details: { path: $params.webhook_path } };
    };
    RETURN NONE;
} COMMENT "Interne : { code, details } si les réglages, la condition ou les secrets ({ p, provider, settings, credentials_path, webhook_path }) sont refusés ; NONE sinon";

-- ----------------------------------------------------------------------------
-- fn::notification_integration_clean_settings (interne) : adresses normalisées, région Mailgun
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_integration_clean_settings($params: object) -> object {
    LET $s = $params.settings;
    RETURN object::from_entries(array::filter(object::entries(object::extend($s, {
        from_address: fn::sanitize_pipeline_execute($s.from_address, [{ rule: "email" }], 5),
        reply_to: IF $s.reply_to IS NONE { NONE } ELSE { fn::sanitize_pipeline_execute($s.reply_to, [{ rule: "email" }], 5) },
        region: IF $params.provider = "mailgun" { $s.region ?? "us" } ELSE { NONE }
    })), |$e| $e[1] IS NOT NONE));
} COMMENT "Interne : réglages ({ provider, settings }) avec adresses normalisées par lyxal_core et région Mailgun us par défaut";

-- ----------------------------------------------------------------------------
-- fn::notification_integration_unset_primary (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_integration_unset_primary($params: object) -> bool {
    LET $scope = IF $params.tenant IS NONE { "installation" } ELSE { <string> record::id($params.tenant) };
    LET $others = (SELECT VALUE id FROM notification_integration WHERE scope_key = $scope AND channel = $params.channel AND primary = true AND id != $params.except);
    LET $updated = IF array::len($others) = 0 { [] } ELSE { (UPDATE $others SET primary = false RETURN id) };
    RETURN array::len($updated) = array::len($others);
} COMMENT "Interne : retire la principale de la portée et du canal ({ tenant, channel, except }) ; faux si une écriture a été refusée";

-- ----------------------------------------------------------------------------
-- fn::notification_integration_create
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_integration_create($params: object) {
    LET $report = fn::validation_object_execute($params, { fields: fn::notification_integration_fields(true), unknown_keys: "reject" }, 60);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::notification_can({ action: "manage", tenant: $p.tenant }) { RETURN fn::error_result("NOTIFICATION_PERMISSION_DENIED", $p.language, {}); };
    LET $refusal = fn::notification_integration_checked({ p: $p, provider: $p.provider, settings: $p.settings, credentials_path: $p.credentials_path, webhook_path: $p.webhook_path });
    IF $refusal IS NOT NONE { RETURN fn::error_result($refusal.code, $p.language, $refusal.details); };
    IF fn::notification_integration_find({ tenant: $p.tenant, key: $p.key }) IS NOT NONE {
        RETURN fn::error_result("NOTIFICATION_INTEGRATION_KEY_TAKEN", $p.language, { key: $p.key });
    };
    LET $primary = $p.primary ?? false;
    IF $primary AND !fn::notification_integration_unset_primary({ tenant: $p.tenant, channel: $p.channel, except: NONE }) {
        RETURN fn::error_result("NOTIFICATION_WRITE_FORBIDDEN", $p.language, { table: "notification_integration" });
    };
    LET $created = (INSERT IGNORE INTO notification_integration {
        tenant: $p.tenant, key: $p.key, channel: $p.channel, provider: $p.provider, name: $p.name,
        active: $p.active ?? true, primary: $primary, priority: $p.priority ?? 100, condition: $p.condition,
        settings: fn::notification_integration_clean_settings({ provider: $p.provider, settings: $p.settings }),
        credentials_path: $p.credentials_path, webhook_path: $p.webhook_path
    });
    IF array::len($created) = 0 {
        RETURN fn::error_result(IF fn::notification_integration_find({ tenant: $p.tenant, key: $p.key }) IS NONE { "NOTIFICATION_WRITE_FORBIDDEN" } ELSE { "NOTIFICATION_INTEGRATION_KEY_TAKEN" }, $p.language, { key: $p.key });
    };
    RETURN fn::result_ok(fn::notification_integration_view($created[0]));
} COMMENT "Crée une intégration ({ tenant, key, provider : smtp, brevo, mailgun, postmark, resend ; channel : email ; name, active, primary, priority, condition, settings : { from_address, from_name, reply_to ; SMTP : host, port, security ; Mailgun : domain, region }, credentials_path, webhook_path }) : réglages contrôlés par lyxal_core, chemins sous notification/ de la même portée, secrets existants et lisibles par l'appelant (D2), une seule principale par portée et canal. Permission notification.manage (installation : notification.installation.manage) et lecture du secret (secrets.value.read ; installation : secrets.installation.manage)";

-- ----------------------------------------------------------------------------
-- fn::notification_integration_update
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_integration_update($params: object) {
    LET $report = fn::validation_object_execute($params, { fields: fn::notification_integration_fields(false), unknown_keys: "reject" }, 60);
    IF !$report.valid OR $params.provider IS NOT NONE OR $params.primary IS NOT NONE OR $params.channel IS NOT NONE {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: object::extend($report.by_field ?? {}, object::from_entries(array::map(array::filter(["provider", "primary", "channel"], |$f| $params[$f] IS NOT NONE), |$f| [$f, { code: "CORE_VALIDATION_NOT_ALLOWED", details: {} }]))) });
    };
    LET $p = $report.value;
    IF !fn::notification_can({ action: "manage", tenant: $p.tenant }) { RETURN fn::error_result("NOTIFICATION_PERMISSION_DENIED", $p.language, {}); };
    LET $current = fn::notification_integration_find({ tenant: $p.tenant, key: $p.key });
    IF $current IS NONE { RETURN fn::error_result("NOTIFICATION_INTEGRATION_NOT_FOUND", $p.language, { key: $p.key }); };
    LET $settings = $p.settings ?? $current.settings;
    LET $credentials_path = $p.credentials_path ?? $current.credentials_path;
    LET $webhook_path = IF $p.clear_webhook { NONE } ELSE { $p.webhook_path ?? $current.webhook_path };
    -- Toute modification exige le droit de lire les secrets de l'intégration (D2)
    LET $refusal = fn::notification_integration_checked({ p: $p, provider: $current.provider, settings: $settings, credentials_path: $credentials_path, webhook_path: $webhook_path });
    IF $refusal IS NOT NONE { RETURN fn::error_result($refusal.code, $p.language, $refusal.details); };
    LET $updated = (UPDATE ONLY $current.id SET
        name = $p.name ?? name,
        active = $p.active ?? active,
        priority = $p.priority ?? priority,
        condition = IF $p.clear_condition { NONE } ELSE { $p.condition ?? condition },
        settings = fn::notification_integration_clean_settings({ provider: $current.provider, settings: $settings }),
        credentials_path = $credentials_path,
        webhook_path = $webhook_path);
    IF $updated == NONE { RETURN fn::error_result("NOTIFICATION_WRITE_FORBIDDEN", $p.language, { table: "notification_integration" }); };
    RETURN fn::result_ok(fn::notification_integration_view($updated));
} COMMENT "Modifie une intégration ({ tenant, key, name, active, priority, condition, clear_condition, settings (remplacés en entier), credentials_path, webhook_path, clear_webhook }) ; fournisseur et canal fixes, principale par notification_integration_set_primary. Mêmes contrôles qu'à la création, droit de lire les secrets compris (D2). Permission notification.manage";

-- ----------------------------------------------------------------------------
-- fn::notification_integration_get
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_integration_get($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            integration: { pipeline: [{ rule: "record", options: { expected_table: "notification_integration" } }] },
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            key: { pipeline: [{ rule: "snake_case_name", options: { min_length: 1, max_length: 64 } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid OR ($params.integration IS NONE AND $params.key IS NONE) {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field ?? {} });
    };
    LET $p = $report.value;
    LET $integration = fn::notification_integration_find($p);
    IF $integration IS NONE OR !fn::notification_can({ action: "read", tenant: $integration.tenant }) {
        RETURN fn::error_result("NOTIFICATION_INTEGRATION_NOT_FOUND", $p.language, { key: $p.key });
    };
    RETURN fn::result_ok(fn::notification_integration_view($integration));
} COMMENT "Intégration ({ integration } ou { tenant, key }), sans aucun secret (chemins seulement). Permission notification.read";

-- ----------------------------------------------------------------------------
-- fn::notification_integration_list
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_integration_list($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            channel: { pipeline: [{ rule: "enum", options: { allowed: ["email"], case_sensitive: true } }] },
            active: { pipeline: [{ rule: "boolean" }] },
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
    LET $rows = (SELECT * FROM notification_integration
        WHERE scope_key = $scope AND ($p.channel IS NONE OR channel = $p.channel) AND ($p.active IS NONE OR active = $p.active)
        ORDER BY channel ASC, primary DESC, priority ASC, key ASC);
    RETURN fn::result_ok(array::map($rows, |$i| fn::notification_integration_view($i)));
} COMMENT "Intégrations d'une portée ({ tenant, channel, active }), la principale d'abord puis par priorité ; sans aucun secret. Permission notification.read";

-- ----------------------------------------------------------------------------
-- fn::notification_integration_delete
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_integration_delete($params: object) {
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
    LET $current = fn::notification_integration_find({ tenant: $p.tenant, key: $p.key });
    IF $current IS NONE { RETURN fn::error_result("NOTIFICATION_INTEGRATION_NOT_FOUND", $p.language, { key: $p.key }); };
    LET $deleted = (DELETE $current.id RETURN BEFORE);
    IF array::len($deleted) = 0 { RETURN fn::error_result("NOTIFICATION_WRITE_FORBIDDEN", $p.language, { table: "notification_integration" }); };
    RETURN fn::result_ok({ deleted: $current.id });
} COMMENT "Supprime une intégration ({ tenant, key }), même la dernière (l'envoi attend alors en file) ; le secret du coffre-fort n'est pas touché, ses retours partent avec elle. Permission notification.manage";

-- ----------------------------------------------------------------------------
-- fn::notification_integration_set_primary
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_integration_set_primary($params: object) {
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
    LET $current = fn::notification_integration_find({ tenant: $p.tenant, key: $p.key });
    IF $current IS NONE { RETURN fn::error_result("NOTIFICATION_INTEGRATION_NOT_FOUND", $p.language, { key: $p.key }); };
    IF !fn::notification_integration_unset_primary({ tenant: $p.tenant, channel: $current.channel, except: $current.id }) {
        RETURN fn::error_result("NOTIFICATION_WRITE_FORBIDDEN", $p.language, { table: "notification_integration" });
    };
    LET $updated = (UPDATE ONLY $current.id SET primary = true);
    IF $updated == NONE { RETURN fn::error_result("NOTIFICATION_WRITE_FORBIDDEN", $p.language, { table: "notification_integration" }); };
    RETURN fn::result_ok(fn::notification_integration_view($updated));
} COMMENT "Fait d'une intégration ({ tenant, key }) la principale de sa portée pour son canal (l'ancienne ne l'est plus). Permission notification.manage";

-- ----------------------------------------------------------------------------
-- fn::notification_integration_eligible (interne) : choix D1
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_integration_eligible($params: object) -> array {
    LET $matches = |$i: object| $i.condition IS NONE OR fn::utils_condition_evaluate($params.context, $i.condition, NONE).matched;
    LET $own = IF $params.tenant IS NONE { [] } ELSE {
        array::filter((SELECT * FROM notification_integration
            WHERE scope_key = <string> record::id($params.tenant) AND channel = $params.channel AND active = true
            ORDER BY primary DESC, priority ASC, key ASC), $matches)
    };
    IF array::len($own) > 0 { RETURN $own; };
    RETURN array::filter((SELECT * FROM notification_integration
        WHERE scope_key = "installation" AND channel = $params.channel AND active = true
        ORDER BY primary DESC, priority ASC, key ASC), $matches);
} COMMENT "Interne : intégrations éligibles ({ tenant, channel, context : { workflow, subscriber, payload } }) : actives de l'organisation dont la condition est vraie, la principale d'abord puis par priorité ; aucune : celles de l'installation dans le même ordre (D1)";

-- ----------------------------------------------------------------------------
-- fn::notification_integration_for_job (interne) : ordre D1 / D3 d'une étape
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_integration_for_job($params: object) -> array {
    LET $job = $params.job;
    LET $run = (SELECT tenant, workflow, subscriber, payload FROM ONLY $job.run);
    LET $workflow = (SELECT key, critical, sensitive FROM ONLY $run.workflow);
    LET $subscriber = IF $run.subscriber IS NONE { NONE } ELSE { (SELECT subscriber_id, locale, timezone, data FROM ONLY $run.subscriber) };
    LET $list = fn::notification_integration_eligible({
        tenant: $run.tenant,
        channel: $job.type,
        context: { workflow: $workflow, subscriber: $subscriber, payload: $run.payload }
    });
    IF array::len($list) = 0 { RETURN []; };
    -- Bascule (D3) : après un échec temporaire, l'intégration suivante ; sinon la première
    LET $index = IF $job.last_error.class = "transient" AND $job.integration IS NOT NONE {
        array::find_index($list.id, $job.integration)
    } ELSE { NONE };
    LET $start = IF $index IS NONE { 0 } ELSE { ($index + 1) % array::len($list) };
    RETURN array::concat(array::slice($list, $start), array::slice($list, 0, $start));
} COMMENT "Interne : intégrations éligibles d'une étape ({ job }) dans l'ordre D1, tournées pour que celle à utiliser soit la première (D3 : après un échec temporaire sur une intégration, la suivante)";

-- ----------------------------------------------------------------------------
-- fn::notification_integration_payload (interne) : ce que le worker reçoit
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_integration_payload($integration: option<object>) -> option<object> {
    IF $integration IS NONE { RETURN NONE; };
    RETURN $integration.{ id, tenant, key, provider, settings, credentials_path, webhook_path };
} COMMENT "Interne : intégration remise au worker ou à l'hôte (fournisseur, réglages, chemins des secrets dans sa portée)";

-- ----------------------------------------------------------------------------
-- fn::notification_integration_select (worker)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_integration_select($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            job_id: { pipeline: [{ rule: "record", options: { expected_table: "notification_job" } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::notification_can({ action: "worker" }) { RETURN fn::error_result("NOTIFICATION_PERMISSION_DENIED", $p.language, {}); };
    LET $job = (SELECT * FROM ONLY $p.job_id);
    IF $job == NONE OR $job.type NOT IN fn::notification_channels({}) { RETURN fn::error_result("NOTIFICATION_NOT_FOUND", $p.language, { resource: "job" }); };
    RETURN fn::result_ok(array::map(fn::notification_integration_for_job({ job: $job }), |$i| fn::notification_integration_payload($i)));
} COMMENT "Intégrations éligibles d'une étape de canal ({ job_id }), dans l'ordre D1 tourné par la bascule D3 (celle à utiliser d'abord) ; liste vide : l'envoi attend. Permission notification.worker";

-- ----------------------------------------------------------------------------
-- fn::notification_integration_test (D6) : contrôle avant l'essai fait par l'hôte
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_integration_test($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            integration: { pipeline: [{ rule: "record", options: { expected_table: "notification_integration" } }], required: true },
            to: { pipeline: [{ rule: "email", options: { max_length: 254 } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $integration = fn::notification_integration_find({ integration: $p.integration });
    IF $integration IS NONE OR !fn::notification_can({ action: "read", tenant: $integration.tenant }) {
        RETURN fn::error_result("NOTIFICATION_INTEGRATION_NOT_FOUND", $p.language, {});
    };
    IF !fn::notification_can({ action: "manage", tenant: $integration.tenant }) { RETURN fn::error_result("NOTIFICATION_PERMISSION_DENIED", $p.language, {}); };
    RETURN fn::result_ok({
        integration: fn::notification_integration_payload($integration),
        to: fn::sanitize_pipeline_execute($p.to, [{ rule: "email" }], 5)
    });
} COMMENT "Essai d'une intégration (D6, { integration, to }) au nom de l'appelant : droit de gestion de sa portée et adresse contrôlée ; rend l'intégration (fournisseur, réglages, chemins) et l'adresse normalisée. L'hôte envoie l'e-mail d'essai avec le vrai fournisseur et enregistre l'issue (fn::notification_integration_test_record). Permission notification.manage";

-- ----------------------------------------------------------------------------
-- fn::notification_integration_test_record (hôte)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_integration_test_record($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            integration: { pipeline: [{ rule: "record", options: { expected_table: "notification_integration" } }], required: true },
            ok: { pipeline: [{ rule: "boolean" }], required: true },
            code: { pipeline: [{ rule: "optional_string", options: { max_length: 64 } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::notification_can({ action: "worker" }) { RETURN fn::error_result("NOTIFICATION_PERMISSION_DENIED", $p.language, {}); };
    IF !record::exists($p.integration) { RETURN fn::error_result("NOTIFICATION_INTEGRATION_NOT_FOUND", $p.language, {}); };
    LET $updated = (UPDATE ONLY $p.integration SET last_test = { at: time::now(), ok: $p.ok, code: $p.code });
    IF $updated == NONE { RETURN fn::error_result("NOTIFICATION_WRITE_FORBIDDEN", $p.language, { table: "notification_integration" }); };
    RETURN fn::result_ok($updated.last_test);
} COMMENT "Enregistre l'issue d'un essai d'intégration ({ integration, ok, code }), appelée par l'hôte après l'envoi ; jamais de secret. Session système de l'hôte (notification.worker)";

-- ----------------------------------------------------------------------------
-- fn::notification_provider_event_record (hôte)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_provider_event_record($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            integration: { pipeline: [{ rule: "record", options: { expected_table: "notification_integration" } }], required: true },
            event_id: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 256 } }], required: true },
            type: { pipeline: [{ rule: "enum", options: { allowed: ["delivered", "bounced", "soft_bounced", "complained"], case_sensitive: true } }], required: true },
            provider_message_id: { pipeline: [{ rule: "optional_string", options: { max_length: 512 } }] },
            occurred_at: { pipeline: [{ rule: "datetime" }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::notification_can({ action: "worker" }) { RETURN fn::error_result("NOTIFICATION_PERMISSION_DENIED", $p.language, {}); };
    LET $integration = (SELECT id, tenant FROM ONLY $p.integration);
    IF $integration == NONE { RETURN fn::error_result("NOTIFICATION_INTEGRATION_NOT_FOUND", $p.language, {}); };
    -- Dédoublonnage par identifiant d'événement du fournisseur
    LET $known = (SELECT VALUE id FROM ONLY notification_provider_event WHERE integration = $integration.id AND provider_event_id = $p.event_id LIMIT 1);
    IF $known IS NOT NONE { RETURN fn::result_ok({ event: $known, status: "duplicate", message: NONE }); };
    LET $message = IF $p.provider_message_id IS NONE { NONE } ELSE {
        (SELECT id, run, to, status FROM ONLY notification_message WHERE integration = $integration.id AND provider_message_id = $p.provider_message_id LIMIT 1)
    };
    LET $tenant = IF $message IS NONE { $integration.tenant } ELSE { (SELECT VALUE tenant FROM ONLY $message.run) };
    LET $settings = fn::notification_settings_effective({ tenant: $tenant });
    LET $created = (INSERT IGNORE INTO notification_provider_event {
        integration: $integration.id, tenant: $tenant, provider_event_id: $p.event_id, type: $p.type,
        message: $message.id, address: $message.to, occurred_at: $p.occurred_at ?? time::now(),
        purge_after: time::now() + duration::from_days($settings.retention_days_log)
    });
    IF array::len($created) = 0 {
        LET $raced = (SELECT VALUE id FROM ONLY notification_provider_event WHERE integration = $integration.id AND provider_event_id = $p.event_id LIMIT 1);
        IF $raced IS NONE { RETURN fn::error_result("NOTIFICATION_WRITE_FORBIDDEN", $p.language, { table: "notification_provider_event" }); };
        RETURN fn::result_ok({ event: $raced, status: "duplicate", message: NONE });
    };
    -- Retour sans message connu : gardé pour le suivi, sans autre effet
    IF $message IS NONE { RETURN fn::result_ok({ event: $created[0].id, status: "unmatched", message: NONE }); };
    -- État du message : délivré seulement depuis envoyé ; un rejet ou une plainte prime ; un
    -- rejet temporaire ne change rien
    LET $status = IF $p.type = "delivered" { IF $message.status = "sent" { "delivered" } ELSE { NONE } }
        ELSE IF $p.type = "bounced" { "bounced" } ELSE IF $p.type = "complained" { "complained" } ELSE { NONE };
    IF $status IS NOT NONE AND $status != $message.status {
        LET $updated = (UPDATE ONLY $message.id SET status = $status, status_at = time::now());
        IF $updated == NONE { RETURN fn::error_result("NOTIFICATION_WRITE_FORBIDDEN", $p.language, { table: "notification_message" }); };
    };
    -- Rejet définitif et plainte : adresse ajoutée à la liste de suppression de l'organisation du message
    IF $p.type IN ["bounced", "complained"] {
        INSERT IGNORE INTO notification_suppression {
            tenant: $tenant, channel: "email", address: string::lowercase($message.to),
            reason: IF $p.type = "bounced" { "hard_bounce" } ELSE { "complaint" },
            source: string::slice(string::concat("provider:", $p.event_id), 0, 256)
        };
    };
    RETURN fn::result_ok({ event: $created[0].id, status: "recorded", message: $message.id });
} COMMENT "Enregistre un retour de fournisseur vérifié par l'hôte ({ integration, event_id, type : delivered, bounced, soft_bounced, complained ; provider_message_id, occurred_at }) : dédoublonné par (intégration, identifiant de l'événement) ; message de l'intégration retrouvé par son identifiant chez le fournisseur et son état mis à jour ; rejet définitif ou plainte : adresse du message ajoutée à la liste de suppression de son organisation. Renvoie { event, status : recorded, duplicate, unmatched ; message }. Session système de l'hôte (notification.worker)";
