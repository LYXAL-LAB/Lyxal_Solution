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
    LET $due = (SELECT VALUE id FROM storage_object WHERE state = "pending" AND pending_expires_at <= $now ORDER BY pending_expires_at LIMIT $p.limit);
    LET $expired = (UPDATE $due SET state = "deleted", deleted_at = $now, purge_after = $now, pending_expires_at = NONE RETURN VALUE id);
    RETURN fn::result_ok({ expired: array::len($expired) });
} COMMENT "Abandonne les écritures en attente hors délai ({ limit }) : état deleted, octets à retirer au plus tôt ; { expired }. Droit : worker";

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
