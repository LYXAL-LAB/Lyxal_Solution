-- lyxal-test: assertions
-- Domaines de courrier : reprise d'un domaine vérifié de lyxal_auth (décision M9), forme ASCII
-- seulement (M10), unicité, état, sous-adresses, liste par curseur, suppression d'un domaine vide,
-- retrait du domaine de lyxal_auth refusé tant qu'il sert au courrier, événements sans donnée
-- personnelle, gardes des écritures directes.
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


-- préparation: domaine international vérifié (refusé au lot 4)
CREATE auth_organization_domain:idn CONTENT { organization: auth_organization:alpha, domain: "café.test", state: "verified", challenge_hash: "af1349b9f5f9a1a6a0404dea36dcc9499bcb25c9adc112b7cc9a93cae41f3262" };

-- test: l'administrateur déclare alpha.test ; événement sans nom de domaine
-- en tant que: admin
{
    LET $created = fn::mail_domain_create({ auth_domain: "auth_organization_domain:alpha" });
    CREATE passe:ids SET domain = <string> $created.data.id;
    RETURN $created.ok AND $created.data.{ name, state, subaddress_separator, tenant, address_count } == { name: "alpha.test", state: "active", subaddress_separator: "+", tenant: auth_organization:alpha, address_count: 0 };
};

-- test: événement mail.domain.created, sans nom de domaine
RETURN (SELECT VALUE payload FROM event_outbox WHERE event_type = "mail.domain.created") == [{ domain_id: (SELECT VALUE domain FROM ONLY passe:ids), tenant: "auth_organization:alpha" }];

-- test: un domaine ne se déclare qu'une fois
-- en tant que: admin
RETURN fn::mail_domain_create({ auth_domain: "auth_organization_domain:alpha" }).error.code == "MAIL_DOMAIN_EXISTS";

-- test: domaine non vérifié, domaine d'une autre organisation (invisible), domaine absent, paramètre invalide
-- en tant que: admin
RETURN fn::mail_domain_create({ auth_domain: "auth_organization_domain:attente" }).error.code == "MAIL_DOMAIN_NOT_VERIFIED"
    AND fn::mail_domain_create({ auth_domain: "auth_organization_domain:beta" }).error.code == "MAIL_DOMAIN_NOT_FOUND"
    AND fn::mail_domain_create({ auth_domain: "auth_organization_domain:absent" }).error.code == "MAIL_DOMAIN_NOT_FOUND"
    AND fn::mail_domain_create({ auth_domain: "mail_domain:x" }).error.code == "MAIL_INVALID_PARAMETERS"
    AND fn::mail_domain_create({ auth_domain: "auth_organization_domain:alpha2", subaddress_separator: "-" }).error.code == "MAIL_INVALID_PARAMETERS";

-- test: décision M10 : un domaine international est refusé (aucune conversion IDNA dans lyxal_core)
-- en tant que: admin
RETURN fn::mail_domain_create({ auth_domain: "auth_organization_domain:idn" }).error.{ code, fields: details.fields } == { code: "MAIL_INVALID_PARAMETERS", fields: { auth_domain: ["ascii_domain_required"] } };

-- test: domaine sans sous-adresses
-- en tant que: admin
{
    LET $created = fn::mail_domain_create({ auth_domain: "auth_organization_domain:alpha2", subaddress_separator: "none" });
    UPDATE passe:ids SET domain2 = <string> $created.data.id;
    RETURN $created.ok AND $created.data.subaddress_separator IS NONE;
};

-- test: lecture et liste par curseur (nom unique), organisation de la session par défaut
-- en tant que: admin
{
    LET $first = fn::mail_domain_list({ limit: 1 }).data;
    LET $second = fn::mail_domain_list({ tenant: "auth_organization:alpha", limit: 1, after: $first.next }).data;
    RETURN fn::mail_domain_get({ domain: (SELECT VALUE domain FROM ONLY passe:ids) }).data.addresses == 0
        AND $first.items.name == ["alpha.test"] AND $first.next == "alpha.test"
        AND $second.items.name == ["alpha2.test"] AND $second.next IS NONE
        AND fn::mail_domain_list({ limit: 0 }).error.code == "MAIL_INVALID_PARAMETERS";
};

-- test: désactivé, un domaine ne reçoit plus d'adresse ; réactivé, si ; le séparateur change
-- en tant que: admin
{
    LET $domain = (SELECT VALUE domain FROM ONLY passe:ids);
    LET $off = fn::mail_domain_update({ domain: $domain, state: "disabled" });
    LET $refused = fn::mail_account_create({ identity: "auth_identity:jean", domain: $domain, local_part: "jean" });
    LET $on = fn::mail_domain_update({ domain: $domain, state: "active", subaddress_separator: "none" });
    LET $back = fn::mail_domain_update({ domain: $domain, subaddress_separator: "+" });
    RETURN $off.data.state == "disabled" AND $refused.error.code == "MAIL_DOMAIN_DISABLED"
        AND $on.data.state == "active" AND $on.data.subaddress_separator IS NONE AND $back.data.subaddress_separator == "+"
        AND fn::mail_domain_update({ domain: $domain, state: "deleted" }).error.code == "MAIL_INVALID_PARAMETERS";
};

-- test: un domaine qui porte une adresse ne se supprime pas ; le compteur d'adresses est tenu
-- en tant que: admin
{
    LET $domain = (SELECT VALUE domain FROM ONLY passe:ids);
    LET $account = fn::mail_account_create({ identity: "auth_identity:jean", domain: $domain, local_part: "jean" });
    RETURN $account.ok AND fn::mail_domain_get({ domain: $domain }).data.addresses == 1
        AND fn::mail_domain_delete({ domain: $domain }).error.{ code, details } == { code: "MAIL_DOMAIN_NOT_EMPTY", details: { addresses: 1 } };
};

-- test: la base le refuse aussi en écriture directe
-- en tant que: admin
-- attendu-erreur: MAIL_DOMAIN_NOT_EMPTY
DELETE type::record((SELECT VALUE domain FROM ONLY passe:ids));

-- test: un domaine vide se supprime
-- en tant que: admin
{
    LET $domain = (SELECT VALUE domain2 FROM ONLY passe:ids);
    LET $deleted = fn::mail_domain_delete({ domain: $domain });
    RETURN $deleted.data == { deleted: true } AND !record::exists(type::record($domain))
        AND fn::mail_domain_delete({ domain: $domain }).error.code == "MAIL_DOMAIN_NOT_FOUND";
};

-- test: événement mail.domain.deleted ; le domaine de lyxal_auth reste
RETURN record::exists(auth_organization_domain:alpha2)
    AND (SELECT VALUE payload FROM event_outbox WHERE event_type = "mail.domain.deleted") == [{ domain_id: (SELECT VALUE domain2 FROM ONLY passe:ids), tenant: "auth_organization:alpha" }];

-- test: le retrait du domaine de lyxal_auth est refusé tant qu'un domaine de courrier le référence
-- attendu-erreur: MAIL_DOMAIN_EXISTS
DELETE auth_organization_domain:alpha;

-- test: un membre ne voit ni ne gère les domaines
-- en tant que: jean
RETURN fn::mail_domain_get({ domain: (SELECT VALUE domain FROM ONLY passe:ids) }).error.code == "MAIL_DOMAIN_NOT_FOUND"
    AND fn::mail_domain_list({}).error.code == "MAIL_PERMISSION_DENIED"
    AND fn::mail_domain_create({ auth_domain: "auth_organization_domain:alpha2" }).error.code == "MAIL_DOMAIN_NOT_FOUND"
    AND array::len(SELECT * FROM mail_domain) == 0;

-- test: une autre organisation ne voit pas les domaines d'alpha
-- en tant que: autre
RETURN fn::mail_domain_get({ domain: (SELECT VALUE domain FROM ONLY passe:ids) }).error.code == "MAIL_DOMAIN_NOT_FOUND"
    AND fn::mail_domain_update({ domain: (SELECT VALUE domain FROM ONLY passe:ids), state: "disabled" }).error.code == "MAIL_DOMAIN_NOT_FOUND"
    AND fn::mail_domain_list({ tenant: "auth_organization:alpha" }).error.code == "MAIL_PERMISSION_DENIED"
    AND fn::mail_domain_list({}).data == { items: [], next: NONE };

-- test: le compte de service lit les domaines, ne les gère pas
-- en tant que: worker
RETURN array::len(SELECT * FROM mail_domain) == 1
    AND fn::mail_domain_get({ domain: (SELECT VALUE domain FROM ONLY passe:ids) }).error.code == "MAIL_PERMISSION_DENIED"
    AND fn::mail_domain_list({}).error.code == "MAIL_PERMISSION_DENIED";

-- test: écriture directe : un domaine dont le nom diffère de celui de lyxal_auth est refusé
-- attendu-erreur: MAIL_WRITE_FORBIDDEN
CREATE mail_domain CONTENT { tenant: auth_organization:alpha, auth_domain: auth_organization_domain:alpha2, name: "autre.test" };

-- test: écriture directe : un domaine non vérifié est refusé
-- attendu-erreur: MAIL_DOMAIN_NOT_VERIFIED
CREATE mail_domain CONTENT { tenant: auth_organization:alpha, auth_domain: auth_organization_domain:attente, name: "attente.test" };

-- test: écriture directe : un domaine d'une autre organisation est refusé
-- attendu-erreur: MAIL_WRITE_FORBIDDEN
CREATE mail_domain CONTENT { tenant: auth_organization:alpha, auth_domain: auth_organization_domain:beta, name: "beta.test" };
