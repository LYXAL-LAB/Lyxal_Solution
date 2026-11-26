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
-- Compteurs répartis (schema/06_storage_usage.surql) : la variation va dans une ligne tirée au
-- sort parmi 64, la même pour la portée et pour le bucket (un seul tirage : deux écritures
-- simultanées ne se heurtent que si elles tirent le même numéro, une fois sur 64).

DEFINE FUNCTION OVERWRITE fn::storage_usage_apply($previous: any, $next: any) -> option<string> {
    LET $old = fn::storage_usage_share($previous);
    LET $new = fn::storage_usage_share($next);
    LET $delta = { objects: $new.objects - $old.objects, bytes: $new.bytes - $old.bytes, reserved: $new.reserved - $old.reserved };
    IF $delta.objects = 0 AND $delta.bytes = 0 AND $delta.reserved = 0 { RETURN NONE; };
    LET $object = $next ?? $previous;
    -- Fiche supprimée avec son organisation : les lignes de la portée et de ses buckets sont
    -- parties avec elle, rien n'est recréé. Fiche supprimée avec son seul bucket : de même pour
    -- les lignes du bucket (la suppression est de toute façon refusée par
    -- storage_object_bucket_guard)
    IF $next IS NONE AND $object.tenant IS NOT NONE AND !record::exists($object.tenant) { RETURN NONE; };
    LET $shard = rand::int(0, 63);
    UPSERT type::record("storage_usage", ["scope", $object.scope_key, $shard])
        SET tenant = $object.tenant, scope_key = $object.scope_key, bucket = NONE, shard = $shard,
            objects += $delta.objects, bytes += $delta.bytes, reserved += $delta.reserved;
    IF $next IS NOT NONE OR record::exists($object.bucket) {
        UPSERT type::record("storage_usage", ["bucket", record::id($object.bucket), $shard])
            SET tenant = $object.tenant, scope_key = $object.scope_key, bucket = $object.bucket, shard = $shard,
                objects += $delta.objects, bytes += $delta.bytes, reserved += $delta.reserved;
    };
    -- Quota de la portée, contrôlé après l'écriture quand le volume augmente (vaut aussi pour une
    -- écriture directe dans la table). La somme est celle de l'instantané de la transaction :
    -- deux écritures simultanées qui tirent deux numéros différents ne se voient pas et peuvent
    -- dépasser ensemble le quota, de leur taille au plus
    IF $delta.bytes + $delta.reserved > 0 {
        LET $quota = fn::storage_settings_effective({ tenant: $object.tenant }).quota_bytes;
        IF $quota IS NOT NONE {
            LET $usage = fn::storage_scope_usage({ tenant: $object.tenant });
            IF $usage.bytes + $usage.reserved > $quota { RETURN "STORAGE_QUOTA_EXCEEDED"; };
        };
    };
    RETURN NONE;
} COMMENT "Interne : compteurs de volume de la portée et du bucket mis à jour pour une fiche passée de $previous à $next (NONE : créée ou supprimée), appelée par l'événement storage_object_usage ; la variation est ajoutée à une ligne tirée au sort parmi 64 (même numéro pour la portée et le bucket) ; NONE, ou STORAGE_QUOTA_EXCEEDED si le volume augmente au-delà du quota de la portée (somme lue dans l'instantané de la transaction : deux écritures simultanées peuvent le dépasser ensemble de leur taille)";

-- ----------------------------------------------------------------------------
-- fn::storage_scope_usage (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::storage_scope_usage($params: object) -> object {
    LET $scope = IF $params.tenant IS NONE { "installation" } ELSE { <string> record::id($params.tenant) };
    -- Somme des lignes de la portée ou du bucket (64 au plus, lues par plage d'identifiants)
    LET $lines = IF $params.bucket IS NONE {
        (SELECT objects, bytes, reserved FROM storage_usage:["scope", $scope, 0]..=["scope", $scope, 63])
    } ELSE {
        LET $bucket_key = record::id($params.bucket);
        (SELECT objects, bytes, reserved FROM storage_usage:["bucket", $bucket_key, 0]..=["bucket", $bucket_key, 63])
    };
    -- La fiche except n'est comptée nulle part : sa propre réservation est retirée
    LET $own = IF $params.except IS NONE { fn::storage_usage_share(NONE) } ELSE { fn::storage_usage_share(SELECT * FROM ONLY $params.except) };
    RETURN {
        objects: math::sum($lines.objects) - $own.objects,
        bytes: math::sum($lines.bytes) - $own.bytes,
        reserved: math::sum($lines.reserved) - $own.reserved
    };
} COMMENT "Volume d'une portée ou d'un bucket ({ tenant, bucket, except }), somme des lignes de compteurs tenues à jour (storage_usage, 64 au plus) : { objects, bytes } des fichiers disponibles ou en quarantaine, reserved : tailles annoncées des écritures en attente ; la part de la fiche except est retirée";
