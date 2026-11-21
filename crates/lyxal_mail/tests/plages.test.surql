-- lyxal-test: assertions
-- Plages d'identifiants (décision P1) : identifiants ordonnés des messages et vue par date,
-- pages par UID et par date lues par plages bornées (trous d'UID, dates éloignées, égalités),
-- isolement par les permissions des tables (autre membre, autre organisation, administrateur),
-- vue par date fermée à l'écriture directe, gardes de l'identifiant.
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


-- préparation: un message dans la boîte de jean
UPDATE passe:ids SET m1 = <string> fn::essai_message(fn::essai_id("jean"), fn::essai_id("jean_inbox"), {}).data.id;


-- préparation: boîte de jean : 12 messages d'UID 1 à 12 (m1 et 11 autres), dates espacées d'un jour en remontant, sauf deux à la même date ; UID 3 à 8 effacés (trou) ; un message de marie
{
    LET $jean = fn::essai_id("jean");
    LET $inbox = fn::essai_id("jean_inbox");
    LET $more = (<array> (2..13)).map(|$n| <string> fn::essai_message($jean, $inbox, { received_at: d"2026-06-01T00:00:00Z" - duration::from_days($n * 30) }).data.id);
    LET $same = d"2026-06-01T00:00:00Z" - duration::from_days(300);
    UPDATE passe:ids SET m_same_a = <string> fn::essai_message($jean, $inbox, { received_at: $same }).data.id,
        m_same_b = <string> fn::essai_message($jean, $inbox, { received_at: $same }).data.id,
        m2 = <string> fn::essai_message(fn::essai_id("marie"), fn::essai_id("marie_inbox"), {}).data.id;
    fn::mail_message_expunge({ mailbox: $inbox, messages: array::slice($more, 1, 7) });
};

-- test: identifiants ordonnés : <clé du dossier>_<10^10 + UID> ; vue par date tenue (une fiche par message, retirée avec lui)
{
    LET $inbox = type::record(fn::essai_id("jean_inbox"));
    LET $ids = (SELECT VALUE id FROM mail_message WHERE mailbox = $inbox ORDER BY uid);
    LET $uids = (SELECT VALUE uid FROM mail_message WHERE mailbox = $inbox ORDER BY uid);
    RETURN $ids == $uids.map(|$u| fn::mail_message_key($inbox, $u))
        AND $uids == [1, 2, 9, 10, 11, 12, 13, 14]
        AND (SELECT VALUE message FROM mail_message_date WHERE mailbox = $inbox).sort() == $ids.sort()
        AND count(SELECT id FROM mail_message_date) == count(SELECT id FROM mail_message);
};

-- test: pages par UID à travers le trou des effacements : sans doublon ni manque, curseur
-- en tant que: jean
{
    LET $inbox = fn::essai_id("jean_inbox");
    LET $first = fn::mail_message_list({ mailbox: $inbox, uid_min: 1, limit: 3 }).data;
    LET $second = fn::mail_message_list({ mailbox: $inbox, uid_min: $first.next.uid_min, limit: 3 }).data;
    LET $third = fn::mail_message_list({ mailbox: $inbox, uid_min: $second.next.uid_min, limit: 3 }).data;
    RETURN $first.items.uid == [1, 2, 9] AND $second.items.uid == [10, 11, 12] AND $third.items.uid == [13, 14] AND $third.next IS NONE
        AND fn::mail_message_list({ mailbox: $inbox, uid_min: 3, uid_max: 8 }).data.items == []
        AND fn::mail_message_list({ mailbox: $inbox, uid_min: 10, uid_max: 11, limit: 5 }).data.items.uid == [10, 11];
};

-- test: pages par date décroissante (fenêtres sur des dates éloignées, deux messages de même date départagés par l'UID) : sans doublon ni manque, même ordre qu'un tri complet
-- en tant que: jean
{
    LET $inbox = fn::essai_id("jean_inbox");
    LET $all = (SELECT VALUE id FROM mail_message WHERE mailbox = type::record($inbox) ORDER BY received_at DESC, uid DESC);
    LET $pages = array::fold(<array> (0..5), { ids: [], next: NONE, done: false }, |$acc, $i| {
        IF $acc.done { RETURN $acc; };
        LET $page = fn::mail_message_list(IF $acc.next IS NONE { { mailbox: $inbox, limit: 2 } } ELSE { { mailbox: $inbox, limit: 2, before: $acc.next.before } }).data;
        RETURN { ids: array::concat($acc.ids, $page.items.id), next: $page.next, done: $page.next IS NONE };
    });
    RETURN $pages.ids == $all AND array::len($all) == 8 AND $pages.done
        AND fn::mail_message_list({ mailbox: $inbox, limit: 50 }).data.items.id == $all;
};

-- test: un autre membre ne lit rien de la boîte de jean par une plage d'identifiants, ni dans la vue par date, ni par les pages internes
-- en tant que: marie
{
    LET $inbox = type::record(fn::essai_id("jean_inbox"));
    RETURN (SELECT * FROM type::record("mail_message", fn::mail_message_key_text($inbox, 0)..fn::mail_message_key_text($inbox, 4294967296))) == []
        AND (SELECT * FROM type::record("mail_message_date", fn::mail_message_date_key_text($inbox, 0, 0)..fn::mail_message_date_key_text($inbox, 99999999999999999, 0))) == []
        AND (SELECT * FROM mail_message_date).all(|$d| $d.account == type::record(fn::essai_id("marie")))
        AND fn::mail_message_uid_page($inbox, 1, 100, 10) == []
        AND fn::mail_message_date_page({ id: $inbox, total: 8, received_min: d"2020-01-01T00:00:00Z", received_max: d"2027-01-01T00:00:00Z" }, NONE, 10) == []
        AND (SELECT * FROM ONLY fn::mail_message_key($inbox, 1)) IS NONE
        AND fn::mail_message_list({ mailbox: fn::essai_id("jean_inbox") }).error.code == "MAIL_MAILBOX_NOT_FOUND";
};

-- test: un administrateur d'une autre organisation non plus, ni l'administrateur d'Alpha (décision M11)
-- en tant que: autre
RETURN (SELECT * FROM type::record("mail_message", fn::mail_message_key_text(type::record(fn::essai_id("jean_inbox")), 0)..fn::mail_message_key_text(type::record(fn::essai_id("jean_inbox")), 4294967296))) == []
    AND count(SELECT id FROM mail_message_date) == 0;

-- test: … ni l'administrateur d'Alpha
-- en tant que: admin
RETURN (SELECT * FROM type::record("mail_message", fn::mail_message_key_text(type::record(fn::essai_id("jean_inbox")), 0)..fn::mail_message_key_text(type::record(fn::essai_id("jean_inbox")), 4294967296))) == []
    AND count(SELECT id FROM mail_message_date) == 0;

-- test: la vue par date ne s'écrit pas directement, même par le titulaire
-- en tant que: jean
{
    LET $inbox = type::record(fn::essai_id("jean_inbox"));
    LET $row = (SELECT * FROM mail_message_date WHERE mailbox = $inbox LIMIT 1)[0];
    RETURN array::len(UPDATE $row.id SET uid = 99) == 0 AND array::len(DELETE $row.id RETURN BEFORE) == 0
        AND array::len(CREATE type::record("mail_message_date", fn::mail_message_date_key_text($inbox, 0, 1)) CONTENT { tenant: auth_organization:alpha, account: type::record(fn::essai_id("jean")), mailbox: $inbox, message: $row.message, received_at: d"1970-01-01T00:00:00Z", uid: 1 }) == 0
        AND count(SELECT id FROM mail_message_date WHERE mailbox = $inbox) == 8;
};

-- test: écriture directe : un message s'inscrit sous son identifiant ordonné seulement
-- en tant que: jean
-- attendu-erreur: MAIL_WRITE_FORBIDDEN
CREATE fn::mail_message_key(type::record(fn::essai_id("jean_inbox")), 500) CONTENT {
    tenant: auth_organization:alpha, account: type::record(fn::essai_id("jean")), mailbox: type::record(fn::essai_id("jean_inbox")),
    content: (SELECT VALUE content FROM ONLY type::record(fn::essai_id("m1"))), uid: 501, modseq: 1000, create_modseq: 1000, thread: "t", received_at: time::now(), size: 100
};

-- test: écriture directe : l'UID d'un message ne change pas (partie de son identifiant)
-- en tant que: jean
-- attendu-erreur: MAIL_WRITE_FORBIDDEN
UPDATE type::record(fn::essai_id("m1")) SET uid = 600, modseq = 2000;

-- test: compteurs égaux au contenu réel après déplacements et effacements ; date bornes du dossier
{
    LET $inbox = type::record(fn::essai_id("jean_inbox"));
    LET $box = (SELECT received_min, received_max FROM ONLY $inbox);
    RETURN fn::essai_coherent(fn::essai_id("jean")) AND $box.received_min <= d"2025-08-05T00:00:00Z" AND $box.received_max >= d"2026-01-01T00:00:00Z";
};

-- test: règle de lecture par fiche : même texte sur les trois tables
{
    LET $rule = |$table| string::split(string::split((INFO FOR DB).tables[$table], "FOR select WHERE ")[1], ", FOR ")[0];
    RETURN $rule("mail_message") == $rule("mail_message_date") AND $rule("mail_message") == $rule("mail_tombstone")
        AND string::contains($rule("mail_message"), "owner");
};

-- test: règle de lecture par fiche : le titulaire lit ses fiches, jamais celles d'une autre boîte ni d'une autre organisation
-- en tant que: jean
RETURN count(SELECT id FROM mail_message) == count(SELECT id FROM mail_message WHERE owner = auth_identity:jean) AND count(SELECT id FROM mail_message) > 0
    AND count(SELECT id FROM mail_message_date) == count(SELECT id FROM mail_message)
    AND count(SELECT id FROM mail_tombstone) == count(SELECT id FROM mail_tombstone WHERE owner = auth_identity:jean) AND count(SELECT id FROM mail_tombstone) > 0;

-- test: contrôle par fiche : aucune permission du courrier n'exige de niveau d'assurance ; titulaire recopié sur chaque fiche
RETURN (SELECT VALUE min_aal FROM auth_permission WHERE module = "lyxal_mail").all(|$a| $a IS NONE OR $a <= 1)
    AND count(SELECT id FROM mail_message WHERE owner IS NONE) == 0
    AND count(SELECT id FROM mail_tombstone WHERE owner IS NONE) == 0
    AND count(SELECT id FROM mail_message_date WHERE owner IS NONE) == 0
    AND count(SELECT id FROM mail_message WHERE owner != account.identity) == 0;

-- test: contrôle par fiche : le compte de service voit toute fiche
-- en tant que: worker
RETURN count(SELECT id FROM mail_message) == count(SELECT id FROM mail_message_date)
    AND count(SELECT id FROM mail_message WHERE owner = auth_identity:marie) > 0 AND count(SELECT id FROM mail_message WHERE owner = auth_identity:jean) > 0;

-- test: contrôle par fiche : l'administrateur d'Alpha ne lit jamais le contenu d'une boîte (décision M11)
-- en tant que: admin
RETURN count(SELECT id FROM mail_message) == 0 AND count(SELECT id FROM mail_message_date) == 0 AND count(SELECT id FROM mail_tombstone) == 0;

-- préparation: compte de jean désactivé par l'administration
-- en tant que: admin
fn::mail_account_update({ account: fn::essai_id("jean"), state: "disabled" });

-- test: compte désactivé : le titulaire lit encore sa boîte (fonctions et lecture directe), n'y change plus rien
-- en tant que: jean
RETURN array::len(fn::mail_message_list({ mailbox: fn::essai_id("jean_inbox") }).data.items) == 8
    AND count(SELECT id FROM type::record("mail_message", fn::mail_message_key_text(type::record(fn::essai_id("jean_inbox")), 0)..fn::mail_message_key_text(type::record(fn::essai_id("jean_inbox")), 4294967296))) == 8
    AND fn::mail_message_flags_set({ messages: [fn::essai_id("m1")], add: ["$flagged"] }).error.code == "MAIL_ACCOUNT_DISABLED";

-- préparation: compte de jean réactivé
-- en tant que: admin
fn::mail_account_update({ account: fn::essai_id("jean"), state: "active" });

-- préparation: session de marie révoquée
UPDATE auth_session:marie SET state = "revoked", revoked_at = time::now(), revoked_reason = "essai";

-- test: session révoquée : plus aucune fiche lue, même directement
-- en tant que: marie
RETURN count(SELECT id FROM mail_message) == 0 AND count(SELECT id FROM mail_message_date) == 0 AND count(SELECT id FROM mail_tombstone) == 0;

-- préparation: jean retiré de l'organisation Alpha (la version de ses droits augmente : son jeton est périmé)
DELETE auth_member_of WHERE in = auth_identity:jean AND out = auth_organization:alpha;

-- test: membre retiré de l'organisation : fonctions refusées et aucune fiche lue, même directement, dès le retrait
-- en tant que: jean
RETURN (SELECT VALUE permissions_version FROM ONLY auth_identity:jean) > 1
    AND fn::mail_message_list({ mailbox: fn::essai_id("jean_inbox") }).error.code == "MAIL_MAILBOX_NOT_FOUND"
    AND fn::mail_message_get({ message: fn::essai_id("m1") }).error.code == "MAIL_MESSAGE_NOT_FOUND"
    AND count(SELECT id FROM type::record("mail_message", fn::mail_message_key_text(type::record(fn::essai_id("jean_inbox")), 0)..fn::mail_message_key_text(type::record(fn::essai_id("jean_inbox")), 4294967296))) == 0
    AND count(SELECT id FROM mail_message) == 0 AND count(SELECT id FROM mail_message_date) == 0 AND count(SELECT id FROM mail_tombstone) == 0;
