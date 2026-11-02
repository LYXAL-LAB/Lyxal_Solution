-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/cache_touch.surql
-- Fonction : fn::utils_cache_touch
--
-- Met à jour l'utilisation et éventuellement l'expiration d'une entrée.
--
-- Paramètres
--   $entry : object
--   $now   : datetime
--   $ttl   : option<duration>
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions utils)
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
