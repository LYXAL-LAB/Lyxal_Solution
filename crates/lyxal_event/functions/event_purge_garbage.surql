-- ============================================================================
-- Function: fn::event_purge_garbage
-- Description: Nettoie les événements et livraisons terminés ayant dépassé le délai de rétention.
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::event_purge_garbage(
    $params: object
) {
    LET $retention_days = IF $params.retention_days != NONE { $params.retention_days } ELSE { 7 };
    LET $cutoff = time::now() - duration::from::days($retention_days);

    -- Suppression des livraisons complétées anciennes
    DELETE event_delivery 
    WHERE status = "delivered" 
      AND delivered_at != NONE 
      AND delivered_at < $cutoff;

    -- Suppression des événements outbox déjà ventilés et anciens
    DELETE event_outbox 
    WHERE status = "fanned_out" 
      AND fanned_out_at != NONE 
      AND fanned_out_at < $cutoff;

    RETURN fn::result_ok(true);
} COMMENT "Purge les événements et livraisons archivés selon la politique de rétention";
