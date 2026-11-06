-- lyxal-test: assertions
-- Unités : le catalogue lit les unités par fn::base_unite_get (lyxal_base) et n'accepte qu'une
-- unité utilisable (unité et type actifs) ; ses champs vers base_unite empêchent la suppression
-- d'une unité utilisée (REFERENCE ON DELETE REJECT).
-- Exécuté par scripts/ci/test_lyxal_modules.py (format en tête du script).
--
-- identité sync: { "id": "catalogue_session:sync", "sub": "service:sync", "iss": "lyxal-os", "aud": "lyxal-catalogue", "role": "catalogue_sync_agent", "scope": ["catalogue:sync:write"] }

-- préparation: type d'unité de test
fn::base_unite_type_create({ code: "ESSAI", libelle: "Essai" });

-- préparation: unité active du type de test
fn::base_unite_create({ code: "ESS", libelle: "Essai", abreviation: "ess", type: "base_unite_type:ESSAI" });

-- préparation: type désactivé (l'unité reste active)
fn::base_unite_type_update({ id: "base_unite_type:ESSAI", enabled: false });

-- test: unité de conditionnement enregistrée au premier niveau
-- en tant que: sync
RETURN fn::catalogue_item_create({ code: "PLAQUE", type: "catalogue_type:PRODUIT", libelle: "Plaque", unite_reference: "base_unite:M2", unite_conditionnement: "base_unite:PCE", conditionnement: { quantite: 3 }, nature_reference: "commerciale", fabricant: "placo", reference_fabricant: "P-1", master_id: "M-P1" }).data.{ u: unite_conditionnement, q: conditionnement.quantite } == { u: base_unite:PCE, q: 3dec };

-- test: unité de conditionnement d'une autre table refusée
-- en tant que: sync
RETURN fn::catalogue_item_create({ code: "X1", type: "catalogue_type:PRODUIT", libelle: "x", unite_reference: "base_unite:M2", unite_conditionnement: "base_unite_type:LONGUEUR", nature_reference: "commerciale", fabricant: "placo", reference_fabricant: "R-X1", master_id: "M-X1" }).error.details.fields == { unite_conditionnement: ["CORE_VALIDATION_NOT_ALLOWED"] };

-- test: unité de référence dont le type est désactivé refusée
-- en tant que: sync
RETURN fn::catalogue_item_create({ code: "X2", type: "catalogue_type:PRODUIT", libelle: "x", unite_reference: "base_unite:ESS", nature_reference: "commerciale", fabricant: "placo", reference_fabricant: "R-X2", master_id: "M-X2" }).error.{ code, u: details.unite_reference } == { code: "CATALOGUE_ITEM_UNITE_INVALID", u: "base_unite:ESS" };

-- test: unité de conditionnement dont le type est désactivé refusée
-- en tant que: sync
RETURN fn::catalogue_item_create({ code: "X3", type: "catalogue_type:PRODUIT", libelle: "x", unite_reference: "base_unite:M2", unite_conditionnement: "base_unite:ESS", nature_reference: "commerciale", fabricant: "placo", reference_fabricant: "R-X3", master_id: "M-X3" }).error.details == { unite_conditionnement: "base_unite:ESS" };

-- test: unité inconnue refusée
-- en tant que: sync
RETURN fn::catalogue_item_create({ code: "X4", type: "catalogue_type:PRODUIT", libelle: "x", unite_reference: "base_unite:INCONNUE", nature_reference: "commerciale", fabricant: "placo", reference_fabricant: "R-X4", master_id: "M-X4" }).error.code == "CATALOGUE_ITEM_UNITE_INVALID";

-- test: attribut sur une unité dont le type est désactivé refusé
RETURN fn::catalogue_attribut_create({ code: "LARGEUR", libelle: "Largeur", type_donnee: "NUMBER", unite: "base_unite:ESS" }).error.code == "CATALOGUE_ATTRIBUT_UNITE_INVALID";

-- préparation: type de test réactivé
fn::base_unite_type_update({ id: "base_unite_type:ESSAI", enabled: true });

-- test: l'agent publie un article conditionné dans l'unité de test
-- en tant que: sync
RETURN fn::catalogue_item_create({ code: "BOITE", type: "catalogue_type:PRODUIT", libelle: "Boîte", unite_reference: "base_unite:U", unite_conditionnement: "base_unite:ESS", nature_reference: "commerciale", fabricant: "placo", reference_fabricant: "B-1", master_id: "M-B1" }).ok;

-- test: unité de conditionnement utilisée : lyxal_base refuse sa suppression
RETURN fn::base_unite_delete({ id: "base_unite:ESS" }).error.{ code, n: details.references } == { code: "BASE_UNITE_IN_USE", n: 1 };

-- test: les 4 champs vers base_unite refusent la suppression d'une unité référencée
RETURN [
    (INFO FOR TABLE catalogue_item).fields.unite_reference,
    (INFO FOR TABLE catalogue_item).fields.unite_conditionnement,
    (INFO FOR TABLE catalogue_composition_ligne).fields.unite,
    (INFO FOR TABLE catalogue_attribut).fields.unite
].all(|$f| string::contains($f, "REFERENCE ON DELETE REJECT"));
