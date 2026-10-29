-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_from_hex
-- Version  : 1.0.1
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_from_hex(
    $value: string
) -> bytes {
    LET $clean = string::lowercase(string::trim($value));

    IF $clean = "" {
        RETURN <bytes>[];
    };

    IF string::len($clean) % 2 != 0
        OR !string::matches($clean, "^[0-9a-f]+$")
    {
        THROW "UTILS_INVALID_HEX_STRING";
    };

    LET $hex_digits = [
        "0", "1", "2", "3", "4", "5", "6", "7",
        "8", "9", "a", "b", "c", "d", "e", "f"
    ];
    LET $pair_count = type::int(math::floor(string::len($clean) / 2));

    LET $byte_list = array::map(
        array::range(0, $pair_count),
        |$index| {
            LET $c_hi = string::slice($clean, $index * 2, $index * 2 + 1);
            LET $c_lo = string::slice($clean, $index * 2 + 1, $index * 2 + 2);
            LET $hi = array::find_index($hex_digits, $c_hi);
            LET $lo = array::find_index($hex_digits, $c_lo);
            RETURN $hi * 16 + $lo;
        }
    );

    RETURN <bytes>$byte_list;
}
COMMENT "Décode une chaîne hexadécimale en octets."
PERMISSIONS FULL;
