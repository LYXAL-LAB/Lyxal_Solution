-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_secret_entropy
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_secret_entropy(
    $secret: string
) -> object {
    LET $alphabet =
        (IF string::matches($secret,"[a-z]"){26}ELSE{0})
        + (IF string::matches($secret,"[A-Z]"){26}ELSE{0})
        + (IF string::matches($secret,"[0-9]"){10}ELSE{0})
        + (IF string::matches($secret,"[^A-Za-z0-9]"){32}ELSE{0});

    LET $bits = IF $alphabet = 0 {
        0f
    } ELSE {
        type::float(string::len($secret))
        * math::log(type::float($alphabet))
        / math::log(2f)
    };

    RETURN {
        estimated_bits: $bits,
        alphabet_size: $alphabet,
        length: string::len($secret),
        heuristic_only: true
    };
}
COMMENT "Estime grossièrement l'entropie à partir des classes de caractères."
PERMISSIONS FULL;
