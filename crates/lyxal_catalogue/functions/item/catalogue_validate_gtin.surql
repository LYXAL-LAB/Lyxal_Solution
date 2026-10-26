-- ============================================================================
-- FONCTION : fn::catalogue_validate_gtin
-- MODULE   : lyxal_catalogue
-- RÔLE     : Validation stricte de conformité GS1 pour codes-barres (GTIN-8, 12, 13, 14)
--            Vérifie la clé de contrôle finale selon l'algorithme officiel GS1 Modulo 10
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::catalogue_validate_gtin($gtin: string) {
    IF $gtin == NONE OR !string::is_numeric($gtin) {
        RETURN false;
    };

    LET $len = string::len($gtin);
    IF !($len = 8 OR $len = 12 OR $len = 13 OR $len = 14) {
        RETURN false;
    };

    LET $last_digit = <int> string::slice($gtin, $len - 1, $len);
    LET $indices = <array> (0..($len - 1));

    LET $terms = (
        SELECT VALUE 
            (<int> string::slice($gtin, $this, $this + 1)) * (IF ((($len - 1) - $this) % 2) = 1 { 3 } ELSE { 1 })
        FROM $indices
    );

    LET $sum = math::sum($terms);
    LET $calculated_check = (10 - ($sum % 10)) % 10;

    RETURN $calculated_check = $last_digit;
} COMMENT "Valide un code GTIN/EAN (8, 12, 13, 14 chiffres) selon l'algorithme officiel GS1 Modulo 10";
