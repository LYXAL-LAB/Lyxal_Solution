-- =============================================================================================
-- |
-- | Fichier : time_unit_seeds.surql
-- | Module : System / Reference
-- | Description : Seeds pour la table de référence `time_unit`.
-- |               Crée toutes les unités de temps utilisables dans le système.
-- |
-- | Dépendances :
-- |   - fn::create_time_unit
-- |   - i18n_config (pour la langue par défaut)
-- =============================================================================================

BEGIN;

-- =============================================================================================
-- | Unités de temps de base
-- =============================================================================================

-- Seconds
fn::create_time_unit(
    "SECONDS",
    "time_unit_seconds_label",
    1,
    true,
    "Secondes",
    NONE,
    NONE,
    true,
    "system"
);

-- Minutes
fn::create_time_unit(
    "MINUTES",
    "time_unit_minutes_label",
    2,
    true,
    "Minutes",
    NONE,
    NONE,
    true,
    "system"
);

-- Hours
fn::create_time_unit(
    "HOURS",
    "time_unit_hours_label",
    3,
    true,
    "Heures",
    NONE,
    NONE,
    true,
    "system"
);

-- Days
fn::create_time_unit(
    "DAYS",
    "time_unit_days_label",
    4,
    true,
    "Jours",
    NONE,
    NONE,
    true,
    "system"
);

-- Weeks
fn::create_time_unit(
    "WEEKS",
    "time_unit_weeks_label",
    5,
    true,
    "Semaines",
    NONE,
    NONE,
    true,
    "system"
);

-- Months
fn::create_time_unit(
    "MONTHS",
    "time_unit_months_label",
    6,
    true,
    "Mois",
    NONE,
    NONE,
    true,
    "system"
);

-- Years
fn::create_time_unit(
    "YEARS",
    "time_unit_years_label",
    7,
    true,
    "Années",
    NONE,
    NONE,
    true,
    "system"
);

COMMIT;

