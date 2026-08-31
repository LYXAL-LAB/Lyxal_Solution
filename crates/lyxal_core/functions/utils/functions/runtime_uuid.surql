-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_runtime_uuid
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_runtime_uuid() -> uuid {
    RETURN rand::uuid::v7();
}
COMMENT "Génère un UUID v7 adapté aux événements temporels."
PERMISSIONS FULL;
