-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_number_format
-- Version  : 1.0.0
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

    LET $rounded = <string>fn::utils_number_round(
        $value,
        $precision
    );

    LET $parts = string::split($rounded,".");
    LET $integer = $parts[0];
    LET $fraction = IF array::len($parts) > 1 {
        $parts[1]
    } ELSE {
        ""
    };

    LET $negative = string::starts_with($integer,"-");
    LET $digits = IF $negative {
        string::slice($integer,1,string::len($integer))
    } ELSE {
        $integer
    };

    LET $reversed = array::reverse(string::split($digits,""));
    LET $grouped = array::map(
        array::range(
            0,
            math::ceil(type::float(array::len($reversed))/3f)
        ),
        |$index| array::join(
            array::reverse(
                array::slice(
                    $reversed,
                    $index*3,
                    ($index+1)*3
                )
            ),
            ""
        )
    );

    LET $integer_formatted = array::join(
        array::reverse($grouped),
        $thousands_separator
    );

    RETURN string::concat(
        IF $negative{"-"}ELSE{""},
        $integer_formatted,
        IF $precision = 0 {
            ""
        } ELSE {
            string::concat(
                $decimal_separator,
                string::pad(
                    $fraction,
                    $precision,
                    "0"
                )
            )
        }
    );
}
COMMENT "Formate un nombre avec précision et séparateurs configurables."
PERMISSIONS FULL;
