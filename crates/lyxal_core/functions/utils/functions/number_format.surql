-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_number_format
-- Version  : 1.0.1
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_number_format(
    $value: number,
    $precision: int,
    $decimal_separator: string,
    $thousands_separator: string
) -> string {
    IF $precision < 0 {
        THROW "UTILS_INVALID_PRECISION";
    };

    LET $rounded_num = fn::utils_number_round(
        $value,
        $precision
    );

    -- Normalisation du zéro signé (-0 -> 0) après arrondi
    LET $normalized = IF $rounded_num == 0 {
        0
    } ELSE {
        $rounded_num
    };

    LET $rounded = string::replace(
        string::replace(<string>$normalized, "dec", ""),
        "f",
        ""
    );

    LET $parts = string::split($rounded, ".");
    LET $integer = $parts[0];
    LET $fraction = IF array::len($parts) > 1 {
        $parts[1]
    } ELSE {
        ""
    };

    LET $negative = string::starts_with($integer, "-") AND $normalized != 0;
    LET $digits = IF string::starts_with($integer, "-") {
        string::slice($integer, 1, string::len($integer))
    } ELSE {
        $integer
    };

    LET $digit_chars = array::filter(
        string::split($digits, ""),
        |$c| $c != ""
    );
    LET $reversed = array::reverse($digit_chars);
    LET $grouped = array::map(
        array::range(
            0,
            math::ceil(type::float(array::len($reversed)) / 3f)
        ),
        |$index| array::join(
            array::reverse(
                array::slice(
                    $reversed,
                    $index * 3,
                    ($index + 1) * 3
                )
            ),
            ""
        )
    );

    LET $integer_formatted = array::join(
        array::reverse($grouped),
        $thousands_separator
    );

    LET $padded_fraction = IF $precision = 0 {
        ""
    } ELSE {
        string::slice(
            string::concat($fraction, string::repeat("0", $precision)),
            0,
            $precision
        )
    };

    RETURN string::concat(
        IF $negative { "-" } ELSE { "" },
        $integer_formatted,
        IF $precision = 0 {
            ""
        } ELSE {
            string::concat(
                $decimal_separator,
                $padded_fraction
            )
        }
    );
}
COMMENT "Formate un nombre avec précision et séparateurs configurables."
PERMISSIONS FULL;
