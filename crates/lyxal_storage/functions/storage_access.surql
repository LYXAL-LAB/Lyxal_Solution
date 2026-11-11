-- ============================================================================
-- FONCTIONS : droits et réglages effectifs
-- MODULE    : lyxal_storage
-- ============================================================================
-- Contrôle unique des droits, utilisé par les PERMISSIONS des tables et par les fonctions
-- publiques.

-- ----------------------------------------------------------------------------
-- fn::storage_can
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::storage_can($params: object) -> bool {
    IF fn::auth_session_valid({}).system { RETURN true; };
    LET $worker = fn::auth_has_permission({ permission: "storage.worker" });
    IF $params.action = "worker" { RETURN $worker; };
    IF $params.tenant IS NONE {
        RETURN fn::auth_has_permission({ permission: "storage.installation.manage" })
            OR ($worker AND $params.action IN ["read", "write"]);
    };
    IF $params.action = "read" {
        RETURN $worker OR array::any(["storage.object.read", "storage.object.write", "storage.bucket.manage"],
            |$code| fn::auth_has_permission({ permission: $code, tenant: $params.tenant }));
    };
    IF $params.action = "write" {
        RETURN $worker OR fn::auth_has_permission({ permission: "storage.object.write", tenant: $params.tenant });
    };
    IF $params.action = "manage" {
        RETURN fn::auth_has_permission({ permission: "storage.bucket.manage", tenant: $params.tenant });
    };
    RETURN false;
} COMMENT "Vrai si l'appelant peut effectuer l'action ({ action : read, write, manage, worker ; tenant : organisation ou NONE pour l'installation }). Jamais d'erreur";

-- ----------------------------------------------------------------------------
-- fn::storage_settings_effective
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::storage_settings_effective($params: object) -> object {
    LET $base = (SELECT * FROM ONLY storage_settings WHERE scope_key = "installation" LIMIT 1) ?? {};
    LET $own = IF $params.tenant IS NONE { {} } ELSE {
        (SELECT * FROM ONLY storage_settings WHERE scope_key = <string> record::id($params.tenant) LIMIT 1) ?? {}
    };
    RETURN {
        max_object_size: $own.max_object_size ?? $base.max_object_size ?? 104857600,
        quota_bytes: $own.quota_bytes ?? $base.quota_bytes,
        pending_ttl_seconds: $own.pending_ttl_seconds ?? $base.pending_ttl_seconds ?? 86400,
        deleted_retention_days: $own.deleted_retention_days ?? $base.deleted_retention_days ?? 7
    };
} COMMENT "Réglages effectifs ({ tenant }) : organisation, sinon installation, sinon valeurs par défaut (100 Mo par fichier, sans quota, 24 h d'attente, 7 jours de conservation)";

-- ----------------------------------------------------------------------------
-- fn::storage_scope_usage
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::storage_scope_usage($params: object) -> object {
    LET $scope = IF $params.tenant IS NONE { "installation" } ELSE { <string> record::id($params.tenant) };
    LET $stored = (SELECT VALUE size FROM storage_object WHERE scope_key = $scope AND state IN ["available", "quarantined"]);
    LET $pending = (SELECT VALUE declared_size ?? 0 FROM storage_object WHERE scope_key = $scope AND state = "pending" AND id != $params.except);
    RETURN { objects: array::len($stored), bytes: math::sum($stored), reserved: math::sum($pending) };
} COMMENT "Volume d'une portée ({ tenant, except }) : { objects, bytes } des fichiers disponibles ou en quarantaine, reserved : tailles annoncées des écritures en attente (hors la fiche except)";
