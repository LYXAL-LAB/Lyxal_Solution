-- =================================================================================================
-- I18N TRANSLATIONS: business_company_category
-- Total: 4 × 2 (nom + desc) × 5 langues = 40 traductions
-- =================================================================================================

-- Catégorie MIC: Microentreprise
----------------------------------------------------------------------------------------------------

RELATE i18n_key:i18n_company_category_mic_name->i18n_translation->i18n_language:fr
    SET text = 'Microentreprise';

RELATE i18n_key:i18n_company_category_mic_name->i18n_translation->i18n_language:en
    SET text = 'Microenterprise';

RELATE i18n_key:i18n_company_category_mic_name->i18n_translation->i18n_language:es
    SET text = 'Microempresa';

RELATE i18n_key:i18n_company_category_mic_name->i18n_translation->i18n_language:de
    SET text = 'Kleinstunternehmen';

RELATE i18n_key:i18n_company_category_mic_name->i18n_translation->i18n_language:it
    SET text = 'Microimpresa';

RELATE i18n_key:i18n_company_category_mic_description->i18n_translation->i18n_language:fr
    SET text = 'Entreprise occupant moins de 10 personnes, et qui a un chiffre d\'affaires annuel ou un total de bilan n\'excédant pas 2 millions d\'euros';

RELATE i18n_key:i18n_company_category_mic_description->i18n_translation->i18n_language:en
    SET text = 'Enterprise with fewer than 10 employees, and with annual turnover or total balance sheet not exceeding 2 million euros';

RELATE i18n_key:i18n_company_category_mic_description->i18n_translation->i18n_language:es
    SET text = 'Empresa con menos de 10 empleados, y con volumen de negocio anual o balance total que no exceda de 2 millones de euros';

RELATE i18n_key:i18n_company_category_mic_description->i18n_translation->i18n_language:de
    SET text = 'Unternehmen mit weniger als 10 Beschäftigten und einem Jahresumsatz oder einer Bilanzsumme von höchstens 2 Millionen Euro';

RELATE i18n_key:i18n_company_category_mic_description->i18n_translation->i18n_language:it
    SET text = 'Impresa con meno di 10 dipendenti e con fatturato annuo o totale di bilancio non superiore a 2 milioni di euro';

-- Catégorie PME: Petite ou Moyenne Entreprise
----------------------------------------------------------------------------------------------------

RELATE i18n_key:i18n_company_category_pme_name->i18n_translation->i18n_language:fr
    SET text = 'Petite ou Moyenne Entreprise';

RELATE i18n_key:i18n_company_category_pme_name->i18n_translation->i18n_language:en
    SET text = 'Small or Medium Enterprise';

RELATE i18n_key:i18n_company_category_pme_name->i18n_translation->i18n_language:es
    SET text = 'Pequeña o Mediana Empresa';

RELATE i18n_key:i18n_company_category_pme_name->i18n_translation->i18n_language:de
    SET text = 'Kleine oder mittlere Unternehmen';

RELATE i18n_key:i18n_company_category_pme_name->i18n_translation->i18n_language:it
    SET text = 'Piccola o Media Impresa';

RELATE i18n_key:i18n_company_category_pme_description->i18n_translation->i18n_language:fr
    SET text = 'Entreprise occupant moins de 250 personnes, et qui a un chiffre d\'affaires annuel inférieur à 50 millions d\'euros ou un total de bilan n\'excédant pas 43 millions d\'euros';

RELATE i18n_key:i18n_company_category_pme_description->i18n_translation->i18n_language:en
    SET text = 'Enterprise with fewer than 250 employees, and with annual turnover less than 50 million euros or total balance sheet not exceeding 43 million euros';

RELATE i18n_key:i18n_company_category_pme_description->i18n_translation->i18n_language:es
    SET text = 'Empresa con menos de 250 empleados, y con volumen de negocio anual inferior a 50 millones de euros o balance total que no exceda de 43 millones de euros';

RELATE i18n_key:i18n_company_category_pme_description->i18n_translation->i18n_language:de
    SET text = 'Unternehmen mit weniger als 250 Beschäftigten und einem Jahresumsatz von weniger als 50 Millionen Euro oder einer Bilanzsumme von höchstens 43 Millionen Euro';

RELATE i18n_key:i18n_company_category_pme_description->i18n_translation->i18n_language:it
    SET text = 'Impresa con meno di 250 dipendenti e con fatturato annuo inferiore a 50 milioni di euro o totale di bilancio non superiore a 43 milioni di euro';

-- Catégorie ETI: Entreprise de Taille Intermédiaire
----------------------------------------------------------------------------------------------------

RELATE i18n_key:i18n_company_category_eti_name->i18n_translation->i18n_language:fr
    SET text = 'Entreprise de Taille Intermédiaire';

RELATE i18n_key:i18n_company_category_eti_name->i18n_translation->i18n_language:en
    SET text = 'Mid-sized Enterprise';

RELATE i18n_key:i18n_company_category_eti_name->i18n_translation->i18n_language:es
    SET text = 'Empresa de Tamaño Intermedio';

RELATE i18n_key:i18n_company_category_eti_name->i18n_translation->i18n_language:de
    SET text = 'Mittelständisches Unternehmen';

RELATE i18n_key:i18n_company_category_eti_name->i18n_translation->i18n_language:it
    SET text = 'Impresa di Dimensioni Intermedie';

RELATE i18n_key:i18n_company_category_eti_description->i18n_translation->i18n_language:fr
    SET text = 'Entreprise ayant entre 250 et 4 999 salariés, et soit un chiffre d\'affaires annuel n\'excédant pas 1,5 milliard d\'euros, soit un total de bilan n\'excédant pas 2 milliards d\'euros. Une entreprise de moins de 250 salariés mais avec plus de 50 millions d\'euros de CA et plus de 43 millions d\'euros de bilan est aussi considérée comme une ETI';

RELATE i18n_key:i18n_company_category_eti_description->i18n_translation->i18n_language:en
    SET text = 'Enterprise with between 250 and 4,999 employees, and either annual turnover not exceeding 1.5 billion euros, or total balance sheet not exceeding 2 billion euros. An enterprise with fewer than 250 employees but with more than 50 million euros turnover and more than 43 million euros balance sheet is also considered a mid-sized enterprise';

RELATE i18n_key:i18n_company_category_eti_description->i18n_translation->i18n_language:es
    SET text = 'Empresa con entre 250 y 4.999 empleados, y con volumen de negocio anual que no exceda de 1.500 millones de euros, o balance total que no exceda de 2.000 millones de euros. Una empresa con menos de 250 empleados pero con más de 50 millones de euros de volumen de negocio y más de 43 millones de euros de balance también se considera ETI';

RELATE i18n_key:i18n_company_category_eti_description->i18n_translation->i18n_language:de
    SET text = 'Unternehmen mit 250 bis 4.999 Beschäftigten und entweder einem Jahresumsatz von höchstens 1,5 Milliarden Euro oder einer Bilanzsumme von höchstens 2 Milliarden Euro. Ein Unternehmen mit weniger als 250 Beschäftigten, aber mehr als 50 Millionen Euro Umsatz und mehr als 43 Millionen Euro Bilanzsumme gilt ebenfalls als mittelständisches Unternehmen';

RELATE i18n_key:i18n_company_category_eti_description->i18n_translation->i18n_language:it
    SET text = 'Impresa con tra 250 e 4.999 dipendenti, e con fatturato annuo non superiore a 1,5 miliardi di euro, o totale di bilancio non superiore a 2 miliardi di euro. Un\'impresa con meno di 250 dipendenti ma con più di 50 milioni di euro di fatturato e più di 43 milioni di euro di bilancio è considerata anche un\'impresa di dimensioni intermedie';

-- Catégorie GE: Grande Entreprise
----------------------------------------------------------------------------------------------------

RELATE i18n_key:i18n_company_category_ge_name->i18n_translation->i18n_language:fr
    SET text = 'Grande Entreprise';

RELATE i18n_key:i18n_company_category_ge_name->i18n_translation->i18n_language:en
    SET text = 'Large Enterprise';

RELATE i18n_key:i18n_company_category_ge_name->i18n_translation->i18n_language:es
    SET text = 'Gran Empresa';

RELATE i18n_key:i18n_company_category_ge_name->i18n_translation->i18n_language:de
    SET text = 'Großunternehmen';

RELATE i18n_key:i18n_company_category_ge_name->i18n_translation->i18n_language:it
    SET text = 'Grande Impresa';

RELATE i18n_key:i18n_company_category_ge_description->i18n_translation->i18n_language:fr
    SET text = 'Entreprise ayant au moins 5 000 salariés. Une entreprise qui a moins de 5 000 salariés mais plus de 1,5 milliard d\'euros de chiffre d\'affaires et plus de 2 milliards d\'euros de total de bilan est aussi considérée comme une grande entreprise';

RELATE i18n_key:i18n_company_category_ge_description->i18n_translation->i18n_language:en
    SET text = 'Enterprise with at least 5,000 employees. An enterprise with fewer than 5,000 employees but with more than 1.5 billion euros turnover and more than 2 billion euros balance sheet is also considered a large enterprise';

RELATE i18n_key:i18n_company_category_ge_description->i18n_translation->i18n_language:es
    SET text = 'Empresa con al menos 5.000 empleados. Una empresa con menos de 5.000 empleados pero con más de 1.500 millones de euros de volumen de negocio y más de 2.000 millones de euros de balance total también se considera una gran empresa';

RELATE i18n_key:i18n_company_category_ge_description->i18n_translation->i18n_language:de
    SET text = 'Unternehmen mit mindestens 5.000 Beschäftigten. Ein Unternehmen mit weniger als 5.000 Beschäftigten, aber mehr als 1,5 Milliarden Euro Umsatz und mehr als 2 Milliarden Euro Bilanzsumme gilt ebenfalls als Großunternehmen';

RELATE i18n_key:i18n_company_category_ge_description->i18n_translation->i18n_language:it
    SET text = 'Impresa con almeno 5.000 dipendenti. Un\'impresa con meno di 5.000 dipendenti ma con più di 1,5 miliardi di euro di fatturato e più di 2 miliardi di euro di bilancio totale è considerata anche una grande impresa';

