-- =====================================================================
-- FONCTION CREATE - Identity Status
-- Il faudra plus tard insérer la notion de clé i18n pour le libellé et la description
-- Il faudra aussi insérer la notion de couleur et d'icône
-- Il faudra aussi insérer les logs et code d'erreur
-- =====================================================================

DEFINE FUNCTION IF NOT EXISTS fn::identity_create_identity_status(
    $label: string,
    $description: string,
    $is_active: bool
) {
    -- Validation des paramètres obligatoires
    IF !$label {
        THROW "Libellé est obligatoire";
    };

    -- Création du code à partir du libellé
    LET $code = string::uppercase(string::replace(string::trim($label), ' ', '_'));
    -- Vérifier que le code n'existe pas déjà
    LET $existing = SELECT id FROM identity_status WHERE code = $code LIMIT 1;
    IF $existing {
        THROW "Un statut avec le code '" + $code + "' existe déjà";
    };
    -- Créer le nouveau statut
    LET $new_status = CREATE identity_status SET
        code = $code,
        label = $label,
        description = $description,
}