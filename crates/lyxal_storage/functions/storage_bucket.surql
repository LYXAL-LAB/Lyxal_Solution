-- ============================================================================
-- FONCTIONS : buckets
-- MODULE    : lyxal_storage
-- ============================================================================

-- ----------------------------------------------------------------------------
-- fn::storage_bucket_create
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::storage_bucket_create($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            name: { pipeline: [{ rule: "lyxal_bucket_name", options: { min_length: 3, max_length: 63 } }], required: true },
            description: { pipeline: [{ rule: "optional_string", options: { max_length: 1024 } }] },
            max_object_size: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 5368709120 } }] },
            allowed_types: { pipeline: [{ rule: "array_of_strings", options: { allow_empty: true } }, { rule: "array_length", options: { max_length: 100 } }, { rule: "each", options: { pipeline: [{ rule: "mime_type" }] } }], default: [] },
            readonly: { pipeline: [{ rule: "boolean" }], default: false },
            backend: { pipeline: [{ rule: "snake_case_name", options: { min_length: 1, max_length: 64 } }], default: "default" },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid {
        RETURN fn::error_result("STORAGE_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::storage_can({ action: "manage", tenant: $p.tenant }) { RETURN fn::error_result("STORAGE_PERMISSION_DENIED", $p.language, {}); };
    LET $inserted = (INSERT IGNORE INTO storage_bucket {
        tenant: $p.tenant, name: $p.name, description: $p.description, max_object_size: $p.max_object_size,
        allowed_types: array::distinct($p.allowed_types), readonly: $p.readonly, backend: $p.backend
    });
    IF array::len($inserted) = 0 { RETURN fn::error_result("STORAGE_BUCKET_EXISTS", $p.language, { name: $p.name }); };
    RETURN fn::result_ok($inserted[0]);
} COMMENT "Crée un bucket ({ name, tenant, description, max_object_size, allowed_types, readonly, backend }) ; nom unique dans sa portée (STORAGE_BUCKET_EXISTS) ; allowed_types vide : tous les types ; backend : nom du support (default), fixé à la création. Droit : gestion";

-- ----------------------------------------------------------------------------
-- fn::storage_bucket_update
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::storage_bucket_update($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            bucket: { pipeline: [{ rule: "record", options: { expected_table: "storage_bucket" } }], required: true },
            description: { pipeline: [{ rule: "optional_string", options: { max_length: 1024 } }] },
            max_object_size: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 5368709120 } }] },
            allowed_types: { pipeline: [{ rule: "array_of_strings", options: { allow_empty: true } }, { rule: "array_length", options: { max_length: 100 } }, { rule: "each", options: { pipeline: [{ rule: "mime_type" }] } }] },
            readonly: { pipeline: [{ rule: "boolean" }] },
            clear: { pipeline: [{ rule: "array_of_strings", options: { allow_empty: true } }, { rule: "each", options: { pipeline: [{ rule: "enum", options: { allowed: ["description", "max_object_size"], case_sensitive: true } }] } }], default: [] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid {
        RETURN fn::error_result("STORAGE_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $bucket = (SELECT * FROM ONLY $p.bucket);
    IF $bucket == NONE { RETURN fn::error_result("STORAGE_BUCKET_NOT_FOUND", $p.language, { bucket: <string> $p.bucket }); };
    IF !fn::storage_can({ action: "manage", tenant: $bucket.tenant }) { RETURN fn::error_result("STORAGE_PERMISSION_DENIED", $p.language, {}); };
    LET $updated = (UPDATE ONLY $bucket.id SET
        description = IF "description" IN $p.clear { NONE } ELSE { $p.description ?? description },
        max_object_size = IF "max_object_size" IN $p.clear { NONE } ELSE { $p.max_object_size ?? max_object_size },
        allowed_types = IF $p.allowed_types IS NONE { allowed_types } ELSE { array::distinct($p.allowed_types) },
        readonly = $p.readonly ?? readonly);
    IF $updated == NONE { RETURN fn::error_result("STORAGE_WRITE_FORBIDDEN", $p.language, { table: "storage_bucket" }); };
    RETURN fn::result_ok($updated);
} COMMENT "Modifie un bucket ({ bucket, description, max_object_size, allowed_types, readonly, clear }) : un champ absent est conservé, clear (description, max_object_size) efface ; le nom et le support ne changent pas. Droit : gestion";

-- ----------------------------------------------------------------------------
-- fn::storage_bucket_get
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::storage_bucket_get($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            bucket: { pipeline: [{ rule: "record", options: { expected_table: "storage_bucket" } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("STORAGE_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $bucket = (SELECT * FROM ONLY $p.bucket);
    IF $bucket == NONE { RETURN fn::error_result("STORAGE_BUCKET_NOT_FOUND", $p.language, { bucket: <string> $p.bucket }); };
    LET $sizes = (SELECT VALUE size FROM storage_object WHERE bucket = $bucket.id AND state IN ["available", "quarantined"]);
    RETURN fn::result_ok(object::extend($bucket, { usage: { objects: array::len($sizes), bytes: math::sum($sizes) } }));
} COMMENT "Bucket ({ bucket }) et son volume (usage : { objects, bytes } des fichiers disponibles ou en quarantaine). Droit : lecture";

-- ----------------------------------------------------------------------------
-- fn::storage_bucket_list
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::storage_bucket_list($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            limit: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 1000 } }], default: 100 },
            start: { pipeline: [{ rule: "integer", options: { min_value: 0 } }], default: 0 },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("STORAGE_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::storage_can({ action: "read", tenant: $p.tenant }) { RETURN fn::error_result("STORAGE_PERMISSION_DENIED", $p.language, {}); };
    LET $scope = IF $p.tenant IS NONE { "installation" } ELSE { <string> record::id($p.tenant) };
    LET $rows = (SELECT * FROM storage_bucket WHERE scope_key = $scope ORDER BY name);
    RETURN fn::result_ok({ items: array::slice($rows, $p.start, $p.start + $p.limit), total: array::len($rows) });
} COMMENT "Buckets d'une portée ({ tenant, limit, start }), triés par nom ; { items, total }. Droit : lecture";

-- ----------------------------------------------------------------------------
-- fn::storage_bucket_delete
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::storage_bucket_delete($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            bucket: { pipeline: [{ rule: "record", options: { expected_table: "storage_bucket" } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("STORAGE_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $bucket = (SELECT id, tenant FROM ONLY $p.bucket);
    IF $bucket == NONE { RETURN fn::error_result("STORAGE_BUCKET_NOT_FOUND", $p.language, { bucket: <string> $p.bucket }); };
    IF !fn::storage_can({ action: "manage", tenant: $bucket.tenant }) { RETURN fn::error_result("STORAGE_PERMISSION_DENIED", $p.language, {}); };
    -- Une fiche supprimée dont les octets ne sont pas encore retirés compte : le bucket reste
    LET $objects = array::len(SELECT VALUE id FROM storage_object WHERE bucket = $bucket.id);
    IF $objects > 0 { RETURN fn::error_result("STORAGE_BUCKET_NOT_EMPTY", $p.language, { objects: $objects }); };
    LET $deleted = (DELETE ONLY $bucket.id RETURN BEFORE);
    IF $deleted == NONE { RETURN fn::error_result("STORAGE_WRITE_FORBIDDEN", $p.language, { table: "storage_bucket" }); };
    RETURN fn::result_ok({ deleted: true });
} COMMENT "Supprime un bucket vide ({ bucket }) ; un fichier, même supprimé mais pas encore purgé, le retient (STORAGE_BUCKET_NOT_EMPTY). Droit : gestion";
