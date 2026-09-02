-- ============================================================================
-- Table: event_dead_letter
-- Description: Destination de mise en quarantaine des livraisons ayant épuisé leurs tentatives.
-- ============================================================================

DEFINE TABLE OVERWRITE event_dead_letter SCHEMAFULL
    COMMENT "Table de rétention et d'audit pour les livraisons en échec définitif.";

DEFINE FIELD OVERWRITE delivery ON TABLE event_dead_letter TYPE record<event_delivery>
    COMMENT "Référence à la livraison ayant échoué.";

DEFINE FIELD OVERWRITE outbox_event ON TABLE event_dead_letter TYPE record<event_outbox>
    COMMENT "Référence à l'événement outbox d'origine.";

DEFINE FIELD OVERWRITE target_module ON TABLE event_dead_letter TYPE string
    COMMENT "Module cible concerné par l'échec.";

DEFINE FIELD OVERWRITE context ON TABLE event_dead_letter TYPE object
    COMMENT "Contexte d'instance capturé lors de l'échec.";

DEFINE FIELD OVERWRITE attempts ON TABLE event_dead_letter TYPE number
    COMMENT "Nombre total de tentatives consommées avant rejet.";

DEFINE FIELD OVERWRITE last_error ON TABLE event_dead_letter TYPE string
    COMMENT "Dernier message d'erreur ou trace diagnostique.";

DEFINE FIELD OVERWRITE payload ON TABLE event_dead_letter TYPE object
    COMMENT "Copie intégrale du payload de l'événement pour inspection/rejeu.";

DEFINE FIELD OVERWRITE metadata ON TABLE event_dead_letter TYPE object DEFAULT {}
    COMMENT "Métadonnées de l'événement d'origine.";

DEFINE FIELD OVERWRITE replayed ON TABLE event_dead_letter TYPE bool DEFAULT false
    COMMENT "Indique si cette dead-letter a été rejouée manuellement ou par politique de replay.";

DEFINE FIELD OVERWRITE replayed_at ON TABLE event_dead_letter TYPE option<datetime>
    COMMENT "Horodatage UTC du rejeu.";

DEFINE FIELD OVERWRITE exhausted_at ON TABLE event_dead_letter TYPE datetime DEFAULT time::now()
    COMMENT "Horodatage UTC auquel le budget de retry a été épuisé.";

DEFINE INDEX OVERWRITE idx_dead_letter_audit ON TABLE event_dead_letter
    COLUMNS exhausted_at, replayed;
