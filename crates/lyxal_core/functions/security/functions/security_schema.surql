-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_schema
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_schema(
    $name:string,
    $version:string,
    $fields:object,
    $default_action:string
)->object{
 LET $action=string::lowercase(string::trim($default_action));
 IF !array::contains(["allow","deny","review"],$action){THROW "SECURITY_INVALID_SCHEMA_DEFAULT_ACTION";};
 RETURN {
  name:string::lowercase(string::trim($name)),
  version:string::lowercase(string::trim($version)),
  fields:$fields,
  default_action:$action
 };
}
COMMENT "Construit un schéma Security versionné."
PERMISSIONS FULL;
