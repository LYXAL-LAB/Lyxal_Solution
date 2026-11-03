-- ============================================================================
-- Table: event_delivery
-- Description: Unité de distribution et suivi d'état par abonné (Fan-Out persistant & Streaming).
-- ============================================================================

DEFINE TABLE OVERWRITE event_delivery
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS NONE
    COMMENT "Enregistrement de livraison unitaire pour un événement et un abonnement.";

DEFINE FIELD OVERWRITE outbox_event ON TABLE event_delivery TYPE record<event_outbox>
    COMMENT "Référence à l'événement parent dans l'outbox.";

DEFINE FIELD OVERWRITE subscription ON TABLE event_delivery TYPE record<event_subscription>
    COMMENT "Référence à l'abonnement destinataire.";

DEFINE FIELD OVERWRITE target_module ON TABLE event_delivery TYPE string
    COMMENT "Module consommateur cible recevant cette livraison.";

DEFINE FIELD OVERWRITE context ON TABLE event_delivery TYPE object FLEXIBLE
    COMMENT "Contexte d'instance et de base de données hérité de l'événement.";

DEFINE FIELD OVERWRITE context.instance_id ON TABLE event_delivery TYPE string;
DEFINE FIELD OVERWRITE context.namespace ON TABLE event_delivery TYPE string;
DEFINE FIELD OVERWRITE context.database ON TABLE event_delivery TYPE string;

DEFINE FIELD OVERWRITE status ON TABLE event_delivery TYPE string DEFAULT "pending"
    ASSERT $value IN ["pending", "processing", "delivered", "failed", "dead_letter", "dropped"]
    COMMENT "Statut actuel de traitement de la livraison étendu aux états terminaux du Dispatcher.";

DEFINE FIELD OVERWRITE attempts ON TABLE event_delivery TYPE number DEFAULT 0
    COMMENT "Nombre de tentatives de traitement déjà consommées.";


DEFINE FIELD OVERWRITE next_retry_at ON TABLE event_delivery TYPE datetime DEFAULT time::now()
    COMMENT "Horodatage UTC à partir duquel la prochaine tentative est éligible.";

DEFINE FIELD OVERWRITE locked_until ON TABLE event_delivery TYPE option<datetime>
    COMMENT "Horodatage UTC d'expiration du bail de traitement en cours.";

DEFINE FIELD OVERWRITE lease_owner ON TABLE event_delivery TYPE option<string>
    COMMENT "Identifiant du worker détenant actuellement le bail de traitement.";

DEFINE FIELD OVERWRITE last_error ON TABLE event_delivery TYPE option<string>
    COMMENT "Dernier message ou cause d'erreur capturé lors du traitement.";

DEFINE FIELD OVERWRITE delivered_at ON TABLE event_delivery TYPE option<datetime>
    COMMENT "Horodatage UTC du succès et de la livraison finale.";

DEFINE FIELD OVERWRITE delivery_seq ON TABLE event_delivery TYPE option<int>
    COMMENT "Numéro de séquence contigu alloué dans le flux de l'abonnement pour LYXAL Event Engine.";

DEFINE FIELD OVERWRITE dead_letter_ref ON TABLE event_delivery TYPE option<record<event_dead_letter>>
    COMMENT "Référence croisée vers l'enregistrement de quarantaine DLQ.";

DEFINE FIELD OVERWRITE dropped_at ON TABLE event_delivery TYPE option<datetime>
    COMMENT "Horodatage UTC de l'abandon de la livraison (politique Drop explicite).";

DEFINE FIELD OVERWRITE drop_reason ON TABLE event_delivery TYPE option<string>
    COMMENT "Motif explicite et auditable de l'abandon de la livraison.";

DEFINE FIELD OVERWRITE created_at ON TABLE event_delivery TYPE datetime DEFAULT time::now()
    COMMENT "Horodatage UTC de génération de la livraison (fan-out).";

-- Index d'éligibilité pour le claim par lot
DEFINE INDEX OVERWRITE idx_delivery_claim_eligibility ON TABLE event_delivery
    COLUMNS status, next_retry_at;

-- Unicité de distribution strictement (outbox_event, subscription)
DEFINE INDEX OVERWRITE idx_delivery_unique_fanout ON TABLE event_delivery
    COLUMNS outbox_event, subscription UNIQUE;

-- Index de recherche et ordonnancement de séquence par abonnement
DEFINE INDEX OVERWRITE idx_del_seq_sub ON TABLE event_delivery
    COLUMNS subscription, delivery_seq;
