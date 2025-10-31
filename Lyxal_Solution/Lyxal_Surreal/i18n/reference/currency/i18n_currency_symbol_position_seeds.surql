-- =============================================================================================
-- |
-- | Fichier     : i18n_currency_symbol_position_seeds.surql
-- | Module      : i18n
-- | Description : Peuple la base de données avec les positions possibles du symbole monétaire
-- |               et les clés i18n associées.
-- |
-- =============================================================================================

-- ---------------------------------------------------------------------------------------------
-- | Section 1 : Création des clés i18n pour les libellés
-- ---------------------------------------------------------------------------------------------

CREATE i18n_key:'i18n.currency.symbol_position.before.name' SET 
description = "Libellé pour la position du symbole monétaire 'avant' le montant.";
CREATE i18n_key:'i18n.currency.symbol_position.after.name' SET 
description = "Libellé pour la position du symbole monétaire 'après' le montant.";


-- ---------------------------------------------------------------------------------------------
-- | Section 2 : Création des enregistrements de position
-- ---------------------------------------------------------------------------------------------

CREATE i18n_currency_symbol_position:before SET 
  code = 'before', 
  key.name = i18n_key:'i18n.currency.symbol_position.before.name';

CREATE i18n_currency_symbol_position:after SET 
  code = 'after', 
  key.name = i18n_key:'i18n.currency.symbol_position.after.name';
