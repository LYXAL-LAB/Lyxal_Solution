-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/security/functions/secret_mask.surql
-- Fonction : fn::security_secret_mask
--
-- Masque un secret en conservant ses extrémités.
--
-- Paramètres
--   $secret        : string
--   $visible_start : int
--   $visible_end   : int
--   $mask          : string
--
-- Valeur renvoyée : string (contrat : crates/lyxal_core/Readme.md, fonctions security)
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $visible_start < 0 OR $visible_end < 0
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::security_secret_mask(
    $secret: string,
    $visible_start: int,
    $visible_end: int,
    $mask: string
) -> string {
    IF $visible_start < 0 OR $visible_end < 0 {
        THROW "CORE_INVALID_ARGUMENT";
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
