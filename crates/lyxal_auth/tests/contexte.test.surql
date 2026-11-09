-- lyxal-test: assertions
-- Contexte et contrôle des droits : session relue à chaque appel (révocation, expiration,
-- not_before, version des droits), portée des permissions, organisation active.
--
-- identité admin: { "id": "auth_session:admin", "pv": 1, "permissions": ["auth.organization.manage", "auth.identity.read"] }
-- identité alpha: { "id": "auth_session:alpha", "pv": 1, "tenant": "auth_organization:alpha", "permissions": ["auth.member.read", "auth.member.manage"] }
-- identité perime: { "id": "auth_session:perime", "pv": 1, "permissions": ["auth.organization.manage"] }
-- identité vieux: { "id": "auth_session:alpha", "pv": 0, "tenant": "auth_organization:alpha", "permissions": ["auth.member.read"] }
-- identité anonyme: { "id": "autre_table:x", "permissions": ["auth.organization.manage"] }

-- préparation: organisations, permissions, identités et sessions
{
    CREATE auth_organization:alpha CONTENT { slug: "alpha", name: "Alpha" };
    CREATE auth_organization:beta CONTENT { slug: "beta", name: "Beta" };
    CREATE auth_identity:admin CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "admin@lyxal.test" } };
    CREATE auth_identity:alpha CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "a@alpha.test" } };
    CREATE auth_session:admin CONTENT { identity: auth_identity:admin, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_session:alpha CONTENT { identity: auth_identity:alpha, organization: auth_organization:alpha, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_session:perime CONTENT { identity: auth_identity:admin, idle_expires_at: time::now() - 1m, expires_at: time::now() + 1d };
    RELATE auth_identity:alpha->auth_member_of->auth_organization:alpha;
};

-- test: la session système a tous les droits
RETURN fn::auth_has_permission({ permission: "auth.organization.manage" }) AND fn::auth_context({}).data.system;

-- test: le contexte d'une session valide
-- en tant que: alpha
RETURN fn::auth_context({}).data.{ identity, organization, system, permissions } == { identity: auth_identity:alpha, organization: auth_organization:alpha, system: false, permissions: ["auth.member.read", "auth.member.manage"] };

-- test: permission d'installation portée par le jeton
-- en tant que: admin
RETURN fn::auth_has_permission({ permission: "auth.organization.manage" });

-- test: permission absente du jeton refusée
-- en tant que: admin
RETURN fn::auth_has_permission({ permission: "auth.member.read", tenant: auth_organization:alpha }) == false;

-- test: permission d'organisation dans l'organisation active seulement
-- en tant que: alpha
RETURN fn::auth_has_permission({ permission: "auth.member.read", tenant: auth_organization:alpha })
    AND !fn::auth_has_permission({ permission: "auth.member.read", tenant: auth_organization:beta })
    AND !fn::auth_has_permission({ permission: "auth.member.read" });

-- test: permission inconnue refusée
-- en tant que: alpha
RETURN fn::auth_has_permission({ permission: "inconnue.read", tenant: auth_organization:alpha }) == false;

-- test: une session expirée par inactivité n'a aucun droit
-- en tant que: perime
RETURN fn::auth_has_permission({ permission: "auth.organization.manage" }) == false AND fn::auth_context({}).error.code == "AUTH_SESSION_EXPIRED";

-- test: un jeton dont la version des droits est dépassée est obsolète
-- en tant que: vieux
RETURN fn::auth_context({}).error.code == "AUTH_SESSION_STALE" AND !fn::auth_has_permission({ permission: "auth.member.read", tenant: auth_organization:alpha });

-- test: un jeton qui ne désigne pas une session n'a aucun droit
-- en tant que: anonyme
RETURN fn::auth_context({}).error.code == "AUTH_SESSION_REQUIRED" AND !fn::auth_has_permission({ permission: "auth.organization.manage" });

-- test: l'administrateur lit les organisations, le membre seulement la sienne
-- en tant que: alpha
RETURN (SELECT VALUE slug FROM auth_organization) == ["alpha"];

-- test: l'identité lit sa propre fiche et celles de son organisation
-- en tant que: alpha
RETURN (SELECT VALUE id FROM auth_identity) == [auth_identity:alpha];

-- test: membre partageant l'organisation
-- en tant que: alpha
RETURN fn::auth_shares_organization({ identity: auth_identity:alpha, permission: "auth.member.read" })
    AND !fn::auth_shares_organization({ identity: auth_identity:admin, permission: "auth.member.read" });

-- préparation: révocation de la session alpha pendant que le jeton reste valide
UPDATE auth_session:alpha SET state = "revoked", revoked_at = time::now();

-- test: une session révoquée perd ses droits dès l'opération suivante
-- en tant que: alpha
RETURN fn::auth_context({}).error.code == "AUTH_SESSION_REVOKED" AND (SELECT VALUE slug FROM auth_organization) == [];

-- préparation: not_before posé sur l'identité après la création de sa session
UPDATE auth_identity:admin SET not_before = time::now() + 1s;

-- test: une session antérieure à not_before est refusée
-- en tant que: admin
RETURN fn::auth_context({}).error.code == "AUTH_SESSION_REVOKED";

-- test: validité de session en direct : session système
RETURN fn::auth_session_valid({}) == { valid: true, system: true, code: NONE };
