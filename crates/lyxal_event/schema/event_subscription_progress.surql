-- ============================================================================
-- Table: event_subscription_progress
-- Description: Progression séquentielle persistée et curseur contigu d'acquittement par abonnement.
-- ============================================================================

DEFINE TABLE OVERWRITE event_subscription_progress
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS NONE
    COMMENT "Progression séquentielle persistée et curseur contigu d'acquittement par abonnement.";

DEFINE FIELD OVERWRITE subscription ON TABLE event_subscription_progress TYPE record<event_subscription>
    COMMENT "Référence à l'abonnement supervisé.";

DEFINE FIELD OVERWRITE partition ON TABLE event_subscription_progress TYPE int DEFAULT 0
    COMMENT "Partition de l'abonnement (défaut 0).";

DEFINE FIELD OVERWRITE last_assigned_seq ON TABLE event_subscription_progress TYPE int DEFAULT 0
    COMMENT "Dernier numéro de séquence contigu alloué à une livraison pour cet abonnement.";

DEFINE FIELD OVERWRITE last_persisted_cursor ON TABLE event_subscription_progress TYPE int DEFAULT 0
    COMMENT "Dernier numéro de séquence contigu durci et acquitté (curseur contigu sûr).";

DEFINE FIELD OVERWRITE updated_at ON TABLE event_subscription_progress TYPE datetime DEFAULT time::now()
    COMMENT "Horodatage UTC de la dernière mise à jour de la progression.";

DEFINE INDEX OVERWRITE idx_sub_progress_partition ON TABLE event_subscription_progress
    COLUMNS subscription, partition UNIQUE;

