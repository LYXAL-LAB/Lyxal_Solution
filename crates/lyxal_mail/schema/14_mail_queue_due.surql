-- SPDX-License-Identifier: AGPL-3.0-only
-- ============================================================================
-- TABLE  : mail_queue_due
-- MODULE : lyxal_mail
-- RÔLE   : Échéancier de la file d'envoi, par seconde (décision E5, mesure du sous-lot 6d)
-- ============================================================================
-- SurrealDB 3.3.4 n'applique pas LIMIT au parcours d'un index dans une fonction (décision P1),
-- mais l'applique à une plage d'identifiants. Une fiche par seconde où au moins un destinataire
-- a été programmé : mail_queue_due:⟨<10^10 + seconde Unix>⟩. La réservation lit ces secondes
-- dans l'ordre, par une plage bornée (de l'origine à l'instant présent), puis, pour chacune, les
-- destinataires scheduled de cette seconde par l'index (state, next_attempt_at) : une lecture
-- d'index bornée aux deux bouts ne parcourt que les destinataires de la seconde. Les baux
-- expirés (reprise après un arrêt brutal) se lisent par l'index (state, locked_until).
-- Une fiche est posée par l'événement des destinataires quand un destinataire est programmé
-- dans une seconde qui n'en a pas ; jamais remise à jour ; retirée par la réservation ou la
-- maintenance quand sa seconde, passée depuis plus d'une minute, n'a plus aucun destinataire
-- programmé. Raison : un DELETE coûte environ 1 ms en SurrealDB 3.3.4 dans une base de Lyxal OS
-- (proportionnel au nombre de tables), alors qu'un échéancier d'une fiche par destinataire en
-- retirait une à chaque réservation et à chaque résultat (mesure : README, « Mesure de la
-- réservation »).

DEFINE TABLE OVERWRITE mail_queue_due
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select, delete WHERE fn::mail_can({ action: "worker" })
        FOR create, update NONE
    COMMENT "Échéancier de la file d'envoi : secondes où des destinataires sont programmés, posées par les événements des destinataires en file";

DEFINE FIELD OVERWRITE at ON TABLE mail_queue_due TYPE datetime READONLY COMMENT "Début de la seconde";
