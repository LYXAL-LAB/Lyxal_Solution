-- ============================================================================
-- FONCTIONS : opérations du worker (quarantaine, expiration, purge, préfixes à retirer)
-- MODULE    : lyxal_storage
-- ============================================================================
-- Réservées au compte de service (permission storage.worker) et à la session système.

-- ----------------------------------------------------------------------------
-- fn::storage_object_quarantine
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::storage_object_quarantine($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            object: { pipeline: [{ rule: "record", options: { expected_table: "storage_object" } }], required: true },
            reason: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 256 } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("STORAGE_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::storage_can({ action: "worker" }) { RETURN fn::error_result("STORAGE_PERMISSION_DENIED", $p.language, {}); };
    LET $object = (SELECT id, state FROM ONLY $p.object);
    IF $object == NONE { RETURN fn::error_result("STORAGE_OBJECT_NOT_FOUND", $p.language, { object: <string> $p.object }); };
    IF $object.state != "available" {
        RETURN fn::error_result("STORAGE_OBJECT_STATE_INVALID", $p.language, { state: $object.state, expected: "available" });
    };
    LET $updated = (UPDATE ONLY $object.id SET state = "quarantined", quarantine_reason = $p.reason);
    IF $updated == NONE { RETURN fn::error_result("STORAGE_WRITE_FORBIDDEN", $p.language, { table: "storage_object" }); };
    RETURN fn::result_ok($updated);
} COMMENT "Met un fichier disponible en quarantaine ({ object, reason }) : il n'est plus servi. Droit : worker";

-- ----------------------------------------------------------------------------
-- fn::storage_object_expire
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::storage_object_expire($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            limit: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 1000 } }], default: 100 },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("STORAGE_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::storage_can({ action: "worker" }) { RETURN fn::error_result("STORAGE_PERMISSION_DENIED", $p.language, {}); };
    LET $now = time::now();
    LET $due = (SELECT VALUE id FROM storage_object WHERE state = "pending" AND pending_expires_at <= $now AND (upload_claimed_until IS NONE OR upload_claimed_until <= $now) ORDER BY pending_expires_at LIMIT $p.limit);
    LET $expired = (UPDATE $due SET state = "deleted", deleted_at = $now, purge_after = $now, pending_expires_at = NONE RETURN VALUE id);
    RETURN fn::result_ok({ expired: array::len($expired) });
} COMMENT "Abandonne les écritures en attente hors délai ({ limit }), sauf un envoi reprenable en cours d'assemblage : état deleted, octets à retirer au plus tôt ; { expired }. Droit : worker";

-- ----------------------------------------------------------------------------
-- fn::storage_object_purge_list
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::storage_object_purge_list($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
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
    IF !fn::storage_can({ action: "worker" }) { RETURN fn::error_result("STORAGE_PERMISSION_DENIED", $p.language, {}); };
    LET $rows = (SELECT id, backend, path, purge_after FROM storage_object
        WHERE state = "deleted" AND purge_after <= time::now() ORDER BY purge_after, id LIMIT $p.limit START $p.start);
    RETURN fn::result_ok({ items: $rows });
} COMMENT "Fichiers supprimés dont le délai de conservation est écoulé ({ limit, start }), du plus ancien au plus récent (start : rang du premier, pour passer les fichiers en échec) : { items: [{ id, backend, path, purge_after }] } ; le worker retire leurs octets puis appelle fn::storage_object_purge. Droit : worker";

-- ----------------------------------------------------------------------------
-- fn::storage_object_purge
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::storage_object_purge($params: object) {
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
    IF !fn::storage_can({ action: "worker" }) { RETURN fn::error_result("STORAGE_PERMISSION_DENIED", $p.language, {}); };
    LET $object = (SELECT id, state, purge_after FROM ONLY $p.object);
    IF $object == NONE { RETURN fn::error_result("STORAGE_OBJECT_NOT_FOUND", $p.language, { object: <string> $p.object }); };
    IF $object.state != "deleted" OR $object.purge_after > time::now() {
        RETURN fn::error_result("STORAGE_OBJECT_STATE_INVALID", $p.language, { state: $object.state, expected: "deleted" });
    };
    LET $deleted = (DELETE ONLY $object.id RETURN BEFORE);
    IF $deleted == NONE { RETURN fn::error_result("STORAGE_WRITE_FORBIDDEN", $p.language, { table: "storage_object" }); };
    RETURN fn::result_ok({ purged: true });
} COMMENT "Supprime la fiche d'un fichier ({ object }) dont les octets ont été retirés du support ; refus si le fichier n'est pas supprimé ou si son délai de conservation n'est pas écoulé. Droit : worker";

-- ----------------------------------------------------------------------------
-- fn::storage_reclaim_list
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::storage_reclaim_list($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
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
    IF !fn::storage_can({ action: "worker" }) { RETURN fn::error_result("STORAGE_PERMISSION_DENIED", $p.language, {}); };
    LET $rows = (SELECT id, backend, prefix, created_at FROM storage_reclaim ORDER BY created_at, id LIMIT $p.limit START $p.start);
    RETURN fn::result_ok({ items: $rows });
} COMMENT "Préfixes d'octets à retirer après la suppression d'un bucket ({ limit, start }), du plus ancien au plus récent (start : rang du premier, pour passer les préfixes en échec) : { items: [{ id, backend, prefix, created_at }] } ; le worker retire les octets du préfixe puis appelle fn::storage_reclaim_done. Droit : worker";

-- ----------------------------------------------------------------------------
-- fn::storage_reclaim_done
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::storage_reclaim_done($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            reclaim: { pipeline: [{ rule: "record", options: { expected_table: "storage_reclaim" } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("STORAGE_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::storage_can({ action: "worker" }) { RETURN fn::error_result("STORAGE_PERMISSION_DENIED", $p.language, {}); };
    -- Rejeu après un arrêt : une ligne déjà retirée n'est pas une erreur
    IF !record::exists($p.reclaim) { RETURN fn::result_ok({ done: false }); };
    LET $deleted = (DELETE ONLY $p.reclaim RETURN BEFORE);
    IF $deleted == NONE { RETURN fn::error_result("STORAGE_WRITE_FORBIDDEN", $p.language, { table: "storage_reclaim" }); };
    RETURN fn::result_ok({ done: true });
} COMMENT "Retire la ligne d'un préfixe ({ reclaim }) dont les octets ont été retirés du support : { done } (false si la ligne n'existait plus). Droit : worker";

-- ----------------------------------------------------------------------------
-- fn::storage_object_key_get
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::storage_object_key_get($params: object) {
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
    IF !fn::storage_can({ action: "worker" }) { RETURN fn::error_result("STORAGE_PERMISSION_DENIED", $p.language, {}); };
    LET $object = (SELECT id, tenant, content_key FROM ONLY $p.object);
    IF $object == NONE { RETURN fn::error_result("STORAGE_OBJECT_NOT_FOUND", $p.language, { object: <string> $p.object }); };
    RETURN fn::result_ok($object);
} COMMENT "Clé scellée d'un fichier ({ object }) : { id, tenant, content_key } (NONE : fichier en clair) ; le service la fait ouvrir par la clé « fichiers » de l'organisation après le contrôle des droits de l'appelant sur la fiche. Droit : session système ou worker";

-- ----------------------------------------------------------------------------
-- fn::storage_object_rekey_list
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::storage_object_rekey_list($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            key_id: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 64 } }], required: true },
            tenant: { pipeline: [{ rule: "record", options: { expected_table: "auth_organization" } }] },
            retired_at: { pipeline: [{ rule: "datetime" }], required: true },
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
    IF !fn::storage_can({ action: "worker" }) { RETURN fn::error_result("STORAGE_PERMISSION_DENIED", $p.language, {}); };
    LET $scope = IF $p.tenant IS NONE { "installation" } ELSE { <string> record::id($p.tenant) };
    LET $retired_at = <datetime> $p.retired_at;
    LET $items = (SELECT id, tenant, content_key FROM storage_object WHERE content_key_id = $p.key_id ORDER BY id LIMIT $p.limit START $p.start);
    -- Écriture en attente d'un bucket chiffré ouverte avant le retrait de la clé : elle a pu
    -- sceller sa clé de fichier par l'ancienne clé et la poser à sa fin d'écriture
    LET $pending = array::len(SELECT VALUE id FROM storage_object
        WHERE scope_key = $scope AND state = "pending" AND created_at <= $retired_at AND bucket.encrypted = true LIMIT 1);
    RETURN fn::result_ok({ items: $items, pending_writes: $pending > 0 });
} COMMENT "Fiches dont la clé de fichier est scellée par une clé « fichiers » retirée ({ key_id, tenant, retired_at : retrait de la clé, limit, start : fiches en échec à passer }) : { items: [{ id, tenant, content_key }], pending_writes : vrai si une écriture d'un bucket chiffré de la portée, ouverte avant le retrait, est encore en attente }. Sans fiche ni écriture en attente, la clé ne sert plus : l'hôte la fait détruire (lyxal_secrets, in_use faux). Droit : session système ou worker";

-- ----------------------------------------------------------------------------
-- fn::storage_object_rekey
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::storage_object_rekey($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            object: { pipeline: [{ rule: "record", options: { expected_table: "storage_object" } }], required: true },
            expected_key_id: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 64 } }], required: true },
            content_key: { pipeline: [{ rule: "required_string", options: { min_length: 8, max_length: 4096 } }, { rule: "starts_with", options: { prefixes: ["enc:v2:"], case_sensitive: true, trim_value: false } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("STORAGE_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::storage_can({ action: "worker" }) { RETURN fn::error_result("STORAGE_PERMISSION_DENIED", $p.language, {}); };
    LET $object = (SELECT id, content_key_id FROM ONLY $p.object);
    IF $object == NONE { RETURN fn::error_result("STORAGE_OBJECT_NOT_FOUND", $p.language, { object: <string> $p.object }); };
    -- Écriture conditionnelle : la clé attendue est toujours celle qui scelle la clé du fichier
    IF $object.content_key_id != $p.expected_key_id {
        RETURN fn::error_result("STORAGE_OBJECT_STATE_INVALID", $p.language, { content_key_id: $object.content_key_id, expected: $p.expected_key_id });
    };
    LET $updated = (UPDATE ONLY $object.id SET content_key = $p.content_key WHERE content_key_id = $p.expected_key_id);
    IF $updated == NONE { RETURN fn::error_result("STORAGE_WRITE_FORBIDDEN", $p.language, { table: "storage_object" }); };
    RETURN fn::result_ok({ object: $updated.id, content_key_id: $updated.content_key_id });
} COMMENT "Range la clé d'un fichier rescellée après la rotation de la clé « fichiers » de son organisation ({ object, expected_key_id : clé retirée qui la scellait, content_key : nouvelle enveloppe enc:v2 }) : { object, content_key_id } ; aucun octet du fichier n'est réécrit ; refus si la clé attendue n'est plus celle de la fiche (STORAGE_OBJECT_STATE_INVALID). Droit : session système ou worker";

-- ----------------------------------------------------------------------------
-- fn::storage_usage_verify
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::storage_usage_verify($params: object) {
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
    IF !fn::storage_can({ action: "worker" }) { RETURN fn::error_result("STORAGE_PERMISSION_DENIED", $p.language, {}); };
    LET $scope = IF $p.tenant IS NONE { "installation" } ELSE { <string> record::id($p.tenant) };
    LET $zero = { objects: 0, bytes: 0, reserved: 0 };
    LET $add = |$total: object, $object: object| {
        LET $share = fn::storage_usage_share($object);
        RETURN { objects: $total.objects + $share.objects, bytes: $total.bytes + $share.bytes, reserved: $total.reserved + $share.reserved };
    };
    LET $objects = (SELECT bucket, state, size, declared_size FROM storage_object WHERE scope_key = $scope);
    LET $recorded = |$row: record| (SELECT objects, bytes, reserved FROM ONLY $row) ?? $zero;
    LET $scope_counted = array::fold($objects, $zero, $add);
    LET $scope_line = { bucket: NONE, counted: $scope_counted, recorded: $recorded(type::record("storage_usage", [$scope])) };
    LET $bucket_lines = array::map((SELECT VALUE id FROM storage_bucket WHERE scope_key = $scope ORDER BY id), |$bucket| {
        bucket: $bucket,
        counted: array::fold(array::filter($objects, |$o| $o.bucket = $bucket), $zero, $add),
        recorded: $recorded(type::record("storage_usage", [$scope, record::id($bucket)]))
    });
    LET $lines = array::concat([$scope_line], $bucket_lines);
    LET $mismatches = array::filter($lines, |$line| $line.counted != $line.recorded);
    RETURN fn::result_ok({ valid: array::len($mismatches) = 0, checked: array::len($lines), mismatches: $mismatches });
} COMMENT "Contrôle de cohérence des compteurs de volume d'une portée ({ tenant }) : fiches recomptées une à une, comparées à la ligne de la portée et à celle de chaque bucket : { valid, checked, mismatches: [{ bucket (NONE : portée), counted, recorded }] } ; rien n'est corrigé. Opération lourde, à la demande. Droit : worker";
