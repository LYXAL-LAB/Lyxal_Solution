-- =====================================================
-- ÉVÉNEMENTS ET TRIGGERS
-- =====================================================

-- Mise à jour automatique du timestamp
DEFINE EVENT update_timestamp ON sale_order_line_type 
    WHEN $event = "UPDATE" 
    THEN (UPDATE $this SET updated_on = time::now());
