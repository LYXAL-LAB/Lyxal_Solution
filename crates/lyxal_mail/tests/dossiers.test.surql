-- lyxal-test: assertions
-- Dossiers : création (chemin, UIDVALIDITY tirée du compte, INBOX réservé, rôles uniques,
-- caractères interdits, limite), renommage et déplacement (sous-dossiers réécrits, UIDVALIDITY
-- gardée, boucle refusée), suppression (boîte de réception, parent, dossier non vide, vidage,
-- plus de 5 000 messages), UIDVALIDITY plus grande pour un dossier recréé, droits du titulaire
-- seulement, gardes des écritures directes.
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


-- test: jean crée Projets puis Projets/2026 : chemins, UIDVALIDITY 7 et 8, numéros de modification croissants
-- en tant que: jean
{
    LET $projets = fn::mail_mailbox_create({ name: "  Projets " }).data;
    LET $annee = fn::mail_mailbox_create({ name: "2026", parent: <string> $projets.id, subscribed: false }).data;
    UPDATE passe:ids SET projets = <string> $projets.id, annee = <string> $annee.id;
    RETURN $projets.{ name, path, parent, role, uid_validity, uid_next, total, subscribed } == { name: "Projets", path: "Projets", parent: NONE, role: NONE, uid_validity: 7, uid_next: 1, total: 0, subscribed: true }
        AND $annee.{ path, parent, uid_validity, subscribed } == { path: "Projets/2026", parent: $projets.id, uid_validity: 8, subscribed: false }
        AND $annee.modseq > $projets.modseq AND $projets.modseq > 6 AND $annee.highest_modseq == $annee.modseq
        AND fn::mail_account_get({}).data.{ mailbox_count, uid_validity_next, modseq } == { mailbox_count: 8, uid_validity_next: 9, modseq: $annee.modseq };
};

-- test: INBOX est réservé quelle que soit la casse ; un chemin existant est refusé ; un sous-dossier INBOX/x est permis
-- en tant que: jean
RETURN ["INBOX", "inbox", "Inbox", "Projets"].all(|$name| fn::mail_mailbox_create({ name: $name }).error.code == "MAIL_MAILBOX_EXISTS")
    AND fn::mail_mailbox_create({ name: "2026", parent: fn::essai_id("projets") }).error.code == "MAIL_MAILBOX_EXISTS"
    AND fn::mail_mailbox_create({ name: "Factures", parent: fn::essai_id("jean_inbox") }).data.path == "INBOX/Factures";

-- test: noms refusés : « / », jokers IMAP, vide, trop long, caractères de contrôle seuls ; parent absent
-- en tant que: jean
RETURN ["a/b", "a*", "50%", "   ", string::repeat("x", 256), "\u0007"].all(|$name| fn::mail_mailbox_create({ name: $name }).error.code == "MAIL_INVALID_PARAMETERS")
    AND fn::mail_mailbox_create({ name: "Bon", parent: "mail_mailbox:absent" }).error.code == "MAIL_MAILBOX_NOT_FOUND"
    AND fn::mail_mailbox_create({ name: "Bon", role: "inbox" }).error.code == "MAIL_INVALID_PARAMETERS";

-- test: un rôle par compte
-- en tant que: jean
RETURN fn::mail_mailbox_create({ name: "Corbeille", role: "trash" }).error.{ code, details } == { code: "MAIL_MAILBOX_ROLE_TAKEN", details: { role: "trash" } };

-- test: lecture d'un dossier et liste triée par chemin
-- en tant que: jean
RETURN fn::mail_mailbox_get({ mailbox: fn::essai_id("annee") }).data.path == "Projets/2026"
    AND fn::mail_mailbox_list({}).data.path == ["Archive", "Drafts", "INBOX", "INBOX/Factures", "Junk", "Projets", "Projets/2026", "Sent", "Trash"]
    AND fn::mail_mailbox_get({ mailbox: "mail_mailbox:absent" }).error.code == "MAIL_MAILBOX_NOT_FOUND";

-- test: renommage : sous-dossiers réécrits, UIDVALIDITY gardée, numéro de modification avancé
-- en tant que: jean
{
    LET $earlier = fn::mail_mailbox_get({ mailbox: fn::essai_id("annee") }).data;
    LET $renamed = fn::mail_mailbox_update({ mailbox: fn::essai_id("projets"), name: "Chantiers" }).data;
    LET $child = fn::mail_mailbox_get({ mailbox: fn::essai_id("annee") }).data;
    RETURN $renamed.{ name, path, uid_validity } == { name: "Chantiers", path: "Chantiers", uid_validity: 7 }
        AND $child.path == "Chantiers/2026" AND $child.uid_validity == 8 AND $child.modseq > $earlier.modseq AND $child.modseq == $renamed.modseq;
};

-- test: déplacement sous un autre dossier, puis retour au premier niveau ; boucle refusée
-- en tant que: jean
{
    LET $moved = fn::mail_mailbox_update({ mailbox: fn::essai_id("projets"), parent: fn::essai_id("jean_archive") }).data;
    LET $child = fn::mail_mailbox_get({ mailbox: fn::essai_id("annee") }).data.path;
    LET $back = fn::mail_mailbox_update({ mailbox: fn::essai_id("projets"), clear: ["parent"] }).data;
    RETURN $moved.path == "Archive/Chantiers" AND $child == "Archive/Chantiers/2026" AND $back.path == "Chantiers" AND $back.parent IS NONE
        AND fn::mail_mailbox_update({ mailbox: fn::essai_id("projets"), parent: fn::essai_id("annee") }).error.details.fields == { parent: ["cycle"] }
        AND fn::mail_mailbox_update({ mailbox: fn::essai_id("projets"), parent: fn::essai_id("projets") }).error.details.fields == { parent: ["cycle"] }
        AND fn::mail_mailbox_update({ mailbox: fn::essai_id("projets"), parent: fn::essai_id("marie_inbox") }).error.code == "MAIL_MAILBOX_NOT_FOUND";
};

-- test: rôles, abonnement, ordre ; une modification sans effet ne prend pas de numéro de modification
-- en tant que: jean
{
    LET $archive = fn::mail_mailbox_update({ mailbox: fn::essai_id("jean_archive"), clear: ["role"] }).data;
    LET $role = fn::mail_mailbox_update({ mailbox: fn::essai_id("projets"), role: "archive", subscribed: false, sort_order: 9 }).data;
    LET $same = fn::mail_mailbox_update({ mailbox: fn::essai_id("projets"), sort_order: 9 }).data;
    RETURN $archive.role IS NONE AND $role.{ role, subscribed, sort_order } == { role: "archive", subscribed: false, sort_order: 9 }
        AND $same.modseq == $role.modseq
        AND fn::mail_mailbox_update({ mailbox: fn::essai_id("jean_archive"), role: "archive" }).error.code == "MAIL_MAILBOX_ROLE_TAKEN"
        AND fn::mail_mailbox_update({ mailbox: fn::essai_id("jean_archive"), name: "inbox" }).error.code == "MAIL_MAILBOX_EXISTS"
        AND fn::mail_mailbox_update({ mailbox: fn::essai_id("jean_archive"), name: "Chantiers" }).error.code == "MAIL_MAILBOX_EXISTS"
        AND fn::mail_mailbox_update({ mailbox: fn::essai_id("jean_archive"), name: "a/b" }).error.code == "MAIL_INVALID_PARAMETERS";
};

-- test: la boîte de réception ne se renomme, ne se déplace, ne perd son rôle ni ne se supprime
-- en tant que: jean
{
    LET $inbox = fn::essai_id("jean_inbox");
    RETURN fn::mail_mailbox_update({ mailbox: $inbox, name: "Reçus" }).error.code == "MAIL_MAILBOX_PROTECTED"
        AND fn::mail_mailbox_update({ mailbox: $inbox, parent: fn::essai_id("jean_archive") }).error.code == "MAIL_MAILBOX_PROTECTED"
        AND fn::mail_mailbox_update({ mailbox: $inbox, clear: ["role"] }).error.code == "MAIL_MAILBOX_PROTECTED"
        AND fn::mail_mailbox_update({ mailbox: $inbox, subscribed: false }).data.subscribed == false
        AND fn::mail_mailbox_delete({ mailbox: $inbox }).error.code == "MAIL_MAILBOX_PROTECTED";
};

-- test: un dossier parent ne se supprime pas ; un dossier vide, si ; pierre tombale du dossier
-- en tant que: jean
{
    LET $refused_parent = fn::mail_mailbox_delete({ mailbox: fn::essai_id("projets") }).error.code;
    LET $earlier = fn::mail_account_get({}).data.modseq;
    LET $deleted = fn::mail_mailbox_delete({ mailbox: fn::essai_id("annee") }).data;
    LET $tomb = (SELECT kind, mailbox, object, modseq FROM ONLY mail_tombstone WHERE kind = "mailbox" LIMIT 1);
    RETURN $refused_parent == "MAIL_MAILBOX_HAS_CHILDREN" AND $deleted == { deleted: true, expunged: 0 }
        AND $tomb == { kind: "mailbox", mailbox: fn::essai_id("annee"), object: fn::essai_id("annee"), modseq: $earlier + 1 }
        AND fn::mail_account_get({}).data.{ modseq, mailbox_count } == { modseq: $earlier + 1, mailbox_count: 8 };
};

-- test: dossier recréé sous le même nom : UIDVALIDITY plus grande
-- en tant que: jean
{
    LET $again = fn::mail_mailbox_create({ name: "2026", parent: fn::essai_id("projets") }).data;
    UPDATE passe:ids SET annee = <string> $again.id;
    RETURN $again.path == "Chantiers/2026" AND $again.uid_validity == 10;
};

-- préparation: deux messages dans Chantiers/2026
{
    fn::essai_message(fn::essai_id("jean"), fn::essai_id("annee"), {});
    fn::essai_message(fn::essai_id("jean"), fn::essai_id("annee"), { seen: true, size: 40 });
};

-- test: un dossier non vide ne se supprime qu'avec ses messages ; pierres tombales des messages
-- en tant que: jean
{
    LET $refused = fn::mail_mailbox_delete({ mailbox: fn::essai_id("annee") }).error.{ code, details };
    LET $deleted = fn::mail_mailbox_delete({ mailbox: fn::essai_id("annee"), remove_messages: true }).data;
    RETURN $refused == { code: "MAIL_MAILBOX_NOT_EMPTY", details: { total: 2 } } AND $deleted == { deleted: true, expunged: 2 }
        AND (SELECT VALUE kind FROM mail_tombstone WHERE mailbox = fn::essai_id("annee") ORDER BY modseq) == ["message", "message", "mailbox"]
        AND fn::essai_coherent(fn::essai_id("jean"));
};

-- préparation: un dossier gonflé de plus de 5 000 messages (compteur posé par la session système)
{
    LET $big = fn::mail_mailbox_create({ account: fn::essai_id("jean"), name: "Gros" }).data.id;
    UPDATE $big SET total = 5001;
    UPDATE passe:ids SET gros = <string> $big;
};

-- test: plus de 5 000 messages : vidage par lots d'abord
-- en tant que: jean
RETURN fn::mail_mailbox_delete({ mailbox: fn::essai_id("gros"), remove_messages: true }).error.code == "MAIL_MAILBOX_TOO_LARGE";

-- préparation: compteur rétabli
UPDATE type::record(fn::essai_id("gros")) SET total = 0;

-- test: limite de dossiers par compte (réglage de l'organisation)
-- en tant que: admin
{
    fn::mail_settings_set({ tenant: "auth_organization:alpha", max_mailboxes_per_account: 6 });
    RETURN fn::mail_settings_effective({ tenant: auth_organization:alpha }).max_mailboxes_per_account == 6;
};

-- test: marie a atteint la limite de six dossiers
-- en tant que: marie
RETURN fn::mail_mailbox_create({ name: "Septième" }).error.{ code, details } == { code: "MAIL_MAILBOX_LIMIT", details: { max_mailboxes_per_account: 6 } };

-- test: un autre membre ne voit ni ne touche les dossiers de jean
-- en tant que: marie
RETURN fn::mail_mailbox_get({ mailbox: fn::essai_id("projets") }).error.code == "MAIL_MAILBOX_NOT_FOUND"
    AND fn::mail_mailbox_update({ mailbox: fn::essai_id("projets"), name: "Pirate" }).error.code == "MAIL_MAILBOX_NOT_FOUND"
    AND fn::mail_mailbox_delete({ mailbox: fn::essai_id("projets") }).error.code == "MAIL_MAILBOX_NOT_FOUND"
    AND fn::mail_mailbox_list({ account: fn::essai_id("jean") }).error.code == "MAIL_ACCOUNT_NOT_FOUND"
    AND fn::mail_mailbox_create({ name: "Intrus", parent: fn::essai_id("projets") }).error.code == "MAIL_MAILBOX_NOT_FOUND"
    AND fn::mail_mailbox_create({ name: "Intrus", account: fn::essai_id("jean") }).error.code == "MAIL_ACCOUNT_NOT_FOUND"
    AND array::len(SELECT * FROM mail_mailbox WHERE account = type::record(fn::essai_id("jean"))) == 0;

-- test: l'administrateur gère le compte, jamais ses dossiers (décision M11)
-- en tant que: admin
RETURN fn::mail_mailbox_create({ name: "Admin", account: fn::essai_id("jean") }).error.code == "MAIL_PERMISSION_DENIED"
    AND fn::mail_mailbox_get({ mailbox: fn::essai_id("projets") }).error.code == "MAIL_MAILBOX_NOT_FOUND";

-- test: le compte de service crée un dossier dans tout compte
-- en tant que: worker
RETURN fn::mail_mailbox_create({ name: "Service", account: fn::essai_id("marie") }).error.code == "MAIL_MAILBOX_LIMIT"
    AND fn::mail_mailbox_create({ name: "Service", account: fn::essai_id("autre") }).data.path == "Service"
    AND fn::mail_mailbox_create({ name: "Sans compte" }).error.code == "MAIL_ACCOUNT_NOT_FOUND";

-- test: écriture directe : les compteurs d'un dossier ne s'écrivent pas (ignorés)
-- en tant que: jean
{
    LET $box = type::record(fn::essai_id("jean_inbox"));
    UPDATE $box SET total = 99, unseen = 99, uid_next = 1000, highest_modseq = 1;
    RETURN (SELECT VALUE [total, unseen, uid_next] FROM ONLY $box) == [0, 0, 1];
};

-- test: écriture directe : un renommage sans numéro de modification est refusé
-- en tant que: jean
-- attendu-erreur: MAIL_WRITE_FORBIDDEN
UPDATE type::record(fn::essai_id("projets")) SET name = "Direct", path = "Direct";

-- test: écriture directe : un chemin incohérent avec le parent est refusé
-- en tant que: jean
-- attendu-erreur: MAIL_WRITE_FORBIDDEN
UPDATE type::record(fn::essai_id("projets")) SET name = "Direct", path = "Ailleurs/Direct", modseq = fn::mail_modseq_next(type::record(fn::essai_id("jean")));

-- test: écriture directe : un dossier créé avec une UIDVALIDITY déjà servie est refusé
-- en tant que: jean
-- attendu-erreur: MAIL_WRITE_FORBIDDEN
CREATE mail_mailbox CONTENT { tenant: auth_organization:alpha, account: type::record(fn::essai_id("jean")), name: "Vieux", path: "Vieux", uid_validity: 1, modseq: 1000, highest_modseq: 1000 };

-- test: écriture directe : un renommage avec numéro de modification et chemin cohérents passe ; compteurs exacts
-- en tant que: jean
{
    UPDATE type::record(fn::essai_id("projets")) SET name = "Direct", path = "Direct", modseq = fn::mail_modseq_next(type::record(fn::essai_id("jean")));
    RETURN fn::mail_mailbox_get({ mailbox: fn::essai_id("projets") }).data.path == "Direct" AND fn::essai_coherent(fn::essai_id("jean"));
};
