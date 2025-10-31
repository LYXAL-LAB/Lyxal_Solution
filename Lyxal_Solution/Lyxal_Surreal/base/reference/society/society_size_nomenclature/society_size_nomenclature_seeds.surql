-- =====================================================
-- NOMENCLATURES DE TAILLE - COUVERTURE MONDIALE COMPLÈTE
-- =====================================================
-- 195 pays + 4 organisations internationales
-- =====================================================

-- =====================================================
-- NOMENCLATURES INTERNATIONALES (4)
-- =====================================================

-- Recommandation européenne 2003/361/CE sur les PME
CREATE society_size_nomenclature:eurostat SET
    code = 'EUROSTAT',
    description_i18n_key = i18n_key:society_size_nomenclature_eurostat_desc,
    pays_reference = NONE,
    period_start = 2005,
    period_end = NONE,
    is_active = true;

-- Classification OCDE des petites et moyennes entreprises
CREATE society_size_nomenclature:oecd SET
    code = 'OECD',
    description_i18n_key = i18n_key:society_size_nomenclature_oecd_desc,
    pays_reference = NONE,
    period_start = 2005,
    period_end = NONE,
    is_active = true;

-- Norme ISO 20022 pour classification financière
CREATE society_size_nomenclature:iso_20022 SET
    code = 'ISO_20022',
    description_i18n_key = i18n_key:society_size_nomenclature_iso_20022_desc,
    pays_reference = NONE,
    period_start = 2013,
    period_end = NONE,
    is_active = true;

-- Classification de la Banque Mondiale
CREATE society_size_nomenclature:world_bank SET
    code = 'WORLD_BANK',
    description_i18n_key = i18n_key:society_size_nomenclature_world_bank_desc,
    pays_reference = NONE,
    period_start = 2000,
    period_end = NONE,
    is_active = true;

-- =====================================================
-- EUROPE (47 PAYS)
-- =====================================================

-- France : Nomenclature INSEE des tranches d'effectifs salariés
CREATE society_size_nomenclature:tefet SET
    code = 'TEFET',
    description_i18n_key = i18n_key:society_size_nomenclature_tefet_desc,
    pays_reference = country:fr,
    period_start = 2008,
    period_end = NONE,
    is_active = true;

-- France : Catégories d'entreprises françaises
CREATE society_size_nomenclature:cat_ent_fr SET
    code = 'CAT_ENT_FR',
    description_i18n_key = i18n_key:society_size_nomenclature_cat_ent_fr_desc,
    pays_reference = country:fr,
    period_start = 2008,
    period_end = NONE,
    is_active = true;

-- Allemagne : Handelsgesetzbuch
CREATE society_size_nomenclature:hgb_de SET
    code = 'HGB_DE',
    description_i18n_key = i18n_key:society_size_nomenclature_hgb_de_desc,
    pays_reference = country:de,
    period_start = 2004,
    period_end = NONE,
    is_active = true;

-- Allemagne : Office statistique fédéral allemand
CREATE society_size_nomenclature:destatis SET
    code = 'DESTATIS',
    description_i18n_key = i18n_key:society_size_nomenclature_destatis_desc,
    pays_reference = country:de,
    period_start = 1995,
    period_end = NONE,
    is_active = true;

-- Royaume-Uni : Companies House
CREATE society_size_nomenclature:ch_uk SET
    code = 'CH_UK',
    description_i18n_key = i18n_key:society_size_nomenclature_ch_uk_desc,
    pays_reference = country:gb,
    period_start = 2006,
    period_end = NONE,
    is_active = true;

-- Royaume-Uni : Office for National Statistics
CREATE society_size_nomenclature:ons_uk SET
    code = 'ONS_UK',
    description_i18n_key = i18n_key:society_size_nomenclature_ons_uk_desc,
    pays_reference = country:gb,
    period_start = 2008,
    period_end = NONE,
    is_active = true;

-- Italie : Codice Civile
CREATE society_size_nomenclature:cc_it SET
    code = 'CC_IT',
    description_i18n_key = i18n_key:society_size_nomenclature_cc_it_desc,
    pays_reference = country:it,
    period_start = 2008,
    period_end = NONE,
    is_active = true;

-- Italie : Istituto nazionale di statistica
CREATE society_size_nomenclature:istat_it SET
    code = 'ISTAT_IT',
    description_i18n_key = i18n_key:society_size_nomenclature_istat_it_desc,
    pays_reference = country:it,
    period_start = 2007,
    period_end = NONE,
    is_active = true;

-- Espagne : Ley de Sociedades de Capital
CREATE society_size_nomenclature:lsc_es SET
    code = 'LSC_ES',
    description_i18n_key = i18n_key:society_size_nomenclature_lsc_es_desc,
    pays_reference = country:es,
    period_start = 2010,
    period_end = NONE,
    is_active = true;

-- Espagne : Instituto Nacional de Estadística
CREATE society_size_nomenclature:ine_es SET
    code = 'INE_ES',
    description_i18n_key = i18n_key:society_size_nomenclature_ine_es_desc,
    pays_reference = country:es,
    period_start = 2009,
    period_end = NONE,
    is_active = true;

-- Pays-Bas : Centraal Bureau voor de Statistiek
CREATE society_size_nomenclature:cbs_nl SET
    code = 'CBS_NL',
    description_i18n_key = i18n_key:society_size_nomenclature_cbs_nl_desc,
    pays_reference = country:nl,
    period_start = 2010,
    period_end = NONE,
    is_active = true;

-- Belgique : Banque Nationale de Belgique
CREATE society_size_nomenclature:nbb_be SET
    code = 'NBB_BE',
    description_i18n_key = i18n_key:society_size_nomenclature_nbb_be_desc,
    pays_reference = country:be,
    period_start = 2008,
    period_end = NONE,
    is_active = true;

-- Belgique : Office statistique belge
CREATE society_size_nomenclature:statbel SET
    code = 'STATBEL',
    description_i18n_key = i18n_key:society_size_nomenclature_statbel_desc,
    pays_reference = country:be,
    period_start = 2011,
    period_end = NONE,
    is_active = true;

-- Suisse : Code des obligations suisse
CREATE society_size_nomenclature:or_ch SET
    code = 'OR_CH',
    description_i18n_key = i18n_key:society_size_nomenclature_or_ch_desc,
    pays_reference = country:ch,
    period_start = 2008,
    period_end = NONE,
    is_active = true;

-- Suisse : Office fédéral de la statistique
CREATE society_size_nomenclature:ofs_ch SET
    code = 'OFS_CH',
    description_i18n_key = i18n_key:society_size_nomenclature_ofs_ch_desc,
    pays_reference = country:ch,
    period_start = 2011,
    period_end = NONE,
    is_active = true;

-- Autriche : Wirtschaftskammer Österreich
CREATE society_size_nomenclature:wko_at SET
    code = 'WKO_AT',
    description_i18n_key = i18n_key:society_size_nomenclature_wko_at_desc,
    pays_reference = country:at,
    period_start = 2009,
    period_end = NONE,
    is_active = true;

-- Luxembourg : Institut national de la statistique
CREATE society_size_nomenclature:statec_lu SET
    code = 'STATEC_LU',
    description_i18n_key = i18n_key:society_size_nomenclature_statec_lu_desc,
    pays_reference = country:lu,
    period_start = 2010,
    period_end = NONE,
    is_active = true;

-- Irlande : Central Statistics Office
CREATE society_size_nomenclature:cso_ie SET
    code = 'CSO_IE',
    description_i18n_key = i18n_key:society_size_nomenclature_cso_ie_desc,
    pays_reference = country:ie,
    period_start = 2007,
    period_end = NONE,
    is_active = true;

-- Portugal : Instituto Nacional de Estatística
CREATE society_size_nomenclature:ine_pt SET
    code = 'INE_PT',
    description_i18n_key = i18n_key:society_size_nomenclature_ine_pt_desc,
    pays_reference = country:pt,
    period_start = 2006,
    period_end = NONE,
    is_active = true;

-- Grèce : Hellenic Statistical Authority
CREATE society_size_nomenclature:elstat SET
    code = 'ELSTAT',
    description_i18n_key = i18n_key:society_size_nomenclature_elstat_desc,
    pays_reference = country:gr,
    period_start = 2008,
    period_end = NONE,
    is_active = true;

-- Monaco : Institut Monégasque de la Statistique
CREATE society_size_nomenclature:imsee_mc SET
    code = 'IMSEE_MC',
    description_i18n_key = i18n_key:society_size_nomenclature_imsee_mc_desc,
    pays_reference = country:mc,
    period_start = 2015,
    period_end = NONE,
    is_active = true;

-- Andorre : Estadística d'Andorra
CREATE society_size_nomenclature:estadi_ad SET
    code = 'ESTADI_AD',
    description_i18n_key = i18n_key:society_size_nomenclature_estadi_ad_desc,
    pays_reference = country:ad,
    period_start = 2012,
    period_end = NONE,
    is_active = true;

-- Liechtenstein : Amt für Statistik Liechtenstein
CREATE society_size_nomenclature:llstat SET
    code = 'LLSTAT',
    description_i18n_key = i18n_key:society_size_nomenclature_llstat_desc,
    pays_reference = country:li,
    period_start = 2010,
    period_end = NONE,
    is_active = true;

-- Vatican : Servizio Statistico Vaticano
CREATE society_size_nomenclature:vastat SET
    code = 'VASTAT',
    description_i18n_key = i18n_key:society_size_nomenclature_vastat_desc,
    pays_reference = country:va,
    period_start = 2018,
    period_end = NONE,
    is_active = true;

-- Saint-Marin : Ufficio Programmazione Economica San Marino
CREATE society_size_nomenclature:upeceds SET
    code = 'UPECEDS',
    description_i18n_key = i18n_key:society_size_nomenclature_upeceds_desc,
    pays_reference = country:sm,
    period_start = 2014,
    period_end = NONE,
    is_active = true;

-- Suède : Statistiska centralbyrån
CREATE society_size_nomenclature:scb_se SET
    code = 'SCB_SE',
    description_i18n_key = i18n_key:society_size_nomenclature_scb_se_desc,
    pays_reference = country:se,
    period_start = 2008,
    period_end = NONE,
    is_active = true;

-- Danemark : Danmarks Statistik
CREATE society_size_nomenclature:dst_dk SET
    code = 'DST_DK',
    description_i18n_key = i18n_key:society_size_nomenclature_dst_dk_desc,
    pays_reference = country:dk,
    period_start = 2007,
    period_end = NONE,
    is_active = true;

-- Norvège : Statistisk sentralbyrå
CREATE society_size_nomenclature:ssb_no SET
    code = 'SSB_NO',
    description_i18n_key = i18n_key:society_size_nomenclature_ssb_no_desc,
    pays_reference = country:no,
    period_start = 2009,
    period_end = NONE,
    is_active = true;

-- Finlande : Statistics Finland
CREATE society_size_nomenclature:stat_fi SET
    code = 'STAT_FI',
    description_i18n_key = i18n_key:society_size_nomenclature_stat_fi_desc,
    pays_reference = country:fi,
    period_start = 2010,
    period_end = NONE,
    is_active = true;

-- Islande : Statistics Iceland
CREATE society_size_nomenclature:statice SET
    code = 'STATICE',
    description_i18n_key = i18n_key:society_size_nomenclature_statice_desc,
    pays_reference = country:is,
    period_start = 2011,
    period_end = NONE,
    is_active = true;

-- Pologne : Główny Urząd Statystyczny
CREATE society_size_nomenclature:gus_pl SET
    code = 'GUS_PL',
    description_i18n_key = i18n_key:society_size_nomenclature_gus_pl_desc,
    pays_reference = country:pl,
    period_start = 2004,
    period_end = NONE,
    is_active = true;

-- République tchèque : Český statistický úřad
CREATE society_size_nomenclature:csu_cz SET
    code = 'CSU_CZ',
    description_i18n_key = i18n_key:society_size_nomenclature_csu_cz_desc,
    pays_reference = country:cz,
    period_start = 2004,
    period_end = NONE,
    is_active = true;

-- Slovaquie : Štatistický úrad Slovenskej republiky
CREATE society_size_nomenclature:sosr_sk SET
    code = 'SOSR_SK',
    description_i18n_key = i18n_key:society_size_nomenclature_sosr_sk_desc,
    pays_reference = country:sk,
    period_start = 2004,
    period_end = NONE,
    is_active = true;

-- Hongrie : Központi Statisztikai Hivatal
CREATE society_size_nomenclature:ksh_hu SET
    code = 'KSH_HU',
    description_i18n_key = i18n_key:society_size_nomenclature_ksh_hu_desc,
    pays_reference = country:hu,
    period_start = 2004,
    period_end = NONE,
    is_active = true;

-- Roumanie : Institutul Național de Statistică
CREATE society_size_nomenclature:ins_ro SET
    code = 'INS_RO',
    description_i18n_key = i18n_key:society_size_nomenclature_ins_ro_desc,
    pays_reference = country:ro,
    period_start = 2007,
    period_end = NONE,
    is_active = true;

-- Bulgarie : National Statistical Institute
CREATE society_size_nomenclature:nsi_bg SET
    code = 'NSI_BG',
    description_i18n_key = i18n_key:society_size_nomenclature_nsi_bg_desc,
    pays_reference = country:bg,
    period_start = 2007,
    period_end = NONE,
    is_active = true;

-- Ukraine : State Statistics Service of Ukraine
CREATE society_size_nomenclature:sssu SET
    code = 'SSSU',
    description_i18n_key = i18n_key:society_size_nomenclature_sssu_desc,
    pays_reference = country:ua,
    period_start = 2014,
    period_end = NONE,
    is_active = true;

-- Biélorussie : National Statistical Committee
CREATE society_size_nomenclature:belstat SET
    code = 'BELSTAT',
    description_i18n_key = i18n_key:society_size_nomenclature_belstat_desc,
    pays_reference = country:by,
    period_start = 2012,
    period_end = NONE,
    is_active = true;

-- Moldavie : Biroul Național de Statistică
CREATE society_size_nomenclature:bns_md SET
    code = 'BNS_MD',
    description_i18n_key = i18n_key:society_size_nomenclature_bns_md_desc,
    pays_reference = country:md,
    period_start = 2010,
    period_end = NONE,
    is_active = true;

-- Russie : Federal State Statistics Service
CREATE society_size_nomenclature:rosstat SET
    code = 'ROSSTAT',
    description_i18n_key = i18n_key:society_size_nomenclature_rosstat_desc,
    pays_reference = country:ru,
    period_start = 2004,
    period_end = NONE,
    is_active = true;

-- Croatie : Croatian Bureau of Statistics
CREATE society_size_nomenclature:cbs_hr SET
    code = 'CBS_HR',
    description_i18n_key = i18n_key:society_size_nomenclature_cbs_hr_desc,
    pays_reference = country:hr,
    period_start = 2013,
    period_end = NONE,
    is_active = true;

-- Slovénie : Statistical Office of Slovenia
CREATE society_size_nomenclature:surs SET
    code = 'SURS',
    description_i18n_key = i18n_key:society_size_nomenclature_surs_desc,
    pays_reference = country:si,
    period_start = 2004,
    period_end = NONE,
    is_active = true;

-- Serbie : Statistical Office of Republic of Serbia
CREATE society_size_nomenclature:rso SET
    code = 'RSO',
    description_i18n_key = i18n_key:society_size_nomenclature_rso_desc,
    pays_reference = country:rs,
    period_start = 2010,
    period_end = NONE,
    is_active = true;

-- Bosnie-Herzégovine : Agency for Statistics Bosnia and Herzegovina
CREATE society_size_nomenclature:bhas SET
    code = 'BHAS',
    description_i18n_key = i18n_key:society_size_nomenclature_bhas_desc,
    pays_reference = country:ba,
    period_start = 2008,
    period_end = NONE,
    is_active = true;

-- Monténégro : Statistical Office of Montenegro
CREATE society_size_nomenclature:monstat SET
    code = 'MONSTAT',
    description_i18n_key = i18n_key:society_size_nomenclature_monstat_desc,
    pays_reference = country:me,
    period_start = 2006,
    period_end = NONE,
    is_active = true;

-- Macédoine du Nord : State Statistical Office North Macedonia
CREATE society_size_nomenclature:sso_mk SET
    code = 'SSO_MK',
    description_i18n_key = i18n_key:society_size_nomenclature_sso_mk_desc,
    pays_reference = country:mk,
    period_start = 2009,
    period_end = NONE,
    is_active = true;

-- Albanie : Instituti i Statistikave
CREATE society_size_nomenclature:instat_al SET
    code = 'INSTAT_AL',
    description_i18n_key = i18n_key:society_size_nomenclature_instat_al_desc,
    pays_reference = country:al,
    period_start = 2011,
    period_end = NONE,
    is_active = true;

-- Kosovo : Kosovo Agency of Statistics
CREATE society_size_nomenclature:kas SET
    code = 'KAS',
    description_i18n_key = i18n_key:society_size_nomenclature_kas_desc,
    pays_reference = country:xk,
    period_start = 2012,
    period_end = NONE,
    is_active = true;

-- Malte : National Statistics Office Malta
CREATE society_size_nomenclature:nso_mt SET
    code = 'NSO_MT',
    description_i18n_key = i18n_key:society_size_nomenclature_nso_mt_desc,
    pays_reference = country:mt,
    period_start = 2004,
    period_end = NONE,
    is_active = true;

-- Chypre : Statistical Service of Cyprus
CREATE society_size_nomenclature:cystat SET
    code = 'CYSTAT',
    description_i18n_key = i18n_key:society_size_nomenclature_cystat_desc,
    pays_reference = country:cy,
    period_start = 2004,
    period_end = NONE,
    is_active = true;

-- Estonie : Statistics Estonia
CREATE society_size_nomenclature:stat_ee SET
    code = 'STAT_EE',
    description_i18n_key = i18n_key:society_size_nomenclature_stat_ee_desc,
    pays_reference = country:ee,
    period_start = 2004,
    period_end = NONE,
    is_active = true;

-- Lettonie : Central Statistical Bureau of Latvia
CREATE society_size_nomenclature:csb_lv SET
    code = 'CSB_LV',
    description_i18n_key = i18n_key:society_size_nomenclature_csb_lv_desc,
    pays_reference = country:lv,
    period_start = 2004,
    period_end = NONE,
    is_active = true;

-- Lituanie : Statistics Lithuania
CREATE society_size_nomenclature:stat_lt SET
    code = 'STAT_LT',
    description_i18n_key = i18n_key:society_size_nomenclature_stat_lt_desc,
    pays_reference = country:lt,
    period_start = 2004,
    period_end = NONE,
    is_active = true;

-- =====================================================
-- ASIE (49 PAYS)
-- =====================================================

-- Chine : Ministry of Industry and Information Technology
CREATE society_size_nomenclature:miit_cn SET
    code = 'MIIT_CN',
    description_i18n_key = i18n_key:society_size_nomenclature_miit_cn_desc,
    pays_reference = country:cn,
    period_start = 2011,
    period_end = NONE,
    is_active = true;

-- Chine : National Bureau of Statistics
CREATE society_size_nomenclature:nbs_cn SET
    code = 'NBS_CN',
    description_i18n_key = i18n_key:society_size_nomenclature_nbs_cn_desc,
    pays_reference = country:cn,
    period_start = 2017,
    period_end = NONE,
    is_active = true;

-- Japon : Ministry of Economy, Trade and Industry
CREATE society_size_nomenclature:meti_jp SET
    code = 'METI_JP',
    description_i18n_key = i18n_key:society_size_nomenclature_meti_jp_desc,
    pays_reference = country:jp,
    period_start = 1999,
    period_end = NONE,
    is_active = true;

-- Japon : Statistics Bureau of Japan
CREATE society_size_nomenclature:stat_jp SET
    code = 'STAT_JP',
    description_i18n_key = i18n_key:society_size_nomenclature_stat_jp_desc,
    pays_reference = country:jp,
    period_start = 2014,
    period_end = NONE,
    is_active = true;

-- Corée du Sud : Statistics Korea
CREATE society_size_nomenclature:kostat SET
    code = 'KOSTAT',
    description_i18n_key = i18n_key:society_size_nomenclature_kostat_desc,
    pays_reference = country:kr,
    period_start = 2007,
    period_end = NONE,
    is_active = true;

-- Corée du Sud : Small and Medium Business Administration
CREATE society_size_nomenclature:smba_kr SET
    code = 'SMBA_KR',
    description_i18n_key = i18n_key:society_size_nomenclature_smba_kr_desc,
    pays_reference = country:kr,
    period_start = 2016,
    period_end = NONE,
    is_active = true;

-- Corée du Nord : Central Bureau of Statistics DPRK
CREATE society_size_nomenclature:cbs_kp SET
    code = 'CBS_KP',
    description_i18n_key = i18n_key:society_size_nomenclature_cbs_kp_desc,
    pays_reference = country:kp,
    period_start = 2010,
    period_end = NONE,
    is_active = true;

-- Mongolie : National Statistics Office of Mongolia
CREATE society_size_nomenclature:nso_mn SET
    code = 'NSO_MN',
    description_i18n_key = i18n_key:society_size_nomenclature_nso_mn_desc,
    pays_reference = country:mn,
    period_start = 2012,
    period_end = NONE,
    is_active = true;

-- Taïwan : Directorate-General of Budget, Accounting and Statistics
CREATE society_size_nomenclature:dgbas_tw SET
    code = 'DGBAS_TW',
    description_i18n_key = i18n_key:society_size_nomenclature_dgbas_tw_desc,
    pays_reference = country:tw,
    period_start = 2011,
    period_end = NONE,
    is_active = true;

-- Hong Kong : Census and Statistics Department
CREATE society_size_nomenclature:censtatd SET
    code = 'CENSTATD',
    description_i18n_key = i18n_key:society_size_nomenclature_censtatd_desc,
    pays_reference = country:hk,
    period_start = 2016,
    period_end = NONE,
    is_active = true;

-- Macao : Statistics and Census Service Macao
CREATE society_size_nomenclature:dsec_mo SET
    code = 'DSEC_MO',
    description_i18n_key = i18n_key:society_size_nomenclature_dsec_mo_desc,
    pays_reference = country:mo,
    period_start = 2015,
    period_end = NONE,
    is_active = true;

-- Indonésie : Badan Pusat Statistik
CREATE society_size_nomenclature:bps_id SET
    code = 'BPS_ID',
    description_i18n_key = i18n_key:society_size_nomenclature_bps_id_desc,
    pays_reference = country:id,
    period_start = 2008,
    period_end = NONE,
    is_active = true;

-- Thaïlande : National Statistical Office
CREATE society_size_nomenclature:nso_th SET
    code = 'NSO_TH',
    description_i18n_key = i18n_key:society_size_nomenclature_nso_th_desc,
    pays_reference = country:th,
    period_start = 2007,
    period_end = NONE,
    is_active = true;

-- Malaisie : Department of Statistics Malaysia
CREATE society_size_nomenclature:dosm_my SET
    code = 'DOSM_MY',
    description_i18n_key = i18n_key:society_size_nomenclature_dosm_my_desc,
    pays_reference = country:my,
    period_start = 2005,
    period_end = NONE,
    is_active = true;

-- Malaisie : SME Corporation Malaysia
CREATE society_size_nomenclature:sme_my SET
    code = 'SME_MY',
    description_i18n_key = i18n_key:society_size_nomenclature_sme_my_desc,
    pays_reference = country:my,
    period_start = 2013,
    period_end = NONE,
    is_active = true;

-- Singapour : Singapore Department of Statistics
CREATE society_size_nomenclature:singstat SET
    code = 'SINGSTAT',
    description_i18n_key = i18n_key:society_size_nomenclature_singstat_desc,
    pays_reference = country:sg,
    period_start = 2015,
    period_end = NONE,
    is_active = true;

-- Singapour : Standards, Productivity and Innovation Board
CREATE society_size_nomenclature:spring_sg SET
    code = 'SPRING_SG',
    description_i18n_key = i18n_key:society_size_nomenclature_spring_sg_desc,
    pays_reference = country:sg,
    period_start = 2001,
    period_end = NONE,
    is_active = true;

-- Philippines : Philippine Statistics Authority
CREATE society_size_nomenclature:psa_ph SET
    code = 'PSA_PH',
    description_i18n_key = i18n_key:society_size_nomenclature_psa_ph_desc,
    pays_reference = country:ph,
    period_start = 2013,
    period_end = NONE,
    is_active = true;

-- Vietnam : General Statistics Office
CREATE society_size_nomenclature:gso_vn SET
    code = 'GSO_VN',
    description_i18n_key = i18n_key:society_size_nomenclature_gso_vn_desc,
    pays_reference = country:vn,
    period_start = 2009,
    period_end = NONE,
    is_active = true;

-- Myanmar : Central Statistical Organization Myanmar
CREATE society_size_nomenclature:cso_mm SET
    code = 'CSO_MM',
    description_i18n_key = i18n_key:society_size_nomenclature_cso_mm_desc,
    pays_reference = country:mm,
    period_start = 2014,
    period_end = NONE,
    is_active = true;

-- Cambodge : National Institute of Statistics Cambodia
CREATE society_size_nomenclature:nis_kh SET
    code = 'NIS_KH',
    description_i18n_key = i18n_key:society_size_nomenclature_nis_kh_desc,
    pays_reference = country:kh,
    period_start = 2010,
    period_end = NONE,
    is_active = true;

-- Laos : Lao Statistics Bureau
CREATE society_size_nomenclature:lsb SET
    code = 'LSB',
    description_i18n_key = i18n_key:society_size_nomenclature_lsb_desc,
    pays_reference = country:la,
    period_start = 2012,
    period_end = NONE,
    is_active = true;

-- Brunei : Department of Economic Planning Brunei
CREATE society_size_nomenclature:deps_bn SET
    code = 'DEPS_BN',
    description_i18n_key = i18n_key:society_size_nomenclature_deps_bn_desc,
    pays_reference = country:bn,
    period_start = 2011,
    period_end = NONE,
    is_active = true;

-- Timor-Leste : Direcção Nacional de Estatística Timor-Leste
CREATE society_size_nomenclature:dne_tl SET
    code = 'DNE_TL',
    description_i18n_key = i18n_key:society_size_nomenclature_dne_tl_desc,
    pays_reference = country:tl,
    period_start = 2015,
    period_end = NONE,
    is_active = true;

-- Inde : Ministry of Micro, Small and Medium Enterprises
CREATE society_size_nomenclature:msme_in SET
    code = 'MSME_IN',
    description_i18n_key = i18n_key:society_size_nomenclature_msme_in_desc,
    pays_reference = country:in,
    period_start = 2006,
    period_end = NONE,
    is_active = true;

-- Inde : Central Statistics Office
CREATE society_size_nomenclature:cso_in SET
    code = 'CSO_IN',
    description_i18n_key = i18n_key:society_size_nomenclature_cso_in_desc,
    pays_reference = country:in,
    period_start = 2008,
    period_end = NONE,
    is_active = true;

-- Pakistan : Pakistan Bureau of Statistics
CREATE society_size_nomenclature:pbs_pk SET
    code = 'PBS_PK',
    description_i18n_key = i18n_key:society_size_nomenclature_pbs_pk_desc,
    pays_reference = country:pk,
    period_start = 2011,
    period_end = NONE,
    is_active = true;

-- Bangladesh : Bangladesh Bureau of Statistics
CREATE society_size_nomenclature:bbs SET
    code = 'BBS',
    description_i18n_key = i18n_key:society_size_nomenclature_bbs_desc,
    pays_reference = country:bd,
    period_start = 2010,
    period_end = NONE,
    is_active = true;

-- Sri Lanka : Department of Census and Statistics Sri Lanka
CREATE society_size_nomenclature:dcs_lk SET
    code = 'DCS_LK',
    description_i18n_key = i18n_key:society_size_nomenclature_dcs_lk_desc,
    pays_reference = country:lk,
    period_start = 2012,
    period_end = NONE,
    is_active = true;

-- Népal : Central Bureau of Statistics Nepal
CREATE society_size_nomenclature:cbs_np SET
    code = 'CBS_NP',
    description_i18n_key = i18n_key:society_size_nomenclature_cbs_np_desc,
    pays_reference = country:np,
    period_start = 2013,
    period_end = NONE,
    is_active = true;

-- Bhoutan : National Statistics Bureau Bhutan
CREATE society_size_nomenclature:nsb_bt SET
    code = 'NSB_BT',
    description_i18n_key = i18n_key:society_size_nomenclature_nsb_bt_desc,
    pays_reference = country:bt,
    period_start = 2014,
    period_end = NONE,
    is_active = true;

-- Maldives : National Bureau of Statistics Maldives
CREATE society_size_nomenclature:nbs_mv SET
    code = 'NBS_MV',
    description_i18n_key = i18n_key:society_size_nomenclature_nbs_mv_desc,
    pays_reference = country:mv,
    period_start = 2015,
    period_end = NONE,
    is_active = true;

-- Afghanistan : Central Statistics Organization Afghanistan
CREATE society_size_nomenclature:cso_af SET
    code = 'CSO_AF',
    description_i18n_key = i18n_key:society_size_nomenclature_cso_af_desc,
    pays_reference = country:af,
    period_start = 2016,
    period_end = NONE,
    is_active = true;

-- Kazakhstan : Bureau of National Statistics Kazakhstan
CREATE society_size_nomenclature:stat_kz SET
    code = 'STAT_KZ',
    description_i18n_key = i18n_key:society_size_nomenclature_stat_kz_desc,
    pays_reference = country:kz,
    period_start = 2010,
    period_end = NONE,
    is_active = true;

-- Ouzbékistan : State Committee on Statistics Uzbekistan
CREATE society_size_nomenclature:stat_uz SET
    code = 'STAT_UZ',
    description_i18n_key = i18n_key:society_size_nomenclature_stat_uz_desc,
    pays_reference = country:uz,
    period_start = 2012,
    period_end = NONE,
    is_active = true;

-- Turkménistan : State Committee of Statistics Turkmenistan
CREATE society_size_nomenclature:stattm SET
    code = 'STATTM',
    description_i18n_key = i18n_key:society_size_nomenclature_stattm_desc,
    pays_reference = country:tm,
    period_start = 2014,
    period_end = NONE,
    is_active = true;

-- Kirghizistan : National Statistical Committee Kyrgyzstan
CREATE society_size_nomenclature:nstatkr SET
    code = 'NSTATKR',
    description_i18n_key = i18n_key:society_size_nomenclature_nstatkr_desc,
    pays_reference = country:kg,
    period_start = 2011,
    period_end = NONE,
    is_active = true;

-- Tadjikistan : Agency on Statistics Tajikistan
CREATE society_size_nomenclature:stat_tj SET
    code = 'STAT_TJ',
    description_i18n_key = i18n_key:society_size_nomenclature_stat_tj_desc,
    pays_reference = country:tj,
    period_start = 2013,
    period_end = NONE,
    is_active = true;

-- Turquie : Türkiye İstatistik Kurumu
CREATE society_size_nomenclature:tuik_tr SET
    code = 'TUIK_TR',
    description_i18n_key = i18n_key:society_size_nomenclature_tuik_tr_desc,
    pays_reference = country:tr,
    period_start = 2005,
    period_end = NONE,
    is_active = true;

-- Israël : Central Bureau of Statistics
CREATE society_size_nomenclature:cbs_il SET
    code = 'CBS_IL',
    description_i18n_key = i18n_key:society_size_nomenclature_cbs_il_desc,
    pays_reference = country:il,
    period_start = 2010,
    period_end = NONE,
    is_active = true;

-- Arabie saoudite : General Authority for Statistics
CREATE society_size_nomenclature:gastat SET
    code = 'GASTAT',
    description_i18n_key = i18n_key:society_size_nomenclature_gastat_desc,
    pays_reference = country:sa,
    period_start = 2016,
    period_end = NONE,
    is_active = true;

-- Émirats arabes unis : Federal Competitiveness and Statistics Centre
CREATE society_size_nomenclature:fcsa_ae SET
    code = 'FCSA_AE',
    description_i18n_key = i18n_key:society_size_nomenclature_fcsa_ae_desc,
    pays_reference = country:ae,
    period_start = 2015,
    period_end = NONE,
    is_active = true;

-- Iran : Statistical Center of Iran
CREATE society_size_nomenclature:sci_ir SET
    code = 'SCI_IR',
    description_i18n_key = i18n_key:society_size_nomenclature_sci_ir_desc,
    pays_reference = country:ir,
    period_start = 2009,
    period_end = NONE,
    is_active = true;

-- Irak : Central Organization for Statistics Iraq
CREATE society_size_nomenclature:cosit SET
    code = 'COSIT',
    description_i18n_key = i18n_key:society_size_nomenclature_cosit_desc,
    pays_reference = country:iq,
    period_start = 2015,
    period_end = NONE,
    is_active = true;

-- Jordanie : Department of Statistics Jordan
CREATE society_size_nomenclature:dos_jo SET
    code = 'DOS_JO',
    description_i18n_key = i18n_key:society_size_nomenclature_dos_jo_desc,
    pays_reference = country:jo,
    period_start = 2010,
    period_end = NONE,
    is_active = true;

-- Liban : Central Administration of Statistics Lebanon
CREATE society_size_nomenclature:cas_lb SET
    code = 'CAS_LB',
    description_i18n_key = i18n_key:society_size_nomenclature_cas_lb_desc,
    pays_reference = country:lb,
    period_start = 2012,
    period_end = NONE,
    is_active = true;

-- Syrie : Central Bureau of Statistics Syria
CREATE society_size_nomenclature:cbs_sy SET
    code = 'CBS_SY',
    description_i18n_key = i18n_key:society_size_nomenclature_cbs_sy_desc,
    pays_reference = country:sy,
    period_start = 2008,
    period_end = NONE,
    is_active = true;

-- Yémen : Central Statistical Organization Yemen
CREATE society_size_nomenclature:cso_ye SET
    code = 'CSO_YE',
    description_i18n_key = i18n_key:society_size_nomenclature_cso_ye_desc,
    pays_reference = country:ye,
    period_start = 2011,
    period_end = NONE,
    is_active = true;

-- Oman : National Centre for Statistics Oman
CREATE society_size_nomenclature:ncsi_om SET
    code = 'NCSI_OM',
    description_i18n_key = i18n_key:society_size_nomenclature_ncsi_om_desc,
    pays_reference = country:om,
    period_start = 2013,
    period_end = NONE,
    is_active = true;

-- Koweït : Central Statistical Bureau Kuwait
CREATE society_size_nomenclature:csb_kw SET
    code = 'CSB_KW',
    description_i18n_key = i18n_key:society_size_nomenclature_csb_kw_desc,
    pays_reference = country:kw,
    period_start = 2010,
    period_end = NONE,
    is_active = true;

-- Qatar : Planning and Statistics Authority Qatar
CREATE society_size_nomenclature:psa_qa SET
    code = 'PSA_QA',
    description_i18n_key = i18n_key:society_size_nomenclature_psa_qa_desc,
    pays_reference = country:qa,
    period_start = 2014,
    period_end = NONE,
    is_active = true;

-- Bahreïn : Statistics Information Center Bahrain
CREATE society_size_nomenclature:sioict SET
    code = 'SIOICT',
    description_i18n_key = i18n_key:society_size_nomenclature_sioict_desc,
    pays_reference = country:bh,
    period_start = 2012,
    period_end = NONE,
    is_active = true;

-- Palestine : Palestinian Central Bureau of Statistics
CREATE society_size_nomenclature:pcbs SET
    code = 'PCBS',
    description_i18n_key = i18n_key:society_size_nomenclature_pcbs_desc,
    pays_reference = country:ps,
    period_start = 2015,
    period_end = NONE,
    is_active = true;

-- Arménie : Statistical Committee of Armenia
CREATE society_size_nomenclature:armstat SET
    code = 'ARMSTAT',
    description_i18n_key = i18n_key:society_size_nomenclature_armstat_desc,
    pays_reference = country:am,
    period_start = 2010,
    period_end = NONE,
    is_active = true;

-- Azerbaïdjan : State Statistical Committee Azerbaijan
CREATE society_size_nomenclature:stat_az SET
    code = 'STAT_AZ',
    description_i18n_key = i18n_key:society_size_nomenclature_stat_az_desc,
    pays_reference = country:az,
    period_start = 2011,
    period_end = NONE,
    is_active = true;

-- Géorgie : National Statistics Office Georgia
CREATE society_size_nomenclature:geostat SET
    code = 'GEOSTAT',
    description_i18n_key = i18n_key:society_size_nomenclature_geostat_desc,
    pays_reference = country:ge,
    period_start = 2012,
    period_end = NONE,
    is_active = true;

-- =====================================================
-- AMÉRIQUES (35 PAYS)
-- =====================================================

-- États-Unis : Small Business Administration
CREATE society_size_nomenclature:sba_us SET
    code = 'SBA_US',
    description_i18n_key = i18n_key:society_size_nomenclature_sba_us_desc,
    pays_reference = country:us,
    period_start = 1953,
    period_end = NONE,
    is_active = true;

-- États-Unis : North American Industry Classification System
CREATE society_size_nomenclature:naics SET
    code = 'NAICS',
    description_i18n_key = i18n_key:society_size_nomenclature_naics_desc,
    pays_reference = country:us,
    period_start = 1997,
    period_end = NONE,
    is_active = true;

-- Canada : Statistics Canada
CREATE society_size_nomenclature:statcan SET
    code = 'STATCAN',
    description_i18n_key = i18n_key:society_size_nomenclature_statcan_desc,
    pays_reference = country:ca,
    period_start = 2009,
    period_end = NONE,
    is_active = true;

-- Canada : Innovation, Science and Economic Development
CREATE society_size_nomenclature:ic_ca SET
    code = 'IC_CA',
    description_i18n_key = i18n_key:society_size_nomenclature_ic_ca_desc,
    pays_reference = country:ca,
    period_start = 2015,
    period_end = NONE,
    is_active = true;

-- Mexique : Instituto Nacional de Estadística y Geografía
CREATE society_size_nomenclature:inegi_mx SET
    code = 'INEGI_MX',
    description_i18n_key = i18n_key:society_size_nomenclature_inegi_mx_desc,
    pays_reference = country:mx,
    period_start = 2009,
    period_end = NONE,
    is_active = true;

-- Mexique : Secretaría de Economía
CREATE society_size_nomenclature:se_mx SET
    code = 'SE_MX',
    description_i18n_key = i18n_key:society_size_nomenclature_se_mx_desc,
    pays_reference = country:mx,
    period_start = 2002,
    period_end = NONE,
    is_active = true;

-- Guatemala : Instituto Nacional de Estadística Guatemala
CREATE society_size_nomenclature:ine_gt SET
    code = 'INE_GT',
    description_i18n_key = i18n_key:society_size_nomenclature_ine_gt_desc,
    pays_reference = country:gt,
    period_start = 2010,
    period_end = NONE,
    is_active = true;

-- Belize : Statistical Institute of Belize
CREATE society_size_nomenclature:sib SET
    code = 'SIB',
    description_i18n_key = i18n_key:society_size_nomenclature_sib_desc,
    pays_reference = country:bz,
    period_start = 2012,
    period_end = NONE,
    is_active = true;

-- Salvador : Dirección General de Estadística El Salvador
CREATE society_size_nomenclature:digestyc SET
    code = 'DIGESTYC',
    description_i18n_key = i18n_key:society_size_nomenclature_digestyc_desc,
    pays_reference = country:sv,
    period_start = 2011,
    period_end = NONE,
    is_active = true;

-- Honduras : Instituto Nacional de Estadística Honduras
CREATE society_size_nomenclature:ine_hn SET
    code = 'INE_HN',
    description_i18n_key = i18n_key:society_size_nomenclature_ine_hn_desc,
    pays_reference = country:hn,
    period_start = 2010,
    period_end = NONE,
    is_active = true;

-- Nicaragua : Instituto Nacional de Información de Desarrollo Nicaragua
CREATE society_size_nomenclature:inide SET
    code = 'INIDE',
    description_i18n_key = i18n_key:society_size_nomenclature_inide_desc,
    pays_reference = country:ni,
    period_start = 2012,
    period_end = NONE,
    is_active = true;

-- Costa Rica : Instituto Nacional de Estadística Costa Rica
CREATE society_size_nomenclature:inec_cr SET
    code = 'INEC_CR',
    description_i18n_key = i18n_key:society_size_nomenclature_inec_cr_desc,
    pays_reference = country:cr,
    period_start = 2009,
    period_end = NONE,
    is_active = true;

-- Panama : Instituto Nacional de Estadística Panamá
CREATE society_size_nomenclature:inec_pa SET
    code = 'INEC_PA',
    description_i18n_key = i18n_key:society_size_nomenclature_inec_pa_desc,
    pays_reference = country:pa,
    period_start = 2010,
    period_end = NONE,
    is_active = true;

-- Cuba : Oficina Nacional de Estadística Cuba
CREATE society_size_nomenclature:onei SET
    code = 'ONEI',
    description_i18n_key = i18n_key:society_size_nomenclature_onei_desc,
    pays_reference = country:cu,
    period_start = 2010,
    period_end = NONE,
    is_active = true;

-- Jamaïque : Statistical Institute of Jamaica
CREATE society_size_nomenclature:statin SET
    code = 'STATIN',
    description_i18n_key = i18n_key:society_size_nomenclature_statin_desc,
    pays_reference = country:jm,
    period_start = 2011,
    period_end = NONE,
    is_active = true;

-- Haïti : Institut Haïtien de Statistique
CREATE society_size_nomenclature:ihsi SET
    code = 'IHSI',
    description_i18n_key = i18n_key:society_size_nomenclature_ihsi_desc,
    pays_reference = country:ht,
    period_start = 2014,
    period_end = NONE,
    is_active = true;

-- République dominicaine : Oficina Nacional de Estadística República Dominicana
CREATE society_size_nomenclature:one_do SET
    code = 'ONE_DO',
    description_i18n_key = i18n_key:society_size_nomenclature_one_do_desc,
    pays_reference = country:do,
    period_start = 2009,
    period_end = NONE,
    is_active = true;

-- Trinité-et-Tobago : Central Statistical Office Trinidad
CREATE society_size_nomenclature:cso_tt SET
    code = 'CSO_TT',
    description_i18n_key = i18n_key:society_size_nomenclature_cso_tt_desc,
    pays_reference = country:tt,
    period_start = 2010,
    period_end = NONE,
    is_active = true;

-- Bahamas : Department of Statistics Bahamas
CREATE society_size_nomenclature:dos_bs SET
    code = 'DOS_BS',
    description_i18n_key = i18n_key:society_size_nomenclature_dos_bs_desc,
    pays_reference = country:bs,
    period_start = 2012,
    period_end = NONE,
    is_active = true;

-- Barbade : Barbados Statistical Service
CREATE society_size_nomenclature:bss SET
    code = 'BSS',
    description_i18n_key = i18n_key:society_size_nomenclature_bss_desc,
    pays_reference = country:bb,
    period_start = 2011,
    period_end = NONE,
    is_active = true;

-- Grenade : Central Statistical Office Grenada
CREATE society_size_nomenclature:cso_gd SET
    code = 'CSO_GD',
    description_i18n_key = i18n_key:society_size_nomenclature_cso_gd_desc,
    pays_reference = country:gd,
    period_start = 2013,
    period_end = NONE,
    is_active = true;

-- Sainte-Lucie : Central Statistical Office Saint Lucia
CREATE society_size_nomenclature:cso_lc SET
    code = 'CSO_LC',
    description_i18n_key = i18n_key:society_size_nomenclature_cso_lc_desc,
    pays_reference = country:lc,
    period_start = 2012,
    period_end = NONE,
    is_active = true;

-- Saint-Vincent : Statistical Office Saint Vincent
CREATE society_size_nomenclature:stats_vc SET
    code = 'STATS_VC',
    description_i18n_key = i18n_key:society_size_nomenclature_stats_vc_desc,
    pays_reference = country:vc,
    period_start = 2014,
    period_end = NONE,
    is_active = true;

-- Antigua-et-Barbuda : Statistics Division Antigua
CREATE society_size_nomenclature:stats_ag SET
    code = 'STATS_AG',
    description_i18n_key = i18n_key:society_size_nomenclature_stats_ag_desc,
    pays_reference = country:ag,
    period_start = 2013,
    period_end = NONE,
    is_active = true;

-- Saint-Christophe : Statistics Department Saint Kitts
CREATE society_size_nomenclature:stats_kn SET
    code = 'STATS_KN',
    description_i18n_key = i18n_key:society_size_nomenclature_stats_kn_desc,
    pays_reference = country:kn,
    period_start = 2015,
    period_end = NONE,
    is_active = true;

-- Dominique : Central Statistical Office Dominica
CREATE society_size_nomenclature:cso_dm SET
    code = 'CSO_DM',
    description_i18n_key = i18n_key:society_size_nomenclature_cso_dm_desc,
    pays_reference = country:dm,
    period_start = 2012,
    period_end = NONE,
    is_active = true;

-- Brésil : Instituto Brasileiro de Geografia e Estatística
CREATE society_size_nomenclature:ibge_br SET
    code = 'IBGE_BR',
    description_i18n_key = i18n_key:society_size_nomenclature_ibge_br_desc,
    pays_reference = country:br,
    period_start = 2006,
    period_end = NONE,
    is_active = true;

-- Brésil : Serviço Brasileiro de Apoio às Micro e Pequenas Empresas
CREATE society_size_nomenclature:sebrae SET
    code = 'SEBRAE',
    description_i18n_key = i18n_key:society_size_nomenclature_sebrae_desc,
    pays_reference = country:br,
    period_start = 2013,
    period_end = NONE,
    is_active = true;

-- Argentine : Instituto Nacional de Estadística y Censos
CREATE society_size_nomenclature:indec_ar SET
    code = 'INDEC_AR',
    description_i18n_key = i18n_key:society_size_nomenclature_indec_ar_desc,
    pays_reference = country:ar,
    period_start = 2010,
    period_end = NONE,
    is_active = true;

-- Chili : Instituto Nacional de Estadísticas
CREATE society_size_nomenclature:ine_cl SET
    code = 'INE_CL',
    description_i18n_key = i18n_key:society_size_nomenclature_ine_cl_desc,
    pays_reference = country:cl,
    period_start = 2007,
    period_end = NONE,
    is_active = true;

-- Colombie : Departamento Administrativo Nacional de Estadística
CREATE society_size_nomenclature:dane_co SET
    code = 'DANE_CO',
    description_i18n_key = i18n_key:society_size_nomenclature_dane_co_desc,
    pays_reference = country:co,
    period_start = 2012,
    period_end = NONE,
    is_active = true;

-- Pérou : Instituto Nacional de Estadística e Informática
CREATE society_size_nomenclature:inei_pe SET
    code = 'INEI_PE',
    description_i18n_key = i18n_key:society_size_nomenclature_inei_pe_desc,
    pays_reference = country:pe,
    period_start = 2008,
    period_end = NONE,
    is_active = true;

-- Venezuela : Instituto Nacional de Estadística Venezuela
CREATE society_size_nomenclature:ine_ve SET
    code = 'INE_VE',
    description_i18n_key = i18n_key:society_size_nomenclature_ine_ve_desc,
    pays_reference = country:ve,
    period_start = 2009,
    period_end = NONE,
    is_active = true;

-- Équateur : Instituto Nacional de Estadística Ecuador
CREATE society_size_nomenclature:inec_ec SET
    code = 'INEC_EC',
    description_i18n_key = i18n_key:society_size_nomenclature_inec_ec_desc,
    pays_reference = country:ec,
    period_start = 2010,
    period_end = NONE,
    is_active = true;

-- Bolivie : Instituto Nacional de Estadística Bolivia
CREATE society_size_nomenclature:ine_bo SET
    code = 'INE_BO',
    description_i18n_key = i18n_key:society_size_nomenclature_ine_bo_desc,
    pays_reference = country:bo,
    period_start = 2011,
    period_end = NONE,
    is_active = true;

-- Paraguay : Instituto Nacional de Estadística Paraguay
CREATE society_size_nomenclature:ine_py SET
    code = 'INE_PY',
    description_i18n_key = i18n_key:society_size_nomenclature_ine_py_desc,
    pays_reference = country:py,
    period_start = 2010,
    period_end = NONE,
    is_active = true;

-- Uruguay : Instituto Nacional de Estadística Uruguay
CREATE society_size_nomenclature:ine_uy SET
    code = 'INE_UY',
    description_i18n_key = i18n_key:society_size_nomenclature_ine_uy_desc,
    pays_reference = country:uy,
    period_start = 2009,
    period_end = NONE,
    is_active = true;

-- Guyana : Bureau of Statistics Guyana
CREATE society_size_nomenclature:bos_gy SET
    code = 'BOS_GY',
    description_i18n_key = i18n_key:society_size_nomenclature_bos_gy_desc,
    pays_reference = country:gy,
    period_start = 2012,
    period_end = NONE,
    is_active = true;

-- Suriname : Algemeen Bureau voor de Statistiek Suriname
CREATE society_size_nomenclature:abs_sr SET
    code = 'ABS_SR',
    description_i18n_key = i18n_key:society_size_nomenclature_abs_sr_desc,
    pays_reference = country:sr,
    period_start = 2013,
    period_end = NONE,
    is_active = true;

-- Guyane française : INSEE Guyane française
CREATE society_size_nomenclature:insee_gf SET
    code = 'INSEE_GF',
    description_i18n_key = i18n_key:society_size_nomenclature_insee_gf_desc,
    pays_reference = country:gf,
    period_start = 2011,
    period_end = NONE,
    is_active = true;

-- =====================================================
-- AFRIQUE (54 PAYS)
-- =====================================================

-- Égypte : Central Agency for Public Mobilization and Statistics
CREATE society_size_nomenclature:capmas SET
    code = 'CAPMAS',
    description_i18n_key = i18n_key:society_size_nomenclature_capmas_desc,
    pays_reference = country:eg,
    period_start = 2017,
    period_end = NONE,
    is_active = true;

-- Algérie : Office National des Statistiques
CREATE society_size_nomenclature:ons_dz SET
    code = 'ONS_DZ',
    description_i18n_key = i18n_key:society_size_nomenclature_ons_dz_desc,
    pays_reference = country:dz,
    period_start = 2016,
    period_end = NONE,
    is_active = true;

-- Maroc : Haut-Commissariat au Plan
CREATE society_size_nomenclature:hcp_ma SET
    code = 'HCP_MA',
    description_i18n_key = i18n_key:society_size_nomenclature_hcp_ma_desc,
    pays_reference = country:ma,
    period_start = 2015,
    period_end = NONE,
    is_active = true;

-- Tunisie : Institut National de la Statistique
CREATE society_size_nomenclature:ins_tn SET
    code = 'INS_TN',
    description_i18n_key = i18n_key:society_size_nomenclature_ins_tn_desc,
    pays_reference = country:tn,
    period_start = 2014,
    period_end = NONE,
    is_active = true;

-- Libye : Bureau of Statistics Libya
CREATE society_size_nomenclature:bsl SET
    code = 'BSL',
    description_i18n_key = i18n_key:society_size_nomenclature_bsl_desc,
    pays_reference = country:ly,
    period_start = 2010,
    period_end = NONE,
    is_active = true;

-- Soudan : Central Bureau of Statistics Sudan
CREATE society_size_nomenclature:cbs_sd SET
    code = 'CBS_SD',
    description_i18n_key = i18n_key:society_size_nomenclature_cbs_sd_desc,
    pays_reference = country:sd,
    period_start = 2012,
    period_end = NONE,
    is_active = true;

-- Soudan du Sud : National Bureau of Statistics South Sudan
CREATE society_size_nomenclature:nbs_ss SET
    code = 'NBS_SS',
    description_i18n_key = i18n_key:society_size_nomenclature_nbs_ss_desc,
    pays_reference = country:ss,
    period_start = 2014,
    period_end = NONE,
    is_active = true;

-- Nigeria : National Bureau of Statistics
CREATE society_size_nomenclature:nbs_ng SET
    code = 'NBS_NG',
    description_i18n_key = i18n_key:society_size_nomenclature_nbs_ng_desc,
    pays_reference = country:ng,
    period_start = 2013,
    period_end = NONE,
    is_active = true;

-- Ghana : Ghana Statistical Service
CREATE society_size_nomenclature:gss SET
    code = 'GSS',
    description_i18n_key = i18n_key:society_size_nomenclature_gss_desc,
    pays_reference = country:gh,
    period_start = 2010,
    period_end = NONE,
    is_active = true;

-- Côte d'Ivoire : Institut National de la Statistique Côte d'Ivoire
CREATE society_size_nomenclature:ins_ci SET
    code = 'INS_CI',
    description_i18n_key = i18n_key:society_size_nomenclature_ins_ci_desc,
    pays_reference = country:ci,
    period_start = 2012,
    period_end = NONE,
    is_active = true;

-- Sénégal : Agence Nationale de la Statistique Sénégal
CREATE society_size_nomenclature:ansd SET
    code = 'ANSD',
    description_i18n_key = i18n_key:society_size_nomenclature_ansd_desc,
    pays_reference = country:sn,
    period_start = 2011,
    period_end = NONE,
    is_active = true;

-- Mali : Institut National de la Statistique Mali
CREATE society_size_nomenclature:instat_ml SET
    code = 'INSTAT_ML',
    description_i18n_key = i18n_key:society_size_nomenclature_instat_ml_desc,
    pays_reference = country:ml,
    period_start = 2013,
    period_end = NONE,
    is_active = true;

-- Burkina Faso : Institut National de la Statistique Burkina Faso
CREATE society_size_nomenclature:insd SET
    code = 'INSD',
    description_i18n_key = i18n_key:society_size_nomenclature_insd_desc,
    pays_reference = country:bf,
    period_start = 2010,
    period_end = NONE,
    is_active = true;

-- Niger : Institut National de la Statistique Niger
CREATE society_size_nomenclature:ins_ne SET
    code = 'INS_NE',
    description_i18n_key = i18n_key:society_size_nomenclature_ins_ne_desc,
    pays_reference = country:ne,
    period_start = 2012,
    period_end = NONE,
    is_active = true;

-- Guinée : Institut National de la Statistique Guinée
CREATE society_size_nomenclature:ins_gn SET
    code = 'INS_GN',
    description_i18n_key = i18n_key:society_size_nomenclature_ins_gn_desc,
    pays_reference = country:gn,
    period_start = 2014,
    period_end = NONE,
    is_active = true;

-- Bénin : Institut National de la Statistique Bénin
CREATE society_size_nomenclature:insae SET
    code = 'INSAE',
    description_i18n_key = i18n_key:society_size_nomenclature_insae_desc,
    pays_reference = country:bj,
    period_start = 2011,
    period_end = NONE,
    is_active = true;

-- Togo : Institut National de la Statistique Togo
CREATE society_size_nomenclature:inseed SET
    code = 'INSEED',
    description_i18n_key = i18n_key:society_size_nomenclature_inseed_desc,
    pays_reference = country:tg,
    period_start = 2013,
    period_end = NONE,
    is_active = true;

-- Libéria : Liberia Institute of Statistics
CREATE society_size_nomenclature:lisgis SET
    code = 'LISGIS',
    description_i18n_key = i18n_key:society_size_nomenclature_lisgis_desc,
    pays_reference = country:lr,
    period_start = 2015,
    period_end = NONE,
    is_active = true;

-- Sierra Leone : Statistics Sierra Leone
CREATE society_size_nomenclature:ssl SET
    code = 'SSL',
    description_i18n_key = i18n_key:society_size_nomenclature_ssl_desc,
    pays_reference = country:sl,
    period_start = 2014,
    period_end = NONE,
    is_active = true;

-- Gambie : Gambia Bureau of Statistics
CREATE society_size_nomenclature:gbos SET
    code = 'GBOS',
    description_i18n_key = i18n_key:society_size_nomenclature_gbos_desc,
    pays_reference = country:gm,
    period_start = 2012,
    period_end = NONE,
    is_active = true;

-- Guinée-Bissau : Instituto Nacional de Estatística Guinée-Bissau
CREATE society_size_nomenclature:ine_gw SET
    code = 'INE_GW',
    description_i18n_key = i18n_key:society_size_nomenclature_ine_gw_desc,
    pays_reference = country:gw,
    period_start = 2013,
    period_end = NONE,
    is_active = true;

-- Cap-Vert : Instituto Nacional de Estatística Cabo Verde
CREATE society_size_nomenclature:ine_cv SET
    code = 'INE_CV',
    description_i18n_key = i18n_key:society_size_nomenclature_ine_cv_desc,
    pays_reference = country:cv,
    period_start = 2010,
    period_end = NONE,
    is_active = true;

-- Mauritanie : Office National de la Statistique Mauritanie
CREATE society_size_nomenclature:ons_mr SET
    code = 'ONS_MR',
    description_i18n_key = i18n_key:society_size_nomenclature_ons_mr_desc,
    pays_reference = country:mr,
    period_start = 2011,
    period_end = NONE,
    is_active = true;

-- Cameroun : Institut National de la Statistique Cameroun
CREATE society_size_nomenclature:ins_cm SET
    code = 'INS_CM',
    description_i18n_key = i18n_key:society_size_nomenclature_ins_cm_desc,
    pays_reference = country:cm,
    period_start = 2010,
    period_end = NONE,
    is_active = true;

-- RD Congo : Institut National de la Statistique RD Congo
CREATE society_size_nomenclature:ins_cd SET
    code = 'INS_CD',
    description_i18n_key = i18n_key:society_size_nomenclature_ins_cd_desc,
    pays_reference = country:cd,
    period_start = 2012,
    period_end = NONE,
    is_active = true;

-- Congo : Centre National de la Statistique Congo
CREATE society_size_nomenclature:cnsee SET
    code = 'CNSEE',
    description_i18n_key = i18n_key:society_size_nomenclature_cnsee_desc,
    pays_reference = country:cg,
    period_start = 2011,
    period_end = NONE,
    is_active = true;

-- Centrafrique : Institut Centrafricain de Statistique
CREATE society_size_nomenclature:icasees SET
    code = 'ICASEES',
    description_i18n_key = i18n_key:society_size_nomenclature_icasees_desc,
    pays_reference = country:cf,
    period_start = 2014,
    period_end = NONE,
    is_active = true;

-- Tchad : Institut National de la Statistique Tchad
CREATE society_size_nomenclature:inseed_td SET
    code = 'INSEED_TD',
    description_i18n_key = i18n_key:society_size_nomenclature_inseed_td_desc,
    pays_reference = country:td,
    period_start = 2013,
    period_end = NONE,
    is_active = true;

-- Gabon : Direction Générale de la Statistique Gabon
CREATE society_size_nomenclature:dgs_ga SET
    code = 'DGS_GA',
    description_i18n_key = i18n_key:society_size_nomenclature_dgs_ga_desc,
    pays_reference = country:ga,
    period_start = 2010,
    period_end = NONE,
    is_active = true;

-- Guinée équatoriale : Instituto Nacional de Estadística Guinée équatoriale
CREATE society_size_nomenclature:inege SET
    code = 'INEGE',
    description_i18n_key = i18n_key:society_size_nomenclature_inege_desc,
    pays_reference = country:gq,
    period_start = 2015,
    period_end = NONE,
    is_active = true;

-- Sao Tomé : Instituto Nacional de Estatística São Tomé
CREATE society_size_nomenclature:ine_st SET
    code = 'INE_ST',
    description_i18n_key = i18n_key:society_size_nomenclature_ine_st_desc,
    pays_reference = country:st,
    period_start = 2012,
    period_end = NONE,
    is_active = true;

-- Kenya : Kenya National Bureau of Statistics
CREATE society_size_nomenclature:knbs SET
    code = 'KNBS',
    description_i18n_key = i18n_key:society_size_nomenclature_knbs_desc,
    pays_reference = country:ke,
    period_start = 2012,
    period_end = NONE,
    is_active = true;

-- Tanzanie : National Bureau of Statistics Tanzania
CREATE society_size_nomenclature:nbs_tz SET
    code = 'NBS_TZ',
    description_i18n_key = i18n_key:society_size_nomenclature_nbs_tz_desc,
    pays_reference = country:tz,
    period_start = 2011,
    period_end = NONE,
    is_active = true;

-- Ouganda : Uganda Bureau of Statistics
CREATE society_size_nomenclature:ubos SET
    code = 'UBOS',
    description_i18n_key = i18n_key:society_size_nomenclature_ubos_desc,
    pays_reference = country:ug,
    period_start = 2010,
    period_end = NONE,
    is_active = true;

-- Éthiopie : Central Statistical Agency Ethiopia
CREATE society_size_nomenclature:csa_et SET
    code = 'CSA_ET',
    description_i18n_key = i18n_key:society_size_nomenclature_csa_et_desc,
    pays_reference = country:et,
    period_start = 2013,
    period_end = NONE,
    is_active = true;

-- Somalie : Somali National Bureau of Statistics
CREATE society_size_nomenclature:snbs SET
    code = 'SNBS',
    description_i18n_key = i18n_key:society_size_nomenclature_snbs_desc,
    pays_reference = country:so,
    period_start = 2016,
    period_end = NONE,
    is_active = true;

-- Djibouti : Direction de la Statistique Djibouti
CREATE society_size_nomenclature:dised SET
    code = 'DISED',
    description_i18n_key = i18n_key:society_size_nomenclature_dised_desc,
    pays_reference = country:dj,
    period_start = 2014,
    period_end = NONE,
    is_active = true;

-- Érythrée : National Statistics Office Eritrea
CREATE society_size_nomenclature:nso_er SET
    code = 'NSO_ER',
    description_i18n_key = i18n_key:society_size_nomenclature_nso_er_desc,
    pays_reference = country:er,
    period_start = 2012,
    period_end = NONE,
    is_active = true;

-- Rwanda : National Institute of Statistics Rwanda
CREATE society_size_nomenclature:nisr SET
    code = 'NISR',
    description_i18n_key = i18n_key:society_size_nomenclature_nisr_desc,
    pays_reference = country:rw,
    period_start = 2011,
    period_end = NONE,
    is_active = true;

-- Burundi : Institut de Statistiques du Burundi
CREATE society_size_nomenclature:isteebu SET
    code = 'ISTEEBU',
    description_i18n_key = i18n_key:society_size_nomenclature_isteebu_desc,
    pays_reference = country:bi,
    period_start = 2013,
    period_end = NONE,
    is_active = true;

-- Malawi : National Statistical Office Malawi
CREATE society_size_nomenclature:nso_mw SET
    code = 'NSO_MW',
    description_i18n_key = i18n_key:society_size_nomenclature_nso_mw_desc,
    pays_reference = country:mw,
    period_start = 2010,
    period_end = NONE,
    is_active = true;

-- Zambie : Zambia Statistics Agency
CREATE society_size_nomenclature:zamstats SET
    code = 'ZAMSTATS',
    description_i18n_key = i18n_key:society_size_nomenclature_zamstats_desc,
    pays_reference = country:zm,
    period_start = 2011,
    period_end = NONE,
    is_active = true;

-- Zimbabwe : Zimbabwe National Statistics Agency
CREATE society_size_nomenclature:zimstat SET
    code = 'ZIMSTAT',
    description_i18n_key = i18n_key:society_size_nomenclature_zimstat_desc,
    pays_reference = country:zw,
    period_start = 2012,
    period_end = NONE,
    is_active = true;

-- Mozambique : Instituto Nacional de Estatística Mozambique
CREATE society_size_nomenclature:ine_mz SET
    code = 'INE_MZ',
    description_i18n_key = i18n_key:society_size_nomenclature_ine_mz_desc,
    pays_reference = country:mz,
    period_start = 2010,
    period_end = NONE,
    is_active = true;

-- Madagascar : Institut National de la Statistique Madagascar
CREATE society_size_nomenclature:instat_mg SET
    code = 'INSTAT_MG',
    description_i18n_key = i18n_key:society_size_nomenclature_instat_mg_desc,
    pays_reference = country:mg,
    period_start = 2012,
    period_end = NONE,
    is_active = true;

-- Maurice : Statistics Mauritius
CREATE society_size_nomenclature:stats_mu SET
    code = 'STATS_MU',
    description_i18n_key = i18n_key:society_size_nomenclature_stats_mu_desc,
    pays_reference = country:mu,
    period_start = 2009,
    period_end = NONE,
    is_active = true;

-- Seychelles : National Bureau of Statistics Seychelles
CREATE society_size_nomenclature:nbs_sc SET
    code = 'NBS_SC',
    description_i18n_key = i18n_key:society_size_nomenclature_nbs_sc_desc,
    pays_reference = country:sc,
    period_start = 2011,
    period_end = NONE,
    is_active = true;

-- Comores : Institut National de la Statistique Comores
CREATE society_size_nomenclature:inseed_km SET
    code = 'INSEED_KM',
    description_i18n_key = i18n_key:society_size_nomenclature_inseed_km_desc,
    pays_reference = country:km,
    period_start = 2013,
    period_end = NONE,
    is_active = true;

-- Afrique du Sud : Statistics South Africa
CREATE society_size_nomenclature:stats_za SET
    code = 'STATS_ZA',
    description_i18n_key = i18n_key:society_size_nomenclature_stats_za_desc,
    pays_reference = country:za,
    period_start = 2008,
    period_end = NONE,
    is_active = true;

-- Afrique du Sud : Department of Small Business Development
CREATE society_size_nomenclature:dsbd_za SET
    code = 'DSBD_ZA',
    description_i18n_key = i18n_key:society_size_nomenclature_dsbd_za_desc,
    pays_reference = country:za,
    period_start = 2014,
    period_end = NONE,
    is_active = true;

-- Namibie : Namibia Statistics Agency
CREATE society_size_nomenclature:nsa SET
    code = 'NSA',
    description_i18n_key = i18n_key:society_size_nomenclature_nsa_desc,
    pays_reference = country:na,
    period_start = 2011,
    period_end = NONE,
    is_active = true;

-- Botswana : Statistics Botswana
CREATE society_size_nomenclature:stats_bw SET
    code = 'STATS_BW',
    description_i18n_key = i18n_key:society_size_nomenclature_stats_bw_desc,
    pays_reference = country:bw,
    period_start = 2010,
    period_end = NONE,
    is_active = true;

-- Eswatini : Central Statistical Office Eswatini
CREATE society_size_nomenclature:cso_sz SET
    code = 'CSO_SZ',
    description_i18n_key = i18n_key:society_size_nomenclature_cso_sz_desc,
    pays_reference = country:sz,
    period_start = 2012,
    period_end = NONE,
    is_active = true;

-- Lesotho : Bureau of Statistics Lesotho
CREATE society_size_nomenclature:bos_ls SET
    code = 'BOS_LS',
    description_i18n_key = i18n_key:society_size_nomenclature_bos_ls_desc,
    pays_reference = country:ls,
    period_start = 2011,
    period_end = NONE,
    is_active = true;

-- Angola : Instituto Nacional de Estatística Angola
CREATE society_size_nomenclature:ine_ao SET
    code = 'INE_AO',
    description_i18n_key = i18n_key:society_size_nomenclature_ine_ao_desc,
    pays_reference = country:ao,
    period_start = 2014,
    period_end = NONE,
    is_active = true;

-- =====================================================
-- OCÉANIE (14 PAYS)
-- =====================================================

-- Australie : Australian Bureau of Statistics
CREATE society_size_nomenclature:abs_au SET
    code = 'ABS_AU',
    description_i18n_key = i18n_key:society_size_nomenclature_abs_au_desc,
    pays_reference = country:au,
    period_start = 2001,
    period_end = NONE,
    is_active = true;

-- Australie : Australian Small Business Ombudsman
CREATE society_size_nomenclature:asbfeo SET
    code = 'ASBFEO',
    description_i18n_key = i18n_key:society_size_nomenclature_asbfeo_desc,
    pays_reference = country:au,
    period_start = 2016,
    period_end = NONE,
    is_active = true;

-- Nouvelle-Zélande : Stats NZ
CREATE society_size_nomenclature:stats_nz SET
    code = 'STATS_NZ',
    description_i18n_key = i18n_key:society_size_nomenclature_stats_nz_desc,
    pays_reference = country:nz,
    period_start = 2013,
    period_end = NONE,
    is_active = true;

-- Nouvelle-Zélande : Ministry of Business, Innovation and Employment
CREATE society_size_nomenclature:mbie_nz SET
    code = 'MBIE_NZ',
    description_i18n_key = i18n_key:society_size_nomenclature_mbie_nz_desc,
    pays_reference = country:nz,
    period_start = 2012,
    period_end = NONE,
    is_active = true;

-- Papouasie-Nouvelle-Guinée : National Statistical Office Papua New Guinea
CREATE society_size_nomenclature:nso_pg SET
    code = 'NSO_PG',
    description_i18n_key = i18n_key:society_size_nomenclature_nso_pg_desc,
    pays_reference = country:pg,
    period_start = 2012,
    period_end = NONE,
    is_active = true;

-- Fidji : Fiji Bureau of Statistics
CREATE society_size_nomenclature:fbos SET
    code = 'FBOS',
    description_i18n_key = i18n_key:society_size_nomenclature_fbos_desc,
    pays_reference = country:fj,
    period_start = 2010,
    period_end = NONE,
    is_active = true;

-- Îles Salomon : Solomon Islands National Statistics Office
CREATE society_size_nomenclature:sinso SET
    code = 'SINSO',
    description_i18n_key = i18n_key:society_size_nomenclature_sinso_desc,
    pays_reference = country:sb,
    period_start = 2013,
    period_end = NONE,
    is_active = true;

-- Vanuatu : Vanuatu National Statistics Office
CREATE society_size_nomenclature:vnso SET
    code = 'VNSO',
    description_i18n_key = i18n_key:society_size_nomenclature_vnso_desc,
    pays_reference = country:vu,
    period_start = 2011,
    period_end = NONE,
    is_active = true;

-- Samoa : Samoa Bureau of Statistics
CREATE society_size_nomenclature:sbs SET
    code = 'SBS',
    description_i18n_key = i18n_key:society_size_nomenclature_sbs_desc,
    pays_reference = country:ws,
    period_start = 2012,
    period_end = NONE,
    is_active = true;

-- Tonga : Tonga Statistics Department
CREATE society_size_nomenclature:tstats SET
    code = 'TSTATS',
    description_i18n_key = i18n_key:society_size_nomenclature_tstats_desc,
    pays_reference = country:to,
    period_start = 2010,
    period_end = NONE,
    is_active = true;

-- Kiribati : National Statistics Office Kiribati
CREATE society_size_nomenclature:nso_ki SET
    code = 'NSO_KI',
    description_i18n_key = i18n_key:society_size_nomenclature_nso_ki_desc,
    pays_reference = country:ki,
    period_start = 2014,
    period_end = NONE,
    is_active = true;

-- Îles Marshall : Economic Policy Planning Office Marshall
CREATE society_size_nomenclature:eppso SET
    code = 'EPPSO',
    description_i18n_key = i18n_key:society_size_nomenclature_eppso_desc,
    pays_reference = country:mh,
    period_start = 2015,
    period_end = NONE,
    is_active = true;

-- Micronésie : FSM Statistics Office
CREATE society_size_nomenclature:fsm_sboc SET
    code = 'FSM_SBOC',
    description_i18n_key = i18n_key:society_size_nomenclature_fsm_sboc_desc,
    pays_reference = country:fm,
    period_start = 2013,
    period_end = NONE,
    is_active = true;

-- Palaos : Bureau of Statistics Palau
CREATE society_size_nomenclature:bspp SET
    code = 'BSPP',
    description_i18n_key = i18n_key:society_size_nomenclature_bspp_desc,
    pays_reference = country:pw,
    period_start = 2012,
    period_end = NONE,
    is_active = true;

-- Nauru : Nauru Bureau of Statistics
CREATE society_size_nomenclature:nrstat SET
    code = 'NRSTAT',
    description_i18n_key = i18n_key:society_size_nomenclature_nrstat_desc,
    pays_reference = country:nr,
    period_start = 2016,
    period_end = NONE,
    is_active = true;

-- Tuvalu : Central Statistics Office Tuvalu
CREATE society_size_nomenclature:cso_tv SET
    code = 'CSO_TV',
    description_i18n_key = i18n_key:society_size_nomenclature_cso_tv_desc,
    pays_reference = country:tv,
    period_start = 2014,
    period_end = NONE,
    is_active = true;
