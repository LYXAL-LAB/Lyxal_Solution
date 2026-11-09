-- lyxal-test: assertions
-- Applications, comptes de service et clés d'API : création selon la portée, secrets en
-- empreinte (illisibles), session de service (permissions des rôles de l'application),
-- application désactivée ou droits retirés → session refusée, clés d'API bornées par les droits
-- du propriétaire, révocation.
--
-- identité plateforme: { "id": "auth_session:plateforme", "pv": 1, "permissions": ["auth.application.manage", "auth.role.manage", "auth.identity.manage"] }
-- identité alpha_admin: { "id": "auth_session:alpha_admin", "pv": 1, "permissions": ["auth.organization.application.manage", "auth.organization.role.manage", "auth.member.read", "auth.self.manage"] }
-- identité claire: { "id": "auth_session:claire", "pv": 1, "permissions": ["auth.member.read", "auth.self.manage"] }
-- identité service: { "id": "auth_session:service", "pv": 1, "permissions": ["auth.identity.read"] }

-- préparation: organisation, identités, sessions, rôle de service
{
    CREATE auth_organization:alpha CONTENT { slug: "alpha", name: "Alpha BTP" };
    CREATE auth_identity:plateforme CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "plateforme@lyxal.test" } };
    CREATE auth_session:plateforme CONTENT { identity: auth_identity:plateforme, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_identity:alpha_admin CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "admin@alpha.test" } };
    RELATE auth_identity:alpha_admin->auth_member_of->auth_organization:alpha;
    CREATE auth_session:alpha_admin CONTENT { identity: auth_identity:alpha_admin, organization: auth_organization:alpha, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    fn::auth_identity_create({ traits: { email: "claire@exemple.fr" }, organization: "auth_organization:alpha" });
    LET $claire = (SELECT VALUE identity FROM ONLY auth_credential_identifier WHERE value = "claire@exemple.fr" LIMIT 1);
    CREATE auth_session:claire CONTENT { identity: $claire, organization: auth_organization:alpha, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_role:lecteur_identites CONTENT { scope_key: "installation", key: "lecteur_identites", name: "Lecteur", scope: "installation", kind: "service" };
    RELATE auth_role:lecteur_identites->auth_role_grants->auth_permission:⟨auth.identity.read⟩;
    DEFINE TABLE test_ref SCHEMALESS PERMISSIONS FULL;
};

-- test: l'administrateur de la plateforme crée une application machine de l'installation
-- en tant que: plateforme
{
    LET $app = fn::auth_application_create({ name: "Synchronisation", type: "machine" }).data;
    CREATE test_ref:app CONTENT { id_app: $app.id, client_id: $app.client_id };
    RETURN $app.type == "machine" AND string::starts_with($app.client_id, "lyx_") AND $app.state == "active" AND $app.tenant IS NONE;
};

-- test: événement auth.application.created publié
RETURN array::len(SELECT * FROM event_outbox WHERE event_type = "auth.application.created") == 1;

-- test: l'administrateur d'organisation crée une application de son organisation, pas de l'installation
-- en tant que: alpha_admin
RETURN fn::auth_application_create({ tenant: "auth_organization:alpha", name: "Mobile Alpha", type: "native", redirect_uris: ["https://alpha.test/retour"] }).data.tenant == auth_organization:alpha
    AND fn::auth_application_create({ name: "Interdit", type: "machine" }).error.code == "AUTH_PERMISSION_DENIED";

-- test: une identité ordinaire ne gère pas d'application
-- en tant que: claire
RETURN fn::auth_application_create({ tenant: "auth_organization:alpha", name: "X", type: "spa" }).error.code == "AUTH_PERMISSION_DENIED"
    AND fn::auth_application_list({ tenant: "auth_organization:alpha" }).error.code == "AUTH_PERMISSION_DENIED";

-- test: secret ajouté (empreinte et préfixe seulement), rôle attribué à l'application
-- en tant que: plateforme
{
    LET $added = fn::auth_application_secret_add({ application: <string> test_ref:app.id_app, secret_hash: "5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a", prefix: "lyxs_abc" }).data;
    LET $app = test_ref:app.id_app;
    LET $role = (RELATE ONLY $app->auth_has_role->auth_role:lecteur_identites);
    RETURN $added.prefix == "lyxs_abc" AND $role IS NOT NONE
        AND fn::auth_application_list({}).data[0].secrets.prefix == ["lyxs_abc"];
};

-- test: l'empreinte du secret est illisible
-- en tant que: plateforme
RETURN (SELECT VALUE secret_hash FROM ONLY auth_application_secret LIMIT 1) IS NONE;

-- test: secret sur une application non machine refusé
-- en tant que: alpha_admin
{
    LET $mobile = (SELECT VALUE id FROM ONLY auth_application WHERE name = "Mobile Alpha" LIMIT 1);
    RETURN fn::auth_application_secret_add({ application: <string> $mobile, secret_hash: "6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b", prefix: "lyxs_def" }).error.code == "AUTH_INVALID_PARAMETERS";
};

-- test: permissions effectives de l'application
RETURN fn::auth_application_permissions({ application: <string> test_ref:app.id_app }).data.{ permissions, version } == { permissions: ["auth.identity.read"], version: 1 };

-- test: session de service : permissions des rôles de l'application, sans jeton de renouvellement
{
    LET $s = fn::auth_service_session_create({ client_id: test_ref:app.client_id, secret_hash: "5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a", access_slot: "a" }).data;
    UPDATE test_ref:app SET service_session = $s.session;
    RETURN $s.kind == "service" AND $s.permissions == ["auth.identity.read"] AND $s.refresh_expires_at IS NONE AND $s.application == test_ref:app.id_app;
};

-- test: client inconnu, secret faux : même erreur
RETURN fn::auth_service_session_create({ client_id: test_ref:app.client_id, secret_hash: "7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c", access_slot: "a" }).error.code == "AUTH_CLIENT_CREDENTIALS_INVALID"
    AND fn::auth_service_session_create({ client_id: "lyx_inconnu_0000000000", secret_hash: "5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a", access_slot: "a" }).error.code == "AUTH_CLIENT_CREDENTIALS_INVALID";

-- préparation: la session de test du compte de service désigne la session émise
{
    LET $s = (SELECT * FROM ONLY test_ref:app.service_session);
    CREATE auth_session:service CONTENT { application: $s.application, kind: "service", idle_expires_at: $s.idle_expires_at, expires_at: $s.expires_at };
};

-- test: le compte de service agit avec ses permissions ; son contexte porte l'application
-- en tant que: service
RETURN fn::auth_context({}).data.{ kind, identity } == { kind: "service", identity: NONE }
    AND fn::auth_has_permission({ permission: "auth.identity.read" });

-- test: retrait d'un droit de l'application : version incrémentée
{
    DELETE auth_has_role WHERE in = test_ref:app.id_app AND out = auth_role:lecteur_identites;
    RETURN (SELECT VALUE permissions_version FROM ONLY test_ref:app.id_app) == 2;
};

-- test: jeton aux droits dépassés refusé
-- en tant que: service
RETURN fn::auth_context({}).error.code == "AUTH_SESSION_STALE";

-- test: application désactivée : nouvelles sessions refusées
-- en tant que: plateforme
{
    UPDATE test_ref:app SET reenabled = true;
    RETURN fn::auth_application_update({ application: <string> test_ref:app.id_app, state: "disabled" }).data.state == "disabled";
};

-- test: application désactivée : ouverture de session refusée
RETURN fn::auth_service_session_create({ client_id: test_ref:app.client_id, secret_hash: "5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a", access_slot: "a" }).error.code == "AUTH_APPLICATION_INACTIVE";

-- test: secret révoqué
-- en tant que: plateforme
{
    LET $secret = (SELECT VALUE id FROM ONLY auth_application_secret LIMIT 1);
    RETURN fn::auth_application_secret_revoke({ secret: <string> $secret }).data.revoked
        AND !fn::auth_application_secret_revoke({ secret: <string> $secret }).data.revoked;
};

-- test: clé d'API créée avec des permissions détenues ; permission non détenue refusée
-- en tant que: claire
{
    LET $key = fn::auth_api_key_create({ name: "Outil CLI", key_hash: "8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d", prefix: "lyxk_cli", permissions: ["auth.member.read"] }).data;
    LET $excess = fn::auth_api_key_create({ name: "Trop", key_hash: "9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e", prefix: "lyxk_bad", permissions: ["auth.identity.manage"] });
    RETURN $key.permissions == ["auth.member.read"] AND $key.organization == auth_organization:alpha
        AND $excess.error.code == "AUTH_PERMISSION_DENIED" AND $excess.error.details.permissions == ["auth.identity.manage"];
};

-- test: l'identité liste ses clés, sans empreinte
-- en tant que: claire
RETURN fn::auth_api_key_list({}).data.prefix == ["lyxk_cli"]
    AND (SELECT VALUE key_hash FROM ONLY auth_api_key LIMIT 1) IS NONE;

-- test: échange de la clé : session api_key limitée aux permissions de la clé
{
    LET $s = fn::auth_api_key_session_create({ key_hash: "8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d", access_slot: "a" }).data;
    UPDATE test_ref:app SET api_session = $s.session;
    RETURN $s.kind == "api_key" AND $s.permissions == ["auth.member.read"] AND $s.refresh_expires_at IS NONE
        AND (SELECT VALUE last_used_at FROM ONLY auth_api_key LIMIT 1) IS NOT NONE;
};

-- test: clé inconnue refusée ; clé expirée refusée
{
    CREATE auth_api_key CONTENT { identity: (SELECT VALUE identity FROM ONLY auth_session:claire), name: "Vieille", key_hash: "0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f", prefix: "lyxk_old", permissions: ["auth.member.read"], expires_at: time::now() - 1s };
    RETURN fn::auth_api_key_session_create({ key_hash: "1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e", access_slot: "a" }).error.code == "AUTH_API_KEY_INVALID"
        AND fn::auth_api_key_session_create({ key_hash: "0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f", access_slot: "a" }).error.code == "AUTH_API_KEY_EXPIRED";
};

-- test: clé révoquée par son propriétaire, puis inutilisable ; événements publiés
-- en tant que: claire
{
    LET $key = (SELECT VALUE id FROM ONLY auth_api_key WHERE prefix = "lyxk_cli" LIMIT 1);
    RETURN fn::auth_api_key_revoke({ api_key: <string> $key }).data.revoked;
};

-- test: clé révoquée : échange refusé, événements de création et de révocation publiés
RETURN fn::auth_api_key_session_create({ key_hash: "8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d", access_slot: "a" }).error.code == "AUTH_API_KEY_INVALID"
    AND array::len(SELECT * FROM event_outbox WHERE event_type IN ["auth.api_key.created", "auth.api_key.revoked"]) == 3
    AND fn::auth_application_can({ tenant: NONE });

-- test: compte de service interne à l'hôte : session ouverte sans secret par la session système, refusée pour une application non machine
{
    LET $machine = fn::auth_application_create({ name: "Agent interne", type: "machine" }).data;
    LET $spa = fn::auth_application_create({ name: "Interface", type: "spa" }).data;
    LET $opened = fn::auth_service_session_open({ client_id: $machine.client_id, access_slot: "a" });
    LET $sess = (SELECT * FROM ONLY $opened.data.session);
    RETURN $opened.ok AND $opened.data.kind == "service" AND $opened.data.refresh_expires_at IS NONE
        AND $sess.application == $machine.id AND $sess.amr.method == ["host"]
        AND fn::auth_service_session_open({ client_id: $spa.client_id, access_slot: "a" }).error.code == "AUTH_APPLICATION_NOT_FOUND"
        AND fn::auth_service_session_open({ client_id: "lyx_inconnu_inconnu_inconnu", access_slot: "a" }).error.code == "AUTH_APPLICATION_NOT_FOUND";
};
