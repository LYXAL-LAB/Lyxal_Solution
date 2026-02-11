-- =============================================================================================
-- |
-- | Fichier : error_code_seeds.surql
-- | Module : base 
-- | Description : Seeds pour les codes d'erreur généraux et de secours du système.
-- |               Utilise uniquement fn::create_error_code (les clés i18n sont créées automatiquement via events).
-- |
-- =============================================================================================

BEGIN;
-- =============================================================================================
-- | Code d'erreur de secours
-- =============================================================================================
-- | Ce code est utilisé par `fn::lib_return_error` lorsqu'un `reason_code`
-- | demandé n'est pas trouvé. Il garantit qu'un message convivial est toujours
-- | retourné à l'utilisateur, même en cas d'erreur de configuration interne.
-- =============================================================================================

-- error.untranslatable
fn::create_error_code(
    "ERROR_UNTRANSLATABLE",
    "error_code_error_untranslatable_message",
    "error",
    false,
    "Une erreur inattendue est survenue. Veuillez réessayer.",
    "error_code_error_untranslatable_label",
    "Erreur inattendue",
    "error_code_error_untranslatable_description",
    "Code d'erreur de secours utilisé lorsqu'un code d'erreur demandé n'est pas trouvé dans la configuration système.",
    "system",
    "Vérifier la configuration du système et contacter le support technique si le problème persiste.",
    NONE,
    NONE
);

-- =============================================================================================
-- | Codes d'erreur généraux du système
-- =============================================================================================

-- Validation
fn::create_error_code(
    "VALIDATION_FAILED",
    "error_code_validation_failed_message",
    "error",
    false,
    "Les données fournies ne sont pas valides.",
    "error_code_validation_failed_label",
    "Erreur de validation",
    "error_code_validation_failed_description",
    "Les données soumises ne respectent pas les règles de validation définies.",
    "validation",
    "Vérifier les données saisies et respecter les contraintes de validation.",
    NONE,
    NONE
);

-- Ressource non trouvée
fn::create_error_code(
    "RESOURCE_NOT_FOUND",
    "error_code_resource_not_found_message",
    "error",
    false,
    "La ressource demandée est introuvable.",
    "error_code_resource_not_found_label",
    "Ressource introuvable",
    "error_code_resource_not_found_description",
    "La ressource demandée n'existe pas ou n'est plus disponible.",
    "system",
    "Vérifier l'identifiant de la ressource et son existence dans le système.",
    NONE,
    NONE
);

-- Accès non autorisé
fn::create_error_code(
    "UNAUTHORIZED_ACCESS",
    "error_code_unauthorized_access_message",
    "error",
    false,
    "Vous n'êtes pas autorisé à accéder à cette ressource.",
    "error_code_unauthorized_access_label",
    "Accès non autorisé",
    "error_code_unauthorized_access_description",
    "L'utilisateur n'a pas les permissions nécessaires pour accéder à cette ressource.",
    "authentication",
    "Vérifier vos permissions ou contacter un administrateur.",
    NONE,
    NONE
);

-- Erreur serveur
fn::create_error_code(
    "INTERNAL_SERVER_ERROR",
    "error_code_internal_server_error_message",
    "critical",
    false,
    "Une erreur interne du serveur est survenue.",
    "error_code_internal_server_error_label",
    "Erreur serveur",
    "error_code_internal_server_error_description",
    "Une erreur interne s'est produite lors du traitement de la requête.",
    "system",
    "Contacter le support technique avec les détails de l'erreur.",
    NONE,
    NONE
);

-- =============================================================================================
-- | Codes d'erreur pour fn::create_error_severity
-- =============================================================================================

-- Code de la sévérité requis (ligne 21)
fn::create_error_code(
    "ERROR_SEVERITY_CODE_REQUIRED",
    "error_code_error_severity_code_required_message",
    "error",
    false,
    "Le code de la sévérité est requis.",
    "error_code_error_severity_code_required_label",
    "Code de sévérité requis",
    "error_code_error_severity_code_required_description",
    "Le paramètre code de la sévérité est obligatoire et ne peut pas être vide.",
    "validation",
    "Fournir un code de sévérité valide (ex: INFO, WARNING, ERROR).",
    NONE,
    "error_severity"
);

-- Identifiant de la clé i18n du libellé requis (ligne 24)
fn::create_error_code(
    "ERROR_SEVERITY_LABEL_I18N_REQUIRED",
    "error_code_error_severity_label_i18n_required_message",
    "error",
    false,
    "L'identifiant de la clé i18n du libellé est requis.",
    "error_code_error_severity_label_i18n_required_label",
    "Clé i18n du libellé requise",
    "error_code_error_severity_label_i18n_required_description",
    "Le paramètre label_i18n est obligatoire et ne peut pas être vide.",
    "validation",
    "Fournir un identifiant de clé i18n valide pour le libellé.",
    NONE,
    "error_severity"
);

-- Libellé source requis (ligne 27)
fn::create_error_code(
    "ERROR_SEVERITY_LABEL_SOURCE_REQUIRED",
    "error_code_error_severity_label_source_required_message",
    "error",
    false,
    "Le libellé source est requis.",
    "error_code_error_severity_label_source_required_label",
    "Libellé source requis",
    "error_code_error_severity_label_source_required_description",
    "Le paramètre label_source est obligatoire et ne peut pas être vide.",
    "validation",
    "Fournir un libellé source en langue par défaut.",
    NONE,
    "error_severity"
);

-- Rang requis (ligne 30)
fn::create_error_code(
    "ERROR_SEVERITY_RANK_REQUIRED",
    "error_code_error_severity_rank_required_message",
    "error",
    false,
    "Le rang est requis.",
    "error_code_error_severity_rank_required_label",
    "Rang requis",
    "error_code_error_severity_rank_required_description",
    "Le paramètre rank est obligatoire et doit être un nombre.",
    "validation",
    "Fournir un rang numérique pour ordonner les niveaux de sévérité.",
    NONE,
    "error_severity"
);

-- Sévérité déjà existante (ligne 49)
fn::create_error_code(
    "ERROR_SEVERITY_ALREADY_EXISTS",
    "error_code_error_severity_already_exists_message",
    "error",
    false,
    "La sévérité avec le code spécifié existe déjà.",
    "error_code_error_severity_already_exists_label",
    "Sévérité déjà existante",
    "error_code_error_severity_already_exists_description",
    "Une sévérité avec le même code existe déjà dans le système.",
    "validation",
    "Utiliser un code de sévérité différent ou modifier la sévérité existante.",
    NONE,
    "error_severity"
);

-- Succès création sévérité (ligne 99)
fn::create_error_code(
    "ERROR_SEVERITY_CREATED_SUCCESS",
    "error_code_error_severity_created_success_message",
    "success",
    true,
    "La sévérité a été créée avec succès.",
    "error_code_error_severity_created_success_label",
    "Sévérité créée",
    "error_code_error_severity_created_success_description",
    "La sévérité d'erreur a été créée avec succès dans le système.",
    "system",
    "La sévérité est maintenant disponible pour utilisation.",
    NONE,
    "error_severity"
);

-- =============================================================================================
-- | Codes d'erreur pour fn::create_error_code
-- =============================================================================================

-- Code de l'erreur requis (ligne 24)
fn::create_error_code(
    "ERROR_CODE_CODE_REQUIRED",
    "error_code_error_code_code_required_message",
    "error",
    false,
    "Le code de l'erreur est requis.",
    "error_code_error_code_code_required_label",
    "Code d'erreur requis",
    "error_code_error_code_code_required_description",
    "Le paramètre code de l'erreur est obligatoire et ne peut pas être vide.",
    "validation",
    "Fournir un code d'erreur valide (ex: USER_NOT_FOUND, INVALID_CREDENTIALS).",
    NONE,
    "error_code"
);

-- Identifiant de la clé i18n du message requis (ligne 27)
fn::create_error_code(
    "ERROR_CODE_MESSAGE_I18N_REQUIRED",
    "error_code_error_code_message_i18n_required_message",
    "error",
    false,
    "L'identifiant de la clé i18n du message est requis.",
    "error_code_error_code_message_i18n_required_label",
    "Clé i18n du message requise",
    "error_code_error_code_message_i18n_required_description",
    "Le paramètre message_i18n est obligatoire et ne peut pas être vide.",
    "validation",
    "Fournir un identifiant de clé i18n valide pour le message.",
    NONE,
    "error_code"
);

-- Message source requis (ligne 30)
fn::create_error_code(
    "ERROR_CODE_MESSAGE_SOURCE_REQUIRED",
    "error_code_error_code_message_source_required_message",
    "error",
    false,
    "Le message source est requis.",
    "error_code_error_code_message_source_required_label",
    "Message source requis",
    "error_code_error_code_message_source_required_description",
    "Le paramètre message_source est obligatoire et ne peut pas être vide.",
    "validation",
    "Fournir un message source en langue par défaut.",
    NONE,
    "error_code"
);

-- Identifiant de la sévérité requis (ligne 33)
fn::create_error_code(
    "ERROR_CODE_SEVERITY_REQUIRED",
    "error_code_error_code_severity_required_message",
    "error",
    false,
    "L'identifiant de la sévérité est requis.",
    "error_code_error_code_severity_required_label",
    "Sévérité requise",
    "error_code_error_code_severity_required_description",
    "Le paramètre severity est obligatoire et ne peut pas être vide.",
    "validation",
    "Fournir un identifiant de sévérité valide (ex: ERROR, WARNING, CRITICAL).",
    NONE,
    "error_code"
);

-- Résultat de succès requis (ligne 36)
fn::create_error_code(
    "ERROR_CODE_SUCCESS_RESULT_REQUIRED",
    "error_code_error_code_success_result_required_message",
    "error",
    false,
    "Le résultat de succès est requis.",
    "error_code_error_code_success_result_required_label",
    "Résultat de succès requis",
    "error_code_error_code_success_result_required_description",
    "Le paramètre success_result est obligatoire et doit être un booléen.",
    "validation",
    "Fournir un résultat de succès (true ou false).",
    NONE,
    "error_code"
);

-- Code d'erreur déjà existant (ligne 55)
fn::create_error_code(
    "ERROR_CODE_ALREADY_EXISTS",
    "error_code_error_code_already_exists_message",
    "error",
    false,
    "Le code d'erreur spécifié existe déjà.",
    "error_code_error_code_already_exists_label",
    "Code d'erreur déjà existant",
    "error_code_error_code_already_exists_description",
    "Un code d'erreur avec le même code existe déjà dans le système.",
    "validation",
    "Utiliser un code d'erreur différent ou modifier le code d'erreur existant.",
    NONE,
    "error_code"
);

-- Sévérité n'existe pas (ligne 78)
fn::create_error_code(
    "ERROR_CODE_SEVERITY_NOT_FOUND",
    "error_code_error_code_severity_not_found_message",
    "error",
    false,
    "La sévérité spécifiée n'existe pas.",
    "error_code_error_code_severity_not_found_label",
    "Sévérité introuvable",
    "error_code_error_code_severity_not_found_description",
    "La sévérité référencée n'existe pas dans le système.",
    "validation",
    "Vérifier que la sévérité existe avant de créer le code d'erreur.",
    NONE,
    "error_code"
);

-- Succès création code d'erreur (ligne 117)
fn::create_error_code(
    "ERROR_CODE_CREATED_SUCCESS",
    "error_code_error_code_created_success_message",
    "success",
    true,
    "Le code d'erreur a été créé avec succès.",
    "error_code_error_code_created_success_label",
    "Code d'erreur créé",
    "error_code_error_code_created_success_description",
    "Le code d'erreur a été créé avec succès dans le système.",
    "system",
    "Le code d'erreur est maintenant disponible pour utilisation.",
    NONE,
    "error_code"
);

COMMIT;