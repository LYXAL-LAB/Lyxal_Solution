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

-- Lecture contrôlée fiche par fiche par une règle allégée (décision P1), même texte sur
-- mail_message, mail_message_date et mail_tombstone (vérifié par le banc plages) : session active et
-- non expirée, sujet actif, session postérieure à son not_before, version des droits du jeton à
-- jour, puis titulaire de la boîte (owner, recopié du compte) dans son organisation active avec
-- mail.mailbox.access, ou compte de service (mail.worker) ; même portée que
-- fn::mail_can({ action: "mailbox" }), lue par chemins sur la session (environ 13 µs par fiche,
-- contre 360 µs pour fn::mail_can). Les permissions du courrier n'exigent aucun niveau
-- d'assurance (banc plages). Les fonctions publiques contrôlent en plus fn::mail_can une fois par
-- appel (dossier, compte ou message visé).

DEFINE TABLE OVERWRITE mail_tombstone
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE type::is_record($auth, "auth_session") AND $auth.state = "active" AND $auth.expires_at > time::now() AND $auth.idle_expires_at > time::now()
            AND ((owner IS NOT NONE AND $auth.identity = owner AND $auth.organization = tenant AND $token.permissions CONTAINS "mail.mailbox.access") OR $token.permissions CONTAINS "mail.worker")
            AND ($auth.identity ?? $auth.application).state = "active"
            AND (($auth.identity ?? $auth.application).not_before IS NONE OR $auth.created_at >= ($auth.identity ?? $auth.application).not_before)
            AND type::is_int($token.pv) AND $token.pv >= ($auth.identity ?? $auth.application).permissions_version
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

DEFINE FIELD OVERWRITE owner ON TABLE mail_tombstone
    TYPE option<record<auth_identity>>
    READONLY
    COMMENT "Titulaire du compte (identité) à l'inscription, recopié de mail_account.identity (garde) : clé du contrôle de lecture par fiche (décision P1) ; jamais changé (le titulaire d'un compte ne change pas ; identité supprimée : compte en suppression)";

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
