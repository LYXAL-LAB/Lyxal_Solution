-- =============================================================================================
-- |
-- | Fichier     : i18n_language_seed.surql
-- | Module      : i18n
-- | Description : Peuple la table language avec une liste exhaustive de langues.
-- |                Utilise exclusivement la fonction fn::create_language.
-- |
-- =============================================================================================
BEGIN;
-- ============================================================================
-- Langues principales
-- ============================================================================

-- Français
fn::create_language("fr", "French", "Français", "ltr", true, "flag_fr", "language_fr_name", false, "");

-- Anglais
fn::create_language("en", "English", "English", "ltr", true, "flag_gb", "language_en_name", false, "");

-- Espagnol
fn::create_language("es", "Spanish", "Español", "ltr", true, "flag_es", "language_es_name", false, "");

-- Allemand
fn::create_language("de", "German", "Deutsch", "ltr", true, "flag_de", "language_de_name", false, "");

-- Italien
fn::create_language("it", "Italian", "Italiano", "ltr", true, "flag_it", "language_it_name", false, "");

-- ============================================================================
-- Langues supplémentaires (A-Z)
-- ============================================================================

-- Afar
fn::create_language("aa", "Afar", "Afaraf", "ltr", false, "flag_dj", "language_aa_name", false, "");

-- Abkhaz
fn::create_language("ab", "Abkhaz", "аҧсуа бызшәа", "ltr", false, "flag_ge", "language_ab_name", false, "");

-- Avestan
fn::create_language("ae", "Avestan", "avesta", "ltr", false, "flag_ir", "language_ae_name", false, "");

-- Afrikaans
fn::create_language("af", "Afrikaans", "Afrikaans", "ltr", false, "flag_za", "language_af_name", false, "");

-- Akan
fn::create_language("ak", "Akan", "Akan", "ltr", false, "flag_gh", "language_ak_name", false, "");

-- Amharic
fn::create_language("am", "Amharic", "አማርኛ", "ltr", false, "flag_et", "language_am_name", false, "");

-- Aragonese
fn::create_language("an", "Aragonese", "aragonés", "ltr", false, "flag_es", "language_an_name", false, "");

-- Arabic
fn::create_language("ar", "Arabic", "العربية", "rtl", true, "flag_sa", "language_ar_name", false, "");

-- Assamese
fn::create_language("as", "Assamese", "অসমীয়া", "ltr", false, "flag_in", "language_as_name", false, "");

-- Avaric
fn::create_language("av", "Avaric", "авар мацӀ", "ltr", false, "flag_ru", "language_av_name", false, "");

-- Aymara
fn::create_language("ay", "Aymara", "aymar aru", "ltr", false, "flag_bo", "language_ay_name", false, "");

-- Azerbaijani
fn::create_language("az", "Azerbaijani", "azərbaycan dili", "ltr", false, "flag_az", "language_az_name", false, "");

-- Bashkir
fn::create_language("ba", "Bashkir", "башҡорт теле", "ltr", false, "flag_ru", "language_ba_name", false, "");

-- Belarusian
fn::create_language("be", "Belarusian", "беларуская мова", "ltr", false, "flag_by", "language_be_name", false, "");

-- Bulgarian
fn::create_language("bg", "Bulgarian", "български език", "ltr", false, "flag_bg", "language_bg_name", false, "");

-- Bihari
fn::create_language("bh", "Bihari", "भोजपुरी", "ltr", false, "flag_in", "language_bh_name", false, "");

-- Bislama
fn::create_language("bi", "Bislama", "Bislama", "ltr", false, "flag_vu", "language_bi_name", false, "");

-- Bambara
fn::create_language("bm", "Bambara", "bamanankan", "ltr", false, "flag_ml", "language_bm_name", false, "");

-- Bengali
fn::create_language("bn", "Bengali", "বাংলা", "ltr", false, "flag_bd", "language_bn_name", false, "");

-- Tibetan
fn::create_language("bo", "Tibetan", "བོད་ཡིག", "ltr", false, "flag_cn", "language_bo_name", false, "");

-- Breton
fn::create_language("br", "Breton", "brezhoneg", "ltr", false, "flag_fr", "language_br_name", false, "");

-- Bosnian
fn::create_language("bs", "Bosnian", "bosanski jezik", "ltr", false, "flag_ba", "language_bs_name", false, "");

-- Catalan
fn::create_language("ca", "Catalan", "català", "ltr", false, "flag_es_ct", "language_ca_name", false, "");

-- Chechen
fn::create_language("ce", "Chechen", "нохчийн мотт", "ltr", false, "flag_ru", "language_ce_name", false, "");

-- Chamorro
fn::create_language("ch", "Chamorro", "Chamoru", "ltr", false, "flag_gu", "language_ch_name", false, "");

-- Corsican
fn::create_language("co", "Corsican", "corsu", "ltr", false, "flag_fr", "language_co_name", false, "");

-- Cree
fn::create_language("cr", "Cree", "ᓀᐦᐃᔭᐍᐏᐣ", "ltr", false, "flag_ca", "language_cr_name", false, "");

-- Czech
fn::create_language("cs", "Czech", "čeština", "ltr", false, "flag_cz", "language_cs_name", false, "");

-- Old Church Slavonic
fn::create_language("cu", "Old Church Slavonic", "ѩзыкъ словѣньскъ", "ltr", false, "flag_ru", "language_cu_name", false, "");

-- Chuvash
fn::create_language("cv", "Chuvash", "чӑваш чӗлхи", "ltr", false, "flag_ru", "language_cv_name", false, "");

-- Welsh
fn::create_language("cy", "Welsh", "Cymraeg", "ltr", false, "flag_gb_wls", "language_cy_name", false, "");

-- Danish
fn::create_language("da", "Danish", "dansk", "ltr", true, "flag_dk", "language_da_name", false, "");

-- Divehi
fn::create_language("dv", "Divehi", "ދިވެހި", "rtl", false, "flag_mv", "language_dv_name", false, "");

-- Dzongkha
fn::create_language("dz", "Dzongkha", "རྫོང་ཁ", "ltr", false, "flag_bt", "language_dz_name", false, "");

-- Ewe
fn::create_language("ee", "Ewe", "Eʋegbe", "ltr", false, "flag_gh", "language_ee_name", false, "");

-- Greek
fn::create_language("el", "Greek", "Ελληνικά", "ltr", true, "flag_gr", "language_el_name", false, "");

-- Esperanto
fn::create_language("eo", "Esperanto", "Esperanto", "ltr", false, "flag_eu", "language_eo_name", false, "");

-- Estonian
fn::create_language("et", "Estonian", "eesti", "ltr", false, "flag_ee", "language_et_name", false, "");

-- Basque
fn::create_language("eu", "Basque", "euskara", "ltr", false, "flag_es_pv", "language_eu_name", false, "");

-- Persian
fn::create_language("fa", "Persian", "فارسی", "rtl", false, "flag_ir", "language_fa_name", false, "");

-- Fula
fn::create_language("ff", "Fula", "Fulfulde", "ltr", false, "flag_sn", "language_ff_name", false, "");

-- Finnish
fn::create_language("fi", "Finnish", "suomi", "ltr", false, "flag_fi", "language_fi_name", false, "");

-- Fijian
fn::create_language("fj", "Fijian", "vosa Vakaviti", "ltr", false, "flag_fj", "language_fj_name", false, "");

-- Faroese
fn::create_language("fo", "Faroese", "føroyskt", "ltr", false, "flag_fo", "language_fo_name", false, "");

-- Western Frisian
fn::create_language("fy", "Western Frisian", "Frysk", "ltr", false, "flag_nl", "language_fy_name", false, "");

-- Irish
fn::create_language("ga", "Irish", "Gaeilge", "ltr", false, "flag_ie", "language_ga_name", false, "");

-- Scottish Gaelic
fn::create_language("gd", "Scottish Gaelic", "Gàidhlig", "ltr", false, "flag_gb_sct", "language_gd_name", false, "");

-- Galician
fn::create_language("gl", "Galician", "galego", "ltr", false, "flag_es_ga", "language_gl_name", false, "");

-- Guaraní
fn::create_language("gn", "Guaraní", "Avañeẽ", "ltr", false, "flag_py", "language_gn_name", false, "");

-- Gujarati
fn::create_language("gu", "Gujarati", "ગુજરાતી", "ltr", false, "flag_in", "language_gu_name", false, "");

-- Manx
fn::create_language("gv", "Manx", "Gaelg", "ltr", false, "flag_im", "language_gv_name", false, "");

-- Hausa
fn::create_language("ha", "Hausa", "هَوُسَ", "rtl", false, "flag_ng", "language_ha_name", false, "");

-- Hebrew
fn::create_language("he", "Hebrew", "עברית", "rtl", false, "flag_il", "language_he_name", false, "");

-- Hindi
fn::create_language("hi", "Hindi", "हिन्दी", "ltr", false, "flag_in", "language_hi_name", false, "");

-- Hiri Motu
fn::create_language("ho", "Hiri Motu", "Hiri Motu", "ltr", false, "flag_pg", "language_ho_name", false, "");

-- Croatian
fn::create_language("hr", "Croatian", "hrvatski jezik", "ltr", false, "flag_hr", "language_hr_name", false, "");

-- Haitian
fn::create_language("ht", "Haitian", "Kreyòl ayisyen", "ltr", false, "flag_ht", "language_ht_name", false, "");

-- Hungarian
fn::create_language("hu", "Hungarian", "magyar", "ltr", true, "flag_hu", "language_hu_name", false, "");

-- Armenian
fn::create_language("hy", "Armenian", "Հայերեն", "ltr", false, "flag_am", "language_hy_name", false, "");

-- Herero
fn::create_language("hz", "Herero", "Otjiherero", "ltr", false, "flag_na", "language_hz_name", false, "");

-- Interlingua
fn::create_language("ia", "Interlingua", "Interlingua", "ltr", false, "flag_eu", "language_ia_name", false, "");

-- Indonesian
fn::create_language("id", "Indonesian", "Bahasa Indonesia", "ltr", false, "flag_id", "language_id_name", false, "");

-- Interlingue
fn::create_language("ie", "Interlingue", "Interlingue", "ltr", false, "flag_eu", "language_ie_name", false, "");

-- Igbo
fn::create_language("ig", "Igbo", "Asụsụ Igbo", "ltr", false, "flag_ng", "language_ig_name", false, "");

-- Sichuan Yi
fn::create_language("ii", "Sichuan Yi", "ꆈꌠ꒿ Nuosuhxop", "ltr", false, "flag_cn", "language_ii_name", false, "");

-- Inupiaq
fn::create_language("ik", "Inupiaq", "Iñupiaq", "ltr", false, "flag_us", "language_ik_name", false, "");

-- Ido
fn::create_language("io", "Ido", "Ido", "ltr", false, "flag_eu", "language_io_name", false, "");

-- Icelandic
fn::create_language("is", "Icelandic", "Íslenska", "ltr", false, "flag_is", "language_is_name", false, "");

-- Inuktitut
fn::create_language("iu", "Inuktitut", "ᐃᓄᒃᑎᑐᑦ", "ltr", false, "flag_ca", "language_iu_name", false, "");

-- Japanese
fn::create_language("ja", "Japanese", "日本語", "ltr", false, "flag_jp", "language_ja_name", false, "");

-- Javanese
fn::create_language("jv", "Javanese", "basa Jawa", "ltr", false, "flag_id", "language_jv_name", false, "");

-- Georgian
fn::create_language("ka", "Georgian", "ქართული", "ltr", false, "flag_ge", "language_ka_name", false, "");

-- Kongo
fn::create_language("kg", "Kongo", "KiKongo", "ltr", false, "flag_cd", "language_kg_name", false, "");

-- Kikuyu
fn::create_language("ki", "Kikuyu", "Gĩkũyũ", "ltr", false, "flag_ke", "language_ki_name", false, "");

-- Kwanyama
fn::create_language("kj", "Kwanyama", "Kuanyama", "ltr", false, "flag_ao", "language_kj_name", false, "");

-- Kazakh
fn::create_language("kk", "Kazakh", "қазақ тілі", "ltr", false, "flag_kz", "language_kk_name", false, "");

-- Kalaallisut
fn::create_language("kl", "Kalaallisut", "kalaallisut", "ltr", false, "flag_gl", "language_kl_name", false, "");

-- Khmer
fn::create_language("km", "Khmer", "ខ្មែរ", "ltr", false, "flag_kh", "language_km_name", false, "");

-- Kannada
fn::create_language("kn", "Kannada", "ಕನ್ನಡ", "ltr", false, "flag_in", "language_kn_name", false, "");

-- Korean
fn::create_language("ko", "Korean", "한국어", "ltr", false, "flag_kr", "language_ko_name", false, "");

-- Kanuri
fn::create_language("kr", "Kanuri", "Kanuri", "ltr", false, "flag_ng", "language_kr_name", false, "");

-- Kashmiri
fn::create_language("ks", "Kashmiri", "कश्मीरी", "rtl", false, "flag_in", "language_ks_name", false, "");

-- Kurdish
fn::create_language("ku", "Kurdish", "Kurdî", "rtl", false, "flag_ir", "language_ku_name", false, "");

-- Komi
fn::create_language("kv", "Komi", "коми кыв", "ltr", false, "flag_ru", "language_kv_name", false, "");

-- Cornish
fn::create_language("kw", "Cornish", "Kernewek", "ltr", false, "flag_gb", "language_kw_name", false, "");

-- Kyrgyz
fn::create_language("ky", "Kyrgyz", "Кыргызча", "ltr", false, "flag_kg", "language_ky_name", false, "");

-- Latin
fn::create_language("la", "Latin", "latine", "ltr", false, "flag_va", "language_la_name", false, "");

-- Luxembourgish
fn::create_language("lb", "Luxembourgish", "Lëtzebuergesch", "ltr", false, "flag_lu", "language_lb_name", false, "");

-- Ganda
fn::create_language("lg", "Ganda", "Luganda", "ltr", false, "flag_ug", "language_lg_name", false, "");

-- Limburgish
fn::create_language("li", "Limburgish", "Limburgs", "ltr", false, "flag_nl", "language_li_name", false, "");

-- Lingala
fn::create_language("ln", "Lingala", "Lingála", "ltr", false, "flag_cd", "language_ln_name", false, "");

-- Lao
fn::create_language("lo", "Lao", "ພາສາລາວ", "ltr", false, "flag_la", "language_lo_name", false, "");

-- Lithuanian
fn::create_language("lt", "Lithuanian", "lietuvių kalba", "ltr", false, "flag_lt", "language_lt_name", false, "");

-- Luba-Katanga
fn::create_language("lu", "Luba-Katanga", "Tshiluba", "ltr", false, "flag_cd", "language_lu_name", false, "");

-- Latvian
fn::create_language("lv", "Latvian", "latviešu valoda", "ltr", false, "flag_lv", "language_lv_name", false, "");

-- Malagasy
fn::create_language("mg", "Malagasy", "Malagasy", "ltr", false, "flag_mg", "language_mg_name", false, "");

-- Marshallese
fn::create_language("mh", "Marshallese", "Kajin M̧ajeļ", "ltr", false, "flag_mh", "language_mh_name", false, "");

-- Māori
fn::create_language("mi", "Māori", "te reo Māori", "ltr", false, "flag_nz", "language_mi_name", false, "");

-- Macedonian
fn::create_language("mk", "Macedonian", "македонски јазик", "ltr", false, "flag_mk", "language_mk_name", false, "");

-- Malayalam
fn::create_language("ml", "Malayalam", "മലയാളം", "ltr", false, "flag_in", "language_ml_name", false, "");

-- Mongolian
fn::create_language("mn", "Mongolian", "монгол", "ltr", false, "flag_mn", "language_mn_name", false, "");

-- Marathi
fn::create_language("mr", "Marathi", "मराठी", "ltr", false, "flag_in", "language_mr_name", false, "");

-- Malay
fn::create_language("ms", "Malay", "bahasa Melayu", "ltr", false, "flag_my", "language_ms_name", false, "");

-- Maltese
fn::create_language("mt", "Maltese", "Malti", "ltr", false, "flag_mt", "language_mt_name", false, "");

-- Burmese
fn::create_language("my", "Burmese", "ဗမာစာ", "ltr", false, "flag_mm", "language_my_name", false, "");

-- Nauru
fn::create_language("na", "Nauru", "Ekakairũ Naoero", "ltr", false, "flag_nr", "language_na_name", false, "");

-- Norwegian Bokmål
fn::create_language("nb", "Norwegian Bokmål", "Norsk bokmål", "ltr", true, "flag_no", "language_nb_name", false, "");

-- Northern Ndebele
fn::create_language("nd", "Northern Ndebele", "isiNdebele", "ltr", false, "flag_zw", "language_nd_name", false, "");

-- Nepali
fn::create_language("ne", "Nepali", "नेपाली", "ltr", false, "flag_np", "language_ne_name", false, "");

-- Ndonga
fn::create_language("ng", "Ndonga", "Owambo", "ltr", false, "flag_na", "language_ng_name", false, "");

-- Dutch
fn::create_language("nl", "Dutch", "Nederlands", "ltr", true, "flag_nl", "language_nl_name", false, "");

-- Norwegian Nynorsk
fn::create_language("nn", "Norwegian Nynorsk", "Norsk nynorsk", "ltr", true, "flag_no", "language_nn_name", false, "");

-- Norwegian
fn::create_language("no", "Norwegian", "Norsk", "ltr", true, "flag_no", "language_no_name", false, "");

-- Southern Ndebele
fn::create_language("nr", "Southern Ndebele", "isiNdebele", "ltr", false, "flag_za", "language_nr_name", false, "");

-- Navajo
fn::create_language("nv", "Navajo", "Diné bizaad", "ltr", false, "flag_us", "language_nv_name", false, "");

-- Chichewa
fn::create_language("ny", "Chichewa", "chiCheŵa", "ltr", false, "flag_mw", "language_ny_name", false, "");

-- Occitan
fn::create_language("oc", "Occitan", "occitan", "ltr", false, "flag_fr", "language_oc_name", false, "");

-- Ojibwe
fn::create_language("oj", "Ojibwe", "ᐊᓂᔑᓈᐯᒧᐎᓐ", "ltr", false, "flag_ca", "language_oj_name", false, "");

-- Oromo
fn::create_language("om", "Oromo", "Afaan Oromoo", "ltr", false, "flag_et", "language_om_name", false, "");

-- Oriya
fn::create_language("or", "Oriya", "ଓଡ଼ିଆ", "ltr", false, "flag_in", "language_or_name", false, "");

-- Ossetian
fn::create_language("os", "Ossetian", "ирон æвзаг", "ltr", false, "flag_ru", "language_os_name", false, "");

-- Panjabi
fn::create_language("pa", "Panjabi", "ਪੰਜਾਬੀ", "ltr", false, "flag_in", "language_pa_name", false, "");

-- Pāli
fn::create_language("pi", "Pāli", "पाऴि", "ltr", false, "flag_in", "language_pi_name", false, "");

-- Polish
fn::create_language("pl", "Polish", "język polski", "ltr", false, "flag_pl", "language_pl_name", false, "");

-- Pashto
fn::create_language("ps", "Pashto", "پښتو", "rtl", false, "flag_af", "language_ps_name", false, "");

-- Portuguese
fn::create_language("pt", "Portuguese", "Português", "ltr", true, "flag_pt", "language_pt_name", false, "");

-- Quechua
fn::create_language("qu", "Quechua", "Runa Simi", "ltr", false, "flag_pe", "language_qu_name", false, "");

-- Romansh
fn::create_language("rm", "Romansh", "rumantsch grischun", "ltr", false, "flag_ch", "language_rm_name", false, "");

-- Kirundi
fn::create_language("rn", "Kirundi", "Ikirundi", "ltr", false, "flag_bi", "language_rn_name", false, "");

-- Romanian
fn::create_language("ro", "Romanian", "limba română", "ltr", true, "flag_ro", "language_ro_name", false, "");

-- Russian
fn::create_language("ru", "Russian", "русский язык", "ltr", true, "flag_ru", "language_ru_name", false, "");

-- Kinyarwanda
fn::create_language("rw", "Kinyarwanda", "Ikinyarwanda", "ltr", false, "flag_rw", "language_rw_name", false, "");

-- Sanskrit
fn::create_language("sa", "Sanskrit", "संस्कृतम्", "ltr", false, "flag_in", "language_sa_name", false, "");

-- Sardinian
fn::create_language("sc", "Sardinian", "sardu", "ltr", false, "flag_it", "language_sc_name", false, "");

-- Sindhi
fn::create_language("sd", "Sindhi", "सिन्धी", "rtl", false, "flag_pk", "language_sd_name", false, "");

-- Northern Sami
fn::create_language("se", "Northern Sami", "Davvisámegiella", "ltr", false, "flag_no", "language_se_name", false, "");

-- Sango
fn::create_language("sg", "Sango", "yângâ tî sängö", "ltr", false, "flag_cf", "language_sg_name", false, "");

-- Sinhala
fn::create_language("si", "Sinhala", "සිංහල", "ltr", false, "flag_lk", "language_si_name", false, "");

-- Slovak
fn::create_language("sk", "Slovak", "slovenčina", "ltr", false, "flag_sk", "language_sk_name", false, "");

-- Slovene
fn::create_language("sl", "Slovene", "slovenski jezik", "ltr", false, "flag_si", "language_sl_name", false, "");

-- Samoan
fn::create_language("sm", "Samoan", "gagana faa Samoa", "ltr", false, "flag_ws", "language_sm_name", false, "");

-- Shona
fn::create_language("sn", "Shona", "chiShona", "ltr", false, "flag_zw", "language_sn_name", false, "");

-- Somali
fn::create_language("so", "Somali", "Soomaaliga", "ltr", false, "flag_so", "language_so_name", false, "");

-- Albanian
fn::create_language("sq", "Albanian", "Shqip", "ltr", false, "flag_al", "language_sq_name", false, "");

-- Serbian
fn::create_language("sr", "Serbian", "српски језик", "ltr", false, "flag_rs", "language_sr_name", false, "");

-- Swati
fn::create_language("ss", "Swati", "SiSwati", "ltr", false, "flag_sz", "language_ss_name", false, "");

-- Southern Sotho
fn::create_language("st", "Southern Sotho", "Sesotho", "ltr", false, "flag_ls", "language_st_name", false, "");

-- Sundanese
fn::create_language("su", "Sundanese", "Basa Sunda", "ltr", false, "flag_id", "language_su_name", false, "");

-- Swedish
fn::create_language("sv", "Swedish", "svenska", "ltr", true, "flag_se", "language_sv_name", false, "");

-- Swahili
fn::create_language("sw", "Swahili", "Kiswahili", "ltr", false, "flag_tz", "language_sw_name", false, "");

-- Tamil
fn::create_language("ta", "Tamil", "தமிழ்", "ltr", true, "flag_in", "language_ta_name", false, "");

-- Telugu
fn::create_language("te", "Telugu", "తెలుగు", "ltr", false, "flag_in", "language_te_name", false, "");

-- Tajik
fn::create_language("tg", "Tajik", "тоҷикӣ", "ltr", false, "flag_tj", "language_tg_name", false, "");

-- Thai
fn::create_language("th", "Thai", "ไทย", "ltr", false, "flag_th", "language_th_name", false, "");

-- Tigrinya
fn::create_language("ti", "Tigrinya", "ትግርኛ", "ltr", false, "flag_er", "language_ti_name", false, "");

-- Turkmen
fn::create_language("tk", "Turkmen", "Türkmen", "ltr", false, "flag_tm", "language_tk_name", false, "");

-- Tagalog
fn::create_language("tl", "Tagalog", "Wikang Tagalog", "ltr", false, "flag_ph", "language_tl_name", false, "");

-- Tswana
fn::create_language("tn", "Tswana", "Setswana", "ltr", false, "flag_bw", "language_tn_name", false, "");

-- Tonga
fn::create_language("to", "Tonga", "faka Tonga", "ltr", false, "flag_to", "language_to_name", false, "");

-- Turkish
fn::create_language("tr", "Turkish", "Türkçe", "ltr", true, "flag_tr", "language_tr_name", false, "");

-- Tsonga
fn::create_language("ts", "Tsonga", "Xitsonga", "ltr", false, "flag_za", "language_ts_name", false, "");

-- Tatar
fn::create_language("tt", "Tatar", "татар теле", "ltr", false, "flag_ru", "language_tt_name", false, "");

-- Twi
fn::create_language("tw", "Twi", "Twi", "ltr", false, "flag_gh", "language_tw_name", false, "");

-- Tahitian
fn::create_language("ty", "Tahitian", "Reo Tahiti", "ltr", false, "flag_pf", "language_ty_name", false, "");

-- Uyghur
fn::create_language("ug", "Uyghur", "ئۇيغۇرچە‎", "rtl", false, "flag_cn", "language_ug_name", false, "");

-- Ukrainian
fn::create_language("uk", "Ukrainian", "українська мова", "ltr", false, "flag_ua", "language_uk_name", false, "");

-- Urdu
fn::create_language("ur", "Urdu", "اردو", "rtl", false, "flag_pk", "language_ur_name", false, "");

-- Uzbek
fn::create_language("uz", "Uzbek", "Oʻzbek", "ltr", false, "flag_uz", "language_uz_name", false, "");

-- Venda
fn::create_language("ve", "Venda", "Tshivenḓa", "ltr", false, "flag_za", "language_ve_name", false, "");

-- Vietnamese
fn::create_language("vi", "Vietnamese", "Tiếng Việt", "ltr", false, "flag_vn", "language_vi_name", false, "");

-- Volapük
fn::create_language("vo", "Volapük", "Volapük", "ltr", false, "flag_eu", "language_vo_name", false, "");

-- Walloon
fn::create_language("wa", "Walloon", "walon", "ltr", false, "flag_be", "language_wa_name", false, "");

-- Wolof
fn::create_language("wo", "Wolof", "Wollof", "ltr", false, "flag_sn", "language_wo_name", false, "");

-- Xhosa
fn::create_language("xh", "Xhosa", "isiXhosa", "ltr", false, "flag_za", "language_xh_name", false, "");

-- Yiddish
fn::create_language("yi", "Yiddish", "ייִדיש", "rtl", false, "flag_il", "language_yi_name", false, "");

-- Yoruba
fn::create_language("yo", "Yoruba", "Yorùbá", "ltr", false, "flag_ng", "language_yo_name", false, "");

-- Zhuang
fn::create_language("za", "Zhuang", "Saɯ cueŋƅ", "ltr", false, "flag_cn", "language_za_name", false, "");

-- Chinese
fn::create_language("zh", "Chinese", "中文", "ltr", false, "flag_cn", "language_zh_name", false, "");

-- Zulu
fn::create_language("zu", "Zulu", "isiZulu", "ltr", false, "flag_za", "language_zu_name", false, "");

COMMIT;