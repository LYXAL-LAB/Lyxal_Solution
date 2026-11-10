-- ============================================================================
-- SEEDS : permissions lyxal_auth des langues et des traductions
-- MODULE : lyxal_i18n
-- ============================================================================
-- Rejouable et non destructif : permissions et attributions créées seulement si elles n'existent pas.

IF !record::exists(auth_permission:⟨i18n.locale.manage⟩) THEN (
    CREATE auth_permission:⟨i18n.locale.manage⟩ CONTENT { code: "i18n.locale.manage", module: "lyxal_i18n", scope: "installation", description: { fr: "Activer les langues de l'installation et choisir la langue par défaut", en: "Enable the installation languages and choose the default language" } }
) END;

IF array::len(SELECT VALUE id FROM auth_role_grants WHERE in = auth_role:platform_admin AND out = auth_permission:⟨i18n.locale.manage⟩) = 0 THEN (
    RELATE auth_role:platform_admin->auth_role_grants->auth_permission:⟨i18n.locale.manage⟩
) END;

IF !record::exists(auth_permission:⟨i18n.translation.manage⟩) THEN (
    CREATE auth_permission:⟨i18n.translation.manage⟩ CONTENT { code: "i18n.translation.manage", module: "lyxal_i18n", scope: "installation", description: { fr: "Gérer les espaces de noms, les clés et les textes de l'installation et des organisations", en: "Manage namespaces, keys and the texts of the installation and of organizations" } }
) END;
IF !record::exists(auth_permission:⟨i18n.organization.translation.manage⟩) THEN (
    CREATE auth_permission:⟨i18n.organization.translation.manage⟩ CONTENT { code: "i18n.organization.translation.manage", module: "lyxal_i18n", scope: "organization", description: { fr: "Modifier les textes pour son organisation", en: "Override texts for one's organization" } }
) END;

IF array::len(SELECT VALUE id FROM auth_role_grants WHERE in = auth_role:platform_admin AND out = auth_permission:⟨i18n.translation.manage⟩) = 0 THEN (
    RELATE auth_role:platform_admin->auth_role_grants->auth_permission:⟨i18n.translation.manage⟩
) END;
IF array::len(SELECT VALUE id FROM auth_role_grants WHERE in = auth_role:organization_admin AND out = auth_permission:⟨i18n.organization.translation.manage⟩) = 0 THEN (
    RELATE auth_role:organization_admin->auth_role_grants->auth_permission:⟨i18n.organization.translation.manage⟩
) END;
