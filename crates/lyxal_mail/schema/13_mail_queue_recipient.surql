-- SPDX-License-Identifier: AGPL-3.0-only
-- ============================================================================
-- TABLE  : mail_queue_recipient
-- MODULE : lyxal_mail
-- RÔLE   : Destinataire en file : unité de la file d'envoi (lot 6, décisions E3, E4)
-- ============================================================================
-- mail_queue_recipient:⟨<clé de l'envoi>_<10^3 + rang>⟩, un par destinataire d'un envoi (modèle :
-- Mox queue.Msg, Stalwart queue::Message). États : scheduled (en attente de son échéance) →
-- running (réservé sous bail par fn::mail_queue_claim, jeton de réservation exigé de toute
-- écriture d'un résultat) → delivered (accepté par le serveur final, ou remis par la route
-- locale), relayed (accepté par un serveur sans DSN avec NOTIFY=SUCCESS), failed (refus
-- définitif), expired (fin de vie de l'envoi), canceled (annulé par l'expéditeur) ; bounced
-- (avis reçu après acceptation). Un bail échu rend le destinataire réservable, sans essai compté.
-- L'échéancier mail_queue_due (secondes programmées), les compteurs de l'envoi et les événements mail.submission.*
-- sont tenus par les événements de la table. Le jeton de réservation n'est lisible que du compte
-- de service. Écritures : compte de service et session système ; création par la clôture d'un
-- dépôt (mail.relay pour un envoi de module) ; annulation par l'expéditeur (garde).

DEFINE TABLE OVERWRITE mail_queue_recipient
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE fn::mail_can({ action: "submission", tenant: tenant, owner: owner, origin: origin })
        FOR create WHERE fn::mail_can({ action: "worker" }) OR (origin = "module" AND fn::mail_can({ action: "relay" }))
        FOR update WHERE fn::mail_can({ action: "submission", tenant: tenant, owner: owner, origin: origin })
        FOR delete WHERE fn::mail_can({ action: "worker" })
    COMMENT "Destinataire en file d'un envoi : état, essais, échéance, bail, dernier résultat";

DEFINE FIELD OVERWRITE tenant ON TABLE mail_queue_recipient TYPE record<auth_organization> REFERENCE ON DELETE CASCADE READONLY COMMENT "Organisation de l'envoi";
DEFINE FIELD OVERWRITE submission ON TABLE mail_queue_recipient TYPE record<mail_submission> REFERENCE ON DELETE CASCADE READONLY COMMENT "Envoi";
DEFINE FIELD OVERWRITE owner ON TABLE mail_queue_recipient TYPE option<record<auth_identity>> READONLY COMMENT "Titulaire de l'envoi, recopié (garde)";
DEFINE FIELD OVERWRITE origin ON TABLE mail_queue_recipient TYPE string READONLY ASSERT $value IN ["submission", "module", "forward", "dsn"] COMMENT "Origine de l'envoi, recopiée (garde)";
DEFINE FIELD OVERWRITE rank ON TABLE mail_queue_recipient TYPE int READONLY ASSERT $value >= 0 AND $value <= 999 COMMENT "Rang du destinataire dans l'envoi";
DEFINE FIELD OVERWRITE address ON TABLE mail_queue_recipient TYPE string READONLY ASSERT string::len($value) >= 3 AND string::len($value) <= 254 COMMENT "Adresse (domaine en minuscules)";
DEFINE FIELD OVERWRITE domain ON TABLE mail_queue_recipient TYPE string READONLY ASSERT string::len($value) <= 253 AND $value == string::lowercase($value) COMMENT "Domaine de routage (forme ASCII, minuscules)";
DEFINE FIELD OVERWRITE local ON TABLE mail_queue_recipient TYPE bool READONLY COMMENT "Domaine de courrier actif de l'installation à la mise en file : route locale (§7)";
DEFINE FIELD OVERWRITE notify ON TABLE mail_queue_recipient TYPE option<array<string>> READONLY COMMENT "NOTIFY (RFC 3461) : [never], ou sous-ensemble de success, failure, delay ; NONE : défaut (failure, delay)";
DEFINE FIELD OVERWRITE orcpt ON TABLE mail_queue_recipient TYPE option<string> READONLY ASSERT $value IS NONE OR string::len($value) <= 500 COMMENT "ORCPT (destinataire d'origine, RFC 3461 §4.2)";

DEFINE FIELD OVERWRITE state ON TABLE mail_queue_recipient
    TYPE string
    DEFAULT "scheduled"
    ASSERT $value IN ["scheduled", "running", "delivered", "relayed", "failed", "expired", "canceled", "bounced"]
    COMMENT "État : scheduled, running (réservé), delivered, relayed, failed, expired, canceled, bounced (avis reçu après acceptation)";

DEFINE FIELD OVERWRITE attempts ON TABLE mail_queue_recipient TYPE int DEFAULT 0 ASSERT $value >= 0 COMMENT "Essais comptés (un bail repris ou un destinataire rendu ne compte pas)";
DEFINE FIELD OVERWRITE next_attempt_at ON TABLE mail_queue_recipient TYPE datetime COMMENT "Échéance du prochain essai (état scheduled)";
DEFINE FIELD OVERWRITE due_second ON TABLE mail_queue_recipient TYPE option<int> VALUE IF state = "scheduled" { time::unix(next_attempt_at) } ELSE { NONE } COMMENT "Seconde Unix de l'échéance d'un destinataire programmé (scheduled), aucune sinon : clé de lecture de l'échéancier mail_queue_due (calculée)";
DEFINE FIELD OVERWRITE locked_until ON TABLE mail_queue_recipient TYPE option<datetime> COMMENT "Fin du bail de réservation (état running)";
DEFINE FIELD OVERWRITE claim ON TABLE mail_queue_recipient
    TYPE option<string>
    PERMISSIONS FOR select WHERE fn::mail_can({ action: "worker" })
    COMMENT "Jeton de la réservation en cours (UUID v7), exigé de toute écriture d'un résultat ; lisible du compte de service seulement";
DEFINE FIELD OVERWRITE claimed_by ON TABLE mail_queue_recipient
    TYPE option<string>
    PERMISSIONS FOR select WHERE fn::mail_can({ action: "worker" })
    ASSERT $value IS NONE OR string::len($value) <= 128
    COMMENT "Nœud qui détient la réservation (journal, mesures)";

DEFINE FIELD OVERWRITE last_result ON TABLE mail_queue_recipient
    TYPE option<object>
    COMMENT "Dernier résultat : { stage, code, enhanced, text (assaini, 512 octets), host, tls { version, verified }, at }";
DEFINE FIELD OVERWRITE last_result.stage ON TABLE mail_queue_recipient TYPE option<string> ASSERT $value IS NONE OR $value IN ["dns", "connect", "tls", "greeting", "mail", "rcpt", "data", "local", "content", "expired", "canceled", "bounce"] COMMENT "Étape";
DEFINE FIELD OVERWRITE last_result.code ON TABLE mail_queue_recipient TYPE option<int> ASSERT $value IS NONE OR ($value >= 200 AND $value <= 599) COMMENT "Code de réponse SMTP";
DEFINE FIELD OVERWRITE last_result.enhanced ON TABLE mail_queue_recipient TYPE option<string> ASSERT $value IS NONE OR string::len($value) <= 16 COMMENT "Code étendu (RFC 3463)";
DEFINE FIELD OVERWRITE last_result.text ON TABLE mail_queue_recipient TYPE option<string> ASSERT $value IS NONE OR string::len($value) <= 512 COMMENT "Texte de la réponse distante, assaini (jamais dans un événement)";
DEFINE FIELD OVERWRITE last_result.host ON TABLE mail_queue_recipient TYPE option<string> ASSERT $value IS NONE OR string::len($value) <= 253 COMMENT "Serveur distant (MX ou relais)";
DEFINE FIELD OVERWRITE last_result.tls ON TABLE mail_queue_recipient TYPE option<object> COMMENT "TLS de la connexion";
DEFINE FIELD OVERWRITE last_result.tls.version ON TABLE mail_queue_recipient TYPE option<string> ASSERT $value IS NONE OR string::len($value) <= 32 COMMENT "Version de TLS";
DEFINE FIELD OVERWRITE last_result.tls.verified ON TABLE mail_queue_recipient TYPE option<bool> COMMENT "Certificat vérifié";
DEFINE FIELD OVERWRITE last_result.at ON TABLE mail_queue_recipient TYPE option<datetime> COMMENT "Date du résultat";

DEFINE FIELD OVERWRITE delayed_at ON TABLE mail_queue_recipient TYPE option<datetime> COMMENT "Premier passage du délai d'avis de retard (publie mail.submission.delayed, une fois)";
DEFINE FIELD OVERWRITE delay_sent ON TABLE mail_queue_recipient TYPE bool DEFAULT false COMMENT "Avis de retard produit (fn::mail_queue_dsn_done)";
DEFINE FIELD OVERWRITE dsn_sent ON TABLE mail_queue_recipient TYPE bool DEFAULT false COMMENT "Avis final produit (échec, remise, relais)";
DEFINE FIELD OVERWRITE final_at ON TABLE mail_queue_recipient TYPE option<datetime> COMMENT "Entrée dans un état final";
DEFINE FIELD OVERWRITE created_at ON TABLE mail_queue_recipient TYPE datetime DEFAULT time::now() READONLY COMMENT "Mise en file";
DEFINE FIELD OVERWRITE updated_at ON TABLE mail_queue_recipient TYPE datetime VALUE time::now() COMMENT "Dernière modification";

DEFINE INDEX OVERWRITE mail_queue_recipient_submission ON TABLE mail_queue_recipient FIELDS submission;
DEFINE INDEX OVERWRITE mail_queue_recipient_state ON TABLE mail_queue_recipient FIELDS state;
-- Réservation (décision E5) : destinataires programmés d'une seconde de l'échéancier (égalité sur
-- un entier : SurrealDB 3.3.4 ne borne une lecture d'index par dates que d'un côté), baux expirés
DEFINE INDEX OVERWRITE mail_queue_recipient_due ON TABLE mail_queue_recipient FIELDS due_second;
DEFINE INDEX OVERWRITE mail_queue_recipient_lease ON TABLE mail_queue_recipient FIELDS state, locked_until;
