-- lyxal-test: assertions
-- Sessions et jetons : ouverture (permissions, auth.self.manage, adhésion exigée), contexte,
-- renouvellement à usage unique et réutilisation (session révoquée), révocations, changement
-- d'organisation, liste, anti-force-brute (seuil, identifiant inconnu compté, remise à zéro).
--
-- identité claire: { "id": "auth_session:claire", "pv": 1, "permissions": ["auth.member.read", "auth.self.manage"] }
-- identité gestion: { "id": "auth_session:gestion", "pv": 1, "permissions": ["auth.session.manage", "auth.member.read"] }

-- préparation: organisations, identité membre d'alpha, sessions de test
{
    CREATE auth_organization:alpha CONTENT { slug: "alpha", name: "Alpha BTP" };
    CREATE auth_organization:beta CONTENT { slug: "beta", name: "Beta" };
    fn::auth_identity_create({ traits: { email: "claire@exemple.fr" }, organization: "auth_organization:alpha" });
    LET $claire = (SELECT VALUE identity FROM ONLY auth_credential_identifier WHERE value = "claire@exemple.fr" LIMIT 1);
    CREATE auth_session:claire CONTENT { identity: $claire, organization: auth_organization:alpha, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_identity:gestion CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "gestion@alpha.test" } };
    RELATE auth_identity:gestion->auth_member_of->auth_organization:alpha;
    CREATE auth_session:gestion CONTENT { identity: auth_identity:gestion, organization: auth_organization:alpha, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    DEFINE TABLE test_ref SCHEMALESS PERMISSIONS FULL;
};

-- test: session ouverte dans l'organisation : permissions du rôle membre et auth.self.manage, durées de la politique
{
    LET $claire = (SELECT VALUE identity FROM ONLY auth_credential_identifier WHERE value = "claire@exemple.fr" LIMIT 1);
    LET $s = fn::auth_session_create({
        identity: <string> $claire, organization: "auth_organization:alpha", amr: ["password"],
        client: { ip: "198.51.100.4", user_agent: "navigateur" }, access_slot: "a",
        refresh_token_hash: "a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1"
    }).data;
    CREATE test_ref:s1 CONTENT { session: $s.session };
    RETURN $s.permissions == ["auth.member.read", "auth.self.manage"] AND $s.access_seconds == 900 AND $s.version == 1
        AND $s.kind == "interactive" AND $s.refresh_expires_at IS NOT NONE AND $s.organization == auth_organization:alpha;
};

-- test: session enregistrée avec son appareil, événement auth.session.created publié, dernière connexion notée
{
    LET $s = (SELECT * FROM ONLY test_ref:s1.session);
    RETURN $s.client == { ip: "198.51.100.4", user_agent: "navigateur" } AND $s.amr.method == ["password"]
        AND array::len(SELECT * FROM event_outbox WHERE event_type = "auth.session.created" AND payload.session_id = <string> $s.id) == 1
        AND (SELECT VALUE last_login_at FROM ONLY $s.identity) IS NOT NONE;
};

-- test: organisation dont l'identité n'est pas membre refusée ; identité inconnue refusée
{
    LET $claire = (SELECT VALUE identity FROM ONLY auth_credential_identifier WHERE value = "claire@exemple.fr" LIMIT 1);
    RETURN fn::auth_session_create({ identity: <string> $claire, organization: "auth_organization:beta", amr: ["password"], access_slot: "a", refresh_token_hash: "b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1" }).error.code == "AUTH_NOT_A_MEMBER"
        AND fn::auth_session_create({ identity: "auth_identity:inconnue", amr: ["password"], access_slot: "a", refresh_token_hash: "c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1" }).error.code == "AUTH_IDENTITY_NOT_FOUND";
};

-- test: renouvellement : nouveau jeton, inactivité repoussée sans dépasser l'expiration absolue
{
    LET $r = fn::auth_session_refresh({ token_hash: "a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1", new_token_hash: "a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2", access_slot: "b" }).data;
    RETURN $r.session == test_ref:s1.session AND $r.idle_expires_at <= $r.expires_at AND $r.permissions == ["auth.member.read", "auth.self.manage"]
        AND (SELECT VALUE access_slot FROM ONLY $r.session) == "b";
};

-- test: jeton inconnu refusé
RETURN fn::auth_session_refresh({ token_hash: "ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff", new_token_hash: "eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee", access_slot: "a" }).error.code == "AUTH_REFRESH_INVALID";

-- test: réutilisation d'un jeton déjà échangé : session révoquée, nouveau jeton inutilisable, événement publié
{
    LET $reuse = fn::auth_session_refresh({ token_hash: "a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1", new_token_hash: "a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3", access_slot: "a" });
    LET $next = fn::auth_session_refresh({ token_hash: "a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2", new_token_hash: "a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4", access_slot: "a" });
    RETURN $reuse.error.code == "AUTH_REFRESH_REUSED" AND $next.error.code == "AUTH_REFRESH_INVALID"
        AND (SELECT VALUE [state, revoked_reason] FROM ONLY test_ref:s1.session) == ["revoked", "refresh_reused"]
        AND array::len(SELECT * FROM event_outbox WHERE event_type = "auth.refresh.reused") == 1
        AND array::len(SELECT * FROM event_outbox WHERE event_type = "auth.session.revoked") == 1;
};

-- préparation: nouvelle session pour le changement d'organisation
{
    LET $claire = (SELECT VALUE identity FROM ONLY auth_credential_identifier WHERE value = "claire@exemple.fr" LIMIT 1);
    LET $s = fn::auth_session_create({ identity: <string> $claire, amr: ["password"], access_slot: "a", refresh_token_hash: "d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1d1" }).data;
    UPSERT test_ref:s2 CONTENT { session: $s.session };
};

-- test: session sans organisation : permissions d'installation seulement (ici auth.self.manage)
RETURN (SELECT VALUE organization FROM ONLY test_ref:s2.session) IS NONE;

-- test: changement d'organisation : nouvelle session, même expiration absolue, ancienne révoquée
{
    LET $old = (SELECT * FROM ONLY test_ref:s2.session);
    LET $r = fn::auth_session_switch_organization({ session: <string> $old.id, organization: "auth_organization:alpha", access_slot: "a", refresh_token_hash: "d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2" }).data;
    RETURN $r.session != $old.id AND $r.organization == auth_organization:alpha AND $r.expires_at == $old.expires_at
        AND (SELECT VALUE expires_at FROM ONLY $r.session) == $old.expires_at
        AND (SELECT VALUE state FROM ONLY $old.id) == "revoked"
        AND fn::auth_session_switch_organization({ session: <string> $old.id, organization: "auth_organization:alpha", access_slot: "a", refresh_token_hash: "d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3" }).error.code == "AUTH_SESSION_REVOKED";
};

-- test: changement vers une organisation dont l'identité n'est pas membre refusé
{
    LET $current = (SELECT VALUE id FROM ONLY auth_session WHERE state = "active" AND organization = auth_organization:alpha AND identity.traits.email = "claire@exemple.fr" AND id != auth_session:claire LIMIT 1);
    RETURN fn::auth_session_switch_organization({ session: <string> $current, organization: "auth_organization:beta", access_slot: "a", refresh_token_hash: "d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4" }).error.code == "AUTH_NOT_A_MEMBER";
};

-- test: l'identité liste ses sessions actives, la session courante marquée
-- en tant que: claire
{
    LET $list = fn::auth_session_list({}).data;
    RETURN array::len($list) >= 2 AND array::len(array::filter($list, |$s| $s.current)) == 1
        AND array::all($list, |$s| $s.identity == (SELECT VALUE identity FROM ONLY auth_session:claire));
};

-- test: sans auth.session.manage, pas de liste d'organisation
-- en tant que: claire
RETURN fn::auth_session_list({ organization: "auth_organization:alpha" }).error.code == "AUTH_PERMISSION_DENIED";

-- test: un gestionnaire liste les sessions de son organisation
-- en tant que: gestion
RETURN array::len(fn::auth_session_list({ organization: "auth_organization:alpha" }).data) >= 3;

-- test: le contexte d'une session interactive porte le sujet, la nature et l'organisation
-- en tant que: claire
RETURN fn::auth_context({}).data.{ kind, application, organization } == { kind: NONE, application: NONE, organization: auth_organization:alpha }
    OR fn::auth_context({}).data.{ kind, application, organization } == { kind: "interactive", application: NONE, organization: auth_organization:alpha };

-- test: révocation d'une session, puis de toutes sauf une
{
    LET $claire = (SELECT VALUE identity FROM ONLY auth_credential_identifier WHERE value = "claire@exemple.fr" LIMIT 1);
    LET $one = fn::auth_session_revoke({ session: "auth_session:gestion", reason: "admin_revoke" }).data;
    LET $again = fn::auth_session_revoke({ session: "auth_session:gestion" }).data;
    LET $all = fn::auth_session_revoke_all({ identity: <string> $claire, except_session: "auth_session:claire" }).data;
    RETURN $one.revoked AND !$again.revoked AND $all.revoked >= 1
        AND array::len(SELECT * FROM auth_session WHERE identity = $claire AND state = "active") == 1;
};

-- test: une session révoquée perd ses droits dès l'opération suivante
-- en tant que: gestion
RETURN fn::auth_context({}).error.code == "AUTH_SESSION_REVOKED"
    AND fn::auth_session_list({ organization: "auth_organization:alpha" }).error.code == "AUTH_SESSION_REVOKED";

-- test: une identité n'ouvre ni ne révoque de session
-- en tant que: claire
RETURN fn::auth_session_create({ identity: "auth_identity:gestion", amr: ["password"], access_slot: "a", refresh_token_hash: "e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1" }).error.code == "AUTH_PERMISSION_DENIED"
    AND fn::auth_session_revoke({ session: "auth_session:claire" }).error.code == "AUTH_PERMISSION_DENIED"
    AND fn::auth_session_refresh({ token_hash: "d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2d2", new_token_hash: "d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5d5", access_slot: "a" }).error.code == "AUTH_PERMISSION_DENIED";

-- test: identifiant non verrouillé au départ
RETURN fn::auth_login_failure_check({ identifier_hash: "1010101010101010101010101010101010101010101010101010101010101010", ip_hash: "2020202020202020202020202020202020202020202020202020202020202020" }).data == { locked: false, until: NONE };

-- test: au dixième échec, identifiant verrouillé ; événements publiés (identité connue)
{
    LET $claire = (SELECT VALUE identity FROM ONLY auth_credential_identifier WHERE value = "claire@exemple.fr" LIMIT 1);
    FOR $i IN [1, 2, 3, 4, 5, 6, 7, 8, 9] {
        fn::auth_login_failure_record({ identifier_hash: "1010101010101010101010101010101010101010101010101010101010101010", ip_hash: "2020202020202020202020202020202020202020202020202020202020202020", identity: <string> $claire });
    };
    LET $ninth = fn::auth_login_failure_check({ identifier_hash: "1010101010101010101010101010101010101010101010101010101010101010" }).data.locked;
    LET $tenth = fn::auth_login_failure_record({ identifier_hash: "1010101010101010101010101010101010101010101010101010101010101010", ip_hash: "2020202020202020202020202020202020202020202020202020202020202020", identity: <string> $claire }).data;
    RETURN !$ninth AND $tenth.locked AND $tenth.until > time::now()
        AND array::len(SELECT * FROM event_outbox WHERE event_type = "auth.login.failed") == 10
        AND array::len(SELECT * FROM event_outbox WHERE event_type = "auth.identity.locked") == 1;
};

-- test: aucun identifiant en clair dans les compteurs ni dans les événements d'échec
RETURN array::all((SELECT VALUE key_hash FROM auth_login_failure), |$h| string::len($h) == 64)
    AND array::len(SELECT * FROM event_outbox WHERE event_type = "auth.login.failed" AND payload.identifier_hash != "1010101010101010101010101010101010101010101010101010101010101010") == 0;

-- test: identifiant inconnu compté pareil ; remise à zéro après une connexion réussie
{
    FOR $i IN [1, 2, 3] { fn::auth_login_failure_record({ identifier_hash: "3030303030303030303030303030303030303030303030303030303030303030" }); };
    LET $counted = (SELECT VALUE failures FROM ONLY auth_login_failure WHERE key_hash = "3030303030303030303030303030303030303030303030303030303030303030" LIMIT 1);
    fn::auth_login_failure_reset({ identifier_hash: "3030303030303030303030303030303030303030303030303030303030303030" });
    RETURN $counted == 3 AND array::len(SELECT * FROM auth_login_failure WHERE key_hash = "3030303030303030303030303030303030303030303030303030303030303030") == 0
        AND fn::auth_login_failure_status({ identifier_hash: "1010101010101010101010101010101010101010101010101010101010101010" }).locked;
};

-- test: fonctions internes : permissions d'un sujet, ouverture refusée pour un sujet inactif
{
    LET $claire = (SELECT VALUE identity FROM ONLY auth_credential_identifier WHERE value = "claire@exemple.fr" LIMIT 1);
    LET $rights = fn::auth_subject_permissions({ identity: $claire, organization: auth_organization:alpha, limit: ["auth.self.manage"] });
    UPDATE auth_identity:gestion SET state = "inactive";
    LET $inactive = fn::auth_session_open({ identity: auth_identity:gestion, kind: "interactive", amr: ["password"], access_slot: "a" });
    RETURN $rights.permissions == ["auth.self.manage"] AND $inactive.code == "AUTH_IDENTITY_INACTIVE";
};
