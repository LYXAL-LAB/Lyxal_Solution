-- =============================================================================================
-- |
-- | Fichier     : i18n_language_error_code_translate_seeds.surql
-- | Module      : i18n
-- | Description : Peuple la table `i18n_translation` avec les traductions pour les
-- |               messages d'erreur et de succès des fonctions de gestion de langue.
-- |
-- =============================================================================================

-- Traductions pour 'i18n.language.list.empty.message'
RELATE i18n_key:'i18n.language.list.empty.message'->i18n_translation->i18n_language:fr 
SET text = 'Aucune langue active n''a été trouvée.';
RELATE i18n_key:'i18n.language.list.empty.message'->i18n_translation->i18n_language:en 
SET text = 'No active languages were found.';
RELATE i18n_key:'i18n.language.list.empty.message'->i18n_translation->i18n_language:es 
SET text = 'No se encontraron idiomas activos.';
RELATE i18n_key:'i18n.language.list.empty.message'->i18n_translation->i18n_language:de 
SET text = 'Keine aktiven Sprachen gefunden.';
RELATE i18n_key:'i18n.language.list.empty.message'->i18n_translation->i18n_language:it 
SET text = 'Nessuna lingua attiva trovata.';

-- Traductions pour 'i18n.language.list.success.message'
RELATE i18n_key:'i18n.language.list.success.message'->i18n_translation->i18n_language:fr 
SET text = 'La liste des langues actives a été récupérée avec succès.';
RELATE i18n_key:'i18n.language.list.success.message'->i18n_translation->i18n_language:en 
SET text = 'The list of active languages has been successfully retrieved.';
RELATE i18n_key:'i18n.language.list.success.message'->i18n_translation->i18n_language:es 
SET text = 'La lista de idiomas activos se ha recuperado correctamente.';
RELATE i18n_key:'i18n.language.list.success.message'->i18n_translation->i18n_language:de 
SET text = 'Die Liste der aktiven Sprachen wurde erfolgreich abgerufen.';
RELATE i18n_key:'i18n.language.list.success.message'->i18n_translation->i18n_language:it 
SET text = 'L''elenco delle lingue attive è stato recuperato con successo.';

-- Traductions pour 'i18n.language.some_not_found.message'
RELATE i18n_key:'i18n.language.some_not_found.message'->i18n_translation->i18n_language:fr 
SET text = 'Erreur : Un ou plusieurs codes de langue fournis sont invalides.';
RELATE i18n_key:'i18n.language.some_not_found.message'->i18n_translation->i18n_language:en 
SET text = 'Error: One or more provided language codes are invalid.';
RELATE i18n_key:'i18n.language.some_not_found.message'->i18n_translation->i18n_language:es 
SET text = 'Error: Uno o más de los códigos de idioma proporcionados no son válidos.';
RELATE i18n_key:'i18n.language.some_not_found.message'->i18n_translation->i18n_language:de 
SET text = 'Fehler: Einer oder mehrere der angegebenen Sprachcodes sind ungültig.';
RELATE i18n_key:'i18n.language.some_not_found.message'->i18n_translation->i18n_language:it 
SET text = 'Errore: uno o più codici lingua forniti non sono validi.';

-- Traductions pour 'i18n.language.update.success.message'
RELATE i18n_key:'i18n.language.update.success.message'->i18n_translation->i18n_language:fr 
SET text = 'Le statut de la langue a été mis à jour avec succès.';
RELATE i18n_key:'i18n.language.update.success.message'->i18n_translation->i18n_language:en 
SET text = 'The language status has been updated successfully.';
RELATE i18n_key:'i18n.language.update.success.message'->i18n_translation->i18n_language:es 
SET text = 'El estado del idioma ha sido actualizado correctamente.';
RELATE i18n_key:'i18n.language.update.success.message'->i18n_translation->i18n_language:de 
SET text = 'Der Sprachstatus wurde erfolgreich aktualisiert.';
RELATE i18n_key:'i18n.language.update.success.message'->i18n_translation->i18n_language:it 
SET text = 'Lo stato della lingua è stato aggiornato con successo.';

-- Traductions pour 'i18n.language.update_batch.success.message'
RELATE i18n_key:'i18n.language.update_batch.success.message'->i18n_translation->i18n_language:fr 
SET text = 'Le statut des langues a été mis à jour avec succès.';
RELATE i18n_key:'i18n.language.update_batch.success.message'->i18n_translation->i18n_language:en 
SET text = 'The status of the languages has been updated successfully.';
RELATE i18n_key:'i18n.language.update_batch.success.message'->i18n_translation->i18n_language:es 
SET text = 'El estado de los idiomas ha sido actualizado correctamente.';
RELATE i18n_key:'i18n.language.update_batch.success.message'->i18n_translation->i18n_language:de 
SET text = 'Der Status der Sprachen wurde erfolgreich aktualisiert.';
RELATE i18n_key:'i18n.language.update_batch.success.message'->i18n_translation->i18n_language:it 
SET text = 'Lo stato delle lingue è stato aggiornato con successo.';
