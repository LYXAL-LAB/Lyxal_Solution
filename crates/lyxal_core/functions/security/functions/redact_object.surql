-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_redact_object
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_redact_object(
    $value: object,
    $sensitive_keys: array<string>
) -> object {
    LET $normalized_keys = array::map(
        $sensitive_keys,
        |$key| string::lowercase(string::trim($key))
    );

    RETURN object::from_entries(
        array::map(
            object::entries($value),
            |$entry| [
                $entry[0],
                IF array::contains(
                    $normalized_keys,
                    string::lowercase($entry[0])
                ) {
                    "***REDACTED***"
                } ELSE {
                    $entry[1]
                }
            ]
        )
    );
}
COMMENT "Masque les valeurs des clés sensibles d'un objet de premier niveau."
PERMISSIONS FULL;
