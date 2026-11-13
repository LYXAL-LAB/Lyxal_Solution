-- lyxal-test: assertions
-- Journal : une entrée chaînée par opération, auteur et type de session, aucune valeur ;
-- vérification de la chaîne ; modification ou suppression par une session système détectée ;
-- aucune écriture possible pour un utilisateur ; isolation des organisations ; bus d'événements.
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

-- préparation: opérations d'alpha (réglages, fiche, versions, étiquette, lecture, suppression, restauration)
{
    fn::secrets_settings_set({ tenant: "auth_organization:alpha", max_versions: 5 });
    LET $s = fn::secrets_secret_create({ tenant: "auth_organization:alpha", path: "smtp", kind: "password", consumers: ["lyxal_notification"] }).data.id;
    fn::secrets_version_add({ secret: <string> $s, number: 1, envelope: "enc:v2:k1:SECRETVALEUR1", key_id: "k1" });
    fn::secrets_version_add({ secret: <string> $s, number: 2, envelope: "enc:v2:k1:SECRETVALEUR2", key_id: "k1" });
    fn::secrets_version_label({ secret: <string> $s, label: "current", number: 1 });
    fn::secrets_secret_update({ secret: <string> $s, description: "Relais" });
    fn::secrets_read_begin({ secret: <string> $s, consumer: "lyxal_notification" });
    fn::secrets_secret_delete({ secret: <string> $s });
    fn::secrets_secret_restore({ secret: <string> $s });
    CREATE passe:s SET id_secret = $s;
};

-- test: une entrée par opération, dans l'ordre, rangs contigus
{
    LET $e = (SELECT VALUE event FROM secrets_audit WHERE scope_key = "alpha" ORDER BY seq ASC);
    RETURN $e.action = ["settings.update", "secret.create", "version.create", "version.create", "version.label", "secret.update", "secret.read", "secret.delete", "secret.restore"]
        AND $e.seq = [1, 2, 3, 4, 5, 6, 7, 8, 9]
        AND $e[5].details.fields = ["description"] AND $e[4].details.after.current = 1
        AND (SELECT VALUE seq FROM ONLY secrets_audit_head:alpha) = 9;
};

-- test: aucune valeur au journal ni sur le bus
{
    LET $journal = <string> (SELECT * FROM secrets_audit);
    LET $bus = <string> (SELECT * FROM event_outbox WHERE producer = "lyxal_secrets");
    RETURN !string::contains($journal, "SECRETVALEUR") AND !string::contains($bus, "SECRETVALEUR") AND !string::contains($bus, "enc:v2");
};

-- test: événements publiés sur le bus
RETURN (SELECT VALUE event_type FROM event_outbox WHERE producer = "lyxal_secrets" ORDER BY created_at ASC) = [
    "secrets.secret.created", "secrets.version.created", "secrets.version.created", "secrets.version.labeled",
    "secrets.secret.updated", "secrets.secret.deleted", "secrets.secret.restored"
];

-- test: lecture du journal par l'administrateur : plus récent d'abord, filtres
-- en tant que: admin
{
    LET $s = <string> (SELECT VALUE id_secret FROM ONLY passe:s);
    LET $all = fn::secrets_audit_list({ tenant: "auth_organization:alpha" }).data;
    LET $reads = fn::secrets_audit_list({ tenant: "auth_organization:alpha", action: "secret.read" }).data;
    LET $of = fn::secrets_audit_list({ tenant: "auth_organization:alpha", secret: $s, limit: 2 }).data;
    RETURN $all.total = 9 AND $all.items[0].seq = 9 AND $reads.total = 1 AND $reads.items[0].event.session_kind = "system"
        AND $of.total = 8 AND array::len($of.items) = 2
        AND $all.items[1].event.actor = NULL AND $all.items[1].event.session_kind = "system";
};

-- test: la chaîne est intacte
-- en tant que: admin
{
    LET $v = fn::secrets_audit_verify({ tenant: "auth_organization:alpha" }).data;
    LET $part = fn::secrets_audit_verify({ tenant: "auth_organization:alpha", from_seq: 5 }).data;
    RETURN $v.valid AND $v.checked = 9 AND $v.head_matches AND $v.broken_at IS NONE AND $part.valid AND $part.checked = 6;
};

-- test: un utilisateur n'écrit ni ne modifie ni ne supprime le journal
-- en tant que: admin
{
    CREATE secrets_audit CONTENT { tenant: auth_organization:alpha, scope_key: "alpha", seq: 99, event: {}, entry_hash: "x" };
    UPDATE secrets_audit SET event.action = "falsifie" WHERE seq = 3;
    DELETE secrets_audit WHERE seq = 4;
    RETURN fn::secrets_audit_verify({ tenant: "auth_organization:alpha" }).data.valid
        AND fn::secrets_audit_list({ tenant: "auth_organization:alpha" }).data.total = 9;
};

-- test: journal d'une autre organisation : invisible et séparé
-- en tant que: autre
{
    fn::secrets_secret_create({ tenant: "auth_organization:beta", path: "smtp", kind: "password" });
    LET $mine = fn::secrets_audit_list({ tenant: "auth_organization:beta" }).data;
    RETURN $mine.total = 1 AND $mine.items[0].seq = 1
        AND fn::secrets_audit_list({ tenant: "auth_organization:alpha" }).error.code = "SECRETS_PERMISSION_DENIED"
        AND array::len(SELECT * FROM secrets_audit WHERE scope_key = "alpha") = 0;
};

-- test: sans la permission, pas de journal
-- en tant que: redacteur
RETURN fn::secrets_audit_list({ tenant: "auth_organization:alpha" }).error.code = "SECRETS_PERMISSION_DENIED"
    AND fn::secrets_audit_verify({ tenant: "auth_organization:alpha" }).error.code = "SECRETS_PERMISSION_DENIED";

-- test: entrée réécrite par une session système (le champ est figé : suppression puis recréation) : détectée
{
    LET $row = (SELECT * FROM ONLY secrets_audit WHERE scope_key = "alpha" AND seq = 3 LIMIT 1);
    UPSERT passe:original SET row = $row;
    DELETE $row.id;
    CREATE secrets_audit CONTENT object::extend(object::remove($row, "id"), { event: object::extend($row.event, { action: "falsifie" }) });
    LET $v = fn::secrets_audit_verify({ tenant: "auth_organization:alpha" }).data;
    RETURN !$v.valid AND $v.broken_at = 3;
};

-- test: suppression d'une entrée au milieu : détectée
{
    LET $row = (SELECT VALUE row FROM ONLY passe:original);
    DELETE secrets_audit WHERE scope_key = "alpha" AND seq = 3;
    CREATE secrets_audit CONTENT object::remove($row, "id");
    LET $ok = fn::secrets_audit_verify({ tenant: "auth_organization:alpha" }).data.valid;
    DELETE secrets_audit WHERE scope_key = "alpha" AND seq = 5;
    LET $v = fn::secrets_audit_verify({ tenant: "auth_organization:alpha" }).data;
    RETURN $ok AND !$v.valid AND $v.broken_at = 6;
};

-- test: suppression des dernières entrées : détectée par la tête de chaîne
{
    LET $before = (SELECT * FROM secrets_audit WHERE scope_key = "alpha" AND seq = 5);
    DELETE secrets_audit WHERE scope_key = "alpha" AND seq >= 8;
    LET $v = fn::secrets_audit_verify({ tenant: "auth_organization:alpha", from_seq: 6 }).data;
    RETURN !$v.valid AND !$v.head_matches;
};

-- test: l'auteur et l'adresse viennent de la session, pas des paramètres
-- en tant que: redacteur
{
    fn::secrets_secret_create({ tenant: "auth_organization:alpha", path: "auteur", kind: "token" });
    RETURN true;
};

-- test: entrée du rédacteur
{
    LET $e = (SELECT VALUE event FROM ONLY secrets_audit WHERE scope_key = "alpha" AND event.path = "auteur" LIMIT 1);
    RETURN $e.actor = "auth_identity:redacteur" AND $e.session = "auth_session:redacteur" AND $e.session_kind = "interactive"
        AND $e.action = "secret.create";
};
