-- =============================================================================================
-- |
-- | Fichier : builder_error_severity_code_seeds.surql
-- | Module : builder / reference
-- | Description : Seeds pour les codes d'erreur de la section builder_error_severity
-- |               via fn::builder_error_code_create.
-- |               Implémente les 24 codes d'erreur de la section builder_error_severity.
-- |
-- | Fonction : fn::builder_error_severity_code_seed_init()
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

    -- severity.create.success
    -- création des clés i18n
    LET $key_i18n_message = type::thing('builder_i18n_key', 'severity.create.success.message');
    LET $key_i18n_description = type::thing('builder_i18n_key', 'severity.create.success.description');
    CREATE $key_i18n_message;
    CREATE $key_i18n_description;
    -- création des translations
    RELATE $key_i18n_message->builder_i18n_translation->$language_id 
    SET text = 'Sévérité créée avec succès';
    RELATE $key_i18n_description->builder_i18n_translation->$language_id 
    SET text = 'Création réussie d\'une nouvelle sévérité d\'erreur';
    -- création du code
    CREATE type::thing('builder_error_code', 'severity.create.success') SET
    severity = $success_id,
    success_result = true,
    message_key = $key_i18n_message,
    description = $key_i18n_description,
    metadata =  {} ,
    payload = {} ,
    created_at = time::now(),
    created_by = NONE ;

    -- severity.create.failed
    -- création des clés i18n
    LET $key_i18n_message = type::thing('builder_i18n_key', 'severity.create.failed.message');
    LET $key_i18n_description = type::thing('builder_i18n_key', 'severity.create.failed.description');
    CREATE $key_i18n_message;
    CREATE $key_i18n_description;
    -- création des translations
    RELATE $key_i18n_message->builder_i18n_translation->$language_id 
    SET text = 'Échec de la création de la sévérité';
    RELATE $key_i18n_description->builder_i18n_translation->$language_id 
    SET text = 'La création de la sévérité a échoué';
    -- création du code
    CREATE type::thing('builder_error_code', 'severity.create.failed') SET
    severity = $error_id,
    success_result = false,
    message_key = $key_i18n_message,
    description = $key_i18n_description,
    metadata =  {} ,
    payload = {} ,
    created_at = time::now(),
    created_by = NONE ;
    
    -- Codes DELETE

    -- severity.delete.success
    -- création des clés i18n
    LET $key_i18n_message = type::thing('builder_i18n_key', 'severity.delete.success.message');
    LET $key_i18n_description = type::thing('builder_i18n_key', 'severity.delete.success.description');
    CREATE $key_i18n_message;
    CREATE $key_i18n_description;
    -- création des translations
    RELATE $key_i18n_message->builder_i18n_translation->$language_id 
    SET text = 'Sévérité supprimée avec succès';
    RELATE $key_i18n_description->builder_i18n_translation->$language_id 
    SET text = 'Suppression réussie de la sévérité et de ses dépendances';
    -- création du code
    CREATE type::thing('builder_error_code', 'severity.delete.success') SET
    severity = $success_id,
    success_result = true,
    message_key = $key_i18n_message,
    description = $key_i18n_description,
    metadata =  {} ,
    payload = {} ,
    created_at = time::now(),
    created_by = NONE ;
    
    -- severity.delete.failed
    -- création des clés i18n
    LET $key_i18n_message = type::thing('builder_i18n_key', 'severity.delete.failed.message');
    LET $key_i18n_description = type::thing('builder_i18n_key', 'severity.delete.failed.description');
    CREATE $key_i18n_message;
    CREATE $key_i18n_description;
    -- création des translations
    RELATE $key_i18n_message->builder_i18n_translation->$language_id 
    SET text = 'Échec de la suppression de la sévérité';
    RELATE $key_i18n_description->builder_i18n_translation->$language_id 
    SET text = 'La suppression de la sévérité a échoué';
    -- création du code
    CREATE type::thing('builder_error_code', 'severity.delete.failed') SET
    severity = $error_id,
    success_result = false,
    message_key = $key_i18n_message,
    description = $key_i18n_description,
    metadata =  {} ,
    payload = {} ,
    created_at = time::now(),
    created_by = NONE ;
    
    -- Codes UPDATE

    -- severity.update.success
    -- création des clés i18n
    LET $key_i18n_message = type::thing('builder_i18n_key', 'severity.update.success.message');
    LET $key_i18n_description = type::thing('builder_i18n_key', 'severity.update.success.description');
    CREATE $key_i18n_message;
    CREATE $key_i18n_description;
    -- création des translations
    RELATE $key_i18n_message->builder_i18n_translation->$language_id 
    SET text = 'Sévérité mise à jour avec succès';
    RELATE $key_i18n_description->builder_i18n_translation->$language_id 
    SET text = 'La mise à jour du statut actif de la sévérité a réussi';
    -- création du code
    CREATE type::thing('builder_error_code', 'severity.update.success') SET
    severity = $success_id,
    success_result = true,
    message_key = $key_i18n_message,
    description = $key_i18n_description,
    metadata =  {} ,
    payload = {} ,
    created_at = time::now(),
    created_by = NONE ;
    
    -- severity.update.failed
    -- création des clés i18n
    LET $key_i18n_message = type::thing('builder_i18n_key', 'severity.update.failed.message');
    LET $key_i18n_description = type::thing('builder_i18n_key', 'severity.update.failed.description');
    CREATE $key_i18n_message;
    CREATE $key_i18n_description;
    -- création des translations
    RELATE $key_i18n_message->builder_i18n_translation->$language_id 
    SET text = 'Échec de la mise à jour de la sévérité';
    RELATE $key_i18n_description->builder_i18n_translation->$language_id 
    SET text = 'La mise à jour de la sévérité a échoué';
    -- création du code
    CREATE type::thing('builder_error_code', 'severity.update.failed') SET
    severity = $error_id,
    success_result = false,
    message_key = $key_i18n_message,
    description = $key_i18n_description,
    metadata =  {} ,
    payload = {} ,
    created_at = time::now(),
    created_by = NONE ; 
    
    -- Codes LIST
    -- severity.list.success
    -- création des clés i18n
    LET $key_i18n_message = type::thing('builder_i18n_key', 'severity.list.success.message');
    LET $key_i18n_description = type::thing('builder_i18n_key', 'severity.list.success.description');
    CREATE $key_i18n_message;
    CREATE $key_i18n_description;
    -- création des translations
    RELATE $key_i18n_message->builder_i18n_translation->$language_id 
    SET text = 'Liste des sévérités récupérée';
    RELATE $key_i18n_description->builder_i18n_translation->$language_id 
    SET text = 'Récupération réussie de la liste des sévérités';
    -- création du code
    CREATE type::thing('builder_error_code', 'severity.list.success') SET
    severity = $success_id,
    success_result = true,
    message_key = $key_i18n_message,
    description = $key_i18n_description,
    metadata =  {} ,
    payload = {} ,
    created_at = time::now(),
    created_by = NONE ;
    
    -- severity.list.failed
    -- création des clés i18n
    LET $key_i18n_message = type::thing('builder_i18n_key', 'severity.list.failed.message');
    LET $key_i18n_description = type::thing('builder_i18n_key', 'severity.list.failed.description');
    CREATE $key_i18n_message;
    CREATE $key_i18n_description;
    -- création des translations
    RELATE $key_i18n_message->builder_i18n_translation->$language_id 
    SET text = 'Échec de récupération de la liste';
    RELATE $key_i18n_description->builder_i18n_translation->$language_id 
    SET text = 'La récupération de la liste des sévérités a échoué';
    -- création du code
    CREATE type::thing('builder_error_code', 'severity.list.failed') SET
    severity = $error_id,
    success_result = false,
    message_key = $key_i18n_message,
    description = $key_i18n_description,
    metadata =  {} ,
    payload = {} ,
    created_at = time::now(),
    created_by = NONE ;
    
    -- Codes GET
    -- severity.code.found
    -- création des clés i18n
    LET $key_i18n_message = type::thing('builder_i18n_key', 'severity.code.found.message');
    LET $key_i18n_description = type::thing('builder_i18n_key', 'severity.code.found.description');
    CREATE $key_i18n_message;
    CREATE $key_i18n_description;
    -- création des translations
    RELATE $key_i18n_message->builder_i18n_translation->$language_id 
    SET text = 'Sévérité trouvée';
    RELATE $key_i18n_description->builder_i18n_translation->$language_id 
    SET text = 'La sévérité demandée a été trouvée';
    -- création du code
    CREATE type::thing('builder_error_code', 'severity.code.found') SET
    severity = $info_id,
    success_result = true,
    message_key = $key_i18n_message,
    description = $key_i18n_description,
    metadata =  {} ,
    payload = {} ,
    created_at = time::now(),
    created_by = NONE ;
 
    -- severity.code.not.found
    -- création des clés i18n
    LET $key_i18n_message = type::thing('builder_i18n_key', 'severity.code.not.found.message');
    LET $key_i18n_description = type::thing('builder_i18n_key', 'severity.code.not.found.description');
    CREATE $key_i18n_message;
    CREATE $key_i18n_description;
    -- création des translations
    RELATE $key_i18n_message->builder_i18n_translation->$language_id 
    SET text = 'Sévérité introuvable';
    RELATE $key_i18n_description->builder_i18n_translation->$language_id 
    SET text = 'La sévérité demandée n\'existe pas';
    -- création du code
    CREATE type::thing('builder_error_code', 'severity.code.not.found') SET
    severity = $warning_id,
    success_result = false,
    message_key = $key_i18n_message,
    description = $key_i18n_description,
    metadata =  {} ,
    payload = {} ,
    created_at = time::now(),
    created_by = NONE ;
    
    -- Codes SANITIZE
    -- severity.sanitize.type.invalid
    -- création des clés i18n
    LET $key_i18n_message = type::thing('builder_i18n_key', 'severity.sanitize.type.invalid.message');
    LET $key_i18n_description = type::thing('builder_i18n_key', 
    'severity.sanitize.type.invalid.description');
    CREATE $key_i18n_message;
    CREATE $key_i18n_description;
    -- création des translations
    RELATE $key_i18n_message->builder_i18n_translation->$language_id 
    SET text = 'Type de valeur invalide pour sanitize';
    RELATE $key_i18n_description->builder_i18n_translation->$language_id 
    SET text = 'Le type de valeur fourni n\'est pas supporté (code, name, description attendus)';
    -- création du code
    CREATE type::thing('builder_error_code', 'severity.sanitize.type.invalid') SET
    severity = $error_id,
    success_result = false,
    message_key = $key_i18n_message,
    description = $key_i18n_description,
    metadata =  {} ,
    payload = {} ,
    created_at = time::now(),
    created_by = NONE ;

    -- severity.sanitize.code.required
    -- création des clés i18n
    LET $key_i18n_message = type::thing('builder_i18n_key', 'severity.sanitize.code.required.message');
    LET $key_i18n_description = type::thing('builder_i18n_key', 
    'severity.sanitize.code.required.description');
    CREATE $key_i18n_message;
    CREATE $key_i18n_description;
    -- création des translations
    RELATE $key_i18n_message->builder_i18n_translation->$language_id
    SET text = 'Code requis après sanitize';
    RELATE $key_i18n_description->builder_i18n_translation->$language_id
    SET text = 'Le code est vide après nettoyage';
    -- création du code
    CREATE type::thing('builder_error_code', 'severity.sanitize.code.required') SET
    severity = $error_id,
    success_result = false,
    message_key = $key_i18n_message,
    description = $key_i18n_description,
    metadata =  {} ,
    payload = {} ,
    created_at = time::now(),
    created_by = NONE ;

    -- severity.sanitize.message.required
    -- création des clés i18n
    LET $key_i18n_message = type::thing('builder_i18n_key', 
    'severity.sanitize.message.required.message');
    LET $key_i18n_description = type::thing('builder_i18n_key', 
    'severity.sanitize.message.required.description');
    CREATE $key_i18n_message;
    CREATE $key_i18n_description;
    -- création des translations
    RELATE $key_i18n_message->builder_i18n_translation->$language_id
    SET text = 'Message requis après sanitize';
    RELATE $key_i18n_description->builder_i18n_translation->$language_id
    SET text = 'Le message est vide après nettoyage';
    -- création du code
    CREATE type::thing('builder_error_code', 'severity.sanitize.message.required') SET
    severity = $error_id,
    success_result = false,
    message_key = $key_i18n_message,
    description = $key_i18n_description,
    metadata =  {} ,
    payload = {} ,
    created_at = time::now(),
    created_by = NONE ;

    -- severity.sanitize.description.required
    -- création des clés i18n
    LET $key_i18n_message = type::thing('builder_i18n_key', 
    'severity.sanitize.description.required.message');
    LET $key_i18n_description = type::thing('builder_i18n_key', 
    'severity.sanitize.description.required.description');
    CREATE $key_i18n_message;
    CREATE $key_i18n_description;
    -- création des translations
    RELATE $key_i18n_message->builder_i18n_translation->$language_id
    SET text = 'Description requise après sanitize';
    RELATE $key_i18n_description->builder_i18n_translation->$language_id
    SET text = 'La description est vide après nettoyage';
    -- création du code
    CREATE type::thing('builder_error_code', 'severity.sanitize.description.required') SET
    severity = $error_id,
    success_result = false,
    message_key = $key_i18n_message,
    description = $key_i18n_description,
    metadata =  {} ,
    payload = {} ,
    created_at = time::now(),
    created_by = NONE ;

    -- severity.sanitize.resolve.success
    -- création des clés i18n
    LET $key_i18n_message = type::thing('builder_i18n_key', 
    'severity.sanitize.resolve.success.message');
    LET $key_i18n_description = type::thing('builder_i18n_key', 
    'severity.sanitize.resolve.success.description');
    CREATE $key_i18n_message;
    CREATE $key_i18n_description;
    -- création des translations
    RELATE $key_i18n_message->builder_i18n_translation->$language_id
    SET text = 'Sanitize réussi';
    RELATE $key_i18n_description->builder_i18n_translation->$language_id
    SET text = 'La valeur a été nettoyée avec succès';
    -- création du code
    CREATE type::thing('builder_error_code', 'severity.sanitize.resolve.success') SET
    severity = $success_id,
    success_result = true,
    message_key = $key_i18n_message,
    description = $key_i18n_description,
    metadata =  {} ,
    payload = {} ,
    created_at = time::now(),
    created_by = NONE ;
    
    -- Codes VALIDATE LENGTH
    -- severity.type.invalid
    -- création des clés i18n
    LET $key_i18n_message = type::thing('builder_i18n_key', 'severity.type.invalid.message');
    LET $key_i18n_description = type::thing('builder_i18n_key', 'severity.type.invalid.description');
    CREATE $key_i18n_message;
    CREATE $key_i18n_description;
    -- création des translations
    RELATE $key_i18n_message->builder_i18n_translation->$language_id
    SET text = 'Type invalide pour validation';
    RELATE $key_i18n_description->builder_i18n_translation->$language_id
    SET text = 'Le type fourni n\'est pas valide pour la validation de longueur';
    -- création du code
    CREATE type::thing('builder_error_code', 'severity.type.invalid') SET
    severity = $error_id,
    success_result = false,
    message_key = $key_i18n_message,
    description = $key_i18n_description,
    metadata =  {} ,
    payload = {} ,
    created_at = time::now(),
    created_by = NONE ;

    -- severity.length.min.violation
    -- création des clés i18n
    LET $key_i18n_message = type::thing('builder_i18n_key', 'severity.length.min.violation.message');
    LET $key_i18n_description = type::thing('builder_i18n_key', 
    'severity.length.min.violation.description');
    CREATE $key_i18n_message;
    CREATE $key_i18n_description;
    -- création des translations
    RELATE $key_i18n_message->builder_i18n_translation->$language_id
    SET text = 'Longueur minimale non respectée';
    RELATE $key_i18n_description->builder_i18n_translation->$language_id
    SET text = 'La valeur est trop courte';
    -- création du code
    CREATE type::thing('builder_error_code', 'severity.length.min.violation') SET
    severity = $error_id,
    success_result = false,
    message_key = $key_i18n_message,
    description = $key_i18n_description,
    metadata =  {} ,
    payload = {} ,
    created_at = time::now(),
    created_by = NONE ;

    -- severity.length.max.violation
    -- création des clés i18n
    LET $key_i18n_message = type::thing('builder_i18n_key', 'severity.length.max.violation.message');
    LET $key_i18n_description = type::thing('builder_i18n_key', 
    'severity.length.max.violation.description');
    CREATE $key_i18n_message;
    CREATE $key_i18n_description;
    -- création des translations
    RELATE $key_i18n_message->builder_i18n_translation->$language_id
    SET text = 'Longueur maximale dépassée';
    RELATE $key_i18n_description->builder_i18n_translation->$language_id
    SET text = 'La valeur est trop longue';
    -- création du code
    CREATE type::thing('builder_error_code', 'severity.length.max.violation') SET
    severity = $error_id,
    success_result = false,
    message_key = $key_i18n_message,
    description = $key_i18n_description,
    metadata =  {} ,
    payload = {} ,
    created_at = time::now(),
    created_by = NONE ;

    -- severity.length.resolve.success (Correction du nom pour éviter conflit)
    -- création des clés i18n
    LET $key_i18n_message = type::thing('builder_i18n_key', 'severity.length.resolve.success.message');
    LET $key_i18n_description = type::thing('builder_i18n_key', 'severity.length.resolve.success.description');
    CREATE $key_i18n_message;
    CREATE $key_i18n_description;
    -- création des translations
    RELATE $key_i18n_message->builder_i18n_translation->$language_id
    SET text = 'Validation de longueur réussie';
    RELATE $key_i18n_description->builder_i18n_translation->$language_id
    SET text = 'La longueur de la valeur est conforme';
    -- création du code
    CREATE type::thing('builder_error_code', 'severity.length.resolve.success') SET
    severity = $success_id,
    success_result = true,
    message_key = $key_i18n_message,
    description = $key_i18n_description,
    metadata =  {} ,
    payload = {} ,
    created_at = time::now(),
    created_by = NONE ;

    -- Codes VERIFY UNICITY
    -- severity.code.unique
    -- création des clés i18n
    LET $key_i18n_message = type::thing('builder_i18n_key', 'severity.code.unique.message');
    LET $key_i18n_description = type::thing('builder_i18n_key', 'severity.code.unique.description');
    CREATE $key_i18n_message;
    CREATE $key_i18n_description;
    -- création des translations
    RELATE $key_i18n_message->builder_i18n_translation->$language_id
    SET text = 'Sévérité unique';
    RELATE $key_i18n_description->builder_i18n_translation->$language_id
    SET text = 'La sévérité n\'existe pas encore, création possible';
    -- création du code
    CREATE type::thing('builder_error_code', 'severity.code.unique') SET
    severity = $info_id,
    success_result = true,
    message_key = $key_i18n_message,
    description = $key_i18n_description,
    metadata =  {} ,
    payload = {} ,
    created_at = time::now(),
    created_by = NONE ;

    -- severity.code.already.exists
    -- création des clés i18n
    LET $key_i18n_message = type::thing('builder_i18n_key', 'severity.code.already.exists.message');
    LET $key_i18n_description = type::thing('builder_i18n_key', 
    'severity.code.already.exists.description');
    CREATE $key_i18n_message;
    CREATE $key_i18n_description;
    -- création des translations
    RELATE $key_i18n_message->builder_i18n_translation->$language_id
    SET text = 'Sévérité déjà existante';
    RELATE $key_i18n_description->builder_i18n_translation->$language_id
    SET text = 'Cette sévérité existe déjà dans le registre';
    -- création du code
    CREATE type::thing('builder_error_code', 'severity.code.already.exists') SET
    severity = $warning_id,
    success_result = false,
    message_key = $key_i18n_message,
    description = $key_i18n_description,
    metadata =  {} ,
    payload = {} ,
    created_at = time::now(),
    created_by = NONE ;

    -- Codes I18N KEY GENERATE
    -- severity.key.i18n.type.invalid
    -- création des clés i18n
    LET $key_i18n_message = type::thing('builder_i18n_key', 'severity.key.i18n.type.invalid.message');
    LET $key_i18n_description = type::thing('builder_i18n_key', 
    'severity.key.i18n.type.invalid.description');
    CREATE $key_i18n_message;
    CREATE $key_i18n_description;
    -- création des translations
    RELATE $key_i18n_message->builder_i18n_translation->$language_id
    SET text = 'Type de clé i18n invalide';
    RELATE $key_i18n_description->builder_i18n_translation->$language_id
    SET text = 'Le type de clé i18n doit être name ou description';
    -- création du code
    CREATE type::thing('builder_error_code', 'severity.key.i18n.type.invalid') SET
    severity = $error_id,
    success_result = false,
    message_key = $key_i18n_message,
    description = $key_i18n_description,
    metadata =  {} ,
    payload = {} ,
    created_at = time::now(),
    created_by = NONE ;

    -- severity.key.i18n.valid
    -- création des clés i18n
    LET $key_i18n_message = type::thing('builder_i18n_key', 'severity.key.i18n.valid.message');
    LET $key_i18n_description = type::thing('builder_i18n_key', 'severity.key.i18n.valid.description');
    CREATE $key_i18n_message;
    CREATE $key_i18n_description;
    -- création des translations
    RELATE $key_i18n_message->builder_i18n_translation->$language_id
    SET text = 'Clé i18n générée avec succès';
    RELATE $key_i18n_description->builder_i18n_translation->$language_id
    SET text = 'La clé i18n a été générée correctement';
    -- création du code
    CREATE type::thing('builder_error_code', 'severity.key.i18n.valid') SET
    severity = $success_id,
    success_result = true,
    message_key = $key_i18n_message,
    description = $key_i18n_description,
    metadata =  {} ,
    payload = {} ,
    created_at = time::now(),
    created_by = NONE ;
  

    -- Code ETAG
    -- severity.etag.mismatch
    -- création des clés i18n
    LET $key_i18n_message = type::thing('builder_i18n_key', 'severity.etag.mismatch.message');
    LET $key_i18n_description = type::thing('builder_i18n_key', 'severity.etag.mismatch.description');
    CREATE $key_i18n_message;
    CREATE $key_i18n_description;
    -- création des translations
    RELATE $key_i18n_message->builder_i18n_translation->$language_id
    SET text = 'Conflit de version (etag)';
    RELATE $key_i18n_description->builder_i18n_translation->$language_id
    SET text = 'L\'etag fourni ne correspond pas à la version actuelle de la ressource';
    -- création du code
    CREATE type::thing('builder_error_code', 'severity.etag.mismatch') SET
    severity = $error_id,
    success_result = false,
    message_key = $key_i18n_message,
    description = $key_i18n_description,
    metadata =  {} ,
    payload = {} ,
    created_at = time::now(),
    created_by = NONE ;