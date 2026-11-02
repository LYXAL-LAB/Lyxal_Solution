-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/security/functions/redact_ip.surql
-- Fonction : fn::security_redact_ip
--
-- Masque partiellement une adresse IPv4 ou IPv6.
--
-- Paramètres
--   $value : string
--
-- Valeur renvoyée : string (contrat : crates/lyxal_core/Readme.md, fonctions security)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::security_redact_ip(
    $value: string
) -> string {
    LET $clean = string::trim($value);

    RETURN IF string::contains($clean,":") {
        LET $parts = string::split($clean,":");
        array::join(
            array::map(
                $parts,
                |$part,$index| IF $index < 3 { $part } ELSE { "xxxx" }
            ),
            ":"
        )
    } ELSE {
        LET $parts = string::split($clean,".");
        IF array::len($parts) = 4 {
            string::concat($parts[0],".",$parts[1],".x.x")
        } ELSE {
            "***"
        }
    };
}
COMMENT "Masque partiellement une adresse IPv4 ou IPv6."
PERMISSIONS FULL;
