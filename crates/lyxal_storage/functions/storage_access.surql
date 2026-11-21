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
        upload_ttl_seconds: $own.upload_ttl_seconds ?? $base.upload_ttl_seconds ?? 86400,
        deleted_retention_days: $own.deleted_retention_days ?? $base.deleted_retention_days ?? 7,
        -- Par défaut : programmes exécutables (Windows, Linux, macOS)
        blocked_types: $own.blocked_types ?? $base.blocked_types ?? [
            "application/vnd.microsoft.portable-executable", "application/x-executable",
            "application/x-mach-binary", "application/x-msdownload"
        ]
    };
} COMMENT "Réglages effectifs ({ tenant }) : organisation, sinon installation, sinon valeurs par défaut (100 Mo par fichier, sans quota, 24 h d'attente, 24 h pour un envoi reprenable, 7 jours de conservation, programmes exécutables refusés)";

-- ----------------------------------------------------------------------------
-- fn::storage_usage_share (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::storage_usage_share($object: any) -> object {
    IF $object IS NONE { RETURN { objects: 0, bytes: 0, reserved: 0 }; };
    LET $stored = $object.state IN ["available", "quarantined"];
    RETURN {
        objects: IF $stored { 1 } ELSE { 0 },
        bytes: IF $stored { $object.size ?? 0 } ELSE { 0 },
        reserved: IF $object.state = "pending" { $object.declared_size ?? 0 } ELSE { 0 }
    };
} COMMENT "Interne : part d'une fiche ($object, NONE : aucune) dans les compteurs de volume : { objects, bytes } si elle est disponible ou en quarantaine, reserved (taille annoncée) si elle est en attente";

-- ----------------------------------------------------------------------------
-- fn::storage_usage_apply (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::storage_usage_apply($previous: any, $next: any) -> option<string> {
    LET $old = fn::storage_usage_share($previous);
    LET $new = fn::storage_usage_share($next);
    LET $delta = { objects: $new.objects - $old.objects, bytes: $new.bytes - $old.bytes, reserved: $new.reserved - $old.reserved };
    IF $delta.objects = 0 AND $delta.bytes = 0 AND $delta.reserved = 0 { RETURN NONE; };
    LET $object = $next ?? $previous;
    LET $rows = [
        { id: type::record("storage_usage", [$object.scope_key]), bucket: NONE },
        { id: type::record("storage_usage", [$object.scope_key, record::id($object.bucket)]), bucket: $object.bucket }
    ];
    IF $next IS NONE {
        -- Fiche supprimée (purge, ou suppression avec son bucket ou son organisation) : une ligne
        -- déjà partie avec son organisation ou son bucket n'est pas recréée
        FOR $row IN $rows {
            UPDATE $row.id SET objects += $delta.objects, bytes += $delta.bytes, reserved += $delta.reserved;
        };
        RETURN NONE;
    };
    FOR $row IN $rows {
        UPSERT $row.id SET tenant = $object.tenant, scope_key = $object.scope_key, bucket = $row.bucket,
            objects += $delta.objects, bytes += $delta.bytes, reserved += $delta.reserved;
    };
    -- Quota de la portée, contrôlé après l'écriture quand le volume augmente (vaut aussi pour une
    -- écriture directe dans la table)
    IF $delta.bytes + $delta.reserved > 0 {
        LET $quota = fn::storage_settings_effective({ tenant: $object.tenant }).quota_bytes;
        LET $usage = (SELECT bytes, reserved FROM ONLY $rows[0].id);
        IF $quota IS NOT NONE AND $usage.bytes + $usage.reserved > $quota { RETURN "STORAGE_QUOTA_EXCEEDED"; };
    };
    RETURN NONE;
} COMMENT "Interne : compteurs de volume de la portée et du bucket mis à jour pour une fiche passée de $previous à $next (NONE : créée ou supprimée), appelée par l'événement storage_object_usage ; NONE, ou STORAGE_QUOTA_EXCEEDED si le volume augmente au-delà du quota de la portée";

-- ----------------------------------------------------------------------------
-- fn::storage_scope_usage (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::storage_scope_usage($params: object) -> object {
    LET $scope = IF $params.tenant IS NONE { "installation" } ELSE { <string> record::id($params.tenant) };
    LET $row = IF $params.bucket IS NONE {
        type::record("storage_usage", [$scope])
    } ELSE {
        type::record("storage_usage", [$scope, record::id($params.bucket)])
    };
    LET $usage = (SELECT objects, bytes, reserved FROM ONLY $row) ?? { objects: 0, bytes: 0, reserved: 0 };
    -- La fiche except n'est comptée nulle part : sa propre réservation est retirée
    LET $own = IF $params.except IS NONE { fn::storage_usage_share(NONE) } ELSE { fn::storage_usage_share(SELECT * FROM ONLY $params.except) };
    RETURN { objects: $usage.objects - $own.objects, bytes: $usage.bytes - $own.bytes, reserved: $usage.reserved - $own.reserved };
} COMMENT "Volume d'une portée ou d'un bucket ({ tenant, bucket, except }), lu dans les compteurs tenus à jour (storage_usage) : { objects, bytes } des fichiers disponibles ou en quarantaine, reserved : tailles annoncées des écritures en attente ; la part de la fiche except est retirée";
