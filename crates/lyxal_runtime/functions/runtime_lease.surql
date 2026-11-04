-- ============================================================================
-- Baux distribués du runtime (table runtime_lease, identifiant runtime_lease:[kind, key]).
-- Toutes les échéances sont calculées avec l'heure de la base (time::now()), jamais avec
-- l'horloge d'un nœud : deux nœuds aux horloges décalées ne peuvent pas détenir le même bail.
-- Les instants sont exposés en secondes Unix ; now est l'heure de la base au moment de l'appel.
-- Fonctions internes : entrées validées par les primitives de lyxal_core.
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::runtime_lease_acquire($params: object) {
    LET $checks = {
        kind: fn::validation_enum($params.kind, ["migration", "installation"], true),
        key: fn::validation_required_string($params.key, 1, 512),
        node_id: fn::validation_required_string($params.node_id, 1, 128),
        ttl_seconds: fn::validation_integer($params.ttl_seconds, 1, 86400),
        language: fn::validation_language_code($params.language ?? "fr", false, NONE)
    };
    LET $invalid = object::from_entries(array::map(array::filter(object::entries($checks), |$e| !$e[1].valid), |$e| [$e[0], [$e[1].code]]));
    IF object::len($invalid) > 0 {
        RETURN fn::error_result("RUNTIME_INVALID_PARAMETERS", $params.language, { fields: $invalid });
    };
    LET $p = object::from_entries(array::map(object::entries($checks), |$e| [$e[0], $e[1].value]));

    LET $id = type::record("runtime_lease", [$p.kind, $p.key]);
    LET $now = time::unix(time::now());

    -- Sentinelle : le bail existe toujours avant l'écriture conditionnelle (création concurrente sûre)
    INSERT IGNORE INTO runtime_lease {
        id: $id,
        kind: $p.kind,
        key: $p.key,
        owner_node_id: "",
        generation: 0,
        is_released: true,
        acquired_at: $now,
        renewed_at: $now,
        expires_at: $now
    };

    LET $current = SELECT * FROM ONLY $id;
    IF !$current.is_released AND $current.expires_at > $now {
        RETURN fn::result_ok({
            outcome: IF $current.owner_node_id = $p.node_id THEN "already_owned" ELSE "held_by_other" END,
            now: $now,
            lease: $current.{ kind, key, owner_node_id, generation, is_released, acquired_at, renewed_at, expires_at }
        });
    };

    -- Écriture conditionnelle sur la génération lue : un seul nœud peut gagner
    LET $won = UPDATE $id SET
        owner_node_id = $p.node_id,
        generation = $current.generation + 1,
        is_released = false,
        acquired_at = $now,
        renewed_at = $now,
        expires_at = $now + $p.ttl_seconds,
        released_at = NONE,
        updated_at = time::now()
    WHERE generation = $current.generation
      AND (is_released = true OR expires_at <= $now)
    RETURN AFTER;

    IF array::len($won) = 0 {
        LET $winner = SELECT * FROM ONLY $id;
        RETURN fn::result_ok({
            outcome: IF $winner.owner_node_id = $p.node_id THEN "already_owned" ELSE "held_by_other" END,
            now: $now,
            lease: $winner.{ kind, key, owner_node_id, generation, is_released, acquired_at, renewed_at, expires_at }
        });
    };
    RETURN fn::result_ok({
        outcome: IF !$current.is_released AND $current.generation > 0 THEN "recovered" ELSE "acquired" END,
        now: $now,
        lease: $won[0].{ kind, key, owner_node_id, generation, is_released, acquired_at, renewed_at, expires_at }
    });
} COMMENT "Prend un bail libre, libéré ou expiré (heure de la base) ; renvoie outcome (acquired, recovered, already_owned, held_by_other) et le bail."
PERMISSIONS FULL;

DEFINE FUNCTION OVERWRITE fn::runtime_lease_renew($params: object) {
    LET $checks = {
        kind: fn::validation_enum($params.kind, ["migration", "installation"], true),
        key: fn::validation_required_string($params.key, 1, 512),
        node_id: fn::validation_required_string($params.node_id, 1, 128),
        generation: fn::validation_integer($params.generation, 1, NONE),
        ttl_seconds: fn::validation_integer($params.ttl_seconds, 1, 86400),
        language: fn::validation_language_code($params.language ?? "fr", false, NONE)
    };
    LET $invalid = object::from_entries(array::map(array::filter(object::entries($checks), |$e| !$e[1].valid), |$e| [$e[0], [$e[1].code]]));
    IF object::len($invalid) > 0 {
        RETURN fn::error_result("RUNTIME_INVALID_PARAMETERS", $params.language, { fields: $invalid });
    };
    LET $p = object::from_entries(array::map(object::entries($checks), |$e| [$e[0], $e[1].value]));

    LET $now = time::unix(time::now());
    LET $renewed = UPDATE type::record("runtime_lease", [$p.kind, $p.key]) SET
        renewed_at = $now,
        expires_at = $now + $p.ttl_seconds,
        updated_at = time::now()
    WHERE owner_node_id = $p.node_id
      AND generation = $p.generation
      AND is_released = false
      AND expires_at > $now
    RETURN AFTER;
    RETURN fn::result_ok({
        renewed: array::len($renewed) = 1,
        now: $now,
        lease: $renewed[0].{ kind, key, owner_node_id, generation, is_released, acquired_at, renewed_at, expires_at }
    });
} COMMENT "Prolonge un bail encore détenu (même nœud, même génération, non expiré à l'heure de la base)."
PERMISSIONS FULL;

DEFINE FUNCTION OVERWRITE fn::runtime_lease_release($params: object) {
    LET $checks = {
        kind: fn::validation_enum($params.kind, ["migration", "installation"], true),
        key: fn::validation_required_string($params.key, 1, 512),
        node_id: fn::validation_required_string($params.node_id, 1, 128),
        generation: fn::validation_integer($params.generation, 1, NONE),
        language: fn::validation_language_code($params.language ?? "fr", false, NONE)
    };
    LET $invalid = object::from_entries(array::map(array::filter(object::entries($checks), |$e| !$e[1].valid), |$e| [$e[0], [$e[1].code]]));
    IF object::len($invalid) > 0 {
        RETURN fn::error_result("RUNTIME_INVALID_PARAMETERS", $params.language, { fields: $invalid });
    };
    LET $p = object::from_entries(array::map(object::entries($checks), |$e| [$e[0], $e[1].value]));

    LET $released = UPDATE type::record("runtime_lease", [$p.kind, $p.key]) SET
        is_released = true,
        released_at = time::unix(time::now()),
        updated_at = time::now()
    WHERE owner_node_id = $p.node_id
      AND generation = $p.generation
      AND is_released = false
    RETURN AFTER;
    RETURN fn::result_ok({ released: array::len($released) = 1 });
} COMMENT "Libère un bail détenu par ce nœud et cette génération ; sans effet sinon."
PERMISSIONS FULL;

DEFINE FUNCTION OVERWRITE fn::runtime_lease_get($params: object) {
    LET $checks = {
        kind: fn::validation_enum($params.kind, ["migration", "installation"], true),
        key: fn::validation_required_string($params.key, 1, 512),
        language: fn::validation_language_code($params.language ?? "fr", false, NONE)
    };
    LET $invalid = object::from_entries(array::map(array::filter(object::entries($checks), |$e| !$e[1].valid), |$e| [$e[0], [$e[1].code]]));
    IF object::len($invalid) > 0 {
        RETURN fn::error_result("RUNTIME_INVALID_PARAMETERS", $params.language, { fields: $invalid });
    };
    LET $p = object::from_entries(array::map(object::entries($checks), |$e| [$e[0], $e[1].value]));

    LET $lease = SELECT * FROM ONLY type::record("runtime_lease", [$p.kind, $p.key]);
    LET $now = time::unix(time::now());
    RETURN fn::result_ok(IF $lease = NONE OR $lease.generation = 0 OR $lease.is_released OR $lease.expires_at <= $now THEN NONE ELSE $lease.{ kind, key, owner_node_id, generation, is_released, acquired_at, renewed_at, expires_at } END);
} COMMENT "Bail actif (détenu et non expiré à l'heure de la base), ou NONE."
PERMISSIONS FULL;
