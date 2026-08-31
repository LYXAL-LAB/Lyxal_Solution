-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_cache_touch
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_cache_touch(
    $entry: object,
    $now: datetime,
    $ttl: option<duration>
) -> object {
    LET $new_expiration = IF $ttl IS NONE {
        $entry.expires_at
    } ELSE {
        $now+$ttl
    };

    RETURN object::extend(
        $entry,
        {
            updated_at:$now,
            expires_at:$new_expiration,
            hits:IF $entry.hits IS NONE{1}ELSE{$entry.hits+1}
        }
    );
}
COMMENT "Met à jour l'utilisation et éventuellement l'expiration d'une entrée."
PERMISSIONS FULL;
