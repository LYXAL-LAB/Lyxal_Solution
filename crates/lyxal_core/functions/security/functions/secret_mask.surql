-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_secret_mask
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_secret_mask(
    $secret: string,
    $visible_start: int,
    $visible_end: int,
    $mask: string
) -> string {
    IF $visible_start < 0 OR $visible_end < 0 {
        THROW "SECURITY_INVALID_SECRET_VISIBILITY";
    };

    LET $length = string::len($secret);
    IF $visible_start + $visible_end >= $length {
        RETURN $secret;
    };

    LET $mask_char = IF string::len($mask) = 0 { "*" } ELSE { string::slice($mask,0,1) };

    RETURN string::concat(
        string::slice($secret,0,$visible_start),
        string::repeat($mask_char,$length-$visible_start-$visible_end),
        string::slice($secret,$length-$visible_end,$length)
    );
}
COMMENT "Masque un secret en conservant ses extrémités."
PERMISSIONS FULL;
