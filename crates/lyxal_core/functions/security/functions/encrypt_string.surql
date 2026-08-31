-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_encrypt_string
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_encrypt_string(
    $value: string,
    $key_reference: string,
    $algorithm: string,
    $aad: option<string>
) -> object {
    RETURN fn::security_encrypt(
        <bytes>$value,
        $key_reference,
        $algorithm,
        IF $aad IS NONE { NONE } ELSE { <bytes>$aad }
    );
}
COMMENT "Prépare le chiffrement authentifié d'une chaîne."
PERMISSIONS FULL;
