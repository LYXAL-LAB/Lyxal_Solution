-- =============================================================================================
-- |
-- | Fichier : time_unit_error_code_seeds.surql
-- | Module : System / Reference / time_unit
-- | Description : Seeds pour les codes d'erreur de la fonction `fn_create_time_unit`.
-- |               Utilise uniquement fn::create_error_code (les clés i18n sont créées automatiquement via events).
-- |
-- =============================================================================================

BEGIN;

-- =============================================================================================
-- | Codes d'erreur pour fn::create_time_unit
-- =============================================================================================

-- Code requis
fn::create_error_code(
    "TIME_UNIT_CODE_REQUIRED",
    "error_code_time_unit_code_required_message",
    "error",
    false,
    "Le code de l'unité de temps est requis.",
    "error_code_time_unit_code_required_label",
    "Code requis",
    "error_code_time_unit_code_required_description",
    "Le code de l'unité de temps (ex: DAYS, WEEKS, MONTHS) est obligatoire pour créer une unité de temps.",
    "validation",
    "Vérifier que le paramètre code est fourni et non vide.",
    NONE,
    "time_unit"
);

-- Label i18n requis
fn::create_error_code(
    "TIME_UNIT_LABEL_I18N_REQUIRED",
    "error_code_time_unit_label_i18n_required_message",
    "error",
    false,
    "L'identifiant de la clé i18n du libellé est requis.",
    "error_code_time_unit_label_i18n_required_label",
    "Clé i18n requise",
    "error_code_time_unit_label_i18n_required_description",
    "L'identifiant de la clé i18n du libellé (ex: time_unit_days_label) est obligatoire pour créer une unité de temps.",
    "validation",
    "Vérifier que le paramètre label_i18n est fourni et non vide.",
    NONE,
    "time_unit"
);

-- Label source requis
fn::create_error_code(
    "TIME_UNIT_LABEL_SOURCE_REQUIRED",
    "error_code_time_unit_label_source_required_message",
    "error",
    false,
    "Le libellé source est requis.",
    "error_code_time_unit_label_source_required_label",
    "Libellé source requis",
    "error_code_time_unit_label_source_required_description",
    "Le libellé source en langue par défaut (ex: \"Jours\", \"Semaines\") est obligatoire pour créer une unité de temps.",
    "validation",
    "Vérifier que le paramètre label_source est fourni et non vide.",
    NONE,
    "time_unit"
);

-- Rank requis
fn::create_error_code(
    "TIME_UNIT_RANK_REQUIRED",
    "error_code_time_unit_rank_required_message",
    "error",
    false,
    "Le rang est requis.",
    "error_code_time_unit_rank_required_label",
    "Rang requis",
    "error_code_time_unit_rank_required_description",
    "Le rang (ordre d'affichage) est obligatoire pour créer une unité de temps (1=seconds, 2=minutes, 3=hours, 4=days, 5=weeks, 6=months, 7=years).",
    "validation",
    "Vérifier que le paramètre rank est fourni et est un nombre valide.",
    NONE,
    "time_unit"
);

-- Unité déjà existante
fn::create_error_code(
    "TIME_UNIT_ALREADY_EXISTS",
    "error_code_time_unit_already_exists_message",
    "error",
    false,
    "L'unité de temps avec le code spécifié existe déjà.",
    "error_code_time_unit_already_exists_label",
    "Unité déjà existante",
    "error_code_time_unit_already_exists_description",
    "Une unité de temps avec le même code existe déjà dans la base de données. Chaque code doit être unique.",
    "validation",
    "Vérifier que le code de l'unité de temps n'existe pas déjà, ou utiliser un code différent.",
    NONE,
    "time_unit"
);

-- Création réussie
fn::create_error_code(
    "TIME_UNIT_CREATED_SUCCESS",
    "error_code_time_unit_created_success_message",
    "success",
    true,
    "L'unité de temps a été créée avec succès.",
    "error_code_time_unit_created_success_label",
    "Unité créée",
    "error_code_time_unit_created_success_description",
    "L'unité de temps a été créée avec succès dans la table de référence time_unit.",
    "system",
    "L'unité de temps est maintenant disponible pour utilisation dans le système.",
    NONE,
    "time_unit"
);

COMMIT;

