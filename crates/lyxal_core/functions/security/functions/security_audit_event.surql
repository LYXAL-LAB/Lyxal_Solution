-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_audit_event
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_audit_event(
    $event_type: string,
    $actor: option<string>,
    $subject: string,
    $action: string,
    $outcome: string,
    $metadata: option<object>,
    $occurred_at: datetime
) -> object {
    LET $clean_outcome = string::lowercase(string::trim($outcome));

    IF !array::contains(
        ["success","failure","denied","review"],
        $clean_outcome
    ) {
        THROW "SECURITY_INVALID_AUDIT_OUTCOME";
    };

    RETURN {
        event_id:rand::uuid::v7(),
        event_type:string::lowercase(string::trim($event_type)),
        actor:IF $actor IS NONE{NONE}ELSE{string::trim($actor)},
        subject:string::trim($subject),
        action:string::lowercase(string::trim($action)),
        outcome:$clean_outcome,
        metadata:IF $metadata IS NONE{{}}ELSE{$metadata},
        occurred_at:$occurred_at
    };
}
COMMENT "Construit un événement d'audit Security."
PERMISSIONS FULL;
