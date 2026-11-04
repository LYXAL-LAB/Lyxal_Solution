-- ============================================================================
-- Migrations appliquées (table runtime_migration, identifiant runtime_migration:[module_id, migration_id]).
-- Fonctions internes : entrées validées par les primitives de lyxal_core.
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::runtime_migration_record($params: object) {
    LET $checks = {
        module_id: fn::validation_required_string($params.module_id, 1, 128),
        migration_id: fn::validation_required_string($params.migration_id, 1, 128),
        module_version: fn::validation_required_string($params.module_version, 1, 64),
        checksum: fn::validation_required_string($params.checksum, 64, 64),
        status: fn::validation_enum($params.status, ["Pending", "Applying", "Applied", "Failed", "RolledBack", "Skipped"], true),
        applied_at: fn::validation_integer($params.applied_at, 0, NONE),
        duration_ms: fn::validation_integer($params.duration_ms, 0, NONE),
        error: fn::validation_optional_string($params.error, NONE, 4000),
        lease_key: fn::validation_optional_string($params.lease_key, NONE, 512),
        node_id: fn::validation_optional_string($params.node_id, NONE, 128),
        generation: IF $params.generation IS NONE THEN { valid: true, value: NONE } ELSE fn::validation_integer($params.generation, 1, NONE) END,
        language: fn::validation_language_code($params.language ?? "fr", false, NONE)
    };
    LET $invalid = object::from_entries(array::map(array::filter(object::entries($checks), |$e| !$e[1].valid), |$e| [$e[0], [$e[1].code]]));
    IF object::len($invalid) > 0 {
        RETURN fn::error_result("RUNTIME_INVALID_PARAMETERS", $params.language, { fields: $invalid });
    };
    LET $p = object::from_entries(array::map(object::entries($checks), |$e| [$e[0], $e[1].value]));

    -- Garde du bail de migration (quand la migration est exécutée sous bail) : l'enregistrement
    -- n'a lieu que si ce nœud détient encore le bail, dans la même génération, non expiré à
    -- l'heure de la base. Sinon tout est annulé (THROW, exception documentée comme dans
    -- lyxal_event) : un nœud qui a perdu son bail n'écrit jamais le résultat d'une migration.
    IF $p.lease_key != NONE OR $p.node_id != NONE OR $p.generation != NONE {
        LET $now = time::unix(time::now());
        LET $guard = UPDATE type::record("runtime_lease", ["migration", $p.lease_key]) SET
            updated_at = time::now()
        WHERE owner_node_id = $p.node_id
          AND generation = $p.generation
          AND is_released = false
          AND expires_at > $now
        RETURN AFTER;
        IF array::len($guard) = 0 {
            THROW "RUNTIME_LEASE_FENCED";
        };
    };

    LET $saved = UPSERT ONLY type::record("runtime_migration", [$p.module_id, $p.migration_id]) MERGE {
        module_id: $p.module_id,
        migration_id: $p.migration_id,
        module_version: $p.module_version,
        checksum: $p.checksum,
        status: $p.status,
        applied_at: $p.applied_at,
        duration_ms: $p.duration_ms,
        error: $p.error,
        updated_at: time::now()
    };
    RETURN fn::result_ok($saved.{ module_id, migration_id, module_version, checksum, status, applied_at, duration_ms, error });
} COMMENT "Enregistre l'état d'une migration ; sous bail (lease_key, node_id, generation), refusé par THROW RUNTIME_LEASE_FENCED si le bail n'est plus détenu."
PERMISSIONS FULL;

DEFINE FUNCTION OVERWRITE fn::runtime_migration_get($params: object) {
    LET $checks = {
        module_id: fn::validation_required_string($params.module_id, 1, 128),
        migration_id: fn::validation_required_string($params.migration_id, 1, 128),
        language: fn::validation_language_code($params.language ?? "fr", false, NONE)
    };
    LET $invalid = object::from_entries(array::map(array::filter(object::entries($checks), |$e| !$e[1].valid), |$e| [$e[0], [$e[1].code]]));
    IF object::len($invalid) > 0 {
        RETURN fn::error_result("RUNTIME_INVALID_PARAMETERS", $params.language, { fields: $invalid });
    };
    LET $p = object::from_entries(array::map(object::entries($checks), |$e| [$e[0], $e[1].value]));

    LET $row = SELECT * FROM ONLY type::record("runtime_migration", [$p.module_id, $p.migration_id]);
    RETURN fn::result_ok(IF $row = NONE THEN NONE ELSE $row.{ module_id, migration_id, module_version, checksum, status, applied_at, duration_ms, error } END);
} COMMENT "État d'une migration d'un module, ou NONE."
PERMISSIONS FULL;

DEFINE FUNCTION OVERWRITE fn::runtime_migration_list($params: object) {
    LET $checks = {
        module_id: fn::validation_required_string($params.module_id, 1, 128),
        language: fn::validation_language_code($params.language ?? "fr", false, NONE)
    };
    LET $invalid = object::from_entries(array::map(array::filter(object::entries($checks), |$e| !$e[1].valid), |$e| [$e[0], [$e[1].code]]));
    IF object::len($invalid) > 0 {
        RETURN fn::error_result("RUNTIME_INVALID_PARAMETERS", $params.language, { fields: $invalid });
    };
    LET $p = object::from_entries(array::map(object::entries($checks), |$e| [$e[0], $e[1].value]));

    RETURN fn::result_ok(SELECT module_id, migration_id, module_version, checksum, status, applied_at, duration_ms, error FROM runtime_migration WHERE module_id = $p.module_id ORDER BY migration_id ASC);
} COMMENT "Migrations enregistrées d'un module, triées par identifiant."
PERMISSIONS FULL;
