-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_secret_strength
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_secret_strength(
    $secret: string
) -> object {
    LET $length = string::len($secret);
    LET $classes =
        (IF string::matches($secret,"[a-z]"){1}ELSE{0})
        + (IF string::matches($secret,"[A-Z]"){1}ELSE{0})
        + (IF string::matches($secret,"[0-9]"){1}ELSE{0})
        + (IF string::matches($secret,"[^A-Za-z0-9]"){1}ELSE{0});

    LET $score =
        (IF $length >= 12 { 1 } ELSE { 0 })
        + (IF $length >= 20 { 1 } ELSE { 0 })
        + (IF $classes >= 3 { 1 } ELSE { 0 })
        + (IF $classes = 4 { 1 } ELSE { 0 });

    RETURN {
        score: $score,
        level: IF $score <= 1 {"weak"} ELSE IF $score = 2 {"medium"} ELSE IF $score = 3 {"strong"} ELSE {"very_strong"},
        length: $length,
        character_classes: $classes
    };
}
COMMENT "
Produit un indicateur heuristique de robustesse ; ce n'est pas une estimation
cryptographique complète.
"
PERMISSIONS FULL;
