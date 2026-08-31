-- ============================================================================
-- EVENT : update_account_timestamp
-- Table  : booking_account
-- Event  : UPDATE
-- Desc   : Horodatage automatique du champ updated_at lors d'une modification
-- ============================================================================

DEFINE EVENT IF NOT EXISTS update_account_timestamp ON TABLE booking_account 
WHEN $before != $after THEN {
    UPDATE $after.id SET updated_at = time::now();
};
