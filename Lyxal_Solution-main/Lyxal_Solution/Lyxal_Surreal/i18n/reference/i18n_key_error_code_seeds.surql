-- =============================================================================================
-- |
-- | Fichier : i18n_key_error_code_seeds.surql
-- | Module : i18n / reference
-- | Description : Seeds pour les codes d'erreur de la section i18n_key
-- |               Implémente les 24 codes d'erreur de la section i18n_key.
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

    -- i18n.key.delete.success
    -- création des clés i18n
    LET $key_i18n_message = type::thing('i18n_key', 'i18n.key.delete.success.message');
    LET $key_i18n_description = type::thing('i18n_key', 'i18n.key.delete.success.description');
    CREATE $key_i18n_message;
    CREATE $key_i18n_description;
    -- création des translations
    RELATE $key_i18n_message->i18n_translation->$language_id 
    SET text = 'Clé i18n supprimée avec succès';
    RELATE $key_i18n_description->i18n_translation->$language_id 
    SET text = 'Suppression réussie de la clé i18n et de ses dépendances';
    -- création du code
    CREATE type::thing('error_code', 'i18n.key.delete.success') SET
    severity = $success_id,
    success_result = true,
    message_key = $key_i18n_message,
    description = $key_i18n_description,
    metadata =  {} ,
    payload = {} ,
    created_at = time::now(),
    created_by = NONE ;
    
    -- i18n.key.delete.failed
    -- création des clés i18n
    LET $key_i18n_message = type::thing('i18n_key', 'i18n.key.delete.failed.message');
    LET $key_i18n_description = type::thing('i18n_key', 'i18n.key.delete.failed.description');
    CREATE $key_i18n_message;
    CREATE $key_i18n_description;
    -- création des translations
    RELATE $key_i18n_message->i18n_translation->$language_id 
    SET text = 'Échec de la suppression de la clé i18n';
    RELATE $key_i18n_description->i18n_translation->$language_id 
    SET text = 'La suppression de la clé i18n a échoué';
    -- création du code
    CREATE type::thing('error_code', 'i18n.key.delete.failed') SET
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
    -- i18n.key.found
    -- création des clés i18n
    LET $key_i18n_message = type::thing('i18n_key', 'i18n.key.found.message');
    LET $key_i18n_description = type::thing('i18n_key', 'i18n.key.found.description');
    CREATE $key_i18n_message;
    CREATE $key_i18n_description;
    -- création des translations
    RELATE $key_i18n_message->i18n_translation->$language_id 
    SET text = 'Clé i18n trouvée';
    RELATE $key_i18n_description->i18n_translation->$language_id 
    SET text = 'La clé i18n demandée a été trouvée';
    -- création du code
    CREATE type::thing('error_code', 'i18n.key.found') SET
    severity = $info_id,
    success_result = true,
    message_key = $key_i18n_message,
    description = $key_i18n_description,
    metadata =  {} ,
    payload = {} ,
    created_at = time::now(),
    created_by = NONE ;
 
    -- i18n.key.not.found
    -- création des clés i18n
    LET $key_i18n_message = type::thing('i18n_key', 'i18n.key.not.found.message');
    LET $key_i18n_description = type::thing('i18n_key', 'i18n.key.not.found.description');
    CREATE $key_i18n_message;
    CREATE $key_i18n_description;
    -- création des translations
    RELATE $key_i18n_message->i18n_translation->$language_id 
    SET text = 'Clé i18n introuvable';
    RELATE $key_i18n_description->i18n_translation->$language_id 
    SET text = 'La clé i18n demandée n\'existe pas';
    -- création du code
    CREATE type::thing('error_code', 'i18n.key.not.found') SET
    severity = $warning_id,
    success_result = false,
    message_key = $key_i18n_message,
    description = $key_i18n_description,
    metadata =  {} ,
    payload = {} ,
    created_at = time::now(),
    created_by = NONE ;
    
    -- Codes SANITIZE
    -- i18n.key.sanitize.failed
    -- création des clés i18n
    LET $key_i18n_message = type::thing('i18n_key', 'i18n.key.sanitize.failed.message');
    LET $key_i18n_description = type::thing('i18n_key','i18n.key.sanitize.failed.description');
    CREATE $key_i18n_message;
    CREATE $key_i18n_description;
    -- création des translations
    RELATE $key_i18n_message->i18n_translation->$language_id 
    SET text = 'Clé i18n requise après sanitisation';
    RELATE $key_i18n_description->i18n_translation->$language_id 
    SET text = 'La clé i18n est vide après nettoyage';
    -- création du code
    CREATE type::thing('error_code', 'i18n.key.sanitize.failed') SET
    severity = $error_id,
    success_result = false,
    message_key = $key_i18n_message,
    description = $key_i18n_description,
    metadata =  {} ,
    payload = {} ,
    created_at = time::now(),
    created_by = NONE ;
    
    -- i18n.key.sanitize.success
    -- création des clés i18n
    LET $key_i18n_message = type::thing('i18n_key', 
    'i18n.key.sanitize.success.message');
    LET $key_i18n_description = type::thing('i18n_key', 
    'i18n.key.sanitize.success.description');
    CREATE $key_i18n_message;
    CREATE $key_i18n_description;
    -- création des translations
    RELATE $key_i18n_message->i18n_translation->$language_id
    SET text = 'Nettoyage de la clé i18n réussi';
    RELATE $key_i18n_description->i18n_translation->$language_id
    SET text = 'La clé i18n a été nettoyée avec succès';
    -- création du code
    CREATE type::thing('error_code', 'i18n.key.sanitize.success') SET
    severity = $success_id,
    success_result = true,
    message_key = $key_i18n_message,
    description = $key_i18n_description,
    metadata =  {} ,
    payload = {} ,
    created_at = time::now(),
    created_by = NONE ;
    
    -- Codes VALIDATE LENGTH

    -- i18n.key.length.min.violation
    -- création des clés i18n
    LET $key_i18n_message = type::thing('i18n_key', 'i18n.key.length.min.violation.message');
    LET $key_i18n_description = type::thing('i18n_key', 
    'i18n.key.length.min.violation.description');
    CREATE $key_i18n_message;
    CREATE $key_i18n_description;
    -- création des translations
    RELATE $key_i18n_message->i18n_translation->$language_id
    SET text = 'Longueur minimale non respectée';
    RELATE $key_i18n_description->i18n_translation->$language_id
    SET text = 'La valeur est trop courte';
    -- création du code
    CREATE type::thing('error_code', 'i18n.key.length.min.violation') SET
    severity = $error_id,
    success_result = false,
    message_key = $key_i18n_message,
    description = $key_i18n_description,
    metadata =  {} ,
    payload = {} ,
    created_at = time::now(),
    created_by = NONE ;

    -- i18n.key.length.max.violation
    -- création des clés i18n
    LET $key_i18n_message = type::thing('i18n_key', 'i18n.key.length.max.violation.message');
    LET $key_i18n_description = type::thing('i18n_key', 
    'i18n.key.length.max.violation.description');
    CREATE $key_i18n_message;
    CREATE $key_i18n_description;
    -- création des translations
    RELATE $key_i18n_message->i18n_translation->$language_id
    SET text = 'Longueur maximale dépassée';
    RELATE $key_i18n_description->i18n_translation->$language_id
    SET text = 'La valeur est trop longue';
    -- création du code
    CREATE type::thing('error_code', 'i18n.key.length.max.violation') SET
    severity = $error_id,
    success_result = false,
    message_key = $key_i18n_message,
    description = $key_i18n_description,
    metadata =  {} ,
    payload = {} ,
    created_at = time::now(),
    created_by = NONE ;

    -- i18n.key.length.success
    -- création des clés i18n
    LET $key_i18n_message = type::thing('i18n_key', 'i18n.key.length.success.message');
    LET $key_i18n_description = type::thing('i18n_key', 'i18n.key.length.success.description');
    CREATE $key_i18n_message;
    CREATE $key_i18n_description;
    -- création des translations
    RELATE $key_i18n_message->i18n_translation->$language_id
    SET text = 'Validation de longueur réussie';
    RELATE $key_i18n_description->i18n_translation->$language_id
    SET text = 'La longueur de la valeur est conforme';
    -- création du code
    CREATE type::thing('error_code', 'i18n.key.length.success') SET
    severity = $success_id,
    success_result = true,
    message_key = $key_i18n_message,
    description = $key_i18n_description,
    metadata =  {} ,
    payload = {} ,
    created_at = time::now(),
    created_by = NONE ;

    -- Codes VERIFY UNICITY
    -- i18n.key.unique
    -- création des clés i18n
    LET $key_i18n_message = type::thing('i18n_key', 'i18n.key.unique.message');
    LET $key_i18n_description = type::thing('i18n_key', 'i18n.key.unique.description');
    CREATE $key_i18n_message;
    CREATE $key_i18n_description;
    -- création des translations
    RELATE $key_i18n_message->i18n_translation->$language_id
    SET text = 'Clé i18n unique';
    RELATE $key_i18n_description->i18n_translation->$language_id
    SET text = 'La clé i18n n\'existe pas encore, création possible';
    -- création du code
    CREATE type::thing('error_code', 'i18n.key.unique') SET
    severity = $info_id,
    success_result = true,
    message_key = $key_i18n_message,
    description = $key_i18n_description,
    metadata =  {} ,
    payload = {} ,
    created_at = time::now(),
    created_by = NONE ;

    -- i18n.key.already.exists
    -- création des clés i18n
    LET $key_i18n_message = type::thing('i18n_key', 'i18n.key.already.exists.message');
    LET $key_i18n_description = type::thing('i18n_key', 
    'i18n.key.already.exists.description');
    CREATE $key_i18n_message;
    CREATE $key_i18n_description;
    -- création des translations
    RELATE $key_i18n_message->i18n_translation->$language_id
    SET text = 'Clé i18n déjà existante';
    RELATE $key_i18n_description->i18n_translation->$language_id
    SET text = 'Cette clé i18n existe déjà dans le registre';
    -- création du code
    CREATE type::thing('error_code', 'i18n.key.already.exists') SET
    severity = $warning_id,
    success_result = false,
    message_key = $key_i18n_message,
    description = $key_i18n_description,
    metadata =  {} ,
    payload = {} ,
    created_at = time::now(),
    created_by = NONE ;

   -- Codes I18N KEY SUFFIX
   -- i18n.key.suffix.invalid
   -- création des clés i18n
   LET $key_i18n_message = type::thing('i18n_key', 'i18n.key.suffix.invalid.message');
   LET $key_i18n_description = type::thing('i18n_key', 'i18n.key.suffix.invalid.description');
   CREATE $key_i18n_message;
   CREATE $key_i18n_description;
   -- création des translations
   RELATE $key_i18n_message->i18n_translation->$language_id
   SET text = 'Suffixe de clé i18n invalide';
   RELATE $key_i18n_description->i18n_translation->$language_id
   SET text = 'Le suffixe de la clé i18n doit être label, description ou message';
   -- création du code
   CREATE type::thing('error_code', 'i18n.key.suffix.invalid') SET
   severity = $error_id,
   success_result = false,
   message_key = $key_i18n_message,
   description = $key_i18n_description,
   metadata =  {} ,
   payload = {} ,
   created_at = time::now(),
   created_by = NONE ;
   
   -- i18n.key.suffix.valid
   -- création des clés i18n
   LET $key_i18n_message = type::thing('i18n_key', 'i18n.key.suffix.valid.message');
   LET $key_i18n_description = type::thing('i18n_key', 'i18n.key.suffix.valid.description');
   CREATE $key_i18n_message;
   CREATE $key_i18n_description;
   -- création des translations
   RELATE $key_i18n_message->i18n_translation->$language_id
   SET text = 'Suffixe de clé i18n valide';
   RELATE $key_i18n_description->i18n_translation->$language_id
   SET text = 'Le suffixe de la clé i18n est valide';
   -- création du code
   CREATE type::thing('error_code', 'i18n.key.suffix.valid') SET
   severity = $success_id,
   success_result = true,
   message_key = $key_i18n_message,
   description = $key_i18n_description,
   metadata =  {} ,
   payload = {} ,
   created_at = time::now(),
   created_by = NONE ;

    -- Codes I18N KEY GENERATE
    -- i18n.key.generate.failed
    -- création des clés i18n
    LET $key_i18n_message = type::thing('i18n_key', 'i18n.key.generate.failed.message');
    LET $key_i18n_description = type::thing('i18n_key', 'i18n.key.generate.failed.description');
    CREATE $key_i18n_message;
    CREATE $key_i18n_description;
    -- création des translations
    RELATE $key_i18n_message->i18n_translation->$language_id
    SET text = 'Échec de génération de la clé i18n';
    RELATE $key_i18n_description->i18n_translation->$language_id
    SET text = 'La génération de la clé i18n a échoué';
    -- création du code
    CREATE type::thing('error_code', 'i18n.key.generate.failed') SET
    severity = $error_id,
    success_result = false,
    message_key = $key_i18n_message,
    description = $key_i18n_description,
    metadata =  {} ,
    payload = {} ,
    created_at = time::now(),
    created_by = NONE ;

    -- i18n.key.generate.success
    -- création des clés i18n
    LET $key_i18n_message = type::thing('i18n_key', 'i18n.key.generate.success.message');
    LET $key_i18n_description = type::thing('i18n_key', 'i18n.key.generate.success.description');
    CREATE $key_i18n_message;
    CREATE $key_i18n_description;
    -- création des translations
    RELATE $key_i18n_message->i18n_translation->$language_id
    SET text = 'Génération de la clé i18n réussie';
    RELATE $key_i18n_description->i18n_translation->$language_id
    SET text = 'La clé i18n a été générée avec succès';
    -- création du code
    CREATE type::thing('error_code', 'i18n.key.generate.success') SET
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