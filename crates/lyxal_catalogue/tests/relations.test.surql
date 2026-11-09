-- lyxal-test: assertions
-- Relations entre articles : types, réciproques, règles métier (spécification commerciale,
-- remplacement sans cycle), isolation des relations privées.
--
-- identité sync: { "id": "auth_session:sync", "pv": 1, "permissions": ["catalogue.master.write"] }
-- identité alpha: { "id": "auth_session:alpha", "pv": 1, "permissions": ["catalogue.item.read", "catalogue.item.manage"] }
-- identité beta: { "id": "auth_session:beta", "pv": 1, "permissions": ["catalogue.item.read", "catalogue.item.manage"] }

-- préparation: organisations, identités et sessions lyxal_auth
{
    CREATE auth_organization:alpha CONTENT { slug: "alpha", name: "Alpha BTP" };
    CREATE auth_organization:beta CONTENT { slug: "beta", name: "Beta Bois" };
    CREATE auth_identity:sync CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "sync@lyxal.test" } };
    CREATE auth_session:sync CONTENT { identity: auth_identity:sync, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_identity:alpha CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "alpha@lyxal.test" } };
    RELATE auth_identity:alpha->auth_member_of->auth_organization:alpha;
    CREATE auth_session:alpha CONTENT { identity: auth_identity:alpha, organization: auth_organization:alpha, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_identity:beta CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "beta@lyxal.test" } };
    RELATE auth_identity:beta->auth_member_of->auth_organization:beta;
    CREATE auth_session:beta CONTENT { identity: auth_identity:beta, organization: auth_organization:beta, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
};

-- préparation: table de test lisible par toutes les identités
DEFINE TABLE test_ref SCHEMALESS PERMISSIONS FULL;

-- test: articles maîtres : un générique et trois commerciaux
-- en tant que: sync
RETURN [
    fn::catalogue_item_create({ code: "VIS-GEN", type: "catalogue_type:PRODUIT", libelle: "Vis générique", unite_reference: "base_unite:U", master_id: "M-VG" }).ok,
    fn::catalogue_item_create({ code: "VIS-A", type: "catalogue_type:PRODUIT", libelle: "Vis A", unite_reference: "base_unite:U", nature_reference: "COMMERCIALE", marque: "SPAX", master_id: "M-VA" }).ok,
    fn::catalogue_item_create({ code: "VIS-B", type: "catalogue_type:PRODUIT", libelle: "Vis B", unite_reference: "base_unite:U", nature_reference: "COMMERCIALE", marque: "SPAX", master_id: "M-VB" }).ok,
    fn::catalogue_item_create({ code: "VIS-C", type: "catalogue_type:PRODUIT", libelle: "Vis C", unite_reference: "base_unite:U", nature_reference: "COMMERCIALE", marque: "SPAX", statut_commercial: "OBSOLETE", master_id: "M-VC" }).ok
] == [true, true, true, true];

-- préparation: identifiants des articles
CREATE test_ref:items CONTENT object::from_entries((SELECT VALUE [string::replace(string::lowercase(code), "-", "_"), <string> id] FROM catalogue_item));

-- test: les types de relation sont lisibles par un locataire
-- en tant que: alpha
RETURN fn::catalogue_type_list({}).data.code == ["ENSEMBLE", "OUVRAGE", "PRODUIT", "RESSOURCE", "SERVICE"] AND (SELECT VALUE code FROM catalogue_relation_type ORDER BY code) CONTAINS "REMPLACEMENT";

-- test: relation bidirectionnelle : la réciproque est créée
-- en tant que: sync
RETURN fn::catalogue_relation_create({ source: test_ref:items.vis_a, cible: test_ref:items.vis_b, relation_type: "catalogue_relation_type:COMPATIBLE", commentaire: "" }).data.commentaire == NONE AND count(SELECT * FROM catalogue_relation WHERE relation_type = catalogue_relation_type:COMPATIBLE) == 2;

-- test: relation à sens unique : pas de réciproque
-- en tant que: sync
RETURN fn::catalogue_relation_create({ source: test_ref:items.vis_a, cible: test_ref:items.vis_gen, relation_type: "catalogue_relation_type:ACCESSOIRE", ordre: 1 }).ok AND count(SELECT * FROM catalogue_relation WHERE relation_type = catalogue_relation_type:ACCESSOIRE) == 1;

-- test: un article ne se relie pas à lui-même
-- en tant que: sync
RETURN fn::catalogue_relation_create({ source: test_ref:items.vis_a, cible: test_ref:items.vis_a, relation_type: "catalogue_relation_type:SIMILAIRE" }).error.code == "CATALOGUE_RELATION_SELF_REFERENCED";

-- test: un type de relation inconnu est refusé
-- en tant que: sync
RETURN fn::catalogue_relation_create({ source: test_ref:items.vis_a, cible: test_ref:items.vis_b, relation_type: "catalogue_relation_type:INCONNU" }).error.code == "CATALOGUE_RELATION_TYPE_NOT_FOUND";

-- test: un article inconnu est refusé
-- en tant que: sync
RETURN fn::catalogue_relation_create({ source: test_ref:items.vis_a, cible: "catalogue_item:inconnu", relation_type: "catalogue_relation_type:SIMILAIRE" }).error.code == "CATALOGUE_ITEM_NOT_FOUND";

-- test: spécification commerciale : d'un commercial vers un générique
-- en tant que: sync
RETURN fn::catalogue_relation_create({ source: test_ref:items.vis_a, cible: test_ref:items.vis_gen, relation_type: "catalogue_relation_type:COMMERCIAL_SPECIFICATION" }).ok;

-- test: spécification commerciale entre deux commerciaux refusée
-- en tant que: sync
RETURN fn::catalogue_relation_create({ source: test_ref:items.vis_a, cible: test_ref:items.vis_b, relation_type: "catalogue_relation_type:COMMERCIAL_SPECIFICATION" }).error.code == "CATALOGUE_RELATION_COMMERCIAL_SPEC_INVALID";

-- test: remplacement vers un article obsolète refusé
-- en tant que: sync
RETURN fn::catalogue_relation_create({ source: test_ref:items.vis_a, cible: test_ref:items.vis_c, relation_type: "catalogue_relation_type:REMPLACEMENT" }).error.code == "CATALOGUE_RELATION_REMPLACEMENT_TARGET_INVALID";

-- test: remplacement A → B accepté
-- en tant que: sync
RETURN fn::catalogue_relation_create({ source: test_ref:items.vis_a, cible: test_ref:items.vis_b, relation_type: "catalogue_relation_type:REMPLACEMENT" }).ok;

-- test: remplacement B → A refusé (cycle)
-- en tant que: sync
RETURN fn::catalogue_relation_create({ source: test_ref:items.vis_b, cible: test_ref:items.vis_a, relation_type: "catalogue_relation_type:REMPLACEMENT" }).error.code == "CATALOGUE_RELATION_REMPLACEMENT_CYCLE";

-- test: garde anti-cycle interne appelée directement
RETURN fn::catalogue_relation_check_cycle({ source: <record> test_ref:items.vis_b, cible: <record> test_ref:items.vis_a, relation_type: catalogue_relation_type:REMPLACEMENT }) IN [true, "CYCLE_DETECTED"];

-- test: un locataire ne relie pas deux articles maîtres
-- en tant que: alpha
RETURN fn::catalogue_relation_create({ source: test_ref:items.vis_b, cible: test_ref:items.vis_gen, relation_type: "catalogue_relation_type:ACCESSOIRE" }).ok == false;

-- test: Alpha relie son article privé à un article maître
-- en tant que: alpha
RETURN fn::catalogue_item_create({ code: "VIS-ALPHA", type: "catalogue_type:PRODUIT", libelle: "Vis Alpha", unite_reference: "base_unite:U" }).ok AND fn::catalogue_relation_create({ source: <string> (SELECT VALUE id FROM ONLY catalogue_item WHERE code = "VIS-ALPHA" LIMIT 1), cible: test_ref:items.vis_a, relation_type: "catalogue_relation_type:ACCESSOIRE" }).ok;

-- préparation: identifiants de l'article et de la relation d'Alpha
CREATE test_ref:alpha SET item = <string> (SELECT VALUE id FROM ONLY catalogue_item WHERE code = "VIS-ALPHA" LIMIT 1);

-- préparation: identifiant de la relation d'Alpha
UPDATE test_ref:alpha SET relation = <string> array::first(SELECT VALUE id FROM catalogue_relation WHERE source = <record> test_ref:alpha.item);

-- test: Beta ne voit pas la relation privée d'Alpha
-- en tant que: beta
RETURN (SELECT * FROM catalogue_relation WHERE source.code = "VIS-ALPHA") == [] AND (SELECT * FROM ONLY <record> test_ref:alpha.relation) == NONE;

-- test: l'agent de synchronisation ne voit pas la relation privée d'Alpha
-- en tant que: sync
RETURN (SELECT * FROM ONLY <record> test_ref:alpha.relation) == NONE;

-- test: Beta ne supprime pas la relation privée d'Alpha
-- en tant que: beta
RETURN fn::catalogue_relation_delete({ id: test_ref:alpha.relation }).error.code == "CATALOGUE_RELATION_NOT_FOUND";

-- test: Beta ne relie pas son article à l'article privé d'Alpha
-- en tant que: beta
RETURN fn::catalogue_item_create({ code: "VIS-BETA", type: "catalogue_type:PRODUIT", libelle: "Vis Beta", unite_reference: "base_unite:U" }).ok AND fn::catalogue_relation_create({ source: <string> (SELECT VALUE id FROM ONLY catalogue_item WHERE code = "VIS-BETA" LIMIT 1), cible: test_ref:alpha.item, relation_type: "catalogue_relation_type:ACCESSOIRE" }).error.code == "CATALOGUE_ITEM_NOT_FOUND";

-- test: Alpha supprime sa relation
-- en tant que: alpha
RETURN fn::catalogue_relation_delete({ id: test_ref:alpha.relation }).data.deleted == true;

-- test: suppression d'une relation bidirectionnelle et de sa réciproque
-- en tant que: sync
RETURN fn::catalogue_relation_delete({ id: <string> (SELECT VALUE id FROM ONLY catalogue_relation WHERE relation_type = catalogue_relation_type:COMPATIBLE LIMIT 1) }).ok AND count(SELECT * FROM catalogue_relation WHERE relation_type = catalogue_relation_type:COMPATIBLE) == 0;

-- test: une relation inconnue est introuvable
-- en tant que: sync
RETURN fn::catalogue_relation_delete({ id: "catalogue_relation:inconnue" }).error.code == "CATALOGUE_RELATION_NOT_FOUND";
