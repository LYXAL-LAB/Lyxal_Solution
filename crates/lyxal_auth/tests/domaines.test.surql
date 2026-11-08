-- lyxal-test: assertions
-- Domaines : déclaration (empreinte du défi seule), exclusivité, vérification par empreintes
-- des enregistrements TXT, rattachement automatique (domaine vérifié exigé), liste, retrait.
--
-- identité alpha: { "id": "auth_session:alpha", "pv": 1, "permissions": ["auth.organization.settings.manage", "auth.member.read"] }
-- identité beta: { "id": "auth_session:beta", "pv": 1, "permissions": ["auth.organization.settings.manage", "auth.member.read"] }

-- préparation: organisations, administrateurs et sessions
{
    CREATE auth_organization:alpha CONTENT { slug: "alpha", name: "Alpha" };
    CREATE auth_organization:beta CONTENT { slug: "beta", name: "Beta" };
    CREATE auth_identity:alpha CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "a@alpha.test" } };
    CREATE auth_identity:beta CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "b@beta.test" } };
    CREATE auth_session:alpha CONTENT { identity: auth_identity:alpha, organization: auth_organization:alpha, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_session:beta CONTENT { identity: auth_identity:beta, organization: auth_organization:beta, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
};

-- test: déclaration d'un domaine : nom de l'enregistrement TXT renvoyé, pas d'empreinte
-- en tant que: alpha
RETURN fn::auth_organization_domain_add({ organization: "auth_organization:alpha", domain: "Alpha-BTP.fr", challenge_hash: "AB12ab12ab12ab12ab12ab12ab12ab12ab12ab12ab12ab12ab12ab12ab12ab12" }).data.{ domain, state, txt_record, challenge_hash } == { domain: "alpha-btp.fr", state: "pending", txt_record: "_lyxal-challenge.alpha-btp.fr", challenge_hash: NONE };

-- préparation: identifiant du domaine
{
    DEFINE TABLE test_ref SCHEMALESS PERMISSIONS FULL;
    CREATE test_ref:d SET rid = <string> (SELECT VALUE id FROM ONLY auth_organization_domain WHERE domain = "alpha-btp.fr" LIMIT 1);
};

-- test: un domaine déclaré par une autre organisation est indisponible (même invisible)
-- en tant que: beta
RETURN fn::auth_organization_domain_add({ organization: "auth_organization:beta", domain: "alpha-btp.fr", challenge_hash: "cd12ab12ab12ab12ab12ab12ab12ab12ab12ab12ab12ab12ab12ab12ab12ab12" }).error.code == "AUTH_DOMAIN_TAKEN";

-- test: beta ne déclare pas de domaine pour alpha
-- en tant que: beta
RETURN fn::auth_organization_domain_add({ organization: "auth_organization:alpha", domain: "autre.fr", challenge_hash: "cd12ab12ab12ab12ab12ab12ab12ab12ab12ab12ab12ab12ab12ab12ab12ab12" }).error.code == "AUTH_PERMISSION_DENIED";

-- test: domaine ou empreinte invalides
-- en tant que: alpha
RETURN fn::auth_organization_domain_add({ organization: "auth_organization:alpha", domain: "pas un domaine", challenge_hash: "ab12ab12ab12ab12ab12ab12ab12ab12ab12ab12ab12ab12ab12ab12ab12ab12" }).error.code == "AUTH_INVALID_PARAMETERS"
    AND fn::auth_organization_domain_add({ organization: "auth_organization:alpha", domain: "ok.fr", challenge_hash: "trop-court" }).error.code == "AUTH_INVALID_PARAMETERS";

-- test: rattachement automatique refusé tant que le domaine n'est pas vérifié
-- en tant que: alpha
RETURN fn::auth_organization_domain_update({ domain: test_ref:d.rid, auto_join: true }).error.code == "AUTH_DOMAIN_NOT_VERIFIED";

-- test: la base refuse aussi le rattachement d'un domaine non vérifié
-- attendu-erreur: AUTH_DOMAIN_NOT_VERIFIED
UPDATE auth_organization_domain SET auto_join = true WHERE domain = "alpha-btp.fr";

-- test: une identité connectée ne fournit pas elle-même la preuve DNS
-- en tant que: alpha
RETURN fn::auth_organization_domain_verify({ domain: test_ref:d.rid, observed_hashes: ["AB12AB12AB12AB12AB12AB12AB12AB12AB12AB12AB12AB12AB12AB12AB12AB12"] }).error.code == "AUTH_PERMISSION_DENIED";

-- test: ni ne change l'état directement (champ réservé à la session système)
-- en tant que: alpha
RETURN (UPDATE auth_organization_domain SET state = "verified" WHERE domain = "alpha-btp.fr").state == ["pending"];

-- test: l'empreinte du défi n'est pas lisible par l'organisation
-- en tant que: alpha
RETURN fn::auth_organization_domain_get({ domain: test_ref:d.rid }).data.{ domain, state } == { domain: "alpha-btp.fr", state: "pending" }
    AND (SELECT VALUE challenge_hash FROM ONLY auth_organization_domain WHERE domain = "alpha-btp.fr" LIMIT 1) IS NONE;

-- test: vérification par l'hôte (session système) échouée sans l'empreinte attendue
RETURN fn::auth_organization_domain_verify({ domain: test_ref:d.rid, observed_hashes: ["0000000000000000000000000000000000000000000000000000000000000000"] }).error.code == "AUTH_DOMAIN_NOT_VERIFIED";

-- test: vérification par l'hôte réussie avec l'empreinte publiée (casse indifférente)
RETURN fn::auth_organization_domain_verify({ domain: test_ref:d.rid, observed_hashes: ["v=spf1", "AB12AB12AB12AB12AB12AB12AB12AB12AB12AB12AB12AB12AB12AB12AB12AB12"] }).data.state == "verified";

-- test: rattachement automatique avec le rôle membre
-- en tant que: alpha
RETURN fn::auth_organization_domain_update({ domain: test_ref:d.rid, auto_join: true, default_roles: ["auth_role:organization_member"] }).data.{ auto_join, default_roles } == { auto_join: true, default_roles: [auth_role:organization_member] };

-- test: rôle d'installation refusé comme rôle de rattachement
-- en tant que: alpha
RETURN fn::auth_organization_domain_update({ domain: test_ref:d.rid, default_roles: ["auth_role:platform_admin"] }).error.code == "AUTH_ROLE_SCOPE_MISMATCH";

-- test: liste des domaines d'alpha, sans empreintes ; beta n'y a pas accès
-- en tant que: alpha
RETURN fn::auth_organization_domain_list({ organization: "auth_organization:alpha" }).data.domain == ["alpha-btp.fr"]
    AND fn::auth_organization_domain_list({ organization: "auth_organization:alpha" }).data[0].challenge_hash IS NONE;

-- test: beta ne lit ni ne retire le domaine d'alpha
-- en tant que: beta
RETURN fn::auth_organization_domain_list({ organization: "auth_organization:alpha" }).error.code == "AUTH_PERMISSION_DENIED"
    AND fn::auth_organization_domain_remove({ domain: test_ref:d.rid }).error.code == "AUTH_DOMAIN_NOT_VERIFIED";

-- test: retrait par alpha ; le domaine redevient disponible
-- en tant que: alpha
RETURN fn::auth_organization_domain_remove({ domain: test_ref:d.rid }).data.removed;

-- test: beta peut maintenant déclarer le domaine
-- en tant que: beta
RETURN fn::auth_organization_domain_add({ organization: "auth_organization:beta", domain: "alpha-btp.fr", challenge_hash: "cd12ab12ab12ab12ab12ab12ab12ab12ab12ab12ab12ab12ab12ab12ab12ab12" }).ok;
