-- lyxal-test: assertions
-- Entrées invalides : chaque fonction publique les refuse par CATALOGUE_INVALID_PARAMETERS
-- (détail par champ dans details.fields), sans lever d'erreur.

-- test: langue d'un mauvais type
RETURN fn::catalogue_type_list({ language: 42 }).error.{ code, f: details.fields } == { code: "CATALOGUE_INVALID_PARAMETERS", f: { language: ["CORE_VALIDATION_TYPE"] } };

-- test: langue anglaise respectée dans le message
RETURN fn::catalogue_item_list({ limit: 0, language: "en" }).error.label == "Invalid parameters";

-- test: champ inconnu
RETURN fn::catalogue_categorie_tree({ profondeur: 2 }).error.details.fields == { profondeur: ["CORE_VALIDATION_NOT_ALLOWED"] };

-- test: booléen attendu
RETURN fn::catalogue_type_list({ enabled: "oui" }).error.details.fields == { enabled: ["CORE_VALIDATION_TYPE"] };

-- test: identifiant natif refusé (identifiants transmis en chaîne)
RETURN fn::catalogue_item_delete({ id: catalogue_item:x }).error.details.fields == { id: ["CORE_VALIDATION_TYPE"] };

-- test: identifiant d'une autre table refusé
RETURN fn::catalogue_relation_delete({ id: "catalogue_item:x" }).error.details.fields == { id: ["CORE_VALIDATION_NOT_ALLOWED"] };

-- test: champs obligatoires absents
RETURN fn::catalogue_item_create({}).error.details.fields == { code: ["CORE_VALIDATION_REQUIRED"], libelle: ["CORE_VALIDATION_REQUIRED"], type: ["CORE_VALIDATION_REQUIRED"], unite_reference: ["CORE_VALIDATION_REQUIRED"] };

-- test: GTIN à clé de contrôle fausse
RETURN fn::catalogue_item_create({ code: "X", type: "catalogue_type:PRODUIT", libelle: "x", unite_reference: "base_unite:U", code_barre: "4006381333932" }).error.details.fields.code_barre == ["CORE_VALIDATION_FORMAT"];

-- test: statut commercial hors liste
RETURN fn::catalogue_item_update({ id: "catalogue_item:x", statut_commercial: "SOLDE" }).error.details.fields == { statut_commercial: ["CORE_VALIDATION_NOT_ALLOWED"] };

-- test: catégories : élément invalide signalé par position
RETURN fn::catalogue_item_create({ code: "X", type: "catalogue_type:PRODUIT", libelle: "x", unite_reference: "base_unite:U", categories: ["catalogue_categorie:a", { id: "catalogue_categorie:b", is_primary: "oui" }] }).error.details.fields.categories[0].{ index, is_primary } == { index: 1, is_primary: "CORE_VALIDATION_TYPE" };

-- test: pagination hors bornes
RETURN fn::catalogue_item_list({ limit: 500, start: -1 }).error.details.fields == { limit: ["CORE_VALIDATION_TOO_LARGE"], start: ["CORE_VALIDATION_TOO_SMALL"] };

-- test: ni identifiant ni code
RETURN fn::catalogue_item_get({}).error.code == "CATALOGUE_INVALID_PARAMETERS";

-- test: ordre négatif
RETURN fn::catalogue_categorie_create({ code: "X", libelle: "x", ordre: -1 }).error.details.fields == { ordre: ["CORE_VALIDATION_TOO_SMALL"] };

-- test: liste de documents qui n'est pas une liste d'objets
RETURN fn::catalogue_item_create({ code: "X", type: "catalogue_type:PRODUIT", libelle: "x", unite_reference: "base_unite:U", documents: ["fiche.pdf"] }).error.details.fields.documents != NONE;

-- test: combinaison absente
RETURN fn::catalogue_variante_set_attributs({ variante_id: "catalogue_variante:x", item_id: "catalogue_item:x" }).error.details.fields == { attributs: ["CORE_VALIDATION_REQUIRED"] };

-- test: composition : quantité non numérique
RETURN fn::catalogue_composition_add_line({ composition_id: "catalogue_composition:x", composant_item: "catalogue_item:x", quantite: "deux", unite: "base_unite:U" }).error.details.fields == { quantite: ["CORE_VALIDATION_TYPE"] };

-- test: introuvables après validation
RETURN [
    fn::catalogue_composition_create({ parent_item: "catalogue_item:inconnu" }).error.code,
    fn::catalogue_composition_publish({ composition_id: "catalogue_composition:inconnue" }).error.code,
    fn::catalogue_composition_clone_version({ source_composition_id: "catalogue_composition:inconnue" }).error.code,
    fn::catalogue_categorie_delete({ id: "catalogue_categorie:inconnue" }).error.code,
    fn::catalogue_attribut_set_static({ item_id: "catalogue_item:inconnu", attribut_id: "catalogue_attribut:a", valeur_id: "catalogue_attribut_valeur:v" }).error.code,
    fn::catalogue_variante_create({ item_id: "catalogue_item:inconnu", code: "V" }).error.code
] == ["CATALOGUE_ITEM_NOT_FOUND", "CATALOGUE_COMPOSITION_NOT_FOUND", "CATALOGUE_COMPOSITION_NOT_FOUND", "CATALOGUE_CATEGORIE_NOT_FOUND", "CATALOGUE_ITEM_NOT_FOUND", "CATALOGUE_ITEM_NOT_FOUND"];

-- test: chaque code émis par une fonction a sa définition
RETURN array::len(SELECT * FROM error_definition WHERE code IN ["CATALOGUE_INVALID_PARAMETERS", "CATALOGUE_WRITE_FORBIDDEN", "CATALOGUE_VARIANTE_DUPLICATE_COMBINAISON"]) == 3;
