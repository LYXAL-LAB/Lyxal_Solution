-- lyxal-test: assertions
-- Conversions : facteur de chaque unité vers l'unité de base de son type, fn::base_unite_convert
-- (calcul décimal, sans arrondi), refus (types différents, unité non convertible, inactive ou
-- inconnue), gardes de l'unité de base. Lecture ouverte à toute identité.
-- Exécuté par scripts/ci/test_lyxal_modules.py (format en tête du script).
--
-- identité utilisateur: { "id": "base_session:utilisateur", "sub": "user:alpha", "iss": "lyxal-os", "role": "tenant_user", "tenant_id": "alpha" }

-- test: socle : unité de base de chaque type convertible, de ce type et de facteur 1
RETURN (SELECT VALUE [code, base_unit] FROM base_unite_type WHERE base_unit != NONE ORDER BY code) == [
        ["DEBIT", base_unite:M3H], ["DUREE", base_unite:H], ["ENERGIE", base_unite:KWH], ["LONGUEUR", base_unite:M], ["MASSE", base_unite:KG],
        ["PRESSION", base_unite:BAR], ["PUISSANCE", base_unite:W], ["SURFACE", base_unite:M2], ["VOLUME", base_unite:M3]
    ]
    AND array::len(SELECT id FROM base_unite_type WHERE base_unit != NONE AND (base_unit.type != id OR base_unit.factor != 1dec)) == 0;

-- test: socle : facteurs des 19 unités convertibles
RETURN object::from_entries((SELECT VALUE [code, factor] FROM base_unite WHERE factor != NONE)) == {
    KM: 1000dec, M: 1dec, ML: 1dec, CM: 0.01dec, MM: 0.001dec, HA: 10000dec, M2: 1dec, M3: 1dec, LTR: 0.001dec,
    T: 1000dec, KG: 1dec, G: 0.001dec, SEM: 168dec, J: 24dec, H: 1dec, KWH: 1dec, W: 1dec, BAR: 1dec, M3H: 1dec
};

-- test: socle : mois, quantités et conditionnements sans facteur
RETURN array::sort((SELECT VALUE code FROM base_unite WHERE factor == NONE)) == ["BTE", "CART", "ENS", "FORFAIT", "MOIS", "PAIRE", "PAL", "PCE", "ROUL", "SAC", "U"];

-- test: CM → M, résultat décimal
RETURN fn::base_unite_convert({ quantity: 250, from: "CM", to: "M" }).data == { quantity: 2.5dec, from: "CM", to: "M" }
    AND type::is_decimal(fn::base_unite_convert({ quantity: 250, from: "CM", to: "M" }).data.quantity);

-- test: KG → T, HA → M2, H → J
RETURN fn::base_unite_convert({ quantity: 1500, from: "KG", to: "T" }).data.quantity == 1.5dec
    AND fn::base_unite_convert({ quantity: 2, from: "HA", to: "M2" }).data.quantity == 20000dec
    AND fn::base_unite_convert({ quantity: 48, from: "H", to: "J" }).data.quantity == 2dec;

-- test: codes nettoyés (espaces, casse) ; mètre linéaire et mètre équivalents
RETURN fn::base_unite_convert({ quantity: 3, from: " ml ", to: "mm" }).data == { quantity: 3000dec, from: "ML", to: "MM" };

-- test: quantité à virgule : aucune erreur d'arrondi binaire
RETURN fn::base_unite_convert({ quantity: 0.1, from: "M", to: "MM" }).data.quantity == 100dec
    AND fn::base_unite_convert({ quantity: 0.3, from: "KM", to: "CM" }).data.quantity == 30000dec
    AND fn::base_unite_convert({ quantity: 12.5dec, from: "G", to: "KG" }).data.quantity == 0.0125dec;

-- test: résultat non arrondi
RETURN fn::base_unite_convert({ quantity: 1, from: "H", to: "J" }).data.quantity == 1dec / 24dec
    AND fn::base_unite_convert({ quantity: 1, from: "H", to: "J" }).data.quantity > 0.0416666666dec;

-- test: plus grande quantité acceptée
RETURN fn::base_unite_convert({ quantity: 1000000000000000, from: "KM", to: "MM" }).data.quantity == 1000000000000000000000dec;

-- test: quantité nulle ; même unité
RETURN fn::base_unite_convert({ quantity: 0, from: "T", to: "G" }).data.quantity == 0dec
    AND fn::base_unite_convert({ quantity: 7, from: "KWH", to: "KWH" }).data.quantity == 7dec;

-- test: un utilisateur convertit (lecture ouverte)
-- en tant que: utilisateur
RETURN fn::base_unite_convert({ quantity: 1, from: "T", to: "KG" }).data.quantity == 1000dec;

-- test: types différents
RETURN fn::base_unite_convert({ quantity: 1, from: "M", to: "KG" }).error.{ code, d: details } == { code: "BASE_UNITE_TYPE_MISMATCH", d: { from: "M", from_type: "base_unite_type:LONGUEUR", to: "KG", to_type: "base_unite_type:MASSE" } };

-- test: unité sans facteur
RETURN fn::base_unite_convert({ quantity: 1, from: "H", to: "MOIS" }).error.{ code, d: details } == { code: "BASE_UNITE_NOT_CONVERTIBLE", d: { code: "MOIS", reason: "no_factor" } };

-- test: unité sans facteur d'un type sans unité de base : même vers elle-même
RETURN fn::base_unite_convert({ quantity: 1, from: "FORFAIT", to: "FORFAIT" }).error.details == { code: "FORFAIT", reason: "no_factor" }
    AND fn::base_unite_convert({ quantity: 1, from: "SAC", to: "PAL" }).error.code == "BASE_UNITE_NOT_CONVERTIBLE";

-- test: unité inconnue
RETURN fn::base_unite_convert({ quantity: 1, from: "M", to: "INCONNUE" }).error.{ code, id: details.id } == { code: "BASE_UNITE_NOT_FOUND", id: "base_unite:INCONNUE" }
    AND fn::base_unite_convert({ quantity: 1, from: "INCONNUE", to: "M" }).error.code == "BASE_UNITE_NOT_FOUND";

-- test: entrées invalides
RETURN fn::base_unite_convert({}).error.{ code, f: details.fields } == { code: "BASE_INVALID_PARAMETERS", f: { from: ["CORE_VALIDATION_REQUIRED"], quantity: ["CORE_VALIDATION_REQUIRED"], to: ["CORE_VALIDATION_REQUIRED"] } }
    AND fn::base_unite_convert({ quantity: -1, from: "M", to: "CM" }).error.details.fields == { quantity: ["CORE_VALIDATION_TOO_SMALL"] }
    AND fn::base_unite_convert({ quantity: "12", from: "M", to: "CM" }).error.details.fields == { quantity: ["CORE_VALIDATION_TYPE"] }
    AND fn::base_unite_convert({ quantity: math::inf, from: "M", to: "CM" }).error.details.fields == { quantity: ["CORE_VALIDATION_TOO_LARGE"] }
    AND fn::base_unite_convert({ quantity: NaN, from: "M", to: "CM" }).error.code == "BASE_INVALID_PARAMETERS"
    AND fn::base_unite_convert({ quantity: 1000000000000001, from: "M", to: "CM" }).error.details.fields == { quantity: ["CORE_VALIDATION_TOO_LARGE"] }
    AND fn::base_unite_convert({ quantity: 1, from: "base_unite:M", to: "CM" }).error.details.fields == { from: ["CORE_VALIDATION_FORMAT"] }
    AND fn::base_unite_convert({ quantity: 1, from: "M", to: "CM", arrondi: 2 }).error.details.fields == { arrondi: ["CORE_VALIDATION_NOT_ALLOWED"] };

-- test: lecture : facteur et convertible
RETURN fn::base_unite_get({ code: "CM" }).data.{ factor, convertible } == { factor: 0.01dec, convertible: true }
    AND fn::base_unite_get({ code: "FORFAIT" }).data.{ factor, convertible } == { factor: NONE, convertible: false }
    AND fn::base_unite_type_get({ code: "LONGUEUR" }).data.base_unit == base_unite:M
    AND fn::base_unite_type_get({ code: "QUANTITE" }).data.base_unit == NONE;

-- test: listes : facteur et unité de base renvoyés
RETURN array::find(fn::base_unite_list({ type: "base_unite_type:MASSE" }).data, |$u| $u.code = "T").factor == 1000dec
    AND array::find(fn::base_unite_type_list({}).data, |$t| $t.code = "MASSE").base_unit == base_unite:KG;

-- préparation: unité désactivée
fn::base_unite_update({ id: "base_unite:MM", enabled: false });

-- test: unité inactive
RETURN fn::base_unite_convert({ quantity: 1, from: "M", to: "MM" }).error.{ code, d: details } == { code: "BASE_UNITE_NOT_CONVERTIBLE", d: { code: "MM", reason: "disabled" } };

-- préparation: unité réactivée
fn::base_unite_update({ id: "base_unite:MM", enabled: true });

-- préparation: type désactivé
fn::base_unite_type_update({ id: "base_unite_type:MASSE", enabled: false });

-- test: type inactif
RETURN fn::base_unite_convert({ quantity: 1, from: "KG", to: "T" }).error.details == { code: "KG", reason: "disabled" }
    AND fn::base_unite_convert({ quantity: 1, from: "M", to: "MM" }).ok;

-- test: l'unité de base d'un type garde le facteur 1
RETURN fn::base_unite_update({ id: "base_unite:M", factor: 100 }).error.{ code, d: details } == { code: "BASE_UNITE_BASE_INVALID", d: { unit: "base_unite:M", type: "base_unite_type:LONGUEUR", reason: "base_unit_factor" } }
    AND fn::base_unite_update({ id: "base_unite:M", clear_factor: true }).error.details.reason == "base_unit_factor"
    AND fn::base_unite_update({ id: "base_unite:M", factor: 1 }).data.factor == 1dec;

-- test: l'unité de base d'un type ne change pas de type
RETURN fn::base_unite_update({ id: "base_unite:M", type: "base_unite_type:SURFACE" }).error.details.reason == "base_unit_type"
    AND fn::base_unite_update({ id: "base_unite:M", type: "base_unite_type:SURFACE", factor: 1 }).error.code == "BASE_UNITE_BASE_INVALID"
    AND (SELECT VALUE [type, factor] FROM ONLY base_unite:M) == [base_unite_type:LONGUEUR, 1dec];

-- test: l'unité de base se désactive, les autres unités du type restent convertibles
RETURN fn::base_unite_update({ id: "base_unite:M", enabled: false }).data.enabled == false
    AND fn::base_unite_convert({ quantity: 1, from: "KM", to: "CM" }).data.quantity == 100000dec
    AND fn::base_unite_convert({ quantity: 1, from: "KM", to: "M" }).error.details == { code: "M", reason: "disabled" }
    AND fn::base_unite_update({ id: "base_unite:M", enabled: true }).data.enabled == true;

-- test: facteur d'une unité : modifié, retiré, rétabli
RETURN fn::base_unite_update({ id: "base_unite:CM", factor: 0.02 }).data.factor == 0.02dec
    AND fn::base_unite_convert({ quantity: 100, from: "CM", to: "M" }).data.quantity == 2dec
    AND fn::base_unite_update({ id: "base_unite:CM", clear_factor: true }).data.factor == NONE
    AND fn::base_unite_get({ code: "CM" }).data.convertible == false
    AND fn::base_unite_convert({ quantity: 100, from: "CM", to: "M" }).error.details == { code: "CM", reason: "no_factor" }
    AND fn::base_unite_update({ id: "base_unite:CM", factor: 0.01 }).data.factor == 0.01dec;

-- test: facteur hors bornes, ou fourni et retiré à la fois
RETURN fn::base_unite_update({ id: "base_unite:CM", factor: 0 }).error.details.fields == { factor: ["CORE_VALIDATION_TOO_SMALL"] }
    AND fn::base_unite_update({ id: "base_unite:CM", factor: -2 }).error.details.fields == { factor: ["CORE_VALIDATION_TOO_SMALL"] }
    AND fn::base_unite_update({ id: "base_unite:CM", factor: 10000000 }).error.details.fields == { factor: ["CORE_VALIDATION_TOO_LARGE"] }
    AND fn::base_unite_update({ id: "base_unite:CM", factor: "1" }).error.details.fields == { factor: ["CORE_VALIDATION_TYPE"] }
    AND fn::base_unite_update({ id: "base_unite:CM", factor: 0.5, clear_factor: true }).error.details.fields == { clear_factor: ["CORE_VALIDATION_COMBINATION"] }
    AND (SELECT VALUE factor FROM ONLY base_unite:CM) == 0.01dec;

-- test: le schéma n'accepte qu'un facteur strictement positif
RETURN string::contains((INFO FOR TABLE base_unite).fields.factor, "ASSERT $value == NONE OR $value > 0");

-- préparation: type de test
fn::base_unite_type_create({ code: "ESSAI", libelle: "Essai" });

-- préparation: pouce, de facteur 1
fn::base_unite_create({ code: "POUCE", libelle: "Pouce", abreviation: "in", type: "base_unite_type:ESSAI", factor: 1 });

-- préparation: pied, de facteur 12
fn::base_unite_create({ code: "PIED", libelle: "Pied", abreviation: "ft", type: "base_unite_type:ESSAI", factor: 12 });

-- préparation: point, sans facteur
fn::base_unite_create({ code: "POINT", libelle: "Point", abreviation: "pt", type: "base_unite_type:ESSAI" });

-- test: création : facteur enregistré en décimal, ou absent
RETURN fn::base_unite_get({ code: "PIED" }).data.{ factor, convertible } == { factor: 12dec, convertible: false }
    AND type::is_decimal(fn::base_unite_get({ code: "PIED" }).data.factor)
    AND fn::base_unite_get({ code: "POINT" }).data.factor == NONE
    AND fn::base_unite_create({ code: "YARD", libelle: "Yard", abreviation: "yd", type: "base_unite_type:ESSAI", factor: 0 }).error.details.fields == { factor: ["CORE_VALIDATION_TOO_SMALL"] };

-- test: type sans unité de base : unités non convertibles malgré leur facteur
RETURN fn::base_unite_convert({ quantity: 1, from: "PIED", to: "POUCE" }).error.details == { code: "PIED", reason: "no_base_unit" };

-- test: unité de base refusée : inconnue, d'un autre type, de facteur différent de 1, sans facteur
RETURN fn::base_unite_type_update({ id: "base_unite_type:ESSAI", base_unit: "base_unite:INCONNUE" }).error.{ code, d: details } == { code: "BASE_UNITE_BASE_INVALID", d: { unit: "base_unite:INCONNUE", type: "base_unite_type:ESSAI", reason: "not_found" } }
    AND fn::base_unite_type_update({ id: "base_unite_type:ESSAI", base_unit: "base_unite:M" }).error.details.reason == "other_type"
    AND fn::base_unite_type_update({ id: "base_unite_type:ESSAI", base_unit: "base_unite:PIED" }).error.details.reason == "factor_not_one"
    AND fn::base_unite_type_update({ id: "base_unite_type:ESSAI", base_unit: "base_unite:POINT" }).error.details.reason == "factor_not_one"
    AND fn::base_unite_type_update({ id: "base_unite_type:ESSAI", base_unit: "base_unite_type:ESSAI" }).error.details.fields == { base_unit: ["CORE_VALIDATION_NOT_ALLOWED"] }
    AND fn::base_unite_type_update({ id: "base_unite_type:ESSAI", base_unit: "base_unite:POUCE", clear_base_unit: true }).error.details.fields == { clear_base_unit: ["CORE_VALIDATION_COMBINATION"] }
    AND fn::base_unite_type_get({ code: "ESSAI" }).data.base_unit == NONE;

-- test: unité de base désignée : les unités du type deviennent convertibles
RETURN fn::base_unite_type_update({ id: "base_unite_type:ESSAI", base_unit: "base_unite:POUCE" }).data.{ code, base_unit } == { code: "ESSAI", base_unit: base_unite:POUCE }
    AND fn::base_unite_convert({ quantity: 3, from: "PIED", to: "POUCE" }).data.quantity == 36dec
    AND fn::base_unite_get({ code: "PIED" }).data.convertible == true;

-- test: changement de type : le facteur est retiré s'il n'est pas fourni
RETURN fn::base_unite_update({ id: "base_unite:PIED", type: "base_unite_type:LONGUEUR" }).data.{ type, factor } == { type: base_unite_type:LONGUEUR, factor: NONE }
    AND fn::base_unite_update({ id: "base_unite:PIED", type: "base_unite_type:ESSAI", factor: 12 }).data.{ type, factor } == { type: base_unite_type:ESSAI, factor: 12dec };

-- test: une unité de base ne se supprime pas tant que son type la désigne
RETURN fn::base_unite_delete({ id: "base_unite:POUCE" }).error.{ code, n: details.references } == { code: "BASE_UNITE_IN_USE", n: 1 }
    AND record::exists(base_unite:POUCE);

-- test: la base refuse elle aussi la suppression d'une unité de base (ON DELETE REJECT)
RETURN string::contains((INFO FOR TABLE base_unite_type).fields.base_unit, "REFERENCE ON DELETE REJECT");

-- test: un utilisateur ne modifie ni facteur ni unité de base
-- en tant que: utilisateur
RETURN fn::base_unite_update({ id: "base_unite:PIED", factor: 10 }).error.code == "BASE_WRITE_FORBIDDEN"
    AND fn::base_unite_type_update({ id: "base_unite_type:ESSAI", clear_base_unit: true }).error.code == "BASE_WRITE_FORBIDDEN";

-- test: rien n'a été modifié
RETURN (SELECT VALUE factor FROM ONLY base_unite:PIED) == 12dec AND (SELECT VALUE base_unit FROM ONLY base_unite_type:ESSAI) == base_unite:POUCE;

-- test: unité de base retirée : unités non convertibles, l'ancienne unité de base se supprime
RETURN fn::base_unite_type_update({ id: "base_unite_type:ESSAI", clear_base_unit: true }).data.base_unit == NONE
    AND fn::base_unite_convert({ quantity: 3, from: "PIED", to: "POUCE" }).error.details.reason == "no_base_unit"
    AND fn::base_unite_update({ id: "base_unite:POUCE", clear_factor: true }).data.factor == NONE
    AND fn::base_unite_delete({ id: "base_unite:POUCE" }).data.deleted == true;

-- test: messages d'erreur résolus en anglais
RETURN fn::base_unite_convert({ quantity: 1, from: "M", to: "KG", language: "en" }).error.label == "Units of different types"
    AND fn::base_unite_convert({ quantity: 1, from: "H", to: "MOIS", language: "en" }).error.label == "Unit not convertible"
    AND fn::base_unite_type_update({ id: "base_unite_type:ESSAI", base_unit: "base_unite:M", language: "en" }).error.label == "Invalid base unit";
