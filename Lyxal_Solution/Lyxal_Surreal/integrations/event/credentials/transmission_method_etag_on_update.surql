-- =====================================================
-- EVENTS
-- =====================================================

DEFINE EVENT IF NOT EXISTS transmission_method_etag_on_update ON TABLE transmission_method 
    WHEN $event = "UPDATE" 
    THEN {
        UPDATE $after.id SET 
            etag = rand::uuid::v7()
    }
    COMMENT 'Régénère l\'ETag et updated_at lors de chaque modification.';