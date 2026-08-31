-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- Fonction : fn::validation_runtime_context
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::validation_runtime_context(
 $schema_name:string,$schema_version:string,$mode:string,$options:option<object>
) -> object {
 LET $name=string::lowercase(string::trim($schema_name));
 LET $version=string::lowercase(string::trim($schema_version));
 LET $clean_mode=string::lowercase(string::trim($mode));
 IF !string::matches($name,"^[a-z][a-z0-9_]*(?:::[a-z][a-z0-9_]*)*$"){THROW "VALIDATION_RUNTIME_INVALID_SCHEMA_NAME";};
 IF !string::matches($version,"^v[1-9][0-9]*$"){THROW "VALIDATION_RUNTIME_INVALID_SCHEMA_VERSION";};
 IF !array::contains(["fail_fast","collect","silent"],$clean_mode){THROW "VALIDATION_RUNTIME_INVALID_MODE";};
 RETURN {schema_name:$name,schema_version:$version,mode:$clean_mode,options:IF $options IS NONE{{}}ELSE{$options},started_at:time::now()};
}
COMMENT "Construit le contexte d'exécution du Validation Runtime."
PERMISSIONS FULL;
