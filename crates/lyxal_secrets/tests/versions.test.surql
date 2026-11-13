-- lyxal-test: assertions
-- Versions : ajout, conflit de numéro, étiquettes (current, previous, pending, libres, retour
-- arrière), conservation, désactivation, destruction, rescellement ; enveloppe jamais lisible par
-- un utilisateur.
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

-- préparation: secret d'alpha
{
    LET $s = fn::secrets_secret_create({ tenant: "auth_organization:alpha", path: "api/brevo", kind: "api_key", rotation_period: 90d }).data.id;
    CREATE passe:s SET id_secret = $s;
};

-- test: première version : current posée, prochaine rotation calculée
-- en tant que: redacteur
{
    LET $s = <string> (SELECT VALUE id_secret FROM ONLY passe:s);
    LET $r = fn::secrets_version_add({ secret: $s, number: 1, envelope: "enc:v2:k1:AAAA", key_id: "k1", keys: ["login", "password"] });
    LET $f = fn::secrets_secret_get({ secret: $s }).data;
    RETURN $r.ok AND $r.data.labels = { current: 1 } AND $r.data.version.number = 1 AND $r.data.version.keys = ["login", "password"]
        AND $r.data.version.envelope IS NONE AND $f.latest_version = 1
        AND $f.next_rotation_at > time::now() + 89d AND $f.next_rotation_at < time::now() + 91d;
};

-- test: numéro qui n'est pas le suivant : conflit
-- en tant que: redacteur
{
    LET $s = <string> (SELECT VALUE id_secret FROM ONLY passe:s);
    LET $r = fn::secrets_version_add({ secret: $s, number: 1, envelope: "enc:v2:k1:BBBB", key_id: "k1" });
    RETURN $r.error.code = "SECRETS_VERSION_CONFLICT" AND $r.error.details.expected = 2;
};

-- test: enveloppe et clé incohérentes ou au mauvais format refusées
-- en tant que: redacteur
{
    LET $s = <string> (SELECT VALUE id_secret FROM ONLY passe:s);
    RETURN fn::secrets_version_add({ secret: $s, number: 2, envelope: "enc:v2:k1:BBBB", key_id: "k2" }).error.code = "SECRETS_ENVELOPE_INVALID"
        AND fn::secrets_version_add({ secret: $s, number: 2, envelope: "enc:v1:k1:BBBB", key_id: "k1" }).error.code = "SECRETS_INVALID_PARAMETERS"
        AND fn::secrets_version_add({ secret: $s, number: 2, envelope: "clair", key_id: "k1" }).error.code = "SECRETS_INVALID_PARAMETERS";
};

-- test: deuxième version : current avance, previous posée
-- en tant que: redacteur
{
    LET $s = <string> (SELECT VALUE id_secret FROM ONLY passe:s);
    RETURN fn::secrets_version_add({ secret: $s, number: 2, envelope: "enc:v2:k1:BBBB", key_id: "k1" }).data.labels = { current: 2, previous: 1 };
};

-- test: version en attente (rotation) : current inchangée
-- en tant que: redacteur
{
    LET $s = <string> (SELECT VALUE id_secret FROM ONLY passe:s);
    RETURN fn::secrets_version_add({ secret: $s, number: 3, envelope: "enc:v2:k1:CCCC", key_id: "k1", stage: "pending" }).data.labels = { current: 2, pending: 3, previous: 1 };
};

-- test: étiquettes : current déplacée (retour arrière), étiquette libre, retrait, current non retirable
-- en tant que: redacteur
{
    LET $s = <string> (SELECT VALUE id_secret FROM ONLY passe:s);
    LET $back = fn::secrets_version_label({ secret: $s, label: "current", number: 1 });
    LET $free = fn::secrets_version_label({ secret: $s, label: "stable", number: 2 });
    LET $rm = fn::secrets_version_label({ secret: $s, label: "stable", remove: true });
    RETURN $back.data.labels = { current: 1, pending: 3, previous: 2 }
        AND $free.data.labels.stable = 2 AND $rm.data.labels.stable IS NONE
        AND fn::secrets_version_label({ secret: $s, label: "current", remove: true }).error.code = "SECRETS_LABEL_INVALID"
        AND fn::secrets_version_label({ secret: $s, label: "inconnue", remove: true }).error.code = "SECRETS_LABEL_INVALID"
        AND fn::secrets_version_label({ secret: $s, label: "x", number: 9 }).error.code = "SECRETS_VERSION_NOT_FOUND"
        AND fn::secrets_version_label({ secret: $s, label: "Mauvais Nom", number: 1 }).error.code = "SECRETS_INVALID_PARAMETERS"
        AND fn::secrets_version_label({ secret: $s, label: "x" }).error.code = "SECRETS_INVALID_PARAMETERS";
};

-- test: liste des versions, la plus récente d'abord, sans enveloppe
-- en tant que: lecteur
{
    LET $s = <string> (SELECT VALUE id_secret FROM ONLY passe:s);
    LET $l = fn::secrets_version_list({ secret: $s }).data;
    RETURN $l.total = 3 AND $l.items.number = [3, 2, 1] AND $l.items.all(|$v| $v.envelope IS NONE)
        AND fn::secrets_version_list({ secret: $s, state: "destroyed" }).data.total = 0;
};

-- test: l'enveloppe n'est lisible par aucun utilisateur, même avec tous les droits
-- en tant que: admin
{
    LET $s = (SELECT VALUE id_secret FROM ONLY passe:s);
    RETURN (SELECT VALUE envelope FROM secrets_version WHERE secret = $s).all(|$e| $e IS NONE)
        AND array::len(SELECT * FROM secrets_version WHERE envelope = "enc:v2:k1:AAAA") = 0
        AND array::len(SELECT * FROM secrets_version WHERE string::starts_with(envelope ?? "", "enc")) = 0
        AND (SELECT VALUE key_id FROM secrets_version WHERE secret = $s).all(|$k| $k = "k1");
};

-- test: la session système lit l'enveloppe
RETURN (SELECT VALUE envelope FROM ONLY secrets_version WHERE secret = (SELECT VALUE id_secret FROM ONLY passe:s) AND number = 1 LIMIT 1) = "enc:v2:k1:AAAA";

-- test: désactivation et réactivation d'une version
-- en tant que: redacteur
{
    LET $s = <string> (SELECT VALUE id_secret FROM ONLY passe:s);
    RETURN fn::secrets_version_disable({ secret: $s, number: 2 }).data.state = "disabled"
        AND fn::secrets_version_disable({ secret: $s, number: 2 }).error.code = "SECRETS_VERSION_STATE_INVALID"
        AND fn::secrets_version_enable({ secret: $s, number: 2 }).data.state = "enabled"
        AND fn::secrets_version_disable({ secret: $s, number: 7 }).error.code = "SECRETS_VERSION_NOT_FOUND";
};

-- test: destruction : refusée au rédacteur, refusée sur une version étiquetée
-- en tant que: redacteur
{
    LET $s = <string> (SELECT VALUE id_secret FROM ONLY passe:s);
    RETURN fn::secrets_version_destroy({ secret: $s, number: 2 }).error.code = "SECRETS_PERMISSION_DENIED";
};

-- test: destruction d'une version étiquetée refusée, puis permise après retrait de l'étiquette
-- en tant que: admin
{
    LET $s = <string> (SELECT VALUE id_secret FROM ONLY passe:s);
    LET $labeled = fn::secrets_version_destroy({ secret: $s, number: 3 });
    fn::secrets_version_label({ secret: $s, label: "pending", remove: true });
    LET $ok = fn::secrets_version_destroy({ secret: $s, number: 3 });
    RETURN $labeled.error.code = "SECRETS_VERSION_LABELED" AND $ok.data.state = "destroyed" AND $ok.data.key_id IS NONE
        AND fn::secrets_version_enable({ secret: $s, number: 3 }).error.code = "SECRETS_VERSION_STATE_INVALID"
        AND fn::secrets_version_label({ secret: $s, label: "x", number: 3 }).error.code = "SECRETS_VERSION_NOT_FOUND";
};

-- test: l'enveloppe d'une version détruite est effacée
RETURN (SELECT VALUE envelope FROM ONLY secrets_version WHERE secret = (SELECT VALUE id_secret FROM ONLY passe:s) AND number = 3 LIMIT 1) IS NONE;

-- test: conservation : au-delà du nombre de versions, les plus anciennes sans étiquette sont détruites
-- en tant que: admin
{
    LET $id = fn::secrets_secret_create({ tenant: "auth_organization:alpha", path: "api/court", kind: "token" }).data.id;
    LET $s = <string> $id;
    fn::secrets_settings_set({ tenant: "auth_organization:alpha", max_versions: 2 });
    fn::secrets_version_add({ secret: $s, number: 1, envelope: "enc:v2:k1:A1", key_id: "k1" });
    fn::secrets_version_add({ secret: $s, number: 2, envelope: "enc:v2:k1:A2", key_id: "k1" });
    LET $third = fn::secrets_version_add({ secret: $s, number: 3, envelope: "enc:v2:k1:A3", key_id: "k1" });
    LET $fourth = fn::secrets_version_add({ secret: $s, number: 4, envelope: "enc:v2:k1:A4", key_id: "k1" });
    fn::secrets_settings_set({ tenant: "auth_organization:alpha", clear: ["max_versions"] });
    RETURN $third.data.destroyed = [1] AND $fourth.data.destroyed = [2] AND $fourth.data.labels = { current: 4, previous: 3 }
        AND (SELECT VALUE state FROM secrets_version WHERE secret = $id ORDER BY number) = ["destroyed", "destroyed", "enabled", "enabled"];
};

-- test: rescellement par la session système : enveloppe et clé changées ensemble
{
    LET $s = <string> (SELECT VALUE id_secret FROM ONLY passe:s);
    LET $r = fn::secrets_version_reseal({ secret: $s, number: 1, expected_key_id: "k1", envelope: "enc:v2:k2:ZZZZ", key_id: "k2" });
    LET $v = (SELECT envelope, key_id, resealed_at FROM ONLY secrets_version WHERE secret = type::record($s) AND number = 1 LIMIT 1);
    RETURN $r.data.resealed AND $v.envelope = "enc:v2:k2:ZZZZ" AND $v.key_id = "k2" AND $v.resealed_at IS NOT NONE
        AND fn::secrets_version_reseal({ secret: $s, number: 1, expected_key_id: "k1", envelope: "enc:v2:k3:YYYY", key_id: "k3" }).error.code = "SECRETS_VERSION_CONFLICT"
        AND fn::secrets_version_reseal({ secret: $s, number: 3, expected_key_id: "k1", envelope: "enc:v2:k3:YYYY", key_id: "k3" }).error.code = "SECRETS_VERSION_STATE_INVALID"
        AND fn::secrets_version_reseal({ secret: $s, number: 1, expected_key_id: "k2", envelope: "enc:v2:k3:YYYY", key_id: "k4" }).error.code = "SECRETS_ENVELOPE_INVALID";
};

-- test: rescellement refusé à un utilisateur, même administrateur
-- en tant que: admin
{
    LET $s = <string> (SELECT VALUE id_secret FROM ONLY passe:s);
    RETURN fn::secrets_version_reseal({ secret: $s, number: 2, expected_key_id: "k1", envelope: "enc:v2:k2:XXXX", key_id: "k2" }).error.code = "SECRETS_PERMISSION_DENIED";
};

-- test: rescellement par le worker
-- en tant que: worker
{
    LET $s = <string> (SELECT VALUE id_secret FROM ONLY passe:s);
    RETURN fn::secrets_version_reseal({ secret: $s, number: 2, expected_key_id: "k1", envelope: "enc:v2:k2:WWWW", key_id: "k2" }).data.key_id = "k2";
};

-- test: écriture directe : remplacement de l'enveloppe par un utilisateur refusé
-- en tant que: admin
-- attendu-erreur: SECRETS_PERMISSION_DENIED
UPDATE secrets_version SET envelope = "enc:v2:k9:EVIL", key_id = "k9", resealed_at = time::now() WHERE secret = (SELECT VALUE id_secret FROM ONLY passe:s) AND number = 1;

-- test: écriture directe : création d'une version au mauvais numéro refusée
-- en tant que: admin
-- attendu-erreur: SECRETS_VERSION_CONFLICT
CREATE secrets_version CONTENT { secret: (SELECT VALUE id_secret FROM ONLY passe:s), tenant: auth_organization:alpha, number: 9, envelope: "enc:v2:k1:QQQQ", key_id: "k1", created_by: auth_identity:admin };

-- test: écriture directe : version au nom d'un autre auteur refusée
-- en tant que: admin
-- attendu-erreur: SECRETS_PERMISSION_DENIED
CREATE secrets_version CONTENT { secret: (SELECT VALUE id_secret FROM ONLY passe:s), tenant: auth_organization:alpha, number: 4, envelope: "enc:v2:k1:QQQQ", key_id: "k1", created_by: auth_identity:lecteur };

-- test: écriture directe : étiquette sur une version détruite refusée
-- en tant que: admin
-- attendu-erreur: SECRETS_LABEL_INVALID
UPDATE (SELECT VALUE id_secret FROM ONLY passe:s) SET labels.old = 3;

-- test: écriture directe : version détruite intouchable
-- attendu-erreur: SECRETS_VERSION_STATE_INVALID
UPDATE secrets_version SET state = "enabled" WHERE secret = (SELECT VALUE id_secret FROM ONLY passe:s) AND number = 3;

-- test: secret supprimé : aucune version ajoutée
-- en tant que: admin
{
    LET $s = <string> (SELECT VALUE id_secret FROM ONLY passe:s);
    fn::secrets_secret_delete({ secret: $s });
    LET $r = fn::secrets_version_add({ secret: $s, number: 4, envelope: "enc:v2:k1:DDDD", key_id: "k1" });
    LET $l = fn::secrets_version_label({ secret: $s, label: "current", number: 2 });
    LET $d = fn::secrets_version_disable({ secret: $s, number: 2 });
    fn::secrets_secret_restore({ secret: $s });
    RETURN $r.error.code = "SECRETS_SECRET_DELETED" AND $l.error.code = "SECRETS_SECRET_DELETED" AND $d.error.code = "SECRETS_SECRET_DELETED";
};

-- test: purge : fiche et versions effacées ensemble
-- en tant que: admin
{
    LET $id = (SELECT VALUE id_secret FROM ONLY passe:s);
    fn::secrets_secret_delete({ secret: <string> $id });
    LET $p = fn::secrets_secret_purge({ secret: <string> $id });
    RETURN $p.data.purged AND array::len(SELECT * FROM secrets_version WHERE secret = $id) = 0;
};
