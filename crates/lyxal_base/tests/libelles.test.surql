-- lyxal-test: assertions
-- Libellés : clés lyxal_i18n (base.unite_<code>, base.unite_type_<code>), rendu dans la langue
-- demandée avec repli, création, modification (traductions obsolètes), suppression, rejeu des
-- seeds, surcharge d'une organisation.
-- Exécuté par scripts/ci/test_lyxal_modules.py (format en tête du script).
--
-- identité utilisateur: { "id": "base_session:utilisateur", "sub": "user:alpha", "iss": "lyxal-os", "role": "tenant_user", "tenant_id": "alpha" }

-- test: nom de la clé d'un libellé
RETURN fn::base_libelle_name("unite", "M2") == "unite_m2" AND fn::base_libelle_name("unite_type", "LONGUEUR") == "unite_type_longueur";

-- test: socle : une clé, un texte français et un texte anglais par type et par unité
RETURN array::len(SELECT VALUE id FROM i18n_key WHERE namespace = i18n_namespace:base) == 41
    AND array::len(SELECT VALUE id FROM i18n_translation WHERE key.namespace = i18n_namespace:base) == 82
    AND array::len(SELECT VALUE id FROM i18n_translation WHERE key.namespace = i18n_namespace:base AND syntax != "plain") == 0;

-- test: libellé en français par défaut, en anglais sur demande
RETURN fn::base_unite_get({ code: "M2" }).data.libelle == "Mètre carré"
    AND fn::base_unite_get({ code: "M2", locale: "en" }).data.libelle == "Square metre"
    AND fn::base_unite_get({ code: "M2", language: "en" }).data.libelle == "Square metre"
    AND fn::base_unite_type_get({ code: "LONGUEUR", locale: "en" }).data.libelle == "Length";

-- test: repli : région vers la langue, langue sans traduction vers la langue par défaut
RETURN fn::base_unite_get({ code: "KG", locale: "en-GB" }).data.libelle == "Kilogram"
    AND fn::base_unite_get({ code: "KG", locale: "fr-CA" }).data.libelle == "Kilogramme"
    AND fn::base_unite_get({ code: "KG", locale: "de" }).data.libelle == "Kilogramme";

-- test: listes dans la langue demandée, triées par code
RETURN fn::base_unite_list({ type: "base_unite_type:MASSE", locale: "en" }).data.{ code, libelle } == [{ code: "G", libelle: "Gram" }, { code: "KG", libelle: "Kilogram" }, { code: "T", libelle: "Tonne" }]
    AND array::first(fn::base_unite_type_list({ locale: "en" }).data).{ code, libelle } == { code: "CONDITIONNEMENT", libelle: "Packaging" }
    AND fn::base_unite_list({ type: "base_unite_type:MASSE", enabled: false }).data == [];

-- test: lecture sous toute identité
-- en tant que: utilisateur
RETURN fn::base_unite_get({ code: "H", locale: "en" }).data.libelle == "Hour" AND fn::base_unite_type_list({ limit: 1 }).data[0].libelle == "Conditionnement";

-- test: langue mal formée refusée
RETURN fn::base_unite_get({ code: "H", locale: "pas une langue" }).error.code == "BASE_INVALID_PARAMETERS"
    AND fn::base_unite_type_list({ locale: 12 }).error.code == "BASE_INVALID_PARAMETERS";

-- test: aucun champ libelle dans les tables
RETURN (SELECT VALUE libelle FROM ONLY base_unite:M) == NONE AND (SELECT VALUE libelle FROM ONLY base_unite_type:MASSE) == NONE;

-- test: création d'un type : la clé et son texte source
RETURN fn::base_unite_type_create({ code: "ESSAI", libelle: "Essai" }).data.{ code, libelle } == { code: "ESSAI", libelle: "Essai" }
    AND (SELECT VALUE [text, syntax, is_source] FROM ONLY i18n_translation:["base.unite_type_essai", "fr", "installation"]) == ["Essai", "plain", true];

-- test: création d'une unité : la clé et son texte source
RETURN fn::base_unite_create({ code: "DM", libelle: "Décimètre", abreviation: "dm", type: "base_unite_type:ESSAI" }).data.libelle == "Décimètre"
    AND fn::i18n_resolve({ key: "base.unite_dm", locale: "fr" }).data.{ text, missing } == { text: "Décimètre", missing: false };

-- test: traduction par lyxal_i18n, rendue par lyxal_base
RETURN fn::i18n_translation_set({ key: "base.unite_dm", locale: "en", text: "Decimetre" }).ok
    AND fn::base_unite_get({ code: "DM", locale: "en" }).data.libelle == "Decimetre";

-- test: modification du libellé : texte source remplacé, traduction obsolète
RETURN fn::base_unite_update({ id: "base_unite:DM", libelle: "Décimètre (dm)" }).data.libelle == "Décimètre (dm)"
    AND fn::base_unite_get({ code: "DM" }).data.libelle == "Décimètre (dm)"
    AND (SELECT VALUE outdated FROM ONLY i18n_translation:["base.unite_dm", "en", "installation"]) == true;

-- test: modification d'un autre champ : libellé inchangé
RETURN fn::base_unite_update({ id: "base_unite:DM", abreviation: "dm." }).data.{ abreviation, libelle } == { abreviation: "dm.", libelle: "Décimètre (dm)" }
    AND fn::base_unite_type_update({ id: "base_unite_type:ESSAI", libelle: "Essais" }).data.libelle == "Essais";

-- test: fonctions internes : écriture et lecture d'un libellé
RETURN fn::base_libelle_update("unite", "DM", "Décimètre") == NONE
    AND fn::base_libelle_attach([{ code: "DM" }, { code: "M" }], "unite", "fr").records.libelle == ["Décimètre", "Mètre"]
    AND fn::base_libelle_attach([], "unite", "fr") == { error: NONE, records: [] }
    AND fn::base_libelle_create("unite", "DM", "Doublon") == "I18N_KEY_EXISTS"
    AND fn::base_libelle_update("unite", "ABSENTE", "x") == "I18N_KEY_NOT_FOUND"
    AND fn::base_libelle_delete("unite", "ABSENTE") == "I18N_KEY_NOT_FOUND";

-- préparation: clé orpheline du même nom qu'une future unité
fn::i18n_key_create({ namespace: "base", name: "unite_dam", source_text: "Décamètre", syntax: "plain" });

-- test: libellé non enregistré : l'unité n'est pas créée
RETURN fn::base_unite_create({ code: "DAM", libelle: "Décamètre", abreviation: "dam", type: "base_unite_type:ESSAI" }).error.{ code, cause: details.cause } == { code: "BASE_LIBELLE_WRITE_FAILED", cause: "I18N_KEY_EXISTS" }
    AND record::exists(base_unite:DAM) == false;

-- test: un utilisateur ne modifie pas un libellé
-- en tant que: utilisateur
RETURN fn::base_unite_update({ id: "base_unite:DM", libelle: "Pirate" }).error.code == "BASE_WRITE_FORBIDDEN";

-- test: le libellé est intact
RETURN fn::base_unite_get({ code: "DM" }).data.libelle == "Décimètre";

-- test: suppression : l'unité, sa clé et ses traductions
RETURN fn::base_unite_delete({ id: "base_unite:DM" }).data.deleted == true
    AND record::exists(i18n_key:⟨base.unite_dm⟩) == false
    AND array::len(SELECT VALUE id FROM i18n_translation WHERE key = i18n_key:⟨base.unite_dm⟩) == 0
    AND fn::base_unite_type_delete({ id: "base_unite_type:ESSAI" }).data.deleted == true
    AND record::exists(i18n_key:⟨base.unite_type_essai⟩) == false;
