-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fonction : fn::sanitize_benchmark_sample
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_benchmark_sample($name:string,$duration:duration,$changed:bool,$metadata:option<object>)->object{
 IF string::trim($name)=""{THROW "SANITIZE_BENCHMARK_INVALID_NAME";};
 IF $duration<0s{THROW "SANITIZE_BENCHMARK_INVALID_DURATION";};
 RETURN {name:string::lowercase(string::trim($name)),duration:$duration,changed:$changed,metadata:IF $metadata IS NONE{{}}ELSE{$metadata}};
}
COMMENT "Construit un échantillon de benchmark."
PERMISSIONS FULL;
