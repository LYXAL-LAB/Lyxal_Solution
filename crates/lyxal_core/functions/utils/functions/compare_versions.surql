-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/compare_versions.surql
-- Fonction : fn::utils_compare_versions
--
-- Compare deux versions numériques de type v1.2.3.
--
-- Paramètres
--   $left  : string
--   $right : string
--
-- Valeur renvoyée : int (contrat : crates/lyxal_core/Readme.md, fonctions utils)
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : version non numérique (segments de 1 à 18 chiffres séparés par « . », préfixe « v » toléré)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_compare_versions(
    $left: string,
    $right: string
) -> int {
    LET $left_clean = string::replace(string::lowercase(string::trim($left)), <regex>"^v", "");
    LET $right_clean = string::replace(string::lowercase(string::trim($right)), <regex>"^v", "");

    IF !string::matches($left_clean, "^[0-9]{1,18}(\\.[0-9]{1,18})*$")
        OR !string::matches($right_clean, "^[0-9]{1,18}(\\.[0-9]{1,18})*$")
    {
        THROW "CORE_INVALID_ARGUMENT";
    };

    LET $a = array::map(string::split($left_clean, "."), |$part| <int>$part);
    LET $b = array::map(string::split($right_clean, "."), |$part| <int>$part);

    LET $length = math::max([array::len($a),array::len($b)]);

    LET $result = array::fold(
        array::range(0,$length),
        0,
        |$current,$index| IF $current != 0 {
            $current
        } ELSE {
            LET $av = IF $a[$index] IS NONE { 0 } ELSE { $a[$index] };
            LET $bv = IF $b[$index] IS NONE { 0 } ELSE { $b[$index] };

            IF $av < $bv { -1 } ELSE IF $av > $bv { 1 } ELSE { 0 }
        }
    );

    RETURN $result;
}
COMMENT "Compare deux versions numériques de type v1.2.3."
PERMISSIONS FULL;
