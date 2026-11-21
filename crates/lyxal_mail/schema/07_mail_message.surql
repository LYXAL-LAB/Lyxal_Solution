-- SPDX-License-Identifier: AGPL-3.0-only
-- ============================================================================
-- TABLE  : mail_message
-- MODULE : lyxal_mail
-- RÔLE   : Messages d'un compte : dossier, UID, numéros de modification, drapeaux, fil, enveloppe
-- ============================================================================
-- Une fiche par message et par dossier (décision M5) ; une copie est une nouvelle fiche sur le
-- même contenu ; un déplacement garde la fiche (même identifiant JMAP), lui donne un nouvel UID
-- dans le dossier cible et laisse une pierre tombale dans le dossier source. Les drapeaux système
-- sont des booléens ; les mots-clés sont en minuscules et triés (modèle de Mox) ; \Recent n'est pas
-- stocké (IMAP4rev2). Le fil (thread) est fixé à l'inscription et ne change jamais (décision M7).
-- Restent en clair (décision M8) : l'enveloppe, le sujet de base et la structure MIME, facultatifs
-- (un contenu chiffré pour l'utilisateur pourra s'inscrire sans eux) ; ni corps, ni aperçu, ni
-- texte des pièces jointes. Compteurs des dossiers et du compte, pierres tombales et lecteurs du
-- contenu : tenus par les événements (events/mail_guards.surql), quelle que soit l'origine de
-- l'écriture ; une écriture qui ne fait pas avancer le numéro de modification est refusée.

DEFINE TABLE OVERWRITE mail_message
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select, create, update, delete WHERE fn::mail_can({ action: "mailbox", tenant: tenant, account: account })
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

DEFINE FIELD OVERWRITE mailbox ON TABLE mail_message
    TYPE record<mail_mailbox>
    REFERENCE ON DELETE CASCADE
    COMMENT "Dossier (un seul) ; un dossier qui contient des messages ne se supprime qu'avec son compte";

DEFINE FIELD OVERWRITE content ON TABLE mail_message
    TYPE record<mail_content>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Contenu (partagé par les copies du message dans le compte) ; un contenu n'est supprimé qu'à zéro lecteur, ou avec son compte";

DEFINE FIELD OVERWRITE uid ON TABLE mail_message
    TYPE int
    ASSERT $value >= 1 AND $value <= 4294967295
    COMMENT "UID dans le dossier : strictement croissant, jamais réutilisé ; nouveau à chaque déplacement";

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
    COMMENT "Date interne (INTERNALDATE IMAP, receivedAt JMAP)";

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
DEFINE INDEX OVERWRITE mail_message_received ON TABLE mail_message FIELDS mailbox, received_at;
DEFINE INDEX OVERWRITE mail_message_mailbox_modseq ON TABLE mail_message FIELDS mailbox, modseq;
DEFINE INDEX OVERWRITE mail_message_seen ON TABLE mail_message FIELDS mailbox, seen;
DEFINE INDEX OVERWRITE mail_message_account_modseq ON TABLE mail_message FIELDS account, modseq;
DEFINE INDEX OVERWRITE mail_message_thread ON TABLE mail_message FIELDS account, thread;
DEFINE INDEX OVERWRITE mail_message_message_id ON TABLE mail_message FIELDS account, message_id;
DEFINE INDEX OVERWRITE mail_message_content ON TABLE mail_message FIELDS content;
