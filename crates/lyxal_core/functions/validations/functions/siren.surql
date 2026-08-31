-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/siren.surql
-- Fonction     : fn::validation_siren
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide un numéro SIREN français à neuf chiffres par Luhn.
--
-- Principes
-- ----------
--   - distinction stricte entre NONE, NULL et type invalide ;
--   - aucune conversion implicite de la valeur métier ;
--   - codes d'erreur stables construits depuis le nom technique du champ ;
--   - aucune lecture ou écriture persistante ;
--   - aucune vérification auprès d'un service bancaire ou administratif.
--
-- Permissions
-- -----------
-- PERMISSIONS FULL
--
-- Dépendances Lyxal
-- -----------------
-- fn::validation_luhn()

-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_siren(
    $value: option<any>,
    $field: string
) -> string {
    RETURN fn::validation_luhn($value, $field, 9, 9);
}
COMMENT "Valide un numéro SIREN français à neuf chiffres par Luhn."
PERMISSIONS FULL;
