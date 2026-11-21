-- lyxal-test: assertions
-- Comptes : création avec l'adresse principale et les six dossiers (décision M18), membre de
-- l'organisation seulement, un compte par membre, partie locale ASCII (M10), lecture par le
-- titulaire et l'administrateur, liste par curseur, état, quota, suppression (adresses retirées,
-- compte en deleting), suppression de l'identité (M12), gardes des écritures directes.
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


-- préparation: domaine alpha.test
{
    LET $domain = fn::mail_domain_create({ auth_domain: "auth_organization_domain:alpha" }).data.id;
    CREATE passe:ids SET domain = <string> $domain;
};

-- test: l'administrateur crée le compte de jean : adresse en minuscules, compteurs à zéro sauf ceux des six dossiers
-- en tant que: admin
{
    LET $created = fn::mail_account_create({ identity: "auth_identity:jean", domain: (SELECT VALUE domain FROM ONLY passe:ids), local_part: " Jean.Dupont " }).data;
    UPDATE passe:ids SET jean = <string> $created.account.id;
    RETURN $created.address.address == "jean.dupont@alpha.test" AND $created.address.kind == "account" AND $created.address.account == $created.account.id
        AND $created.account.primary_address == $created.address.id AND $created.account.identity == auth_identity:jean
        AND $created.account.{ state, message_count, used_bytes, modseq, uid_validity_next, mailbox_count, address_count, changes_floor }
            == { state: "active", message_count: 0, used_bytes: 0, modseq: 6, uid_validity_next: 7, mailbox_count: 6, address_count: 1, changes_floor: 0 };
};

-- test: l'administrateur ne voit pas les dossiers de jean (décision M11)
-- en tant que: admin
RETURN array::len(SELECT * FROM mail_mailbox) == 0
    AND fn::mail_mailbox_list({ account: (SELECT VALUE jean FROM ONLY passe:ids) }).error.code == "MAIL_PERMISSION_DENIED";

-- test: jean voit ses six dossiers : noms anglais, rôles SPECIAL-USE, UIDVALIDITY tirées du compte
-- en tant que: jean
RETURN (SELECT VALUE [path, role, uid_validity, uid_next, total, subscribed] FROM mail_mailbox ORDER BY uid_validity) == [
        ["INBOX", "inbox", 1, 1, 0, true], ["Drafts", "drafts", 2, 1, 0, true], ["Sent", "sent", 3, 1, 0, true],
        ["Junk", "junk", 4, 1, 0, true], ["Trash", "trash", 5, 1, 0, true], ["Archive", "archive", 6, 1, 0, true]
    ]
    AND fn::mail_mailbox_list({}).data.path == ["Archive", "Drafts", "INBOX", "Junk", "Sent", "Trash"];

-- test: événements mail.account.created et mail.address.created, sans adresse
RETURN (SELECT VALUE payload FROM event_outbox WHERE event_type = "mail.account.created") == [{ account_id: (SELECT VALUE jean FROM ONLY passe:ids), tenant: "auth_organization:alpha" }]
    AND (SELECT VALUE payload.keys() FROM event_outbox WHERE event_type = "mail.address.created") == [["account_id", "address_id", "kind", "tenant"]];

-- test: refus : personne hors de l'organisation, compte en double, adresse prise, domaine absent
-- en tant que: admin
{
    LET $domain = (SELECT VALUE domain FROM ONLY passe:ids);
    RETURN fn::mail_account_create({ identity: "auth_identity:autre", domain: $domain, local_part: "autre" }).error.code == "MAIL_ACCOUNT_NOT_MEMBER"
        AND fn::mail_account_create({ identity: "auth_identity:absent", domain: $domain, local_part: "absent" }).error.code == "MAIL_ACCOUNT_NOT_MEMBER"
        AND fn::mail_account_create({ identity: "auth_identity:jean", domain: $domain, local_part: "jean2" }).error.code == "MAIL_ACCOUNT_EXISTS"
        AND fn::mail_account_create({ identity: "auth_identity:marie", domain: $domain, local_part: "JEAN.dupont" }).error.code == "MAIL_ADDRESS_EXISTS"
        AND fn::mail_account_create({ identity: "auth_identity:marie", domain: "mail_domain:absent", local_part: "marie" }).error.code == "MAIL_DOMAIN_NOT_FOUND";
};

-- test: décision M10 : partie locale ASCII en dot-atom de 64 caractères au plus
-- en tant que: admin
{
    LET $domain = (SELECT VALUE domain FROM ONLY passe:ids);
    RETURN ["a b", "rené", "a..b", ".a", "a.", "a@b", string::repeat("a", 65), ""].all(|$local|
            fn::mail_account_create({ identity: "auth_identity:marie", domain: $domain, local_part: $local }).error.code == "MAIL_INVALID_PARAMETERS")
        AND fn::mail_account_create({ identity: "auth_identity:marie", domain: $domain, local_part: "marie", quota_bytes: -1 }).error.code == "MAIL_INVALID_PARAMETERS";
};

-- test: compte de marie (partie locale avec caractères permis)
-- en tant que: admin
{
    LET $created = fn::mail_account_create({ identity: "auth_identity:marie", domain: (SELECT VALUE domain FROM ONLY passe:ids), local_part: "marie_o'neil+x", quota_bytes: 5000 });
    UPDATE passe:ids SET marie = <string> $created.data.account.id;
    RETURN $created.data.address.address == "marie_o'neil+x@alpha.test" AND $created.data.account.quota_bytes == 5000;
};

-- test: le titulaire lit son compte sans le nommer ; un autre membre ne le voit pas
-- en tant que: jean
RETURN fn::mail_account_get({}).data.id == type::record((SELECT VALUE jean FROM ONLY passe:ids))
    AND fn::mail_account_get({}).data.effective_quota_bytes IS NONE
    AND fn::mail_account_get({ account: (SELECT VALUE marie FROM ONLY passe:ids) }).error.code == "MAIL_ACCOUNT_NOT_FOUND"
    AND fn::mail_account_list({}).error.code == "MAIL_PERMISSION_DENIED"
    AND array::len(SELECT * FROM mail_account) == 1;

-- test: un membre sans compte n'en a pas
-- en tant que: membre
RETURN fn::mail_account_get({}).error.code == "MAIL_ACCOUNT_NOT_FOUND" AND fn::mail_quota_get({}).error.code == "MAIL_ACCOUNT_NOT_FOUND";

-- test: la session système doit nommer le compte
RETURN fn::mail_account_get({}).error.code == "MAIL_ACCOUNT_NOT_FOUND"
    AND fn::mail_account_get({ account: (SELECT VALUE marie FROM ONLY passe:ids) }).data.effective_quota_bytes == 5000;

-- test: liste des comptes par curseur (identifiant), filtre par état
-- en tant que: admin
{
    LET $first = fn::mail_account_list({ limit: 1 }).data;
    LET $second = fn::mail_account_list({ tenant: "auth_organization:alpha", limit: 1, after: $first.next }).data;
    LET $all = fn::mail_account_list({}).data.items.id;
    RETURN array::len($all) == 2 AND $first.items.id == [$all[0]] AND $second.items.id == [$all[1]] AND $second.next IS NONE
        AND fn::mail_account_list({ state: "disabled" }).data.items == []
        AND fn::mail_account_list({ state: "inconnu" }).error.code == "MAIL_INVALID_PARAMETERS";
};

-- test: état et quota changés par l'administrateur ; clear revient au quota des réglages
-- en tant que: admin
{
    LET $jean = (SELECT VALUE jean FROM ONLY passe:ids);
    LET $quota = fn::mail_account_update({ account: $jean, quota_bytes: 500 }).data;
    LET $read = fn::mail_account_get({ account: $jean }).data;
    LET $cleared = fn::mail_account_update({ account: $jean, clear: ["quota_bytes"] }).data;
    LET $disabled = fn::mail_account_update({ account: $jean, state: "disabled" }).data;
    RETURN $quota.quota_bytes == 500 AND $read.effective_quota_bytes == 500 AND $cleared.quota_bytes IS NONE AND $disabled.state == "disabled"
        AND fn::mail_account_update({ account: $jean, state: "deleting" }).error.code == "MAIL_INVALID_PARAMETERS";
};

-- test: compte désactivé : aucune écriture du titulaire
-- en tant que: jean
RETURN fn::mail_content_begin({ account: (SELECT VALUE jean FROM ONLY passe:ids), size: 10 }).error.code == "MAIL_ACCOUNT_DISABLED"
    AND fn::mail_mailbox_create({ name: "Projets" }).error.code == "MAIL_ACCOUNT_DISABLED";

-- test: compte réactivé ; quota du compte lu par son titulaire (ressources STORAGE et MESSAGE)
-- en tant que: admin
RETURN fn::mail_account_update({ account: (SELECT VALUE jean FROM ONLY passe:ids), state: "active", quota_bytes: 2000 }).data.state == "active";

-- test: le titulaire lit son quota
-- en tant que: jean
RETURN fn::mail_quota_get({}).data == {
        used_bytes: 0, message_count: 0, quota_bytes: 2000,
        resources: [{ name: "STORAGE", usage: 0, limit: 2000 }, { name: "MESSAGE", usage: 0, limit: NONE }]
    }
    AND fn::mail_quota_get({ account: (SELECT VALUE marie FROM ONLY passe:ids) }).error.code == "MAIL_ACCOUNT_NOT_FOUND";

-- test: un membre ne change ni l'état ni le quota de son compte, même en écriture directe
-- en tant que: jean
{
    LET $jean = type::record((SELECT VALUE jean FROM ONLY passe:ids));
    UPDATE $jean SET quota_bytes = 999999999, state = "disabled", used_bytes = 0, modseq = 1, message_count = 3;
    RETURN (SELECT VALUE [quota_bytes, state, modseq, message_count] FROM ONLY $jean) == [2000, "active", 6, 0]
        AND fn::mail_account_update({ account: <string> $jean, quota_bytes: 10 }).error.code == "MAIL_PERMISSION_DENIED"
        AND fn::mail_account_delete({ account: <string> $jean }).error.code == "MAIL_PERMISSION_DENIED";
};

-- test: écriture directe : un compte ne se crée pas avec des compteurs posés
-- en tant que: admin
-- attendu-erreur: MAIL_WRITE_FORBIDDEN
CREATE mail_account CONTENT { tenant: auth_organization:alpha, identity: auth_identity:membre, message_count: 5 };

-- test: écriture directe : l'identité d'un compte ne se remplace pas
-- en tant que: admin
-- attendu-erreur: MAIL_WRITE_FORBIDDEN
UPDATE type::record((SELECT VALUE jean FROM ONLY passe:ids)) SET identity = auth_identity:membre;

-- test: écriture directe : l'adresse principale ne se retire pas d'un compte vivant
-- en tant que: admin
-- attendu-erreur: MAIL_ADDRESS_IS_PRIMARY
UPDATE type::record((SELECT VALUE jean FROM ONLY passe:ids)) SET primary_address = NONE;

-- test: suppression de marie : état deleting, adresses retirées tout de suite, plus aucun changement
-- en tant que: admin
{
    LET $marie = (SELECT VALUE marie FROM ONLY passe:ids);
    LET $deleted = fn::mail_account_delete({ account: $marie }).data;
    RETURN $deleted.state == "deleting" AND $deleted.primary_address IS NONE AND $deleted.address_count == 0
        AND array::len(SELECT * FROM mail_address WHERE account = type::record($marie)) == 0
        AND fn::mail_domain_get({ domain: (SELECT VALUE domain FROM ONLY passe:ids) }).data.addresses == 1
        AND fn::mail_account_delete({ account: $marie }).error.code == "MAIL_ACCOUNT_DELETING"
        AND fn::mail_account_update({ account: $marie, quota_bytes: 1 }).error.code == "MAIL_ACCOUNT_DELETING"
        AND fn::mail_account_delete({ account: "mail_account:absent" }).error.code == "MAIL_ACCOUNT_NOT_FOUND";
};

-- test: écriture directe : un compte en suppression ne revient pas
-- en tant que: admin
-- attendu-erreur: MAIL_ACCOUNT_DELETING
UPDATE type::record((SELECT VALUE marie FROM ONLY passe:ids)) SET state = "active";

-- test: événement mail.address.deleted à la suppression, aucun mail.account.deleted avant la purge
RETURN (SELECT VALUE payload FROM event_outbox WHERE event_type = "mail.address.deleted").kind == ["account"]
    AND array::len(SELECT * FROM event_outbox WHERE event_type = "mail.account.deleted") == 0;

-- préparation: compte du membre sans droit de courrier, puis suppression de son identité
{
    LET $created = fn::mail_account_create({ identity: "auth_identity:membre", domain: (SELECT VALUE domain FROM ONLY passe:ids), local_part: "membre" });
    UPDATE passe:ids SET membre = <string> $created.data.account.id;
};

-- test: décision M12 : l'identité supprimée, son compte passe à deleting et perd ses adresses
{
    DELETE auth_identity:membre;
    LET $account = (SELECT * FROM ONLY type::record((SELECT VALUE membre FROM ONLY passe:ids)));
    RETURN $account.identity IS NONE AND $account.state == "deleting" AND $account.primary_address IS NONE
        AND array::len(SELECT * FROM mail_address WHERE address = "membre@alpha.test") == 0;
};
