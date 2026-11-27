-- SPDX-License-Identifier: AGPL-3.0-only
-- ============================================================================
-- EVENTS : lyxal_mail — gardes des écritures et compteurs
-- MODULE : lyxal_mail
-- RÔLE   : Refuser une écriture qui casse un invariant, puis tenir compteurs, pierres tombales et lecteurs des contenus
-- ============================================================================
-- Exécutés dans la transaction de chaque écriture, quelle qu'en soit l'origine (fonctions
-- publiques, écriture directe, suppression en cascade) : les fonctions publiques rendent une
-- erreur lisible, ces gardes sont le dernier rempart (modèle : storage_object_update_guard).
-- Un refus (THROW du code MAIL_*) annule l'écriture. Rien n'est publié ici
-- (events/mail_events.surql) et aucun autre module n'est modifié.

DEFINE EVENT OVERWRITE mail_account_guard ON TABLE mail_account
WHEN $event IN ["CREATE", "UPDATE", "DELETE"]
THEN {
    LET $refusal = fn::mail_write_refusal("mail_account", $before, $after);
    IF $refusal IS NOT NONE { THROW $refusal; };
    fn::mail_counters_apply("mail_account", $before, $after);
};

DEFINE EVENT OVERWRITE mail_domain_guard ON TABLE mail_domain
WHEN $event IN ["CREATE", "UPDATE", "DELETE"]
THEN {
    LET $refusal = fn::mail_write_refusal("mail_domain", $before, $after);
    IF $refusal IS NOT NONE { THROW $refusal; };
};

DEFINE EVENT OVERWRITE mail_address_guard ON TABLE mail_address
WHEN $event IN ["CREATE", "UPDATE", "DELETE"]
THEN {
    LET $refusal = fn::mail_write_refusal("mail_address", $before, $after);
    IF $refusal IS NOT NONE { THROW $refusal; };
    fn::mail_counters_apply("mail_address", $before, $after);
};

DEFINE EVENT OVERWRITE mail_mailbox_guard ON TABLE mail_mailbox
WHEN $event IN ["CREATE", "UPDATE", "DELETE"]
THEN {
    LET $refusal = fn::mail_write_refusal("mail_mailbox", $before, $after);
    IF $refusal IS NOT NONE { THROW $refusal; };
    fn::mail_counters_apply("mail_mailbox", $before, $after);
};

DEFINE EVENT OVERWRITE mail_content_guard ON TABLE mail_content
WHEN $event IN ["CREATE", "UPDATE"]
THEN {
    LET $refusal = fn::mail_write_refusal("mail_content", $before, $after);
    IF $refusal IS NOT NONE { THROW $refusal; };
};

DEFINE EVENT OVERWRITE mail_message_guard ON TABLE mail_message
WHEN $event IN ["CREATE", "UPDATE", "DELETE"]
THEN {
    LET $refusal = fn::mail_write_refusal("mail_message", $before, $after);
    IF $refusal IS NOT NONE { THROW $refusal; };
    fn::mail_counters_apply("mail_message", $before, $after);
};

-- Envoi (lot 6) : gardes des envois et des destinataires en file ; compteurs d'envoi, échéancier
-- ordonné et destinataires ouverts de l'envoi tenus dans la même transaction
DEFINE EVENT OVERWRITE mail_submission_guard ON TABLE mail_submission
WHEN $event IN ["CREATE", "UPDATE", "DELETE"]
THEN {
    LET $refusal = fn::mail_submission_refusal($before, $after);
    IF $refusal IS NOT NONE { THROW $refusal; };
    fn::mail_submission_apply($before, $after);
};

DEFINE EVENT OVERWRITE mail_queue_recipient_guard ON TABLE mail_queue_recipient
WHEN $event IN ["CREATE", "UPDATE", "DELETE"]
THEN {
    LET $refusal = fn::mail_queue_recipient_refusal($before, $after);
    IF $refusal IS NOT NONE { THROW $refusal; };
    fn::mail_queue_recipient_apply($before, $after);
};
