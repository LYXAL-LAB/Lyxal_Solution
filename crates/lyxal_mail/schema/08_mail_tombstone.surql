-- SPDX-License-Identifier: AGPL-3.0-only
-- ============================================================================
-- TABLE  : mail_tombstone
-- MODULE : lyxal_mail
-- RÔLE   : Effacements, pour la synchronisation (QRESYNC VANISHED, JMAP destroyed)
-- ============================================================================
-- Une pierre tombale par message effacé ou déplacé hors d'un dossier, et par dossier supprimé,
-- avec son numéro de modification. Écrites par les événements seuls ; conservées
-- tombstone_retention_days (30 jours par défaut, décision M17), puis purgées par la maintenance,
-- qui avance le plancher du compte (changes_floor).

DEFINE TABLE OVERWRITE mail_tombstone
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE fn::mail_can({ action: "mailbox", tenant: tenant, account: account })
        FOR create, update NONE
        FOR delete WHERE fn::mail_can({ action: "worker" })
    COMMENT "Effacements, pour la synchronisation (QRESYNC VANISHED, JMAP destroyed)";

DEFINE FIELD OVERWRITE tenant ON TABLE mail_tombstone
    TYPE record<auth_organization>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Organisation du compte";

DEFINE FIELD OVERWRITE account ON TABLE mail_tombstone
    TYPE record<mail_account>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Compte";

DEFINE FIELD OVERWRITE kind ON TABLE mail_tombstone
    TYPE string
    READONLY
    ASSERT $value IN ["message", "mailbox"]
    COMMENT "Ce qui a disparu : un message d'un dossier (effacé ou déplacé), ou un dossier";

DEFINE FIELD OVERWRITE mailbox ON TABLE mail_tombstone
    TYPE string
    READONLY
    COMMENT "Identifiant du dossier, en texte (le dossier peut avoir disparu)";

DEFINE FIELD OVERWRITE uid ON TABLE mail_tombstone
    TYPE option<int>
    READONLY
    COMMENT "UID du message dans ce dossier (NONE pour un dossier)";

DEFINE FIELD OVERWRITE object ON TABLE mail_tombstone
    TYPE string
    READONLY
    COMMENT "Identifiant du message ou du dossier disparu, en texte";

DEFINE FIELD OVERWRITE modseq ON TABLE mail_tombstone
    TYPE int
    READONLY
    ASSERT $value >= 1
    COMMENT "Numéro de modification de l'effacement";

DEFINE FIELD OVERWRITE created_at ON TABLE mail_tombstone
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT "Création (point de départ de la conservation)";

DEFINE FIELD OVERWRITE updated_at ON TABLE mail_tombstone
    TYPE datetime
    VALUE time::now()
    COMMENT "Dernière modification";

DEFINE INDEX OVERWRITE mail_tombstone_mailbox ON TABLE mail_tombstone FIELDS mailbox, modseq;
DEFINE INDEX OVERWRITE mail_tombstone_account ON TABLE mail_tombstone FIELDS account, modseq;
DEFINE INDEX OVERWRITE mail_tombstone_created ON TABLE mail_tombstone FIELDS tenant, created_at;
