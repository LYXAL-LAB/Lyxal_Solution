-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/security/functions/redact_report.surql
-- Fonction : fn::security_redact_report
--
-- Produit un rapport sans réexposer les valeurs sensibles.
--
-- Paramètres
--   $subject : string
--   $input   : any
--   $output  : any
--   $fields  : array<string>
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions security)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::security_redact_report(
    $subject: string,
    $input: any,
    $output: any,
    $fields: array<string>
) -> object {
    RETURN {
        subject: string::trim($subject),
        changed: $input != $output,
        redacted_fields: array::distinct($fields),
        input_type: type::of($input),
        output_type: type::of($output),
        generated_at: time::now()
    };
}
COMMENT "Produit un rapport sans réexposer les valeurs sensibles."
PERMISSIONS FULL;
