-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/engine_schema_hash.surql
-- Fonction : fn::utils_engine_schema_hash
--
-- Empreinte SHA-256 déterministe d'un schéma normalisé, calculée sur sa
-- représentation SurrealQL (types conservés : la durée 1s et la chaîne « 1s
-- » diffèrent ; clés triées), utilisable comme clé de cache
-- (fn::utils_cache_key, fn::utils_cache_entry).
--
-- Paramètres
--   $schema : object
--
-- Valeur renvoyée : string (contrat : crates/lyxal_core/Readme.md, fonctions utils)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_engine_schema_hash(
    $schema: object
) -> string {
    RETURN crypto::sha256(<string> $schema);
}
COMMENT "Empreinte SHA-256 déterministe d'un schéma normalisé, calculée sur sa représentation SurrealQL (types conservés : la durée 1s et la chaîne « 1s » diffèrent ; clés triées), utilisable comme clé de cache (fn::utils_cache_key, fn::utils_cache_entry)."
PERMISSIONS FULL;
