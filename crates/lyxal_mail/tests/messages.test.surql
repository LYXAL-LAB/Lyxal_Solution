-- lyxal-test: assertions
-- Messages : inscription (UID, numéro de modification, drapeaux et mots-clés, enveloppe,
-- protection rendue), refus (contenu, enveloppe, taille, mots-clés, UID épuisés), UID strictement
-- croissants et jamais réutilisés, pages par curseur sans doublon ni manque à égalité de date,
-- plage d'UID, drapeaux (CONDSTORE), déplacement, copie, effacement, fils (réponse, références,
-- sujet différent, avis de non-remise, enfant avant parent), compteurs égaux au contenu réel,
-- droits du titulaire, gardes des écritures directes.
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


-- préparation: deux contenus déposés dans le compte de jean, un dans celui de marie
{
    UPDATE passe:ids SET c1 = fn::essai_contenu(fn::essai_id("jean"), 120), c2 = fn::essai_contenu(fn::essai_id("jean"), 80), cm = fn::essai_contenu(fn::essai_id("marie"), 10);
};

-- test: jean inscrit un message : UID 1, numéro de modification suivant, drapeaux et mots-clés en minuscules, protection rendue
-- en tant que: jean
{
    LET $earlier = fn::mail_account_get({}).data.modseq;
    LET $created = fn::mail_message_create({
        content: fn::essai_id("c1"), mailbox: fn::essai_id("jean_inbox"), received_at: d"2026-11-01T10:00:00Z", sent_at: d"2026-11-01T09:59:00Z",
        keywords: ["$Seen", "Projet", "$Label1", "projet"], flagged: true, message_id: "racine@ailleurs.test", base_subject: "Chantier",
        envelope: { date: d"2026-11-01T09:59:00Z", subject: "Chantier", message_id: "racine@ailleurs.test", from: [{ name: "Expéditeur", address: "exp@ailleurs.test" }], to: [{ address: "jean@alpha.test" }] },
        structure: { type: "multipart/mixed", parts: [{ type: "text/plain" }, { type: "application/pdf", name: "plan.pdf" }] }, has_attachment: true
    }).data;
    UPDATE passe:ids SET m1 = <string> $created.id, t1 = $created.thread;
    RETURN $created.{ uid, size, seen, flagged, answered, keywords, protection, has_attachment, thread_orphan }
            == { uid: 1, size: 120, seen: true, flagged: true, answered: false, keywords: ["$label1", "projet"], protection: "platform", has_attachment: true, thread_orphan: false }
        AND $created.modseq == $earlier + 1 AND $created.create_modseq == $created.modseq
        AND $created.envelope.to == [{ address: "jean@alpha.test" }]
        AND fn::mail_mailbox_get({ mailbox: fn::essai_id("jean_inbox") }).data.{ total, unseen, size, uid_next, highest_modseq } == { total: 1, unseen: 0, size: 120, uid_next: 2, highest_modseq: $created.modseq }
        AND fn::mail_quota_get({}).data.{ used_bytes, message_count } == { used_bytes: 120, message_count: 1 };
};

-- test: lecture d'un message avec la protection de son contenu (décision M15)
-- en tant que: jean
RETURN fn::mail_message_get({ message: fn::essai_id("m1") }).data.{ uid, protection, key_fingerprint, base_subject } == { uid: 1, protection: "platform", key_fingerprint: NONE, base_subject: "Chantier" }
    AND fn::mail_message_get({ message: "mail_message:absent" }).error.code == "MAIL_MESSAGE_NOT_FOUND";

-- test: refus : contenu déjà inscrit, contenu d'un autre compte, enveloppe ou structure absentes, paramètres invalides
-- en tant que: jean
{
    LET $base = { mailbox: fn::essai_id("jean_inbox"), received_at: time::now(), envelope: { subject: "x" }, structure: { type: "text/plain" } };
    RETURN fn::mail_message_create(object::extend($base, { content: fn::essai_id("c1") })).error.code == "MAIL_CONTENT_STATE_INVALID"
        AND fn::mail_message_create(object::extend($base, { content: fn::essai_id("cm") })).error.code == "MAIL_CONTENT_NOT_FOUND"
        AND fn::mail_message_create({ content: fn::essai_id("c2"), mailbox: fn::essai_id("jean_inbox"), received_at: time::now(), structure: { type: "text/plain" } }).error.{ code, fields: details.fields } == { code: "MAIL_MESSAGE_MALFORMED", fields: { envelope: ["required"], structure: [] } }
        AND fn::mail_message_create(object::extend($base, { content: fn::essai_id("c2"), keywords: ["a b"] })).error.code == "MAIL_INVALID_PARAMETERS"
        AND fn::mail_message_create(object::extend($base, { content: fn::essai_id("c2"), keywords: ["a]"] })).error.code == "MAIL_INVALID_PARAMETERS"
        AND fn::mail_message_create(object::extend($base, { content: fn::essai_id("c2"), envelope: { subject: "x", to: [{ address: "a", extra: 1 }] } })).error.code == "MAIL_INVALID_PARAMETERS"
        AND fn::mail_message_create(object::extend($base, { content: fn::essai_id("c2"), received_at: "2026-11-01" })).error.code == "MAIL_INVALID_PARAMETERS"
        AND fn::mail_message_create(object::extend($base, { content: fn::essai_id("c2"), received_at: d"1969-12-31T23:59:59Z" })).error.code == "MAIL_INVALID_PARAMETERS"
        AND fn::mail_message_create(object::extend($base, { content: fn::essai_id("c2"), mailbox: fn::essai_id("marie_inbox") })).error.code == "MAIL_MAILBOX_NOT_FOUND";
};

-- préparation: gros contenu déposé ; mots-clés limités à deux
{
    UPDATE passe:ids SET big = fn::essai_contenu(fn::essai_id("jean"), 2000);
    fn::mail_settings_set({ tenant: "auth_organization:alpha", max_keywords_per_message: 2 });
};

-- test: trop de mots-clés (drapeaux système non comptés)
-- en tant que: jean
{
    LET $base = { mailbox: fn::essai_id("jean_inbox"), received_at: time::now(), envelope: { subject: "x" }, structure: { type: "text/plain" } };
    RETURN fn::mail_message_create(object::extend($base, { content: fn::essai_id("c2"), keywords: ["a", "b", "c"] })).error.{ code, details } == { code: "MAIL_KEYWORD_LIMIT", details: { max_keywords_per_message: 2 } }
        AND fn::mail_message_create(object::extend($base, { content: fn::essai_id("c2"), keywords: ["$seen", "a", "b"] })).ok;
};

-- préparation: taille maximale abaissée sous celle du gros contenu, après son dépôt
fn::mail_settings_set({ tenant: "auth_organization:alpha", max_message_bytes: 1024, clear: ["max_keywords_per_message"] });

-- test: un contenu plus grand que la taille maximale ne s'inscrit pas
-- en tant que: jean
RETURN fn::mail_message_create({ content: fn::essai_id("big"), mailbox: fn::essai_id("jean_inbox"), received_at: time::now(), envelope: { subject: "x" }, structure: { type: "text/plain" } }).error.{ code, details } == { code: "MAIL_MESSAGE_TOO_LARGE", details: { size: 2000, max_message_bytes: 1024 } };

-- préparation: taille par défaut ; trois messages de même date dans Sent
{
    fn::mail_settings_set({ tenant: "auth_organization:alpha", clear: ["max_message_bytes"] });
    FOR $n IN [1, 2, 3] { fn::essai_message(fn::essai_id("jean"), fn::essai_id("jean_sent"), { received_at: d"2026-11-02T08:00:00Z" }); };
    fn::essai_message(fn::essai_id("jean"), fn::essai_id("jean_sent"), { received_at: d"2026-11-03T08:00:00Z" });
};

-- test: pages par curseur à égalité de date : ni doublon ni manque, même ordre à chaque appel
-- en tant que: jean
{
    LET $sent = fn::essai_id("jean_sent");
    LET $p1 = fn::mail_message_list({ mailbox: $sent, limit: 1 }).data;
    LET $p2 = fn::mail_message_list({ mailbox: $sent, limit: 1, before: $p1.next.before }).data;
    LET $p3 = fn::mail_message_list({ mailbox: $sent, limit: 1, before: { received_at: $p2.next.before.received_at, id: $p2.next.before.id } }).data;
    LET $p4 = fn::mail_message_list({ mailbox: $sent, limit: 1, before: $p3.next.before }).data;
    LET $all = fn::mail_message_list({ mailbox: $sent }).data;
    LET $paged = array::flatten([$p1.items.id, $p2.items.id, $p3.items.id, $p4.items.id]);
    RETURN $paged == $all.items.id AND array::len(array::distinct($paged)) == 4 AND $p4.next IS NONE AND $all.next IS NONE
        AND $all.items[0].received_at == d"2026-11-03T08:00:00Z"
        AND $paged == fn::mail_message_list({ mailbox: $sent, limit: 10 }).data.items.id;
};

-- test: plage d'UID par ordre croissant ; résumé sans enveloppe ni structure, vue complète avec
-- en tant que: jean
{
    LET $sent = fn::essai_id("jean_sent");
    LET $first = fn::mail_message_list({ mailbox: $sent, uid_min: 1, limit: 3 }).data;
    LET $rest = fn::mail_message_list({ mailbox: $sent, uid_min: $first.next.uid_min, limit: 3 }).data;
    LET $full = fn::mail_message_list({ mailbox: $sent, uid_min: 2, uid_max: 2, fields: "full" }).data.items;
    RETURN $first.items.uid == [1, 2, 3] AND $first.next == { uid_min: 4 } AND $rest.items.uid == [4] AND $rest.next IS NONE
        AND $first.items[0].envelope IS NONE AND $first.items[0].structure IS NONE AND $first.items[0].protection == "platform"
        AND $full[0].uid == 2 AND $full[0].envelope.subject == "Essai"
        AND fn::mail_message_list({ mailbox: $sent, uid_min: 1, before: { received_at: time::now(), id: "mail_message:x" } }).error.code == "MAIL_INVALID_PARAMETERS"
        AND fn::mail_message_list({ mailbox: $sent, limit: 1001 }).error.code == "MAIL_INVALID_PARAMETERS";
};

-- test: drapeaux : ajout, retrait, remplacement ; un numéro de modification pour l'appel ; compteur de non-lus
-- en tant que: jean
{
    LET $ids = fn::mail_message_list({ mailbox: fn::essai_id("jean_sent"), uid_min: 1 }).data.items.map(|$m| <string> $m.id);
    LET $added = fn::mail_message_flags_set({ messages: $ids, add: ["$seen", "Urgent"] }).data;
    LET $unseen = fn::mail_mailbox_get({ mailbox: fn::essai_id("jean_sent") }).data.unseen;
    LET $removed = fn::mail_message_flags_set({ messages: [$ids[0]], remove: ["$SEEN", "urgent"] }).data;
    LET $replaced = fn::mail_message_flags_set({ messages: [$ids[1]], replace: ["$flagged", "$draft", "z", "a"] }).data;
    LET $m1 = fn::mail_message_get({ message: $ids[0] }).data;
    LET $m2 = fn::mail_message_get({ message: $ids[1] }).data;
    RETURN array::len($added.updated) == 4 AND array::len(array::distinct($added.updated.modseq)) == 1 AND $added.conflicts == []
        AND $unseen == 0 AND fn::mail_mailbox_get({ mailbox: fn::essai_id("jean_sent") }).data.unseen == 2
        AND $removed.updated[0].modseq == $added.updated[0].modseq + 1
        AND $m1.{ seen, keywords } == { seen: false, keywords: [] }
        AND $m2.{ seen, flagged, draft, keywords } == { seen: false, flagged: true, draft: true, keywords: ["a", "z"] }
        AND $replaced.updated[0].modseq == $m2.modseq;
};

-- test: un message inchangé n'est pas réécrit ; CONDSTORE : unchanged_since rend les conflits
-- en tant que: jean
{
    LET $ids = fn::mail_message_list({ mailbox: fn::essai_id("jean_sent"), uid_min: 1 }).data.items;
    LET $same = fn::mail_message_flags_set({ messages: [<string> $ids[1].id], add: ["$flagged"] }).data;
    LET $guarded = fn::mail_message_flags_set({ messages: [<string> $ids[0].id, <string> $ids[2].id], add: ["$answered"], unchanged_since: $ids[2].modseq }).data;
    RETURN $same == { updated: [], conflicts: [] }
        AND $guarded.conflicts == [$ids[0].id] AND $guarded.updated.id == [$ids[2].id];
};

-- test: drapeaux : paramètres incohérents, message absent ou d'un autre compte, lot trop grand
-- en tant que: jean
{
    LET $id = fn::essai_id("m1");
    RETURN fn::mail_message_flags_set({ messages: [$id], replace: ["a"], add: ["b"] }).error.code == "MAIL_INVALID_PARAMETERS"
        AND fn::mail_message_flags_set({ messages: [$id] }).error.code == "MAIL_INVALID_PARAMETERS"
        AND fn::mail_message_flags_set({ messages: [], add: ["a"] }).error.code == "MAIL_INVALID_PARAMETERS"
        AND fn::mail_message_flags_set({ messages: (<array> (0..501)).map(|$n| string::concat("mail_message:m", <string> $n)), add: ["a"] }).error.code == "MAIL_INVALID_PARAMETERS"
        AND fn::mail_message_flags_set({ messages: [$id, "mail_message:absent"], add: ["a"] }).error.{ code, details } == { code: "MAIL_MESSAGE_NOT_FOUND", details: { messages: ["mail_message:absent"] } }
        AND fn::mail_message_flags_set({ messages: [$id], add: (<array> (0..51)).map(|$n| string::concat("k", <string> $n)) }).error.code == "MAIL_KEYWORD_LIMIT";
};

-- test: déplacement : nouvelle fiche (nouvel UID, nouvel identifiant ordonné, même email_id, même contenu), ancienne retirée, pierre tombale à la source
-- en tant que: jean
{
    LET $id = fn::essai_id("m1");
    LET $original = fn::mail_message_get({ message: $id }).data;
    LET $moved = fn::mail_message_move({ messages: [$id], mailbox: fn::essai_id("jean_archive") }).data.moved;
    LET $moved_row = fn::mail_message_get({ message: <string> $moved[0].id }).data;
    UPDATE passe:ids SET m1 = <string> $moved[0].id;
    LET $tomb = (SELECT kind, mailbox, uid, object, modseq FROM ONLY mail_tombstone WHERE object = $id LIMIT 1);
    RETURN $moved == [{ id: fn::mail_message_key(type::record(fn::essai_id("jean_archive")), 1), from: type::record($id), from_uid: 1, uid: 1, modseq: $moved_row.modseq }]
        AND fn::mail_message_get({ message: $id }).error.code == "MAIL_MESSAGE_NOT_FOUND"
        AND $moved_row.{ email_id, content, thread, uid } == { email_id: $original.email_id, content: $original.content, thread: $original.thread, uid: 1 }
        AND (SELECT VALUE [refs, state] FROM ONLY $original.content) == [1, "stored"]
        AND $moved_row.mailbox == type::record(fn::essai_id("jean_archive"))
        AND $tomb == { kind: "message", mailbox: fn::essai_id("jean_inbox"), uid: 1, object: $id, modseq: $moved_row.modseq }
        AND fn::mail_mailbox_get({ mailbox: fn::essai_id("jean_inbox") }).data.{ total, highest_modseq } == { total: 1, highest_modseq: $moved_row.modseq }
        AND fn::mail_message_move({ messages: [<string> $moved[0].id], mailbox: fn::essai_id("marie_inbox") }).error.code == "MAIL_MAILBOX_NOT_FOUND"
        AND fn::essai_coherent(fn::essai_id("jean"));
};

-- test: copie : nouvelle fiche sur le même contenu (lecteurs), même fil, drapeaux gardés, quota compté
-- en tant que: jean
{
    LET $id = fn::essai_id("m1");
    LET $copied = fn::mail_message_copy({ messages: [$id], mailbox: fn::essai_id("jean_inbox") }).data.copied;
    LET $copy = fn::mail_message_get({ message: <string> $copied[0].id }).data;
    LET $source = fn::mail_message_get({ message: $id }).data;
    UPDATE passe:ids SET copie = <string> $copied[0].id;
    RETURN $copied[0].source == type::record($id) AND $copied[0].uid == 3 AND $copy.content == $source.content AND $copy.thread == $source.thread
        AND $copy.keywords == $source.keywords AND $copy.id != $source.id AND $copy.email_id != $source.email_id
        AND (SELECT VALUE refs FROM ONLY $source.content) == 2
        AND fn::mail_quota_get({}).data.used_bytes == math::sum((SELECT VALUE size FROM mail_message))
        AND fn::essai_coherent(fn::essai_id("jean"));
};

-- test: effacement du dernier UID puis nouveau message : UID jamais réutilisé
-- en tant que: jean
{
    LET $inbox = fn::essai_id("jean_inbox");
    LET $gone = fn::mail_message_expunge({ mailbox: $inbox, messages: [fn::essai_id("copie")] }).data;
    LET $content = (SELECT VALUE content FROM ONLY type::record(fn::essai_id("m1")));
    RETURN $gone.expunged[0].{ id, uid } == { id: type::record(fn::essai_id("copie")), uid: 3 } AND $gone.more == false
        AND (SELECT VALUE refs FROM ONLY $content) == 1
        AND fn::mail_mailbox_get({ mailbox: $inbox }).data.uid_next == 4;
};

-- préparation: nouveau message dans INBOX
UPDATE passe:ids SET m_new = <string> fn::essai_message(fn::essai_id("jean"), fn::essai_id("jean_inbox"), {}).data.id;

-- test: le nouveau message prend l'UID 4, jamais 3
-- en tant que: jean
RETURN fn::mail_message_get({ message: fn::essai_id("m_new") }).data.uid == 4;

-- test: effacement des messages \Deleted d'un dossier, par lots ; un dossier sans \Deleted ne bouge pas
-- en tant que: jean
{
    LET $inbox = fn::essai_id("jean_inbox");
    LET $ids = (SELECT VALUE id FROM mail_message WHERE mailbox = type::record($inbox));
    fn::mail_message_flags_set({ messages: $ids.map(|$i| <string> $i), add: ["$deleted"] });
    LET $gone = fn::mail_message_expunge({ mailbox: $inbox }).data;
    LET $nothing = fn::mail_message_expunge({ mailbox: $inbox }).data;
    RETURN array::len($gone.expunged) == 2 AND array::sort::asc($gone.expunged.id) == array::sort::asc($ids) AND $gone.expunged[0].modseq < $gone.expunged[1].modseq
        AND $nothing == { expunged: [], more: false }
        AND fn::mail_mailbox_get({ mailbox: $inbox }).data.{ total, unseen, size } == { total: 0, unseen: 0, size: 0 }
        AND fn::essai_coherent(fn::essai_id("jean"));
};

-- test: effacement : messages nommés hors du dossier refusés
-- en tant que: jean
RETURN fn::mail_message_expunge({ mailbox: fn::essai_id("jean_inbox"), messages: [fn::essai_id("m1")] }).error.{ code, details } == { code: "MAIL_MESSAGE_NOT_FOUND", details: { messages: [fn::essai_id("m1")] } }
    AND fn::mail_message_expunge({ mailbox: "mail_mailbox:absent" }).error.code == "MAIL_MAILBOX_NOT_FOUND";

-- préparation: fils : parent, réponse par In-Reply-To, réponse par References, sujet différent, avis de non-remise, enfant avant parent
{
    LET $acc = fn::essai_id("jean");
    LET $box = fn::essai_id("jean_inbox");
    LET $root = fn::essai_message($acc, $box, { message_id: "p@x", base_subject: "Devis" }).data;
    LET $reply = fn::essai_message($acc, $box, { message_id: "r1@x", in_reply_to: ["p@x"], base_subject: "Devis" }).data;
    LET $refs = fn::essai_message($acc, $box, { message_id: "r2@x", references: ["p@x", "inconnu@x"], base_subject: "Devis" }).data;
    LET $other = fn::essai_message($acc, $box, { message_id: "r3@x", in_reply_to: ["p@x"], base_subject: "Autre sujet" }).data;
    LET $report = fn::essai_message($acc, $box, { message_id: "dsn@x", in_reply_to: ["p@x"], base_subject: "Undelivered", is_report: true }).data;
    LET $orphan = fn::essai_message($acc, $box, { message_id: "o2@x", in_reply_to: ["o1@x"], base_subject: "Orphelin" }).data;
    LET $late = fn::essai_message($acc, $box, { message_id: "o1@x", base_subject: "Orphelin" }).data;
    LET $dup = fn::essai_message($acc, $box, { message_id: "p@x", base_subject: "Devis" }).data;
    CREATE passe:fils CONTENT { parent: $root, reply: $reply, refs: $refs, other: $other, report: $report, orphan: $orphan, late: $late, dup: $dup };
};

-- test: fils : réponse et références rejoignent le fil, sujet différent et enfant avant parent ouvrent le leur ; jamais de fusion
{
    LET $f = (SELECT * FROM ONLY passe:fils);
    RETURN $f.reply.thread == $f.parent.thread AND $f.refs.thread == $f.parent.thread AND $f.dup.thread == $f.parent.thread
        AND $f.other.thread != $f.parent.thread AND !$f.other.thread_orphan
        AND $f.report.thread == $f.parent.thread
        AND $f.orphan.thread_orphan AND $f.late.thread != $f.orphan.thread AND !$f.late.thread_orphan
        AND !$f.parent.thread_orphan;
};

-- test: messages d'un fil par date de réception
-- en tant que: jean
{
    LET $f = (SELECT * FROM ONLY passe:fils);
    RETURN fn::mail_thread_get({ thread: $f.parent.thread }).data.messages == [$f.parent.id, $f.reply.id, $f.refs.id, $f.report.id, $f.dup.id]
        AND fn::mail_thread_get({ thread: "01a1fe58-39f8-7751-9c23-d02bcba3a036" }).error.code == "MAIL_MESSAGE_NOT_FOUND"
        AND fn::mail_thread_get({ thread: "pas-un-uuid" }).error.code == "MAIL_INVALID_PARAMETERS";
};

-- test: un autre membre ne voit ni ne touche les messages de jean
-- en tant que: marie
{
    LET $f = (SELECT * FROM ONLY passe:fils);
    LET $id = <string> $f.parent.id;
    RETURN fn::mail_message_get({ message: $id }).error.code == "MAIL_MESSAGE_NOT_FOUND"
        AND fn::mail_message_flags_set({ messages: [$id], add: ["$seen"] }).error.code == "MAIL_MESSAGE_NOT_FOUND"
        AND fn::mail_message_move({ messages: [$id], mailbox: fn::essai_id("marie_inbox") }).error.code == "MAIL_MESSAGE_NOT_FOUND"
        AND fn::mail_message_copy({ messages: [$id], mailbox: fn::essai_id("marie_inbox") }).error.code == "MAIL_MESSAGE_NOT_FOUND"
        AND fn::mail_message_list({ mailbox: fn::essai_id("jean_inbox") }).error.code == "MAIL_MAILBOX_NOT_FOUND"
        AND fn::mail_thread_get({ thread: $f.parent.thread }).error.code == "MAIL_MESSAGE_NOT_FOUND"
        AND fn::mail_thread_get({ thread: $f.parent.thread, account: fn::essai_id("jean") }).error.code == "MAIL_ACCOUNT_NOT_FOUND"
        AND array::len(SELECT * FROM mail_message) == 0;
};

-- test: l'administrateur ne lit pas le contenu des boîtes (décision M11)
-- en tant que: admin
RETURN fn::mail_message_get({ message: <string> (SELECT VALUE parent.id FROM ONLY passe:fils) }).error.code == "MAIL_MESSAGE_NOT_FOUND"
    AND array::len(SELECT * FROM mail_message) == 0 AND array::len(SELECT * FROM mail_content) == 0;

-- test: écriture directe : un drapeau changé sans numéro de modification est refusé
-- en tant que: jean
-- attendu-erreur: MAIL_WRITE_FORBIDDEN
UPDATE (SELECT VALUE parent.id FROM ONLY passe:fils) SET seen = true;

-- test: écriture directe : l'UID d'un message ne change pas sans déplacement
-- en tant que: jean
-- attendu-erreur: MAIL_WRITE_FORBIDDEN
UPDATE (SELECT VALUE parent.id FROM ONLY passe:fils) SET uid = 1000, modseq = fn::mail_modseq_next(type::record(fn::essai_id("jean")));

-- test: écriture directe : un message ne passe pas dans le dossier d'un autre compte
-- attendu-erreur: MAIL_WRITE_FORBIDDEN
UPDATE (SELECT VALUE parent.id FROM ONLY passe:fils) SET mailbox = type::record(fn::essai_id("marie_inbox")), uid = 1, modseq = 10000;

-- test: écriture directe : un message ne s'inscrit pas sans contenu stocké de son compte
-- en tant que: jean
-- attendu-erreur: MAIL_WRITE_FORBIDDEN
CREATE fn::mail_message_key(type::record(fn::essai_id("jean_inbox")), 1000) CONTENT {
    tenant: auth_organization:alpha, account: type::record(fn::essai_id("jean")), mailbox: type::record(fn::essai_id("jean_inbox")),
    content: type::record(fn::essai_id("cm")), origin: "append", uid: 1000, modseq: 1000, create_modseq: 1000, thread: "t", received_at: time::now(), size: 10
};

-- test: écriture directe avec un numéro de modification : drapeau changé, compteurs tenus ; effacement direct : pierre tombale
-- en tant que: jean
{
    LET $id = (SELECT VALUE parent.id FROM ONLY passe:fils);
    UPDATE $id SET seen = true, modseq = fn::mail_modseq_next(type::record(fn::essai_id("jean")));
    LET $reply = (SELECT VALUE reply.id FROM ONLY passe:fils);
    DELETE $reply;
    RETURN fn::essai_coherent(fn::essai_id("jean")) AND (SELECT VALUE seen FROM ONLY $id) == true
        AND array::len(SELECT * FROM mail_tombstone WHERE object = <string> $reply) == 1;
};

-- préparation: dossier aux UID épuisés (compteur posé par la session système)
UPDATE type::record(fn::essai_id("jean_trash")) SET uid_next = 4294967296;

-- test: UID épuisés : plus aucune entrée dans le dossier
-- en tant que: jean
{
    LET $f = (SELECT * FROM ONLY passe:fils);
    RETURN fn::mail_message_create({ content: fn::essai_id("c2"), mailbox: fn::essai_id("jean_trash"), received_at: time::now(), envelope: { subject: "x" }, structure: { type: "text/plain" } }).error.code == "MAIL_CONTENT_STATE_INVALID"
        AND fn::mail_message_move({ messages: [<string> $f.parent.id], mailbox: fn::essai_id("jean_trash") }).error.code == "MAIL_MAILBOX_UID_EXHAUSTED"
        AND fn::mail_message_copy({ messages: [<string> $f.parent.id], mailbox: fn::essai_id("jean_trash") }).error.code == "MAIL_MAILBOX_UID_EXHAUSTED";
};

-- test: UID épuisés : l'inscription est refusée aussi
-- en tant que: jean
RETURN fn::mail_message_create({ content: (SELECT VALUE big FROM ONLY passe:ids), mailbox: fn::essai_id("jean_trash"), received_at: time::now(), envelope: { subject: "x" }, structure: { type: "text/plain" } }).error.code == "MAIL_MAILBOX_UID_EXHAUSTED";

-- préparation: un message dans INBOX, un autre déjà dans Archive (déplacement en lot)
{
    LET $a = fn::essai_message(fn::essai_id("jean"), fn::essai_id("jean_inbox"), { size: 30 }).data;
    LET $b = fn::essai_message(fn::essai_id("jean"), fn::essai_id("jean_archive"), { size: 40 }).data;
    UPDATE passe:ids SET lot_a = <string> $a.id, lot_b = <string> $b.id;
};

-- test: déplacement d'un lot dont un message est déjà dans la cible : il reste inchangé (ni nouvel UID, ni compté), l'autre est déplacé (nouvelle fiche)
-- en tant que: jean
{
    LET $a = fn::essai_id("lot_a");
    LET $b = fn::essai_id("lot_b");
    LET $initial = fn::mail_message_get({ message: $b }).data;
    LET $archive = fn::mail_mailbox_get({ mailbox: fn::essai_id("jean_archive") }).data;
    LET $result = fn::mail_message_move({ messages: [$a, $b], mailbox: fn::essai_id("jean_archive") });
    UPDATE passe:ids SET lot_a = <string> $result.data.moved[0].id;
    LET $after_a = fn::mail_message_get({ message: <string> $result.data.moved[0].id }).data;
    LET $after_b = fn::mail_message_get({ message: $b }).data;
    RETURN $result.ok
        AND $result.data.moved.map(|$m| $m.from) == [type::record($a)]
        AND !record::exists(type::record($a))
        AND $result.data.moved[0].uid == $archive.uid_next
        AND $after_a.mailbox == type::record(fn::essai_id("jean_archive"))
        AND $after_b.{ mailbox, uid, modseq } == $initial.{ mailbox, uid, modseq }
        AND fn::mail_mailbox_get({ mailbox: fn::essai_id("jean_archive") }).data.{ total, uid_next } == { total: $archive.total + 1, uid_next: $archive.uid_next + 1 }
        AND fn::essai_coherent(fn::essai_id("jean"));
};

-- test: déplacement d'un lot entièrement déjà dans la cible : rien n'est écrit
-- en tant que: jean
{
    LET $b = fn::essai_id("lot_b");
    LET $initial = fn::mail_message_get({ message: $b }).data;
    LET $result = fn::mail_message_move({ messages: [$b], mailbox: fn::essai_id("jean_archive") });
    RETURN $result.ok AND $result.data.moved == [] AND fn::mail_message_get({ message: $b }).data.{ uid, modseq } == $initial.{ uid, modseq };
};

-- préparation: compte de jean désactivé par l'administration
fn::mail_account_update({ account: fn::essai_id("jean"), state: "disabled" });

-- test: compte désactivé : le titulaire ne change plus un message en écriture directe, même avec un numéro de modification
-- en tant que: jean
-- attendu-erreur: MAIL_ACCOUNT_DISABLED
UPDATE type::record(fn::essai_id("lot_a")) SET flagged = true, modseq = fn::mail_modseq_next(type::record(fn::essai_id("jean"))) + 10;

-- test: compte désactivé : le titulaire n'efface plus un message en écriture directe
-- en tant que: jean
-- attendu-erreur: MAIL_ACCOUNT_DISABLED
DELETE type::record(fn::essai_id("lot_a"));

-- test: compte désactivé : la session système écrit encore (exploitation)
{
    UPDATE type::record(fn::essai_id("lot_a")) SET flagged = true, modseq = fn::mail_modseq_next(type::record(fn::essai_id("jean")));
    RETURN (SELECT VALUE flagged FROM ONLY type::record(fn::essai_id("lot_a"))) == true AND fn::essai_coherent(fn::essai_id("jean"));
};

-- préparation: compte de jean réactivé
fn::mail_account_update({ account: fn::essai_id("jean"), state: "active" });

-- test: compteurs égaux au contenu réel en fin de scénario
RETURN fn::essai_coherent(fn::essai_id("jean")) AND fn::essai_coherent(fn::essai_id("marie"));
