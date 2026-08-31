-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_secret_generate
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_secret_generate(
    $length: int,
    $prefix: option<string>
) -> string {
    IF $length < 24 OR $length > 256 {
        THROW "SECURITY_INVALID_SECRET_LENGTH";
    };

    LET $secret = rand::id($length);

    RETURN IF $prefix IS NONE OR string::trim($prefix) = "" {
        $secret
    } ELSE {
        string::concat(string::trim($prefix), "_", $secret)
    };
}
COMMENT "
Génère un secret alphanumérique à partir de rand::id. Pour des clés binaires
ou contraintes cryptographiques précises, utiliser le moteur Rust.
"
PERMISSIONS FULL;
