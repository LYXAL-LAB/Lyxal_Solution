-- lyxal-test: assertions
-- Adresses et alias : création (sorte account ou alias), limite par compte, cibles d'un alias
-- (comptes vivants de l'organisation), adresse principale protégée, liste par domaine ou par
-- compte, résolution d'un destinataire (casse, sous-adresse, alias, état du domaine, de l'adresse
-- et du compte), événements sans adresse, gardes des écritures directes.
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


-- test: adresse supplémentaire de jean et alias vers jean et marie
-- en tant que: admin
{
    LET $domain = fn::essai_id("domain");
    LET $extra = fn::mail_address_create({ domain: $domain, local_part: "J.Dupont", kind: "account", account: fn::essai_id("jean") });
    LET $alias = fn::mail_address_create({ domain: $domain, local_part: "equipe", kind: "alias", targets: [fn::essai_id("jean"), fn::essai_id("marie")] });
    UPDATE passe:ids SET extra = <string> $extra.data.id, alias = <string> $alias.data.id;
    RETURN $extra.data.{ address, kind, targets } == { address: "j.dupont@alpha.test", kind: "account", targets: [] }
        AND $alias.data.{ address, kind, account } == { address: "equipe@alpha.test", kind: "alias", account: NONE }
        AND fn::mail_account_get({ account: fn::essai_id("jean") }).data.address_count == 2
        AND fn::mail_domain_get({ domain: $domain }).data.addresses == 4;
};

-- test: sorte et paramètres incohérents, adresse prise, domaine absent
-- en tant que: admin
{
    LET $domain = fn::essai_id("domain");
    RETURN fn::mail_address_create({ domain: $domain, local_part: "x", kind: "account" }).error.details.fields == { kind: ["account_or_targets"] }
        AND fn::mail_address_create({ domain: $domain, local_part: "x", kind: "alias", account: fn::essai_id("jean") }).error.code == "MAIL_INVALID_PARAMETERS"
        AND fn::mail_address_create({ domain: $domain, local_part: "x", kind: "alias", targets: [] }).error.code == "MAIL_INVALID_PARAMETERS"
        AND fn::mail_address_create({ domain: $domain, local_part: "x", kind: "alias", targets: [fn::essai_id("jean"), fn::essai_id("jean")] }).error.code == "MAIL_INVALID_PARAMETERS"
        AND fn::mail_address_create({ domain: $domain, local_part: "x", kind: "liste", account: fn::essai_id("jean") }).error.code == "MAIL_INVALID_PARAMETERS"
        AND fn::mail_address_create({ domain: $domain, local_part: "EQUIPE", kind: "account", account: fn::essai_id("jean") }).error.code == "MAIL_ADDRESS_EXISTS"
        AND fn::mail_address_create({ domain: "mail_domain:absent", local_part: "x", kind: "account", account: fn::essai_id("jean") }).error.code == "MAIL_DOMAIN_NOT_FOUND"
        AND fn::mail_address_create({ domain: $domain, local_part: "x", kind: "account", account: "mail_account:absent" }).error.code == "MAIL_ACCOUNT_NOT_FOUND";
};

-- test: un alias ne vise que des comptes de l'organisation
-- en tant que: admin
RETURN fn::mail_address_create({ domain: fn::essai_id("domain"), local_part: "mixte", kind: "alias", targets: [fn::essai_id("jean"), fn::essai_id("autre")] }).error.code == "MAIL_ALIAS_TARGET_INVALID"
    AND fn::mail_address_create({ domain: fn::essai_id("domain"), local_part: "x", kind: "account", account: fn::essai_id("autre") }).error.code == "MAIL_ACCOUNT_NOT_FOUND";

-- test: limite d'adresses par compte (réglage de l'organisation)
-- en tant que: admin
{
    fn::mail_settings_set({ tenant: "auth_organization:alpha", max_addresses_per_account: 2 });
    RETURN fn::mail_address_create({ domain: fn::essai_id("domain"), local_part: "troisieme", kind: "account", account: fn::essai_id("jean") }).error.{ code, details } == { code: "MAIL_ADDRESS_LIMIT", details: { max_addresses_per_account: 2 } };
};

-- test: l'adresse principale ne se retire pas ; une adresse supplémentaire, si
-- en tant que: admin
{
    LET $primary = <string> (SELECT VALUE primary_address FROM ONLY type::record(fn::essai_id("jean")));
    RETURN fn::mail_address_delete({ address: $primary }).error.code == "MAIL_ADDRESS_IS_PRIMARY"
        AND fn::mail_address_delete({ address: fn::essai_id("extra") }).data == { deleted: true }
        AND fn::mail_address_delete({ address: fn::essai_id("extra") }).error.code == "MAIL_ADDRESS_NOT_FOUND"
        AND fn::mail_account_get({ account: fn::essai_id("jean") }).data.address_count == 1;
};

-- test: événements des adresses, sans adresse ni domaine
RETURN (SELECT VALUE payload FROM event_outbox WHERE event_type = "mail.address.deleted") == [{ address_id: fn::essai_id("extra"), kind: "account", tenant: "auth_organization:alpha" }]
    AND (SELECT VALUE payload FROM event_outbox WHERE event_type = "mail.address.created" AND payload.address_id = fn::essai_id("alias")) == [{ address_id: fn::essai_id("alias"), kind: "alias", tenant: "auth_organization:alpha" }];

-- test: modification : état, cibles d'un alias seulement
-- en tant que: admin
{
    LET $primary = <string> (SELECT VALUE primary_address FROM ONLY type::record(fn::essai_id("jean")));
    LET $alias = fn::mail_address_update({ address: fn::essai_id("alias"), targets: [fn::essai_id("marie")] });
    RETURN $alias.data.targets == [type::record(fn::essai_id("marie"))]
        AND fn::mail_address_update({ address: $primary, targets: [fn::essai_id("marie")] }).error.details.fields == { targets: ["alias_only"] }
        AND fn::mail_address_update({ address: fn::essai_id("alias"), targets: [fn::essai_id("autre")] }).error.code == "MAIL_ALIAS_TARGET_INVALID"
        AND fn::mail_address_update({ address: fn::essai_id("alias"), state: "disabled" }).data.state == "disabled"
        AND fn::mail_address_update({ address: fn::essai_id("alias"), state: "active", targets: [fn::essai_id("jean"), fn::essai_id("marie")] }).data.state == "active";
};

-- test: liste par domaine (gestion), par curseur sur l'adresse
-- en tant que: admin
{
    LET $first = fn::mail_address_list({ domain: fn::essai_id("domain"), limit: 2 }).data;
    LET $rest = fn::mail_address_list({ domain: fn::essai_id("domain"), limit: 2, after: $first.next }).data;
    RETURN $first.items.address == ["equipe@alpha.test", "jean@alpha.test"] AND $first.next == "jean@alpha.test"
        AND $rest.items.address == ["marie@alpha.test"] AND $rest.next IS NONE
        AND fn::mail_address_list({}).error.code == "MAIL_INVALID_PARAMETERS"
        AND fn::mail_address_list({ domain: fn::essai_id("domain"), account: fn::essai_id("jean") }).error.code == "MAIL_INVALID_PARAMETERS";
};

-- test: le titulaire liste les adresses de son compte, pas celles d'un autre ni du domaine
-- en tant que: jean
RETURN fn::mail_address_list({ account: fn::essai_id("jean") }).data.items.address == ["jean@alpha.test"]
    AND fn::mail_address_list({ account: fn::essai_id("marie") }).error.code == "MAIL_ACCOUNT_NOT_FOUND"
    AND fn::mail_address_list({ domain: fn::essai_id("domain") }).error.code == "MAIL_DOMAIN_NOT_FOUND"
    AND (SELECT VALUE address FROM mail_address) == ["jean@alpha.test"]
    AND fn::mail_address_create({ domain: fn::essai_id("domain"), local_part: "pirate", kind: "account", account: fn::essai_id("jean") }).error.code == "MAIL_DOMAIN_NOT_FOUND";

-- test: résolution : casse ignorée, sous-adresse retirée, alias développé (comptes triés)
-- en tant que: worker
{
    LET $jean = type::record(fn::essai_id("jean"));
    LET $marie = type::record(fn::essai_id("marie"));
    RETURN fn::mail_address_resolve({ address: " JEAN@Alpha.Test " }).data == { accounts: [$jean], address: "jean@alpha.test" }
        AND fn::mail_address_resolve({ address: "jean+factures@alpha.test" }).data == { accounts: [$jean], address: "jean@alpha.test" }
        AND fn::mail_address_resolve({ address: "equipe@alpha.test" }).data.accounts == array::sort::asc([$jean, $marie])
        AND fn::mail_address_resolve({ address: "equipe+x@alpha.test" }).data.address == "equipe@alpha.test";
};

-- test: résolution : destinataire inconnu, sans écho de l'adresse
-- en tant que: worker
RETURN ["inconnu@alpha.test", "jean@inconnu.test", "pas-une-adresse", "jean+@nulle.test"].all(|$a|
        fn::mail_address_resolve({ address: $a }).error.{ code, details } == { code: "MAIL_RECIPIENT_UNKNOWN", details: {} })
    AND fn::mail_address_resolve({ address: "jéan@alpha.test" }).error.code == "MAIL_INVALID_PARAMETERS"
    AND fn::mail_address_resolve({}).error.code == "MAIL_INVALID_PARAMETERS";

-- préparation: compte de marie désactivé, adresse de jean désactivée, domaine bêta sans sous-adresse
{
    fn::mail_account_update({ account: fn::essai_id("marie"), state: "disabled" });
    fn::mail_domain_update({ domain: fn::essai_id("domain_beta"), subaddress_separator: "none" });
};

-- test: résolution : comptes actifs seulement, domaine sans sous-adresse
-- en tant que: worker
RETURN fn::mail_address_resolve({ address: "equipe@alpha.test" }).data.accounts == [type::record(fn::essai_id("jean"))]
    AND fn::mail_address_resolve({ address: "marie@alpha.test" }).error.code == "MAIL_RECIPIENT_UNKNOWN"
    AND fn::mail_address_resolve({ address: "autre@beta.test" }).data.accounts == [type::record(fn::essai_id("autre"))]
    AND fn::mail_address_resolve({ address: "autre+x@beta.test" }).error.code == "MAIL_RECIPIENT_UNKNOWN";

-- préparation: adresse de jean désactivée, puis domaine alpha désactivé
{
    fn::mail_address_update({ address: <string> (SELECT VALUE primary_address FROM ONLY type::record(fn::essai_id("jean"))), state: "disabled" });
};

-- test: résolution : adresse désactivée, puis domaine désactivé
{
    LET $address = fn::mail_address_resolve({ address: "jean@alpha.test" }).error.code;
    fn::mail_domain_update({ domain: fn::essai_id("domain"), state: "disabled" });
    LET $domain = fn::mail_address_resolve({ address: "equipe@alpha.test" }).error.code;
    fn::mail_domain_update({ domain: fn::essai_id("domain"), state: "active" });
    RETURN $address == "MAIL_RECIPIENT_UNKNOWN" AND $domain == "MAIL_RECIPIENT_UNKNOWN"
        AND fn::mail_address_resolve({ address: "equipe@alpha.test" }).ok;
};

-- test: un membre ne résout pas d'adresse ; l'administrateur non plus
-- en tant que: jean
RETURN fn::mail_address_resolve({ address: "jean@alpha.test" }).error.code == "MAIL_PERMISSION_DENIED";

-- test: une autre organisation ne voit ni ne gère les adresses d'alpha
-- en tant que: autre
RETURN fn::mail_address_update({ address: fn::essai_id("alias"), state: "disabled" }).error.code == "MAIL_ADDRESS_NOT_FOUND"
    AND fn::mail_address_delete({ address: fn::essai_id("alias") }).error.code == "MAIL_ADDRESS_NOT_FOUND"
    AND (SELECT VALUE address FROM mail_address) == ["autre@beta.test"];

-- test: écriture directe : l'adresse calculée doit correspondre à la partie locale et au domaine
-- en tant que: admin
-- attendu-erreur: MAIL_WRITE_FORBIDDEN
CREATE mail_address CONTENT { tenant: auth_organization:alpha, domain: type::record(fn::essai_id("domain")), local_part: "x", address: "y@alpha.test", kind: "account", account: type::record(fn::essai_id("jean")) };

-- test: écriture directe : un alias vers un compte d'une autre organisation est refusé
-- attendu-erreur: MAIL_ALIAS_TARGET_INVALID
CREATE mail_address CONTENT { tenant: auth_organization:alpha, domain: type::record(fn::essai_id("domain")), local_part: "fuite", address: "fuite@alpha.test", kind: "alias", targets: [type::record(fn::essai_id("autre"))] };

-- test: écriture directe : l'adresse principale d'un compte vivant ne se retire pas
-- en tant que: admin
-- attendu-erreur: MAIL_ADDRESS_IS_PRIMARY
DELETE (SELECT VALUE primary_address FROM ONLY type::record(fn::essai_id("jean")));

-- test: le compte supprimé ne reste cible d'aucun alias ; un alias sans cible disparaît
-- en tant que: admin
{
    LET $solo = fn::mail_address_create({ domain: fn::essai_id("domain"), local_part: "solo", kind: "alias", targets: [fn::essai_id("marie")] }).data.id;
    fn::mail_account_delete({ account: fn::essai_id("marie") });
    RETURN fn::mail_address_list({ domain: fn::essai_id("domain") }).data.items.address == ["equipe@alpha.test", "jean@alpha.test"]
        AND (SELECT VALUE targets FROM ONLY type::record(fn::essai_id("alias"))) == [type::record(fn::essai_id("jean"))]
        AND !record::exists($solo);
};
