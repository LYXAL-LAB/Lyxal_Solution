-- ============================================================================
-- FONCTIONS : worker (passes de réconciliation, essais, vérifications, purge, santé)
-- MODULE    : lyxal_infra
-- ============================================================================
-- Appelées par les tâches de lyxal_scheduler exécutées dans lyxal-server (lot 1b) : droit
-- infra.worker ou session système. Une passe d'une zone (plan §3.2) : fn::infra_zone_claim,
-- lecture chez l'hébergeur (Rust), fn::infra_zone_observe, fn::infra_zone_plan,
-- fn::infra_zone_apply_begin, écriture chez l'hébergeur (Rust), fn::infra_zone_apply_result,
-- vérification, fn::infra_zone_release. Toute écriture d'une passe exige le jeton de réservation
-- de la zone (INFRA_ZONE_CLAIM_LOST). Entrées contrôlées par fn::validation_fields_execute.

-- ----------------------------------------------------------------------------
-- fn::infra__claim_check (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::infra__claim_check($zone: record<infra_zone>, $claim: string) -> object {
    LET $row = (SELECT * FROM ONLY $zone);
    IF $row == NONE { RETURN { code: "INFRA_ZONE_NOT_FOUND", zone: NONE }; };
    IF $row.claim != $claim OR $row.locked_until IS NONE OR $row.locked_until <= time::now() { RETURN { code: "INFRA_ZONE_CLAIM_LOST", zone: NONE }; };
    RETURN { code: NONE, zone: $row };
} COMMENT "Interne : { code : NONE, zone } si la zone est réservée par ce jeton et que la réservation court ; sinon { code : INFRA_ZONE_NOT_FOUND ou INFRA_ZONE_CLAIM_LOST }";

-- ----------------------------------------------------------------------------
-- fn::infra__worker_refusal (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::infra__worker_refusal($report: object, $params: any) -> option<object> {
    IF !$report.valid { RETURN fn::infra__invalid($params, $report.by_field); };
    IF !fn::infra_can({ action: "worker" }) { RETURN fn::error_result("INFRA_PERMISSION_DENIED", $report.value.language, {}); };
    RETURN NONE;
} COMMENT "Interne : erreur à rendre par une fonction du worker (paramètres refusés par lyxal_core, droit infra.worker manquant), NONE sinon";

-- ----------------------------------------------------------------------------
-- fn::infra_account_due
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::infra_account_due($params: object) {
    LET $report = fn::validation_fields_execute($params, {
        limit: { checks: [|$v: any| fn::validation_integer($v, 1, 100)], default: 20 },
        language: { checks: [|$v: any| fn::validation_language_code($v, false, NONE)], default: "fr" }
    }, "reject");
    LET $refusal = fn::infra__worker_refusal($report, $params);
    IF $refusal IS NOT NONE { RETURN $refusal; };
    LET $p = $report.value;
    LET $rows = (SELECT id, provider, credentials_path, settings, test_requested_at FROM infra_account
        WHERE test_requested_at IS NOT NONE AND test_requested_at <= time::now() AND state != "disabled" ORDER BY test_requested_at ASC, id ASC);
    RETURN fn::result_ok({ items: array::map(array::slice($rows, 0, $p.limit), |$a| { account: $a.id, provider: $a.provider, credentials_path: $a.credentials_path, settings: $a.settings }) });
} COMMENT "Worker : comptes dont un essai est demandé ({ limit : 100 au plus }), le plus ancien d'abord : { items : [{ account, provider, credentials_path, settings }] } (chemin du secret, jamais de valeur). Droit infra.worker, session système";

-- ----------------------------------------------------------------------------
-- fn::infra_account_test_result
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::infra_account_test_result($params: object) {
    LET $report = fn::validation_fields_execute($params, {
        account: { checks: [|$v: any| fn::validation_record($v, "infra_account")], required: true },
        ok: { checks: [|$v: any| fn::validation_boolean($v)], required: true },
        code: { checks: [|$v: any| fn::validation_enum($v, ["INFRA_PROVIDER_AUTH", "INFRA_PROVIDER_REJECTED", "INFRA_PROVIDER_NOT_FOUND", "INFRA_PROVIDER_QUOTA", "INFRA_PROVIDER_RATE_LIMITED", "INFRA_PROVIDER_UNAVAILABLE", "INFRA_PROVIDER_RESPONSE_INVALID", "INFRA_CREDENTIALS_UNAVAILABLE"], true)] },
        zones: { checks: [|$v: any| fn::validation_array_objects($v, false), |$v: any| fn::validation_array_length($v, 0, 1000)], default: [] },
        language: { checks: [|$v: any| fn::validation_language_code($v, false, NONE)], default: "fr" }
    }, "reject");
    LET $refusal = fn::infra__worker_refusal($report, $params);
    IF $refusal IS NOT NONE { RETURN $refusal; };
    LET $p = $report.value;
    IF !$p.ok AND $p.code IS NONE { RETURN fn::infra__invalid($params, { code: ["CORE_VALIDATION_REQUIRED"] }); };
    -- Zones rendues par le fournisseur : nom DNS (A-label, minuscules) et statut
    LET $zones = array::map($p.zones, |$z, $i| {
        LET $name = fn::validation_dns_name($z.name, false, false, NONE);
        LET $status = fn::validation_required_string($z.status, 1, 32);
        RETURN { index: $i, valid: $name.valid AND $status.valid, value: { name: $name.value, status: $status.value } };
    });
    LET $wrong = array::first(array::filter($zones, |$z| !$z.valid));
    IF $wrong IS NOT NONE { RETURN fn::infra__invalid($params, object::from_entries([["zones[" + <string> $wrong.index + "]", ["CORE_VALIDATION_FORMAT"]]])); };
    LET $current = (SELECT id, state FROM ONLY $p.account);
    IF $current == NONE { RETURN fn::error_result("INFRA_ACCOUNT_NOT_FOUND", $p.language, { account: <string> $p.account }); };
    LET $updated = (UPDATE ONLY $current.id SET
        last_test = { at: time::now(), ok: $p.ok, code: IF $p.ok { NONE } ELSE { $p.code } },
        test_requested_at = NONE,
        discovered_zones = IF $p.ok { $zones.value } ELSE { discovered_zones },
        state = IF state = "disabled" { "disabled" } ELSE IF $p.ok { "active" } ELSE IF $p.code = "INFRA_PROVIDER_AUTH" { "failing" } ELSE { state });
    IF $updated == NONE { RETURN fn::error_result("INFRA_WRITE_FORBIDDEN", $p.language, { table: "infra_account" }); };
    RETURN fn::result_ok({ account: $updated.id, state: $updated.state, zones: array::len($updated.discovered_zones) });
} COMMENT "Worker : résultat de l'essai d'un compte ({ account, ok, code (INFRA_PROVIDER_* ou INFRA_CREDENTIALS_UNAVAILABLE si ok est faux), zones : 1 000 au plus × { name, status } }) : dernier essai noté, demande effacée, zones visibles remplacées si l'essai a réussi ; clé refusée (INFRA_PROVIDER_AUTH) : compte failing ; réussite : active (sauf disabled). Rend { account, state, zones }. Droit infra.worker, session système";

-- ----------------------------------------------------------------------------
-- fn::infra_zone_due
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::infra_zone_due($params: object) {
    LET $report = fn::validation_fields_execute($params, {
        limit: { checks: [|$v: any| fn::validation_integer($v, 1, 500)], default: 100 },
        language: { checks: [|$v: any| fn::validation_language_code($v, false, NONE)], default: "fr" }
    }, "reject");
    LET $refusal = fn::infra__worker_refusal($report, $params);
    IF $refusal IS NOT NONE { RETURN $refusal; };
    LET $p = $report.value;
    LET $now = time::now();
    LET $active = (SELECT VALUE id FROM infra_account WHERE state = "active");
    LET $zones = (SELECT id, account, next_reconcile_at, reconcile_requested_at, reconciled_at, locked_until FROM infra_zone
        WHERE account IN $active AND (locked_until IS NONE OR locked_until <= $now) ORDER BY next_reconcile_at ASC, id ASC);
    -- Échue : passe périodique, demande, ou déclaration (pending, releasing) plus récente que la dernière passe
    LET $due = array::filter($zones, |$z| $z.next_reconcile_at <= $now
        OR ($z.reconcile_requested_at IS NOT NONE AND $z.reconcile_requested_at <= $now)
        OR count(SELECT id FROM infra_record WHERE zone = $z.id AND state IN ["pending", "releasing"] AND updated_at > ($z.reconciled_at ?? d"1970-01-01T00:00:00Z")) > 0);
    RETURN fn::result_ok({ items: array::map(array::slice($due, 0, $p.limit), |$z| { zone: $z.id, account: $z.account }) });
} COMMENT "Worker : zones à réconcilier ({ limit : 500 au plus }) d'un compte actif, non réservées : passe périodique échue, passe demandée, ou enregistrement pending ou releasing modifié depuis la dernière passe ; { items : [{ zone, account }] }. Droit infra.worker, session système";

-- ----------------------------------------------------------------------------
-- fn::infra_zone_claim
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::infra_zone_claim($params: object) {
    LET $report = fn::validation_fields_execute($params, {
        zone: { checks: [|$v: any| fn::validation_record($v, "infra_zone")], required: true },
        ttl_seconds: { checks: [|$v: any| fn::validation_integer($v, 60, 900)], default: 300 },
        language: { checks: [|$v: any| fn::validation_language_code($v, false, NONE)], default: "fr" }
    }, "reject");
    LET $refusal = fn::infra__worker_refusal($report, $params);
    IF $refusal IS NOT NONE { RETURN $refusal; };
    LET $p = $report.value;
    IF !record::exists($p.zone) { RETURN fn::error_result("INFRA_ZONE_NOT_FOUND", $p.language, { zone: <string> $p.zone }); };
    LET $claim_token = <string> rand::uuid::v7();
    LET $until = time::now() + <duration> (<string> $p.ttl_seconds + "s");
    LET $claimed = (UPDATE ONLY $p.zone SET claim = $claim_token, claimed_at = time::now(), locked_until = $until
        WHERE locked_until IS NONE OR locked_until <= time::now());
    IF $claimed == NONE { RETURN fn::error_result("INFRA_ZONE_CLAIM_LOST", $p.language, { zone: <string> $p.zone }); };
    LET $account = (SELECT id, provider, credentials_path, settings, state FROM ONLY $claimed.account);
    RETURN fn::result_ok({
        zone: $claimed.id,
        claim: $claim_token,
        locked_until: $until,
        name: $claimed.name,
        provider_ref: $claimed.provider_ref,
        mode: $claimed.mode,
        nameservers: $claimed.nameservers,
        account: { account: $account.id, provider: $account.provider, credentials_path: $account.credentials_path, settings: $account.settings, state: $account.state }
    });
} COMMENT "Worker : réserve une zone pour une passe ({ zone, ttl_seconds : 60 à 900, 300 par défaut }) : jeton (UUID) rendu avec ce qu'il faut pour appeler l'hébergeur (name, provider_ref, mode, nameservers, account : { account, provider, credentials_path, settings, state }) ; zone déjà réservée : INFRA_ZONE_CLAIM_LOST. Droit infra.worker, session système";

-- ----------------------------------------------------------------------------
-- fn::infra_zone_renew
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::infra_zone_renew($params: object) {
    LET $report = fn::validation_fields_execute($params, {
        zone: { checks: [|$v: any| fn::validation_record($v, "infra_zone")], required: true },
        claim: { checks: [|$v: any| fn::validation_uuid_v7($v, true)], required: true },
        ttl_seconds: { checks: [|$v: any| fn::validation_integer($v, 60, 900)], default: 300 },
        language: { checks: [|$v: any| fn::validation_language_code($v, false, NONE)], default: "fr" }
    }, "reject");
    LET $refusal = fn::infra__worker_refusal($report, $params);
    IF $refusal IS NOT NONE { RETURN $refusal; };
    LET $p = $report.value;
    LET $held = fn::infra__claim_check($p.zone, $p.claim);
    IF $held.code IS NOT NONE { RETURN fn::error_result($held.code, $p.language, { zone: <string> $p.zone }); };
    LET $until = time::now() + <duration> (<string> $p.ttl_seconds + "s");
    LET $renewed = (UPDATE ONLY $p.zone SET locked_until = $until WHERE claim = $p.claim);
    IF $renewed == NONE { RETURN fn::error_result("INFRA_ZONE_CLAIM_LOST", $p.language, { zone: <string> $p.zone }); };
    RETURN fn::result_ok({ zone: $p.zone, locked_until: $until });
} COMMENT "Worker : renouvelle la réservation d'une zone ({ zone, claim, ttl_seconds }) : { zone, locked_until } ; jeton perdu : INFRA_ZONE_CLAIM_LOST. Droit infra.worker, session système";

-- ----------------------------------------------------------------------------
-- fn::infra__observed_row (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::infra__observed_row($item: any, $index: int) -> object {
    LET $report = fn::validation_fields_execute($item, {
        provider_id: { checks: [|$v: any| fn::validation_required_string($v, 1, 128)], required: true },
        fqdn: { checks: [|$v: any| fn::validation_dns_name($v, true, true, NONE)], required: true },
        type: { checks: [|$v: any| fn::validation_alphanumeric($v, true), |$v: any| fn::validation_required_string($v, 1, 16)], required: true },
        value: { checks: [|$v: any| fn::validation_max_length($v, 4096)], required: true },
        ttl: { checks: [|$v: any| fn::validation_integer($v, 0, 2147483647)], required: true },
        comment: { checks: [|$v: any| fn::validation_max_length($v, 256)] }
    }, "reject");
    RETURN IF $report.valid { { valid: true, value: object::extend($report.value, { type: string::uppercase($report.value.type) }), errors: {} } }
        ELSE { { valid: false, value: NONE, errors: object::from_entries(array::map(object::entries($report.by_field), |$e| ["records[" + <string> $index + "]." + $e[0], $e[1]])) } };
} COMMENT "Interne : ligne lue chez le fournisseur ($item, rang $index) contrôlée par fn::validation_fields_execute (provider_id, fqdn : nom DNS, tiret bas et joker permis, type, value : 4 096 caractères au plus, ttl, comment) ; type en majuscules. Rend { valid, value, errors }";

-- ----------------------------------------------------------------------------
-- fn::infra_zone_observe
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::infra_zone_observe($params: object) {
    LET $report = fn::validation_fields_execute($params, {
        zone: { checks: [|$v: any| fn::validation_record($v, "infra_zone")], required: true },
        claim: { checks: [|$v: any| fn::validation_uuid_v7($v, true)], required: true },
        status: { checks: [|$v: any| fn::validation_enum($v, ["active", "pending", "error", "locked"], true)], required: true },
        nameservers: { checks: [|$v: any| fn::validation_array_of_strings($v, false, 1, 253), |$v: any| fn::validation_array_length($v, 0, 20)], default: [] },
        delegated: { checks: [|$v: any| fn::validation_boolean($v)] },
        records: { checks: [|$v: any| fn::validation_array_objects($v, false), |$v: any| fn::validation_array_length($v, 0, 20000)], required: true },
        language: { checks: [|$v: any| fn::validation_language_code($v, false, NONE)], default: "fr" }
    }, "reject");
    LET $refusal = fn::infra__worker_refusal($report, $params);
    IF $refusal IS NOT NONE { RETURN $refusal; };
    LET $p = $report.value;
    LET $checked = array::map($p.records, |$item, $index| fn::infra__observed_row($item, $index));
    LET $errors = array::fold(array::filter($checked, |$c| !$c.valid), {}, |$acc, $c| object::extend($acc, $c.errors));
    IF !object::is_empty($errors) { RETURN fn::infra__invalid($params, $errors); };
    LET $held = fn::infra__claim_check($p.zone, $p.claim);
    IF $held.code IS NOT NONE { RETURN fn::error_result($held.code, $p.language, { zone: <string> $p.zone }); };
    LET $zone = $held.zone;
    LET $zone_key = <string> record::id($zone.id);
    -- Propriétaires : marque lyxal:<clé> du commentaire, sinon identifiant noté à l'écriture
    -- Index (fn::utils_collection_index_by) : la photo d'une grande zone est comparée en temps linéaire
    LET $wanted = (SELECT id, provider_ids FROM infra_record WHERE zone = $zone.id AND state != "released");
    LET $by_key = fn::utils_collection_index_by(array::map($wanted, |$w| { key: <string> record::id($w.id), id: $w.id }), "key");
    LET $by_provider = fn::utils_collection_index_by(array::flatten(array::map($wanted, |$w| array::map($w.provider_ids, |$written| { provider_id: $written.id, id: $w.id }))), "provider_id");
    LET $incoming = array::map($checked.value, |$o| {
        LET $marked = IF $o.comment IS NOT NONE AND string::starts_with($o.comment, "lyxal:") { $by_key[string::slice($o.comment, 6)].id } ELSE { NONE };
        RETURN object::extend($o, {
            id: type::record("infra_zone_record", $zone_key + "_" + $o.provider_id),
            record: $marked ?? $by_provider[$o.provider_id].id
        });
    });
    -- Écriture par différence : seules les lignes nouvelles ou changées sont écrites (lecture
    -- ponctuelle par identifiant ; une fermeture recopierait la photo entière à chaque ligne)
    LET $start = time::now();
    FOR $o IN $incoming {
        LET $old = (SELECT fqdn, type, value, ttl, comment, record FROM ONLY $o.id);
        IF $old == NONE OR $old.fqdn != $o.fqdn OR $old.type != $o.type OR $old.value != $o.value OR $old.ttl != $o.ttl OR $old.comment != $o.comment OR $old.record != $o.record {
            UPSERT $o.id CONTENT { zone: $zone.id, provider_id: $o.provider_id, fqdn: $o.fqdn, type: $o.type, value: $o.value, ttl: $o.ttl, comment: $o.comment, record: $o.record, seen_at: time::now() };
        };
    };
    LET $incoming_by = fn::utils_collection_index_by($incoming, "provider_id");
    LET $removed = (DELETE infra_zone_record WHERE zone = $zone.id AND $incoming_by[provider_id] IS NONE RETURN BEFORE);
    LET $changed = count(SELECT id FROM infra_zone_record WHERE zone = $zone.id AND seen_at >= $start);
    -- Écritures filtrées par les permissions : la photo enregistrée ne compte pas toutes les lignes
    IF count(SELECT id FROM infra_zone_record WHERE zone = $zone.id) != array::len($incoming) { THROW "INFRA_WRITE_FORBIDDEN"; };
    LET $hash = fn::security_hash_object({ rows: array::sort(array::map($incoming, |$o| string::join("\n", $o.provider_id, $o.fqdn, $o.type, $o.value, <string> $o.ttl, $o.comment ?? ""))) }, "sha256").hash;
    LET $state = IF $p.delegated = false { "not_delegated" } ELSE IF $p.status = "pending" { "pending_provider" }
        ELSE IF $zone.state IN ["not_delegated", "pending_provider", "failing"] { "ok" } ELSE { $zone.state };
    LET $updated = (UPDATE ONLY $zone.id SET nameservers = $p.nameservers, delegated = $p.delegated ?? delegated, observed_hash = $hash, state = $state);
    IF $updated == NONE { THROW "INFRA_WRITE_FORBIDDEN"; };
    RETURN fn::result_ok({
        zone: $zone.id,
        total: array::len($incoming),
        written: $changed,
        removed: array::len($removed),
        owned: array::len(array::filter($incoming, |$o| $o.record IS NOT NONE)),
        state: $state,
        hash: $hash
    });
} COMMENT "Worker : photo de la zone réservée lue chez le fournisseur ({ zone, claim, status : active, pending, error, locked ; nameservers ; delegated : rattachement vérifié chez la zone parente ; records : 20 000 au plus × { provider_id, fqdn, type, value (canonique), ttl, comment } }) écrite par différence dans infra_zone_record (lignes nouvelles ou changées écrites, disparues supprimées), chaque ligne rattachée à son enregistrement de Lyxal (marque lyxal:<clé> ou identifiant noté) ; état de la zone : not_delegated, pending_provider, sinon ok (blocked conservé). Rend { zone, total, written, removed, owned, state, hash }. Droit infra.worker, session système ; jeton exigé";

-- ----------------------------------------------------------------------------
-- fn::infra_zone_apply_begin
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::infra_zone_apply_begin($params: object) {
    LET $report = fn::validation_fields_execute($params, {
        zone: { checks: [|$v: any| fn::validation_record($v, "infra_zone")], required: true },
        claim: { checks: [|$v: any| fn::validation_uuid_v7($v, true)], required: true },
        plan_hash: { checks: [|$v: any| fn::validation_hexadecimal($v, 64, 64, false)], required: true },
        language: { checks: [|$v: any| fn::validation_language_code($v, false, NONE)], default: "fr" }
    }, "reject");
    LET $refusal = fn::infra__worker_refusal($report, $params);
    IF $refusal IS NOT NONE { RETURN $refusal; };
    LET $p = $report.value;
    LET $held = fn::infra__claim_check($p.zone, $p.claim);
    IF $held.code IS NOT NONE { RETURN fn::error_result($held.code, $p.language, { zone: <string> $p.zone }); };
    LET $zone = $held.zone;
    IF $zone.mode != "managed" OR $zone.state = "blocked" OR $zone.last_plan.hash != string::lowercase($p.plan_hash) {
        RETURN fn::error_result("INFRA_ZONE_PLAN_STALE", $p.language, { zone: <string> $zone.id, mode: $zone.mode, state: $zone.state });
    };
    -- Intention notée avant l'appel (sent) ; l'issue est posée par fn::infra_zone_apply_result
    LET $sent = array::map($zone.last_plan.changes, |$c| {
        LET $entry = fn::infra__change_write({
            zone: $zone.id, record: $c.record, action: $c.action, state: "sent",
            before: IF $c.action = "add" { NONE } ELSE { { provider_id: $c.provider_id, fqdn: $c.fqdn, type: $c.type, value: $c.value } },
            after: IF $c.action = "delete" { NONE } ELSE { { provider_id: $c.provider_id, fqdn: $c.fqdn, type: $c.type, value: $c.value, ttl: $c.ttl } }
        });
        RETURN IF $entry IS NONE { NONE } ELSE { object::extend($c, { change: $entry.id, comment: "lyxal:" + <string> record::id($c.record) }) };
    });
    IF array::any($sent, |$s| $s IS NONE) { THROW "INFRA_WRITE_FORBIDDEN"; };
    LET $updated = (UPDATE ONLY $zone.id SET approved_plan_hash = NONE);
    IF $updated == NONE { THROW "INFRA_WRITE_FORBIDDEN"; };
    RETURN fn::result_ok({ zone: $zone.id, changes: $sent });
} COMMENT "Worker : début de l'écriture du plan rangé d'une zone gérée réservée ({ zone, claim, plan_hash }) : une entrée sent au journal par changement, avant l'appel ; rend { zone, changes : [{ change (entrée du journal), action, record, provider_id, fqdn, type, value, ttl, comment (marque lyxal:<clé> à écrire chez le fournisseur) }] } ; une approbation est consommée. Zone en observation ou bloquée, ou plan changé : INFRA_ZONE_PLAN_STALE. Droit infra.worker, session système ; jeton exigé";

-- ----------------------------------------------------------------------------
-- fn::infra__apply_record (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::infra__apply_record($row: object, $results: array) -> object {
    LET $added = array::map(array::filter($results, |$x| $x.ok AND $x.action = "add"), |$x| { id: $x.provider_id, value: $x.value });
    LET $deleted = array::filter($results, |$x| $x.ok AND $x.action = "delete").provider_id;
    LET $ids = array::concat(array::filter($row.provider_ids, |$w| $w.id NOT IN $deleted), $added);
    LET $permanent = array::first(array::filter($results, |$x| !$x.ok AND !$x.retryable));
    LET $transient = array::any($results, |$x| !$x.ok AND $x.retryable);
    LET $state = IF $permanent IS NOT NONE { "failed" }
        ELSE IF $transient { $row.state }
        -- Retrait demandé pendant l'écriture (même quand aucun identifiant n'était encore noté) : il est
        -- gardé, et une écriture rendue tardivement reste notée pour être supprimée à la passe suivante
        ELSE IF $row.state IN ["releasing", "released"] { IF array::len($ids) = 0 { "released" } ELSE { "releasing" } }
        ELSE { "written" };
    LET $updated = (UPDATE ONLY $row.id SET
        provider_ids = $ids,
        applied_values = array::distinct($ids.value),
        state = $state,
        conflict = IF $state = "written" { NONE } ELSE { conflict },
        error = IF $permanent IS NOT NONE { { code: $permanent.code, at: time::now() } } ELSE IF $state = "written" { NONE } ELSE { error },
        written_at = IF $state = "written" { time::now() } ELSE { written_at },
        verify_attempts = IF $state = "written" { 0 } ELSE { verify_attempts },
        next_verify_at = IF $state = "written" { time::now() + 30s } ELSE { NONE },
        resolution = IF $state = "written" AND resolution.action = "take_over" AND resolution.applied_at IS NONE { object::extend(resolution, { applied_at: time::now() }) } ELSE { resolution });
    RETURN { record: $row.id, state: $state, written: $updated != NONE };
} COMMENT "Interne : issue des changements d'un enregistrement ($row, $results joints au journal) : identifiants ajoutés et retirés ; échec définitif : failed (code) ; échec passager : état inchangé (passe reprise) ; enregistrement retiré (releasing, ou released pendant l'écriture) : releasing tant qu'il reste un identifiant noté (écriture tardive supprimée à la passe suivante), sinon released ; sinon written, vérification dans 30 s, take_over consommé";

-- ----------------------------------------------------------------------------
-- fn::infra_zone_apply_result
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::infra_zone_apply_result($params: object) {
    LET $report = fn::validation_fields_execute($params, {
        zone: { checks: [|$v: any| fn::validation_record($v, "infra_zone")], required: true },
        claim: { checks: [|$v: any| fn::validation_uuid_v7($v, true)], required: true },
        results: { checks: [|$v: any| fn::validation_array_objects($v, false), |$v: any| fn::validation_array_length($v, 1, 5000)], required: true },
        language: { checks: [|$v: any| fn::validation_language_code($v, false, NONE)], default: "fr" }
    }, "reject");
    LET $refusal = fn::infra__worker_refusal($report, $params);
    IF $refusal IS NOT NONE { RETURN $refusal; };
    LET $p = $report.value;
    LET $checked = array::map($p.results, |$item, $index| {
        LET $one = fn::validation_fields_execute($item, {
            change: { checks: [|$v: any| fn::validation_record($v, "infra_change")], required: true },
            ok: { checks: [|$v: any| fn::validation_boolean($v)], required: true },
            provider_id: { checks: [|$v: any| fn::validation_required_string($v, 1, 128)] },
            provider_status: { checks: [|$v: any| fn::validation_integer($v, 100, 599)] },
            code: { checks: [|$v: any| fn::validation_enum($v, ["INFRA_PROVIDER_AUTH", "INFRA_PROVIDER_REJECTED", "INFRA_PROVIDER_NOT_FOUND", "INFRA_PROVIDER_QUOTA", "INFRA_PROVIDER_RATE_LIMITED", "INFRA_PROVIDER_UNAVAILABLE", "INFRA_PROVIDER_RESPONSE_INVALID", "INFRA_CREDENTIALS_UNAVAILABLE"], true)] },
            retryable: { checks: [|$v: any| fn::validation_boolean($v)], default: false }
        }, "reject");
        RETURN { index: $index, report: $one };
    });
    LET $wrong = array::first(array::filter($checked, |$c| !$c.report.valid));
    IF $wrong IS NOT NONE { RETURN fn::infra__invalid($params, object::from_entries(array::map(object::entries($wrong.report.by_field), |$e| ["results[" + <string> $wrong.index + "]." + $e[0], $e[1]]))); };
    LET $results = $checked.report.value;
    LET $held = fn::infra__claim_check($p.zone, $p.claim);
    IF $held.code IS NOT NONE { RETURN fn::error_result($held.code, $p.language, { zone: <string> $p.zone }); };
    -- Chaque résultat répond à une intention sent de cette zone ; un ajout réussi rend son identifiant
    LET $entries = (SELECT id, zone, record, action, state, before, after FROM infra_change WHERE id IN $results.change);
    LET $joined = array::map($results, |$x| {
        LET $entry = array::first(array::filter($entries, |$e| $e.id = $x.change));
        RETURN object::extend($x, {
            entry: $entry,
            action: $entry.action,
            record: $entry.record,
            value: $entry.after.value ?? $entry.before.value,
            provider_id: IF $entry.action = "add" { $x.provider_id } ELSE { $entry.before.provider_id ?? $entry.after.provider_id }
        });
    });
    LET $refused = array::find_index($joined, |$x| $x.entry IS NONE OR $x.entry.zone != $p.zone OR $x.entry.state != "sent"
        OR ($x.ok AND $x.action = "add" AND $x.provider_id IS NONE) OR (!$x.ok AND $x.code IS NONE));
    IF $refused IS NOT NONE { RETURN fn::infra__invalid($params, object::from_entries([["results[" + <string> $refused + "]", ["CORE_VALIDATION_NOT_ALLOWED"]]])); };
    LET $closed = array::map($joined, |$x| (UPDATE ONLY $x.change SET state = IF $x.ok { "done" } ELSE { "failed" }, provider_status = $x.provider_status, code = IF $x.ok { NONE } ELSE { $x.code }));
    IF array::any($closed, |$c| $c == NONE) { THROW "INFRA_WRITE_FORBIDDEN"; };
    LET $rows = (SELECT * FROM infra_record WHERE id IN array::distinct(array::filter($joined.record, |$r| $r IS NOT NONE)));
    LET $records = array::map($rows, |$row| fn::infra__apply_record($row, array::filter($joined, |$x| $x.record = $row.id)));
    IF array::any($records, |$r| !$r.written) { THROW "INFRA_WRITE_FORBIDDEN"; };
    LET $transient = array::first(array::filter($joined, |$x| !$x.ok AND $x.retryable));
    IF $transient IS NOT NONE {
        LET $noted = (UPDATE ONLY $p.zone SET last_error = { code: $transient.code, at: time::now() });
        IF $noted == NONE { THROW "INFRA_WRITE_FORBIDDEN"; };
    };
    RETURN fn::result_ok({
        zone: $p.zone,
        done: array::len(array::filter($joined, |$x| $x.ok)),
        failed: array::len(array::filter($joined, |$x| !$x.ok)),
        records: array::map($records, |$r| { record: $r.record, state: $r.state })
    });
} COMMENT "Worker : issue de l'écriture chez le fournisseur ({ zone, claim, results : 5 000 au plus × { change (entrée sent de la zone), ok, provider_id (identifiant attribué à un ajout), provider_status, code (INFRA_PROVIDER_*, si ok est faux), retryable } }) : entrée du journal done ou failed, identifiants des enregistrements tenus à jour, états written (vérification dans 30 s), released, failed (échec définitif) ou inchangé (échec passager, last_error de la zone). Rend { zone, done, failed, records : [{ record, state }] }. Droit infra.worker, session système ; jeton exigé";

-- ----------------------------------------------------------------------------
-- fn::infra_zone_release
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::infra_zone_release($params: object) {
    LET $report = fn::validation_fields_execute($params, {
        zone: { checks: [|$v: any| fn::validation_record($v, "infra_zone")], required: true },
        claim: { checks: [|$v: any| fn::validation_uuid_v7($v, true)], required: true },
        outcome: { checks: [|$v: any| fn::validation_enum($v, ["noop", "applied", "observed", "blocked", "failed"], true)], required: true },
        code: { checks: [|$v: any| fn::validation_enum($v, ["INFRA_PROVIDER_AUTH", "INFRA_PROVIDER_REJECTED", "INFRA_PROVIDER_NOT_FOUND", "INFRA_PROVIDER_QUOTA", "INFRA_PROVIDER_RATE_LIMITED", "INFRA_PROVIDER_UNAVAILABLE", "INFRA_PROVIDER_RESPONSE_INVALID", "INFRA_CREDENTIALS_UNAVAILABLE", "INFRA_DNS_UNAVAILABLE", "INFRA_WRITE_FORBIDDEN"], true)] },
        language: { checks: [|$v: any| fn::validation_language_code($v, false, NONE)], default: "fr" }
    }, "reject");
    LET $refusal = fn::infra__worker_refusal($report, $params);
    IF $refusal IS NOT NONE { RETURN $refusal; };
    LET $p = $report.value;
    IF $p.outcome = "failed" AND $p.code IS NONE { RETURN fn::infra__invalid($params, { code: ["CORE_VALIDATION_REQUIRED"] }); };
    LET $held = fn::infra__claim_check($p.zone, $p.claim);
    IF $held.code IS NOT NONE { RETURN fn::error_result($held.code, $p.language, { zone: <string> $p.zone }); };
    LET $zone = $held.zone;
    LET $failed = $p.outcome = "failed";
    -- Erreur définitive de l'hébergeur : zone en échec (sonde « dégradé ») ; clé refusée : compte en échec
    LET $permanent = $failed AND $p.code IN ["INFRA_PROVIDER_AUTH", "INFRA_PROVIDER_NOT_FOUND", "INFRA_PROVIDER_QUOTA"];
    LET $next = time::now() + <duration> (<string> fn::infra__settings().reconcile_minutes + "m");
    LET $updated = (UPDATE ONLY $zone.id SET
        claim = NONE, claimed_at = NONE, locked_until = NONE,
        reconciled_at = IF $failed { reconciled_at } ELSE { time::now() },
        next_reconcile_at = $next,
        reconcile_requested_at = IF reconcile_requested_at IS NOT NONE AND reconcile_requested_at <= $zone.claimed_at { NONE } ELSE { reconcile_requested_at },
        last_error = IF $failed { { code: $p.code, at: time::now() } } ELSE { NONE },
        state = IF $permanent { "failing" } ELSE IF !$failed AND state = "failing" { "ok" } ELSE { state }
        WHERE claim = $p.claim);
    IF $updated == NONE { RETURN fn::error_result("INFRA_ZONE_CLAIM_LOST", $p.language, { zone: <string> $p.zone }); };
    IF $failed AND $p.code = "INFRA_PROVIDER_AUTH" {
        LET $account = (UPDATE ONLY $zone.account SET state = "failing", last_test = { at: time::now(), ok: false, code: $p.code } WHERE state = "active");
    };
    RETURN fn::result_ok({ zone: $zone.id, state: $updated.state, next_reconcile_at: $next });
} COMMENT "Worker : fin de la passe d'une zone ({ zone, claim, outcome : noop, applied, observed, blocked, failed ; code si failed }) : réservation levée, prochaine passe dans reconcile_minutes, demande servie effacée ; réussite : reconciled_at, erreur effacée, failing levé ; échec : last_error, et zone failing pour une erreur définitive (INFRA_PROVIDER_AUTH, _NOT_FOUND, _QUOTA), compte failing si la clé est refusée. Rend { zone, state, next_reconcile_at }. Droit infra.worker, session système ; jeton exigé";

-- ----------------------------------------------------------------------------
-- fn::infra_records_to_verify
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::infra_records_to_verify($params: object) {
    LET $report = fn::validation_fields_execute($params, {
        limit: { checks: [|$v: any| fn::validation_integer($v, 1, 1000)], default: 200 },
        language: { checks: [|$v: any| fn::validation_language_code($v, false, NONE)], default: "fr" }
    }, "reject");
    LET $refusal = fn::infra__worker_refusal($report, $params);
    IF $refusal IS NOT NONE { RETURN $refusal; };
    LET $p = $report.value;
    LET $now = time::now();
    LET $rows = array::filter((SELECT id, zone, fqdn, type, values, written_at, next_verify_at FROM infra_record
        WHERE state = "written" AND next_verify_at <= $now ORDER BY next_verify_at ASC, id ASC), |$r| $r.next_verify_at <= $now);
    LET $page = array::slice($rows, 0, $p.limit);
    LET $zones = (SELECT id, name, nameservers FROM infra_zone WHERE id IN array::distinct($page.zone));
    RETURN fn::result_ok({
        items: array::map($page, |$r| {
            LET $zone = array::first(array::filter($zones, |$z| $z.id = $r.zone));
            RETURN { record: $r.id, zone: $r.zone, zone_name: $zone.name, nameservers: $zone.nameservers ?? [], fqdn: $r.fqdn, type: $r.type, values: $r.values, written_at: $r.written_at };
        })
    });
} COMMENT "Worker : enregistrements écrits dont la vérification est due ({ limit : 1 000 au plus }), le plus ancien d'abord : { items : [{ record, zone, zone_name, nameservers, fqdn, type, values, written_at }] } (questions à poser aux serveurs faisant autorité). Droit infra.worker, session système";

-- ----------------------------------------------------------------------------
-- fn::infra__verify_delay (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::infra__verify_delay($attempts: int) -> duration {
    RETURN [30s, 1m, 2m, 5m, 10m][$attempts - 1] ?? 30m;
} COMMENT "Interne : délai avant la vérification suivante après $attempts essais (30 s, 1, 2, 5, 10 min, puis toutes les 30 min)";

-- ----------------------------------------------------------------------------
-- fn::infra_record_verify_result
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::infra_record_verify_result($params: object) {
    LET $report = fn::validation_fields_execute($params, {
        record: { checks: [|$v: any| fn::validation_record($v, "infra_record")], required: true },
        written_at: { checks: [|$v: any| fn::validation_datetime($v, NONE, NONE)], required: true },
        published: { checks: [|$v: any| fn::validation_boolean($v)], required: true },
        code: { checks: [|$v: any| fn::validation_enum($v, ["INFRA_DNS_UNAVAILABLE"], true)] },
        language: { checks: [|$v: any| fn::validation_language_code($v, false, NONE)], default: "fr" }
    }, "reject");
    LET $refusal = fn::infra__worker_refusal($report, $params);
    IF $refusal IS NOT NONE { RETURN $refusal; };
    LET $p = $report.value;
    LET $row = (SELECT id, state, written_at, verify_attempts FROM ONLY $p.record);
    IF $row == NONE { RETURN fn::error_result("INFRA_RECORD_NOT_FOUND", $p.language, { record: <string> $p.record }); };
    -- Enregistrement changé depuis la question (nouvelle écriture, retrait) : réponse ignorée
    IF $row.state != "written" OR $row.written_at != <datetime> $p.written_at { RETURN fn::result_ok({ record: $row.id, state: $row.state, skipped: true }); };
    LET $attempts = $row.verify_attempts + 1;
    LET $expired = time::now() > $row.written_at + <duration> (<string> fn::infra__settings().verify_timeout_hours + "h");
    LET $updated = IF $p.published {
        (UPDATE ONLY $row.id SET state = "published", published_at = time::now(), verify_attempts = $attempts, next_verify_at = NONE, error = NONE)
    } ELSE IF $expired {
        (UPDATE ONLY $row.id SET state = "failed", verify_attempts = $attempts, next_verify_at = NONE, error = { code: "INFRA_DNS_NOT_PUBLISHED", at: time::now() })
    } ELSE {
        (UPDATE ONLY $row.id SET verify_attempts = $attempts, next_verify_at = time::now() + fn::infra__verify_delay($attempts),
            error = IF $p.code IS NONE { error } ELSE { { code: $p.code, at: time::now() } })
    };
    IF $updated == NONE { RETURN fn::error_result("INFRA_WRITE_FORBIDDEN", $p.language, { table: "infra_record" }); };
    RETURN fn::result_ok({ record: $row.id, state: $updated.state, skipped: false, next_verify_at: $updated.next_verify_at });
} COMMENT "Worker : réponse des serveurs faisant autorité pour un enregistrement écrit ({ record, written_at (rendu par fn::infra_records_to_verify), published : servi par tous, code : INFRA_DNS_UNAVAILABLE si les serveurs ne répondent pas }) : published ; sinon nouvel essai (30 s, 1, 2, 5, 10 min, puis 30 min) ; au-delà de verify_timeout_hours, failed (INFRA_DNS_NOT_PUBLISHED). Enregistrement changé depuis : ignoré (skipped). Rend { record, state, skipped, next_verify_at }. Droit infra.worker, session système";

-- ----------------------------------------------------------------------------
-- fn::infra_purge
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::infra_purge($params: object) {
    LET $report = fn::validation_fields_execute($params, {
        limit: { checks: [|$v: any| fn::validation_integer($v, 1, 10000)], default: 1000 },
        language: { checks: [|$v: any| fn::validation_language_code($v, false, NONE)], default: "fr" }
    }, "reject");
    LET $refusal = fn::infra__worker_refusal($report, $params);
    IF $refusal IS NOT NONE { RETURN $refusal; };
    LET $p = $report.value;
    LET $settings = fn::infra__settings();
    LET $cutoff = time::now() - <duration> (<string> $settings.change_retention_days + "d");
    -- Journal : seul un début de chaîne contigu est retiré (la chaîne restante se vérifie depuis sa
    -- première entrée), jamais la dernière entrée d'une zone
    LET $zones = array::distinct(SELECT VALUE zone FROM infra_change WHERE zone IS NOT NONE);
    LET $last_ranks = array::map($zones, |$z| math::max(SELECT VALUE rank FROM infra_change WHERE zone = $z));
    LET $first_recent = (SELECT VALUE rank FROM infra_change WHERE created_at >= $cutoff ORDER BY rank ASC LIMIT 1)[0];
    LET $bound = math::min(array::concat($last_ranks, [$first_recent ?? ((SELECT VALUE rank FROM ONLY infra_change_head:installation) ?? 0) + 1]));
    LET $old = array::slice((SELECT VALUE id FROM infra_change WHERE rank < $bound ORDER BY rank ASC LIMIT $p.limit), 0, $p.limit);
    LET $changes = IF array::len($old) = 0 { [] } ELSE { (DELETE $old RETURN BEFORE) };
    -- Enregistrements retirés au-delà de leur conservation
    LET $released_cutoff = time::now() - <duration> (<string> $settings.released_retention_days + "d");
    LET $gone = array::slice((SELECT VALUE id FROM infra_record WHERE state = "released" AND updated_at < $released_cutoff), 0, $p.limit);
    LET $records = IF array::len($gone) = 0 { [] } ELSE { (DELETE $gone RETURN BEFORE) };
    IF array::len($changes) != array::len($old) OR array::len($records) != array::len($gone) {
        RETURN fn::error_result("INFRA_WRITE_FORBIDDEN", $p.language, { table: IF array::len($changes) != array::len($old) { "infra_change" } ELSE { "infra_record" } });
    };
    RETURN fn::result_ok({ changes: array::len($changes), records: array::len($records), more: array::len($old) = $p.limit OR array::len($gone) = $p.limit });
} COMMENT "Worker (tâche infra.purge) : retire ({ limit : 10 000 au plus par table }) le début du journal plus ancien que change_retention_days (portion contiguse : la dernière entrée de chaque zone et tout ce qui la suit sont gardés) et les enregistrements released depuis plus de released_retention_days. Rend { changes, records, more }. Droit infra.worker, session système";

-- ----------------------------------------------------------------------------
-- fn::infra_health
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::infra_health($params: object) {
    LET $report = fn::validation_fields_execute($params, {
        language: { checks: [|$v: any| fn::validation_language_code($v, false, NONE)], default: "fr" }
    }, "reject");
    IF !$report.valid { RETURN fn::infra__invalid($params, $report.by_field); };
    LET $p = $report.value;
    IF !fn::infra_can({ action: "read" }) AND !fn::infra_can({ action: "worker" }) { RETURN fn::error_result("INFRA_PERMISSION_DENIED", $p.language, {}); };
    LET $settings = fn::infra__settings();
    LET $now = time::now();
    LET $accounts = (SELECT VALUE state FROM infra_account);
    LET $zones = (SELECT state, next_reconcile_at FROM infra_zone);
    LET $late = $now - <duration> (<string> ($settings.reconcile_minutes * 3) + "m");
    LET $records = (SELECT state, written_at FROM infra_record WHERE state IN ["conflict", "failed", "written"]);
    LET $counts = {
        accounts: array::len($accounts),
        accounts_failing: array::len(array::filter($accounts, |$s| $s = "failing")),
        zones: array::len($zones),
        zones_blocked: array::len(array::filter($zones, |$z| $z.state = "blocked")),
        zones_not_delegated: array::len(array::filter($zones, |$z| $z.state = "not_delegated")),
        zones_failing: array::len(array::filter($zones, |$z| $z.state = "failing")),
        zones_late: array::len(array::filter($zones, |$z| $z.next_reconcile_at < $late)),
        records_conflict: array::len(array::filter($records, |$r| $r.state = "conflict")),
        records_failed: array::len(array::filter($records, |$r| $r.state = "failed")),
        records_written_late: array::len(array::filter($records, |$r| $r.state = "written" AND $r.written_at < $now - 1h))
    };
    LET $settings_ok = record::exists(infra_settings:installation);
    LET $degraded = $counts.accounts_failing + $counts.zones_blocked + $counts.zones_not_delegated + $counts.zones_failing
        + $counts.zones_late + $counts.records_conflict + $counts.records_failed + $counts.records_written_late > 0;
    RETURN fn::result_ok(object::extend($counts, {
        settings_ok: $settings_ok,
        status: IF !$settings_ok { "unhealthy" } ELSE IF $degraded { "degraded" } ELSE { "healthy" }
    }));
} COMMENT "Sonde (InfraHealthCheck, lot 1b) : nombres, jamais de nom : comptes (en échec), zones (bloquées, non rattachées, en échec, passe en retard de plus de 3 intervalles), enregistrements en conflit, en échec ou écrits depuis plus d'une heure ; status : unhealthy (réglages absents), degraded (au moins un cas), healthy. Droit infra.read ou infra.worker, session système";
