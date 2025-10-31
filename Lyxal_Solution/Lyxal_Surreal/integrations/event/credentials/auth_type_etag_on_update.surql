-- =====================================================
-- EVENTS
-- =====================================================

DEFINE EVENT IF NOT EXISTS auth_type_etag_on_update ON TABLE auth_type 
    WHEN $event = "UPDATE" 
    THEN {
        UPDATE $after.id SET 
            etag = rand::uuid::v7()
    }
    COMMENT 'Régénère l\'ETag et updated_at lors de chaque modification.';