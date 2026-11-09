-- lyxal-test: assertions
-- Seconds facteurs : TOTP (enrôlement, confirmation, anti-rejeu), codes de secours (génération,
-- usage unique), passkeys (enregistrement, recherche, mise à jour, nom), liste des facteurs,
-- retrait (dernier facteur protégé), remise à zéro par un administrateur, niveau atteignable,
-- actions sensibles (authentification récente), alertes publiées avec le destinataire.
--
-- identité marie: { "id": "auth_session:marie", "pv": 1, "permissions": ["auth.self.manage"] }
-- identité paul: { "id": "auth_session:paul", "pv": 1, "permissions": ["auth.self.manage"] }

-- préparation: organisation exigeant le double facteur, identités avec mot de passe, sessions
{
    CREATE auth_organization:alpha CONTENT { slug: "alpha", name: "Alpha BTP", mfa_required: false };
    CREATE auth_identity:marie CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "marie@exemple.fr", name: { first: "Marie" } } };
    CREATE auth_identity:paul CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "paul@exemple.fr" } };
    CREATE auth_identity:admin CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "admin@exemple.fr" } };
    RELATE auth_identity:marie->auth_member_of->auth_organization:alpha;
    LET $admin = auth_identity:admin;
    RELATE $admin->auth_has_role->auth_role:platform_admin;
    CREATE auth_credential:marie_pwd CONTENT { identity: auth_identity:marie, type: "password", secret_data: "enc:v2:cle-2026:MARIEMARIEMARIEMARIE" };
    CREATE auth_credential:paul_pwd CONTENT { identity: auth_identity:paul, type: "password", secret_data: "enc:v2:cle-2026:PAULPAULPAULPAULPAUL" };
    CREATE auth_credential:admin_pwd CONTENT { identity: auth_identity:admin, type: "password", secret_data: "enc:v2:cle-2026:ADMINADMINADMINADMIN" };
    CREATE auth_session:marie CONTENT { identity: auth_identity:marie, organization: auth_organization:alpha, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_session:marie_old CONTENT { identity: auth_identity:marie, organization: auth_organization:alpha, authenticated_at: time::now() - 2h, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_session:paul CONTENT { identity: auth_identity:paul, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_session:admin CONTENT { identity: auth_identity:admin, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    DEFINE TABLE test_ref SCHEMALESS PERMISSIONS FULL;
};

-- test: niveau atteignable recalculé : 1 avec un mot de passe seul
RETURN (SELECT VALUE available_aal FROM ONLY auth_identity:marie) == 1 AND (SELECT VALUE available_aal FROM ONLY auth_identity:paul) == 1;

-- test: double facteur exigé : par rôle (platform_admin), par organisation, sinon non
{
    LET $before = fn::auth_mfa_required({ identity: auth_identity:marie, organization: auth_organization:alpha });
    UPDATE auth_organization:alpha SET mfa_required = true;
    LET $after = fn::auth_mfa_required({ identity: auth_identity:marie, organization: auth_organization:alpha });
    RETURN !$before AND $after AND fn::auth_mfa_required({ identity: auth_identity:admin })
        AND !fn::auth_mfa_required({ identity: auth_identity:marie }) AND !fn::auth_mfa_required({});
};

-- test: exigences de connexion : configure_mfa calculée dans l'organisation exigeante, absente sinon
{
    LET $in_alpha = fn::auth_login_requirements({ identity: "auth_identity:marie", organization: "auth_organization:alpha" }).data;
    LET $alone = fn::auth_login_requirements({ identity: "auth_identity:marie" }).data;
    RETURN $in_alpha.required_actions == ["configure_mfa"] AND $in_alpha.mfa_required AND $in_alpha.available_aal == 1 AND $in_alpha.methods == []
        AND $alone.required_actions == [] AND !$alone.mfa_required;
};

-- test: exigences de connexion réservées à la session système
-- en tant que: marie
RETURN fn::auth_login_requirements({ identity: "auth_identity:marie" }).error.code == "AUTH_PERMISSION_DENIED";

-- test: acteur : session interactive, session absente refusée, action sensible sur une session ancienne refusée
{
    LET $ok = fn::auth_mfa_actor({ session: auth_session:marie, sensitive: true });
    LET $stale = fn::auth_mfa_actor({ session: auth_session:marie_old, sensitive: true });
    RETURN $ok.code IS NONE AND $ok.identity == auth_identity:marie AND $ok.organization == auth_organization:alpha
        AND $stale.code == "AUTH_REAUTHENTICATION_REQUIRED" AND $stale.details.reauthenticate_with == ["password"]
        AND fn::auth_mfa_actor({}).code == "AUTH_SESSION_REQUIRED";
};

-- test: enrôlement TOTP sur une session ancienne refusé (authentification récente exigée)
RETURN fn::auth_mfa_totp_begin({ session: "auth_session:marie_old", credential: "auth_credential:marie_totp", secret: "enc:v2:cle-2026:TOTPTOTPTOTPTOTPTOTP" }).error.code == "AUTH_REAUTHENTICATION_REQUIRED";

-- test: enrôlement TOTP en attente : niveau atteignable inchangé, compte renvoyé pour l'URI
{
    LET $r = fn::auth_mfa_totp_begin({ session: "auth_session:marie", credential: "auth_credential:marie_totp", secret: "enc:v2:cle-2026:TOTPTOTPTOTPTOTPTOTP" });
    LET $c = (SELECT * FROM ONLY auth_credential:marie_totp);
    RETURN $r.ok AND $r.data.account == "marie@exemple.fr" AND $c.state == "pending" AND $c.public_data.digits == 6
        AND (SELECT VALUE available_aal FROM ONLY auth_identity:marie) == 1;
};

-- test: secret scellé en attente lisible par l'hôte ; aucun TOTP actif
{
    LET $pending = fn::auth_mfa_totp_secret_get({ identity: "auth_identity:marie", state: "pending" });
    RETURN $pending.ok AND $pending.data.secret == "enc:v2:cle-2026:TOTPTOTPTOTPTOTPTOTP"
        AND fn::auth_mfa_totp_secret_get({ identity: "auth_identity:marie" }).error.code == "AUTH_MFA_NOT_ENROLLED";
};

-- test: le secret TOTP n'est pas lisible par son titulaire
-- en tant que: marie
RETURN (SELECT VALUE secret_data FROM ONLY auth_credential:marie_totp) IS NONE;

-- test: activation : TOTP actif, niveau 2, session en AAL2, configure_mfa levée, alerte avec destinataire
{
    CREATE auth_required_action CONTENT { identity: auth_identity:marie, action: "configure_mfa" };
    LET $r = fn::auth_mfa_totp_activate({ session: "auth_session:marie", credential: "auth_credential:marie_totp", step: 100 });
    LET $e = (SELECT * FROM ONLY event_outbox WHERE event_type = "auth.mfa.enrolled" LIMIT 1);
    RETURN $r.ok AND $r.data.recovery_codes == 0
        AND (SELECT VALUE state FROM ONLY auth_credential:marie_totp) == "active"
        AND (SELECT VALUE available_aal FROM ONLY auth_identity:marie) == 2
        AND (SELECT VALUE aal FROM ONLY auth_session:marie) == 2
        AND array::len(SELECT * FROM auth_required_action WHERE identity = auth_identity:marie) == 0
        AND $e.payload.method == "totp" AND $e.payload.recipient_email == "marie@exemple.fr" AND $e.payload.recipient_name == "Marie";
};

-- test: second enrôlement refusé ; activation sans TOTP en attente refusée
RETURN fn::auth_mfa_totp_begin({ session: "auth_session:marie", credential: "auth_credential:marie_totp2", secret: "enc:v2:cle-2026:TOTPTOTPTOTPTOTPTOTP" }).error.code == "AUTH_MFA_ALREADY_ENROLLED"
    AND fn::auth_mfa_totp_activate({ session: "auth_session:marie", credential: "auth_credential:marie_totp", step: 101 }).error.code == "AUTH_MFA_NOT_ENROLLED";

-- test: anti-rejeu : un pas déjà utilisé ou antérieur est refusé, un pas suivant accepté
RETURN fn::auth_mfa_totp_step_use({ credential: "auth_credential:marie_totp", step: 100 }).error.code == "AUTH_MFA_INVALID"
    AND fn::auth_mfa_totp_step_use({ credential: "auth_credential:marie_totp", step: 99 }).error.code == "AUTH_MFA_INVALID"
    AND fn::auth_mfa_totp_step_use({ credential: "auth_credential:marie_totp", step: 101 }).ok
    AND (SELECT VALUE public_data.last_step FROM ONLY auth_credential:marie_totp) == 101;

-- test: codes de secours : nombre et doublons contrôlés
RETURN fn::auth_mfa_recovery_codes_replace({ session: "auth_session:marie", batch: "0193aaaa00007000800000000000aaaa",
        code_hashes: ["a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1"] }).error.code == "AUTH_INVALID_PARAMETERS"
    AND fn::auth_mfa_recovery_codes_replace({ session: "auth_session:marie", batch: "0193aaaa00007000800000000000aaaa",
        code_hashes: array::map(<array>(0..5), |$i| "a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1") }).error.code == "AUTH_INVALID_PARAMETERS";

-- test: codes de secours générés (10), alerte publiée ; une identité sans second facteur refusée
{
    LET $hashes = array::map(<array>(0..10), |$i| string::concat(string::repeat("ab", 31), "0", <string> $i));
    LET $r = fn::auth_mfa_recovery_codes_replace({ session: "auth_session:marie", batch: "0193aaaa00007000800000000000aaaa", code_hashes: $hashes });
    CREATE test_ref:codes CONTENT { hashes: $hashes };
    RETURN $r.ok AND $r.data.count == 10
        AND array::len(SELECT * FROM auth_recovery_code WHERE identity = auth_identity:marie) == 10
        AND array::len(SELECT * FROM event_outbox WHERE event_type = "auth.mfa.recovery_codes_generated") == 1
        AND fn::auth_mfa_recovery_codes_replace({ session: "auth_session:paul", batch: "0193aaaa00007000800000000000bbbb", code_hashes: $hashes }).error.code == "AUTH_MFA_NOT_ENROLLED";
};

-- test: les empreintes des codes ne sont pas lisibles par leur titulaire
-- en tant que: marie
RETURN array::len(SELECT * FROM auth_recovery_code) == 10 AND array::all((SELECT VALUE code_hash FROM auth_recovery_code), |$h| $h IS NONE);

-- test: code de secours à usage unique, codes restants et alerte publiés
{
    LET $hash = test_ref:codes.hashes[0];
    LET $first = fn::auth_mfa_recovery_code_use({ identity: "auth_identity:marie", code_hash: $hash });
    LET $again = fn::auth_mfa_recovery_code_use({ identity: "auth_identity:marie", code_hash: $hash });
    LET $other = fn::auth_mfa_recovery_code_use({ identity: "auth_identity:paul", code_hash: test_ref:codes.hashes[1] });
    LET $e = (SELECT * FROM ONLY event_outbox WHERE event_type = "auth.mfa.recovery_code_used" LIMIT 1);
    RETURN $first.ok AND $first.data.remaining == 9 AND $again.error.code == "AUTH_MFA_INVALID" AND $other.error.code == "AUTH_MFA_INVALID"
        AND $e.payload.remaining == 9 AND !$e.payload.low;
};

-- test: seconds facteurs utilisables : totp et codes de secours
RETURN fn::auth_mfa_methods({ identity: auth_identity:marie }) == ["totp", "recovery_code"] AND fn::auth_mfa_methods({ identity: auth_identity:paul }) == [];

-- test: passkey enregistrée ; même clé refusée ensuite (y compris pour une autre identité)
{
    LET $r = fn::auth_mfa_passkey_save({ session: "auth_session:marie", credential_id: "Y3JlZGVudGlhbC1tYXJpZS0x", label: "Ordinateur", public_data: { cred: { counter: 0 }, backup_eligible: true, backup_state: true } });
    CREATE test_ref:passkey CONTENT { credential: $r.data.credential };
    RETURN $r.ok AND $r.data.label == "Ordinateur"
        AND fn::auth_mfa_passkey_save({ session: "auth_session:paul", credential_id: "Y3JlZGVudGlhbC1tYXJpZS0x", public_data: {} }).error.code == "AUTH_PASSKEY_TAKEN";
};

-- test: passkey retrouvée par son identifiant WebAuthn ; inconnue refusée ; liste de l'identité
{
    LET $found = fn::auth_mfa_passkey_find({ credential_id: "Y3JlZGVudGlhbC1tYXJpZS0x" }).data;
    LET $list = fn::auth_mfa_passkey_list_for({ identity: "auth_identity:marie" }).data;
    RETURN $found.identity == auth_identity:marie AND $found.identity_state == "active" AND $found.public_data.backup_eligible
        AND fn::auth_mfa_passkey_find({ credential_id: "aW5jb25udWUtaW5jb25udWU" }).error.code == "AUTH_PASSKEY_INVALID"
        AND array::len($list) == 1 AND $list[0].credential_id == "Y3JlZGVudGlhbC1tYXJpZS0x";
};

-- test: passkey mise à jour après authentification (compteur), puis renommée par sa titulaire
{
    LET $credential = test_ref:passkey.credential;
    LET $updated = fn::auth_mfa_passkey_update({ credential: <string> $credential, public_data: { cred: { counter: 4 }, backup_eligible: true, backup_state: false } });
    LET $renamed = fn::auth_mfa_passkey_rename({ session: "auth_session:marie", credential: <string> $credential, label: "Téléphone" });
    LET $foreign = fn::auth_mfa_passkey_rename({ session: "auth_session:paul", credential: <string> $credential, label: "Vol" });
    LET $c = (SELECT * FROM ONLY $credential);
    RETURN $updated.ok AND $renamed.ok AND $foreign.error.code == "AUTH_PASSKEY_INVALID"
        AND $c.public_data.cred.counter == 4 AND $c.label == "Téléphone" AND $c.last_used_at IS NOT NONE;
};

-- test: liste des facteurs par l'hôte (session) : totp, passkey, codes restants, sans secret
{
    LET $f = fn::auth_mfa_factor_list({ session: "auth_session:marie" }).data;
    RETURN $f.totp.state == "active" AND array::len($f.passkeys) == 1 AND $f.passkeys[0].label == "Téléphone"
        AND $f.recovery_codes == { total: 10, remaining: 9, created_at: $f.recovery_codes.created_at } AND $f.available_aal == 2
        AND $f.totp.secret_data IS NONE;
};

-- test: liste de ses facteurs par la titulaire ; ceux d'un autre refusés sans auth.identity.read
-- en tant que: marie
{
    LET $own = fn::auth_mfa_factor_list({});
    RETURN $own.ok AND array::len($own.data.passkeys) == 1
        AND fn::auth_mfa_factor_list({ identity: "auth_identity:paul" }).error.code == "AUTH_PERMISSION_DENIED";
};

-- test: fonctions d'enrôlement réservées à la session système
-- en tant que: marie
RETURN fn::auth_mfa_totp_begin({ session: "auth_session:marie", credential: "auth_credential:x", secret: "enc:v2:cle-2026:TOTPTOTPTOTPTOTPTOTP" }).error.code == "AUTH_PERMISSION_DENIED"
    AND fn::auth_mfa_recovery_code_use({ identity: "auth_identity:marie", code_hash: "a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1" }).error.code == "AUTH_PERMISSION_DENIED"
    AND fn::auth_mfa_passkey_find({ credential_id: "Y3JlZGVudGlhbC1tYXJpZS0x" }).error.code == "AUTH_PERMISSION_DENIED";

-- test: retrait du TOTP par sa titulaire : la passkey reste, niveau 2 conservé, alerte publiée
{
    LET $r = fn::auth_mfa_factor_remove({ session: "auth_session:marie", method: "totp" });
    LET $e = (SELECT * FROM ONLY event_outbox WHERE event_type = "auth.mfa.removed" LIMIT 1);
    RETURN $r.ok AND $r.data.available_aal == 2 AND !record::exists(auth_credential:marie_totp)
        AND $e.payload.method == "totp" AND $e.payload.reason == "owner";
};

-- test: dernier facteur protégé quand l'organisation exige le double facteur
RETURN fn::auth_mfa_factor_remove({ session: "auth_session:marie", method: "passkey", credential: <string> test_ref:passkey.credential }).error.code == "AUTH_MFA_LAST_FACTOR";

-- test: dernier facteur retiré quand rien ne l'exige : niveau 1, codes de secours supprimés
{
    UPDATE auth_organization:alpha SET mfa_required = false;
    LET $r = fn::auth_mfa_factor_remove({ session: "auth_session:marie", method: "passkey", credential: <string> test_ref:passkey.credential });
    RETURN $r.ok AND $r.data.available_aal == 1 AND array::len(SELECT * FROM auth_recovery_code WHERE identity = auth_identity:marie) == 0
        AND fn::auth_mfa_factor_remove({ session: "auth_session:marie", method: "totp" }).error.code == "AUTH_MFA_NOT_ENROLLED";
};

-- test: effets d'un enrôlement depuis un parcours de connexion : méthode retenue par le parcours
{
    LET $flow = fn::auth_flow_start({ type: "login", state: "action_required", identity: "auth_identity:paul", required_actions: ["configure_mfa"] }).data;
    CREATE auth_required_action CONTENT { identity: auth_identity:paul, action: "configure_mfa" };
    LET $actor = fn::auth_mfa_actor({ flow: $flow.id });
    fn::auth_mfa_enrolled({ actor: $actor, method: "totp", label: NONE });
    CREATE test_ref:paul_flow CONTENT { flow: $flow.id };
    RETURN $actor.code IS NONE AND $actor.identity == auth_identity:paul AND $actor.flow == $flow.id
        AND (SELECT VALUE methods FROM ONLY $flow.id) == ["totp"]
        AND array::len(SELECT * FROM auth_required_action WHERE identity = auth_identity:paul) == 0;
};

-- test: alerte de sécurité publiée directement avec le destinataire
{
    LET $ok = fn::auth_mfa_publish({ event_type: "auth.mfa.removed", identity: auth_identity:paul, data: { method: "all", reason: "test" } });
    LET $e = (SELECT * FROM ONLY event_outbox WHERE event_type = "auth.mfa.removed" AND payload.reason = "test" LIMIT 1);
    RETURN $ok AND $e.payload.recipient_email == "paul@exemple.fr" AND $e.payload.identity_id == "auth_identity:paul";
};

-- test: remise à zéro par un administrateur : facteurs et codes supprimés, sessions révoquées
{
    fn::auth_mfa_passkey_save({ session: "auth_session:marie", credential_id: "Y3JlZGVudGlhbC1tYXJpZS0y", public_data: {} });
    LET $r = fn::auth_mfa_reset({ session: "auth_session:admin", identity: "auth_identity:marie" });
    RETURN $r.ok AND $r.data.removed == 1 AND $r.data.sessions_revoked == 2
        AND (SELECT VALUE state FROM ONLY auth_session:marie) == "revoked"
        AND array::len(SELECT * FROM auth_credential WHERE identity = auth_identity:marie AND type = "passkey") == 0;
};

-- test: remise à zéro refusée sans droit d'administration, et sur soi-même
RETURN fn::auth_mfa_reset({ session: "auth_session:paul", identity: "auth_identity:admin" }).error.code == "AUTH_PERMISSION_DENIED"
    AND fn::auth_mfa_reset({ session: "auth_session:admin", identity: "auth_identity:admin" }).error.code == "AUTH_PERMISSION_DENIED";
