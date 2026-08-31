-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_debug_slowest
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_debug_slowest(
    $session: object,
    $limit: int
) -> array<object> {
    IF $limit < 1 {
        THROW "SECURITY_DEBUG_INVALID_LIMIT";
    };

    RETURN array::slice(
        array::sort::desc($session.traces,"duration"),
        0,
        $limit
    );
}
COMMENT "Retourne les traces Security les plus lentes."
PERMISSIONS FULL;
