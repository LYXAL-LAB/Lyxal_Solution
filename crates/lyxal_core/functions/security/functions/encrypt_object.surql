-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_encrypt_object
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_encrypt_object(
    $value: object,
    $key_reference: string,
    $algorithm: string,
    $aad: option<string>
) -> object {
    LET $canonical = encoding::json::encode($value);

    RETURN object::extend(
        fn::security_encrypt(
            <bytes>$canonical,
            $key_reference,
            $algorithm,
            IF $aad IS NONE { NONE } ELSE { <bytes>$aad }
        ),
        {
            content_type: "application/json",
            canonical: $canonical
        }
    );
}
COMMENT "Prépare le chiffrement authentifié d'un objet JSON."
PERMISSIONS FULL;
