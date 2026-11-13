-- ============================================================================
-- FONCTIONS : journal chaîné
-- MODULE    : lyxal_secrets
-- ============================================================================
-- Le journal est écrit par les DEFINE EVENT du module (fn::secrets_audit_write), dans la
-- transaction de l'opération journalisée : sans entrée au journal, pas d'opération.

-- ----------------------------------------------------------------------------
-- fn::secrets_audit_clean (interne)
-- ----------------------------------------------------------------------------
-- Une valeur NONE disparaît d'un objet enregistré : l'empreinte serait calculée sur un objet
-- différent de celui relu. Les NONE deviennent NULL, conservé tel quel.

DEFINE FUNCTION OVERWRITE fn::secrets_audit_clean($value: any) -> any {
    IF $value IS NONE { RETURN NULL; };
    IF type::is_object($value) { RETURN object::from_entries(array::map(object::entries($value), |$e| [$e[0], fn::secrets_audit_clean($e[1])])); };
    IF type::is_array($value) { RETURN array::map($value, |$v| fn::secrets_audit_clean($v)); };
    RETURN $value;
} COMMENT "Interne : remplace récursivement NONE par NULL (entrée du journal identique avant et après enregistrement)";

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
        -- Au nom d'un appelant (refus constaté par le service) : seule la session système l'indique
        actor: IF $caller.system AND $entry.on_behalf IS NOT NONE { $entry.on_behalf.actor } ELSE IF $caller.identity IS NONE { NONE } ELSE { <string> $caller.identity },
        application: IF $caller.system AND $entry.on_behalf IS NOT NONE { $entry.on_behalf.application } ELSE IF $caller.application IS NONE { NONE } ELSE { <string> $caller.application },
        session: IF $caller.system AND $entry.on_behalf IS NOT NONE { $entry.on_behalf.session } ELSE IF $caller.session IS NONE { NONE } ELSE { <string> $caller.session },
        session_kind: IF $caller.system AND $entry.on_behalf IS NOT NONE { $entry.on_behalf.session_kind } ELSE IF $caller.system { "system" } ELSE { $caller.kind },
        ip: $session.ip,
        secret: IF $entry.secret IS NONE { NONE } ELSE { <string> $entry.secret },
        path: $entry.path,
        version: $entry.version,
        details: $entry.details ?? {},
        at: time::now()
    };
    LET $event = fn::secrets_audit_clean($event);
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
} COMMENT "Interne (événements du module, refus constatés par le service) : ajoute une entrée chaînée au journal de la portée ({ tenant, action, outcome, secret, path, version, details, on_behalf }) ; auteur, type de session et adresse lus dans la session, ou, pour la session système seulement, dans on_behalf ({ actor, application, session, session_kind }) ; jamais de valeur";

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
    -- Rangs contigus, entrées intactes ; l'ancre ne sert qu'au lien de la première entrée de la plage (elle est vérifiée avec sa propre plage)
    LET $broken = array::filter(array::map($results, |$r| {
        seq: $entries[$r.index].seq,
        ok: (($r.index = 0 AND $p.from_seq > 1) OR ($r.valid_hash AND $r.valid_previous))
            AND $entries[$r.index].seq = $first + $r.index
            AND $entries[$r.index].event.seq = $entries[$r.index].seq
    }), |$r| !$r.ok);
    LET $last = $entries[array::len($entries) - 1];
    -- Fin de chaîne : la dernière entrée doit être celle de la tête (aucune entrée retirée à la fin)
    LET $complete = array::len($entries) <= $p.limit;
    LET $tail_ok = $head IS NOT NONE AND $head.seq = $last.seq AND $head.last_hash = $last.entry_hash;
    LET $head_ok = (array::len($entries) = 0 AND $head IS NONE) OR (array::len($entries) > 0 AND (!$complete OR $tail_ok));
    RETURN fn::result_ok({
        valid: array::len($broken) = 0 AND $head_ok,
        checked: array::len($entries),
        broken_at: $broken[0].seq,
        head_matches: $head_ok,
        complete: $complete
    });
} COMMENT "Vérifie la chaîne du journal d'une portée ({ tenant, from_seq, limit (10000 au plus) }) par fn::security_audit_verify : empreintes, liens, rangs contigus et, si la plage va jusqu'au bout, accord avec la tête de chaîne. { valid, checked, broken_at, head_matches, complete }. Droit : journal";

-- ----------------------------------------------------------------------------
-- fn::secrets_audit_denied
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_audit_denied($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            secret: { pipeline: [{ rule: "record", options: { expected_table: "secrets_secret" } }], required: true },
            code: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 128 } }], required: true },
            actor: { pipeline: [{ rule: "record", options: { expected_table: "auth_identity" } }] },
            application: { pipeline: [{ rule: "record", options: { expected_table: "auth_application" } }] },
            session: { pipeline: [{ rule: "record", options: { expected_table: "auth_session" } }] },
            session_kind: { pipeline: [{ rule: "enum", options: { allowed: ["interactive", "service", "api_key", "system"], case_sensitive: true } }], required: true },
            consumer: { pipeline: [{ rule: "optional_string", options: { min_length: 1, max_length: 128 } }] },
            version: { pipeline: [{ rule: "integer", options: { min_value: 1 } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid {
        RETURN fn::error_result("SECRETS_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::auth_session_valid({}).system { RETURN fn::error_result("SECRETS_PERMISSION_DENIED", $p.language, {}); };
    LET $secret = (SELECT id, tenant, path FROM ONLY $p.secret);
    IF $secret == NONE { RETURN fn::error_result("SECRETS_SECRET_NOT_FOUND", $p.language, { secret: <string> $p.secret }); };
    LET $entry = fn::secrets_audit_write({
        tenant: $secret.tenant,
        action: "secret.read",
        outcome: "denied",
        secret: $secret.id,
        path: $secret.path,
        version: $p.version,
        details: { code: $p.code, consumer: $p.consumer },
        on_behalf: {
            actor: IF $p.actor IS NONE { NONE } ELSE { <string> $p.actor },
            application: IF $p.application IS NONE { NONE } ELSE { <string> $p.application },
            session: IF $p.session IS NONE { NONE } ELSE { <string> $p.session },
            session_kind: $p.session_kind
        }
    });
    RETURN fn::result_ok({ seq: $entry.seq });
} COMMENT "Journalise une lecture refusée au nom de l'appelant ({ secret, code, actor, application, session, session_kind, consumer, version }) : entrée secret.read au résultat denied, avec le code du refus ; jamais de valeur. Session système seulement (service Rust)";
