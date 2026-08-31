-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_hmac_headers
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_hmac_headers(
    $headers: object,
    $included_headers: array<string>
) -> string {
    LET $names = array::sort::asc(
        array::map(
            $included_headers,
            |$name| string::lowercase(string::trim($name))
        )
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
COMMENT "Canonise un sous-ensemble d'en-têtes pour une signature HMAC."
PERMISSIONS FULL;
