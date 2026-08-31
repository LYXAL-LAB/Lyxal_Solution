-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_hash_compare
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_hash_compare(
    $left: string,
    $right: string
) -> bool {
    RETURN $left = $right;
}
COMMENT "
Compare deux empreintes. Cette primitive SurrealQL n'est pas garantie en temps
constant ; utiliser le moteur Rust pour les MAC, signatures et secrets.
"
PERMISSIONS FULL;
