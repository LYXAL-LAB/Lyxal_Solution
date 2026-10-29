-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_optimizer_order
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_optimizer_order(
    $pipeline: array<object>
) -> array<object> {
    LET $weights = {
        permission_check:10,
        detect_file:20,
        detect_payload:30,
        redact_object:40,
        redact_log:50,
        redact_email:60,
        redact_phone:60,
        redact_card:60,
        redact_secret:60
    };

    LET $weighted = array::map(
        $pipeline,
        |$step| object::extend(
            $step,
            {
                _weight: IF $weights[$step.rule] IS NONE {
                    100
                } ELSE {
                    $weights[$step.rule]
                }
            }
        )
    );

    RETURN array::fold(
        $weighted,
        [],
        |$acc, $item| {
            LET $before = array::filter($acc, |$x| $x._weight <= $item._weight);
            LET $after  = array::filter($acc, |$x| $x._weight > $item._weight);
            array::concat(array::append($before, $item), $after)
        }
    );
}
COMMENT "Ordonne les étapes Security selon un ordre canonique."
PERMISSIONS FULL;
