-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_redact_ip
-- Version  : 1.0.0
-- Statut   : Stable
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
