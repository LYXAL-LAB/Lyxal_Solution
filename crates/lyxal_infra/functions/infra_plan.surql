-- ============================================================================
-- FONCTIONS : plan de réconciliation d'une zone (cœur des règles, plan §3.1)
-- MODULE    : lyxal_infra
-- ============================================================================
-- Compare l'état voulu (infra_record) à la photo de la zone (infra_zone_record) et rend les
-- changements (add, set par identifiant, delete par identifiant) et les conflits :
--   * Lyxal ne modifie ni ne supprime que ses propres écritures (ligne rattachée à
--     l'enregistrement et valeur encore celle qu'il a écrite) ;
--   * valeur étrangère qui gêne (jeu exclusif, préfixe unique d'un TXT partagé, y compris tenu par
--     un autre enregistrement de Lyxal, CNAME) ou
--     écriture de Lyxal modifiée par un humain : conflit, rien n'est écrit, jusqu'à une décision
--     humaine (take_over, une fois ; yield) ;
--   * écriture de Lyxal supprimée par un humain : recréée et notée (drift_deleted) ;
--   * valeur humaine identique à une valeur voulue : satisfaite, jamais prise ni dupliquée ;
--   * prudence : plus de max_deletions suppressions, ou plus de max_deletion_percent % des
--     enregistrements de Lyxal d'une zone qui en a plus de max_deletions : plan bloqué jusqu'à
--     son approbation par empreinte.

-- ----------------------------------------------------------------------------
-- fn::infra__record_plan (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::infra__record_plan($r: object, $observed: array) -> object {
    LET $at_name = array::filter($observed, |$o| $o.fqdn = $r.fqdn);
    LET $same = array::filter($at_name, |$o| $o.type = $r.type);
    LET $mine = array::filter($same, |$o| $o.record = $r.id);
    LET $human = array::filter($same, |$o| $o.record IS NONE);
    LET $applied = $r.applied_values ?? [];
    LET $delete = |$o: object| { action: "delete", record: $r.id, provider_id: $o.provider_id, fqdn: $o.fqdn, type: $o.type, value: $o.value, ttl: $o.ttl };
    -- Retrait : seules les écritures de Lyxal dont la valeur est encore celle écrite
    IF $r.state = "releasing" {
        RETURN { record: $r.id, conflict: NONE, changes: array::map(array::filter($mine, |$o| $o.value IN $applied), $delete), drift: [], adopt: [], release: true };
    };
    LET $take = $r.resolution.action = "take_over" AND $r.resolution.applied_at IS NONE;
    LET $cname_rows = IF $r.type = "CNAME" {
        array::filter($at_name, |$o| $o.record IS NONE AND $o.type != "CNAME")
    } ELSE {
        array::filter($at_name, |$o| $o.record IS NONE AND $o.type = "CNAME")
    };
    LET $modified = array::filter($mine, |$o| $o.value NOT IN $applied AND $o.value NOT IN $r.values);
    LET $foreign = IF $r.mode = "exclusive" { array::filter($human, |$o| $o.value NOT IN $r.values) } ELSE { [] };
    -- Préfixe unique : valeur humaine différente, ou toute valeur d'un autre enregistrement de Lyxal
    -- (en retrait, ou déclarations concurrentes) : jamais un second SPF
    LET $singleton = IF $r.mode = "shared" AND $r.singleton_prefix IS NOT NONE {
        array::concat(
            array::filter($human, |$o| string::starts_with($o.value, $r.singleton_prefix) AND $o.value NOT IN $r.values),
            array::filter($same, |$o| $o.record IS NOT NONE AND $o.record != $r.id AND string::starts_with($o.value, $r.singleton_prefix))
        )
    } ELSE { [] };
    LET $reason = IF array::len($cname_rows) > 0 { "cname" }
        ELSE IF array::len($modified) > 0 { "drift_modified" }
        ELSE IF array::len($foreign) > 0 { "foreign_value" }
        ELSE IF array::len($singleton) > 0 { "foreign_singleton" }
        ELSE { NONE };
    IF $reason IS NOT NONE AND !$take {
        LET $offending = { cname: $cname_rows, drift_modified: $modified, foreign_value: $foreign, foreign_singleton: $singleton }[$reason];
        -- Valeurs en cause : 5 au plus, 512 caractères chacune (4 Kio au plus en tout)
        LET $shown = array::map(array::slice(array::sort(array::distinct($offending.value)), 0, 5), |$v| string::slice($v, 0, 512));
        RETURN { record: $r.id, conflict: { reason: $reason, observed: $shown }, changes: [], drift: [], adopt: [], release: false };
    };
    -- Écritures de Lyxal gardées (valeur voulue), une par valeur ; les autres sont retirées
    LET $kept_all = array::filter($mine, |$o| $o.value IN $r.values);
    LET $kept = array::fold($kept_all, [], |$acc, $o| IF $o.value IN $acc.value { $acc } ELSE { array::append($acc, $o) });
    LET $duplicates = array::filter($kept_all, |$o| $o.provider_id NOT IN $kept.provider_id);
    LET $removed = array::concat(
        IF $take { array::concat(array::concat($cname_rows, $foreign), array::concat($singleton, $modified)) } ELSE { [] },
        array::concat(array::filter($mine, |$o| $o.value IN $applied AND $o.value NOT IN $r.values), $duplicates)
    );
    -- Valeurs déjà servies : par Lyxal, ou par un humain à l'identique (jamais dupliquées ni prises)
    LET $present = array::union($kept.value, array::filter($human, |$o| $o.value IN $r.values AND $o.provider_id NOT IN $removed.provider_id).value);
    LET $adds = array::map(array::filter($r.values, |$v| $v NOT IN $present), |$v| { action: "add", record: $r.id, fqdn: $r.fqdn, type: $r.type, value: $v, ttl: $r.ttl });
    LET $sets = array::map(array::filter($kept, |$o| $o.ttl != $r.ttl), |$o| { action: "set", record: $r.id, provider_id: $o.provider_id, fqdn: $o.fqdn, type: $o.type, value: $o.value, ttl: $r.ttl });
    -- Écritures de Lyxal disparues de chez le fournisseur (supprimées par un humain) : recréées par les ajouts
    LET $drift = array::filter($r.provider_ids, |$w| $w.id NOT IN $mine.provider_id);
    -- Écritures retrouvées par leur marque lyxal: (reprise après un arrêt entre l'écriture et son résultat)
    LET $adopt = array::map(array::filter($kept, |$o| $o.provider_id NOT IN $r.provider_ids.id), |$o| { id: $o.provider_id, value: $o.value });
    RETURN {
        record: $r.id,
        conflict: NONE,
        changes: array::concat(array::concat(array::map($removed, $delete), $sets), $adds),
        drift: $drift,
        adopt: $adopt,
        release: false
    };
} COMMENT "Interne : plan d'un enregistrement voulu ($r) face à la photo de sa zone ($observed) : { record, conflict ({ reason : cname, drift_modified, foreign_value, foreign_singleton ; observed : 5 valeurs au plus }), changes ({ action : add, set, delete ; record, provider_id, fqdn, type, value, ttl }), drift (écritures de Lyxal disparues, recréées), adopt (écritures retrouvées par leur marque), release }. Règles : voir l'en-tête du fichier";

-- ----------------------------------------------------------------------------
-- fn::infra__change_sorted (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::infra__change_sorted($items: array, $key: any) -> array {
    LET $keyed = array::map($items, |$c| object::extend($c, { sort_key: $key($c) }));
    RETURN array::map(fn::utils_collection_sort_by($keyed, "sort_key", "asc"), |$c| object::remove($c, "sort_key"));
} COMMENT "Interne : éléments triés par la clé calculée par la fermeture $key (ordre stable du plan, donc empreinte stable)";

-- ----------------------------------------------------------------------------
-- fn::infra__zone_compute (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::infra__zone_compute($zone: object) -> object {
    LET $settings = fn::infra__settings();
    LET $wanted = (SELECT * FROM infra_record WHERE zone = $zone.id AND state IN ["pending", "written", "published", "conflict", "failed", "releasing"]);
    -- Lignes observées des seuls noms voulus (index zone, fqdn, type) : le coût ne dépend pas des lignes humaines
    LET $observed = (SELECT provider_id, fqdn, type, value, ttl, record FROM infra_zone_record WHERE zone = $zone.id AND fqdn IN array::distinct($wanted.fqdn));
    LET $plans = array::map($wanted, |$r| fn::infra__record_plan($r, $observed));
    LET $all = array::flatten($plans.changes);
    -- Une ligne n'est supprimée qu'une fois (deux reprises d'une même valeur étrangère)
    LET $deletes = array::filter($all, |$c| $c.action = "delete");
    LET $unique_deletes = array::fold($deletes, [], |$acc, $c| IF $c.provider_id IN $acc.provider_id { $acc } ELSE { array::append($acc, $c) });
    LET $changes = fn::infra__change_sorted(array::concat($unique_deletes, array::filter($all, |$c| $c.action != "delete")),
        |$c: object| string::join("\n", $c.fqdn, $c.type, $c.action, $c.value, $c.provider_id ?? "", <string> $c.record));
    LET $conflicts = fn::infra__change_sorted(array::map(array::filter($plans, |$p| $p.conflict IS NOT NONE), |$p| object::extend($p.conflict, { record: $p.record })),
        |$c: object| <string> $c.record);
    LET $deletions = array::len($unique_deletes);
    LET $owned = count(SELECT id FROM infra_zone_record WHERE zone = $zone.id AND record IS NOT NONE);
    LET $over = $deletions > $settings.max_deletions
        OR ($owned > $settings.max_deletions AND $deletions * 100 > $owned * $settings.max_deletion_percent);
    RETURN {
        plans: $plans,
        changes: $changes,
        conflicts: $conflicts,
        deletions: $deletions,
        owned: $owned,
        over: $over,
        hash: fn::security_hash_object({ zone: <string> $zone.id, changes: $changes, conflicts: $conflicts }, "sha256").hash
    };
} COMMENT "Interne : plan complet d'une zone ($zone) : { plans (par enregistrement), changes (triés, une suppression par ligne), conflicts, deletions, owned (lignes de Lyxal observées), over (seuils de prudence dépassés), hash (SHA-256 des changements et conflits, fn::security_hash_object) }";

-- ----------------------------------------------------------------------------
-- fn::infra__plan_states (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::infra__plan_states($zone: object, $plans: array) -> object {
    LET $rows = (SELECT * FROM infra_record WHERE id IN $plans.record);
    LET $outcomes = array::map($plans, |$p| {
        LET $r = array::first(array::filter($rows, |$row| $row.id = $p.record));
        -- Conflit : noté une fois (à l'entrée ou au changement de cause), rien d'autre n'est écrit
        IF $p.conflict IS NOT NONE {
            IF $r.state = "conflict" AND $r.conflict.reason = $p.conflict.reason { RETURN { kind: "conflict", written: true }; };
            LET $updated = (UPDATE ONLY $r.id SET state = "conflict", conflict = object::extend($p.conflict, { at: time::now() }), next_verify_at = NONE);
            LET $noted = fn::infra__change_write({ zone: $zone.id, record: $r.id, action: "conflict", after: $p.conflict });
            RETURN { kind: "conflict", written: $updated != NONE AND $noted IS NOT NONE };
        };
        IF $p.release {
            IF array::len($p.changes) > 0 { RETURN { kind: "releasing", written: true }; };
            LET $updated = (UPDATE ONLY $r.id SET state = "released", provider_ids = [], applied_values = []);
            RETURN { kind: "released", written: $updated != NONE };
        };
        -- Écritures disparues (notées) et retrouvées : identifiants tenus à jour
        LET $noted = IF array::len($p.drift) = 0 { true } ELSE {
            fn::infra__change_write({ zone: $zone.id, record: $r.id, action: "drift_deleted", before: { values: $p.drift.value } }) IS NOT NONE
        };
        LET $ids = array::concat(array::filter($r.provider_ids, |$w| $w.id NOT IN $p.drift.id), $p.adopt);
        LET $satisfied = array::len($p.changes) = 0;
        LET $state = IF $satisfied AND $r.state IN ["pending", "failed", "conflict"] { "written" }
            ELSE IF !$satisfied AND $r.state IN ["conflict", "written", "published"] { "pending" }
            ELSE { $r.state };
        IF $ids = $r.provider_ids AND $state = $r.state { RETURN { kind: IF $satisfied { "satisfied" } ELSE { "pending" }, written: $noted }; };
        LET $updated = (UPDATE ONLY $r.id SET
            provider_ids = $ids,
            applied_values = array::distinct($ids.value),
            state = $state,
            conflict = NONE,
            error = IF $state = "written" { NONE } ELSE { error },
            written_at = IF $state = "written" AND $r.state != "written" { time::now() } ELSE { written_at },
            verify_attempts = IF $state = "written" AND $r.state != "written" { 0 } ELSE { verify_attempts },
            next_verify_at = IF $state = "written" AND $r.state != "written" { time::now() } ELSE IF $state = "pending" { NONE } ELSE { next_verify_at },
            resolution = IF $satisfied AND resolution.action = "take_over" AND resolution.applied_at IS NONE { object::extend(resolution, { applied_at: time::now() }) } ELSE { resolution });
        RETURN { kind: IF $satisfied { "satisfied" } ELSE { "pending" }, written: $updated != NONE AND $noted };
    });
    IF array::any($outcomes, |$o| !$o.written) { THROW "INFRA_WRITE_FORBIDDEN"; };
    RETURN {
        conflicts: array::len(array::filter($outcomes, |$o| $o.kind = "conflict")),
        satisfied: array::len(array::filter($outcomes, |$o| $o.kind = "satisfied")),
        pending: array::len(array::filter($outcomes, |$o| $o.kind IN ["pending", "releasing"])),
        released: array::len(array::filter($outcomes, |$o| $o.kind = "released"))
    };
} COMMENT "Interne : états des enregistrements d'une zone gérée après son plan ($zone, $plans) : conflit noté au journal à son entrée ; retrait sans suppression à faire : released ; écritures disparues notées (drift_deleted) et retirées des identifiants, écritures retrouvées ajoutées ; enregistrement satisfait (aucun changement) : written (vérification de la publication), take_over consommé ; changement à faire : pending. Rend { conflicts, satisfied, pending, released }";

-- ----------------------------------------------------------------------------
-- fn::infra_zone_plan
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::infra_zone_plan($params: object) {
    LET $report = fn::validation_fields_execute($params, {
        zone: { checks: [|$v: any| fn::validation_record($v, "infra_zone")], required: true },
        claim: { checks: [|$v: any| fn::validation_uuid_v7($v, true)], required: true },
        language: { checks: [|$v: any| fn::validation_language_code($v, false, NONE)], default: "fr" }
    }, "reject");
    IF !$report.valid { RETURN fn::infra__invalid($params, $report.by_field); };
    LET $p = $report.value;
    IF !fn::infra_can({ action: "worker" }) { RETURN fn::error_result("INFRA_PERMISSION_DENIED", $p.language, {}); };
    LET $held = fn::infra__claim_check($p.zone, $p.claim);
    IF $held.code IS NOT NONE { RETURN fn::error_result($held.code, $p.language, { zone: <string> $p.zone }); };
    LET $zone = $held.zone;
    LET $plan = fn::infra__zone_compute($zone);
    LET $last = { hash: $plan.hash, at: time::now(), changes: $plan.changes, conflicts: $plan.conflicts, deletions: $plan.deletions, owned: $plan.owned };
    LET $approved = $zone.approved_plan_hash IS NOT NONE AND $zone.approved_plan_hash = $plan.hash;
    LET $reason = IF $zone.mode = "observe" { "observe" } ELSE IF $plan.over AND !$approved { "blocked" } ELSE IF array::len($plan.changes) = 0 { "noop" } ELSE { "apply" };
    LET $records = IF $reason IN ["noop", "apply"] { fn::infra__plan_states($zone, $plan.plans) } ELSE { NONE };
    LET $updated = (UPDATE ONLY $zone.id SET
        last_plan = $last,
        state = IF $reason = "blocked" { "blocked" } ELSE IF state = "blocked" { "ok" } ELSE { state },
        approved_plan_hash = IF $approved AND $reason = "apply" { approved_plan_hash } ELSE { NONE });
    IF $updated == NONE { THROW "INFRA_WRITE_FORBIDDEN"; };
    RETURN fn::result_ok({
        zone: $zone.id,
        apply: $reason = "apply",
        reason: $reason,
        hash: $plan.hash,
        changes: $plan.changes,
        conflicts: $plan.conflicts,
        deletions: $plan.deletions,
        owned: $plan.owned,
        records: $records
    });
} COMMENT "Worker : plan de la zone réservée ({ zone, claim, language }) rangé dans last_plan : { zone, apply, reason : observe (rien n'est écrit), blocked (seuils dépassés : zone bloquée jusqu'à fn::infra_zone_plan_approve), noop, apply ; hash, changes, conflicts, deletions, owned, records (états mis à jour, zone gérée seulement) }. Un plan approuvé n'est appliqué que si son empreinte est inchangée. Droit infra.worker, session système ; jeton de réservation exigé (INFRA_ZONE_CLAIM_LOST)";
