-- ============================================================================
-- Table: event_stream_lease
-- Description: Table de coordination distribuée du bail de streaming outbox (Leadership & Fencing).
-- ============================================================================

DEFINE TABLE OVERWRITE event_stream_lease SCHEMAFULL
    COMMENT "Table de coordination distribuée du bail de streaming outbox (Leadership & Fencing).";

DEFINE FIELD OVERWRITE generation ON TABLE event_stream_lease TYPE int
    COMMENT "Numéro de génération monotone strict pour le fencing token.";

DEFINE FIELD OVERWRITE owner_node_id ON TABLE event_stream_lease TYPE string
    COMMENT "Identifiant du nœud détenant actuellement le leadership.";

DEFINE FIELD OVERWRITE acquired_at ON TABLE event_stream_lease TYPE datetime DEFAULT time::now()
    COMMENT "Horodatage UTC d'acquisition initiale du bail.";

DEFINE FIELD OVERWRITE expires_at ON TABLE event_stream_lease TYPE datetime
    COMMENT "Horodatage UTC d'expiration du bail (TTL).";

DEFINE FIELD OVERWRITE last_flushed_at ON TABLE event_stream_lease TYPE datetime DEFAULT time::now()
    COMMENT "Horodatage UTC de la dernière mutation réussie (cible de la garde MVCC de fencing).";

DEFINE FIELD OVERWRITE is_released ON TABLE event_stream_lease TYPE bool DEFAULT false
    COMMENT "Indique si le bail a été explicitement libéré lors d'un arrêt propre du leader.";

