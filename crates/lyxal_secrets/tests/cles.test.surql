-- lyxal-test: assertions
-- Clés des organisations : aucun accès utilisateur, une seule clé active, création concurrente,
-- rotation, rescellement par une nouvelle clé maîtresse, destruction, liste de rescellement,
-- journal ; lectures refusées journalisées au nom de l'appelant.
--
-- identité admin: { "id": "auth_session:admin", "pv": 1, "permissions": ["secrets.secret.list", "secrets.secret.write", "secrets.secret.delete", "secrets.secret.restore", "secrets.secret.purge", "secrets.audit.read", "secrets.settings.manage", "secrets.value.read"] }
-- identité redacteur: { "id": "auth_session:redacteur", "pv": 1, "permissions": ["secrets.secret.list", "secrets.secret.write"] }
-- identité lecteur: { "id": "auth_session:lecteur", "pv": 1, "permissions": ["secrets.secret.list"] }
-- identité humain: { "id": "auth_session:humain", "pv": 1, "permissions": ["secrets.secret.list", "secrets.value.read"] }
-- identité autre: { "id": "auth_session:autre", "pv": 1, "permissions": ["secrets.secret.list", "secrets.secret.write", "secrets.secret.delete", "secrets.secret.restore", "secrets.secret.purge", "secrets.audit.read", "secrets.settings.manage", "secrets.value.read"] }
-- identité membre: { "id": "auth_session:membre", "pv": 1, "permissions": [] }
-- identité plateforme: { "id": "auth_session:plateforme", "pv": 1, "permissions": ["secrets.installation.manage"] }
-- identité robot: { "id": "auth_session:robot", "pv": 1, "permissions": ["secrets.value.read"] }
-- identité worker: { "id": "auth_session:worker", "pv": 1, "permissions": ["secrets.worker"] }

-- préparation: organisations, identités et sessions lyxal_auth
{
    CREATE auth_organization:alpha CONTENT { slug: "alpha", name: "Alpha BTP" };
    CREATE auth_organization:beta CONTENT { slug: "beta", name: "Beta Bois" };
    FOR $n IN ["admin", "redacteur", "lecteur", "humain", "membre"] {
        CREATE type::record("auth_identity", $n) CONTENT { schema: auth_identity_schema:default_v1, traits: { email: $n + "@lyxal.test" } };
        RELATE (type::record("auth_identity", $n))->auth_member_of->auth_organization:alpha;
        CREATE type::record("auth_session", $n) CONTENT { identity: type::record("auth_identity", $n), organization: auth_organization:alpha, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    };
    CREATE auth_identity:autre CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "autre@lyxal.test" } };
    RELATE auth_identity:autre->auth_member_of->auth_organization:beta;
    CREATE auth_session:autre CONTENT { identity: auth_identity:autre, organization: auth_organization:beta, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    FOR $n IN ["plateforme", "worker"] {
        CREATE type::record("auth_identity", $n) CONTENT { schema: auth_identity_schema:default_v1, traits: { email: $n + "@lyxal.test" } };
        CREATE type::record("auth_session", $n) CONTENT { identity: type::record("auth_identity", $n), idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    };
    -- Compte de service d'alpha : session sans identité
    CREATE auth_application:robot CONTENT { tenant: auth_organization:alpha, client_id: "lyxal-test-robot-alpha", name: "Robot", type: "machine", redirect_uris: [], state: "active", permissions_version: 1 };
    CREATE auth_session:robot CONTENT { application: auth_application:robot, kind: "service", organization: auth_organization:alpha, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    -- Table de passage d'identifiants entre identités (lisible par tous)
    DEFINE TABLE OVERWRITE passe SCHEMALESS PERMISSIONS FULL;
};

-- test: première clé de l'organisation, rangée scellée
{
    LET $r = fn::secrets_tenant_key_create({ tenant: "auth_organization:alpha", key_id: "alpha-1", wrapped: "enc:v2:m1:K1" });
    LET $ring = fn::secrets_tenant_key_ring({ tenant: "auth_organization:alpha" }).data.items;
    RETURN $r.ok AND $r.data.state = "active" AND $r.data.retired IS NONE
        AND $ring = [{ key_id: "alpha-1", wrapped: "enc:v2:m1:K1", state: "active" }]
        AND fn::secrets_keys_trusted();
};

-- test: seconde première clé refusée (une seule clé active)
RETURN fn::secrets_tenant_key_create({ tenant: "auth_organization:alpha", key_id: "alpha-x", wrapped: "enc:v2:m1:KX" }).error.code = "SECRETS_TENANT_KEY_CONFLICT"
    AND fn::secrets_tenant_key_create({ tenant: "auth_organization:alpha", key_id: "alpha-x", wrapped: "enc:v2:m1:KX", replaces: "inconnue" }).error.code = "SECRETS_TENANT_KEY_CONFLICT";

-- test: aucun accès utilisateur, même administrateur
-- en tant que: admin
RETURN array::len(SELECT * FROM secrets_tenant_key) = 0
    AND fn::secrets_tenant_key_ring({ tenant: "auth_organization:alpha" }).error.code = "SECRETS_PERMISSION_DENIED"
    AND fn::secrets_tenant_key_create({ tenant: "auth_organization:alpha", key_id: "pirate", wrapped: "enc:v2:m1:P" }).error.code = "SECRETS_PERMISSION_DENIED"
    AND fn::secrets_rewrap_list({ master_key_id: "m1" }).error.code = "SECRETS_PERMISSION_DENIED"
    AND !fn::secrets_keys_trusted();

-- test: écriture directe dans la table refusée à un utilisateur (rien n'est écrit)
-- en tant que: admin
{
    CREATE secrets_tenant_key CONTENT { tenant: auth_organization:alpha, key_id: "pirate", wrapped: "enc:v2:m1:P" };
    RETURN true;
};

-- test: rien n'a été écrit
RETURN array::len(SELECT * FROM secrets_tenant_key WHERE key_id = "pirate") = 0;

-- test: droit de demander une rotation : administrateur oui, rédacteur non
-- en tant que: admin
RETURN fn::secrets_tenant_key_rotate_allowed({ tenant: "auth_organization:alpha" }).data = { allowed: true, requested_by: auth_identity:admin };

-- test: rédacteur sans droit de réglage
-- en tant que: redacteur
RETURN fn::secrets_tenant_key_rotate_allowed({ tenant: "auth_organization:alpha" }).error.code = "SECRETS_PERMISSION_DENIED";

-- préparation: un secret d'alpha scellé par la première clé
{
    LET $s = fn::secrets_secret_create({ tenant: "auth_organization:alpha", path: "api", kind: "api_key" }).data.id;
    fn::secrets_version_add({ secret: <string> $s, number: 1, envelope: "enc:v2:alpha-1:V1", key_id: "alpha-1" });
    CREATE passe:s SET id_secret = $s;
};

-- test: rotation : nouvelle clé active, l'ancienne relit seulement
{
    LET $r = fn::secrets_tenant_key_create({ tenant: "auth_organization:alpha", key_id: "alpha-2", wrapped: "enc:v2:m1:K2", replaces: "alpha-1", requested_by: "auth_identity:admin" });
    LET $ring = fn::secrets_tenant_key_ring({ tenant: "auth_organization:alpha" }).data.items;
    RETURN $r.data.retired = "alpha-1" AND $ring.key_id = ["alpha-1", "alpha-2"] AND $ring.state = ["decrypt_only", "active"]
        AND (SELECT VALUE requested_by FROM ONLY secrets_tenant_key WHERE key_id = "alpha-2" LIMIT 1) = "auth_identity:admin";
};

-- test: liste de rescellement : version de l'ancienne clé, clés d'une autre clé maîtresse
{
    LET $l = fn::secrets_rewrap_list({ master_key_id: "m2" }).data;
    RETURN $l.versions.key_id = ["alpha-1"] AND $l.versions[0].envelope = "enc:v2:alpha-1:V1"
        AND array::sort($l.keys.key_id) = ["alpha-1", "alpha-2"] AND $l.unused = []
        AND fn::secrets_rewrap_list({ master_key_id: "m1" }).data.keys = [];
};

-- test: destruction refusée tant qu'une version utilise l'ancienne clé ; clé active non destructible
RETURN fn::secrets_tenant_key_destroy({ key_id: "alpha-1" }).error.code = "SECRETS_TENANT_KEY_CONFLICT"
    AND fn::secrets_tenant_key_destroy({ key_id: "alpha-2" }).error.code = "SECRETS_TENANT_KEY_UNAVAILABLE";

-- test: après rescellement de la version, l'ancienne clé est inutilisée puis détruite
{
    LET $s = <string> (SELECT VALUE id_secret FROM ONLY passe:s);
    fn::secrets_version_reseal({ secret: $s, number: 1, expected_key_id: "alpha-1", envelope: "enc:v2:alpha-2:V1B", key_id: "alpha-2" });
    LET $l = fn::secrets_rewrap_list({ master_key_id: "m1" }).data;
    LET $d = fn::secrets_tenant_key_destroy({ key_id: "alpha-1" });
    LET $k = (SELECT state, wrapped, destroyed_at FROM ONLY secrets_tenant_key WHERE key_id = "alpha-1" LIMIT 1);
    RETURN $l.versions = [] AND $l.unused = ["alpha-1"] AND $d.data.destroyed AND $k.state = "destroyed" AND $k.wrapped IS NONE
        AND fn::secrets_tenant_key_ring({ tenant: "auth_organization:alpha" }).data.items.key_id = ["alpha-2"];
};

-- test: rescellement par une nouvelle clé maîtresse ; écriture conditionnelle
{
    LET $ok = fn::secrets_tenant_key_rewrap({ key_id: "alpha-2", expected_master_key_id: "m1", wrapped: "enc:v2:m2:K2B" });
    LET $again = fn::secrets_tenant_key_rewrap({ key_id: "alpha-2", expected_master_key_id: "m1", wrapped: "enc:v2:m3:K2C" });
    RETURN $ok.data.master_key_id = "m2" AND $again.error.code = "SECRETS_TENANT_KEY_CONFLICT"
        AND fn::secrets_tenant_key_rewrap({ key_id: "alpha-1", expected_master_key_id: "m1", wrapped: "enc:v2:m2:X" }).error.code = "SECRETS_TENANT_KEY_UNAVAILABLE"
        AND fn::secrets_rewrap_list({ master_key_id: "m2" }).data.keys = [];
};

-- test: journal des clés : création, retrait, destruction, rescellement ; aucune matière de clé
{
    LET $e = (SELECT VALUE event FROM secrets_audit WHERE scope_key = "alpha" AND string::starts_with(event.action, "key.") ORDER BY seq ASC);
    RETURN $e.action = ["key.create", "key.retire", "key.create", "key.destroy", "key.rewrap"]
        AND $e[2].details.requested_by = "auth_identity:admin" AND $e[4].details.master_key_id_before = "m1"
        AND !string::contains(<string> $e, "K2B") AND !string::contains(<string> $e, "enc:v2");
};

-- test: transition interdite par la garde : une clé détruite ne revient pas
-- attendu-erreur: SECRETS_TENANT_KEY_UNAVAILABLE
UPDATE secrets_tenant_key SET state = "decrypt_only", wrapped = "enc:v2:m2:R" WHERE key_id = "alpha-1";

-- test: lecture refusée journalisée au nom de l'appelant, session système seulement
{
    LET $s = <string> (SELECT VALUE id_secret FROM ONLY passe:s);
    LET $r = fn::secrets_audit_denied({ secret: $s, code: "SECRETS_REVEAL_FORBIDDEN", actor: "auth_identity:humain", session: "auth_session:humain", session_kind: "interactive", version: 1 });
    LET $e = (SELECT VALUE event FROM ONLY secrets_audit WHERE scope_key = "alpha" AND seq = $r.data.seq LIMIT 1);
    RETURN $e.action = "secret.read" AND $e.outcome = "denied" AND $e.actor = "auth_identity:humain"
        AND $e.session_kind = "interactive" AND $e.details.code = "SECRETS_REVEAL_FORBIDDEN"
        AND fn::secrets_audit_verify({ tenant: "auth_organization:alpha" }).data.valid;
};

-- test: un utilisateur ne journalise pas un refus au nom d'un autre
-- en tant que: admin
RETURN fn::secrets_audit_denied({ secret: <string> (SELECT VALUE id_secret FROM ONLY passe:s), code: "X", actor: "auth_identity:lecteur", session_kind: "interactive" }).error.code = "SECRETS_PERMISSION_DENIED";

-- test: organisation supprimée : ses clés partent avec elle
{
    fn::secrets_tenant_key_create({ tenant: "auth_organization:beta", key_id: "beta-1", wrapped: "enc:v2:m2:B1" });
    DELETE auth_organization:beta;
    RETURN array::len(SELECT * FROM secrets_tenant_key WHERE key_id = "beta-1") = 0;
};
