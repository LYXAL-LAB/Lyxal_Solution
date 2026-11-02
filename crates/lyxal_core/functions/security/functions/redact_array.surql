-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/security/functions/redact_array.surql
-- Fonction : fn::security_redact_array
--
-- Masque les éléments d'un tableau selon leurs index.
--
-- Paramètres
--   $value   : array<any>
--   $indexes : array<int>
--
-- Valeur renvoyée : array<any> (contrat : crates/lyxal_core/Readme.md, fonctions security)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::security_redact_array(
    $value: array<any>,
    $indexes: array<int>
) -> array<any> {
    RETURN array::map(
        $value,
        |$item,$index| IF (($indexes) CONTAINS ($index)) {
            "***REDACTED***"
        } ELSE {
            $item
        }
    );
}
COMMENT "Masque les éléments d'un tableau selon leurs index."
PERMISSIONS FULL;
