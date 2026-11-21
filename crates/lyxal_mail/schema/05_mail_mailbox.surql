-- SPDX-License-Identifier: AGPL-3.0-only
-- ============================================================================
-- TABLE  : mail_mailbox
-- MODULE : lyxal_mail
-- RÔLE   : Dossiers d'un compte
-- ============================================================================
-- Un message appartient à un seul dossier (décision M5, modèle de Mox). Un dossier porte son
-- chemin complet (délimiteur « / »), son rôle SPECIAL-USE (RFC 6154), son UIDVALIDITY (tirée du
-- compteur du compte : un dossier recréé sous un ancien nom en reçoit une plus grande), et ses
-- compteurs tenus par les événements des messages (total, non lus, volume, prochain UID, plus haut
-- numéro de modification de ses messages). UID et UIDVALIDITY tiennent sur 32 bits non signés.
-- Lus et écrits par le seul titulaire du compte (et le compte de service) : l'administrateur de
-- l'organisation ne voit pas les dossiers (décision M11). Les six dossiers du compte sont créés
-- par l'événement de création du compte.

DEFINE TABLE OVERWRITE mail_mailbox
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select, create, update, delete WHERE fn::mail_can({ action: "mailbox", tenant: tenant, account: account })
    COMMENT "Dossiers d'un compte";

DEFINE FIELD OVERWRITE tenant ON TABLE mail_mailbox
    TYPE record<auth_organization>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Organisation du compte";

DEFINE FIELD OVERWRITE account ON TABLE mail_mailbox
    TYPE record<mail_account>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Compte";

DEFINE FIELD OVERWRITE parent ON TABLE mail_mailbox
    TYPE option<record<mail_mailbox>>
    COMMENT "Dossier parent (NONE : premier niveau) ; un dossier qui a des sous-dossiers ne se supprime pas";

DEFINE FIELD OVERWRITE name ON TABLE mail_mailbox
    TYPE string
    ASSERT string::len($value) >= 1 AND string::len($value) <= 255 AND !string::contains($value, "/")
    COMMENT "Nom du dossier (segment du chemin, sans « / »)";

DEFINE FIELD OVERWRITE path ON TABLE mail_mailbox
    TYPE string
    ASSERT string::len($value) >= 1 AND string::len($value) <= 1024
    COMMENT "Chemin complet, segments séparés par « / » (INBOX pour la boîte de réception)";

DEFINE FIELD OVERWRITE role ON TABLE mail_mailbox
    TYPE option<string>
    ASSERT $value IS NONE OR $value IN ["inbox", "drafts", "sent", "junk", "trash", "archive"]
    COMMENT "Rôle SPECIAL-USE (RFC 6154) et rôle JMAP : un dossier par rôle et par compte";

DEFINE FIELD OVERWRITE subscribed ON TABLE mail_mailbox
    TYPE bool
    DEFAULT true
    COMMENT "Abonnement IMAP";

DEFINE FIELD OVERWRITE sort_order ON TABLE mail_mailbox
    TYPE int
    DEFAULT 0
    ASSERT $value >= 0 AND $value <= 2147483647
    COMMENT "Ordre d'affichage (JMAP sortOrder)";

DEFINE FIELD OVERWRITE uid_validity ON TABLE mail_mailbox
    TYPE int
    READONLY
    ASSERT $value >= 1 AND $value <= 4294967295
    COMMENT "UIDVALIDITY, tirée du compteur du compte à la création ; gardée au renommage";

DEFINE FIELD OVERWRITE uid_next ON TABLE mail_mailbox
    TYPE int
    DEFAULT 1
    ASSERT $value >= 1 AND $value <= 4294967296
    PERMISSIONS FOR update WHERE fn::mail_can({ action: "worker" })
    COMMENT "Prochain UID ; ne diminue jamais (UID jamais réutilisés tant que l'UIDVALIDITY reste)";

DEFINE FIELD OVERWRITE modseq ON TABLE mail_mailbox
    TYPE int
    ASSERT $value >= 1
    COMMENT "Numéro de modification du dernier changement du dossier lui-même (création, nom, parent, rôle, abonnement, ordre)";

DEFINE FIELD OVERWRITE highest_modseq ON TABLE mail_mailbox
    TYPE int
    ASSERT $value >= 0
    PERMISSIONS FOR update WHERE fn::mail_can({ action: "worker" })
    COMMENT "Plus haut numéro de modification des messages du dossier, effacements compris (HIGHESTMODSEQ)";

DEFINE FIELD OVERWRITE received_min ON TABLE mail_mailbox
    TYPE option<datetime>
    PERMISSIONS FOR update WHERE fn::mail_can({ action: "worker" })
    COMMENT "Plus ancienne date interne inscrite dans le dossier (jamais avancée par un effacement), tenue par les événements : borne de la lecture par date (fn::mail_message_date_page)";

DEFINE FIELD OVERWRITE received_max ON TABLE mail_mailbox
    TYPE option<datetime>
    PERMISSIONS FOR update WHERE fn::mail_can({ action: "worker" })
    COMMENT "Plus récente date interne inscrite dans le dossier (jamais reculée par un effacement), tenue par les événements";

DEFINE FIELD OVERWRITE total ON TABLE mail_mailbox
    TYPE int
    DEFAULT 0
    PERMISSIONS FOR update WHERE fn::mail_can({ action: "worker" })
    COMMENT "Nombre de messages, tenu par les événements";

DEFINE FIELD OVERWRITE unseen ON TABLE mail_mailbox
    TYPE int
    DEFAULT 0
    PERMISSIONS FOR update WHERE fn::mail_can({ action: "worker" })
    COMMENT "Nombre de messages non lus, tenu par les événements";

DEFINE FIELD OVERWRITE size ON TABLE mail_mailbox
    TYPE int
    DEFAULT 0
    PERMISSIONS FOR update WHERE fn::mail_can({ action: "worker" })
    COMMENT "Volume des messages, en octets, tenu par les événements";

DEFINE FIELD OVERWRITE created_at ON TABLE mail_mailbox
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT "Création";

DEFINE FIELD OVERWRITE updated_at ON TABLE mail_mailbox
    TYPE datetime
    VALUE time::now()
    COMMENT "Dernière modification";

DEFINE INDEX OVERWRITE mail_mailbox_path ON TABLE mail_mailbox FIELDS account, path UNIQUE;
DEFINE INDEX OVERWRITE mail_mailbox_role ON TABLE mail_mailbox FIELDS account, role UNIQUE;
DEFINE INDEX OVERWRITE mail_mailbox_parent ON TABLE mail_mailbox FIELDS account, parent;
