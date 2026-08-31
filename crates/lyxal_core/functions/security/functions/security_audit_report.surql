-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_audit_report
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_audit_report(
    $entries: array<object>
) -> object {
    LET $verification = fn::security_audit_verify($entries);

    RETURN {
        entry_count:array::len($entries),
        valid:$verification.valid,
        first_event_at:IF array::len($entries)=0{
            NONE
        }ELSE{
            $entries[0].event.occurred_at
        },
        last_event_at:IF array::len($entries)=0{
            NONE
        }ELSE{
            $entries[array::len($entries)-1].event.occurred_at
        },
        verification:$verification,
        generated_at:time::now()
    };
}
COMMENT "Produit un rapport d'intégrité d'audit."
PERMISSIONS FULL;
