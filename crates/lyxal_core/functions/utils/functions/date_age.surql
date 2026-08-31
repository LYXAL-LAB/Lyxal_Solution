-- ============================================================================
-- LYXAL OS — CORE UTILS
-- ============================================================================
-- Fonction : fn::utils_date_age
-- Version  : 1.0.0
-- Statut   : Stable
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
