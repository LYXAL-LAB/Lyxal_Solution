-- ============================================================================
-- SEEDS : permissions lyxal_auth du stockage
-- MODULE : lyxal_storage
-- ============================================================================
-- Rejouable et non destructif : permissions et attributions créées seulement si elles n'existent
-- pas. La permission storage.worker n'est attribuée à aucun rôle : elle est réservée au compte de
-- service du worker.

IF !record::exists(auth_permission:⟨storage.object.read⟩) THEN (
    CREATE auth_permission:⟨storage.object.read⟩ CONTENT { code: "storage.object.read", module: "lyxal_storage", scope: "organization", description: { fr: "Lire les fiches et les fichiers de son organisation", en: "Read one's organization file records and files" } }
) END;

IF !record::exists(auth_permission:⟨storage.object.write⟩) THEN (
    CREATE auth_permission:⟨storage.object.write⟩ CONTENT { code: "storage.object.write", module: "lyxal_storage", scope: "organization", description: { fr: "Écrire et supprimer des fichiers de son organisation", en: "Write and delete one's organization files" } }
) END;

IF !record::exists(auth_permission:⟨storage.bucket.manage⟩) THEN (
    CREATE auth_permission:⟨storage.bucket.manage⟩ CONTENT { code: "storage.bucket.manage", module: "lyxal_storage", scope: "organization", description: { fr: "Créer et régler les buckets et les réglages de stockage de son organisation", en: "Create and configure one's organization buckets and storage settings" } }
) END;

IF !record::exists(auth_permission:⟨storage.installation.manage⟩) THEN (
    CREATE auth_permission:⟨storage.installation.manage⟩ CONTENT { code: "storage.installation.manage", module: "lyxal_storage", scope: "installation", description: { fr: "Gérer les buckets, les fichiers et les réglages de stockage de l'installation", en: "Manage the installation buckets, files and storage settings" } }
) END;

IF !record::exists(auth_permission:⟨storage.worker⟩) THEN (
    CREATE auth_permission:⟨storage.worker⟩ CONTENT { code: "storage.worker", module: "lyxal_storage", scope: "installation", description: { fr: "Compte de service du stockage : terminer une écriture, expirer, purger, mettre en quarantaine", en: "Storage service account: complete a write, expire, purge, quarantine" } }
) END;

IF array::len(SELECT VALUE id FROM auth_role_grants WHERE in = auth_role:organization_admin AND out = auth_permission:⟨storage.object.read⟩) = 0 THEN (
    RELATE auth_role:organization_admin->auth_role_grants->auth_permission:⟨storage.object.read⟩
) END;

IF array::len(SELECT VALUE id FROM auth_role_grants WHERE in = auth_role:organization_admin AND out = auth_permission:⟨storage.object.write⟩) = 0 THEN (
    RELATE auth_role:organization_admin->auth_role_grants->auth_permission:⟨storage.object.write⟩
) END;

IF array::len(SELECT VALUE id FROM auth_role_grants WHERE in = auth_role:organization_admin AND out = auth_permission:⟨storage.bucket.manage⟩) = 0 THEN (
    RELATE auth_role:organization_admin->auth_role_grants->auth_permission:⟨storage.bucket.manage⟩
) END;

IF array::len(SELECT VALUE id FROM auth_role_grants WHERE in = auth_role:platform_admin AND out = auth_permission:⟨storage.installation.manage⟩) = 0 THEN (
    RELATE auth_role:platform_admin->auth_role_grants->auth_permission:⟨storage.installation.manage⟩
) END;
