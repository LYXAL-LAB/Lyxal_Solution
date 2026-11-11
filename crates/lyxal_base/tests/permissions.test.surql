-- lyxal-test: assertions
-- Permissions : les référentiels se lisent sous toute identité et ne s'écrivent que depuis une
-- session d'administration. Une écriture refusée renvoie BASE_WRITE_FORBIDDEN et n'écrit rien.
-- Exécuté par scripts/ci/test_lyxal_modules.py (format en tête du script).
--
-- identité utilisateur: { "id": "base_session:utilisateur", "sub": "user:alpha", "iss": "lyxal-os", "role": "tenant_user", "tenant_id": "alpha" }

-- préparation: type non système créé par l'administration
fn::base_unite_type_create({ code: "ESSAI", libelle: "Essai" });

-- préparation: type vide créé par l'administration
fn::base_unite_type_create({ code: "VIDE", libelle: "Vide" });

-- préparation: unité non système créée par l'administration
fn::base_unite_create({ code: "ESS", libelle: "Essai", abreviation: "ess", type: "base_unite_type:ESSAI" });

-- test: un utilisateur lit les unités
-- en tant que: utilisateur
RETURN fn::base_unite_get({ code: "M2" }).data.libelle == "Mètre carré";

-- test: un utilisateur liste les types
-- en tant que: utilisateur
RETURN array::len(fn::base_unite_type_list({}).data) >= 6;

-- test: un utilisateur ne crée pas de type
-- en tant que: utilisateur
RETURN fn::base_unite_type_create({ code: "PIRATE", libelle: "Pirate" }).error.code == "BASE_WRITE_FORBIDDEN";

-- test: rien n'a été créé
RETURN record::exists(base_unite_type:PIRATE) == false;

-- test: un utilisateur ne modifie pas un type
-- en tant que: utilisateur
RETURN fn::base_unite_type_update({ id: "base_unite_type:ESSAI", libelle: "Modifié" }).error.code == "BASE_WRITE_FORBIDDEN";

-- test: un utilisateur ne supprime pas un type
-- en tant que: utilisateur
RETURN fn::base_unite_type_delete({ id: "base_unite_type:VIDE" }).error.code == "BASE_WRITE_FORBIDDEN" AND record::exists(base_unite_type:VIDE);

-- test: un utilisateur ne crée pas d'unité
-- en tant que: utilisateur
RETURN fn::base_unite_create({ code: "PIR", libelle: "Pirate", abreviation: "pir", type: "base_unite_type:ESSAI" }).error.code == "BASE_WRITE_FORBIDDEN";

-- test: un utilisateur ne modifie pas une unité
-- en tant que: utilisateur
RETURN fn::base_unite_update({ id: "base_unite:ESS", enabled: false }).error.code == "BASE_WRITE_FORBIDDEN";

-- test: un utilisateur ne supprime pas une unité
-- en tant que: utilisateur
RETURN fn::base_unite_delete({ id: "base_unite:ESS" }).error.code == "BASE_WRITE_FORBIDDEN";

-- test: le type et l'unité sont intacts
RETURN fn::base_unite_type_get({ code: "ESSAI" }).data.libelle == "Essai" AND (SELECT VALUE enabled FROM ONLY base_unite:ESS) == true;

-- test: l'administration supprime l'unité puis le type
RETURN fn::base_unite_delete({ id: "base_unite:ESS" }).data.deleted == true AND fn::base_unite_type_delete({ id: "base_unite_type:ESSAI" }).data.deleted == true;
