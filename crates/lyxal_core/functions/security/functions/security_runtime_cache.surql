-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_runtime_cache
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_runtime_cache(
    $entries:array<object>,
    $entry:object,
    $now:datetime
)->array<object>{
 LET $active=array::filter($entries,|$e|$e.expires_at>$now AND $e.key!=$entry.key);
 RETURN array::append($active,$entry);
}
COMMENT "Purge et remplace une entrée de cache Security."
PERMISSIONS FULL;
