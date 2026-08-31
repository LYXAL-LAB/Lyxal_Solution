-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- Fonction : fn::validation_runtime_prepare_schema
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::validation_runtime_prepare_schema(
 $schema_entry:object,$cache_entries:array<object>,$source_hash:string,$ttl:duration,$now:datetime
) -> object {
 LET $key=fn::validation_schema_cache_key($schema_entry.name,$schema_entry.version,$source_hash);
 LET $cached=fn::validation_schema_cache_select($cache_entries,$key,$now);
 IF $cached IS NOT NONE{RETURN {cache_hit:true,cache_key:$key,compiled_schema:$cached.compiled_schema,cache_entry:$cached};};
 LET $compiled=fn::validation_schema_compile($schema_entry.name,$schema_entry.version,$schema_entry.schema);
 RETURN {cache_hit:false,cache_key:$key,compiled_schema:$compiled,cache_entry:fn::validation_schema_cache_entry($key,$compiled,$ttl,$now)};
}
COMMENT "Résout un schéma compilé depuis le cache ou le compile."
PERMISSIONS FULL;
