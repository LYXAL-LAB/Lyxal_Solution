-- lyxal-test: assertions
-- Identités : schéma des traits, création (installation ou organisation), identifiants uniques
-- (un e-mail = une identité), lecture, liste, modification des traits, états et révocation.
--
-- identité admin: { "id": "auth_session:admin", "pv": 1, "permissions": ["auth.identity.manage", "auth.identity.read", "auth.organization.manage"] }
-- identité orga: { "id": "auth_session:orga", "pv": 1, "permissions": ["auth.member.manage", "auth.member.read"] }
-- identité lecteur: { "id": "auth_session:lecteur", "pv": 1, "permissions": ["auth.member.read"] }
-- identité soi: { "id": "auth_session:soi", "pv": 1, "permissions": [] }

-- préparation: organisation, identités et sessions
{
    CREATE auth_organization:alpha CONTENT { slug: "alpha", name: "Alpha" };
    CREATE auth_organization:beta CONTENT { slug: "beta", name: "Beta" };
    CREATE auth_identity:admin CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "admin@lyxal.test" } };
    CREATE auth_identity:orga CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "orga@alpha.test" } };
    RELATE auth_identity:orga->auth_member_of->auth_organization:alpha;
    CREATE auth_session:admin CONTENT { identity: auth_identity:admin, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_session:orga CONTENT { identity: auth_identity:orga, organization: auth_organization:alpha, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    DEFINE TABLE test_ref SCHEMALESS PERMISSIONS FULL;
};

-- test: schéma par défaut
RETURN fn::auth_identity_schema_get({}).data.{ key, version, is_default } == { key: "default", version: 1, is_default: true };

-- test: nouvelle version d'un schéma
-- en tant que: admin
RETURN fn::auth_identity_schema_save({
    key: "default",
    traits: { fields: { email: { pipeline: [{ rule: "email", options: { max_length: 254 } }], required: true }, phone: { pipeline: [{ rule: "phone" }] } }, unknown_keys: "reject" },
    identifiers: [{ trait: "email", type: "email" }],
    verifiable: [{ trait: "email", channel: "email", usage: "verification" }]
}).data.version == 2;

-- test: dernière version par clé, version précise, défaut inchangé
RETURN fn::auth_identity_schema_get({ key: "default" }).data.version == 2
    AND fn::auth_identity_schema_get({ key: "default", version: 1 }).data.version == 1
    AND fn::auth_identity_schema_get({}).data.version == 1;

-- test: schéma dont un identifiant désigne un trait inconnu refusé
-- en tant que: admin
RETURN fn::auth_identity_schema_save({ key: "autre", traits: { fields: { email: { pipeline: [{ rule: "email" }] } } }, identifiers: [{ trait: "inconnu", type: "email" }] }).error.code == "AUTH_SCHEMA_INVALID";

-- test: schéma introuvable
RETURN fn::auth_identity_schema_get({ key: "inexistant" }).error.code == "AUTH_SCHEMA_INVALID";

-- test: sans permission, schéma refusé
-- en tant que: orga
RETURN fn::auth_identity_schema_save({ key: "pirate", traits: { fields: {} } }).error.code == "AUTH_PERMISSION_DENIED";

-- test: l'administrateur crée une identité ; identifiant et adresses déduits et normalisés
-- en tant que: admin
RETURN fn::auth_identity_create({ traits: { email: "Jean.Dupont@Exemple.FR", name: { first: "Jean", last: "Dupont" }, locale: "fr-FR" } }).data.traits.name.first == "Jean";

-- préparation: identifiant de Jean
CREATE test_ref:jean SET rid = <string> (SELECT VALUE identity FROM ONLY auth_credential_identifier WHERE value = "jean.dupont@exemple.fr" LIMIT 1);

-- test: identifiant e-mail en minuscules et deux adresses (vérification, récupération)
RETURN (SELECT VALUE value FROM auth_credential_identifier WHERE identity = <record> test_ref:jean.rid) == ["jean.dupont@exemple.fr"]
    AND array::len(SELECT * FROM auth_address WHERE identity = <record> test_ref:jean.rid) == 2;

-- test: création publiée (auth.identity.created)
RETURN array::len(SELECT * FROM event_outbox WHERE event_type = "auth.identity.created" AND payload.identity_id = test_ref:jean.rid) == 1;

-- test: un e-mail = une identité, quelle que soit la casse
-- en tant que: admin
RETURN fn::auth_identity_create({ traits: { email: "JEAN.DUPONT@exemple.fr" } }).error.code == "AUTH_IDENTIFIER_TAKEN";

-- test: traits invalides (e-mail mal formé, trait inconnu)
-- en tant que: admin
RETURN fn::auth_identity_create({ traits: { email: "pas-un-email" } }).error.code == "AUTH_TRAITS_INVALID"
    AND fn::auth_identity_create({ traits: { email: "ok@exemple.fr", inconnu: 1 } }).error.code == "AUTH_TRAITS_INVALID";

-- test: identifiant externe unique
-- en tant que: admin
RETURN fn::auth_identity_create({ traits: { email: "ext1@exemple.fr" }, external_id: "ERP-1" }).ok
    AND fn::auth_identity_create({ traits: { email: "ext2@exemple.fr" }, external_id: "ERP-1" }).error.code == "AUTH_IDENTIFIER_TAKEN";

-- test: l'administrateur d'une organisation crée un membre directement
-- en tant que: orga
RETURN fn::auth_identity_create({ traits: { email: "marie@alpha.test" }, organization: "auth_organization:alpha" }).ok;

-- test: le nouveau membre a le rôle par défaut
RETURN (SELECT VALUE ->auth_has_role->auth_role.key FROM ONLY auth_member_of WHERE in.traits.email = "marie@alpha.test" LIMIT 1) == ["organization_member"];

-- test: l'administrateur d'une organisation ne crée pas d'identité hors de son organisation
-- en tant que: orga
RETURN fn::auth_identity_create({ traits: { email: "hors@alpha.test" } }).error.code == "AUTH_PERMISSION_DENIED"
    AND fn::auth_identity_create({ traits: { email: "hors@alpha.test" }, organization: "auth_organization:beta" }).error.code == "AUTH_PERMISSION_DENIED";

-- préparation: Marie a une session sans permission, identifiant mémorisé
{
    LET $marie = (SELECT VALUE id FROM ONLY auth_identity WHERE traits.email = "marie@alpha.test" LIMIT 1);
    CREATE test_ref:marie SET rid = <string> $marie;
    CREATE auth_session:soi CONTENT { identity: $marie, organization: auth_organization:alpha, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_session:lecteur CONTENT { identity: $marie, organization: auth_organization:alpha, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
};

-- test: une identité lit sa fiche et ses adhésions, sans les métadonnées d'administration
-- en tant que: soi
RETURN fn::auth_identity_get({ identity: test_ref:marie.rid }).data.{ e: identifiers[0].value, m: array::len(memberships), a: admin_metadata } == { e: "marie@alpha.test", m: 1, a: NONE };

-- test: une identité ne lit pas celle d'une autre organisation
-- en tant que: soi
RETURN fn::auth_identity_get({ identity: test_ref:jean.rid }).error.code == "AUTH_IDENTITY_NOT_FOUND";

-- test: un membre lit les membres de son organisation (sans leurs adhésions)
-- en tant que: lecteur
RETURN fn::auth_identity_get({ identity: "auth_identity:orga" }).data.memberships == [];

-- test: l'administrateur lit tout, métadonnées comprises
-- en tant que: admin
RETURN fn::auth_identity_get({ identity: test_ref:jean.rid }).data.admin_metadata == {};

-- test: liste réservée à auth.identity.read
-- en tant que: admin
RETURN array::len(fn::auth_identity_list({}).data) >= 5 AND array::len(fn::auth_identity_list({ state: "locked" }).data) == 0;

-- test: liste refusée sans permission
-- en tant que: orga
RETURN fn::auth_identity_list({}).error.code == "AUTH_PERMISSION_DENIED";

-- test: modification des traits ; l'identifiant suit l'e-mail (auth.identity.manage)
-- en tant que: admin
RETURN fn::auth_identity_update_traits({ identity: test_ref:marie.rid, traits: { email: "Marie.Curie@alpha.test", name: { first: "Marie" } } }).data.traits.email == "Marie.Curie@alpha.test";

-- test: ancien identifiant retiré, nouveau créé, adresses remplacées
RETURN (SELECT VALUE value FROM auth_credential_identifier WHERE identity = <record> test_ref:marie.rid) == ["marie.curie@alpha.test"]
    AND (SELECT VALUE value FROM auth_address WHERE identity = <record> test_ref:marie.rid).distinct() == ["marie.curie@alpha.test"];

-- test: modification vers un e-mail déjà pris refusée
-- en tant que: admin
RETURN fn::auth_identity_update_traits({ identity: test_ref:marie.rid, traits: { email: "jean.dupont@exemple.fr" } }).error.code == "AUTH_IDENTIFIER_TAKEN";

-- test: un administrateur d'organisation ne modifie pas une identité hors de son organisation
-- en tant que: orga
RETURN fn::auth_identity_update_traits({ identity: test_ref:jean.rid, traits: { email: "pirate@exemple.fr" } }).error.code == "AUTH_PERMISSION_DENIED";

-- test: l'administrateur d'organisation modifie les autres traits d'un membre
-- en tant que: orga
RETURN fn::auth_identity_update_traits({ identity: test_ref:marie.rid, traits: { email: "marie.curie@alpha.test", name: { first: "Marie", last: "Curie" } } }).data.traits.name.last == "Curie";

-- test: l'administrateur d'organisation ne change pas l'e-mail d'un membre (prise de compte)
-- en tant que: orga
RETURN fn::auth_identity_update_traits({ identity: test_ref:marie.rid, traits: { email: "pirate@alpha.test" } }).error.{ code, reason: details.reason } == { code: "AUTH_PERMISSION_DENIED", reason: "identifier_change" }
    AND (SELECT VALUE value FROM auth_credential_identifier WHERE identity = <record> test_ref:marie.rid) == ["marie.curie@alpha.test"];

-- test: ni directement : identifiant, adresse et champs de sécurité intouchables
-- en tant que: orga
{
    LET $marie = <record> test_ref:marie.rid;
    UPDATE auth_credential_identifier SET value = "pirate@alpha.test" WHERE identity = $marie;
    UPDATE auth_address SET value = "pirate@alpha.test" WHERE identity = $marie;
    DELETE auth_address WHERE identity = $marie;
    CREATE auth_credential_identifier CONTENT { identity: $marie, type: "email", value: "pirate2@alpha.test" };
    CREATE auth_address CONTENT { identity: $marie, channel: "email", usage: "recovery", value: "pirate2@alpha.test", primary: false };
    UPDATE $marie SET available_aal = 0, state = "inactive", permissions_version = 1, not_before = NONE, membership_count = 0;
    RETURN true;
};

-- test: rien n'a changé
RETURN (SELECT VALUE value FROM auth_credential_identifier WHERE identity = <record> test_ref:marie.rid) == ["marie.curie@alpha.test"]
    AND (SELECT VALUE value FROM auth_address WHERE identity = <record> test_ref:marie.rid).distinct() == ["marie.curie@alpha.test"]
    AND (SELECT VALUE [state, membership_count] FROM ONLY <record> test_ref:marie.rid) == ["active", 1];

-- préparation: membre d'une seconde organisation, membre administrateur de la plateforme
{
    CREATE auth_identity:double CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "double@alpha.test" } };
    RELATE auth_identity:double->auth_member_of->auth_organization:alpha;
    RELATE auth_identity:double->auth_member_of->auth_organization:beta;
    CREATE auth_identity:plateforme CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "plateforme@alpha.test" } };
    RELATE auth_identity:plateforme->auth_member_of->auth_organization:alpha;
    RELATE auth_identity:plateforme->auth_has_role->auth_role:platform_admin;
};

-- test: compteurs tenus par la base ; l'administrateur d'organisation ne gère pas ces identités
-- en tant que: orga
RETURN (SELECT VALUE [membership_count, installation_role_count] FROM ONLY auth_identity:double) == [2, 0]
    AND (SELECT VALUE [membership_count, installation_role_count] FROM ONLY auth_identity:plateforme) == [1, 1]
    AND fn::auth_org_admin_can_manage({ identity: <record> test_ref:marie.rid })
    AND !fn::auth_org_admin_can_manage({ identity: auth_identity:double })
    AND !fn::auth_org_admin_can_manage({ identity: auth_identity:plateforme })
    AND fn::auth_identity_update_traits({ identity: "auth_identity:double", traits: { email: "double@alpha.test", name: { first: "D" } } }).error.code == "AUTH_PERMISSION_DENIED"
    AND fn::auth_identity_update_traits({ identity: "auth_identity:plateforme", traits: { email: "plateforme@alpha.test", name: { first: "P" } } }).error.code == "AUTH_PERMISSION_DENIED";

-- test: premier identifiant et première adresse seulement (création d'une identité)
-- en tant que: orga
RETURN !fn::auth_org_admin_first_identifier({ identity: <record> test_ref:marie.rid, type: "email" })
    AND fn::auth_org_admin_first_identifier({ identity: <record> test_ref:marie.rid, type: "username" })
    AND !fn::auth_org_admin_first_address({ identity: <record> test_ref:marie.rid, channel: "email", usage: "recovery" })
    AND !fn::auth_org_admin_first_identifier({ identity: auth_identity:double, type: "username" });

-- test: retrait d'une adhésion : compteur mis à jour
{
    DELETE auth_member_of WHERE in = auth_identity:double AND out = auth_organization:beta;
    RETURN (SELECT VALUE membership_count FROM ONLY auth_identity:double) == 1;
};

-- test: verrouillage : not_before posé, version des droits incrémentée
-- en tant que: admin
RETURN fn::auth_identity_set_state({ identity: test_ref:marie.rid, state: "locked" }).data.{ s: state, n: not_before IS NOT NONE, v: permissions_version } == { s: "locked", n: true, v: 2 };

-- test: la session de l'identité verrouillée est refusée dès l'opération suivante
-- en tant que: soi
RETURN fn::auth_context({}).error.code == "AUTH_IDENTITY_INACTIVE";

-- test: événement de changement d'état
RETURN (SELECT VALUE payload.state FROM ONLY event_outbox WHERE event_type = "auth.identity.state_changed" LIMIT 1) == "locked";

-- test: changement d'état réservé à auth.identity.manage
-- en tant que: orga
RETURN fn::auth_identity_set_state({ identity: test_ref:marie.rid, state: "active" }).error.code == "AUTH_PERMISSION_DENIED";

-- test: suppression définitive : l'identité ne revient pas
-- en tant que: admin
RETURN fn::auth_identity_set_state({ identity: test_ref:jean.rid, state: "deleted" }).data.state == "deleted"
    AND fn::auth_identity_set_state({ identity: test_ref:jean.rid, state: "active" }).error.code == "AUTH_IDENTITY_INACTIVE";

-- test: identité inconnue
-- en tant que: admin
RETURN fn::auth_identity_get({ identity: "auth_identity:fantome" }).error.code == "AUTH_IDENTITY_NOT_FOUND"
    AND fn::auth_identity_set_state({ identity: "auth_identity:fantome", state: "locked" }).error.code == "AUTH_IDENTITY_NOT_FOUND";

-- test: dérivation directe des identifiants et adresses
RETURN fn::auth_identity_derive({ schema: (SELECT * FROM ONLY auth_identity_schema:default_v1), traits: { email: " A@B.FR " } }).identifiers == [{ type: "email", value: "a@b.fr" }];

-- test: création par une organisation avec l'e-mail d'une identité qu'elle ne voit pas : annulée
-- en tant que: orga
-- attendu-erreur: AUTH_IDENTIFIER_TAKEN
fn::auth_identity_create({ traits: { email: "ext1@exemple.fr" }, organization: "auth_organization:alpha" });

-- test: rien n'a été créé par la tentative annulée
RETURN array::len(SELECT * FROM auth_credential_identifier WHERE value = "ext1@exemple.fr") == 1;
