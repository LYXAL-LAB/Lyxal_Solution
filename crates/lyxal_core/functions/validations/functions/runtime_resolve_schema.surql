-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- Fonction : fn::validation_runtime_resolve_schema
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::validation_runtime_resolve_schema(
 $registry_entries:array<object>,$schema_name:string,$schema_version:string
) -> object {
 LET $name=string::lowercase(string::trim($schema_name));
 LET $version=string::lowercase(string::trim($schema_version));
 LET $matches=array::filter($registry_entries,|$entry|$entry.name=$name AND $entry.version=$version AND $entry.status="active");
 IF array::len($matches)=0{THROW "VALIDATION_RUNTIME_SCHEMA_NOT_FOUND";};
 RETURN $matches[0];
}
COMMENT "Résout un schéma actif à partir d'un registre."
PERMISSIONS FULL;
