-- ============================================================================
-- FONCTIONS : journal chaîné
-- MODULE    : lyxal_secrets
-- ============================================================================
-- Le journal est écrit par les DEFINE EVENT du module (fn::secrets_audit_write), dans la
-- transaction de l'opération journalisée : sans entrée au journal, pas d'opération.

-- ----------------------------------------------------------------------------
-- fn::secrets_audit_write (interne, appelée par les événements)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_audit_write($entry: object) -> object {
    LET $scope = IF $entry.tenant IS NONE { "installation" } ELSE { <string> record::id($entry.tenant) };
    LET $head = (SELECT seq, last_hash FROM ONLY type::record("secrets_audit_head", $scope));
    LET $seq = ($head.seq ?? 0) + 1;
    LET $caller = fn::secrets_caller();
    LET $event = {
        seq: $seq,
        action: $entry.action,
        outcome: $entry.outcome ?? "success",
        actor: IF $caller.identity IS NONE { NONE } ELSE { <string> $caller.identity },
        application: IF $caller.application IS NONE { NONE } ELSE { <string> $caller.application },
        session: IF $caller.session IS NONE { NONE } ELSE { <string> $caller.session },
        session_kind: IF $caller.system { "system" } ELSE { $caller.kind },
        ip: $session.ip,
        secret: IF $entry.secret IS NONE { NONE } ELSE { <string> $entry.secret },
        path: $entry.path,
        version: $entry.version,
        details: $entry.details ?? {},
        at: time::now()
    };
    LET $chained = fn::security_audit_entry($event, $head.last_hash);
    UPSERT type::record("secrets_audit_head", $scope) SET tenant = $entry.tenant, seq = $seq, last_hash = $chained.entry_hash;
    CREATE secrets_audit CONTENT {
        tenant: $entry.tenant,
        scope_key: $scope,
        seq: $seq,
        event: $event,
        previous_hash: $chained.previous_hash,
        entry_hash: $chained.entry_hash,
        created_at: $chained.created_at
    };
    RETURN $event;
} COMMENT "Interne (événements du module) : ajoute une entrée chaînée au journal de la portée ({ tenant, action, outcome, secret, path, version, details }) ; auteur, type de session et adresse lus dans la session ; jamais de valeur";

-- ----------------------------------------------------------------------------
-- fn::secrets_audit_list
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_audit_list($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            secret: { pipeline: [{ rule: "record", options: { expected_table: "secrets_secret" } }] },
            action: { pipeline: [{ rule: "optional_string", options: { max_length: 64 } }] },
            since: { pipeline: [{ rule: "datetime" }] },
            limit: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 500 } }], default: 100 },
            start: { pipeline: [{ rule: "integer", options: { min_value: 0 } }], default: 0 },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid {
        RETURN fn::error_result("SECRETS_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::secrets_can({ action: "audit", tenant: $p.tenant }) { RETURN fn::error_result("SECRETS_PERMISSION_DENIED", $p.language, {}); };
    LET $scope = IF $p.tenant IS NONE { "installation" } ELSE { <string> record::id($p.tenant) };
    LET $secret = IF $p.secret IS NONE { NONE } ELSE { <string> $p.secret };
    LET $all = (SELECT seq, event, entry_hash, created_at FROM secrets_audit
        WHERE scope_key = $scope
            AND ($secret IS NONE OR event.secret = $secret)
            AND ($p.action IS NONE OR event.action = $p.action)
            AND ($p.since IS NONE OR created_at >= $p.since)
        ORDER BY seq DESC);
    RETURN fn::result_ok({ items: array::slice($all, $p.start, $p.start + $p.limit), total: array::len($all) });
} COMMENT "Entrées du journal d'une portée ({ tenant, secret, action, since, limit (500 au plus), start }), les plus récentes d'abord : { items, total }. Droit : journal";

-- ----------------------------------------------------------------------------
-- fn::secrets_audit_verify
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_audit_verify($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            from_seq: { pipeline: [{ rule: "integer", options: { min_value: 1 } }], default: 1 },
            limit: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 10000 } }], default: 1000 },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("SECRETS_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::secrets_can({ action: "audit", tenant: $p.tenant }) { RETURN fn::error_result("SECRETS_PERMISSION_DENIED", $p.language, {}); };
    LET $scope = IF $p.tenant IS NONE { "installation" } ELSE { <string> record::id($p.tenant) };
    -- L'entrée qui précède la plage sert d'ancre : son empreinte doit être celle annoncée par la première
    LET $first = IF $p.from_seq > 1 { $p.from_seq - 1 } ELSE { 1 };
    LET $entries = (SELECT seq, event, previous_hash, entry_hash FROM secrets_audit
        WHERE scope_key = $scope AND seq >= $first ORDER BY seq ASC LIMIT $p.limit + 1);
    LET $head = (SELECT seq, last_hash FROM ONLY type::record("secrets_audit_head", $scope));
    LET $results = fn::security_audit_verify($entries).results;
    -- Rangs contigus, entrées intactes ; l'ancre n'est vérifiée que pour son empreinte
    LET $broken = array::filter(array::map($results, |$r| {
        seq: $entries[$r.index].seq,
        ok: $r.valid_hash
            AND ($r.valid_previous OR ($r.index = 0 AND $p.from_seq > 1))
            AND $entries[$r.index].seq = $first + $r.index
            AND $entries[$r.index].event.seq = $entries[$r.index].seq
    }), |$r| !$r.ok);
    LET $last = $entries[array::len($entries) - 1];
    -- Fin de chaîne : la dernière entrée doit être celle de la tête (aucune entrée retirée à la fin)
    LET $complete = array::len($entries) <= $p.limit;
    LET $head_ok = IF array::len($entries) = 0 { ($head IS NONE) } ELSE IF !$complete { true } ELSE {
        ($head IS NOT NONE AND $head.seq = $last.seq AND $head.last_hash = $last.entry_hash)
    };
    RETURN fn::result_ok({
        valid: array::len($broken) = 0 AND $head_ok,
        checked: array::len($entries),
        broken_at: $broken[0].seq,
        head_matches: $head_ok,
        complete: $complete
    });
} COMMENT "Vérifie la chaîne du journal d'une portée ({ tenant, from_seq, limit (10000 au plus) }) par fn::security_audit_verify : empreintes, liens, rangs contigus et, si la plage va jusqu'au bout, accord avec la tête de chaîne. { valid, checked, broken_at, head_matches, complete }. Droit : journal";
