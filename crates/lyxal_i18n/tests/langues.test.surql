-- lyxal-test: assertions
-- Référentiel des langues : données CLDR, liste, recherche, lecture, activation et
-- désactivation, garde des langues des réglages, droits.
--
-- identité plateforme: { "id": "auth_session:plateforme", "pv": 1, "permissions": ["i18n.locale.manage"] }
-- identité membre: { "id": "auth_session:membre", "pv": 1, "permissions": [] }

-- préparation: identités et sessions
{
    CREATE auth_identity:plateforme CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "plateforme@lyxal.test" } };
    CREATE auth_session:plateforme CONTENT { identity: auth_identity:plateforme, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_identity:membre CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "membre@lyxal.test" } };
    CREATE auth_session:membre CONTENT { identity: auth_identity:membre, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
};

-- test: référentiel CLDR 49 complet (langues publiées et par défaut), français et anglais seuls actifs
RETURN array::len(SELECT VALUE id FROM i18n_locale) == 924
    AND (SELECT VALUE tag FROM i18n_locale WHERE active ORDER BY tag) == ["en", "fr"]
    AND array::len(SELECT VALUE id FROM i18n_locale WHERE cldr_version != "49") == 0;

-- test: données d'une langue : noms, sens d'écriture, pluriels, repli
RETURN (SELECT tag, name_en, name_native, direction, plural_cardinal, fallback FROM ONLY i18n_locale:⟨ar⟩)
        == { tag: "ar", name_en: "Arabic", name_native: "العربية", direction: "rtl", plural_cardinal: ["zero", "one", "two", "few", "many", "other"], fallback: [] }
    AND i18n_locale:⟨es-MX⟩.fallback == ["es-419", "es"]
    AND i18n_locale:⟨en-AU⟩.fallback == ["en-001", "en"]
    AND i18n_locale:⟨zh-Hant-TW⟩.fallback == ["zh-Hant"]
    AND i18n_locale:⟨fr-FR⟩.{ name_native, fallback } == { name_native: "français (France)", fallback: ["fr"] };

-- test: toute langue de repli fait partie du référentiel
RETURN array::len(array::filter(array::flatten(SELECT VALUE fallback FROM i18n_locale), |$t| !record::exists(type::record("i18n_locale", $t)))) == 0;

-- test: liste filtrée, recherche sur l'étiquette ou les noms, pagination
-- en tant que: membre
RETURN fn::i18n_locale_list({ active: true }).data.items.tag == ["en", "fr"]
    AND fn::i18n_locale_list({ search: "fr-c" }).data.items.tag == ["fr-CA", "fr-CD", "fr-CF", "fr-CG", "fr-CH", "fr-CI", "fr-CM"]
    AND fn::i18n_locale_list({ search: "Canadian French" }).data.items.tag == ["fr-CA"]
    AND fn::i18n_locale_list({ search: "français canadien" }).data.items.tag == ["fr-CA"]
    AND fn::i18n_locale_list({ limit: 2, start: 1 }).data.{ n: array::len(items), total } == { n: 2, total: 924 }
    AND fn::i18n_locale_list({ limit: 0 }).error.code == "I18N_INVALID_PARAMETERS";

-- test: lecture d'une langue sous forme canonique ; langue inconnue ou étiquette invalide
-- en tant que: membre
RETURN fn::i18n_locale_get({ locale: "zh_hant_tw" }).data.tag == "zh-Hant-TW"
    AND fn::i18n_locale_get({ locale: "tlh" }).error.code == "I18N_LOCALE_NOT_FOUND"
    AND fn::i18n_locale_get({ locale: "français" }).error.code == "I18N_INVALID_PARAMETERS";

-- test: un membre sans permission n'active pas de langue, l'écriture directe est filtrée
-- en tant que: membre
RETURN fn::i18n_locale_activate({ locale: "de" }).error.code == "I18N_PERMISSION_DENIED"
    AND (UPDATE ONLY i18n_locale:⟨de⟩ SET active = true) == NONE
    AND i18n_locale:⟨de⟩.active == false;

-- test: l'administrateur active puis désactive une langue ; un événement par changement
-- en tant que: plateforme
RETURN fn::i18n_locale_activate({ locale: "de" }).data.active == true
    AND fn::i18n_locale_deactivate({ locale: "de" }).data.active == false
    AND fn::i18n_locale_activate({ locale: "xx" }).error.code == "I18N_LOCALE_NOT_FOUND";

-- test: événements i18n.locale.activated puis i18n.locale.deactivated
RETURN (SELECT VALUE [event_type, payload.locale] FROM event_outbox WHERE producer = "lyxal_i18n" ORDER BY created_at)
    == [["i18n.locale.activated", "de"], ["i18n.locale.deactivated", "de"]];

-- test: la langue par défaut ne se désactive pas, ni par la fonction ni par une écriture directe
-- en tant que: plateforme
RETURN fn::i18n_locale_deactivate({ locale: "fr" }).error.code == "I18N_LOCALE_DEFAULT_REQUIRED"
    AND i18n_locale:⟨fr⟩.active == true;

-- test: garde de la base sur une écriture directe
-- attendu-erreur: I18N_LOCALE_DEFAULT_REQUIRED
UPDATE i18n_locale:⟨fr⟩ SET active = false;

-- test: les données CLDR ne se modifient pas
-- en tant que: plateforme
RETURN (UPDATE ONLY i18n_locale:⟨en⟩ SET name_en = "Anglais", fallback = ["fr"]).{ name_en, fallback } == { name_en: "English", fallback: [] };

-- test: fonction interne d'activation, étiquette invalide
RETURN fn::i18n_locale_set_active({ locale: 42 }, true).error.code == "I18N_INVALID_PARAMETERS";
