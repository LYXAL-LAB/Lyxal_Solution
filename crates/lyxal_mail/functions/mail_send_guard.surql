-- SPDX-License-Identifier: AGPL-3.0-only
-- ============================================================================
-- FONCTIONS : gardes et effets des écritures de l'envoi (lot 6)
-- MODULE    : lyxal_mail
-- ============================================================================
-- Appelées par les événements de events/mail_guards.surql, dans la transaction de chaque
-- écriture des envois et des destinataires en file, quelle qu'en soit l'origine. Un événement
-- s'exécute avec les droits de la base mais voit l'identité de l'appelant : la garde refuse ce
-- qui casserait un invariant (THROW du code rendu) ; les effets tiennent les compteurs d'envoi,
-- l'échéancier par seconde (mail_queue_due) et le compte des destinataires ouverts de l'envoi.

-- ----------------------------------------------------------------------------
-- fn::mail_queue_worker_writer (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_queue_worker_writer() -> bool {
    RETURN $auth IS NONE OR (($token.permissions ?? []) CONTAINS "mail.worker");
} COMMENT "Interne : vrai si l'écriture en cours vient de la session système ou d'un compte de service (mail.worker dans le jeton). Lue par la garde des destinataires en file, après les permissions de la table (fn::mail_can complet, qui a déjà refusé une session invalide ou sans droit) : contrôle allégé, une fois par écriture, sans relire la session (environ 0,5 ms de moins par destinataire réservé, mesure du lot 6c)";

-- ----------------------------------------------------------------------------
-- fn::mail_address_send_refusal (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_address_send_refusal($previous: any, $next: object) -> option<string> {
    IF $previous IS NONE {
        LET $local = fn::mail_local_part_refusal($next.domain, $next.local_part);
        IF $local IS NOT NONE { RETURN $local; };
    };
    IF $next.kind = "account" {
        RETURN IF array::len($next.senders) > 0 OR array::len($next.forward_to) > 0 { "MAIL_WRITE_FORBIDDEN" } ELSE { NONE };
    };
    -- Alias : comptes vivants de l'organisation dans senders ; adresses extérieures dans forward_to
    IF $previous IS NONE OR $previous.senders != $next.senders {
        LET $valid = (SELECT VALUE id FROM array::distinct($next.senders) WHERE tenant = $next.tenant AND state != "deleting");
        IF array::len($valid) != array::len($next.senders) { RETURN "MAIL_ALIAS_TARGET_INVALID"; };
    };
    IF $previous IS NONE OR $previous.forward_to != $next.forward_to {
        LET $domains = array::map($next.forward_to, |$a| array::last(string::split($a, "@")));
        IF array::len(array::distinct($next.forward_to)) != array::len($next.forward_to)
            OR array::len(SELECT VALUE id FROM mail_domain WHERE name IN $domains LIMIT 1) > 0 { RETURN "MAIL_ALIAS_TARGET_INVALID"; };
    };
    RETURN NONE;
} COMMENT "Interne : garde d'une adresse pour l'envoi ($previous, $next) : partie locale réservée (rp=, MAIL_ADDRESS_RESERVED) ou expéditeur des modules du domaine (MAIL_MODULE_SENDER_CONFLICT) refusée à la création ; senders et forward_to vides pour une adresse de compte ; alias : senders parmi les comptes vivants de l'organisation, forward_to distincts et hors des domaines de l'installation (MAIL_ALIAS_TARGET_INVALID)";

-- ----------------------------------------------------------------------------
-- fn::mail_submission_refusal (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_submission_refusal($previous: any, $next: any) -> option<string> {
    IF $next IS NONE { RETURN NONE; };
    IF $previous IS NONE {
        IF $next.state != "pending" OR $next.open_count != 0 OR $next.queued_at IS NOT NONE OR $next.done_at IS NOT NONE OR $next.aborted_at IS NOT NONE
            OR $next.content.object IS NOT NONE OR $next.content.removed_at IS NOT NONE
            OR $next.content.key != string::concat("queue/", <string> record::id($next.id), ".eml")
            OR $next.recipient_count != array::len($next.pending_recipients) OR $next.require_tls IS NOT NONE { RETURN "MAIL_WRITE_FORBIDDEN"; };
        -- Préparation (jeton, préfixe, adresse de retour) : par le worker, sauf transfert et avis
        -- déposés par le compte de service
        LET $prepared = $next.prepared_at IS NOT NONE OR $next.return_token IS NOT NONE OR $next.prefix IS NOT NONE OR $next.envelope_from IS NOT NONE;
        IF $prepared AND ($next.origin IN ["submission", "module"] OR !fn::mail_can({ action: "worker" })) { RETURN "MAIL_WRITE_FORBIDDEN"; };
        IF ($next.forward IS NOT NONE) != ($next.origin = "forward") OR ($next.client_reference IS NOT NONE AND $next.origin != "module") { RETURN "MAIL_WRITE_FORBIDDEN"; };
        IF $next.origin = "submission" {
            -- Hors compte de service : l'envoi est celui du compte de la session, jamais d'un autre
            IF !fn::mail_can({ action: "worker" }) AND ($next.account IS NONE OR $next.account != fn::mail_session_account(NONE)) { RETURN "MAIL_WRITE_FORBIDDEN"; };
            LET $account = IF $next.account IS NONE { NONE } ELSE { (SELECT tenant, identity, state FROM ONLY $next.account) };
            IF $account == NONE OR $account.tenant != $next.tenant OR $account.identity IS NONE OR $account.identity != $next.owner OR $account.state != "active" { RETURN "MAIL_WRITE_FORBIDDEN"; };
            RETURN IF array::all(fn::mail_sender_allowed($next.tenant, $next.account, array::concat([$next.sender ?? ""], $next.header_from)), |$ok| $ok) { NONE } ELSE { "MAIL_SENDER_FORBIDDEN" };
        };
        IF $next.account IS NOT NONE OR $next.owner IS NOT NONE { RETURN "MAIL_WRITE_FORBIDDEN"; };
        IF $next.origin = "module" {
            RETURN IF $next.sender IS NOT NONE AND array::all(array::concat([$next.sender], $next.header_from), |$a| fn::mail_module_sender_tenant($a) = $next.tenant) { NONE } ELSE { "MAIL_SENDER_FORBIDDEN" };
        };
        RETURN IF ($next.origin = "dsn") != ($next.sender IS NONE) { "MAIL_WRITE_FORBIDDEN" } ELSE { NONE };
    };
    -- États : pending → queued (fichier lié, non abandonné) → done (aucun destinataire ouvert)
    LET $allowed = { pending: ["pending", "queued"], queued: ["queued", "done"], done: ["done"] }[$previous.state];
    IF $next.state NOTINSIDE $allowed { RETURN "MAIL_SUBMISSION_STATE_INVALID"; };
    IF $previous.state = "pending" AND $next.state = "queued" AND ($next.content.object IS NONE OR $next.aborted_at IS NOT NONE OR $next.queued_at IS NONE OR array::len($next.pending_recipients) > 0) { RETURN "MAIL_WRITE_FORBIDDEN"; };
    IF $next.state = "done" AND $previous.state != "done" AND $next.open_count != 0 { RETURN "MAIL_WRITE_FORBIDDEN"; };
    -- Abandon : une fois, avant la clôture ; préparation : une fois
    IF $previous.aborted_at IS NOT NONE AND $next.aborted_at != $previous.aborted_at { RETURN "MAIL_WRITE_FORBIDDEN"; };
    IF $next.aborted_at IS NOT NONE AND $previous.aborted_at IS NONE AND $previous.state != "pending" { RETURN "MAIL_SUBMISSION_STATE_INVALID"; };
    IF $previous.prepared_at IS NOT NONE AND $next.prepared_at != $previous.prepared_at { RETURN "MAIL_WRITE_FORBIDDEN"; };
    IF $previous.content.object IS NOT NONE AND $next.content.object != $previous.content.object { RETURN "MAIL_WRITE_FORBIDDEN"; };
    RETURN IF $next.content.key != $previous.content.key OR $next.content.size != $previous.content.size OR $next.open_count < 0 { "MAIL_WRITE_FORBIDDEN" } ELSE { NONE };
} COMMENT "Interne : garde d'une écriture d'un envoi ($previous, $next) : à la création, état pending sans compteur ni fichier, clé du fichier queue/<clé de l'envoi>.eml, un destinataire annoncé par destinataire compté ; préparation (jeton, préfixe, adresse de retour) réservée au compte de service pour un transfert ou un avis ; dépôt authentifié : compte actif de l'organisation, titulaire recopié, toutes les adresses permises (fn::mail_sender_allowed, MAIL_SENDER_FORBIDDEN) ; module : expéditeur et champs d'en-tête parmi les expéditeurs des modules de l'organisation ; avis : expéditeur vide. Ensuite : états pending → queued (fichier lié, destinataires en file) → done (aucun destinataire ouvert) ; abandon une fois et avant la clôture ; préparation, fichier, clé et taille jamais changés";

-- ----------------------------------------------------------------------------
-- fn::mail_submission_apply (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_submission_apply($previous: any, $next: any) -> none {
    IF $next IS NONE AND !record::exists($previous.tenant) { RETURN NONE; };
    IF $previous IS NONE {
        LET $over = fn::mail_send_counter_take(fn::mail_send_counters($next, fn::mail_settings_effective({ tenant: $next.tenant })));
        IF $over IS NOT NONE { THROW "MAIL_SEND_LIMIT_EXCEEDED"; };
        RETURN NONE;
    };
    -- Dépôt abandonné, ou retiré sans avoir été clos ni abandonné : compteurs rendus une fois
    LET $abandoned = $next IS NOT NONE AND $previous.aborted_at IS NONE AND $next.aborted_at IS NOT NONE;
    LET $dropped = $next IS NONE AND $previous.state = "pending" AND $previous.aborted_at IS NONE;
    IF $abandoned OR $dropped {
        fn::mail_send_counter_release(fn::mail_send_counters($previous, fn::mail_settings_effective({ tenant: $previous.tenant })));
    };
    RETURN NONE;
} COMMENT "Interne : effets d'une écriture d'un envoi admise ($previous, $next) : création → compteurs d'envoi pris (THROW MAIL_SEND_LIMIT_EXCEEDED au-delà de la limite : l'envoi n'est pas créé) ; abandon, ou retrait d'un dépôt jamais clos ni abandonné → compteurs rendus";

-- ----------------------------------------------------------------------------
-- fn::mail_queue_recipient_refusal (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_queue_recipient_refusal($previous: any, $next: any) -> option<string> {
    IF $next IS NONE { RETURN NONE; };
    IF $previous IS NONE {
        LET $submission = (SELECT tenant, owner, origin, state, recipient_count FROM ONLY $next.submission);
        RETURN IF $submission == NONE OR $submission.state != "pending" OR $submission.tenant != $next.tenant OR $submission.owner != $next.owner
            OR $submission.origin != $next.origin OR $next.rank >= $submission.recipient_count OR $next.id != fn::mail_queue_recipient_key($next.submission, $next.rank)
            OR $next.state != "scheduled" OR $next.attempts != 0 OR $next.claim IS NOT NONE OR $next.locked_until IS NOT NONE
            OR $next.last_result IS NOT NONE OR $next.delayed_at IS NOT NONE OR $next.dsn_sent OR $next.delay_sent { "MAIL_WRITE_FORBIDDEN" } ELSE { NONE };
    };
    LET $allowed = {
        scheduled: ["scheduled", "running", "canceled", "failed"], running: ["running", "scheduled", "delivered", "relayed", "failed", "expired"],
        delivered: ["delivered", "bounced"], relayed: ["relayed", "bounced"], failed: ["failed"], expired: ["expired"], canceled: ["canceled"], bounced: ["bounced"]
    }[$previous.state];
    IF $next.state NOTINSIDE $allowed OR $next.attempts < $previous.attempts { RETURN "MAIL_WRITE_FORBIDDEN"; };
    IF $next.state = "running" AND ($next.claim IS NONE OR $next.locked_until IS NONE) { RETURN "MAIL_WRITE_FORBIDDEN"; };
    IF ($previous.dsn_sent AND !$next.dsn_sent) OR ($previous.delay_sent AND !$next.delay_sent) OR ($previous.delayed_at IS NOT NONE AND $next.delayed_at != $previous.delayed_at) { RETURN "MAIL_WRITE_FORBIDDEN"; };
    IF fn::mail_queue_worker_writer() { RETURN NONE; };
    -- Expéditeur (titulaire, mail.relay) : annulation d'un destinataire en attente seulement
    RETURN IF $previous.state = "scheduled" AND $next.state = "canceled" AND $next.attempts = $previous.attempts AND $next.next_attempt_at = $previous.next_attempt_at
        AND $next.claim IS NONE AND $next.dsn_sent = $previous.dsn_sent AND $next.delay_sent = $previous.delay_sent { NONE } ELSE { "MAIL_WRITE_FORBIDDEN" };
} COMMENT "Interne : garde d'une écriture d'un destinataire en file ($previous, $next) : création par la clôture d'un envoi pending (même organisation, titulaire et origine, rang et identifiant ordonnés, état scheduled sans essai ni réservation) ; états scheduled → running → delivered, relayed, failed, expired (ou retour à scheduled), scheduled → canceled ou failed (message illisible), delivered et relayed → bounced ; réservation avec jeton et bail ; essais, retard et avis jamais remis en arrière ; hors compte de service, annulation d'un destinataire en attente seulement";

-- ----------------------------------------------------------------------------
-- fn::mail_submission_event_payload (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_submission_event_payload($recipient: object) -> object {
    RETURN {
        tenant: <string> $recipient.tenant,
        submission: <string> $recipient.submission,
        recipient: <string> $recipient.id,
        rank: $recipient.rank,
        origin: $recipient.origin,
        client_reference: (SELECT VALUE client_reference FROM ONLY $recipient.submission),
        status: $recipient.last_result.enhanced,
        attempts: $recipient.attempts,
        local: $recipient.local,
        at: <string> ($recipient.final_at ?? $recipient.delayed_at ?? time::now())
    };
} COMMENT "Interne : charge utile des événements mail.submission.* d'un destinataire ($recipient) : identifiants, rang, origine, référence du module appelant, code étendu du dernier résultat, essais, route locale, date ; ni adresse, ni domaine, ni sujet, ni texte distant";

-- ----------------------------------------------------------------------------
-- fn::mail_queue_recipient_apply (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_queue_recipient_apply($previous: any, $next: any) -> none {
    LET $row = $next ?? $previous;
    -- Échéancier : seconde de l'échéance posée si elle manque (jamais remise à jour ni retirée ici)
    IF $next IS NOT NONE AND $next.state = "scheduled" AND ($previous IS NONE OR $previous.state != "scheduled" OR $previous.next_attempt_at != $next.next_attempt_at) {
        LET $second = fn::mail_queue_due_key($next.next_attempt_at);
        IF !record::exists($second) { CREATE $second CONTENT { at: fn::mail_queue_due_second($next.next_attempt_at) }; };
    };
    -- Destinataires ouverts de l'envoi ; le dernier fini termine l'envoi (jeton de retour : 14 jours)
    LET $final = ["delivered", "relayed", "failed", "expired", "canceled", "bounced"];
    LET $was_open = $previous IS NOT NONE AND $previous.state NOTINSIDE $final;
    LET $is_open = $next IS NOT NONE AND $next.state NOTINSIDE $final;
    IF $was_open != $is_open AND record::exists($row.submission) {
        LET $updated = (UPDATE ONLY $row.submission SET open_count += IF $is_open { 1 } ELSE { -1 });
        IF $updated.open_count = 0 AND $updated.state = "queued" {
            LET $now = time::now();
            UPDATE $row.submission SET state = "done", done_at = $now, return_expires_at = IF return_token IS NONE { return_expires_at } ELSE { $now + 14d };
        };
    };
    RETURN NONE;
} COMMENT "Interne : effets d'une écriture d'un destinataire en file ($previous, $next) : seconde de l'échéance posée dans l'échéancier mail_queue_due quand un destinataire y est programmé et qu'elle manque (décision E5 ; aucun retrait ici : un DELETE coûte environ 1 ms) ; compte des destinataires ouverts de l'envoi ; au dernier destinataire fini d'un envoi en file : envoi done, adresse de retour valable 14 jours";
