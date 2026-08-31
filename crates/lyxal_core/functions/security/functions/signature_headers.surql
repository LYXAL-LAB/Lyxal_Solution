-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_signature_headers
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_signature_headers(
    $headers: object,
    $included: array<string>
) -> string {
    LET $names = array::sort::asc(
        array::map($included, |$name| string::lowercase(string::trim($name)))
    );

    RETURN array::join(
        array::map(
            $names,
            |$name| string::concat(
                $name,
                ":",
                string::trim(<string>$headers[$name])
            )
        ),
        "\n"
    );
}
COMMENT "Canonise les en-têtes sélectionnés avant signature."
PERMISSIONS FULL;
