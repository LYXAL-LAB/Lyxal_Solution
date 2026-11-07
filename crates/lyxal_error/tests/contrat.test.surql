-- lyxal-test: assertions
-- Contrat des fonctions de lyxal_error en session d'administration : résultat universel,
-- résolution, définitions, correspondances externes et journal des occurrences.
-- Exécuté par scripts/ci/test_lyxal_modules.py (format en tête du script).

-- test: fn::error_result renvoie le contrat d'échec avec le libellé traduit
RETURN fn::error_result("ERROR_DEFINITION_NOT_FOUND", "fr", { code: "X" }).ok == false
    AND fn::error_result("ERROR_DEFINITION_NOT_FOUND", "fr", { code: "X" }).error.code == "ERROR_DEFINITION_NOT_FOUND";

-- test: fn::error_resolve donne le libellé de la langue demandée
RETURN fn::error_resolve("ERROR_WRITE_FORBIDDEN", "fr", NONE).label == "Écriture refusée";

-- test: une définition est créée
RETURN fn::error_definition_create({ code: "DEMO_PANNE", module: "demo", message: "Demo failure" }).data.code == "DEMO_PANNE";

-- test: une définition se lit
RETURN fn::error_definition_get({ code: "DEMO_PANNE" }).data.message == "Demo failure";

-- test: les définitions du module se listent
RETURN array::len(fn::error_definition_list({ module: "demo" }).data) == 1;

-- test: une définition se modifie
RETURN fn::error_definition_update({ code: "DEMO_PANNE", message: "Demo outage" }).data.message == "Demo outage";

-- test: une correspondance externe est créée
RETURN fn::error_mapping_create({ provider: "demo_pay", external_code: "declined", definition_code: "DEMO_PANNE" }).data.external_code == "declined";

-- test: une erreur externe se résout par la correspondance
RETURN fn::error_map_external({ provider: "demo_pay", external_code: "declined" }).data.definition_code == "DEMO_PANNE";

-- test: une correspondance se liste et se lit
RETURN fn::error_mapping_get({ mapping_id: (fn::error_mapping_list({ provider: "demo_pay" }).data)[0].id }).data.external_code == "declined";

-- test: une correspondance se modifie
RETURN fn::error_mapping_update({ mapping_id: (SELECT VALUE id FROM ONLY error_external_mapping LIMIT 1), priority: 5 }).data.priority == 5;

-- test: une correspondance se désactive
RETURN fn::error_mapping_disable({ mapping_id: (SELECT VALUE id FROM ONLY error_external_mapping LIMIT 1) }).data.disabled == true;

-- test: une occurrence est journalisée (logged = true)
RETURN fn::error_log({ code: "DEMO_PANNE", source_module: "demo", environment: "test" }).data.occurrence.code == "DEMO_PANNE";

-- test: le journal contient l'occurrence, marquée journalisée
RETURN array::len(SELECT * FROM error_occurrence WHERE code = "DEMO_PANNE") == 1;

-- test: une occurrence se liste et se lit
RETURN fn::error_occurrence_get({ occurrence_id: (fn::error_occurrence_list({ source_module: "demo" }).data)[0].id }).data.code == "DEMO_PANNE";

-- préparation: définition sans journalisation
fn::error_definition_create({ code: "DEMO_SILENCE", module: "demo", message: "Silent", log_occurrence: false });

-- test: une définition sans journalisation n'écrit rien (logged = false)
RETURN fn::error_log({ code: "DEMO_SILENCE", source_module: "demo" }).data == { logged: false, occurrence: NONE };

-- test: aucune occurrence n'a été écrite pour ce code
RETURN array::len(SELECT * FROM error_occurrence WHERE code = "DEMO_SILENCE") == 0;

-- test: une définition se désactive
RETURN fn::error_definition_disable({ code: "DEMO_PANNE" }).data.disabled == true;

-- test: la purge supprime les occurrences antérieures à la date
RETURN fn::error_occurrence_purge_before({ before_date: d"2099-01-01T00:00:00Z" }).data.count == 1;
