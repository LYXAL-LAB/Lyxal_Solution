-- =============================================================================================
-- |
-- | Fichier : builder_error_code_seeds.surql
-- | Module : builder / reference
-- | Description : Seeds pour builder_error_code via fn::builder_error_code_create.
-- |               Implémente les 21 codes d'erreur de la section builder_error_code.
-- |
-- | Fonction : fn::builder_error_code_seed_init()
-- | Paramètres : aucun
-- | Retour : { success: bool, count: int, results: array }
-- |
-- | Notes :
-- |   - Utilise la langue 'fr' par défaut
-- |   - Aucun user_id (création système)
-- |   - Les severity sont : info, success, warning, error, critical
-- =============================================================================================
    LET $language_id=type::thing('i18n_language','fr');
    LET $info_id = type::thing('builder_error_severity','info');
    LET $success_id = type::thing('builder_error_severity','success');
    LET $warning_id = type::thing('builder_error_severity','warning');
    LET $error_id = type::thing('builder_error_severity','error');
    LET $critical_id = type::thing('builder_error_severity','critical');

    -- Codes CREATE
    
    -- error.code.create.success
    -- création des clés i18n
    LET $key_i18n_message = type::thing('builder_i18n_key', 'error.code.create.success.message');
    LET $key_i18n_description = type::thing('builder_i18n_key', 'error.code.create.success.description');
    CREATE $key_i18n_message;
    CREATE $key_i18n_description;
    -- création des translations
    RELATE $key_i18n_message->builder_i18n_translation->$language_id
    SET text = 'Code d\'erreur créé avec succès';
    RELATE $key_i18n_description->builder_i18n_translation->$language_id
    SET text = 'Création réussie d\'un nouveau code d\'erreur dans le registre';
    -- création du code
    CREATE type::thing('builder_error_code', 'error.code.create.success') SET
    severity = $success_id,
    success_result = true,
    message_key = $key_i18n_message,
    description = $key_i18n_description,
    metadata =  {} ,
    payload = {} ,
    created_at = time::now(),
    created_by = NONE ;

    -- error.code.create.failed
    -- création des clés i18n
    LET $key_i18n_message = type::thing('builder_i18n_key', 'error.code.create.failed.message');
    LET $key_i18n_description = type::thing('builder_i18n_key', 'error.code.create.failed.description');
    CREATE $key_i18n_message;
    CREATE $key_i18n_description;
    -- création des translations
    RELATE $key_i18n_message->builder_i18n_translation->$language_id
    SET text = 'Échec de la création du code d\'erreur';
    RELATE $key_i18n_description->builder_i18n_translation->$language_id
    SET text = 'La création du code d\'erreur a échoué';
    -- création du code
    CREATE type::thing('builder_error_code', 'error.code.create.failed') SET
    severity = $error_id,
    success_result = false,
    message_key = $key_i18n_message,
    description = $key_i18n_description,
    metadata =  {} ,
    payload = {} ,
    created_at = time::now(),
    created_by = NONE ;

    -- Codes DELETE
    -- error.code.delete.success
    -- création des clés i18n
    LET $key_i18n_message = type::thing('builder_i18n_key', 'error.code.delete.success.message');
    LET $key_i18n_description = type::thing('builder_i18n_key', 'error.code.delete.success.description');
    CREATE $key_i18n_message;
    CREATE $key_i18n_description;
    -- création des translations
    RELATE $key_i18n_message->builder_i18n_translation->$language_id
    SET text = 'Code d\'erreur supprimé avec succès';
    RELATE $key_i18n_description->builder_i18n_translation->$language_id
    SET text = 'Suppression réussie du code d\'erreur et de ses dépendances';
    -- création du code
    CREATE type::thing('builder_error_code', 'error.code.delete.success') SET
    severity = $success_id,
    success_result = true,
    message_key = $key_i18n_message,
    description = $key_i18n_description,
    metadata =  {} ,
    payload = {} ,
    created_at = time::now(),
    created_by = NONE ;
    
    -- error.code.delete.failed
    -- création des clés i18n
    LET $key_i18n_message = type::thing('builder_i18n_key', 'error.code.delete.failed.message');
    LET $key_i18n_description = type::thing('builder_i18n_key', 'error.code.delete.failed.description');
    CREATE $key_i18n_message;
    CREATE $key_i18n_description;
    -- création des translations
    RELATE $key_i18n_message->builder_i18n_translation->$language_id
    SET text = 'Échec de la suppression du code d\'erreur';
    RELATE $key_i18n_description->builder_i18n_translation->$language_id
    SET text = 'La suppression du code d\'erreur a échoué';
    -- création du code
    CREATE type::thing('builder_error_code', 'error.code.delete.failed') SET
    severity = $error_id,
    success_result = false,
    message_key = $key_i18n_message,
    description = $key_i18n_description,
    metadata =  {} ,
    payload = {} ,
    created_at = time::now(),
    created_by = NONE ;
    
    -- Codes LIST
    -- error.code.list.success
    -- création des clés i18n
    LET $key_i18n_message = type::thing('builder_i18n_key', 'error.code.list.success.message');
    LET $key_i18n_description = type::thing('builder_i18n_key', 'error.code.list.success.description');
    CREATE $key_i18n_message;
    CREATE $key_i18n_description;
    -- création des translations
    RELATE $key_i18n_message->builder_i18n_translation->$language_id
    SET text = 'Liste des codes d\'erreur récupérée';
    RELATE $key_i18n_description->builder_i18n_translation->$language_id
    SET text = 'Récupération réussie de la liste des codes d\'erreur';
    -- création du code
    CREATE type::thing('builder_error_code', 'error.code.list.success') SET
    severity = $success_id,
    success_result = true,
    message_key = $key_i18n_message,
    description = $key_i18n_description,
    metadata =  {} ,
    payload = {} ,
    created_at = time::now(),
    created_by = NONE ;

    -- error.code.list.failed
    -- création des clés i18n
    LET $key_i18n_message = type::thing('builder_i18n_key', 'error.code.list.failed.message');
    LET $key_i18n_description = type::thing('builder_i18n_key', 'error.code.list.failed.description');
    CREATE $key_i18n_message;
    CREATE $key_i18n_description;
    -- création des translations
    RELATE $key_i18n_message->builder_i18n_translation->$language_id
    SET text = 'Échec de récupération de la liste';
    RELATE $key_i18n_description->builder_i18n_translation->$language_id
    SET text = 'La récupération de la liste des codes d\'erreur a échoué';
    -- création du code
    CREATE type::thing('builder_error_code', 'error.code.list.failed') SET
    severity = $error_id,
    success_result = false,
    message_key = $key_i18n_message,
    description = $key_i18n_description,
    metadata =  {} ,
    payload = {} ,
    created_at = time::now(),
    created_by = NONE ;

    -- Codes GET
    -- error.code.found
    -- création des clés i18n
    LET $key_i18n_message = type::thing('builder_i18n_key', 'error.code.found.message');
    LET $key_i18n_description = type::thing('builder_i18n_key', 'error.code.found.description');
    CREATE $key_i18n_message;
    CREATE $key_i18n_description;
    -- création des translations
    RELATE $key_i18n_message->builder_i18n_translation->$language_id
    SET text = 'Code d\'erreur trouvé';
    RELATE $key_i18n_description->builder_i18n_translation->$language_id
    SET text = 'Le code d\'erreur demandé a été trouvé';
    -- création du code
    CREATE type::thing('builder_error_code', 'error.code.found') SET
    severity = $info_id,
    success_result = true,
    message_key = $key_i18n_message,
    description = $key_i18n_description,
    metadata =  {} ,
    payload = {} ,
    created_at = time::now(),
    created_by = NONE ;

    -- error.code.not.found
    -- création des clés i18n
    LET $key_i18n_message = type::thing('builder_i18n_key', 'error.code.not.found.message');
    LET $key_i18n_description = type::thing('builder_i18n_key', 'error.code.not.found.description');
    CREATE $key_i18n_message;
    CREATE $key_i18n_description;
    -- création des translations
    RELATE $key_i18n_message->builder_i18n_translation->$language_id
    SET text = 'Code d\'erreur introuvable';
    RELATE $key_i18n_description->builder_i18n_translation->$language_id
    SET text = 'Le code d\'erreur demandé n\'existe pas';
    -- création du code
    CREATE type::thing('builder_error_code', 'error.code.not.found') SET
    severity = $warning_id,
    success_result = false,
    message_key = $key_i18n_message,
    description = $key_i18n_description,
    metadata =  {} ,
    payload = {} ,
    created_at = time::now(),
    created_by = NONE ;
  
    -- Codes SANITIZE
    -- error.code.sanitize.type.invalid
    -- création des clés i18n
    LET $key_i18n_message = type::thing('builder_i18n_key', 
    'error.code.sanitize.type.invalid.message');
    LET $key_i18n_description = type::thing('builder_i18n_key', 
    'error.code.sanitize.type.invalid.description');
    CREATE $key_i18n_message;
    CREATE $key_i18n_description;
    -- création des translations
    RELATE $key_i18n_message->builder_i18n_translation->$language_id
    SET text = 'Type de valeur invalide pour sanitize';
    RELATE $key_i18n_description->builder_i18n_translation->$language_id
    SET text = 'Le type de valeur fourni n\'est pas supporté (code, message, description attendus)';
    -- création du code
    CREATE type::thing('builder_error_code', 'error.code.sanitize.type.invalid') SET
    severity = $error_id,
    success_result = false,
    message_key = $key_i18n_message,
    description = $key_i18n_description,
    metadata =  {} ,
    payload = {} ,
    created_at = time::now(),
    created_by = NONE ;

    -- error.code.sanitize.code.required
    -- création des clés i18n
    LET $key_i18n_message = type::thing('builder_i18n_key', 
    'error.code.sanitize.code.required.message');
    LET $key_i18n_description = type::thing('builder_i18n_key', 
    'error.code.sanitize.code.required.description');
    CREATE $key_i18n_message;
    CREATE $key_i18n_description;
    -- création des translations
    RELATE $key_i18n_message->builder_i18n_translation->$language_id
    SET text = 'Code requis après sanitize';
    RELATE $key_i18n_description->builder_i18n_translation->$language_id
    SET text = 'Le code est vide après nettoyage';
    -- création du code
    CREATE type::thing('builder_error_code', 'error.code.sanitize.code.required') SET
    severity = $error_id,
    success_result = false,
    message_key = $key_i18n_message,
    description = $key_i18n_description,
    metadata =  {} ,
    payload = {} ,
    created_at = time::now(),
    created_by = NONE ;

    -- error.code.sanitize.message.required
    -- création des clés i18n
    LET $key_i18n_message = type::thing('builder_i18n_key', 
    'error.code.sanitize.message.required.message');
    LET $key_i18n_description = type::thing('builder_i18n_key', 
    'error.code.sanitize.message.required.description');
    CREATE $key_i18n_message;
    CREATE $key_i18n_description;
    -- création des translations
    RELATE $key_i18n_message->builder_i18n_translation->$language_id
    SET text = 'Message requis après sanitize';
    RELATE $key_i18n_description->builder_i18n_translation->$language_id
    SET text = 'Le message est vide après nettoyage';
    -- création du code
    CREATE type::thing('builder_error_code', 'error.code.sanitize.message.required') SET
    severity = $error_id,
    success_result = false,
    message_key = $key_i18n_message,
    description = $key_i18n_description,
    metadata =  {} ,
    payload = {} ,
    created_at = time::now(),
    created_by = NONE ;

    -- error.code.sanitize.description.required
    -- création des clés i18n
    LET $key_i18n_message = type::thing('builder_i18n_key', 
    'error.code.sanitize.description.required.message');
    LET $key_i18n_description = type::thing('builder_i18n_key', 
    'error.code.sanitize.description.required.description');
    CREATE $key_i18n_message;
    CREATE $key_i18n_description;
    -- création des translations
    RELATE $key_i18n_message->builder_i18n_translation->$language_id
    SET text = 'Description requise après sanitize';
    RELATE $key_i18n_description->builder_i18n_translation->$language_id
    SET text = 'La description est vide après nettoyage';
    -- création du code
    CREATE type::thing('builder_error_code', 'error.code.sanitize.description.required') SET
    severity = $error_id,
    success_result = false,
    message_key = $key_i18n_message,
    description = $key_i18n_description,
    metadata =  {} ,
    payload = {} ,
    created_at = time::now(),
    created_by = NONE ;
    
    -- error.code.sanitize.resolve.success
    -- création des clés i18n
    LET $key_i18n_message = type::thing('builder_i18n_key', 
    'error.code.sanitize.resolve.success.message');
    LET $key_i18n_description = type::thing('builder_i18n_key', 
    'error.code.sanitize.resolve.success.description');
    CREATE $key_i18n_message;
    CREATE $key_i18n_description;
    -- création des translations
    RELATE $key_i18n_message->builder_i18n_translation->$language_id
    SET text = 'Sanitize réussi';
    RELATE $key_i18n_description->builder_i18n_translation->$language_id
    SET text = 'La valeur a été nettoyée avec succès';
    -- création du code
    CREATE type::thing('builder_error_code', 'error.code.sanitize.resolve.success') SET
    severity = $success_id,
    success_result = true,
    message_key = $key_i18n_message,
    description = $key_i18n_description,
    metadata =  {} ,
    payload = {} ,
    created_at = time::now(),
    created_by = NONE ;
    
    -- Codes VALIDATE LENGTH
    -- error.code.type.invalid
    -- création des clés i18n
    LET $key_i18n_message = type::thing('builder_i18n_key', 'error.code.type.invalid.message');
    LET $key_i18n_description = type::thing('builder_i18n_key', 'error.code.type.invalid.description');
    CREATE $key_i18n_message;
    CREATE $key_i18n_description;
    -- création des translations
    RELATE $key_i18n_message->builder_i18n_translation->$language_id
    SET text = 'Type invalide pour validation';
    RELATE $key_i18n_description->builder_i18n_translation->$language_id
    SET text = 'Le type fourni n\'est pas valide pour la validation de longueur';
    -- création du code
    CREATE type::thing('builder_error_code', 'error.code.type.invalid') SET
    severity = $error_id,
    success_result = false,
    message_key = $key_i18n_message,
    description = $key_i18n_description,
    metadata =  {} ,
    payload = {} ,
    created_at = time::now(),
    created_by = NONE ;

    -- error.code.length.min.violation
    -- création des clés i18n
    LET $key_i18n_message = type::thing('builder_i18n_key', 'error.code.length.min.violation.message');
    LET $key_i18n_description = type::thing('builder_i18n_key', 'error.code.length.min.violation.description');
    CREATE $key_i18n_message;
    CREATE $key_i18n_description;
    -- création des translations
    RELATE $key_i18n_message->builder_i18n_translation->$language_id
    SET text = 'Longueur minimale non respectée';
    RELATE $key_i18n_description->builder_i18n_translation->$language_id
    SET text = 'La valeur est trop courte';
    -- création du code
    CREATE type::thing('builder_error_code', 'error.code.length.min.violation') SET
    severity = $error_id,
    success_result = false,
    message_key = $key_i18n_message,
    description = $key_i18n_description,
    metadata =  {} ,
    payload = {} ,
    created_at = time::now(),
    created_by = NONE ;

    -- error.code.length.max.violation
    -- création des clés i18n
    LET $key_i18n_message = type::thing('builder_i18n_key', 'error.code.length.max.violation.message');
    LET $key_i18n_description = type::thing('builder_i18n_key', 'error.code.length.max.violation.description');
    CREATE $key_i18n_message;
    CREATE $key_i18n_description;
    -- création des translations
    RELATE $key_i18n_message->builder_i18n_translation->$language_id
    SET text = 'Longueur maximale dépassée';
    RELATE $key_i18n_description->builder_i18n_translation->$language_id
    SET text = 'La valeur est trop longue';
    -- création du code
    CREATE type::thing('builder_error_code', 'error.code.length.max.violation') SET
    severity = $error_id,
    success_result = false,
    message_key = $key_i18n_message,
    description = $key_i18n_description,
    metadata =  {} ,
    payload = {} ,
    created_at = time::now(),
    created_by = NONE ;
    
    -- error.code.length.resolve.success
    -- création des clés i18n
    LET $key_i18n_message = type::thing('builder_i18n_key', 
    'error.code.length.resolve.success.message');
    LET $key_i18n_description = type::thing('builder_i18n_key', 
    'error.code.length.resolve.success.description');
    CREATE $key_i18n_message;
    CREATE $key_i18n_description;
    -- création des translations
    RELATE $key_i18n_message->builder_i18n_translation->$language_id
    SET text = 'Validation de longueur réussie';
    RELATE $key_i18n_description->builder_i18n_translation->$language_id
    SET text = 'La longueur de la valeur est conforme';
    -- création du code
    CREATE type::thing('builder_error_code', 'error.code.length.resolve.success') SET
    severity = $success_id,
    success_result = true,
    message_key = $key_i18n_message,
    description = $key_i18n_description,
    metadata =  {} ,
    payload = {} ,
    created_at = time::now(),
    created_by = NONE ;
    
    -- Codes VERIFY UNICITY
    -- error.code.unique
    -- création des clés i18n
    LET $key_i18n_message = type::thing('builder_i18n_key', 'error.code.unique.message');
    LET $key_i18n_description = type::thing('builder_i18n_key', 'error.code.unique.description');
    CREATE $key_i18n_message;
    CREATE $key_i18n_description;
    -- création des translations
    RELATE $key_i18n_message->builder_i18n_translation->$language_id
    SET text = 'Code d\'erreur unique';
    RELATE $key_i18n_description->builder_i18n_translation->$language_id
    SET text = 'Le code d\'erreur n\'existe pas encore, création possible';
    -- création du code
    CREATE type::thing('builder_error_code', 'error.code.unique') SET
    severity = $info_id,
    success_result = true,
    message_key = $key_i18n_message,
    description = $key_i18n_description,
    metadata =  {} ,
    payload = {} ,
    created_at = time::now(),
    created_by = NONE ; 

    -- error.code.already.exists
    -- création des clés i18n
    LET $key_i18n_message = type::thing('builder_i18n_key', 'error.code.already.exists.message');
    LET $key_i18n_description = type::thing('builder_i18n_key', 'error.code.already.exists.description');
    CREATE $key_i18n_message;
    CREATE $key_i18n_description;
    -- création des translations
    RELATE $key_i18n_message->builder_i18n_translation->$language_id
    SET text = 'Code d\'erreur déjà existant';
    RELATE $key_i18n_description->builder_i18n_translation->$language_id
    SET text = 'Ce code d\'erreur existe déjà dans le registre';
    -- création du code
    CREATE type::thing('builder_error_code', 'error.code.already.exists') SET
    severity = $warning_id,
    success_result = false,
    message_key = $key_i18n_message,
    description = $key_i18n_description,
    metadata =  {} ,
    payload = {} ,
    created_at = time::now(),
    created_by = NONE ;
    
    -- Codes I18N KEY GENERATE
    -- error.code.key.i18n.type.invalid
    -- création des clés i18n
    LET $key_i18n_message = type::thing('builder_i18n_key', 'error.code.key.i18n.type.invalid.message');
    LET $key_i18n_description = type::thing('builder_i18n_key', 'error.code.key.i18n.type.invalid.description');
    CREATE $key_i18n_message;
    CREATE $key_i18n_description;
    -- création des translations
    RELATE $key_i18n_message->builder_i18n_translation->$language_id
    SET text = 'Type de clé i18n invalide';
    RELATE $key_i18n_description->builder_i18n_translation->$language_id
    SET text = 'Le type de clé i18n doit être message ou description';
    -- création du code
    CREATE type::thing('builder_error_code', 'error.code.key.i18n.type.invalid') SET
    severity = $error_id,
    success_result = false,
    message_key = $key_i18n_message,
    description = $key_i18n_description,
    metadata =  {} ,
    payload = {} ,
    created_at = time::now(),
    created_by = NONE ;

    -- error.code.key.i18n.valid
    -- création des clés i18n
    LET $key_i18n_message = type::thing('builder_i18n_key', 'error.code.key.i18n.valid.message');
    LET $key_i18n_description = type::thing('builder_i18n_key', 'error.code.key.i18n.valid.description');
    CREATE $key_i18n_message;
    CREATE $key_i18n_description;
    -- création des translations
    RELATE $key_i18n_message->builder_i18n_translation->$language_id
    SET text = 'Clé i18n générée avec succès';
    RELATE $key_i18n_description->builder_i18n_translation->$language_id
    SET text = 'La clé i18n a été générée correctement';
    -- création du code
    CREATE type::thing('builder_error_code', 'error.code.key.i18n.valid') SET
    severity = $success_id,
    success_result = true,
    message_key = $key_i18n_message,
    description = $key_i18n_description,
    metadata =  {} ,
    payload = {} ,
    created_at = time::now(),
    created_by = NONE ;