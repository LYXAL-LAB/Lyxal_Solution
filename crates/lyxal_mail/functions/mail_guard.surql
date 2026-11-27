-- SPDX-License-Identifier: AGPL-3.0-only
-- ============================================================================
-- FONCTIONS : gardes des écritures et compteurs tenus par les événements
-- MODULE    : lyxal_mail
-- ============================================================================
-- Appelées par les événements de events/mail_guards.surql, dans la transaction de chaque
-- écriture, quelle qu'en soit l'origine (fonctions publiques, écriture directe, suppression en
-- cascade). Un événement s'exécute avec les droits de la base, mais voit l'identité de
-- l'appelant : la garde refuse ce qui casserait un invariant (THROW du code rendu), puis les
-- compteurs des dossiers et du compte, les pierres tombales et les lecteurs des contenus sont
-- tenus à jour. Les champs de compteurs ne s'écrivent pas directement (permission du compte de
-- service) ; une écriture de message ou de dossier qui ne fait pas avancer le numéro de
-- modification est refusée (MAIL_WRITE_FORBIDDEN).

-- ----------------------------------------------------------------------------
-- fn::mail_write_refusal (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_write_refusal($table: string, $previous: any, $next: any) -> option<string> {
    -- Suppression emportée par celle de l'organisation (cascade) : toujours permise
    IF $next IS NONE AND !record::exists($previous.tenant) { RETURN NONE; };
    IF $table = "mail_account" {
        IF $previous IS NONE {
            -- Compteurs à zéro, compte actif, sans adresse principale : posés par les événements
            RETURN IF $next.state != "active" OR $next.message_count != 0 OR $next.used_bytes != 0 OR $next.modseq != 0
                OR $next.uid_validity_next != 1 OR $next.changes_floor != 0 OR $next.mailbox_count != 0 OR $next.address_count != 0
                OR $next.primary_address IS NOT NONE OR $next.quota_exceeded_at IS NOT NONE { "MAIL_WRITE_FORBIDDEN" } ELSE { NONE };
        };
        IF $next IS NONE { RETURN NONE; };
        -- L'identité ne se retire qu'avec elle (REFERENCE ON DELETE UNSET) ; jamais remplacée
        IF $previous.identity != $next.identity AND !($next.identity IS NONE AND !record::exists($previous.identity)) { RETURN "MAIL_WRITE_FORBIDDEN"; };
        IF $previous.state = "deleting" AND $next.state != "deleting" { RETURN "MAIL_ACCOUNT_DELETING"; };
        IF $next.primary_address IS NOT NONE AND $next.primary_address != $previous.primary_address
            AND (SELECT VALUE account FROM ONLY $next.primary_address) != $next.id { RETURN "MAIL_WRITE_FORBIDDEN"; };
        IF $previous.primary_address IS NOT NONE AND $next.primary_address IS NONE AND $next.state != "deleting" { RETURN "MAIL_ADDRESS_IS_PRIMARY"; };
        -- La date du dépassement s'efface quand de la place se libère (effacement, dans la même
        -- écriture que le volume) ou par l'administrateur (quota changé) ; jamais par le titulaire seul
        RETURN IF $previous.quota_exceeded_at IS NOT NONE AND $next.quota_exceeded_at IS NONE AND $next.used_bytes >= $previous.used_bytes
            AND !fn::mail_can({ action: "manage", tenant: $next.tenant }) AND !fn::mail_can({ action: "worker" }) { "MAIL_WRITE_FORBIDDEN" } ELSE { NONE };
    };
    IF $table = "mail_domain" {
        IF $previous IS NONE {
            -- Domaine vérifié de la même organisation (décision M9), sous son nom
            LET $found = fn::auth_organization_domain_get({ domain: <string> $next.auth_domain });
            LET $auth_domain = IF $found.ok { $found.data } ELSE { NONE };
            IF $auth_domain == NONE OR $auth_domain.organization != $next.tenant OR $auth_domain.domain != $next.name OR $next.address_count != 0
                OR $next.catch_all IS NOT NONE OR $next.postmaster IS NOT NONE OR array::len($next.module_senders) > 0 { RETURN "MAIL_WRITE_FORBIDDEN"; };
            RETURN IF $auth_domain.state != "verified" { "MAIL_DOMAIN_NOT_VERIFIED" } ELSE { NONE };
        };
        -- Un domaine qui porte des adresses ne se supprime qu'avec son organisation
        IF $next IS NONE { RETURN IF $previous.address_count > 0 AND record::exists($previous.tenant) { "MAIL_DOMAIN_NOT_EMPTY" } ELSE { NONE }; };
        -- Expéditeurs des modules (lot 6, §12.3) : jamais une adresse inscrite du domaine
        LET $added = array::complement($next.module_senders, $previous.module_senders);
        IF array::len($added) > 0 AND array::len(SELECT VALUE id FROM mail_address WHERE domain = $next.id AND local_part IN $added LIMIT 1) > 0 { RETURN "MAIL_MODULE_SENDER_CONFLICT"; };
        -- Attrape-tout et postmaster : posés sur un compte actif de la même organisation
        LET $posed = array::filter(["catch_all", "postmaster"], |$f| $next[$f] IS NOT NONE AND $next[$f] != $previous[$f]);
        RETURN IF array::all($posed, |$f| (SELECT VALUE id FROM ONLY $next[$f] WHERE tenant = $next.tenant AND state = "active") IS NOT NONE) { NONE } ELSE { "MAIL_WRITE_FORBIDDEN" };
    };
    IF $table = "mail_address" {
        IF $next IS NONE {
            -- L'adresse principale d'un compte vivant ne se retire pas
            LET $owner = IF $previous.account IS NONE { NONE } ELSE { (SELECT state, primary_address FROM ONLY $previous.account) };
            RETURN IF $owner IS NOT NONE AND $owner.state != "deleting" AND $owner.primary_address = $previous.id { "MAIL_ADDRESS_IS_PRIMARY" } ELSE { NONE };
        };
        -- Envoi (lot 6) : préfixe réservé, expéditeurs des modules, senders et forward_to des alias
        LET $sending = fn::mail_address_send_refusal($previous, $next);
        IF $sending IS NOT NONE { RETURN $sending; };
        IF $previous IS NONE {
            LET $domain = (SELECT tenant, name FROM ONLY $next.domain);
            IF $domain == NONE OR $domain.tenant != $next.tenant OR $next.address != string::concat($next.local_part, "@", $domain.name) { RETURN "MAIL_WRITE_FORBIDDEN"; };
            IF $next.kind = "account" {
                LET $owner = IF $next.account IS NONE { NONE } ELSE { (SELECT tenant, state FROM ONLY $next.account) };
                RETURN IF $owner == NONE OR $owner.tenant != $next.tenant OR $owner.state = "deleting" OR array::len($next.targets) > 0 { "MAIL_WRITE_FORBIDDEN" } ELSE { NONE };
            };
            IF $next.account IS NOT NONE { RETURN "MAIL_WRITE_FORBIDDEN"; };
        };
        IF $next.kind = "account" { RETURN IF array::len($next.targets) > 0 { "MAIL_WRITE_FORBIDDEN" } ELSE { NONE }; };
        IF $previous IS NOT NONE AND $previous.targets = $next.targets { RETURN NONE; };
        -- Alias : 1 à 50 comptes vivants de la même organisation
        LET $valid = (SELECT VALUE id FROM array::distinct($next.targets) WHERE tenant = $next.tenant AND state != "deleting");
        RETURN IF array::len($next.targets) < 1 OR array::len($valid) != array::len(array::distinct($next.targets)) OR array::len($next.targets) != array::len(array::distinct($next.targets)) { "MAIL_ALIAS_TARGET_INVALID" } ELSE { NONE };
    };
    IF $table = "mail_mailbox" {
        LET $owner = (SELECT tenant, state, modseq, uid_validity_next FROM ONLY ($next ?? $previous).account);
        IF $next IS NONE {
            -- Suppression : pas la boîte de réception, ni un dossier non vide ou parent, sauf avec le compte
            IF $owner == NONE OR $owner.state = "deleting" { RETURN NONE; };
            IF $previous.role = "inbox" { RETURN "MAIL_MAILBOX_PROTECTED"; };
            IF $previous.total > 0 { RETURN "MAIL_MAILBOX_NOT_EMPTY"; };
            RETURN IF array::len(SELECT VALUE id FROM mail_mailbox WHERE account = $previous.account AND parent = $previous.id LIMIT 1) > 0 { "MAIL_MAILBOX_HAS_CHILDREN" } ELSE { NONE };
        };
        IF $owner == NONE OR $owner.tenant != $next.tenant { RETURN "MAIL_WRITE_FORBIDDEN"; };
        LET $above = IF $next.parent IS NONE { NONE } ELSE { (SELECT account, path FROM ONLY $next.parent) };
        LET $expected = IF $next.parent IS NONE { $next.name } ELSE { string::concat($above.path ?? "", "/", $next.name) };
        LET $layout = ($next.parent IS NOT NONE AND ($above == NONE OR $above.account != $next.account OR $next.parent = $next.id))
            OR $next.path != $expected OR (($next.role = "inbox") != ($next.path = "INBOX"));
        IF $previous IS NONE {
            IF $owner.state = "deleting" { RETURN "MAIL_ACCOUNT_DELETING"; };
            RETURN IF $layout OR $next.total != 0 OR $next.unseen != 0 OR $next.size != 0 OR $next.uid_next != 1
                OR $next.uid_validity < $owner.uid_validity_next OR $next.modseq <= $owner.modseq OR $next.highest_modseq != $next.modseq { "MAIL_WRITE_FORBIDDEN" } ELSE { NONE };
        };
        IF $next.uid_next < $previous.uid_next { RETURN "MAIL_WRITE_FORBIDDEN"; };
        LET $changed = array::any(["name", "path", "parent", "role", "subscribed", "sort_order"], |$f| $previous[$f] != $next[$f]);
        IF !$changed { RETURN IF $next.modseq < $previous.modseq { "MAIL_WRITE_FORBIDDEN" } ELSE { NONE }; };
        -- Un déplacement sous lui-même ou sous un de ses sous-dossiers ferait une boucle
        LET $cycle = $above IS NOT NONE AND string::starts_with($above.path, string::concat($previous.path, "/"));
        RETURN IF $layout OR $cycle OR $next.modseq <= $previous.modseq OR $next.modseq < $owner.modseq { "MAIL_WRITE_FORBIDDEN" } ELSE { NONE };
    };
    IF $table = "mail_content" {
        IF $next IS NONE { RETURN NONE; };
        IF $previous IS NONE {
            LET $owner = (SELECT tenant, state FROM ONLY $next.account);
            IF $owner IS NOT NONE AND $owner.tenant = $next.tenant AND $owner.state = "deleting" { RETURN "MAIL_ACCOUNT_DELETING"; };
            RETURN IF $owner == NONE OR $owner.tenant != $next.tenant OR $next.state != "pending" OR $next.refs != 0 OR $next.object IS NOT NONE
                OR !string::starts_with($next.key, string::concat(<string> record::id($next.account), "/")) { "MAIL_WRITE_FORBIDDEN" } ELSE { NONE };
        };
        -- released → stored : contenu relu par la fiche qui remplace celle d'un déplacement
        LET $allowed = { pending: ["pending", "stored"], stored: ["stored", "released"], released: ["released", "stored"] }[$previous.state];
        IF $next.state NOTINSIDE $allowed OR ($previous.state = "released" AND $next.state = "stored" AND $next.refs < 1) { RETURN "MAIL_CONTENT_STATE_INVALID"; };
        RETURN IF ($next.object != $previous.object AND !($previous.state = "pending" AND $next.state = "stored")) OR ($next.state != "pending" AND $next.object IS NONE) { "MAIL_WRITE_FORBIDDEN" } ELSE { NONE };
    };
    IF $table = "mail_message" {
        IF $next IS NONE {
            -- Compte désactivé : ses messages ne s'effacent plus, sauf par l'exploitation (session
            -- système, compte de service) ; compte en suppression ou déjà retiré : purge permise
            LET $holder = (SELECT VALUE state FROM ONLY $previous.account);
            RETURN IF $holder = "disabled" AND !fn::mail_can({ action: "worker" }) { "MAIL_ACCOUNT_DISABLED" } ELSE { NONE };
        };
        LET $owner = (SELECT tenant, identity, state, modseq, used_bytes, quota_bytes FROM ONLY $next.account);
        IF $owner == NONE OR $owner.tenant != $next.tenant { RETURN "MAIL_WRITE_FORBIDDEN"; };
        -- Compte désactivé ou en suppression : aucun message ne change, sauf par l'exploitation
        IF $previous IS NOT NONE AND $owner.state != "active" AND !fn::mail_can({ action: "worker" }) {
            RETURN IF $owner.state = "deleting" { "MAIL_ACCOUNT_DELETING" } ELSE { "MAIL_ACCOUNT_DISABLED" };
        };
        LET $box = (SELECT account, uid_next FROM ONLY $next.mailbox);
        IF $box == NONE OR $box.account != $next.account { RETURN "MAIL_WRITE_FORBIDDEN"; };
        IF $previous IS NONE {
            IF $owner.state != "active" { RETURN IF $owner.state = "deleting" { "MAIL_ACCOUNT_DELETING" } ELSE { "MAIL_ACCOUNT_DISABLED" }; };
            -- Identifiant ordonné : <clé du dossier>_<10^10 + UID> (décision P1)
            IF $next.id != fn::mail_message_key($next.mailbox, $next.uid) { RETURN "MAIL_WRITE_FORBIDDEN"; };
            -- Titulaire recopié du compte : clé du contrôle de lecture par fiche (décision P1)
            IF $owner.identity IS NONE OR $next.owner != $owner.identity { RETURN "MAIL_WRITE_FORBIDDEN"; };
            -- Origine delivery : service de remise seulement, avec les résultats de la réception ;
            -- aucune autre origine ne les porte (seule delivery publie mail.message.received)
            IF ($next.origin = "delivery") != ($next.reception IS NOT NONE) OR ($next.origin = "delivery" AND (object::len($next.reception) != 7 OR !fn::mail_can({ action: "worker" }))) { RETURN "MAIL_WRITE_FORBIDDEN"; };
            LET $content = (SELECT account, state, size, protection FROM ONLY $next.content);
            IF $content == NONE OR $content.account != $next.account OR $content.size != $next.size OR $content.protection != $next.protection { RETURN "MAIL_WRITE_FORBIDDEN"; };
            -- Un contenu libéré dans la même transaction est relu par la fiche qui remplace celle
            -- d'un déplacement (fn::mail_message_move)
            IF $content.state NOTINSIDE ["stored", "released"] { RETURN "MAIL_CONTENT_STATE_INVALID"; };
            IF $next.uid < $box.uid_next OR $next.modseq < $owner.modseq OR $next.modseq < 1 OR $next.create_modseq != $next.modseq { RETURN "MAIL_WRITE_FORBIDDEN"; };
            LET $quota = $owner.quota_bytes ?? fn::mail_settings_effective({ tenant: $next.tenant }).default_quota_bytes;
            RETURN IF $quota IS NOT NONE AND $owner.used_bytes + $next.size > $quota { "MAIL_QUOTA_EXCEEDED" } ELSE { NONE };
        };
        -- Tout changement visible d'un client (dossier, UID, drapeaux, mots-clés) prend un numéro
        -- de modification plus grand, au moins égal au dernier du compte
        LET $changed = array::any(["mailbox", "uid", "seen", "answered", "flagged", "deleted", "draft", "keywords"], |$f| $previous[$f] != $next[$f]);
        IF $next.modseq < $previous.modseq OR ($changed AND ($next.modseq <= $previous.modseq OR $next.modseq < $owner.modseq)) { RETURN "MAIL_WRITE_FORBIDDEN"; };
        -- Dossier et UID font partie de l'identifiant : un déplacement inscrit une nouvelle fiche
        RETURN IF $next.mailbox != $previous.mailbox OR $next.uid != $previous.uid { "MAIL_WRITE_FORBIDDEN" } ELSE { NONE };
    };
    RETURN NONE;
} COMMENT "Interne : garde d'une écriture dans une table de lyxal_mail ($table ; $previous, $next : NONE à la création, à la suppression), appelée par les événements de garde ; NONE, ou le code MAIL_* du refus. Compteurs à zéro à la création ; identité jamais remplacée ; adresse principale gardée tant que le compte vit ; domaine vérifié de la même organisation, non vide seulement avec elle, attrape-tout et postmaster posés sur un compte actif de l'organisation ; alias vers 1 à 50 comptes vivants de l'organisation ; dossier : chemin, parent et rôle cohérents, UIDVALIDITY tirée du compte, pas de boucle, boîte de réception, dossier non vide ou parent protégés ; contenu : états pending → stored → released ; message : même compte que son dossier et son contenu, contenu stocké, compte actif (inscription et changement ; effacement refusé sur un compte désactivé ; changement et effacement permis à l'exploitation : session système, compte de service), origine delivery réservée au service de remise et seule à porter les résultats de la réception, UID au moins égal au prochain du dossier, numéro de modification qui avance, quota (filet de sécurité de fn::mail_message_create)";

-- ----------------------------------------------------------------------------
-- fn::mail_counters_apply (interne)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::mail_counters_apply($table: string, $previous: any, $next: any) -> none {
    -- Suppression emportée par celle de l'organisation : rien à tenir, tout part avec elle
    IF $next IS NONE AND !record::exists($previous.tenant) { RETURN NONE; };
    IF $table = "mail_account" {
        IF $previous IS NONE {
            -- Six dossiers créés avec le compte (décision M18) : noms anglais, rôles SPECIAL-USE
            FOR $box IN [
                { name: "INBOX", role: "inbox", rank: 1 }, { name: "Drafts", role: "drafts", rank: 2 },
                { name: "Sent", role: "sent", rank: 3 }, { name: "Junk", role: "junk", rank: 4 },
                { name: "Trash", role: "trash", rank: 5 }, { name: "Archive", role: "archive", rank: 6 }
            ] {
                CREATE mail_mailbox CONTENT {
                    tenant: $next.tenant, account: $next.id, name: $box.name, path: $box.name, role: $box.role,
                    subscribed: true, sort_order: $box.rank - 1, uid_validity: $box.rank, modseq: $box.rank, highest_modseq: $box.rank
                };
            };
            RETURN NONE;
        };
        IF $next IS NONE { RETURN NONE; };
        -- Identité supprimée : le compte part en suppression (décision M12)
        IF $previous.identity IS NOT NONE AND $next.identity IS NONE AND $next.state != "deleting" {
            UPDATE $next.id SET state = "deleting";
            RETURN NONE;
        };
        -- Compte en suppression : ses adresses sont retirées tout de suite, les alias ne le visent plus
        IF $previous.state != "deleting" AND $next.state = "deleting" {
            DELETE mail_address WHERE account = $next.id;
            DELETE mail_address WHERE kind = "alias" AND targets CONTAINS $next.id AND array::len(targets) = 1;
            UPDATE mail_address SET targets = array::complement(targets, [$next.id]) WHERE kind = "alias" AND targets CONTAINS $next.id;
            UPDATE mail_address SET senders = array::complement(senders, [$next.id]) WHERE kind = "alias" AND senders CONTAINS $next.id;
            UPDATE $next.id SET primary_address = NONE;
            UPDATE mail_domain SET catch_all = NONE WHERE catch_all = $next.id;
            UPDATE mail_domain SET postmaster = NONE WHERE postmaster = $next.id;
            RETURN NONE;
        };
        RETURN NONE;
    };
    IF $table = "mail_address" {
        LET $row = $next ?? $previous;
        LET $step = IF $next IS NONE { -1 } ELSE { 1 };
        IF $previous IS NONE OR $next IS NONE {
            UPDATE $row.domain SET address_count += $step;
            IF $row.account IS NOT NONE { UPDATE $row.account SET address_count += $step; };
        };
        RETURN NONE;
    };
    IF $table = "mail_mailbox" {
        IF $previous IS NONE {
            UPDATE $next.account SET uid_validity_next = math::max([uid_validity_next, $next.uid_validity + 1]),
                modseq = math::max([modseq, $next.modseq]), mailbox_count += 1;
            RETURN NONE;
        };
        IF $next IS NOT NONE {
            IF $next.modseq != $previous.modseq { UPDATE $next.account SET modseq = math::max([modseq, $next.modseq]); };
            RETURN NONE;
        };
        LET $owner = (SELECT identity, state, modseq FROM ONLY $previous.account);
        IF $owner == NONE { RETURN NONE; };
        IF $owner.state = "deleting" {
            UPDATE $previous.account SET mailbox_count -= 1;
            RETURN NONE;
        };
        LET $modseq = $owner.modseq + 1;
        CREATE mail_tombstone CONTENT { tenant: $previous.tenant, account: $previous.account, owner: $owner.identity, kind: "mailbox", mailbox: <string> $previous.id, object: <string> $previous.id, modseq: $modseq };
        UPDATE $previous.account SET modseq = $modseq, mailbox_count -= 1;
        RETURN NONE;
    };
    IF $table = "mail_message" {
        IF $previous IS NONE {
            UPDATE $next.mailbox SET total += 1, unseen += IF $next.seen { 0 } ELSE { 1 }, size += $next.size,
                uid_next = math::max([uid_next, $next.uid + 1]), highest_modseq = math::max([highest_modseq, $next.modseq]);
            UPDATE $next.account SET message_count += 1, used_bytes += $next.size, modseq = math::max([modseq, $next.modseq]);
            UPDATE $next.content SET refs += 1, expires_at = NONE, state = "stored";
            -- Vue par date (pages par date, décision P1) et bornes de dates du dossier
            CREATE type::record("mail_message_date", fn::mail_message_date_key_text($next.mailbox, time::micros($next.received_at), $next.uid)) CONTENT {
                tenant: $next.tenant, account: $next.account, owner: $next.owner, mailbox: $next.mailbox, message: $next.id, received_at: $next.received_at, uid: $next.uid
            };
            UPDATE $next.mailbox SET received_min = IF received_min IS NONE OR $next.received_at < received_min { $next.received_at } ELSE { received_min },
                received_max = IF received_max IS NONE OR $next.received_at > received_max { $next.received_at } ELSE { received_max };
            RETURN NONE;
        };
        IF $next IS NONE {
            DELETE type::record("mail_message_date", fn::mail_message_date_key_text($previous.mailbox, time::micros($previous.received_at), $previous.uid));
            LET $owner = (SELECT state, modseq FROM ONLY $previous.account);
            IF $owner == NONE { RETURN NONE; };
            -- Compte en purge : ni pierre tombale ni numéro de modification
            LET $modseq = IF $owner.state = "deleting" { $owner.modseq } ELSE { $owner.modseq + 1 };
            IF $owner.state != "deleting" {
                CREATE mail_tombstone CONTENT { tenant: $previous.tenant, account: $previous.account, owner: $previous.owner, kind: "message", mailbox: <string> $previous.mailbox, uid: $previous.uid, object: <string> $previous.id, modseq: $modseq };
            };
            UPDATE $previous.mailbox SET total -= 1, unseen -= IF $previous.seen { 0 } ELSE { 1 }, size -= $previous.size,
                highest_modseq = math::max([highest_modseq, $modseq]);
            -- De la place se libère : un nouveau dépassement pourra publier mail.quota.exceeded
            UPDATE $previous.account SET message_count -= 1, used_bytes -= $previous.size, modseq = $modseq,
                quota_exceeded_at = IF $previous.size > 0 { NONE } ELSE { quota_exceeded_at };
            fn::mail_content_release($previous.content);
            RETURN NONE;
        };
        IF $next.seen != $previous.seen OR $next.modseq != $previous.modseq {
            UPDATE $next.mailbox SET unseen += IF $previous.seen = $next.seen { 0 } ELSE IF $next.seen { -1 } ELSE { 1 },
                highest_modseq = math::max([highest_modseq, $next.modseq]);
        };
        IF $next.modseq != $previous.modseq { UPDATE $next.account SET modseq = math::max([modseq, $next.modseq]); };
        RETURN NONE;
    };
    RETURN NONE;
} COMMENT "Interne : effets d'une écriture admise par fn::mail_write_refusal ($table ; $previous, $next), appelée par les événements de compteurs. Compte créé : six dossiers (INBOX, Drafts, Sent, Junk, Trash, Archive, rôles posés, décision M18) ; identité supprimée : compte en suppression ; compte en suppression : adresses retirées, alias ne le visant plus (vides : retirés), attrape-tout et postmaster des domaines effacés ; volume sous le quota : date du dépassement effacée. Adresse : compteurs du domaine et du compte. Dossier : UIDVALIDITY suivante, numéro de modification et nombre de dossiers du compte, pierre tombale à la suppression. Message : compteurs du dossier (total, non lus, volume, prochain UID, HIGHESTMODSEQ) et du compte (messages, volume, numéro de modification), lecteurs du contenu, pierres tombales (effacement, déplacement) ; rien pour un compte en purge";
