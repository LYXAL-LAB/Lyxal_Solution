-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/utils/functions/date_age.surql
-- Fonction : fn::utils_date_age
--
-- Calcule l'âge entier à une date donnée.
--
-- Paramètres
--   $birth_date : datetime
--   $at         : datetime
--
-- Valeur renvoyée : int (contrat : crates/lyxal_core/Readme.md, fonctions utils)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::utils_date_age(
    $birth_date: datetime,
    $at: datetime
) -> int {
    LET $years = time::year($at)-time::year($birth_date);

    LET $birthday_passed =
        time::month($at) > time::month($birth_date)
        OR (
            time::month($at)=time::month($birth_date)
            AND time::day($at)>=time::day($birth_date)
        );

    RETURN $years - IF $birthday_passed { 0 } ELSE { 1 };
}
COMMENT "Calcule l'âge entier à une date donnée."
PERMISSIONS FULL;
