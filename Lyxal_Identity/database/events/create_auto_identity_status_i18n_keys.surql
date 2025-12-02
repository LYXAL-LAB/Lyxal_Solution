-- =====================================================================
-- EVENT : Création du statut identité
-- =====================================================================

DEFINE EVENT IF NOT EXISTS create_auto_identity_status_i18n_keys ON TABLE identity_status
WHEN $event = "CREATE" THEN {
    -- Log de l'événement de création du statut
    -- lancement de la création des clés i18n pour le libellé et la description
};