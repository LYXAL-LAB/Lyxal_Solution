-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_hash_object
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_hash_object(
    $value: object,
    $algorithm: string
) -> object {
    LET $canonical = encoding::json::encode($value);
    RETURN {
        algorithm: string::lowercase(string::trim($algorithm)),
        canonical: $canonical,
        hash: fn::security_hash_string($canonical, $algorithm)
    };
}
COMMENT "
Encode un objet en JSON puis calcule son empreinte. La stabilité dépend de
l'ordre canonique fourni par l'encodeur et du même environnement d'exécution.
"
PERMISSIONS FULL;
