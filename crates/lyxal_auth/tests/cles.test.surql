-- lyxal-test: assertions
-- Clés de signature et purge : première clé, rotation dans l'emplacement inactif, garde de
-- réutilisation (seconde rotation trop tôt refusée, forçage possible), clé de condensation créée
-- une fois ; purge des éléments expirés.
--
-- identité claire: { "id": "auth_session:claire", "pv": 1, "permissions": ["auth.self.manage"] }

-- préparation: identité et session
{
    CREATE auth_identity:claire CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "claire@exemple.fr" } };
    CREATE auth_session:claire CONTENT { identity: auth_identity:claire, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
};

-- test: aucune clé active au départ
RETURN fn::auth_signing_key_get_active({ purpose: "access_token" }).error.code == "AUTH_SIGNING_KEY_UNAVAILABLE";

-- test: première clé dans l'emplacement a
RETURN fn::auth_signing_key_rotate({ purpose: "access_token", secret: "enc:v2:k:AAAAAAAAAAAAAAAAAAAAAAAA" }).data == { slot: "a", created: true }
    AND fn::auth_signing_key_get_active({ purpose: "access_token" }).data.active.{ slot, secret } == { slot: "a", secret: "enc:v2:k:AAAAAAAAAAAAAAAAAAAAAAAA" };

-- test: rotation : nouvelle clé dans l'emplacement b, l'ancienne reste vérifiable (previous)
{
    LET $r = fn::auth_signing_key_rotate({ purpose: "access_token", secret: "enc:v2:k:BBBBBBBBBBBBBBBBBBBBBBBB" }).data;
    LET $keys = fn::auth_signing_key_get_active({ purpose: "access_token" }).data;
    RETURN $r.slot == "b" AND $r.previous_reusable_after > time::now() + 900s
        AND $keys.active.slot == "b" AND $keys.previous.slot == "a";
};

-- test: seconde rotation trop tôt refusée (l'emplacement a vérifie encore des jetons valides)
RETURN fn::auth_signing_key_rotate({ purpose: "access_token", secret: "enc:v2:k:CCCCCCCCCCCCCCCCCCCCCCCC" }).error.code == "AUTH_SIGNING_KEY_ROTATION_TOO_SOON"
    AND fn::auth_signing_key_get_active({ purpose: "access_token" }).data.active.slot == "b";

-- test: rotation forcée (clé compromise) : emplacement a écrasé
RETURN fn::auth_signing_key_rotate({ purpose: "access_token", secret: "enc:v2:k:DDDDDDDDDDDDDDDDDDDDDDDD", force: true }).data.slot == "a"
    AND fn::auth_signing_key_get_active({ purpose: "access_token" }).data.active.secret == "enc:v2:k:DDDDDDDDDDDDDDDDDDDDDDDD";

-- test: clé de condensation des codes créée une seule fois
RETURN fn::auth_signing_key_rotate({ purpose: "code_pepper", secret: "enc:v2:k:EEEEEEEEEEEEEEEEEEEEEEEE" }).data.created
    AND !fn::auth_signing_key_rotate({ purpose: "code_pepper", secret: "enc:v2:k:FFFFFFFFFFFFFFFFFFFFFFFF" }).data.created
    AND fn::auth_signing_key_get_active({ purpose: "code_pepper" }).data.active.secret == "enc:v2:k:EEEEEEEEEEEEEEEEEEEEEEEE";

-- test: clés réservées à la session système
-- en tant que: claire
RETURN fn::auth_signing_key_get_active({ purpose: "access_token" }).error.code == "AUTH_PERMISSION_DENIED"
    AND fn::auth_purge({}).error.code == "AUTH_PERMISSION_DENIED"
    AND array::len(SELECT * FROM auth_signing_key) == 0;

-- préparation: éléments expirés à purger
{
    CREATE auth_session:vieille CONTENT { identity: auth_identity:claire, idle_expires_at: time::now() - 1h, expires_at: time::now() - 1s };
    CREATE auth_session:ancienne CONTENT { identity: auth_identity:claire, state: "revoked", revoked_at: time::now() - 60d, idle_expires_at: time::now() - 60d, expires_at: time::now() - 59d };
    LET $flow = fn::auth_flow_start({ type: "recovery", address: "claire@exemple.fr" }).data.id;
    UPDATE $flow SET expires_at = time::now() - 1s;
    CREATE auth_refresh_token CONTENT { session: auth_session:claire, token_hash: "abababababababababababababababababababababababababababababababab", expires_at: time::now() - 1s };
    CREATE auth_login_failure CONTENT { kind: "ip", key_hash: "cdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcd", failures: 3 };
    CREATE auth_organization:alpha CONTENT { slug: "alpha", name: "Alpha" };
    CREATE auth_organization_invitation CONTENT {
        organization: auth_organization:alpha, email: "x@exemple.fr", roles: [], token_hash: "efefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefef", expires_at: time::now() - 1s,
        delivery: { event_id: "01a1bca0-0000-7000-8000-0000000000ef", secret: "enc:v2:k:AAAAAAAAAAAAAAAAAAAAAAAA" }
    };
};

-- test: purge : session expirée marquée, session terminée ancienne supprimée, parcours et jeton expirés supprimés
{
    LET $r = fn::auth_purge({ limit: 100 }).data;
    RETURN $r.sessions_expired == 1 AND $r.sessions == 1 AND $r.flows == 1 AND $r.refresh_tokens == 1 AND $r.invitations_expired == 1
        AND (SELECT VALUE state FROM ONLY auth_session:vieille) == "expired"
        AND !record::exists(auth_session:ancienne)
        AND (SELECT VALUE state FROM ONLY auth_session:claire) == "active";
};
