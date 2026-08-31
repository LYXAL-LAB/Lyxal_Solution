-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_audit_verify
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_audit_verify(
    $entries: array<object>
) -> object {
    LET $results = array::map(
        $entries,
        |$entry,$index| {
            LET $expected_previous = IF $index=0 {
                NONE
            } ELSE {
                $entries[$index-1].entry_hash
            };

            LET $payload = encoding::json::encode($entry.event);
            LET $expected_hash = crypto::sha256(
                string::concat(
                    IF $expected_previous IS NONE{""}ELSE{$expected_previous},
                    ":",
                    $payload
                )
            );

            {
                index:$index,
                valid_previous:$entry.previous_hash=$expected_previous,
                valid_hash:$entry.entry_hash=$expected_hash
            }
        }
    );

    RETURN {
        valid:array::all(
            $results,
            |$result|$result.valid_previous AND $result.valid_hash
        ),
        results:$results
    };
}
COMMENT "Vérifie l'intégrité d'une chaîne d'audit."
PERMISSIONS FULL;
