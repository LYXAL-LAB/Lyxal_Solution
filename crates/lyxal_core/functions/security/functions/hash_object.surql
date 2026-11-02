-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/security/functions/hash_object.surql
-- Fonction : fn::security_hash_object
--
-- Encode un objet en JSON puis calcule son empreinte. La stabilité dépend de
-- l'ordre canonique fourni par l'encodeur et du même environnement
-- d'exécution.
--
-- Paramètres
--   $value     : object
--   $algorithm : string
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions security)
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
COMMENT "Encode un objet en JSON puis calcule son empreinte. La stabilité dépend de l'ordre canonique fourni par l'encodeur et du même environnement d'exécution."
PERMISSIONS FULL;
