-- lyxal-test: assertions
-- Intégrité référentielle : une unité ou un type référencé par une autre table (champ déclaré
-- REFERENCE ON DELETE REJECT, comme ceux du catalogue) ne se supprime pas ; la fonction le dit
-- (BASE_*_IN_USE) et la base le refuse. lyxal_base ne connaît pas la table qui référence.
-- Exécuté par scripts/ci/test_lyxal_modules.py (format en tête du script).

-- préparation: table d'un module consommateur simulé
DEFINE TABLE test_consommateur SCHEMAFULL PERMISSIONS FULL;

-- préparation: champ de référence vers une unité
DEFINE FIELD unite ON test_consommateur TYPE option<record<base_unite>> REFERENCE ON DELETE REJECT;

-- préparation: type non système
fn::base_unite_type_create({ code: "ESSAI", libelle: "Essai" });

-- préparation: unité non système de ce type
fn::base_unite_create({ code: "ESS", libelle: "Essai", abreviation: "ess", type: "base_unite_type:ESSAI" });

-- préparation: unité référencée par la table consommatrice
CREATE test_consommateur:ligne SET unite = base_unite:ESS;

-- test: unité référencée : suppression refusée, avec le nombre de références
RETURN fn::base_unite_delete({ id: "base_unite:ESS" }).error.{ code, n: details.references } == { code: "BASE_UNITE_IN_USE", n: 1 };

-- test: type portant une unité : suppression refusée
RETURN fn::base_unite_type_delete({ id: "base_unite_type:ESSAI" }).error.{ code, n: details.references } == { code: "BASE_UNITE_TYPE_IN_USE", n: 1 };

-- test: la base refuse elle aussi la suppression d'un type portant des unités (ON DELETE REJECT)
RETURN string::contains((INFO FOR TABLE base_unite).fields.type, "REFERENCE ON DELETE REJECT");

-- test: l'unité et le type sont intacts
RETURN record::exists(base_unite:ESS) AND record::exists(base_unite_type:ESSAI);

-- test: unité système : suppression refusée avant tout
RETURN fn::base_unite_delete({ id: "base_unite:M" }).error.code == "BASE_UNITE_IS_SYSTEM";

-- préparation: la référence disparaît
UPDATE test_consommateur:ligne SET unite = NONE;

-- test: unité libre : suppression acceptée
RETURN fn::base_unite_delete({ id: "base_unite:ESS" }).data.deleted == true AND !record::exists(base_unite:ESS);

-- test: type libre : suppression acceptée
RETURN fn::base_unite_type_delete({ id: "base_unite_type:ESSAI" }).data.deleted == true;
