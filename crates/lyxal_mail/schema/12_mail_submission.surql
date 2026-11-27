-- SPDX-License-Identifier: AGPL-3.0-only
-- ============================================================================
-- TABLE  : mail_submission
-- MODULE : lyxal_mail
-- RÔLE   : Envoi : un message déposé pour la file d'envoi (lot 6, décision E3)
-- ============================================================================
-- mail_submission:s<UUID v7 en hexadécimal, sans tirets> (clé ordonnée par le temps). Origines : submission (dépôt authentifié d'un compte), module
-- (contrat public de dépôt des autres modules, §12), forward (transfert d'un alias vers
-- l'extérieur, §13), dsn (avis de non-remise envoyé à l'extérieur, §10.2). États : pending
-- (réservé par fn::mail_submission_begin, fichier en écriture) → queued (fn::mail_submission_commit :
-- destinataires en file) → done (tous ses destinataires dans un état final, tenu par les
-- événements de mail_queue_recipient). Contenu : fichier chiffré du bucket lyxal-mail de
-- l'organisation (clé queue/<clé de l'envoi>.eml), supprimé par la maintenance après la fin de l'envoi ;
-- préfixe (en-têtes DKIM-Signature, Received) rangé en base, lisible du compte de service seul.
-- Jeton de l'adresse de retour (rp=<jeton>@<domaine>, §11) tiré par le worker, unique, valable
-- 14 jours après la fin de l'envoi. Lecture : titulaire (dépôt authentifié), mail.relay (envois des
-- modules), compte de service ; jamais un administrateur d'organisation (décision M11).
-- Compteurs d'envoi (mail_send_counter) pris par l'événement de création, rendus à l'abandon.

DEFINE TABLE OVERWRITE mail_submission
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE fn::mail_can({ action: "submission", tenant: tenant, owner: owner, origin: origin })
        FOR create WHERE fn::mail_can({ action: "submit", tenant: tenant, origin: origin })
        FOR update WHERE fn::mail_can({ action: "submission", tenant: tenant, owner: owner, origin: origin })
        FOR delete WHERE fn::mail_can({ action: "worker" })
    COMMENT "Envoi : message déposé pour la file d'envoi (dépôt authentifié, module, transfert, avis)";

DEFINE FIELD OVERWRITE tenant ON TABLE mail_submission
    TYPE record<auth_organization>
    REFERENCE ON DELETE CASCADE
    READONLY
    COMMENT "Organisation de l'envoi (celle du compte, ou du domaine de l'expéditeur)";

DEFINE FIELD OVERWRITE origin ON TABLE mail_submission
    TYPE string
    READONLY
    ASSERT $value IN ["submission", "module", "forward", "dsn"]
    COMMENT "Origine : submission (dépôt authentifié), module (contrat public de dépôt), forward (transfert d'alias), dsn (avis de non-remise vers l'extérieur)";

DEFINE FIELD OVERWRITE account ON TABLE mail_submission
    TYPE option<record<mail_account>>
    READONLY
    COMMENT "Compte expéditeur d'un dépôt authentifié (NONE pour les autres origines)";

DEFINE FIELD OVERWRITE owner ON TABLE mail_submission
    TYPE option<record<auth_identity>>
    READONLY
    COMMENT "Titulaire du compte expéditeur, recopié du compte (garde) : clé de la lecture par fiche";

DEFINE FIELD OVERWRITE sender ON TABLE mail_submission
    TYPE option<string>
    READONLY
    ASSERT $value IS NONE OR (string::len($value) >= 3 AND string::len($value) <= 254 AND $value == string::lowercase($value))
    COMMENT "Adresse d'expéditeur annoncée (MAIL FROM, minuscules) ; NONE : expéditeur vide (<>)";

DEFINE FIELD OVERWRITE header_from ON TABLE mail_submission
    TYPE array<string>
    READONLY
    ASSERT array::len($value) >= 1 AND array::len($value) <= 10 AND array::all($value, |$a| string::len($a) <= 254 AND $a == string::lowercase($a))
    COMMENT "Adresses des champs From (et Sender, Resent-*) contrôlées au dépôt (1 à 10, minuscules)";

DEFINE FIELD OVERWRITE envelope_from ON TABLE mail_submission
    TYPE option<string>
    PERMISSIONS FOR update WHERE fn::mail_can({ action: "worker" })
    ASSERT $value IS NONE OR string::len($value) <= 254
    COMMENT "Adresse d'enveloppe utilisée à l'envoi : adresse de retour à jeton (rp=<jeton>@<domaine>), posée par le worker à la préparation ; NONE : expéditeur vide, ou pas encore préparé";

DEFINE FIELD OVERWRITE return_token ON TABLE mail_submission
    TYPE option<string>
    PERMISSIONS FOR select, update WHERE fn::mail_can({ action: "worker" })
    ASSERT $value IS NONE OR string::len($value) = 26
    COMMENT "Jeton de l'adresse de retour (26 caractères en base 32 de Crockford, 128 bits tirés par OsRng dans lyxal-groupware), unique ; retiré par la maintenance à son échéance";

DEFINE FIELD OVERWRITE return_expires_at ON TABLE mail_submission
    TYPE option<datetime>
    PERMISSIONS FOR update WHERE fn::mail_can({ action: "worker" })
    COMMENT "Fin de validité de l'adresse de retour (fin de vie de l'envoi + 14 jours, puis fin de l'envoi + 14 jours)";

DEFINE FIELD OVERWRITE client_reference ON TABLE mail_submission
    TYPE option<string>
    READONLY
    ASSERT $value IS NONE OR (string::len($value) >= 1 AND string::len($value) <= 128)
    COMMENT "Référence opaque d'un module appelant (1 à 128 caractères, jamais une adresse), rendue dans les événements mail.submission.*";

DEFINE FIELD OVERWRITE content ON TABLE mail_submission
    TYPE object
    PERMISSIONS FOR update WHERE fn::mail_can({ action: "worker" }) OR fn::mail_can({ action: "relay" })
    COMMENT "Contenu : { key (queue/<clé de l'envoi>.eml, bucket lyxal-mail de l'organisation), size (octets en clair), object (fiche lyxal_storage, posée à la clôture), removed_at (fichier supprimé par la maintenance) }";

DEFINE FIELD OVERWRITE content.key ON TABLE mail_submission TYPE string ASSERT string::starts_with($value, "queue/") AND string::len($value) <= 512 COMMENT "Clé du fichier dans le bucket lyxal-mail";
DEFINE FIELD OVERWRITE content.size ON TABLE mail_submission TYPE int ASSERT $value >= 1 AND $value <= 5368709120 COMMENT "Taille annoncée du message, en octets";
DEFINE FIELD OVERWRITE content.object ON TABLE mail_submission TYPE option<record<storage_object>> COMMENT "Fiche du fichier écrit (clôture)";
DEFINE FIELD OVERWRITE content.removed_at ON TABLE mail_submission TYPE option<datetime> COMMENT "Fichier supprimé par la maintenance";

DEFINE FIELD OVERWRITE prefix ON TABLE mail_submission
    TYPE option<string>
    PERMISSIONS FOR select, update WHERE fn::mail_can({ action: "worker" })
    ASSERT $value IS NONE OR string::len($value) <= 16384
    COMMENT "En-têtes ajoutés devant le fichier à l'envoi (DKIM-Signature ; 16 Kio au plus, modèle Mox MsgPrefix), posés par le worker ; lisibles du compte de service seulement";

DEFINE FIELD OVERWRITE prepared_at ON TABLE mail_submission
    TYPE option<datetime>
    PERMISSIONS FOR update WHERE fn::mail_can({ action: "worker" })
    COMMENT "Préparation faite (jeton de retour, signature, préfixe) : au dépôt pour un transfert ou un avis, à la première réservation par le worker sinon (fn::mail_queue_prepare)";

DEFINE FIELD OVERWRITE smtputf8 ON TABLE mail_submission TYPE bool DEFAULT false READONLY COMMENT "L'envoi exige SMTPUTF8 (adresses ou en-têtes UTF-8)";
DEFINE FIELD OVERWRITE eight_bit ON TABLE mail_submission TYPE bool DEFAULT false READONLY COMMENT "Le contenu a des octets 8 bits (8BITMIME exigé)";

DEFINE FIELD OVERWRITE dsn ON TABLE mail_submission
    TYPE object
    READONLY
    COMMENT "Demande d'avis (RFC 3461) : { ret (hdrs par défaut, ou full), envid (100 caractères au plus) }";
DEFINE FIELD OVERWRITE dsn.ret ON TABLE mail_submission TYPE string DEFAULT "hdrs" ASSERT $value IN ["hdrs", "full"] COMMENT "Partie du message rendue dans un avis : en-têtes (hdrs) ou message entier (full)";
DEFINE FIELD OVERWRITE dsn.envid ON TABLE mail_submission TYPE option<string> ASSERT $value IS NONE OR string::len($value) <= 100 COMMENT "Identifiant de l'envoi donné par l'expéditeur (ENVID, xtext décodé)";

DEFINE FIELD OVERWRITE require_tls ON TABLE mail_submission
    TYPE option<bool>
    READONLY
    COMMENT "Réservé au lot 7 (REQUIRETLS, RFC 8689) ; toujours NONE au lot 6";

DEFINE FIELD OVERWRITE forward ON TABLE mail_submission
    TYPE option<object>
    READONLY
    COMMENT "Transfert seulement : réception d'origine, pour l'avis à son expéditeur (§10.2)";
DEFINE FIELD OVERWRITE forward.envelope_from ON TABLE mail_submission TYPE option<string> ASSERT $value IS NONE OR string::len($value) <= 254 COMMENT "Adresse d'enveloppe d'origine (NONE : expéditeur vide)";
DEFINE FIELD OVERWRITE forward.spf ON TABLE mail_submission TYPE option<string> ASSERT $value IS NONE OR $value IN ["none", "neutral", "pass", "fail", "softfail", "temperror", "permerror"] COMMENT "SPF de la réception d'origine (identité MAIL FROM)";
DEFINE FIELD OVERWRITE forward.envelope_dkim ON TABLE mail_submission TYPE option<bool> COMMENT "Vrai si une signature DKIM valide porte le domaine de l'adresse d'enveloppe d'origine ou son domaine d'organisation";

DEFINE FIELD OVERWRITE pending_recipients ON TABLE mail_submission
    TYPE array<object>
    DEFAULT []
    PERMISSIONS FOR update WHERE fn::mail_can({ action: "worker" }) OR fn::mail_can({ action: "relay" })
    ASSERT array::len($value) <= 1000
    COMMENT "Destinataires annoncés au dépôt ({ address, domain, notify, orcpt }), en attente de la clôture qui les met en file ; vidé à la clôture";
DEFINE FIELD OVERWRITE pending_recipients[*] ON TABLE mail_submission TYPE object COMMENT "Destinataire annoncé";
DEFINE FIELD OVERWRITE pending_recipients[*].address ON TABLE mail_submission TYPE string ASSERT string::len($value) <= 254 COMMENT "Adresse (domaine en minuscules)";
DEFINE FIELD OVERWRITE pending_recipients[*].domain ON TABLE mail_submission TYPE string ASSERT string::len($value) <= 253 AND $value == string::lowercase($value) COMMENT "Domaine (forme ASCII, minuscules)";
DEFINE FIELD OVERWRITE pending_recipients[*].notify ON TABLE mail_submission TYPE option<array<string>> COMMENT "NOTIFY (never, ou success, failure, delay) ; NONE : défaut";
DEFINE FIELD OVERWRITE pending_recipients[*].orcpt ON TABLE mail_submission TYPE option<string> COMMENT "ORCPT (destinataire d'origine)";

DEFINE FIELD OVERWRITE state ON TABLE mail_submission
    TYPE string
    DEFAULT "pending"
    PERMISSIONS FOR update WHERE fn::mail_can({ action: "worker" }) OR fn::mail_can({ action: "relay" })
    ASSERT $value IN ["pending", "queued", "done"]
    COMMENT "État : pending (fichier en écriture), queued (destinataires en file), done (tous finis, tenu par les événements)";

DEFINE FIELD OVERWRITE recipient_count ON TABLE mail_submission
    TYPE int
    READONLY
    ASSERT $value >= 1 AND $value <= 1000
    COMMENT "Nombre de destinataires";

DEFINE FIELD OVERWRITE open_count ON TABLE mail_submission
    TYPE int
    DEFAULT 0
    PERMISSIONS FOR update WHERE fn::mail_can({ action: "worker" })
    COMMENT "Destinataires en file dans un état non final, tenu par les événements de mail_queue_recipient";

DEFINE FIELD OVERWRITE aborted_at ON TABLE mail_submission
    TYPE option<datetime>
    COMMENT "Dépôt abandonné avant la clôture (fn::mail_submission_abort) : compteurs d'envoi rendus, envoi et fichier retirés par la maintenance";

DEFINE FIELD OVERWRITE created_at ON TABLE mail_submission TYPE datetime DEFAULT time::now() READONLY COMMENT "Dépôt";
DEFINE FIELD OVERWRITE pending_expires_at ON TABLE mail_submission TYPE datetime READONLY COMMENT "Fin du délai de clôture (dépôt + 1 h) : un envoi pending non clos est retiré par la maintenance";
DEFINE FIELD OVERWRITE expires_at ON TABLE mail_submission
    TYPE datetime
    PERMISSIONS FOR update WHERE fn::mail_can({ action: "worker" })
    COMMENT "Fin de vie en file (dépôt + expire_hours) : un destinataire non remis expire (4.4.7) ; avancée ou reculée par l'exploitation seulement";
DEFINE FIELD OVERWRITE queued_at ON TABLE mail_submission
    TYPE option<datetime>
    PERMISSIONS FOR update WHERE fn::mail_can({ action: "worker" }) OR fn::mail_can({ action: "relay" })
    COMMENT "Clôture : destinataires mis en file";
DEFINE FIELD OVERWRITE done_at ON TABLE mail_submission
    TYPE option<datetime>
    PERMISSIONS FOR update WHERE fn::mail_can({ action: "worker" })
    COMMENT "Fin : tous les destinataires dans un état final";
DEFINE FIELD OVERWRITE updated_at ON TABLE mail_submission TYPE datetime VALUE time::now() COMMENT "Dernière modification";

DEFINE INDEX OVERWRITE mail_submission_return_token ON TABLE mail_submission FIELDS return_token UNIQUE;
DEFINE INDEX OVERWRITE mail_submission_state ON TABLE mail_submission FIELDS state, done_at;
DEFINE INDEX OVERWRITE mail_submission_pending ON TABLE mail_submission FIELDS state, pending_expires_at;
DEFINE INDEX OVERWRITE mail_submission_return_expires ON TABLE mail_submission FIELDS return_expires_at;
