-- ============================================================================
-- Releases des modules (table runtime_release, identifiant runtime_release:[module_id, version]).
-- Fonctions internes : entrées validées par les primitives de lyxal_core.
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::runtime_release_register($params: object) {
    LET $checks = {
        module_id: fn::validation_required_string($params.module_id, 1, 128),
        version: fn::validation_semantic_version($params.version, false),
        manifest_version: fn::validation_integer($params.manifest_version, 1, NONE),
        status: fn::validation_enum($params.status, ["Discovered", "Installing", "Installed", "Active", "Inactive", "Failed"], true),
        description: fn::validation_optional_string($params.description, NONE, 4000),
        checksum: fn::validation_optional_string($params.checksum, NONE, 128),
        installation_phase: fn::validation_optional_string($params.installation_phase, NONE, 64),
        language: fn::validation_language_code($params.language ?? "fr", false, NONE)
    };
    LET $invalid = object::from_entries(array::map(array::filter(object::entries($checks), |$e| !$e[1].valid), |$e| [$e[0], [$e[1].code]]));
    IF object::len($invalid) > 0 {
        RETURN fn::error_result("RUNTIME_INVALID_PARAMETERS", $params.language, { fields: $invalid });
    };
    LET $p = object::from_entries(array::map(object::entries($checks), |$e| [$e[0], $e[1].value]));

    -- Réenregistrer une release existante (reprise d'une installation) la remet à l'état fourni
    LET $saved = UPSERT ONLY type::record("runtime_release", [$p.module_id, $p.version]) MERGE {
        module_id: $p.module_id,
        version: $p.version,
        manifest_version: $p.manifest_version,
        status: $p.status,
        description: $p.description,
        checksum: $p.checksum,
        installation_phase: $p.installation_phase,
        updated_at: time::now()
    };
    RETURN fn::result_ok($saved.{ module_id, version, manifest_version, status, description, checksum, installation_phase, created_at, installed_at, updated_at });
} COMMENT "Enregistre une release de module, ou la remet à l'état fourni si elle existe déjà."
PERMISSIONS FULL;

DEFINE FUNCTION OVERWRITE fn::runtime_release_get($params: object) {
    LET $checks = {
        module_id: fn::validation_required_string($params.module_id, 1, 128),
        version: fn::validation_required_string($params.version, 1, 64),
        language: fn::validation_language_code($params.language ?? "fr", false, NONE)
    };
    LET $invalid = object::from_entries(array::map(array::filter(object::entries($checks), |$e| !$e[1].valid), |$e| [$e[0], [$e[1].code]]));
    IF object::len($invalid) > 0 {
        RETURN fn::error_result("RUNTIME_INVALID_PARAMETERS", $params.language, { fields: $invalid });
    };
    LET $p = object::from_entries(array::map(object::entries($checks), |$e| [$e[0], $e[1].value]));

    RETURN fn::result_ok(SELECT * OMIT id FROM ONLY type::record("runtime_release", [$p.module_id, $p.version]));
} COMMENT "Release d'un module, ou NONE."
PERMISSIONS FULL;

DEFINE FUNCTION OVERWRITE fn::runtime_release_list($params: object) {
    LET $checks = {
        module_id: fn::validation_required_string($params.module_id, 1, 128),
        language: fn::validation_language_code($params.language ?? "fr", false, NONE)
    };
    LET $invalid = object::from_entries(array::map(array::filter(object::entries($checks), |$e| !$e[1].valid), |$e| [$e[0], [$e[1].code]]));
    IF object::len($invalid) > 0 {
        RETURN fn::error_result("RUNTIME_INVALID_PARAMETERS", $params.language, { fields: $invalid });
    };
    LET $p = object::from_entries(array::map(object::entries($checks), |$e| [$e[0], $e[1].value]));

    RETURN fn::result_ok(SELECT * OMIT id FROM runtime_release WHERE module_id = $p.module_id ORDER BY version ASC);
} COMMENT "Releases d'un module, triées par version."
PERMISSIONS FULL;

DEFINE FUNCTION OVERWRITE fn::runtime_release_status_update($params: object) {
    LET $checks = {
        module_id: fn::validation_required_string($params.module_id, 1, 128),
        version: fn::validation_required_string($params.version, 1, 64),
        status: fn::validation_enum($params.status, ["Discovered", "Installing", "Installed", "Active", "Inactive", "Failed"], true),
        phase: fn::validation_optional_string($params.phase, NONE, 64),
        language: fn::validation_language_code($params.language ?? "fr", false, NONE)
    };
    LET $invalid = object::from_entries(array::map(array::filter(object::entries($checks), |$e| !$e[1].valid), |$e| [$e[0], [$e[1].code]]));
    IF object::len($invalid) > 0 {
        RETURN fn::error_result("RUNTIME_INVALID_PARAMETERS", $params.language, { fields: $invalid });
    };
    LET $p = object::from_entries(array::map(object::entries($checks), |$e| [$e[0], $e[1].value]));

    LET $release = type::record("runtime_release", [$p.module_id, $p.version]);
    IF !record::exists($release) {
        RETURN fn::error_result("RUNTIME_RELEASE_NOT_FOUND", $p.language, { module_id: $p.module_id, version: $p.version });
    };
    LET $saved = UPDATE ONLY $release MERGE {
        status: $p.status,
        installation_phase: $p.phase,
        installed_at: IF $p.status = "Installed" THEN time::now() ELSE $release.installed_at END,
        updated_at: time::now()
    };
    RETURN fn::result_ok($saved.{ module_id, version, manifest_version, status, description, checksum, installation_phase, created_at, installed_at, updated_at });
} COMMENT "Change le statut (et la phase) d'une release existante ; RUNTIME_RELEASE_NOT_FOUND sinon."
PERMISSIONS FULL;
