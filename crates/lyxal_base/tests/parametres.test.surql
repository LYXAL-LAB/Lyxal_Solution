-- lyxal-test: assertions
-- Entrées : chaque fonction publique valide et nettoie ses paramètres par lyxal_core ; une donnée
-- invalide renvoie BASE_INVALID_PARAMETERS (détail par champ dans details.fields), sans erreur
-- levée. Exécuté par scripts/ci/test_lyxal_modules.py (format en tête du script).

-- test: langue d'un mauvais type
RETURN fn::base_unite_get({ code: "M", language: 42 }).error.{ code, f: details.fields } == { code: "BASE_INVALID_PARAMETERS", f: { language: ["CORE_VALIDATION_TYPE"] } };

-- test: langue anglaise respectée dans le message
RETURN fn::base_unite_list({ limit: 0, language: "en" }).error.label == "Invalid parameters";

-- test: champ inconnu refusé
RETURN fn::base_unite_type_list({ actif: true }).error.details.fields == { actif: ["CORE_VALIDATION_NOT_ALLOWED"] };

-- test: booléen attendu (aucune conversion implicite)
RETURN fn::base_unite_type_update({ id: "base_unite_type:LONGUEUR", enabled: "oui" }).error.details.fields == { enabled: ["CORE_VALIDATION_TYPE"] };

-- test: pagination hors bornes
RETURN fn::base_unite_type_list({ limit: 500, start: -1 }).error.details.fields == { limit: ["CORE_VALIDATION_TOO_LARGE"], start: ["CORE_VALIDATION_TOO_SMALL"] };

-- test: limite non entière
RETURN fn::base_unite_list({ limit: "abc" }).error.details.fields.limit == ["CORE_VALIDATION_TYPE"];

-- test: champs obligatoires absents à la création d'une unité
RETURN fn::base_unite_create({}).error.details.fields == { abreviation: ["CORE_VALIDATION_REQUIRED"], code: ["CORE_VALIDATION_REQUIRED"], libelle: ["CORE_VALIDATION_REQUIRED"], type: ["CORE_VALIDATION_REQUIRED"] };

-- test: code non alphanumérique
RETURN fn::base_unite_type_create({ code: "LONG-UEUR", libelle: "x" }).error.details.fields.code == ["CORE_VALIDATION_FORMAT"];

-- test: libellé vide après suppression des espaces
RETURN fn::base_unite_type_create({ code: "X", libelle: "   " }).error.details.fields.libelle == ["CORE_VALIDATION_BLANK"];

-- test: abréviation trop longue
RETURN fn::base_unite_create({ code: "X", libelle: "x", abreviation: "abcdefghijk", type: "base_unite_type:LONGUEUR" }).error.details.fields.abreviation == ["CORE_VALIDATION_TOO_LONG"];

-- test: identifiant natif refusé (identifiants transmis en texte)
RETURN fn::base_unite_delete({ id: base_unite:M }).error.details.fields == { id: ["CORE_VALIDATION_TYPE"] };

-- test: identifiant d'une autre table refusé à la suppression d'un type (rien n'est supprimé)
RETURN fn::base_unite_type_delete({ id: "error_definition:BASE_WRITE_FORBIDDEN" }).error.details.fields == { id: ["CORE_VALIDATION_NOT_ALLOWED"] } AND record::exists(error_definition:BASE_WRITE_FORBIDDEN);

-- test: identifiant d'une autre table refusé à la mise à jour d'une unité
RETURN fn::base_unite_update({ id: "base_unite_type:LONGUEUR", libelle: "x" }).error.details.fields == { id: ["CORE_VALIDATION_NOT_ALLOWED"] };

-- test: identifiant d'une autre table refusé en lecture
RETURN fn::base_unite_get({ id: "error_definition:BASE_WRITE_FORBIDDEN" }).error.details.fields == { id: ["CORE_VALIDATION_NOT_ALLOWED"] };

-- test: type d'une autre table refusé
RETURN fn::base_unite_create({ code: "X", libelle: "x", abreviation: "x", type: "base_unite:M" }).error.details.fields == { type: ["CORE_VALIDATION_NOT_ALLOWED"] };

-- test: ni identifiant ni code
RETURN fn::base_unite_type_get({}).error.details.fields == { code: ["CORE_VALIDATION_REQUIRED"], id: ["CORE_VALIDATION_REQUIRED"] };

-- test: aucun champ modifiable
RETURN fn::base_unite_update({ id: "base_unite:M" }).error.code == "BASE_NO_UPDATABLE_FIELDS_PROVIDED";

-- test: type par identifiant texte dans la liste (5 longueurs)
RETURN array::len(fn::base_unite_list({ type: "base_unite_type:LONGUEUR" }).data) == 5;

-- test: lecture par identifiant texte
RETURN fn::base_unite_get({ id: "base_unite:M" }).data.{ code, libelle, usable } == { code: "M", libelle: "Mètre", usable: true };

-- test: code nettoyé avant lecture
RETURN fn::base_unite_type_get({ code: " longueur " }).data.libelle == "Longueur";
