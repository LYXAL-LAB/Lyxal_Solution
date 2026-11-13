-- lyxal-test: assertions
-- Fonctions internes appelées directement : gardes (refus attendus), vues sans enveloppe,
-- réglages effectifs, nettoyage des entrées du journal, écriture d'une entrée, publication.
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

-- préparation: un secret d'alpha avec une version
{
    fn::secrets_tenant_key_create({ tenant: "auth_organization:alpha", key_id: "k1", wrapped: "enc:v2:m1:K1" });
    LET $s = fn::secrets_secret_create({ tenant: "auth_organization:alpha", path: "interne", kind: "token" }).data.id;
    fn::secrets_version_add({ secret: <string> $s, number: 1, envelope: "enc:v2:k1:I1", key_id: "k1" });
    CREATE passe:s SET id_secret = $s;
};

-- test: vues : fiche avec versions, version sans enveloppe
{
    LET $s = (SELECT VALUE id_secret FROM ONLY passe:s);
    LET $f = fn::secrets_secret_view($s);
    LET $v = fn::secrets_version_view($s, 1);
    RETURN $f.versions[0].number = 1 AND $f.versions[0].envelope IS NONE AND $v.number = 1 AND $v.envelope IS NONE
        AND $v.key_id = "k1" AND fn::secrets_version_view($s, 9) IS NONE AND fn::secrets_secret_view(secrets_secret:inconnu) IS NONE;
};

-- test: réglages effectifs par défaut
RETURN fn::secrets_settings_effective({ tenant: auth_organization:alpha }).max_versions = 10
    AND fn::secrets_key_is_active("alpha", "k1") AND !fn::secrets_key_is_active("alpha", "k9") AND !fn::secrets_key_is_active("beta", "k1")
    AND fn::secrets_settings_effective({}).deleted_retention_days = 30;

-- test: nettoyage : NONE devient NULL, y compris en profondeur
RETURN fn::secrets_audit_clean({ a: NONE, b: { c: NONE, d: 1 }, e: [NONE, 2] }) = { a: NULL, b: { c: NULL, d: 1 }, e: [NULL, 2] }
    AND fn::secrets_audit_clean(NONE) = NULL AND fn::secrets_audit_clean("x") = "x";

-- test: gardes de création : état initial imposé
{
    LET $s = (SELECT * FROM ONLY (SELECT VALUE id_secret FROM ONLY passe:s));
    RETURN fn::secrets_secret_create_refusal(object::extend($s, { latest_version: 0, labels: {} })) IS NONE
        AND fn::secrets_secret_create_refusal(object::extend($s, { latest_version: 0, labels: {}, state: "disabled" })) = "SECRETS_SECRET_STATE_INVALID"
        AND fn::secrets_version_create_refusal({ secret: $s.id, tenant: $s.tenant, scope_key: "alpha", number: 2, state: "enabled", envelope: "enc:v2:k1:X", key_id: "k1" }) IS NONE
        AND fn::secrets_version_create_refusal({ secret: $s.id, tenant: $s.tenant, scope_key: "alpha", number: 5, state: "enabled", envelope: "enc:v2:k1:X", key_id: "k1" }) = "SECRETS_VERSION_CONFLICT"
        AND fn::secrets_version_create_refusal({ secret: $s.id, tenant: NONE, scope_key: "alpha", number: 2, state: "enabled", envelope: "enc:v2:k1:X", key_id: "k1" }) = "SECRETS_VERSION_STATE_INVALID";
};

-- test: gardes de modification : transitions
{
    LET $s = (SELECT * FROM ONLY (SELECT VALUE id_secret FROM ONLY passe:s));
    LET $v = (SELECT * FROM ONLY secrets_version WHERE secret = $s.id AND number = 1 LIMIT 1);
    RETURN fn::secrets_secret_update_refusal($s, object::extend($s, { state: "disabled" })) IS NONE
        AND fn::secrets_secret_update_refusal($s, object::extend($s, { state: "deleted" })) = "SECRETS_SECRET_STATE_INVALID"
        AND fn::secrets_secret_update_refusal($s, object::extend($s, { labels: { current: 7 } })) = "SECRETS_LABEL_INVALID"
        AND fn::secrets_version_update_refusal($v, object::extend($v, { state: "disabled" })) IS NONE
        AND fn::secrets_version_update_refusal($v, object::extend($v, { state: "destroyed", envelope: NONE, key_id: NONE, destroyed_at: time::now() })) = "SECRETS_VERSION_LABELED"
        AND fn::secrets_version_update_refusal($v, object::extend($v, { keys: ["x"] })) = "SECRETS_PERMISSION_DENIED"
        AND fn::secrets_secret_delete_refusal($s) = "SECRETS_SECRET_STATE_INVALID";
};

-- test: changements d'état internes
{
    LET $s = <string> (SELECT VALUE id_secret FROM ONLY passe:s);
    RETURN fn::secrets_secret_transition({ secret: $s }, "disable").data.state = "disabled"
        AND fn::secrets_secret_transition({ secret: $s }, "enable").data.state = "active"
        AND fn::secrets_version_state({ secret: $s, number: 1 }, "disabled").data.state = "disabled"
        AND fn::secrets_version_state({ secret: $s, number: 1 }, "enabled").data.state = "enabled";
};

-- test: garde de lecture : la session système doit s'annoncer si la liste est fixée
{
    LET $s = (SELECT * FROM ONLY (SELECT VALUE id_secret FROM ONLY passe:s));
    LET $v = (SELECT VALUE id FROM ONLY secrets_version WHERE secret = $s.id AND number = 1 LIMIT 1);
    LET $libre = fn::secrets_read_refusal({ secret: $s.id, version: $v, number: 1 });
    fn::secrets_secret_update({ secret: <string> $s.id, consumers: ["lyxal_connect"] });
    LET $liste = fn::secrets_read_refusal({ secret: $s.id, version: $v, number: 1, consumer: "lyxal_storage" });
    LET $faux = fn::secrets_read_refusal({ secret: $s.id, version: $v, number: 2 });
    RETURN $libre IS NONE AND $liste.code = "SECRETS_CONSUMER_NOT_ALLOWED" AND $faux.code = "SECRETS_VERSION_NOT_FOUND";
};

-- test: écriture d'une entrée de journal et publication sur le bus
{
    LET $s = (SELECT * FROM ONLY (SELECT VALUE id_secret FROM ONLY passe:s));
    LET $before = (SELECT VALUE seq FROM ONLY secrets_audit_head:alpha);
    LET $e = fn::secrets_audit_write({ tenant: auth_organization:alpha, action: "test.write", secret: $s.id, path: $s.path, details: { note: NONE } });
    LET $published = fn::secrets_publish("secrets.test.done", $s, { number: 1 });
    RETURN $e.seq = $before + 1 AND $e.details = { note: NULL } AND $e.session_kind = "system" AND $published
        AND (SELECT VALUE seq FROM ONLY secrets_audit_head:alpha) = $before + 1
        AND array::len(SELECT * FROM event_outbox WHERE event_type = "secrets.test.done") = 1
        AND fn::secrets_audit_verify({ tenant: "auth_organization:alpha" }).data.valid;
};
