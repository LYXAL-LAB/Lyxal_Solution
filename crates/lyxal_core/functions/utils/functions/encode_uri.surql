-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_encode_uri
-- Version  : 1.0.1
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_encode_uri(
    $value: string
) -> string {
    LET $hex_upper = [
        "0", "1", "2", "3", "4", "5", "6", "7",
        "8", "9", "A", "B", "C", "D", "E", "F"
    ];
    LET $byte_list = <array><bytes>$value;

    RETURN array::join(
        array::map(
            $byte_list,
            |$b| {
                IF ($b >= 65 AND $b <= 90)
                    OR ($b >= 97 AND $b <= 122)
                    OR ($b >= 48 AND $b <= 57)
                    OR $b = 45
                    OR $b = 46
                    OR $b = 95
                    OR $b = 126
                {
                    RETURN <string><bytes>[$b];
                };

                LET $hi = type::int(math::floor($b / 16));
                LET $lo = $b % 16;
                RETURN string::concat(
                    "%",
                    $hex_upper[$hi],
                    $hex_upper[$lo]
                );
            }
        ),
        ""
    );
}
COMMENT "Encode une chaîne UTF-8 en Percent-Encoding RFC 3986 pour une URI."
PERMISSIONS FULL;
