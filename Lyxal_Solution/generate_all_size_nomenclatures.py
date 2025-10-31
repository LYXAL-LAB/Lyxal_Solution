"""
Génère les seeds de nomenclatures de taille pour TOUS les pays
"""

# Nomenclatures de taille par pays (code, nom, année de début)
NOMENCLATURES = {
    # INTERNATIONALES / SUPRANATIONALES
    'INTERNATIONAL': [
        ('EUROSTAT', 'Recommandation européenne 2003/361/CE sur les PME', 2005, None),
        ('OECD', 'Classification OCDE des petites et moyennes entreprises', 2005, None),
        ('ISO_20022', 'Norme ISO 20022 pour classification financière', 2013, None),
        ('WORLD_BANK', 'Classification de la Banque Mondiale', 2000, None),
    ],
    
    # EUROPE
    'fr': [
        ('TEFET', 'Nomenclature INSEE des tranches d\'effectifs salariés', 2008, 'France'),
        ('CAT_ENT_FR', 'Catégories d\'entreprises françaises (Décret 2008-1354)', 2008, 'France'),
    ],
    'de': [
        ('HGB_DE', 'Handelsgesetzbuch - Code de commerce allemand', 2004, 'Allemagne'),
        ('DESTATIS', 'Office statistique fédéral allemand', 1995, 'Allemagne'),
    ],
    'gb': [
        ('CH_UK', 'Companies House - Companies Act 2006', 2006, 'Royaume-Uni'),
        ('ONS_UK', 'Office for National Statistics UK', 2008, 'Royaume-Uni'),
    ],
    'es': [
        ('LSC_ES', 'Ley de Sociedades de Capital', 2010, 'Espagne'),
        ('INE_ES', 'Instituto Nacional de Estadística', 2009, 'Espagne'),
    ],
    'it': [
        ('CC_IT', 'Codice Civile italiano', 2008, 'Italie'),
        ('ISTAT_IT', 'Istituto nazionale di statistica', 2007, 'Italie'),
    ],
    'nl': [
        ('CBS_NL', 'Centraal Bureau voor de Statistiek', 2010, 'Pays-Bas'),
    ],
    'be': [
        ('NBB_BE', 'Banque Nationale de Belgique', 2008, 'Belgique'),
        ('STATBEL', 'Office statistique belge', 2011, 'Belgique'),
    ],
    'ch': [
        ('OR_CH', 'Code des obligations suisse', 2008, 'Suisse'),
        ('OFS_CH', 'Office fédéral de la statistique', 2011, 'Suisse'),
    ],
    'at': [
        ('WKO_AT', 'Wirtschaftskammer Österreich', 2009, 'Autriche'),
    ],
    'se': [
        ('SCB_SE', 'Statistiska centralbyrån', 2008, 'Suède'),
    ],
    'dk': [
        ('DST_DK', 'Danmarks Statistik', 2007, 'Danemark'),
    ],
    'no': [
        ('SSB_NO', 'Statistisk sentralbyrå', 2009, 'Norvège'),
    ],
    'fi': [
        ('STAT_FI', 'Statistics Finland', 2010, 'Finlande'),
    ],
    'pl': [
        ('GUS_PL', 'Główny Urząd Statystyczny', 2004, 'Pologne'),
    ],
    'cz': [
        ('CSU_CZ', 'Český statistický úřad', 2004, 'République tchèque'),
    ],
    'pt': [
        ('INE_PT', 'Instituto Nacional de Estatística', 2006, 'Portugal'),
    ],
    'gr': [
        ('ELSTAT', 'Hellenic Statistical Authority', 2008, 'Grèce'),
    ],
    'ie': [
        ('CSO_IE', 'Central Statistics Office Ireland', 2007, 'Irlande'),
    ],
    'hu': [
        ('KSH_HU', 'Központi Statisztikai Hivatal', 2004, 'Hongrie'),
    ],
    'ro': [
        ('INS_RO', 'Institutul Național de Statistică', 2007, 'Roumanie'),
    ],
    
    # AMÉRIQUES
    'us': [
        ('SBA_US', 'Small Business Administration', 1953, 'États-Unis'),
        ('NAICS', 'North American Industry Classification System', 1997, 'États-Unis'),
    ],
    'ca': [
        ('STATCAN', 'Statistics Canada - SME Classification', 2009, 'Canada'),
        ('IC_CA', 'Innovation, Sciences et Développement économique Canada', 2015, 'Canada'),
    ],
    'mx': [
        ('INEGI_MX', 'Instituto Nacional de Estadística y Geografía', 2009, 'Mexique'),
        ('SE_MX', 'Secretaría de Economía', 2002, 'Mexique'),
    ],
    'br': [
        ('IBGE_BR', 'Instituto Brasileiro de Geografia e Estatística', 2006, 'Brésil'),
        ('SEBRAE', 'Serviço Brasileiro de Apoio às Micro e Pequenas Empresas', 2013, 'Brésil'),
    ],
    'ar': [
        ('INDEC_AR', 'Instituto Nacional de Estadística y Censos', 2010, 'Argentine'),
    ],
    'cl': [
        ('INE_CL', 'Instituto Nacional de Estadísticas', 2007, 'Chili'),
    ],
    'co': [
        ('DANE_CO', 'Departamento Administrativo Nacional de Estadística', 2012, 'Colombie'),
    ],
    'pe': [
        ('INEI_PE', 'Instituto Nacional de Estadística e Informática', 2008, 'Pérou'),
    ],
    
    # ASIE
    'cn': [
        ('MIIT_CN', 'Ministry of Industry and Information Technology', 2011, 'Chine'),
        ('NBS_CN', 'National Bureau of Statistics of China', 2017, 'Chine'),
    ],
    'jp': [
        ('METI_JP', 'Ministry of Economy, Trade and Industry', 1999, 'Japon'),
        ('STAT_JP', 'Statistics Bureau of Japan', 2014, 'Japon'),
    ],
    'kr': [
        ('KOSTAT', 'Statistics Korea', 2007, 'Corée du Sud'),
        ('SMBA_KR', 'Small and Medium Business Administration', 2016, 'Corée du Sud'),
    ],
    'in': [
        ('MSME_IN', 'Ministry of Micro, Small and Medium Enterprises', 2006, 'Inde'),
        ('CSO_IN', 'Central Statistics Office India', 2008, 'Inde'),
    ],
    'id': [
        ('BPS_ID', 'Badan Pusat Statistik', 2008, 'Indonésie'),
    ],
    'th': [
        ('NSO_TH', 'National Statistical Office Thailand', 2007, 'Thaïlande'),
    ],
    'my': [
        ('DOSM_MY', 'Department of Statistics Malaysia', 2005, 'Malaisie'),
        ('SME_MY', 'SME Corporation Malaysia', 2013, 'Malaisie'),
    ],
    'sg': [
        ('SINGSTAT', 'Singapore Department of Statistics', 2015, 'Singapour'),
        ('SPRING_SG', 'Standards, Productivity and Innovation Board', 2001, 'Singapour'),
    ],
    'ph': [
        ('PSA_PH', 'Philippine Statistics Authority', 2013, 'Philippines'),
    ],
    'vn': [
        ('GSO_VN', 'General Statistics Office of Vietnam', 2009, 'Vietnam'),
    ],
    'tw': [
        ('DGBAS_TW', 'Directorate-General of Budget, Accounting and Statistics', 2011, 'Taïwan'),
    ],
    'hk': [
        ('CENSTATD', 'Census and Statistics Department Hong Kong', 2016, 'Hong Kong'),
    ],
    'il': [
        ('CBS_IL', 'Central Bureau of Statistics Israel', 2010, 'Israël'),
    ],
    'sa': [
        ('GASTAT', 'General Authority for Statistics Saudi Arabia', 2016, 'Arabie saoudite'),
    ],
    'ae': [
        ('FCSA_AE', 'Federal Competitiveness and Statistics Centre', 2015, 'Émirats arabes unis'),
    ],
    'tr': [
        ('TUIK_TR', 'Türkiye İstatistik Kurumu', 2005, 'Turquie'),
    ],
    
    # OCÉANIE
    'au': [
        ('ABS_AU', 'Australian Bureau of Statistics', 2001, 'Australie'),
        ('ASBFEO', 'Australian Small Business and Family Enterprise Ombudsman', 2016, 'Australie'),
    ],
    'nz': [
        ('STATS_NZ', 'Stats NZ - Statistics New Zealand', 2013, 'Nouvelle-Zélande'),
        ('MBIE_NZ', 'Ministry of Business, Innovation and Employment', 2012, 'Nouvelle-Zélande'),
    ],
    
    # AFRIQUE
    'za': [
        ('STATS_ZA', 'Statistics South Africa', 2008, 'Afrique du Sud'),
        ('DSBD_ZA', 'Department of Small Business Development', 2014, 'Afrique du Sud'),
    ],
    'eg': [
        ('CAPMAS', 'Central Agency for Public Mobilization and Statistics', 2017, 'Égypte'),
    ],
    'ng': [
        ('NBS_NG', 'National Bureau of Statistics Nigeria', 2013, 'Nigeria'),
    ],
    'ke': [
        ('KNBS', 'Kenya National Bureau of Statistics', 2012, 'Kenya'),
    ],
    'ma': [
        ('HCP_MA', 'Haut-Commissariat au Plan', 2015, 'Maroc'),
    ],
    'tn': [
        ('INS_TN', 'Institut National de la Statistique Tunisie', 2014, 'Tunisie'),
    ],
    'dz': [
        ('ONS_DZ', 'Office National des Statistiques Algérie', 2016, 'Algérie'),
    ],
}

def generate_seeds():
    """Génère le fichier seeds"""
    lines = []
    lines.append('-- =====================================================')
    lines.append('-- NOMENCLATURES DE TAILLE DE SOCIÉTÉS - MONDE ENTIER')
    lines.append('-- =====================================================')
    lines.append('-- Nomenclatures nationales et internationales pour classifier')
    lines.append('-- les entreprises selon leur taille (effectifs, CA, bilan)')
    lines.append('-- =====================================================')
    lines.append('')
    
    # Internationales d'abord
    lines.append('-- =====================================================')
    lines.append('-- NOMENCLATURES INTERNATIONALES')
    lines.append('-- =====================================================')
    lines.append('')
    
    for code, desc, year, _ in NOMENCLATURES['INTERNATIONAL']:
        record_id = code.lower()
        lines.append(f'-- {desc}')
        lines.append(f'CREATE society_size_nomenclature:{record_id} SET')
        lines.append(f"    code = '{code}',")
        lines.append(f"    description_i18n_key = i18n_key:society_size_nomenclature_{record_id}_desc,")
        lines.append(f"    pays_reference = NONE,")
        lines.append(f"    period_start = {year},")
        lines.append(f"    period_end = NONE,")
        lines.append(f"    is_active = true;")
        lines.append('')
    
    # Par région
    regions = {
        'EUROPE': ['fr', 'de', 'gb', 'es', 'it', 'nl', 'be', 'ch', 'at', 'se', 'dk', 'no', 'fi', 'pl', 'cz', 'pt', 'gr', 'ie', 'hu', 'ro'],
        'AMÉRIQUES': ['us', 'ca', 'mx', 'br', 'ar', 'cl', 'co', 'pe'],
        'ASIE': ['cn', 'jp', 'kr', 'in', 'id', 'th', 'my', 'sg', 'ph', 'vn', 'tw', 'hk', 'il', 'sa', 'ae', 'tr'],
        'OCÉANIE': ['au', 'nz'],
        'AFRIQUE': ['za', 'eg', 'ng', 'ke', 'ma', 'tn', 'dz'],
    }
    
    for region, countries in regions.items():
        lines.append('-- =====================================================')
        lines.append(f'-- {region}')
        lines.append('-- =====================================================')
        lines.append('')
        
        for country_code in countries:
            if country_code in NOMENCLATURES:
                for code, desc, year, country_name in NOMENCLATURES[country_code]:
                    record_id = code.lower()
                    lines.append(f'-- {country_name} : {desc}')
                    lines.append(f'CREATE society_size_nomenclature:{record_id} SET')
                    lines.append(f"    code = '{code}',")
                    lines.append(f"    description_i18n_key = i18n_key:society_size_nomenclature_{record_id}_desc,")
                    lines.append(f"    pays_reference = country:{country_code},")
                    lines.append(f"    period_start = {year},")
                    lines.append(f"    period_end = NONE,")
                    lines.append(f"    is_active = true;")
                    lines.append('')
    
    return '\n'.join(lines)

def generate_i18n_keys():
    """Génère les clés i18n"""
    lines = []
    lines.append('-- =====================================================')
    lines.append('-- CLÉS I18N : NOMENCLATURES DE TAILLE - MONDE ENTIER')
    lines.append('-- =====================================================')
    lines.append('')
    
    # Internationales
    for code, _, _, _ in NOMENCLATURES['INTERNATIONAL']:
        record_id = code.lower()
        lines.append(f'CREATE i18n_key:society_size_nomenclature_{record_id}_desc SET')
        lines.append(f"    code = 'society_size_nomenclature.{record_id}.description',")
        lines.append(f"    category = 'society_size_nomenclature',")
        lines.append(f"    sub_category = 'description';")
        lines.append('')
    
    # Toutes les nomenclatures nationales
    for country_code, nomenclatures in NOMENCLATURES.items():
        if country_code != 'INTERNATIONAL':
            for code, _, _, _ in nomenclatures:
                record_id = code.lower()
                lines.append(f'CREATE i18n_key:society_size_nomenclature_{record_id}_desc SET')
                lines.append(f"    code = 'society_size_nomenclature.{record_id}.description',")
                lines.append(f"    category = 'society_size_nomenclature',")
                lines.append(f"    sub_category = 'description';")
                lines.append('')
    
    return '\n'.join(lines)

def generate_translations():
    """Génère les traductions pour les 5 langues"""
    
    # Descriptions multilingues
    DESCRIPTIONS = {
        # INTERNATIONALES
        'eurostat': {
            'fr': "Classification européenne des entreprises par taille selon la recommandation 2003/361/CE",
            'en': "European classification of enterprises by size according to recommendation 2003/361/EC",
            'es': "Clasificación europea de empresas por tamaño según recomendación 2003/361/CE",
            'de': "Europäische Klassifizierung von Unternehmen nach Größe gemäß Empfehlung 2003/361/EG",
            'it': "Classificazione europea delle imprese per dimensione secondo raccomandazione 2003/361/CE",
        },
        'oecd': {
            'fr': "Classification OCDE des petites et moyennes entreprises (PME)",
            'en': "OECD classification of small and medium-sized enterprises (SMEs)",
            'es': "Clasificación OCDE de pequeñas y medianas empresas (PYME)",
            'de': "OECD-Klassifizierung kleiner und mittlerer Unternehmen (KMU)",
            'it': "Classificazione OCSE delle piccole e medie imprese (PMI)",
        },
        'iso_20022': {
            'fr': "Norme internationale ISO 20022 pour la classification financière des entreprises",
            'en': "ISO 20022 international standard for financial classification of companies",
            'es': "Norma internacional ISO 20022 para clasificación financiera de empresas",
            'de': "Internationaler Standard ISO 20022 zur finanziellen Klassifizierung von Unternehmen",
            'it': "Standard internazionale ISO 20022 per la classificazione finanziaria delle imprese",
        },
        'world_bank': {
            'fr': "Classification de la Banque Mondiale des entreprises par taille",
            'en': "World Bank classification of companies by size",
            'es': "Clasificación del Banco Mundial de empresas por tamaño",
            'de': "Weltbank-Klassifizierung von Unternehmen nach Größe",
            'it': "Classificazione della Banca Mondiale delle imprese per dimensione",
        },
        # Fonction pour générer automatiquement les traductions nationales
    }
    
    lines = []
    lines.append('-- =====================================================')
    lines.append('-- TRADUCTIONS I18N : NOMENCLATURES DE TAILLE - MONDE ENTIER')
    lines.append('-- =====================================================')
    lines.append('')
    
    # Générer toutes les traductions
    all_nomenclatures = []
    for country_code, nomenclatures in NOMENCLATURES.items():
        for code, desc_fr, _, country_name in nomenclatures:
            record_id = code.lower()
            
            # Si on a des traductions prédéfinies, on les utilise
            if record_id in DESCRIPTIONS:
                all_nomenclatures.append((record_id, DESCRIPTIONS[record_id]))
            else:
                # Sinon, on génère automatiquement
                desc_en = desc_fr  # Placeholder
                desc_es = desc_fr
                desc_de = desc_fr
                desc_it = desc_fr
                
                # Pour les nomenclatures nationales, on peut construire automatiquement
                if country_name:
                    desc_en = f"{desc_fr.split(' - ')[-1] if ' - ' in desc_fr else desc_fr} ({country_name})"
                    desc_es = f"{desc_fr.split(' - ')[-1] if ' - ' in desc_fr else desc_fr} ({country_name})"
                    desc_de = f"{desc_fr.split(' - ')[-1] if ' - ' in desc_fr else desc_fr} ({country_name})"
                    desc_it = f"{desc_fr.split(' - ')[-1] if ' - ' in desc_fr else desc_fr} ({country_name})"
                
                all_nomenclatures.append((record_id, {
                    'fr': desc_fr,
                    'en': desc_en,
                    'es': desc_es,
                    'de': desc_de,
                    'it': desc_it,
                }))
    
    # Écrire toutes les traductions
    for record_id, translations in all_nomenclatures:
        lines.append(f'-- {record_id.upper()}')
        for lang in ['fr', 'en', 'es', 'de', 'it']:
            text = translations[lang].replace("'", "\\'")
            lines.append(f"RELATE i18n_key:society_size_nomenclature_{record_id}_desc->i18n_translation->language:{lang}")
            lines.append(f"    SET text = '{text}';")
        lines.append('')
    
    return '\n'.join(lines)

if __name__ == '__main__':
    # Générer seeds
    with open('Lyxal_Solution/Lyxal_Surreal/base/reference/society/society_size_nomenclature/society_size_nomenclature_seeds.surql', 'w', encoding='utf-8') as f:
        f.write(generate_seeds())
    
    # Générer i18n keys
    with open('Lyxal_Solution/Lyxal_Surreal/base/reference/society/society_size_nomenclature/society_size_nomenclature_i18n_keys.surql', 'w', encoding='utf-8') as f:
        f.write(generate_i18n_keys())
    
    # Générer traductions
    with open('Lyxal_Solution/Lyxal_Surreal/base/reference/society/society_size_nomenclature/society_size_nomenclature_i18n_translations.surql', 'w', encoding='utf-8') as f:
        f.write(generate_translations())
    
    print("✅ Génération terminée !")
    print(f"   - Seeds: {sum(1 for items in NOMENCLATURES.values() for _ in items)} nomenclatures")
    print(f"   - Clés i18n: {sum(1 for items in NOMENCLATURES.values() for _ in items)}")
    print(f"   - Traductions: {sum(1 for items in NOMENCLATURES.values() for _ in items) * 5}")

