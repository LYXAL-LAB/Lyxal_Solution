-- ============================================================================
-- FONCTIONS : partages à usage unique
-- MODULE    : lyxal_secrets
-- ============================================================================
-- Le service Rust tire la clé du lien, scelle la copie et ne passe à la base que l'enveloppe,
-- l'empreinte de la clé et le hachage du mot de passe. À l'ouverture, la session système lit le
-- partage (secrets_share_load), le service vérifie la clé et le mot de passe, puis consomme une
-- ouverture (secrets_share_consume) avant d'ouvrir l'enveloppe ; un essai faux est compté
-- (secrets_share_fail). Fin d'un partage : enveloppe, empreinte et hachage effacés.

-- ----------------------------------------------------------------------------
-- fn::secrets_share_view (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_share_view($id: record<secrets_share>) -> option<object> {
    RETURN (SELECT id, tenant, created_identity, created_application, secret, number, protected, members_only, note,
        max_views, views, failed_attempts, state, expires_at, created_at, last_opened_at, finished_at FROM ONLY $id);
} COMMENT "Interne : un partage sans enveloppe, empreinte ni hachage";

-- ----------------------------------------------------------------------------
-- fn::secrets_share_refusal (interne, garde)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_share_refusal($event: string, $before: option<object>, $after: object) -> option<string> {
    LET $system = fn::auth_session_valid({}).system;
    LET $caller = fn::secrets_caller();
    IF $event = "CREATE" {
        IF $after.state != "active" OR $after.views != 0 OR $after.failed_attempts != 0 OR $after.envelope IS NONE
            OR $after.key_fingerprint IS NONE OR $after.protected != ($after.passphrase_hash IS NOT NONE)
            OR $after.finished_at IS NOT NONE OR $after.last_opened_at IS NOT NONE { RETURN "SECRETS_SHARE_INVALID"; };
        LET $settings = fn::secrets_settings_effective({ tenant: $after.tenant });
        IF $after.expires_at <= time::now() OR $after.expires_at > time::now() + $settings.share_max_ttl + 1m
            OR $after.max_views > $settings.share_max_views { RETURN "SECRETS_SHARE_INVALID"; };
        IF $system { RETURN NONE; };
        IF $after.created_identity != $caller.identity OR $after.created_application != (IF $caller.identity IS NONE { $caller.application } ELSE { NONE }) {
            RETURN "SECRETS_PERMISSION_DENIED";
        };
        -- Copie d'un secret : l'auteur doit pouvoir en lire la valeur
        IF $after.secret IS NOT NONE {
            LET $secret = (SELECT tenant, path FROM ONLY $after.secret);
            IF $secret == NONE OR $secret.tenant != $after.tenant OR $after.number IS NONE { RETURN "SECRETS_SHARE_INVALID"; };
            IF !fn::secrets_can({ action: "read_value", tenant: $secret.tenant, path: $secret.path }) { RETURN "SECRETS_PERMISSION_DENIED"; };
        };
        RETURN NONE;
    };
    -- Références (secret, auteur) : figées, sauf leur effacement par la suppression de l'enregistrement visé,
    -- permis quel que soit l'état et sans autre changement
    LET $refs = ["secret", "created_identity", "created_application"];
    IF !array::all($refs, |$f| $before[$f] = $after[$f] OR ($after[$f] IS NONE AND $before[$f] IS NOT NONE AND !record::exists($before[$f]))) {
        RETURN "SECRETS_SHARE_INVALID";
    };
    IF array::any($refs, |$f| $before[$f] != $after[$f]) {
        LET $rest = ["state", "views", "failed_attempts", "envelope", "key_fingerprint", "passphrase_hash", "finished_at", "last_opened_at"];
        RETURN IF array::all($rest, |$f| $before[$f] = $after[$f]) { NONE } ELSE { "SECRETS_SHARE_INVALID" };
    };
    IF $before.state != "active" { RETURN "SECRETS_SHARE_UNAVAILABLE"; };
    LET $trusted = $system OR fn::secrets_can({ action: "worker", tenant: $after.tenant });
    -- Ouvertures et essais faux : comptés par la session système seulement, un à un
    IF $after.views != $before.views AND (!$trusted OR $after.views != $before.views + 1 OR $after.views > $after.max_views) { RETURN "SECRETS_SHARE_INVALID"; };
    IF $after.failed_attempts != $before.failed_attempts AND (!$trusted OR $after.failed_attempts != $before.failed_attempts + 1) { RETURN "SECRETS_SHARE_INVALID"; };
    LET $finished = $after.state != "active";
    -- Les éléments scellés ne changent pas ; ils sont effacés à la fin, ensemble
    LET $sealed = ["envelope", "key_fingerprint", "passphrase_hash"];
    IF $finished {
        IF array::any($sealed, |$f| $after[$f] IS NOT NONE) OR $after.finished_at IS NONE { RETURN "SECRETS_SHARE_INVALID"; };
    } ELSE IF array::any($sealed, |$f| $after[$f] != $before[$f]) OR $after.finished_at IS NOT NONE {
        RETURN "SECRETS_SHARE_INVALID";
    };
    RETURN IF $after.state = "active" { NONE }
        ELSE IF $after.state = "consumed" { IF $trusted AND $after.views = $after.max_views { NONE } ELSE { "SECRETS_SHARE_INVALID" } }
        ELSE IF $after.state = "destroyed" { IF $trusted AND $after.failed_attempts = 5 { NONE } ELSE { "SECRETS_SHARE_INVALID" } }
        ELSE IF $after.state = "expired" { IF $trusted AND $after.expires_at <= time::now() { NONE } ELSE { "SECRETS_SHARE_INVALID" } }
        -- Retrait : l'auteur, un détenteur du droit de partage, ou la session système
        ELSE IF $trusted OR fn::secrets_can({ action: "share", tenant: $after.tenant })
            OR ($after.created_identity IS NOT NONE AND $after.created_identity = $caller.identity)
            OR ($after.created_application IS NOT NONE AND $after.created_application = $caller.application) { NONE }
        ELSE { "SECRETS_PERMISSION_DENIED" };
} COMMENT "Interne : refus d'une écriture de partage ($event, $before, $after) : création active, scellée, bornée par les réglages, au nom de l'appelant (copie d'un secret : droit de lire sa valeur) ; ouvertures et essais faux comptés un à un par la session système ; éléments scellés figés, effacés ensemble à la fin ; fin par épuisement, 5 essais faux ou échéance (session système ou worker), ou par retrait (auteur, droit de partage) ; partage fini intouchable ; secret et auteur figés, sauf leur effacement par la suppression de l'enregistrement visé. NONE ou code d'erreur";

-- ----------------------------------------------------------------------------
-- fn::secrets_share_create
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_share_create($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            secret: { pipeline: [{ rule: "record", options: { expected_table: "secrets_secret" } }] },
            number: { pipeline: [{ rule: "integer", options: { min_value: 1 } }] },
            envelope: { pipeline: [{ rule: "required_string", options: { min_length: 8, max_length: 1398211 } }, { rule: "starts_with", options: { prefixes: ["enc:v2:"], case_sensitive: true, trim_value: false } }], required: true },
            key_fingerprint: { pipeline: [{ rule: "required_string", options: { min_length: 64, max_length: 64 } }], required: true },
            passphrase_hash: { pipeline: [{ rule: "optional_string", options: { min_length: 10, max_length: 512 } }, { rule: "starts_with", options: { prefixes: ["$argon2id$"], case_sensitive: true, trim_value: false } }] },
            max_views: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 10 } }], default: 1 },
            ttl: { pipeline: [{ rule: "duration", options: { min_value: 5m, max_value: 30d } }] },
            members_only: { pipeline: [{ rule: "boolean" }], default: false },
            note: { pipeline: [{ rule: "optional_string", options: { max_length: 256 } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid {
        RETURN fn::error_result("SECRETS_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::secrets_can({ action: "share", tenant: $p.tenant }) { RETURN fn::error_result("SECRETS_PERMISSION_DENIED", $p.language, {}); };
    -- Copie d'un secret : visible et lisible par l'auteur, de la même organisation
    IF $p.secret IS NOT NONE {
        LET $secret = (SELECT id, tenant, path FROM ONLY $p.secret);
        IF $secret == NONE { RETURN fn::error_result("SECRETS_SECRET_NOT_FOUND", $p.language, { secret: <string> $p.secret }); };
        IF $secret.tenant != $p.tenant OR $p.number IS NONE { RETURN fn::error_result("SECRETS_SHARE_INVALID", $p.language, { reason: "source" }); };
        IF !fn::secrets_can({ action: "read_value", tenant: $secret.tenant, path: $secret.path }) { RETURN fn::error_result("SECRETS_PERMISSION_DENIED", $p.language, {}); };
    };
    LET $settings = fn::secrets_settings_effective({ tenant: $p.tenant });
    LET $ttl = $p.ttl ?? $settings.share_default_ttl;
    IF $ttl > $settings.share_max_ttl OR $p.max_views > $settings.share_max_views {
        RETURN fn::error_result("SECRETS_SHARE_INVALID", $p.language, { max_ttl: $settings.share_max_ttl, max_views: $settings.share_max_views });
    };
    LET $caller = fn::secrets_caller();
    LET $created = (CREATE ONLY secrets_share CONTENT {
        tenant: $p.tenant,
        created_identity: $caller.identity,
        created_application: IF $caller.identity IS NONE { $caller.application } ELSE { NONE },
        secret: $p.secret,
        number: IF $p.secret IS NONE { NONE } ELSE { $p.number },
        envelope: $p.envelope,
        key_fingerprint: $p.key_fingerprint,
        passphrase_hash: $p.passphrase_hash,
        protected: $p.passphrase_hash IS NOT NONE,
        members_only: $p.members_only,
        note: $p.note,
        max_views: $p.max_views,
        expires_at: time::now() + $ttl
    });
    IF $created == NONE { RETURN fn::error_result("SECRETS_WRITE_FORBIDDEN", $p.language, { table: "secrets_share" }); };
    RETURN fn::result_ok(fn::secrets_share_view($created.id));
} COMMENT "Crée un partage à usage unique ({ tenant, secret et number (copie d'un secret) ou rien (texte), envelope (copie scellée par la clé du lien), key_fingerprint (SHA-256 de la clé), passphrase_hash (Argon2id, facultatif), max_views (1 par défaut), ttl (24 h par défaut), members_only, note }) ; bornes des réglages (SECRETS_SHARE_INVALID). Appelée par le service Rust, qui seul tire la clé et scelle. Droit : secrets.share.create ; pour un secret, droit de lire sa valeur";

-- ----------------------------------------------------------------------------
-- fn::secrets_share_list
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_share_list($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
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
    -- Les droits de la table ne montrent que ses partages, ou tous avec le droit de partage
    LET $ids = (SELECT VALUE id FROM secrets_share WHERE tenant = $p.tenant AND (!$p.active_only OR state = "active") ORDER BY created_at DESC);
    RETURN fn::result_ok({
        items: array::map(array::slice($ids, $p.start, $p.start + $p.limit), |$id| fn::secrets_share_view($id)),
        total: array::len($ids)
    });
} COMMENT "Partages d'une portée, les plus récents d'abord ({ tenant, active_only (défaut vrai), limit (100 au plus), start }) : { items, total }, sans élément scellé. L'auteur voit les siens ; secrets.share.create voit tout";

-- ----------------------------------------------------------------------------
-- fn::secrets_share_load_params (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_share_load_params($params: object) -> object {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            share: { pipeline: [{ rule: "record", options: { expected_table: "secrets_share" } }], required: true },
            opener: { pipeline: [{ rule: "record", options: { expected_table: "auth_identity" } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN { error: fn::error_result("SECRETS_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field }) };
    };
    LET $p = $report.value;
    LET $share = (SELECT * FROM ONLY $p.share);
    -- Partage inconnu ou fini : la même réponse, sans détail
    IF $share == NONE { RETURN { error: fn::error_result("SECRETS_SHARE_UNAVAILABLE", $p.language, {}) }; };
    RETURN { p: $p, share: $share };
} COMMENT "Interne : valide { share, opener, language } et charge le partage : { p, share } ou { error } (SECRETS_SHARE_UNAVAILABLE pour un partage inconnu)";

-- ----------------------------------------------------------------------------
-- fn::secrets_share_revoke
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_share_revoke($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            share: { pipeline: [{ rule: "record", options: { expected_table: "secrets_share" } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("SECRETS_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $share = fn::secrets_share_view($p.share);
    IF $share == NONE { RETURN fn::error_result("SECRETS_SHARE_NOT_FOUND", $p.language, { share: <string> $p.share }); };
    IF $share.state != "active" { RETURN fn::error_result("SECRETS_SHARE_UNAVAILABLE", $p.language, { state: $share.state }); };
    LET $updated = (UPDATE ONLY $share.id SET state = "revoked", finished_at = time::now(), envelope = NONE, key_fingerprint = NONE, passphrase_hash = NONE WHERE state = "active");
    IF $updated == NONE { RETURN fn::error_result("SECRETS_WRITE_FORBIDDEN", $p.language, { table: "secrets_share" }); };
    RETURN fn::result_ok(fn::secrets_share_view($share.id));
} COMMENT "Retire un partage actif tout de suite ({ share }) : la copie scellée est effacée. Droit : auteur, ou secrets.share.create";

-- ----------------------------------------------------------------------------
-- fn::secrets_share_load
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_share_load($params: object) {
    LET $l = fn::secrets_share_load_params($params);
    IF $l.error IS NOT NONE { RETURN $l.error; };
    IF !fn::auth_session_valid({}).system { RETURN fn::error_result("SECRETS_PERMISSION_DENIED", $l.p.language, {}); };
    LET $s = $l.share;
    IF $s.state != "active" OR $s.expires_at <= time::now() OR $s.envelope IS NONE { RETURN fn::error_result("SECRETS_SHARE_UNAVAILABLE", $l.p.language, {}); };
    RETURN fn::result_ok({
        id: $s.id,
        tenant: $s.tenant,
        envelope: $s.envelope,
        key_fingerprint: $s.key_fingerprint,
        passphrase_hash: $s.passphrase_hash,
        members_only: $s.members_only,
        max_views: $s.max_views,
        views: $s.views,
        expires_at: $s.expires_at
    });
} COMMENT "Session système seulement : un partage actif et non échu avec sa copie scellée, l'empreinte de sa clé et le hachage de son mot de passe ({ share }) ; sinon SECRETS_SHARE_UNAVAILABLE, sans détail";

-- ----------------------------------------------------------------------------
-- fn::secrets_share_fail
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_share_fail($params: object) {
    LET $l = fn::secrets_share_load_params($params);
    IF $l.error IS NOT NONE { RETURN $l.error; };
    IF !fn::auth_session_valid({}).system { RETURN fn::error_result("SECRETS_PERMISSION_DENIED", $l.p.language, {}); };
    LET $s = $l.share;
    IF $s.state != "active" { RETURN fn::error_result("SECRETS_SHARE_UNAVAILABLE", $l.p.language, {}); };
    LET $attempts = $s.failed_attempts + 1;
    LET $updated = IF $attempts >= 5 {
        (UPDATE ONLY $s.id SET failed_attempts = 5, state = "destroyed", finished_at = time::now(), envelope = NONE, key_fingerprint = NONE, passphrase_hash = NONE
            WHERE state = "active" AND failed_attempts = $s.failed_attempts)
    } ELSE {
        (UPDATE ONLY $s.id SET failed_attempts = $attempts WHERE state = "active" AND failed_attempts = $s.failed_attempts)
    };
    IF $updated == NONE { RETURN fn::error_result("SECRETS_SHARE_UNAVAILABLE", $l.p.language, {}); };
    RETURN fn::result_ok({ failed_attempts: $updated.failed_attempts, destroyed: $updated.state = "destroyed" });
} COMMENT "Session système seulement : compte un essai faux (clé ou mot de passe) sur un partage actif ({ share }) ; au 5e, le partage est détruit et sa copie effacée : { failed_attempts, destroyed }";

-- ----------------------------------------------------------------------------
-- fn::secrets_share_consume
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_share_consume($params: object) {
    LET $l = fn::secrets_share_load_params($params);
    IF $l.error IS NOT NONE { RETURN $l.error; };
    IF !fn::auth_session_valid({}).system { RETURN fn::error_result("SECRETS_PERMISSION_DENIED", $l.p.language, {}); };
    LET $s = $l.share;
    LET $now = time::now();
    IF $s.state != "active" OR $s.expires_at <= $now OR $s.views >= $s.max_views { RETURN fn::error_result("SECRETS_SHARE_UNAVAILABLE", $l.p.language, {}); };
    LET $views = $s.views + 1;
    -- Une ouverture à la fois (views inchangé depuis la lecture) ; à la dernière, la copie est effacée
    LET $updated = IF $views >= $s.max_views {
        (UPDATE ONLY $s.id SET views = $views, last_opened_at = $now, state = "consumed", finished_at = $now,
            envelope = NONE, key_fingerprint = NONE, passphrase_hash = NONE WHERE state = "active" AND views = $s.views)
    } ELSE {
        (UPDATE ONLY $s.id SET views = $views, last_opened_at = $now WHERE state = "active" AND views = $s.views)
    };
    IF $updated == NONE { RETURN fn::error_result("SECRETS_SHARE_UNAVAILABLE", $l.p.language, {}); };
    -- Ouvreur connu (lien réservé à l'organisation) : au journal
    IF $l.p.opener IS NOT NONE {
        fn::secrets_audit_write({ tenant: $s.tenant, action: "share.opener", details: { share: <string> $s.id, opener: <string> $l.p.opener } });
    };
    RETURN fn::result_ok({ views: $updated.views, remaining: $updated.max_views - $updated.views, state: $updated.state });
} COMMENT "Session système seulement : consomme une ouverture d'un partage actif et non échu ({ share, opener (identité connectée, si le lien est réservé) }), atomiquement ; à la dernière, le partage est épuisé et sa copie effacée : { views, remaining, state }. Le service ouvre ensuite la copie lue par fn::secrets_share_load";

-- ----------------------------------------------------------------------------
-- fn::secrets_share_due
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_share_due($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            limit: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 1000 } }], default: 100 },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("SECRETS_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::secrets_can({ action: "worker" }) { RETURN fn::error_result("SECRETS_PERMISSION_DENIED", $p.language, {}); };
    LET $now = time::now();
    LET $expired = array::filter(array::map(
        (SELECT VALUE id FROM secrets_share WHERE state = "active" AND expires_at <= $now ORDER BY expires_at ASC LIMIT $p.limit),
        |$id| (UPDATE ONLY $id SET state = "expired", finished_at = $now, envelope = NONE, key_fingerprint = NONE, passphrase_hash = NONE
            WHERE state = "active" AND expires_at <= $now)),
        |$s| $s IS NOT NONE);
    -- finished_at IS NOT NONE : NONE se compare comme inférieur à toute date
    LET $removed = (DELETE secrets_share WHERE state != "active" AND finished_at IS NOT NONE AND finished_at <= $now - 30d RETURN BEFORE);
    RETURN fn::result_ok({ shares_expired: array::len($expired), shares_removed: array::len($removed) });
} COMMENT "Fait expirer les partages échus (copie effacée) et retire les fiches finies depuis plus de 30 jours ({ limit (1000 au plus) }) : { shares_expired, shares_removed }. Droit : worker";
