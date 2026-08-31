-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_redact_email
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_redact_email(
    $value: string
) -> string {
    LET $parts = string::split(string::trim($value),"@");

    IF array::len($parts) != 2 {
        RETURN "***";
    };

    LET $local = $parts[0];
    LET $domain = $parts[1];

    RETURN string::concat(
        IF string::len($local) <= 2 {
            string::repeat("*",string::len($local))
        } ELSE {
            string::concat(
                string::slice($local,0,1),
                string::repeat("*",string::len($local)-2),
                string::slice($local,string::len($local)-1,string::len($local))
            )
        },
        "@",
        $domain
    );
}
COMMENT "Masque la partie locale d'une adresse email."
PERMISSIONS FULL;
