-- ============================================================================
-- LYXAL OS — BOOKING AVAILABILITY OVERRIDES
-- ============================================================================
-- Fichier  : functions/availability/fn_delete_availability_override.surql
-- Fonction : fn::booking_delete_availability_override
-- Version  : 1.0.0
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::booking_delete_availability_override($params: object) {
    LET $id = $params.id;

    DELETE type::thing($id);

    RETURN { deleted: true };
};
