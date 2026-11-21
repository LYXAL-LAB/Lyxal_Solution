-- SPDX-License-Identifier: AGPL-3.0-only
-- ============================================================================
-- TABLE  : mail_message_date
-- MODULE : lyxal_mail
-- RÔLE   : Vue ordonnée des messages d'un dossier par date interne (pages par date)
-- ============================================================================
-- Une fiche par message, d'identifiant ordonné
-- mail_message_date:⟨<clé du dossier>_<10^16 + date interne en µs>_<10^10 + UID>⟩ (décision P1) :
-- une page par date se lit par des plages d'identifiants bornées (fn::mail_message_date_page),
-- qui ne parcourent que les fiches de la fenêtre lue, permissions comprises. Écrite par les
-- événements des messages seuls (création et suppression d'un message) ; aucune écriture directe.

-- Lecture contrôlée fiche par fiche par une règle allégée (décision P1), même texte sur
-- mail_message, mail_message_date et mail_tombstone (vérifié par le banc plages) : session active et
-- non expirée, sujet actif, session postérieure à son not_before, version des droits du jeton à
-- jour, puis titulaire de la boîte (owner, recopié du compte) dans son organisation active avec
-- mail.mailbox.access, ou compte de service (mail.worker) ; même portée que
-- fn::mail_can({ action: "mailbox" }), lue par chemins sur la session (environ 13 µs par fiche,
-- contre 360 µs pour fn::mail_can). Les permissions du courrier n'exigent aucun niveau
-- d'assurance (banc plages). Les fonctions publiques contrôlent en plus fn::mail_can une fois par
-- appel (dossier, compte ou message visé).

DEFINE TABLE OVERWRITE mail_message_date
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE type::is_record($auth, "auth_session") AND $auth.state = "active" AND $auth.expires_at > time::now() AND $auth.idle_expires_at > time::now()
            AND ((owner IS NOT NONE AND $auth.identity = owner AND $auth.organization = tenant AND $token.permissions CONTAINS "mail.mailbox.access") OR $token.permissions CONTAINS "mail.worker")
            AND ($auth.identity ?? $auth.application).state = "active"
            AND (($auth.identity ?? $auth.application).not_before IS NONE OR $auth.created_at >= ($auth.identity ?? $auth.application).not_before)
            AND type::is_int($token.pv) AND $token.pv >= ($auth.identity ?? $auth.application).permissions_version
        FOR create, update, delete NONE
    COMMENT "Vue des messages d'un dossier ordonnée par date interne, tenue par les événements des messages";

DEFINE FIELD OVERWRITE tenant ON TABLE mail_message_date
    TYPE record<auth_organization>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Organisation du compte";

DEFINE FIELD OVERWRITE account ON TABLE mail_message_date
    TYPE record<mail_account>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Compte";

DEFINE FIELD OVERWRITE owner ON TABLE mail_message_date
    TYPE option<record<auth_identity>>
    READONLY
    COMMENT "Titulaire du compte (identité) à l'inscription, recopié de mail_account.identity (garde) : clé du contrôle de lecture par fiche (décision P1) ; jamais changé (le titulaire d'un compte ne change pas ; identité supprimée : compte en suppression)";

DEFINE FIELD OVERWRITE mailbox ON TABLE mail_message_date
    TYPE record<mail_mailbox>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Dossier";

DEFINE FIELD OVERWRITE message ON TABLE mail_message_date
    TYPE record<mail_message>
    READONLY
    COMMENT "Message (retiré avec lui par l'événement de suppression du message)";

DEFINE FIELD OVERWRITE received_at ON TABLE mail_message_date
    TYPE datetime
    READONLY
    COMMENT "Date interne du message";

DEFINE FIELD OVERWRITE uid ON TABLE mail_message_date
    TYPE int
    READONLY
    COMMENT "UID du message dans le dossier";
