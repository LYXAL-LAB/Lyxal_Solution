-- lyxal-test: assertions
-- Mots de passe et actions imposées : identifiant inconnu sans identité (pas d'énumération),
-- empreinte scellée illisible, remplacement et révocation des autres sessions, actions imposées,
-- fonctions système refusées à une identité.
--
-- identité admin: { "id": "auth_session:admin", "pv": 1, "permissions": ["auth.identity.manage", "auth.identity.read"] }
-- identité claire: { "id": "auth_session:claire", "pv": 1, "permissions": ["auth.self.manage"] }

-- préparation: identités et sessions
{
    CREATE auth_identity:admin CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "admin@lyxal.test" } };
    CREATE auth_session:admin CONTENT { identity: auth_identity:admin, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    fn::auth_identity_create({ traits: { email: "Claire@Exemple.fr" } });
    LET $claire = (SELECT VALUE identity FROM ONLY auth_credential_identifier WHERE value = "claire@exemple.fr" LIMIT 1);
    CREATE auth_session:claire CONTENT { identity: $claire, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_session:claire_2 CONTENT { identity: $claire, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
};

-- test: identifiant inconnu : réponse sans identité ni empreinte
RETURN fn::auth_password_credential_get({ identifier: "inconnu@exemple.fr" }).data == { identity: NONE, identifier: "inconnu@exemple.fr", state: NONE, secret: NONE, required_actions: [] };

-- test: mot de passe enregistré (empreinte scellée), identifiant normalisé à la lecture
{
    LET $claire = (SELECT VALUE identity FROM ONLY auth_credential_identifier WHERE value = "claire@exemple.fr" LIMIT 1);
    LET $set = fn::auth_password_set({ identity: <string> $claire, secret: "enc:v2:cle-2026:AAAAAAAAAAAAAAAAAAAAAAAA" });
    LET $got = fn::auth_password_credential_get({ identifier: "CLAIRE@exemple.fr" }).data;
    RETURN $set.ok AND $got.identity == $claire AND $got.secret == "enc:v2:cle-2026:AAAAAAAAAAAAAAAAAAAAAAAA" AND $got.state == "active";
};

-- test: événement auth.password.changed publié (premier mot de passe)
RETURN (SELECT VALUE payload.first FROM event_outbox WHERE event_type = "auth.password.changed") == [true];

-- test: l'empreinte est illisible pour l'identité elle-même
-- en tant que: claire
RETURN (SELECT VALUE secret_data FROM ONLY auth_credential LIMIT 1) IS NONE
    AND (SELECT VALUE type FROM ONLY auth_credential LIMIT 1) == "password";

-- test: une identité n'appelle pas les fonctions système
-- en tant que: claire
RETURN fn::auth_password_credential_get({ identifier: "claire@exemple.fr" }).error.code == "AUTH_PERMISSION_DENIED"
    AND fn::auth_password_set({ identity: "auth_identity:admin", secret: "enc:v2:cle-2026:BBBBBBBBBBBBBBBBBBBBBBBB" }).error.code == "AUTH_PERMISSION_DENIED";

-- test: empreinte non scellée refusée
RETURN fn::auth_password_set({ identity: "auth_identity:admin", secret: "$argon2id$v=19$m=19456,t=2,p=1$abc" }).error.code == "AUTH_INVALID_PARAMETERS";

-- test: une action imposée est ajoutée par un administrateur, sans doublon
-- en tant que: admin
{
    LET $claire = (SELECT VALUE identity FROM ONLY auth_credential_identifier WHERE value = "claire@exemple.fr" LIMIT 1);
    LET $first = fn::auth_required_action_add({ identity: <string> $claire, action: "update_password", reason: "mot de passe initial" }).data;
    LET $again = fn::auth_required_action_add({ identity: <string> $claire, action: "update_password" }).data;
    RETURN $first.created AND !$again.created AND $first.action == $again.action;
};

-- test: l'identité voit ses actions imposées ; elle ne s'en impose pas
-- en tant que: claire
RETURN fn::auth_required_action_list({}).data.action == ["update_password"]
    AND fn::auth_required_action_add({ identity: "auth_identity:admin", action: "accept_terms" }).error.code == "AUTH_PERMISSION_DENIED";

-- test: les actions imposées sont renvoyées avec l'empreinte
RETURN fn::auth_password_credential_get({ identifier: "claire@exemple.fr" }).data.required_actions == ["update_password"];

-- test: nouveau mot de passe : action levée, autres sessions révoquées sauf la session courante
{
    LET $claire = (SELECT VALUE identity FROM ONLY auth_credential_identifier WHERE value = "claire@exemple.fr" LIMIT 1);
    LET $set = fn::auth_password_set({ identity: <string> $claire, secret: "enc:v2:cle-2026:CCCCCCCCCCCCCCCCCCCCCCCC", revoke_sessions: true, except_session: "auth_session:claire" }).data;
    RETURN $set.sessions_revoked == 1
        AND (SELECT VALUE state FROM ONLY auth_session:claire_2) == "revoked"
        AND (SELECT VALUE state FROM ONLY auth_session:claire) == "active"
        AND array::len(SELECT * FROM auth_required_action WHERE identity = $claire) == 0;
};

-- test: une action levée par la session système ; identité inconnue refusée
{
    fn::auth_required_action_add({ identity: "auth_identity:admin", action: "accept_terms" });
    RETURN fn::auth_required_action_complete({ identity: "auth_identity:admin", action: "accept_terms" }).data.completed
        AND !fn::auth_required_action_complete({ identity: "auth_identity:admin", action: "accept_terms" }).data.completed
        AND fn::auth_password_set({ identity: "auth_identity:inconnue", secret: "enc:v2:cle-2026:DDDDDDDDDDDDDDDDDDDDDDDD" }).error.code == "AUTH_IDENTITY_NOT_FOUND";
};
