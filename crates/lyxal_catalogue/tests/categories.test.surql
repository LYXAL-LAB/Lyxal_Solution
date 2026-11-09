-- lyxal-test: assertions
-- Catégories : création, arborescence, déplacement, gardes anti-cycle, suppression.
-- Le référentiel des catégories est administré (session root) ; les utilisateurs le lisent.
--
-- identité alpha: { "id": "auth_session:alpha", "pv": 1, "permissions": ["catalogue.item.read", "catalogue.item.manage"] }

-- préparation: organisations, identités et sessions lyxal_auth
{
    CREATE auth_organization:alpha CONTENT { slug: "alpha", name: "Alpha BTP" };
    CREATE auth_organization:beta CONTENT { slug: "beta", name: "Beta Bois" };
    CREATE auth_identity:alpha CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "alpha@lyxal.test" } };
    RELATE auth_identity:alpha->auth_member_of->auth_organization:alpha;
    CREATE auth_session:alpha CONTENT { identity: auth_identity:alpha, organization: auth_organization:alpha, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
};

-- test: création d'une catégorie racine
RETURN fn::catalogue_categorie_create({ code: " gros-oeuvre ", libelle: " Gros œuvre ", ordre: 1 }).data.{ code, libelle, ordre } == { code: "GROS-OEUVRE", libelle: "Gros œuvre", ordre: 1 };

-- préparation: table de test lisible par toutes les identités
DEFINE TABLE test_ref SCHEMALESS PERMISSIONS FULL;

-- préparation: identifiant de la racine
CREATE test_ref:racine SET id_cat = <string> (SELECT VALUE id FROM ONLY catalogue_categorie WHERE code = "GROS-OEUVRE" LIMIT 1);

-- test: création d'une sous-catégorie
RETURN fn::catalogue_categorie_create({ code: "MACONNERIE", libelle: "Maçonnerie", parent: test_ref:racine.id_cat }).ok;

-- préparation: identifiant de la sous-catégorie
CREATE test_ref:enfant SET id_cat = <string> (SELECT VALUE id FROM ONLY catalogue_categorie WHERE code = "MACONNERIE" LIMIT 1);

-- test: création d'une petite-fille
RETURN fn::catalogue_categorie_create({ code: "BLOCS", libelle: "Blocs béton", parent: test_ref:enfant.id_cat }).ok;

-- préparation: identifiant de la petite-fille
CREATE test_ref:petite_fille SET id_cat = <string> (SELECT VALUE id FROM ONLY catalogue_categorie WHERE code = "BLOCS" LIMIT 1);

-- test: un code déjà pris est refusé
RETURN fn::catalogue_categorie_create({ code: "maconnerie", libelle: "Doublon" }).error.code == "CATALOGUE_CATEGORIE_ALREADY_EXISTS";

-- test: un parent inconnu est refusé
RETURN fn::catalogue_categorie_create({ code: "ORPHELINE", libelle: "x", parent: "catalogue_categorie:inconnue" }).error.code == "CATALOGUE_CATEGORIE_NOT_FOUND";

-- test: un parent d'une autre table est refusé
RETURN fn::catalogue_categorie_create({ code: "ORPHELINE", libelle: "x", parent: "catalogue_item:x" }).error.details.fields == { parent: ["CORE_VALIDATION_NOT_ALLOWED"] };

-- test: l'arborescence regroupe les niveaux
RETURN (SELECT VALUE [code, children.code, children.children[0].code] FROM ONLY fn::catalogue_categorie_tree({}).data WHERE code = "GROS-OEUVRE" LIMIT 1) == ["GROS-OEUVRE", ["MACONNERIE"], ["BLOCS"]];

-- test: un locataire lit l'arborescence
-- en tant que: alpha
RETURN fn::catalogue_categorie_tree({}).data.code CONTAINS "GROS-OEUVRE";

-- test: un locataire ne crée pas de catégorie
-- en tant que: alpha
RETURN fn::catalogue_categorie_create({ code: "PIRATE", libelle: "x" }).error.{ code, http_status } == { code: "CATALOGUE_WRITE_FORBIDDEN", http_status: 403 };

-- test: un locataire ne modifie pas une catégorie
-- en tant que: alpha
RETURN fn::catalogue_categorie_update({ id: test_ref:racine.id_cat, libelle: "Piraté" }).error.code == "CATALOGUE_WRITE_FORBIDDEN";

-- test: un locataire ne supprime pas une catégorie
-- en tant que: alpha
RETURN fn::catalogue_categorie_delete({ id: test_ref:petite_fille.id_cat }).error.code == "CATALOGUE_WRITE_FORBIDDEN";

-- test: rien n'a été écrit par le locataire
RETURN (SELECT VALUE code FROM catalogue_categorie ORDER BY code) == ["BLOCS", "GROS-OEUVRE", "MACONNERIE"];

-- test: une catégorie ne devient pas son propre parent
RETURN fn::catalogue_categorie_update({ id: test_ref:racine.id_cat, parent: test_ref:racine.id_cat }).error.code == "CATALOGUE_CATEGORIE_CYCLE_DETECTED";

-- test: une catégorie ne passe pas sous sa descendante
RETURN fn::catalogue_categorie_update({ id: test_ref:racine.id_cat, parent: test_ref:petite_fille.id_cat }).error.code == "CATALOGUE_CATEGORIE_CYCLE_DETECTED";

-- test: renommage sans changer le parent
RETURN fn::catalogue_categorie_update({ id: test_ref:enfant.id_cat, libelle: "Maçonnerie générale" }).data.{ libelle, parent } == { libelle: "Maçonnerie générale", parent: <record> test_ref:racine.id_cat };

-- test: parent null : la catégorie devient racine
RETURN fn::catalogue_categorie_update({ id: test_ref:petite_fille.id_cat, parent: null }).data.parent IN [NONE, NULL];

-- test: la catégorie détachée apparaît à la racine
RETURN fn::catalogue_categorie_tree({}).data.code CONTAINS "BLOCS";

-- test: désactivation et filtre de l'arborescence
RETURN fn::catalogue_categorie_update({ id: test_ref:petite_fille.id_cat, enabled: false }).ok AND !(fn::catalogue_categorie_tree({ enabled: true }).data.code CONTAINS "BLOCS");

-- test: une catégorie avec des enfants ne se supprime pas
RETURN fn::catalogue_categorie_delete({ id: test_ref:racine.id_cat }).error.code == "CATALOGUE_CATEGORIE_HAS_CHILDREN";

-- test: suppression d'une feuille
RETURN fn::catalogue_categorie_delete({ id: test_ref:petite_fille.id_cat }).data.deleted == true;

-- test: une catégorie supprimée est introuvable
RETURN fn::catalogue_categorie_update({ id: test_ref:petite_fille.id_cat, libelle: "x" }).error.code == "CATALOGUE_CATEGORIE_NOT_FOUND";

-- test: un champ inconnu est refusé
RETURN fn::catalogue_categorie_create({ code: "X", libelle: "x", couleur: "rouge" }).error.details.fields == { couleur: ["CORE_VALIDATION_NOT_ALLOWED"] };

-- test: un libellé vide est refusé
RETURN fn::catalogue_categorie_create({ code: "X", libelle: "  " }).error.details.fields == { libelle: ["CORE_VALIDATION_BLANK"] };
