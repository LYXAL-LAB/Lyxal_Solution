DEFINE TABLE IF NOT EXISTS i18n_locale 
	TYPE NORMAL SCHEMAFULL 
	COMMENT 'Référentiel des locales (langue/format) pour i18n' 
	PERMISSIONS FULL;

	-- ------------------------------
	-- FIELDS
	-- ------------------------------

	-- Identité
	DEFINE FIELD code ON i18n_locale 
	TYPE string 
	COMMENT 'Code BCP 47 (ex: fr-FR, en-US)';

	DEFINE FIELD language ON i18n_locale 
	TYPE record<i18n_language> 
	REFERENCE ON DELETE REJECT
	VALUE IF $value == NONE then NONE else type::thing('i18n_language', $value) end
	COMMENT 'Langue (référence i18n_language)';

	DEFINE FIELD country ON i18n_locale 
	TYPE option<record<base_country>>
	REFERENCE ON DELETE REJECT
	VALUE IF $value == NONE then NONE else type::thing('base_country', $value) end
	COMMENT 'Pays (référence base_country)';

	DEFINE FIELD displayName ON i18n_locale 
	TYPE option<string>
	COMMENT 'Libellé d\'affichage (ex: French (France))';

	DEFINE FIELD nativeDisplayName ON i18n_locale 
	TYPE option<string>
	COMMENT 'Libellé natif (ex: Français (France))';

	-- Formats de date/heure (mutualisés)
	DEFINE FIELD datetimeFormat ON i18n_locale 
	TYPE option<record<i18n_datetime_format>> 
	REFERENCE ON DELETE REJECT
	VALUE IF $value == NONE then NONE else type::thing('i18n_datetime_format', $value)
	 end
	COMMENT 'Profil de formats date/heure (référence i18n_datetime_format)';

	-- Fuseau horaire
	DEFINE FIELD timezone ON i18n_locale TYPE option<record<base_timezone>> 
	COMMENT 'Fuseau horaire (référence base_timezone)';
	
	-- Formats numériques
    DEFINE FIELD decimalSeparator ON i18n_locale 
	TYPE option<record<i18n_decimal_separator>> 
    REFERENCE ON DELETE REJECT
    VALUE IF $value == NONE then NONE 
	else type::thing('i18n_decimal_separator', $value) end
    COMMENT 'Séparateur décimal (référence contrôlée)';

    DEFINE FIELD thousandSeparator ON i18n_locale 
	TYPE option<record<i18n_thousand_separator>> 
    REFERENCE ON DELETE REJECT
    VALUE IF $value == NONE then NONE 
	else type::thing('i18n_thousand_separator', $value) end
    COMMENT 'Séparateur de milliers (référence contrôlée)';

	-- Monétaire
	DEFINE FIELD currency ON i18n_locale 
	TYPE option<record<base_currency>> 
	REFERENCE ON DELETE REJECT
	VALUE IF $value == NONE then NONE else type::thing('base_currency', $value) end
	COMMENT 'Devise par défaut';

    DEFINE FIELD currencySymbolPosition ON i18n_locale 
	TYPE option<record<i18n_currency_symbol_position>> 
    REFERENCE ON DELETE REJECT
    VALUE IF $value == NONE then NONE 
	else type::thing('i18n_currency_symbol_position', $value) end
    COMMENT 'Position du symbole (référence contrôlée)';

	DEFINE FIELD spaceBetweenSymbolAndAmount ON i18n_locale 
	TYPE bool 
	DEFAULT true
	COMMENT 'Espace entre symbole et montant (ex: fr-FR: true)';

	-- Adresse
	DEFINE FIELD addressFormat ON i18n_locale 
	TYPE option<record<base_address_format>> 
	REFERENCE ON DELETE REJECT
	VALUE IF $value == NONE then NONE else type::thing('base_address_format', $value) end
	COMMENT 'Référence vers base_address_format (format d\'adresse)';

	-- État
	DEFINE FIELD isActive ON i18n_locale 
	TYPE bool DEFAULT true 
	COMMENT 'Locale active';

	-- Audit
	DEFINE FIELD created_at ON i18n_locale 
	TYPE datetime 
	COMMENT 'Date de création';
	
	DEFINE FIELD updated_at ON i18n_locale 
	TYPE datetime 
	COMMENT 'Date de modification';

	-- INDEXES
	DEFINE INDEX idx_i18n_locale_code_unique ON i18n_locale 
	FIELDS code UNIQUE
	COMMENT 'Unicité du code de la locale';
	
	DEFINE INDEX idx_i18n_locale_language ON i18n_locale 
	FIELDS language
	COMMENT 'Index sur la langue';
	
	DEFINE INDEX idx_i18n_locale_displayName ON i18n_locale 
	FIELDS displayName
	COMMENT 'Index sur le libellé d\'affichage';
	
	DEFINE INDEX idx_i18n_locale_nativeDisplayName ON i18n_locale 
	FIELDS nativeDisplayName
	COMMENT 'Index sur le libellé natif';
	
	DEFINE INDEX idx_i18n_locale_addressFormat ON i18n_locale 
	FIELDS addressFormat
	COMMENT 'Index sur le format d\'adresse';