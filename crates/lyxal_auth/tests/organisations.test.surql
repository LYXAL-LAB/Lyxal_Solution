-- lyxal-test: assertions
-- Organisations : création (avec administrateur), lecture, liste, modification, état,
-- isolement entre organisations, écritures refusées, événements.
--
-- identité plateforme: { "id": "auth_session:plateforme", "pv": 1, "permissions": ["auth.organization.manage", "auth.identity.read"] }
-- identité alpha_admin: { "id": "auth_session:alpha_admin", "pv": 1, "permissions": ["auth.organization.settings.manage", "auth.member.read", "auth.member.manage"] }
-- identité beta_membre: { "id": "auth_session:beta_membre", "pv": 1, "permissions": ["auth.member.read"] }
-- identité sans_droit: { "id": "auth_session:sans_droit", "pv": 1, "permissions": [] }

-- préparation: identités et sessions de test
{
    CREATE auth_identity:plateforme CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "plateforme@lyxal.test" } };
    CREATE auth_identity:alpha_admin CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "admin@alpha.test" } };
    CREATE auth_identity:beta_membre CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "membre@beta.test" } };
    CREATE auth_session:plateforme CONTENT { identity: auth_identity:plateforme, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_session:sans_droit CONTENT { identity: auth_identity:plateforme, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    DEFINE TABLE test_ref SCHEMALESS PERMISSIONS FULL;
};

-- test: la plateforme crée une organisation avec son administrateur
-- en tant que: plateforme
RETURN fn::auth_organization_create({ slug: "alpha", name: "Alpha BTP", owner: "auth_identity:alpha_admin" }).data.{ slug, name, state } == { slug: "alpha", name: "Alpha BTP", state: "active" };

-- préparation: identifiant de l'organisation alpha
CREATE test_ref:alpha SET rid = <string> (SELECT VALUE id FROM ONLY auth_organization WHERE slug = "alpha" LIMIT 1);

-- test: l'administrateur désigné est membre avec les rôles administrateur et membre
RETURN (SELECT VALUE ->auth_has_role->auth_role.key FROM ONLY auth_member_of WHERE in = auth_identity:alpha_admin LIMIT 1).sort() == ["organization_admin", "organization_member"];

-- test: la création publie auth.organization.created et l'adhésion auth.member.added
RETURN array::len(SELECT * FROM event_outbox WHERE event_type = "auth.organization.created") == 1
    AND array::len(SELECT * FROM event_outbox WHERE event_type = "auth.member.added") == 1;

-- test: slug déjà utilisé
-- en tant que: plateforme
RETURN fn::auth_organization_create({ slug: "alpha", name: "Autre" }).error.code == "AUTH_ORGANIZATION_SLUG_TAKEN";

-- test: paramètres invalides (slug mal formé, clé inconnue)
-- en tant que: plateforme
RETURN fn::auth_organization_create({ slug: "Pas Un Slug", name: "X" }).error.code == "AUTH_INVALID_PARAMETERS"
    AND fn::auth_organization_create({ slug: "gamma", name: "G", inconnu: 1 }).error.code == "AUTH_INVALID_PARAMETERS";

-- test: propriétaire inexistant
-- en tant que: plateforme
RETURN fn::auth_organization_create({ slug: "gamma", name: "Gamma", owner: "auth_identity:fantome" }).error.code == "AUTH_IDENTITY_NOT_FOUND";

-- test: sans permission, création refusée et rien créé
-- en tant que: sans_droit
RETURN fn::auth_organization_create({ slug: "pirate", name: "Pirate" }).error.code == "AUTH_PERMISSION_DENIED";

-- test: rien n'a été créé
RETURN array::len(SELECT * FROM auth_organization WHERE slug = "pirate") == 0;

-- préparation: organisation beta et sessions des membres
{
    LET $beta = fn::auth_organization_create({ slug: "beta", name: "Beta", owner: "auth_identity:beta_membre" }).data.id;
    CREATE test_ref:beta SET rid = <string> $beta;
    CREATE auth_session:alpha_admin CONTENT { identity: auth_identity:alpha_admin, organization: <record> test_ref:alpha.rid, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_session:beta_membre CONTENT { identity: auth_identity:beta_membre, organization: $beta, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
};

-- test: lecture par slug et par identifiant
-- en tant que: plateforme
RETURN fn::auth_organization_get({ slug: "alpha" }).data.name == "Alpha BTP"
    AND fn::auth_organization_get({ organization: test_ref:alpha.rid }).data.slug == "alpha";

-- test: lecture sans critère refusée, organisation inconnue introuvable
-- en tant que: plateforme
RETURN fn::auth_organization_get({}).error.code == "AUTH_INVALID_PARAMETERS"
    AND fn::auth_organization_get({ slug: "inconnue" }).error.code == "AUTH_ORGANIZATION_NOT_FOUND";

-- test: un membre ne voit que son organisation
-- en tant que: beta_membre
RETURN fn::auth_organization_list({}).data.slug == ["beta"]
    AND fn::auth_organization_get({ slug: "alpha" }).error.code == "AUTH_ORGANIZATION_NOT_FOUND";

-- test: la plateforme liste toutes les organisations, filtre par état
-- en tant que: plateforme
RETURN fn::auth_organization_list({}).data.slug == ["alpha", "beta"]
    AND fn::auth_organization_list({ state: "suspended" }).data == []
    AND fn::auth_organization_list({ limit: 0 }).error.code == "AUTH_INVALID_PARAMETERS";

-- test: l'administrateur d'alpha modifie sa fiche
-- en tant que: alpha_admin
RETURN fn::auth_organization_update({ organization: test_ref:alpha.rid, name: "Alpha Bâtiment", description: "Entreprise générale" }).data.{ name, description } == { name: "Alpha Bâtiment", description: "Entreprise générale" };

-- test: l'administrateur d'alpha ne modifie pas beta
-- en tant que: alpha_admin
RETURN fn::auth_organization_update({ organization: test_ref:beta.rid, name: "Piratée" }).error.code == "AUTH_PERMISSION_DENIED";

-- test: un simple membre ne modifie pas sa fiche
-- en tant que: beta_membre
RETURN fn::auth_organization_update({ organization: test_ref:beta.rid, name: "Piratée" }).error.code == "AUTH_PERMISSION_DENIED";

-- test: beta est intacte
RETURN (SELECT VALUE name FROM ONLY <record> test_ref:beta.rid) == "Beta";

-- test: seule la plateforme change l'état
-- en tant que: alpha_admin
RETURN fn::auth_organization_set_state({ organization: test_ref:alpha.rid, state: "suspended" }).error.code == "AUTH_PERMISSION_DENIED";

-- test: la plateforme suspend beta et l'événement est publié
-- en tant que: plateforme
RETURN fn::auth_organization_set_state({ organization: test_ref:beta.rid, state: "suspended" }).data.state == "suspended";

-- test: événement de changement d'état
RETURN (SELECT VALUE payload FROM ONLY event_outbox WHERE event_type = "auth.organization.state_changed" LIMIT 1).{ previous_state, state } == { previous_state: "active", state: "suspended" };

-- test: les sessions ouvertes sur l'organisation suspendue sont révoquées, droits des membres périmés
RETURN (SELECT VALUE [state, revoked_reason] FROM ONLY auth_session:beta_membre) == ["revoked", "organization_inactive"]
    AND (SELECT VALUE permissions_version FROM ONLY auth_identity:beta_membre) == 2;

-- test: le membre de l'organisation suspendue n'a plus aucun droit
-- en tant que: beta_membre
RETURN fn::auth_context({}).error.code == "AUTH_SESSION_REVOKED";

-- test: une organisation suspendue n'accepte pas de nouveau membre
RETURN fn::auth_organization_member_add({ organization: test_ref:beta.rid, identity: "auth_identity:plateforme" }).error.code == "AUTH_ORGANIZATION_INACTIVE";

-- test: une organisation supprimée ne revient pas
-- en tant que: plateforme
RETURN fn::auth_organization_set_state({ organization: test_ref:beta.rid, state: "deleted" }).data.state == "deleted"
    AND fn::auth_organization_set_state({ organization: test_ref:beta.rid, state: "active" }).error.code == "AUTH_ORGANIZATION_INACTIVE";

-- test: la base refuse aussi la résurrection directe
-- attendu-erreur: AUTH_ORGANIZATION_INACTIVE
UPDATE <record> test_ref:beta.rid SET state = "active";
