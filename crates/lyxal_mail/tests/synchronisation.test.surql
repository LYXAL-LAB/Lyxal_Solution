-- lyxal-test: assertions
-- Synchronisation : numéros de modification croissants dans le compte, changements d'un compte ou
-- d'un dossier depuis un numéro (créations, drapeaux, déplacements, effacements, dossiers
-- supprimés), pages sans couper un numéro de modification, pierres tombales purgées après la
-- conservation de l'organisation, plancher du compte et MAIL_CHANGES_TOO_OLD.
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


-- préparation: trois messages dans INBOX, un dossier Projets
{
    UPDATE passe:ids SET since0 = (SELECT VALUE modseq FROM ONLY type::record(fn::essai_id("jean")));
    FOR $n IN [1, 2, 3] { fn::essai_message(fn::essai_id("jean"), fn::essai_id("jean_inbox"), {}); };
    UPDATE passe:ids SET projets = <string> fn::mail_mailbox_create({ account: fn::essai_id("jean"), name: "Projets" }).data.id;
};

-- test: numéros de modification croissants dans le compte, un par écriture
-- en tant que: jean
{
    LET $modseqs = (SELECT VALUE modseq FROM mail_message ORDER BY uid);
    LET $since0 = (SELECT VALUE since0 FROM ONLY passe:ids);
    RETURN $modseqs == [$since0 + 1, $since0 + 2, $since0 + 3]
        AND fn::mail_account_get({}).data.modseq == $since0 + 4;
};

-- test: changements du compte depuis le début : trois créations, aucun effacement
-- en tant que: jean
{
    LET $since0 = (SELECT VALUE since0 FROM ONLY passe:ids);
    LET $changes = fn::mail_message_changes({ account: fn::essai_id("jean"), since: $since0 }).data;
    RETURN array::len($changes.changed) == 3 AND $changes.removed == [] AND $changes.more == false
        AND $changes.highest_modseq == $since0 + 4
        AND $changes.changed[0].keys() == ["deleted", "id", "keywords", "mailbox", "modseq", "uid", "answered", "draft", "flagged", "seen"].sort()
        AND fn::mail_message_changes({ account: fn::essai_id("jean"), since: $since0 + 4 }).data == { changed: [], removed: [], highest_modseq: $since0 + 4, more: false };
};

-- préparation: point de synchronisation, puis drapeau, déplacement, effacement, dossier supprimé
{
    LET $ids = (SELECT VALUE id FROM mail_message WHERE account = type::record(fn::essai_id("jean")) ORDER BY uid);
    UPDATE passe:ids SET since1 = (SELECT VALUE modseq FROM ONLY type::record(fn::essai_id("jean"))), ids = $ids.map(|$i| <string> $i);
    fn::mail_message_flags_set({ messages: [<string> $ids[0]], add: ["$seen"] });
    fn::mail_message_move({ messages: [<string> $ids[1]], mailbox: fn::essai_id("jean_archive") });
    fn::mail_message_expunge({ mailbox: fn::essai_id("jean_inbox"), messages: [<string> $ids[2]] });
    fn::mail_mailbox_delete({ mailbox: fn::essai_id("projets") });
};

-- test: changements du compte : drapeau et déplacement modifiés, effacement et départ du dossier source, dossier supprimé
-- en tant que: jean
{
    LET $p = (SELECT * FROM ONLY passe:ids);
    LET $changes = fn::mail_message_changes({ account: $p.jean, since: $p.since1 }).data;
    RETURN $changes.changed.id == [type::record($p.ids[0]), type::record($p.ids[1])]
        AND $changes.changed[0].seen == true AND $changes.changed[1].mailbox == type::record($p.jean_archive) AND $changes.changed[1].uid == 1
        AND $changes.removed.map(|$r| [$r.kind, $r.mailbox, $r.uid, $r.object]) == [
            ["message", $p.jean_inbox, 2, $p.ids[1]], ["message", $p.jean_inbox, 3, $p.ids[2]], ["mailbox", $p.projets, NONE, $p.projets]
        ]
        AND $changes.removed.all(|$r| $r.keys().len() == 5 OR $r.kind == "mailbox")
        AND $changes.highest_modseq == fn::mail_account_get({}).data.modseq AND !$changes.more;
};

-- test: changements d'un dossier : INBOX voit un drapeau et deux départs ; Archive une arrivée ; HIGHESTMODSEQ
-- en tant que: jean
{
    LET $p = (SELECT * FROM ONLY passe:ids);
    LET $inbox = fn::mail_message_changes({ mailbox: $p.jean_inbox, since: $p.since1 }).data;
    LET $archive = fn::mail_message_changes({ mailbox: $p.jean_archive, since: $p.since1 }).data;
    LET $box = fn::mail_mailbox_get({ mailbox: $p.jean_inbox }).data;
    RETURN $inbox.changed.id == [type::record($p.ids[0])] AND $inbox.removed.uid == [2, 3]
        AND $inbox.highest_modseq == $box.highest_modseq AND $box.highest_modseq == $inbox.removed[1].modseq
        AND $archive.changed.id == [type::record($p.ids[1])] AND $archive.removed == [];
};

-- test: pages : limit coupe entre deux numéros de modification, highest_modseq sert de point de reprise
-- en tant que: jean
{
    LET $p = (SELECT * FROM ONLY passe:ids);
    LET $first = fn::mail_message_changes({ account: $p.jean, since: $p.since0, limit: 2 }).data;
    LET $second = fn::mail_message_changes({ account: $p.jean, since: $first.highest_modseq, limit: 2 }).data;
    LET $third = fn::mail_message_changes({ account: $p.jean, since: $second.highest_modseq, limit: 2 }).data;
    LET $all = fn::mail_message_changes({ account: $p.jean, since: $p.since0 }).data;
    LET $paged = array::flatten([$first.changed, $second.changed, $third.changed]).id;
    RETURN $first.more AND array::len($first.changed) + array::len($first.removed) == 1 AND $first.highest_modseq == $first.changed[0].modseq
        AND array::len(array::flatten([$first.removed, $second.removed, $third.removed])) == array::len($all.removed)
        AND array::sort::asc($paged) == array::sort::asc($all.changed.id) AND !$third.more;
};

-- préparation: quatre messages modifiés par une seule écriture (même numéro de modification)
{
    LET $ids = (SELECT VALUE id FROM mail_message WHERE account = type::record(fn::essai_id("jean")));
    FOR $n IN [1, 2, 3] { fn::essai_message(fn::essai_id("jean"), fn::essai_id("jean_inbox"), {}); };
    LET $all = (SELECT VALUE id FROM mail_message WHERE account = type::record(fn::essai_id("jean")));
    UPDATE passe:ids SET since2 = (SELECT VALUE modseq FROM ONLY type::record(fn::essai_id("jean")));
    fn::mail_message_flags_set({ messages: $all.map(|$i| <string> $i), add: ["lot"] });
};

-- test: un numéro de modification plus grand que limit est rendu en entier, jamais coupé
-- en tant que: jean
{
    LET $p = (SELECT * FROM ONLY passe:ids);
    LET $page = fn::mail_message_changes({ account: $p.jean, since: $p.since2, limit: 1 }).data;
    RETURN array::len($page.changed) == 5 AND array::len(array::distinct($page.changed.modseq)) == 1
        AND $page.highest_modseq == $p.since2 + 1 AND $page.more == false;
};

-- test: paramètres : compte ou dossier, l'un des deux ; dossier ou compte d'un autre membre
-- en tant que: jean
RETURN fn::mail_message_changes({ since: 0 }).error.code == "MAIL_INVALID_PARAMETERS"
    AND fn::mail_message_changes({ account: fn::essai_id("jean"), mailbox: fn::essai_id("jean_inbox"), since: 0 }).error.code == "MAIL_INVALID_PARAMETERS"
    AND fn::mail_message_changes({ account: fn::essai_id("jean"), since: -1 }).error.code == "MAIL_INVALID_PARAMETERS"
    AND fn::mail_message_changes({ mailbox: fn::essai_id("marie_inbox"), since: 0 }).error.code == "MAIL_MAILBOX_NOT_FOUND"
    AND fn::mail_message_changes({ account: fn::essai_id("marie"), since: 0 }).error.code == "MAIL_ACCOUNT_NOT_FOUND";

-- test: l'administrateur ne lit pas les changements d'une boîte (décision M11)
-- en tant que: admin
RETURN fn::mail_message_changes({ account: fn::essai_id("jean"), since: 0 }).error.code == "MAIL_PERMISSION_DENIED";

-- test: pierres tombales récentes : la purge n'en retire aucune
-- en tant que: worker
RETURN fn::mail_tombstone_purge({}).data == { purged: 0 };

-- préparation: conservation de 10 jours pour alpha, 30 par défaut ailleurs ; une pierre tombale chez beta
{
    fn::mail_settings_set({ tenant: "auth_organization:alpha", tombstone_retention_days: 10 });
    fn::essai_message(fn::essai_id("autre"), fn::essai_id("autre_inbox"), {});
    fn::mail_message_expunge({ mailbox: fn::essai_id("autre_inbox"), messages: (SELECT VALUE id FROM mail_message WHERE account = type::record(fn::essai_id("autre"))).map(|$i| <string> $i) });
};

-- préparation: pierres tombales vieillies (champ en lecture seule : réécrites par la session système)
{
    LET $rows = (SELECT * FROM mail_tombstone);
    DELETE mail_tombstone;
    FOR $row IN $rows { CREATE mail_tombstone CONTENT object::extend($row, { created_at: time::now() - 20d }); };
};

-- test: un membre ne purge pas ; paramètres bornés
-- en tant que: jean
RETURN fn::mail_tombstone_purge({}).error.code == "MAIL_PERMISSION_DENIED"
    AND fn::mail_tombstone_purge({ limit: 0 }).error.code == "MAIL_INVALID_PARAMETERS";

-- test: purge par lots selon la conservation de chaque organisation ; plancher du compte avancé
-- en tant que: worker
{
    LET $jean = type::record(fn::essai_id("jean"));
    LET $highest = math::max((SELECT VALUE modseq FROM mail_tombstone WHERE account = $jean));
    LET $first = fn::mail_tombstone_purge({ limit: 1 }).data;
    LET $rest = fn::mail_tombstone_purge({}).data;
    RETURN $first == { purged: 1 } AND $rest == { purged: 2 }
        AND (SELECT VALUE changes_floor FROM ONLY $jean) == $highest
        AND array::len(SELECT * FROM mail_tombstone WHERE account = $jean) == 0
        AND array::len(SELECT * FROM mail_tombstone WHERE account = type::record(fn::essai_id("autre"))) == 1;
};

-- test: synchronisation plus ancienne que le plancher refusée ; au plancher, permise
-- en tant que: jean
{
    LET $floor = fn::mail_account_get({}).data.changes_floor;
    RETURN fn::mail_message_changes({ account: fn::essai_id("jean"), since: $floor - 1 }).error.{ code, details } == { code: "MAIL_CHANGES_TOO_OLD", details: { since: $floor - 1, floor: $floor } }
        AND fn::mail_message_changes({ account: fn::essai_id("jean"), since: $floor }).ok
        AND fn::mail_message_changes({ mailbox: fn::essai_id("jean_inbox"), since: 0 }).error.code == "MAIL_CHANGES_TOO_OLD";
};

-- test: les pierres tombales ne s'écrivent ni ne se suppriment par un membre
-- en tant que: autre
{
    DELETE mail_tombstone;
    CREATE mail_tombstone CONTENT { tenant: auth_organization:beta, account: type::record(fn::essai_id("autre")), kind: "message", mailbox: "x", object: "y", modseq: 1 };
    RETURN array::len(SELECT * FROM mail_tombstone) == 1;
};
