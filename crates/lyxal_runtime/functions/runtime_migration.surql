-- ============================================================================
-- Migrations appliquées (table runtime_migration, identifiant runtime_migration:[module_id, migration_id]).
-- Fonctions internes (session système du runtime) : entrées validées par lyxal_core.
--
-- États : Pending, Applying, Applied, Failed, RolledBack, Skipped sont écrits par le moteur de
-- migration (fn::runtime_migration_record) ; RetryRequested et Abandoned ne sont écrits que par
-- fn::runtime_migration_resolve, décision d'exploitation sur une migration interrompue.
-- Migration interrompue : restée à l'état Applying alors que son bail de migration
-- (runtime_lease:["migration", "<module>:<migration>"]) est libéré, expiré ou absent.
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
        script: fn::validation_optional_string($params.script, NONE, 512),
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
    IF $p.lease_key != NONE OR $p.generation != NONE {
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
        script: $p.script,
        node_id: $p.node_id,
        updated_at: time::now()
    };
    -- Début de l'exécution : date de la base, relue pour une migration interrompue
    IF $p.status = "Applying" {
        UPDATE type::record("runtime_migration", [$p.module_id, $p.migration_id]) SET started_at = time::now();
    };
    RETURN fn::result_ok($saved.{ module_id, migration_id, module_version, checksum, status, applied_at, duration_ms, error, script, node_id });
} COMMENT "Enregistre l'état d'une migration (script, nœud qui l'écrit) ; sous bail (lease_key, node_id, generation), refusé par THROW RUNTIME_LEASE_FENCED si le bail n'est plus détenu."
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
    RETURN fn::result_ok(IF $row = NONE THEN NONE ELSE $row.{ module_id, migration_id, module_version, checksum, status, applied_at, duration_ms, error, script, node_id } END);
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

    RETURN fn::result_ok(SELECT module_id, migration_id, module_version, checksum, status, applied_at, duration_ms, error, script, node_id FROM runtime_migration WHERE module_id = $p.module_id ORDER BY migration_id ASC);
} COMMENT "Migrations enregistrées d'un module, triées par identifiant."
PERMISSIONS FULL;

-- ----------------------------------------------------------------------------
-- Reprise guidée d'une migration interrompue
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::runtime_migration_interrupted_list($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            module: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 128 } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("RUNTIME_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;

    -- Une migration Applying dont le bail de migration est encore détenu est en cours, pas
    -- interrompue (heure de la base, comme les baux)
    LET $now = time::unix(time::now());
    LET $candidates = (SELECT
            module_id,
            migration_id,
            module_version,
            script,
            node_id,
            status,
            started_at,
            resolution,
            (SELECT VALUE (!is_released AND expires_at > $now) FROM ONLY type::record("runtime_lease", ["migration", string::concat($parent.module_id, ":", $parent.migration_id)])) ?? false AS running
        FROM runtime_migration
        WHERE status IN ["Applying", "Abandoned"]
          AND ($p.module = NONE OR module_id = $p.module)
        ORDER BY module_id ASC, migration_id ASC);
    RETURN fn::result_ok($candidates.filter(|$m| $m.status = "Abandoned" OR !$m.running).map(|$m| {
        module: $m.module_id,
        migration: $m.migration_id,
        version: $m.module_version,
        script: $m.script,
        node: $m.node_id,
        state: IF $m.status = "Abandoned" { "abandoned" } ELSE { "interrupted" },
        started_at: $m.started_at,
        resolution: $m.resolution
    }));
} COMMENT "Migrations interrompues ({ module } facultatif) : restées Applying sans bail de migration détenu (state interrupted) ou abandonnées et non rejouées (state abandoned) ; pour chacune { module, migration, version, script, node, state, started_at, resolution }, triées par module puis migration."
PERMISSIONS FULL;

DEFINE FUNCTION OVERWRITE fn::runtime_migration_resolve($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            module: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 128 } }], required: true },
            migration: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 128 } }], required: true },
            action: { pipeline: [{ rule: "enum", options: { allowed: ["retry", "abandon"], case_sensitive: true } }], required: true },
            reason: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 1000 } }], required: true },
            actor: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 256 } }], required: true },
            node_id: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 128 } }], required: true },
            generation: { pipeline: [{ rule: "integer", options: { min_value: 1 } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid {
        RETURN fn::error_result("RUNTIME_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;

    LET $id = type::record("runtime_migration", [$p.module, $p.migration]);
    LET $row = SELECT * FROM ONLY $id;
    IF $row = NONE {
        RETURN fn::error_result("RUNTIME_MIGRATION_NOT_INTERRUPTED", $p.language, { module: $p.module, migration: $p.migration, status: "unknown" });
    };

    -- Garde du bail d'installation de la release du module : la décision n'est prise que par le
    -- nœud qui le détient, dans cette génération, non expiré à l'heure de la base. L'installation
    -- du module (qui rejoue les migrations) se fait sous ce même bail : les deux s'excluent.
    LET $now = time::unix(time::now());
    LET $lease_key = string::concat($row.module_id, ":", $row.module_version);
    LET $guard = UPDATE type::record("runtime_lease", ["installation", $lease_key]) SET
        updated_at = time::now()
    WHERE owner_node_id = $p.node_id
      AND generation = $p.generation
      AND is_released = false
      AND expires_at > $now
    RETURN AFTER;
    IF array::len($guard) = 0 {
        RETURN fn::error_result("RUNTIME_LEASE_FENCED", $p.language, { lock_key: $lease_key });
    };

    -- Décision possible : migration interrompue (Applying sans bail de migration détenu), ou
    -- migration abandonnée que l'on demande de rejouer
    LET $migration_lease = SELECT * FROM ONLY type::record("runtime_lease", ["migration", string::concat($row.module_id, ":", $row.migration_id)]);
    LET $running = $migration_lease != NONE AND !$migration_lease.is_released AND $migration_lease.expires_at > $now;
    LET $interrupted = $row.status = "Applying" AND !$running;
    IF !$interrupted AND !($row.status = "Abandoned" AND $p.action = "retry") {
        RETURN fn::error_result("RUNTIME_MIGRATION_NOT_INTERRUPTED", $p.language, {
            module: $p.module,
            migration: $p.migration,
            status: IF $row.status = "Applying" { "running" } ELSE { $row.status }
        });
    };

    LET $saved = UPDATE ONLY $id SET
        status = IF $p.action = "retry" { "RetryRequested" } ELSE { "Abandoned" },
        resolution = { action: $p.action, actor: $p.actor, reason: $p.reason, node_id: $p.node_id, at: time::now() },
        updated_at = time::now()
    RETURN AFTER;
    -- Écriture filtrée (session sans droit sur la table) : jamais de succès annoncé
    IF $saved = NONE {
        RETURN fn::error_result("RUNTIME_MIGRATION_NOT_INTERRUPTED", $p.language, { module: $p.module, migration: $p.migration, status: "unknown" });
    };
    RETURN fn::result_ok({
        module: $saved.module_id,
        migration: $saved.migration_id,
        version: $saved.module_version,
        action: $p.action,
        status: $saved.status,
        previous_status: $row.status,
        resolved_at: $saved.resolution.at
    });
} COMMENT "Décision sur une migration interrompue ({ module, migration, action, reason, actor, node_id, generation }) : retry la marque RetryRequested (rejouée à la prochaine installation du module), abandon la marque Abandoned (installation du module refusée tant qu'un retry ne l'a pas remise à rejouer) ; une migration abandonnée n'accepte que retry. Sous bail d'installation de la release (node_id, generation) : RUNTIME_LEASE_FENCED sinon ; RUNTIME_MIGRATION_NOT_INTERRUPTED si la migration est inconnue, en cours ou dans un autre état. La décision (qui, quand, pourquoi) est gardée dans resolution."
PERMISSIONS FULL;
