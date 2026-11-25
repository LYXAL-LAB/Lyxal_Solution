-- SPDX-License-Identifier: AGPL-3.0-only
-- ============================================================================
-- TABLE  : mail_delivery
-- MODULE : lyxal_mail
-- RÔLE   : Idempotence d'une remise SMTP (décision S8)
-- ============================================================================
-- Une fiche par message remis à un compte, d'identifiant
-- mail_delivery:⟨<clé du compte>_<empreinte>⟩ : l'empreinte (delivery_key, BLAKE3 en
-- hexadécimal, calculée par le service de remise) couvre l'adresse inscrite du destinataire,
-- l'expéditeur de l'enveloppe et les octets reçus. Un expéditeur qui réessaie après un refus
-- temporaire renvoie les mêmes octets : le compte déjà servi est reconnu (fn::mail_delivery_begin)
-- et ne reçoit pas de doublon. Conservée 7 jours, puis purgée par la maintenance
-- (fn::mail_delivery_purge). Ni adresse, ni sujet : l'empreinte ne se renverse pas. La fiche
-- survit à l'effacement du message par son titulaire (un nouvel essai ne le remet pas).

DEFINE TABLE OVERWRITE mail_delivery
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select, create, update, delete WHERE fn::mail_can({ action: "worker" })
    COMMENT "Idempotence d'une remise SMTP : message déjà remis à un compte (7 jours)";

DEFINE FIELD OVERWRITE tenant ON TABLE mail_delivery
    TYPE record<auth_organization>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Organisation du compte";

DEFINE FIELD OVERWRITE account ON TABLE mail_delivery
    TYPE record<mail_account>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Compte servi";

DEFINE FIELD OVERWRITE message ON TABLE mail_delivery
    TYPE record<mail_message>
    READONLY
    COMMENT "Fiche inscrite par la remise (peut avoir été effacée ou déplacée depuis)";

DEFINE FIELD OVERWRITE expires_at ON TABLE mail_delivery
    TYPE datetime
    READONLY
    COMMENT "Fin de conservation (7 jours après la remise)";

DEFINE FIELD OVERWRITE created_at ON TABLE mail_delivery
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT "Remise";

DEFINE INDEX OVERWRITE mail_delivery_expires ON TABLE mail_delivery FIELDS expires_at;
