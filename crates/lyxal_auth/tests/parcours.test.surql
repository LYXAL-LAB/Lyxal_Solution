-- lyxal-test: assertions
-- Parcours et codes : démarrage, transitions conditionnelles, codes (tentatives, expiration,
-- usage unique, lien), publication du secret scellé jamais conservé, inscription par invitation
-- et par lien d'installation, premier administrateur unique, vérification et changement
-- d'adresse, rattachement par domaine.

-- préparation: organisation avec domaine vérifié à rattachement automatique, invitation
{
    CREATE auth_organization:alpha CONTENT { slug: "alpha", name: "Alpha BTP" };
    CREATE auth_organization_domain:alpha_dom CONTENT { organization: auth_organization:alpha, domain: "alpha-btp.fr", challenge_hash: "0000000000000000000000000000000000000000000000000000000000000000", state: "verified", auto_join: true, verified_at: time::now() };
    CREATE auth_organization_invitation:inv CONTENT {
        organization: auth_organization:alpha, email: "claire@exemple.fr", roles: [],
        token_hash: "1111111111111111111111111111111111111111111111111111111111111111", expires_at: time::now() + 7d,
        delivery: { event_id: "01a1bca0-0000-7000-8000-0000000000aa", secret: "enc:v2:cle-2026:AAAAAAAAAAAAAAAAAAAAAAAA" }
    };
};

-- test: états admis par type de parcours
RETURN fn::auth_flow_states({ type: "recovery" }) == ["code_sent", "code_verified", "completed", "failed"]
    AND fn::auth_flow_states({ type: "inconnu" }) == [];

-- test: réglage de la politique avec défaut
RETURN fn::auth_policy_value({ theme: "code", key: "max_attempts", default: 1 }) == 5
    AND fn::auth_policy_value({ theme: "absent", key: "x", default: 7 }) == 7;

-- test: parcours de récupération démarré à l'état code_sent, adresse normalisée
RETURN fn::auth_flow_start({ type: "recovery", address: "Claire@Exemple.FR", client: { ip: "203.0.113.7", user_agent: "test" } }).data.{ type, state, address }
    == { type: "recovery", state: "code_sent", address: "claire@exemple.fr" };

-- test: code émis : événement auth.recovery.requested avec le secret scellé et l'event_id fourni
{
    LET $flow = (SELECT VALUE id FROM ONLY auth_flow WHERE type = "recovery" LIMIT 1);
    LET $r = fn::auth_code_issue({
        flow: <string> $flow, purpose: "recovery", address: "claire@exemple.fr",
        code_hash: "2222222222222222222222222222222222222222222222222222222222222222",
        link_hash: "3333333333333333333333333333333333333333333333333333333333333333",
        event_id: "01a1bca0-0000-7000-8000-000000000101", secret: "enc:v2:cle-2026:BBBBBBBBBBBBBBBBBBBBBBBB", locale: "fr"
    });
    LET $e = (SELECT * FROM ONLY event_outbox WHERE event_type = "auth.recovery.requested" LIMIT 1);
    RETURN $r.ok AND <string> $e.event_id == "01a1bca0-0000-7000-8000-000000000101"
        AND $e.payload.{ recipient_email, recipient_locale, secret, tenant } == { recipient_email: "claire@exemple.fr", recipient_locale: "fr", secret: "enc:v2:cle-2026:BBBBBBBBBBBBBBBBBBBBBBBB", tenant: NONE };
};

-- test: le secret n'est conservé nulle part
RETURN (SELECT VALUE delivery FROM ONLY auth_one_time_code LIMIT 1) IS NONE;

-- test: code faux : tentative comptée ; flux et code inconnus refusés
{
    LET $flow = (SELECT VALUE id FROM ONLY auth_flow WHERE type = "recovery" LIMIT 1);
    LET $bad = fn::auth_code_verify({ flow: <string> $flow, purpose: "recovery", code_hash: "4444444444444444444444444444444444444444444444444444444444444444" });
    RETURN $bad.error.code == "AUTH_CODE_INVALID" AND $bad.error.details.attempts_left == 4
        AND fn::auth_code_verify({ purpose: "recovery", link_hash: "5555555555555555555555555555555555555555555555555555555555555555" }).error.code == "AUTH_CODE_INVALID"
        AND fn::auth_code_verify({ purpose: "recovery", code_hash: "2222222222222222222222222222222222222222222222222222222222222222" }).error.code == "AUTH_INVALID_PARAMETERS";
};

-- test: bon code accepté une seule fois
{
    LET $flow = (SELECT VALUE id FROM ONLY auth_flow WHERE type = "recovery" LIMIT 1);
    LET $ok = fn::auth_code_verify({ flow: <string> $flow, purpose: "recovery", code_hash: "2222222222222222222222222222222222222222222222222222222222222222" });
    LET $again = fn::auth_code_verify({ flow: <string> $flow, purpose: "recovery", code_hash: "2222222222222222222222222222222222222222222222222222222222222222" });
    RETURN $ok.data.{ type, address, purpose } == { type: "recovery", address: "claire@exemple.fr", purpose: "recovery" }
        AND $again.error.code == "AUTH_CODE_INVALID";
};

-- test: transition conditionnelle : code_sent → code_verified une seule fois ; transition interdite refusée
{
    LET $flow = (SELECT VALUE id FROM ONLY auth_flow WHERE type = "recovery" LIMIT 1);
    LET $first = fn::auth_flow_submit({ flow: <string> $flow, from: ["code_sent"], state: "code_verified" });
    LET $second = fn::auth_flow_submit({ flow: <string> $flow, from: ["code_sent"], state: "code_verified" });
    LET $invalid = fn::auth_flow_submit({ flow: <string> $flow, from: ["code_verified"], state: "action_required" });
    RETURN $first.data.state == "code_verified" AND $second.error.code == "AUTH_FLOW_INVALID_STATE" AND $invalid.error.code == "AUTH_FLOW_INVALID_STATE";
};

-- test: parcours terminé, puis inutilisable
{
    LET $flow = (SELECT VALUE id FROM ONLY auth_flow WHERE type = "recovery" LIMIT 1);
    fn::auth_flow_submit({ flow: <string> $flow, from: ["code_verified"], state: "completed" });
    RETURN fn::auth_flow_get({ flow: <string> $flow }).error.code == "AUTH_FLOW_INVALID_STATE"
        AND fn::auth_flow_get({ flow: "auth_flow:inconnu" }).error.code == "AUTH_FLOW_NOT_FOUND"
        AND fn::auth_flow_load({ flow: $flow }).code == "AUTH_FLOW_INVALID_STATE";
};

-- test: code épuisé (tentatives) puis code expiré
{
    LET $flow = fn::auth_flow_start({ type: "verification", address: "x@exemple.fr" }).data.id;
    fn::auth_code_issue({ flow: <string> $flow, purpose: "verification", address: "x@exemple.fr", code_hash: "6666666666666666666666666666666666666666666666666666666666666666", link_hash: "7777777777777777777777777777777777777777777777777777777777777777" });
    FOR $i IN [1, 2, 3, 4, 5] { fn::auth_code_verify({ flow: <string> $flow, purpose: "verification", code_hash: "8888888888888888888888888888888888888888888888888888888888888888" }); };
    LET $blocked = fn::auth_code_verify({ flow: <string> $flow, purpose: "verification", code_hash: "6666666666666666666666666666666666666666666666666666666666666666" });
    fn::auth_code_issue({ flow: <string> $flow, purpose: "verification", address: "x@exemple.fr", code_hash: "6666666666666666666666666666666666666666666666666666666666666666", link_hash: "9999999999999999999999999999999999999999999999999999999999999999" });
    UPDATE auth_one_time_code SET expires_at = time::now() - 1s WHERE link_hash = "9999999999999999999999999999999999999999999999999999999999999999";
    LET $expired = fn::auth_code_verify({ purpose: "verification", link_hash: "9999999999999999999999999999999999999999999999999999999999999999" });
    RETURN $blocked.error.code == "AUTH_TOO_MANY_ATTEMPTS" AND $expired.error.code == "AUTH_CODE_EXPIRED";
};

-- test: inscription par invitation : parcours démarré avec l'adresse de l'invitation
RETURN fn::auth_registration_start({ invitation_token_hash: "1111111111111111111111111111111111111111111111111111111111111111" }).data.{ email, organization, kind }
    == { email: "claire@exemple.fr", organization: auth_organization:alpha, kind: "invitation" };

-- test: inscription terminée : identité avec l'adresse de l'invitation (jamais celle fournie), adhésion, invitation acceptée, adresse vérifiée
{
    LET $flow = (SELECT VALUE id FROM ONLY auth_flow WHERE type = "registration" LIMIT 1);
    LET $r = fn::auth_registration_complete({ flow: <string> $flow, traits: { email: "pirate@exemple.fr", name: { first: "Claire" } } }).data;
    fn::auth_password_set({ identity: <string> $r.identity, secret: "enc:v2:cle-2026:CCCCCCCCCCCCCCCCCCCCCCCC" });
    LET $identity = (SELECT * FROM ONLY $r.identity);
    RETURN $identity.traits.email == "claire@exemple.fr" AND $identity.traits.name.first == "Claire"
        AND (SELECT VALUE state FROM ONLY auth_organization_invitation:inv) == "accepted"
        AND array::len(SELECT * FROM auth_member_of WHERE in = $r.identity AND out = auth_organization:alpha) == 1
        AND (SELECT VALUE verified_at FROM ONLY auth_address WHERE identity = $r.identity LIMIT 1) IS NOT NONE
        AND (SELECT VALUE secret_data FROM ONLY auth_credential WHERE identity = $r.identity LIMIT 1) == "enc:v2:cle-2026:CCCCCCCCCCCCCCCCCCCCCCCC";
};

-- test: invitation réutilisée ou inconnue refusée ; adresse déjà inscrite refusée
{
    CREATE auth_organization_invitation:inv2 CONTENT {
        organization: auth_organization:alpha, email: "claire@exemple.fr", roles: [],
        token_hash: "abababababababababababababababababababababababababababababababab", expires_at: time::now() + 7d,
        delivery: { event_id: "01a1bca0-0000-7000-8000-0000000000ab", secret: "enc:v2:cle-2026:AAAAAAAAAAAAAAAAAAAAAAAA" }
    };
    RETURN fn::auth_registration_start({ invitation_token_hash: "1111111111111111111111111111111111111111111111111111111111111111" }).error.code == "AUTH_INVITATION_INVALID"
        AND fn::auth_registration_start({ invitation_token_hash: "cdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcd" }).error.code == "AUTH_INVITATION_INVALID"
        AND fn::auth_registration_start({ invitation_token_hash: "abababababababababababababababababababababababababababababababab" }).error.code == "AUTH_IDENTIFIER_TAKEN";
};

-- test: lien d'installation : premier administrateur créé avec le rôle platform_admin
{
    LET $setup = fn::auth_setup_start({ email: "Admin@Lyxal.test", link_hash: "efefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefef" });
    LET $start = fn::auth_registration_start({ setup_link_hash: "efefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefef" }).data;
    LET $done = fn::auth_registration_complete({ flow: <string> $start.flow, traits: {} }).data;
    RETURN $setup.ok AND $start.{ email, kind } == { email: "admin@lyxal.test", kind: "setup" }
        AND (SELECT VALUE out FROM auth_has_role WHERE in = $done.identity) == [auth_role:platform_admin];
};

-- test: lien d'installation à usage unique ; second premier administrateur refusé
RETURN fn::auth_registration_start({ setup_link_hash: "efefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefef" }).error.code == "AUTH_SETUP_TOKEN_INVALID"
    AND fn::auth_setup_start({ email: "autre@lyxal.test", link_hash: "1212121212121212121212121212121212121212121212121212121212121212" }).error.code == "AUTH_SETUP_DONE";

-- préparation: identité au domaine de l'organisation, adresse non vérifiée
fn::auth_identity_create({ traits: { email: "paul@alpha-btp.fr" } });

-- test: adresse vérifiée : rattachement automatique par domaine
{
    LET $paul = (SELECT VALUE identity FROM ONLY auth_credential_identifier WHERE value = "paul@alpha-btp.fr" LIMIT 1);
    LET $before = array::len(SELECT * FROM auth_member_of WHERE in = $paul);
    LET $r = fn::auth_address_verify({ identity: <string> $paul, address: "paul@alpha-btp.fr" }).data;
    RETURN $before == 0 AND $r.organizations_joined == [auth_organization:alpha]
        AND fn::auth_domain_auto_join({ identity: $paul }) == [];
};

-- test: changement d'adresse : adresse prise refusée ; demande créée
{
    LET $paul = (SELECT VALUE identity FROM ONLY auth_credential_identifier WHERE value = "paul@alpha-btp.fr" LIMIT 1);
    LET $taken = fn::auth_address_change_request({ identity: <string> $paul, new_address: "claire@exemple.fr" });
    LET $r = fn::auth_address_change_request({ identity: <string> $paul, new_address: "Paul.Martin@Exemple.fr" }).data;
    RETURN $taken.error.code == "AUTH_IDENTIFIER_TAKEN" AND $r.address == "paul.martin@exemple.fr"
        AND array::len(SELECT * FROM auth_pending_address_change WHERE identity = $paul) == 1;
};

-- test: confirmation avant vérification du code refusée ; après : identifiant, adresse et trait remplacés, événement vers l'ancienne adresse
{
    LET $paul = (SELECT VALUE identity FROM ONLY auth_credential_identifier WHERE value = "paul@alpha-btp.fr" LIMIT 1);
    LET $flow = (SELECT VALUE flow FROM ONLY auth_pending_address_change WHERE identity = $paul LIMIT 1);
    LET $early = fn::auth_address_change_confirm({ flow: <string> $flow });
    fn::auth_flow_submit({ flow: <string> $flow, from: ["code_sent"], state: "code_verified" });
    LET $done = fn::auth_address_change_confirm({ flow: <string> $flow }).data;
    LET $e = (SELECT * FROM ONLY event_outbox WHERE event_type = "auth.address.changed" LIMIT 1);
    RETURN $early.error.code == "AUTH_FLOW_INVALID_STATE" AND $done.address == "paul.martin@exemple.fr"
        AND (SELECT VALUE value FROM ONLY auth_credential_identifier WHERE identity = $paul LIMIT 1) == "paul.martin@exemple.fr"
        AND (SELECT VALUE traits.email FROM ONLY $paul) == "paul.martin@exemple.fr"
        AND $e.payload.previous_address == "paul@alpha-btp.fr";
};
