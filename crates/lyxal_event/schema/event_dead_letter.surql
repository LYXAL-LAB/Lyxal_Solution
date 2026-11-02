-- ============================================================================
-- Table: event_dead_letter
-- Description: Destination de mise en quarantaine des livraisons ayant épuisé leurs tentatives
--              ou soumises à une erreur fatale/poison.
-- ============================================================================

DEFINE TABLE OVERWRITE event_dead_letter
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS NONE
    COMMENT "Table de rétention et d'audit pour les livraisons en échec définitif.";

DEFINE FIELD OVERWRITE delivery ON TABLE event_dead_letter TYPE record<event_delivery>
    COMMENT "Référence à la livraison ayant échoué.";

DEFINE FIELD OVERWRITE delivery_id_str ON TABLE event_dead_letter TYPE option<string>
    COMMENT "Identifiant textuel canonique de la livraison d'origine.";

DEFINE FIELD OVERWRITE subscription ON TABLE event_dead_letter TYPE option<record<event_subscription>>
    COMMENT "Référence à l'abonnement ayant rejeté la livraison.";

DEFINE FIELD OVERWRITE outbox_event ON TABLE event_dead_letter TYPE record<event_outbox>
    COMMENT "Référence à l'événement outbox d'origine.";

DEFINE FIELD OVERWRITE target_module ON TABLE event_dead_letter TYPE string
    COMMENT "Module cible concerné par l'échec.";

DEFINE FIELD OVERWRITE context ON TABLE event_dead_letter TYPE option<object> FLEXIBLE
    COMMENT "Contexte d'isolation de l'événement en quarantaine (flexible pour sous-champs instance, ns, db).";

DEFINE FIELD OVERWRITE attempts ON TABLE event_dead_letter TYPE number
    COMMENT "Nombre total de tentatives consommées avant rejet.";

DEFINE FIELD OVERWRITE last_error ON TABLE event_dead_letter TYPE string
    COMMENT "Dernier message d'erreur ou trace diagnostique.";

DEFINE FIELD OVERWRITE payload ON TABLE event_dead_letter TYPE option<object> FLEXIBLE
    COMMENT "Payload métier original de l'événement en quarantaine (schéma arbitraire préservé).";

DEFINE FIELD OVERWRITE metadata ON TABLE event_dead_letter TYPE option<object> FLEXIBLE
    COMMENT "Métadonnées transversales d'audit (flexible pour en-têtes et traçabilité).";

DEFINE FIELD OVERWRITE replayed ON TABLE event_dead_letter TYPE bool DEFAULT false
    COMMENT "Indique si cette dead-letter a été rejouée manuellement ou par politique de replay.";

DEFINE FIELD OVERWRITE replayed_at ON TABLE event_dead_letter TYPE option<datetime>
    COMMENT "Horodatage UTC du rejeu.";

DEFINE FIELD OVERWRITE exhausted_at ON TABLE event_dead_letter TYPE datetime DEFAULT time::now()
    COMMENT "Horodatage UTC auquel le budget de retry a été épuisé.";

DEFINE INDEX OVERWRITE idx_dead_letter_audit ON TABLE event_dead_letter
    COLUMNS exhausted_at, replayed;
