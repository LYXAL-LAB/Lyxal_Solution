-- ============================================================================
-- Table: event_subscription
-- Description: Déclaration des abonnements et des modules consommateurs.
-- ============================================================================

DEFINE TABLE OVERWRITE event_subscription
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS NONE
    COMMENT "Registre des abonnements des modules aux types d'événements.";

DEFINE FIELD OVERWRITE name ON TABLE event_subscription TYPE string
    COMMENT "Nom lisible unique de l'abonnement.";

DEFINE FIELD OVERWRITE target_module ON TABLE event_subscription TYPE string
    COMMENT "Identifiant du module consommateur (ex: lyxal_notification).";

DEFINE FIELD OVERWRITE event_pattern ON TABLE event_subscription TYPE string
    COMMENT "Pattern d'événement écouté (ex: booking.created, booking.*, *).";

DEFINE FIELD OVERWRITE host ON TABLE event_subscription TYPE string
    ASSERT string::matches($value, "^[a-z][a-z0-9_]{0,63}$")
    COMMENT "Hôte propriétaire de l'abonnement : rôle du binaire qui porte son handler (ex: lyxal_server). Seul le chef des événements de cet hôte lit, numérote et solde ses livraisons ; changé seulement par fn::event_subscription_transfer.";

DEFINE FIELD OVERWRITE handler_name ON TABLE event_subscription TYPE string
    COMMENT "Nom de l'opération ou du handler de traitement.";

DEFINE FIELD OVERWRITE is_active ON TABLE event_subscription TYPE bool DEFAULT true
    COMMENT "Indique si l'abonnement est actif et doit recevoir les événements.";

DEFINE FIELD OVERWRITE max_attempts ON TABLE event_subscription TYPE number DEFAULT 5
    COMMENT "Nombre maximal d'essais alloués aux livraisons issues de cet abonnement.";

DEFINE FIELD OVERWRITE created_at ON TABLE event_subscription TYPE datetime DEFAULT time::now()
    COMMENT "Horodatage UTC d'enregistrement de l'abonnement.";

DEFINE INDEX OVERWRITE idx_subscription_lookup ON TABLE event_subscription
    COLUMNS event_pattern, is_active;

DEFINE INDEX OVERWRITE idx_subscription_host ON TABLE event_subscription
    COLUMNS host;

DEFINE INDEX OVERWRITE idx_subscription_name ON TABLE event_subscription
    COLUMNS name UNIQUE;
