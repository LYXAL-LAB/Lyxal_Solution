-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/security/functions/audit_chain.surql
-- Fonction : fn::security_audit_chain
--
-- Construit une chaîne d'audit complète.
--
-- Paramètres
--   $events : array<object>
--
-- Valeur renvoyée : array<object> (contrat : crates/lyxal_core/Readme.md, fonctions security)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::security_audit_chain(
    $events: array<object>
) -> array<object> {
    RETURN array::fold(
        $events,
        [],
        |$entries,$event| {
            LET $previous_hash = IF array::len($entries)=0 {
                NONE
            } ELSE {
                $entries[array::len($entries)-1].entry_hash
            };

            array::append(
                $entries,
                fn::security_audit_entry($event,$previous_hash)
            )
        }
    );
}
COMMENT "Construit une chaîne d'audit complète."
PERMISSIONS FULL;
