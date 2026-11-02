-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/security/functions/hmac_headers.surql
-- Fonction : fn::security_hmac_headers
--
-- Canonise un sous-ensemble d'en-têtes pour une signature HMAC.
--
-- Paramètres
--   $headers          : object
--   $included_headers : array<string>
--
-- Valeur renvoyée : string (contrat : crates/lyxal_core/Readme.md, fonctions security)
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
