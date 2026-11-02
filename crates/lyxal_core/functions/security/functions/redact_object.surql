-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/security/functions/redact_object.surql
-- Fonction : fn::security_redact_object
--
-- Masque les valeurs des clés sensibles d'un objet de premier niveau.
--
-- Paramètres
--   $value          : object
--   $sensitive_keys : array<string>
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions security)
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
                IF (($normalized_keys) CONTAINS (string::lowercase($entry[0]))) {
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
