-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_audit_chain
-- Version  : 1.0.0
-- Statut   : Stable
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
