-- lyxal-test: assertions
-- Permissions : définitions, correspondances et occurrences ne s'écrivent que depuis une session
-- d'administration. Sous une identité, chaque écriture renvoie ERROR_WRITE_FORBIDDEN (jamais un
-- succès) et rien n'est écrit. Exécuté par scripts/ci/test_lyxal_modules.py.
--
-- identité utilisateur: { "id": "user:tester", "sub": "user:tester", "iss": "lyxal-os", "role": "tenant_user", "tenant_id": "alpha" }

-- préparation: définition créée par l'administration
fn::error_definition_create({ code: "DEMO_PANNE", module: "demo", message: "Demo failure" });

-- préparation: correspondance créée par l'administration
fn::error_mapping_create({ provider: "demo_pay", external_code: "declined", definition_code: "DEMO_PANNE" });

-- préparation: occurrence journalisée par l'administration
fn::error_log({ code: "DEMO_PANNE", source_module: "demo" });

-- test: un utilisateur lit les définitions
-- en tant que: utilisateur
RETURN fn::error_definition_get({ code: "DEMO_PANNE" }).data.code == "DEMO_PANNE";

-- test: un utilisateur ne crée pas de définition
-- en tant que: utilisateur
RETURN fn::error_definition_create({ code: "DEMO_PIRATE", module: "demo", message: "Pirate" }).error.code == "ERROR_WRITE_FORBIDDEN";

-- test: rien n'a été créé
RETURN record::exists(error_definition:DEMO_PIRATE) == false;

-- test: un utilisateur ne modifie pas de définition
-- en tant que: utilisateur
RETURN fn::error_definition_update({ code: "DEMO_PANNE", message: "Pirate" }).error.code == "ERROR_WRITE_FORBIDDEN";

-- test: un utilisateur ne désactive pas de définition
-- en tant que: utilisateur
RETURN fn::error_definition_disable({ code: "DEMO_PANNE" }).error.code == "ERROR_WRITE_FORBIDDEN";

-- test: la définition est intacte
RETURN error_definition:DEMO_PANNE.message == "Demo failure" AND error_definition:DEMO_PANNE.enabled == true;

-- test: un utilisateur ne crée pas de correspondance
-- en tant que: utilisateur
RETURN fn::error_mapping_create({ provider: "demo_pay", external_code: "fraud", definition_code: "DEMO_PANNE" }).error.code == "ERROR_WRITE_FORBIDDEN";

-- test: un utilisateur ne voit ni ne modifie les correspondances
-- en tant que: utilisateur
RETURN fn::error_mapping_update({ mapping_id: (SELECT VALUE id FROM ONLY error_external_mapping LIMIT 1) ?? error_external_mapping:inconnu, priority: 9 }).ok == false
    AND fn::error_mapping_disable({ mapping_id: error_external_mapping:inconnu }).ok == false;

-- test: une seule correspondance, intacte
RETURN array::len(SELECT * FROM error_external_mapping) == 1
    AND (SELECT VALUE priority FROM ONLY error_external_mapping LIMIT 1) == 100
    AND (SELECT VALUE enabled FROM ONLY error_external_mapping LIMIT 1) == true;

-- test: un utilisateur ne journalise pas d'occurrence
-- en tant que: utilisateur
RETURN fn::error_log({ code: "DEMO_PANNE", source_module: "demo" }).error.code == "ERROR_WRITE_FORBIDDEN";

-- test: un utilisateur ne purge pas le journal
-- en tant que: utilisateur
RETURN fn::error_occurrence_purge_before({ before_date: d"2099-01-01T00:00:00Z" }).error.code == "ERROR_WRITE_FORBIDDEN";

-- test: le journal contient toujours la seule occurrence de l'administration
RETURN array::len(SELECT * FROM error_occurrence) == 1;
