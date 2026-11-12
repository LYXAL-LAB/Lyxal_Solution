-- ============================================================================
-- FONCTIONS : fiches de fichiers
-- MODULE    : lyxal_storage
-- ============================================================================
-- Écriture en deux temps : fn::storage_object_begin crée la fiche à l'état pending, le Rust
-- écrit les octets, fn::storage_object_commit enregistre taille, type réel et empreinte et rend
-- le fichier disponible. Aucune transaction ne couvre la base et le support : une écriture
-- abandonnée est retirée par fn::storage_object_expire.

-- ----------------------------------------------------------------------------
-- fn::storage_object_limits (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::storage_object_limits($params: object) -> option<object> {
    LET $bucket = $params.bucket;
    LET $settings = fn::storage_settings_effective({ tenant: $bucket.tenant });
    LET $max = $bucket.max_object_size ?? $settings.max_object_size;
    IF $params.size IS NOT NONE AND $params.size > $max {
        RETURN { code: "STORAGE_OBJECT_TOO_LARGE", details: { size: $params.size, max_object_size: $max } };
    };
    IF $params.content_type IS NOT NONE AND $params.content_type INSIDE $settings.blocked_types {
        RETURN { code: "STORAGE_OBJECT_TYPE_REFUSED", details: { content_type: $params.content_type, blocked: true } };
    };
    IF $params.content_type IS NOT NONE AND array::len($bucket.allowed_types) > 0 AND $params.content_type NOTINSIDE $bucket.allowed_types {
        RETURN { code: "STORAGE_OBJECT_TYPE_REFUSED", details: { content_type: $params.content_type, allowed_types: $bucket.allowed_types } };
    };
    IF $settings.quota_bytes IS NOT NONE {
        LET $usage = fn::storage_scope_usage({ tenant: $bucket.tenant, except: $params.except });
        LET $wanted = $usage.bytes + $usage.reserved + ($params.size ?? 0);
        IF $wanted > $settings.quota_bytes {
            RETURN { code: "STORAGE_QUOTA_EXCEEDED", details: { quota_bytes: $settings.quota_bytes, used_bytes: $usage.bytes + $usage.reserved } };
        };
    };
    RETURN NONE;
} COMMENT "Interne : règles du bucket, types refusés des réglages et quota de sa portée pour un fichier ({ bucket, size, content_type, except }) ; NONE, ou { code, details } de l'erreur STORAGE_* à rendre";

-- ----------------------------------------------------------------------------
-- fn::storage_object_is_author (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::storage_object_is_author($object: object) -> bool {
    LET $context = fn::auth_context({});
    IF !$context.ok { RETURN false; };
    IF $context.data.identity IS NOT NONE { RETURN $context.data.identity = $object.owner; };
    RETURN $context.data.application IS NOT NONE AND $context.data.application = $object.owner_application;
} COMMENT "Interne : vrai si l'appelant a ouvert l'écriture de cette fiche ($object) : son identité, ou, pour une session sans identité (compte de service), son application";

-- ----------------------------------------------------------------------------
-- fn::storage_object_update_refusal (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::storage_object_update_refusal($before: object, $after: object) -> option<string> {
    LET $worker = fn::storage_can({ action: "worker" });
    IF $before.state = $after.state {
        -- Hors transition, seul le worker touche aux champs posés par les fonctions
        LET $fixed = ["owner", "owner_application", "declared_type", "declared_size", "content_type", "size", "blake3", "quarantine_reason", "pending_expires_at", "deleted_at", "purge_after"];
        IF !$worker AND array::any($fixed, |$f| $before[$f] != $after[$f]) { RETURN "STORAGE_PERMISSION_DENIED"; };
        -- Assemblage d'un envoi reprenable : réservé par son auteur ou par le worker
        RETURN IF !$worker AND ($before.upload_claimed_until != $after.upload_claimed_until OR $before.upload_claim != $after.upload_claim) AND !fn::storage_object_is_author($before) { "STORAGE_PERMISSION_DENIED" } ELSE { NONE };
    };
    LET $allowed = {
        pending: ["available", "deleted"],
        available: ["quarantined", "deleted"],
        quarantined: ["deleted"],
        deleted: []
    }[$before.state];
    IF $after.state NOTINSIDE $allowed { RETURN "STORAGE_OBJECT_STATE_INVALID"; };
    LET $bucket = (SELECT * FROM ONLY $after.bucket);
    IF $after.state = "available" {
        -- Fin d'écriture : le worker, ou l'appelant qui a ouvert l'écriture ; délai, contenu et règles du bucket
        IF !$worker AND !fn::storage_object_is_author($before) { RETURN "STORAGE_PERMISSION_DENIED"; };
        IF $before.pending_expires_at IS NONE OR ($before.pending_expires_at <= time::now() AND !fn::storage_upload_claimed($before)) { RETURN "STORAGE_OBJECT_STATE_INVALID"; };
        -- Envoi reprenable : toutes les parties reçues, taille finale égale à l'annonce
        IF $before.resumable AND ($after.size != $before.declared_size OR fn::storage_upload_offset($before.id, NONE) != $before.declared_size) { RETURN "STORAGE_OBJECT_STATE_INVALID"; };
        -- Envoi reprenable : terminé sous une réservation d'assemblage en cours
        IF $before.resumable AND !fn::storage_upload_claimed($before) { RETURN "STORAGE_UPLOAD_BUSY"; };
        IF $after.size IS NONE OR $after.content_type IS NONE OR $after.blake3 IS NONE { RETURN "STORAGE_OBJECT_STATE_INVALID"; };
        IF $bucket.readonly { RETURN "STORAGE_BUCKET_READONLY"; };
        RETURN fn::storage_object_limits({ bucket: $bucket, size: $after.size, content_type: $after.content_type, except: $after.id }).code;
    };
    IF $after.state = "quarantined" {
        RETURN IF $worker { NONE } ELSE { "STORAGE_PERMISSION_DENIED" };
    };
    -- Suppression : dates posées ; hors worker, bucket modifiable, fichier non référencé, conservation respectée
    IF $after.deleted_at IS NONE OR $after.purge_after IS NONE { RETURN "STORAGE_OBJECT_STATE_INVALID"; };
    IF $worker { RETURN NONE; };
    IF $bucket.readonly { RETURN "STORAGE_BUCKET_READONLY"; };
    IF array::len((SELECT VALUE <~? FROM ONLY $after.id) ?? []) > 0 { RETURN "STORAGE_OBJECT_IN_USE"; };
    LET $retention = fn::storage_settings_effective({ tenant: $after.tenant }).deleted_retention_days;
    IF $before.state != "pending" AND $after.purge_after < time::now() + duration::from_days($retention) - 1m {
        RETURN "STORAGE_PERMISSION_DENIED";
    };
    RETURN NONE;
} COMMENT "Interne : garde d'une modification de fiche ($before, $after), appelée par l'événement storage_object_update_guard ; NONE, ou le code STORAGE_* du refus. Transitions permises, droits de l'appelant (worker, auteur de l'écriture), délai, contenu, règles du bucket, références, conservation";

-- ----------------------------------------------------------------------------
-- fn::storage_object_begin
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::storage_object_begin($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            bucket: { pipeline: [{ rule: "record", options: { expected_table: "storage_bucket" } }], required: true },
            key: { pipeline: [{ rule: "lyxal_storage_path", options: { allow_file_extension: true, max_length: 512 } }], required: true },
            filename: { pipeline: [{ rule: "filename", options: { min_length: 1, max_length: 255 } }], required: true },
            declared_type: { pipeline: [{ rule: "mime_type" }] },
            declared_size: { pipeline: [{ rule: "integer", options: { min_value: 0 } }] },
            resumable: { pipeline: [{ rule: "boolean" }], default: false },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid {
        RETURN fn::error_result("STORAGE_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    -- Envoi reprenable : la taille est connue dès l'ouverture
    IF $p.resumable AND $p.declared_size IS NONE {
        RETURN fn::error_result("STORAGE_INVALID_PARAMETERS", $p.language, { fields: { declared_size: ["required"] } });
    };
    LET $bucket = (SELECT * FROM ONLY $p.bucket);
    IF $bucket == NONE { RETURN fn::error_result("STORAGE_BUCKET_NOT_FOUND", $p.language, { bucket: <string> $p.bucket }); };
    IF !fn::storage_can({ action: "write", tenant: $bucket.tenant }) { RETURN fn::error_result("STORAGE_PERMISSION_DENIED", $p.language, {}); };
    IF $bucket.readonly { RETURN fn::error_result("STORAGE_BUCKET_READONLY", $p.language, { bucket: $bucket.name }); };
    -- Adresse occupée par un fichier non supprimé : refus (pas de remplacement)
    IF array::len(SELECT VALUE id FROM storage_object WHERE bucket = $bucket.id AND slot = $p.key) > 0 {
        RETURN fn::error_result("STORAGE_OBJECT_EXISTS", $p.language, { bucket: $bucket.name, key: $p.key });
    };
    LET $refusal = fn::storage_object_limits({ bucket: $bucket, size: $p.declared_size, content_type: $p.declared_type });
    IF $refusal IS NOT NONE { RETURN fn::error_result($refusal.code, $p.language, $refusal.details); };
    LET $settings = fn::storage_settings_effective({ tenant: $bucket.tenant });
    LET $context = fn::auth_context({});
    LET $created = (CREATE ONLY storage_object CONTENT {
        bucket: $bucket.id, tenant: $bucket.tenant, key: $p.key, backend: $bucket.backend,
        owner: IF $context.ok { $context.data.identity } ELSE { NONE },
        owner_application: IF $context.ok AND $context.data.identity IS NONE { $context.data.application } ELSE { NONE },
        filename: $p.filename, declared_type: $p.declared_type, declared_size: $p.declared_size, resumable: $p.resumable,
        state: "pending", pending_expires_at: time::now() + duration::from_secs(IF $p.resumable { $settings.upload_ttl_seconds } ELSE { $settings.pending_ttl_seconds })
    });
    IF $created == NONE { RETURN fn::error_result("STORAGE_WRITE_FORBIDDEN", $p.language, { table: "storage_object" }); };
    RETURN fn::result_ok(object::extend($created, { max_size: $bucket.max_object_size ?? $settings.max_object_size }));
} COMMENT "Ouvre l'écriture d'un fichier ({ bucket, key, filename, declared_type, declared_size, resumable }) : fiche créée à l'état pending avec son délai (resumable : envoi reprenable, taille obligatoire, délai upload_ttl_seconds), rendue avec max_size (taille maximale acceptée, pour arrêter une écriture qui dépasse) ; refus si le bucket est en lecture seule, si l'adresse est occupée (STORAGE_OBJECT_EXISTS), ou si la taille, le type ou le quota annoncés dépassent les règles. Droit : écriture";

-- ----------------------------------------------------------------------------
-- fn::storage_object_commit
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::storage_object_commit($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            object: { pipeline: [{ rule: "record", options: { expected_table: "storage_object" } }], required: true },
            size: { pipeline: [{ rule: "integer", options: { min_value: 0 } }], required: true },
            content_type: { pipeline: [{ rule: "mime_type" }], required: true },
            blake3: { pipeline: [{ rule: "checksum", options: { algorithm: "blake3" } }], required: true },
            claim: { pipeline: [{ rule: "uuid" }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid {
        RETURN fn::error_result("STORAGE_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $object = (SELECT * FROM ONLY $p.object);
    IF $object == NONE { RETURN fn::error_result("STORAGE_OBJECT_NOT_FOUND", $p.language, { object: <string> $p.object }); };
    -- Le worker, ou l'appelant qui a ouvert l'écriture (identité, ou application d'un compte de service)
    IF !fn::storage_can({ action: "worker" }) AND !(fn::storage_object_is_author($object) AND fn::storage_can({ action: "write", tenant: $object.tenant })) {
        RETURN fn::error_result("STORAGE_PERMISSION_DENIED", $p.language, {});
    };
    IF $object.state != "pending" OR ($object.pending_expires_at <= time::now() AND !fn::storage_upload_claimed($object)) {
        RETURN fn::error_result("STORAGE_OBJECT_STATE_INVALID", $p.language, { state: $object.state, expected: "pending" });
    };
    -- Envoi reprenable : toutes les parties sont reçues et la taille finale est celle de l'annonce
    IF $object.resumable AND ($p.size != $object.declared_size OR fn::storage_upload_offset($object.id, NONE) != $object.declared_size) {
        RETURN fn::error_result("STORAGE_OBJECT_STATE_INVALID", $p.language, { state: $object.state, expected: "complete" });
    };
    -- Envoi reprenable : seul le détenteur de la réservation d'assemblage en cours le termine ;
    -- un assembleur dont la réservation a été reprise ne touche plus à l'envoi
    IF $object.resumable AND ($p.claim IS NONE OR $p.claim != $object.upload_claim OR !fn::storage_upload_claimed($object)) {
        RETURN fn::error_result("STORAGE_UPLOAD_BUSY", $p.language, {});
    };
    LET $bucket = (SELECT * FROM ONLY $object.bucket);
    -- Bucket passé en lecture seule depuis l'ouverture de l'écriture : plus aucune écriture
    IF $bucket.readonly { RETURN fn::error_result("STORAGE_BUCKET_READONLY", $p.language, { bucket: $bucket.name }); };
    LET $refusal = fn::storage_object_limits({ bucket: $bucket, size: $p.size, content_type: $p.content_type, except: $object.id });
    IF $refusal IS NOT NONE { RETURN fn::error_result($refusal.code, $p.language, $refusal.details); };
    LET $updated = (UPDATE ONLY $object.id SET size = $p.size, content_type = $p.content_type, blake3 = $p.blake3,
        state = "available", pending_expires_at = NONE, upload_claim = NONE);
    IF $updated == NONE { RETURN fn::error_result("STORAGE_WRITE_FORBIDDEN", $p.language, { table: "storage_object" }); };
    RETURN fn::result_ok($updated);
} COMMENT "Termine l'écriture d'un fichier ({ object, size, content_type, blake3, claim (envoi reprenable : jeton de la réservation d'assemblage, STORAGE_UPLOAD_BUSY s'il n'est plus celui en cours) }) : taille, type réel et empreinte enregistrés, état available ; la taille, le type et le quota réels sont revérifiés ; refus si la fiche n'est plus pending, si son délai est passé ou si le bucket est passé en lecture seule. Droit : worker, ou l'appelant qui a ouvert l'écriture (son identité, ou son application pour un compte de service)";

-- ----------------------------------------------------------------------------
-- fn::storage_object_get
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::storage_object_get($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            object: { pipeline: [{ rule: "record", options: { expected_table: "storage_object" } }] },
            bucket: { pipeline: [{ rule: "record", options: { expected_table: "storage_bucket" } }] },
            key: { pipeline: [{ rule: "lyxal_storage_path", options: { allow_file_extension: true, max_length: 512 } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid OR ($report.value.object IS NONE AND ($report.value.bucket IS NONE OR $report.value.key IS NONE)) {
        RETURN fn::error_result("STORAGE_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $object = IF $p.object IS NOT NONE {
        (SELECT * FROM ONLY $p.object)
    } ELSE {
        (SELECT * FROM ONLY storage_object WHERE bucket = $p.bucket AND slot = $p.key LIMIT 1)
    };
    IF $object == NONE { RETURN fn::error_result("STORAGE_OBJECT_NOT_FOUND", $p.language, {}); };
    RETURN fn::result_ok($object);
} COMMENT "Fiche d'un fichier, par son identifiant ({ object }) ou par son adresse ({ bucket, key }, fichier non supprimé) ; l'état dit si le fichier peut être servi (available seulement). Droit : lecture";

-- ----------------------------------------------------------------------------
-- fn::storage_object_open
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::storage_object_open($params: object) {
    LET $found = fn::storage_object_get($params);
    IF !$found.ok { RETURN $found; };
    IF $found.data.state != "available" {
        -- Langue déjà validée par fn::storage_object_get, qui a réussi : absente, « fr » par défaut
        RETURN fn::error_result("STORAGE_OBJECT_NOT_AVAILABLE", $params.language ?? "fr", { state: $found.data.state });
    };
    RETURN $found;
} COMMENT "Fiche d'un fichier à servir ({ object }, ou { bucket, key }) : comme fn::storage_object_get, mais refus si le fichier n'est pas à l'état available (STORAGE_OBJECT_NOT_AVAILABLE) ; backend et path disent où lire ses octets. Droit : lecture";

-- ----------------------------------------------------------------------------
-- fn::storage_object_list
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::storage_object_list($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            bucket: { pipeline: [{ rule: "record", options: { expected_table: "storage_bucket" } }], required: true },
            prefix: { pipeline: [{ rule: "lyxal_storage_path", options: { allow_file_extension: true, max_length: 512 } }] },
            state: { pipeline: [{ rule: "enum", options: { allowed: ["pending", "available", "quarantined", "deleted"], case_sensitive: true } }], default: "available" },
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
    LET $bucket = (SELECT id, tenant FROM ONLY $p.bucket);
    IF $bucket == NONE { RETURN fn::error_result("STORAGE_BUCKET_NOT_FOUND", $p.language, { bucket: <string> $p.bucket }); };
    IF !fn::storage_can({ action: "read", tenant: $bucket.tenant }) { RETURN fn::error_result("STORAGE_PERMISSION_DENIED", $p.language, {}); };
    LET $rows = (SELECT * FROM storage_object
        WHERE bucket = $bucket.id AND state = $p.state AND ($p.prefix IS NONE OR string::starts_with(key, $p.prefix))
        ORDER BY key);
    RETURN fn::result_ok({ items: array::slice($rows, $p.start, $p.start + $p.limit), total: array::len($rows) });
} COMMENT "Fichiers d'un bucket ({ bucket, prefix, state (available), limit, start }), triés par clé ; { items, total }. Droit : lecture";

-- ----------------------------------------------------------------------------
-- fn::storage_object_delete
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::storage_object_delete($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            object: { pipeline: [{ rule: "record", options: { expected_table: "storage_object" } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("STORAGE_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $object = (SELECT * FROM ONLY $p.object);
    IF $object == NONE { RETURN fn::error_result("STORAGE_OBJECT_NOT_FOUND", $p.language, { object: <string> $p.object }); };
    IF !fn::storage_can({ action: "write", tenant: $object.tenant }) { RETURN fn::error_result("STORAGE_PERMISSION_DENIED", $p.language, {}); };
    IF $object.state = "deleted" {
        RETURN fn::error_result("STORAGE_OBJECT_STATE_INVALID", $p.language, { state: "deleted" });
    };
    IF (SELECT VALUE readonly FROM ONLY $object.bucket) = true {
        RETURN fn::error_result("STORAGE_BUCKET_READONLY", $p.language, {});
    };
    -- Références entrantes de toute table (champs déclarés REFERENCE), sans connaître les consommateurs
    LET $references = array::len((SELECT VALUE <~? FROM ONLY $object.id) ?? []);
    IF $references > 0 { RETURN fn::error_result("STORAGE_OBJECT_IN_USE", $p.language, { references: $references }); };
    LET $retention = fn::storage_settings_effective({ tenant: $object.tenant }).deleted_retention_days;
    -- Une écriture jamais terminée n'a rien à conserver : ses octets sont retirés au plus tôt
    LET $purge_after = IF $object.state = "pending" { time::now() } ELSE { time::now() + duration::from_days($retention) };
    LET $updated = (UPDATE ONLY $object.id SET state = "deleted", deleted_at = time::now(), purge_after = $purge_after, pending_expires_at = NONE);
    IF $updated == NONE { RETURN fn::error_result("STORAGE_WRITE_FORBIDDEN", $p.language, { table: "storage_object" }); };
    RETURN fn::result_ok($updated);
} COMMENT "Supprime un fichier ({ object }) : état deleted, adresse libérée ; ses octets sont retirés par le worker après le délai de conservation ; refus s'il est référencé par une autre table (STORAGE_OBJECT_IN_USE) ou si son bucket est en lecture seule. Droit : écriture";

-- ----------------------------------------------------------------------------
-- fn::storage_object_usage
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::storage_object_usage($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("STORAGE_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::storage_can({ action: "read", tenant: $p.tenant }) { RETURN fn::error_result("STORAGE_PERMISSION_DENIED", $p.language, {}); };
    LET $usage = fn::storage_scope_usage({ tenant: $p.tenant });
    RETURN fn::result_ok({
        objects: $usage.objects,
        bytes: $usage.bytes,
        reserved_bytes: $usage.reserved,
        quota_bytes: fn::storage_settings_effective({ tenant: $p.tenant }).quota_bytes
    });
} COMMENT "Volume d'une portée ({ tenant }) : { objects, bytes, reserved_bytes (écritures en attente), quota_bytes (NONE : sans quota) }. Droit : lecture";
