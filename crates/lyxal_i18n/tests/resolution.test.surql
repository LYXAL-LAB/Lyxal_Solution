-- lyxal-test: assertions
-- Choix de la langue d'une requête : candidats par ordre de préférence, chaîne de repli CLDR,
-- troncature hors référentiel, langue par défaut.

-- test: langue active demandée telle quelle
RETURN fn::i18n_locale_resolve({ candidates: ["en"] }).data == { locale: "en", language: "en", fallback: ["fr"], matched: true };

-- test: fr-CA inactif → fr par la chaîne de repli
RETURN fn::i18n_locale_resolve({ candidates: ["fr-CA", "en"] }).data == { locale: "fr", language: "fr", fallback: [], matched: true };

-- test: le premier candidat qui correspond l'emporte, les candidats invalides sont ignorés
RETURN fn::i18n_locale_resolve({ candidates: ["klingon!", "de", "en-GB"] }).data.locale == "en";

-- test: aucun candidat → langue par défaut, matched faux
RETURN fn::i18n_locale_resolve({ candidates: [] }).data == { locale: "fr", language: "fr", fallback: [], matched: false }
    AND fn::i18n_locale_resolve({}).data.matched == false
    AND fn::i18n_locale_resolve({ candidates: ["de", "it"] }).data.locale == "fr";

-- test: repli CLDR es-MX → es-419 quand seul es-419 est actif
RETURN fn::i18n_locale_activate({ locale: "es-419" }).ok AND fn::i18n_locale_resolve({ candidates: ["es-MX"] }).data == { locale: "es-419", language: "es", fallback: ["es", "fr"], matched: true };

-- test: script et forme non canonique ; Hant ne se replie pas sur zh (Hans)
RETURN fn::i18n_locale_activate({ locale: "zh" }).ok
    AND fn::i18n_locale_resolve({ candidates: ["zh_hant_tw"] }).data.locale == "fr"
    AND fn::i18n_locale_resolve({ candidates: ["zh-Hans-CN"] }).data.locale == "zh";

-- test: étiquette hors référentiel → troncature
RETURN fn::i18n_locale_chain("en-Latn-ZZ") == ["en-Latn-ZZ", "en-Latn", "en"]
    AND fn::i18n_locale_chain("fr-CA") == ["fr-CA", "fr"]
    AND fn::i18n_locale_resolve({ candidates: ["en-Latn-ZZ"] }).data.locale == "en";

-- test: plus de 20 candidats ou candidats non textuels refusés
RETURN fn::i18n_locale_resolve({ candidates: array::map(<array> (0..21), |$i| "fr") }).error.code == "I18N_INVALID_PARAMETERS"
    AND fn::i18n_locale_resolve({ candidates: [42] }).error.code == "I18N_INVALID_PARAMETERS";

-- test: une langue à trois lettres retenue est acceptée comme langue des messages
RETURN fn::i18n_locale_activate({ locale: "fil" }).ok
    AND fn::i18n_locale_resolve({ candidates: ["fil-PH"] }).data.language == "fil"
    AND fn::i18n_locale_resolve({ candidates: ["fil"], language: "fil" }).data.locale == "fil"
    AND fn::i18n_locale_list({ active: true, language: "fil" }).ok;
