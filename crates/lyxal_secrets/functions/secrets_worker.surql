-- ============================================================================
-- FONCTIONS : tâches du worker
-- MODULE    : lyxal_secrets
-- ============================================================================

-- ----------------------------------------------------------------------------
-- fn::secrets_purge_due
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_purge_due($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            limit: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 1000 } }], default: 100 },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("SECRETS_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::secrets_can({ action: "worker" }) { RETURN fn::error_result("SECRETS_PERMISSION_DENIED", $p.language, {}); };
    LET $due = (SELECT VALUE id FROM secrets_secret WHERE state = "deleted" AND purge_at <= time::now() ORDER BY purge_at ASC LIMIT $p.limit);
    LET $purged = array::filter(array::map($due, |$id| (DELETE ONLY $id RETURN BEFORE)), |$s| $s IS NOT NONE);
    -- Tickets de lecture échus depuis plus d'un jour
    LET $tickets = (DELETE secrets_read_ticket WHERE expires_at < time::now() - 1d RETURN BEFORE);
    RETURN fn::result_ok({ purged: array::len($purged), tickets_removed: array::len($tickets) });
} COMMENT "Purge les secrets supprimés dont la date de purge est passée ({ limit (1000 au plus) }) et retire les tickets de lecture échus depuis plus d'un jour : { purged, tickets_removed }. Droit : worker";

-- ----------------------------------------------------------------------------
-- fn::secrets_due_list
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_due_list($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            limit: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 1000 } }], default: 100 },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("SECRETS_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::secrets_can({ action: "worker" }) { RETURN fn::error_result("SECRETS_PERMISSION_DENIED", $p.language, {}); };
    LET $now = time::now();
    -- Échéance proche : dans le délai d'alerte de la portée (365 jours au plus)
    LET $expiring = array::slice(array::filter(
        (SELECT id, tenant, path, expires_at FROM secrets_secret WHERE state = "active" AND expiry_warned_at IS NONE
            AND expires_at IS NOT NONE AND expires_at > $now AND expires_at <= $now + 365d ORDER BY expires_at ASC),
        |$s| $s.expires_at <= $now + duration::from_days(fn::secrets_settings_effective({ tenant: $s.tenant }).expiry_warning_days)), 0, $p.limit);
    LET $expired = (SELECT id, tenant, path, expires_at FROM secrets_secret WHERE state != "deleted" AND expired_notified_at IS NONE
        AND expires_at IS NOT NONE AND expires_at <= $now ORDER BY expires_at ASC LIMIT $p.limit);
    LET $rotation_due = (SELECT id, tenant, path, kind, next_rotation_at FROM secrets_secret WHERE state = "active" AND rotation_notified_at IS NONE
        AND next_rotation_at IS NOT NONE AND next_rotation_at <= $now ORDER BY next_rotation_at ASC LIMIT $p.limit);
    -- Clé d'organisation plus ancienne que la période de rotation de sa portée (0 : jamais)
    LET $keys = array::slice(array::filter(
        (SELECT tenant, scope_key, key_id, created_at FROM secrets_tenant_key WHERE state = "active" AND created_at <= $now - 30d ORDER BY created_at ASC),
        |$k| {
            LET $days = fn::secrets_settings_effective({ tenant: $k.tenant }).tenant_key_rotation_days;
            RETURN $days > 0 AND $k.created_at <= $now - duration::from_days($days);
        }), 0, $p.limit);
    RETURN fn::result_ok({ expiring: $expiring, expired: $expired, rotation_due: $rotation_due, tenant_keys_due: $keys });
} COMMENT "Échéances à traiter ({ limit (1000 au plus) }) : { expiring (échéance dans le délai d'alerte, pas encore signalée), expired (échéance passée, pas encore signalée), rotation_due (date de rotation passée, rappel pas encore envoyé), tenant_keys_due (clés actives plus anciennes que la période de rotation de leur portée) }. Droit : worker";

-- ----------------------------------------------------------------------------
-- fn::secrets_due_mark
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::secrets_due_mark($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            secret: { pipeline: [{ rule: "record", options: { expected_table: "secrets_secret" } }], required: true },
            kind: { pipeline: [{ rule: "enum", options: { allowed: ["expiring", "expired", "rotation_due"], case_sensitive: true } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("SECRETS_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $s = (SELECT id, tenant, state, expires_at, next_rotation_at, expiry_warned_at, expired_notified_at, rotation_notified_at FROM ONLY $p.secret);
    IF $s == NONE { RETURN fn::error_result("SECRETS_SECRET_NOT_FOUND", $p.language, { secret: <string> $p.secret }); };
    IF !fn::secrets_can({ action: "worker", tenant: $s.tenant }) { RETURN fn::error_result("SECRETS_PERMISSION_DENIED", $p.language, {}); };
    LET $now = time::now();
    -- L'alerte n'est posée qu'une fois, et seulement si la situation tient encore
    LET $due = IF $p.kind = "expiring" {
        $s.state = "active" AND $s.expiry_warned_at IS NONE AND $s.expires_at > $now
            AND $s.expires_at <= $now + duration::from_days(fn::secrets_settings_effective({ tenant: $s.tenant }).expiry_warning_days)
    } ELSE IF $p.kind = "expired" {
        $s.state != "deleted" AND $s.expired_notified_at IS NONE AND $s.expires_at IS NOT NONE AND $s.expires_at <= $now
    } ELSE {
        $s.state = "active" AND $s.rotation_notified_at IS NONE AND $s.next_rotation_at IS NOT NONE AND $s.next_rotation_at <= $now
    };
    IF !$due { RETURN fn::result_ok({ marked: false }); };
    LET $updated = IF $p.kind = "expiring" { (UPDATE ONLY $s.id SET expiry_warned_at = $now) }
        ELSE IF $p.kind = "expired" { (UPDATE ONLY $s.id SET expired_notified_at = $now) }
        ELSE { (UPDATE ONLY $s.id SET rotation_notified_at = $now) };
    IF $updated == NONE { RETURN fn::error_result("SECRETS_WRITE_FORBIDDEN", $p.language, { table: "secrets_secret" }); };
    RETURN fn::result_ok({ marked: true });
} COMMENT "Signale une échéance une seule fois ({ secret, kind : expiring, expired, rotation_due }) : la date d'alerte est posée, l'entrée de journal et l'événement secrets.secret.<kind> suivent ; rien si la situation ne tient plus ou a déjà été signalée. { marked }. Droit : worker";
