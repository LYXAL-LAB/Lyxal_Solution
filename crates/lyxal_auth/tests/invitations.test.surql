-- lyxal-test: assertions
-- Invitations : création (empreinte seule, lien scellé publié avec l'event_id fourni),
-- remplacement, rôles prévus, acceptation par la bonne adresse, refus (adresse, expiration,
-- révocation, rejeu), liste, révocation.
--
-- identité gestion: { "id": "auth_session:gestion", "pv": 1, "permissions": ["auth.member.manage", "auth.member.read"] }
-- identité invite: { "id": "auth_session:invite", "pv": 1, "permissions": [] }
-- identité intrus: { "id": "auth_session:intrus", "pv": 1, "permissions": [] }

-- préparation: organisation, gestionnaire, invitée, intrus et sessions
{
    CREATE auth_organization:alpha CONTENT { slug: "alpha", name: "Alpha BTP" };
    CREATE auth_identity:gestion CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "gestion@alpha.test", name: { first: "Gérard" } } };
    RELATE auth_identity:gestion->auth_member_of->auth_organization:alpha;
    CREATE auth_identity:invite CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "claire@exemple.fr", locale: "fr-FR" } };
    CREATE auth_credential_identifier CONTENT { identity: auth_identity:invite, type: "email", value: "claire@exemple.fr" };
    CREATE auth_identity:intrus CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "intrus@exemple.fr" } };
    CREATE auth_credential_identifier CONTENT { identity: auth_identity:intrus, type: "email", value: "intrus@exemple.fr" };
    CREATE auth_session:gestion CONTENT { identity: auth_identity:gestion, organization: auth_organization:alpha, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_session:invite CONTENT { identity: auth_identity:invite, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_session:intrus CONTENT { identity: auth_identity:intrus, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    DEFINE TABLE test_ref SCHEMALESS PERMISSIONS FULL;
};

-- test: invitation créée ; l'empreinte du jeton n'est pas renvoyée
-- en tant que: gestion
RETURN fn::auth_invitation_create({
    organization: "auth_organization:alpha",
    email: "Claire@Exemple.fr",
    event_id: "01a1bca0-0000-7000-8000-000000000001",
    token_hash: "aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11",
    secret: "enc:v2:cle-2026:AAAAAAAAAAAAAAAAAAAAAAAA"
}).data.{ email, state, token_hash } == { email: "claire@exemple.fr", state: "pending", token_hash: NONE };

-- test: événement publié avec l'event_id fourni et le lien scellé, sans jeton en clair
{
    LET $e = (SELECT * FROM ONLY event_outbox WHERE event_type = "auth.invitation.created" LIMIT 1);
    RETURN { id: $e.event_id, secret: $e.payload.secret, org: $e.payload.organization_name, inviter: $e.payload.inviter_name, locale: $e.payload.recipient_locale, tenant: $e.payload.tenant }
        == { id: "01a1bca0-0000-7000-8000-000000000001", secret: "enc:v2:cle-2026:AAAAAAAAAAAAAAAAAAAAAAAA", org: "Alpha BTP", inviter: "Gérard", locale: "fr-FR", tenant: "alpha" };
};

-- test: le lien scellé n'est enregistré nulle part dans l'invitation (champ transitoire effacé)
RETURN (SELECT VALUE delivery FROM ONLY auth_organization_invitation LIMIT 1) IS NONE;

-- test: une identité connectée ne publie pas directement dans l'outbox (refus signalé)
-- en tant que: gestion
RETURN fn::event_publish({ event_id: <uuid> "01a1bca0-0000-7000-8000-0000000000ff", event_type: "auth.test.direct", producer: "lyxal_auth", payload: {} }).error.code == "EVENT_WRITE_FORBIDDEN";

-- test: secret non scellé (format enc:v2 exigé) et event_id invalide refusés
-- en tant que: gestion
RETURN fn::auth_invitation_create({ organization: "auth_organization:alpha", email: "x@exemple.fr", event_id: "01a1bca0-0000-7000-8000-000000000002", token_hash: "bb11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11", secret: "lien-en-clair-https://x" }).error.code == "AUTH_INVALID_PARAMETERS"
    AND fn::auth_invitation_create({ organization: "auth_organization:alpha", email: "x@exemple.fr", event_id: "pas-un-uuid", token_hash: "bb11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11", secret: "enc:v2:cle-2026:AAAAAAAAAAAAAAAAAAAAAAAA" }).error.code == "AUTH_INVALID_PARAMETERS";

-- test: un gestionnaire sans gestion des rôles ne prévoit pas de rôle administrateur
-- en tant que: gestion
RETURN fn::auth_invitation_create({ organization: "auth_organization:alpha", email: "x@exemple.fr", roles: ["auth_role:organization_admin"], event_id: "01a1bca0-0000-7000-8000-000000000003", token_hash: "cc11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11", secret: "enc:v2:cle-2026:AAAAAAAAAAAAAAAAAAAAAAAA" }).error.code == "AUTH_PERMISSION_DENIED";

-- test: une nouvelle invitation pour la même adresse remplace la précédente
-- en tant que: gestion
RETURN fn::auth_invitation_create({ organization: "auth_organization:alpha", email: "claire@exemple.fr", event_id: "01a1bca0-0000-7000-8000-000000000004", token_hash: "dd11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11", secret: "enc:v2:cle-2026:BBBBBBBBBBBBBBBBBBBBBBBB" }).ok;

-- test: la première invitation est révoquée, une seule en attente
RETURN (SELECT VALUE state FROM auth_organization_invitation WHERE email = "claire@exemple.fr" ORDER BY created_at) == ["revoked", "pending"];

-- test: l'invitée voit son invitation en attente, sans l'empreinte du jeton
-- en tant que: invite
RETURN (SELECT VALUE [state, token_hash] FROM auth_organization_invitation WHERE state = "pending") == [["pending", NONE]];

-- test: sans le jeton, l'invitée ne rejoint pas l'organisation par écriture directe
-- en tant que: invite
{
    RELATE auth_identity:invite->auth_member_of->auth_organization:alpha;
    UPDATE auth_organization_invitation SET state = "accepted", accepted_by = auth_identity:invite WHERE state = "pending";
    CREATE auth_invitation_claim CONTENT { identity: auth_identity:intrus, token_hash: "dd11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11" };
    RETURN true;
};

-- test: aucune adhésion, invitation toujours en attente, aucune demande au nom d'autrui
RETURN array::len(SELECT * FROM auth_member_of WHERE in = auth_identity:invite) == 0
    AND (SELECT VALUE state FROM ONLY auth_organization_invitation WHERE token_hash = "dd11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11" LIMIT 1) == "pending"
    AND array::len(SELECT * FROM auth_invitation_claim WHERE identity = auth_identity:intrus) == 0;

-- test: l'intrus ne voit pas l'invitation d'une autre adresse
-- en tant que: intrus
RETURN array::len(SELECT * FROM auth_organization_invitation) == 0;

-- test: l'intrus ne peut pas accepter l'invitation d'une autre adresse
-- en tant que: intrus
RETURN fn::auth_invitation_accept({ token_hash: "dd11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11" }).error.code == "AUTH_INVITATION_INVALID";

-- test: l'ancienne invitation remplacée n'est plus acceptable
-- en tant que: invite
RETURN fn::auth_invitation_accept({ token_hash: "aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11" }).error.code == "AUTH_INVITATION_INVALID";

-- test: l'invitée accepte : adhésion et rôle par défaut créés
-- en tant que: invite
RETURN fn::auth_invitation_accept({ token_hash: "DD11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11" }).data.roles == [auth_role:organization_member];

-- test: la demande d'acceptation porte l'issue écrite par la base, sans l'empreinte
-- en tant que: invite
RETURN (SELECT VALUE [outcome, token_hash, organization] FROM auth_invitation_claim ORDER BY created_at) == [["AUTH_INVITATION_INVALID", NONE, NONE], ["accepted", NONE, auth_organization:alpha]];

-- test: invitation acceptée, événements publiés
RETURN (SELECT VALUE state FROM ONLY auth_organization_invitation WHERE token_hash = "dd11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11" LIMIT 1) == "accepted"
    AND array::len(SELECT * FROM event_outbox WHERE event_type = "auth.invitation.accepted") == 1;

-- test: une invitation acceptée ne se rejoue pas
-- en tant que: invite
RETURN fn::auth_invitation_accept({ token_hash: "dd11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11" }).error.code == "AUTH_INVITATION_INVALID";

-- test: un membre n'est pas réinvité
-- en tant que: gestion
RETURN fn::auth_invitation_create({ organization: "auth_organization:alpha", email: "claire@exemple.fr", event_id: "01a1bca0-0000-7000-8000-000000000005", token_hash: "ee11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11", secret: "enc:v2:cle-2026:AAAAAAAAAAAAAAAAAAAAAAAA" }).error.code == "AUTH_ALREADY_A_MEMBER";

-- préparation: invitation expirée pour l'intrus
CREATE auth_organization_invitation CONTENT { organization: auth_organization:alpha, email: "intrus@exemple.fr", token_hash: "ff11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11", expires_at: time::now() - 1m, delivery: { event_id: "01a1bca0-0000-7000-8000-000000000007", secret: "enc:v2:cle-2026:AAAAAAAAAAAAAAAAAAAAAAAA" } };

-- test: invitation expirée refusée
-- en tant que: intrus
RETURN fn::auth_invitation_accept({ token_hash: "ff11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11" }).error.code == "AUTH_INVITATION_EXPIRED";

-- test: la liste montre l'expiration, sans empreintes
-- en tant que: gestion
{
    LET $list = fn::auth_invitation_list({ organization: "auth_organization:alpha" }).data;
    RETURN array::len($list) == 3 AND array::any($list, |$i| $i.expired) AND !array::any($list, |$i| $i.token_hash IS NOT NONE);
};

-- préparation: invitation à révoquer
{
    LET $created = fn::auth_invitation_create({ organization: "auth_organization:alpha", email: "revoque@exemple.fr", event_id: "01a1bca0-0000-7000-8000-000000000006", token_hash: "1111aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11", secret: "enc:v2:cle-2026:AAAAAAAAAAAAAAAAAAAAAAAA" });
    CREATE test_ref:revoque SET rid = <string> $created.data.id;
};

-- test: révocation par le gestionnaire, puis plus révocable
-- en tant que: gestion
RETURN fn::auth_invitation_revoke({ invitation: test_ref:revoque.rid }).data.state == "revoked"
    AND fn::auth_invitation_revoke({ invitation: test_ref:revoque.rid }).error.code == "AUTH_INVITATION_INVALID";

-- test: un tiers ne révoque ni ne liste
-- en tant que: intrus
RETURN fn::auth_invitation_list({ organization: "auth_organization:alpha" }).error.code == "AUTH_PERMISSION_DENIED";

-- test: la session système n'accepte pas d'invitation (identité requise)
RETURN fn::auth_invitation_accept({ token_hash: "1111aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11aa11" }).error.code == "AUTH_SESSION_REQUIRED";
