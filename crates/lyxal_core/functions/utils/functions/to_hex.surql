-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/to_hex.surql
-- Fonction : fn::utils_to_hex
--
-- Encode des octets en chaîne hexadécimale minuscule.
--
-- Paramètres
--   $value : bytes
--
-- Valeur renvoyée : string (contrat : crates/lyxal_core/Readme.md, fonctions utils)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_to_hex(
    $value: bytes
) -> string {
    LET $hex_digits = [
        "0", "1", "2", "3", "4", "5", "6", "7",
        "8", "9", "a", "b", "c", "d", "e", "f"
    ];
    LET $byte_list = <array>$value;

    RETURN array::join(
        array::map(
            $byte_list,
            |$b| {
                LET $hi = type::int(math::floor($b / 16));
                LET $lo = $b % 16;
                RETURN string::concat(
                    $hex_digits[$hi],
                    $hex_digits[$lo]
                );
            }
        ),
        ""
    );
}
COMMENT "Encode des octets en chaîne hexadécimale minuscule."
PERMISSIONS FULL;
