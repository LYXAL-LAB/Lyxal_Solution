-- SPDX-License-Identifier: AGPL-3.0-only
-- ============================================================================
-- FONCTIONS : droits, réglages effectifs, compte de la session, numéros de modification
-- MODULE    : lyxal_mail
-- ============================================================================
-- Contrôle unique des droits (fn::mail_can), utilisé par les PERMISSIONS des tables et par les
-- fonctions publiques, sur le modèle de fn::storage_can. Fonctions internes : COMMENT « Interne ».

-- ----------------------------------------------------------------------------
-- fn::mail_can (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_can($params: object) -> bool {
    IF fn::auth_session_valid({}).system { RETURN true; };
    IF $params.action = "worker" { RETURN fn::auth_has_permission({ permission: "mail.worker" }); };
    IF $params.action = "manage" {
        RETURN IF $params.tenant IS NONE {
            fn::auth_has_permission({ permission: "mail.installation.manage" })
        } ELSE {
            fn::auth_has_permission({ permission: "mail.domain.manage", tenant: $params.tenant })
        };
    };
    IF $params.action = "settings" {
        RETURN $params.tenant IS NONE
            OR fn::auth_has_permission({ permission: "mail.mailbox.access", tenant: $params.tenant })
            OR fn::auth_has_permission({ permission: "mail.domain.manage", tenant: $params.tenant })
            OR fn::auth_has_permission({ permission: "mail.worker" });
    };
    -- Envoi (lot 6) : déposer sous ses adresses (mail.send), par le contrat des modules
    -- (mail.relay), ou en origine forward / dsn (compte de service)
    IF $params.action = "send" { RETURN $params.tenant IS NOT NONE AND fn::auth_has_permission({ permission: "mail.send", tenant: $params.tenant }); };
    IF $params.action = "relay" { RETURN fn::auth_has_permission({ permission: "mail.relay" }); };
    IF $params.action = "submit" {
        RETURN IF $params.origin = "submission" {
            $params.tenant IS NOT NONE AND fn::auth_has_permission({ permission: "mail.send", tenant: $params.tenant })
        } ELSE IF $params.origin = "module" {
            fn::auth_has_permission({ permission: "mail.relay" })
        } ELSE {
            fn::auth_has_permission({ permission: "mail.worker" })
        };
    };
    IF $params.action = "sender" {
        -- Titulaire qui envoie : l'identité du compte (account, ou identity) est celle de la
        -- session, avec mail.send dans l'organisation (lecture de ses adresses et de son compte)
        LET $holder = IF $params.account IS NONE { $params.identity } ELSE { (SELECT VALUE identity FROM ONLY $params.account) };
        RETURN $params.tenant IS NOT NONE AND $holder IS NOT NONE AND $auth IS NOT NONE AND $holder = $auth.identity
            AND fn::auth_has_permission({ permission: "mail.send", tenant: $params.tenant });
    };
    IF $params.action = "submission" {
        -- Titulaire d'un dépôt authentifié (jamais l'administrateur de l'organisation, M11),
        -- mail.relay pour les envois des modules, sinon compte de service
        IF $params.origin = "submission" AND $params.owner IS NOT NONE AND $auth IS NOT NONE AND $params.owner = $auth.identity
            AND fn::auth_has_permission({ permission: "mail.send", tenant: $params.tenant }) { RETURN true; };
        IF $params.origin = "module" AND fn::auth_has_permission({ permission: "mail.relay" }) { RETURN true; };
        RETURN fn::auth_has_permission({ permission: "mail.worker" });
    };
    IF $params.action = "mailbox" {
        -- Titulaire : l'identité du compte est celle de la session (lue sur le compte, sauf si
        -- l'appelant la fournit : permissions de mail_account elle-même) ; sinon compte de service
        LET $owner = IF $params.account IS NONE { $params.identity } ELSE { (SELECT VALUE identity FROM ONLY $params.account) };
        IF $params.tenant IS NOT NONE AND $owner IS NOT NONE AND $auth IS NOT NONE AND $owner = $auth.identity {
            RETURN fn::auth_has_permission({ permission: "mail.mailbox.access", tenant: $params.tenant });
        };
        RETURN fn::auth_has_permission({ permission: "mail.worker" });
    };
    RETURN false;
} COMMENT "Interne : vrai si l'appelant peut effectuer l'action ({ action, tenant, account, identity }) : session système → toujours ; worker → mail.worker ; manage → mail.domain.manage dans l'organisation (mail.installation.manage sans tenant), jamais le contenu des boîtes (décision M11) ; settings → lecture des limites (installation : tous ; organisation : ses membres qui ont une boîte, ses administrateurs, le compte de service) ; mailbox → mail.mailbox.access dans l'organisation et identité du compte (account, ou identity) égale à celle de la session, ou mail.worker ; send → mail.send dans l'organisation ; sender → titulaire du compte (account, ou identity) avec mail.send ; relay → mail.relay ; submit (création d'un envoi, { tenant, origin }) → mail.send (submission), mail.relay (module), mail.worker (forward, dsn) ; submission (lecture et écriture d'un envoi, { tenant, owner, origin }) → titulaire d'un dépôt authentifié avec mail.send, mail.relay pour un envoi de module, ou mail.worker. Jamais d'erreur";

-- ----------------------------------------------------------------------------
-- fn::mail_settings_effective (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_settings_effective($params: object) -> object {
    LET $base = (SELECT * FROM ONLY mail_settings WHERE scope_key = "installation" LIMIT 1) ?? {};
    LET $own = IF $params.tenant IS NONE { {} } ELSE {
        (SELECT * FROM ONLY mail_settings WHERE scope_key = <string> record::id($params.tenant) LIMIT 1) ?? {}
    };
    RETURN {
        max_message_bytes: $own.max_message_bytes ?? $base.max_message_bytes ?? 52428800,
        default_quota_bytes: $own.default_quota_bytes ?? $base.default_quota_bytes,
        tombstone_retention_days: $own.tombstone_retention_days ?? $base.tombstone_retention_days ?? 30,
        max_mailboxes_per_account: $own.max_mailboxes_per_account ?? $base.max_mailboxes_per_account ?? 1000,
        max_addresses_per_account: $own.max_addresses_per_account ?? $base.max_addresses_per_account ?? 100,
        max_keywords_per_message: $own.max_keywords_per_message ?? $base.max_keywords_per_message ?? 50,
        -- Limites d'envoi : celle de l'organisation, plafonnée par celle de l'installation (E16)
        send_recipients_per_message: math::min([$own.send_recipients_per_message ?? 1000, $base.send_recipients_per_message ?? 100]),
        send_messages_per_day: math::min([$own.send_messages_per_day ?? 1000000, $base.send_messages_per_day ?? 1000]),
        send_recipients_per_day: math::min([$own.send_recipients_per_day ?? 10000000, $base.send_recipients_per_day ?? 2000]),
        module_messages_per_hour: math::min([$own.module_messages_per_hour ?? 10000000, $base.module_messages_per_hour ?? 10000]),
        forward_messages_per_day: math::min([$own.forward_messages_per_day ?? 10000000, $base.forward_messages_per_day ?? 10000]),
        -- File d'envoi : installation seulement (E6)
        retry_intervals: $base.retry_intervals ?? [5, 10, 20, 40, 80, 120],
        retry_jitter_percent: $base.retry_jitter_percent ?? 10,
        delay_notice_hours: $base.delay_notice_hours ?? 4,
        expire_hours: $base.expire_hours ?? 120
    };
} COMMENT "Interne : réglages effectifs ({ tenant }) : organisation, sinon installation, sinon valeurs par défaut (décision M18 : message de 50 Mio au plus, aucun quota par défaut ; 30 jours de conservation des effacements, M17 ; 1 000 dossiers, 100 adresses par compte, 50 mots-clés par message). Envoi (lot 6) : limites de l'organisation plafonnées par celles de l'installation (100 destinataires par message, 1 000 messages et 2 000 destinataires par compte et par jour, 10 000 messages des modules par heure, 10 000 transferts par jour) ; file réglée par l'installation (essais après 5, 10, 20, 40, 80 puis 120 min, ± 10 %, avis de retard à 4 h, expiration à 120 h)";

-- ----------------------------------------------------------------------------
-- fn::mail_session_account (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_session_account($account: any) -> option<record<mail_account>> {
    IF $account IS NOT NONE { RETURN $account; };
    LET $context = fn::auth_context({});
    IF !$context.ok OR $context.data.identity IS NONE OR $context.data.organization IS NONE { RETURN NONE; };
    RETURN (SELECT VALUE id FROM ONLY mail_account WHERE tenant = $context.data.organization AND identity = $context.data.identity LIMIT 1);
} COMMENT "Interne : compte visé ($account), ou, s'il est absent, compte de l'identité de la session dans son organisation active ; NONE sans session d'identité ou sans compte";

-- ----------------------------------------------------------------------------
-- fn::mail_address_normalize (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_address_normalize($local_part: string, $domain: string) -> object {
    LET $local = fn::sanitize_lowercase(fn::sanitize_trim($local_part));
    LET $address = string::concat($local, "@", $domain);
    -- Décision M10 : partie locale ASCII (dot-atom de la RFC 5322, 64 caractères au plus)
    LET $valid = fn::validation_ascii($local, false, false).valid
        AND fn::validation_max_length($local, 64).valid
        AND fn::validation_regex($local, "^[a-z0-9!#$%&'*+/=?^_`{|}~-]+(\\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*$").valid
        AND fn::validation_email($address, 254).valid;
    RETURN { valid: $valid, local_part: $local, address: $address };
} COMMENT "Interne : partie locale nettoyée (espaces retirés, minuscules) et adresse complète sur le domaine ($local_part, $domain) ; valid : partie locale ASCII en dot-atom de 64 caractères au plus et adresse e-mail valide de 254 caractères au plus (lyxal_core). { valid, local_part, address }";

-- ----------------------------------------------------------------------------
-- fn::mail_modseq_next (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_modseq_next($account: record<mail_account>) -> int {
    RETURN ((SELECT VALUE modseq FROM ONLY $account) ?? 0) + 1;
} COMMENT "Interne : prochain numéro de modification du compte ($account). Une écriture le pose sur ce qu'elle change (message, dossier) ; la garde de la table l'exige au moins égal au dernier numéro du compte et l'événement de compteurs fait avancer le compte (fn::mail_counters_apply), dans la même transaction : deux écritures concurrentes d'un compte se heurtent sur sa fiche (décision M6)";

-- ----------------------------------------------------------------------------
-- fn::mail_thread_assign (interne)
-- ----------------------------------------------------------------------------
-- Modèle : Mox, store/threads.go (commit b32f0de) ; règle de la décision M7.

DEFINE FUNCTION OVERWRITE fn::mail_thread_assign($params: object) -> object {
    -- Ancêtres du plus proche au plus lointain : In-Reply-To, puis References à rebours, puis le
    -- Message-ID lui-même (autre exemplaire du même message) ; 50 au plus
    LET $ancestors = array::distinct(array::concat($params.in_reply_to ?? [], array::reverse($params.references ?? [])));
    LET $candidates = array::slice(array::distinct(array::concat($ancestors, IF $params.message_id IS NONE { [] } ELSE { [$params.message_id] })), 0, 50);
    LET $found = array::filter(array::map($candidates, |$candidate|
        (SELECT thread, base_subject FROM ONLY mail_message WHERE account = $params.account AND message_id = $candidate LIMIT 1)
    ), |$row| $row IS NOT NONE);
    IF array::len($found) > 0 AND ($params.is_report OR $found[0].base_subject = $params.base_subject) {
        RETURN { thread: $found[0].thread, orphan: false };
    };
    RETURN { thread: <string> rand::uuid::v7(), orphan: array::len($found) = 0 AND array::len($ancestors) > 0 };
} COMMENT "Interne : fil d'un message inscrit ({ account, message_id, in_reply_to, references, base_subject, is_report }) : celui du premier ancêtre trouvé dans le compte (In-Reply-To, puis References du plus proche au plus lointain, puis un message de même Message-ID), si le sujet de base est égal ou si le message est un avis de non-remise ; sinon un nouveau fil (UUID v7). Jamais de fusion après coup (décision M7) ; orphan : réponse dont aucun ancêtre n'est trouvé. { thread, orphan }";

-- ----------------------------------------------------------------------------
-- fn::mail_content_release (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_content_release($content: record<mail_content>) -> none {
    LET $row = (SELECT refs, state FROM ONLY $content);
    IF $row == NONE { RETURN NONE; };
    IF $row.refs <= 1 {
        UPDATE $content SET refs = 0, state = IF $row.state = "stored" { "released" } ELSE { $row.state }, expires_at = time::now();
    } ELSE {
        UPDATE $content SET refs -= 1;
    };
    RETURN NONE;
} COMMENT "Interne : un message cesse de lire ce contenu ($content) ; au dernier lecteur, le contenu passe à released : il est retiré avec son fichier par la maintenance (fn::mail_content_expire), dans une même transaction. Appelée par l'événement des messages";

-- ----------------------------------------------------------------------------
-- Identifiants ordonnés des messages (internes, décision P1)
-- ----------------------------------------------------------------------------
-- SurrealDB 3.3.4 n'applique pas LIMIT au parcours d'un index dans une fonction, et évalue la
-- permission d'une table sur chaque ligne parcourue : une page lue par index coûte autant que le
-- dossier. Une plage d'identifiants d'enregistrement bornée ne parcourt que les fiches qu'elle
-- contient. Les clés sont des textes de largeur fixe (entiers décalés, sans remplissage) :
-- <clé du dossier>_<10^10 + UID> pour mail_message,
-- <clé du dossier>_<10^16 + date interne en µs>_<10^10 + UID> pour mail_message_date.

DEFINE FUNCTION OVERWRITE fn::mail_message_key_text($mailbox: record<mail_mailbox>, $uid: int) -> string {
    RETURN string::concat(<string> record::id($mailbox), "_", <string> (10000000000 + $uid));
} COMMENT "Interne : clé (texte) de l'identifiant du message d'UID $uid (0 à 4 294 967 296 : bornes de plage comprises) dans le dossier $mailbox ; l'ordre des clés est celui des UID";

DEFINE FUNCTION OVERWRITE fn::mail_message_key($mailbox: record<mail_mailbox>, $uid: int) -> record<mail_message> {
    RETURN type::record("mail_message", fn::mail_message_key_text($mailbox, $uid));
} COMMENT "Interne : identifiant du message d'UID $uid dans le dossier $mailbox (mail_message:⟨<clé du dossier>_<10^10 + UID>⟩), posé à l'inscription et vérifié par la garde";

DEFINE FUNCTION OVERWRITE fn::mail_message_date_key_text($mailbox: record<mail_mailbox>, $micros: int, $uid: int) -> string {
    RETURN string::concat(<string> record::id($mailbox), "_", <string> (10000000000000000 + $micros), "_", <string> (10000000000 + $uid));
} COMMENT "Interne : clé (texte) de la vue par date d'un message (date interne en microsecondes depuis 1970, $micros ; UID, $uid) dans le dossier $mailbox ; l'ordre des clés est celui des dates, puis des UID";

