-- SPDX-License-Identifier: AGPL-3.0-only
-- ============================================================================
-- TABLE  : mail_content
-- MODULE : lyxal_mail
-- RÔLE   : Contenu d'un message : le fichier .eml rangé par lyxal_storage
-- ============================================================================
-- Un contenu par compte (décision M14) ; les copies d'un message dans le même compte partagent
-- le même contenu (refs : nombre de messages qui le lisent, tenu par les événements). États :
-- pending (réservé par fn::mail_content_begin, fichier en cours d'écriture), stored (fichier
-- disponible dans le bucket chiffré lyxal-mail de l'organisation), released (plus aucun message
-- ne le lit : retiré avec son fichier par la maintenance). Le champ protection dit qui peut lire le
-- contenu (décision M15) : platform (niveau A, le serveur), seul accepté au lot 4 ; openpgp et
-- client sont réservés. La clé du fichier n'est jamais ici : elle est scellée dans la fiche de
-- lyxal_storage.

DEFINE TABLE OVERWRITE mail_content
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select, create WHERE fn::mail_can({ action: "mailbox", tenant: tenant, account: account })
        FOR update, delete WHERE fn::mail_can({ action: "worker" })
    COMMENT "Contenu d'un message : le fichier .eml rangé par lyxal_storage";

DEFINE FIELD OVERWRITE tenant ON TABLE mail_content
    TYPE record<auth_organization>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Organisation du compte";

DEFINE FIELD OVERWRITE account ON TABLE mail_content
    TYPE record<mail_account>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Compte";

DEFINE FIELD OVERWRITE key ON TABLE mail_content
    TYPE string
    READONLY
    ASSERT string::len($value) >= 1 AND string::len($value) <= 512
    COMMENT "Clé du fichier dans le bucket lyxal-mail : <clé du compte>/<UUID v7>.eml (aucune donnée personnelle)";

DEFINE FIELD OVERWRITE object ON TABLE mail_content
    TYPE option<record<storage_object>>
    REFERENCE
    COMMENT "Fiche du fichier dans lyxal_storage, posée à l'état stored ; le fichier ne se supprime pas tant que ce contenu existe";

DEFINE FIELD OVERWRITE state ON TABLE mail_content
    TYPE string
    DEFAULT "pending"
    ASSERT $value IN ["pending", "stored", "released"]
    COMMENT "État : pending, stored, released";

DEFINE FIELD OVERWRITE size ON TABLE mail_content
    TYPE int
    READONLY
    ASSERT $value >= 0 AND $value <= 5368709120
    COMMENT "Taille du message en clair, en octets";

DEFINE FIELD OVERWRITE protection ON TABLE mail_content
    TYPE string
    DEFAULT "platform"
    READONLY
    ASSERT $value IN ["platform", "openpgp", "client"]
    COMMENT "Qui lit le contenu : platform (niveau A, seul accepté au lot 4), openpgp et client réservés (niveaux B et C)";

DEFINE FIELD OVERWRITE key_fingerprint ON TABLE mail_content
    TYPE option<string>
    READONLY
    ASSERT $value IS NONE OR string::len($value) <= 128
    COMMENT "Empreinte de la clé de l'utilisateur (niveaux B et C) ; aucune au lot 4";

DEFINE FIELD OVERWRITE refs ON TABLE mail_content
    TYPE int
    DEFAULT 0
    PERMISSIONS FOR update WHERE fn::mail_can({ action: "worker" })
    COMMENT "Nombre de messages qui lisent ce contenu, tenu par les événements ; à zéro, le contenu est libéré";

DEFINE FIELD OVERWRITE expires_at ON TABLE mail_content
    TYPE option<datetime>
    COMMENT "Délai d'abandon d'un contenu qui n'est encore lu par aucun message ; date de libération d'un contenu released";

DEFINE FIELD OVERWRITE created_at ON TABLE mail_content
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT "Création";

DEFINE FIELD OVERWRITE updated_at ON TABLE mail_content
    TYPE datetime
    VALUE time::now()
    COMMENT "Dernière modification";

DEFINE INDEX OVERWRITE mail_content_key ON TABLE mail_content FIELDS key UNIQUE;
DEFINE INDEX OVERWRITE mail_content_state ON TABLE mail_content FIELDS state, expires_at;
DEFINE INDEX OVERWRITE mail_content_account ON TABLE mail_content FIELDS account;
