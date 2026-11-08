-- lyxal-test: assertions
-- Rôles et permissions : registre non destructif, rôles de l'installation et d'une organisation,
-- portées, rôles système, permissions accordées, rôles composites (cycles refusés),
-- attribution et retrait, permissions effectives, version des droits.
--
-- identité plateforme: { "id": "auth_session:plateforme", "pv": 1, "permissions": ["auth.role.manage", "auth.identity.read", "auth.organization.manage"] }
-- identité alpha_admin: { "id": "auth_session:alpha_admin", "pv": 1, "permissions": ["auth.organization.role.manage", "auth.member.read", "auth.member.manage"] }
-- identité beta_admin: { "id": "auth_session:beta_admin", "pv": 1, "permissions": ["auth.organization.role.manage", "auth.member.read"] }

-- préparation: organisations, identités, adhésions et sessions
{
    CREATE auth_organization:alpha CONTENT { slug: "alpha", name: "Alpha" };
    CREATE auth_organization:beta CONTENT { slug: "beta", name: "Beta" };
    CREATE auth_identity:plateforme CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "p@lyxal.test" } };
    CREATE auth_identity:alpha_admin CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "admin@alpha.test" } };
    CREATE auth_identity:paul CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "paul@alpha.test" } };
    CREATE auth_identity:beta_admin CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "admin@beta.test" } };
    RELATE auth_identity:alpha_admin->auth_member_of->auth_organization:alpha CONTENT { id: auth_member_of:alpha_admin };
    RELATE auth_identity:paul->auth_member_of->auth_organization:alpha CONTENT { id: auth_member_of:paul };
    RELATE auth_identity:beta_admin->auth_member_of->auth_organization:beta CONTENT { id: auth_member_of:beta_admin };
    RELATE auth_member_of:alpha_admin->auth_has_role->auth_role:organization_admin;
    CREATE auth_session:plateforme CONTENT { identity: auth_identity:plateforme, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_session:alpha_admin CONTENT { identity: auth_identity:alpha_admin, organization: auth_organization:alpha, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_session:beta_admin CONTENT { identity: auth_identity:beta_admin, organization: auth_organization:beta, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    DEFINE TABLE test_ref SCHEMALESS PERMISSIONS FULL;
};

-- test: enregistrement d'une permission de module
RETURN fn::auth_permission_register({ code: "catalogue.item.write", module: "lyxal_catalogue", scope: "organization", description: { fr: "Écrire les articles" } }).data.created == true;

-- test: rejouer l'enregistrement ne modifie rien
RETURN fn::auth_permission_register({ code: "catalogue.item.write", module: "lyxal_catalogue", scope: "organization", description: { fr: "Autre texte" } }).data.{ created, d: description.fr } == { created: false, d: "Écrire les articles" };

-- test: même code déclaré avec une autre portée refusé
RETURN fn::auth_permission_register({ code: "catalogue.item.write", module: "lyxal_catalogue", scope: "installation" }).error.code == "AUTH_PERMISSION_CONFLICT";

-- test: code mal formé refusé
RETURN fn::auth_permission_register({ code: "PasBon", module: "lyxal_catalogue", scope: "organization" }).error.code == "AUTH_INVALID_PARAMETERS";

-- test: modification volontaire de la description
-- en tant que: plateforme
RETURN fn::auth_permission_update({ code: "catalogue.item.write", description: { fr: "Créer et modifier les articles" } }).data.description.fr == "Créer et modifier les articles"
    AND fn::auth_permission_update({ code: "inconnue.code", description: {} }).error.code == "AUTH_PERMISSION_UNKNOWN";

-- test: liste filtrée par module et par portée
RETURN fn::auth_permission_list({ module: "lyxal_catalogue" }).data.code == ["catalogue.item.write"]
    AND array::len(fn::auth_permission_list({ scope: "installation" }).data) == 7;

-- test: un administrateur d'organisation n'enregistre pas de permission
-- en tant que: alpha_admin
RETURN fn::auth_permission_register({ code: "pirate.write", module: "lyxal_pirate", scope: "organization" }).error.code == "AUTH_PERMISSION_DENIED";

-- test: la plateforme crée un rôle de l'installation
-- en tant que: plateforme
RETURN fn::auth_role_create({ key: "support", name: "Support", scope: "installation" }).data.{ key, scope_key } == { key: "support", scope_key: "installation" };

-- test: un administrateur d'organisation crée un rôle propre à son organisation
-- en tant que: alpha_admin
RETURN fn::auth_role_create({ tenant: "auth_organization:alpha", key: "chef_chantier", name: "Chef de chantier", scope: "organization" }).data.key == "chef_chantier";

-- préparation: identifiants des rôles
{
    CREATE test_ref:support SET rid = <string> (SELECT VALUE id FROM ONLY auth_role WHERE key = "support" LIMIT 1);
    CREATE test_ref:chef SET rid = <string> (SELECT VALUE id FROM ONLY auth_role WHERE key = "chef_chantier" LIMIT 1);
};

-- test: la même clé est libre dans une autre organisation, prise dans la même portée
-- en tant que: beta_admin
RETURN fn::auth_role_create({ tenant: "auth_organization:beta", key: "chef_chantier", name: "Chef", scope: "organization" }).ok;

-- test: clé déjà prise dans la portée
-- en tant que: alpha_admin
RETURN fn::auth_role_create({ tenant: "auth_organization:alpha", key: "chef_chantier", name: "Doublon", scope: "organization" }).error.code == "AUTH_ROLE_KEY_TAKEN";

-- test: un rôle propre à une organisation est un rôle d'organisation
-- en tant que: alpha_admin
RETURN fn::auth_role_create({ tenant: "auth_organization:alpha", key: "faux", name: "Faux", scope: "installation" }).error.code == "AUTH_ROLE_SCOPE_MISMATCH";

-- test: un administrateur d'organisation ne crée ni rôle d'installation ni rôle d'une autre organisation
-- en tant que: alpha_admin
RETURN fn::auth_role_create({ key: "pirate", name: "Pirate", scope: "installation" }).error.code == "AUTH_PERMISSION_DENIED"
    AND fn::auth_role_create({ tenant: "auth_organization:beta", key: "pirate", name: "Pirate", scope: "organization" }).error.code == "AUTH_PERMISSION_DENIED";

-- test: un rôle système n'est modifié que par la session système
-- en tant que: plateforme
RETURN fn::auth_role_update({ role: "auth_role:platform_admin", name: "Renommé" }).error.code == "AUTH_ROLE_SYSTEM"
    AND fn::auth_role_permission_set({ role: "auth_role:organization_member", permissions: ["auth.member.read"] }).error.code == "AUTH_ROLE_SYSTEM";

-- test: modification d'un rôle propre
-- en tant que: alpha_admin
RETURN fn::auth_role_update({ role: test_ref:chef.rid, name: "Conducteur de travaux", is_default: true }).data.{ name, is_default } == { name: "Conducteur de travaux", is_default: true };

-- test: un rôle d'installation n'est pas attribué par défaut
-- en tant que: plateforme
RETURN fn::auth_role_update({ role: test_ref:support.rid, is_default: true }).error.code == "AUTH_ROLE_SCOPE_MISMATCH";

-- test: liste : rôles de l'installation et de l'organisation demandée seulement
-- en tant que: alpha_admin
RETURN array::sort(fn::auth_role_list({ tenant: "auth_organization:alpha", scope: "organization" }).data.key) == ["chef_chantier", "organization_admin", "organization_member"];

-- test: permissions d'un rôle propre : même portée exigée, codes connus exigés
-- en tant que: alpha_admin
RETURN fn::auth_role_permission_set({ role: test_ref:chef.rid, permissions: ["auth.identity.read"] }).error.code == "AUTH_ROLE_SCOPE_MISMATCH"
    AND fn::auth_role_permission_set({ role: test_ref:chef.rid, permissions: ["inconnu.code"] }).error.code == "AUTH_PERMISSION_UNKNOWN";

-- test: permissions d'un rôle propre remplacées
-- en tant que: alpha_admin
RETURN fn::auth_role_permission_set({ role: test_ref:chef.rid, permissions: ["catalogue.item.write", "auth.member.read"] }).data.permissions == ["auth.member.read", "catalogue.item.write"];

-- test: remplacement suivant : les permissions absentes sont retirées
-- en tant que: alpha_admin
RETURN fn::auth_role_permission_set({ role: test_ref:chef.rid, permissions: ["catalogue.item.write"] }).data.permissions == ["catalogue.item.write"];

-- test: ajout sans retrait (seeds) par clé de rôle de l'installation
RETURN fn::auth_role_permission_grant({ role_key: "organization_admin", permissions: ["catalogue.item.write"] }).data.permissions CONTAINS "catalogue.item.write"
    AND fn::auth_role_permission_grant({ role_key: "inexistant", permissions: ["catalogue.item.write"] }).error.code == "AUTH_ROLE_NOT_FOUND";

-- test: le rôle d'organisation de beta n'est pas gérable par alpha
-- en tant que: alpha_admin
RETURN fn::auth_role_can_manage({ tenant: auth_organization:alpha }) AND !fn::auth_role_can_manage({ tenant: auth_organization:beta }) AND !fn::auth_role_can_manage({});

-- test: rôles composites : le rôle inclut le rôle membre
-- en tant que: alpha_admin
RETURN fn::auth_role_include_set({ role: test_ref:chef.rid, includes: ["auth_role:organization_member"] }).data.includes == [auth_role:organization_member];

-- préparation: second rôle propre inclus par le premier
{
    LET $adjoint = fn::auth_role_create({ tenant: "auth_organization:alpha", key: "adjoint", name: "Adjoint", scope: "organization" }).data.id;
    CREATE test_ref:adjoint SET rid = <string> $adjoint;
    fn::auth_role_include_set({ role: test_ref:chef.rid, includes: ["auth_role:organization_member", <string> $adjoint] });
};

-- test: un cycle de rôles est refusé
-- en tant que: alpha_admin
RETURN fn::auth_role_include_set({ role: test_ref:adjoint.rid, includes: [test_ref:chef.rid] }).error.code == "AUTH_ROLE_CYCLE"
    AND fn::auth_role_include_set({ role: test_ref:chef.rid, includes: [test_ref:chef.rid] }).error.code == "AUTH_ROLE_CYCLE";

-- test: la base refuse aussi un cycle créé directement
-- attendu-erreur: AUTH_ROLE_CYCLE
RELATE (<record> test_ref:adjoint.rid)->auth_role_includes->(<record> test_ref:chef.rid);

-- test: inclusion d'un rôle d'une autre portée refusée
-- en tant que: alpha_admin
RETURN fn::auth_role_include_set({ role: test_ref:chef.rid, includes: ["auth_role:platform_admin"] }).error.code == "AUTH_ROLE_SCOPE_MISMATCH";

-- test: titulaire d'un rôle selon sa portée
RETURN fn::auth_role_target({ role: { scope: "organization", tenant: NONE }, identity: auth_identity:paul, organization: auth_organization:alpha }).holder == auth_member_of:paul
    AND fn::auth_role_target({ role: { scope: "installation" }, identity: auth_identity:paul, organization: auth_organization:alpha }).code == "AUTH_ROLE_SCOPE_MISMATCH"
    AND fn::auth_role_target({ role: { scope: "organization" }, identity: auth_identity:plateforme, organization: auth_organization:alpha }).code == "AUTH_NOT_A_MEMBER";

-- test: attribution d'un rôle d'organisation à un membre
-- en tant que: alpha_admin
RETURN fn::auth_role_assign({ role: test_ref:chef.rid, identity: "auth_identity:paul", organization: "auth_organization:alpha" }).data.assigned == true;

-- test: attribution rejouée sans doublon
-- en tant que: alpha_admin
RETURN fn::auth_role_assign({ role: test_ref:chef.rid, identity: "auth_identity:paul", organization: "auth_organization:alpha" }).data.assigned == false;

-- test: événement d'attribution
RETURN array::len(SELECT * FROM event_outbox WHERE event_type = "auth.role.assigned" AND payload.identity_id = "auth_identity:paul") == 1;

-- test: une identité invisible pour l'administrateur d'organisation est introuvable
-- en tant que: alpha_admin
RETURN fn::auth_role_assign({ role: test_ref:chef.rid, identity: "auth_identity:plateforme", organization: "auth_organization:alpha" }).error.code == "AUTH_IDENTITY_NOT_FOUND";

-- test: rôle d'organisation hors adhésion refusé (plateforme)
-- en tant que: plateforme
RETURN fn::auth_role_assign({ role: test_ref:chef.rid, identity: "auth_identity:plateforme", organization: "auth_organization:alpha" }).error.code == "AUTH_NOT_A_MEMBER";

-- test: rôle propre à une autre organisation refusé
-- en tant que: alpha_admin
RETURN fn::auth_role_assign({ role: test_ref:chef.rid, identity: "auth_identity:paul", organization: "auth_organization:beta" }).error.code == "AUTH_ROLE_SCOPE_MISMATCH";

-- test: la base refuse un rôle d'installation sur une adhésion
-- attendu-erreur: AUTH_ROLE_SCOPE_MISMATCH
RELATE auth_member_of:paul->auth_has_role->auth_role:platform_admin;

-- test: permissions effectives de Paul : rôles inclus compris
-- en tant que: alpha_admin
RETURN fn::auth_identity_permissions({ identity: "auth_identity:paul", organization: "auth_organization:alpha" }).data.{ i: installation, o: organization_permissions } == { i: [], o: ["auth.member.read", "catalogue.item.write"] };

-- test: permissions effectives d'une identité hors de l'organisation : refusées
-- en tant que: alpha_admin
RETURN fn::auth_identity_permissions({ identity: "auth_identity:beta_admin", organization: "auth_organization:beta" }).error.code == "AUTH_PERMISSION_DENIED";

-- test: rôle d'installation attribué par la plateforme
-- en tant que: plateforme
RETURN fn::auth_role_assign({ role: test_ref:support.rid, identity: "auth_identity:paul" }).data.assigned
    AND fn::auth_role_assign({ role: test_ref:support.rid, identity: "auth_identity:paul", organization: "auth_organization:alpha" }).error.code == "AUTH_ROLE_SCOPE_MISMATCH";

-- test: un administrateur d'organisation n'attribue pas de rôle d'installation
-- en tant que: alpha_admin
RETURN fn::auth_role_assign({ role: test_ref:support.rid, identity: "auth_identity:alpha_admin" }).error.code == "AUTH_PERMISSION_DENIED";

-- test: titulaires d'un rôle, y compris par un rôle qui l'inclut
RETURN fn::auth_role_holders({ role: <record> test_ref:adjoint.rid }) == [auth_identity:paul]
    AND (SELECT VALUE permissions_version FROM ONLY auth_identity:paul) == 1;

-- test: retirer une permission d'un rôle inclus rend obsolètes les sessions de ses titulaires
-- en tant que: alpha_admin
RETURN fn::auth_role_permission_set({ role: test_ref:adjoint.rid, permissions: ["auth.member.read"] }).ok
    AND fn::auth_role_permission_set({ role: test_ref:adjoint.rid, permissions: ["catalogue.item.write"] }).ok;

-- test: la version des droits de Paul a augmenté (retrait de auth.member.read d'adjoint)
RETURN (SELECT VALUE permissions_version FROM ONLY auth_identity:paul) == 2;

-- test: retrait d'un rôle : version des droits incrémentée, événement publié
-- en tant que: alpha_admin
RETURN fn::auth_role_unassign({ role: test_ref:chef.rid, identity: "auth_identity:paul", organization: "auth_organization:alpha" }).data.unassigned == true;

-- test: Paul a perdu le rôle, sa version a augmenté
RETURN {
    roles: (SELECT VALUE ->auth_has_role->auth_role.key FROM ONLY auth_member_of:paul),
    version: (SELECT VALUE permissions_version FROM ONLY auth_identity:paul),
    events: array::len(SELECT * FROM event_outbox WHERE event_type = "auth.role.unassigned")
} == { roles: [], version: 3, events: 1 };

-- test: retirer le rôle administrateur du dernier administrateur est refusé
-- en tant que: alpha_admin
RETURN fn::auth_role_unassign({ role: "auth_role:organization_admin", identity: "auth_identity:alpha_admin", organization: "auth_organization:alpha" }).error.code == "AUTH_LAST_ADMIN";

-- test: retrait d'un rôle non attribué : sans effet
-- en tant que: alpha_admin
RETURN fn::auth_role_unassign({ role: test_ref:chef.rid, identity: "auth_identity:paul", organization: "auth_organization:alpha" }).data.unassigned == false;

-- test: rôle inconnu
-- en tant que: alpha_admin
RETURN fn::auth_role_update({ role: "auth_role:fantome", name: "X" }).error.code == "AUTH_ROLE_NOT_FOUND"
    AND fn::auth_role_assign({ role: "auth_role:fantome", identity: "auth_identity:paul", organization: "auth_organization:alpha" }).error.code == "AUTH_ROLE_NOT_FOUND";

-- test: un administrateur peut se retirer un rôle à lui-même ; sa session devient obsolète
-- en tant que: alpha_admin
RETURN fn::auth_role_assign({ role: test_ref:chef.rid, identity: "auth_identity:alpha_admin", organization: "auth_organization:alpha" }).data.assigned
    AND fn::auth_role_unassign({ role: test_ref:chef.rid, identity: "auth_identity:alpha_admin", organization: "auth_organization:alpha" }).data.unassigned;

-- test: la session de l'administrateur est obsolète après le retrait de son propre rôle
-- en tant que: alpha_admin
RETURN fn::auth_context({}).error.code == "AUTH_SESSION_STALE";
