-- lyxal-test: assertions
-- Types d'unités : création, lecture, liste, mise à jour, suppression ; socle système.
-- Exécuté par scripts/ci/test_lyxal_modules.py (format en tête du script).

-- test: création : code nettoyé et mis en majuscules, libellé tel que saisi, actif, non système
RETURN fn::base_unite_type_create({ code: " temperature ", libelle: "  Température  " }).data.{ id, code, libelle, enabled, is_system } == { id: base_unite_type:TEMPERATURE, code: "TEMPERATURE", libelle: "Température", enabled: true, is_system: false };

-- test: horodatages posés par le schéma
RETURN (SELECT VALUE created_at != NONE AND updated_at != NONE FROM ONLY base_unite_type:TEMPERATURE) == true;

-- test: code déjà pris (casse indifférente)
RETURN fn::base_unite_type_create({ code: "Temperature", libelle: "Doublon" }).error.{ code, c: details.code } == { code: "BASE_UNITE_TYPE_ALREADY_EXISTS", c: "TEMPERATURE" };

-- test: lecture par identifiant
RETURN fn::base_unite_type_get({ id: "base_unite_type:TEMPERATURE" }).data.libelle == "Température";

-- test: lecture d'un type absent
RETURN fn::base_unite_type_get({ code: "INCONNU" }).error.{ code, id: details.id } == { code: "BASE_UNITE_TYPE_NOT_FOUND", id: "base_unite_type:INCONNU" };

-- test: liste triée par code
RETURN fn::base_unite_type_list({}).data.code == array::sort(fn::base_unite_type_list({}).data.code);

-- test: liste paginée
RETURN fn::base_unite_type_list({ limit: 2, start: 1 }).data.code == ["DEBIT", "DUREE"];

-- test: mise à jour du libellé
RETURN fn::base_unite_type_update({ id: "base_unite_type:TEMPERATURE", libelle: " Températures " }).data.{ libelle, enabled } == { libelle: "Températures", enabled: true };

-- test: désactivation
RETURN fn::base_unite_type_update({ id: "base_unite_type:TEMPERATURE", enabled: false }).data.enabled == false;

-- test: liste filtrée sur les types inactifs
RETURN fn::base_unite_type_list({ enabled: false }).data.code == ["TEMPERATURE"];

-- test: liste filtrée sur les types actifs
RETURN !("TEMPERATURE" IN fn::base_unite_type_list({ enabled: true }).data.code);

-- test: mise à jour d'un type absent
RETURN fn::base_unite_type_update({ id: "base_unite_type:INCONNU", enabled: true }).error.code == "BASE_UNITE_TYPE_NOT_FOUND";

-- test: un type système se désactive mais ne se supprime pas
RETURN fn::base_unite_type_delete({ id: "base_unite_type:DEBIT" }).error.code == "BASE_UNITE_TYPE_IS_SYSTEM"
    AND fn::base_unite_type_update({ id: "base_unite_type:DEBIT", enabled: false }).data.enabled == false
    AND fn::base_unite_type_update({ id: "base_unite_type:DEBIT", enabled: true }).data.enabled == true;

-- test: suppression d'un type absent
RETURN fn::base_unite_type_delete({ id: "base_unite_type:INCONNU" }).error.code == "BASE_UNITE_TYPE_NOT_FOUND";

-- test: suppression d'un type libre
RETURN fn::base_unite_type_delete({ id: "base_unite_type:TEMPERATURE" }).data == { id: "base_unite_type:TEMPERATURE", deleted: true } AND !record::exists(base_unite_type:TEMPERATURE);

-- test: messages d'erreur résolus en anglais
RETURN fn::base_unite_type_get({ code: "INCONNU", language: "en" }).error.label == "Unit type not found";

-- test: les 13 codes du module sont définis
RETURN array::len(SELECT id FROM error_definition WHERE string::starts_with(code, "BASE_")) == 13
    AND [
        "BASE_INVALID_PARAMETERS", "BASE_NO_UPDATABLE_FIELDS_PROVIDED", "BASE_WRITE_FORBIDDEN",
        "BASE_UNITE_TYPE_NOT_FOUND", "BASE_UNITE_TYPE_ALREADY_EXISTS", "BASE_UNITE_TYPE_IS_SYSTEM", "BASE_UNITE_TYPE_IN_USE",
        "BASE_UNITE_NOT_FOUND", "BASE_UNITE_ALREADY_EXISTS", "BASE_UNITE_IS_SYSTEM", "BASE_UNITE_IN_USE",
        "BASE_UNITE_TYPE_INVALID", "BASE_UNITE_TYPE_DISABLED"
    ].all(|$c| record::exists(type::record("error_definition", $c)));
