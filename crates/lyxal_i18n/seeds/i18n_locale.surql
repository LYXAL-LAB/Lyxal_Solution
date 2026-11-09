-- ============================================================================
-- SEEDS : référentiel des langues (Unicode CLDR 49.0.0, licence Unicode-3.0)
-- MODULE : lyxal_i18n
-- ============================================================================
-- Fichier généré par scripts/i18n/generate_locales.py : ne pas modifier à la main.
-- Rejouable et non destructif : une langue existante n'est pas modifiée (son état actif
-- est conservé). Langues actives à la création : fr, en.

IF !record::exists(i18n_locale:⟨ady⟩) THEN (
    CREATE i18n_locale:⟨ady⟩ CONTENT { tag: "ady", language: "ady", script: NONE, region: NONE, name_en: "Adyghe", name_native: "адыгабзэ", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ady-JO⟩) THEN (
    CREATE i18n_locale:⟨ady-JO⟩ CONTENT { tag: "ady-JO", language: "ady", script: NONE, region: "JO", name_en: "Adyghe (Jordan)", name_native: "адыгабзэ (Иордание)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["ady"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ady-RU⟩) THEN (
    CREATE i18n_locale:⟨ady-RU⟩ CONTENT { tag: "ady-RU", language: "ady", script: NONE, region: "RU", name_en: "Adyghe (Russia)", name_native: "адыгабзэ (Урысые)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["ady"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ady-TR⟩) THEN (
    CREATE i18n_locale:⟨ady-TR⟩ CONTENT { tag: "ady-TR", language: "ady", script: NONE, region: "TR", name_en: "Adyghe (Türkiye)", name_native: "адыгабзэ (Тыркуе)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["ady"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨af⟩) THEN (
    CREATE i18n_locale:⟨af⟩ CONTENT { tag: "af", language: "af", script: NONE, region: NONE, name_en: "Afrikaans", name_native: "Afrikaans", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["few", "other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨af-NA⟩) THEN (
    CREATE i18n_locale:⟨af-NA⟩ CONTENT { tag: "af-NA", language: "af", script: NONE, region: "NA", name_en: "Afrikaans (Namibia)", name_native: "Afrikaans (Namibië)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["few", "other"], fallback: ["af"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨af-ZA⟩) THEN (
    CREATE i18n_locale:⟨af-ZA⟩ CONTENT { tag: "af-ZA", language: "af", script: NONE, region: "ZA", name_en: "Afrikaans (South Africa)", name_native: "Afrikaans (Suid-Afrika)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["few", "other"], fallback: ["af"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨agq⟩) THEN (
    CREATE i18n_locale:⟨agq⟩ CONTENT { tag: "agq", language: "agq", script: NONE, region: NONE, name_en: "Aghem", name_native: "Aghem", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨agq-CM⟩) THEN (
    CREATE i18n_locale:⟨agq-CM⟩ CONTENT { tag: "agq-CM", language: "agq", script: NONE, region: "CM", name_en: "Aghem (Cameroon)", name_native: "Aghem (Kàmàlûŋ)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["agq"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ak⟩) THEN (
    CREATE i18n_locale:⟨ak⟩ CONTENT { tag: "ak", language: "ak", script: NONE, region: NONE, name_en: "Akan", name_native: "Akan", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ak-GH⟩) THEN (
    CREATE i18n_locale:⟨ak-GH⟩ CONTENT { tag: "ak-GH", language: "ak", script: NONE, region: "GH", name_en: "Akan (Ghana)", name_native: "Akan (Gaana)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["ak"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨am⟩) THEN (
    CREATE i18n_locale:⟨am⟩ CONTENT { tag: "am", language: "am", script: NONE, region: NONE, name_en: "Amharic", name_native: "አማርኛ", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨am-ET⟩) THEN (
    CREATE i18n_locale:⟨am-ET⟩ CONTENT { tag: "am-ET", language: "am", script: NONE, region: "ET", name_en: "Amharic (Ethiopia)", name_native: "አማርኛ (ኢትዮጵያ)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["am"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ar⟩) THEN (
    CREATE i18n_locale:⟨ar⟩ CONTENT { tag: "ar", language: "ar", script: NONE, region: NONE, name_en: "Arabic", name_native: "العربية", direction: "rtl", plural_cardinal: ["zero", "one", "two", "few", "many", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ar-001⟩) THEN (
    CREATE i18n_locale:⟨ar-001⟩ CONTENT { tag: "ar-001", language: "ar", script: NONE, region: "001", name_en: "Modern Standard Arabic", name_native: "العربية الفصحى الحديثة", direction: "rtl", plural_cardinal: ["zero", "one", "two", "few", "many", "other"], plural_ordinal: ["other"], fallback: ["ar"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ar-AE⟩) THEN (
    CREATE i18n_locale:⟨ar-AE⟩ CONTENT { tag: "ar-AE", language: "ar", script: NONE, region: "AE", name_en: "Arabic (United Arab Emirates)", name_native: "العربية (الإمارات العربية المتحدة)", direction: "rtl", plural_cardinal: ["zero", "one", "two", "few", "many", "other"], plural_ordinal: ["other"], fallback: ["ar"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ar-BH⟩) THEN (
    CREATE i18n_locale:⟨ar-BH⟩ CONTENT { tag: "ar-BH", language: "ar", script: NONE, region: "BH", name_en: "Arabic (Bahrain)", name_native: "العربية (البحرين)", direction: "rtl", plural_cardinal: ["zero", "one", "two", "few", "many", "other"], plural_ordinal: ["other"], fallback: ["ar"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ar-DJ⟩) THEN (
    CREATE i18n_locale:⟨ar-DJ⟩ CONTENT { tag: "ar-DJ", language: "ar", script: NONE, region: "DJ", name_en: "Arabic (Djibouti)", name_native: "العربية (جيبوتي)", direction: "rtl", plural_cardinal: ["zero", "one", "two", "few", "many", "other"], plural_ordinal: ["other"], fallback: ["ar"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ar-DZ⟩) THEN (
    CREATE i18n_locale:⟨ar-DZ⟩ CONTENT { tag: "ar-DZ", language: "ar", script: NONE, region: "DZ", name_en: "Arabic (Algeria)", name_native: "العربية (الجزائر)", direction: "rtl", plural_cardinal: ["zero", "one", "two", "few", "many", "other"], plural_ordinal: ["other"], fallback: ["ar"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ar-EG⟩) THEN (
    CREATE i18n_locale:⟨ar-EG⟩ CONTENT { tag: "ar-EG", language: "ar", script: NONE, region: "EG", name_en: "Arabic (Egypt)", name_native: "العربية (مصر)", direction: "rtl", plural_cardinal: ["zero", "one", "two", "few", "many", "other"], plural_ordinal: ["other"], fallback: ["ar"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ar-EH⟩) THEN (
    CREATE i18n_locale:⟨ar-EH⟩ CONTENT { tag: "ar-EH", language: "ar", script: NONE, region: "EH", name_en: "Arabic (Western Sahara)", name_native: "العربية (الصحراء الغربية)", direction: "rtl", plural_cardinal: ["zero", "one", "two", "few", "many", "other"], plural_ordinal: ["other"], fallback: ["ar"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ar-ER⟩) THEN (
    CREATE i18n_locale:⟨ar-ER⟩ CONTENT { tag: "ar-ER", language: "ar", script: NONE, region: "ER", name_en: "Arabic (Eritrea)", name_native: "العربية (إريتريا)", direction: "rtl", plural_cardinal: ["zero", "one", "two", "few", "many", "other"], plural_ordinal: ["other"], fallback: ["ar"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ar-IL⟩) THEN (
    CREATE i18n_locale:⟨ar-IL⟩ CONTENT { tag: "ar-IL", language: "ar", script: NONE, region: "IL", name_en: "Arabic (Israel)", name_native: "العربية (إسرائيل)", direction: "rtl", plural_cardinal: ["zero", "one", "two", "few", "many", "other"], plural_ordinal: ["other"], fallback: ["ar"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ar-IQ⟩) THEN (
    CREATE i18n_locale:⟨ar-IQ⟩ CONTENT { tag: "ar-IQ", language: "ar", script: NONE, region: "IQ", name_en: "Arabic (Iraq)", name_native: "العربية (العراق)", direction: "rtl", plural_cardinal: ["zero", "one", "two", "few", "many", "other"], plural_ordinal: ["other"], fallback: ["ar"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ar-JO⟩) THEN (
    CREATE i18n_locale:⟨ar-JO⟩ CONTENT { tag: "ar-JO", language: "ar", script: NONE, region: "JO", name_en: "Arabic (Jordan)", name_native: "العربية (الأردن)", direction: "rtl", plural_cardinal: ["zero", "one", "two", "few", "many", "other"], plural_ordinal: ["other"], fallback: ["ar"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ar-KM⟩) THEN (
    CREATE i18n_locale:⟨ar-KM⟩ CONTENT { tag: "ar-KM", language: "ar", script: NONE, region: "KM", name_en: "Arabic (Comoros)", name_native: "العربية (جزر القمر)", direction: "rtl", plural_cardinal: ["zero", "one", "two", "few", "many", "other"], plural_ordinal: ["other"], fallback: ["ar"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ar-KW⟩) THEN (
    CREATE i18n_locale:⟨ar-KW⟩ CONTENT { tag: "ar-KW", language: "ar", script: NONE, region: "KW", name_en: "Arabic (Kuwait)", name_native: "العربية (الكويت)", direction: "rtl", plural_cardinal: ["zero", "one", "two", "few", "many", "other"], plural_ordinal: ["other"], fallback: ["ar"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ar-LB⟩) THEN (
    CREATE i18n_locale:⟨ar-LB⟩ CONTENT { tag: "ar-LB", language: "ar", script: NONE, region: "LB", name_en: "Arabic (Lebanon)", name_native: "العربية (لبنان)", direction: "rtl", plural_cardinal: ["zero", "one", "two", "few", "many", "other"], plural_ordinal: ["other"], fallback: ["ar"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ar-LY⟩) THEN (
    CREATE i18n_locale:⟨ar-LY⟩ CONTENT { tag: "ar-LY", language: "ar", script: NONE, region: "LY", name_en: "Arabic (Libya)", name_native: "العربية (ليبيا)", direction: "rtl", plural_cardinal: ["zero", "one", "two", "few", "many", "other"], plural_ordinal: ["other"], fallback: ["ar"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ar-MA⟩) THEN (
    CREATE i18n_locale:⟨ar-MA⟩ CONTENT { tag: "ar-MA", language: "ar", script: NONE, region: "MA", name_en: "Arabic (Morocco)", name_native: "العربية (المغرب)", direction: "rtl", plural_cardinal: ["zero", "one", "two", "few", "many", "other"], plural_ordinal: ["other"], fallback: ["ar"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ar-MR⟩) THEN (
    CREATE i18n_locale:⟨ar-MR⟩ CONTENT { tag: "ar-MR", language: "ar", script: NONE, region: "MR", name_en: "Arabic (Mauritania)", name_native: "العربية (موريتانيا)", direction: "rtl", plural_cardinal: ["zero", "one", "two", "few", "many", "other"], plural_ordinal: ["other"], fallback: ["ar"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ar-OM⟩) THEN (
    CREATE i18n_locale:⟨ar-OM⟩ CONTENT { tag: "ar-OM", language: "ar", script: NONE, region: "OM", name_en: "Arabic (Oman)", name_native: "العربية (عُمان)", direction: "rtl", plural_cardinal: ["zero", "one", "two", "few", "many", "other"], plural_ordinal: ["other"], fallback: ["ar"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ar-PS⟩) THEN (
    CREATE i18n_locale:⟨ar-PS⟩ CONTENT { tag: "ar-PS", language: "ar", script: NONE, region: "PS", name_en: "Arabic (Palestinian Territories)", name_native: "العربية (الأراضي الفلسطينية)", direction: "rtl", plural_cardinal: ["zero", "one", "two", "few", "many", "other"], plural_ordinal: ["other"], fallback: ["ar"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ar-QA⟩) THEN (
    CREATE i18n_locale:⟨ar-QA⟩ CONTENT { tag: "ar-QA", language: "ar", script: NONE, region: "QA", name_en: "Arabic (Qatar)", name_native: "العربية (قطر)", direction: "rtl", plural_cardinal: ["zero", "one", "two", "few", "many", "other"], plural_ordinal: ["other"], fallback: ["ar"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ar-SA⟩) THEN (
    CREATE i18n_locale:⟨ar-SA⟩ CONTENT { tag: "ar-SA", language: "ar", script: NONE, region: "SA", name_en: "Arabic (Saudi Arabia)", name_native: "العربية (المملكة العربية السعودية)", direction: "rtl", plural_cardinal: ["zero", "one", "two", "few", "many", "other"], plural_ordinal: ["other"], fallback: ["ar"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ar-SD⟩) THEN (
    CREATE i18n_locale:⟨ar-SD⟩ CONTENT { tag: "ar-SD", language: "ar", script: NONE, region: "SD", name_en: "Arabic (Sudan)", name_native: "العربية (السودان)", direction: "rtl", plural_cardinal: ["zero", "one", "two", "few", "many", "other"], plural_ordinal: ["other"], fallback: ["ar"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ar-SO⟩) THEN (
    CREATE i18n_locale:⟨ar-SO⟩ CONTENT { tag: "ar-SO", language: "ar", script: NONE, region: "SO", name_en: "Arabic (Somalia)", name_native: "العربية (الصومال)", direction: "rtl", plural_cardinal: ["zero", "one", "two", "few", "many", "other"], plural_ordinal: ["other"], fallback: ["ar"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ar-SS⟩) THEN (
    CREATE i18n_locale:⟨ar-SS⟩ CONTENT { tag: "ar-SS", language: "ar", script: NONE, region: "SS", name_en: "Arabic (South Sudan)", name_native: "العربية (جنوب السودان)", direction: "rtl", plural_cardinal: ["zero", "one", "two", "few", "many", "other"], plural_ordinal: ["other"], fallback: ["ar"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ar-SY⟩) THEN (
    CREATE i18n_locale:⟨ar-SY⟩ CONTENT { tag: "ar-SY", language: "ar", script: NONE, region: "SY", name_en: "Arabic (Syria)", name_native: "العربية (سوريا)", direction: "rtl", plural_cardinal: ["zero", "one", "two", "few", "many", "other"], plural_ordinal: ["other"], fallback: ["ar"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ar-TD⟩) THEN (
    CREATE i18n_locale:⟨ar-TD⟩ CONTENT { tag: "ar-TD", language: "ar", script: NONE, region: "TD", name_en: "Arabic (Chad)", name_native: "العربية (تشاد)", direction: "rtl", plural_cardinal: ["zero", "one", "two", "few", "many", "other"], plural_ordinal: ["other"], fallback: ["ar"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ar-TN⟩) THEN (
    CREATE i18n_locale:⟨ar-TN⟩ CONTENT { tag: "ar-TN", language: "ar", script: NONE, region: "TN", name_en: "Arabic (Tunisia)", name_native: "العربية (تونس)", direction: "rtl", plural_cardinal: ["zero", "one", "two", "few", "many", "other"], plural_ordinal: ["other"], fallback: ["ar"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ar-YE⟩) THEN (
    CREATE i18n_locale:⟨ar-YE⟩ CONTENT { tag: "ar-YE", language: "ar", script: NONE, region: "YE", name_en: "Arabic (Yemen)", name_native: "العربية (اليمن)", direction: "rtl", plural_cardinal: ["zero", "one", "two", "few", "many", "other"], plural_ordinal: ["other"], fallback: ["ar"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨as⟩) THEN (
    CREATE i18n_locale:⟨as⟩ CONTENT { tag: "as", language: "as", script: NONE, region: NONE, name_en: "Assamese", name_native: "অসমীয়া", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "many", "other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨as-IN⟩) THEN (
    CREATE i18n_locale:⟨as-IN⟩ CONTENT { tag: "as-IN", language: "as", script: NONE, region: "IN", name_en: "Assamese (India)", name_native: "অসমীয়া (ভাৰত)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "many", "other"], fallback: ["as"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨asa⟩) THEN (
    CREATE i18n_locale:⟨asa⟩ CONTENT { tag: "asa", language: "asa", script: NONE, region: NONE, name_en: "Asu", name_native: "Kipare", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨asa-TZ⟩) THEN (
    CREATE i18n_locale:⟨asa-TZ⟩ CONTENT { tag: "asa-TZ", language: "asa", script: NONE, region: "TZ", name_en: "Asu (Tanzania)", name_native: "Kipare (Tadhania)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["asa"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ast⟩) THEN (
    CREATE i18n_locale:⟨ast⟩ CONTENT { tag: "ast", language: "ast", script: NONE, region: NONE, name_en: "Asturian", name_native: "asturianu", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ast-ES⟩) THEN (
    CREATE i18n_locale:⟨ast-ES⟩ CONTENT { tag: "ast-ES", language: "ast", script: NONE, region: "ES", name_en: "Asturian (Spain)", name_native: "asturianu (España)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["ast"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨az⟩) THEN (
    CREATE i18n_locale:⟨az⟩ CONTENT { tag: "az", language: "az", script: NONE, region: NONE, name_en: "Azerbaijani", name_native: "azərbaycan", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "few", "many", "other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨az-Cyrl⟩) THEN (
    CREATE i18n_locale:⟨az-Cyrl⟩ CONTENT { tag: "az-Cyrl", language: "az", script: "Cyrl", region: NONE, name_en: "Azerbaijani (Cyrillic)", name_native: "азәрбајҹан (Кирил)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "few", "many", "other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨az-Cyrl-AZ⟩) THEN (
    CREATE i18n_locale:⟨az-Cyrl-AZ⟩ CONTENT { tag: "az-Cyrl-AZ", language: "az", script: "Cyrl", region: "AZ", name_en: "Azerbaijani (Cyrillic, Azerbaijan)", name_native: "азәрбајҹан (Кирил, Азәрбајҹан)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "few", "many", "other"], fallback: ["az-Cyrl"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨az-Latn⟩) THEN (
    CREATE i18n_locale:⟨az-Latn⟩ CONTENT { tag: "az-Latn", language: "az", script: "Latn", region: NONE, name_en: "Azerbaijani (Latin)", name_native: "azərbaycan (latın)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "few", "many", "other"], fallback: ["az"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨az-Latn-AZ⟩) THEN (
    CREATE i18n_locale:⟨az-Latn-AZ⟩ CONTENT { tag: "az-Latn-AZ", language: "az", script: "Latn", region: "AZ", name_en: "Azerbaijani (Latin, Azerbaijan)", name_native: "azərbaycan (latın, Azərbaycan)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "few", "many", "other"], fallback: ["az-Latn", "az"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ba⟩) THEN (
    CREATE i18n_locale:⟨ba⟩ CONTENT { tag: "ba", language: "ba", script: NONE, region: NONE, name_en: "Bashkir", name_native: "башҡорт", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ba-RU⟩) THEN (
    CREATE i18n_locale:⟨ba-RU⟩ CONTENT { tag: "ba-RU", language: "ba", script: NONE, region: "RU", name_en: "Bashkir (Russia)", name_native: "башҡорт (Рәсәй)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["ba"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨bal-Latn⟩) THEN (
    CREATE i18n_locale:⟨bal-Latn⟩ CONTENT { tag: "bal-Latn", language: "bal", script: "Latn", region: NONE, name_en: "Baluchi (Latin)", name_native: "Balóchi (Látin)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨bal-Latn-PK⟩) THEN (
    CREATE i18n_locale:⟨bal-Latn-PK⟩ CONTENT { tag: "bal-Latn-PK", language: "bal", script: "Latn", region: "PK", name_en: "Baluchi (Latin, Pakistan)", name_native: "Balóchi (Látin Engrézi (Látin) Engrézi (Látin, Amrikáay Tepákén Están) syáhag: Látini, Pákestán)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "other"], fallback: ["bal-Latn"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨bas⟩) THEN (
    CREATE i18n_locale:⟨bas⟩ CONTENT { tag: "bas", language: "bas", script: NONE, region: NONE, name_en: "Basaa", name_native: "Ɓàsàa", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨bas-CM⟩) THEN (
    CREATE i18n_locale:⟨bas-CM⟩ CONTENT { tag: "bas-CM", language: "bas", script: NONE, region: "CM", name_en: "Basaa (Cameroon)", name_native: "Ɓàsàa (Kàmɛ̀rûn)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["bas"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨be⟩) THEN (
    CREATE i18n_locale:⟨be⟩ CONTENT { tag: "be", language: "be", script: NONE, region: NONE, name_en: "Belarusian", name_native: "беларуская", direction: "ltr", plural_cardinal: ["one", "few", "many", "other"], plural_ordinal: ["few", "other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨be-BY⟩) THEN (
    CREATE i18n_locale:⟨be-BY⟩ CONTENT { tag: "be-BY", language: "be", script: NONE, region: "BY", name_en: "Belarusian (Belarus)", name_native: "беларуская (Беларусь)", direction: "ltr", plural_cardinal: ["one", "few", "many", "other"], plural_ordinal: ["few", "other"], fallback: ["be"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨bem⟩) THEN (
    CREATE i18n_locale:⟨bem⟩ CONTENT { tag: "bem", language: "bem", script: NONE, region: NONE, name_en: "Bemba", name_native: "Ichibemba", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨bem-ZM⟩) THEN (
    CREATE i18n_locale:⟨bem-ZM⟩ CONTENT { tag: "bem-ZM", language: "bem", script: NONE, region: "ZM", name_en: "Bemba (Zambia)", name_native: "Ichibemba (Zambia)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["bem"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨bez⟩) THEN (
    CREATE i18n_locale:⟨bez⟩ CONTENT { tag: "bez", language: "bez", script: NONE, region: NONE, name_en: "Bena", name_native: "Hibena", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨bez-TZ⟩) THEN (
    CREATE i18n_locale:⟨bez-TZ⟩ CONTENT { tag: "bez-TZ", language: "bez", script: NONE, region: "TZ", name_en: "Bena (Tanzania)", name_native: "Hibena (Hutanzania)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["bez"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨bg⟩) THEN (
    CREATE i18n_locale:⟨bg⟩ CONTENT { tag: "bg", language: "bg", script: NONE, region: NONE, name_en: "Bulgarian", name_native: "български", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨bg-BG⟩) THEN (
    CREATE i18n_locale:⟨bg-BG⟩ CONTENT { tag: "bg-BG", language: "bg", script: NONE, region: "BG", name_en: "Bulgarian (Bulgaria)", name_native: "български (България)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["bg"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨bgc⟩) THEN (
    CREATE i18n_locale:⟨bgc⟩ CONTENT { tag: "bgc", language: "bgc", script: NONE, region: NONE, name_en: "Haryanvi", name_native: "हरियाणवी", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨bgc-IN⟩) THEN (
    CREATE i18n_locale:⟨bgc-IN⟩ CONTENT { tag: "bgc-IN", language: "bgc", script: NONE, region: "IN", name_en: "Haryanvi (India)", name_native: "हरियाणवी (भारत)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["bgc"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨bho⟩) THEN (
    CREATE i18n_locale:⟨bho⟩ CONTENT { tag: "bho", language: "bho", script: NONE, region: NONE, name_en: "Bhojpuri", name_native: "भोजपुरी", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨bho-IN⟩) THEN (
    CREATE i18n_locale:⟨bho-IN⟩ CONTENT { tag: "bho-IN", language: "bho", script: NONE, region: "IN", name_en: "Bhojpuri (India)", name_native: "भोजपुरी (भारत)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["bho"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨blo⟩) THEN (
    CREATE i18n_locale:⟨blo⟩ CONTENT { tag: "blo", language: "blo", script: NONE, region: NONE, name_en: "Anii", name_native: "anii kagɩja", direction: "ltr", plural_cardinal: ["zero", "one", "other"], plural_ordinal: ["zero", "one", "few", "other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨blo-BJ⟩) THEN (
    CREATE i18n_locale:⟨blo-BJ⟩ CONTENT { tag: "blo-BJ", language: "blo", script: NONE, region: "BJ", name_en: "Anii (Benin)", name_native: "anii kagɩja (Benɛɛ)", direction: "ltr", plural_cardinal: ["zero", "one", "other"], plural_ordinal: ["zero", "one", "few", "other"], fallback: ["blo"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨bm⟩) THEN (
    CREATE i18n_locale:⟨bm⟩ CONTENT { tag: "bm", language: "bm", script: NONE, region: NONE, name_en: "Bambara", name_native: "bamanakan", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨bm-ML⟩) THEN (
    CREATE i18n_locale:⟨bm-ML⟩ CONTENT { tag: "bm-ML", language: "bm", script: NONE, region: "ML", name_en: "Bambara (Mali)", name_native: "bamanakan (Mali)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["bm"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨bn⟩) THEN (
    CREATE i18n_locale:⟨bn⟩ CONTENT { tag: "bn", language: "bn", script: NONE, region: NONE, name_en: "Bangla", name_native: "বাংলা", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "many", "other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨bn-BD⟩) THEN (
    CREATE i18n_locale:⟨bn-BD⟩ CONTENT { tag: "bn-BD", language: "bn", script: NONE, region: "BD", name_en: "Bangla (Bangladesh)", name_native: "বাংলা (বাংলাদেশ)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "many", "other"], fallback: ["bn"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨bn-IN⟩) THEN (
    CREATE i18n_locale:⟨bn-IN⟩ CONTENT { tag: "bn-IN", language: "bn", script: NONE, region: "IN", name_en: "Bangla (India)", name_native: "বাংলা (ভারত)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "many", "other"], fallback: ["bn"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨bo⟩) THEN (
    CREATE i18n_locale:⟨bo⟩ CONTENT { tag: "bo", language: "bo", script: NONE, region: NONE, name_en: "Tibetan", name_native: "བོད་སྐད་", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨bo-CN⟩) THEN (
    CREATE i18n_locale:⟨bo-CN⟩ CONTENT { tag: "bo-CN", language: "bo", script: NONE, region: "CN", name_en: "Tibetan (China)", name_native: "བོད་སྐད་ (རྒྱ་ནག)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["bo"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨bo-IN⟩) THEN (
    CREATE i18n_locale:⟨bo-IN⟩ CONTENT { tag: "bo-IN", language: "bo", script: NONE, region: "IN", name_en: "Tibetan (India)", name_native: "བོད་སྐད་ (རྒྱ་གར་)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["bo"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨br⟩) THEN (
    CREATE i18n_locale:⟨br⟩ CONTENT { tag: "br", language: "br", script: NONE, region: NONE, name_en: "Breton", name_native: "brezhoneg", direction: "ltr", plural_cardinal: ["one", "two", "few", "many", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨br-FR⟩) THEN (
    CREATE i18n_locale:⟨br-FR⟩ CONTENT { tag: "br-FR", language: "br", script: NONE, region: "FR", name_en: "Breton (France)", name_native: "brezhoneg (Frañs)", direction: "ltr", plural_cardinal: ["one", "two", "few", "many", "other"], plural_ordinal: ["other"], fallback: ["br"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨brx⟩) THEN (
    CREATE i18n_locale:⟨brx⟩ CONTENT { tag: "brx", language: "brx", script: NONE, region: NONE, name_en: "Bodo", name_native: "बर’", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨brx-IN⟩) THEN (
    CREATE i18n_locale:⟨brx-IN⟩ CONTENT { tag: "brx-IN", language: "brx", script: NONE, region: "IN", name_en: "Bodo (India)", name_native: "बर’ (भारत)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["brx"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨bs⟩) THEN (
    CREATE i18n_locale:⟨bs⟩ CONTENT { tag: "bs", language: "bs", script: NONE, region: NONE, name_en: "Bosnian", name_native: "bosanski", direction: "ltr", plural_cardinal: ["one", "few", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨bs-Cyrl⟩) THEN (
    CREATE i18n_locale:⟨bs-Cyrl⟩ CONTENT { tag: "bs-Cyrl", language: "bs", script: "Cyrl", region: NONE, name_en: "Bosnian (Cyrillic)", name_native: "босански (ћирилица)", direction: "ltr", plural_cardinal: ["one", "few", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨bs-Cyrl-BA⟩) THEN (
    CREATE i18n_locale:⟨bs-Cyrl-BA⟩ CONTENT { tag: "bs-Cyrl-BA", language: "bs", script: "Cyrl", region: "BA", name_en: "Bosnian (Cyrillic, Bosnia & Herzegovina)", name_native: "босански (ћирилица, Босна и Херцеговина)", direction: "ltr", plural_cardinal: ["one", "few", "other"], plural_ordinal: ["other"], fallback: ["bs-Cyrl"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨bs-Latn⟩) THEN (
    CREATE i18n_locale:⟨bs-Latn⟩ CONTENT { tag: "bs-Latn", language: "bs", script: "Latn", region: NONE, name_en: "Bosnian (Latin)", name_native: "bosanski (latinica)", direction: "ltr", plural_cardinal: ["one", "few", "other"], plural_ordinal: ["other"], fallback: ["bs"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨bs-Latn-BA⟩) THEN (
    CREATE i18n_locale:⟨bs-Latn-BA⟩ CONTENT { tag: "bs-Latn-BA", language: "bs", script: "Latn", region: "BA", name_en: "Bosnian (Latin, Bosnia & Herzegovina)", name_native: "bosanski (latinica, Bosna i Hercegovina)", direction: "ltr", plural_cardinal: ["one", "few", "other"], plural_ordinal: ["other"], fallback: ["bs-Latn", "bs"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨bua⟩) THEN (
    CREATE i18n_locale:⟨bua⟩ CONTENT { tag: "bua", language: "bua", script: NONE, region: NONE, name_en: "Buriat", name_native: "буряад", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨bua-RU⟩) THEN (
    CREATE i18n_locale:⟨bua-RU⟩ CONTENT { tag: "bua-RU", language: "bua", script: NONE, region: "RU", name_en: "Buriat (Russia)", name_native: "буряад (Ород Улас)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["bua"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ca⟩) THEN (
    CREATE i18n_locale:⟨ca⟩ CONTENT { tag: "ca", language: "ca", script: NONE, region: NONE, name_en: "Catalan", name_native: "català", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ca-AD⟩) THEN (
    CREATE i18n_locale:⟨ca-AD⟩ CONTENT { tag: "ca-AD", language: "ca", script: NONE, region: "AD", name_en: "Catalan (Andorra)", name_native: "català (Andorra)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["ca"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ca-ES⟩) THEN (
    CREATE i18n_locale:⟨ca-ES⟩ CONTENT { tag: "ca-ES", language: "ca", script: NONE, region: "ES", name_en: "Catalan (Spain)", name_native: "català (Espanya)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["ca"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ca-FR⟩) THEN (
    CREATE i18n_locale:⟨ca-FR⟩ CONTENT { tag: "ca-FR", language: "ca", script: NONE, region: "FR", name_en: "Catalan (France)", name_native: "català (França)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["ca"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ca-IT⟩) THEN (
    CREATE i18n_locale:⟨ca-IT⟩ CONTENT { tag: "ca-IT", language: "ca", script: NONE, region: "IT", name_en: "Catalan (Italy)", name_native: "català (Itàlia)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["ca"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ccp⟩) THEN (
    CREATE i18n_locale:⟨ccp⟩ CONTENT { tag: "ccp", language: "ccp", script: NONE, region: NONE, name_en: "Chakma", name_native: "𑄌𑄋𑄴𑄟𑄳𑄦", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ccp-BD⟩) THEN (
    CREATE i18n_locale:⟨ccp-BD⟩ CONTENT { tag: "ccp-BD", language: "ccp", script: NONE, region: "BD", name_en: "Chakma (Bangladesh)", name_native: "𑄌𑄋𑄴𑄟𑄳𑄦 (𑄝𑄁𑄣𑄘𑄬𑄌𑄴)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["ccp"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ccp-IN⟩) THEN (
    CREATE i18n_locale:⟨ccp-IN⟩ CONTENT { tag: "ccp-IN", language: "ccp", script: NONE, region: "IN", name_en: "Chakma (India)", name_native: "𑄌𑄋𑄴𑄟𑄳𑄦 (𑄞𑄢𑄧𑄖𑄴)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["ccp"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ce⟩) THEN (
    CREATE i18n_locale:⟨ce⟩ CONTENT { tag: "ce", language: "ce", script: NONE, region: NONE, name_en: "Chechen", name_native: "нохчийн", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ce-RU⟩) THEN (
    CREATE i18n_locale:⟨ce-RU⟩ CONTENT { tag: "ce-RU", language: "ce", script: NONE, region: "RU", name_en: "Chechen (Russia)", name_native: "нохчийн (Росси)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["ce"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ceb⟩) THEN (
    CREATE i18n_locale:⟨ceb⟩ CONTENT { tag: "ceb", language: "ceb", script: NONE, region: NONE, name_en: "Cebuano", name_native: "Cebuano", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ceb-PH⟩) THEN (
    CREATE i18n_locale:⟨ceb-PH⟩ CONTENT { tag: "ceb-PH", language: "ceb", script: NONE, region: "PH", name_en: "Cebuano (Philippines)", name_native: "Cebuano (Philippines)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["ceb"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨cgg⟩) THEN (
    CREATE i18n_locale:⟨cgg⟩ CONTENT { tag: "cgg", language: "cgg", script: NONE, region: NONE, name_en: "Chiga", name_native: "Rukiga", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨cgg-UG⟩) THEN (
    CREATE i18n_locale:⟨cgg-UG⟩ CONTENT { tag: "cgg-UG", language: "cgg", script: NONE, region: "UG", name_en: "Chiga (Uganda)", name_native: "Rukiga (Uganda)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["cgg"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨chr⟩) THEN (
    CREATE i18n_locale:⟨chr⟩ CONTENT { tag: "chr", language: "chr", script: NONE, region: NONE, name_en: "Cherokee", name_native: "ᏣᎳᎩ", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨chr-US⟩) THEN (
    CREATE i18n_locale:⟨chr-US⟩ CONTENT { tag: "chr-US", language: "chr", script: NONE, region: "US", name_en: "Cherokee (United States)", name_native: "ᏣᎳᎩ (ᏌᏊ ᎢᏳᎾᎵᏍᏔᏅ ᏍᎦᏚᎩ)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["chr"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ckb⟩) THEN (
    CREATE i18n_locale:⟨ckb⟩ CONTENT { tag: "ckb", language: "ckb", script: NONE, region: NONE, name_en: "Central Kurdish", name_native: "کوردیی ناوەندی", direction: "rtl", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ckb-IQ⟩) THEN (
    CREATE i18n_locale:⟨ckb-IQ⟩ CONTENT { tag: "ckb-IQ", language: "ckb", script: NONE, region: "IQ", name_en: "Central Kurdish (Iraq)", name_native: "کوردیی ناوەندی (عێراق)", direction: "rtl", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["ckb"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ckb-IR⟩) THEN (
    CREATE i18n_locale:⟨ckb-IR⟩ CONTENT { tag: "ckb-IR", language: "ckb", script: NONE, region: "IR", name_en: "Central Kurdish (Iran)", name_native: "کوردیی ناوەندی (ئێران)", direction: "rtl", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["ckb"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨cop⟩) THEN (
    CREATE i18n_locale:⟨cop⟩ CONTENT { tag: "cop", language: "cop", script: NONE, region: NONE, name_en: "Coptic", name_native: "ϯⲙⲉⲧⲣⲉⲙⲛ̀ⲭⲏⲙⲓ", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨cop-EG⟩) THEN (
    CREATE i18n_locale:⟨cop-EG⟩ CONTENT { tag: "cop-EG", language: "cop", script: NONE, region: "EG", name_en: "Coptic (Egypt)", name_native: "ϯⲙⲉⲧⲣⲉⲙⲛ̀ⲭⲏⲙⲓ (ⲭⲏⲙⲓ)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["cop"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨cs⟩) THEN (
    CREATE i18n_locale:⟨cs⟩ CONTENT { tag: "cs", language: "cs", script: NONE, region: NONE, name_en: "Czech", name_native: "čeština", direction: "ltr", plural_cardinal: ["one", "few", "many", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨cs-CZ⟩) THEN (
    CREATE i18n_locale:⟨cs-CZ⟩ CONTENT { tag: "cs-CZ", language: "cs", script: NONE, region: "CZ", name_en: "Czech (Czechia)", name_native: "čeština (Česko)", direction: "ltr", plural_cardinal: ["one", "few", "many", "other"], plural_ordinal: ["other"], fallback: ["cs"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨csw⟩) THEN (
    CREATE i18n_locale:⟨csw⟩ CONTENT { tag: "csw", language: "csw", script: NONE, region: NONE, name_en: "Swampy Cree", name_native: "ᓀᐦᐃᓇᐍᐏᐣ", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨csw-CA⟩) THEN (
    CREATE i18n_locale:⟨csw-CA⟩ CONTENT { tag: "csw-CA", language: "csw", script: NONE, region: "CA", name_en: "Swampy Cree (Canada)", name_native: "ᓀᐦᐃᓇᐍᐏᐣ (ᑳᓇᑕ)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["csw"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨cv⟩) THEN (
    CREATE i18n_locale:⟨cv⟩ CONTENT { tag: "cv", language: "cv", script: NONE, region: NONE, name_en: "Chuvash", name_native: "чӑваш чӗлхи", direction: "ltr", plural_cardinal: ["zero", "one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨cv-RU⟩) THEN (
    CREATE i18n_locale:⟨cv-RU⟩ CONTENT { tag: "cv-RU", language: "cv", script: NONE, region: "RU", name_en: "Chuvash (Russia)", name_native: "чӑваш чӗлхи (Раҫҫей)", direction: "ltr", plural_cardinal: ["zero", "one", "other"], plural_ordinal: ["other"], fallback: ["cv"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨cy⟩) THEN (
    CREATE i18n_locale:⟨cy⟩ CONTENT { tag: "cy", language: "cy", script: NONE, region: NONE, name_en: "Welsh", name_native: "Cymraeg", direction: "ltr", plural_cardinal: ["zero", "one", "two", "few", "many", "other"], plural_ordinal: ["zero", "one", "two", "few", "many", "other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨cy-GB⟩) THEN (
    CREATE i18n_locale:⟨cy-GB⟩ CONTENT { tag: "cy-GB", language: "cy", script: NONE, region: "GB", name_en: "Welsh (United Kingdom)", name_native: "Cymraeg (Y Deyrnas Unedig)", direction: "ltr", plural_cardinal: ["zero", "one", "two", "few", "many", "other"], plural_ordinal: ["zero", "one", "two", "few", "many", "other"], fallback: ["cy"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨da⟩) THEN (
    CREATE i18n_locale:⟨da⟩ CONTENT { tag: "da", language: "da", script: NONE, region: NONE, name_en: "Danish", name_native: "dansk", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨da-DK⟩) THEN (
    CREATE i18n_locale:⟨da-DK⟩ CONTENT { tag: "da-DK", language: "da", script: NONE, region: "DK", name_en: "Danish (Denmark)", name_native: "dansk (Danmark)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["da"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨da-GL⟩) THEN (
    CREATE i18n_locale:⟨da-GL⟩ CONTENT { tag: "da-GL", language: "da", script: NONE, region: "GL", name_en: "Danish (Greenland)", name_native: "dansk (Grønland)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["da"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨dav⟩) THEN (
    CREATE i18n_locale:⟨dav⟩ CONTENT { tag: "dav", language: "dav", script: NONE, region: NONE, name_en: "Taita", name_native: "Kitaita", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨dav-KE⟩) THEN (
    CREATE i18n_locale:⟨dav-KE⟩ CONTENT { tag: "dav-KE", language: "dav", script: NONE, region: "KE", name_en: "Taita (Kenya)", name_native: "Kitaita (Kenya)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["dav"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨de⟩) THEN (
    CREATE i18n_locale:⟨de⟩ CONTENT { tag: "de", language: "de", script: NONE, region: NONE, name_en: "German", name_native: "Deutsch", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨de-AT⟩) THEN (
    CREATE i18n_locale:⟨de-AT⟩ CONTENT { tag: "de-AT", language: "de", script: NONE, region: "AT", name_en: "Austrian German", name_native: "Österreichisches Deutsch", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["de"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨de-BE⟩) THEN (
    CREATE i18n_locale:⟨de-BE⟩ CONTENT { tag: "de-BE", language: "de", script: NONE, region: "BE", name_en: "German (Belgium)", name_native: "Deutsch (Belgien)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["de"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨de-CH⟩) THEN (
    CREATE i18n_locale:⟨de-CH⟩ CONTENT { tag: "de-CH", language: "de", script: NONE, region: "CH", name_en: "Swiss High German", name_native: "Schweizer Hochdeutsch", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["de"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨de-DE⟩) THEN (
    CREATE i18n_locale:⟨de-DE⟩ CONTENT { tag: "de-DE", language: "de", script: NONE, region: "DE", name_en: "German (Germany)", name_native: "Deutsch (Deutschland)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["de"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨de-IT⟩) THEN (
    CREATE i18n_locale:⟨de-IT⟩ CONTENT { tag: "de-IT", language: "de", script: NONE, region: "IT", name_en: "German (Italy)", name_native: "Deutsch (Italien)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["de"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨de-LI⟩) THEN (
    CREATE i18n_locale:⟨de-LI⟩ CONTENT { tag: "de-LI", language: "de", script: NONE, region: "LI", name_en: "German (Liechtenstein)", name_native: "Deutsch (Liechtenstein)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["de"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨de-LU⟩) THEN (
    CREATE i18n_locale:⟨de-LU⟩ CONTENT { tag: "de-LU", language: "de", script: NONE, region: "LU", name_en: "German (Luxembourg)", name_native: "Deutsch (Luxemburg)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["de"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨dje⟩) THEN (
    CREATE i18n_locale:⟨dje⟩ CONTENT { tag: "dje", language: "dje", script: NONE, region: NONE, name_en: "Zarma", name_native: "Zarmaciine", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨dje-NE⟩) THEN (
    CREATE i18n_locale:⟨dje-NE⟩ CONTENT { tag: "dje-NE", language: "dje", script: NONE, region: "NE", name_en: "Zarma (Niger)", name_native: "Zarmaciine (Nižer)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["dje"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨doi⟩) THEN (
    CREATE i18n_locale:⟨doi⟩ CONTENT { tag: "doi", language: "doi", script: NONE, region: NONE, name_en: "Dogri", name_native: "डोगरी", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨doi-IN⟩) THEN (
    CREATE i18n_locale:⟨doi-IN⟩ CONTENT { tag: "doi-IN", language: "doi", script: NONE, region: "IN", name_en: "Dogri (India)", name_native: "डोगरी (भारत)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["doi"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨dsb⟩) THEN (
    CREATE i18n_locale:⟨dsb⟩ CONTENT { tag: "dsb", language: "dsb", script: NONE, region: NONE, name_en: "Lower Sorbian", name_native: "dolnoserbšćina", direction: "ltr", plural_cardinal: ["one", "two", "few", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨dsb-DE⟩) THEN (
    CREATE i18n_locale:⟨dsb-DE⟩ CONTENT { tag: "dsb-DE", language: "dsb", script: NONE, region: "DE", name_en: "Lower Sorbian (Germany)", name_native: "dolnoserbšćina (Nimska)", direction: "ltr", plural_cardinal: ["one", "two", "few", "other"], plural_ordinal: ["other"], fallback: ["dsb"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨dua⟩) THEN (
    CREATE i18n_locale:⟨dua⟩ CONTENT { tag: "dua", language: "dua", script: NONE, region: NONE, name_en: "Duala", name_native: "duálá", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨dua-CM⟩) THEN (
    CREATE i18n_locale:⟨dua-CM⟩ CONTENT { tag: "dua-CM", language: "dua", script: NONE, region: "CM", name_en: "Duala (Cameroon)", name_native: "duálá (Cameroun)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["dua"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨dyo⟩) THEN (
    CREATE i18n_locale:⟨dyo⟩ CONTENT { tag: "dyo", language: "dyo", script: NONE, region: NONE, name_en: "Jola-Fonyi", name_native: "joola", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨dyo-SN⟩) THEN (
    CREATE i18n_locale:⟨dyo-SN⟩ CONTENT { tag: "dyo-SN", language: "dyo", script: NONE, region: "SN", name_en: "Jola-Fonyi (Senegal)", name_native: "joola (Senegal)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["dyo"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨dz⟩) THEN (
    CREATE i18n_locale:⟨dz⟩ CONTENT { tag: "dz", language: "dz", script: NONE, region: NONE, name_en: "Dzongkha", name_native: "རྫོང་ཁ", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨dz-BT⟩) THEN (
    CREATE i18n_locale:⟨dz-BT⟩ CONTENT { tag: "dz-BT", language: "dz", script: NONE, region: "BT", name_en: "Dzongkha (Bhutan)", name_native: "རྫོང་ཁ། (འབྲུག།)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["dz"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ebu⟩) THEN (
    CREATE i18n_locale:⟨ebu⟩ CONTENT { tag: "ebu", language: "ebu", script: NONE, region: NONE, name_en: "Embu", name_native: "Kĩembu", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ebu-KE⟩) THEN (
    CREATE i18n_locale:⟨ebu-KE⟩ CONTENT { tag: "ebu-KE", language: "ebu", script: NONE, region: "KE", name_en: "Embu (Kenya)", name_native: "Kĩembu (Kenya)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["ebu"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ee⟩) THEN (
    CREATE i18n_locale:⟨ee⟩ CONTENT { tag: "ee", language: "ee", script: NONE, region: NONE, name_en: "Ewe", name_native: "eʋegbe", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ee-GH⟩) THEN (
    CREATE i18n_locale:⟨ee-GH⟩ CONTENT { tag: "ee-GH", language: "ee", script: NONE, region: "GH", name_en: "Ewe (Ghana)", name_native: "eʋegbe (Ghana nutome)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["ee"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ee-TG⟩) THEN (
    CREATE i18n_locale:⟨ee-TG⟩ CONTENT { tag: "ee-TG", language: "ee", script: NONE, region: "TG", name_en: "Ewe (Togo)", name_native: "eʋegbe (Togo nutome)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["ee"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨el⟩) THEN (
    CREATE i18n_locale:⟨el⟩ CONTENT { tag: "el", language: "el", script: NONE, region: NONE, name_en: "Greek", name_native: "Ελληνικά", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨el-CY⟩) THEN (
    CREATE i18n_locale:⟨el-CY⟩ CONTENT { tag: "el-CY", language: "el", script: NONE, region: "CY", name_en: "Greek (Cyprus)", name_native: "Ελληνικά (Κύπρος)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["el"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨el-GR⟩) THEN (
    CREATE i18n_locale:⟨el-GR⟩ CONTENT { tag: "el-GR", language: "el", script: NONE, region: "GR", name_en: "Greek (Greece)", name_native: "Ελληνικά (Ελλάδα)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["el"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en⟩) THEN (
    CREATE i18n_locale:⟨en⟩ CONTENT { tag: "en", language: "en", script: NONE, region: NONE, name_en: "English", name_native: "English", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: [], active: true, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-001⟩) THEN (
    CREATE i18n_locale:⟨en-001⟩ CONTENT { tag: "en-001", language: "en", script: NONE, region: "001", name_en: "English (world)", name_native: "English (world)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-150⟩) THEN (
    CREATE i18n_locale:⟨en-150⟩ CONTENT { tag: "en-150", language: "en", script: NONE, region: "150", name_en: "English (Europe)", name_native: "English (Europe)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-AE⟩) THEN (
    CREATE i18n_locale:⟨en-AE⟩ CONTENT { tag: "en-AE", language: "en", script: NONE, region: "AE", name_en: "English (United Arab Emirates)", name_native: "English (United Arab Emirates)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-AG⟩) THEN (
    CREATE i18n_locale:⟨en-AG⟩ CONTENT { tag: "en-AG", language: "en", script: NONE, region: "AG", name_en: "English (Antigua & Barbuda)", name_native: "English (Antigua & Barbuda)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-AI⟩) THEN (
    CREATE i18n_locale:⟨en-AI⟩ CONTENT { tag: "en-AI", language: "en", script: NONE, region: "AI", name_en: "English (Anguilla)", name_native: "English (Anguilla)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-AS⟩) THEN (
    CREATE i18n_locale:⟨en-AS⟩ CONTENT { tag: "en-AS", language: "en", script: NONE, region: "AS", name_en: "English (American Samoa)", name_native: "English (American Samoa)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-AT⟩) THEN (
    CREATE i18n_locale:⟨en-AT⟩ CONTENT { tag: "en-AT", language: "en", script: NONE, region: "AT", name_en: "English (Austria)", name_native: "English (Austria)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-150", "en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-AU⟩) THEN (
    CREATE i18n_locale:⟨en-AU⟩ CONTENT { tag: "en-AU", language: "en", script: NONE, region: "AU", name_en: "Australian English", name_native: "Australian English", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-BB⟩) THEN (
    CREATE i18n_locale:⟨en-BB⟩ CONTENT { tag: "en-BB", language: "en", script: NONE, region: "BB", name_en: "English (Barbados)", name_native: "English (Barbados)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-BE⟩) THEN (
    CREATE i18n_locale:⟨en-BE⟩ CONTENT { tag: "en-BE", language: "en", script: NONE, region: "BE", name_en: "English (Belgium)", name_native: "English (Belgium)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-150", "en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-BI⟩) THEN (
    CREATE i18n_locale:⟨en-BI⟩ CONTENT { tag: "en-BI", language: "en", script: NONE, region: "BI", name_en: "English (Burundi)", name_native: "English (Burundi)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-BM⟩) THEN (
    CREATE i18n_locale:⟨en-BM⟩ CONTENT { tag: "en-BM", language: "en", script: NONE, region: "BM", name_en: "English (Bermuda)", name_native: "English (Bermuda)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-BS⟩) THEN (
    CREATE i18n_locale:⟨en-BS⟩ CONTENT { tag: "en-BS", language: "en", script: NONE, region: "BS", name_en: "English (Bahamas)", name_native: "English (Bahamas)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-BW⟩) THEN (
    CREATE i18n_locale:⟨en-BW⟩ CONTENT { tag: "en-BW", language: "en", script: NONE, region: "BW", name_en: "English (Botswana)", name_native: "English (Botswana)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-BZ⟩) THEN (
    CREATE i18n_locale:⟨en-BZ⟩ CONTENT { tag: "en-BZ", language: "en", script: NONE, region: "BZ", name_en: "English (Belize)", name_native: "English (Belize)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-CA⟩) THEN (
    CREATE i18n_locale:⟨en-CA⟩ CONTENT { tag: "en-CA", language: "en", script: NONE, region: "CA", name_en: "Canadian English", name_native: "Canadian English", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-CC⟩) THEN (
    CREATE i18n_locale:⟨en-CC⟩ CONTENT { tag: "en-CC", language: "en", script: NONE, region: "CC", name_en: "English (Cocos (Keeling) Islands)", name_native: "English (Cocos (Keeling) Islands)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-CH⟩) THEN (
    CREATE i18n_locale:⟨en-CH⟩ CONTENT { tag: "en-CH", language: "en", script: NONE, region: "CH", name_en: "English (Switzerland)", name_native: "English (Switzerland)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-150", "en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-CK⟩) THEN (
    CREATE i18n_locale:⟨en-CK⟩ CONTENT { tag: "en-CK", language: "en", script: NONE, region: "CK", name_en: "English (Cook Islands)", name_native: "English (Cook Islands)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-CM⟩) THEN (
    CREATE i18n_locale:⟨en-CM⟩ CONTENT { tag: "en-CM", language: "en", script: NONE, region: "CM", name_en: "English (Cameroon)", name_native: "English (Cameroon)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-CX⟩) THEN (
    CREATE i18n_locale:⟨en-CX⟩ CONTENT { tag: "en-CX", language: "en", script: NONE, region: "CX", name_en: "English (Christmas Island)", name_native: "English (Christmas Island)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-CY⟩) THEN (
    CREATE i18n_locale:⟨en-CY⟩ CONTENT { tag: "en-CY", language: "en", script: NONE, region: "CY", name_en: "English (Cyprus)", name_native: "English (Cyprus)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-CZ⟩) THEN (
    CREATE i18n_locale:⟨en-CZ⟩ CONTENT { tag: "en-CZ", language: "en", script: NONE, region: "CZ", name_en: "English (Czechia)", name_native: "English (Czechia)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-150", "en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-DE⟩) THEN (
    CREATE i18n_locale:⟨en-DE⟩ CONTENT { tag: "en-DE", language: "en", script: NONE, region: "DE", name_en: "English (Germany)", name_native: "English (Germany)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-150", "en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-DG⟩) THEN (
    CREATE i18n_locale:⟨en-DG⟩ CONTENT { tag: "en-DG", language: "en", script: NONE, region: "DG", name_en: "English (Diego Garcia)", name_native: "English (Diego Garcia)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-DK⟩) THEN (
    CREATE i18n_locale:⟨en-DK⟩ CONTENT { tag: "en-DK", language: "en", script: NONE, region: "DK", name_en: "English (Denmark)", name_native: "English (Denmark)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-150", "en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-DM⟩) THEN (
    CREATE i18n_locale:⟨en-DM⟩ CONTENT { tag: "en-DM", language: "en", script: NONE, region: "DM", name_en: "English (Dominica)", name_native: "English (Dominica)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-EE⟩) THEN (
    CREATE i18n_locale:⟨en-EE⟩ CONTENT { tag: "en-EE", language: "en", script: NONE, region: "EE", name_en: "English (Estonia)", name_native: "English (Estonia)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-150", "en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-ER⟩) THEN (
    CREATE i18n_locale:⟨en-ER⟩ CONTENT { tag: "en-ER", language: "en", script: NONE, region: "ER", name_en: "English (Eritrea)", name_native: "English (Eritrea)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-ES⟩) THEN (
    CREATE i18n_locale:⟨en-ES⟩ CONTENT { tag: "en-ES", language: "en", script: NONE, region: "ES", name_en: "English (Spain)", name_native: "English (Spain)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-150", "en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-FI⟩) THEN (
    CREATE i18n_locale:⟨en-FI⟩ CONTENT { tag: "en-FI", language: "en", script: NONE, region: "FI", name_en: "English (Finland)", name_native: "English (Finland)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-150", "en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-FJ⟩) THEN (
    CREATE i18n_locale:⟨en-FJ⟩ CONTENT { tag: "en-FJ", language: "en", script: NONE, region: "FJ", name_en: "English (Fiji)", name_native: "English (Fiji)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-FK⟩) THEN (
    CREATE i18n_locale:⟨en-FK⟩ CONTENT { tag: "en-FK", language: "en", script: NONE, region: "FK", name_en: "English (Falkland Islands)", name_native: "English (Falkland Islands)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-FM⟩) THEN (
    CREATE i18n_locale:⟨en-FM⟩ CONTENT { tag: "en-FM", language: "en", script: NONE, region: "FM", name_en: "English (Micronesia)", name_native: "English (Micronesia)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-FR⟩) THEN (
    CREATE i18n_locale:⟨en-FR⟩ CONTENT { tag: "en-FR", language: "en", script: NONE, region: "FR", name_en: "English (France)", name_native: "English (France)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-150", "en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-GB⟩) THEN (
    CREATE i18n_locale:⟨en-GB⟩ CONTENT { tag: "en-GB", language: "en", script: NONE, region: "GB", name_en: "British English", name_native: "British English", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-GD⟩) THEN (
    CREATE i18n_locale:⟨en-GD⟩ CONTENT { tag: "en-GD", language: "en", script: NONE, region: "GD", name_en: "English (Grenada)", name_native: "English (Grenada)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-GE⟩) THEN (
    CREATE i18n_locale:⟨en-GE⟩ CONTENT { tag: "en-GE", language: "en", script: NONE, region: "GE", name_en: "English (Georgia)", name_native: "English (Georgia)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-150", "en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-GG⟩) THEN (
    CREATE i18n_locale:⟨en-GG⟩ CONTENT { tag: "en-GG", language: "en", script: NONE, region: "GG", name_en: "English (Guernsey)", name_native: "English (Guernsey)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-GH⟩) THEN (
    CREATE i18n_locale:⟨en-GH⟩ CONTENT { tag: "en-GH", language: "en", script: NONE, region: "GH", name_en: "English (Ghana)", name_native: "English (Ghana)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-GI⟩) THEN (
    CREATE i18n_locale:⟨en-GI⟩ CONTENT { tag: "en-GI", language: "en", script: NONE, region: "GI", name_en: "English (Gibraltar)", name_native: "English (Gibraltar)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-GM⟩) THEN (
    CREATE i18n_locale:⟨en-GM⟩ CONTENT { tag: "en-GM", language: "en", script: NONE, region: "GM", name_en: "English (Gambia)", name_native: "English (Gambia)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-GS⟩) THEN (
    CREATE i18n_locale:⟨en-GS⟩ CONTENT { tag: "en-GS", language: "en", script: NONE, region: "GS", name_en: "English (South Georgia & South Sandwich Islands)", name_native: "English (South Georgia & South Sandwich Islands)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-GU⟩) THEN (
    CREATE i18n_locale:⟨en-GU⟩ CONTENT { tag: "en-GU", language: "en", script: NONE, region: "GU", name_en: "English (Guam)", name_native: "English (Guam)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-GY⟩) THEN (
    CREATE i18n_locale:⟨en-GY⟩ CONTENT { tag: "en-GY", language: "en", script: NONE, region: "GY", name_en: "English (Guyana)", name_native: "English (Guyana)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-HK⟩) THEN (
    CREATE i18n_locale:⟨en-HK⟩ CONTENT { tag: "en-HK", language: "en", script: NONE, region: "HK", name_en: "English (Hong Kong SAR China)", name_native: "English (Hong Kong SAR China)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-HU⟩) THEN (
    CREATE i18n_locale:⟨en-HU⟩ CONTENT { tag: "en-HU", language: "en", script: NONE, region: "HU", name_en: "English (Hungary)", name_native: "English (Hungary)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-150", "en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-ID⟩) THEN (
    CREATE i18n_locale:⟨en-ID⟩ CONTENT { tag: "en-ID", language: "en", script: NONE, region: "ID", name_en: "English (Indonesia)", name_native: "English (Indonesia)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-IE⟩) THEN (
    CREATE i18n_locale:⟨en-IE⟩ CONTENT { tag: "en-IE", language: "en", script: NONE, region: "IE", name_en: "English (Ireland)", name_native: "English (Ireland)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-IL⟩) THEN (
    CREATE i18n_locale:⟨en-IL⟩ CONTENT { tag: "en-IL", language: "en", script: NONE, region: "IL", name_en: "English (Israel)", name_native: "English (Israel)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-IM⟩) THEN (
    CREATE i18n_locale:⟨en-IM⟩ CONTENT { tag: "en-IM", language: "en", script: NONE, region: "IM", name_en: "English (Isle of Man)", name_native: "English (Isle of Man)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-IN⟩) THEN (
    CREATE i18n_locale:⟨en-IN⟩ CONTENT { tag: "en-IN", language: "en", script: NONE, region: "IN", name_en: "English (India)", name_native: "English (India)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-IO⟩) THEN (
    CREATE i18n_locale:⟨en-IO⟩ CONTENT { tag: "en-IO", language: "en", script: NONE, region: "IO", name_en: "English (British Indian Ocean Territory)", name_native: "English (British Indian Ocean Territory)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-IT⟩) THEN (
    CREATE i18n_locale:⟨en-IT⟩ CONTENT { tag: "en-IT", language: "en", script: NONE, region: "IT", name_en: "English (Italy)", name_native: "English (Italy)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-150", "en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-JE⟩) THEN (
    CREATE i18n_locale:⟨en-JE⟩ CONTENT { tag: "en-JE", language: "en", script: NONE, region: "JE", name_en: "English (Jersey)", name_native: "English (Jersey)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-JM⟩) THEN (
    CREATE i18n_locale:⟨en-JM⟩ CONTENT { tag: "en-JM", language: "en", script: NONE, region: "JM", name_en: "English (Jamaica)", name_native: "English (Jamaica)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-JP⟩) THEN (
    CREATE i18n_locale:⟨en-JP⟩ CONTENT { tag: "en-JP", language: "en", script: NONE, region: "JP", name_en: "English (Japan)", name_native: "English (Japan)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-KE⟩) THEN (
    CREATE i18n_locale:⟨en-KE⟩ CONTENT { tag: "en-KE", language: "en", script: NONE, region: "KE", name_en: "English (Kenya)", name_native: "English (Kenya)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-KI⟩) THEN (
    CREATE i18n_locale:⟨en-KI⟩ CONTENT { tag: "en-KI", language: "en", script: NONE, region: "KI", name_en: "English (Kiribati)", name_native: "English (Kiribati)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-KN⟩) THEN (
    CREATE i18n_locale:⟨en-KN⟩ CONTENT { tag: "en-KN", language: "en", script: NONE, region: "KN", name_en: "English (St. Kitts & Nevis)", name_native: "English (St Kitts & Nevis)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-KY⟩) THEN (
    CREATE i18n_locale:⟨en-KY⟩ CONTENT { tag: "en-KY", language: "en", script: NONE, region: "KY", name_en: "English (Cayman Islands)", name_native: "English (Cayman Islands)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-LC⟩) THEN (
    CREATE i18n_locale:⟨en-LC⟩ CONTENT { tag: "en-LC", language: "en", script: NONE, region: "LC", name_en: "English (St. Lucia)", name_native: "English (St Lucia)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-LR⟩) THEN (
    CREATE i18n_locale:⟨en-LR⟩ CONTENT { tag: "en-LR", language: "en", script: NONE, region: "LR", name_en: "English (Liberia)", name_native: "English (Liberia)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-LS⟩) THEN (
    CREATE i18n_locale:⟨en-LS⟩ CONTENT { tag: "en-LS", language: "en", script: NONE, region: "LS", name_en: "English (Lesotho)", name_native: "English (Lesotho)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-LT⟩) THEN (
    CREATE i18n_locale:⟨en-LT⟩ CONTENT { tag: "en-LT", language: "en", script: NONE, region: "LT", name_en: "English (Lithuania)", name_native: "English (Lithuania)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-150", "en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-LV⟩) THEN (
    CREATE i18n_locale:⟨en-LV⟩ CONTENT { tag: "en-LV", language: "en", script: NONE, region: "LV", name_en: "English (Latvia)", name_native: "English (Latvia)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-150", "en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-MG⟩) THEN (
    CREATE i18n_locale:⟨en-MG⟩ CONTENT { tag: "en-MG", language: "en", script: NONE, region: "MG", name_en: "English (Madagascar)", name_native: "English (Madagascar)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-MH⟩) THEN (
    CREATE i18n_locale:⟨en-MH⟩ CONTENT { tag: "en-MH", language: "en", script: NONE, region: "MH", name_en: "English (Marshall Islands)", name_native: "English (Marshall Islands)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-MO⟩) THEN (
    CREATE i18n_locale:⟨en-MO⟩ CONTENT { tag: "en-MO", language: "en", script: NONE, region: "MO", name_en: "English (Macao SAR China)", name_native: "English (Macao SAR China)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-MP⟩) THEN (
    CREATE i18n_locale:⟨en-MP⟩ CONTENT { tag: "en-MP", language: "en", script: NONE, region: "MP", name_en: "English (Northern Mariana Islands)", name_native: "English (Northern Mariana Islands)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-MS⟩) THEN (
    CREATE i18n_locale:⟨en-MS⟩ CONTENT { tag: "en-MS", language: "en", script: NONE, region: "MS", name_en: "English (Montserrat)", name_native: "English (Montserrat)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-MT⟩) THEN (
    CREATE i18n_locale:⟨en-MT⟩ CONTENT { tag: "en-MT", language: "en", script: NONE, region: "MT", name_en: "English (Malta)", name_native: "English (Malta)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-MU⟩) THEN (
    CREATE i18n_locale:⟨en-MU⟩ CONTENT { tag: "en-MU", language: "en", script: NONE, region: "MU", name_en: "English (Mauritius)", name_native: "English (Mauritius)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-MV⟩) THEN (
    CREATE i18n_locale:⟨en-MV⟩ CONTENT { tag: "en-MV", language: "en", script: NONE, region: "MV", name_en: "English (Maldives)", name_native: "English (Maldives)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-MW⟩) THEN (
    CREATE i18n_locale:⟨en-MW⟩ CONTENT { tag: "en-MW", language: "en", script: NONE, region: "MW", name_en: "English (Malawi)", name_native: "English (Malawi)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-MY⟩) THEN (
    CREATE i18n_locale:⟨en-MY⟩ CONTENT { tag: "en-MY", language: "en", script: NONE, region: "MY", name_en: "English (Malaysia)", name_native: "English (Malaysia)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-NA⟩) THEN (
    CREATE i18n_locale:⟨en-NA⟩ CONTENT { tag: "en-NA", language: "en", script: NONE, region: "NA", name_en: "English (Namibia)", name_native: "English (Namibia)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-NF⟩) THEN (
    CREATE i18n_locale:⟨en-NF⟩ CONTENT { tag: "en-NF", language: "en", script: NONE, region: "NF", name_en: "English (Norfolk Island)", name_native: "English (Norfolk Island)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-NG⟩) THEN (
    CREATE i18n_locale:⟨en-NG⟩ CONTENT { tag: "en-NG", language: "en", script: NONE, region: "NG", name_en: "English (Nigeria)", name_native: "English (Nigeria)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-NL⟩) THEN (
    CREATE i18n_locale:⟨en-NL⟩ CONTENT { tag: "en-NL", language: "en", script: NONE, region: "NL", name_en: "English (Netherlands)", name_native: "English (Netherlands)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-150", "en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-NO⟩) THEN (
    CREATE i18n_locale:⟨en-NO⟩ CONTENT { tag: "en-NO", language: "en", script: NONE, region: "NO", name_en: "English (Norway)", name_native: "English (Norway)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-150", "en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-NR⟩) THEN (
    CREATE i18n_locale:⟨en-NR⟩ CONTENT { tag: "en-NR", language: "en", script: NONE, region: "NR", name_en: "English (Nauru)", name_native: "English (Nauru)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-NU⟩) THEN (
    CREATE i18n_locale:⟨en-NU⟩ CONTENT { tag: "en-NU", language: "en", script: NONE, region: "NU", name_en: "English (Niue)", name_native: "English (Niue)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-NZ⟩) THEN (
    CREATE i18n_locale:⟨en-NZ⟩ CONTENT { tag: "en-NZ", language: "en", script: NONE, region: "NZ", name_en: "English (New Zealand)", name_native: "English (New Zealand)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-PG⟩) THEN (
    CREATE i18n_locale:⟨en-PG⟩ CONTENT { tag: "en-PG", language: "en", script: NONE, region: "PG", name_en: "English (Papua New Guinea)", name_native: "English (Papua New Guinea)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-PH⟩) THEN (
    CREATE i18n_locale:⟨en-PH⟩ CONTENT { tag: "en-PH", language: "en", script: NONE, region: "PH", name_en: "English (Philippines)", name_native: "English (Philippines)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-PK⟩) THEN (
    CREATE i18n_locale:⟨en-PK⟩ CONTENT { tag: "en-PK", language: "en", script: NONE, region: "PK", name_en: "English (Pakistan)", name_native: "English (Pakistan)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-PL⟩) THEN (
    CREATE i18n_locale:⟨en-PL⟩ CONTENT { tag: "en-PL", language: "en", script: NONE, region: "PL", name_en: "English (Poland)", name_native: "English (Poland)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-150", "en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-PN⟩) THEN (
    CREATE i18n_locale:⟨en-PN⟩ CONTENT { tag: "en-PN", language: "en", script: NONE, region: "PN", name_en: "English (Pitcairn Islands)", name_native: "English (Pitcairn Islands)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-PR⟩) THEN (
    CREATE i18n_locale:⟨en-PR⟩ CONTENT { tag: "en-PR", language: "en", script: NONE, region: "PR", name_en: "English (Puerto Rico)", name_native: "English (Puerto Rico)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-PT⟩) THEN (
    CREATE i18n_locale:⟨en-PT⟩ CONTENT { tag: "en-PT", language: "en", script: NONE, region: "PT", name_en: "English (Portugal)", name_native: "English (Portugal)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-150", "en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-PW⟩) THEN (
    CREATE i18n_locale:⟨en-PW⟩ CONTENT { tag: "en-PW", language: "en", script: NONE, region: "PW", name_en: "English (Palau)", name_native: "English (Palau)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-RO⟩) THEN (
    CREATE i18n_locale:⟨en-RO⟩ CONTENT { tag: "en-RO", language: "en", script: NONE, region: "RO", name_en: "English (Romania)", name_native: "English (Romania)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-150", "en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-RW⟩) THEN (
    CREATE i18n_locale:⟨en-RW⟩ CONTENT { tag: "en-RW", language: "en", script: NONE, region: "RW", name_en: "English (Rwanda)", name_native: "English (Rwanda)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-SB⟩) THEN (
    CREATE i18n_locale:⟨en-SB⟩ CONTENT { tag: "en-SB", language: "en", script: NONE, region: "SB", name_en: "English (Solomon Islands)", name_native: "English (Solomon Islands)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-SC⟩) THEN (
    CREATE i18n_locale:⟨en-SC⟩ CONTENT { tag: "en-SC", language: "en", script: NONE, region: "SC", name_en: "English (Seychelles)", name_native: "English (Seychelles)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-SD⟩) THEN (
    CREATE i18n_locale:⟨en-SD⟩ CONTENT { tag: "en-SD", language: "en", script: NONE, region: "SD", name_en: "English (Sudan)", name_native: "English (Sudan)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-SE⟩) THEN (
    CREATE i18n_locale:⟨en-SE⟩ CONTENT { tag: "en-SE", language: "en", script: NONE, region: "SE", name_en: "English (Sweden)", name_native: "English (Sweden)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-150", "en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-SG⟩) THEN (
    CREATE i18n_locale:⟨en-SG⟩ CONTENT { tag: "en-SG", language: "en", script: NONE, region: "SG", name_en: "English (Singapore)", name_native: "English (Singapore)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-SH⟩) THEN (
    CREATE i18n_locale:⟨en-SH⟩ CONTENT { tag: "en-SH", language: "en", script: NONE, region: "SH", name_en: "English (St. Helena, Ascension & Tristan da Cunha)", name_native: "English (St Helena, Ascension & Tristan da Cunha)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-SI⟩) THEN (
    CREATE i18n_locale:⟨en-SI⟩ CONTENT { tag: "en-SI", language: "en", script: NONE, region: "SI", name_en: "English (Slovenia)", name_native: "English (Slovenia)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-150", "en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-SK⟩) THEN (
    CREATE i18n_locale:⟨en-SK⟩ CONTENT { tag: "en-SK", language: "en", script: NONE, region: "SK", name_en: "English (Slovakia)", name_native: "English (Slovakia)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-150", "en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-SL⟩) THEN (
    CREATE i18n_locale:⟨en-SL⟩ CONTENT { tag: "en-SL", language: "en", script: NONE, region: "SL", name_en: "English (Sierra Leone)", name_native: "English (Sierra Leone)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-SS⟩) THEN (
    CREATE i18n_locale:⟨en-SS⟩ CONTENT { tag: "en-SS", language: "en", script: NONE, region: "SS", name_en: "English (South Sudan)", name_native: "English (South Sudan)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-SX⟩) THEN (
    CREATE i18n_locale:⟨en-SX⟩ CONTENT { tag: "en-SX", language: "en", script: NONE, region: "SX", name_en: "English (Sint Maarten)", name_native: "English (Sint Maarten)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-SZ⟩) THEN (
    CREATE i18n_locale:⟨en-SZ⟩ CONTENT { tag: "en-SZ", language: "en", script: NONE, region: "SZ", name_en: "English (Eswatini)", name_native: "English (Eswatini)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-TC⟩) THEN (
    CREATE i18n_locale:⟨en-TC⟩ CONTENT { tag: "en-TC", language: "en", script: NONE, region: "TC", name_en: "English (Turks & Caicos Islands)", name_native: "English (Turks & Caicos Islands)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-TK⟩) THEN (
    CREATE i18n_locale:⟨en-TK⟩ CONTENT { tag: "en-TK", language: "en", script: NONE, region: "TK", name_en: "English (Tokelau)", name_native: "English (Tokelau)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-TO⟩) THEN (
    CREATE i18n_locale:⟨en-TO⟩ CONTENT { tag: "en-TO", language: "en", script: NONE, region: "TO", name_en: "English (Tonga)", name_native: "English (Tonga)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-TT⟩) THEN (
    CREATE i18n_locale:⟨en-TT⟩ CONTENT { tag: "en-TT", language: "en", script: NONE, region: "TT", name_en: "English (Trinidad & Tobago)", name_native: "English (Trinidad & Tobago)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-TV⟩) THEN (
    CREATE i18n_locale:⟨en-TV⟩ CONTENT { tag: "en-TV", language: "en", script: NONE, region: "TV", name_en: "English (Tuvalu)", name_native: "English (Tuvalu)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-TZ⟩) THEN (
    CREATE i18n_locale:⟨en-TZ⟩ CONTENT { tag: "en-TZ", language: "en", script: NONE, region: "TZ", name_en: "English (Tanzania)", name_native: "English (Tanzania)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-UA⟩) THEN (
    CREATE i18n_locale:⟨en-UA⟩ CONTENT { tag: "en-UA", language: "en", script: NONE, region: "UA", name_en: "English (Ukraine)", name_native: "English (Ukraine)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-150", "en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-UG⟩) THEN (
    CREATE i18n_locale:⟨en-UG⟩ CONTENT { tag: "en-UG", language: "en", script: NONE, region: "UG", name_en: "English (Uganda)", name_native: "English (Uganda)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-UM⟩) THEN (
    CREATE i18n_locale:⟨en-UM⟩ CONTENT { tag: "en-UM", language: "en", script: NONE, region: "UM", name_en: "English (U.S. Outlying Islands)", name_native: "English (U.S. Outlying Islands)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-US⟩) THEN (
    CREATE i18n_locale:⟨en-US⟩ CONTENT { tag: "en-US", language: "en", script: NONE, region: "US", name_en: "American English", name_native: "American English", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-VC⟩) THEN (
    CREATE i18n_locale:⟨en-VC⟩ CONTENT { tag: "en-VC", language: "en", script: NONE, region: "VC", name_en: "English (St. Vincent & Grenadines)", name_native: "English (St Vincent & the Grenadines)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-VG⟩) THEN (
    CREATE i18n_locale:⟨en-VG⟩ CONTENT { tag: "en-VG", language: "en", script: NONE, region: "VG", name_en: "English (British Virgin Islands)", name_native: "English (British Virgin Islands)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-VI⟩) THEN (
    CREATE i18n_locale:⟨en-VI⟩ CONTENT { tag: "en-VI", language: "en", script: NONE, region: "VI", name_en: "English (U.S. Virgin Islands)", name_native: "English (U.S. Virgin Islands)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-VU⟩) THEN (
    CREATE i18n_locale:⟨en-VU⟩ CONTENT { tag: "en-VU", language: "en", script: NONE, region: "VU", name_en: "English (Vanuatu)", name_native: "English (Vanuatu)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-WS⟩) THEN (
    CREATE i18n_locale:⟨en-WS⟩ CONTENT { tag: "en-WS", language: "en", script: NONE, region: "WS", name_en: "English (Samoa)", name_native: "English (Samoa)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-ZA⟩) THEN (
    CREATE i18n_locale:⟨en-ZA⟩ CONTENT { tag: "en-ZA", language: "en", script: NONE, region: "ZA", name_en: "English (South Africa)", name_native: "English (South Africa)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-ZM⟩) THEN (
    CREATE i18n_locale:⟨en-ZM⟩ CONTENT { tag: "en-ZM", language: "en", script: NONE, region: "ZM", name_en: "English (Zambia)", name_native: "English (Zambia)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨en-ZW⟩) THEN (
    CREATE i18n_locale:⟨en-ZW⟩ CONTENT { tag: "en-ZW", language: "en", script: NONE, region: "ZW", name_en: "English (Zimbabwe)", name_native: "English (Zimbabwe)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨eo⟩) THEN (
    CREATE i18n_locale:⟨eo⟩ CONTENT { tag: "eo", language: "eo", script: NONE, region: NONE, name_en: "Esperanto", name_native: "Esperanto", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨eo-001⟩) THEN (
    CREATE i18n_locale:⟨eo-001⟩ CONTENT { tag: "eo-001", language: "eo", script: NONE, region: "001", name_en: "Esperanto (world)", name_native: "Esperanto (mondo)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["eo"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨es⟩) THEN (
    CREATE i18n_locale:⟨es⟩ CONTENT { tag: "es", language: "es", script: NONE, region: NONE, name_en: "Spanish", name_native: "español", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨es-419⟩) THEN (
    CREATE i18n_locale:⟨es-419⟩ CONTENT { tag: "es-419", language: "es", script: NONE, region: "419", name_en: "Latin American Spanish", name_native: "español latinoamericano", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "other"], fallback: ["es"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨es-AR⟩) THEN (
    CREATE i18n_locale:⟨es-AR⟩ CONTENT { tag: "es-AR", language: "es", script: NONE, region: "AR", name_en: "Spanish (Argentina)", name_native: "español (Argentina)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "other"], fallback: ["es-419", "es"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨es-BO⟩) THEN (
    CREATE i18n_locale:⟨es-BO⟩ CONTENT { tag: "es-BO", language: "es", script: NONE, region: "BO", name_en: "Spanish (Bolivia)", name_native: "español (Bolivia)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "other"], fallback: ["es-419", "es"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨es-BR⟩) THEN (
    CREATE i18n_locale:⟨es-BR⟩ CONTENT { tag: "es-BR", language: "es", script: NONE, region: "BR", name_en: "Spanish (Brazil)", name_native: "español (Brasil)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "other"], fallback: ["es-419", "es"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨es-BZ⟩) THEN (
    CREATE i18n_locale:⟨es-BZ⟩ CONTENT { tag: "es-BZ", language: "es", script: NONE, region: "BZ", name_en: "Spanish (Belize)", name_native: "español (Belice)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "other"], fallback: ["es-419", "es"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨es-CL⟩) THEN (
    CREATE i18n_locale:⟨es-CL⟩ CONTENT { tag: "es-CL", language: "es", script: NONE, region: "CL", name_en: "Spanish (Chile)", name_native: "español (Chile)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "other"], fallback: ["es-419", "es"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨es-CO⟩) THEN (
    CREATE i18n_locale:⟨es-CO⟩ CONTENT { tag: "es-CO", language: "es", script: NONE, region: "CO", name_en: "Spanish (Colombia)", name_native: "español (Colombia)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "other"], fallback: ["es-419", "es"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨es-CR⟩) THEN (
    CREATE i18n_locale:⟨es-CR⟩ CONTENT { tag: "es-CR", language: "es", script: NONE, region: "CR", name_en: "Spanish (Costa Rica)", name_native: "español (Costa Rica)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "other"], fallback: ["es-419", "es"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨es-CU⟩) THEN (
    CREATE i18n_locale:⟨es-CU⟩ CONTENT { tag: "es-CU", language: "es", script: NONE, region: "CU", name_en: "Spanish (Cuba)", name_native: "español (Cuba)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "other"], fallback: ["es-419", "es"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨es-DO⟩) THEN (
    CREATE i18n_locale:⟨es-DO⟩ CONTENT { tag: "es-DO", language: "es", script: NONE, region: "DO", name_en: "Spanish (Dominican Republic)", name_native: "español (República Dominicana)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "other"], fallback: ["es-419", "es"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨es-EA⟩) THEN (
    CREATE i18n_locale:⟨es-EA⟩ CONTENT { tag: "es-EA", language: "es", script: NONE, region: "EA", name_en: "Spanish (Ceuta & Melilla)", name_native: "español (Ceuta y Melilla)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "other"], fallback: ["es"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨es-EC⟩) THEN (
    CREATE i18n_locale:⟨es-EC⟩ CONTENT { tag: "es-EC", language: "es", script: NONE, region: "EC", name_en: "Spanish (Ecuador)", name_native: "español (Ecuador)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "other"], fallback: ["es-419", "es"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨es-ES⟩) THEN (
    CREATE i18n_locale:⟨es-ES⟩ CONTENT { tag: "es-ES", language: "es", script: NONE, region: "ES", name_en: "European Spanish", name_native: "español de España", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "other"], fallback: ["es"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨es-GQ⟩) THEN (
    CREATE i18n_locale:⟨es-GQ⟩ CONTENT { tag: "es-GQ", language: "es", script: NONE, region: "GQ", name_en: "Spanish (Equatorial Guinea)", name_native: "español (Guinea Ecuatorial)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "other"], fallback: ["es"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨es-GT⟩) THEN (
    CREATE i18n_locale:⟨es-GT⟩ CONTENT { tag: "es-GT", language: "es", script: NONE, region: "GT", name_en: "Spanish (Guatemala)", name_native: "español (Guatemala)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "other"], fallback: ["es-419", "es"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨es-HN⟩) THEN (
    CREATE i18n_locale:⟨es-HN⟩ CONTENT { tag: "es-HN", language: "es", script: NONE, region: "HN", name_en: "Spanish (Honduras)", name_native: "español (Honduras)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "other"], fallback: ["es-419", "es"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨es-IC⟩) THEN (
    CREATE i18n_locale:⟨es-IC⟩ CONTENT { tag: "es-IC", language: "es", script: NONE, region: "IC", name_en: "Spanish (Canary Islands)", name_native: "español (Canarias)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "other"], fallback: ["es"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨es-MX⟩) THEN (
    CREATE i18n_locale:⟨es-MX⟩ CONTENT { tag: "es-MX", language: "es", script: NONE, region: "MX", name_en: "Mexican Spanish", name_native: "español de México", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "other"], fallback: ["es-419", "es"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨es-NI⟩) THEN (
    CREATE i18n_locale:⟨es-NI⟩ CONTENT { tag: "es-NI", language: "es", script: NONE, region: "NI", name_en: "Spanish (Nicaragua)", name_native: "español (Nicaragua)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "other"], fallback: ["es-419", "es"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨es-PA⟩) THEN (
    CREATE i18n_locale:⟨es-PA⟩ CONTENT { tag: "es-PA", language: "es", script: NONE, region: "PA", name_en: "Spanish (Panama)", name_native: "español (Panamá)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "other"], fallback: ["es-419", "es"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨es-PE⟩) THEN (
    CREATE i18n_locale:⟨es-PE⟩ CONTENT { tag: "es-PE", language: "es", script: NONE, region: "PE", name_en: "Spanish (Peru)", name_native: "español (Perú)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "other"], fallback: ["es-419", "es"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨es-PH⟩) THEN (
    CREATE i18n_locale:⟨es-PH⟩ CONTENT { tag: "es-PH", language: "es", script: NONE, region: "PH", name_en: "Spanish (Philippines)", name_native: "español (Filipinas)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "other"], fallback: ["es"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨es-PR⟩) THEN (
    CREATE i18n_locale:⟨es-PR⟩ CONTENT { tag: "es-PR", language: "es", script: NONE, region: "PR", name_en: "Spanish (Puerto Rico)", name_native: "español (Puerto Rico)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "other"], fallback: ["es-419", "es"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨es-PY⟩) THEN (
    CREATE i18n_locale:⟨es-PY⟩ CONTENT { tag: "es-PY", language: "es", script: NONE, region: "PY", name_en: "Spanish (Paraguay)", name_native: "español (Paraguay)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "other"], fallback: ["es-419", "es"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨es-SV⟩) THEN (
    CREATE i18n_locale:⟨es-SV⟩ CONTENT { tag: "es-SV", language: "es", script: NONE, region: "SV", name_en: "Spanish (El Salvador)", name_native: "español (El Salvador)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "other"], fallback: ["es-419", "es"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨es-US⟩) THEN (
    CREATE i18n_locale:⟨es-US⟩ CONTENT { tag: "es-US", language: "es", script: NONE, region: "US", name_en: "Spanish (United States)", name_native: "español (Estados Unidos)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "other"], fallback: ["es-419", "es"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨es-UY⟩) THEN (
    CREATE i18n_locale:⟨es-UY⟩ CONTENT { tag: "es-UY", language: "es", script: NONE, region: "UY", name_en: "Spanish (Uruguay)", name_native: "español (Uruguay)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "other"], fallback: ["es-419", "es"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨es-VE⟩) THEN (
    CREATE i18n_locale:⟨es-VE⟩ CONTENT { tag: "es-VE", language: "es", script: NONE, region: "VE", name_en: "Spanish (Venezuela)", name_native: "español (Venezuela)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "other"], fallback: ["es-419", "es"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨et⟩) THEN (
    CREATE i18n_locale:⟨et⟩ CONTENT { tag: "et", language: "et", script: NONE, region: NONE, name_en: "Estonian", name_native: "eesti", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨et-EE⟩) THEN (
    CREATE i18n_locale:⟨et-EE⟩ CONTENT { tag: "et-EE", language: "et", script: NONE, region: "EE", name_en: "Estonian (Estonia)", name_native: "eesti (Eesti)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["et"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨eu⟩) THEN (
    CREATE i18n_locale:⟨eu⟩ CONTENT { tag: "eu", language: "eu", script: NONE, region: NONE, name_en: "Basque", name_native: "euskara", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨eu-ES⟩) THEN (
    CREATE i18n_locale:⟨eu-ES⟩ CONTENT { tag: "eu-ES", language: "eu", script: NONE, region: "ES", name_en: "Basque (Spain)", name_native: "euskara (Espainia)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["eu"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ewo⟩) THEN (
    CREATE i18n_locale:⟨ewo⟩ CONTENT { tag: "ewo", language: "ewo", script: NONE, region: NONE, name_en: "Ewondo", name_native: "ewondo", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ewo-CM⟩) THEN (
    CREATE i18n_locale:⟨ewo-CM⟩ CONTENT { tag: "ewo-CM", language: "ewo", script: NONE, region: "CM", name_en: "Ewondo (Cameroon)", name_native: "ewondo (Kamərún)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["ewo"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨fa⟩) THEN (
    CREATE i18n_locale:⟨fa⟩ CONTENT { tag: "fa", language: "fa", script: NONE, region: NONE, name_en: "Persian", name_native: "فارسی", direction: "rtl", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨fa-AF⟩) THEN (
    CREATE i18n_locale:⟨fa-AF⟩ CONTENT { tag: "fa-AF", language: "fa", script: NONE, region: "AF", name_en: "Dari", name_native: "دری", direction: "rtl", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["fa"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨fa-IR⟩) THEN (
    CREATE i18n_locale:⟨fa-IR⟩ CONTENT { tag: "fa-IR", language: "fa", script: NONE, region: "IR", name_en: "Persian (Iran)", name_native: "فارسی (ایران)", direction: "rtl", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["fa"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ff⟩) THEN (
    CREATE i18n_locale:⟨ff⟩ CONTENT { tag: "ff", language: "ff", script: NONE, region: NONE, name_en: "Fula", name_native: "Pulaar", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ff-Adlm⟩) THEN (
    CREATE i18n_locale:⟨ff-Adlm⟩ CONTENT { tag: "ff-Adlm", language: "ff", script: "Adlm", region: NONE, name_en: "Fula (Adlam)", name_native: "𞤆𞤵𞤤𞤢𞤪 (𞤀𞤁𞤂𞤢𞤃)", direction: "rtl", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ff-Adlm-BF⟩) THEN (
    CREATE i18n_locale:⟨ff-Adlm-BF⟩ CONTENT { tag: "ff-Adlm-BF", language: "ff", script: "Adlm", region: "BF", name_en: "Fula (Adlam, Burkina Faso)", name_native: "𞤆𞤵𞤤𞤢𞤪 (𞤀𞤁𞤂𞤢𞤃⹁ 𞤄𞤵𞤪𞤳𞤭𞤲𞤢 𞤊𞤢𞤧𞤮𞥅)", direction: "rtl", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["ff-Adlm"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ff-Adlm-CM⟩) THEN (
    CREATE i18n_locale:⟨ff-Adlm-CM⟩ CONTENT { tag: "ff-Adlm-CM", language: "ff", script: "Adlm", region: "CM", name_en: "Fula (Adlam, Cameroon)", name_native: "𞤆𞤵𞤤𞤢𞤪 (𞤀𞤁𞤂𞤢𞤃⹁ 𞤑𞤢𞤥𞤢𞤪𞤵𞥅𞤲)", direction: "rtl", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["ff-Adlm"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ff-Adlm-GH⟩) THEN (
    CREATE i18n_locale:⟨ff-Adlm-GH⟩ CONTENT { tag: "ff-Adlm-GH", language: "ff", script: "Adlm", region: "GH", name_en: "Fula (Adlam, Ghana)", name_native: "𞤆𞤵𞤤𞤢𞤪 (𞤀𞤁𞤂𞤢𞤃⹁ 𞤘𞤢𞤲𞤢)", direction: "rtl", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["ff-Adlm"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ff-Adlm-GM⟩) THEN (
    CREATE i18n_locale:⟨ff-Adlm-GM⟩ CONTENT { tag: "ff-Adlm-GM", language: "ff", script: "Adlm", region: "GM", name_en: "Fula (Adlam, Gambia)", name_native: "𞤆𞤵𞤤𞤢𞤪 (𞤀𞤁𞤂𞤢𞤃⹁ 𞤘𞤢𞤥𞤦𞤭𞤴𞤢)", direction: "rtl", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["ff-Adlm"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ff-Adlm-GN⟩) THEN (
    CREATE i18n_locale:⟨ff-Adlm-GN⟩ CONTENT { tag: "ff-Adlm-GN", language: "ff", script: "Adlm", region: "GN", name_en: "Fula (Adlam, Guinea)", name_native: "𞤆𞤵𞤤𞤢𞤪 (𞤀𞤁𞤂𞤢𞤃⹁ 𞤘𞤭𞤲𞤫)", direction: "rtl", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["ff-Adlm"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ff-Adlm-GW⟩) THEN (
    CREATE i18n_locale:⟨ff-Adlm-GW⟩ CONTENT { tag: "ff-Adlm-GW", language: "ff", script: "Adlm", region: "GW", name_en: "Fula (Adlam, Guinea-Bissau)", name_native: "𞤆𞤵𞤤𞤢𞤪 (𞤀𞤁𞤂𞤢𞤃⹁ 𞤘𞤭𞤲𞤫-𞤄𞤭𞤧𞤢𞤱𞤮𞥅)", direction: "rtl", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["ff-Adlm"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ff-Adlm-LR⟩) THEN (
    CREATE i18n_locale:⟨ff-Adlm-LR⟩ CONTENT { tag: "ff-Adlm-LR", language: "ff", script: "Adlm", region: "LR", name_en: "Fula (Adlam, Liberia)", name_native: "𞤆𞤵𞤤𞤢𞤪 (𞤀𞤁𞤂𞤢𞤃⹁ 𞤂𞤢𞤦𞤭𞤪𞤭𞤴𞤢𞥄)", direction: "rtl", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["ff-Adlm"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ff-Adlm-MR⟩) THEN (
    CREATE i18n_locale:⟨ff-Adlm-MR⟩ CONTENT { tag: "ff-Adlm-MR", language: "ff", script: "Adlm", region: "MR", name_en: "Fula (Adlam, Mauritania)", name_native: "𞤆𞤵𞤤𞤢𞤪 (𞤀𞤁𞤂𞤢𞤃⹁ 𞤃𞤮𞤪𞤼𞤢𞤲𞤭𞥅)", direction: "rtl", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["ff-Adlm"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ff-Adlm-NE⟩) THEN (
    CREATE i18n_locale:⟨ff-Adlm-NE⟩ CONTENT { tag: "ff-Adlm-NE", language: "ff", script: "Adlm", region: "NE", name_en: "Fula (Adlam, Niger)", name_native: "𞤆𞤵𞤤𞤢𞤪 (𞤀𞤁𞤂𞤢𞤃⹁ 𞤐𞤭𞥅𞤶𞤫𞤪)", direction: "rtl", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["ff-Adlm"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ff-Adlm-NG⟩) THEN (
    CREATE i18n_locale:⟨ff-Adlm-NG⟩ CONTENT { tag: "ff-Adlm-NG", language: "ff", script: "Adlm", region: "NG", name_en: "Fula (Adlam, Nigeria)", name_native: "𞤆𞤵𞤤𞤢𞤪 (𞤀𞤁𞤂𞤢𞤃⹁ 𞤐𞤢𞤶𞤫𞤪𞤭𞤴𞤢𞥄)", direction: "rtl", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["ff-Adlm"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ff-Adlm-SL⟩) THEN (
    CREATE i18n_locale:⟨ff-Adlm-SL⟩ CONTENT { tag: "ff-Adlm-SL", language: "ff", script: "Adlm", region: "SL", name_en: "Fula (Adlam, Sierra Leone)", name_native: "𞤆𞤵𞤤𞤢𞤪 (𞤀𞤁𞤂𞤢𞤃⹁ 𞤅𞤢𞤪𞤢𞤤𞤮𞤲)", direction: "rtl", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["ff-Adlm"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ff-Adlm-SN⟩) THEN (
    CREATE i18n_locale:⟨ff-Adlm-SN⟩ CONTENT { tag: "ff-Adlm-SN", language: "ff", script: "Adlm", region: "SN", name_en: "Fula (Adlam, Senegal)", name_native: "𞤆𞤵𞤤𞤢𞤪 (𞤀𞤁𞤂𞤢𞤃⹁ 𞤅𞤫𞤲𞤫𞤺𞤢𞥄𞤤)", direction: "rtl", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["ff-Adlm"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ff-Latn⟩) THEN (
    CREATE i18n_locale:⟨ff-Latn⟩ CONTENT { tag: "ff-Latn", language: "ff", script: "Latn", region: NONE, name_en: "Fula (Latin)", name_native: "Pulaar (Latn)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["ff"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ff-Latn-BF⟩) THEN (
    CREATE i18n_locale:⟨ff-Latn-BF⟩ CONTENT { tag: "ff-Latn-BF", language: "ff", script: "Latn", region: "BF", name_en: "Fula (Latin, Burkina Faso)", name_native: "Pulaar (Latn, Burkibaa Faaso)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["ff-Latn", "ff"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ff-Latn-CM⟩) THEN (
    CREATE i18n_locale:⟨ff-Latn-CM⟩ CONTENT { tag: "ff-Latn-CM", language: "ff", script: "Latn", region: "CM", name_en: "Fula (Latin, Cameroon)", name_native: "Pulaar (Latn, Kameruun)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["ff-Latn", "ff"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ff-Latn-GH⟩) THEN (
    CREATE i18n_locale:⟨ff-Latn-GH⟩ CONTENT { tag: "ff-Latn-GH", language: "ff", script: "Latn", region: "GH", name_en: "Fula (Latin, Ghana)", name_native: "Pulaar (Latn, Ganaa)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["ff-Latn", "ff"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ff-Latn-GM⟩) THEN (
    CREATE i18n_locale:⟨ff-Latn-GM⟩ CONTENT { tag: "ff-Latn-GM", language: "ff", script: "Latn", region: "GM", name_en: "Fula (Latin, Gambia)", name_native: "Pulaar (Latn, Gammbi)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["ff-Latn", "ff"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ff-Latn-GN⟩) THEN (
    CREATE i18n_locale:⟨ff-Latn-GN⟩ CONTENT { tag: "ff-Latn-GN", language: "ff", script: "Latn", region: "GN", name_en: "Fula (Latin, Guinea)", name_native: "Pulaar (Latn, Gine)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["ff-Latn", "ff"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ff-Latn-GW⟩) THEN (
    CREATE i18n_locale:⟨ff-Latn-GW⟩ CONTENT { tag: "ff-Latn-GW", language: "ff", script: "Latn", region: "GW", name_en: "Fula (Latin, Guinea-Bissau)", name_native: "Pulaar (Latn, Gine-Bisaawo)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["ff-Latn", "ff"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ff-Latn-LR⟩) THEN (
    CREATE i18n_locale:⟨ff-Latn-LR⟩ CONTENT { tag: "ff-Latn-LR", language: "ff", script: "Latn", region: "LR", name_en: "Fula (Latin, Liberia)", name_native: "Pulaar (Latn, Liberiyaa)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["ff-Latn", "ff"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ff-Latn-MR⟩) THEN (
    CREATE i18n_locale:⟨ff-Latn-MR⟩ CONTENT { tag: "ff-Latn-MR", language: "ff", script: "Latn", region: "MR", name_en: "Fula (Latin, Mauritania)", name_native: "Pulaar (Latn, Muritani)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["ff-Latn", "ff"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ff-Latn-NE⟩) THEN (
    CREATE i18n_locale:⟨ff-Latn-NE⟩ CONTENT { tag: "ff-Latn-NE", language: "ff", script: "Latn", region: "NE", name_en: "Fula (Latin, Niger)", name_native: "Pulaar (Latn, Nijeer)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["ff-Latn", "ff"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ff-Latn-NG⟩) THEN (
    CREATE i18n_locale:⟨ff-Latn-NG⟩ CONTENT { tag: "ff-Latn-NG", language: "ff", script: "Latn", region: "NG", name_en: "Fula (Latin, Nigeria)", name_native: "Pulaar (Latn, Nijeriyaa)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["ff-Latn", "ff"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ff-Latn-SL⟩) THEN (
    CREATE i18n_locale:⟨ff-Latn-SL⟩ CONTENT { tag: "ff-Latn-SL", language: "ff", script: "Latn", region: "SL", name_en: "Fula (Latin, Sierra Leone)", name_native: "Pulaar (Latn, Seraa liyon)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["ff-Latn", "ff"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ff-Latn-SN⟩) THEN (
    CREATE i18n_locale:⟨ff-Latn-SN⟩ CONTENT { tag: "ff-Latn-SN", language: "ff", script: "Latn", region: "SN", name_en: "Fula (Latin, Senegal)", name_native: "Pulaar (Latn, Senegaal)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["ff-Latn", "ff"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨fi⟩) THEN (
    CREATE i18n_locale:⟨fi⟩ CONTENT { tag: "fi", language: "fi", script: NONE, region: NONE, name_en: "Finnish", name_native: "suomi", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨fi-FI⟩) THEN (
    CREATE i18n_locale:⟨fi-FI⟩ CONTENT { tag: "fi-FI", language: "fi", script: NONE, region: "FI", name_en: "Finnish (Finland)", name_native: "suomi (Suomi)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["fi"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨fil⟩) THEN (
    CREATE i18n_locale:⟨fil⟩ CONTENT { tag: "fil", language: "fil", script: NONE, region: NONE, name_en: "Filipino", name_native: "Filipino", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨fil-PH⟩) THEN (
    CREATE i18n_locale:⟨fil-PH⟩ CONTENT { tag: "fil-PH", language: "fil", script: NONE, region: "PH", name_en: "Filipino (Philippines)", name_native: "Filipino (Pilipinas)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "other"], fallback: ["fil"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨fo⟩) THEN (
    CREATE i18n_locale:⟨fo⟩ CONTENT { tag: "fo", language: "fo", script: NONE, region: NONE, name_en: "Faroese", name_native: "føroyskt", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨fo-DK⟩) THEN (
    CREATE i18n_locale:⟨fo-DK⟩ CONTENT { tag: "fo-DK", language: "fo", script: NONE, region: "DK", name_en: "Faroese (Denmark)", name_native: "føroyskt (Danmark)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["fo"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨fo-FO⟩) THEN (
    CREATE i18n_locale:⟨fo-FO⟩ CONTENT { tag: "fo-FO", language: "fo", script: NONE, region: "FO", name_en: "Faroese (Faroe Islands)", name_native: "føroyskt (Føroyar)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["fo"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨fr⟩) THEN (
    CREATE i18n_locale:⟨fr⟩ CONTENT { tag: "fr", language: "fr", script: NONE, region: NONE, name_en: "French", name_native: "français", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "other"], fallback: [], active: true, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨fr-BE⟩) THEN (
    CREATE i18n_locale:⟨fr-BE⟩ CONTENT { tag: "fr-BE", language: "fr", script: NONE, region: "BE", name_en: "French (Belgium)", name_native: "français (Belgique)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "other"], fallback: ["fr"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨fr-BF⟩) THEN (
    CREATE i18n_locale:⟨fr-BF⟩ CONTENT { tag: "fr-BF", language: "fr", script: NONE, region: "BF", name_en: "French (Burkina Faso)", name_native: "français (Burkina Faso)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "other"], fallback: ["fr"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨fr-BI⟩) THEN (
    CREATE i18n_locale:⟨fr-BI⟩ CONTENT { tag: "fr-BI", language: "fr", script: NONE, region: "BI", name_en: "French (Burundi)", name_native: "français (Burundi)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "other"], fallback: ["fr"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨fr-BJ⟩) THEN (
    CREATE i18n_locale:⟨fr-BJ⟩ CONTENT { tag: "fr-BJ", language: "fr", script: NONE, region: "BJ", name_en: "French (Benin)", name_native: "français (Bénin)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "other"], fallback: ["fr"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨fr-BL⟩) THEN (
    CREATE i18n_locale:⟨fr-BL⟩ CONTENT { tag: "fr-BL", language: "fr", script: NONE, region: "BL", name_en: "French (St. Barthélemy)", name_native: "français (Saint-Barthélemy)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "other"], fallback: ["fr"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨fr-CA⟩) THEN (
    CREATE i18n_locale:⟨fr-CA⟩ CONTENT { tag: "fr-CA", language: "fr", script: NONE, region: "CA", name_en: "Canadian French", name_native: "français canadien", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "other"], fallback: ["fr"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨fr-CD⟩) THEN (
    CREATE i18n_locale:⟨fr-CD⟩ CONTENT { tag: "fr-CD", language: "fr", script: NONE, region: "CD", name_en: "French (Congo - Kinshasa)", name_native: "français (Congo-Kinshasa)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "other"], fallback: ["fr"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨fr-CF⟩) THEN (
    CREATE i18n_locale:⟨fr-CF⟩ CONTENT { tag: "fr-CF", language: "fr", script: NONE, region: "CF", name_en: "French (Central African Republic)", name_native: "français (République centrafricaine)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "other"], fallback: ["fr"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨fr-CG⟩) THEN (
    CREATE i18n_locale:⟨fr-CG⟩ CONTENT { tag: "fr-CG", language: "fr", script: NONE, region: "CG", name_en: "French (Congo - Brazzaville)", name_native: "français (Congo-Brazzaville)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "other"], fallback: ["fr"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨fr-CH⟩) THEN (
    CREATE i18n_locale:⟨fr-CH⟩ CONTENT { tag: "fr-CH", language: "fr", script: NONE, region: "CH", name_en: "Swiss French", name_native: "français suisse", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "other"], fallback: ["fr"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨fr-CI⟩) THEN (
    CREATE i18n_locale:⟨fr-CI⟩ CONTENT { tag: "fr-CI", language: "fr", script: NONE, region: "CI", name_en: "French (Côte d’Ivoire)", name_native: "français (Côte d’Ivoire)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "other"], fallback: ["fr"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨fr-CM⟩) THEN (
    CREATE i18n_locale:⟨fr-CM⟩ CONTENT { tag: "fr-CM", language: "fr", script: NONE, region: "CM", name_en: "French (Cameroon)", name_native: "français (Cameroun)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "other"], fallback: ["fr"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨fr-DJ⟩) THEN (
    CREATE i18n_locale:⟨fr-DJ⟩ CONTENT { tag: "fr-DJ", language: "fr", script: NONE, region: "DJ", name_en: "French (Djibouti)", name_native: "français (Djibouti)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "other"], fallback: ["fr"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨fr-DZ⟩) THEN (
    CREATE i18n_locale:⟨fr-DZ⟩ CONTENT { tag: "fr-DZ", language: "fr", script: NONE, region: "DZ", name_en: "French (Algeria)", name_native: "français (Algérie)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "other"], fallback: ["fr"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨fr-FR⟩) THEN (
    CREATE i18n_locale:⟨fr-FR⟩ CONTENT { tag: "fr-FR", language: "fr", script: NONE, region: "FR", name_en: "French (France)", name_native: "français (France)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "other"], fallback: ["fr"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨fr-GA⟩) THEN (
    CREATE i18n_locale:⟨fr-GA⟩ CONTENT { tag: "fr-GA", language: "fr", script: NONE, region: "GA", name_en: "French (Gabon)", name_native: "français (Gabon)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "other"], fallback: ["fr"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨fr-GF⟩) THEN (
    CREATE i18n_locale:⟨fr-GF⟩ CONTENT { tag: "fr-GF", language: "fr", script: NONE, region: "GF", name_en: "French (French Guiana)", name_native: "français (Guyane française)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "other"], fallback: ["fr"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨fr-GN⟩) THEN (
    CREATE i18n_locale:⟨fr-GN⟩ CONTENT { tag: "fr-GN", language: "fr", script: NONE, region: "GN", name_en: "French (Guinea)", name_native: "français (Guinée)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "other"], fallback: ["fr"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨fr-GP⟩) THEN (
    CREATE i18n_locale:⟨fr-GP⟩ CONTENT { tag: "fr-GP", language: "fr", script: NONE, region: "GP", name_en: "French (Guadeloupe)", name_native: "français (Guadeloupe)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "other"], fallback: ["fr"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨fr-GQ⟩) THEN (
    CREATE i18n_locale:⟨fr-GQ⟩ CONTENT { tag: "fr-GQ", language: "fr", script: NONE, region: "GQ", name_en: "French (Equatorial Guinea)", name_native: "français (Guinée équatoriale)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "other"], fallback: ["fr"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨fr-HT⟩) THEN (
    CREATE i18n_locale:⟨fr-HT⟩ CONTENT { tag: "fr-HT", language: "fr", script: NONE, region: "HT", name_en: "French (Haiti)", name_native: "français (Haïti)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "other"], fallback: ["fr"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨fr-KM⟩) THEN (
    CREATE i18n_locale:⟨fr-KM⟩ CONTENT { tag: "fr-KM", language: "fr", script: NONE, region: "KM", name_en: "French (Comoros)", name_native: "français (Comores)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "other"], fallback: ["fr"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨fr-LU⟩) THEN (
    CREATE i18n_locale:⟨fr-LU⟩ CONTENT { tag: "fr-LU", language: "fr", script: NONE, region: "LU", name_en: "French (Luxembourg)", name_native: "français (Luxembourg)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "other"], fallback: ["fr"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨fr-MA⟩) THEN (
    CREATE i18n_locale:⟨fr-MA⟩ CONTENT { tag: "fr-MA", language: "fr", script: NONE, region: "MA", name_en: "French (Morocco)", name_native: "français (Maroc)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "other"], fallback: ["fr"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨fr-MC⟩) THEN (
    CREATE i18n_locale:⟨fr-MC⟩ CONTENT { tag: "fr-MC", language: "fr", script: NONE, region: "MC", name_en: "French (Monaco)", name_native: "français (Monaco)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "other"], fallback: ["fr"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨fr-MF⟩) THEN (
    CREATE i18n_locale:⟨fr-MF⟩ CONTENT { tag: "fr-MF", language: "fr", script: NONE, region: "MF", name_en: "French (St. Martin)", name_native: "français (Saint-Martin)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "other"], fallback: ["fr"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨fr-MG⟩) THEN (
    CREATE i18n_locale:⟨fr-MG⟩ CONTENT { tag: "fr-MG", language: "fr", script: NONE, region: "MG", name_en: "French (Madagascar)", name_native: "français (Madagascar)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "other"], fallback: ["fr"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨fr-ML⟩) THEN (
    CREATE i18n_locale:⟨fr-ML⟩ CONTENT { tag: "fr-ML", language: "fr", script: NONE, region: "ML", name_en: "French (Mali)", name_native: "français (Mali)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "other"], fallback: ["fr"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨fr-MQ⟩) THEN (
    CREATE i18n_locale:⟨fr-MQ⟩ CONTENT { tag: "fr-MQ", language: "fr", script: NONE, region: "MQ", name_en: "French (Martinique)", name_native: "français (Martinique)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "other"], fallback: ["fr"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨fr-MR⟩) THEN (
    CREATE i18n_locale:⟨fr-MR⟩ CONTENT { tag: "fr-MR", language: "fr", script: NONE, region: "MR", name_en: "French (Mauritania)", name_native: "français (Mauritanie)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "other"], fallback: ["fr"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨fr-MU⟩) THEN (
    CREATE i18n_locale:⟨fr-MU⟩ CONTENT { tag: "fr-MU", language: "fr", script: NONE, region: "MU", name_en: "French (Mauritius)", name_native: "français (Maurice)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "other"], fallback: ["fr"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨fr-NC⟩) THEN (
    CREATE i18n_locale:⟨fr-NC⟩ CONTENT { tag: "fr-NC", language: "fr", script: NONE, region: "NC", name_en: "French (New Caledonia)", name_native: "français (Nouvelle-Calédonie)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "other"], fallback: ["fr"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨fr-NE⟩) THEN (
    CREATE i18n_locale:⟨fr-NE⟩ CONTENT { tag: "fr-NE", language: "fr", script: NONE, region: "NE", name_en: "French (Niger)", name_native: "français (Niger)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "other"], fallback: ["fr"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨fr-PF⟩) THEN (
    CREATE i18n_locale:⟨fr-PF⟩ CONTENT { tag: "fr-PF", language: "fr", script: NONE, region: "PF", name_en: "French (French Polynesia)", name_native: "français (Polynésie française)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "other"], fallback: ["fr"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨fr-PM⟩) THEN (
    CREATE i18n_locale:⟨fr-PM⟩ CONTENT { tag: "fr-PM", language: "fr", script: NONE, region: "PM", name_en: "French (St. Pierre & Miquelon)", name_native: "français (Saint-Pierre-et-Miquelon)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "other"], fallback: ["fr"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨fr-RE⟩) THEN (
    CREATE i18n_locale:⟨fr-RE⟩ CONTENT { tag: "fr-RE", language: "fr", script: NONE, region: "RE", name_en: "French (Réunion)", name_native: "français (La Réunion)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "other"], fallback: ["fr"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨fr-RW⟩) THEN (
    CREATE i18n_locale:⟨fr-RW⟩ CONTENT { tag: "fr-RW", language: "fr", script: NONE, region: "RW", name_en: "French (Rwanda)", name_native: "français (Rwanda)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "other"], fallback: ["fr"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨fr-SC⟩) THEN (
    CREATE i18n_locale:⟨fr-SC⟩ CONTENT { tag: "fr-SC", language: "fr", script: NONE, region: "SC", name_en: "French (Seychelles)", name_native: "français (Seychelles)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "other"], fallback: ["fr"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨fr-SN⟩) THEN (
    CREATE i18n_locale:⟨fr-SN⟩ CONTENT { tag: "fr-SN", language: "fr", script: NONE, region: "SN", name_en: "French (Senegal)", name_native: "français (Sénégal)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "other"], fallback: ["fr"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨fr-SY⟩) THEN (
    CREATE i18n_locale:⟨fr-SY⟩ CONTENT { tag: "fr-SY", language: "fr", script: NONE, region: "SY", name_en: "French (Syria)", name_native: "français (Syrie)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "other"], fallback: ["fr"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨fr-TD⟩) THEN (
    CREATE i18n_locale:⟨fr-TD⟩ CONTENT { tag: "fr-TD", language: "fr", script: NONE, region: "TD", name_en: "French (Chad)", name_native: "français (Tchad)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "other"], fallback: ["fr"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨fr-TG⟩) THEN (
    CREATE i18n_locale:⟨fr-TG⟩ CONTENT { tag: "fr-TG", language: "fr", script: NONE, region: "TG", name_en: "French (Togo)", name_native: "français (Togo)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "other"], fallback: ["fr"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨fr-TN⟩) THEN (
    CREATE i18n_locale:⟨fr-TN⟩ CONTENT { tag: "fr-TN", language: "fr", script: NONE, region: "TN", name_en: "French (Tunisia)", name_native: "français (Tunisie)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "other"], fallback: ["fr"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨fr-VU⟩) THEN (
    CREATE i18n_locale:⟨fr-VU⟩ CONTENT { tag: "fr-VU", language: "fr", script: NONE, region: "VU", name_en: "French (Vanuatu)", name_native: "français (Vanuatu)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "other"], fallback: ["fr"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨fr-WF⟩) THEN (
    CREATE i18n_locale:⟨fr-WF⟩ CONTENT { tag: "fr-WF", language: "fr", script: NONE, region: "WF", name_en: "French (Wallis & Futuna)", name_native: "français (Wallis-et-Futuna)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "other"], fallback: ["fr"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨fr-YT⟩) THEN (
    CREATE i18n_locale:⟨fr-YT⟩ CONTENT { tag: "fr-YT", language: "fr", script: NONE, region: "YT", name_en: "French (Mayotte)", name_native: "français (Mayotte)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["one", "other"], fallback: ["fr"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨fur⟩) THEN (
    CREATE i18n_locale:⟨fur⟩ CONTENT { tag: "fur", language: "fur", script: NONE, region: NONE, name_en: "Friulian", name_native: "furlan", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨fur-IT⟩) THEN (
    CREATE i18n_locale:⟨fur-IT⟩ CONTENT { tag: "fur-IT", language: "fur", script: NONE, region: "IT", name_en: "Friulian (Italy)", name_native: "furlan (Italie)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["fur"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨fy⟩) THEN (
    CREATE i18n_locale:⟨fy⟩ CONTENT { tag: "fy", language: "fy", script: NONE, region: NONE, name_en: "Western Frisian", name_native: "Frysk", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨fy-NL⟩) THEN (
    CREATE i18n_locale:⟨fy-NL⟩ CONTENT { tag: "fy-NL", language: "fy", script: NONE, region: "NL", name_en: "Western Frisian (Netherlands)", name_native: "Frysk (Nederlân)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["fy"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ga⟩) THEN (
    CREATE i18n_locale:⟨ga⟩ CONTENT { tag: "ga", language: "ga", script: NONE, region: NONE, name_en: "Irish", name_native: "Gaeilge", direction: "ltr", plural_cardinal: ["one", "two", "few", "many", "other"], plural_ordinal: ["one", "other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ga-GB⟩) THEN (
    CREATE i18n_locale:⟨ga-GB⟩ CONTENT { tag: "ga-GB", language: "ga", script: NONE, region: "GB", name_en: "Irish (United Kingdom)", name_native: "Gaeilge (an Ríocht Aontaithe)", direction: "ltr", plural_cardinal: ["one", "two", "few", "many", "other"], plural_ordinal: ["one", "other"], fallback: ["ga"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ga-IE⟩) THEN (
    CREATE i18n_locale:⟨ga-IE⟩ CONTENT { tag: "ga-IE", language: "ga", script: NONE, region: "IE", name_en: "Irish (Ireland)", name_native: "Gaeilge (Éire)", direction: "ltr", plural_cardinal: ["one", "two", "few", "many", "other"], plural_ordinal: ["one", "other"], fallback: ["ga"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨gaa⟩) THEN (
    CREATE i18n_locale:⟨gaa⟩ CONTENT { tag: "gaa", language: "gaa", script: NONE, region: NONE, name_en: "Ga", name_native: "Gã", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨gaa-GH⟩) THEN (
    CREATE i18n_locale:⟨gaa-GH⟩ CONTENT { tag: "gaa-GH", language: "gaa", script: NONE, region: "GH", name_en: "Ga (Ghana)", name_native: "Gã (Ghana)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["gaa"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨gd⟩) THEN (
    CREATE i18n_locale:⟨gd⟩ CONTENT { tag: "gd", language: "gd", script: NONE, region: NONE, name_en: "Scottish Gaelic", name_native: "Gàidhlig", direction: "ltr", plural_cardinal: ["one", "two", "few", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨gd-GB⟩) THEN (
    CREATE i18n_locale:⟨gd-GB⟩ CONTENT { tag: "gd-GB", language: "gd", script: NONE, region: "GB", name_en: "Scottish Gaelic (United Kingdom)", name_native: "Gàidhlig (An Rìoghachd Aonaichte)", direction: "ltr", plural_cardinal: ["one", "two", "few", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["gd"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨gl⟩) THEN (
    CREATE i18n_locale:⟨gl⟩ CONTENT { tag: "gl", language: "gl", script: NONE, region: NONE, name_en: "Galician", name_native: "galego", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨gl-ES⟩) THEN (
    CREATE i18n_locale:⟨gl-ES⟩ CONTENT { tag: "gl-ES", language: "gl", script: NONE, region: "ES", name_en: "Galician (Spain)", name_native: "galego (España)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["other"], fallback: ["gl"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨gsw⟩) THEN (
    CREATE i18n_locale:⟨gsw⟩ CONTENT { tag: "gsw", language: "gsw", script: NONE, region: NONE, name_en: "Swiss German", name_native: "Schwiizertüütsch", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨gsw-CH⟩) THEN (
    CREATE i18n_locale:⟨gsw-CH⟩ CONTENT { tag: "gsw-CH", language: "gsw", script: NONE, region: "CH", name_en: "Swiss German (Switzerland)", name_native: "Schwiizertüütsch (Schwiiz)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["gsw"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨gsw-FR⟩) THEN (
    CREATE i18n_locale:⟨gsw-FR⟩ CONTENT { tag: "gsw-FR", language: "gsw", script: NONE, region: "FR", name_en: "Swiss German (France)", name_native: "Schwiizertüütsch (Frankriich)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["gsw"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨gsw-LI⟩) THEN (
    CREATE i18n_locale:⟨gsw-LI⟩ CONTENT { tag: "gsw-LI", language: "gsw", script: NONE, region: "LI", name_en: "Swiss German (Liechtenstein)", name_native: "Schwiizertüütsch (Liächteschtäi)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["gsw"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨gu⟩) THEN (
    CREATE i18n_locale:⟨gu⟩ CONTENT { tag: "gu", language: "gu", script: NONE, region: NONE, name_en: "Gujarati", name_native: "ગુજરાતી", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "many", "other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨gu-IN⟩) THEN (
    CREATE i18n_locale:⟨gu-IN⟩ CONTENT { tag: "gu-IN", language: "gu", script: NONE, region: "IN", name_en: "Gujarati (India)", name_native: "ગુજરાતી (ભારત)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "many", "other"], fallback: ["gu"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨guz⟩) THEN (
    CREATE i18n_locale:⟨guz⟩ CONTENT { tag: "guz", language: "guz", script: NONE, region: NONE, name_en: "Gusii", name_native: "Ekegusii", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨guz-KE⟩) THEN (
    CREATE i18n_locale:⟨guz-KE⟩ CONTENT { tag: "guz-KE", language: "guz", script: NONE, region: "KE", name_en: "Gusii (Kenya)", name_native: "Ekegusii (Kenya)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["guz"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨gv⟩) THEN (
    CREATE i18n_locale:⟨gv⟩ CONTENT { tag: "gv", language: "gv", script: NONE, region: NONE, name_en: "Manx", name_native: "Gaelg", direction: "ltr", plural_cardinal: ["one", "two", "few", "many", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨gv-IM⟩) THEN (
    CREATE i18n_locale:⟨gv-IM⟩ CONTENT { tag: "gv-IM", language: "gv", script: NONE, region: "IM", name_en: "Manx (Isle of Man)", name_native: "Gaelg (Ellan Vannin)", direction: "ltr", plural_cardinal: ["one", "two", "few", "many", "other"], plural_ordinal: ["other"], fallback: ["gv"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ha⟩) THEN (
    CREATE i18n_locale:⟨ha⟩ CONTENT { tag: "ha", language: "ha", script: NONE, region: NONE, name_en: "Hausa", name_native: "Hausa", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ha-GH⟩) THEN (
    CREATE i18n_locale:⟨ha-GH⟩ CONTENT { tag: "ha-GH", language: "ha", script: NONE, region: "GH", name_en: "Hausa (Ghana)", name_native: "Hausa (Gana)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["ha"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ha-NE⟩) THEN (
    CREATE i18n_locale:⟨ha-NE⟩ CONTENT { tag: "ha-NE", language: "ha", script: NONE, region: "NE", name_en: "Hausa (Niger)", name_native: "Hausa (Nijar)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["ha"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ha-NG⟩) THEN (
    CREATE i18n_locale:⟨ha-NG⟩ CONTENT { tag: "ha-NG", language: "ha", script: NONE, region: "NG", name_en: "Hausa (Nigeria)", name_native: "Hausa (Nijeriya)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["ha"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨haw⟩) THEN (
    CREATE i18n_locale:⟨haw⟩ CONTENT { tag: "haw", language: "haw", script: NONE, region: NONE, name_en: "Hawaiian", name_native: "ʻŌlelo Hawaiʻi", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨haw-US⟩) THEN (
    CREATE i18n_locale:⟨haw-US⟩ CONTENT { tag: "haw-US", language: "haw", script: NONE, region: "US", name_en: "Hawaiian (United States)", name_native: "ʻŌlelo Hawaiʻi (ʻAmelika Hui Pū ʻIa)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["haw"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨he⟩) THEN (
    CREATE i18n_locale:⟨he⟩ CONTENT { tag: "he", language: "he", script: NONE, region: NONE, name_en: "Hebrew", name_native: "עברית", direction: "rtl", plural_cardinal: ["one", "two", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨he-IL⟩) THEN (
    CREATE i18n_locale:⟨he-IL⟩ CONTENT { tag: "he-IL", language: "he", script: NONE, region: "IL", name_en: "Hebrew (Israel)", name_native: "עברית (ישראל)", direction: "rtl", plural_cardinal: ["one", "two", "other"], plural_ordinal: ["other"], fallback: ["he"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨hi⟩) THEN (
    CREATE i18n_locale:⟨hi⟩ CONTENT { tag: "hi", language: "hi", script: NONE, region: NONE, name_en: "Hindi", name_native: "हिन्दी", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "many", "other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨hi-IN⟩) THEN (
    CREATE i18n_locale:⟨hi-IN⟩ CONTENT { tag: "hi-IN", language: "hi", script: NONE, region: "IN", name_en: "Hindi (India)", name_native: "हिन्दी (भारत)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "many", "other"], fallback: ["hi"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨hi-Latn⟩) THEN (
    CREATE i18n_locale:⟨hi-Latn⟩ CONTENT { tag: "hi-Latn", language: "hi", script: "Latn", region: NONE, name_en: "Hindi (Latin)", name_native: "Hindi (Latin)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["en-IN", "en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨hi-Latn-IN⟩) THEN (
    CREATE i18n_locale:⟨hi-Latn-IN⟩ CONTENT { tag: "hi-Latn-IN", language: "hi", script: "Latn", region: "IN", name_en: "Hindi (Latin, India)", name_native: "Hindi (Latin, Bharat)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["hi-Latn", "en-IN", "en-001", "en"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨hr⟩) THEN (
    CREATE i18n_locale:⟨hr⟩ CONTENT { tag: "hr", language: "hr", script: NONE, region: NONE, name_en: "Croatian", name_native: "hrvatski", direction: "ltr", plural_cardinal: ["one", "few", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨hr-BA⟩) THEN (
    CREATE i18n_locale:⟨hr-BA⟩ CONTENT { tag: "hr-BA", language: "hr", script: NONE, region: "BA", name_en: "Croatian (Bosnia & Herzegovina)", name_native: "hrvatski (Bosna i Hercegovina)", direction: "ltr", plural_cardinal: ["one", "few", "other"], plural_ordinal: ["other"], fallback: ["hr"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨hr-HR⟩) THEN (
    CREATE i18n_locale:⟨hr-HR⟩ CONTENT { tag: "hr-HR", language: "hr", script: NONE, region: "HR", name_en: "Croatian (Croatia)", name_native: "hrvatski (Hrvatska)", direction: "ltr", plural_cardinal: ["one", "few", "other"], plural_ordinal: ["other"], fallback: ["hr"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨hsb⟩) THEN (
    CREATE i18n_locale:⟨hsb⟩ CONTENT { tag: "hsb", language: "hsb", script: NONE, region: NONE, name_en: "Upper Sorbian", name_native: "hornjoserbšćina", direction: "ltr", plural_cardinal: ["one", "two", "few", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨hsb-DE⟩) THEN (
    CREATE i18n_locale:⟨hsb-DE⟩ CONTENT { tag: "hsb-DE", language: "hsb", script: NONE, region: "DE", name_en: "Upper Sorbian (Germany)", name_native: "hornjoserbšćina (Němska)", direction: "ltr", plural_cardinal: ["one", "two", "few", "other"], plural_ordinal: ["other"], fallback: ["hsb"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨hu⟩) THEN (
    CREATE i18n_locale:⟨hu⟩ CONTENT { tag: "hu", language: "hu", script: NONE, region: NONE, name_en: "Hungarian", name_native: "magyar", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨hu-HU⟩) THEN (
    CREATE i18n_locale:⟨hu-HU⟩ CONTENT { tag: "hu-HU", language: "hu", script: NONE, region: "HU", name_en: "Hungarian (Hungary)", name_native: "magyar (Magyarország)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "other"], fallback: ["hu"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨hy⟩) THEN (
    CREATE i18n_locale:⟨hy⟩ CONTENT { tag: "hy", language: "hy", script: NONE, region: NONE, name_en: "Armenian", name_native: "հայերեն", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨hy-AM⟩) THEN (
    CREATE i18n_locale:⟨hy-AM⟩ CONTENT { tag: "hy-AM", language: "hy", script: NONE, region: "AM", name_en: "Armenian (Armenia)", name_native: "հայերեն (Հայաստան)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "other"], fallback: ["hy"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ia⟩) THEN (
    CREATE i18n_locale:⟨ia⟩ CONTENT { tag: "ia", language: "ia", script: NONE, region: NONE, name_en: "Interlingua", name_native: "interlingua", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ia-001⟩) THEN (
    CREATE i18n_locale:⟨ia-001⟩ CONTENT { tag: "ia-001", language: "ia", script: NONE, region: "001", name_en: "Interlingua (world)", name_native: "interlingua (mundo)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["ia"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨id⟩) THEN (
    CREATE i18n_locale:⟨id⟩ CONTENT { tag: "id", language: "id", script: NONE, region: NONE, name_en: "Indonesian", name_native: "Indonesia", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨id-ID⟩) THEN (
    CREATE i18n_locale:⟨id-ID⟩ CONTENT { tag: "id-ID", language: "id", script: NONE, region: "ID", name_en: "Indonesian (Indonesia)", name_native: "Indonesia (Indonesia)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["id"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ie⟩) THEN (
    CREATE i18n_locale:⟨ie⟩ CONTENT { tag: "ie", language: "ie", script: NONE, region: NONE, name_en: "Interlingue", name_native: "Interlingue", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ie-EE⟩) THEN (
    CREATE i18n_locale:⟨ie-EE⟩ CONTENT { tag: "ie-EE", language: "ie", script: NONE, region: "EE", name_en: "Interlingue (Estonia)", name_native: "Interlingue (Estonia)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["ie"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ig⟩) THEN (
    CREATE i18n_locale:⟨ig⟩ CONTENT { tag: "ig", language: "ig", script: NONE, region: NONE, name_en: "Igbo", name_native: "Asụsụ Igbo", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ig-NG⟩) THEN (
    CREATE i18n_locale:⟨ig-NG⟩ CONTENT { tag: "ig-NG", language: "ig", script: NONE, region: "NG", name_en: "Igbo (Nigeria)", name_native: "Asụsụ Igbo (Naịjịrịa)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["ig"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ii⟩) THEN (
    CREATE i18n_locale:⟨ii⟩ CONTENT { tag: "ii", language: "ii", script: NONE, region: NONE, name_en: "Sichuan Yi", name_native: "ꆈꌠꉙ", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ii-CN⟩) THEN (
    CREATE i18n_locale:⟨ii-CN⟩ CONTENT { tag: "ii-CN", language: "ii", script: NONE, region: "CN", name_en: "Sichuan Yi (China)", name_native: "ꆈꌠꉙ（ꍏꇩ）", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["ii"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨is⟩) THEN (
    CREATE i18n_locale:⟨is⟩ CONTENT { tag: "is", language: "is", script: NONE, region: NONE, name_en: "Icelandic", name_native: "íslenska", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨is-IS⟩) THEN (
    CREATE i18n_locale:⟨is-IS⟩ CONTENT { tag: "is-IS", language: "is", script: NONE, region: "IS", name_en: "Icelandic (Iceland)", name_native: "íslenska (Ísland)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["is"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨it⟩) THEN (
    CREATE i18n_locale:⟨it⟩ CONTENT { tag: "it", language: "it", script: NONE, region: NONE, name_en: "Italian", name_native: "italiano", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["many", "other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨it-CH⟩) THEN (
    CREATE i18n_locale:⟨it-CH⟩ CONTENT { tag: "it-CH", language: "it", script: NONE, region: "CH", name_en: "Italian (Switzerland)", name_native: "italiano (Svizzera)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["many", "other"], fallback: ["it"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨it-IT⟩) THEN (
    CREATE i18n_locale:⟨it-IT⟩ CONTENT { tag: "it-IT", language: "it", script: NONE, region: "IT", name_en: "Italian (Italy)", name_native: "italiano (Italia)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["many", "other"], fallback: ["it"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨it-SM⟩) THEN (
    CREATE i18n_locale:⟨it-SM⟩ CONTENT { tag: "it-SM", language: "it", script: NONE, region: "SM", name_en: "Italian (San Marino)", name_native: "italiano (San Marino)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["many", "other"], fallback: ["it"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨it-VA⟩) THEN (
    CREATE i18n_locale:⟨it-VA⟩ CONTENT { tag: "it-VA", language: "it", script: NONE, region: "VA", name_en: "Italian (Vatican City)", name_native: "italiano (Città del Vaticano)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["many", "other"], fallback: ["it"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ja⟩) THEN (
    CREATE i18n_locale:⟨ja⟩ CONTENT { tag: "ja", language: "ja", script: NONE, region: NONE, name_en: "Japanese", name_native: "日本語", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ja-JP⟩) THEN (
    CREATE i18n_locale:⟨ja-JP⟩ CONTENT { tag: "ja-JP", language: "ja", script: NONE, region: "JP", name_en: "Japanese (Japan)", name_native: "日本語 (日本)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["ja"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨jgo⟩) THEN (
    CREATE i18n_locale:⟨jgo⟩ CONTENT { tag: "jgo", language: "jgo", script: NONE, region: NONE, name_en: "Ngomba", name_native: "Ndaꞌa", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨jgo-CM⟩) THEN (
    CREATE i18n_locale:⟨jgo-CM⟩ CONTENT { tag: "jgo-CM", language: "jgo", script: NONE, region: "CM", name_en: "Ngomba (Cameroon)", name_native: "Ndaꞌa (Kamɛlûn)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["jgo"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨jmc⟩) THEN (
    CREATE i18n_locale:⟨jmc⟩ CONTENT { tag: "jmc", language: "jmc", script: NONE, region: NONE, name_en: "Machame", name_native: "Kimachame", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨jmc-TZ⟩) THEN (
    CREATE i18n_locale:⟨jmc-TZ⟩ CONTENT { tag: "jmc-TZ", language: "jmc", script: NONE, region: "TZ", name_en: "Machame (Tanzania)", name_native: "Kimachame (Tanzania)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["jmc"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨jv⟩) THEN (
    CREATE i18n_locale:⟨jv⟩ CONTENT { tag: "jv", language: "jv", script: NONE, region: NONE, name_en: "Javanese", name_native: "Jawa", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨jv-ID⟩) THEN (
    CREATE i18n_locale:⟨jv-ID⟩ CONTENT { tag: "jv-ID", language: "jv", script: NONE, region: "ID", name_en: "Javanese (Indonesia)", name_native: "Jawa (Indonesia)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["jv"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ka⟩) THEN (
    CREATE i18n_locale:⟨ka⟩ CONTENT { tag: "ka", language: "ka", script: NONE, region: NONE, name_en: "Georgian", name_native: "ქართული", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "many", "other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ka-GE⟩) THEN (
    CREATE i18n_locale:⟨ka-GE⟩ CONTENT { tag: "ka-GE", language: "ka", script: NONE, region: "GE", name_en: "Georgian (Georgia)", name_native: "ქართული (საქართველო)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "many", "other"], fallback: ["ka"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨kab⟩) THEN (
    CREATE i18n_locale:⟨kab⟩ CONTENT { tag: "kab", language: "kab", script: NONE, region: NONE, name_en: "Kabyle", name_native: "Taqbaylit", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨kab-DZ⟩) THEN (
    CREATE i18n_locale:⟨kab-DZ⟩ CONTENT { tag: "kab-DZ", language: "kab", script: NONE, region: "DZ", name_en: "Kabyle (Algeria)", name_native: "Taqbaylit (Lezzayer)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["kab"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨kam⟩) THEN (
    CREATE i18n_locale:⟨kam⟩ CONTENT { tag: "kam", language: "kam", script: NONE, region: NONE, name_en: "Kamba", name_native: "Kikamba", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨kam-KE⟩) THEN (
    CREATE i18n_locale:⟨kam-KE⟩ CONTENT { tag: "kam-KE", language: "kam", script: NONE, region: "KE", name_en: "Kamba (Kenya)", name_native: "Kikamba (Kenya)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["kam"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨kbd⟩) THEN (
    CREATE i18n_locale:⟨kbd⟩ CONTENT { tag: "kbd", language: "kbd", script: NONE, region: NONE, name_en: "Kabardian", name_native: "къэбэрдеибзэ", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨kbd-RU⟩) THEN (
    CREATE i18n_locale:⟨kbd-RU⟩ CONTENT { tag: "kbd-RU", language: "kbd", script: NONE, region: "RU", name_en: "Kabardian (Russia)", name_native: "къэбэрдеибзэ (Урысей)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["kbd"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨kbd-TR⟩) THEN (
    CREATE i18n_locale:⟨kbd-TR⟩ CONTENT { tag: "kbd-TR", language: "kbd", script: NONE, region: "TR", name_en: "Kabardian (Türkiye)", name_native: "къэбэрдеибзэ (Тыркуе)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["kbd"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨kde⟩) THEN (
    CREATE i18n_locale:⟨kde⟩ CONTENT { tag: "kde", language: "kde", script: NONE, region: NONE, name_en: "Makonde", name_native: "Chimakonde", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨kde-TZ⟩) THEN (
    CREATE i18n_locale:⟨kde-TZ⟩ CONTENT { tag: "kde-TZ", language: "kde", script: NONE, region: "TZ", name_en: "Makonde (Tanzania)", name_native: "Chimakonde (Tanzania)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["kde"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨kea⟩) THEN (
    CREATE i18n_locale:⟨kea⟩ CONTENT { tag: "kea", language: "kea", script: NONE, region: NONE, name_en: "Kabuverdianu", name_native: "kabuverdianu", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨kea-CV⟩) THEN (
    CREATE i18n_locale:⟨kea-CV⟩ CONTENT { tag: "kea-CV", language: "kea", script: NONE, region: "CV", name_en: "Kabuverdianu (Cape Verde)", name_native: "kabuverdianu (Kabu Verdi)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["kea"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨kek⟩) THEN (
    CREATE i18n_locale:⟨kek⟩ CONTENT { tag: "kek", language: "kek", script: NONE, region: NONE, name_en: "Qʼeqchiʼ", name_native: "Qʼeqchiʼ", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨kek-GT⟩) THEN (
    CREATE i18n_locale:⟨kek-GT⟩ CONTENT { tag: "kek-GT", language: "kek", script: NONE, region: "GT", name_en: "Qʼeqchiʼ (Guatemala)", name_native: "Qʼeqchiʼ (Iximchʼochʼ)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["kek"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨kgp⟩) THEN (
    CREATE i18n_locale:⟨kgp⟩ CONTENT { tag: "kgp", language: "kgp", script: NONE, region: NONE, name_en: "Kaingang", name_native: "kanhgág", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨kgp-BR⟩) THEN (
    CREATE i18n_locale:⟨kgp-BR⟩ CONTENT { tag: "kgp-BR", language: "kgp", script: NONE, region: "BR", name_en: "Kaingang (Brazil)", name_native: "kanhgág (Mrasir)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["kgp"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨khq⟩) THEN (
    CREATE i18n_locale:⟨khq⟩ CONTENT { tag: "khq", language: "khq", script: NONE, region: NONE, name_en: "Koyra Chiini", name_native: "Koyra ciini", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨khq-ML⟩) THEN (
    CREATE i18n_locale:⟨khq-ML⟩ CONTENT { tag: "khq-ML", language: "khq", script: NONE, region: "ML", name_en: "Koyra Chiini (Mali)", name_native: "Koyra ciini (Maali)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["khq"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ki⟩) THEN (
    CREATE i18n_locale:⟨ki⟩ CONTENT { tag: "ki", language: "ki", script: NONE, region: NONE, name_en: "Kikuyu", name_native: "Gĩgĩkũyũ", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ki-KE⟩) THEN (
    CREATE i18n_locale:⟨ki-KE⟩ CONTENT { tag: "ki-KE", language: "ki", script: NONE, region: "KE", name_en: "Kikuyu (Kenya)", name_native: "Gĩgĩkũyũ (Kenya)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["ki"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨kk⟩) THEN (
    CREATE i18n_locale:⟨kk⟩ CONTENT { tag: "kk", language: "kk", script: NONE, region: NONE, name_en: "Kazakh", name_native: "қазақ тілі", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["many", "other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨kk-Arab⟩) THEN (
    CREATE i18n_locale:⟨kk-Arab⟩ CONTENT { tag: "kk-Arab", language: "kk", script: "Arab", region: NONE, name_en: "Kazakh (Arabic)", name_native: "قازاق ءتىلى (توتە)", direction: "rtl", plural_cardinal: ["one", "other"], plural_ordinal: ["many", "other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨kk-Arab-CN⟩) THEN (
    CREATE i18n_locale:⟨kk-Arab-CN⟩ CONTENT { tag: "kk-Arab-CN", language: "kk", script: "Arab", region: "CN", name_en: "Kazakh (Arabic, China)", name_native: "قازاق ءتىلى (اراب جازۋى، قىتاي)", direction: "rtl", plural_cardinal: ["one", "other"], plural_ordinal: ["many", "other"], fallback: ["kk-Arab"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨kk-Cyrl⟩) THEN (
    CREATE i18n_locale:⟨kk-Cyrl⟩ CONTENT { tag: "kk-Cyrl", language: "kk", script: "Cyrl", region: NONE, name_en: "Kazakh (Cyrillic)", name_native: "қазақ тілі (кирилл жазуы)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["many", "other"], fallback: ["kk"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨kk-Cyrl-KZ⟩) THEN (
    CREATE i18n_locale:⟨kk-Cyrl-KZ⟩ CONTENT { tag: "kk-Cyrl-KZ", language: "kk", script: "Cyrl", region: "KZ", name_en: "Kazakh (Cyrillic, Kazakhstan)", name_native: "қазақ тілі (кирилл жазуы, Қазақстан)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["many", "other"], fallback: ["kk-Cyrl", "kk"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨kk-KZ⟩) THEN (
    CREATE i18n_locale:⟨kk-KZ⟩ CONTENT { tag: "kk-KZ", language: "kk", script: NONE, region: "KZ", name_en: "Kazakh (Kazakhstan)", name_native: "қазақ тілі (Қазақстан)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["many", "other"], fallback: ["kk"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨kkj⟩) THEN (
    CREATE i18n_locale:⟨kkj⟩ CONTENT { tag: "kkj", language: "kkj", script: NONE, region: NONE, name_en: "Kako", name_native: "kakɔ", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨kkj-CM⟩) THEN (
    CREATE i18n_locale:⟨kkj-CM⟩ CONTENT { tag: "kkj-CM", language: "kkj", script: NONE, region: "CM", name_en: "Kako (Cameroon)", name_native: "kakɔ (Kamɛrun)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["kkj"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨kl⟩) THEN (
    CREATE i18n_locale:⟨kl⟩ CONTENT { tag: "kl", language: "kl", script: NONE, region: NONE, name_en: "Kalaallisut", name_native: "kalaallisut", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨kl-GL⟩) THEN (
    CREATE i18n_locale:⟨kl-GL⟩ CONTENT { tag: "kl-GL", language: "kl", script: NONE, region: "GL", name_en: "Kalaallisut (Greenland)", name_native: "kalaallisut (Kalaallit Nunaat)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["kl"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨kln⟩) THEN (
    CREATE i18n_locale:⟨kln⟩ CONTENT { tag: "kln", language: "kln", script: NONE, region: NONE, name_en: "Kalenjin", name_native: "Kalenjin", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨kln-KE⟩) THEN (
    CREATE i18n_locale:⟨kln-KE⟩ CONTENT { tag: "kln-KE", language: "kln", script: NONE, region: "KE", name_en: "Kalenjin (Kenya)", name_native: "Kalenjin (Emetab Kenya)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["kln"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨km⟩) THEN (
    CREATE i18n_locale:⟨km⟩ CONTENT { tag: "km", language: "km", script: NONE, region: NONE, name_en: "Khmer", name_native: "ខ្មែរ", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨km-KH⟩) THEN (
    CREATE i18n_locale:⟨km-KH⟩ CONTENT { tag: "km-KH", language: "km", script: NONE, region: "KH", name_en: "Khmer (Cambodia)", name_native: "ខ្មែរ (កម្ពុជា)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["km"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨kn⟩) THEN (
    CREATE i18n_locale:⟨kn⟩ CONTENT { tag: "kn", language: "kn", script: NONE, region: NONE, name_en: "Kannada", name_native: "ಕನ್ನಡ", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨kn-IN⟩) THEN (
    CREATE i18n_locale:⟨kn-IN⟩ CONTENT { tag: "kn-IN", language: "kn", script: NONE, region: "IN", name_en: "Kannada (India)", name_native: "ಕನ್ನಡ (ಭಾರತ)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["kn"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ko⟩) THEN (
    CREATE i18n_locale:⟨ko⟩ CONTENT { tag: "ko", language: "ko", script: NONE, region: NONE, name_en: "Korean", name_native: "한국어", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ko-CN⟩) THEN (
    CREATE i18n_locale:⟨ko-CN⟩ CONTENT { tag: "ko-CN", language: "ko", script: NONE, region: "CN", name_en: "Korean (China)", name_native: "한국어(중국)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["ko"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ko-KP⟩) THEN (
    CREATE i18n_locale:⟨ko-KP⟩ CONTENT { tag: "ko-KP", language: "ko", script: NONE, region: "KP", name_en: "Korean (North Korea)", name_native: "한국어(조선민주주의인민공화국)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["ko"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ko-KR⟩) THEN (
    CREATE i18n_locale:⟨ko-KR⟩ CONTENT { tag: "ko-KR", language: "ko", script: NONE, region: "KR", name_en: "Korean (South Korea)", name_native: "한국어(대한민국)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["ko"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨kok⟩) THEN (
    CREATE i18n_locale:⟨kok⟩ CONTENT { tag: "kok", language: "kok", script: NONE, region: NONE, name_en: "Konkani", name_native: "कोंकणी", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨kok-Deva⟩) THEN (
    CREATE i18n_locale:⟨kok-Deva⟩ CONTENT { tag: "kok-Deva", language: "kok", script: "Deva", region: NONE, name_en: "Konkani (Devanagari)", name_native: "कोंकणी (देवनागरी)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["kok"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨kok-Deva-IN⟩) THEN (
    CREATE i18n_locale:⟨kok-Deva-IN⟩ CONTENT { tag: "kok-Deva-IN", language: "kok", script: "Deva", region: "IN", name_en: "Konkani (Devanagari, India)", name_native: "कोंकणी (देवनागरी, भारत)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["kok-Deva", "kok"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨kok-Latn⟩) THEN (
    CREATE i18n_locale:⟨kok-Latn⟩ CONTENT { tag: "kok-Latn", language: "kok", script: "Latn", region: NONE, name_en: "Konkani (Latin)", name_native: "Konknni (Romi)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨kok-Latn-IN⟩) THEN (
    CREATE i18n_locale:⟨kok-Latn-IN⟩ CONTENT { tag: "kok-Latn-IN", language: "kok", script: "Latn", region: "IN", name_en: "Konkani (Latin, India)", name_native: "Konknni (Romi, Bharot)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["kok-Latn"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ks⟩) THEN (
    CREATE i18n_locale:⟨ks⟩ CONTENT { tag: "ks", language: "ks", script: NONE, region: NONE, name_en: "Kashmiri", name_native: "کٲشُر", direction: "rtl", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ks-Arab⟩) THEN (
    CREATE i18n_locale:⟨ks-Arab⟩ CONTENT { tag: "ks-Arab", language: "ks", script: "Arab", region: NONE, name_en: "Kashmiri (Arabic)", name_native: "کٲشُر (عربی)", direction: "rtl", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["ks"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ks-Arab-IN⟩) THEN (
    CREATE i18n_locale:⟨ks-Arab-IN⟩ CONTENT { tag: "ks-Arab-IN", language: "ks", script: "Arab", region: "IN", name_en: "Kashmiri (Arabic, India)", name_native: "کٲشُر (عربی, ہِندوستان)", direction: "rtl", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["ks-Arab", "ks"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ks-Deva⟩) THEN (
    CREATE i18n_locale:⟨ks-Deva⟩ CONTENT { tag: "ks-Deva", language: "ks", script: "Deva", region: NONE, name_en: "Kashmiri (Devanagari)", name_native: "कॉशुर (देवनागरी)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ks-Deva-IN⟩) THEN (
    CREATE i18n_locale:⟨ks-Deva-IN⟩ CONTENT { tag: "ks-Deva-IN", language: "ks", script: "Deva", region: "IN", name_en: "Kashmiri (Devanagari, India)", name_native: "कॉशुर (देवनागरी, हिंदोस्तान)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["ks-Deva"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ksb⟩) THEN (
    CREATE i18n_locale:⟨ksb⟩ CONTENT { tag: "ksb", language: "ksb", script: NONE, region: NONE, name_en: "Shambala", name_native: "Kishambaa", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ksb-TZ⟩) THEN (
    CREATE i18n_locale:⟨ksb-TZ⟩ CONTENT { tag: "ksb-TZ", language: "ksb", script: NONE, region: "TZ", name_en: "Shambala (Tanzania)", name_native: "Kishambaa (Tanzania)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["ksb"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ksf⟩) THEN (
    CREATE i18n_locale:⟨ksf⟩ CONTENT { tag: "ksf", language: "ksf", script: NONE, region: NONE, name_en: "Bafia", name_native: "rikpa", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ksf-CM⟩) THEN (
    CREATE i18n_locale:⟨ksf-CM⟩ CONTENT { tag: "ksf-CM", language: "ksf", script: NONE, region: "CM", name_en: "Bafia (Cameroon)", name_native: "rikpa (kamɛrún)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["ksf"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ksh⟩) THEN (
    CREATE i18n_locale:⟨ksh⟩ CONTENT { tag: "ksh", language: "ksh", script: NONE, region: NONE, name_en: "Colognian", name_native: "Kölsch", direction: "ltr", plural_cardinal: ["zero", "one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ksh-DE⟩) THEN (
    CREATE i18n_locale:⟨ksh-DE⟩ CONTENT { tag: "ksh-DE", language: "ksh", script: NONE, region: "DE", name_en: "Colognian (Germany)", name_native: "Kölsch en Doütschland", direction: "ltr", plural_cardinal: ["zero", "one", "other"], plural_ordinal: ["other"], fallback: ["ksh"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ku⟩) THEN (
    CREATE i18n_locale:⟨ku⟩ CONTENT { tag: "ku", language: "ku", script: NONE, region: NONE, name_en: "Kurdish", name_native: "kurdî (kurmancî)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ku-Latn⟩) THEN (
    CREATE i18n_locale:⟨ku-Latn⟩ CONTENT { tag: "ku-Latn", language: "ku", script: "Latn", region: NONE, name_en: "Kurdish (Latin)", name_native: "kurdî (kurmancî) (latînî)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["ku"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ku-Latn-IQ⟩) THEN (
    CREATE i18n_locale:⟨ku-Latn-IQ⟩ CONTENT { tag: "ku-Latn-IQ", language: "ku", script: "Latn", region: "IQ", name_en: "Kurdish (Latin, Iraq)", name_native: "kurdî (kurmancî) (latînî, Îraq)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["ku-Latn", "ku"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ku-Latn-SY⟩) THEN (
    CREATE i18n_locale:⟨ku-Latn-SY⟩ CONTENT { tag: "ku-Latn-SY", language: "ku", script: "Latn", region: "SY", name_en: "Kurdish (Latin, Syria)", name_native: "kurdî (kurmancî) (latînî, Sûrîye)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["ku-Latn", "ku"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ku-Latn-TR⟩) THEN (
    CREATE i18n_locale:⟨ku-Latn-TR⟩ CONTENT { tag: "ku-Latn-TR", language: "ku", script: "Latn", region: "TR", name_en: "Kurdish (Latin, Türkiye)", name_native: "kurdî (kurmancî) (latînî, Türkiye)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["ku-Latn", "ku"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ku-TR⟩) THEN (
    CREATE i18n_locale:⟨ku-TR⟩ CONTENT { tag: "ku-TR", language: "ku", script: NONE, region: "TR", name_en: "Kurdish (Türkiye)", name_native: "kurdî (kurmancî) (Türkiye)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["ku"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨kw⟩) THEN (
    CREATE i18n_locale:⟨kw⟩ CONTENT { tag: "kw", language: "kw", script: NONE, region: NONE, name_en: "Cornish", name_native: "kernewek", direction: "ltr", plural_cardinal: ["zero", "one", "two", "few", "many", "other"], plural_ordinal: ["one", "many", "other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨kw-GB⟩) THEN (
    CREATE i18n_locale:⟨kw-GB⟩ CONTENT { tag: "kw-GB", language: "kw", script: NONE, region: "GB", name_en: "Cornish (United Kingdom)", name_native: "kernewek (Rywvaneth Unys)", direction: "ltr", plural_cardinal: ["zero", "one", "two", "few", "many", "other"], plural_ordinal: ["one", "many", "other"], fallback: ["kw"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨kxv⟩) THEN (
    CREATE i18n_locale:⟨kxv⟩ CONTENT { tag: "kxv", language: "kxv", script: NONE, region: NONE, name_en: "Kuvi", name_native: "kuvi", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨kxv-Deva⟩) THEN (
    CREATE i18n_locale:⟨kxv-Deva⟩ CONTENT { tag: "kxv-Deva", language: "kxv", script: "Deva", region: NONE, name_en: "Kuvi (Devanagari)", name_native: "कुवि (देवनागरी)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨kxv-Deva-IN⟩) THEN (
    CREATE i18n_locale:⟨kxv-Deva-IN⟩ CONTENT { tag: "kxv-Deva-IN", language: "kxv", script: "Deva", region: "IN", name_en: "Kuvi (Devanagari, India)", name_native: "कुवि (देवनागरी, बारत)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["kxv-Deva"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨kxv-Latn⟩) THEN (
    CREATE i18n_locale:⟨kxv-Latn⟩ CONTENT { tag: "kxv-Latn", language: "kxv", script: "Latn", region: NONE, name_en: "Kuvi (Latin)", name_native: "kuvi (laṭin)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["kxv"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨kxv-Latn-IN⟩) THEN (
    CREATE i18n_locale:⟨kxv-Latn-IN⟩ CONTENT { tag: "kxv-Latn-IN", language: "kxv", script: "Latn", region: "IN", name_en: "Kuvi (Latin, India)", name_native: "kuvi (laṭin, inḍiā)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["kxv-Latn", "kxv"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨kxv-Orya⟩) THEN (
    CREATE i18n_locale:⟨kxv-Orya⟩ CONTENT { tag: "kxv-Orya", language: "kxv", script: "Orya", region: NONE, name_en: "Kuvi (Odia)", name_native: "କୁୱି (ଅଡ଼ିଆ)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨kxv-Orya-IN⟩) THEN (
    CREATE i18n_locale:⟨kxv-Orya-IN⟩ CONTENT { tag: "kxv-Orya-IN", language: "kxv", script: "Orya", region: "IN", name_en: "Kuvi (Odia, India)", name_native: "କୁୱି (ଅଡ଼ିଆ, ବାରତ)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["kxv-Orya"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨kxv-Telu⟩) THEN (
    CREATE i18n_locale:⟨kxv-Telu⟩ CONTENT { tag: "kxv-Telu", language: "kxv", script: "Telu", region: NONE, name_en: "Kuvi (Telugu)", name_native: "కువి (తెలుగు)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨kxv-Telu-IN⟩) THEN (
    CREATE i18n_locale:⟨kxv-Telu-IN⟩ CONTENT { tag: "kxv-Telu-IN", language: "kxv", script: "Telu", region: "IN", name_en: "Kuvi (Telugu, India)", name_native: "కువి (తెలుగు, బారతదెసాం)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["kxv-Telu"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ky⟩) THEN (
    CREATE i18n_locale:⟨ky⟩ CONTENT { tag: "ky", language: "ky", script: NONE, region: NONE, name_en: "Kyrgyz", name_native: "кыргызча", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ky-KG⟩) THEN (
    CREATE i18n_locale:⟨ky-KG⟩ CONTENT { tag: "ky-KG", language: "ky", script: NONE, region: "KG", name_en: "Kyrgyz (Kyrgyzstan)", name_native: "кыргызча (Кыргызстан)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["ky"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨lag⟩) THEN (
    CREATE i18n_locale:⟨lag⟩ CONTENT { tag: "lag", language: "lag", script: NONE, region: NONE, name_en: "Langi", name_native: "Kɨlaangi", direction: "ltr", plural_cardinal: ["zero", "one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨lag-TZ⟩) THEN (
    CREATE i18n_locale:⟨lag-TZ⟩ CONTENT { tag: "lag-TZ", language: "lag", script: NONE, region: "TZ", name_en: "Langi (Tanzania)", name_native: "Kɨlaangi (Taansanía)", direction: "ltr", plural_cardinal: ["zero", "one", "other"], plural_ordinal: ["other"], fallback: ["lag"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨lb⟩) THEN (
    CREATE i18n_locale:⟨lb⟩ CONTENT { tag: "lb", language: "lb", script: NONE, region: NONE, name_en: "Luxembourgish", name_native: "Lëtzebuergesch", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨lb-LU⟩) THEN (
    CREATE i18n_locale:⟨lb-LU⟩ CONTENT { tag: "lb-LU", language: "lb", script: NONE, region: "LU", name_en: "Luxembourgish (Luxembourg)", name_native: "Lëtzebuergesch (Lëtzebuerg)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["lb"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨lg⟩) THEN (
    CREATE i18n_locale:⟨lg⟩ CONTENT { tag: "lg", language: "lg", script: NONE, region: NONE, name_en: "Ganda", name_native: "Luganda", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨lg-UG⟩) THEN (
    CREATE i18n_locale:⟨lg-UG⟩ CONTENT { tag: "lg-UG", language: "lg", script: NONE, region: "UG", name_en: "Ganda (Uganda)", name_native: "Luganda (Yuganda)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["lg"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨lij⟩) THEN (
    CREATE i18n_locale:⟨lij⟩ CONTENT { tag: "lij", language: "lij", script: NONE, region: NONE, name_en: "Ligurian", name_native: "ligure", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["many", "other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨lij-IT⟩) THEN (
    CREATE i18n_locale:⟨lij-IT⟩ CONTENT { tag: "lij-IT", language: "lij", script: NONE, region: "IT", name_en: "Ligurian (Italy)", name_native: "ligure (Italia)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["many", "other"], fallback: ["lij"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨lkt⟩) THEN (
    CREATE i18n_locale:⟨lkt⟩ CONTENT { tag: "lkt", language: "lkt", script: NONE, region: NONE, name_en: "Lakota", name_native: "Lakȟólʼiyapi", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨lkt-US⟩) THEN (
    CREATE i18n_locale:⟨lkt-US⟩ CONTENT { tag: "lkt-US", language: "lkt", script: NONE, region: "US", name_en: "Lakota (United States)", name_native: "Lakȟólʼiyapi (Mílahaŋska Tȟamákȟočhe)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["lkt"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨lld⟩) THEN (
    CREATE i18n_locale:⟨lld⟩ CONTENT { tag: "lld", language: "lld", script: NONE, region: NONE, name_en: "Ladin", name_native: "ladin", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["many", "other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨lld-IT⟩) THEN (
    CREATE i18n_locale:⟨lld-IT⟩ CONTENT { tag: "lld-IT", language: "lld", script: NONE, region: "IT", name_en: "Ladin (Italy)", name_native: "ladin (Talia)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["many", "other"], fallback: ["lld"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨lmo⟩) THEN (
    CREATE i18n_locale:⟨lmo⟩ CONTENT { tag: "lmo", language: "lmo", script: NONE, region: NONE, name_en: "Lombard", name_native: "Lombard", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨lmo-IT⟩) THEN (
    CREATE i18n_locale:⟨lmo-IT⟩ CONTENT { tag: "lmo-IT", language: "lmo", script: NONE, region: "IT", name_en: "Lombard (Italy)", name_native: "Lombard (Italia)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["lmo"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ln⟩) THEN (
    CREATE i18n_locale:⟨ln⟩ CONTENT { tag: "ln", language: "ln", script: NONE, region: NONE, name_en: "Lingala", name_native: "lingála", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ln-AO⟩) THEN (
    CREATE i18n_locale:⟨ln-AO⟩ CONTENT { tag: "ln-AO", language: "ln", script: NONE, region: "AO", name_en: "Lingala (Angola)", name_native: "lingála (Angóla)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["ln"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ln-CD⟩) THEN (
    CREATE i18n_locale:⟨ln-CD⟩ CONTENT { tag: "ln-CD", language: "ln", script: NONE, region: "CD", name_en: "Lingala (Congo - Kinshasa)", name_native: "lingála (Republíki ya Kongó Demokratíki)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["ln"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ln-CF⟩) THEN (
    CREATE i18n_locale:⟨ln-CF⟩ CONTENT { tag: "ln-CF", language: "ln", script: NONE, region: "CF", name_en: "Lingala (Central African Republic)", name_native: "lingála (Repibiki ya Afríka ya Káti)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["ln"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ln-CG⟩) THEN (
    CREATE i18n_locale:⟨ln-CG⟩ CONTENT { tag: "ln-CG", language: "ln", script: NONE, region: "CG", name_en: "Lingala (Congo - Brazzaville)", name_native: "lingála (Kongo)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["ln"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨lo⟩) THEN (
    CREATE i18n_locale:⟨lo⟩ CONTENT { tag: "lo", language: "lo", script: NONE, region: NONE, name_en: "Lao", name_native: "ລາວ", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["one", "other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨lo-LA⟩) THEN (
    CREATE i18n_locale:⟨lo-LA⟩ CONTENT { tag: "lo-LA", language: "lo", script: NONE, region: "LA", name_en: "Lao (Laos)", name_native: "ລາວ (ລາວ)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["one", "other"], fallback: ["lo"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨lrc⟩) THEN (
    CREATE i18n_locale:⟨lrc⟩ CONTENT { tag: "lrc", language: "lrc", script: NONE, region: NONE, name_en: "Northern Luri", name_native: "لۊری شومالی", direction: "rtl", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨lrc-IQ⟩) THEN (
    CREATE i18n_locale:⟨lrc-IQ⟩ CONTENT { tag: "lrc-IQ", language: "lrc", script: NONE, region: "IQ", name_en: "Northern Luri (Iraq)", name_native: "لۊری شومالی (IQ)", direction: "rtl", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["lrc"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨lrc-IR⟩) THEN (
    CREATE i18n_locale:⟨lrc-IR⟩ CONTENT { tag: "lrc-IR", language: "lrc", script: NONE, region: "IR", name_en: "Northern Luri (Iran)", name_native: "لۊری شومالی (IR)", direction: "rtl", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["lrc"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨lt⟩) THEN (
    CREATE i18n_locale:⟨lt⟩ CONTENT { tag: "lt", language: "lt", script: NONE, region: NONE, name_en: "Lithuanian", name_native: "lietuvių", direction: "ltr", plural_cardinal: ["one", "few", "many", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨lt-LT⟩) THEN (
    CREATE i18n_locale:⟨lt-LT⟩ CONTENT { tag: "lt-LT", language: "lt", script: NONE, region: "LT", name_en: "Lithuanian (Lithuania)", name_native: "lietuvių (Lietuva)", direction: "ltr", plural_cardinal: ["one", "few", "many", "other"], plural_ordinal: ["other"], fallback: ["lt"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨lu⟩) THEN (
    CREATE i18n_locale:⟨lu⟩ CONTENT { tag: "lu", language: "lu", script: NONE, region: NONE, name_en: "Luba-Katanga", name_native: "Tshiluba", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨lu-CD⟩) THEN (
    CREATE i18n_locale:⟨lu-CD⟩ CONTENT { tag: "lu-CD", language: "lu", script: NONE, region: "CD", name_en: "Luba-Katanga (Congo - Kinshasa)", name_native: "Tshiluba (Ditunga wa Kongu)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["lu"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨luo⟩) THEN (
    CREATE i18n_locale:⟨luo⟩ CONTENT { tag: "luo", language: "luo", script: NONE, region: NONE, name_en: "Luo", name_native: "Dholuo", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨luo-KE⟩) THEN (
    CREATE i18n_locale:⟨luo-KE⟩ CONTENT { tag: "luo-KE", language: "luo", script: NONE, region: "KE", name_en: "Luo (Kenya)", name_native: "Dholuo (Kenya)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["luo"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨luy⟩) THEN (
    CREATE i18n_locale:⟨luy⟩ CONTENT { tag: "luy", language: "luy", script: NONE, region: NONE, name_en: "Luyia", name_native: "Luluhia", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨luy-KE⟩) THEN (
    CREATE i18n_locale:⟨luy-KE⟩ CONTENT { tag: "luy-KE", language: "luy", script: NONE, region: "KE", name_en: "Luyia (Kenya)", name_native: "Luluhia (Kenya)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["luy"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨lv⟩) THEN (
    CREATE i18n_locale:⟨lv⟩ CONTENT { tag: "lv", language: "lv", script: NONE, region: NONE, name_en: "Latvian", name_native: "latviešu", direction: "ltr", plural_cardinal: ["zero", "one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨lv-LV⟩) THEN (
    CREATE i18n_locale:⟨lv-LV⟩ CONTENT { tag: "lv-LV", language: "lv", script: NONE, region: "LV", name_en: "Latvian (Latvia)", name_native: "latviešu (Latvija)", direction: "ltr", plural_cardinal: ["zero", "one", "other"], plural_ordinal: ["other"], fallback: ["lv"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨mai⟩) THEN (
    CREATE i18n_locale:⟨mai⟩ CONTENT { tag: "mai", language: "mai", script: NONE, region: NONE, name_en: "Maithili", name_native: "मैथिली", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨mai-IN⟩) THEN (
    CREATE i18n_locale:⟨mai-IN⟩ CONTENT { tag: "mai-IN", language: "mai", script: NONE, region: "IN", name_en: "Maithili (India)", name_native: "मैथिली (भारत)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["mai"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨mas⟩) THEN (
    CREATE i18n_locale:⟨mas⟩ CONTENT { tag: "mas", language: "mas", script: NONE, region: NONE, name_en: "Masai", name_native: "Maa", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨mas-KE⟩) THEN (
    CREATE i18n_locale:⟨mas-KE⟩ CONTENT { tag: "mas-KE", language: "mas", script: NONE, region: "KE", name_en: "Masai (Kenya)", name_native: "Maa (Kenya)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["mas"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨mas-TZ⟩) THEN (
    CREATE i18n_locale:⟨mas-TZ⟩ CONTENT { tag: "mas-TZ", language: "mas", script: NONE, region: "TZ", name_en: "Masai (Tanzania)", name_native: "Maa (Tansania)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["mas"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨mer⟩) THEN (
    CREATE i18n_locale:⟨mer⟩ CONTENT { tag: "mer", language: "mer", script: NONE, region: NONE, name_en: "Meru", name_native: "Kĩmĩrũ", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨mer-KE⟩) THEN (
    CREATE i18n_locale:⟨mer-KE⟩ CONTENT { tag: "mer-KE", language: "mer", script: NONE, region: "KE", name_en: "Meru (Kenya)", name_native: "Kĩmĩrũ (Kenya)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["mer"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨mfe⟩) THEN (
    CREATE i18n_locale:⟨mfe⟩ CONTENT { tag: "mfe", language: "mfe", script: NONE, region: NONE, name_en: "Morisyen", name_native: "kreol morisien", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨mfe-MU⟩) THEN (
    CREATE i18n_locale:⟨mfe-MU⟩ CONTENT { tag: "mfe-MU", language: "mfe", script: NONE, region: "MU", name_en: "Morisyen (Mauritius)", name_native: "kreol morisien (Moris)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["mfe"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨mg⟩) THEN (
    CREATE i18n_locale:⟨mg⟩ CONTENT { tag: "mg", language: "mg", script: NONE, region: NONE, name_en: "Malagasy", name_native: "Malagasy", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨mg-MG⟩) THEN (
    CREATE i18n_locale:⟨mg-MG⟩ CONTENT { tag: "mg-MG", language: "mg", script: NONE, region: "MG", name_en: "Malagasy (Madagascar)", name_native: "Malagasy (Madagasikara)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["mg"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨mgh⟩) THEN (
    CREATE i18n_locale:⟨mgh⟩ CONTENT { tag: "mgh", language: "mgh", script: NONE, region: NONE, name_en: "Makhuwa-Meetto", name_native: "Makua", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨mgh-MZ⟩) THEN (
    CREATE i18n_locale:⟨mgh-MZ⟩ CONTENT { tag: "mgh-MZ", language: "mgh", script: NONE, region: "MZ", name_en: "Makhuwa-Meetto (Mozambique)", name_native: "Makua (Umozambiki)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["mgh"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨mgo⟩) THEN (
    CREATE i18n_locale:⟨mgo⟩ CONTENT { tag: "mgo", language: "mgo", script: NONE, region: NONE, name_en: "Metaʼ", name_native: "metaʼ", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨mgo-CM⟩) THEN (
    CREATE i18n_locale:⟨mgo-CM⟩ CONTENT { tag: "mgo-CM", language: "mgo", script: NONE, region: "CM", name_en: "Metaʼ (Cameroon)", name_native: "metaʼ (Kamalun)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["mgo"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨mi⟩) THEN (
    CREATE i18n_locale:⟨mi⟩ CONTENT { tag: "mi", language: "mi", script: NONE, region: NONE, name_en: "Māori", name_native: "Māori", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨mi-NZ⟩) THEN (
    CREATE i18n_locale:⟨mi-NZ⟩ CONTENT { tag: "mi-NZ", language: "mi", script: NONE, region: "NZ", name_en: "Māori (New Zealand)", name_native: "Māori (Aotearoa)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["mi"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨mk⟩) THEN (
    CREATE i18n_locale:⟨mk⟩ CONTENT { tag: "mk", language: "mk", script: NONE, region: NONE, name_en: "Macedonian", name_native: "македонски", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "many", "other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨mk-MK⟩) THEN (
    CREATE i18n_locale:⟨mk-MK⟩ CONTENT { tag: "mk-MK", language: "mk", script: NONE, region: "MK", name_en: "Macedonian (North Macedonia)", name_native: "македонски (Северна Македонија)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "many", "other"], fallback: ["mk"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ml⟩) THEN (
    CREATE i18n_locale:⟨ml⟩ CONTENT { tag: "ml", language: "ml", script: NONE, region: NONE, name_en: "Malayalam", name_native: "മലയാളം", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ml-IN⟩) THEN (
    CREATE i18n_locale:⟨ml-IN⟩ CONTENT { tag: "ml-IN", language: "ml", script: NONE, region: "IN", name_en: "Malayalam (India)", name_native: "മലയാളം (ഇന്ത്യ)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["ml"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨mn⟩) THEN (
    CREATE i18n_locale:⟨mn⟩ CONTENT { tag: "mn", language: "mn", script: NONE, region: NONE, name_en: "Mongolian", name_native: "монгол", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨mn-MN⟩) THEN (
    CREATE i18n_locale:⟨mn-MN⟩ CONTENT { tag: "mn-MN", language: "mn", script: NONE, region: "MN", name_en: "Mongolian (Mongolia)", name_native: "монгол (Монгол)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["mn"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨mni⟩) THEN (
    CREATE i18n_locale:⟨mni⟩ CONTENT { tag: "mni", language: "mni", script: NONE, region: NONE, name_en: "Manipuri", name_native: "মৈতৈলোন্", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨mni-Beng⟩) THEN (
    CREATE i18n_locale:⟨mni-Beng⟩ CONTENT { tag: "mni-Beng", language: "mni", script: "Beng", region: NONE, name_en: "Manipuri (Bangla)", name_native: "মৈতৈলোন্ (বাংলা)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["mni"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨mni-Beng-IN⟩) THEN (
    CREATE i18n_locale:⟨mni-Beng-IN⟩ CONTENT { tag: "mni-Beng-IN", language: "mni", script: "Beng", region: "IN", name_en: "Manipuri (Bangla, India)", name_native: "মৈতৈলোন্ (বাংলা, ইন্দিয়া)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["mni-Beng", "mni"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨mr⟩) THEN (
    CREATE i18n_locale:⟨mr⟩ CONTENT { tag: "mr", language: "mr", script: NONE, region: NONE, name_en: "Marathi", name_native: "मराठी", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨mr-IN⟩) THEN (
    CREATE i18n_locale:⟨mr-IN⟩ CONTENT { tag: "mr-IN", language: "mr", script: NONE, region: "IN", name_en: "Marathi (India)", name_native: "मराठी (भारत)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "other"], fallback: ["mr"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ms⟩) THEN (
    CREATE i18n_locale:⟨ms⟩ CONTENT { tag: "ms", language: "ms", script: NONE, region: NONE, name_en: "Malay", name_native: "Melayu", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["one", "other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ms-BN⟩) THEN (
    CREATE i18n_locale:⟨ms-BN⟩ CONTENT { tag: "ms-BN", language: "ms", script: NONE, region: "BN", name_en: "Malay (Brunei)", name_native: "Melayu (Brunei)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["one", "other"], fallback: ["ms"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ms-ID⟩) THEN (
    CREATE i18n_locale:⟨ms-ID⟩ CONTENT { tag: "ms-ID", language: "ms", script: NONE, region: "ID", name_en: "Malay (Indonesia)", name_native: "Melayu (Indonesia)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["one", "other"], fallback: ["ms"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ms-MY⟩) THEN (
    CREATE i18n_locale:⟨ms-MY⟩ CONTENT { tag: "ms-MY", language: "ms", script: NONE, region: "MY", name_en: "Malay (Malaysia)", name_native: "Melayu (Malaysia)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["one", "other"], fallback: ["ms"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ms-SG⟩) THEN (
    CREATE i18n_locale:⟨ms-SG⟩ CONTENT { tag: "ms-SG", language: "ms", script: NONE, region: "SG", name_en: "Malay (Singapore)", name_native: "Melayu (Singapura)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["one", "other"], fallback: ["ms"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨mt⟩) THEN (
    CREATE i18n_locale:⟨mt⟩ CONTENT { tag: "mt", language: "mt", script: NONE, region: NONE, name_en: "Maltese", name_native: "Malti", direction: "ltr", plural_cardinal: ["one", "two", "few", "many", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨mt-MT⟩) THEN (
    CREATE i18n_locale:⟨mt-MT⟩ CONTENT { tag: "mt-MT", language: "mt", script: NONE, region: "MT", name_en: "Maltese (Malta)", name_native: "Malti (Malta)", direction: "ltr", plural_cardinal: ["one", "two", "few", "many", "other"], plural_ordinal: ["other"], fallback: ["mt"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨mua⟩) THEN (
    CREATE i18n_locale:⟨mua⟩ CONTENT { tag: "mua", language: "mua", script: NONE, region: NONE, name_en: "Mundang", name_native: "MUNDAŊ", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨mua-CM⟩) THEN (
    CREATE i18n_locale:⟨mua-CM⟩ CONTENT { tag: "mua-CM", language: "mua", script: NONE, region: "CM", name_en: "Mundang (Cameroon)", name_native: "MUNDAŊ (kameruŋ)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["mua"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨my⟩) THEN (
    CREATE i18n_locale:⟨my⟩ CONTENT { tag: "my", language: "my", script: NONE, region: NONE, name_en: "Burmese", name_native: "မြန်မာ", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨my-MM⟩) THEN (
    CREATE i18n_locale:⟨my-MM⟩ CONTENT { tag: "my-MM", language: "my", script: NONE, region: "MM", name_en: "Burmese (Myanmar (Burma))", name_native: "မြန်မာ (မြန်မာ)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["my"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨mzn⟩) THEN (
    CREATE i18n_locale:⟨mzn⟩ CONTENT { tag: "mzn", language: "mzn", script: NONE, region: NONE, name_en: "Mazanderani", name_native: "مازرونی", direction: "rtl", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨mzn-IR⟩) THEN (
    CREATE i18n_locale:⟨mzn-IR⟩ CONTENT { tag: "mzn-IR", language: "mzn", script: NONE, region: "IR", name_en: "Mazanderani (Iran)", name_native: "مازرونی (ایران)", direction: "rtl", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["mzn"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨naq⟩) THEN (
    CREATE i18n_locale:⟨naq⟩ CONTENT { tag: "naq", language: "naq", script: NONE, region: NONE, name_en: "Nama", name_native: "Khoekhoegowab", direction: "ltr", plural_cardinal: ["one", "two", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨naq-NA⟩) THEN (
    CREATE i18n_locale:⟨naq-NA⟩ CONTENT { tag: "naq-NA", language: "naq", script: NONE, region: "NA", name_en: "Nama (Namibia)", name_native: "Khoekhoegowab (Namibiab)", direction: "ltr", plural_cardinal: ["one", "two", "other"], plural_ordinal: ["other"], fallback: ["naq"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨nb⟩) THEN (
    CREATE i18n_locale:⟨nb⟩ CONTENT { tag: "nb", language: "nb", script: NONE, region: NONE, name_en: "Norwegian Bokmål", name_native: "norsk bokmål", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["no"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨nb-NO⟩) THEN (
    CREATE i18n_locale:⟨nb-NO⟩ CONTENT { tag: "nb-NO", language: "nb", script: NONE, region: "NO", name_en: "Norwegian Bokmål (Norway)", name_native: "norsk bokmål (Norge)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["nb", "no"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨nb-SJ⟩) THEN (
    CREATE i18n_locale:⟨nb-SJ⟩ CONTENT { tag: "nb-SJ", language: "nb", script: NONE, region: "SJ", name_en: "Norwegian Bokmål (Svalbard & Jan Mayen)", name_native: "norsk bokmål (Svalbard og Jan Mayen)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["nb", "no"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨nd⟩) THEN (
    CREATE i18n_locale:⟨nd⟩ CONTENT { tag: "nd", language: "nd", script: NONE, region: NONE, name_en: "North Ndebele", name_native: "isiNdebele", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨nd-ZW⟩) THEN (
    CREATE i18n_locale:⟨nd-ZW⟩ CONTENT { tag: "nd-ZW", language: "nd", script: NONE, region: "ZW", name_en: "North Ndebele (Zimbabwe)", name_native: "isiNdebele (Zimbabwe)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["nd"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨nds⟩) THEN (
    CREATE i18n_locale:⟨nds⟩ CONTENT { tag: "nds", language: "nds", script: NONE, region: NONE, name_en: "Low German", name_native: "Neddersass’sch", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨nds-DE⟩) THEN (
    CREATE i18n_locale:⟨nds-DE⟩ CONTENT { tag: "nds-DE", language: "nds", script: NONE, region: "DE", name_en: "Low German (Germany)", name_native: "Neddersass’sch (Düütschland)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["nds"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨nds-NL⟩) THEN (
    CREATE i18n_locale:⟨nds-NL⟩ CONTENT { tag: "nds-NL", language: "nds", script: NONE, region: "NL", name_en: "Low Saxon", name_native: "Neddersass’sch (Nedderlannen)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["nds"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ne⟩) THEN (
    CREATE i18n_locale:⟨ne⟩ CONTENT { tag: "ne", language: "ne", script: NONE, region: NONE, name_en: "Nepali", name_native: "नेपाली", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ne-IN⟩) THEN (
    CREATE i18n_locale:⟨ne-IN⟩ CONTENT { tag: "ne-IN", language: "ne", script: NONE, region: "IN", name_en: "Nepali (India)", name_native: "नेपाली (भारत)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "other"], fallback: ["ne"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ne-NP⟩) THEN (
    CREATE i18n_locale:⟨ne-NP⟩ CONTENT { tag: "ne-NP", language: "ne", script: NONE, region: "NP", name_en: "Nepali (Nepal)", name_native: "नेपाली (नेपाल)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "other"], fallback: ["ne"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨nl⟩) THEN (
    CREATE i18n_locale:⟨nl⟩ CONTENT { tag: "nl", language: "nl", script: NONE, region: NONE, name_en: "Dutch", name_native: "Nederlands", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨nl-AW⟩) THEN (
    CREATE i18n_locale:⟨nl-AW⟩ CONTENT { tag: "nl-AW", language: "nl", script: NONE, region: "AW", name_en: "Dutch (Aruba)", name_native: "Nederlands (Aruba)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["nl"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨nl-BE⟩) THEN (
    CREATE i18n_locale:⟨nl-BE⟩ CONTENT { tag: "nl-BE", language: "nl", script: NONE, region: "BE", name_en: "Flemish", name_native: "Vlaams", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["nl"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨nl-BQ⟩) THEN (
    CREATE i18n_locale:⟨nl-BQ⟩ CONTENT { tag: "nl-BQ", language: "nl", script: NONE, region: "BQ", name_en: "Dutch (Caribbean Netherlands)", name_native: "Nederlands (Caribisch Nederland)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["nl"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨nl-CW⟩) THEN (
    CREATE i18n_locale:⟨nl-CW⟩ CONTENT { tag: "nl-CW", language: "nl", script: NONE, region: "CW", name_en: "Dutch (Curaçao)", name_native: "Nederlands (Curaçao)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["nl"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨nl-NL⟩) THEN (
    CREATE i18n_locale:⟨nl-NL⟩ CONTENT { tag: "nl-NL", language: "nl", script: NONE, region: "NL", name_en: "Dutch (Netherlands)", name_native: "Nederlands (Nederland)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["nl"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨nl-SR⟩) THEN (
    CREATE i18n_locale:⟨nl-SR⟩ CONTENT { tag: "nl-SR", language: "nl", script: NONE, region: "SR", name_en: "Dutch (Suriname)", name_native: "Nederlands (Suriname)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["nl"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨nl-SX⟩) THEN (
    CREATE i18n_locale:⟨nl-SX⟩ CONTENT { tag: "nl-SX", language: "nl", script: NONE, region: "SX", name_en: "Dutch (Sint Maarten)", name_native: "Nederlands (Sint-Maarten)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["nl"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨nmg⟩) THEN (
    CREATE i18n_locale:⟨nmg⟩ CONTENT { tag: "nmg", language: "nmg", script: NONE, region: NONE, name_en: "Kwasio", name_native: "Kwasio", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨nmg-CM⟩) THEN (
    CREATE i18n_locale:⟨nmg-CM⟩ CONTENT { tag: "nmg-CM", language: "nmg", script: NONE, region: "CM", name_en: "Kwasio (Cameroon)", name_native: "Kwasio (Cameroon)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["nmg"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨nn⟩) THEN (
    CREATE i18n_locale:⟨nn⟩ CONTENT { tag: "nn", language: "nn", script: NONE, region: NONE, name_en: "Norwegian Nynorsk", name_native: "norsk nynorsk", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["no"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨nn-NO⟩) THEN (
    CREATE i18n_locale:⟨nn-NO⟩ CONTENT { tag: "nn-NO", language: "nn", script: NONE, region: "NO", name_en: "Norwegian Nynorsk (Norway)", name_native: "norsk nynorsk (Noreg)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["nn", "no"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨nnh⟩) THEN (
    CREATE i18n_locale:⟨nnh⟩ CONTENT { tag: "nnh", language: "nnh", script: NONE, region: NONE, name_en: "Ngiemboon", name_native: "Shwóŋò ngiembɔɔn", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨nnh-CM⟩) THEN (
    CREATE i18n_locale:⟨nnh-CM⟩ CONTENT { tag: "nnh-CM", language: "nnh", script: NONE, region: "CM", name_en: "Ngiemboon (Cameroon)", name_native: "Shwóŋò ngiembɔɔn (Kàmalûm)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["nnh"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨no⟩) THEN (
    CREATE i18n_locale:⟨no⟩ CONTENT { tag: "no", language: "no", script: NONE, region: NONE, name_en: "Norwegian", name_native: "norsk", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨nqo⟩) THEN (
    CREATE i18n_locale:⟨nqo⟩ CONTENT { tag: "nqo", language: "nqo", script: NONE, region: NONE, name_en: "N’Ko", name_native: "ߒߞߏ", direction: "rtl", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨nqo-GN⟩) THEN (
    CREATE i18n_locale:⟨nqo-GN⟩ CONTENT { tag: "nqo-GN", language: "nqo", script: NONE, region: "GN", name_en: "N’Ko (Guinea)", name_native: "ߒߞߏ (ߖߌ߬ߣߍ߫)", direction: "rtl", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["nqo"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨nso⟩) THEN (
    CREATE i18n_locale:⟨nso⟩ CONTENT { tag: "nso", language: "nso", script: NONE, region: NONE, name_en: "Northern Sotho", name_native: "Sesotho sa Leboa", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨nso-ZA⟩) THEN (
    CREATE i18n_locale:⟨nso-ZA⟩ CONTENT { tag: "nso-ZA", language: "nso", script: NONE, region: "ZA", name_en: "Northern Sotho (South Africa)", name_native: "Sesotho sa Leboa (Afrika Borwa)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["nso"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨nus⟩) THEN (
    CREATE i18n_locale:⟨nus⟩ CONTENT { tag: "nus", language: "nus", script: NONE, region: NONE, name_en: "Nuer", name_native: "Thok Nath", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨nus-SS⟩) THEN (
    CREATE i18n_locale:⟨nus-SS⟩ CONTENT { tag: "nus-SS", language: "nus", script: NONE, region: "SS", name_en: "Nuer (South Sudan)", name_native: "Thok Nath (SS)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["nus"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨nyn⟩) THEN (
    CREATE i18n_locale:⟨nyn⟩ CONTENT { tag: "nyn", language: "nyn", script: NONE, region: NONE, name_en: "Nyankole", name_native: "Runyankore", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨nyn-UG⟩) THEN (
    CREATE i18n_locale:⟨nyn-UG⟩ CONTENT { tag: "nyn-UG", language: "nyn", script: NONE, region: "UG", name_en: "Nyankole (Uganda)", name_native: "Runyankore (Uganda)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["nyn"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨oc⟩) THEN (
    CREATE i18n_locale:⟨oc⟩ CONTENT { tag: "oc", language: "oc", script: NONE, region: NONE, name_en: "Occitan", name_native: "occitan", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨oc-ES⟩) THEN (
    CREATE i18n_locale:⟨oc-ES⟩ CONTENT { tag: "oc-ES", language: "oc", script: NONE, region: "ES", name_en: "Occitan (Spain)", name_native: "occitan (Espanha)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["oc"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨oc-FR⟩) THEN (
    CREATE i18n_locale:⟨oc-FR⟩ CONTENT { tag: "oc-FR", language: "oc", script: NONE, region: "FR", name_en: "Occitan (France)", name_native: "occitan (França)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["oc"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨om⟩) THEN (
    CREATE i18n_locale:⟨om⟩ CONTENT { tag: "om", language: "om", script: NONE, region: NONE, name_en: "Oromo", name_native: "Oromoo", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨om-ET⟩) THEN (
    CREATE i18n_locale:⟨om-ET⟩ CONTENT { tag: "om-ET", language: "om", script: NONE, region: "ET", name_en: "Oromo (Ethiopia)", name_native: "Oromoo (Itoophiyaa)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["om"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨om-KE⟩) THEN (
    CREATE i18n_locale:⟨om-KE⟩ CONTENT { tag: "om-KE", language: "om", script: NONE, region: "KE", name_en: "Oromo (Kenya)", name_native: "Oromoo (Keeniyaa)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["om"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨or⟩) THEN (
    CREATE i18n_locale:⟨or⟩ CONTENT { tag: "or", language: "or", script: NONE, region: NONE, name_en: "Odia", name_native: "ଓଡ଼ିଆ", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "many", "other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨or-IN⟩) THEN (
    CREATE i18n_locale:⟨or-IN⟩ CONTENT { tag: "or-IN", language: "or", script: NONE, region: "IN", name_en: "Odia (India)", name_native: "ଓଡ଼ିଆ (ଭାରତ)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "two", "few", "many", "other"], fallback: ["or"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨os⟩) THEN (
    CREATE i18n_locale:⟨os⟩ CONTENT { tag: "os", language: "os", script: NONE, region: NONE, name_en: "Ossetic", name_native: "ирон", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨os-GE⟩) THEN (
    CREATE i18n_locale:⟨os-GE⟩ CONTENT { tag: "os-GE", language: "os", script: NONE, region: "GE", name_en: "Ossetic (Georgia)", name_native: "ирон (Гуырдзыстон)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["os"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨os-RU⟩) THEN (
    CREATE i18n_locale:⟨os-RU⟩ CONTENT { tag: "os-RU", language: "os", script: NONE, region: "RU", name_en: "Ossetic (Russia)", name_native: "ирон (Уӕрӕсе)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["os"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨pa⟩) THEN (
    CREATE i18n_locale:⟨pa⟩ CONTENT { tag: "pa", language: "pa", script: NONE, region: NONE, name_en: "Punjabi", name_native: "ਪੰਜਾਬੀ", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨pa-Arab⟩) THEN (
    CREATE i18n_locale:⟨pa-Arab⟩ CONTENT { tag: "pa-Arab", language: "pa", script: "Arab", region: NONE, name_en: "Punjabi (Arabic)", name_native: "پنجابی (عربی)", direction: "rtl", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨pa-Arab-PK⟩) THEN (
    CREATE i18n_locale:⟨pa-Arab-PK⟩ CONTENT { tag: "pa-Arab-PK", language: "pa", script: "Arab", region: "PK", name_en: "Punjabi (Arabic, Pakistan)", name_native: "پنجابی (عربی, پاکستان)", direction: "rtl", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["pa-Arab"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨pa-Guru⟩) THEN (
    CREATE i18n_locale:⟨pa-Guru⟩ CONTENT { tag: "pa-Guru", language: "pa", script: "Guru", region: NONE, name_en: "Punjabi (Gurmukhi)", name_native: "ਪੰਜਾਬੀ (ਗੁਰਮੁਖੀ)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["pa"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨pa-Guru-IN⟩) THEN (
    CREATE i18n_locale:⟨pa-Guru-IN⟩ CONTENT { tag: "pa-Guru-IN", language: "pa", script: "Guru", region: "IN", name_en: "Punjabi (Gurmukhi, India)", name_native: "ਪੰਜਾਬੀ (ਗੁਰਮੁਖੀ, ਭਾਰਤ)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["pa-Guru", "pa"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨pcm⟩) THEN (
    CREATE i18n_locale:⟨pcm⟩ CONTENT { tag: "pcm", language: "pcm", script: NONE, region: NONE, name_en: "Nigerian Pidgin", name_native: "Naijíriá Píjin", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨pcm-NG⟩) THEN (
    CREATE i18n_locale:⟨pcm-NG⟩ CONTENT { tag: "pcm-NG", language: "pcm", script: NONE, region: "NG", name_en: "Nigerian Pidgin (Nigeria)", name_native: "Naijíriá Píjin (Naijíria)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["pcm"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨pl⟩) THEN (
    CREATE i18n_locale:⟨pl⟩ CONTENT { tag: "pl", language: "pl", script: NONE, region: NONE, name_en: "Polish", name_native: "polski", direction: "ltr", plural_cardinal: ["one", "few", "many", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨pl-PL⟩) THEN (
    CREATE i18n_locale:⟨pl-PL⟩ CONTENT { tag: "pl-PL", language: "pl", script: NONE, region: "PL", name_en: "Polish (Poland)", name_native: "polski (Polska)", direction: "ltr", plural_cardinal: ["one", "few", "many", "other"], plural_ordinal: ["other"], fallback: ["pl"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨pms⟩) THEN (
    CREATE i18n_locale:⟨pms⟩ CONTENT { tag: "pms", language: "pms", script: NONE, region: NONE, name_en: "Piedmontese", name_native: "piemontèis", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨pms-IT⟩) THEN (
    CREATE i18n_locale:⟨pms-IT⟩ CONTENT { tag: "pms-IT", language: "pms", script: NONE, region: "IT", name_en: "Piedmontese (Italy)", name_native: "piemontèis (Italia)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["pms"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨prg⟩) THEN (
    CREATE i18n_locale:⟨prg⟩ CONTENT { tag: "prg", language: "prg", script: NONE, region: NONE, name_en: "Prussian", name_native: "prūsiskan", direction: "ltr", plural_cardinal: ["zero", "one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨prg-PL⟩) THEN (
    CREATE i18n_locale:⟨prg-PL⟩ CONTENT { tag: "prg-PL", language: "prg", script: NONE, region: "PL", name_en: "Prussian (Poland)", name_native: "prūsiskan (Pōli)", direction: "ltr", plural_cardinal: ["zero", "one", "other"], plural_ordinal: ["other"], fallback: ["prg"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ps⟩) THEN (
    CREATE i18n_locale:⟨ps⟩ CONTENT { tag: "ps", language: "ps", script: NONE, region: NONE, name_en: "Pashto", name_native: "پښتو", direction: "rtl", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ps-AF⟩) THEN (
    CREATE i18n_locale:⟨ps-AF⟩ CONTENT { tag: "ps-AF", language: "ps", script: NONE, region: "AF", name_en: "Pashto (Afghanistan)", name_native: "پښتو (افغانستان)", direction: "rtl", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["ps"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ps-PK⟩) THEN (
    CREATE i18n_locale:⟨ps-PK⟩ CONTENT { tag: "ps-PK", language: "ps", script: NONE, region: "PK", name_en: "Pashto (Pakistan)", name_native: "پښتو (پاکستان)", direction: "rtl", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["ps"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨pt⟩) THEN (
    CREATE i18n_locale:⟨pt⟩ CONTENT { tag: "pt", language: "pt", script: NONE, region: NONE, name_en: "Portuguese", name_native: "português", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨pt-AO⟩) THEN (
    CREATE i18n_locale:⟨pt-AO⟩ CONTENT { tag: "pt-AO", language: "pt", script: NONE, region: "AO", name_en: "Portuguese (Angola)", name_native: "português (Angola)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["other"], fallback: ["pt-PT", "pt"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨pt-BR⟩) THEN (
    CREATE i18n_locale:⟨pt-BR⟩ CONTENT { tag: "pt-BR", language: "pt", script: NONE, region: "BR", name_en: "Brazilian Portuguese", name_native: "português (Brasil)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["other"], fallback: ["pt"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨pt-CH⟩) THEN (
    CREATE i18n_locale:⟨pt-CH⟩ CONTENT { tag: "pt-CH", language: "pt", script: NONE, region: "CH", name_en: "Portuguese (Switzerland)", name_native: "português (Suíça)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["other"], fallback: ["pt-PT", "pt"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨pt-CV⟩) THEN (
    CREATE i18n_locale:⟨pt-CV⟩ CONTENT { tag: "pt-CV", language: "pt", script: NONE, region: "CV", name_en: "Portuguese (Cape Verde)", name_native: "português (Cabo Verde)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["other"], fallback: ["pt-PT", "pt"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨pt-GQ⟩) THEN (
    CREATE i18n_locale:⟨pt-GQ⟩ CONTENT { tag: "pt-GQ", language: "pt", script: NONE, region: "GQ", name_en: "Portuguese (Equatorial Guinea)", name_native: "português (Guiné Equatorial)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["other"], fallback: ["pt-PT", "pt"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨pt-GW⟩) THEN (
    CREATE i18n_locale:⟨pt-GW⟩ CONTENT { tag: "pt-GW", language: "pt", script: NONE, region: "GW", name_en: "Portuguese (Guinea-Bissau)", name_native: "português (Guiné-Bissau)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["other"], fallback: ["pt-PT", "pt"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨pt-LU⟩) THEN (
    CREATE i18n_locale:⟨pt-LU⟩ CONTENT { tag: "pt-LU", language: "pt", script: NONE, region: "LU", name_en: "Portuguese (Luxembourg)", name_native: "português (Luxemburgo)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["other"], fallback: ["pt-PT", "pt"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨pt-MO⟩) THEN (
    CREATE i18n_locale:⟨pt-MO⟩ CONTENT { tag: "pt-MO", language: "pt", script: NONE, region: "MO", name_en: "Portuguese (Macao SAR China)", name_native: "português (Macau, RAE da China)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["other"], fallback: ["pt-PT", "pt"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨pt-MZ⟩) THEN (
    CREATE i18n_locale:⟨pt-MZ⟩ CONTENT { tag: "pt-MZ", language: "pt", script: NONE, region: "MZ", name_en: "Portuguese (Mozambique)", name_native: "português (Moçambique)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["other"], fallback: ["pt-PT", "pt"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨pt-PT⟩) THEN (
    CREATE i18n_locale:⟨pt-PT⟩ CONTENT { tag: "pt-PT", language: "pt", script: NONE, region: "PT", name_en: "European Portuguese", name_native: "português europeu", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["other"], fallback: ["pt"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨pt-ST⟩) THEN (
    CREATE i18n_locale:⟨pt-ST⟩ CONTENT { tag: "pt-ST", language: "pt", script: NONE, region: "ST", name_en: "Portuguese (São Tomé & Príncipe)", name_native: "português (São Tomé e Príncipe)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["other"], fallback: ["pt-PT", "pt"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨pt-TL⟩) THEN (
    CREATE i18n_locale:⟨pt-TL⟩ CONTENT { tag: "pt-TL", language: "pt", script: NONE, region: "TL", name_en: "Portuguese (Timor-Leste)", name_native: "português (Timor-Leste)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["other"], fallback: ["pt-PT", "pt"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨qu⟩) THEN (
    CREATE i18n_locale:⟨qu⟩ CONTENT { tag: "qu", language: "qu", script: NONE, region: NONE, name_en: "Quechua", name_native: "Runasimi", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨qu-BO⟩) THEN (
    CREATE i18n_locale:⟨qu-BO⟩ CONTENT { tag: "qu-BO", language: "qu", script: NONE, region: "BO", name_en: "Quechua (Bolivia)", name_native: "Runasimi (Bolivia)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["qu"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨qu-EC⟩) THEN (
    CREATE i18n_locale:⟨qu-EC⟩ CONTENT { tag: "qu-EC", language: "qu", script: NONE, region: "EC", name_en: "Quechua (Ecuador)", name_native: "Runasimi (Ecuador)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["qu"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨qu-PE⟩) THEN (
    CREATE i18n_locale:⟨qu-PE⟩ CONTENT { tag: "qu-PE", language: "qu", script: NONE, region: "PE", name_en: "Quechua (Peru)", name_native: "Runasimi (Perú)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["qu"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨quc⟩) THEN (
    CREATE i18n_locale:⟨quc⟩ CONTENT { tag: "quc", language: "quc", script: NONE, region: NONE, name_en: "Kʼicheʼ", name_native: "kʼicheʼ", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨quc-GT⟩) THEN (
    CREATE i18n_locale:⟨quc-GT⟩ CONTENT { tag: "quc-GT", language: "quc", script: NONE, region: "GT", name_en: "Kʼicheʼ (Guatemala)", name_native: "kʼicheʼ (Guatemala)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["quc"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨raj⟩) THEN (
    CREATE i18n_locale:⟨raj⟩ CONTENT { tag: "raj", language: "raj", script: NONE, region: NONE, name_en: "Rajasthani", name_native: "राजस्थानी", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨raj-IN⟩) THEN (
    CREATE i18n_locale:⟨raj-IN⟩ CONTENT { tag: "raj-IN", language: "raj", script: NONE, region: "IN", name_en: "Rajasthani (India)", name_native: "राजस्थानी (भारत)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["raj"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨rm⟩) THEN (
    CREATE i18n_locale:⟨rm⟩ CONTENT { tag: "rm", language: "rm", script: NONE, region: NONE, name_en: "Romansh", name_native: "rumantsch", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨rm-CH⟩) THEN (
    CREATE i18n_locale:⟨rm-CH⟩ CONTENT { tag: "rm-CH", language: "rm", script: NONE, region: "CH", name_en: "Romansh (Switzerland)", name_native: "rumantsch (Svizra)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["rm"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨rn⟩) THEN (
    CREATE i18n_locale:⟨rn⟩ CONTENT { tag: "rn", language: "rn", script: NONE, region: NONE, name_en: "Rundi", name_native: "Ikirundi", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨rn-BI⟩) THEN (
    CREATE i18n_locale:⟨rn-BI⟩ CONTENT { tag: "rn-BI", language: "rn", script: NONE, region: "BI", name_en: "Rundi (Burundi)", name_native: "Ikirundi (Uburundi)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["rn"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ro⟩) THEN (
    CREATE i18n_locale:⟨ro⟩ CONTENT { tag: "ro", language: "ro", script: NONE, region: NONE, name_en: "Romanian", name_native: "română", direction: "ltr", plural_cardinal: ["one", "few", "other"], plural_ordinal: ["one", "other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ro-MD⟩) THEN (
    CREATE i18n_locale:⟨ro-MD⟩ CONTENT { tag: "ro-MD", language: "ro", script: NONE, region: "MD", name_en: "Moldavian", name_native: "română (Republica Moldova)", direction: "ltr", plural_cardinal: ["one", "few", "other"], plural_ordinal: ["one", "other"], fallback: ["ro"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ro-RO⟩) THEN (
    CREATE i18n_locale:⟨ro-RO⟩ CONTENT { tag: "ro-RO", language: "ro", script: NONE, region: "RO", name_en: "Romanian (Romania)", name_native: "română (România)", direction: "ltr", plural_cardinal: ["one", "few", "other"], plural_ordinal: ["one", "other"], fallback: ["ro"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨rof⟩) THEN (
    CREATE i18n_locale:⟨rof⟩ CONTENT { tag: "rof", language: "rof", script: NONE, region: NONE, name_en: "Rombo", name_native: "Kihorombo", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨rof-TZ⟩) THEN (
    CREATE i18n_locale:⟨rof-TZ⟩ CONTENT { tag: "rof-TZ", language: "rof", script: NONE, region: "TZ", name_en: "Rombo (Tanzania)", name_native: "Kihorombo (Tanzania)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["rof"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ru⟩) THEN (
    CREATE i18n_locale:⟨ru⟩ CONTENT { tag: "ru", language: "ru", script: NONE, region: NONE, name_en: "Russian", name_native: "русский", direction: "ltr", plural_cardinal: ["one", "few", "many", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ru-BY⟩) THEN (
    CREATE i18n_locale:⟨ru-BY⟩ CONTENT { tag: "ru-BY", language: "ru", script: NONE, region: "BY", name_en: "Russian (Belarus)", name_native: "русский (Беларусь)", direction: "ltr", plural_cardinal: ["one", "few", "many", "other"], plural_ordinal: ["other"], fallback: ["ru"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ru-KG⟩) THEN (
    CREATE i18n_locale:⟨ru-KG⟩ CONTENT { tag: "ru-KG", language: "ru", script: NONE, region: "KG", name_en: "Russian (Kyrgyzstan)", name_native: "русский (Киргизия)", direction: "ltr", plural_cardinal: ["one", "few", "many", "other"], plural_ordinal: ["other"], fallback: ["ru"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ru-KZ⟩) THEN (
    CREATE i18n_locale:⟨ru-KZ⟩ CONTENT { tag: "ru-KZ", language: "ru", script: NONE, region: "KZ", name_en: "Russian (Kazakhstan)", name_native: "русский (Казахстан)", direction: "ltr", plural_cardinal: ["one", "few", "many", "other"], plural_ordinal: ["other"], fallback: ["ru"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ru-MD⟩) THEN (
    CREATE i18n_locale:⟨ru-MD⟩ CONTENT { tag: "ru-MD", language: "ru", script: NONE, region: "MD", name_en: "Russian (Moldova)", name_native: "русский (Молдова)", direction: "ltr", plural_cardinal: ["one", "few", "many", "other"], plural_ordinal: ["other"], fallback: ["ru"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ru-RU⟩) THEN (
    CREATE i18n_locale:⟨ru-RU⟩ CONTENT { tag: "ru-RU", language: "ru", script: NONE, region: "RU", name_en: "Russian (Russia)", name_native: "русский (Россия)", direction: "ltr", plural_cardinal: ["one", "few", "many", "other"], plural_ordinal: ["other"], fallback: ["ru"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ru-UA⟩) THEN (
    CREATE i18n_locale:⟨ru-UA⟩ CONTENT { tag: "ru-UA", language: "ru", script: NONE, region: "UA", name_en: "Russian (Ukraine)", name_native: "русский (Украина)", direction: "ltr", plural_cardinal: ["one", "few", "many", "other"], plural_ordinal: ["other"], fallback: ["ru"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨rw⟩) THEN (
    CREATE i18n_locale:⟨rw⟩ CONTENT { tag: "rw", language: "rw", script: NONE, region: NONE, name_en: "Kinyarwanda", name_native: "Ikinyarwanda", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨rw-RW⟩) THEN (
    CREATE i18n_locale:⟨rw-RW⟩ CONTENT { tag: "rw-RW", language: "rw", script: NONE, region: "RW", name_en: "Kinyarwanda (Rwanda)", name_native: "Ikinyarwanda (U Rwanda)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["rw"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨rwk⟩) THEN (
    CREATE i18n_locale:⟨rwk⟩ CONTENT { tag: "rwk", language: "rwk", script: NONE, region: NONE, name_en: "Rwa", name_native: "Kiruwa", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨rwk-TZ⟩) THEN (
    CREATE i18n_locale:⟨rwk-TZ⟩ CONTENT { tag: "rwk-TZ", language: "rwk", script: NONE, region: "TZ", name_en: "Rwa (Tanzania)", name_native: "Kiruwa (Tanzania)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["rwk"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨sa⟩) THEN (
    CREATE i18n_locale:⟨sa⟩ CONTENT { tag: "sa", language: "sa", script: NONE, region: NONE, name_en: "Sanskrit", name_native: "संस्कृत भाषा", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨sa-IN⟩) THEN (
    CREATE i18n_locale:⟨sa-IN⟩ CONTENT { tag: "sa-IN", language: "sa", script: NONE, region: "IN", name_en: "Sanskrit (India)", name_native: "संस्कृत भाषा (भारतः)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["sa"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨sah⟩) THEN (
    CREATE i18n_locale:⟨sah⟩ CONTENT { tag: "sah", language: "sah", script: NONE, region: NONE, name_en: "Yakut", name_native: "саха тыла", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨sah-RU⟩) THEN (
    CREATE i18n_locale:⟨sah-RU⟩ CONTENT { tag: "sah-RU", language: "sah", script: NONE, region: "RU", name_en: "Yakut (Russia)", name_native: "саха тыла (Арассыыйа)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["sah"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨saq⟩) THEN (
    CREATE i18n_locale:⟨saq⟩ CONTENT { tag: "saq", language: "saq", script: NONE, region: NONE, name_en: "Samburu", name_native: "Kisampur", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨saq-KE⟩) THEN (
    CREATE i18n_locale:⟨saq-KE⟩ CONTENT { tag: "saq-KE", language: "saq", script: NONE, region: "KE", name_en: "Samburu (Kenya)", name_native: "Kisampur (Kenya)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["saq"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨sat⟩) THEN (
    CREATE i18n_locale:⟨sat⟩ CONTENT { tag: "sat", language: "sat", script: NONE, region: NONE, name_en: "Santali", name_native: "ᱥᱟᱱᱛᱟᱲᱤ", direction: "ltr", plural_cardinal: ["one", "two", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨sat-Olck⟩) THEN (
    CREATE i18n_locale:⟨sat-Olck⟩ CONTENT { tag: "sat-Olck", language: "sat", script: "Olck", region: NONE, name_en: "Santali (Ol Chiki)", name_native: "ᱥᱟᱱᱛᱟᱲᱤ (ᱚᱞ ᱪᱤᱠᱤ)", direction: "ltr", plural_cardinal: ["one", "two", "other"], plural_ordinal: ["other"], fallback: ["sat"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨sat-Olck-IN⟩) THEN (
    CREATE i18n_locale:⟨sat-Olck-IN⟩ CONTENT { tag: "sat-Olck-IN", language: "sat", script: "Olck", region: "IN", name_en: "Santali (Ol Chiki, India)", name_native: "ᱥᱟᱱᱛᱟᱲᱤ (ᱚᱞ ᱪᱤᱠᱤ, ᱤᱱᱰᱤᱭᱟ)", direction: "ltr", plural_cardinal: ["one", "two", "other"], plural_ordinal: ["other"], fallback: ["sat-Olck", "sat"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨sbp⟩) THEN (
    CREATE i18n_locale:⟨sbp⟩ CONTENT { tag: "sbp", language: "sbp", script: NONE, region: NONE, name_en: "Sangu", name_native: "Ishisangu", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨sbp-TZ⟩) THEN (
    CREATE i18n_locale:⟨sbp-TZ⟩ CONTENT { tag: "sbp-TZ", language: "sbp", script: NONE, region: "TZ", name_en: "Sangu (Tanzania)", name_native: "Ishisangu (Tansaniya)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["sbp"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨sc⟩) THEN (
    CREATE i18n_locale:⟨sc⟩ CONTENT { tag: "sc", language: "sc", script: NONE, region: NONE, name_en: "Sardinian", name_native: "sardu", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["many", "other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨sc-IT⟩) THEN (
    CREATE i18n_locale:⟨sc-IT⟩ CONTENT { tag: "sc-IT", language: "sc", script: NONE, region: "IT", name_en: "Sardinian (Italy)", name_native: "sardu (Itàlia)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["many", "other"], fallback: ["sc"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨scn⟩) THEN (
    CREATE i18n_locale:⟨scn⟩ CONTENT { tag: "scn", language: "scn", script: NONE, region: NONE, name_en: "Sicilian", name_native: "sicilianu", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["many", "other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨scn-IT⟩) THEN (
    CREATE i18n_locale:⟨scn-IT⟩ CONTENT { tag: "scn-IT", language: "scn", script: NONE, region: "IT", name_en: "Sicilian (Italy)", name_native: "sicilianu (Italia)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["many", "other"], fallback: ["scn"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨sd⟩) THEN (
    CREATE i18n_locale:⟨sd⟩ CONTENT { tag: "sd", language: "sd", script: NONE, region: NONE, name_en: "Sindhi", name_native: "سنڌي", direction: "rtl", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨sd-Arab⟩) THEN (
    CREATE i18n_locale:⟨sd-Arab⟩ CONTENT { tag: "sd-Arab", language: "sd", script: "Arab", region: NONE, name_en: "Sindhi (Arabic)", name_native: "سنڌي (عربي)", direction: "rtl", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["sd"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨sd-Arab-PK⟩) THEN (
    CREATE i18n_locale:⟨sd-Arab-PK⟩ CONTENT { tag: "sd-Arab-PK", language: "sd", script: "Arab", region: "PK", name_en: "Sindhi (Arabic, Pakistan)", name_native: "سنڌي (عربي, پاڪستان)", direction: "rtl", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["sd-Arab", "sd"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨sd-Deva⟩) THEN (
    CREATE i18n_locale:⟨sd-Deva⟩ CONTENT { tag: "sd-Deva", language: "sd", script: "Deva", region: NONE, name_en: "Sindhi (Devanagari)", name_native: "सिन्धी (देवनागिरी)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨sd-Deva-IN⟩) THEN (
    CREATE i18n_locale:⟨sd-Deva-IN⟩ CONTENT { tag: "sd-Deva-IN", language: "sd", script: "Deva", region: "IN", name_en: "Sindhi (Devanagari, India)", name_native: "सिन्धी (देवनागिरी, भारत)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["sd-Deva"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨se⟩) THEN (
    CREATE i18n_locale:⟨se⟩ CONTENT { tag: "se", language: "se", script: NONE, region: NONE, name_en: "Northern Sami", name_native: "davvisámegiella", direction: "ltr", plural_cardinal: ["one", "two", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨se-FI⟩) THEN (
    CREATE i18n_locale:⟨se-FI⟩ CONTENT { tag: "se-FI", language: "se", script: NONE, region: "FI", name_en: "Northern Sami (Finland)", name_native: "davvisámegiella (Suopma)", direction: "ltr", plural_cardinal: ["one", "two", "other"], plural_ordinal: ["other"], fallback: ["se"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨se-NO⟩) THEN (
    CREATE i18n_locale:⟨se-NO⟩ CONTENT { tag: "se-NO", language: "se", script: NONE, region: "NO", name_en: "Northern Sami (Norway)", name_native: "davvisámegiella (Norga)", direction: "ltr", plural_cardinal: ["one", "two", "other"], plural_ordinal: ["other"], fallback: ["se"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨se-SE⟩) THEN (
    CREATE i18n_locale:⟨se-SE⟩ CONTENT { tag: "se-SE", language: "se", script: NONE, region: "SE", name_en: "Northern Sami (Sweden)", name_native: "davvisámegiella (Ruoŧŧa)", direction: "ltr", plural_cardinal: ["one", "two", "other"], plural_ordinal: ["other"], fallback: ["se"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨seh⟩) THEN (
    CREATE i18n_locale:⟨seh⟩ CONTENT { tag: "seh", language: "seh", script: NONE, region: NONE, name_en: "Sena", name_native: "sena", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨seh-MZ⟩) THEN (
    CREATE i18n_locale:⟨seh-MZ⟩ CONTENT { tag: "seh-MZ", language: "seh", script: NONE, region: "MZ", name_en: "Sena (Mozambique)", name_native: "sena (Moçambique)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["seh"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ses⟩) THEN (
    CREATE i18n_locale:⟨ses⟩ CONTENT { tag: "ses", language: "ses", script: NONE, region: NONE, name_en: "Koyraboro Senni", name_native: "Koyraboro senni", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ses-ML⟩) THEN (
    CREATE i18n_locale:⟨ses-ML⟩ CONTENT { tag: "ses-ML", language: "ses", script: NONE, region: "ML", name_en: "Koyraboro Senni (Mali)", name_native: "Koyraboro senni (Maali)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["ses"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨sg⟩) THEN (
    CREATE i18n_locale:⟨sg⟩ CONTENT { tag: "sg", language: "sg", script: NONE, region: NONE, name_en: "Sango", name_native: "Sängö", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨sg-CF⟩) THEN (
    CREATE i18n_locale:⟨sg-CF⟩ CONTENT { tag: "sg-CF", language: "sg", script: NONE, region: "CF", name_en: "Sango (Central African Republic)", name_native: "Sängö (Ködörösêse tî Bêafrîka)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["sg"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨shi⟩) THEN (
    CREATE i18n_locale:⟨shi⟩ CONTENT { tag: "shi", language: "shi", script: NONE, region: NONE, name_en: "Tachelhit", name_native: "ⵜⴰⵛⵍⵃⵉⵜ", direction: "ltr", plural_cardinal: ["one", "few", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨shi-Latn⟩) THEN (
    CREATE i18n_locale:⟨shi-Latn⟩ CONTENT { tag: "shi-Latn", language: "shi", script: "Latn", region: NONE, name_en: "Tachelhit (Latin)", name_native: "Tashelḥiyt (Latn)", direction: "ltr", plural_cardinal: ["one", "few", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨shi-Latn-MA⟩) THEN (
    CREATE i18n_locale:⟨shi-Latn-MA⟩ CONTENT { tag: "shi-Latn-MA", language: "shi", script: "Latn", region: "MA", name_en: "Tachelhit (Latin, Morocco)", name_native: "Tashelḥiyt (Latn, lmɣrib)", direction: "ltr", plural_cardinal: ["one", "few", "other"], plural_ordinal: ["other"], fallback: ["shi-Latn"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨shi-Tfng⟩) THEN (
    CREATE i18n_locale:⟨shi-Tfng⟩ CONTENT { tag: "shi-Tfng", language: "shi", script: "Tfng", region: NONE, name_en: "Tachelhit (Tifinagh)", name_native: "ⵜⴰⵛⵍⵃⵉⵜ (Tfng)", direction: "ltr", plural_cardinal: ["one", "few", "other"], plural_ordinal: ["other"], fallback: ["shi"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨shi-Tfng-MA⟩) THEN (
    CREATE i18n_locale:⟨shi-Tfng-MA⟩ CONTENT { tag: "shi-Tfng-MA", language: "shi", script: "Tfng", region: "MA", name_en: "Tachelhit (Tifinagh, Morocco)", name_native: "ⵜⴰⵛⵍⵃⵉⵜ (Tfng, ⵍⵎⵖⵔⵉⴱ)", direction: "ltr", plural_cardinal: ["one", "few", "other"], plural_ordinal: ["other"], fallback: ["shi-Tfng", "shi"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨shn⟩) THEN (
    CREATE i18n_locale:⟨shn⟩ CONTENT { tag: "shn", language: "shn", script: NONE, region: NONE, name_en: "Shan", name_native: "တႆး", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨shn-MM⟩) THEN (
    CREATE i18n_locale:⟨shn-MM⟩ CONTENT { tag: "shn-MM", language: "shn", script: NONE, region: "MM", name_en: "Shan (Myanmar (Burma))", name_native: "တႆး (မျၢၼ်ႇမႃႇ (မိူင်းမၢၼ်ႈ))", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["shn"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨shn-TH⟩) THEN (
    CREATE i18n_locale:⟨shn-TH⟩ CONTENT { tag: "shn-TH", language: "shn", script: NONE, region: "TH", name_en: "Shan (Thailand)", name_native: "တႆး (မိူင်းထႆး)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["shn"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨si⟩) THEN (
    CREATE i18n_locale:⟨si⟩ CONTENT { tag: "si", language: "si", script: NONE, region: NONE, name_en: "Sinhala", name_native: "සිංහල", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨si-LK⟩) THEN (
    CREATE i18n_locale:⟨si-LK⟩ CONTENT { tag: "si-LK", language: "si", script: NONE, region: "LK", name_en: "Sinhala (Sri Lanka)", name_native: "සිංහල (ශ්‍රී ලංකාව)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["si"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨sk⟩) THEN (
    CREATE i18n_locale:⟨sk⟩ CONTENT { tag: "sk", language: "sk", script: NONE, region: NONE, name_en: "Slovak", name_native: "slovenčina", direction: "ltr", plural_cardinal: ["one", "few", "many", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨sk-SK⟩) THEN (
    CREATE i18n_locale:⟨sk-SK⟩ CONTENT { tag: "sk-SK", language: "sk", script: NONE, region: "SK", name_en: "Slovak (Slovakia)", name_native: "slovenčina (Slovensko)", direction: "ltr", plural_cardinal: ["one", "few", "many", "other"], plural_ordinal: ["other"], fallback: ["sk"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨sl⟩) THEN (
    CREATE i18n_locale:⟨sl⟩ CONTENT { tag: "sl", language: "sl", script: NONE, region: NONE, name_en: "Slovenian", name_native: "slovenščina", direction: "ltr", plural_cardinal: ["one", "two", "few", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨sl-SI⟩) THEN (
    CREATE i18n_locale:⟨sl-SI⟩ CONTENT { tag: "sl-SI", language: "sl", script: NONE, region: "SI", name_en: "Slovenian (Slovenia)", name_native: "slovenščina (Slovenija)", direction: "ltr", plural_cardinal: ["one", "two", "few", "other"], plural_ordinal: ["other"], fallback: ["sl"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨smn⟩) THEN (
    CREATE i18n_locale:⟨smn⟩ CONTENT { tag: "smn", language: "smn", script: NONE, region: NONE, name_en: "Inari Sami", name_native: "anarâškielâ", direction: "ltr", plural_cardinal: ["one", "two", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨smn-FI⟩) THEN (
    CREATE i18n_locale:⟨smn-FI⟩ CONTENT { tag: "smn-FI", language: "smn", script: NONE, region: "FI", name_en: "Inari Sami (Finland)", name_native: "anarâškielâ (Suomâ)", direction: "ltr", plural_cardinal: ["one", "two", "other"], plural_ordinal: ["other"], fallback: ["smn"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨sn⟩) THEN (
    CREATE i18n_locale:⟨sn⟩ CONTENT { tag: "sn", language: "sn", script: NONE, region: NONE, name_en: "Shona", name_native: "chiShona", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨sn-ZW⟩) THEN (
    CREATE i18n_locale:⟨sn-ZW⟩ CONTENT { tag: "sn-ZW", language: "sn", script: NONE, region: "ZW", name_en: "Shona (Zimbabwe)", name_native: "chiShona (Zimbabwe)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["sn"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨so⟩) THEN (
    CREATE i18n_locale:⟨so⟩ CONTENT { tag: "so", language: "so", script: NONE, region: NONE, name_en: "Somali", name_native: "Soomaali", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨so-DJ⟩) THEN (
    CREATE i18n_locale:⟨so-DJ⟩ CONTENT { tag: "so-DJ", language: "so", script: NONE, region: "DJ", name_en: "Somali (Djibouti)", name_native: "Soomaali (Jabuuti)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["so"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨so-ET⟩) THEN (
    CREATE i18n_locale:⟨so-ET⟩ CONTENT { tag: "so-ET", language: "so", script: NONE, region: "ET", name_en: "Somali (Ethiopia)", name_native: "Soomaali (Itoobiya)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["so"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨so-KE⟩) THEN (
    CREATE i18n_locale:⟨so-KE⟩ CONTENT { tag: "so-KE", language: "so", script: NONE, region: "KE", name_en: "Somali (Kenya)", name_native: "Soomaali (Kenya)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["so"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨so-SO⟩) THEN (
    CREATE i18n_locale:⟨so-SO⟩ CONTENT { tag: "so-SO", language: "so", script: NONE, region: "SO", name_en: "Somali (Somalia)", name_native: "Soomaali (Soomaaliya)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["so"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨sq⟩) THEN (
    CREATE i18n_locale:⟨sq⟩ CONTENT { tag: "sq", language: "sq", script: NONE, region: NONE, name_en: "Albanian", name_native: "shqip", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "many", "other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨sq-AL⟩) THEN (
    CREATE i18n_locale:⟨sq-AL⟩ CONTENT { tag: "sq-AL", language: "sq", script: NONE, region: "AL", name_en: "Albanian (Albania)", name_native: "shqip (Shqipëri)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "many", "other"], fallback: ["sq"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨sq-MK⟩) THEN (
    CREATE i18n_locale:⟨sq-MK⟩ CONTENT { tag: "sq-MK", language: "sq", script: NONE, region: "MK", name_en: "Albanian (North Macedonia)", name_native: "shqip (Maqedonia e Veriut)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "many", "other"], fallback: ["sq"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨sq-XK⟩) THEN (
    CREATE i18n_locale:⟨sq-XK⟩ CONTENT { tag: "sq-XK", language: "sq", script: NONE, region: "XK", name_en: "Albanian (Kosovo)", name_native: "shqip (Kosovë)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "many", "other"], fallback: ["sq"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨sr⟩) THEN (
    CREATE i18n_locale:⟨sr⟩ CONTENT { tag: "sr", language: "sr", script: NONE, region: NONE, name_en: "Serbian", name_native: "српски", direction: "ltr", plural_cardinal: ["one", "few", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨sr-Cyrl⟩) THEN (
    CREATE i18n_locale:⟨sr-Cyrl⟩ CONTENT { tag: "sr-Cyrl", language: "sr", script: "Cyrl", region: NONE, name_en: "Serbian (Cyrillic)", name_native: "српски (ћирилица)", direction: "ltr", plural_cardinal: ["one", "few", "other"], plural_ordinal: ["other"], fallback: ["sr"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨sr-Cyrl-BA⟩) THEN (
    CREATE i18n_locale:⟨sr-Cyrl-BA⟩ CONTENT { tag: "sr-Cyrl-BA", language: "sr", script: "Cyrl", region: "BA", name_en: "Serbian (Cyrillic, Bosnia & Herzegovina)", name_native: "српски (ћирилица, Босна и Херцеговина)", direction: "ltr", plural_cardinal: ["one", "few", "other"], plural_ordinal: ["other"], fallback: ["sr-Cyrl", "sr"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨sr-Cyrl-ME⟩) THEN (
    CREATE i18n_locale:⟨sr-Cyrl-ME⟩ CONTENT { tag: "sr-Cyrl-ME", language: "sr", script: "Cyrl", region: "ME", name_en: "Serbian (Cyrillic, Montenegro)", name_native: "српски (ћирилица, Црна Гора)", direction: "ltr", plural_cardinal: ["one", "few", "other"], plural_ordinal: ["other"], fallback: ["sr-Cyrl", "sr"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨sr-Cyrl-RS⟩) THEN (
    CREATE i18n_locale:⟨sr-Cyrl-RS⟩ CONTENT { tag: "sr-Cyrl-RS", language: "sr", script: "Cyrl", region: "RS", name_en: "Serbian (Cyrillic, Serbia)", name_native: "српски (ћирилица, Србија)", direction: "ltr", plural_cardinal: ["one", "few", "other"], plural_ordinal: ["other"], fallback: ["sr-Cyrl", "sr"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨sr-Cyrl-XK⟩) THEN (
    CREATE i18n_locale:⟨sr-Cyrl-XK⟩ CONTENT { tag: "sr-Cyrl-XK", language: "sr", script: "Cyrl", region: "XK", name_en: "Serbian (Cyrillic, Kosovo)", name_native: "српски (ћирилица, Косово)", direction: "ltr", plural_cardinal: ["one", "few", "other"], plural_ordinal: ["other"], fallback: ["sr-Cyrl", "sr"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨sr-Latn⟩) THEN (
    CREATE i18n_locale:⟨sr-Latn⟩ CONTENT { tag: "sr-Latn", language: "sr", script: "Latn", region: NONE, name_en: "Serbian (Latin)", name_native: "srpski (latinica)", direction: "ltr", plural_cardinal: ["one", "few", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨sr-Latn-BA⟩) THEN (
    CREATE i18n_locale:⟨sr-Latn-BA⟩ CONTENT { tag: "sr-Latn-BA", language: "sr", script: "Latn", region: "BA", name_en: "Serbian (Latin, Bosnia & Herzegovina)", name_native: "srpski (latinica, Bosna i Hercegovina)", direction: "ltr", plural_cardinal: ["one", "few", "other"], plural_ordinal: ["other"], fallback: ["sr-Latn"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨sr-Latn-ME⟩) THEN (
    CREATE i18n_locale:⟨sr-Latn-ME⟩ CONTENT { tag: "sr-Latn-ME", language: "sr", script: "Latn", region: "ME", name_en: "Serbian (Latin, Montenegro)", name_native: "srpski (latinica, Crna Gora)", direction: "ltr", plural_cardinal: ["one", "few", "other"], plural_ordinal: ["other"], fallback: ["sr-Latn"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨sr-Latn-RS⟩) THEN (
    CREATE i18n_locale:⟨sr-Latn-RS⟩ CONTENT { tag: "sr-Latn-RS", language: "sr", script: "Latn", region: "RS", name_en: "Serbian (Latin, Serbia)", name_native: "srpski (latinica, Srbija)", direction: "ltr", plural_cardinal: ["one", "few", "other"], plural_ordinal: ["other"], fallback: ["sr-Latn"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨sr-Latn-XK⟩) THEN (
    CREATE i18n_locale:⟨sr-Latn-XK⟩ CONTENT { tag: "sr-Latn-XK", language: "sr", script: "Latn", region: "XK", name_en: "Serbian (Latin, Kosovo)", name_native: "srpski (latinica, Kosovo)", direction: "ltr", plural_cardinal: ["one", "few", "other"], plural_ordinal: ["other"], fallback: ["sr-Latn"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨st⟩) THEN (
    CREATE i18n_locale:⟨st⟩ CONTENT { tag: "st", language: "st", script: NONE, region: NONE, name_en: "Southern Sotho", name_native: "Sesotho", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨st-LS⟩) THEN (
    CREATE i18n_locale:⟨st-LS⟩ CONTENT { tag: "st-LS", language: "st", script: NONE, region: "LS", name_en: "Southern Sotho (Lesotho)", name_native: "Sesotho (Lesotho)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["st"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨st-ZA⟩) THEN (
    CREATE i18n_locale:⟨st-ZA⟩ CONTENT { tag: "st-ZA", language: "st", script: NONE, region: "ZA", name_en: "Southern Sotho (South Africa)", name_native: "Sesotho (Afrika Borwa)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["st"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨su⟩) THEN (
    CREATE i18n_locale:⟨su⟩ CONTENT { tag: "su", language: "su", script: NONE, region: NONE, name_en: "Sundanese", name_native: "Basa Sunda", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨su-Latn⟩) THEN (
    CREATE i18n_locale:⟨su-Latn⟩ CONTENT { tag: "su-Latn", language: "su", script: "Latn", region: NONE, name_en: "Sundanese (Latin)", name_native: "Basa Sunda (Basa Latin)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["su"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨su-Latn-ID⟩) THEN (
    CREATE i18n_locale:⟨su-Latn-ID⟩ CONTENT { tag: "su-Latn-ID", language: "su", script: "Latn", region: "ID", name_en: "Sundanese (Latin, Indonesia)", name_native: "Basa Sunda (Basa Latin, Basa Indonesia)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["su-Latn", "su"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨suz-Sunu⟩) THEN (
    CREATE i18n_locale:⟨suz-Sunu⟩ CONTENT { tag: "suz-Sunu", language: "suz", script: "Sunu", region: NONE, name_en: "suz-Sunu", name_native: "𑯒𑯅𑯍𑯅𑯓𑯖𑯄 (𑯒𑯅𑯍𑯅𑯓𑯖𑯄)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨suz-Sunu-NP⟩) THEN (
    CREATE i18n_locale:⟨suz-Sunu-NP⟩ CONTENT { tag: "suz-Sunu-NP", language: "suz", script: "Sunu", region: "NP", name_en: "suz-Sunu-NP", name_native: "𑯒𑯅𑯍𑯅𑯓𑯖𑯄 (𑯒𑯅𑯍𑯅𑯓𑯖𑯄, 𑯍𑯂𑯉𑯖𑯂)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["suz-Sunu"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨sv⟩) THEN (
    CREATE i18n_locale:⟨sv⟩ CONTENT { tag: "sv", language: "sv", script: NONE, region: NONE, name_en: "Swedish", name_native: "svenska", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨sv-AX⟩) THEN (
    CREATE i18n_locale:⟨sv-AX⟩ CONTENT { tag: "sv-AX", language: "sv", script: NONE, region: "AX", name_en: "Swedish (Åland Islands)", name_native: "svenska (Åland)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "other"], fallback: ["sv"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨sv-FI⟩) THEN (
    CREATE i18n_locale:⟨sv-FI⟩ CONTENT { tag: "sv-FI", language: "sv", script: NONE, region: "FI", name_en: "Swedish (Finland)", name_native: "svenska (Finland)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "other"], fallback: ["sv"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨sv-SE⟩) THEN (
    CREATE i18n_locale:⟨sv-SE⟩ CONTENT { tag: "sv-SE", language: "sv", script: NONE, region: "SE", name_en: "Swedish (Sweden)", name_native: "svenska (Sverige)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "other"], fallback: ["sv"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨sw⟩) THEN (
    CREATE i18n_locale:⟨sw⟩ CONTENT { tag: "sw", language: "sw", script: NONE, region: NONE, name_en: "Swahili", name_native: "Kiswahili", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨sw-CD⟩) THEN (
    CREATE i18n_locale:⟨sw-CD⟩ CONTENT { tag: "sw-CD", language: "sw", script: NONE, region: "CD", name_en: "Congo Swahili", name_native: "Kiswahili (Kongo - Kinshasa)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["sw"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨sw-KE⟩) THEN (
    CREATE i18n_locale:⟨sw-KE⟩ CONTENT { tag: "sw-KE", language: "sw", script: NONE, region: "KE", name_en: "Swahili (Kenya)", name_native: "Kiswahili (Kenya)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["sw"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨sw-TZ⟩) THEN (
    CREATE i18n_locale:⟨sw-TZ⟩ CONTENT { tag: "sw-TZ", language: "sw", script: NONE, region: "TZ", name_en: "Swahili (Tanzania)", name_native: "Kiswahili (Tanzania)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["sw"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨sw-UG⟩) THEN (
    CREATE i18n_locale:⟨sw-UG⟩ CONTENT { tag: "sw-UG", language: "sw", script: NONE, region: "UG", name_en: "Swahili (Uganda)", name_native: "Kiswahili (Uganda)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["sw"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨syr⟩) THEN (
    CREATE i18n_locale:⟨syr⟩ CONTENT { tag: "syr", language: "syr", script: NONE, region: NONE, name_en: "Syriac", name_native: "ܣܘܪܝܝܐ", direction: "rtl", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨syr-IQ⟩) THEN (
    CREATE i18n_locale:⟨syr-IQ⟩ CONTENT { tag: "syr-IQ", language: "syr", script: NONE, region: "IQ", name_en: "Syriac (Iraq)", name_native: "ܣܘܪܝܝܐ (ܥܝܪܩ)", direction: "rtl", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["syr"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨syr-SY⟩) THEN (
    CREATE i18n_locale:⟨syr-SY⟩ CONTENT { tag: "syr-SY", language: "syr", script: NONE, region: "SY", name_en: "Syriac (Syria)", name_native: "ܣܘܪܝܝܐ (ܣܘܪܝܐ)", direction: "rtl", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["syr"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨szl⟩) THEN (
    CREATE i18n_locale:⟨szl⟩ CONTENT { tag: "szl", language: "szl", script: NONE, region: NONE, name_en: "Silesian", name_native: "ślōnski", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨szl-PL⟩) THEN (
    CREATE i18n_locale:⟨szl-PL⟩ CONTENT { tag: "szl-PL", language: "szl", script: NONE, region: "PL", name_en: "Silesian (Poland)", name_native: "ślōnski (Polska)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["szl"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ta⟩) THEN (
    CREATE i18n_locale:⟨ta⟩ CONTENT { tag: "ta", language: "ta", script: NONE, region: NONE, name_en: "Tamil", name_native: "தமிழ்", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ta-IN⟩) THEN (
    CREATE i18n_locale:⟨ta-IN⟩ CONTENT { tag: "ta-IN", language: "ta", script: NONE, region: "IN", name_en: "Tamil (India)", name_native: "தமிழ் (இந்தியா)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["ta"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ta-LK⟩) THEN (
    CREATE i18n_locale:⟨ta-LK⟩ CONTENT { tag: "ta-LK", language: "ta", script: NONE, region: "LK", name_en: "Tamil (Sri Lanka)", name_native: "தமிழ் (இலங்கை)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["ta"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ta-MY⟩) THEN (
    CREATE i18n_locale:⟨ta-MY⟩ CONTENT { tag: "ta-MY", language: "ta", script: NONE, region: "MY", name_en: "Tamil (Malaysia)", name_native: "தமிழ் (மலேசியா)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["ta"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ta-SG⟩) THEN (
    CREATE i18n_locale:⟨ta-SG⟩ CONTENT { tag: "ta-SG", language: "ta", script: NONE, region: "SG", name_en: "Tamil (Singapore)", name_native: "தமிழ் (சிங்கப்பூர்)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["ta"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨te⟩) THEN (
    CREATE i18n_locale:⟨te⟩ CONTENT { tag: "te", language: "te", script: NONE, region: NONE, name_en: "Telugu", name_native: "తెలుగు", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨te-IN⟩) THEN (
    CREATE i18n_locale:⟨te-IN⟩ CONTENT { tag: "te-IN", language: "te", script: NONE, region: "IN", name_en: "Telugu (India)", name_native: "తెలుగు (భారతదేశం)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["te"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨teo⟩) THEN (
    CREATE i18n_locale:⟨teo⟩ CONTENT { tag: "teo", language: "teo", script: NONE, region: NONE, name_en: "Teso", name_native: "Kiteso", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨teo-KE⟩) THEN (
    CREATE i18n_locale:⟨teo-KE⟩ CONTENT { tag: "teo-KE", language: "teo", script: NONE, region: "KE", name_en: "Teso (Kenya)", name_native: "Kiteso (Kenia)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["teo"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨teo-UG⟩) THEN (
    CREATE i18n_locale:⟨teo-UG⟩ CONTENT { tag: "teo-UG", language: "teo", script: NONE, region: "UG", name_en: "Teso (Uganda)", name_native: "Kiteso (Uganda)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["teo"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨tg⟩) THEN (
    CREATE i18n_locale:⟨tg⟩ CONTENT { tag: "tg", language: "tg", script: NONE, region: NONE, name_en: "Tajik", name_native: "тоҷикӣ", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨tg-TJ⟩) THEN (
    CREATE i18n_locale:⟨tg-TJ⟩ CONTENT { tag: "tg-TJ", language: "tg", script: NONE, region: "TJ", name_en: "Tajik (Tajikistan)", name_native: "тоҷикӣ (Тоҷикистон)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["tg"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨th⟩) THEN (
    CREATE i18n_locale:⟨th⟩ CONTENT { tag: "th", language: "th", script: NONE, region: NONE, name_en: "Thai", name_native: "ไทย", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨th-TH⟩) THEN (
    CREATE i18n_locale:⟨th-TH⟩ CONTENT { tag: "th-TH", language: "th", script: NONE, region: "TH", name_en: "Thai (Thailand)", name_native: "ไทย (ไทย)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["th"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ti⟩) THEN (
    CREATE i18n_locale:⟨ti⟩ CONTENT { tag: "ti", language: "ti", script: NONE, region: NONE, name_en: "Tigrinya", name_native: "ትግርኛ", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ti-ER⟩) THEN (
    CREATE i18n_locale:⟨ti-ER⟩ CONTENT { tag: "ti-ER", language: "ti", script: NONE, region: "ER", name_en: "Tigrinya (Eritrea)", name_native: "ትግርኛ (ኤርትራ)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["ti"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ti-ET⟩) THEN (
    CREATE i18n_locale:⟨ti-ET⟩ CONTENT { tag: "ti-ET", language: "ti", script: NONE, region: "ET", name_en: "Tigrinya (Ethiopia)", name_native: "ትግርኛ (ኢትዮጵያ)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["ti"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨tk⟩) THEN (
    CREATE i18n_locale:⟨tk⟩ CONTENT { tag: "tk", language: "tk", script: NONE, region: NONE, name_en: "Turkmen", name_native: "türkmen dili", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["few", "other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨tk-TM⟩) THEN (
    CREATE i18n_locale:⟨tk-TM⟩ CONTENT { tag: "tk-TM", language: "tk", script: NONE, region: "TM", name_en: "Turkmen (Turkmenistan)", name_native: "türkmen dili (Türkmenistan)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["few", "other"], fallback: ["tk"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨tn⟩) THEN (
    CREATE i18n_locale:⟨tn⟩ CONTENT { tag: "tn", language: "tn", script: NONE, region: NONE, name_en: "Tswana", name_native: "Setswana", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨tn-BW⟩) THEN (
    CREATE i18n_locale:⟨tn-BW⟩ CONTENT { tag: "tn-BW", language: "tn", script: NONE, region: "BW", name_en: "Tswana (Botswana)", name_native: "Setswana (Botswana)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["tn"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨tn-ZA⟩) THEN (
    CREATE i18n_locale:⟨tn-ZA⟩ CONTENT { tag: "tn-ZA", language: "tn", script: NONE, region: "ZA", name_en: "Tswana (South Africa)", name_native: "Setswana (Aforika Borwa)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["tn"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨to⟩) THEN (
    CREATE i18n_locale:⟨to⟩ CONTENT { tag: "to", language: "to", script: NONE, region: NONE, name_en: "Tongan", name_native: "lea fakatonga", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨to-TO⟩) THEN (
    CREATE i18n_locale:⟨to-TO⟩ CONTENT { tag: "to-TO", language: "to", script: NONE, region: "TO", name_en: "Tongan (Tonga)", name_native: "lea fakatonga (Tonga)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["to"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨tok⟩) THEN (
    CREATE i18n_locale:⟨tok⟩ CONTENT { tag: "tok", language: "tok", script: NONE, region: NONE, name_en: "Toki Pona", name_native: "toki pona", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨tok-001⟩) THEN (
    CREATE i18n_locale:⟨tok-001⟩ CONTENT { tag: "tok-001", language: "tok", script: NONE, region: "001", name_en: "Toki Pona (world)", name_native: "toki pona (ma ale)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["tok"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨tr⟩) THEN (
    CREATE i18n_locale:⟨tr⟩ CONTENT { tag: "tr", language: "tr", script: NONE, region: NONE, name_en: "Turkish", name_native: "Türkçe", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨tr-CY⟩) THEN (
    CREATE i18n_locale:⟨tr-CY⟩ CONTENT { tag: "tr-CY", language: "tr", script: NONE, region: "CY", name_en: "Turkish (Cyprus)", name_native: "Türkçe (Kıbrıs)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["tr"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨tr-TR⟩) THEN (
    CREATE i18n_locale:⟨tr-TR⟩ CONTENT { tag: "tr-TR", language: "tr", script: NONE, region: "TR", name_en: "Turkish (Türkiye)", name_native: "Türkçe (Türkiye)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["tr"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨tt⟩) THEN (
    CREATE i18n_locale:⟨tt⟩ CONTENT { tag: "tt", language: "tt", script: NONE, region: NONE, name_en: "Tatar", name_native: "татар", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨tt-RU⟩) THEN (
    CREATE i18n_locale:⟨tt-RU⟩ CONTENT { tag: "tt-RU", language: "tt", script: NONE, region: "RU", name_en: "Tatar (Russia)", name_native: "татар (Россия)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["tt"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨twq⟩) THEN (
    CREATE i18n_locale:⟨twq⟩ CONTENT { tag: "twq", language: "twq", script: NONE, region: NONE, name_en: "Tasawaq", name_native: "Tasawaq senni", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨twq-NE⟩) THEN (
    CREATE i18n_locale:⟨twq-NE⟩ CONTENT { tag: "twq-NE", language: "twq", script: NONE, region: "NE", name_en: "Tasawaq (Niger)", name_native: "Tasawaq senni (Nižer)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["twq"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨tyv⟩) THEN (
    CREATE i18n_locale:⟨tyv⟩ CONTENT { tag: "tyv", language: "tyv", script: NONE, region: NONE, name_en: "Tuvinian", name_native: "Тыва", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨tyv-RU⟩) THEN (
    CREATE i18n_locale:⟨tyv-RU⟩ CONTENT { tag: "tyv-RU", language: "tyv", script: NONE, region: "RU", name_en: "Tuvinian (Russia)", name_native: "Тыва (Россия Федерациязы)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["tyv"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨tzm⟩) THEN (
    CREATE i18n_locale:⟨tzm⟩ CONTENT { tag: "tzm", language: "tzm", script: NONE, region: NONE, name_en: "Central Atlas Tamazight", name_native: "Tamaziɣt n laṭlaṣ", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨tzm-MA⟩) THEN (
    CREATE i18n_locale:⟨tzm-MA⟩ CONTENT { tag: "tzm-MA", language: "tzm", script: NONE, region: "MA", name_en: "Central Atlas Tamazight (Morocco)", name_native: "Tamaziɣt n laṭlaṣ (Meṛṛuk)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["tzm"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ug⟩) THEN (
    CREATE i18n_locale:⟨ug⟩ CONTENT { tag: "ug", language: "ug", script: NONE, region: NONE, name_en: "Uyghur", name_native: "ئۇيغۇرچە", direction: "rtl", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ug-CN⟩) THEN (
    CREATE i18n_locale:⟨ug-CN⟩ CONTENT { tag: "ug-CN", language: "ug", script: NONE, region: "CN", name_en: "Uyghur (China)", name_native: "ئۇيغۇرچە (جۇڭگو)", direction: "rtl", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["ug"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨uk⟩) THEN (
    CREATE i18n_locale:⟨uk⟩ CONTENT { tag: "uk", language: "uk", script: NONE, region: NONE, name_en: "Ukrainian", name_native: "українська", direction: "ltr", plural_cardinal: ["one", "few", "many", "other"], plural_ordinal: ["few", "other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨uk-UA⟩) THEN (
    CREATE i18n_locale:⟨uk-UA⟩ CONTENT { tag: "uk-UA", language: "uk", script: NONE, region: "UA", name_en: "Ukrainian (Ukraine)", name_native: "українська (Україна)", direction: "ltr", plural_cardinal: ["one", "few", "many", "other"], plural_ordinal: ["few", "other"], fallback: ["uk"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ur⟩) THEN (
    CREATE i18n_locale:⟨ur⟩ CONTENT { tag: "ur", language: "ur", script: NONE, region: NONE, name_en: "Urdu", name_native: "اردو", direction: "rtl", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ur-IN⟩) THEN (
    CREATE i18n_locale:⟨ur-IN⟩ CONTENT { tag: "ur-IN", language: "ur", script: NONE, region: "IN", name_en: "Urdu (India)", name_native: "اردو (بھارت)", direction: "rtl", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["ur"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨ur-PK⟩) THEN (
    CREATE i18n_locale:⟨ur-PK⟩ CONTENT { tag: "ur-PK", language: "ur", script: NONE, region: "PK", name_en: "Urdu (Pakistan)", name_native: "اردو (پاکستان)", direction: "rtl", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["ur"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨uz⟩) THEN (
    CREATE i18n_locale:⟨uz⟩ CONTENT { tag: "uz", language: "uz", script: NONE, region: NONE, name_en: "Uzbek", name_native: "o‘zbek", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨uz-Arab⟩) THEN (
    CREATE i18n_locale:⟨uz-Arab⟩ CONTENT { tag: "uz-Arab", language: "uz", script: "Arab", region: NONE, name_en: "Uzbek (Arabic)", name_native: "اوزبیک (عربی)", direction: "rtl", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨uz-Arab-AF⟩) THEN (
    CREATE i18n_locale:⟨uz-Arab-AF⟩ CONTENT { tag: "uz-Arab-AF", language: "uz", script: "Arab", region: "AF", name_en: "Uzbek (Arabic, Afghanistan)", name_native: "اوزبیک (عربی, افغانستان)", direction: "rtl", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["uz-Arab"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨uz-Cyrl⟩) THEN (
    CREATE i18n_locale:⟨uz-Cyrl⟩ CONTENT { tag: "uz-Cyrl", language: "uz", script: "Cyrl", region: NONE, name_en: "Uzbek (Cyrillic)", name_native: "ўзбекча (Кирил)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨uz-Cyrl-UZ⟩) THEN (
    CREATE i18n_locale:⟨uz-Cyrl-UZ⟩ CONTENT { tag: "uz-Cyrl-UZ", language: "uz", script: "Cyrl", region: "UZ", name_en: "Uzbek (Cyrillic, Uzbekistan)", name_native: "ўзбекча (Кирил, Ўзбекистон)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["uz-Cyrl"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨uz-Latn⟩) THEN (
    CREATE i18n_locale:⟨uz-Latn⟩ CONTENT { tag: "uz-Latn", language: "uz", script: "Latn", region: NONE, name_en: "Uzbek (Latin)", name_native: "o‘zbek (lotin)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["uz"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨uz-Latn-UZ⟩) THEN (
    CREATE i18n_locale:⟨uz-Latn-UZ⟩ CONTENT { tag: "uz-Latn-UZ", language: "uz", script: "Latn", region: "UZ", name_en: "Uzbek (Latin, Uzbekistan)", name_native: "o‘zbek (lotin, Oʻzbekiston)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["uz-Latn", "uz"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨vai⟩) THEN (
    CREATE i18n_locale:⟨vai⟩ CONTENT { tag: "vai", language: "vai", script: NONE, region: NONE, name_en: "Vai", name_native: "ꕙꔤ", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨vai-Latn⟩) THEN (
    CREATE i18n_locale:⟨vai-Latn⟩ CONTENT { tag: "vai-Latn", language: "vai", script: "Latn", region: NONE, name_en: "Vai (Latin)", name_native: "Vai (Latn)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨vai-Latn-LR⟩) THEN (
    CREATE i18n_locale:⟨vai-Latn-LR⟩ CONTENT { tag: "vai-Latn-LR", language: "vai", script: "Latn", region: "LR", name_en: "Vai (Latin, Liberia)", name_native: "Vai (Latn, Laibhiya)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["vai-Latn"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨vai-Vaii⟩) THEN (
    CREATE i18n_locale:⟨vai-Vaii⟩ CONTENT { tag: "vai-Vaii", language: "vai", script: "Vaii", region: NONE, name_en: "Vai (Vai)", name_native: "ꕙꔤ (Vaii)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["vai"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨vai-Vaii-LR⟩) THEN (
    CREATE i18n_locale:⟨vai-Vaii-LR⟩ CONTENT { tag: "vai-Vaii-LR", language: "vai", script: "Vaii", region: "LR", name_en: "Vai (Vai, Liberia)", name_native: "ꕙꔤ (Vaii, ꕞꔤꔫꕩ)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["vai-Vaii", "vai"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨vec⟩) THEN (
    CREATE i18n_locale:⟨vec⟩ CONTENT { tag: "vec", language: "vec", script: NONE, region: NONE, name_en: "Venetian", name_native: "veneto", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["many", "other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨vec-IT⟩) THEN (
    CREATE i18n_locale:⟨vec-IT⟩ CONTENT { tag: "vec-IT", language: "vec", script: NONE, region: "IT", name_en: "Venetian (Italy)", name_native: "veneto (Italia)", direction: "ltr", plural_cardinal: ["one", "many", "other"], plural_ordinal: ["many", "other"], fallback: ["vec"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨vi⟩) THEN (
    CREATE i18n_locale:⟨vi⟩ CONTENT { tag: "vi", language: "vi", script: NONE, region: NONE, name_en: "Vietnamese", name_native: "Tiếng Việt", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨vi-VN⟩) THEN (
    CREATE i18n_locale:⟨vi-VN⟩ CONTENT { tag: "vi-VN", language: "vi", script: NONE, region: "VN", name_en: "Vietnamese (Vietnam)", name_native: "Tiếng Việt (Việt Nam)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["one", "other"], fallback: ["vi"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨vmw⟩) THEN (
    CREATE i18n_locale:⟨vmw⟩ CONTENT { tag: "vmw", language: "vmw", script: NONE, region: NONE, name_en: "Makhuwa", name_native: "emakhuwa", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨vmw-MZ⟩) THEN (
    CREATE i18n_locale:⟨vmw-MZ⟩ CONTENT { tag: "vmw-MZ", language: "vmw", script: NONE, region: "MZ", name_en: "Makhuwa (Mozambique)", name_native: "emakhuwa (oMosambikhi)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["vmw"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨vun⟩) THEN (
    CREATE i18n_locale:⟨vun⟩ CONTENT { tag: "vun", language: "vun", script: NONE, region: NONE, name_en: "Vunjo", name_native: "Kyivunjo", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨vun-TZ⟩) THEN (
    CREATE i18n_locale:⟨vun-TZ⟩ CONTENT { tag: "vun-TZ", language: "vun", script: NONE, region: "TZ", name_en: "Vunjo (Tanzania)", name_native: "Kyivunjo (Tanzania)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["vun"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨wae⟩) THEN (
    CREATE i18n_locale:⟨wae⟩ CONTENT { tag: "wae", language: "wae", script: NONE, region: NONE, name_en: "Walser", name_native: "Walser", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨wae-CH⟩) THEN (
    CREATE i18n_locale:⟨wae-CH⟩ CONTENT { tag: "wae-CH", language: "wae", script: NONE, region: "CH", name_en: "Walser (Switzerland)", name_native: "Walser (Schwiz)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["wae"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨wo⟩) THEN (
    CREATE i18n_locale:⟨wo⟩ CONTENT { tag: "wo", language: "wo", script: NONE, region: NONE, name_en: "Wolof", name_native: "Wolof", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨wo-SN⟩) THEN (
    CREATE i18n_locale:⟨wo-SN⟩ CONTENT { tag: "wo-SN", language: "wo", script: NONE, region: "SN", name_en: "Wolof (Senegal)", name_native: "Wolof (Senegaal)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["wo"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨xh⟩) THEN (
    CREATE i18n_locale:⟨xh⟩ CONTENT { tag: "xh", language: "xh", script: NONE, region: NONE, name_en: "Xhosa", name_native: "IsiXhosa", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨xh-ZA⟩) THEN (
    CREATE i18n_locale:⟨xh-ZA⟩ CONTENT { tag: "xh-ZA", language: "xh", script: NONE, region: "ZA", name_en: "Xhosa (South Africa)", name_native: "IsiXhosa (EMzantsi Afrika)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["xh"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨xnr⟩) THEN (
    CREATE i18n_locale:⟨xnr⟩ CONTENT { tag: "xnr", language: "xnr", script: NONE, region: NONE, name_en: "Kangri", name_native: "कांगड़ी", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨xnr-IN⟩) THEN (
    CREATE i18n_locale:⟨xnr-IN⟩ CONTENT { tag: "xnr-IN", language: "xnr", script: NONE, region: "IN", name_en: "Kangri (India)", name_native: "कांगड़ी (भारत)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["xnr"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨xog⟩) THEN (
    CREATE i18n_locale:⟨xog⟩ CONTENT { tag: "xog", language: "xog", script: NONE, region: NONE, name_en: "Soga", name_native: "Olusoga", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨xog-UG⟩) THEN (
    CREATE i18n_locale:⟨xog-UG⟩ CONTENT { tag: "xog-UG", language: "xog", script: NONE, region: "UG", name_en: "Soga (Uganda)", name_native: "Olusoga (Yuganda)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["xog"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨yav⟩) THEN (
    CREATE i18n_locale:⟨yav⟩ CONTENT { tag: "yav", language: "yav", script: NONE, region: NONE, name_en: "Yangben", name_native: "nuasue", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨yav-CM⟩) THEN (
    CREATE i18n_locale:⟨yav-CM⟩ CONTENT { tag: "yav-CM", language: "yav", script: NONE, region: "CM", name_en: "Yangben (Cameroon)", name_native: "nuasue (Kemelún)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["yav"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨yi⟩) THEN (
    CREATE i18n_locale:⟨yi⟩ CONTENT { tag: "yi", language: "yi", script: NONE, region: NONE, name_en: "Yiddish", name_native: "ייִדיש", direction: "rtl", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨yi-UA⟩) THEN (
    CREATE i18n_locale:⟨yi-UA⟩ CONTENT { tag: "yi-UA", language: "yi", script: NONE, region: "UA", name_en: "Yiddish (Ukraine)", name_native: "ייִדיש (אוקראַינע)", direction: "rtl", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["yi"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨yo⟩) THEN (
    CREATE i18n_locale:⟨yo⟩ CONTENT { tag: "yo", language: "yo", script: NONE, region: NONE, name_en: "Yoruba", name_native: "Èdè Yorùbá", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨yo-BJ⟩) THEN (
    CREATE i18n_locale:⟨yo-BJ⟩ CONTENT { tag: "yo-BJ", language: "yo", script: NONE, region: "BJ", name_en: "Yoruba (Benin)", name_native: "Èdè Yorùbá (Bɛ̀nɛ̀)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["yo"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨yo-NG⟩) THEN (
    CREATE i18n_locale:⟨yo-NG⟩ CONTENT { tag: "yo-NG", language: "yo", script: NONE, region: "NG", name_en: "Yoruba (Nigeria)", name_native: "Èdè Yorùbá (Nàìjíríà)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["yo"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨yrl⟩) THEN (
    CREATE i18n_locale:⟨yrl⟩ CONTENT { tag: "yrl", language: "yrl", script: NONE, region: NONE, name_en: "Nheengatu", name_native: "nheẽgatu", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨yrl-BR⟩) THEN (
    CREATE i18n_locale:⟨yrl-BR⟩ CONTENT { tag: "yrl-BR", language: "yrl", script: NONE, region: "BR", name_en: "Nheengatu (Brazil)", name_native: "nheẽgatu (Brasiu)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["yrl"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨yrl-CO⟩) THEN (
    CREATE i18n_locale:⟨yrl-CO⟩ CONTENT { tag: "yrl-CO", language: "yrl", script: NONE, region: "CO", name_en: "Nheengatu (Colombia)", name_native: "ñengatú (Kurũbiya)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["yrl"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨yrl-VE⟩) THEN (
    CREATE i18n_locale:⟨yrl-VE⟩ CONTENT { tag: "yrl-VE", language: "yrl", script: NONE, region: "VE", name_en: "Nheengatu (Venezuela)", name_native: "ñengatú (Wenesuera)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["yrl"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨yue⟩) THEN (
    CREATE i18n_locale:⟨yue⟩ CONTENT { tag: "yue", language: "yue", script: NONE, region: NONE, name_en: "Cantonese", name_native: "粵語", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨yue-Hans⟩) THEN (
    CREATE i18n_locale:⟨yue-Hans⟩ CONTENT { tag: "yue-Hans", language: "yue", script: "Hans", region: NONE, name_en: "Cantonese (Simplified)", name_native: "粤语 (简体)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨yue-Hans-CN⟩) THEN (
    CREATE i18n_locale:⟨yue-Hans-CN⟩ CONTENT { tag: "yue-Hans-CN", language: "yue", script: "Hans", region: "CN", name_en: "Cantonese (Simplified, China)", name_native: "粤语 (简体，中国)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["yue-Hans"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨yue-Hant⟩) THEN (
    CREATE i18n_locale:⟨yue-Hant⟩ CONTENT { tag: "yue-Hant", language: "yue", script: "Hant", region: NONE, name_en: "Cantonese (Traditional)", name_native: "粵語 (繁體)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["yue"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨yue-Hant-CN⟩) THEN (
    CREATE i18n_locale:⟨yue-Hant-CN⟩ CONTENT { tag: "yue-Hant-CN", language: "yue", script: "Hant", region: "CN", name_en: "Cantonese (Traditional, China)", name_native: "粵語 (繁體，中國)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["yue-Hant", "yue"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨yue-Hant-HK⟩) THEN (
    CREATE i18n_locale:⟨yue-Hant-HK⟩ CONTENT { tag: "yue-Hant-HK", language: "yue", script: "Hant", region: "HK", name_en: "Cantonese (Traditional, Hong Kong SAR China)", name_native: "粵語 (繁體，中國香港特別行政區)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["yue-Hant", "yue"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨yue-Hant-MO⟩) THEN (
    CREATE i18n_locale:⟨yue-Hant-MO⟩ CONTENT { tag: "yue-Hant-MO", language: "yue", script: "Hant", region: "MO", name_en: "Cantonese (Traditional, Macao SAR China)", name_native: "粵語 (繁體，中國澳門特別行政區)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["yue-Hant", "yue"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨za⟩) THEN (
    CREATE i18n_locale:⟨za⟩ CONTENT { tag: "za", language: "za", script: NONE, region: NONE, name_en: "Zhuang", name_native: "Vahcuengh", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨za-CN⟩) THEN (
    CREATE i18n_locale:⟨za-CN⟩ CONTENT { tag: "za-CN", language: "za", script: NONE, region: "CN", name_en: "Zhuang (China)", name_native: "Vahcuengh (Cunghgoz)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["za"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨zgh⟩) THEN (
    CREATE i18n_locale:⟨zgh⟩ CONTENT { tag: "zgh", language: "zgh", script: NONE, region: NONE, name_en: "Standard Moroccan Tamazight", name_native: "ⵜⴰⵎⴰⵣⵉⵖⵜ", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨zgh-MA⟩) THEN (
    CREATE i18n_locale:⟨zgh-MA⟩ CONTENT { tag: "zgh-MA", language: "zgh", script: NONE, region: "MA", name_en: "Standard Moroccan Tamazight (Morocco)", name_native: "ⵜⴰⵎⴰⵣⵉⵖⵜ (ⵍⵎⵖⵔⵉⴱ)", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["zgh"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨zh⟩) THEN (
    CREATE i18n_locale:⟨zh⟩ CONTENT { tag: "zh", language: "zh", script: NONE, region: NONE, name_en: "Chinese", name_native: "中文", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨zh-Hans⟩) THEN (
    CREATE i18n_locale:⟨zh-Hans⟩ CONTENT { tag: "zh-Hans", language: "zh", script: "Hans", region: NONE, name_en: "Simplified Chinese", name_native: "简体中文", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["zh"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨zh-Hans-CN⟩) THEN (
    CREATE i18n_locale:⟨zh-Hans-CN⟩ CONTENT { tag: "zh-Hans-CN", language: "zh", script: "Hans", region: "CN", name_en: "Chinese (Simplified, China)", name_native: "中文（简体，中国）", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["zh-Hans", "zh"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨zh-Hans-HK⟩) THEN (
    CREATE i18n_locale:⟨zh-Hans-HK⟩ CONTENT { tag: "zh-Hans-HK", language: "zh", script: "Hans", region: "HK", name_en: "Chinese (Simplified, Hong Kong SAR China)", name_native: "中文（简体，中国香港特别行政区）", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["zh-Hans", "zh"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨zh-Hans-MO⟩) THEN (
    CREATE i18n_locale:⟨zh-Hans-MO⟩ CONTENT { tag: "zh-Hans-MO", language: "zh", script: "Hans", region: "MO", name_en: "Chinese (Simplified, Macao SAR China)", name_native: "中文（简体，中国澳门特别行政区）", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["zh-Hans", "zh"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨zh-Hans-MY⟩) THEN (
    CREATE i18n_locale:⟨zh-Hans-MY⟩ CONTENT { tag: "zh-Hans-MY", language: "zh", script: "Hans", region: "MY", name_en: "Chinese (Simplified, Malaysia)", name_native: "中文（简体，马来西亚）", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["zh-Hans", "zh"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨zh-Hans-SG⟩) THEN (
    CREATE i18n_locale:⟨zh-Hans-SG⟩ CONTENT { tag: "zh-Hans-SG", language: "zh", script: "Hans", region: "SG", name_en: "Chinese (Simplified, Singapore)", name_native: "中文（简体，新加坡）", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["zh-Hans", "zh"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨zh-Hant⟩) THEN (
    CREATE i18n_locale:⟨zh-Hant⟩ CONTENT { tag: "zh-Hant", language: "zh", script: "Hant", region: NONE, name_en: "Traditional Chinese", name_native: "繁體中文", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨zh-Hant-HK⟩) THEN (
    CREATE i18n_locale:⟨zh-Hant-HK⟩ CONTENT { tag: "zh-Hant-HK", language: "zh", script: "Hant", region: "HK", name_en: "Chinese (Traditional, Hong Kong SAR China)", name_native: "中文（繁體字，中國香港特別行政區）", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["zh-Hant"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨zh-Hant-MO⟩) THEN (
    CREATE i18n_locale:⟨zh-Hant-MO⟩ CONTENT { tag: "zh-Hant-MO", language: "zh", script: "Hant", region: "MO", name_en: "Chinese (Traditional, Macao SAR China)", name_native: "中文（繁體字，中國澳門特別行政區）", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["zh-Hant-HK", "zh-Hant"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨zh-Hant-MY⟩) THEN (
    CREATE i18n_locale:⟨zh-Hant-MY⟩ CONTENT { tag: "zh-Hant-MY", language: "zh", script: "Hant", region: "MY", name_en: "Chinese (Traditional, Malaysia)", name_native: "中文（繁體，馬來西亞）", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["zh-Hant"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨zh-Hant-TW⟩) THEN (
    CREATE i18n_locale:⟨zh-Hant-TW⟩ CONTENT { tag: "zh-Hant-TW", language: "zh", script: "Hant", region: "TW", name_en: "Chinese (Traditional, Taiwan)", name_native: "中文（繁體，台灣）", direction: "ltr", plural_cardinal: ["other"], plural_ordinal: ["other"], fallback: ["zh-Hant"], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨zu⟩) THEN (
    CREATE i18n_locale:⟨zu⟩ CONTENT { tag: "zu", language: "zu", script: NONE, region: NONE, name_en: "Zulu", name_native: "isiZulu", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: [], active: false, cldr_version: "49" }
) END;
IF !record::exists(i18n_locale:⟨zu-ZA⟩) THEN (
    CREATE i18n_locale:⟨zu-ZA⟩ CONTENT { tag: "zu-ZA", language: "zu", script: NONE, region: "ZA", name_en: "Zulu (South Africa)", name_native: "isiZulu (iNingizimu Afrika)", direction: "ltr", plural_cardinal: ["one", "other"], plural_ordinal: ["other"], fallback: ["zu"], active: false, cldr_version: "49" }
) END;
