-- lyxal-test: assertions
-- Socle : seeds (schéma, politique, permissions, rôles du socle et leurs permissions), rejouables
-- sans doublon.

-- test: quatorze permissions du socle, une portée chacune
RETURN array::len(fn::auth_permission_list({ module: "lyxal_auth" }).data) == 14
    AND array::len(fn::auth_permission_list({ module: "lyxal_auth", scope: "organization" }).data) == 7;

-- test: rôles du socle et leurs permissions
RETURN (SELECT VALUE array::len(->auth_role_grants) FROM ONLY auth_role:platform_admin) == 6
    AND (SELECT VALUE array::len(->auth_role_grants) FROM ONLY auth_role:organization_admin) == 7
    AND (SELECT VALUE ->auth_role_grants->auth_permission.code FROM ONLY auth_role:organization_member) == ["auth.member.read"];

-- test: seul le rôle membre est attribué par défaut
RETURN (SELECT VALUE key FROM auth_role WHERE is_default = true) == ["organization_member"];

-- préparation: rejeu des seeds
fn::auth_policy_get({});

-- test: aucun compte par défaut
RETURN array::len(SELECT * FROM auth_identity) == 0 AND array::len(SELECT * FROM auth_session) == 0;
