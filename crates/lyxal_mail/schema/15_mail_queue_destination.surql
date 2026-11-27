-- SPDX-License-Identifier: AGPL-3.0-only
-- ============================================================================
-- TABLE  : mail_queue_destination
-- MODULE : lyxal_mail
-- RÔLE   : Destination de la file d'envoi : suspension après des échecs de connexion (décision E7)
-- ============================================================================
-- mail_queue_destination:⟨<domaine>⟩ (forme ASCII, minuscules). Quand aucun MX ni aucune adresse
-- n'a répondu, la destination est suspendue 5 min, durée doublée à chaque échec consécutif, 2 h au
-- plus (modèle KumoMTA consecutive_connection_failures_before_delay) ; une réponse de serveur
-- remet le compteur à zéro. Écrite par fn::mail_queue_fail, lue par fn::mail_queue_claim ; compte
-- de service et session système seulement.

DEFINE TABLE OVERWRITE mail_queue_destination
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select, create, update, delete WHERE fn::mail_can({ action: "worker" })
    COMMENT "Destination de la file d'envoi : suspension après des échecs de connexion";

DEFINE FIELD OVERWRITE suspended_until ON TABLE mail_queue_destination TYPE option<datetime> COMMENT "Fin de la suspension en cours";
DEFINE FIELD OVERWRITE consecutive_failures ON TABLE mail_queue_destination TYPE int DEFAULT 0 ASSERT $value >= 0 COMMENT "Échecs de connexion consécutifs";
DEFINE FIELD OVERWRITE last_failure ON TABLE mail_queue_destination TYPE option<object> COMMENT "Dernier échec : { stage, at }";
DEFINE FIELD OVERWRITE last_failure.stage ON TABLE mail_queue_destination TYPE option<string> ASSERT $value IS NONE OR $value IN ["dns", "connect", "tls", "greeting"] COMMENT "Étape";
DEFINE FIELD OVERWRITE last_failure.at ON TABLE mail_queue_destination TYPE option<datetime> COMMENT "Date";
DEFINE FIELD OVERWRITE updated_at ON TABLE mail_queue_destination TYPE datetime VALUE time::now() COMMENT "Dernière modification";

DEFINE INDEX OVERWRITE mail_queue_destination_suspended ON TABLE mail_queue_destination FIELDS suspended_until;
