-- SPDX-License-Identifier: AGPL-3.0-only
-- ============================================================================
-- FONCTIONS : clés DKIM des domaines (fiches publiques)
-- MODULE    : lyxal_mail
-- ============================================================================
-- Plan du lot 6, §9 (décision E18). La tâche mail.dkim_provision de lyxal-groupware génère les
-- clés (lyxal_crypto), range la clé privée dans lyxal_secrets (chemin mail/dkim/<domaine>/
-- <sélecteur>), puis inscrit la fiche publique (fn::mail_dkim_key_create) ; elle l'active quand
-- l'enregistrement DNS publié est identique (fn::mail_dkim_key_activate). Le worker d'envoi lit
-- les clés actives des domaines d'un message (fn::mail_dkim_signers) ; l'administrateur de
-- l'organisation lit les enregistrements à publier (fn::mail_dkim_key_list). Aucune clé privée en
-- base, au journal ni dans un événement.

-- ----------------------------------------------------------------------------
-- fn::mail_dkim_key_create
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_dkim_key_create($params: object) {
    LET $report = fn::validation_fields_execute($params, {
        domain: { checks: [|$v: any| fn::validation_record($v, "mail_domain")], required: true },
        selector: { checks: [|$v: any| fn::validation_slug($v, 63)], required: true },
        algorithm: { checks: [|$v: any| fn::validation_enum($v, ["rsa-sha256", "ed25519-sha256"], true)], required: true },
        bits: { checks: [|$v: any| fn::validation_integer($v, 2048, 4096)] },
        public_key: { checks: [|$v: any| fn::validation_required_string($v, 1, 1024), |$v: any| fn::validation_base64($v, false, false)], required: true },
        secret_path: { checks: [|$v: any| fn::validation_required_string($v, 1, 512)], required: true },
        language: { checks: [|$v: any| fn::validation_language_code($v, false, NONE)], default: "fr" }
    }, "reject");
    IF !$report.valid {
        RETURN fn::error_result("MAIL_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::mail_can({ action: "worker" }) { RETURN fn::error_result("MAIL_PERMISSION_DENIED", $p.language, {}); };
    -- RSA : taille exigée ; Ed25519 : aucune
    IF ($p.algorithm = "rsa-sha256") != ($p.bits IS NOT NONE) {
        RETURN fn::error_result("MAIL_INVALID_PARAMETERS", $p.language, { fields: { bits: [IF $p.bits IS NONE { "required" } ELSE { "not_allowed" }] } });
    };
    LET $domain = (SELECT id, tenant, name FROM ONLY $p.domain);
    IF $domain == NONE { RETURN fn::error_result("MAIL_DOMAIN_NOT_FOUND", $p.language, { domain: <string> $p.domain }); };
    -- Chemin du secret déterminé par le domaine et le sélecteur (un arrêt entre l'écriture du
    -- secret et la fiche laisse un secret réécrit au passage suivant)
    IF $p.secret_path != string::concat("mail/dkim/", $domain.name, "/", $p.selector) {
        RETURN fn::error_result("MAIL_INVALID_PARAMETERS", $p.language, { fields: { secret_path: ["mail/dkim/<domain>/<selector>"] } });
    };
    LET $id = type::record("mail_dkim_key", string::concat(<string> record::id($domain.id), "_", $p.selector));
    IF record::exists($id) { RETURN fn::error_result("MAIL_DKIM_KEY_EXISTS", $p.language, { selector: $p.selector }); };
    LET $created = (CREATE ONLY $id CONTENT {
        tenant: $domain.tenant, domain: $domain.id, selector: $p.selector, algorithm: $p.algorithm, bits: $p.bits,
        public_key: $p.public_key, secret_path: $p.secret_path, state: "pending"
    });
    IF $created == NONE { RETURN fn::error_result("MAIL_WRITE_FORBIDDEN", $p.language, { table: "mail_dkim_key" }); };
    RETURN fn::result_ok(object::remove($created, "secret_path"));
} COMMENT "Inscrit la fiche publique d'une clé DKIM ({ domain, selector (slug, 63 caractères), algorithm (rsa-sha256 avec bits de 2 048 à 4 096, ou ed25519-sha256 sans bits), public_key (valeur p= en Base64, 1 Kio au plus), secret_path (mail/dkim/<domaine>/<sélecteur> : clé privée rangée dans lyxal_secrets par l'appelant) }) à l'état pending ; MAIL_DKIM_KEY_EXISTS, MAIL_DOMAIN_NOT_FOUND ; fiche rendue sans le chemin du secret. Droit : compte de service, session système";

-- ----------------------------------------------------------------------------
-- fn::mail_dkim_key_activate
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_dkim_key_activate($params: object) {
    LET $report = fn::validation_fields_execute($params, {
        key: { checks: [|$v: any| fn::validation_record($v, "mail_dkim_key")], required: true },
        language: { checks: [|$v: any| fn::validation_language_code($v, false, NONE)], default: "fr" }
    }, "reject");
    IF !$report.valid {
        RETURN fn::error_result("MAIL_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::mail_can({ action: "worker" }) { RETURN fn::error_result("MAIL_PERMISSION_DENIED", $p.language, {}); };
    LET $key = (SELECT id, state FROM ONLY $p.key);
    IF $key == NONE { RETURN fn::error_result("MAIL_DKIM_KEY_NOT_FOUND", $p.language, { key: <string> $p.key }); };
    LET $now = time::now();
    LET $updated = IF $key.state = "active" {
        (UPDATE ONLY $key.id SET dns_checked_at = $now)
    } ELSE IF $key.state = "pending" {
        (UPDATE ONLY $key.id SET state = "active", activated_at = $now, dns_checked_at = $now)
    } ELSE { NONE };
    IF $key.state NOTINSIDE ["pending", "active"] { RETURN fn::error_result("MAIL_INVALID_PARAMETERS", $p.language, { fields: { key: ["state"] } }); };
    IF $updated == NONE { RETURN fn::error_result("MAIL_WRITE_FORBIDDEN", $p.language, { table: "mail_dkim_key" }); };
    RETURN fn::result_ok(object::remove($updated, "secret_path"));
} COMMENT "Active une clé DKIM dont l'enregistrement DNS publié est identique ({ key }) : pending → active (activated_at) ; une clé déjà active garde son état (date du contrôle seulement) ; MAIL_DKIM_KEY_NOT_FOUND. Droit : compte de service, session système";

-- ----------------------------------------------------------------------------
-- fn::mail_dkim_key_list
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_dkim_key_list($params: object) {
    LET $report = fn::validation_fields_execute($params, {
        domain: { checks: [|$v: any| fn::validation_record($v, "mail_domain")], required: true },
        language: { checks: [|$v: any| fn::validation_language_code($v, false, NONE)], default: "fr" }
    }, "reject");
    IF !$report.valid {
        RETURN fn::error_result("MAIL_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $domain = (SELECT id, tenant, name FROM ONLY $p.domain);
    IF $domain == NONE { RETURN fn::error_result("MAIL_DOMAIN_NOT_FOUND", $p.language, { domain: <string> $p.domain }); };
    IF !fn::mail_can({ action: "manage", tenant: $domain.tenant }) AND !fn::mail_can({ action: "worker" }) { RETURN fn::error_result("MAIL_PERMISSION_DENIED", $p.language, {}); };
    LET $rows = (SELECT id, selector, algorithm, state, public_key, created_at, activated_at FROM mail_dkim_key WHERE domain = $domain.id ORDER BY selector);
    RETURN fn::result_ok({ items: array::map($rows, |$k| {
        key: $k.id, selector: $k.selector, algorithm: $k.algorithm, state: $k.state, created_at: $k.created_at, activated_at: $k.activated_at,
        dns_name: string::concat($k.selector, "._domainkey.", $domain.name),
        dns_value: string::concat("v=DKIM1; k=", IF $k.algorithm = "rsa-sha256" { "rsa" } ELSE { "ed25519" }, "; p=", $k.public_key)
    }) });
} COMMENT "Clés DKIM d'un domaine ({ domain }), triées par sélecteur (unique dans le domaine) : { items : [{ key, selector, algorithm, state, created_at, activated_at, dns_name (<sélecteur>._domainkey.<domaine>), dns_value (enregistrement TXT à publier : v=DKIM1; k=rsa|ed25519; p=…) }] }. Droit : gestion du domaine (mail.domain.manage), compte de service";

-- ----------------------------------------------------------------------------
-- fn::mail_dkim_signers
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_dkim_signers($params: object) {
    LET $report = fn::validation_fields_execute($params, {
        domains: { checks: [|$v: any| fn::validation_array_length($v, 1, 2), |$v: any| array::map($v, |$d: any| fn::validation_domain($d, true))], required: true },
        language: { checks: [|$v: any| fn::validation_language_code($v, false, NONE)], default: "fr" }
    }, "reject");
    IF !$report.valid {
        RETURN fn::error_result("MAIL_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::mail_can({ action: "worker" }) { RETURN fn::error_result("MAIL_PERMISSION_DENIED", $p.language, {}); };
    LET $names = array::distinct(array::map($p.domains, |$d| fn::sanitize_lowercase($d)));
    LET $domains = (SELECT id, name FROM mail_domain WHERE name IN $names AND state = "active");
    LET $keys = (SELECT domain, selector, algorithm, secret_path FROM mail_dkim_key WHERE domain IN $domains.id AND state = "active" ORDER BY selector);
    RETURN fn::result_ok({ items: array::map($keys, |$k| {
        domain: array::find($domains, |$d| $d.id = $k.domain).name, selector: $k.selector, algorithm: $k.algorithm, secret_path: $k.secret_path
    }) });
} COMMENT "Clés DKIM actives des domaines d'auteur d'un message ({ domains : 1 ou 2 noms de domaine }), relues à chaque message (une clé qui n'est plus active n'est jamais servie) : { items : [{ domain, selector, algorithm, secret_path }] } ; un domaine inconnu ou désactivé n'en a aucune (le message part non signé). Droit : compte de service, session système";

-- ----------------------------------------------------------------------------
-- fn::mail_dkim_pending
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_dkim_pending($params: object) {
    LET $report = fn::validation_fields_execute($params, {
        limit: { checks: [|$v: any| fn::validation_integer($v, 1, 1000)], default: 100 },
        language: { checks: [|$v: any| fn::validation_language_code($v, false, NONE)], default: "fr" }
    }, "reject");
    IF !$report.valid {
        RETURN fn::error_result("MAIL_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::mail_can({ action: "worker" }) { RETURN fn::error_result("MAIL_PERMISSION_DENIED", $p.language, {}); };
    LET $algorithms = ["rsa-sha256", "ed25519-sha256"];
    LET $domains = (SELECT id, tenant, name FROM mail_domain WHERE state = "active" ORDER BY name);
    LET $keys = (SELECT domain, algorithm FROM mail_dkim_key WHERE state IN ["pending", "active"]);
    LET $missing = array::flatten(array::map($domains, |$d| array::map(
        array::filter($algorithms, |$a| !array::any($keys, |$k| $k.domain = $d.id AND $k.algorithm = $a)),
        |$a| { domain: $d.id, name: $d.name, tenant: $d.tenant, algorithm: $a }
    )));
    LET $pending = (SELECT id AS key, domain, domain.name AS name, selector, algorithm, public_key, created_at FROM mail_dkim_key WHERE state = "pending" ORDER BY created_at, key LIMIT $p.limit);
    RETURN fn::result_ok({ missing: array::slice($missing, 0, $p.limit), pending: $pending });
} COMMENT "Travail de la tâche mail.dkim_provision ({ limit : 100 }) : { missing : domaines actifs sans clé pending ni active d'un algorithme [{ domain, name, tenant, algorithm }], par nom de domaine puis algorithme ; pending : clés en attente de publication [{ key, domain, name, selector, algorithm, public_key, created_at }], les plus anciennes d'abord } ; limit éléments au plus dans chaque liste. Droit : compte de service, session système";
