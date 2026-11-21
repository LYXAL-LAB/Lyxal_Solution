-- SPDX-License-Identifier: AGPL-3.0-only
-- ============================================================================
-- TABLE  : mail_message
-- MODULE : lyxal_mail
-- RÔLE   : Messages d'un compte : dossier, UID, numéros de modification, drapeaux, fil, enveloppe
-- ============================================================================
-- Une fiche par message et par dossier (décision M5), d'identifiant ordonné
-- mail_message:⟨<clé du dossier>_<10000000000 + UID>⟩ (décision P1) : une page ou une plage d'UID
-- se lit par une plage d'identifiants bornée (fn::mail_message_key), qui ne parcourt que les fiches
-- rendues, permissions de la table comprises. Une copie est une nouvelle fiche sur le même
-- contenu ; un déplacement inscrit une nouvelle fiche dans le dossier cible (nouvel UID, donc
-- nouvel identifiant) et retire l'ancienne (pierre tombale à la source), dans la même
-- transaction ; email_id (identifiant JMAP) passe de l'une à l'autre. Les drapeaux système
-- sont des booléens ; les mots-clés sont en minuscules et triés (modèle de Mox) ; \Recent n'est pas
-- stocké (IMAP4rev2). Le fil (thread) est fixé à l'inscription et ne change jamais (décision M7).
-- Restent en clair (décision M8) : l'enveloppe, le sujet de base et la structure MIME, facultatifs
-- (un contenu chiffré pour l'utilisateur pourra s'inscrire sans eux) ; ni corps, ni aperçu, ni
-- texte des pièces jointes. Compteurs des dossiers et du compte, pierres tombales et lecteurs du
-- contenu : tenus par les événements (events/mail_guards.surql), quelle que soit l'origine de
-- l'écriture ; une écriture qui ne fait pas avancer le numéro de modification est refusée.

-- Lecture contrôlée fiche par fiche par une règle allégée (décision P1), même texte sur
-- mail_message, mail_message_date et mail_tombstone (vérifié par le banc plages) : session active et
-- non expirée, sujet actif, session postérieure à son not_before, version des droits du jeton à
-- jour, puis titulaire de la boîte (owner, recopié du compte) dans son organisation active avec
-- mail.mailbox.access, ou compte de service (mail.worker) ; même portée que
-- fn::mail_can({ action: "mailbox" }), lue par chemins sur la session (environ 13 µs par fiche,
-- contre 360 µs pour fn::mail_can). Les permissions du courrier n'exigent aucun niveau
-- d'assurance (banc plages). Les fonctions publiques contrôlent en plus fn::mail_can une fois par
-- appel (dossier, compte ou message visé).

DEFINE TABLE OVERWRITE mail_message
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE type::is_record($auth, "auth_session") AND $auth.state = "active" AND $auth.expires_at > time::now() AND $auth.idle_expires_at > time::now()
            AND ((owner IS NOT NONE AND $auth.identity = owner AND $auth.organization = tenant AND $token.permissions CONTAINS "mail.mailbox.access") OR $token.permissions CONTAINS "mail.worker")
            AND ($auth.identity ?? $auth.application).state = "active"
            AND (($auth.identity ?? $auth.application).not_before IS NONE OR $auth.created_at >= ($auth.identity ?? $auth.application).not_before)
            AND type::is_int($token.pv) AND $token.pv >= ($auth.identity ?? $auth.application).permissions_version
        FOR create, update, delete WHERE fn::mail_can({ action: "mailbox", tenant: tenant, account: account })
    COMMENT "Messages d'un compte : dossier, UID, numéros de modification, drapeaux, fil, enveloppe";

DEFINE FIELD OVERWRITE tenant ON TABLE mail_message
    TYPE record<auth_organization>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Organisation du compte";

DEFINE FIELD OVERWRITE account ON TABLE mail_message
    TYPE record<mail_account>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Compte";

DEFINE FIELD OVERWRITE owner ON TABLE mail_message
    TYPE option<record<auth_identity>>
    READONLY
    COMMENT "Titulaire du compte (identité) à l'inscription, recopié de mail_account.identity (garde) : clé du contrôle de lecture par fiche (décision P1) ; jamais changé (le titulaire d'un compte ne change pas ; identité supprimée : compte en suppression)";

DEFINE FIELD OVERWRITE protection ON TABLE mail_message
    TYPE string
    DEFAULT "platform"
    READONLY
    ASSERT $value IN ["platform", "openpgp", "client"]
    COMMENT "Protection du contenu (décision M15), recopiée de mail_content.protection (garde) : une page la rend sans lire le contenu (une lecture et un contrôle de moins par fiche)";

DEFINE FIELD OVERWRITE mailbox ON TABLE mail_message
    TYPE record<mail_mailbox>
    REFERENCE ON DELETE CASCADE
    COMMENT "Dossier (un seul), partie de l'identifiant, jamais changé (garde) ; un dossier qui contient des messages ne se supprime qu'avec son compte";

DEFINE FIELD OVERWRITE content ON TABLE mail_message
    TYPE record<mail_content>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Contenu (partagé par les copies du message dans le compte) ; un contenu n'est supprimé qu'à zéro lecteur, ou avec son compte";

DEFINE FIELD OVERWRITE uid ON TABLE mail_message
    TYPE int
    ASSERT $value >= 1 AND $value <= 4294967295
    COMMENT "UID dans le dossier : strictement croissant, jamais réutilisé ; partie de l'identifiant, jamais changé (garde : un déplacement inscrit une nouvelle fiche)";

DEFINE FIELD OVERWRITE email_id ON TABLE mail_message
    TYPE string
    DEFAULT <string> rand::uuid::v7()
    READONLY
    ASSERT string::len($value) >= 1 AND string::len($value) <= 64
    COMMENT "Identifiant du message pour JMAP (Email.id, UUID v7) : nouveau à l'inscription et à la copie, gardé par un déplacement";

DEFINE FIELD OVERWRITE modseq ON TABLE mail_message
    TYPE int
    ASSERT $value >= 1
    COMMENT "Numéro de modification du dernier changement (MODSEQ), pris dans le compteur du compte";

DEFINE FIELD OVERWRITE create_modseq ON TABLE mail_message
    TYPE int
    READONLY
    ASSERT $value >= 1
    COMMENT "Numéro de modification de l'inscription";

DEFINE FIELD OVERWRITE thread ON TABLE mail_message
    TYPE string
    READONLY
    ASSERT string::len($value) >= 1 AND string::len($value) <= 64
    COMMENT "Fil (UUID v7), fixé à l'inscription, jamais changé ni fusionné (JMAP threadId)";

DEFINE FIELD OVERWRITE thread_orphan ON TABLE mail_message
    TYPE bool
    DEFAULT false
    READONLY
    COMMENT "Réponse inscrite sans qu'aucun ancêtre ne soit trouvé dans le compte : fil à part (limite connue)";

DEFINE FIELD OVERWRITE received_at ON TABLE mail_message
    TYPE datetime
    READONLY
    ASSERT $value >= d"1970-01-01T00:00:00Z"
    COMMENT "Date interne (INTERNALDATE IMAP, receivedAt JMAP), postérieure à 1970 (clé de la vue par date, mail_message_date)";

DEFINE FIELD OVERWRITE sent_at ON TABLE mail_message
    TYPE option<datetime>
    READONLY
    COMMENT "Date de l'en-tête Date";

DEFINE FIELD OVERWRITE size ON TABLE mail_message
    TYPE int
    READONLY
    ASSERT $value >= 0
    COMMENT "Taille du message en clair, en octets (celle du contenu)";

DEFINE FIELD OVERWRITE seen ON TABLE mail_message TYPE bool DEFAULT false COMMENT "\\Seen ($seen)";
DEFINE FIELD OVERWRITE answered ON TABLE mail_message TYPE bool DEFAULT false COMMENT "\\Answered ($answered)";
DEFINE FIELD OVERWRITE flagged ON TABLE mail_message TYPE bool DEFAULT false COMMENT "\\Flagged ($flagged)";
DEFINE FIELD OVERWRITE deleted ON TABLE mail_message TYPE bool DEFAULT false COMMENT "\\Deleted (à effacer)";
DEFINE FIELD OVERWRITE draft ON TABLE mail_message TYPE bool DEFAULT false COMMENT "\\Draft ($draft)";

DEFINE FIELD OVERWRITE keywords ON TABLE mail_message
    TYPE array<string>
    DEFAULT []
    ASSERT array::len($value) <= 1000
    COMMENT "Mots-clés (IMAP, JMAP), en minuscules, triés et sans doublon ; libellés compris";

DEFINE FIELD OVERWRITE message_id ON TABLE mail_message
    TYPE option<string>
    READONLY
    ASSERT $value IS NONE OR string::len($value) <= 2048
    COMMENT "Message-ID sans chevrons (rattachement des fils)";

DEFINE FIELD OVERWRITE base_subject ON TABLE mail_message
    TYPE option<string>
    READONLY
    ASSERT $value IS NONE OR string::len($value) <= 16384
    COMMENT "Sujet de base (RFC 5256 §2.1)";

DEFINE FIELD OVERWRITE has_attachment ON TABLE mail_message
    TYPE bool
    DEFAULT false
    READONLY
    COMMENT "Le message porte au moins une pièce jointe";

DEFINE FIELD OVERWRITE envelope ON TABLE mail_message
    TYPE option<object>
    READONLY
    COMMENT "Enveloppe (IMAP ENVELOPE, JMAP) : date, sujet, adresses, Message-ID, In-Reply-To, References ; facultative";

DEFINE FIELD OVERWRITE envelope.date ON TABLE mail_message TYPE option<datetime> COMMENT "En-tête Date";
DEFINE FIELD OVERWRITE envelope.subject ON TABLE mail_message TYPE option<string> ASSERT $value IS NONE OR string::len($value) <= 16384 COMMENT "Sujet décodé";
DEFINE FIELD OVERWRITE envelope.message_id ON TABLE mail_message TYPE option<string> ASSERT $value IS NONE OR string::len($value) <= 2048 COMMENT "Message-ID sans chevrons";
DEFINE FIELD OVERWRITE envelope.in_reply_to ON TABLE mail_message TYPE option<array<string>> ASSERT $value IS NONE OR array::len($value) <= 100 COMMENT "In-Reply-To, sans chevrons";
DEFINE FIELD OVERWRITE envelope.in_reply_to[*] ON TABLE mail_message TYPE string ASSERT string::len($value) <= 2048;
DEFINE FIELD OVERWRITE envelope.references ON TABLE mail_message TYPE option<array<string>> ASSERT $value IS NONE OR array::len($value) <= 1000 COMMENT "References, sans chevrons, du plus ancien au plus récent";
DEFINE FIELD OVERWRITE envelope.references[*] ON TABLE mail_message TYPE string ASSERT string::len($value) <= 2048;

DEFINE FIELD OVERWRITE envelope.from ON TABLE mail_message TYPE option<array<object>> ASSERT $value IS NONE OR array::len($value) <= 1000 COMMENT "Adresses de From (1 000 au plus)";
DEFINE FIELD OVERWRITE envelope.from[*] ON TABLE mail_message TYPE object;
DEFINE FIELD OVERWRITE envelope.from[*].name ON TABLE mail_message TYPE option<string> ASSERT $value IS NONE OR string::len($value) <= 2048;
DEFINE FIELD OVERWRITE envelope.from[*].address ON TABLE mail_message TYPE option<string> ASSERT $value IS NONE OR string::len($value) <= 2048;
DEFINE FIELD OVERWRITE envelope.from[*].group ON TABLE mail_message TYPE option<string> ASSERT $value IS NONE OR string::len($value) <= 2048;

DEFINE FIELD OVERWRITE envelope.sender ON TABLE mail_message TYPE option<array<object>> ASSERT $value IS NONE OR array::len($value) <= 1000 COMMENT "Adresses de Sender (1 000 au plus)";
DEFINE FIELD OVERWRITE envelope.sender[*] ON TABLE mail_message TYPE object;
DEFINE FIELD OVERWRITE envelope.sender[*].name ON TABLE mail_message TYPE option<string> ASSERT $value IS NONE OR string::len($value) <= 2048;
DEFINE FIELD OVERWRITE envelope.sender[*].address ON TABLE mail_message TYPE option<string> ASSERT $value IS NONE OR string::len($value) <= 2048;
DEFINE FIELD OVERWRITE envelope.sender[*].group ON TABLE mail_message TYPE option<string> ASSERT $value IS NONE OR string::len($value) <= 2048;

DEFINE FIELD OVERWRITE envelope.reply_to ON TABLE mail_message TYPE option<array<object>> ASSERT $value IS NONE OR array::len($value) <= 1000 COMMENT "Adresses de Reply-To (1 000 au plus)";
DEFINE FIELD OVERWRITE envelope.reply_to[*] ON TABLE mail_message TYPE object;
DEFINE FIELD OVERWRITE envelope.reply_to[*].name ON TABLE mail_message TYPE option<string> ASSERT $value IS NONE OR string::len($value) <= 2048;
DEFINE FIELD OVERWRITE envelope.reply_to[*].address ON TABLE mail_message TYPE option<string> ASSERT $value IS NONE OR string::len($value) <= 2048;
DEFINE FIELD OVERWRITE envelope.reply_to[*].group ON TABLE mail_message TYPE option<string> ASSERT $value IS NONE OR string::len($value) <= 2048;

DEFINE FIELD OVERWRITE envelope.to ON TABLE mail_message TYPE option<array<object>> ASSERT $value IS NONE OR array::len($value) <= 1000 COMMENT "Adresses de To (1 000 au plus)";
DEFINE FIELD OVERWRITE envelope.to[*] ON TABLE mail_message TYPE object;
DEFINE FIELD OVERWRITE envelope.to[*].name ON TABLE mail_message TYPE option<string> ASSERT $value IS NONE OR string::len($value) <= 2048;
DEFINE FIELD OVERWRITE envelope.to[*].address ON TABLE mail_message TYPE option<string> ASSERT $value IS NONE OR string::len($value) <= 2048;
DEFINE FIELD OVERWRITE envelope.to[*].group ON TABLE mail_message TYPE option<string> ASSERT $value IS NONE OR string::len($value) <= 2048;

DEFINE FIELD OVERWRITE envelope.cc ON TABLE mail_message TYPE option<array<object>> ASSERT $value IS NONE OR array::len($value) <= 1000 COMMENT "Adresses de Cc (1 000 au plus)";
DEFINE FIELD OVERWRITE envelope.cc[*] ON TABLE mail_message TYPE object;
DEFINE FIELD OVERWRITE envelope.cc[*].name ON TABLE mail_message TYPE option<string> ASSERT $value IS NONE OR string::len($value) <= 2048;
DEFINE FIELD OVERWRITE envelope.cc[*].address ON TABLE mail_message TYPE option<string> ASSERT $value IS NONE OR string::len($value) <= 2048;
DEFINE FIELD OVERWRITE envelope.cc[*].group ON TABLE mail_message TYPE option<string> ASSERT $value IS NONE OR string::len($value) <= 2048;

DEFINE FIELD OVERWRITE envelope.bcc ON TABLE mail_message TYPE option<array<object>> ASSERT $value IS NONE OR array::len($value) <= 1000 COMMENT "Adresses de Bcc (1 000 au plus)";
DEFINE FIELD OVERWRITE envelope.bcc[*] ON TABLE mail_message TYPE object;
DEFINE FIELD OVERWRITE envelope.bcc[*].name ON TABLE mail_message TYPE option<string> ASSERT $value IS NONE OR string::len($value) <= 2048;
DEFINE FIELD OVERWRITE envelope.bcc[*].address ON TABLE mail_message TYPE option<string> ASSERT $value IS NONE OR string::len($value) <= 2048;
DEFINE FIELD OVERWRITE envelope.bcc[*].group ON TABLE mail_message TYPE option<string> ASSERT $value IS NONE OR string::len($value) <= 2048;

DEFINE FIELD OVERWRITE structure ON TABLE mail_message
    TYPE option<object> FLEXIBLE
    READONLY
    COMMENT "Structure MIME (types, paramètres, noms de fichiers, tailles, lignes, positions dans le fichier) produite par lyxal_mail_proto, profondeur et nombre de parties bornés ; facultative";

DEFINE FIELD OVERWRITE created_at ON TABLE mail_message
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT "Création";

DEFINE FIELD OVERWRITE updated_at ON TABLE mail_message
    TYPE datetime
    VALUE time::now()
    COMMENT "Dernière modification";

DEFINE INDEX OVERWRITE mail_message_uid ON TABLE mail_message FIELDS mailbox, uid UNIQUE;
DEFINE INDEX OVERWRITE mail_message_deleted ON TABLE mail_message FIELDS mailbox, deleted;
DEFINE INDEX OVERWRITE mail_message_mailbox_modseq ON TABLE mail_message FIELDS mailbox, modseq;
DEFINE INDEX OVERWRITE mail_message_seen ON TABLE mail_message FIELDS mailbox, seen;
DEFINE INDEX OVERWRITE mail_message_account_modseq ON TABLE mail_message FIELDS account, modseq;
DEFINE INDEX OVERWRITE mail_message_thread ON TABLE mail_message FIELDS account, thread;
DEFINE INDEX OVERWRITE mail_message_message_id ON TABLE mail_message FIELDS account, message_id;
DEFINE INDEX OVERWRITE mail_message_content ON TABLE mail_message FIELDS content;
