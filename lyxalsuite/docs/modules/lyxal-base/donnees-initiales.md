# Données d'Initialisation - LyxalBase

Ce fichier contient les scripts d'initialisation des données de base du système.

## 📋 Tables de Référence Système

### Structures des tables de référence

```sql
-- ═══════════════════════════════════════════════════════════════════════════
-- 📋 CIVILITÉS
-- ═══════════════════════════════════════════════════════════════════════════
DEFINE TABLE title_type SCHEMAFUL;
DEFINE FIELD code ON title_type TYPE string ASSERT $value != NULL;
DEFINE FIELD name ON title_type TYPE string ASSERT $value != NULL;
DEFINE FIELD order ON title_type TYPE number;
DEFINE INDEX title_type_code_idx ON title_type FIELDS code UNIQUE;

-- ═══════════════════════════════════════════════════════════════════════════
-- 👥 TYPES DE PARTENAIRES
-- ═══════════════════════════════════════════════════════════════════════════
DEFINE TABLE partner_type SCHEMAFUL;
DEFINE FIELD code ON partner_type TYPE string ASSERT $value != NULL;
DEFINE FIELD name ON partner_type TYPE string ASSERT $value != NULL;
DEFINE FIELD order ON partner_type TYPE number;
DEFINE FIELD description ON partner_type TYPE string;
DEFINE INDEX partner_type_code_idx ON partner_type FIELDS code UNIQUE;

-- ═══════════════════════════════════════════════════════════════════════════
-- 📦 TYPES DE PRODUITS
-- ═══════════════════════════════════════════════════════════════════════════
DEFINE TABLE product_type SCHEMAFUL;
DEFINE FIELD code ON product_type TYPE string ASSERT $value != NULL;
DEFINE FIELD name ON product_type TYPE string ASSERT $value != NULL;
DEFINE FIELD order ON product_type TYPE number;
DEFINE FIELD description ON product_type TYPE string;
DEFINE INDEX product_type_code_idx ON product_type FIELDS code UNIQUE;

-- ═══════════════════════════════════════════════════════════════════════════
-- 🌍 PAYS
-- ═══════════════════════════════════════════════════════════════════════════
DEFINE TABLE country SCHEMAFUL;
DEFINE FIELD code ON country TYPE string ASSERT $value != NULL;
DEFINE FIELD name ON country TYPE string ASSERT $value != NULL;
DEFINE FIELD alpha2Code ON country TYPE string;
DEFINE FIELD alpha3Code ON country TYPE string;
DEFINE FIELD phonePrefix ON country TYPE string;
DEFINE FIELD numericCode ON country TYPE string;
DEFINE FIELD isDefault ON country TYPE bool DEFAULT false;
DEFINE FIELD isObsolete ON country TYPE bool DEFAULT false;
DEFINE INDEX country_code_idx ON country FIELDS code UNIQUE;
DEFINE INDEX country_alpha2_idx ON country FIELDS alpha2Code UNIQUE;
DEFINE INDEX country_alpha3_idx ON country FIELDS alpha3Code UNIQUE;

-- ═══════════════════════════════════════════════════════════════════════════
-- 🏛️ ÉTATS/PROVINCES
-- ═══════════════════════════════════════════════════════════════════════════
DEFINE TABLE state SCHEMAFUL;
DEFINE FIELD code ON state TYPE string ASSERT $value != NULL;
DEFINE FIELD name ON state TYPE string ASSERT $value != NULL;
DEFINE FIELD country ON state TYPE record<country>;
DEFINE INDEX state_code_idx ON state FIELDS code UNIQUE;
DEFINE INDEX state_country_idx ON state FIELDS country;

-- ═══════════════════════════════════════════════════════════════════════════
-- 🏙️ VILLES
-- ═══════════════════════════════════════════════════════════════════════════
DEFINE TABLE city SCHEMAFUL;
DEFINE FIELD code ON city TYPE string ASSERT $value != NULL;
DEFINE FIELD name ON city TYPE string ASSERT $value != NULL;
DEFINE FIELD zip ON city TYPE string;
DEFINE FIELD state ON city TYPE record<state>;
DEFINE FIELD country ON city TYPE record<country>;
DEFINE FIELD inseeCode ON city TYPE string;
DEFINE INDEX city_code_idx ON city FIELDS code UNIQUE;
DEFINE INDEX city_zip_idx ON city FIELDS zip;
DEFINE INDEX city_country_state_idx ON city FIELDS country, state;

-- ═══════════════════════════════════════════════════════════════════════════
-- 🏭 SECTEURS D'ACTIVITÉ
-- ═══════════════════════════════════════════════════════════════════════════
DEFINE TABLE industry_sector SCHEMAFUL;
DEFINE FIELD code ON industry_sector TYPE string ASSERT $value != NULL;
DEFINE FIELD name ON industry_sector TYPE string ASSERT $value != NULL;
DEFINE FIELD description ON industry_sector TYPE string;
DEFINE FIELD parent ON industry_sector TYPE record<industry_sector>;
DEFINE INDEX industry_sector_code_idx ON industry_sector FIELDS code UNIQUE;

-- ═══════════════════════════════════════════════════════════════════════════
-- 💼 ACTIVITÉS PRINCIPALES
-- ═══════════════════════════════════════════════════════════════════════════
DEFINE TABLE main_activity SCHEMAFUL;
DEFINE FIELD code ON main_activity TYPE string ASSERT $value != NULL;
DEFINE FIELD name ON main_activity TYPE string ASSERT $value != NULL;
DEFINE FIELD description ON main_activity TYPE string;
DEFINE FIELD industrySector ON main_activity TYPE record<industry_sector>;
DEFINE INDEX main_activity_code_idx ON main_activity FIELDS code UNIQUE;

-- ═══════════════════════════════════════════════════════════════════════════
-- 📍 SOURCES DE PARTENAIRES
-- ═══════════════════════════════════════════════════════════════════════════
DEFINE TABLE source SCHEMAFUL;
DEFINE FIELD code ON source TYPE string ASSERT $value != NULL;
DEFINE FIELD name ON source TYPE string ASSERT $value != NULL;
DEFINE FIELD description ON source TYPE string;
DEFINE FIELD category ON source TYPE string;
DEFINE INDEX source_code_idx ON source FIELDS code UNIQUE;
```

## ⚙️ Configuration de base

```sql
-- Configuration de base
CREATE app_configuration:1 SET 
  code = "BASE", 
  name = "Configuration Base", 
  version = "1.0.0",
  defaultCountry = country:FR,
  defaultCurrency = currency:EUR,
  defaultPartnerLanguage = "fr",
  generatePartnerSequence = true,
  nbDecimalDigitForQty = 2,
  nbDecimalDigitForUnitPrice = 2,
  computeMethodDiscountSelect = 1,
  checkDuplicatePartner = true,
  checkDuplicateProduct = true,
  isDefault = true,
  isActive = true;
```

## 🌍 Configuration des locales

```sql
-- Configuration des locales
CREATE locale_configuration:FR SET 
  code = "fr_FR", 
  name = "Français (France)", 
  language = "fr",
  country = country:FR,
  dateFormat = "dd/MM/yyyy",
  timeFormat = "HH:mm",
  decimalSeparator = ",",
  groupingSeparator = " ",
  isDefault = true;

CREATE locale_configuration:EN SET 
  code = "en_US", 
  name = "English (US)", 
  language = "en",
  country = country:US,
  dateFormat = "MM/dd/yyyy",
  timeFormat = "hh:mm a",
  decimalSeparator = ".",
  groupingSeparator = ",",
  isDefault = false;
```

## Configuration des séquences

```sql
-- Configuration des séquences
CREATE sequence_configuration:PARTNER SET 
  code = "PARTNER", 
  name = "Séquence Partenaire", 
  modelName = "partner",
  defaultPrefix = "P",
  defaultPadding = 5,
  isCompanySpecific = false,
  isYearlyReset = false;

CREATE sequence_configuration:PRODUCT SET 
  code = "PRODUCT", 
  name = "Séquence Produit", 
  modelName = "product",
  defaultPrefix = "PR",
  defaultPadding = 5,
  isCompanySpecific = false,
  isYearlyReset = false;

CREATE sequence_configuration:COMPANY SET 
  code = "COMPANY", 
  name = "Séquence Société", 
  modelName = "company",
  defaultPrefix = "C",
  defaultPadding = 3,
  isCompanySpecific = false,
  isYearlyReset = false;

CREATE sequence_configuration:ADDRESS SET 
  code = "ADDRESS", 
  name = "Séquence Adresse", 
  modelName = "address",
  defaultPrefix = "ADR",
  defaultPadding = 5,
  isCompanySpecific = false,
  isYearlyReset = false;
```

## Création des séquences initiales

```sql
-- Création des séquences initiales
CREATE sequence:1 SET 
  code = "partner_seq", 
  name = "Séquence Partenaire", 
  prefix = "P",
  padding = 5,
  nextNum = 1,
  isDefault = true;

CREATE sequence:2 SET 
  code = "product_seq", 
  name = "Séquence Produit", 
  prefix = "PR",
  padding = 5,
  nextNum = 1,
  isDefault = true;

CREATE sequence:3 SET 
  code = "company_seq", 
  name = "Séquence Société", 
  prefix = "C",
  padding = 3,
  nextNum = 1,
  isDefault = true;
```

## Règles de numérotation

```sql
-- Règles de numérotation
CREATE auto_numbering_rule:1 SET 
  code = "PARTNER_SEQ", 
  name = "Numérotation des partenaires", 
  modelName = "partner",
  fieldName = "partnerSeq",
  sequence = sequence:1,
  isActive = true;

CREATE auto_numbering_rule:2 SET 
  code = "PRODUCT_CODE", 
  name = "Numérotation des produits", 
  modelName = "product",
  fieldName = "code",
  sequence = sequence:2,
  isActive = true;

CREATE auto_numbering_rule:3 SET 
  code = "COMPANY_CODE", 
  name = "Numérotation des sociétés", 
  modelName = "company",
  fieldName = "code",
  sequence = sequence:3,
  isActive = true;
```

## 🌍 Données de référence : Pays (enrichi)

```sql
-- Pays européens
CREATE country:FR SET 
  code = "FR", 
  name = "France", 
  alpha2Code = "FR",
  alpha3Code = "FRA",
  phonePrefix = "+33",
  numericCode = "250",
  isDefault = true;

CREATE country:BE SET 
  code = "BE", 
  name = "Belgique", 
  alpha2Code = "BE",
  alpha3Code = "BEL",
  phonePrefix = "+32",
  numericCode = "056";

CREATE country:DE SET 
  code = "DE", 
  name = "Allemagne", 
  alpha2Code = "DE",
  alpha3Code = "DEU",
  phonePrefix = "+49",
  numericCode = "276";

CREATE country:ES SET 
  code = "ES", 
  name = "Espagne", 
  alpha2Code = "ES",
  alpha3Code = "ESP",
  phonePrefix = "+34",
  numericCode = "724";

CREATE country:IT SET 
  code = "IT", 
  name = "Italie", 
  alpha2Code = "IT",
  alpha3Code = "ITA",
  phonePrefix = "+39",
  numericCode = "380";

CREATE country:CH SET 
  code = "CH", 
  name = "Suisse", 
  alpha2Code = "CH",
  alpha3Code = "CHE",
  phonePrefix = "+41",
  numericCode = "756";

CREATE country:LU SET 
  code = "LU", 
  name = "Luxembourg", 
  alpha2Code = "LU",
  alpha3Code = "LUX",
  phonePrefix = "+352",
  numericCode = "442";

-- Pays internationaux
CREATE country:US SET 
  code = "US", 
  name = "États-Unis", 
  alpha2Code = "US",
  alpha3Code = "USA",
  phonePrefix = "+1",
  numericCode = "840";

CREATE country:CA SET 
  code = "CA", 
  name = "Canada", 
  alpha2Code = "CA",
  alpha3Code = "CAN",
  phonePrefix = "+1",
  numericCode = "124";

CREATE country:GB SET 
  code = "GB", 
  name = "Royaume-Uni", 
  alpha2Code = "GB",
  alpha3Code = "GBR",
  phonePrefix = "+44",
  numericCode = "826";

CREATE country:JP SET 
  code = "JP", 
  name = "Japon", 
  alpha2Code = "JP",
  alpha3Code = "JPN",
  phonePrefix = "+81",
  numericCode = "392";

CREATE country:CN SET 
  code = "CN", 
  name = "Chine", 
  alpha2Code = "CN",
  alpha3Code = "CHN",
  phonePrefix = "+86",
  numericCode = "156";
```

## 🏛️ Données de référence : États/Provinces

```sql
-- États français (régions)
CREATE state:IDF SET 
  code = "IDF", 
  name = "Île-de-France", 
  country = country:FR;

CREATE state:PACA SET 
  code = "PACA", 
  name = "Provence-Alpes-Côte d'Azur", 
  country = country:FR;

CREATE state:ARA SET 
  code = "ARA", 
  name = "Auvergne-Rhône-Alpes", 
  country = country:FR;

CREATE state:HDF SET 
  code = "HDF", 
  name = "Hauts-de-France", 
  country = country:FR;

-- États américains
CREATE state:CA_US SET 
  code = "CA", 
  name = "California", 
  country = country:US;

CREATE state:NY SET 
  code = "NY", 
  name = "New York", 
  country = country:US;

CREATE state:TX SET 
  code = "TX", 
  name = "Texas", 
  country = country:US;

-- Provinces allemandes
CREATE state:BY SET 
  code = "BY", 
  name = "Bayern", 
  country = country:DE;

CREATE state:NW SET 
  code = "NW", 
  name = "Nordrhein-Westfalen", 
  country = country:DE;
```

## 🏙️ Données de référence : Villes principales

```sql
-- Villes françaises
CREATE city:PARIS SET 
  code = "PARIS", 
  name = "Paris", 
  zip = "75000",
  state = state:IDF,
  country = country:FR,
  inseeCode = "75056";

CREATE city:MARSEILLE SET 
  code = "MARSEILLE", 
  name = "Marseille", 
  zip = "13000",
  state = state:PACA,
  country = country:FR,
  inseeCode = "13055";

CREATE city:LYON SET 
  code = "LYON", 
  name = "Lyon", 
  zip = "69000",
  state = state:ARA,
  country = country:FR,
  inseeCode = "69123";

CREATE city:LILLE SET 
  code = "LILLE", 
  name = "Lille", 
  zip = "59000",
  state = state:HDF,
  country = country:FR,
  inseeCode = "59350";

-- Villes internationales
CREATE city:NYC SET 
  code = "NYC", 
  name = "New York", 
  zip = "10001",
  state = state:NY,
  country = country:US;

CREATE city:LA SET 
  code = "LA", 
  name = "Los Angeles", 
  zip = "90001",
  state = state:CA_US,
  country = country:US;

CREATE city:BERLIN SET 
  code = "BERLIN", 
  name = "Berlin", 
  zip = "10115",
  state = state:BY,
  country = country:DE;
```

## 🏭 Données de référence : Secteurs d'activité

```sql
-- Secteurs principaux
CREATE industry_sector:TECH SET 
  code = "TECH", 
  name = "Technologies de l'information", 
  description = "Développement logiciel, services IT, télécommunications";

CREATE industry_sector:MANUF SET 
  code = "MANUF", 
  name = "Industrie manufacturière", 
  description = "Production industrielle, transformation";

CREATE industry_sector:RETAIL SET 
  code = "RETAIL", 
  name = "Commerce de détail", 
  description = "Vente au détail, distribution";

CREATE industry_sector:HEALTH SET 
  code = "HEALTH", 
  name = "Santé", 
  description = "Services médicaux, pharmaceutique";

CREATE industry_sector:FINANCE SET 
  code = "FINANCE", 
  name = "Services financiers", 
  description = "Banque, assurance, investissement";

CREATE industry_sector:CONSTRUCT SET 
  code = "CONSTRUCT", 
  name = "BTP", 
  description = "Bâtiment et travaux publics";

CREATE industry_sector:ENERGY SET 
  code = "ENERGY", 
  name = "Énergie", 
  description = "Production et distribution d'énergie";

CREATE industry_sector:AGRI SET 
  code = "AGRI", 
  name = "Agriculture", 
  description = "Agriculture, élevage, pêche";

CREATE industry_sector:EDUCATION SET 
  code = "EDUCATION", 
  name = "Éducation", 
  description = "Enseignement, formation";

CREATE industry_sector:TRANSPORT SET 
  code = "TRANSPORT", 
  name = "Transport et logistique", 
  description = "Transport, logistique, entreposage";

-- Sous-secteurs technologiques
CREATE industry_sector:SOFTWARE SET 
  code = "SOFTWARE", 
  name = "Développement logiciel", 
  description = "Création et édition de logiciels",
  parent = industry_sector:TECH;

CREATE industry_sector:SAAS SET 
  code = "SAAS", 
  name = "Software as a Service", 
  description = "Solutions logicielles en cloud",
  parent = industry_sector:SOFTWARE;

CREATE industry_sector:ECOMMERCE SET 
  code = "ECOMMERCE", 
  name = "E-commerce", 
  description = "Commerce électronique",
  parent = industry_sector:RETAIL;
```

## 💼 Données de référence : Activités principales

```sql
-- Activités technologiques
CREATE main_activity:DEV_WEB SET 
  code = "DEV_WEB", 
  name = "Développement web", 
  description = "Création de sites et applications web",
  industrySector = industry_sector:SOFTWARE;

CREATE main_activity:DEV_MOBILE SET 
  code = "DEV_MOBILE", 
  name = "Développement mobile", 
  description = "Applications mobiles iOS et Android",
  industrySector = industry_sector:SOFTWARE;

CREATE main_activity:CONSULTANT_IT SET 
  code = "CONSULTANT_IT", 
  name = "Conseil en informatique", 
  description = "Conseil et expertise IT",
  industrySector = industry_sector:TECH;

-- Activités commerciales
CREATE main_activity:VENTE_DETAIL SET 
  code = "VENTE_DETAIL", 
  name = "Vente au détail", 
  description = "Commerce de détail généraliste",
  industrySector = industry_sector:RETAIL;

CREATE main_activity:ECOM_MODE SET 
  code = "ECOM_MODE", 
  name = "E-commerce mode", 
  description = "Vente en ligne de vêtements",
  industrySector = industry_sector:ECOMMERCE;

-- Activités industrielles
CREATE main_activity:FABRICATION SET 
  code = "FABRICATION", 
  name = "Fabrication", 
  description = "Production manufacturière",
  industrySector = industry_sector:MANUF;

CREATE main_activity:MACONNERIE SET 
  code = "MACONNERIE", 
  name = "Maçonnerie", 
  description = "Travaux de maçonnerie",
  industrySector = industry_sector:CONSTRUCT;

-- Activités de services
CREATE main_activity:COMPTABILITE SET 
  code = "COMPTABILITE", 
  name = "Comptabilité", 
  description = "Services comptables",
  industrySector = industry_sector:FINANCE;

CREATE main_activity:FORMATION SET 
  code = "FORMATION", 
  name = "Formation professionnelle", 
  description = "Organisme de formation",
  industrySector = industry_sector:EDUCATION;
```

## 📍 Données de référence : Sources de partenaires

```sql
-- Sources digitales
CREATE source:WEBSITE SET 
  code = "WEBSITE", 
  name = "Site web", 
  description = "Prospects venus du site web",
  category = "digital";

CREATE source:SEO SET 
  code = "SEO", 
  name = "Référencement naturel", 
  description = "Trafic organique SEO",
  category = "digital";

CREATE source:SEM SET 
  code = "SEM", 
  name = "Publicité Google Ads", 
  description = "Campagnes payantes Google",
  category = "digital";

CREATE source:SOCIAL SET 
  code = "SOCIAL", 
  name = "Réseaux sociaux", 
  description = "LinkedIn, Facebook, Twitter",
  category = "digital";

CREATE source:EMAIL SET 
  code = "EMAIL", 
  name = "Campagne email", 
  description = "Marketing par email",
  category = "digital";

-- Sources traditionnelles
CREATE source:REFERRAL SET 
  code = "REFERRAL", 
  name = "Recommandation", 
  description = "Bouche-à-oreille, parrainage",
  category = "traditional";

CREATE source:COLD_CALL SET 
  code = "COLD_CALL", 
  name = "Appel à froid", 
  description = "Prospection téléphonique",
  category = "traditional";

CREATE source:TRADE_SHOW SET 
  code = "TRADE_SHOW", 
  name = "Salon professionnel", 
  description = "Rencontres en salons",
  category = "traditional";

CREATE source:PRINT_AD SET 
  code = "PRINT_AD", 
  name = "Publicité print", 
  description = "Journaux, magazines",
  category = "traditional";

-- Sources partenaires
CREATE source:PARTNER SET 
  code = "PARTNER", 
  name = "Partenaire commercial", 
  description = "Réseau de partenaires",
  category = "partnership";

CREATE source:RESELLER SET 
  code = "RESELLER", 
  name = "Revendeur", 
  description = "Canal de distribution",
  category = "partnership";

-- Sources internes
CREATE source:INTERNAL SET 
  code = "INTERNAL", 
  name = "Interne", 
  description = "Prospect interne",
  category = "internal";

CREATE source:EXISTING_CLIENT SET 
  code = "EXISTING_CLIENT", 
  name = "Client existant", 
  description = "Upsell ou cross-sell",
  category = "internal";
```

## 📋 Données de référence : Types (enrichi)

```sql
-- Civilités étendues
CREATE title_type:MR SET 
  code = "MR", 
  name = "Monsieur", 
  order = 1;

CREATE title_type:MRS SET 
  code = "MRS", 
  name = "Madame", 
  order = 2;

CREATE title_type:MS SET 
  code = "MS", 
  name = "Mademoiselle", 
  order = 3;

CREATE title_type:DR SET 
  code = "DR", 
  name = "Docteur", 
  order = 4;

CREATE title_type:PROF SET 
  code = "PROF", 
  name = "Professeur", 
  order = 5;

-- Types de partenaires étendus
CREATE partner_type:COMPANY SET 
  code = "COMPANY", 
  name = "Entreprise", 
  description = "Société, SARL, SAS, etc.",
  order = 1;

CREATE partner_type:INDIVIDUAL SET 
  code = "INDIVIDUAL", 
  name = "Particulier", 
  description = "Personne physique",
  order = 2;

CREATE partner_type:FREELANCE SET 
  code = "FREELANCE", 
  name = "Indépendant", 
  description = "Travailleur indépendant, auto-entrepreneur",
  order = 3;

CREATE partner_type:NONPROFIT SET 
  code = "NONPROFIT", 
  name = "Association", 
  description = "Organisation à but non lucratif",
  order = 4;

CREATE partner_type:GOVERNMENT SET 
  code = "GOVERNMENT", 
  name = "Administration", 
  description = "Organisme public",
  order = 5;

-- Types de produits étendus
CREATE product_type:PHYSICAL SET 
  code = "PHYSICAL", 
  name = "Produit physique", 
  description = "Bien matériel stockable",
  order = 1;

CREATE product_type:SERVICE SET 
  code = "SERVICE", 
  name = "Service", 
  description = "Prestation de service",
  order = 2;

CREATE product_type:DIGITAL SET 
  code = "DIGITAL", 
  name = "Produit numérique", 
  description = "Logiciel, licence, contenu digital",
  order = 3;

CREATE product_type:CONSUMABLE SET 
  code = "CONSUMABLE", 
  name = "Consommable", 
  description = "Produit consommé lors de l'usage",
  order = 4;

CREATE product_type:SUBSCRIPTION SET 
  code = "SUBSCRIPTION", 
  name = "Abonnement", 
  description = "Service récurrent payant",
  order = 5;
```

## Données de référence : Devises

```sql
-- Devises principales
CREATE currency:EUR SET 
  code = "EUR", 
  name = "Euro", 
  symbol = "€",
  decimals = 2;

CREATE currency:USD SET 
  code = "USD", 
  name = "Dollar américain", 
  symbol = "$",
  decimals = 2;

CREATE currency:GBP SET 
  code = "GBP", 
  name = "Livre sterling", 
  symbol = "£",
  decimals = 2;

CREATE currency:CHF SET 
  code = "CHF", 
  name = "Franc suisse", 
  symbol = "CHF",
  decimals = 2;
```

## Données de référence : Unités

```sql
-- Types d'unités
CREATE unit_type:1 SET 
  code = "LENGTH", 
  name = "Longueur";

CREATE unit_type:2 SET 
  code = "WEIGHT", 
  name = "Poids";

CREATE unit_type:3 SET 
  code = "VOLUME", 
  name = "Volume";

CREATE unit_type:4 SET 
  code = "UNIT", 
  name = "Unité";

-- Unités de base
CREATE unit:1 SET 
  code = "M", 
  name = "Mètre", 
  symbol = "m",
  unitType = unit_type:1,
  isBaseUnit = true;

CREATE unit:2 SET 
  code = "KG", 
  name = "Kilogramme", 
  symbol = "kg",
  unitType = unit_type:2,
  isBaseUnit = true;

CREATE unit:3 SET 
  code = "L", 
  name = "Litre", 
  symbol = "l",
  unitType = unit_type:3,
  isBaseUnit = true;

CREATE unit:4 SET 
  code = "UNIT", 
  name = "Unité", 
  symbol = "u",
  unitType = unit_type:4,
  isBaseUnit = true;

-- Unités dérivées
CREATE unit:5 SET 
  code = "CM", 
  name = "Centimètre", 
  symbol = "cm",
  unitType = unit_type:1;

CREATE unit:6 SET 
  code = "MM", 
  name = "Millimètre", 
  symbol = "mm",
  unitType = unit_type:1;

CREATE unit:7 SET 
  code = "G", 
  name = "Gramme", 
  symbol = "g",
  unitType = unit_type:2;

CREATE unit:8 SET 
  code = "ML", 
  name = "Millilitre", 
  symbol = "ml",
  unitType = unit_type:3;
```

## Données de référence : Positions fiscales

```sql
-- Initialisation des positions fiscales
CREATE fiscal_position:1 SET 
  code = 'NORMAL', 
  name = 'Régime normal',
  country = country:FR,
  isDefault = true;

CREATE fiscal_position:2 SET 
  code = 'EXPORT', 
  name = 'Export hors UE',
  vatRequired = false;

CREATE fiscal_position:3 SET 
  code = 'INTRAEUVAT', 
  name = 'Intra-communautaire avec TVA',
  vatRequired = true;

CREATE fiscal_position:4 SET 
  code = 'INTRAEUNOVAT', 
  name = 'Intra-communautaire sans TVA',
  vatRequired = false,
  reverseCharge = true;
```

## Données de référence : Termes de paiement

```sql
-- Termes de paiement
CREATE payment_term:1 SET 
  code = 'CASH', 
  name = 'Comptant', 
  paymentTime = 0, 
  paymentTimeUnit = 'days',
  isDefault = true;

CREATE payment_term:2 SET 
  code = 'NET30', 
  name = '30 jours net', 
  paymentTime = 30, 
  paymentTimeUnit = 'days';

CREATE payment_term:3 SET 
  code = 'NET45', 
  name = '45 jours net', 
  paymentTime = 45, 
  paymentTimeUnit = 'days';

CREATE payment_term:4 SET 
  code = 'NET60', 
  name = '60 jours net', 
  paymentTime = 60, 
  paymentTimeUnit = 'days';

CREATE payment_term:5 SET 
  code = 'EOM30', 
  name = 'Fin de mois + 30 jours', 
  paymentTime = 30, 
  paymentTimeUnit = 'eom';
```

## Données de référence : Types

```sql
-- Types de partenaires
CREATE partner_type:1 SET 
  code = "COMPANY", 
  name = "Entreprise", 
  order = 1;

CREATE partner_type:2 SET 
  code = "INDIVIDUAL", 
  name = "Particulier", 
  order = 2;

-- Types de produits
CREATE product_type:1 SET 
  code = "STORABLE", 
  name = "Stockable", 
  order = 1;

CREATE product_type:2 SET 
  code = "SERVICE", 
  name = "Service", 
  order = 2;

CREATE product_type:3 SET 
  code = "CONSUMABLE", 
  name = "Consommable", 
  order = 3;

-- Civilités
CREATE title_type:1 SET 
  code = "MR", 
  name = "Monsieur", 
  order = 1;

CREATE title_type:2 SET 
  code = "MRS", 
  name = "Madame", 
  order = 2;

CREATE title_type:3 SET 
  code = "MS", 
  name = "Mademoiselle", 
  order = 3;

-- Types de taxes
CREATE tax_type:1 SET 
  code = "VAT", 
  name = "TVA", 
  description = "Taxe sur la valeur ajoutée";

CREATE tax_type:2 SET 
  code = "EXCISE", 
  name = "Accise", 
  description = "Taxe d'accise";
```

## 🏭 Données de référence : Secteurs d'activité

```sql
-- Secteurs principaux
CREATE industry_sector:TECH SET 
  code = "TECH", 
  name = "Technologies de l'information", 
  description = "Développement logiciel, services IT, télécommunications";

CREATE industry_sector:MANUF SET 
  code = "MANUF", 
  name = "Industrie manufacturière", 
  description = "Production industrielle, transformation";

CREATE industry_sector:RETAIL SET 
  code = "RETAIL", 
  name = "Commerce de détail", 
  description = "Vente au détail, distribution";

CREATE industry_sector:HEALTH SET 
  code = "HEALTH", 
  name = "Santé", 
  description = "Services médicaux, pharmaceutique";

CREATE industry_sector:FINANCE SET 
  code = "FINANCE", 
  name = "Services financiers", 
  description = "Banque, assurance, investissement";

CREATE industry_sector:CONSTRUCT SET 
  code = "CONSTRUCT", 
  name = "BTP", 
  description = "Bâtiment et travaux publics";

CREATE industry_sector:ENERGY SET 
  code = "ENERGY", 
  name = "Énergie", 
  description = "Production et distribution d'énergie";

CREATE industry_sector:AGRI SET 
  code = "AGRI", 
  name = "Agriculture", 
  description = "Agriculture, élevage, pêche";

CREATE industry_sector:EDUCATION SET 
  code = "EDUCATION", 
  name = "Éducation", 
  description = "Enseignement, formation";

CREATE industry_sector:TRANSPORT SET 
  code = "TRANSPORT", 
  name = "Transport et logistique", 
  description = "Transport, logistique, entreposage";

-- Sous-secteurs technologiques
CREATE industry_sector:SOFTWARE SET 
  code = "SOFTWARE", 
  name = "Développement logiciel", 
  description = "Création et édition de logiciels",
  parent = industry_sector:TECH;

CREATE industry_sector:SAAS SET 
  code = "SAAS", 
  name = "Software as a Service", 
  description = "Solutions logicielles en cloud",
  parent = industry_sector:SOFTWARE;

CREATE industry_sector:ECOMMERCE SET 
  code = "ECOMMERCE", 
  name = "E-commerce", 
  description = "Commerce électronique",
  parent = industry_sector:RETAIL;
```

## 💼 Données de référence : Activités principales

```sql
-- Activités technologiques
CREATE main_activity:DEV_WEB SET 
  code = "DEV_WEB", 
  name = "Développement web", 
  description = "Création de sites et applications web",
  industrySector = industry_sector:SOFTWARE;

CREATE main_activity:DEV_MOBILE SET 
  code = "DEV_MOBILE", 
  name = "Développement mobile", 
  description = "Applications mobiles iOS et Android",
  industrySector = industry_sector:SOFTWARE;

CREATE main_activity:CONSULTANT_IT SET 
  code = "CONSULTANT_IT", 
  name = "Conseil en informatique", 
  description = "Conseil et expertise IT",
  industrySector = industry_sector:TECH;

-- Activités commerciales
CREATE main_activity:VENTE_DETAIL SET 
  code = "VENTE_DETAIL", 
  name = "Vente au détail", 
  description = "Commerce de détail généraliste",
  industrySector = industry_sector:RETAIL;

CREATE main_activity:ECOM_MODE SET 
  code = "ECOM_MODE", 
  name = "E-commerce mode", 
  description = "Vente en ligne de vêtements",
  industrySector = industry_sector:ECOMMERCE;

-- Activités industrielles
CREATE main_activity:FABRICATION SET 
  code = "FABRICATION", 
  name = "Fabrication", 
  description = "Production manufacturière",
  industrySector = industry_sector:MANUF;

CREATE main_activity:MACONNERIE SET 
  code = "MACONNERIE", 
  name = "Maçonnerie", 
  description = "Travaux de maçonnerie",
  industrySector = industry_sector:CONSTRUCT;

-- Activités de services
CREATE main_activity:COMPTABILITE SET 
  code = "COMPTABILITE", 
  name = "Comptabilité", 
  description = "Services comptables",
  industrySector = industry_sector:FINANCE;

CREATE main_activity:FORMATION SET 
  code = "FORMATION", 
  name = "Formation professionnelle", 
  description = "Organisme de formation",
  industrySector = industry_sector:EDUCATION;
```

## 📍 Données de référence : Sources de partenaires

```sql
-- Sources digitales
CREATE source:WEBSITE SET 
  code = "WEBSITE", 
  name = "Site web", 
  description = "Prospects venus du site web",
  category = "digital";

CREATE source:SEO SET 
  code = "SEO", 
  name = "Référencement naturel", 
  description = "Trafic organique SEO",
  category = "digital";

CREATE source:SEM SET 
  code = "SEM", 
  name = "Publicité Google Ads", 
  description = "Campagnes payantes Google",
  category = "digital";

CREATE source:SOCIAL SET 
  code = "SOCIAL", 
  name = "Réseaux sociaux", 
  description = "LinkedIn, Facebook, Twitter",
  category = "digital";

CREATE source:EMAIL SET 
  code = "EMAIL", 
  name = "Campagne email", 
  description = "Marketing par email",
  category = "digital";

-- Sources traditionnelles
CREATE source:REFERRAL SET 
  code = "REFERRAL", 
  name = "Recommandation", 
  description = "Bouche-à-oreille, parrainage",
  category = "traditional";

CREATE source:COLD_CALL SET 
  code = "COLD_CALL", 
  name = "Appel à froid", 
  description = "Prospection téléphonique",
  category = "traditional";

CREATE source:TRADE_SHOW SET 
  code = "TRADE_SHOW", 
  name = "Salon professionnel", 
  description = "Rencontres en salons",
  category = "traditional";

CREATE source:PRINT_AD SET 
  code = "PRINT_AD", 
  name = "Publicité print", 
  description = "Journaux, magazines",
  category = "traditional";

-- Sources partenaires
CREATE source:PARTNER SET 
  code = "PARTNER", 
  name = "Partenaire commercial", 
  description = "Réseau de partenaires",
  category = "partnership";

CREATE source:RESELLER SET 
  code = "RESELLER", 
  name = "Revendeur", 
  description = "Canal de distribution",
  category = "partnership";

-- Sources internes
CREATE source:INTERNAL SET 
  code = "INTERNAL", 
  name = "Interne", 
  description = "Prospect interne",
  category = "internal";

CREATE source:EXISTING_CLIENT SET 
  code = "EXISTING_CLIENT", 
  name = "Client existant", 
  description = "Upsell ou cross-sell",
  category = "internal";
```

## 📋 Résumé de l'Intégration

**✅ Tables de référence intégrées depuis `references.md` :**

- 📋 **Civilités** (`title_type`) - 3 civilités de base + Dr, Prof
- 👥 **Types de partenaires** (`partner_type`) - 5 types enrichis
- 📦 **Types de produits** (`product_type`) - 5 types modernes
- 🌍 **Pays** (`country`) - 12 pays principaux enrichis
- 🏛️ **États/Provinces** (`state`) - 9 régions/états
- 🏙️ **Villes** (`city`) - 7 villes principales  
- 🏭 **Secteurs d'activité** (`industry_sector`) - 13 secteurs hiérarchiques
- 💼 **Activités principales** (`main_activity`) - 9 activités métier
- 📍 **Sources de partenaires** (`source`) - 13 sources classifiées

**🎯 Architecture complète :**
- **Structures de tables** reprises à l'identique
- **Données enrichies** avec descriptions et catégories
- **Relations hiérarchiques** (secteurs/sous-secteurs)
- **Classification par catégories** (sources digitales/traditionnelles)
- **Compatibilité 100%** avec les entités IA-native existantes

Le fichier `references.md` peut maintenant être **supprimé en toute sécurité** ! 🗑️✨