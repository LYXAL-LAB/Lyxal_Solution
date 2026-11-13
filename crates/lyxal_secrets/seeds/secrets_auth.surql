-- ============================================================================
-- SEEDS : permissions lyxal_auth du coffre-fort
-- MODULE : lyxal_secrets
-- ============================================================================
-- Rejouable et non destructif : permissions et attributions créées seulement si elles n'existent
-- pas. Moindre privilège : organization_admin ne reçoit ni secrets.value.read ni
-- secrets.secret.purge, attribuées explicitement ; secrets.worker n'est attribuée à aucun rôle
-- (compte de service du worker).

IF !record::exists(auth_permission:⟨secrets.secret.list⟩) THEN (
    CREATE auth_permission:⟨secrets.secret.list⟩ CONTENT { code: "secrets.secret.list", module: "lyxal_secrets", scope: "organization", description: { fr: "Lire les fiches et les versions des secrets de son organisation, sans valeur", en: "Read one's organization secret records and versions, without values" } }
) END;

IF !record::exists(auth_permission:⟨secrets.value.read⟩) THEN (
    CREATE auth_permission:⟨secrets.value.read⟩ CONTENT { code: "secrets.value.read", module: "lyxal_secrets", scope: "organization", description: { fr: "Lire la valeur d'un secret de son organisation (humain : secret révélable et double facteur)", en: "Read a secret value of one's organization (human: revealable secret and second factor)" } }
) END;

IF !record::exists(auth_permission:⟨secrets.secret.write⟩) THEN (
    CREATE auth_permission:⟨secrets.secret.write⟩ CONTENT { code: "secrets.secret.write", module: "lyxal_secrets", scope: "organization", description: { fr: "Créer des secrets, modifier leurs fiches, ajouter des versions, déplacer des étiquettes, désactiver et réactiver", en: "Create secrets, edit their records, add versions, move labels, disable and enable" } }
) END;

IF !record::exists(auth_permission:⟨secrets.secret.delete⟩) THEN (
    CREATE auth_permission:⟨secrets.secret.delete⟩ CONTENT { code: "secrets.secret.delete", module: "lyxal_secrets", scope: "organization", description: { fr: "Supprimer des secrets (suppression douce) et détruire des versions", en: "Delete secrets (soft delete) and destroy versions" } }
) END;

IF !record::exists(auth_permission:⟨secrets.secret.restore⟩) THEN (
    CREATE auth_permission:⟨secrets.secret.restore⟩ CONTENT { code: "secrets.secret.restore", module: "lyxal_secrets", scope: "organization", description: { fr: "Restaurer des secrets supprimés", en: "Restore deleted secrets" } }
) END;

IF !record::exists(auth_permission:⟨secrets.secret.purge⟩) THEN (
    CREATE auth_permission:⟨secrets.secret.purge⟩ CONTENT { code: "secrets.secret.purge", module: "lyxal_secrets", scope: "organization", description: { fr: "Purger un secret supprimé avant sa date de purge", en: "Purge a deleted secret before its purge date" } }
) END;

IF !record::exists(auth_permission:⟨secrets.audit.read⟩) THEN (
    CREATE auth_permission:⟨secrets.audit.read⟩ CONTENT { code: "secrets.audit.read", module: "lyxal_secrets", scope: "organization", description: { fr: "Lire et vérifier le journal du coffre-fort de son organisation", en: "Read and verify one's organization vault journal" } }
) END;

IF !record::exists(auth_permission:⟨secrets.settings.manage⟩) THEN (
    CREATE auth_permission:⟨secrets.settings.manage⟩ CONTENT { code: "secrets.settings.manage", module: "lyxal_secrets", scope: "organization", description: { fr: "Régler le coffre-fort de son organisation (dont la protection contre la purge)", en: "Configure one's organization vault (including purge protection)" } }
) END;

IF !record::exists(auth_permission:⟨secrets.installation.manage⟩) THEN (
    CREATE auth_permission:⟨secrets.installation.manage⟩ CONTENT { code: "secrets.installation.manage", module: "lyxal_secrets", scope: "installation", description: { fr: "Gérer les secrets, le journal et les réglages du coffre-fort de l'installation", en: "Manage the installation vault secrets, journal and settings" } }
) END;

IF !record::exists(auth_permission:⟨secrets.worker⟩) THEN (
    CREATE auth_permission:⟨secrets.worker⟩ CONTENT { code: "secrets.worker", module: "lyxal_secrets", scope: "installation", description: { fr: "Compte de service du coffre-fort : purge à échéance, rescellement", en: "Vault service account: due purge, resealing" } }
) END;

IF array::len(SELECT VALUE id FROM auth_role_grants WHERE in = auth_role:organization_admin AND out = auth_permission:⟨secrets.secret.list⟩) = 0 THEN (
    RELATE auth_role:organization_admin->auth_role_grants->auth_permission:⟨secrets.secret.list⟩
) END;

IF array::len(SELECT VALUE id FROM auth_role_grants WHERE in = auth_role:organization_admin AND out = auth_permission:⟨secrets.secret.write⟩) = 0 THEN (
    RELATE auth_role:organization_admin->auth_role_grants->auth_permission:⟨secrets.secret.write⟩
) END;

IF array::len(SELECT VALUE id FROM auth_role_grants WHERE in = auth_role:organization_admin AND out = auth_permission:⟨secrets.secret.delete⟩) = 0 THEN (
    RELATE auth_role:organization_admin->auth_role_grants->auth_permission:⟨secrets.secret.delete⟩
) END;

IF array::len(SELECT VALUE id FROM auth_role_grants WHERE in = auth_role:organization_admin AND out = auth_permission:⟨secrets.secret.restore⟩) = 0 THEN (
    RELATE auth_role:organization_admin->auth_role_grants->auth_permission:⟨secrets.secret.restore⟩
) END;

IF array::len(SELECT VALUE id FROM auth_role_grants WHERE in = auth_role:organization_admin AND out = auth_permission:⟨secrets.audit.read⟩) = 0 THEN (
    RELATE auth_role:organization_admin->auth_role_grants->auth_permission:⟨secrets.audit.read⟩
) END;

IF array::len(SELECT VALUE id FROM auth_role_grants WHERE in = auth_role:organization_admin AND out = auth_permission:⟨secrets.settings.manage⟩) = 0 THEN (
    RELATE auth_role:organization_admin->auth_role_grants->auth_permission:⟨secrets.settings.manage⟩
) END;

IF array::len(SELECT VALUE id FROM auth_role_grants WHERE in = auth_role:platform_admin AND out = auth_permission:⟨secrets.installation.manage⟩) = 0 THEN (
    RELATE auth_role:platform_admin->auth_role_grants->auth_permission:⟨secrets.installation.manage⟩
) END;
