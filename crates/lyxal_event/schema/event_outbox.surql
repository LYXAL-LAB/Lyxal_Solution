-- ============================================================================
-- Table: event_outbox
-- Description: Enregistrement d'origine et persistance outbox de tout événement émis.
-- ============================================================================

DEFINE TABLE OVERWRITE event_outbox SCHEMAFULL
    COMMENT "Table transactionnelle Outbox stockant les événements bruts publiés.";

DEFINE FIELD OVERWRITE event_id ON TABLE event_outbox TYPE string
    COMMENT "Identifiant unique universel de l'événement (UUIDv7).";

DEFINE FIELD OVERWRITE event_type ON TABLE event_outbox TYPE string
    COMMENT "Nom de domaine qualifié de l'événement (ex: booking.created).";

DEFINE FIELD OVERWRITE version ON TABLE event_outbox TYPE number DEFAULT 1
    COMMENT "Numéro de version du contrat d'événement.";

DEFINE FIELD OVERWRITE producer ON TABLE event_outbox TYPE string
    COMMENT "Identifiant du module émetteur (ex: booking).";

DEFINE FIELD OVERWRITE source ON TABLE event_outbox TYPE option<record>
    COMMENT "Référence à l'enregistrement à l'origine de la mutation (optionnel).";

DEFINE FIELD OVERWRITE context ON TABLE event_outbox TYPE object
    COMMENT "Contexte d'isolation de l'instance (instance_id, namespace, database).";

DEFINE FIELD OVERWRITE context.instance_id ON TABLE event_outbox TYPE string;
DEFINE FIELD OVERWRITE context.namespace ON TABLE event_outbox TYPE string;
DEFINE FIELD OVERWRITE context.database ON TABLE event_outbox TYPE string;

DEFINE FIELD OVERWRITE correlation_id ON TABLE event_outbox TYPE string
    COMMENT "Identifiant de corrélation pour le traçage distribué.";

DEFINE FIELD OVERWRITE causation_id ON TABLE event_outbox TYPE option<string>
    COMMENT "Identifiant de causalité reliant l'événement à son déclencheur parent.";

DEFINE FIELD OVERWRITE payload ON TABLE event_outbox TYPE object
    COMMENT "Données métier de l'événement.";

DEFINE FIELD OVERWRITE metadata ON TABLE event_outbox TYPE object DEFAULT {}
    COMMENT "Métadonnées transversales (acteur, horodatage client, headers).";

DEFINE FIELD OVERWRITE status ON TABLE event_outbox TYPE string DEFAULT "pending"
    ASSERT $value IN ["pending", "fanned_out", "archived"]
    COMMENT "Statut du cycle de vie outbox (pending, fanned_out, archived).";

DEFINE FIELD OVERWRITE created_at ON TABLE event_outbox TYPE datetime DEFAULT time::now()
    COMMENT "Horodatage UTC de création de l'enregistrement outbox.";

DEFINE FIELD OVERWRITE fanned_out_at ON TABLE event_outbox TYPE option<datetime>
    COMMENT "Horodatage UTC auquel le fan-out a été complété avec succès.";

-- Index d'unicité et de recherche
DEFINE INDEX OVERWRITE idx_outbox_event_id ON TABLE event_outbox
    COLUMNS event_id UNIQUE;

DEFINE INDEX OVERWRITE idx_outbox_pending_fanout ON TABLE event_outbox
    COLUMNS status, created_at;
