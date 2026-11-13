-- lyxal-test: assertions
-- Lecture d'une valeur : ticket à usage unique tracé au journal, refus (désactivé, supprimé,
-- expiré, version inactive, consommateur non prévu, secret restreint pour un humain, double
-- facteur), échange du ticket contre l'enveloppe par la session système seulement.
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

-- préparation: secrets d'alpha, un restreint (réservé au robot et au module de notification) et un révélable
{
    LET $r = fn::secrets_secret_create({ tenant: "auth_organization:alpha", path: "smtp", kind: "password", consumers: ["lyxal-test-robot-alpha", "lyxal_notification"] }).data.id;
    fn::secrets_version_add({ secret: <string> $r, number: 1, envelope: "enc:v2:k1:R1", key_id: "k1" });
    fn::secrets_version_add({ secret: <string> $r, number: 2, envelope: "enc:v2:k1:R2", key_id: "k1" });
    LET $v = fn::secrets_secret_create({ tenant: "auth_organization:alpha", path: "console", kind: "password", visibility: "revealable" }).data.id;
    fn::secrets_version_add({ secret: <string> $v, number: 1, envelope: "enc:v2:k1:V1", key_id: "k1" });
    LET $o = fn::secrets_secret_create({ tenant: "auth_organization:alpha", path: "ouvert", kind: "token" }).data.id;
    fn::secrets_version_add({ secret: <string> $o, number: 1, envelope: "enc:v2:k1:O1", key_id: "k1" });
    CREATE passe:ids SET restreint = $r, revelable = $v, ouvert = $o;
};

-- test: un programme prévu lit la version courante : ticket créé et tracé au journal
-- en tant que: robot
{
    LET $s = <string> (SELECT VALUE restreint FROM ONLY passe:ids);
    LET $r = fn::secrets_read_begin({ secret: $s });
    UPSERT passe:ticket SET robot = $r.data.ticket;
    RETURN $r.ok AND $r.data.number = 2 AND $r.data.key_id = "k1" AND $r.data.expires_at <= time::now() + 60s
        AND $r.data.expires_at > time::now() + 50s;
};

-- test: le ticket du robot porte son client_id et une entrée « secret.read » est au journal
{
    LET $t = (SELECT * FROM ONLY (SELECT VALUE robot FROM ONLY passe:ticket));
    LET $j = (SELECT VALUE event FROM secrets_audit WHERE event.action = "secret.read");
    RETURN $t.consumer = "lyxal-test-robot-alpha" AND $t.application = auth_application:robot AND $t.actor IS NONE
        AND array::len($j) = 1 AND $j[0].application = "auth_application:robot" AND $j[0].session_kind = "service"
        AND $j[0].version = 2 AND $j[0].details.consumer = "lyxal-test-robot-alpha";
};

-- test: la session système échange le ticket contre l'enveloppe, une seule fois
{
    LET $t = (SELECT VALUE robot FROM ONLY passe:ticket);
    LET $e = fn::secrets_read_envelope({ ticket: <string> $t });
    LET $again = fn::secrets_read_envelope({ ticket: <string> $t });
    RETURN $e.data.envelope = "enc:v2:k1:R2" AND $e.data.key_id = "k1" AND $e.data.number = 2
        AND $e.data.context.tenant = "alpha" AND $e.data.context.module = "lyxal_secrets"
        AND $e.data.context.resource = "secrets_version" AND $e.data.context.field = "value"
        AND $e.data.context.record_id = <string> record::id((SELECT VALUE restreint FROM ONLY passe:ids)) + ":2"
        AND $again.error.code = "SECRETS_READ_TICKET_INVALID";
};

-- test: un utilisateur ne peut pas échanger un ticket
-- en tant que: robot
{
    LET $s = <string> (SELECT VALUE restreint FROM ONLY passe:ids);
    LET $t = fn::secrets_read_begin({ secret: $s, number: 1 }).data.ticket;
    UPSERT passe:ticket SET robot2 = $t;
    RETURN fn::secrets_read_envelope({ ticket: <string> $t }).error.code = "SECRETS_PERMISSION_DENIED";
};

-- test: ticket expiré refusé
{
    LET $t = (SELECT VALUE robot2 FROM ONLY passe:ticket);
    -- Création antidatée par la session système (la garde refuse un ticket plus long que 60 s)
    LET $old = (CREATE ONLY secrets_read_ticket CONTENT { secret: (SELECT VALUE restreint FROM ONLY passe:ids), version: (SELECT VALUE version FROM ONLY $t), tenant: auth_organization:alpha, number: 1, consumer: "lyxal_notification", created_at: time::now() - 2m, expires_at: time::now() - 1m });
    RETURN fn::secrets_read_envelope({ ticket: <string> $old.id }).error.code = "SECRETS_READ_TICKET_INVALID"
        AND fn::secrets_read_envelope({ ticket: <string> $t }).data.envelope = "enc:v2:k1:R1";
};

-- test: module de l'hôte (session système) : consommateur annoncé dans la liste
{
    LET $s = <string> (SELECT VALUE restreint FROM ONLY passe:ids);
    RETURN fn::secrets_read_begin({ secret: $s, consumer: "lyxal_notification" }).ok
        AND fn::secrets_read_begin({ secret: $s, consumer: "lyxal_storage" }).error.code = "SECRETS_CONSUMER_NOT_ALLOWED"
        AND fn::secrets_read_begin({ secret: $s }).error.code = "SECRETS_CONSUMER_NOT_ALLOWED";
};

-- test: un programme ne s'annonce pas sous un autre nom
-- en tant que: robot
{
    LET $s = <string> (SELECT VALUE restreint FROM ONLY passe:ids);
    RETURN fn::secrets_read_begin({ secret: $s, consumer: "lyxal_notification" }).error.code = "SECRETS_CONSUMER_NOT_ALLOWED";
};

-- test: un humain ne lit pas un secret restreint
-- en tant que: humain
{
    LET $s = <string> (SELECT VALUE ouvert FROM ONLY passe:ids);
    RETURN fn::secrets_read_begin({ secret: $s }).error.code = "SECRETS_REVEAL_FORBIDDEN";
};

-- test: un humain lit un secret révélable avec une authentification récente
-- en tant que: humain
{
    LET $s = <string> (SELECT VALUE revelable FROM ONLY passe:ids);
    RETURN fn::secrets_read_begin({ secret: $s }).ok;
};

-- préparation: l'humain active un second facteur ; sa session reste au premier niveau
{
    UPDATE auth_identity:humain SET available_aal = 2;
};

-- test: second facteur disponible mais non utilisé dans la session : lecture refusée
-- en tant que: humain
{
    LET $s = <string> (SELECT VALUE revelable FROM ONLY passe:ids);
    RETURN fn::secrets_read_begin({ secret: $s }).error.code = "AUTH_AAL_INSUFFICIENT";
};

-- préparation: session au second facteur, authentifiée il y a une heure
{
    UPDATE auth_session:humain SET aal = 2, authenticated_at = time::now() - 1h;
};

-- test: authentification trop ancienne : réauthentification demandée
-- en tant que: humain
{
    LET $s = <string> (SELECT VALUE revelable FROM ONLY passe:ids);
    RETURN fn::secrets_read_begin({ secret: $s }).error.code = "AUTH_REAUTHENTICATION_REQUIRED";
};

-- préparation: réauthentification récente
{
    UPDATE auth_session:humain SET authenticated_at = time::now();
};

-- test: second facteur récent : lecture permise
-- en tant que: humain
{
    LET $s = <string> (SELECT VALUE revelable FROM ONLY passe:ids);
    RETURN fn::secrets_read_begin({ secret: $s, label: "current" }).ok;
};

-- test: sans la permission de lire une valeur, rien n'est lu
-- en tant que: lecteur
{
    LET $s = <string> (SELECT VALUE ouvert FROM ONLY passe:ids);
    RETURN fn::secrets_read_begin({ secret: $s }).error.code = "SECRETS_PERMISSION_DENIED";
};

-- test: secret d'une autre organisation invisible
-- en tant que: autre
{
    LET $s = <string> (SELECT VALUE ouvert FROM ONLY passe:ids);
    RETURN fn::secrets_read_begin({ secret: $s }).error.code = "SECRETS_SECRET_NOT_FOUND";
};

-- test: version inconnue ou désactivée refusée ; secret désactivé, expiré ou supprimé refusé
{
    LET $o = <string> (SELECT VALUE ouvert FROM ONLY passe:ids);
    LET $absente = fn::secrets_read_begin({ secret: $o, number: 5 });
    LET $etiquette = fn::secrets_read_begin({ secret: $o, label: "pending" });
    fn::secrets_version_disable({ secret: $o, number: 1 });
    LET $version = fn::secrets_read_begin({ secret: $o });
    fn::secrets_version_enable({ secret: $o, number: 1 });
    fn::secrets_secret_disable({ secret: $o });
    LET $desactive = fn::secrets_read_begin({ secret: $o });
    fn::secrets_secret_enable({ secret: $o });
    UPDATE type::record($o) SET expires_at = time::now() - 1s;
    LET $expire = fn::secrets_read_begin({ secret: $o });
    fn::secrets_secret_update({ secret: $o, clear: ["expires_at"] });
    fn::secrets_secret_delete({ secret: $o });
    LET $supprime = fn::secrets_read_begin({ secret: $o });
    fn::secrets_secret_restore({ secret: $o });
    RETURN $absente.error.code = "SECRETS_VERSION_NOT_FOUND" AND $etiquette.error.code = "SECRETS_VERSION_NOT_FOUND"
        AND $version.error.code = "SECRETS_VERSION_STATE_INVALID" AND $desactive.error.code = "SECRETS_SECRET_DISABLED"
        AND $expire.error.code = "SECRETS_SECRET_EXPIRED" AND $supprime.error.code = "SECRETS_SECRET_DELETED"
        AND fn::secrets_read_begin({ secret: $o }).ok;
};

-- test: un ticket ouvert puis secret désactivé : l'échange est refusé
{
    LET $o = <string> (SELECT VALUE ouvert FROM ONLY passe:ids);
    LET $t = fn::secrets_read_begin({ secret: $o }).data.ticket;
    fn::secrets_secret_disable({ secret: $o });
    LET $e = fn::secrets_read_envelope({ ticket: <string> $t });
    fn::secrets_secret_enable({ secret: $o });
    RETURN $e.error.code = "SECRETS_READ_TICKET_INVALID";
};

-- test: écriture directe : ticket au nom d'un autre refusé
-- en tant que: robot
-- attendu-erreur: SECRETS_READ_TICKET_INVALID
CREATE secrets_read_ticket CONTENT { secret: (SELECT VALUE restreint FROM ONLY passe:ids), version: (SELECT VALUE id FROM ONLY secrets_version WHERE secret = (SELECT VALUE restreint FROM ONLY passe:ids) AND number = 2 LIMIT 1), tenant: auth_organization:alpha, number: 2, actor: auth_identity:admin, consumer: "lyxal-test-robot-alpha" };

-- test: écriture directe : ticket plus long que 60 secondes refusé
-- en tant que: robot
-- attendu-erreur: SECRETS_READ_TICKET_INVALID
CREATE secrets_read_ticket CONTENT { secret: (SELECT VALUE restreint FROM ONLY passe:ids), version: (SELECT VALUE id FROM ONLY secrets_version WHERE secret = (SELECT VALUE restreint FROM ONLY passe:ids) AND number = 2 LIMIT 1), tenant: auth_organization:alpha, number: 2, application: auth_application:robot, expires_at: time::now() + 1d };

-- test: écriture directe : ticket d'un humain sur un secret restreint refusé par la garde
-- en tant que: humain
-- attendu-erreur: SECRETS_REVEAL_FORBIDDEN
CREATE secrets_read_ticket CONTENT { secret: (SELECT VALUE ouvert FROM ONLY passe:ids), version: (SELECT VALUE id FROM ONLY secrets_version WHERE secret = (SELECT VALUE ouvert FROM ONLY passe:ids) AND number = 1 LIMIT 1), tenant: auth_organization:alpha, number: 1, actor: auth_identity:humain };

-- test: un ticket ne se modifie que pour être consommé
-- attendu-erreur: SECRETS_READ_TICKET_INVALID
UPDATE (SELECT VALUE robot FROM ONLY passe:ticket) SET used_at = NONE;
