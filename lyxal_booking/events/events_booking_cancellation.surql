-- ============================================================================
-- EVENT : on_booking_cancelled
-- Table  : booking
-- Event  : UPDATE
-- Desc   : Libération automatique des ressources physiques allouées lors de l'annulation d'un rendez-vous
-- ============================================================================

DEFINE EVENT IF NOT EXISTS on_booking_cancelled ON TABLE booking 
WHEN $before.status != 'cancelled' AND $after.status == 'cancelled' THEN {
    -- Supprime les allocations de ressources physiques (salles, matériels)
    DELETE booking_resource_allocation WHERE booking = $after.id;
};
