-- =============================================================================================
-- |
-- | Fichier : credential_type_etag_on_update.surql
-- | Module : integrations > event > credentials
-- | Description : Event pour régénérer l'ETag lors des UPDATE de credential_type.
-- |
-- | Note : Le CREATE est géré par DEFAULT rand::uuid::v7() dans la table.
-- |        Seul l'UPDATE nécessite un EVENT pour régénérer l'ETag.
-- |
-- =============================================================================================

DEFINE EVENT IF NOT EXISTS credential_type_etag_on_update ON TABLE credential_type 
    WHEN $event = "UPDATE" 
    THEN {
        UPDATE $after.id SET 
            etag = rand::uuid::v7()
    }
    COMMENT 'Régénère l\'ETag lors de chaque modification pour détection de changements temps réel.';

