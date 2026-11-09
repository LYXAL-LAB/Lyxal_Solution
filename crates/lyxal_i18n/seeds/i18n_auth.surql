-- ============================================================================
-- SEEDS : permissions lyxal_auth des langues
-- MODULE : lyxal_i18n
-- ============================================================================
-- Rejouable et non destructif : permission et attribution créées seulement si elles n'existent pas.

IF !record::exists(auth_permission:⟨i18n.locale.manage⟩) THEN (
    CREATE auth_permission:⟨i18n.locale.manage⟩ CONTENT { code: "i18n.locale.manage", module: "lyxal_i18n", scope: "installation", description: { fr: "Activer les langues de l'installation et choisir la langue par défaut", en: "Enable the installation languages and choose the default language" } }
) END;

IF array::len(SELECT VALUE id FROM auth_role_grants WHERE in = auth_role:platform_admin AND out = auth_permission:⟨i18n.locale.manage⟩) = 0 THEN (
    RELATE auth_role:platform_admin->auth_role_grants->auth_permission:⟨i18n.locale.manage⟩
) END;
