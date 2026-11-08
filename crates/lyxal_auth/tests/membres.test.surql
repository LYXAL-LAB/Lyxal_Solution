-- lyxal-test: assertions
-- Membres : ajout avec rôles par défaut, rôles demandés (permission dédiée), doublons, liste,
-- suspension, retrait (rôles supprimés avec l'adhésion, version des droits), dernier
-- administrateur, prédicats.
--
-- identité gestion: { "id": "auth_session:gestion", "pv": 1, "permissions": ["auth.member.manage", "auth.member.read"] }
-- identité admin: { "id": "auth_session:admin", "pv": 1, "permissions": ["auth.member.manage", "auth.member.read", "auth.organization.role.manage"] }
-- identité lecteur: { "id": "auth_session:lecteur", "pv": 1, "permissions": ["auth.member.read"] }

-- préparation: organisation, identités, administrateur et sessions
{
    CREATE auth_organization:alpha CONTENT { slug: "alpha", name: "Alpha" };
    CREATE auth_organization:beta CONTENT { slug: "beta", name: "Beta" };
    CREATE auth_identity:admin CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "admin@alpha.test" } };
    CREATE auth_identity:gestion CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "gestion@alpha.test" } };
    CREATE auth_identity:lea CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "lea@alpha.test" } };
    CREATE auth_identity:tom CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "tom@alpha.test" } };
    RELATE auth_identity:admin->auth_member_of->auth_organization:alpha CONTENT { id: auth_member_of:admin };
    RELATE auth_identity:gestion->auth_member_of->auth_organization:alpha CONTENT { id: auth_member_of:gestion };
    RELATE auth_member_of:admin->auth_has_role->auth_role:organization_admin;
    CREATE auth_session:admin CONTENT { identity: auth_identity:admin, organization: auth_organization:alpha, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_session:gestion CONTENT { identity: auth_identity:gestion, organization: auth_organization:alpha, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_session:lecteur CONTENT { identity: auth_identity:gestion, organization: auth_organization:alpha, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
};

-- test: la plateforme (session système) ajoute Léa : rôle par défaut attribué
RETURN fn::auth_organization_member_add({ organization: "auth_organization:alpha", identity: "auth_identity:lea" }).data.roles == [auth_role:organization_member];

-- test: déjà membre
RETURN fn::auth_organization_member_add({ organization: "auth_organization:alpha", identity: "auth_identity:lea" }).error.code == "AUTH_ALREADY_A_MEMBER";

-- test: rôles demandés sans la permission de gérer les rôles : refusé
-- en tant que: gestion
RETURN fn::auth_organization_member_add({ organization: "auth_organization:alpha", identity: "auth_identity:tom", roles: ["auth_role:organization_admin"] }).error.code == "AUTH_PERMISSION_DENIED";

-- test: un gestionnaire sans visibilité sur l'identité ne l'ajoute pas
-- en tant que: gestion
RETURN fn::auth_organization_member_add({ organization: "auth_organization:alpha", identity: "auth_identity:tom" }).error.code == "AUTH_IDENTITY_NOT_FOUND";

-- test: rôle d'installation refusé sur une adhésion
RETURN fn::auth_organization_member_add({ organization: "auth_organization:alpha", identity: "auth_identity:tom", roles: ["auth_role:platform_admin"] }).error.code == "AUTH_ROLE_SCOPE_MISMATCH";

-- test: ajout de Tom comme second administrateur (session système)
RETURN array::sort(fn::auth_organization_member_add({ organization: "auth_organization:alpha", identity: "auth_identity:tom", roles: ["auth_role:organization_admin"] }).data.roles) == [auth_role:organization_admin, auth_role:organization_member];

-- test: liste des membres avec leurs rôles
-- en tant que: lecteur
RETURN array::len(fn::auth_organization_member_list({ organization: "auth_organization:alpha" }).data) == 4
    AND fn::auth_organization_member_list({ organization: "auth_organization:beta" }).error.code == "AUTH_PERMISSION_DENIED";

-- test: un lecteur n'ajoute ni ne retire de membre
-- en tant que: lecteur
RETURN fn::auth_organization_member_remove({ organization: "auth_organization:alpha", identity: "auth_identity:lea" }).error.code == "AUTH_PERMISSION_DENIED";

-- test: dernier administrateur : faux tant que Tom l'est aussi
RETURN fn::auth_is_last_admin({ membership: auth_member_of:admin }) == false
    AND fn::auth_is_last_admin({ membership: auth_member_of:gestion }) == false;

-- test: suspension de Tom (administrateur) ; version des droits incrémentée
-- en tant que: admin
RETURN fn::auth_organization_member_set_state({ organization: "auth_organization:alpha", identity: "auth_identity:tom", state: "suspended" }).data.state == "suspended"
    AND (SELECT VALUE permissions_version FROM ONLY auth_identity:tom) == 2;

-- test: l'administrateur restant est désormais le dernier actif
RETURN fn::auth_is_last_admin({ membership: auth_member_of:admin });

-- test: le dernier administrateur ne peut être ni suspendu ni retiré
-- en tant que: admin
RETURN fn::auth_organization_member_set_state({ organization: "auth_organization:alpha", identity: "auth_identity:admin", state: "suspended" }).error.code == "AUTH_LAST_ADMIN"
    AND fn::auth_organization_member_remove({ organization: "auth_organization:alpha", identity: "auth_identity:admin" }).error.code == "AUTH_LAST_ADMIN";

-- test: réactivation de Tom
-- en tant que: admin
RETURN fn::auth_organization_member_set_state({ organization: "auth_organization:alpha", identity: "auth_identity:tom", state: "active" }).data.state == "active";

-- test: l'administrateur lit un membre de son organisation et partage l'organisation avec lui
-- en tant que: admin
RETURN fn::auth_shares_organization({ identity: auth_identity:lea, permission: "auth.member.manage" })
    AND !fn::auth_shares_organization({ identity: auth_identity:lea, permission: "auth.organization.role.manage.inconnue" });

-- test: retrait de Léa : rôles supprimés avec l'adhésion, version incrémentée, événement
-- en tant que: gestion
RETURN fn::auth_organization_member_remove({ organization: "auth_organization:alpha", identity: "auth_identity:lea" }).data.removed;

-- test: plus aucune trace de l'adhésion ni de ses rôles
RETURN array::len(SELECT * FROM auth_member_of WHERE in = auth_identity:lea) == 0
    AND array::len(SELECT * FROM auth_has_role WHERE in.in = auth_identity:lea) == 0
    AND (SELECT VALUE permissions_version FROM ONLY auth_identity:lea) == 2
    AND array::len(SELECT * FROM event_outbox WHERE event_type = "auth.member.removed") == 1;

-- test: retirer un non-membre
-- en tant que: gestion
RETURN fn::auth_organization_member_remove({ organization: "auth_organization:alpha", identity: "auth_identity:lea" }).error.code == "AUTH_NOT_A_MEMBER";

-- test: paramètres invalides
RETURN fn::auth_organization_member_add({ organization: "pas_une_org:x", identity: "auth_identity:lea" }).error.code == "AUTH_INVALID_PARAMETERS";

-- test: création directe d'une adhésion avec rôles (session système)
RETURN fn::auth_membership_create({ identity: auth_identity:lea, organization: auth_organization:beta, roles: [], by: NONE }).roles == [auth_role:organization_member];
