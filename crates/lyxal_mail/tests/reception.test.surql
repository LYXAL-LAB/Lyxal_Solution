-- lyxal-test: assertions
-- Réception (lot 5) : résolution d'un destinataire (aucun relais, adresse inconnue ou
-- désactivée, sous-adresse, alias, attrape-tout, postmaster avec et sans domaine, quota plein,
-- taille de l'organisation, compte désactivé) ; remise : ouverture, doublon, lot de 32, élément en
-- erreur sans annuler les autres, lot de 33 refusé, origine et résultats de réception, compteurs
-- égaux au contenu, dossier Junk ; événement mail.message.received publié une fois par compte,
-- sans adresse ni sujet, jamais pour une copie, un déplacement ou un dépôt du titulaire ; purge.
--
-- identité admin: { "id": "auth_session:admin", "pv": 1, "permissions": ["mail.domain.manage", "mail.mailbox.access", "auth.member.read", "auth.organization.settings.manage"] }
-- identité jean: { "id": "auth_session:jean", "pv": 1, "permissions": ["mail.mailbox.access"] }
-- identité marie: { "id": "auth_session:marie", "pv": 1, "permissions": ["mail.mailbox.access"] }
-- identité autre: { "id": "auth_session:autre", "pv": 1, "permissions": ["mail.domain.manage", "mail.mailbox.access", "auth.member.read", "auth.organization.settings.manage"] }
-- identité worker: { "id": "auth_session:worker", "pv": 1, "permissions": ["mail.worker", "storage.worker"] }
-- identité plateforme: { "id": "auth_session:plateforme", "pv": 1, "permissions": ["mail.installation.manage"] }

-- préparation: organisations alpha et beta, identités et sessions lyxal_auth, domaines vérifiés, table de passage
{
    CREATE auth_organization:alpha CONTENT { slug: "alpha", name: "Alpha BTP" };
    CREATE auth_organization:beta CONTENT { slug: "beta", name: "Beta Bois" };
    FOR $person IN [["admin", "alpha"], ["jean", "alpha"], ["marie", "alpha"], ["paul", "alpha"], ["autre", "beta"]] {
        LET $identity = type::record("auth_identity", $person[0]);
        LET $organization = type::record("auth_organization", $person[1]);
        CREATE $identity CONTENT { schema: auth_identity_schema:default_v1, traits: { email: string::concat($person[0], "@lyxal.test") } };
        RELATE $identity->auth_member_of->$organization;
        CREATE type::record("auth_session", $person[0]) CONTENT { identity: $identity, organization: $organization, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    };
    FOR $name IN ["worker", "plateforme"] {
        CREATE type::record("auth_identity", $name) CONTENT { schema: auth_identity_schema:default_v1, traits: { email: string::concat($name, "@lyxal.test") } };
        CREATE type::record("auth_session", $name) CONTENT { identity: type::record("auth_identity", $name), idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    };
    CREATE auth_organization_domain:alpha CONTENT { organization: auth_organization:alpha, domain: "alpha.test", state: "verified", challenge_hash: "af1349b9f5f9a1a6a0404dea36dcc9499bcb25c9adc112b7cc9a93cae41f3262" };
    CREATE auth_organization_domain:beta CONTENT { organization: auth_organization:beta, domain: "beta.test", state: "verified", challenge_hash: "af1349b9f5f9a1a6a0404dea36dcc9499bcb25c9adc112b7cc9a93cae41f3262" };
    DEFINE TABLE OVERWRITE passe SCHEMALESS PERMISSIONS FULL;
};

-- préparation: domaines, comptes de jean, marie et paul (alpha) et d'autre (beta), alias equipe, buckets chiffrés du courrier
{
    LET $domain = fn::mail_domain_create({ auth_domain: "auth_organization_domain:alpha" }).data.id;
    LET $domain_beta = fn::mail_domain_create({ auth_domain: "auth_organization_domain:beta" }).data.id;
    LET $jean = fn::mail_account_create({ identity: "auth_identity:jean", domain: <string> $domain, local_part: "jean" }).data.account.id;
    LET $marie = fn::mail_account_create({ identity: "auth_identity:marie", domain: <string> $domain, local_part: "marie" }).data.account.id;
    LET $paul = fn::mail_account_create({ identity: "auth_identity:paul", domain: <string> $domain, local_part: "paul" }).data.account.id;
    LET $autre = fn::mail_account_create({ identity: "auth_identity:autre", domain: <string> $domain_beta, local_part: "autre" }).data.account.id;
    fn::mail_address_create({ domain: <string> $domain, local_part: "equipe", kind: "alias", targets: [<string> $jean, <string> $marie] });
    fn::storage_bucket_create({ tenant: "auth_organization:alpha", name: "lyxal-mail", encrypted: true });
    fn::storage_bucket_create({ tenant: "auth_organization:beta", name: "lyxal-mail", encrypted: true });
    LET $box = |$account, $role| <string> (SELECT VALUE id FROM ONLY mail_mailbox WHERE account = $account AND role = $role LIMIT 1);
    CREATE passe:ids CONTENT {
        domain: <string> $domain, domain_beta: <string> $domain_beta,
        jean: <string> $jean, marie: <string> $marie, paul: <string> $paul, autre: <string> $autre,
        jean_inbox: $box($jean, "inbox"), jean_junk: $box($jean, "junk"), jean_archive: $box($jean, "archive"),
        marie_inbox: $box($marie, "inbox"), marie_junk: $box($marie, "junk"), paul_inbox: $box($paul, "inbox")
    };
    DEFINE FUNCTION OVERWRITE fn::essai_id($name: string) -> string { RETURN (SELECT * FROM ONLY passe:ids)[$name]; };
};

-- préparation: aides d'essai : empreinte, fichier écrit, élément de remise prêt à inscrire, compteurs recalculés, événements de réception
{
    DEFINE FUNCTION OVERWRITE fn::essai_cle($n: int) -> string { RETURN string::concat(string::repeat("0", 60), <string> (1000 + $n)); };
    DEFINE FUNCTION OVERWRITE fn::essai_fichier($account: string, $key: string, $size: int) -> string {
        LET $tenant = (SELECT VALUE tenant FROM ONLY type::record($account));
        LET $bucket = (SELECT VALUE id FROM ONLY storage_bucket WHERE tenant = $tenant AND name = "lyxal-mail" LIMIT 1);
        LET $object = fn::storage_object_begin({ bucket: <string> $bucket, key: $key, filename: "message.eml", declared_size: $size }).data;
        fn::storage_object_commit({ object: <string> $object.id, size: $size, content_type: "message/rfc822", blake3: "af1349b9f5f9a1a6a0404dea36dcc9499bcb25c9adc112b7cc9a93cae41f3262", content_key: "enc:v2:essai-files-1:QUJD" });
        RETURN <string> $object.id;
    };
    DEFINE FUNCTION OVERWRITE fn::essai_element($account: string, $n: int, $extra: object) -> object {
        LET $size = $extra.size ?? 100;
        LET $reserved = fn::mail_delivery_begin({ account: $account, size: $size, delivery_key: fn::essai_cle($n) }).data;
        RETURN object::extend({
            content: <string> $reserved.content, object: fn::essai_fichier($account, $reserved.storage_key, $size), received_at: time::now(), delivery_key: fn::essai_cle($n),
            envelope: { subject: "Devis confidentiel", from: [{ name: "Expéditeur", address: "exp@ailleurs.test" }] }, structure: { type: "text/plain", size: $size },
            message_id: string::concat("m", <string> $n, "@ailleurs.test"),
            reception: { spf: "pass", dkim: "pass", dmarc: "pass", iprev: "pass", antivirus: "not_scanned", spam: "none", tls: true }
        }, object::remove($extra, "size"));
    };
    DEFINE FUNCTION OVERWRITE fn::essai_coherent($account: string) -> bool {
        LET $id = type::record($account);
        LET $boxes = (SELECT id, total, unseen, size, uid_next FROM mail_mailbox WHERE account = $id);
        LET $messages = (SELECT mailbox, seen, size, uid, modseq FROM mail_message WHERE account = $id);
        LET $owner = (SELECT message_count, used_bytes, modseq FROM ONLY $id);
        RETURN $boxes.all(|$b| {
            LET $mine = $messages.filter(|$m| $m.mailbox = $b.id);
            RETURN $b.total == array::len($mine) AND $b.unseen == array::len($mine.filter(|$m| !$m.seen)) AND $b.size == math::sum($mine.map(|$m| $m.size))
                AND $mine.all(|$m| $m.uid < $b.uid_next) AND array::len(array::distinct($mine.uid)) == array::len($mine);
        }) AND $owner.message_count == array::len($messages) AND $owner.used_bytes == math::sum($messages.map(|$m| $m.size))
            AND $messages.all(|$m| $m.modseq <= $owner.modseq) AND array::len(array::distinct($messages.modseq)) == array::len($messages);
    };
    DEFINE FUNCTION OVERWRITE fn::essai_recus($account: string) -> array {
        RETURN (SELECT VALUE payload FROM event_outbox WHERE event_type = "mail.message.received" AND payload.account = $account);
    };
};

-- test: résolution : adresse d'un compte, casse ignorée, sous-adresse retirée ; taille maximale de l'organisation
-- en tant que: worker
{
    LET $jean = type::record(fn::essai_id("jean"));
    LET $expected = { address: "jean@alpha.test", domain: "alpha.test", tenant: auth_organization:alpha, max_message_bytes: 52428800, accounts: [{ account: $jean, quota_full: false }] };
    RETURN fn::mail_recipient_resolve({ address: "Jean@ALPHA.test" }).data == $expected
        AND fn::mail_recipient_resolve({ address: "jean+devis@alpha.test" }).data == $expected;
};

-- test: résolution : alias développé, comptes triés
-- en tant que: worker
RETURN fn::mail_recipient_resolve({ address: "equipe@alpha.test" }).data.{ address, accounts }
    == { address: "equipe@alpha.test", accounts: array::sort::asc([type::record(fn::essai_id("jean")), type::record(fn::essai_id("marie"))]).map(|$a| { account: $a, quota_full: false }) };

-- test: aucun relais : domaine étranger, adresse littérale, route par pourcentage vers l'extérieur
-- en tant que: worker
RETURN ["jean@ailleurs.test", "jean@[127.0.0.1]", "jean@127.0.0.1", "jean%alpha.test@ailleurs.test", "jean@alpha.test.ailleurs.test"].all(|$a|
    fn::mail_recipient_resolve({ address: $a }).error.{ code, details } == { code: "MAIL_RELAY_DENIED", details: {} });

-- test: destinataire inconnu : adresse absente, route par pourcentage, sans domaine ; aucun attrape-tout par défaut
-- en tant que: worker
RETURN ["inconnu@alpha.test", "jean%ailleurs.test@alpha.test", "sans-domaine", "@alpha.test", "postmaster@alpha.test", "postmaster"].all(|$a|
    fn::mail_recipient_resolve({ address: $a }).error.{ code, details } == { code: "MAIL_RECIPIENT_UNKNOWN", details: {} });

-- test: entrées refusées par lyxal_core : adresse absente, trop longue, non ASCII, clé inconnue
-- en tant que: worker
RETURN [{}, { address: string::concat(string::repeat("a", 250), "@alpha.test") }, { address: "jéan@alpha.test" }, { address: "jean@alpha.test", autre: 1 }].all(|$p|
    fn::mail_recipient_resolve($p).error.code == "MAIL_INVALID_PARAMETERS");

-- test: postmaster du domaine : compte désigné par l'administrateur, à défaut d'adresse inscrite
-- en tant que: admin
{
    LET $set = fn::mail_domain_update({ domain: fn::essai_id("domain"), postmaster: fn::essai_id("marie") });
    RETURN $set.data.postmaster == type::record(fn::essai_id("marie")) AND $set.data.catch_all IS NONE;
};

-- test: postmaster@domaine résolu vers ce compte, sous-adresse comprise ; les autres adresses restent inconnues
-- en tant que: worker
RETURN fn::mail_recipient_resolve({ address: "Postmaster@alpha.test" }).data.{ address, accounts } == { address: "postmaster@alpha.test", accounts: [{ account: type::record(fn::essai_id("marie")), quota_full: false }] }
    AND fn::mail_recipient_resolve({ address: "postmaster+abus@alpha.test" }).data.accounts.account == [type::record(fn::essai_id("marie"))]
    AND fn::mail_recipient_resolve({ address: "inconnu@alpha.test" }).error.code == "MAIL_RECIPIENT_UNKNOWN"
    AND fn::mail_recipient_resolve({ address: "postmaster@beta.test" }).error.code == "MAIL_RECIPIENT_UNKNOWN";

-- test: attrape-tout : compte désigné par l'administrateur ; compte d'une autre organisation ou inconnu refusé
-- en tant que: admin
RETURN fn::mail_domain_update({ domain: fn::essai_id("domain"), catch_all: fn::essai_id("autre") }).error.code == "MAIL_ACCOUNT_NOT_FOUND"
    AND fn::mail_domain_update({ domain: fn::essai_id("domain"), catch_all: "mail_account:absent" }).error.code == "MAIL_ACCOUNT_NOT_FOUND"
    AND fn::mail_domain_update({ domain: fn::essai_id("domain"), clear: ["inconnu"] }).error.code == "MAIL_INVALID_PARAMETERS"
    AND fn::mail_domain_update({ domain: fn::essai_id("domain"), catch_all: fn::essai_id("paul") }).data.{ catch_all, postmaster } == { catch_all: type::record(fn::essai_id("paul")), postmaster: type::record(fn::essai_id("marie")) };

-- test: attrape-tout : une adresse inconnue du domaine arrive au compte désigné, sous l'adresse demandée ; postmaster garde son compte
-- en tant que: worker
RETURN fn::mail_recipient_resolve({ address: "Inconnu@alpha.test" }).data.{ address, accounts } == { address: "inconnu@alpha.test", accounts: [{ account: type::record(fn::essai_id("paul")), quota_full: false }] }
    AND fn::mail_recipient_resolve({ address: "postmaster@alpha.test" }).data.accounts.account == [type::record(fn::essai_id("marie"))]
    AND fn::mail_recipient_resolve({ address: "inconnu@beta.test" }).error.code == "MAIL_RECIPIENT_UNKNOWN";

-- test: écriture directe : la base refuse un attrape-tout d'une autre organisation
-- attendu-erreur: MAIL_WRITE_FORBIDDEN
UPDATE type::record(fn::essai_id("domain")) SET catch_all = type::record(fn::essai_id("autre"));

-- test: écriture directe : un domaine ne se crée pas avec un attrape-tout
-- attendu-erreur: MAIL_WRITE_FORBIDDEN
{
    CREATE auth_organization_domain:alpha3 CONTENT { organization: auth_organization:alpha, domain: "alpha3.test", state: "verified", challenge_hash: "af1349b9f5f9a1a6a0404dea36dcc9499bcb25c9adc112b7cc9a93cae41f3262" };
    CREATE mail_domain CONTENT { tenant: auth_organization:alpha, auth_domain: auth_organization_domain:alpha3, name: "alpha3.test", catch_all: type::record(fn::essai_id("paul")) };
};

-- préparation: adresse postmaster inscrite (alias vers jean), adresse inscrite puis désactivée
{
    fn::mail_address_create({ domain: fn::essai_id("domain"), local_part: "postmaster", kind: "alias", targets: [fn::essai_id("jean")] });
    LET $old = fn::mail_address_create({ domain: fn::essai_id("domain"), local_part: "ancien", kind: "account", account: fn::essai_id("jean") }).data.id;
    fn::mail_address_update({ address: <string> $old, state: "disabled" });
};

-- test: une adresse postmaster inscrite l'emporte sur le compte du domaine ; une adresse désactivée n'est pas rattrapée par l'attrape-tout
-- en tant que: worker
RETURN fn::mail_recipient_resolve({ address: "postmaster@alpha.test" }).data.accounts.account == [type::record(fn::essai_id("jean"))]
    AND fn::mail_recipient_resolve({ address: "ancien@alpha.test" }).error.code == "MAIL_RECIPIENT_UNKNOWN";

-- test: postmaster sans domaine : réglage de l'installation seulement, rangé en minuscules
-- en tant que: plateforme
RETURN fn::mail_settings_set({ postmaster: " Postmaster@Alpha.test " }).data.postmaster == "postmaster@alpha.test"
    AND fn::mail_settings_set({ postmaster: "pas-une-adresse" }).error.code == "MAIL_INVALID_PARAMETERS"
    AND fn::mail_settings_get({}).data.own.postmaster == "postmaster@alpha.test";

-- test: un administrateur d'organisation ne pose pas ce réglage, même dans son organisation
-- en tant que: admin
RETURN fn::mail_settings_set({ tenant: "auth_organization:alpha", postmaster: "jean@alpha.test" }).error.details == { fields: { postmaster: ["installation_only"] } }
    AND fn::mail_settings_set({ postmaster: "jean@alpha.test" }).error.code == "MAIL_PERMISSION_DENIED";

-- test: <postmaster> sans domaine résolu vers l'adresse du réglage
-- en tant que: worker
RETURN fn::mail_recipient_resolve({ address: "POSTMASTER" }).data.{ address, domain, accounts } == { address: "postmaster@alpha.test", domain: "alpha.test", accounts: [{ account: type::record(fn::essai_id("jean")), quota_full: false }] };

-- test: réglage effacé : <postmaster> sans domaine redevient inconnu
{
    LET $cleared = fn::mail_settings_set({ clear: ["postmaster"] }).data.postmaster;
    RETURN $cleared IS NONE AND fn::mail_recipient_resolve({ address: "postmaster" }).error.code == "MAIL_RECIPIENT_UNKNOWN";
};

-- préparation: quota de marie atteint, taille maximale de beta réduite, compte de paul désactivé
{
    fn::mail_account_update({ account: fn::essai_id("marie"), quota_bytes: 0 });
    fn::mail_settings_set({ tenant: "auth_organization:beta", max_message_bytes: 2048 });
    fn::mail_account_update({ account: fn::essai_id("paul"), state: "disabled" });
};

-- test: quota plein signalé par compte (alias compris) ; taille de l'organisation ; compte désactivé
-- en tant que: worker
RETURN fn::mail_recipient_resolve({ address: "marie@alpha.test" }).data.accounts == [{ account: type::record(fn::essai_id("marie")), quota_full: true }]
    AND array::sort::asc(fn::mail_recipient_resolve({ address: "equipe@alpha.test" }).data.accounts.quota_full) == [false, true]
    AND fn::mail_recipient_resolve({ address: "autre@beta.test" }).data.max_message_bytes == 2048
    AND fn::mail_recipient_resolve({ address: "paul@alpha.test" }).error.{ code, details } == { code: "MAIL_RECIPIENT_DISABLED", details: {} }
    AND fn::mail_recipient_resolve({ address: "inconnu@alpha.test" }).error.code == "MAIL_RECIPIENT_DISABLED";

-- test: un compte désactivé ne devient pas attrape-tout ni postmaster
-- en tant que: admin
RETURN fn::mail_domain_update({ domain: fn::essai_id("domain"), postmaster: fn::essai_id("paul") }).error.code == "MAIL_ACCOUNT_DISABLED";

-- test: compte attrape-tout supprimé : le domaine n'a plus d'attrape-tout, l'adresse redevient inconnue
{
    fn::mail_account_update({ account: fn::essai_id("paul"), state: "active" });
    fn::mail_account_delete({ account: fn::essai_id("paul") });
    RETURN fn::mail_domain_get({ domain: fn::essai_id("domain") }).data.{ catch_all, postmaster } == { catch_all: NONE, postmaster: type::record(fn::essai_id("marie")) }
        AND fn::mail_recipient_resolve({ address: "inconnu@alpha.test" }).error.code == "MAIL_RECIPIENT_UNKNOWN"
        AND fn::mail_domain_update({ domain: fn::essai_id("domain"), catch_all: fn::essai_id("paul") }).error.code == "MAIL_ACCOUNT_DELETING"
        AND fn::mail_domain_update({ domain: fn::essai_id("domain"), clear: ["postmaster"] }).data.postmaster IS NONE;
};

-- test: comptes d'une adresse (interne) : état et quota par compte, comptes absents ignorés
RETURN fn::mail_recipient_accounts([type::record(fn::essai_id("marie")), mail_account:absent], NONE) == [{ account: type::record(fn::essai_id("marie")), state: "active", quota_full: true }]
    AND fn::mail_recipient_accounts([type::record(fn::essai_id("jean"))], 0)[0].quota_full == true;

-- préparation: quota de marie retiré
fn::mail_account_update({ account: fn::essai_id("marie"), quota_bytes: 1000 });

-- test: ouverture d'une remise : contenu réservé, clé du fichier sous le compte ; entrées refusées par lyxal_core
-- en tant que: worker
{
    LET $begun = fn::mail_delivery_begin({ account: fn::essai_id("jean"), size: 300, delivery_key: fn::essai_cle(900) });
    LET $content = (SELECT * FROM ONLY $begun.data.content);
    RETURN $begun.data.keys().sort() == ["content", "duplicate", "storage_key"] AND $begun.data.duplicate == false
        AND string::starts_with($begun.data.storage_key, string::concat(<string> record::id(type::record(fn::essai_id("jean"))), "/")) AND string::ends_with($begun.data.storage_key, ".eml")
        AND $content.{ state, size, protection, refs, key } == { state: "pending", size: 300, protection: "platform", refs: 0, key: $begun.data.storage_key }
        AND [{ account: fn::essai_id("jean"), size: 300 }, { account: fn::essai_id("jean"), size: 300, delivery_key: "abc" }, { account: fn::essai_id("jean"), size: 300, delivery_key: string::repeat("z", 64) },
             { account: fn::essai_id("jean"), size: 0, delivery_key: fn::essai_cle(1) }, { account: "mail_mailbox:x", size: 1, delivery_key: fn::essai_cle(1) }]
            .all(|$p| fn::mail_delivery_begin($p).error.code == "MAIL_INVALID_PARAMETERS");
};

-- test: ouverture refusée : compte absent, taille de l'organisation, quota (événement unique), compte en suppression
-- en tant que: worker
RETURN fn::mail_delivery_begin({ account: "mail_account:absent", size: 10, delivery_key: fn::essai_cle(1) }).error.code == "MAIL_ACCOUNT_NOT_FOUND"
    AND fn::mail_delivery_begin({ account: fn::essai_id("autre"), size: 4096, delivery_key: fn::essai_cle(1) }).error.details == { size: 4096, max_message_bytes: 2048 }
    AND fn::mail_delivery_begin({ account: fn::essai_id("marie"), size: 2000, delivery_key: fn::essai_cle(1) }).error.code == "MAIL_QUOTA_EXCEEDED"
    AND fn::mail_delivery_begin({ account: fn::essai_id("marie"), size: 2000, delivery_key: fn::essai_cle(1) }).error.details == { quota_bytes: 1000, used_bytes: 0 }
    AND fn::mail_delivery_begin({ account: fn::essai_id("paul"), size: 10, delivery_key: fn::essai_cle(1) }).error.code == "MAIL_ACCOUNT_DELETING";

-- test: un seul événement de dépassement de quota pour les deux refus
RETURN (SELECT VALUE payload FROM event_outbox WHERE event_type = "mail.quota.exceeded") == [{ account_id: fn::essai_id("marie"), tenant: "auth_organization:alpha", quota_bytes: 1000, used_bytes: 0 }];

-- test: remise d'un message : inscrit dans la boîte de réception, origine delivery, résultats de réception, fiche d'idempotence de 7 jours
-- en tant que: worker
{
    LET $item = fn::essai_element(fn::essai_id("jean"), 1, { size: 120, has_attachment: true, in_reply_to: ["parent@ailleurs.test"] });
    LET $done = fn::mail_delivery_commit({ account: fn::essai_id("jean"), items: [$item] });
    LET $row = $done.data.items[0];
    LET $message = (SELECT * FROM ONLY $row.message);
    LET $kept = (SELECT * FROM ONLY fn::mail_delivery_key(type::record(fn::essai_id("jean")), fn::essai_cle(1)));
    CREATE passe:m1 CONTENT { message: <string> $row.message, content: $item.content };
    RETURN $done.ok AND $row.keys().sort() == ["duplicate", "mailbox", "message", "uid"]
        AND $row.{ uid, mailbox, duplicate } == { uid: 1, mailbox: type::record(fn::essai_id("jean_inbox")), duplicate: false }
        AND $message.{ origin, uid, size, seen, has_attachment, protection, thread_orphan, message_id, owner }
            == { origin: "delivery", uid: 1, size: 120, seen: false, has_attachment: true, protection: "platform", thread_orphan: true, message_id: "m1@ailleurs.test", owner: auth_identity:jean }
        AND $message.reception == { spf: "pass", dkim: "pass", dmarc: "pass", iprev: "pass", antivirus: "not_scanned", spam: "none", tls: true }
        AND $message.modseq == $message.create_modseq AND $message.envelope.subject == "Devis confidentiel"
        AND (SELECT VALUE [state, refs, object] FROM ONLY type::record($item.content)) == ["stored", 1, type::record($item.object)]
        AND $kept.{ tenant, account, message } == { tenant: auth_organization:alpha, account: type::record(fn::essai_id("jean")), message: $row.message }
        AND $kept.expires_at > time::now() + 6d AND $kept.expires_at <= time::now() + 7d
        AND fn::essai_coherent(fn::essai_id("jean"));
};

-- test: événement mail.message.received : un seul, pour ce compte, sans adresse, domaine, sujet ni Message-ID
{
    LET $events = fn::essai_recus(fn::essai_id("jean"));
    LET $message = (SELECT * FROM ONLY type::record((SELECT VALUE message FROM ONLY passe:m1)));
    LET $text = <string> $events[0];
    RETURN array::len($events) == 1 AND array::len(SELECT * FROM event_outbox WHERE event_type = "mail.message.received") == 1
        AND $events[0].keys().sort() == ["account", "email_id", "has_attachment", "mailbox", "message", "protection", "received_at", "reception", "size", "tenant"]
        AND $events[0].{ tenant, account, mailbox, message, email_id, size, has_attachment, protection }
            == { tenant: "auth_organization:alpha", account: fn::essai_id("jean"), mailbox: fn::essai_id("jean_inbox"), message: <string> $message.id, email_id: $message.email_id, size: 120, has_attachment: true, protection: "platform" }
        AND <datetime> $events[0].received_at == $message.received_at
        AND $events[0].reception == { spf: "pass", dkim: "pass", dmarc: "pass", iprev: "pass", antivirus: "not_scanned", spam: "none", tls: true }
        AND ["@", "alpha.test", "ailleurs", "Devis", "jean"].all(|$word| !string::contains(string::replace($text, "auth_organization:alpha", ""), $word))
        AND (SELECT VALUE [producer, source] FROM event_outbox WHERE event_type = "mail.message.received") == [["lyxal_mail", $message.id]];
};

-- test: nouvel essai de l'expéditeur : le compte déjà servi répond « déjà remis », rien n'est réservé ni inscrit
-- en tant que: worker
{
    LET $contents = array::len(SELECT VALUE id FROM mail_content);
    LET $again = fn::mail_delivery_begin({ account: fn::essai_id("jean"), size: 120, delivery_key: fn::essai_cle(1) });
    RETURN $again.data == { duplicate: true, message: type::record((SELECT VALUE message FROM ONLY passe:m1)) }
        AND array::len(SELECT VALUE id FROM mail_content) == $contents
        AND fn::mail_delivery_begin({ account: fn::essai_id("marie"), size: 120, delivery_key: fn::essai_cle(1) }).data.duplicate == false;
};

-- test: même message présenté deux fois à l'inscription (deux nœuds) : le second est reconnu, un seul message, un seul événement
-- en tant que: worker
{
    LET $account = fn::essai_id("jean");
    LET $first = fn::essai_element($account, 2, {});
    LET $second = fn::essai_element($account, 2, {});
    LET $done = fn::mail_delivery_commit({ account: $account, items: [$first, $second] }).data.items;
    LET $later = fn::mail_delivery_commit({ account: $account, items: [$second] }).data.items;
    RETURN $done[0].{ uid, duplicate } == { uid: 2, duplicate: false }
        AND $done[1] == { message: $done[0].message, uid: 2, mailbox: type::record(fn::essai_id("jean_inbox")), duplicate: true }
        AND $later == [$done[1]]
        AND (SELECT VALUE state FROM ONLY type::record($second.content)) == "pending"
        AND array::len(SELECT VALUE id FROM mail_message WHERE account = type::record($account)) == 2
        AND fn::essai_coherent($account);
};

-- test: lot de 32 : UID et numéros de modification croissants, compteurs égaux au contenu, un événement par message
-- en tant que: worker
{
    LET $account = fn::essai_id("jean");
    LET $start = (SELECT modseq, message_count, used_bytes FROM ONLY type::record($account));
    LET $items = (<array> (0..32)).map(|$i| fn::essai_element($account, 100 + $i, { size: 50 + $i }));
    LET $done = fn::mail_delivery_commit({ account: $account, items: $items });
    LET $end = (SELECT modseq, message_count, used_bytes FROM ONLY type::record($account));
    LET $rows = (SELECT uid, modseq, size FROM $done.data.items.message);
    RETURN array::len($done.data.items) == 32 AND $done.data.items.all(|$i| $i.error IS NONE AND !$i.duplicate)
        AND $done.data.items.uid == (<array> (3..35))
        AND array::sort::asc($rows.modseq) == array::map(<array> (1..33), |$i| $start.modseq + $i)
        AND $end.{ modseq, message_count } == { modseq: $start.modseq + 32, message_count: $start.message_count + 32 }
        AND $end.used_bytes == $start.used_bytes + math::sum($items.map(|$i| $i.structure.size))
        AND (SELECT VALUE [total, unseen, uid_next] FROM ONLY type::record(fn::essai_id("jean_inbox"))) == [34, 34, 35]
        AND fn::essai_coherent($account);
};

-- test: lot de 33 refusé en entier, rien d'inscrit ; lot vide et élément mal formé refusés par lyxal_core
-- en tant que: worker
{
    LET $account = fn::essai_id("jean");
    LET $count = array::len(SELECT VALUE id FROM mail_message WHERE account = type::record($account));
    LET $item = fn::essai_element($account, 200, {});
    LET $refused = fn::mail_delivery_commit({ account: $account, items: (<array> (0..33)).map(|$i| $item) });
    RETURN $refused.error.{ code, details } == { code: "MAIL_DELIVERY_BATCH_TOO_LARGE", details: { max_items: 32 } }
        AND array::len(SELECT VALUE id FROM mail_message WHERE account = type::record($account)) == $count
        AND [[], [object::remove($item, "reception")], [object::extend($item, { reception: object::extend($item.reception, { spf: "certain" }) })], [object::extend($item, { role: "trash" })],
             [object::extend($item, { delivery_key: "x" })], [object::extend($item, { envelope: "texte" })], [object::extend($item, { autre: 1 })], [object::remove($item, "structure")]]
            .all(|$items| fn::mail_delivery_commit({ account: $account, items: $items }).error.code == "MAIL_INVALID_PARAMETERS")
        AND fn::mail_delivery_commit({ account: "mail_account:absent", items: [$item] }).error.code == "MAIL_ACCOUNT_NOT_FOUND";
};

-- test: un élément en erreur n'annule pas les autres : contenu d'un autre compte, fichier d'une autre taille, contenu déjà inscrit
-- en tant que: worker
{
    LET $account = fn::essai_id("jean");
    LET $good = fn::essai_element($account, 300, {});
    LET $foreign = fn::essai_element(fn::essai_id("marie"), 301, {});
    LET $wrong = fn::essai_element($account, 302, {});
    LET $short = object::extend($wrong, { object: fn::essai_fichier($account, string::concat(<string> record::id(type::record($account)), "/autre.eml"), 7) });
    LET $used = object::extend(fn::essai_element($account, 303, {}), { content: (SELECT VALUE content FROM ONLY passe:m1) });
    LET $last = fn::essai_element($account, 304, {});
    LET $done = fn::mail_delivery_commit({ account: $account, items: [$good, $foreign, $short, $used, $last] }).data.items;
    RETURN $done[0].{ uid, duplicate } == { uid: 35, duplicate: false } AND $done[4].{ uid, duplicate } == { uid: 36, duplicate: false }
        AND [$done[1], $done[2], $done[3]].all(|$i| $i.keys() == ["error"])
        AND [$done[1], $done[2], $done[3]].error.code == ["MAIL_CONTENT_NOT_FOUND", "MAIL_CONTENT_STATE_INVALID", "MAIL_CONTENT_STATE_INVALID"]
        AND $done[1].error.label == "Contenu introuvable"
        AND (SELECT VALUE state FROM ONLY type::record($wrong.content)) == "pending"
        AND !record::exists(fn::mail_delivery_key(type::record($account), fn::essai_cle(302)))
        AND fn::essai_coherent($account);
};

-- test: quota atteint au milieu d'un lot : les suivants sont refusés un par un, les premiers restent inscrits
-- en tant que: worker
{
    LET $account = fn::essai_id("marie");
    LET $items = (<array> (0..3)).map(|$i| fn::essai_element($account, 400 + $i, { size: 400 }));
    LET $done = fn::mail_delivery_commit({ account: $account, items: $items }).data.items;
    RETURN $done[0].uid == 1 AND $done[1].uid == 2 AND $done[2].error.code == "MAIL_QUOTA_EXCEEDED" AND $done[2].error.details == { quota_bytes: 1000, used_bytes: 800 }
        AND (SELECT VALUE used_bytes FROM ONLY type::record($account)) == 800
        AND fn::essai_coherent($account);
};

-- test: dossier Junk (quarantaine DMARC) ; dossier Junk supprimé par son titulaire : boîte de réception
-- en tant que: worker
{
    LET $account = fn::essai_id("autre");
    LET $junk = fn::mail_delivery_commit({ account: $account, items: [fn::essai_element($account, 500, { role: "junk", reception: { spf: "fail", dkim: "none", dmarc: "fail", iprev: "fail", antivirus: "clean", spam: "none", tls: false } })] }).data.items[0];
    LET $box = (SELECT role FROM ONLY $junk.mailbox);
    DELETE $junk.message;
    DELETE $junk.mailbox;
    LET $inbox = fn::mail_delivery_commit({ account: $account, items: [fn::essai_element($account, 501, { role: "junk" })] }).data.items[0];
    RETURN $box.role == "junk" AND (SELECT VALUE role FROM ONLY $inbox.mailbox) == "inbox" AND $inbox.uid == 1
        AND (SELECT VALUE origin FROM ONLY $inbox.message) == "delivery";
};

-- test: message effacé par son titulaire : un nouvel essai de l'expéditeur ne le remet pas
-- en tant que: worker
RETURN fn::mail_delivery_begin({ account: fn::essai_id("autre"), size: 100, delivery_key: fn::essai_cle(500) }).data.duplicate == true;

-- test: aucun événement de réception pour une copie, un déplacement ou un dépôt du titulaire ; origines posées, sans résultats de réception
-- en tant que: jean
{
    LET $m1 = (SELECT VALUE message FROM ONLY passe:m1);
    LET $copied = fn::mail_message_copy({ messages: [$m1], mailbox: fn::essai_id("jean_archive") }).data.copied[0].id;
    LET $moved = fn::mail_message_move({ messages: [$m1], mailbox: fn::essai_id("jean_archive") }).data.moved[0].id;
    RETURN (SELECT VALUE [origin, reception] FROM [$copied, $moved]) == [["copy", NONE], ["move", NONE]]
        AND (SELECT VALUE uid FROM ONLY $moved) == 2;
};

-- préparation: contenu stocké pour jean, inscrit par la session système comme un dépôt du titulaire (APPEND)
{
    LET $reserved = fn::mail_content_begin({ account: fn::essai_id("jean"), size: 10 }).data;
    fn::mail_content_attach({ content: <string> $reserved.content, object: fn::essai_fichier(fn::essai_id("jean"), $reserved.key, 10) });
    LET $appended = fn::mail_message_create({ content: <string> $reserved.content, mailbox: fn::essai_id("jean_inbox"), received_at: time::now(), envelope: { subject: "x" }, structure: { type: "text/plain" } }).data;
    CREATE passe:append CONTENT { origin: $appended.origin, reception: $appended.reception, content: <string> $reserved.content };
};

-- test: dépôt du titulaire : origine append, aucun événement de réception
RETURN (SELECT VALUE [origin, reception] FROM ONLY passe:append) == ["append", NONE]
    AND array::len(fn::essai_recus(fn::essai_id("jean"))) == 36
    AND array::sort::asc(fn::essai_recus(fn::essai_id("autre")).reception.dmarc) == ["fail", "pass"];

-- test: écriture directe : un titulaire n'inscrit pas un message d'origine delivery
-- en tant que: jean
-- attendu-erreur: MAIL_WRITE_FORBIDDEN
{
    LET $source = (SELECT * FROM ONLY mail_message WHERE account = type::record(fn::essai_id("jean")) AND mailbox = type::record(fn::essai_id("jean_inbox")) LIMIT 1);
    CREATE fn::mail_message_key($source.mailbox, 5000) CONTENT {
        tenant: $source.tenant, account: $source.account, owner: $source.owner, mailbox: $source.mailbox, content: $source.content, origin: "delivery",
        reception: { spf: "pass", dkim: "pass", dmarc: "pass", iprev: "pass", antivirus: "clean", spam: "none", tls: true },
        uid: 5000, modseq: 100000, create_modseq: 100000, thread: "t", received_at: time::now(), size: $source.size
    };
};

-- test: écriture directe : des résultats de réception sans origine delivery sont refusés
-- attendu-erreur: MAIL_WRITE_FORBIDDEN
{
    LET $source = (SELECT * FROM ONLY mail_message WHERE account = type::record(fn::essai_id("jean")) AND mailbox = type::record(fn::essai_id("jean_inbox")) LIMIT 1);
    CREATE fn::mail_message_key($source.mailbox, 5000) CONTENT {
        tenant: $source.tenant, account: $source.account, owner: $source.owner, mailbox: $source.mailbox, content: $source.content, origin: "append",
        reception: { spf: "pass", dkim: "pass", dmarc: "pass", iprev: "pass", antivirus: "clean", spam: "none", tls: true },
        uid: 5000, modseq: 100000, create_modseq: 100000, thread: "t", received_at: time::now(), size: $source.size
    };
};

-- test: écriture directe : une remise sans tous ses résultats de réception est refusée, même par le service
-- attendu-erreur: MAIL_WRITE_FORBIDDEN
{
    LET $source = (SELECT * FROM ONLY mail_message WHERE account = type::record(fn::essai_id("jean")) AND mailbox = type::record(fn::essai_id("jean_inbox")) LIMIT 1);
    CREATE fn::mail_message_key($source.mailbox, 5000) CONTENT {
        tenant: $source.tenant, account: $source.account, owner: $source.owner, mailbox: $source.mailbox, content: $source.content, origin: "delivery",
        reception: { spf: "pass", dkim: "pass" },
        uid: 5000, modseq: 100000, create_modseq: 100000, thread: "t", received_at: time::now(), size: $source.size
    };
};

-- test: règle d'entrée des résultats de réception (interne) : sept champs exigés, mots de la RFC 8601
{
    LET $check = |$reception| fn::validation_fields_execute({ r: $reception }, { r: fn::mail_reception_rule() }, "reject");
    LET $full = { spf: "softfail", dkim: "policy", dmarc: "temperror", iprev: "permerror", antivirus: "clean", spam: "none", tls: false };
    LET $reports = [$full, NONE, object::remove($full, "tls"), object::extend($full, { iprev: "none" }), object::extend($full, { domaine: "alpha.test" })].map(|$reception| $check($reception));
    RETURN $reports.valid == [true, false, false, false, false]
        AND $reports[2].by_field.keys() == ["r.tls"]
        AND $reports[3].by_field.keys() == ["r.iprev"]
        AND $reports[4].by_field.keys() == ["r.domaine"];
};

-- test: élément remis directement (interne) : mêmes contrôles, sans validation des entrées
{
    LET $account = type::record(fn::essai_id("jean"));
    LET $settings = fn::mail_settings_effective({ tenant: auth_organization:alpha });
    LET $item = object::extend({ role: "inbox", in_reply_to: [], references: [], is_report: false, has_attachment: false }, fn::essai_element(fn::essai_id("jean"), 600, {}));
    LET $typed = object::extend($item, { content: type::record($item.content), object: type::record($item.object) });
    LET $small = fn::mail_delivery_item($account, $typed, object::extend($settings, { max_message_bytes: 10 }), "en");
    LET $done = fn::mail_delivery_item($account, $typed, $settings, "fr");
    RETURN $small.error.{ code, label } == { code: "MAIL_MESSAGE_TOO_LARGE", label: "Message too large" }
        AND $done.duplicate == false AND fn::mail_delivery_item($account, $typed, $settings, "fr") == object::extend($done, { duplicate: true });
};

-- préparation: fiches d'idempotence échues (écrites par la session système)
{
    CREATE fn::mail_delivery_key(type::record(fn::essai_id("jean")), fn::essai_cle(700)) CONTENT { tenant: auth_organization:alpha, account: type::record(fn::essai_id("jean")), message: mail_message:ancien, expires_at: time::now() - 1h };
    CREATE fn::mail_delivery_key(type::record(fn::essai_id("jean")), fn::essai_cle(701)) CONTENT { tenant: auth_organization:alpha, account: type::record(fn::essai_id("jean")), message: mail_message:ancien, expires_at: time::now() - 2h };
    CREATE fn::mail_delivery_key(type::record(fn::essai_id("jean")), fn::essai_cle(702)) CONTENT { tenant: auth_organization:alpha, account: type::record(fn::essai_id("jean")), message: mail_message:ancien, expires_at: time::now() - 3h };
};

-- test: une fiche échue n'est plus un doublon : le message est remis à nouveau
-- en tant que: worker
{
    LET $begun = fn::mail_delivery_begin({ account: fn::essai_id("jean"), size: 100, delivery_key: fn::essai_cle(700) });
    LET $done = fn::mail_delivery_commit({ account: fn::essai_id("jean"), items: [fn::essai_element(fn::essai_id("jean"), 700, {})] }).data.items[0];
    RETURN $begun.data.duplicate == false AND $done.duplicate == false
        AND (SELECT VALUE message FROM ONLY fn::mail_delivery_key(type::record(fn::essai_id("jean")), fn::essai_cle(700))) == $done.message;
};

-- test: purge des fiches d'idempotence échues, par lots ; les fiches en cours restent
-- en tant que: worker
{
    LET $kept = array::len(SELECT VALUE id FROM mail_delivery WHERE expires_at > time::now());
    LET $first = fn::mail_delivery_purge({ limit: 1 }).data;
    LET $second = fn::mail_delivery_purge({}).data;
    LET $third = fn::mail_delivery_purge({}).data;
    RETURN $first == { removed: 1 } AND $second == { removed: 1 } AND $third == { removed: 0 }
        AND !record::exists(fn::mail_delivery_key(type::record(fn::essai_id("jean")), fn::essai_cle(702)))
        AND array::len(SELECT VALUE id FROM mail_delivery) == $kept AND $kept > 30
        AND fn::mail_delivery_purge({ limit: 0 }).error.code == "MAIL_INVALID_PARAMETERS";
};

-- préparation: élément de remise prêt pour marie (inscrit après la désactivation de son compte)
{
    LET $account = fn::essai_id("marie");
    LET $item = fn::essai_element($account, 800, { size: 10 });
    CREATE passe:refus CONTENT { item: $item };
};

-- préparation: compte de marie désactivé
fn::mail_account_update({ account: fn::essai_id("marie"), state: "disabled" });

-- test: compte désactivé : ni ouverture ni inscription
-- en tant que: worker
RETURN fn::mail_delivery_begin({ account: fn::essai_id("marie"), size: 10, delivery_key: fn::essai_cle(801) }).error.code == "MAIL_ACCOUNT_DISABLED"
    AND fn::mail_delivery_commit({ account: fn::essai_id("marie"), items: [(SELECT VALUE item FROM ONLY passe:refus)] }).error.code == "MAIL_ACCOUNT_DISABLED"
    AND fn::mail_delivery_begin({ account: fn::essai_id("marie"), size: 400, delivery_key: fn::essai_cle(400) }).data.duplicate == true;
