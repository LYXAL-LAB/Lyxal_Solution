-- =============================================================================================
-- |
-- | Fichier     : i18n_currency_symbol_position_translate_seeds.surql
-- | Module      : i18n
-- | Description : Peuple la table `i18n_translation` avec les traductions pour les
-- |               positions du symbole monétaire.
-- |
-- =============================================================================================

-- Traductions pour 'i18n.currency.symbol_position.before.name'
RELATE i18n_key:'i18n.currency.symbol_position.before.name'->i18n_translation->i18n_language:fr 
SET text = 'Avant le montant';
RELATE i18n_key:'i18n.currency.symbol_position.before.name'->i18n_translation->i18n_language:en 
SET text = 'Before the amount';
RELATE i18n_key:'i18n.currency.symbol_position.before.name'->i18n_translation->i18n_language:es 
SET text = 'Antes del importe';
RELATE i18n_key:'i18n.currency.symbol_position.before.name'->i18n_translation->i18n_language:de 
SET text = 'Vor dem Betrag';
RELATE i18n_key:'i18n.currency.symbol_position.before.name'->i18n_translation->i18n_language:it 
SET text = 'Prima dell''importo';

-- Traductions pour 'i18n.currency.symbol_position.after.name'
RELATE i18n_key:'i18n.currency.symbol_position.after.name'->i18n_translation->i18n_language:fr 
SET text = 'Après le montant';
RELATE i18n_key:'i18n.currency.symbol_position.after.name'->i18n_translation->i18n_language:en 
SET text = 'After the amount';
RELATE i18n_key:'i18n.currency.symbol_position.after.name'->i18n_translation->i18n_language:es 
SET text = 'Después del importe';
RELATE i18n_key:'i18n.currency.symbol_position.after.name'->i18n_translation->i18n_language:de 
SET text = 'Nach dem Betrag';
RELATE i18n_key:'i18n.currency.symbol_position.after.name'->i18n_translation->i18n_language:it 
SET text = 'Dopo l''importo';
