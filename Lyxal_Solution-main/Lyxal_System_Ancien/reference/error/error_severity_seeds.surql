-- =============================================================================================
-- |
-- | Fichier : error_severity_seeds.surql
-- | Module : base
-- | Description : Initialisation des données de référence (seeds) pour la table
-- |               `error_severity`, en accord avec la structure immuable.
-- |               Utilise uniquement fn::create_error_severity (les clés i18n doivent exister).
-- |
-- =============================================================================================
BEGIN;
-- 1. Sévérité : 'SUCCESS' (rank=0)
fn::create_error_severity("SUCCESS", "error_severity_success_label", 0, true, "Succès", "error_severity_success_description", "Opération réussie", NONE, NONE, NONE);

-- 2. Sévérité : 'INFO' (rank=10)
fn::create_error_severity("INFO", "error_severity_info_label", 10, true, "Information", "error_severity_info_description", "Information générale", NONE, NONE, NONE);

-- 3. Sévérité : 'WARNING' (rank=20)
fn::create_error_severity("WARNING", "error_severity_warning_label", 20, true, "Avertissement", "error_severity_warning_description", "Attention requise", NONE, NONE, NONE);

-- 4. Sévérité : 'ERROR' (rank=30)
fn::create_error_severity("ERROR", "error_severity_error_label", 30, true, "Erreur", "error_severity_error_description", "Une erreur s'est produite", NONE, NONE, NONE);

-- 5. Sévérité : 'CRITICAL' (rank=40)
fn::create_error_severity("CRITICAL", "error_severity_critical_label", 40, true, "Critique", "error_severity_critical_description", "Erreur critique nécessitant une intervention immédiate", NONE, NONE, NONE);

COMMIT;