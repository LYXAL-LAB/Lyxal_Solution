-- =============================================================================================
-- |
-- | Fichier     : i18n_address_format_seeds.surql
-- | Module      : i18n
-- | Description : Peuple la table `i18n_address_format` avec un format par défaut.
-- |
-- =============================================================================================

-- Crée un format d'adresse générique par défaut.
-- Ce format pourra être utilisé pour les pays qui n'ont pas de spécificité majeure.
CREATE i18n_address_format:default
    SET template = {
            line1: '{name}',
            line2: '{street}',
            line3: '{postalCode} {city}',
            line4: '{country}'
        },
        requiresState = false,
        uppercasePostalCode = true,
        example = 'M. Jean Dupont\n123 Rue de la République\n75001 PARIS\nFRANCE';
