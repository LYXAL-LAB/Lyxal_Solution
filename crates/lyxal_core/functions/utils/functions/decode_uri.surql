-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_decode_uri
-- Version  : 1.0.1
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::utils_decode_uri(
    $value: string
) -> string {
    IF string::contains($value, "%")
        AND !string::matches($value, "^([^%]|%[0-9a-fA-F]{2})*$")
    {
        THROW "UTILS_INVALID_URI_ENCODING";
    };

    IF !string::contains($value, "%") {
        RETURN $value;
    };

    LET $hex_digits = [
        "0", "1", "2", "3", "4", "5", "6", "7",
        "8", "9", "a", "b", "c", "d", "e", "f"
    ];
    LET $segments = string::split($value, "%");
    LET $tail_segments = array::slice($segments, 1, array::len($segments));

    LET $tail_byte_groups = array::map(
        $tail_segments,
        |$seg| {
            LET $seg_bytes = <array><bytes>$seg;
            LET $c_hi = string::lowercase(string::slice($seg, 0, 1));
            LET $c_lo = string::lowercase(string::slice($seg, 1, 2));
            LET $hi = array::find_index($hex_digits, $c_hi);
            LET $lo = array::find_index($hex_digits, $c_lo);
            LET $decoded_byte = $hi * 16 + $lo;

            LET $rest_bytes = IF array::len($seg_bytes) > 2 {
                array::slice($seg_bytes, 2, array::len($seg_bytes))
            } ELSE {
                []
            };

            RETURN array::concat([$decoded_byte], $rest_bytes);
        }
    );

    LET $out_bytes = array::concat(
        <array><bytes>$segments[0],
        array::flatten($tail_byte_groups)
    );

    -- Validation stricte UTF-8 (RFC 3629) sans mutation de variable
    LET $len = array::len($out_bytes);
    FOR $i IN array::range(0, $len) {
        LET $b = $out_bytes[$i];

        IF ($b >= 192 AND $b <= 193) OR $b >= 245 {
            THROW "UTILS_INVALID_URI_ENCODING";
        };

        IF $b >= 194 AND $b <= 223 {
            IF $i + 1 >= $len
                OR $out_bytes[$i + 1] < 128
                OR $out_bytes[$i + 1] > 191
            {
                THROW "UTILS_INVALID_URI_ENCODING";
            };
        };

        IF $b >= 224 AND $b <= 239 {
            IF $i + 2 >= $len
                OR $out_bytes[$i + 1] < 128
                OR $out_bytes[$i + 1] > 191
                OR $out_bytes[$i + 2] < 128
                OR $out_bytes[$i + 2] > 191
                OR ($b = 224 AND $out_bytes[$i + 1] < 160)
                OR ($b = 237 AND $out_bytes[$i + 1] >= 160)
            {
                THROW "UTILS_INVALID_URI_ENCODING";
            };
        };

        IF $b >= 240 AND $b <= 244 {
            IF $i + 3 >= $len
                OR $out_bytes[$i + 1] < 128
                OR $out_bytes[$i + 1] > 191
                OR $out_bytes[$i + 2] < 128
                OR $out_bytes[$i + 2] > 191
                OR $out_bytes[$i + 3] < 128
                OR $out_bytes[$i + 3] > 191
                OR ($b = 240 AND $out_bytes[$i + 1] < 144)
                OR ($b = 244 AND $out_bytes[$i + 1] >= 144)
            {
                THROW "UTILS_INVALID_URI_ENCODING";
            };
        };

        IF $b >= 128 AND $b <= 191 {
            LET $valid_prev1 = $i >= 1
                AND $out_bytes[$i - 1] >= 194
                AND $out_bytes[$i - 1] <= 244;
            LET $valid_prev2 = $i >= 2
                AND $out_bytes[$i - 2] >= 224
                AND $out_bytes[$i - 2] <= 244
                AND $out_bytes[$i - 1] >= 128
                AND $out_bytes[$i - 1] <= 191;
            LET $valid_prev3 = $i >= 3
                AND $out_bytes[$i - 3] >= 240
                AND $out_bytes[$i - 3] <= 244
                AND $out_bytes[$i - 2] >= 128
                AND $out_bytes[$i - 2] <= 191
                AND $out_bytes[$i - 1] >= 128
                AND $out_bytes[$i - 1] <= 191;

            IF !$valid_prev1 AND !$valid_prev2 AND !$valid_prev3 {
                THROW "UTILS_INVALID_URI_ENCODING";
            };
        };
    };

    RETURN <string><bytes>$out_bytes;
}
COMMENT "Décode une chaîne URI encodée en Percent-Encoding RFC 3986 (UTF-8)."
PERMISSIONS FULL;
