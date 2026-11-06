-- lyxal-test: assertions
-- Unités : création, lecture, liste, mise à jour, suppression ; hiérarchie avec le type (pas
-- d'unité active sur un type inactif) ; règle « utilisable pour un nouveau document ».
-- Exécuté par scripts/ci/test_lyxal_modules.py (format en tête du script).

-- préparation: type de test
fn::base_unite_type_create({ code: "ESSAI", libelle: "Essai" });

-- préparation: second type de test
fn::base_unite_type_create({ code: "AUTRE", libelle: "Autre" });

-- test: création : code en majuscules, libellé et abréviation tels que saisis
RETURN fn::base_unite_create({ code: "dm", libelle: " Décimètre ", abreviation: " dm ", type: "base_unite_type:ESSAI" }).data.{ id, code, libelle, abreviation, type, enabled, is_system } == { id: base_unite:DM, code: "DM", libelle: "Décimètre", abreviation: "dm", type: base_unite_type:ESSAI, enabled: true, is_system: false };

-- test: code déjà pris
RETURN fn::base_unite_create({ code: "DM", libelle: "x", abreviation: "x", type: "base_unite_type:ESSAI" }).error.code == "BASE_UNITE_ALREADY_EXISTS";

-- test: type parent inexistant
RETURN fn::base_unite_create({ code: "X", libelle: "x", abreviation: "x", type: "base_unite_type:INCONNU" }).error.{ code, t: details.type } == { code: "BASE_UNITE_TYPE_INVALID", t: "base_unite_type:INCONNU" };

-- test: lecture avec le détail du type
RETURN fn::base_unite_get({ id: "base_unite:DM", fetch_type: true }).data.{ t: type_detail.code, usable } == { t: "ESSAI", usable: true };

-- test: lecture d'une unité absente
RETURN fn::base_unite_get({ code: "INCONNUE" }).error.code == "BASE_UNITE_NOT_FOUND";

-- test: liste filtrée par type
RETURN fn::base_unite_list({ type: "base_unite_type:ESSAI" }).data.code == ["DM"];

-- test: liste paginée et triée par code
RETURN fn::base_unite_list({ limit: 3 }).data.code == ["BAR", "BTE", "CART"];

-- test: mise à jour du libellé et de l'abréviation
RETURN fn::base_unite_update({ id: "base_unite:DM", libelle: "Décimètres", abreviation: "dm." }).data.{ libelle, abreviation } == { libelle: "Décimètres", abreviation: "dm." };

-- test: changement de type vers un type actif
RETURN fn::base_unite_update({ id: "base_unite:DM", type: "base_unite_type:AUTRE" }).data.type == base_unite_type:AUTRE;

-- préparation: type AUTRE désactivé (l'unité DM reste active)
fn::base_unite_type_update({ id: "base_unite_type:AUTRE", enabled: false });

-- test: unité active sur un type désactivé : inutilisable
RETURN fn::base_unite_get({ code: "DM" }).data.{ enabled, usable } == { enabled: true, usable: false };

-- test: nouveaux documents : ni unité inactive ni unité d'un type inactif
RETURN !("DM" IN fn::base_unite_list({ for_new_documents: true, limit: 200 }).data.code)
    AND "M" IN fn::base_unite_list({ for_new_documents: true, limit: 200 }).data.code;

-- test: création refusée sur un type désactivé
RETURN fn::base_unite_create({ code: "Y", libelle: "y", abreviation: "y", type: "base_unite_type:AUTRE" }).error.code == "BASE_UNITE_TYPE_DISABLED";

-- test: rattachement refusé à un type désactivé
RETURN fn::base_unite_update({ id: "base_unite:M", type: "base_unite_type:AUTRE" }).error.code == "BASE_UNITE_TYPE_DISABLED";

-- test: désactivation de l'unité possible sur un type désactivé
RETURN fn::base_unite_update({ id: "base_unite:DM", enabled: false }).data.enabled == false;

-- test: réactivation refusée tant que le type est désactivé
RETURN fn::base_unite_update({ id: "base_unite:DM", enabled: true }).error.code == "BASE_UNITE_TYPE_DISABLED";

-- test: liste filtrée sur les unités inactives
RETURN fn::base_unite_list({ enabled: false }).data.code == ["DM"];

-- test: réactivation possible avec un retour vers un type actif dans la même mise à jour
RETURN fn::base_unite_update({ id: "base_unite:DM", type: "base_unite_type:ESSAI", enabled: true }).data.{ type, enabled } == { type: base_unite_type:ESSAI, enabled: true };

-- test: mise à jour d'une unité absente
RETURN fn::base_unite_update({ id: "base_unite:INCONNUE", libelle: "x" }).error.code == "BASE_UNITE_NOT_FOUND";

-- test: une unité système se désactive mais ne se supprime pas
RETURN fn::base_unite_delete({ id: "base_unite:KWH" }).error.code == "BASE_UNITE_IS_SYSTEM"
    AND fn::base_unite_update({ id: "base_unite:KWH", enabled: false }).data.enabled == false
    AND fn::base_unite_get({ code: "KWH" }).data.usable == false;

-- test: suppression d'une unité absente
RETURN fn::base_unite_delete({ id: "base_unite:INCONNUE" }).error.code == "BASE_UNITE_NOT_FOUND";

-- test: suppression d'une unité libre
RETURN fn::base_unite_delete({ id: "base_unite:DM" }).data == { id: "base_unite:DM", deleted: true };
