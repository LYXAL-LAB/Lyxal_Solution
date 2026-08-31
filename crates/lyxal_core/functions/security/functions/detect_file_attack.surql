-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_detect_file_attack
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_detect_file_attack(
    $filename: string,
    $mime: string
) -> object {
    LET $name = string::lowercase(string::trim($filename));
    LET $clean_mime = string::lowercase(string::trim($mime));

    LET $dangerous_extension = string::matches(
        $name,
        "\\.(exe|dll|bat|cmd|com|scr|ps1|vbs|js|jar|msi|php|phtml|sh)$"
    );

    LET $double_extension = string::matches(
        $name,
        "\\.(jpg|jpeg|png|gif|pdf|docx?)\\.(exe|js|php|sh|bat|cmd)$"
    );

    LET $mime_mismatch =
        ($clean_mime = "image/jpeg" AND !string::matches($name,"\\.jpe?g$"))
        OR ($clean_mime = "image/png" AND !string::matches($name,"\\.png$"))
        OR ($clean_mime = "application/pdf" AND !string::matches($name,"\\.pdf$"));

    RETURN {
        detected: $dangerous_extension OR $double_extension OR $mime_mismatch,
        category: "file_attack",
        score:
            (IF $dangerous_extension { 60 } ELSE { 0 })
            + (IF $double_extension { 30 } ELSE { 0 })
            + (IF $mime_mismatch { 20 } ELSE { 0 }),
        dangerous_extension: $dangerous_extension,
        double_extension: $double_extension,
        mime_mismatch: $mime_mismatch
    };
}
COMMENT "Détecte plusieurs anomalies simples sur un nom de fichier et son MIME."
PERMISSIONS FULL;
