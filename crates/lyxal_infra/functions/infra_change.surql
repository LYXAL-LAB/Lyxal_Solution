-- ============================================================================
-- FONCTIONS : journal chaîné des changements
-- MODULE    : lyxal_infra
-- ============================================================================
-- Une entrée est écrite par fn::infra__change_write dans la transaction de l'opération notée :
-- sans entrée au journal, pas d'opération. Chaîne unique pour l'installation
-- (infra_change_head:installation), vérifiée par fn::infra_change_verify.

-- ----------------------------------------------------------------------------
-- fn::infra__change_content (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::infra__change_content($row: object) -> object {
    RETURN fn::infra__clean({
        rank: $row.rank,
        zone: $row.zone,
        record: $row.record,
        action: $row.action,
        before: $row.before,
        after: $row.after,
        actor: $row.actor,
        created_at: $row.created_at
    });
} COMMENT "Interne : contenu chaîné d'une entrée ({ rank, zone, record, action, before, after, actor, created_at }, NONE remplacé par NULL, identifiants en texte) ; l'issue (state, provider_status, code) n'en fait pas partie";

-- ----------------------------------------------------------------------------
-- fn::infra__change_write (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::infra__change_write($entry: object) -> option<object> {
    LET $head = (SELECT rank, last_hash FROM ONLY infra_change_head:installation);
    LET $rank = ($head.rank ?? 0) + 1;
    LET $content = fn::infra__change_content({
        rank: $rank, zone: $entry.zone, record: $entry.record, action: $entry.action,
        before: $entry.before, after: $entry.after, actor: fn::infra__actor(), created_at: time::now()
    });
    LET $chained = fn::security_audit_entry($content, $head.last_hash);
    LET $moved = (UPSERT ONLY infra_change_head:installation SET rank = $rank, last_hash = $chained.entry_hash);
    IF $moved == NONE { RETURN NONE; };
    RETURN (CREATE ONLY type::record("infra_change", string::replace(<string> rand::uuid::v7(), "-", "")) CONTENT {
        rank: $rank,
        zone: $entry.zone,
        record: $entry.record,
        action: $entry.action,
        state: $entry.state ?? "noted",
        before: $content.before,
        after: $content.after,
        actor: $content.actor,
        previous_hash: $head.last_hash,
        entry_hash: $chained.entry_hash,
        created_at: $content.created_at
    });
} COMMENT "Interne : ajoute au journal une entrée chaînée ({ zone, record, action, state : noted par défaut ou sent, before, after }), auteur lu dans la session ; rend l'entrée, NONE si l'écriture est refusée par les permissions";

-- ----------------------------------------------------------------------------
-- fn::infra__change_view (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::infra__change_view($row: object) -> object {
    RETURN $row.{ id, rank, zone, record, action, state, before, after, actor, provider_status, code, entry_hash, created_at };
} COMMENT "Interne : vue publique d'une entrée du journal";

-- ----------------------------------------------------------------------------
-- fn::infra_change_list
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::infra_change_list($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            zone: { pipeline: [{ rule: "record", options: { expected_table: "infra_zone" } }] },
            record: { pipeline: [{ rule: "record", options: { expected_table: "infra_record" } }] },
            action: { pipeline: [{ rule: "enum", options: { allowed: ["add", "set", "delete", "conflict", "resolve", "approve", "drift_deleted", "attach", "detach", "mode"], case_sensitive: true } }] },
            limit: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 500 } }], default: 100 },
            start: { pipeline: [{ rule: "integer", options: { min_value: 0 } }], default: 0 },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid { RETURN fn::infra__invalid($params, $report.by_field); };
    LET $p = $report.value;
    IF !fn::infra_can({ action: "read" }) { RETURN fn::error_result("INFRA_PERMISSION_DENIED", $p.language, {}); };
    LET $rows = (SELECT * FROM infra_change
        WHERE ($p.zone IS NONE OR zone = $p.zone) AND ($p.record IS NONE OR record = $p.record) AND ($p.action IS NONE OR action = $p.action)
        ORDER BY rank DESC);
    RETURN fn::result_ok({
        items: array::map(array::slice($rows, $p.start, $p.start + $p.limit), |$r| fn::infra__change_view($r)),
        total: array::len($rows)
    });
} COMMENT "Entrées du journal ({ zone, record, action, limit (500 au plus), start }), les plus récentes d'abord (rang décroissant) : { items, total }. Droit infra.read";

-- ----------------------------------------------------------------------------
-- fn::infra_change_verify
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::infra_change_verify($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            from_rank: { pipeline: [{ rule: "integer", options: { min_value: 1 } }] },
            limit: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 10000 } }], default: 1000 },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid { RETURN fn::infra__invalid($params, $report.by_field); };
    LET $p = $report.value;
    IF !fn::infra_can({ action: "read" }) { RETURN fn::error_result("INFRA_PERMISSION_DENIED", $p.language, {}); };
    -- Début : rang demandé, sinon la plus ancienne entrée conservée (la purge retire le début de la
    -- chaîne : la première entrée lue sert d'ancre, son lien vers la précédente n'est pas contrôlé)
    LET $oldest = (SELECT VALUE rank FROM infra_change ORDER BY rank ASC LIMIT 1)[0];
    LET $first = $p.from_rank ?? $oldest ?? 1;
    LET $rows = array::slice((SELECT * FROM infra_change WHERE rank >= $first ORDER BY rank ASC LIMIT $p.limit), 0, $p.limit);
    LET $entries = array::map($rows, |$r| { event: fn::infra__change_content($r), previous_hash: $r.previous_hash, entry_hash: $r.entry_hash });
    LET $results = fn::security_audit_verify($entries).results;
    LET $broken = array::filter(array::map($results, |$r| {
        rank: $rows[$r.index].rank,
        ok: ($r.index = 0 OR ($r.valid_hash AND $r.valid_previous)) AND $rows[$r.index].rank = $first + $r.index
    }), |$r| !$r.ok);
    -- La première entrée : son empreinte est recalculée depuis le lien qu'elle annonce
    LET $anchor_ok = array::len($rows) = 0 OR fn::security_audit_entry($entries[0].event, $rows[0].previous_hash).entry_hash = $rows[0].entry_hash;
    LET $head = (SELECT rank, last_hash FROM ONLY infra_change_head:installation);
    LET $last = array::last($rows);
    LET $complete = array::len($rows) < $p.limit;
    LET $head_ok = (array::len($rows) = 0 AND ($head IS NONE OR $p.from_rank IS NOT NONE))
        OR (array::len($rows) > 0 AND (!$complete OR ($head.rank = $last.rank AND $head.last_hash = $last.entry_hash)));
    RETURN fn::result_ok({
        valid: $anchor_ok AND array::len($broken) = 0 AND $head_ok,
        checked: array::len($rows),
        from_rank: $first,
        broken_at: IF !$anchor_ok { $first } ELSE { array::first($broken).rank },
        head_matches: $head_ok,
        complete: $complete
    });
} COMMENT "Vérifie la chaîne du journal ({ from_rank (défaut : plus ancienne entrée conservée), limit (10 000 au plus) }) par fn::security_audit_verify : empreintes recalculées, liens, rangs contigus et, si la plage va jusqu'au bout, accord avec la tête de chaîne. { valid, checked, from_rank, broken_at, head_matches, complete }. Droit infra.read";
