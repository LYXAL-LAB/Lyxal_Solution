-- lyxal-test: assertions
-- Clôture : les sondes de l'audit (A1 à A9) doivent échouer ; urgence de rotation, étiquette
-- pending, journal des fiches, accès à soi-même, attributions, demandes trompeuses, purge sans
-- date, jeton de réservation, champs scellés triés.
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
-- identité gestion: { "id": "auth_session:gestion", "pv": 1, "permissions": ["secrets.secret.list", "secrets.access.manage"] }
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

-- préparation: gestionnaire ; clé ; secret protégé infra/db (deux versions), secrets libres api/x et api/y
{
    CREATE auth_identity:gestion CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "gestion@lyxal.test" } };
    RELATE auth_identity:gestion->auth_member_of->auth_organization:alpha;
    CREATE auth_session:gestion CONTENT { identity: auth_identity:gestion, organization: auth_organization:alpha, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    fn::secrets_tenant_key_create({ tenant: "auth_organization:alpha", key_id: "k1", wrapped: "enc:v2:m1:K1" });
    LET $db = fn::secrets_secret_create({ tenant: "auth_organization:alpha", path: "infra/db", kind: "password" }).data.id;
    fn::secrets_version_add({ secret: <string> $db, number: 1, envelope: "enc:v2:k1:AAAA", key_id: "k1" });
    fn::secrets_version_add({ secret: <string> $db, number: 2, envelope: "enc:v2:k1:BBBB", key_id: "k1" });
    LET $x = fn::secrets_secret_create({ tenant: "auth_organization:alpha", path: "api/x", kind: "token" }).data.id;
    fn::secrets_version_add({ secret: <string> $x, number: 1, envelope: "enc:v2:k1:AAAA", key_id: "k1" });
    LET $y = fn::secrets_secret_create({ tenant: "auth_organization:alpha", path: "api/y", kind: "token" }).data.id;
    fn::secrets_policy_set({ tenant: "auth_organization:alpha", path: "infra", folder: true, required_approvals: 1 });
    CREATE passe:ids SET db = $db, x = $x, y = $y;
    UPDATE auth_identity:redacteur SET available_aal = 2;
};

-- test: A1 : une rotation d'urgence directe sans l'assurance requise est refusée
-- en tant que: redacteur
-- attendu-erreur: SECRETS_PERMISSION_DENIED
CREATE secrets_rotation CONTENT { secret: (SELECT VALUE db FROM ONLY passe:ids), tenant: auth_organization:alpha, emergency: true, started_by: "auth_identity:redacteur" };

-- test: A6 : une rotation ne se démarre pas au nom d'un autre
-- en tant que: redacteur
-- attendu-erreur: SECRETS_PERMISSION_DENIED
CREATE secrets_rotation CONTENT { secret: (SELECT VALUE x FROM ONLY passe:ids), tenant: auth_organization:alpha, started_by: "auth_identity:autre" };

-- préparation: rotation planifiée de infra/db démarrée par la session système
{
    fn::secrets_rotation_begin({ secret: <string> (SELECT VALUE db FROM ONLY passe:ids) });
};

-- test: A2 : un rédacteur ne pose ni n'écrit la nouvelle valeur d'une rotation
-- en tant que: redacteur
{
    LET $db = <string> (SELECT VALUE db FROM ONLY passe:ids);
    RETURN fn::secrets_version_add({ secret: $db, number: 3, envelope: "enc:v2:k1:CCCC", key_id: "k1", stage: "pending" }).error.code = "SECRETS_PERMISSION_DENIED"
        AND fn::secrets_version_label({ secret: $db, label: "pending", number: 1 }).error.code = "SECRETS_PERMISSION_DENIED";
};

-- test: A2 : écriture directe de l'étiquette pending refusée
-- en tant que: redacteur
-- attendu-erreur: SECRETS_PERMISSION_DENIED
UPDATE (SELECT VALUE db FROM ONLY passe:ids) SET labels.pending = 1;

-- test: A9 : le jeton de réservation n'est rendu qu'au worker qui réserve
-- en tant que: lecteur
{
    LET $g = fn::secrets_rotation_get({ secret: <string> (SELECT VALUE db FROM ONLY passe:ids) }).data;
    RETURN $g.active IS NOT NONE AND $g.active.lease IS NONE AND !("lease" INSIDE object::keys($g.active));
};

-- test: A9 : la réservation rend le jeton
-- en tant que: worker
RETURN string::len(fn::secrets_rotation_claim({}).data.items[0].lease) > 0;

-- test: A3 : une nouvelle version et un changement de fiche ne s'écrivent pas ensemble
-- en tant que: redacteur
-- attendu-erreur: SECRETS_SECRET_STATE_INVALID
{
    LET $x = (SELECT VALUE x FROM ONLY passe:ids);
    CREATE secrets_version CONTENT { secret: $x, tenant: auth_organization:alpha, number: 2, envelope: "enc:v2:k1:BBBB", key_id: "k1", created_by: auth_identity:redacteur };
    UPDATE $x SET latest_version = 2, visibility = "revealable", consumers = [];
};

-- test: A4 : un gestionnaire ne s'accorde rien à lui-même
-- en tant que: gestion
RETURN fn::secrets_grant_create({ tenant: "auth_organization:alpha", identity: "auth_identity:gestion", path: "api", folder: true, actions: ["read_value"], reason: "x" }).error.details.reason = "self"
    AND fn::secrets_grant_create({ tenant: "auth_organization:alpha", identity: "auth_identity:membre", path: "api", folder: true, actions: ["list"], reason: "support" }).ok;

-- test: A4 : écriture directe d'un accès à soi-même refusée
-- en tant que: gestion
-- attendu-erreur: SECRETS_GRANT_INVALID
CREATE secrets_grant CONTENT { tenant: auth_organization:alpha, subject_identity: auth_identity:gestion, path: "api", folder: true, actions: ["read_value"], expires_at: time::now() + 1h, reason: "x", granted_by: "auth_identity:gestion" };

-- test: A6 : un accès ne s'attribue pas à un autre auteur
-- en tant que: gestion
-- attendu-erreur: SECRETS_PERMISSION_DENIED
CREATE secrets_grant CONTENT { tenant: auth_organization:alpha, subject_identity: auth_identity:membre, path: "api", folder: true, actions: ["list"], expires_at: time::now() + 1h, reason: "x", granted_by: "auth_identity:quelquun" };

-- test: A6 : une protection ne s'attribue pas à un autre auteur
-- en tant que: gestion
-- attendu-erreur: SECRETS_PERMISSION_DENIED
UPDATE secrets_policy SET updated_by = "auth_identity:quelquun";

-- test: A6 : le demandeur ne pose pas les champs de décision
-- en tant que: membre
-- attendu-erreur: SECRETS_REQUEST_STATE_INVALID
{
    LET $r = fn::secrets_request_access({ tenant: "auth_organization:alpha", path: "api/x", actions: ["list"], reason: "x" }).data.id;
    UPDATE $r SET decided_by = "auth_identity:gestion", decision_reason = "accordé";
};

-- test: A7 : une demande de changement ne porte pas sur la valeur d'un autre
-- en tant que: redacteur
-- attendu-erreur: SECRETS_REQUEST_STATE_INVALID
CREATE secrets_request CONTENT { tenant: auth_organization:alpha, kind: "change", requested_identity: auth_identity:redacteur, path: "infra/db",
    secret: (SELECT VALUE db FROM ONLY passe:ids), operation: "value", number: 1, reason: "x", required_approvals: 1, expires_at: time::now() + 1d };

-- test: A7 : sans droit sur le secret, pas de demande de changement
-- en tant que: lecteur
-- attendu-erreur: SECRETS_PERMISSION_DENIED
CREATE secrets_request CONTENT { tenant: auth_organization:alpha, kind: "change", requested_identity: auth_identity:lecteur, path: "infra/db",
    secret: (SELECT VALUE db FROM ONLY passe:ids), operation: "disable", reason: "x", required_approvals: 1, expires_at: time::now() + 1d };

-- préparation: api/y supprimé
{
    fn::secrets_secret_delete({ secret: <string> (SELECT VALUE y FROM ONLY passe:ids) });
};

-- test: A8 : un secret supprimé garde sa date de purge, même pour la session système
-- attendu-erreur: SECRETS_SECRET_STATE_INVALID
UPDATE (SELECT VALUE y FROM ONLY passe:ids) SET purge_at = NONE;

-- test: A8 : le worker ne purge pas avant la date
-- en tant que: worker
{
    RETURN fn::secrets_purge_due({}).data.purged = 0 AND (SELECT VALUE state FROM ONLY (SELECT VALUE y FROM ONLY passe:ids)) = "deleted";
};

-- test: champs scellés : un tri sur l'enveloppe ne révèle rien
-- en tant que: lecteur
{
    LET $rows = (SELECT number, envelope FROM secrets_version ORDER BY envelope ASC);
    RETURN array::len($rows) > 0 AND array::all($rows, |$r| $r.envelope IS NONE);
};

-- test: garde des protections, appelée directement
RETURN fn::secrets_policy_refusal({ updated_by: "auth_identity:x" }) IS NONE;
