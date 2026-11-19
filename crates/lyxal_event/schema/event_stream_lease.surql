-- ============================================================================
-- Table: event_stream_lease
-- Description: Baux des chefs des événements (Leadership & Fencing), un par hôte :
--              identifiant event_stream_lease:<hôte>.
-- ============================================================================

DEFINE TABLE OVERWRITE event_stream_lease
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS NONE
    COMMENT "Baux des chefs des événements, un par hôte (event_stream_lease:<hôte>) : génération monotone (fencing), propriétaire, échéance.";

DEFINE FIELD OVERWRITE host ON TABLE event_stream_lease TYPE string
    ASSERT string::matches($value, "^[a-z][a-z0-9_]{0,63}$")
    COMMENT "Hôte servi par ce bail (égal à l'identifiant de l'enregistrement).";

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

