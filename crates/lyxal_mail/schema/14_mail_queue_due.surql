-- SPDX-License-Identifier: AGPL-3.0-only
-- ============================================================================
-- TABLE  : mail_queue_due
-- MODULE : lyxal_mail
-- RÔLE   : Échéancier ordonné de la file d'envoi (décision E5)
-- ============================================================================
-- SurrealDB 3.3.4 n'applique pas LIMIT au parcours d'un index dans une fonction (décision P1) :
-- la réservation lit une plage d'identifiants bornée de cette vue, de l'origine à l'instant
-- présent. Une fiche par destinataire non final :
-- mail_queue_due:⟨<10^16 + instant en µs>_<clé du destinataire>⟩, sous son échéance (état
-- scheduled) ou sous la fin de son bail (état running, clé refaite à chaque réservation et à
-- chaque renouvellement) : la même plage rend les destinataires échus et ceux dont le bail a
-- expiré après un arrêt brutal. Retirée dans les autres états. Tenue par les événements de
-- mail_queue_recipient seuls ; aucune écriture directe.

DEFINE TABLE OVERWRITE mail_queue_due
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE fn::mail_can({ action: "worker" })
        FOR create, update, delete NONE
    COMMENT "Échéancier ordonné de la file d'envoi, tenu par les événements des destinataires en file";

DEFINE FIELD OVERWRITE recipient ON TABLE mail_queue_due TYPE record<mail_queue_recipient> READONLY COMMENT "Destinataire en file";
DEFINE FIELD OVERWRITE domain ON TABLE mail_queue_due TYPE string READONLY COMMENT "Domaine de routage du destinataire (exclusions et suspensions lues sans relire le destinataire)";
DEFINE FIELD OVERWRITE at ON TABLE mail_queue_due TYPE datetime READONLY COMMENT "Échéance (scheduled) ou fin du bail (running)";
