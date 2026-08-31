-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_pipeline_step
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_pipeline_step(
    $name: string,
    $value: any,
    $metadata: option<object>
) -> object {
    LET $clean_name = string::lowercase(string::trim($name));

    IF $clean_name = "" {
        THROW "UTILS_INVALID_PIPELINE_STEP_NAME";
    };

    RETURN {
        name:$clean_name,
        value:$value,
        metadata:IF $metadata IS NONE{{}}ELSE{$metadata}
    };
}
COMMENT "Construit une étape générique de pipeline."
PERMISSIONS FULL;
