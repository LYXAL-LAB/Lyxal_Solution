-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/siret.surql
-- Fonction     : fn::validation_siret
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide un numéro SIRET français à quatorze chiffres et sépare SIREN et NIC.
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

DEFINE FUNCTION OVERWRITE fn::validation_siret(
    $value: option<any>,
    $field: string
) -> object {
    LET $siret = fn::validation_luhn($value, $field, 14, 14);
    RETURN {
        siret: $siret,
        siren: string::slice($siret, 0, 9),
        nic: string::slice($siret, 9, 14)
    };
}
COMMENT "Valide un SIRET français et retourne son SIREN et son NIC."
PERMISSIONS FULL;
