-- lyxal-test: assertions
-- Contenus : réservation (compte, taille, quota et événement unique de dépassement), lien au
-- fichier de lyxal_storage (bucket chiffré lyxal-mail de l'organisation, clé, taille, délai),
-- lecture, contenu partagé par les copies, libération au dernier lecteur, retrait du contenu et
-- de son fichier dans la même transaction (abandonnés, libérés), purge d'un compte supprimé.
--
-- identité admin: { "id": "auth_session:admin", "pv": 1, "permissions": ["mail.domain.manage", "mail.mailbox.access", "auth.member.read", "auth.organization.settings.manage"] }
-- identité jean: { "id": "auth_session:jean", "pv": 1, "permissions": ["mail.mailbox.access"] }
-- identité marie: { "id": "auth_session:marie", "pv": 1, "permissions": ["mail.mailbox.access"] }
-- identité membre: { "id": "auth_session:membre", "pv": 1, "permissions": [] }
-- identité autre: { "id": "auth_session:autre", "pv": 1, "permissions": ["mail.domain.manage", "mail.mailbox.access", "auth.member.read", "auth.organization.settings.manage"] }
-- identité worker: { "id": "auth_session:worker", "pv": 1, "permissions": ["mail.worker"] }
-- identité plateforme: { "id": "auth_session:plateforme", "pv": 1, "permissions": ["mail.installation.manage"] }

-- préparation: organisations alpha et beta, identités et sessions lyxal_auth, domaines vérifiés, table de passage
{
    CREATE auth_organization:alpha CONTENT { slug: "alpha", name: "Alpha BTP" };
    CREATE auth_organization:beta CONTENT { slug: "beta", name: "Beta Bois" };
    FOR $person IN [["admin", "alpha"], ["jean", "alpha"], ["marie", "alpha"], ["membre", "alpha"], ["autre", "beta"]] {
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
    CREATE auth_organization_domain:alpha2 CONTENT { organization: auth_organization:alpha, domain: "alpha2.test", state: "verified", challenge_hash: "af1349b9f5f9a1a6a0404dea36dcc9499bcb25c9adc112b7cc9a93cae41f3262" };
    CREATE auth_organization_domain:attente CONTENT { organization: auth_organization:alpha, domain: "attente.test", challenge_hash: "af1349b9f5f9a1a6a0404dea36dcc9499bcb25c9adc112b7cc9a93cae41f3262" };
    CREATE auth_organization_domain:beta CONTENT { organization: auth_organization:beta, domain: "beta.test", state: "verified", challenge_hash: "af1349b9f5f9a1a6a0404dea36dcc9499bcb25c9adc112b7cc9a93cae41f3262" };
    DEFINE TABLE OVERWRITE passe SCHEMALESS PERMISSIONS FULL;
};

-- préparation: aides d'essai (session système) : contenu déposé dans le bucket chiffré, message inscrit, compteurs recalculés
{
    DEFINE FUNCTION OVERWRITE fn::essai_contenu($account: string, $size: int) -> string {
        LET $tenant = (SELECT VALUE tenant FROM ONLY type::record($account));
        LET $existing = (SELECT VALUE id FROM ONLY storage_bucket WHERE tenant = $tenant AND name = "lyxal-mail" LIMIT 1);
        LET $bucket = $existing ?? fn::storage_bucket_create({ tenant: <string> $tenant, name: "lyxal-mail", encrypted: true }).data.id;
        LET $reserved = fn::mail_content_begin({ account: $account, size: $size }).data;
        LET $object = fn::storage_object_begin({ bucket: <string> $bucket, key: $reserved.key, filename: "message.eml", declared_size: $size }).data;
        fn::storage_object_commit({ object: <string> $object.id, size: $size, content_type: "message/rfc822", blake3: "af1349b9f5f9a1a6a0404dea36dcc9499bcb25c9adc112b7cc9a93cae41f3262", content_key: "enc:v2:essai-files-1:QUJD" });
        fn::mail_content_attach({ content: <string> $reserved.content, object: <string> $object.id });
        RETURN <string> $reserved.content;
    };
    DEFINE FUNCTION OVERWRITE fn::essai_message($account: string, $mailbox: string, $extra: object) -> object {
        LET $content = fn::essai_contenu($account, $extra.size ?? 100);
        RETURN fn::mail_message_create(object::extend({
            content: $content, mailbox: $mailbox, received_at: time::now(),
            envelope: { subject: "Essai", from: [{ name: "Expéditeur", address: "exp@ailleurs.test" }] }, structure: { type: "text/plain", size: 100 }
        }, object::remove($extra, "size")));
    };
    DEFINE FUNCTION OVERWRITE fn::essai_coherent($account: string) -> bool {
        LET $id = type::record($account);
        LET $boxes = (SELECT id, total, unseen, size FROM mail_mailbox WHERE account = $id);
        LET $messages = (SELECT mailbox, seen, size FROM mail_message WHERE account = $id);
        LET $owner = (SELECT message_count, used_bytes, mailbox_count FROM ONLY $id);
        RETURN $boxes.all(|$b| {
            LET $mine = $messages.filter(|$m| $m.mailbox = $b.id);
            RETURN $b.total == array::len($mine) AND $b.unseen == array::len($mine.filter(|$m| !$m.seen)) AND $b.size == math::sum($mine.map(|$m| $m.size));
        }) AND $owner.message_count == array::len($messages) AND $owner.used_bytes == math::sum($messages.map(|$m| $m.size)) AND $owner.mailbox_count == array::len($boxes);
    };
};

-- préparation: domaines alpha.test et beta.test, comptes de jean et marie (alpha) et d'autre (beta)
{
    LET $domain = fn::mail_domain_create({ auth_domain: "auth_organization_domain:alpha" }).data.id;
    LET $domain_beta = fn::mail_domain_create({ auth_domain: "auth_organization_domain:beta" }).data.id;
    LET $jean = fn::mail_account_create({ identity: "auth_identity:jean", domain: <string> $domain, local_part: "jean" }).data.account.id;
    LET $marie = fn::mail_account_create({ identity: "auth_identity:marie", domain: <string> $domain, local_part: "marie" }).data.account.id;
    LET $autre = fn::mail_account_create({ identity: "auth_identity:autre", domain: <string> $domain_beta, local_part: "autre" }).data.account.id;
    LET $box = |$account, $role| <string> (SELECT VALUE id FROM ONLY mail_mailbox WHERE account = $account AND role = $role LIMIT 1);
    CREATE passe:ids CONTENT {
        domain: <string> $domain, domain_beta: <string> $domain_beta,
        jean: <string> $jean, marie: <string> $marie, autre: <string> $autre,
        jean_inbox: $box($jean, "inbox"), jean_trash: $box($jean, "trash"), jean_archive: $box($jean, "archive"), jean_sent: $box($jean, "sent"),
        marie_inbox: $box($marie, "inbox"), autre_inbox: $box($autre, "inbox")
    };
    DEFINE FUNCTION OVERWRITE fn::essai_id($name: string) -> string { RETURN (SELECT * FROM ONLY passe:ids)[$name]; };
};


-- préparation: buckets de stockage d'alpha : lyxal-mail (chiffré), clair (non chiffré)
{
    LET $mail = fn::storage_bucket_create({ tenant: "auth_organization:alpha", name: "lyxal-mail", encrypted: true }).data.id;
    LET $clear = fn::storage_bucket_create({ tenant: "auth_organization:alpha", name: "clair" }).data.id;
    LET $other = fn::storage_bucket_create({ tenant: "auth_organization:alpha", name: "autre-chiffre", encrypted: true }).data.id;
    CREATE passe:storage CONTENT { mail: <string> $mail, clear: <string> $clear, other: <string> $other };
    DEFINE FUNCTION OVERWRITE fn::essai_fichier($bucket: string, $key: string, $size: int, $encrypted: bool) -> string {
        LET $object = fn::storage_object_begin({ bucket: $bucket, key: $key, filename: "message.eml", declared_size: $size }).data;
        fn::storage_object_commit(object::extend({ object: <string> $object.id, size: $size, content_type: "message/rfc822", blake3: "af1349b9f5f9a1a6a0404dea36dcc9499bcb25c9adc112b7cc9a93cae41f3262" }, IF $encrypted { { content_key: "enc:v2:essai-files-1:QUJD" } } ELSE { {} }));
        RETURN <string> $object.id;
    };
};

-- test: jean réserve un contenu : clé sans donnée personnelle, bucket du courrier, délai d'une heure
-- en tant que: jean
{
    LET $reserved = fn::mail_content_begin({ account: fn::essai_id("jean"), size: 300 }).data;
    UPDATE passe:ids SET c1 = <string> $reserved.content, k1 = $reserved.key;
    LET $content = (SELECT * FROM ONLY $reserved.content);
    RETURN string::starts_with($reserved.key, string::concat(record::id(type::record(fn::essai_id("jean"))), "/")) AND string::ends_with($reserved.key, ".eml")
        AND $reserved.bucket_name == "lyxal-mail" AND $reserved.max_size == 52428800 AND $reserved.tenant == auth_organization:alpha
        AND $content.{ state, size, protection, refs, object, key_fingerprint } == { state: "pending", size: 300, protection: "platform", refs: 0, object: NONE, key_fingerprint: NONE }
        AND $content.expires_at > time::now() + 59m AND $content.expires_at <= time::now() + 1h;
};

-- test: réservation refusée : protection réservée, taille, compte d'un autre membre
-- en tant que: jean
RETURN fn::mail_content_begin({ account: fn::essai_id("jean"), size: 10, protection: "openpgp" }).error.code == "MAIL_INVALID_PARAMETERS"
    AND fn::mail_content_begin({ account: fn::essai_id("jean"), size: 0 }).error.code == "MAIL_INVALID_PARAMETERS"
    AND fn::mail_content_begin({ account: fn::essai_id("jean"), size: 52428801 }).error.code == "MAIL_MESSAGE_TOO_LARGE"
    AND fn::mail_content_begin({ account: fn::essai_id("marie"), size: 10 }).error.code == "MAIL_ACCOUNT_NOT_FOUND";

-- test: l'administrateur ne dépose pas dans la boîte d'un membre
-- en tant que: admin
RETURN fn::mail_content_begin({ account: fn::essai_id("jean"), size: 10 }).error.code == "MAIL_PERMISSION_DENIED";

-- test: le lien au fichier est réservé à la session système et au compte de service
-- en tant que: jean
RETURN fn::mail_content_attach({ content: fn::essai_id("c1"), object: "storage_object:x" }).error.code == "MAIL_PERMISSION_DENIED";

-- test: le compte de service sans droit sur les fichiers ne lit pas le fichier : contenu indisponible
-- en tant que: worker
RETURN fn::mail_content_attach({ content: fn::essai_id("c1"), object: "storage_object:x" }).error.{ code, retryable } == { code: "MAIL_CONTENT_UNAVAILABLE", retryable: true };

-- test: fichier refusé : autre clé, autre taille, bucket non chiffré, autre bucket chiffré, fichier non disponible
{
    LET $s = (SELECT * FROM ONLY passe:storage);
    LET $k = fn::essai_id("k1");
    LET $c = fn::essai_id("c1");
    LET $wrong_key = fn::essai_fichier($s.mail, "ailleurs.eml", 300, true);
    LET $wrong_size = fn::essai_fichier($s.other, $k, 299, true);
    LET $clear = fn::essai_fichier($s.clear, $k, 300, false);
    LET $other = fn::essai_fichier($s.other, string::concat($k, ".bis"), 300, true);
    LET $pending = fn::storage_object_begin({ bucket: $s.mail, key: string::concat($k, ".attente"), filename: "message.eml", declared_size: 300 }).data.id;
    RETURN [$wrong_key, $wrong_size, $clear, $other, <string> $pending].all(|$o| fn::mail_content_attach({ content: $c, object: $o }).error.code == "MAIL_CONTENT_STATE_INVALID")
        AND fn::mail_content_attach({ content: $c, object: "storage_object:absent" }).error.code == "MAIL_CONTENT_UNAVAILABLE"
        AND fn::mail_content_attach({ content: "mail_content:absent", object: $wrong_key }).error.code == "MAIL_CONTENT_NOT_FOUND";
};

-- test: le bon fichier : contenu stored, lié à sa fiche ; un second lien est refusé
{
    LET $object = fn::essai_fichier((SELECT VALUE mail FROM ONLY passe:storage), fn::essai_id("k1"), 300, true);
    UPDATE passe:ids SET o1 = $object;
    LET $attached = fn::mail_content_attach({ content: fn::essai_id("c1"), object: $object }).data;
    RETURN $attached.state == "stored" AND $attached.object == type::record($object)
        AND fn::mail_content_attach({ content: fn::essai_id("c1"), object: $object }).error.code == "MAIL_CONTENT_STATE_INVALID";
};

-- test: un fichier lié à un contenu ne se supprime pas dans lyxal_storage
RETURN fn::storage_object_delete({ object: fn::essai_id("o1") }).error.code == "STORAGE_OBJECT_IN_USE";

-- test: inscription puis lecture du contenu par son titulaire
-- en tant que: jean
{
    LET $message = fn::mail_message_create({ content: fn::essai_id("c1"), mailbox: fn::essai_id("jean_inbox"), received_at: time::now(), envelope: { subject: "x" }, structure: { type: "text/plain" } }).data;
    UPDATE passe:ids SET m1 = <string> $message.id;
    RETURN fn::mail_content_open({ message: <string> $message.id }).data == { object: type::record(fn::essai_id("o1")), size: 300, protection: "platform", key_fingerprint: NONE }
        AND (SELECT VALUE [refs, expires_at] FROM ONLY type::record(fn::essai_id("c1"))) == [1, NONE];
};

-- test: un autre membre ne lit pas le contenu ; le compte de service, si
-- en tant que: marie
RETURN fn::mail_content_open({ message: fn::essai_id("m1") }).error.code == "MAIL_MESSAGE_NOT_FOUND"
    AND array::len(SELECT * FROM mail_content) == 0;

-- test: le compte de service lit le contenu de tout compte
-- en tant que: worker
RETURN fn::mail_content_open({ message: fn::essai_id("m1") }).data.object == type::record(fn::essai_id("o1"));

-- test: une copie partage le contenu ; l'effacement de l'une garde le contenu ; celui de la dernière le libère
-- en tant que: jean
{
    LET $copy = fn::mail_message_copy({ messages: [fn::essai_id("m1")], mailbox: fn::essai_id("jean_archive") }).data.copied[0].id;
    LET $refs = (SELECT VALUE refs FROM ONLY type::record(fn::essai_id("c1")));
    fn::mail_message_expunge({ mailbox: fn::essai_id("jean_inbox"), messages: [fn::essai_id("m1")] });
    LET $kept = (SELECT VALUE [state, refs] FROM ONLY type::record(fn::essai_id("c1")));
    LET $open = fn::mail_content_open({ message: <string> $copy }).ok;
    fn::mail_message_expunge({ mailbox: fn::essai_id("jean_archive"), messages: [<string> $copy] });
    RETURN $refs == 2 AND $kept == ["stored", 1] AND $open
        AND (SELECT VALUE [state, refs] FROM ONLY type::record(fn::essai_id("c1"))) == ["released", 0];
};

-- test: un contenu libéré ne s'inscrit plus
-- en tant que: jean
RETURN fn::mail_message_create({ content: fn::essai_id("c1"), mailbox: fn::essai_id("jean_inbox"), received_at: time::now(), envelope: { subject: "x" }, structure: { type: "text/plain" } }).error.code == "MAIL_CONTENT_STATE_INVALID";

-- préparation: contenus abandonnés : réservé jamais écrit, écrit jamais lié, lié jamais inscrit ; un contenu en cours
{
    LET $jean = fn::essai_id("jean");
    LET $mail = (SELECT VALUE mail FROM ONLY passe:storage);
    LET $never = fn::mail_content_begin({ account: $jean, size: 10 }).data;
    LET $written = fn::mail_content_begin({ account: $jean, size: 20 }).data;
    LET $written_object = fn::essai_fichier($mail, $written.key, 20, true);
    LET $linked = fn::essai_contenu($jean, 30);
    LET $fresh = fn::mail_content_begin({ account: $jean, size: 40 }).data;
    UPDATE [$never.content, $written.content, type::record($linked)] SET expires_at = time::now() - 1m;
    CREATE passe:abandon CONTENT { never: <string> $never.content, written: <string> $written.content, written_object: $written_object, linked: $linked, fresh: <string> $fresh.content,
        linked_object: <string> (SELECT VALUE object FROM ONLY type::record($linked)) };
};

-- test: le lien d'un contenu dont le délai est passé est refusé
{
    LET $a = (SELECT * FROM ONLY passe:abandon);
    RETURN fn::mail_content_attach({ content: $a.written, object: $a.written_object }).error.code == "MAIL_CONTENT_STATE_INVALID";
};

-- test: un membre ne lance pas la maintenance
-- en tant que: jean
RETURN fn::mail_content_expire({}).error.code == "MAIL_PERMISSION_DENIED"
    AND fn::mail_account_purge_step({}).error.code == "MAIL_PERMISSION_DENIED"
    AND fn::mail_content_expire({ limit: 0 }).error.code == "MAIL_INVALID_PARAMETERS";

-- test: le compte de service sans droit sur les fichiers ne retire rien (refus de lyxal_storage, tout est annulé)
-- en tant que: worker
-- attendu-erreur: MAIL_CONTENT_UNAVAILABLE
RETURN fn::mail_content_expire({});

-- test: maintenance : contenus abandonnés et libérés retirés avec leurs fichiers, dans la même transaction ; le contenu en cours reste
{
    LET $a = (SELECT * FROM ONLY passe:abandon);
    LET $first = fn::mail_content_expire({ limit: 2 }).data;
    LET $rest = fn::mail_content_expire({}).data;
    LET $again = fn::mail_content_expire({}).data;
    RETURN $first == { expired: 2, released: 0 } AND $rest == { expired: 1, released: 1 } AND $again == { expired: 0, released: 0 }
        AND [$a.never, $a.written, $a.linked, fn::essai_id("c1")].all(|$c| !record::exists(type::record($c)))
        AND record::exists(type::record($a.fresh))
        AND [$a.written_object, $a.linked_object, fn::essai_id("o1")].all(|$o| (SELECT VALUE state FROM ONLY type::record($o)) == "deleted");
};

-- test: compteurs exacts après les effacements
RETURN fn::essai_coherent(fn::essai_id("jean"));

-- préparation: deux messages et un contenu en cours pour marie, puis suppression de son compte
{
    LET $marie = fn::essai_id("marie");
    fn::essai_message($marie, fn::essai_id("marie_inbox"), {});
    fn::essai_message($marie, fn::essai_id("marie_inbox"), { seen: true });
    LET $pending = fn::mail_content_begin({ account: $marie, size: 10 }).data;
    UPDATE passe:ids SET marie_objects = (SELECT VALUE object FROM mail_content WHERE account = type::record($marie) AND object IS NOT NONE).map(|$o| <string> $o);
    fn::mail_account_delete({ account: $marie });
};

-- test: un compte en suppression ne reçoit plus rien
-- en tant que: worker
RETURN fn::mail_content_begin({ account: fn::essai_id("marie"), size: 10 }).error.code == "MAIL_ACCOUNT_DELETING"
    AND fn::mail_address_resolve({ address: "marie@alpha.test" }).error.code == "MAIL_RECIPIENT_UNKNOWN";

-- test: purge par étapes : messages, puis contenus et fichiers, puis le compte ; mail.account.deleted
{
    LET $marie = type::record(fn::essai_id("marie"));
    LET $tombs_before = array::len(SELECT * FROM mail_tombstone WHERE account = $marie);
    LET $s1 = fn::mail_account_purge_step({ limit: 1 }).data;
    LET $s2 = fn::mail_account_purge_step({}).data;
    LET $s3 = fn::mail_account_purge_step({}).data;
    LET $s4 = fn::mail_account_purge_step({}).data;
    LET $s5 = fn::mail_account_purge_step({}).data;
    RETURN $s1 == { accounts: 0, messages: 1, done: false } AND $s2 == { accounts: 0, messages: 1, done: false }
        AND $s3 == { accounts: 0, messages: 0, done: false } AND $s4 == { accounts: 1, messages: 0, done: true }
        AND $s5 == { accounts: 0, messages: 0, done: true }
        AND $tombs_before == 0 AND !record::exists($marie)
        AND [mail_mailbox, mail_message, mail_content, mail_tombstone, mail_address].all(|$t| array::len(SELECT * FROM $t WHERE account = $marie) == 0)
        AND (SELECT VALUE marie_objects FROM ONLY passe:ids).all(|$o| (SELECT VALUE state FROM ONLY type::record($o)) == "deleted")
        AND (SELECT VALUE payload FROM event_outbox WHERE event_type = "mail.account.deleted") == [{ account_id: <string> $marie, tenant: "auth_organization:alpha" }];
};

-- test: la purge d'un compte est sans effet sur les autres
RETURN fn::essai_coherent(fn::essai_id("jean")) AND record::exists(type::record(fn::essai_id("jean")));

-- test: écriture directe : un contenu ne se crée pas déjà stocké ni hors du préfixe de son compte
-- en tant que: jean
-- attendu-erreur: MAIL_WRITE_FORBIDDEN
CREATE mail_content CONTENT { tenant: auth_organization:alpha, account: type::record(fn::essai_id("jean")), key: "autre/x.eml", size: 1 };

-- test: écriture directe : un membre ne change pas l'état ni les lecteurs d'un contenu (ignoré)
-- en tant que: jean
{
    LET $fresh = type::record((SELECT VALUE fresh FROM ONLY passe:abandon));
    UPDATE $fresh SET state = "stored", refs = 5;
    RETURN (SELECT VALUE [state, refs] FROM ONLY $fresh) == ["pending", 0];
};

-- test: écriture directe : un contenu libéré ne revient pas
-- attendu-erreur: MAIL_CONTENT_STATE_INVALID
{
    LET $linked = fn::essai_contenu(fn::essai_id("jean"), 5);
    UPDATE type::record($linked) SET state = "released";
    UPDATE type::record($linked) SET state = "stored";
};

-- préparation: quota de 1 000 octets pour jean ; 600 octets déposés et inscrits
{
    fn::mail_account_update({ account: fn::essai_id("jean"), quota_bytes: 1000 });
    UPDATE passe:ids SET q1 = <string> fn::essai_message(fn::essai_id("jean"), fn::essai_id("jean_inbox"), { size: 600 }).data.id;
};

-- test: quota : réservation au-delà refusée ; premier refus daté, un seul événement mail.quota.exceeded sans donnée personnelle
-- en tant que: jean
{
    LET $first = fn::mail_content_begin({ account: fn::essai_id("jean"), size: 500 }).error;
    LET $second = fn::mail_content_begin({ account: fn::essai_id("jean"), size: 900 }).error;
    RETURN $first.{ code, details } == { code: "MAIL_QUOTA_EXCEEDED", details: { quota_bytes: 1000, used_bytes: 600 } } AND $second.code == "MAIL_QUOTA_EXCEEDED"
        AND fn::mail_account_get({}).data.quota_exceeded_at IS NOT NONE
        AND fn::mail_content_begin({ account: fn::essai_id("jean"), size: 400 }).ok;
};

-- test: événement unique de dépassement
RETURN (SELECT VALUE payload FROM event_outbox WHERE event_type = "mail.quota.exceeded") == [{ account_id: fn::essai_id("jean"), tenant: "auth_organization:alpha", quota_bytes: 1000, used_bytes: 600 }];

-- test: quota : une copie compte à nouveau ; refus sans nouvel événement
-- en tant que: jean
RETURN fn::mail_message_copy({ messages: [fn::essai_id("q1")], mailbox: fn::essai_id("jean_inbox") }).error.code == "MAIL_QUOTA_EXCEEDED";

-- test: quota : un dépôt réservé avant un quota abaissé est refusé à l'inscription ; le quota changé, le refus publie à nouveau
{
    LET $content = fn::essai_contenu(fn::essai_id("jean"), 300);
    fn::mail_account_update({ account: fn::essai_id("jean"), quota_bytes: 700 });
    RETURN fn::mail_message_create({ content: $content, mailbox: fn::essai_id("jean_inbox"), received_at: time::now(), envelope: { subject: "x" }, structure: { type: "text/plain" } }).error.code == "MAIL_QUOTA_EXCEEDED"
        AND array::len(SELECT * FROM event_outbox WHERE event_type = "mail.quota.exceeded") == 2;
};

-- test: écriture directe : la base refuse aussi un message au-delà du quota
-- attendu-erreur: MAIL_QUOTA_EXCEEDED
{
    LET $account = type::record(fn::essai_id("jean"));
    LET $content = (SELECT VALUE id FROM ONLY mail_content WHERE account = $account AND state = "stored" AND refs = 0 LIMIT 1);
    CREATE mail_message CONTENT { tenant: auth_organization:alpha, account: $account, mailbox: type::record(fn::essai_id("jean_inbox")), content: $content,
        uid: 100, modseq: 1000, create_modseq: 1000, thread: "t", received_at: time::now(), size: 300 };
};

-- test: le titulaire n'efface pas la date du dépassement sans libérer de place
-- en tant que: jean
-- attendu-erreur: MAIL_WRITE_FORBIDDEN
UPDATE type::record(fn::essai_id("jean")) SET quota_exceeded_at = NONE;

-- test: quota relevé : la date du dépassement s'efface ; un nouveau dépassement publie à nouveau
{
    fn::mail_account_update({ account: fn::essai_id("jean"), quota_bytes: 2000 });
    LET $cleared = (SELECT VALUE quota_exceeded_at FROM ONLY type::record(fn::essai_id("jean")));
    fn::mail_account_update({ account: fn::essai_id("jean"), quota_bytes: 650 });
    LET $refused = fn::mail_content_begin({ account: fn::essai_id("jean"), size: 100 }).error.code;
    RETURN $cleared IS NONE AND $refused == "MAIL_QUOTA_EXCEEDED"
        AND array::len(SELECT * FROM event_outbox WHERE event_type = "mail.quota.exceeded") == 3;
};

-- test: un effacement libère de la place : la date du dépassement s'efface d'elle-même
-- en tant que: jean
{
    fn::mail_message_expunge({ mailbox: fn::essai_id("jean_inbox"), messages: [fn::essai_id("q1")] });
    RETURN fn::mail_account_get({}).data.quota_exceeded_at IS NONE AND fn::mail_quota_get({}).data.used_bytes == 0;
};
