-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_audit_entry
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_audit_entry(
    $event: object,
    $previous_hash: option<string>
) -> object {
    LET $payload = encoding::json::encode($event);
    LET $chain_input = string::concat(
        IF $previous_hash IS NONE{""}ELSE{$previous_hash},
        ":",
        $payload
    );

    RETURN {
        event:$event,
        previous_hash:$previous_hash,
        entry_hash:crypto::sha256($chain_input),
        created_at:time::now()
    };
}
COMMENT "Construit une entrée d'audit chaînée par hash."
PERMISSIONS FULL;
