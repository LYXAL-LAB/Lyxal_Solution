-- SPDX-License-Identifier: AGPL-3.0-only
-- ============================================================================
-- FONCTIONS : envoi — droit d'expéditeur, dépôt (contrat public), lecture, annulation
-- MODULE    : lyxal_mail
-- ============================================================================
-- Chemin d'un dépôt (plan du lot 6, §8.5 et §12, décision E19, solution B) :
-- fn::mail_submission_begin (session de l'appelant : droit, expéditeur, limites ; envoi pending
-- et compteurs d'envoi pris par l'événement de création) → écriture chiffrée du fichier par
-- lyxal_storage (StorageService::put, bucket lyxal-mail de l'organisation, clé rendue) →
-- fn::mail_submission_commit (fichier contrôlé, destinataires mis en file, en une transaction).
-- L'écriture et le contrôle du fichier demandent les droits du stockage : pour un dépôt
-- authentifié, l'hôte les fait sous sa session système ; un module les fait sous la session
-- système de son hôte (ou un compte de service qui a aussi storage.worker). Le droit
-- d'expéditeur (§8.3) est une seule règle (fn::mail_sender_allowed), appelée par
-- fn::mail_sender_check, par fn::mail_submission_begin et par la garde de mail_submission.
-- Contrat public stable pour les autres modules (lyxal_notification, lyxal_calendar) : origine
-- module, fn::mail_submission_begin / _commit / _abort / _get / _cancel, issue par les événements
-- mail.submission.* ; aucune dépendance Cargo.

-- ----------------------------------------------------------------------------
-- Règles internes : droit d'expéditeur, expéditeurs des modules, préfixe réservé, compteurs
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_absent() -> object {
    RETURN fn::validation_optional_string(NONE, NONE, NONE);
} COMMENT "Interne : résultat de lyxal_core d'un champ facultatif absent (valide, valeur NONE), pour fn::validation_checks_report";

DEFINE FUNCTION OVERWRITE fn::mail_sender_allowed($tenant: record<auth_organization>, $account: option<record<mail_account>>, $addresses: array) -> array {
    LET $domains = (SELECT name, subaddress_separator FROM mail_domain WHERE tenant = $tenant AND state = "active");
    RETURN array::map($addresses, |$raw| {
        -- Expéditeur vide (MAIL FROM:<>, accusés de lecture RFC 8098) : permis
        IF $raw IS NONE OR $raw = "" { RETURN true; };
        IF $account IS NONE OR !type::is_string($raw) { RETURN false; };
        LET $address = fn::sanitize_lowercase(fn::sanitize_trim($raw));
        LET $parts = string::split($address, "@");
        IF array::len($parts) != 2 { RETURN false; };
        LET $domain = array::find($domains, |$d| $d.name = $parts[1]);
        IF $domain IS NONE { RETURN false; };
        -- Adresse exacte, sinon sans sa sous-adresse si le domaine en a (moi+liste → moi)
        LET $exact = (SELECT kind, account, senders, state FROM ONLY mail_address WHERE address = $address LIMIT 1);
        LET $plain = IF $exact IS NONE AND $domain.subaddress_separator IS NOT NONE AND string::contains($parts[0], $domain.subaddress_separator) {
            (SELECT kind, account, senders, state FROM ONLY mail_address WHERE address = string::concat(string::split($parts[0], $domain.subaddress_separator)[0], "@", $parts[1]) LIMIT 1)
        } ELSE { NONE };
        LET $row = $exact ?? $plain;
        RETURN $row IS NOT NONE AND $row.state = "active"
            AND (($row.kind = "account" AND $row.account = $account) OR ($row.kind = "alias" AND $row.senders CONTAINS $account));
    });
} COMMENT "Interne : règle unique du droit d'envoyer sous une adresse (§8.3, décision E15), pour chaque adresse de $addresses : vrai pour l'expéditeur vide (\"\") ; sinon adresse d'un domaine de courrier actif de l'organisation $tenant, inscrite et active, du compte $account (adresse du compte) ou d'un alias dont la liste senders nomme ce compte ; une sous-adresse vaut son adresse de base si le domaine a un séparateur. Casse ignorée. Lue sous les droits de l'appelant (domaines et adresses visibles d'un compte qui a mail.send) ou de la base (garde)";

DEFINE FUNCTION OVERWRITE fn::mail_module_sender_tenant($address: string) -> option<record<auth_organization>> {
    LET $parts = string::split(fn::sanitize_lowercase(fn::sanitize_trim($address)), "@");
    IF array::len($parts) != 2 { RETURN NONE; };
    LET $domain = (SELECT tenant, state, module_senders FROM ONLY mail_domain WHERE name = $parts[1] LIMIT 1);
    RETURN IF $domain IS NOT NONE AND $domain.state = "active" AND $domain.module_senders CONTAINS $parts[0] { $domain.tenant } ELSE { NONE };
} COMMENT "Interne : organisation du domaine de courrier actif dont la liste module_senders contient la partie locale de $address (expéditeur d'un module, §12.3) ; NONE sinon";

DEFINE FUNCTION OVERWRITE fn::mail_local_part_refusal($domain: record<mail_domain>, $local_part: string) -> option<string> {
    IF string::starts_with($local_part, "rp=") { RETURN "MAIL_ADDRESS_RESERVED"; };
    RETURN IF (SELECT VALUE module_senders FROM ONLY $domain) CONTAINS $local_part { "MAIL_MODULE_SENDER_CONFLICT" } ELSE { NONE };
} COMMENT "Interne : refus d'une partie locale d'adresse inscrite sur le domaine : MAIL_ADDRESS_RESERVED (préfixe rp= des adresses de retour, §11), MAIL_MODULE_SENDER_CONFLICT (expéditeur des modules du domaine, §12.3) ; NONE sinon";

DEFINE FUNCTION OVERWRITE fn::mail_send_counters($submission: object, $settings: object) -> array {
    LET $day = time::format($submission.created_at, "%Y%m%d");
    LET $hour = time::format($submission.created_at, "%Y%m%d%H");
    LET $day_end = <datetime> string::concat(time::format($submission.created_at, "%Y-%m-%d"), "T00:00:00Z") + 2d;
    LET $hour_end = <datetime> string::concat(time::format($submission.created_at, "%Y-%m-%dT%H"), ":00:00Z") + 1h + 1d;
    LET $account = IF $submission.account IS NONE { NONE } ELSE { <string> record::id($submission.account) };
    LET $tenant = <string> record::id($submission.tenant);
    LET $counter = |$kind: string, $scope: string, $window: string, $amount: int, $limit: int, $expires: datetime| {
        id: type::record("mail_send_counter", string::concat($kind, "_", $scope, "_", $window)), kind: $kind, amount: $amount, limit: $limit, expires_at: $expires,
        tenant: $submission.tenant, account: IF $kind IN ["account_messages", "account_recipients"] { $submission.account } ELSE { NONE }
    };
    RETURN IF $submission.origin = "submission" {
        [
            $counter("account_messages", $account, $day, 1, $settings.send_messages_per_day, $day_end),
            $counter("account_recipients", $account, $day, $submission.recipient_count, $settings.send_recipients_per_day, $day_end)
        ]
    } ELSE IF $submission.origin = "module" {
        [$counter("module_messages", $tenant, $hour, 1, $settings.module_messages_per_hour, $hour_end)]
    } ELSE IF $submission.origin = "forward" {
        [$counter("forward_messages", $tenant, $day, 1, $settings.forward_messages_per_day, $day_end)]
    } ELSE { [] };
} COMMENT "Interne : compteurs d'envoi que prend un envoi ($submission : origin, account, tenant, recipient_count, created_at ; $settings : réglages effectifs de l'organisation) : [{ id, kind, amount, limit, expires_at }] ; dépôt authentifié : messages et destinataires du compte par jour UTC ; module : messages des modules de l'organisation par heure UTC ; transfert : transferts de l'organisation par jour UTC ; avis : aucun. Fenêtre gardée un jour de plus, puis purgée";

DEFINE FUNCTION OVERWRITE fn::mail_send_counter_take($counters: array) -> option<string> {
    LET $over = array::find($counters, |$c| ((SELECT VALUE count FROM ONLY $c.id) ?? 0) + $c.amount > $c.limit);
    IF $over IS NOT NONE { RETURN $over.kind; };
    FOR $c IN $counters {
        UPSERT $c.id SET tenant = $c.tenant, account = $c.account, kind = $c.kind, count = (count ?? 0) + $c.amount, expires_at = expires_at ?? $c.expires_at;
    };
    RETURN NONE;
} COMMENT "Interne : prend les compteurs d'envoi ($counters, de fn::mail_send_counters) ; sans rien écrire, rend la sorte du premier compteur dont la limite serait dépassée ; NONE quand tous sont pris. Appelée par l'événement de création d'un envoi (droits de la base)";

DEFINE FUNCTION OVERWRITE fn::mail_send_counter_release($counters: array) -> none {
    FOR $c IN $counters {
        IF record::exists($c.id) { UPDATE $c.id SET count = math::max([0, count - $c.amount]); };
    };
    RETURN NONE;
} COMMENT "Interne : rend les compteurs d'envoi pris par un dépôt abandonné ($counters) ; un compteur purgé (fenêtre passée) est ignoré";

DEFINE FUNCTION OVERWRITE fn::mail_submission_recipient_check($recipient: any) -> object {
    RETURN fn::validation_fields_execute($recipient, {
        address: { checks: [|$v: any| fn::validation_email($v, 254)], required: true },
        notify: { checks: [
            |$v: any| fn::validation_array_length($v, 1, 4),
            |$v: any| array::map($v, |$word: any| fn::validation_enum($word, ["never", "success", "failure", "delay"], false)),
            |$v: any| fn::validation_array_unique($v)
        ] },
        orcpt: { checks: [|$v: any| fn::validation_optional_string($v, 1, 500)] }
    }, "reject");
} COMMENT "Interne : contrôle d'un destinataire d'un dépôt par lyxal_core ({ address : adresse e-mail de 254 caractères au plus ; notify : 1 à 4 mots distincts parmi never, success, failure, delay ; orcpt : 500 caractères au plus }), clés inconnues refusées ; rapport de fn::validation_fields_execute";

-- ----------------------------------------------------------------------------
-- fn::mail_sender_check
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_sender_check($params: object) {
    LET $report = fn::validation_fields_execute($params, {
        addresses: { checks: [
            |$v: any| fn::validation_array_length($v, 1, 10),
            |$v: any| array::map($v, |$a: any| IF $a = "" { fn::validation_optional_string($a, 0, 0) } ELSE { fn::validation_email($a, 254) })
        ], required: true },
        language: { checks: [|$v: any| fn::validation_language_code($v, false, NONE)], default: "fr" }
    }, "reject");
    IF !$report.valid {
        RETURN fn::error_result("MAIL_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $account = fn::mail_session_account(NONE);
    LET $row = IF $account IS NONE { NONE } ELSE { (SELECT tenant, state FROM ONLY $account) };
    IF $row == NONE OR !fn::mail_can({ action: "send", tenant: $row.tenant }) { RETURN fn::error_result("MAIL_PERMISSION_DENIED", $p.language, {}); };
    LET $allowed = IF $row.state = "active" { fn::mail_sender_allowed($row.tenant, $account, $p.addresses) } ELSE { array::map($p.addresses, |$a| false) };
    LET $refused = array::filter(array::map($allowed, |$ok, $rank| IF $ok { NONE } ELSE { $rank }), |$rank| $rank IS NOT NONE);
    RETURN fn::result_ok({ allowed: array::len($refused) = 0, refused: $refused });
} COMMENT "Droit du compte de la session d'envoyer sous des adresses ({ addresses : 1 à 10 adresses, \"\" pour l'expéditeur vide }) : règle du §8.3 (adresses du compte, sous-adresses, alias qui le nomment dans senders, domaines actifs de son organisation) ; compte désactivé : tout refusé ; { allowed, refused : rangs refusés } (aucune adresse rendue). Appelée à MAIL FROM et sur From, Sender, Resent-From, Resent-Sender. Droit : mail.send (compte de la session)";

-- ----------------------------------------------------------------------------
-- fn::mail_submission_begin
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_submission_begin($params: object) {
    LET $report = fn::validation_fields_execute($params, {
        origin: { checks: [|$v: any| fn::validation_enum($v, ["submission", "module", "forward", "dsn"], true)], default: "submission" },
        from: { checks: [|$v: any| IF $v = "" { fn::validation_optional_string($v, 0, 0) } ELSE { fn::validation_email($v, 254) }], required: true },
        header_from: { checks: [|$v: any| fn::validation_array_length($v, 1, 10), |$v: any| array::map($v, |$a: any| fn::validation_email($a, 254))], required: true },
        recipients: { checks: [|$v: any| fn::validation_array_length($v, 1, 1000), |$v: any| array::map($v, |$r: any| fn::mail_submission_recipient_check($r))], required: true },
        size: { checks: [|$v: any| fn::validation_integer($v, 1, 5368709120)], required: true },
        smtputf8: { checks: [|$v: any| fn::validation_boolean($v)], default: false },
        eight_bit: { checks: [|$v: any| fn::validation_boolean($v)], default: false },
        dsn: { checks: [|$v: any| fn::validation_fields_execute($v, {
            ret: { checks: [|$r: any| fn::validation_enum($r, ["hdrs", "full"], false)], default: "hdrs" },
            envid: { checks: [|$e: any| fn::validation_optional_string($e, 1, 100)] }
        }, "reject")], default: {} },
        client_reference: { checks: [|$v: any| fn::validation_identifier($v, 1, 128)] },
        return_token: { checks: [|$v: any| fn::validation_regex($v, "^[0-9a-hjkmnp-tv-z]{26}$")] },
        prefix: { checks: [|$v: any| fn::validation_max_length($v, 16384)] },
        forward: { checks: [|$v: any| fn::validation_fields_execute($v, {
            envelope_from: { checks: [|$a: any| fn::validation_email($a, 254)] },
            spf: { checks: [|$s: any| fn::validation_enum($s, ["none", "neutral", "pass", "fail", "softfail", "temperror", "permerror"], true)], required: true },
            envelope_dkim: { checks: [|$b: any| fn::validation_boolean($b)], required: true }
        }, "reject")] },
        tenant: { checks: [|$v: any| fn::validation_record($v, "auth_organization")] },
        language: { checks: [|$v: any| fn::validation_language_code($v, false, NONE)], default: "fr" }
    }, "reject");
    IF !$report.valid {
        RETURN fn::error_result("MAIL_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    -- Expéditeur vide : "" (rendu NONE par lyxal_core)
    LET $p = object::extend($report.value, { from: $report.value.from ?? "" });
    LET $invalid = |$field: string, $reason: string| fn::error_result("MAIL_INVALID_PARAMETERS", $p.language, { fields: object::from_entries([[$field, [$reason]]]) });
    -- Champs propres à une origine : jeton et préfixe d'un transfert ou d'un avis (le worker
    -- prépare les autres envois, §8.5), référence d'un module, réception d'un transfert, organisation d'un avis
    LET $worker_origin = $p.origin IN ["forward", "dsn"];
    IF !$worker_origin AND $p.return_token IS NOT NONE { RETURN $invalid("return_token", "forward_or_dsn_only"); };
    IF !$worker_origin AND $p.prefix IS NOT NONE { RETURN $invalid("prefix", "forward_or_dsn_only"); };
    IF $p.client_reference IS NOT NONE AND $p.origin != "module" { RETURN $invalid("client_reference", "module_only"); };
    IF ($p.forward IS NOT NONE) != ($p.origin = "forward") { RETURN $invalid("forward", "forward_only"); };
    IF ($p.tenant IS NOT NONE) != ($p.origin = "dsn") { RETURN $invalid("tenant", "dsn_only"); };
    IF ($p.from = "") != ($p.origin = "dsn") AND $p.origin IN ["module", "forward", "dsn"] { RETURN $invalid("from", IF $p.origin = "dsn" { "empty_required" } ELSE { "required" }); };
    IF ($p.origin = "forward") != ($p.return_token IS NOT NONE) AND $p.origin IN ["forward", "dsn"] { RETURN $invalid("return_token", "forward_only"); };
    IF array::any($p.recipients, |$r| $r.notify IS NOT NONE AND $r.notify.map(|$w| fn::sanitize_lowercase($w)) CONTAINS "never" AND array::len($r.notify) > 1) { RETURN $invalid("recipients", "notify_never_alone"); };
    LET $sender = IF $p.from = "" { NONE } ELSE { fn::sanitize_lowercase(fn::sanitize_trim($p.from)) };
    LET $header_from = array::distinct(array::map($p.header_from, |$a| fn::sanitize_lowercase(fn::sanitize_trim($a))));
    -- Appelant, organisation et compte selon l'origine, puis droit d'expéditeur
    LET $origin = fn::mail_submission_origin($p.origin, $sender, $header_from, $p.tenant);
    IF $origin.error IS NOT NONE { RETURN fn::error_result($origin.error, $p.language, $origin.details); };
    LET $settings = fn::mail_settings_effective({ tenant: $origin.tenant });
    LET $max_recipients = IF $p.origin = "submission" { $settings.send_recipients_per_message } ELSE IF $p.origin = "forward" { 10 } ELSE { 100 };
    IF array::len($p.recipients) > $max_recipients { RETURN fn::error_result("MAIL_SUBMISSION_TOO_MANY_RECIPIENTS", $p.language, { max_recipients: $max_recipients }); };
    IF $p.size > $settings.max_message_bytes { RETURN fn::error_result("MAIL_MESSAGE_TOO_LARGE", $p.language, { size: $p.size, max_message_bytes: $settings.max_message_bytes }); };
    LET $now = time::now();
    -- Clé s<UUID v7 en hexadécimal> : ordonnée par le temps, écrite sans échappement dans un identifiant
    LET $key = string::concat("s", string::replace(<string> rand::uuid::v7(), "-", ""));
    LET $row = {
        tenant: $origin.tenant, origin: $p.origin, account: $origin.account, owner: $origin.owner, sender: $sender, header_from: $header_from,
        client_reference: $p.client_reference, content: { key: string::concat("queue/", $key, ".eml"), size: $p.size },
        smtputf8: $p.smtputf8, eight_bit: $p.eight_bit, dsn: { ret: fn::sanitize_lowercase($p.dsn.ret), envid: $p.dsn.envid }, forward: $p.forward,
        pending_recipients: array::map($p.recipients, |$r| {
            LET $at = string::split($r.address, "@");
            LET $domain = fn::sanitize_lowercase(array::last($at));
            RETURN { address: string::concat(array::join(array::slice($at, 0, array::len($at) - 1), "@"), "@", $domain), domain: $domain,
                notify: IF $r.notify IS NONE { NONE } ELSE { array::map($r.notify, |$w| fn::sanitize_lowercase($w)) }, orcpt: $r.orcpt };
        }),
        recipient_count: array::len($p.recipients), created_at: $now, pending_expires_at: $now + 1h,
        expires_at: $now + duration::from_hours($settings.expire_hours)
    };
    -- Limites d'envoi lues ici pour une erreur lisible ; prises par l'événement de création
    LET $over = array::find(fn::mail_send_counters($row, $settings), |$c| ((SELECT VALUE count FROM ONLY $c.id) ?? 0) + $c.amount > $c.limit);
    IF $over IS NOT NONE { RETURN fn::error_result("MAIL_SEND_LIMIT_EXCEEDED", $p.language, { kind: $over.kind, limit: $over.limit }); };
    LET $created = (CREATE ONLY type::record("mail_submission", $key) CONTENT object::extend($row, {
        return_token: $p.return_token, prefix: $p.prefix,
        envelope_from: IF $p.return_token IS NONE { NONE } ELSE { string::concat("rp=", $p.return_token, "@", array::last(string::split($sender, "@"))) },
        return_expires_at: IF $p.return_token IS NONE { NONE } ELSE { $row.expires_at + 14d },
        prepared_at: IF $worker_origin { $now } ELSE { NONE }
    }));
    IF $created == NONE { RETURN fn::error_result("MAIL_WRITE_FORBIDDEN", $p.language, { table: "mail_submission" }); };
    RETURN fn::result_ok({
        submission: $created.id, tenant: $created.tenant, bucket_name: "lyxal-mail", key: $created.content.key,
        max_size: $settings.max_message_bytes, return_address: $created.envelope_from, expires_at: $created.pending_expires_at
    });
} COMMENT "Ouvre un dépôt dans la file d'envoi ({ origin (submission par défaut ; module ; forward, dsn : compte de service), from (adresse d'enveloppe annoncée, \"\" : expéditeur vide, exigé d'un avis), header_from (1 à 10 adresses des champs From, Sender, Resent-*), recipients (1 à 1 000 × { address, notify, orcpt }), size, smtputf8, eight_bit, dsn ({ ret : hdrs ou full, envid }), client_reference (module : identifiant opaque de 1 à 128 caractères), return_token et prefix (transfert ou avis seulement : le worker prépare les autres envois), forward (transfert : { envelope_from, spf, envelope_dkim }), tenant (avis : organisation) }) : droit de l'appelant et d'expéditeur (dépôt authentifié : adresses du compte de la session, §8.3 ; module : expéditeurs des modules d'un domaine, §12.3 ; MAIL_SENDER_FORBIDDEN, rangs refusés), nombre de destinataires (MAIL_SUBMISSION_TOO_MANY_RECIPIENTS : limite de l'organisation, 100 pour un module, 10 pour un transfert), taille (MAIL_MESSAGE_TOO_LARGE), limites d'envoi (MAIL_SEND_LIMIT_EXCEEDED ; compteurs pris dans la transaction, rendus par fn::mail_submission_abort) ; envoi pending, à clore dans l'heure ; { submission, tenant, bucket_name (lyxal-mail : bucket chiffré de l'organisation, créé par l'hôte s'il manque), key (queue/<clé de l'envoi>.eml), max_size, return_address (transfert seulement ; ailleurs posée par le worker à la préparation), expires_at }. Droit : mail.send (dépôt authentifié), mail.relay ou session système (module), mail.worker (transfert, avis)";

DEFINE FUNCTION OVERWRITE fn::mail_submission_origin($origin: string, $sender: option<string>, $header_from: array, $tenant: option<record<auth_organization>>) -> object {
    LET $denied = { error: "MAIL_PERMISSION_DENIED", details: {} };
    LET $refused = |$allowed: array| {
        error: "MAIL_SENDER_FORBIDDEN",
        details: { refused: array::filter(array::map($allowed, |$ok, $rank| IF $ok { NONE } ELSE { $rank }), |$rank| $rank IS NOT NONE) }
    };
    IF $origin = "submission" {
        LET $account = fn::mail_session_account(NONE);
        LET $row = IF $account IS NONE { NONE } ELSE { (SELECT id, tenant, identity, state FROM ONLY $account) };
        IF $row == NONE OR !fn::mail_can({ action: "send", tenant: $row.tenant }) { RETURN $denied; };
        IF $row.state != "active" { RETURN { error: IF $row.state = "deleting" { "MAIL_ACCOUNT_DELETING" } ELSE { "MAIL_ACCOUNT_DISABLED" }, details: {} }; };
        LET $allowed = fn::mail_sender_allowed($row.tenant, $row.id, array::concat([$sender ?? ""], $header_from));
        IF !array::all($allowed, |$ok| $ok) { RETURN $refused($allowed); };
        RETURN { tenant: $row.tenant, account: $row.id, owner: $row.identity };
    };
    IF $origin = "module" {
        IF !fn::mail_can({ action: "relay" }) { RETURN $denied; };
        LET $found = fn::mail_module_sender_tenant($sender ?? "");
        LET $allowed = array::map(array::concat([$sender ?? ""], $header_from), |$a| {
            LET $owner = fn::mail_module_sender_tenant($a);
            RETURN $owner IS NOT NONE AND ($found IS NONE OR $owner = $found);
        });
        IF !array::all($allowed, |$ok| $ok) { RETURN $refused($allowed); };
        RETURN { tenant: $found, account: NONE, owner: NONE };
    };
    IF !fn::mail_can({ action: "worker" }) { RETURN $denied; };
    IF $origin = "dsn" { RETURN { tenant: $tenant, account: NONE, owner: NONE }; };
    -- Transfert : depuis une adresse inscrite active d'un domaine actif (l'alias transféré)
    LET $alias = (SELECT tenant, state, domain.state AS domain_state FROM ONLY mail_address WHERE address = $sender LIMIT 1);
    IF $alias == NONE OR $alias.state != "active" OR $alias.domain_state != "active" { RETURN $refused([false]); };
    RETURN { tenant: $alias.tenant, account: NONE, owner: NONE };
} COMMENT "Interne : appelant, organisation et compte d'un dépôt selon son origine ($origin ; $sender : adresse d'enveloppe ou NONE ; $header_from ; $tenant : organisation d'un avis) : submission → compte actif de la session avec mail.send, toutes les adresses permises (fn::mail_sender_allowed) ; module → mail.relay ou session système, expéditeur et champs d'en-tête parmi les expéditeurs des modules d'un même domaine ; forward → compte de service, expéditeur égal à une adresse inscrite active ; dsn → compte de service. { tenant, account, owner }, ou { error, details } (MAIL_PERMISSION_DENIED, MAIL_ACCOUNT_DISABLED, MAIL_ACCOUNT_DELETING, MAIL_SENDER_FORBIDDEN avec les rangs refusés : 0 pour l'expéditeur, puis les champs d'en-tête)";

-- ----------------------------------------------------------------------------
-- fn::mail_submission_commit
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_submission_commit($params: object) {
    LET $report = fn::validation_fields_execute($params, {
        submission: { checks: [|$v: any| fn::validation_record($v, "mail_submission")], required: true },
        object: { checks: [|$v: any| fn::validation_record($v, "storage_object")], required: true },
        language: { checks: [|$v: any| fn::validation_language_code($v, false, NONE)], default: "fr" }
    }, "reject");
    IF !$report.valid {
        RETURN fn::error_result("MAIL_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $row = (SELECT id, tenant, origin, owner, state, aborted_at, pending_expires_at, content, pending_recipients FROM ONLY $p.submission);
    IF $row == NONE { RETURN fn::error_result("MAIL_SUBMISSION_NOT_FOUND", $p.language, { submission: <string> $p.submission }); };
    -- Mise en file : compte de service, session système, ou mail.relay pour un envoi de module
    IF !fn::mail_can({ action: "worker" }) AND !($row.origin = "module" AND fn::mail_can({ action: "relay" })) { RETURN fn::error_result("MAIL_PERMISSION_DENIED", $p.language, {}); };
    LET $now = time::now();
    IF $row.state != "pending" OR $row.aborted_at IS NOT NONE OR $row.pending_expires_at <= $now {
        RETURN fn::error_result("MAIL_SUBMISSION_STATE_INVALID", $p.language, { state: $row.state, expected: "pending" });
    };
    -- Le fichier, lu par les fonctions publiques de lyxal_storage : disponible, dans le bucket
    -- chiffré lyxal-mail de l'organisation, à la clé de l'envoi, de la taille annoncée
    LET $object = fn::storage_object_get({ object: <string> $p.object, with_bucket: true });
    IF !$object.ok { RETURN fn::error_result("MAIL_CONTENT_UNAVAILABLE", $p.language, { storage: $object.error.code }); };
    LET $bucket = $object.data.bucket_summary;
    IF $object.data.state != "available" OR $object.data.key != $row.content.key OR $object.data.size != $row.content.size
        OR $bucket.name != "lyxal-mail" OR $bucket.tenant != $row.tenant OR !$bucket.encrypted {
        RETURN fn::error_result("MAIL_CONTENT_STATE_INVALID", $p.language, { object: <string> $p.object });
    };
    -- Route locale (§7) : domaine de courrier actif de l'installation, quelle que soit son organisation
    LET $local = (SELECT VALUE name FROM mail_domain WHERE name IN array::distinct($row.pending_recipients.domain) AND state = "active");
    LET $queued = array::filter(array::map($row.pending_recipients, |$r, $rank| (CREATE ONLY fn::mail_queue_recipient_key($row.id, $rank) CONTENT {
        tenant: $row.tenant, submission: $row.id, owner: $row.owner, origin: $row.origin, rank: $rank, address: $r.address, domain: $r.domain,
        local: $local CONTAINS $r.domain, notify: $r.notify, orcpt: $r.orcpt, next_attempt_at: $now
    })), |$created| $created IS NOT NONE);
    IF array::len($queued) = 0 { RETURN fn::error_result("MAIL_WRITE_FORBIDDEN", $p.language, { table: "mail_queue_recipient" }); };
    -- Même droit pour tous les destinataires : un refus partiel annule tout
    IF array::len($queued) != array::len($row.pending_recipients) { THROW "MAIL_WRITE_FORBIDDEN"; };
    LET $updated = (UPDATE ONLY $row.id SET state = "queued", queued_at = $now, content.object = $object.data.id, pending_recipients = []);
    IF $updated == NONE OR $updated.state != "queued" { THROW "MAIL_WRITE_FORBIDDEN"; };
    RETURN fn::result_ok({ submission: $row.id, recipients: array::len($queued), queued_at: $now });
} COMMENT "Clôt un dépôt ({ submission, object (fichier écrit par lyxal_storage) }) en une transaction : envoi pending, non abandonné, dans son délai d'une heure (sinon MAIL_SUBMISSION_STATE_INVALID) ; fichier available, dans le bucket chiffré lyxal-mail de l'organisation, à la clé de l'envoi et de la taille annoncée (MAIL_CONTENT_STATE_INVALID ; illisible : MAIL_CONTENT_UNAVAILABLE) ; un destinataire en file par adresse (rang, route locale posée pour un domaine de courrier actif de l'installation, échéance immédiate, échéancier tenu par les événements), envoi queued ; { submission, recipients, queued_at }. Droit : compte de service ou session système (l'hôte clôt un dépôt authentifié sous sa session système), mail.relay pour un envoi de module";

-- ----------------------------------------------------------------------------
-- fn::mail_submission_abort
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_submission_abort($params: object) {
    LET $report = fn::validation_fields_execute($params, {
        submission: { checks: [|$v: any| fn::validation_record($v, "mail_submission")], required: true },
        language: { checks: [|$v: any| fn::validation_language_code($v, false, NONE)], default: "fr" }
    }, "reject");
    IF !$report.valid {
        RETURN fn::error_result("MAIL_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $row = (SELECT id, state, aborted_at FROM ONLY $p.submission);
    IF $row == NONE { RETURN fn::error_result("MAIL_SUBMISSION_NOT_FOUND", $p.language, { submission: <string> $p.submission }); };
    IF $row.state != "pending" OR $row.aborted_at IS NOT NONE { RETURN fn::error_result("MAIL_SUBMISSION_STATE_INVALID", $p.language, { state: $row.state, expected: "pending" }); };
    LET $updated = (UPDATE ONLY $row.id SET aborted_at = time::now());
    IF $updated == NONE OR $updated.aborted_at IS NONE { RETURN fn::error_result("MAIL_WRITE_FORBIDDEN", $p.language, { table: "mail_submission" }); };
    RETURN fn::result_ok({ released: true });
} COMMENT "Abandonne un dépôt non clos ({ submission }) : compteurs d'envoi rendus (événement), envoi et fichier éventuel retirés par la maintenance (fn::mail_queue_purge) ; MAIL_SUBMISSION_STATE_INVALID si l'envoi est clos ou déjà abandonné ; { released }. Droit : l'appelant de fn::mail_submission_begin (titulaire, mail.relay pour un module, compte de service)";

-- ----------------------------------------------------------------------------
-- fn::mail_submission_get
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_submission_get($params: object) {
    LET $report = fn::validation_fields_execute($params, {
        submission: { checks: [|$v: any| fn::validation_record($v, "mail_submission")], required: true },
        language: { checks: [|$v: any| fn::validation_language_code($v, false, NONE)], default: "fr" }
    }, "reject");
    IF !$report.valid {
        RETURN fn::error_result("MAIL_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $row = (SELECT id, tenant, origin, account, sender, header_from, envelope_from, client_reference, content.size AS size, smtputf8, eight_bit, dsn,
        state, recipient_count, open_count, aborted_at, created_at, queued_at, done_at, expires_at FROM ONLY $p.submission);
    IF $row == NONE { RETURN fn::error_result("MAIL_SUBMISSION_NOT_FOUND", $p.language, { submission: <string> $p.submission }); };
    -- Texte des serveurs distants : jamais pour un module (il ne sert que l'issue)
    LET $remote_text = fn::mail_can({ action: "worker" }) OR $row.origin != "module";
    LET $recipients = (SELECT id AS recipient, rank, address, state, attempts, next_attempt_at, last_result, delayed_at, final_at
        FROM type::record("mail_queue_recipient", fn::mail_queue_recipient_key_text($row.id, 0)..fn::mail_queue_recipient_key_text($row.id, 1000)) ORDER BY rank);
    RETURN fn::result_ok(object::extend($row, {
        recipients: IF $remote_text { $recipients } ELSE {
            array::map($recipients, |$r| object::extend($r, { last_result: IF $r.last_result IS NONE { NONE } ELSE { object::remove($r.last_result, "text") } }))
        }
    }));
} COMMENT "Envoi ({ submission }), sans préfixe, jeton ni contenu, et ses destinataires par rang ({ recipient, rank, address, state, attempts, next_attempt_at, last_result (sans le texte du serveur distant pour un module), delayed_at, final_at }) ; invisible : MAIL_SUBMISSION_NOT_FOUND. Droit : titulaire d'un dépôt authentifié (jamais l'administrateur de l'organisation), mail.relay pour un envoi de module, compte de service";

-- ----------------------------------------------------------------------------
-- fn::mail_submission_cancel
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_submission_cancel($params: object) {
    LET $report = fn::validation_fields_execute($params, {
        submission: { checks: [|$v: any| fn::validation_record($v, "mail_submission")], required: true },
        language: { checks: [|$v: any| fn::validation_language_code($v, false, NONE)], default: "fr" }
    }, "reject");
    IF !$report.valid {
        RETURN fn::error_result("MAIL_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $row = (SELECT id, state FROM ONLY $p.submission);
    IF $row == NONE { RETURN fn::error_result("MAIL_SUBMISSION_NOT_FOUND", $p.language, { submission: <string> $p.submission }); };
    IF $row.state != "queued" { RETURN fn::error_result("MAIL_SUBMISSION_STATE_INVALID", $p.language, { state: $row.state, expected: "queued" }); };
    LET $now = time::now();
    LET $waiting = (SELECT VALUE id FROM type::record("mail_queue_recipient", fn::mail_queue_recipient_key_text($row.id, 0)..fn::mail_queue_recipient_key_text($row.id, 1000)) WHERE state = "scheduled");
    IF array::len($waiting) = 0 { RETURN fn::result_ok({ canceled: 0 }); };
    LET $canceled = (UPDATE $waiting SET state = "canceled", final_at = $now, last_result = { stage: "canceled", at: $now } WHERE state = "scheduled");
    IF array::len($canceled) = 0 { RETURN fn::error_result("MAIL_WRITE_FORBIDDEN", $p.language, { table: "mail_queue_recipient" }); };
    RETURN fn::result_ok({ canceled: array::len($canceled) });
} COMMENT "Annule un envoi en file ({ submission }) : ses destinataires en attente (scheduled) passent à canceled ; un destinataire en cours d'envoi n'est pas interrompu ; MAIL_SUBMISSION_STATE_INVALID si l'envoi n'est pas en file (pending, done) ; { canceled }. Droit : titulaire d'un dépôt authentifié, mail.relay pour un envoi de module, compte de service";
