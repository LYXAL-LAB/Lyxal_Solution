-- lyxal-test: assertions
-- Politique : politique de l'installation (seed), surcharge par organisation thème par thème,
-- valeurs bornées, permissions.
--
-- identité plateforme: { "id": "auth_session:plateforme", "pv": 1, "permissions": ["auth.policy.manage"] }
-- identité alpha: { "id": "auth_session:alpha", "pv": 1, "permissions": ["auth.organization.policy.manage", "auth.member.read"] }

-- préparation: organisations et sessions
{
    CREATE auth_organization:alpha CONTENT { slug: "alpha", name: "Alpha" };
    CREATE auth_organization:beta CONTENT { slug: "beta", name: "Beta" };
    CREATE auth_identity:p CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "p@lyxal.test" } };
    CREATE auth_session:plateforme CONTENT { identity: auth_identity:p, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_session:alpha CONTENT { identity: auth_identity:p, organization: auth_organization:alpha, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
};

-- test: politique de l'installation issue du seed (inscription sur invitation seulement)
RETURN fn::auth_policy_get({}).data.{ m: password.min_length, r: registration.mode, t: invitation.ttl_seconds } == { m: 12, r: "invitation_only", t: 604800 };

-- test: la plateforme renforce le verrouillage de l'installation
-- en tant que: plateforme
RETURN fn::auth_policy_save({ lockout: { max_failures: 5, lock_seconds: 1800 } }).data.lockout.{ max_failures, lock_seconds } == { max_failures: 5, lock_seconds: 1800 };

-- test: valeurs hors bornes et clés inconnues refusées
-- en tant que: plateforme
RETURN fn::auth_policy_save({ password: { min_length: 4 } }).error.code == "AUTH_INVALID_PARAMETERS"
    AND fn::auth_policy_save({ password: { inconnu: 1 } }).error.code == "AUTH_INVALID_PARAMETERS"
    AND fn::auth_policy_save({ mfa: { methods: ["sms"] } }).error.code == "AUTH_INVALID_PARAMETERS"
    AND fn::auth_policy_save({ password: "x" }).error.code == "AUTH_INVALID_PARAMETERS";

-- test: une organisation durcit sa politique
-- en tant que: alpha
RETURN fn::auth_policy_save({ organization: "auth_organization:alpha", password: { min_length: 16 }, mfa: { required: true } }).ok;

-- test: politique effective d'alpha : surcharge champ par champ
RETURN fn::auth_policy_get({ organization: "auth_organization:alpha" }).data.{ m: password.min_length, h: password.history, f: lockout.max_failures, mfa: mfa.required } == { m: 16, h: 5, f: 5, mfa: true };

-- test: durées de session par défaut (ASVS niveau 2) : inactivité 30 min, absolue et renouvellement 12 h
RETURN fn::auth_policy_get({}).data.{ i: session.idle_seconds, a: session.absolute_seconds, r: refresh.ttl_seconds } == { i: 1800, a: 43200, r: 43200 };

-- test: une organisation raccourcit ses sessions mais ne les allonge pas au-delà de l'installation
-- en tant que: alpha
RETURN fn::auth_policy_save({ organization: "auth_organization:alpha", session: { idle_seconds: 900, absolute_seconds: 604800 }, refresh: { ttl_seconds: 2592000 } }).ok
    AND fn::auth_policy_get({ organization: "auth_organization:alpha" }).data.{ i: session.idle_seconds, a: session.absolute_seconds, r: refresh.ttl_seconds } == { i: 900, a: 43200, r: 43200 };

-- test: beta garde la politique de l'installation
RETURN fn::auth_policy_get({ organization: "auth_organization:beta" }).data.password.min_length == 12;

-- test: alpha ne modifie ni la politique de l'installation ni celle de beta
-- en tant que: alpha
RETURN fn::auth_policy_save({ password: { min_length: 8 } }).error.code == "AUTH_PERMISSION_DENIED"
    AND fn::auth_policy_save({ organization: "auth_organization:beta", password: { min_length: 8 } }).error.code == "AUTH_PERMISSION_DENIED";

-- test: organisation inconnue
RETURN fn::auth_policy_save({ organization: "auth_organization:fantome", password: { min_length: 14 } }).error.code == "AUTH_ORGANIZATION_NOT_FOUND";
