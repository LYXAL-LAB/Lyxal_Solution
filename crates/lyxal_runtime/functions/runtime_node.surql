-- ============================================================================
-- Présence des nœuds (table runtime_node, identifiant runtime_node:<node_id>).
-- Un nœud est un processus en marche ; son hôte est le rôle de son binaire, le même pour toutes
-- ses copies. Chaque nœud écrit sa ligne au démarrage puis à chaque battement, la retire à
-- l'arrêt propre ; une ligne sans battement depuis longtemps est purgée avec les lignes
-- runtime_worker et runtime_health du nœud.
-- « Vivant » se juge à l'heure de la base (time::now()), jamais à l'horloge d'un nœud.
-- Entrées validées par le moteur de lyxal_core (fn::validation_object_execute).
-- Tables en PERMISSIONS NONE : seule la session système lit et écrit.
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::runtime_node_upsert($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            node_id: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 128 } }], required: true },
            host: { pipeline: [{ rule: "regex", options: { pattern: "^[a-z][a-z0-9_]{0,63}$" } }], required: true },
            modules: { pipeline: [{ rule: "array_of_strings", options: { allow_empty: false, min_length: 1, max_length: 128 } }, { rule: "array_length", options: { min_length: 0, max_length: 1000 } }], required: true },
            foundation_checksum: { pipeline: [{ rule: "regex", options: { pattern: "^[0-9a-f]{64}$" } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid {
        RETURN fn::error_result("RUNTIME_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;

    -- Premier battement : démarrage et battement portent la même date
    LET $id = type::record("runtime_node", $p.node_id);
    LET $now = time::now();
    LET $saved = UPSERT $id MERGE {
        node_id: $p.node_id,
        host: $p.host,
        modules: $p.modules,
        foundation_checksum: $p.foundation_checksum,
        started_at: (SELECT VALUE started_at FROM ONLY $id) ?? $now,
        seen_at: $now
    } RETURN AFTER;
    -- Écriture filtrée (session sans droit sur la table) : jamais de succès annoncé
    IF array::len($saved) = 0 {
        RETURN fn::error_result("RUNTIME_WRITE_FORBIDDEN", $p.language, { table: "runtime_node" });
    };
    RETURN fn::result_ok($saved[0].{ node_id, host, modules, foundation_checksum, started_at, seen_at });
} COMMENT "Battement d'un nœud ({ node_id, host, modules : modules enregistrés dans son runtime, foundation_checksum : empreinte du socle de son binaire, optionnelle }) : crée ou rafraîchit sa ligne de présence (seen_at à l'heure de la base, started_at gardé) et la renvoie. Écriture refusée par les permissions : RUNTIME_WRITE_FORBIDDEN."
PERMISSIONS FULL;

DEFINE FUNCTION OVERWRITE fn::runtime_node_remove($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            node_id: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 128 } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid {
        RETURN fn::error_result("RUNTIME_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;

    -- Tables en PERMISSIONS NONE : une session d'accès (utilisateur, jeton) ne voit aucune ligne et
    -- sa suppression serait filtrée sans erreur ; elle est refusée au lieu d'annoncer un succès
    IF $access != NONE {
        RETURN fn::error_result("RUNTIME_WRITE_FORBIDDEN", $p.language, { table: "runtime_node" });
    };

    LET $workers = DELETE runtime_worker WHERE node_id = $p.node_id RETURN BEFORE;
    LET $health = DELETE runtime_health WHERE node_id = $p.node_id RETURN BEFORE;
    LET $node = DELETE type::record("runtime_node", $p.node_id) RETURN BEFORE;
    RETURN fn::result_ok({
        node_id: $p.node_id,
        removed: array::len($node) > 0,
        workers: array::len($workers),
        health: array::len($health)
    });
} COMMENT "Retire un nœud arrêté ({ node_id }) : sa ligne de présence et ses lignes runtime_worker et runtime_health. { node_id, removed, workers, health } ; removed est faux pour un nœud inconnu. Appel hors de la session système : RUNTIME_WRITE_FORBIDDEN."
PERMISSIONS FULL;

DEFINE FUNCTION OVERWRITE fn::runtime_node_list($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            alive_within: { pipeline: [{ rule: "duration", options: { min_value: 1s, max_value: 1d } }], default: 30s },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid {
        RETURN fn::error_result("RUNTIME_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;

    LET $limit = time::now() - $p.alive_within;
    RETURN fn::result_ok(
        SELECT node_id, host, modules, foundation_checksum, started_at, seen_at, seen_at > $limit AS alive
        FROM runtime_node
        ORDER BY seen_at DESC, node_id ASC
        LIMIT 1000
    );
} COMMENT "Nœuds connus de la base ({ alive_within : 30 s par défaut, 1 j au plus }), du battement le plus récent au plus ancien, 1000 au plus : { node_id, host, modules, foundation_checksum, started_at, seen_at, alive } ; alive est vrai si le dernier battement date de moins que alive_within à l'heure de la base."
PERMISSIONS FULL;

DEFINE FUNCTION OVERWRITE fn::runtime_node_purge($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            older_than: { pipeline: [{ rule: "duration", options: { min_value: 1m, max_value: 365d } }], default: 7d },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid {
        RETURN fn::error_result("RUNTIME_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;

    -- Tables en PERMISSIONS NONE : une session d'accès (utilisateur, jeton) ne voit aucune ligne et
    -- sa suppression serait filtrée sans erreur ; elle est refusée au lieu d'annoncer un succès
    IF $access != NONE {
        RETURN fn::error_result("RUNTIME_WRITE_FORBIDDEN", $p.language, { table: "runtime_node" });
    };

    LET $limit = time::now() - $p.older_than;
    -- Nœuds sans battement depuis older_than, avec leurs lignes
    -- (« $stale CONTAINS node_id » et non « node_id IN $stale » : en 3.3.4, un UPDATE ou un DELETE
    -- filtré par IN sur le premier champ d'un index composé ne trouve aucune ligne)
    LET $stale = SELECT VALUE node_id FROM runtime_node WHERE seen_at < $limit;
    LET $workers = DELETE runtime_worker WHERE $stale CONTAINS node_id RETURN BEFORE;
    LET $health = DELETE runtime_health WHERE $stale CONTAINS node_id RETURN BEFORE;
    LET $nodes = DELETE runtime_node WHERE $stale CONTAINS node_id AND seen_at < $limit RETURN BEFORE;
    -- Lignes restées sans nœud (processus coupé avant son premier battement), aussi anciennes
    LET $known = SELECT VALUE node_id FROM runtime_node;
    LET $orphan_workers = DELETE runtime_worker WHERE updated_at < $limit AND $known CONTAINSNOT node_id RETURN BEFORE;
    LET $orphan_health = DELETE runtime_health WHERE updated_at < $limit AND $known CONTAINSNOT node_id RETURN BEFORE;
    RETURN fn::result_ok({
        nodes: array::len($nodes),
        workers: array::len($workers) + array::len($orphan_workers),
        health: array::len($health) + array::len($orphan_health)
    });
} COMMENT "Purge les nœuds sans battement depuis older_than (7 j par défaut, 1 min au moins) avec leurs lignes runtime_worker et runtime_health, et les lignes runtime_worker et runtime_health aussi anciennes dont le nœud n'a plus de ligne de présence. { nodes, workers, health } : nombres de lignes supprimées. Appel hors de la session système : RUNTIME_WRITE_FORBIDDEN."
PERMISSIONS FULL;
