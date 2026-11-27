-- SPDX-License-Identifier: AGPL-3.0-only
-- ============================================================================
-- FONCTIONS : file d'envoi — réservation sous bail, résultats, avis, mesures, maintenance
-- MODULE    : lyxal_mail
-- ============================================================================
-- Appelées par le worker d'envoi (lyxal_mail:mail.outbound) de chaque nœud de lyxal-groupware,
-- sous la session système ou un compte de service (mail.worker), plan du lot 6 §5 (décisions E2
-- à E7). La réservation (fn::mail_queue_claim) lit une plage bornée de l'échéancier ordonné
-- mail_queue_due, de l'origine à l'instant présent : destinataires échus et destinataires dont
-- le bail a expiré après un arrêt brutal, repris sans essai compté. Toute écriture d'un résultat
-- exige le jeton de la réservation et un bail non échu (garde, « fencing ») : sinon le
-- destinataire est rendu dans lost, ou MAIL_QUEUE_CLAIM_LOST quand tout le lot est perdu, et rien
-- n'est écrit pour lui. Les éléments des lots du worker sont contrôlés par appels directs des
-- primitives de lyxal_core et fn::validation_checks_report (décision E32 du CTO,
-- .agents/AGENTS.md §5.7.8) ; les fonctions appelées une fois par passage gardent
-- fn::validation_fields_execute.

-- ----------------------------------------------------------------------------
-- Identifiants ordonnés, garde et règles internes
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_queue_recipient_key_text($submission: record<mail_submission>, $rank: int) -> string {
    RETURN string::concat(<string> record::id($submission), "_", <string> (1000 + $rank));
} COMMENT "Interne : clé (texte) de l'identifiant du destinataire de rang $rank de l'envoi $submission ; borne d'une plage des destinataires d'un envoi (rangs 0 à 1 000 exclu)";

DEFINE FUNCTION OVERWRITE fn::mail_queue_recipient_key($submission: record<mail_submission>, $rank: int) -> record<mail_queue_recipient> {
    RETURN type::record("mail_queue_recipient", fn::mail_queue_recipient_key_text($submission, $rank));
} COMMENT "Interne : identifiant du destinataire de rang $rank (0 à 999 ; 1 000 : borne haute exclue d'une plage) de l'envoi $submission (mail_queue_recipient:⟨<clé de l'envoi>_<10^3 + rang>⟩) : les destinataires d'un envoi se lisent par une plage bornée";

DEFINE FUNCTION OVERWRITE fn::mail_queue_due_key($at: datetime, $recipient: record<mail_queue_recipient>) -> record<mail_queue_due> {
    RETURN type::record("mail_queue_due", string::concat(<string> (10000000000000000 + time::micros($at)), "_", <string> record::id($recipient)));
} COMMENT "Interne : identifiant de la fiche de l'échéancier d'un destinataire à l'instant $at (mail_queue_due:⟨<10^16 + instant en µs>_<clé du destinataire>⟩, décision E5) : l'ordre des clés est celui des instants, puis des dépôts (clés UUID v7)";

DEFINE FUNCTION OVERWRITE fn::mail_queue_due_at($row: any) -> option<datetime> {
    RETURN IF $row IS NONE { NONE } ELSE IF $row.state = "scheduled" { $row.next_attempt_at } ELSE IF $row.state = "running" { $row.locked_until } ELSE { NONE };
} COMMENT "Interne : instant sous lequel un destinataire figure dans l'échéancier : son échéance (scheduled), la fin de son bail (running), aucun sinon";

DEFINE FUNCTION OVERWRITE fn::mail_queue_held($recipient: record<mail_queue_recipient>, $claim: string, $now: datetime) -> option<object> {
    LET $row = (SELECT * FROM ONLY $recipient);
    RETURN IF $row IS NOT NONE AND $row.state = "running" AND $row.claim = $claim AND $row.locked_until > $now { $row } ELSE { NONE };
} COMMENT "Interne : destinataire tenu par la réservation $claim à l'instant $now (running, même jeton, bail non échu), sinon NONE : garde de toute écriture d'un résultat (§5.3)";

DEFINE FUNCTION OVERWRITE fn::mail_queue_next_attempt($attempts: int, $settings: object, $now: datetime) -> datetime {
    LET $intervals = $settings.retry_intervals;
    LET $minutes = $intervals[math::max([0, math::min([$attempts, array::len($intervals)]) - 1])];
    -- Décalage aléatoire sans usage cryptographique (rand::float), borné par le réglage
    LET $factor = 1.0 + (rand::float() * 2.0 - 1.0) * <float> $settings.retry_jitter_percent / 100.0;
    RETURN $now + duration::from_millis(<int> math::round(<float> $minutes * 60000.0 * $factor));
} COMMENT "Interne : échéance de l'essai suivant après $attempts essais comptés (réglages de l'installation, décision E6) : délai retry_intervals[essais - 1] en minutes (le dernier se répète), décalé de ± retry_jitter_percent %";

DEFINE FUNCTION OVERWRITE fn::mail_queue_dsn_wanted($submission: object, $recipient: object, $action: string) -> bool {
    -- Jamais pour un module (événements seulement), un avis, un expéditeur vide
    IF $submission.origin IN ["module", "dsn"] OR $submission.sender IS NONE { RETURN false; };
    -- Transfert : seulement vers une adresse d'enveloppe d'origine authentifiée (SPF ou DKIM de son domaine)
    IF $submission.origin = "forward" AND ($submission.forward.envelope_from IS NONE OR !($submission.forward.spf = "pass" OR $submission.forward.envelope_dkim)) { RETURN false; };
    LET $notify = $recipient.notify ?? ["failure", "delay"];
    IF $notify CONTAINS "never" { RETURN false; };
    RETURN IF $action = "failed" { $notify CONTAINS "failure" AND !$recipient.dsn_sent }
        ELSE IF $action = "delayed" { $notify CONTAINS "delay" AND !$recipient.delay_sent }
        ELSE IF $action = "delivered" { $notify CONTAINS "success" AND $recipient.local AND !$recipient.dsn_sent }
        ELSE IF $action = "relayed" { $notify CONTAINS "success" AND !$recipient.dsn_sent }
        ELSE { false };
} COMMENT "Interne : vrai si un avis $action (failed, delayed, delivered, relayed) est dû pour ce destinataire (§10.1, §10.2) : NOTIFY (défaut failure, delay ; never : jamais), jamais pour un module, un avis ou un expéditeur vide ; transfert : seulement si l'adresse d'enveloppe d'origine est authentifiée (SPF pass, ou DKIM de son domaine) ; delivered : route locale seulement (un serveur qui annonce DSN s'en charge) ; jamais deux fois";

DEFINE FUNCTION OVERWRITE fn::mail_queue_dsn_groups($due: array) -> array {
    LET $keys = array::distinct(array::map($due, |$d| { submission: $d.submission, action: $d.action }));
    RETURN array::map($keys, |$k| object::extend($k, { recipients: array::filter($due, |$d| $d.submission = $k.submission AND $d.action = $k.action).recipient }));
} COMMENT "Interne : avis dus ($due : [{ submission, action, recipient }]) regroupés par envoi et par action : [{ submission, action, recipients }]";

DEFINE FUNCTION OVERWRITE fn::mail_queue_item_check($kind: string, $item: any) -> object {
    LET $tls = $item.tls;
    LET $optional = |$value: any, $check: any| IF $value IS NONE { fn::mail_absent() } ELSE { $check };
    RETURN IF $kind = "complete" {
        fn::validation_checks_report($item, {
            recipient: fn::validation_record($item.recipient, "mail_queue_recipient"),
            outcome: fn::validation_enum($item.outcome, ["delivered", "relayed"], true),
            host: fn::validation_optional_string($item.host, 1, 253),
            code: $optional($item.code, fn::validation_integer($item.code, 200, 299)),
            enhanced: fn::validation_optional_string($item.enhanced, 5, 16),
            tls: IF $tls IS NONE { fn::mail_absent() } ELSE { fn::validation_checks_report($tls, {
                version: fn::validation_optional_string($tls.version, 1, 32),
                verified: fn::validation_boolean($tls.verified)
            }) },
            at: $optional($item.at, fn::validation_datetime($item.at, d"1970-01-01T00:00:00Z", NONE))
        })
    } ELSE IF $kind = "fail" {
        fn::validation_checks_report($item, {
            recipient: fn::validation_record($item.recipient, "mail_queue_recipient"),
            permanent: fn::validation_boolean($item.permanent),
            stage: fn::validation_enum($item.stage, ["dns", "connect", "tls", "greeting", "mail", "rcpt", "data", "local", "content"], true),
            code: $optional($item.code, fn::validation_integer($item.code, 400, 599)),
            enhanced: fn::validation_optional_string($item.enhanced, 5, 16),
            text: fn::validation_optional_string($item.text, 1, 512),
            host: fn::validation_optional_string($item.host, 1, 253)
        })
    } ELSE {
        fn::validation_checks_report($item, {
            recipient: fn::validation_record($item.recipient, "mail_queue_recipient"),
            action: fn::validation_enum($item.action, ["failed", "delayed", "delivered", "relayed", "expanded"], false),
            status: fn::validation_optional_string($item.status, 5, 16),
            diagnostic: fn::validation_optional_string($item.diagnostic, 1, 512)
        })
    };
} COMMENT "Interne : contrôle d'un élément d'un lot du worker d'envoi par appels directs des primitives de lyxal_core et fn::validation_checks_report (décision E32) : complete ({ recipient, outcome : delivered ou relayed, host, code 2xx, enhanced, tls { version, verified }, at }), fail ({ recipient, permanent, stage, code 4xx ou 5xx, enhanced, text de 512 caractères, host }), return ({ recipient, action : failed, delayed, delivered, relayed, expanded, status, diagnostic de 512 caractères }) ; clés inconnues refusées. Rapport { valid, value, errors, warnings, by_field } de lyxal_core";

DEFINE FUNCTION OVERWRITE fn::mail_queue_batch_report($params: any, $kind: string, $max: int, $extra: object) -> object {
    LET $sized = fn::validation_array_length($params.items, 1, $max);
    RETURN fn::validation_checks_report($params, object::extend($extra, {
        items: IF $sized.valid { array::map($sized.value, |$item: any| fn::mail_queue_item_check($kind, $item)) } ELSE { $sized },
        language: fn::validation_language_code(IF $params.language IS NONE { "fr" } ELSE { $params.language }, false, NONE)
    }));
} COMMENT "Interne : rapport de lyxal_core d'un lot du worker ($params : { items, language, … } ; $kind : sorte des éléments, fn::mail_queue_item_check ; $max : borne du lot ; $extra : résultats déjà calculés des autres champs)";

DEFINE FUNCTION OVERWRITE fn::mail_queue_batch_error($report: object, $params: any, $max: int) -> object {
    LET $language = IF type::is_string($params.language) { $params.language } ELSE { NONE };
    RETURN IF ($report.by_field.items ?? []) CONTAINS "CORE_VALIDATION_TOO_LONG" OR ($report.by_field.recipients ?? []) CONTAINS "CORE_VALIDATION_TOO_LONG" {
        fn::error_result("MAIL_QUEUE_BATCH_TOO_LARGE", $language, { max_items: $max })
    } ELSE {
        fn::error_result("MAIL_INVALID_PARAMETERS", $language, { fields: $report.by_field })
    };
} COMMENT "Interne : erreur d'un lot refusé par lyxal_core : MAIL_QUEUE_BATCH_TOO_LARGE au-delà de sa borne ($max), MAIL_INVALID_PARAMETERS sinon";

DEFINE FUNCTION OVERWRITE fn::mail_queue_lost($lost: array, $language: string, $result: object) -> object {
    RETURN IF array::len($lost) > 0 AND array::len($result.done ?? []) = 0 {
        fn::error_result("MAIL_QUEUE_CLAIM_LOST", $language, { lost: $lost })
    } ELSE {
        fn::result_ok(object::extend(object::remove($result, "done"), { lost: $lost }))
    };
} COMMENT "Interne : résultat d'un lot gardé par la réservation : MAIL_QUEUE_CLAIM_LOST quand aucun élément n'est tenu ($lost : destinataires perdus ; $result.done : éléments écrits), sinon le résultat et lost";

-- ----------------------------------------------------------------------------
-- fn::mail_queue_due_read (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_queue_due_read($now: datetime, $limit: int, $excluded: array) -> array {
    LET $upper = string::concat(<string> (10000000000000000 + time::micros($now) + 1), "_");
    -- Fenêtres successives de 1 000 fiches (10 au plus) : des destinataires d'une destination
    -- suspendue ou d'un domaine exclu en tête de l'échéancier n'affament pas les autres
    LET $state = array::fold(<array> (0..10), { rows: [], from: "0", done: false }, |$acc, $step| {
        IF $acc.done { RETURN $acc; };
        LET $got = (SELECT id, recipient, domain FROM type::record("mail_queue_due", $acc.from..$upper) LIMIT 1001);
        -- Borne basse incluse : la dernière fiche de la fenêtre précédente est relue, puis écartée
        LET $fresh = IF $step = 0 { $got } ELSE { array::slice($got, 1) };
        LET $suspended = (SELECT VALUE record::id(id) FROM array::map(array::distinct($fresh.domain), |$d| type::record("mail_queue_destination", $d)) WHERE suspended_until > $now);
        LET $blocked = array::union($excluded, $suspended);
        LET $rows = array::concat($acc.rows, array::filter($fresh, |$d| $d.domain NOTINSIDE $blocked));
        RETURN {
            rows: $rows,
            from: IF array::len($got) = 0 { $acc.from } ELSE { <string> record::id(array::last($got).id) },
            done: array::len($rows) >= $limit OR array::len($fresh) < 1000
        };
    });
    RETURN array::slice($state.rows, 0, $limit);
} COMMENT "Interne : jusqu'à $limit fiches de l'échéancier échues à l'instant $now (destinataires scheduled échus, baux expirés), dans l'ordre des clés, lues par plages bornées de 1 000 fiches (10 au plus), destinations suspendues et domaines de $excluded écartés : [{ id, recipient, domain }]";

-- ----------------------------------------------------------------------------
-- fn::mail_queue_claim
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_queue_claim($params: object) {
    LET $report = fn::validation_fields_execute($params, {
        node: { checks: [|$v: any| fn::validation_required_string($v, 1, 128), |$v: any| fn::validation_ascii($v, true, false)], required: true },
        limit: { checks: [|$v: any| fn::validation_integer($v, 1, 500)], default: 100 },
        lease_seconds: { checks: [|$v: any| fn::validation_integer($v, 60, 1800)], default: 600 },
        exclude_domains: { checks: [|$v: any| fn::validation_array_of_strings($v, true, 1, 253), |$v: any| fn::validation_array_length($v, 0, 1000)], default: [] },
        language: { checks: [|$v: any| fn::validation_language_code($v, false, NONE)], default: "fr" }
    }, "reject");
    IF !$report.valid {
        RETURN fn::error_result("MAIL_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::mail_can({ action: "worker" }) { RETURN fn::error_result("MAIL_PERMISSION_DENIED", $p.language, {}); };
    LET $now = time::now();
    LET $picked = fn::mail_queue_due_read($now, $p.limit, array::map($p.exclude_domains, |$d| fn::sanitize_lowercase($d)));
    IF array::len($picked) = 0 { RETURN fn::result_ok({ claim: NONE, items: [] }); };
    LET $claim = <string> rand::uuid::v7();
    LET $until = $now + duration::from_secs($p.lease_seconds);
    -- Échu (scheduled) ou bail expiré (running) : un destinataire déjà repris par un autre nœud n'est pas rendu
    LET $taken = array::filter(array::map($picked, |$d| (UPDATE ONLY $d.recipient SET state = "running", claim = $claim, claimed_by = $p.node, locked_until = $until
        WHERE (state = "scheduled" AND next_attempt_at <= $now) OR (state = "running" AND locked_until <= $now))), |$row| $row IS NOT NONE);
    IF array::len($taken) = 0 { RETURN fn::result_ok({ claim: NONE, items: [] }); };
    LET $submissions = (SELECT id, tenant, origin, sender, header_from, envelope_from, content, prefix, prepared_at, smtputf8, eight_bit, dsn, created_at, expires_at
        FROM array::distinct($taken.submission));
    RETURN fn::result_ok({
        claim: $claim,
        locked_until: $until,
        items: array::map($taken, |$r| {
            LET $s = array::find($submissions, |$x| $x.id = $r.submission);
            RETURN {
                recipient: $r.id, submission: $r.submission, tenant: $r.tenant, origin: $r.origin, rank: $r.rank, address: $r.address, domain: $r.domain,
                local: $r.local, notify: $r.notify, orcpt: $r.orcpt, attempts: $r.attempts,
                sender: $s.sender, header_from: $s.header_from, envelope_from: $s.envelope_from, prepared: $s.prepared_at IS NOT NONE,
                content: { key: $s.content.key, object: $s.content.object, size: $s.content.size }, prefix: $s.prefix,
                smtputf8: $s.smtputf8, eight_bit: $s.eight_bit, dsn: $s.dsn, size: $s.content.size, created_at: $s.created_at, expires_at: $s.expires_at
            };
        })
    });
} COMMENT "Réserve des destinataires de la file ({ node (nœud qui réserve), limit (100 ; 1 à 500), lease_seconds (600 ; 60 à 1 800), exclude_domains (domaines saturés du nœud, 1 000 au plus) }) : lus dans l'ordre de l'échéancier (échéance, puis dépôt) par une plage bornée, destinations suspendues et domaines exclus écartés ; destinataires échus (scheduled) et dont le bail a expiré (running après un arrêt brutal, sans essai compté) passés à running sous un bail et un jeton de réservation tirés ici ; { claim (NONE : rien à faire), locked_until, items : [{ recipient, submission, tenant, origin, rank, address, domain, local, notify, orcpt, attempts, sender, header_from, envelope_from, prepared (faux : fn::mail_queue_prepare avant l'envoi), content { key, object, size }, prefix, smtputf8, eight_bit, dsn, size, created_at, expires_at }] }. Droit : compte de service, session système";

-- ----------------------------------------------------------------------------
-- fn::mail_queue_renew
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_queue_renew($params: object) {
    LET $sized = fn::validation_array_length($params.recipients, 1, 500);
    LET $report = fn::validation_checks_report($params, {
        claim: fn::validation_uuid_v7($params.claim, true),
        recipients: IF $sized.valid { array::map($sized.value, |$r: any| fn::validation_record($r, "mail_queue_recipient")) } ELSE { $sized },
        lease_seconds: fn::validation_integer(IF $params.lease_seconds IS NONE { 600 } ELSE { $params.lease_seconds }, 60, 1800),
        language: fn::validation_language_code(IF $params.language IS NONE { "fr" } ELSE { $params.language }, false, NONE)
    });
    IF !$report.valid { RETURN fn::mail_queue_batch_error($report, $params, 500); };
    LET $p = $report.value;
    IF !fn::mail_can({ action: "worker" }) { RETURN fn::error_result("MAIL_PERMISSION_DENIED", $p.language, {}); };
    LET $now = time::now();
    LET $claim = <string> $p.claim;
    LET $until = $now + duration::from_secs($p.lease_seconds);
    LET $renewed = array::filter(array::map($p.recipients, |$r| (UPDATE ONLY $r SET locked_until = $until WHERE state = "running" AND claim = $claim AND locked_until > $now)), |$row| $row IS NOT NONE).id;
    RETURN fn::mail_queue_lost(array::complement($p.recipients, $renewed), $p.language, { renewed: array::len($renewed), locked_until: $until, done: $renewed });
} COMMENT "Renouvelle le bail de destinataires réservés ({ claim, recipients : 1 à 500, lease_seconds (600 ; 60 à 1 800) }) pendant un envoi long : seuls ceux que tient la réservation (même jeton, bail non échu) ; { renewed, locked_until, lost : destinataires perdus } ; tous perdus : MAIL_QUEUE_CLAIM_LOST ; plus de 500 : MAIL_QUEUE_BATCH_TOO_LARGE. Droit : compte de service, session système";

-- ----------------------------------------------------------------------------
-- fn::mail_queue_prepare
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_queue_prepare($params: object) {
    LET $report = fn::validation_fields_execute($params, {
        claim: { checks: [|$v: any| fn::validation_uuid_v7($v, true)], required: true },
        submission: { checks: [|$v: any| fn::validation_record($v, "mail_submission")], required: true },
        return_token: { checks: [|$v: any| fn::validation_regex($v, "^[0-9a-hjkmnp-tv-z]{26}$")] },
        prefix: { checks: [|$v: any| fn::validation_max_length($v, 16384)] },
        malformed: { checks: [|$v: any| fn::validation_boolean($v)], default: false },
        language: { checks: [|$v: any| fn::validation_language_code($v, false, NONE)], default: "fr" }
    }, "reject");
    IF !$report.valid {
        RETURN fn::error_result("MAIL_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::mail_can({ action: "worker" }) { RETURN fn::error_result("MAIL_PERMISSION_DENIED", $p.language, {}); };
    LET $row = (SELECT id, origin, sender, notify, forward, state, prepared_at, expires_at FROM ONLY $p.submission);
    IF $row == NONE { RETURN fn::error_result("MAIL_SUBMISSION_NOT_FOUND", $p.language, { submission: <string> $p.submission }); };
    IF $row.origin NOTINSIDE ["submission", "module"] OR $row.state != "queued" OR $row.prepared_at IS NOT NONE {
        RETURN fn::error_result("MAIL_SUBMISSION_STATE_INVALID", $p.language, { state: $row.state, prepared: $row.prepared_at IS NOT NONE });
    };
    -- Jeton de retour : exigé, sauf pour un expéditeur vide (aucune adresse de retour)
    IF ($row.sender IS NONE) != ($p.return_token IS NONE) {
        RETURN fn::error_result("MAIL_INVALID_PARAMETERS", $p.language, { fields: { return_token: [IF $row.sender IS NONE { "not_allowed" } ELSE { "required" }] } });
    };
    LET $now = time::now();
    LET $claim = <string> $p.claim;
    -- Garde : au moins un destinataire de l'envoi tenu par la réservation
    IF array::len(SELECT VALUE id FROM type::record("mail_queue_recipient", fn::mail_queue_recipient_key_text($row.id, 0)..fn::mail_queue_recipient_key_text($row.id, 1000)) WHERE state = "running" AND claim = $claim AND locked_until > $now LIMIT 1) = 0 {
        RETURN fn::error_result("MAIL_QUEUE_CLAIM_LOST", $p.language, {});
    };
    LET $updated = (UPDATE ONLY $row.id SET prepared_at = $now, return_token = $p.return_token, prefix = $p.prefix,
        envelope_from = IF $p.return_token IS NONE { NONE } ELSE { string::concat("rp=", $p.return_token, "@", array::last(string::split($row.sender, "@"))) },
        return_expires_at = IF $p.return_token IS NONE { NONE } ELSE { $row.expires_at + 14d });
    IF $updated == NONE OR $updated.prepared_at IS NONE { RETURN fn::error_result("MAIL_WRITE_FORBIDDEN", $p.language, { table: "mail_submission" }); };
    -- Message illisible (§12.3) : ses destinataires en attente ou tenus par cette réservation échouent (5.6.0)
    LET $failed = IF $p.malformed {
        (UPDATE type::record("mail_queue_recipient", fn::mail_queue_recipient_key_text($row.id, 0)..fn::mail_queue_recipient_key_text($row.id, 1000)) SET state = "failed", final_at = $now, claim = NONE, locked_until = NONE, claimed_by = NONE,
            last_result = { stage: "content", code: 554, enhanced: "5.6.0", at: $now }
            WHERE state = "scheduled" OR (state = "running" AND claim = $claim))
    } ELSE { [] };
    LET $submission = (SELECT id, origin, sender, forward FROM ONLY $row.id);
    LET $due = array::filter(array::map($failed, |$r| IF fn::mail_queue_dsn_wanted($submission, $r, "failed") { { submission: $row.id, action: "failed", recipient: $r.id } } ELSE { NONE }), |$d| $d IS NOT NONE);
    RETURN fn::result_ok({ prepared: true, envelope_from: $updated.envelope_from, failed: array::len($failed), dsn: fn::mail_queue_dsn_groups($due) });
} COMMENT "Prépare un envoi à sa première réservation ({ claim, submission, return_token (26 caractères en base 32 de Crockford, tiré par OsRng ; exigé sauf pour un expéditeur vide), prefix (en-têtes DKIM-Signature à placer devant le fichier, 16 Kio au plus), malformed (message illisible) }) : dépôt authentifié ou module, en file, pas encore préparé (sinon MAIL_SUBMISSION_STATE_INVALID), au moins un destinataire tenu par la réservation (sinon MAIL_QUEUE_CLAIM_LOST) ; adresse de retour rp=<jeton>@<domaine de l'expéditeur>, valable 14 jours après la fin de vie de l'envoi ; message illisible : destinataires en attente ou tenus en échec définitif (5.6.0) ; { prepared, envelope_from, failed, dsn : avis dus [{ submission, action, recipients }] }. Droit : compte de service, session système";

-- ----------------------------------------------------------------------------
-- fn::mail_queue_complete
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_queue_complete($params: object) {
    LET $report = fn::mail_queue_batch_report($params, "complete", 100, { claim: fn::validation_uuid_v7($params.claim, true) });
    IF !$report.valid { RETURN fn::mail_queue_batch_error($report, $params, 100); };
    LET $p = $report.value;
    IF !fn::mail_can({ action: "worker" }) { RETURN fn::error_result("MAIL_PERMISSION_DENIED", $p.language, {}); };
    LET $now = time::now();
    LET $claim = <string> $p.claim;
    LET $written = array::filter(array::map($p.items, |$item| (UPDATE ONLY $item.recipient SET state = $item.outcome, final_at = $now, claim = NONE, locked_until = NONE, claimed_by = NONE,
        last_result = { stage: IF local { "local" } ELSE { "data" }, code: $item.code, enhanced: $item.enhanced, host: $item.host, tls: $item.tls, at: $item.at ?? $now }
        WHERE state = "running" AND claim = $claim AND locked_until > $now)), |$row| $row IS NOT NONE);
    LET $submissions = (SELECT id, origin, sender, forward FROM array::distinct($written.submission));
    LET $due = array::filter(array::map($written, |$r| {
        LET $s = array::find($submissions, |$x| $x.id = $r.submission);
        RETURN IF fn::mail_queue_dsn_wanted($s, $r, $r.state) { { submission: $r.submission, action: $r.state, recipient: $r.id } } ELSE { NONE };
    }), |$d| $d IS NOT NONE);
    RETURN fn::mail_queue_lost(array::complement($p.items.recipient, $written.id), $p.language, { dsn: fn::mail_queue_dsn_groups($due), done: $written.id });
} COMMENT "Écrit les remises réussies d'une transaction ({ claim, items : 1 à 100 × { recipient, outcome (delivered : accepté par le serveur final ou remis par la route locale ; relayed : accepté par un serveur sans DSN), host, code, enhanced, tls { version, verified }, at } }) sous la garde de la réservation ; publie mail.submission.delivered ; { dsn : avis dus (NOTIFY=SUCCESS : delivered par la route locale, relayed) [{ submission, action, recipients }], lost } ; tous perdus : MAIL_QUEUE_CLAIM_LOST ; plus de 100 : MAIL_QUEUE_BATCH_TOO_LARGE. Droit : compte de service, session système";

-- ----------------------------------------------------------------------------
-- fn::mail_queue_fail
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_queue_fail($params: object) {
    LET $destination = $params.destination;
    LET $report = fn::mail_queue_batch_report($params, "fail", 100, {
        claim: fn::validation_uuid_v7($params.claim, true),
        destination: IF $destination IS NONE { fn::mail_absent() } ELSE { fn::validation_checks_report($destination, {
            domain: fn::validation_domain($destination.domain, true),
            unreachable: fn::validation_boolean($destination.unreachable),
            stage: fn::validation_enum(IF $destination.stage IS NONE { "connect" } ELSE { $destination.stage }, ["dns", "connect", "tls", "greeting"], true)
        }) }
    });
    IF !$report.valid { RETURN fn::mail_queue_batch_error($report, $params, 100); };
    LET $p = $report.value;
    IF !fn::mail_can({ action: "worker" }) { RETURN fn::error_result("MAIL_PERMISSION_DENIED", $p.language, {}); };
    LET $now = time::now();
    LET $settings = fn::mail_settings_effective({});
    -- Destination injoignable : suspendue 5 min, doublé à chaque échec consécutif, 2 h au plus ;
    -- une réponse de serveur remet le compteur à zéro (décision E7)
    -- Destination écrite seulement si le lot tient encore au moins un destinataire : un nœud dont
    -- la réservation est perdue ne suspend ni ne remet à zéro une destination
    LET $holds = array::any($p.items, |$i| fn::mail_queue_held($i.recipient, <string> $p.claim, $now) IS NOT NONE);
    LET $suspended_until = IF $holds { fn::mail_queue_destination_record($p.destination, $now) } ELSE { NONE };
    LET $results = array::map($p.items, |$item| fn::mail_queue_fail_item($item, <string> $p.claim, $now, $settings, $suspended_until));
    LET $written = array::filter($results, |$r| $r IS NOT NONE);
    RETURN fn::mail_queue_lost(array::complement($p.items.recipient, $written.recipient), $p.language, {
        items: array::map($written, |$w| { recipient: $w.recipient, state: $w.state, next_attempt_at: $w.next_attempt_at }),
        dsn: fn::mail_queue_dsn_groups(array::flatten($written.dsn)),
        done: $written.recipient
    });
} COMMENT "Écrit les échecs d'une transaction ({ claim, items : 1 à 100 × { recipient, permanent, stage (dns, connect, tls, greeting, mail, rcpt, data, local, content), code, enhanced, text (assaini, 512 caractères), host }, destination ({ domain, unreachable (aucun MX ni aucune adresse n'a répondu), stage }) }) sous la garde de la réservation : essai compté ; refus définitif → failed ; sinon échéance suivante (réglages de l'installation, après la suspension de la destination), ou expired après la fin de vie de l'envoi (4.4.7) ; premier passage du délai d'avis de retard noté (mail.submission.delayed) ; destination suspendue ou remise à zéro ; { items : [{ recipient, state, next_attempt_at }], dsn : avis dus (failed, expired, delayed) [{ submission, action, recipients }], lost } ; tous perdus : MAIL_QUEUE_CLAIM_LOST ; plus de 100 : MAIL_QUEUE_BATCH_TOO_LARGE. Droit : compte de service, session système";

DEFINE FUNCTION OVERWRITE fn::mail_queue_destination_record($destination: any, $now: datetime) -> option<datetime> {
    IF $destination IS NONE { RETURN NONE; };
    LET $id = type::record("mail_queue_destination", fn::sanitize_lowercase($destination.domain));
    IF !$destination.unreachable {
        IF record::exists($id) { UPDATE $id SET consecutive_failures = 0, suspended_until = NONE; };
        RETURN NONE;
    };
    LET $failures = ((SELECT VALUE consecutive_failures FROM ONLY $id) ?? 0) + 1;
    LET $until = $now + duration::from_mins(<int> math::min([5 * math::pow(2, math::min([$failures - 1, 5])), 120]));
    LET $saved = (UPSERT ONLY $id SET consecutive_failures = $failures, suspended_until = $until, last_failure = { stage: $destination.stage, at: $now });
    IF $saved == NONE { THROW "MAIL_WRITE_FORBIDDEN"; };
    RETURN $until;
} COMMENT "Interne : résultat d'une destination dans fn::mail_queue_fail ($destination : { domain, unreachable, stage } ou NONE) : injoignable → échecs consécutifs + 1 et suspension (5 min doublé à chaque échec, 2 h au plus), rendue ; joignable → compteur à zéro ; NONE sans suspension";

DEFINE FUNCTION OVERWRITE fn::mail_queue_fail_item($item: object, $claim: string, $now: datetime, $settings: object, $suspended_until: option<datetime>) -> option<object> {
    LET $row = fn::mail_queue_held($item.recipient, $claim, $now);
    IF $row IS NONE { RETURN NONE; };
    LET $submission = (SELECT id, origin, sender, forward, created_at, queued_at, expires_at FROM ONLY $row.submission);
    LET $attempts = $row.attempts + 1;
    LET $expired = !$item.permanent AND $now >= $submission.expires_at;
    LET $state = IF $item.permanent { "failed" } ELSE IF $expired { "expired" } ELSE { "scheduled" };
    LET $computed = fn::mail_queue_next_attempt($attempts, $settings, $now);
    LET $later = IF $suspended_until IS NOT NONE AND $suspended_until > $computed { $suspended_until } ELSE { $computed };
    LET $next = IF $later > $submission.expires_at { $submission.expires_at } ELSE { $later };
    -- Toujours en file après delay_notice_hours depuis sa mise en file : avis de retard, une fois
    LET $delayed = $state = "scheduled" AND $row.delayed_at IS NONE AND $now >= ($submission.queued_at ?? $submission.created_at) + duration::from_hours($settings.delay_notice_hours);
    LET $updated = (UPDATE ONLY $row.id SET state = $state, attempts = $attempts, claim = NONE, locked_until = NONE, claimed_by = NONE,
        next_attempt_at = IF $state = "scheduled" { $next } ELSE { next_attempt_at },
        final_at = IF $state = "scheduled" { NONE } ELSE { $now },
        delayed_at = IF $delayed { $now } ELSE { delayed_at },
        last_result = { stage: IF $expired { "expired" } ELSE { $item.stage }, code: $item.code, enhanced: IF $expired { "4.4.7" } ELSE { $item.enhanced }, text: $item.text, host: $item.host, at: $now }
        WHERE state = "running" AND claim = $claim);
    IF $updated == NONE { RETURN NONE; };
    LET $action = IF $state = "scheduled" { IF $delayed { "delayed" } ELSE { NONE } } ELSE { "failed" };
    RETURN {
        recipient: $row.id, state: $state, next_attempt_at: IF $state = "scheduled" { $next } ELSE { NONE },
        dsn: IF $action IS NOT NONE AND fn::mail_queue_dsn_wanted($submission, $updated, $action) { [{ submission: $row.submission, action: $action, recipient: $row.id }] } ELSE { [] }
    };
} COMMENT "Interne : un échec de fn::mail_queue_fail ($item validé, $claim, $now, $settings de l'installation, $suspended_until : fin de suspension de la destination) ; NONE si la réservation ne le tient plus (rien n'est écrit) ; sinon { recipient, state, next_attempt_at, dsn }";

-- ----------------------------------------------------------------------------
-- fn::mail_queue_release
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_queue_release($params: object) {
    LET $sized = fn::validation_array_length($params.recipients, 1, 500);
    LET $report = fn::validation_checks_report($params, {
        claim: fn::validation_uuid_v7($params.claim, true),
        recipients: IF $sized.valid { array::map($sized.value, |$r: any| fn::validation_record($r, "mail_queue_recipient")) } ELSE { $sized },
        not_before: IF $params.not_before IS NONE { fn::mail_absent() } ELSE { fn::validation_datetime($params.not_before, d"1970-01-01T00:00:00Z", NONE) },
        language: fn::validation_language_code(IF $params.language IS NONE { "fr" } ELSE { $params.language }, false, NONE)
    });
    IF !$report.valid { RETURN fn::mail_queue_batch_error($report, $params, 500); };
    LET $p = $report.value;
    IF !fn::mail_can({ action: "worker" }) { RETURN fn::error_result("MAIL_PERMISSION_DENIED", $p.language, {}); };
    LET $now = time::now();
    LET $claim = <string> $p.claim;
    LET $at = $p.not_before ?? $now;
    LET $released = array::filter(array::map($p.recipients, |$r| (UPDATE ONLY $r SET state = "scheduled", next_attempt_at = $at, claim = NONE, locked_until = NONE, claimed_by = NONE
        WHERE state = "running" AND claim = $claim AND locked_until > $now)), |$row| $row IS NOT NONE).id;
    RETURN fn::mail_queue_lost(array::complement($p.recipients, $released), $p.language, { released: array::len($released), done: $released });
} COMMENT "Rend à la file des destinataires réservés et non commencés ({ claim, recipients : 1 à 500, not_before (échéance, maintenant par défaut : cadence de la destination) }) sans essai compté : arrêt propre, cadence d'une destination, connexion coupée avant leur tour ; { released, lost } ; tous perdus : MAIL_QUEUE_CLAIM_LOST ; plus de 500 : MAIL_QUEUE_BATCH_TOO_LARGE. Droit : compte de service, session système";

-- ----------------------------------------------------------------------------
-- fn::mail_queue_dsn_done
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_queue_dsn_done($params: object) {
    LET $sized = fn::validation_array_length($params.recipients, 1, 1000);
    LET $report = fn::validation_checks_report($params, {
        submission: fn::validation_record($params.submission, "mail_submission"),
        action: fn::validation_enum($params.action, ["failed", "delayed", "delivered", "relayed"], true),
        recipients: IF $sized.valid { array::map($sized.value, |$r: any| fn::validation_record($r, "mail_queue_recipient")) } ELSE { $sized },
        language: fn::validation_language_code(IF $params.language IS NONE { "fr" } ELSE { $params.language }, false, NONE)
    });
    IF !$report.valid { RETURN fn::mail_queue_batch_error($report, $params, 1000); };
    LET $p = $report.value;
    IF !fn::mail_can({ action: "worker" }) { RETURN fn::error_result("MAIL_PERMISSION_DENIED", $p.language, {}); };
    LET $marked = IF $p.action = "delayed" {
        (UPDATE $p.recipients SET delay_sent = true WHERE submission = $p.submission AND !delay_sent)
    } ELSE {
        (UPDATE $p.recipients SET dsn_sent = true WHERE submission = $p.submission AND !dsn_sent)
    };
    RETURN fn::result_ok({ marked: array::len($marked) });
} COMMENT "Note les avis produits ({ submission, action (failed, delayed, delivered, relayed), recipients : 1 à 1 000 destinataires de l'envoi }) : delay_sent (retard) ou dsn_sent (avis final) ; un avis n'est jamais produit deux fois, même après une reprise ; { marked } (destinataires notés par cet appel). Droit : compte de service, session système";

-- ----------------------------------------------------------------------------
-- fn::mail_queue_stats
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_queue_stats($params: object) {
    LET $report = fn::validation_fields_execute($params, {
        language: { checks: [|$v: any| fn::validation_language_code($v, false, NONE)], default: "fr" }
    }, "reject");
    IF !$report.valid {
        RETURN fn::error_result("MAIL_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::mail_can({ action: "worker" }) { RETURN fn::error_result("MAIL_PERMISSION_DENIED", $p.language, {}); };
    LET $now = time::now();
    -- Échus : plage bornée de l'échéancier, comptée jusqu'à 10 000
    LET $due = (SELECT at FROM type::record("mail_queue_due", "0"..string::concat(<string> (10000000000000000 + time::micros($now) + 1), "_")) LIMIT 10000);
    RETURN fn::result_ok({
        scheduled: count(SELECT VALUE id FROM mail_queue_recipient WHERE state = "scheduled"),
        running: count(SELECT VALUE id FROM mail_queue_recipient WHERE state = "running"),
        due: array::len($due),
        oldest_due_at: $due[0].at,
        suspended_destinations: count(SELECT VALUE id FROM mail_queue_destination WHERE suspended_until > $now)
    });
} COMMENT "Mesures de la file ({ }) : { scheduled, running (index d'état), due (échus ou baux expirés, comptés sur l'échéancier jusqu'à 10 000), oldest_due_at (plus ancienne échéance passée : file bloquée ou trop lente), suspended_destinations }, pour la sonde et /metrics. Droit : compte de service, session système";

-- ----------------------------------------------------------------------------
-- fn::mail_queue_purge
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_queue_purge($params: object) {
    LET $report = fn::validation_fields_execute($params, {
        limit: { checks: [|$v: any| fn::validation_integer($v, 1, 1000)], default: 100 },
        language: { checks: [|$v: any| fn::validation_language_code($v, false, NONE)], default: "fr" }
    }, "reject");
    IF !$report.valid {
        RETURN fn::error_result("MAIL_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::mail_can({ action: "worker" }) { RETURN fn::error_result("MAIL_PERMISSION_DENIED", $p.language, {}); };
    LET $now = time::now();
    -- Contenus des envois finis : fichier supprimé aussitôt (il ne sert plus)
    LET $finished = (SELECT id, tenant, content FROM mail_submission WHERE state = "done" AND content.removed_at IS NONE ORDER BY done_at LIMIT $p.limit);
    FOR $row IN $finished {
        fn::mail_submission_file_remove($row);
        UPDATE $row.id SET content.removed_at = $now;
    };
    -- Envois finis depuis 14 jours (destinataires emportés), dépôts abandonnés ou jamais clos avec leur fichier
    LET $old = (SELECT VALUE id FROM mail_submission WHERE state = "done" AND done_at < $now - 14d ORDER BY done_at LIMIT $p.limit);
    LET $abandoned = (SELECT id, tenant, content FROM mail_submission WHERE state = "pending" AND (aborted_at IS NOT NONE OR pending_expires_at < $now) ORDER BY pending_expires_at LIMIT $p.limit);
    FOR $row IN $abandoned { fn::mail_submission_file_remove($row); };
    LET $removed = (DELETE array::concat($old, $abandoned.id) RETURN BEFORE);
    -- Adresses de retour échues, compteurs d'envoi dont la fenêtre est passée
    LET $tokens = (UPDATE mail_submission SET return_token = NONE WHERE return_token IS NOT NONE AND return_expires_at < $now);
    LET $counters = (DELETE mail_send_counter WHERE expires_at < $now RETURN BEFORE);
    RETURN fn::result_ok({ submissions: array::len($removed), contents: array::len($finished) + array::len($abandoned), tokens: array::len($tokens), counters: array::len($counters) });
} COMMENT "Maintenance de la file ({ limit : 100 }) : fichiers des envois finis supprimés ; envois finis depuis 14 jours retirés avec leurs destinataires ; dépôts abandonnés ou non clos dans l'heure retirés avec leur fichier (compteurs rendus) ; jetons de retour échus effacés ; compteurs d'envoi échus retirés ; { submissions, contents, tokens, counters }. Droit : session système, ou compte de service qui gère aussi les fichiers (storage.worker)";

DEFINE FUNCTION OVERWRITE fn::mail_submission_file_remove($row: object) -> bool {
    LET $object = IF $row.content.object IS NOT NONE {
        fn::storage_object_get({ object: <string> $row.content.object })
    } ELSE {
        LET $bucket = fn::mail_content_bucket($row.tenant);
        IF $bucket IS NONE { NONE } ELSE { fn::storage_object_get({ bucket: <string> $bucket, key: $row.content.key }) }
    };
    IF $object IS NOT NONE AND !$object.ok AND $object.error.code != "STORAGE_OBJECT_NOT_FOUND" { THROW "MAIL_CONTENT_UNAVAILABLE"; };
    IF $object IS NOT NONE AND $object.ok AND $object.data.state != "deleted" {
        LET $removed = fn::storage_object_delete({ object: <string> $object.data.id });
        IF !$removed.ok { THROW $removed.error.code; };
    };
    RETURN true;
} COMMENT "Interne : supprime le fichier d'un envoi ($row : id, tenant, content) par lyxal_storage : sa fiche (envoi clos), sinon celle écrite à sa clé (dépôt interrompu) ; un fichier jamais écrit est ignoré ; un refus de lyxal_storage annule tout (THROW)";

-- ----------------------------------------------------------------------------
-- fn::mail_return_record
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_return_record($params: object) {
    LET $report = fn::mail_queue_batch_report($params, "return", 100, { submission: fn::validation_record($params.submission, "mail_submission") });
    IF !$report.valid { RETURN fn::mail_queue_batch_error($report, $params, 100); };
    LET $p = $report.value;
    IF !fn::mail_can({ action: "worker" }) { RETURN fn::error_result("MAIL_PERMISSION_DENIED", $p.language, {}); };
    IF !record::exists($p.submission) { RETURN fn::error_result("MAIL_SUBMISSION_NOT_FOUND", $p.language, { submission: <string> $p.submission }); };
    LET $now = time::now();
    -- Rejet après acceptation : seuls les échecs d'un destinataire remis ou relayé de cet envoi
    LET $failed = array::filter($p.items, |$i| fn::sanitize_lowercase($i.action) = "failed");
    LET $bounced = array::filter(array::map($failed, |$i| (UPDATE ONLY $i.recipient SET state = "bounced",
        last_result = { stage: "bounce", enhanced: $i.status, text: $i.diagnostic, at: $now }
        WHERE submission = $p.submission AND state IN ["delivered", "relayed"])), |$row| $row IS NOT NONE);
    RETURN fn::result_ok({ bounced: array::len($bounced), ignored: array::len($p.items) - array::len($bounced) });
} COMMENT "Inscrit un avis de non-remise reçu sur une adresse de retour ({ submission, items : 1 à 100 × { recipient, action (failed, delayed, delivered, relayed, expanded), status, diagnostic } }, §10.3) : un échec d'un destinataire de l'envoi déjà remis ou relayé le passe à bounced (mail.submission.bounced) ; les autres éléments sont seulement comptés ; { bounced, ignored }. Droit : compte de service, session système";
