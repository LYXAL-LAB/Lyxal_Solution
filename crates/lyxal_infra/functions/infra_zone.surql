-- ============================================================================
-- FONCTIONS : zones DNS (administration)
-- MODULE    : lyxal_infra
-- ============================================================================
-- Une zone est rattachée une par une par l'administrateur de la plateforme, parmi les zones
-- visibles du compte (discovered_zones), d'abord en mode observe. Les actions qui demandent
-- l'hébergeur (passe immédiate) sont des demandes notées en base, exécutées par les tâches de
-- lyxal_scheduler (infra.zone_reconcile, infra.tick).

-- ----------------------------------------------------------------------------
-- fn::infra__zone_view (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::infra__zone_view($zone: object) -> object {
    RETURN $zone.{ id, account, name, provider_ref, mode, tenants, state, nameservers, delegated, last_plan, approved_plan_hash, reconcile_requested_at, reconciled_at, next_reconcile_at, last_error, created_at, updated_at };
} COMMENT "Interne : vue d'une zone pour l'administration (sans jeton de réservation)";

-- ----------------------------------------------------------------------------
-- fn::infra__reconcile_enqueue (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::infra__reconcile_enqueue($zones: array) -> object {
    -- Seul un appelant qui peut lancer la tâche (session système de l'hôte, ou permissions du
    -- planificateur et infra.worker) la met en file ; sinon la tâche infra.tick reprend la zone
    -- à sa prochaine minute (demande ou déclaration plus récente que la dernière passe)
    LET $task = scheduler_task:⟨infra.zone_reconcile⟩;
    IF array::len($zones) = 0 OR !record::exists($task) OR !fn::scheduler_can({ action: "write", task: $task }) {
        RETURN { queued: 0, codes: [] };
    };
    LET $outcomes = array::map(array::distinct($zones), |$zone| {
        LET $enqueued = fn::scheduler_run_enqueue({ task: "infra.zone_reconcile", args: { zone: <string> $zone }, delay: 10s, unique_key: <string> $zone });
        RETURN IF $enqueued.ok { NONE } ELSE { $enqueued.error.code };
    });
    RETURN {
        queued: array::len(array::filter($outcomes, |$o| $o IS NONE)),
        codes: array::distinct(array::filter($outcomes, |$o| $o IS NOT NONE))
    };
} COMMENT "Interne : met en file la tâche infra.zone_reconcile de chaque zone ($zones), départ dans 10 s, unique par zone (fn::scheduler_run_enqueue) quand l'appelant peut la lancer ; sinon rien (infra.tick reprend la zone). Rend { queued, codes } (codes des refus du planificateur)";

-- ----------------------------------------------------------------------------
-- fn::infra__zone_adopt (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::infra__zone_adopt($zone: object) -> int {
    -- Enregistrements déjà déclarés sans zone que la nouvelle zone couvre, si elle accepte leur organisation
    LET $suffix = "." + $zone.name;
    LET $covered = (SELECT id, tenant FROM infra_record WHERE zone IS NONE AND state = "unmanaged"
        AND (fqdn = $zone.name OR string::ends_with(fqdn, $suffix)));
    LET $accepted = array::filter($covered, |$r| $r.tenant IS NONE OR $zone.tenants CONTAINS $r.tenant);
    IF array::len($accepted) = 0 { RETURN 0; };
    LET $updated = (UPDATE $accepted.id SET zone = $zone.id, state = "pending" RETURN id);
    RETURN array::len($updated);
} COMMENT "Interne : rattache à la zone ($zone) les enregistrements unmanaged qu'elle couvre et dont elle accepte l'organisation (état pending) ; rend leur nombre";

-- ----------------------------------------------------------------------------
-- fn::infra_zone_attach
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::infra_zone_attach($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            account: { pipeline: [{ rule: "record", options: { expected_table: "infra_account" } }], required: true },
            name: { pipeline: [{ rule: "dns_name", options: { allow_underscore: false, allow_wildcard: false } }], required: true },
            mode: { pipeline: [{ rule: "enum", options: { allowed: ["observe", "managed"], case_sensitive: true } }], default: "observe" },
            tenants: { pipeline: [{ rule: "array_length", options: { max_length: 1000 } }, { rule: "each", options: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] } }], default: [] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid { RETURN fn::infra__invalid($params, $report.by_field); };
    LET $p = $report.value;
    IF !fn::infra_can({ action: "manage" }) { RETURN fn::error_result("INFRA_PERMISSION_DENIED", $p.language, {}); };
    LET $account = (SELECT id, discovered_zones FROM ONLY $p.account);
    IF $account == NONE { RETURN fn::error_result("INFRA_ACCOUNT_NOT_FOUND", $p.language, { account: <string> $p.account }); };
    IF count(SELECT id FROM infra_zone WHERE name = $p.name) > 0 { RETURN fn::error_result("INFRA_ZONE_EXISTS", $p.language, {}); };
    IF $p.name NOT IN $account.discovered_zones.name { RETURN fn::error_result("INFRA_ZONE_NOT_VISIBLE", $p.language, { account: <string> $p.account }); };
    -- Zone emboîtée dans une zone rattachée, ou qui en contient une : refusée
    LET $overlap = (SELECT VALUE id FROM infra_zone WHERE string::ends_with($p.name, "." + name) OR string::ends_with(name, "." + $p.name));
    IF array::len($overlap) > 0 { RETURN fn::error_result("INFRA_ZONE_OVERLAP", $p.language, { zone: <string> $overlap[0] }); };
    LET $id = type::record("infra_zone", string::replace(<string> rand::uuid::v7(), "-", ""));
    LET $created = (CREATE $id CONTENT {
        account: $account.id,
        name: $p.name,
        provider_ref: $p.name,
        mode: $p.mode,
        tenants: array::distinct($p.tenants),
        state: "ok",
        reconcile_requested_at: time::now(),
        next_reconcile_at: time::now()
    });
    IF array::len($created) = 0 { RETURN fn::error_result("INFRA_WRITE_FORBIDDEN", $p.language, { table: "infra_zone" }); };
    LET $noted = fn::infra__change_write({ zone: $id, action: "attach", after: { mode: $p.mode, tenants: array::len($p.tenants) } });
    IF $noted IS NONE { THROW "INFRA_WRITE_FORBIDDEN"; };
    LET $adopted = fn::infra__zone_adopt($created[0]);
    LET $queued = fn::infra__reconcile_enqueue([$id]);
    RETURN fn::result_ok(object::extend(fn::infra__zone_view($created[0]), { adopted: $adopted, queued: $queued.queued }));
} COMMENT "Rattache une zone ({ account, name, mode : observe (défaut) ou managed, tenants : organisations dont les déclarations sont acceptées }) : zone visible du compte (dernier essai), ni déjà rattachée, ni emboîtée dans une autre ou la contenant ; clé opaque (UUID v7 en 32 chiffres hexadécimaux) ; les enregistrements déjà déclarés qu'elle couvre lui sont rattachés (adopted) ; une passe est demandée. Droit infra.manage";

-- ----------------------------------------------------------------------------
-- fn::infra_zone_update
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::infra_zone_update($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            zone: { pipeline: [{ rule: "record", options: { expected_table: "infra_zone" } }], required: true },
            mode: { pipeline: [{ rule: "enum", options: { allowed: ["observe", "managed"], case_sensitive: true } }] },
            tenants: { pipeline: [{ rule: "array_length", options: { max_length: 1000 } }, { rule: "each", options: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid { RETURN fn::infra__invalid($params, $report.by_field); };
    LET $p = $report.value;
    IF !fn::infra_can({ action: "manage" }) { RETURN fn::error_result("INFRA_PERMISSION_DENIED", $p.language, {}); };
    LET $current = (SELECT * FROM ONLY $p.zone);
    IF $current == NONE { RETURN fn::error_result("INFRA_ZONE_NOT_FOUND", $p.language, { zone: <string> $p.zone }); };
    LET $mode = $p.mode ?? $current.mode;
    LET $updated = (UPDATE ONLY $current.id SET
        mode = $mode,
        tenants = IF $p.tenants IS NONE { tenants } ELSE { array::distinct($p.tenants) },
        reconcile_requested_at = IF $mode != $current.mode { time::now() } ELSE { reconcile_requested_at });
    IF $updated == NONE { RETURN fn::error_result("INFRA_WRITE_FORBIDDEN", $p.language, { table: "infra_zone" }); };
    IF $mode != $current.mode {
        LET $noted = fn::infra__change_write({ zone: $current.id, action: "mode", before: { mode: $current.mode }, after: { mode: $mode } });
        IF $noted IS NONE { THROW "INFRA_WRITE_FORBIDDEN"; };
    };
    LET $adopted = IF $p.tenants IS NONE { 0 } ELSE { fn::infra__zone_adopt($updated) };
    LET $queued = IF $mode != $current.mode OR $adopted > 0 { fn::infra__reconcile_enqueue([$current.id]).queued } ELSE { 0 };
    RETURN fn::result_ok(object::extend(fn::infra__zone_view($updated), { adopted: $adopted, queued: $queued }));
} COMMENT "Modifie une zone ({ zone, mode : observe ou managed, tenants (remplacés en entier) }) ; un changement de mode est noté au journal et demande une passe ; de nouvelles organisations acceptées rattachent leurs enregistrements déjà déclarés (adopted). Le retrait d'une organisation ne vaut que pour ses déclarations suivantes. Droit infra.manage";

-- ----------------------------------------------------------------------------
-- fn::infra_zone_detach
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::infra_zone_detach($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            zone: { pipeline: [{ rule: "record", options: { expected_table: "infra_zone" } }], required: true },
            forget: { pipeline: [{ rule: "boolean" }], default: false },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 10);
    IF !$report.valid { RETURN fn::infra__invalid($params, $report.by_field); };
    LET $p = $report.value;
    IF !fn::infra_can({ action: "manage" }) { RETURN fn::error_result("INFRA_PERMISSION_DENIED", $p.language, {}); };
    IF !record::exists($p.zone) { RETURN fn::error_result("INFRA_ZONE_NOT_FOUND", $p.language, { zone: <string> $p.zone }); };
    LET $records = (SELECT id, provider_ids, state FROM infra_record WHERE zone = $p.zone);
    LET $written = array::filter($records, |$r| array::len($r.provider_ids) > 0);
    IF array::len($written) > 0 AND !$p.forget {
        RETURN fn::error_result("INFRA_ZONE_HAS_RECORDS", $p.language, { zone: <string> $p.zone, records: array::len($written) });
    };
    -- Enregistrements oubliés : ce que Lyxal a écrit reste chez le fournisseur, sans propriétaire.
    -- Les déclarations actives redeviennent unmanaged (reprises par un rattachement suivant) ; un
    -- enregistrement retiré (releasing, released) reste released : jamais remis en état voulu
    LET $withdrawn = array::filter($records, |$r| $r.state IN ["releasing", "released"]).id;
    LET $active = array::filter($records, |$r| $r.state NOT IN ["releasing", "released"]).id;
    LET $unlinked = array::concat(
        IF array::len($active) = 0 { [] } ELSE { (UPDATE $active SET zone = NONE, state = "unmanaged", provider_ids = [], applied_values = [], conflict = NONE, next_verify_at = NONE RETURN id) },
        IF array::len($withdrawn) = 0 { [] } ELSE { (UPDATE $withdrawn SET zone = NONE, state = "released", provider_ids = [], applied_values = [], conflict = NONE, next_verify_at = NONE RETURN id) }
    );
    IF array::len($unlinked) != array::len($records) { RETURN fn::error_result("INFRA_WRITE_FORBIDDEN", $p.language, { table: "infra_record" }); };
    LET $noted = fn::infra__change_write({ zone: $p.zone, action: "detach", after: { forget: $p.forget, records: array::len($records), kept_at_provider: array::len($written) } });
    IF $noted IS NONE { THROW "INFRA_WRITE_FORBIDDEN"; };
    LET $deleted = (DELETE $p.zone RETURN BEFORE);
    IF array::len($deleted) = 0 { THROW "INFRA_WRITE_FORBIDDEN"; };
    RETURN fn::result_ok({ detached: $p.zone, records: array::len($records), kept_at_provider: array::len($written) });
} COMMENT "Détache une zone ({ zone, forget }) : refusé tant que des enregistrements de Lyxal y sont écrits (INFRA_ZONE_HAS_RECORDS), sauf forget : ils restent alors chez le fournisseur et Lyxal les oublie (noté au journal) ; les enregistrements voulus actifs redeviennent unmanaged (repris par un rattachement suivant), les enregistrements retirés (releasing, released) restent released, sans zone ; la photo est supprimée. Droit infra.manage";

-- ----------------------------------------------------------------------------
-- fn::infra__zone_counts (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::infra__zone_counts($zone: record<infra_zone>) -> object {
    LET $states = (SELECT VALUE state FROM infra_record WHERE zone = $zone);
    RETURN object::from_entries(array::map(["pending", "written", "published", "conflict", "yielded", "failed", "releasing", "released"],
        |$s| [$s, array::len(array::filter($states, |$x| $x = $s))]));
} COMMENT "Interne : nombre d'enregistrements voulus de la zone par état";

-- ----------------------------------------------------------------------------
-- fn::infra_zone_get
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::infra_zone_get($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            zone: { pipeline: [{ rule: "record", options: { expected_table: "infra_zone" } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 10);
    IF !$report.valid { RETURN fn::infra__invalid($params, $report.by_field); };
    LET $p = $report.value;
    IF !fn::infra_can({ action: "read" }) { RETURN fn::error_result("INFRA_PERMISSION_DENIED", $p.language, {}); };
    LET $zone = (SELECT * FROM ONLY $p.zone);
    IF $zone == NONE { RETURN fn::error_result("INFRA_ZONE_NOT_FOUND", $p.language, { zone: <string> $p.zone }); };
    RETURN fn::result_ok(object::extend(fn::infra__zone_view($zone), {
        counts: fn::infra__zone_counts($zone.id),
        observed: count(SELECT id FROM infra_zone_record WHERE zone = $zone.id)
    }));
} COMMENT "Zone ({ zone }) : réglages, état, dernier plan, enregistrements voulus par état (counts) et lignes observées (observed). Droit infra.read";

-- ----------------------------------------------------------------------------
-- fn::infra_zone_list
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::infra_zone_list($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            account: { pipeline: [{ rule: "record", options: { expected_table: "infra_account" } }] },
            state: { pipeline: [{ rule: "enum", options: { allowed: ["ok", "blocked", "not_delegated", "failing", "pending_provider"], case_sensitive: true } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 10);
    IF !$report.valid { RETURN fn::infra__invalid($params, $report.by_field); };
    LET $p = $report.value;
    IF !fn::infra_can({ action: "read" }) { RETURN fn::error_result("INFRA_PERMISSION_DENIED", $p.language, {}); };
    LET $rows = (SELECT * FROM infra_zone WHERE ($p.account IS NONE OR account = $p.account) AND ($p.state IS NONE OR state = $p.state) ORDER BY name ASC);
    RETURN fn::result_ok({ items: array::map($rows, |$z| object::extend(fn::infra__zone_view($z), { counts: fn::infra__zone_counts($z.id) })) });
} COMMENT "Zones ({ account, state }), par nom : { items } avec leurs enregistrements voulus par état. Droit infra.read";

-- ----------------------------------------------------------------------------
-- fn::infra_zone_reconcile_request
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::infra_zone_reconcile_request($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            zone: { pipeline: [{ rule: "record", options: { expected_table: "infra_zone" } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 10);
    IF !$report.valid { RETURN fn::infra__invalid($params, $report.by_field); };
    LET $p = $report.value;
    IF !fn::infra_can({ action: "manage" }) { RETURN fn::error_result("INFRA_PERMISSION_DENIED", $p.language, {}); };
    IF !record::exists($p.zone) { RETURN fn::error_result("INFRA_ZONE_NOT_FOUND", $p.language, { zone: <string> $p.zone }); };
    LET $updated = (UPDATE ONLY $p.zone SET reconcile_requested_at = time::now());
    IF $updated == NONE { RETURN fn::error_result("INFRA_WRITE_FORBIDDEN", $p.language, { table: "infra_zone" }); };
    RETURN fn::result_ok({ zone: $p.zone, requested_at: $updated.reconcile_requested_at, queued: fn::infra__reconcile_enqueue([$p.zone]).queued });
} COMMENT "Demande une passe immédiate de la zone ({ zone }), exécutée par la tâche infra.zone_reconcile (mise en file quand l'appelant le peut, sinon reprise par infra.tick) : { zone, requested_at, queued }. Droit infra.manage";

-- ----------------------------------------------------------------------------
-- fn::infra_zone_plan_approve
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::infra_zone_plan_approve($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            zone: { pipeline: [{ rule: "record", options: { expected_table: "infra_zone" } }], required: true },
            plan_hash: { pipeline: [{ rule: "hexadecimal", options: { min_length: 64, max_length: 64, allow_prefix: false } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 10);
    IF !$report.valid { RETURN fn::infra__invalid($params, $report.by_field); };
    LET $p = $report.value;
    IF !fn::infra_can({ action: "manage" }) { RETURN fn::error_result("INFRA_PERMISSION_DENIED", $p.language, {}); };
    LET $zone = (SELECT id, state, last_plan FROM ONLY $p.zone);
    IF $zone == NONE { RETURN fn::error_result("INFRA_ZONE_NOT_FOUND", $p.language, { zone: <string> $p.zone }); };
    IF $zone.state != "blocked" OR $zone.last_plan.hash != string::lowercase($p.plan_hash) {
        RETURN fn::error_result("INFRA_ZONE_PLAN_STALE", $p.language, { zone: <string> $p.zone, state: $zone.state });
    };
    LET $updated = (UPDATE ONLY $zone.id SET approved_plan_hash = $zone.last_plan.hash, state = "ok", reconcile_requested_at = time::now());
    IF $updated == NONE { RETURN fn::error_result("INFRA_WRITE_FORBIDDEN", $p.language, { table: "infra_zone" }); };
    LET $noted = fn::infra__change_write({ zone: $zone.id, action: "approve", after: { plan_hash: $zone.last_plan.hash, deletions: $zone.last_plan.deletions } });
    IF $noted IS NONE { THROW "INFRA_WRITE_FORBIDDEN"; };
    RETURN fn::result_ok(object::extend(fn::infra__zone_view($updated), { queued: fn::infra__reconcile_enqueue([$zone.id]).queued }));
} COMMENT "Approuve une fois le plan bloqué d'une zone ({ zone, plan_hash : empreinte exacte du plan montré }) : la passe suivante l'applique s'il n'a pas changé ; zone non bloquée ou empreinte différente : INFRA_ZONE_PLAN_STALE. Noté au journal. Droit infra.manage";

-- ----------------------------------------------------------------------------
-- fn::infra_zone_records
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::infra_zone_records($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            zone: { pipeline: [{ rule: "record", options: { expected_table: "infra_zone" } }], required: true },
            owner: { pipeline: [{ rule: "enum", options: { allowed: ["lyxal", "human"], case_sensitive: true } }] },
            limit: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 1000 } }], default: 100 },
            start: { pipeline: [{ rule: "integer", options: { min_value: 0 } }], default: 0 },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 10);
    IF !$report.valid { RETURN fn::infra__invalid($params, $report.by_field); };
    LET $p = $report.value;
    IF !fn::infra_can({ action: "read" }) { RETURN fn::error_result("INFRA_PERMISSION_DENIED", $p.language, {}); };
    IF !record::exists($p.zone) { RETURN fn::error_result("INFRA_ZONE_NOT_FOUND", $p.language, { zone: <string> $p.zone }); };
    LET $rows = (SELECT id, provider_id, fqdn, type, value, ttl, comment, record, seen_at FROM infra_zone_record
        WHERE zone = $p.zone AND ($p.owner IS NONE OR ($p.owner = "lyxal" AND record IS NOT NONE) OR ($p.owner = "human" AND record IS NONE))
        ORDER BY fqdn ASC, type ASC, value ASC, id ASC);
    RETURN fn::result_ok({ items: array::slice($rows, $p.start, $p.start + $p.limit), total: array::len($rows) });
} COMMENT "Photo de la zone chez le fournisseur ({ zone, owner : lyxal ou human, limit (1 000 au plus), start }), par nom, type et valeur : { items, total }. Droit infra.read";
