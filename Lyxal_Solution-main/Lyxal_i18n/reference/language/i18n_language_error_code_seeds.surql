-- =============================================================================================
-- |
-- | Fichier     : i18n_language_error_code_seeds.surql
-- | Module      : i18n
-- | Description : Peuple la base de données avec les clés i18n et les codes d'erreur
-- |               spécifiques aux fonctions de gestion des langues.
-- |
-- =============================================================================================

-- ---------------------------------------------------------------------------------------------
-- | Section 1 : Création des clés i18n pour les messages de retour
-- ---------------------------------------------------------------------------------------------

CREATE i18n_key:'i18n.language.list.empty.message' SET 
description = "Message retourné quand la liste des langues actives est vide.";
CREATE i18n_key:'i18n.language.list.success.message' SET 
description = "Message de succès pour la récupération de la liste des langues actives.";
CREATE i18n_key:'i18n.language.some_not_found.message' SET 
description = "Message d'erreur quand certains codes de langue n'ont pas été trouvés.";
CREATE i18n_key:'i18n.language.update.success.message' SET 
description = "Message de succès pour la mise à jour d'une seule langue (utilisé pour le log).";
CREATE i18n_key:'i18n.language.update_batch.success.message' SET 
description = "Message de succès pour la mise à jour d'un lot de langues.";


-- ---------------------------------------------------------------------------------------------
-- | Section 2 : Création des codes d'erreur
-- ---------------------------------------------------------------------------------------------

-- Code pour fn::i18n_language_list_active
CREATE error_code:'i18n.language.list.empty' SET success_result = true, i18n = 
{ message: i18n_key:'i18n.language.list.empty.message' }, 
description = "Aucune langue active trouvée.";
CREATE error_code:'i18n.language.list.success' SET success_result = true, i18n = 
{ message: i18n_key:'i18n.language.list.success.message' }, 
description = "Liste des langues actives récupérée avec succès.";

-- Codes pour fn::i18n_language_set_active_status
CREATE error_code:'i18n.language.some_not_found' SET success_result = false, i18n = 
{ message: i18n_key:'i18n.language.some_not_found.message' }, 
description = "Un ou plusieurs codes de langue fournis sont invalides.";
CREATE error_code:'i18n.language.update.success' SET success_result = true, i18n = 
{ message: i18n_key:'i18n.language.update.success.message' }, 
description = "Le statut d'une langue a été mis à jour avec succès.";
CREATE error_code:'i18n.language.update_batch.success' SET success_result = true, i18n = 
{ message: i18n_key:'i18n.language.update_batch.success.message' }, 
description = "Le statut des langues a été mis à jour avec succès.";
