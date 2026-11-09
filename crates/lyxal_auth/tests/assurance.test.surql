-- lyxal-test: assertions
-- Niveau d'assurance : AAL calculé depuis l'AMR à l'ouverture de session, double facteur exigé
-- (AUTH_MFA_REQUIRED), réauthentification (mot de passe ou second facteur), exigence d'une
-- action (AAL, authentification récente), niveau minimal par permission, état scellé d'une
-- cérémonie passkey (lecture unique), échecs du second facteur (verrouillage, parcours échoué).
--
-- identité lea: { "id": "auth_session:lea", "pv": 1, "permissions": ["auth.self.manage", "auth.identity.read"] }
-- identité lea_ancienne: { "id": "auth_session:lea_old", "pv": 1, "permissions": ["auth.self.manage"] }

-- préparation: identités avec mot de passe, Léa avec un TOTP actif, sessions
{
    CREATE auth_identity:lea CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "lea@exemple.fr" } };
    CREATE auth_identity:hugo CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "hugo@exemple.fr" } };
    CREATE auth_credential:lea_pwd CONTENT { identity: auth_identity:lea, type: "password", secret_data: "enc:v2:cle-2026:LEALEALEALEALEALEALEA" };
    CREATE auth_credential:lea_totp CONTENT { identity: auth_identity:lea, type: "totp", secret_data: "enc:v2:cle-2026:TOTPTOTPTOTPTOTPTOTP", public_data: { last_step: 10 } };
    CREATE auth_credential:hugo_pwd CONTENT { identity: auth_identity:hugo, type: "password", secret_data: "enc:v2:cle-2026:HUGOHUGOHUGOHUGOHUGO" };
    CREATE auth_session:lea CONTENT { identity: auth_identity:lea, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_session:lea_old CONTENT { identity: auth_identity:lea, aal: 2, authenticated_at: time::now() - 2h, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_session:hugo CONTENT { identity: auth_identity:hugo, authenticated_at: time::now() - 2h, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    DEFINE TABLE test_ref SCHEMALESS PERMISSIONS FULL;
};

-- test: identité avec un second facteur : session sur le seul mot de passe refusée
RETURN fn::auth_session_create({ identity: "auth_identity:lea", amr: ["password"], access_slot: "a",
    refresh_token_hash: "e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1e1" }).error.code == "AUTH_MFA_REQUIRED";

-- test: mot de passe et TOTP : session AAL2 avec les deux méthodes
{
    LET $r = fn::auth_session_create({ identity: "auth_identity:lea", amr: ["password", "totp"], access_slot: "a",
        refresh_token_hash: "e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2" }).data;
    LET $s = (SELECT * FROM ONLY $r.session);
    CREATE test_ref:lea_s CONTENT { session: $r.session };
    RETURN $r.aal == 2 AND $s.aal == 2 AND $s.amr.method == ["password", "totp"] AND $s.authenticated_at IS NOT NONE;
};

-- test: passkey sans mot de passe (vérification de l'utilisateur) : session AAL2
RETURN fn::auth_session_create({ identity: "auth_identity:lea", amr: ["passkey"], access_slot: "a",
    refresh_token_hash: "e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3" }).data.aal == 2;

-- test: identité sans second facteur ni exigence : session AAL1 sur le mot de passe
RETURN fn::auth_session_create({ identity: "auth_identity:hugo", amr: ["password"], access_slot: "a",
    refresh_token_hash: "e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4e4" }).data.aal == 1;

-- test: changement d'organisation : AAL, méthodes et date d'authentification conservés
{
    CREATE auth_organization:beta CONTENT { slug: "beta", name: "Beta" };
    RELATE auth_identity:lea->auth_member_of->auth_organization:beta;
    LET $old = (SELECT * FROM ONLY test_ref:lea_s.session);
    LET $r = fn::auth_session_switch_organization({ session: <string> $old.id, organization: "auth_organization:beta", access_slot: "b",
        refresh_token_hash: "e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5" }).data;
    LET $new = (SELECT * FROM ONLY $r.session);
    RETURN $r.aal == 2 AND $new.authenticated_at == $old.authenticated_at AND $new.amr == $old.amr;
};

-- test: réauthentification par mot de passe refusée à une identité qui a un second facteur
RETURN fn::auth_session_reauthenticate({ session: "auth_session:lea", method: "password", access_slot: "a" }).error.code == "AUTH_MFA_REQUIRED";

-- test: réauthentification par TOTP : AAL2, date mise à jour, méthode ajoutée, événement, jeton à émettre
{
    LET $r = fn::auth_session_reauthenticate({ session: "auth_session:lea", method: "totp", access_slot: "b" });
    LET $s = (SELECT * FROM ONLY auth_session:lea);
    RETURN $r.ok AND $r.data.aal == 2 AND $r.data.refresh_expires_at IS NONE AND "auth.self.manage" IN $r.data.permissions
        AND $s.aal == 2 AND $s.access_slot == "b" AND "totp" IN $s.amr.method AND $s.authenticated_at > time::now() - 1m
        AND array::len(SELECT * FROM event_outbox WHERE event_type = "auth.session.reauthenticated") == 1;
};

-- test: réauthentification par mot de passe d'une identité sans second facteur : date mise à jour, AAL1 conservé
{
    LET $r = fn::auth_session_reauthenticate({ session: "auth_session:hugo", method: "password", access_slot: "a" });
    LET $s = (SELECT * FROM ONLY auth_session:hugo);
    RETURN $r.ok AND $r.data.aal == 1 AND $s.authenticated_at > time::now() - 1m;
};

-- test: réauthentification d'une session révoquée refusée
{
    CREATE auth_session:revoked CONTENT { identity: auth_identity:hugo, state: "revoked", idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    RETURN fn::auth_session_reauthenticate({ session: "auth_session:revoked", method: "password", access_slot: "a" }).error.code == "AUTH_SESSION_REVOKED";
};

-- test: état d'assurance : AAL la plus haute disponible et ancienneté
{
    LET $fresh = fn::auth_assurance_state({ session: auth_session:lea, min_aal: "highest_available", fresh: true });
    LET $stale = fn::auth_assurance_state({ session: auth_session:lea_old, min_aal: "highest_available", fresh: true });
    LET $aal2 = fn::auth_assurance_state({ session: auth_session:hugo, min_aal: "aal2" });
    RETURN $fresh.code IS NONE AND $fresh.aal == 2 AND $fresh.available_aal == 2
        AND $stale.code == "AUTH_REAUTHENTICATION_REQUIRED" AND $stale.details.reauthenticate_with == ["totp"]
        AND $aal2.code == "AUTH_AAL_INSUFFICIENT" AND $aal2.details.reauthenticate_with == [];
};

-- test: une session AAL1 d'une identité qui peut atteindre AAL2 doit monter en assurance
{
    CREATE auth_session:lea_aal1 CONTENT { identity: auth_identity:lea, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    LET $state = fn::auth_assurance_state({ session: auth_session:lea_aal1, min_aal: "highest_available" });
    RETURN $state.code == "AUTH_AAL_INSUFFICIENT" AND $state.details.required_aal == 2 AND $state.details.reauthenticate_with == ["totp"];
};

-- test: exigence vérifiée par la session système pour une session désignée ; sans session : accordée
RETURN fn::auth_assurance_check({ session: "auth_session:lea_old", fresh: true }).error.code == "AUTH_REAUTHENTICATION_REQUIRED"
    AND fn::auth_assurance_check({ session: "auth_session:lea", fresh: true }).data.aal == 2
    AND fn::auth_assurance_check({}).data.system;

-- test: une session vérifie sa propre exigence ; ancienne : réauthentification demandée avec ses méthodes
-- en tant que: lea_ancienne
{
    LET $r = fn::auth_assurance_check({ fresh: true });
    RETURN $r.error.code == "AUTH_REAUTHENTICATION_REQUIRED" AND $r.error.details.reauthenticate_with == ["totp"]
        AND fn::auth_assurance_check({ min_aal: "aal2" }).ok
        AND fn::auth_assurance_check({ session: "auth_session:lea" }).error.code == "AUTH_PERMISSION_DENIED";
};

-- test: le contexte porte l'AAL, les méthodes et la date d'authentification
-- en tant que: lea
{
    LET $c = fn::auth_context({}).data;
    RETURN $c.aal == 2 AND "totp" IN $c.amr AND $c.authenticated_at IS NOT NONE;
};

-- test: niveau minimal d'une permission : déclaré, puis modifié
{
    LET $r = fn::auth_permission_register({ code: "test.sensible", module: "lyxal_test", scope: "installation", min_aal: 2 });
    LET $u = fn::auth_permission_update({ code: "auth.identity.read", min_aal: 2 });
    RETURN $r.data.min_aal == 2 AND $u.data.min_aal == 2 AND $u.data.description.fr IS NOT NONE;
};

-- test: permission d'AAL2 accordée à une session AAL2
-- en tant que: lea
RETURN fn::auth_has_permission({ permission: "auth.identity.read" });

-- test: permission d'AAL2 refusée à une session AAL1, même si le jeton la porte
{
    UPDATE auth_session:lea SET aal = 1;
    RETURN (SELECT VALUE aal FROM ONLY auth_session:lea) == 1;
};

-- test: (suite) la permission AAL2 n'est plus accordée
-- en tant que: lea
RETURN !fn::auth_has_permission({ permission: "auth.identity.read" }) AND fn::auth_has_permission({ permission: "auth.self.manage" });

-- test: création d'une clé d'API : action sensible refusée sur une session ancienne
-- en tant que: lea_ancienne
RETURN fn::auth_api_key_create({ name: "outil", key_hash: "f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1", prefix: "lyxk_abc", permissions: ["auth.self.manage"] }).error.code == "AUTH_REAUTHENTICATION_REQUIRED";

-- test: état scellé d'une cérémonie : enregistré, lu une seule fois
{
    LET $flow = fn::auth_flow_start({ type: "passkey_login" }).data;
    LET $saved = fn::auth_flow_state_save({ flow: <string> $flow.id, secret_state: "enc:v2:cle-2026:ETATETATETATETATETAT" });
    LET $taken = fn::auth_flow_state_take({ flow: <string> $flow.id });
    LET $again = fn::auth_flow_state_take({ flow: <string> $flow.id });
    RETURN $flow.state == "started" AND $saved.ok AND $taken.data.secret_state == "enc:v2:cle-2026:ETATETATETATETATETAT" AND $taken.data.type == "passkey_login"
        AND $again.error.code == "AUTH_FLOW_INVALID_STATE";
};

-- test: l'état scellé n'est pas lisible, et les fonctions de cérémonie sont réservées à la session système
-- en tant que: lea
RETURN fn::auth_flow_state_save({ flow: "auth_flow:x", secret_state: "enc:v2:cle-2026:ETATETATETATETATETAT" }).error.code == "AUTH_PERMISSION_DENIED"
    AND fn::auth_flow_state_take({ flow: "auth_flow:x" }).error.code == "AUTH_PERMISSION_DENIED";

-- test: échecs du second facteur : parcours échoué après mfa.max_attempts essais
{
    LET $flow = fn::auth_flow_start({ type: "login", state: "mfa_required", identity: "auth_identity:lea", methods: ["totp"] }).data;
    LET $hash = "9a9a9a9a9a9a9a9a9a9a9a9a9a9a9a9a9a9a9a9a9a9a9a9a9a9a9a9a9a9a9a9a";
    LET $results = array::map(<array>(0..5), |$i| fn::auth_mfa_failure_record({ identity_hash: $hash, identity: "auth_identity:lea", flow: <string> $flow.id, method: "totp" }).data);
    RETURN !$results[3].flow_failed AND $results[4].flow_failed AND (SELECT VALUE state FROM ONLY $flow.id) == "failed"
        AND array::len(SELECT * FROM event_outbox WHERE event_type = "auth.mfa.failed") == 5;
};

-- test: verrouillage du second facteur au seuil de lockout.max_failures, puis remise à zéro
{
    LET $hash = "9a9a9a9a9a9a9a9a9a9a9a9a9a9a9a9a9a9a9a9a9a9a9a9a9a9a9a9a9a9a9a9a";
    LET $more = array::map(<array>(0..5), |$i| fn::auth_mfa_failure_record({ identity_hash: $hash, identity: "auth_identity:lea", method: "recovery_code" }).data);
    LET $locked = fn::auth_mfa_failure_check({ identity_hash: $hash }).data;
    LET $reset = fn::auth_mfa_failure_reset({ identity_hash: $hash });
    RETURN $more[4].locked AND $locked.locked AND $reset.ok AND !fn::auth_mfa_failure_check({ identity_hash: $hash }).data.locked;
};

-- test: parcours de connexion à l'état mfa_required avec les méthodes admises
{
    LET $flow = fn::auth_flow_start({ type: "login", state: "mfa_required", identity: "auth_identity:lea", methods: ["totp", "recovery_code"] }).data;
    LET $done = fn::auth_flow_submit({ flow: <string> $flow.id, from: ["mfa_required"], state: "completed" });
    RETURN $flow.methods == ["totp", "recovery_code"] AND $done.data.state == "completed"
        AND fn::auth_flow_states({ type: "reauthentication" }) == ["started", "completed", "failed"];
};

-- test: politique du double facteur enregistrée avec ses nouveaux réglages ; valeurs hors bornes refusées
RETURN fn::auth_policy_save({ mfa: { required: false, max_attempts: 4, privileged_max_age_seconds: 600, required_roles: ["platform_admin"] } }).data.mfa.max_attempts == 4
    AND fn::auth_policy_save({ mfa: { max_attempts: 50 } }).error.code == "AUTH_INVALID_PARAMETERS"
    AND fn::auth_policy_value({ theme: "mfa", key: "privileged_max_age_seconds", default: 0 }) == 600;

-- test: méthode désactivée par la politique : ni session, ni réauthentification
{
    fn::auth_policy_save({ mfa: { methods: ["passkey", "recovery_code"] } });
    LET $opened = fn::auth_session_create({ identity: "auth_identity:lea", amr: ["password", "totp"], access_slot: "a",
        refresh_token_hash: "e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6e6" });
    LET $reauth = fn::auth_session_reauthenticate({ session: "auth_session:lea", method: "totp", access_slot: "a" });
    fn::auth_policy_save({ mfa: { methods: ["totp", "passkey", "recovery_code"] } });
    RETURN $opened.error.code == "AUTH_MFA_METHOD_DISABLED" AND $reauth.error.code == "AUTH_MFA_METHOD_DISABLED"
        AND fn::auth_session_reauthenticate({ session: "auth_session:lea", method: "totp", access_slot: "a" }).ok;
};
