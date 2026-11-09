-- ============================================================================
-- SEEDS : permissions et rôles lyxal_auth du catalogue
-- MODULE : lyxal_catalogue
-- ============================================================================
-- Rejouable et non destructif : chaque permission, rôle et attribution est créé seulement s'il
-- n'existe pas. Le rôle d'installation catalogue_sync est porté par le compte de service de
-- synchronisation (application lyxal-catalogue-sync, créée par lyxal_pipeline_ingestion).

IF !record::exists(auth_permission:⟨catalogue.item.read⟩) THEN (
    CREATE auth_permission:⟨catalogue.item.read⟩ CONTENT { code: "catalogue.item.read", module: "lyxal_catalogue", scope: "organization", description: { fr: "Lire le catalogue partagé et les articles privés de son organisation", en: "Read the shared catalogue and one's organization private items" } }
) END;
IF !record::exists(auth_permission:⟨catalogue.item.manage⟩) THEN (
    CREATE auth_permission:⟨catalogue.item.manage⟩ CONTENT { code: "catalogue.item.manage", module: "lyxal_catalogue", scope: "organization", description: { fr: "Créer, modifier et supprimer les articles privés de son organisation et ses personnalisations", en: "Create, update and delete one's organization private items and customisations" } }
) END;
IF !record::exists(auth_permission:⟨catalogue.master.write⟩) THEN (
    CREATE auth_permission:⟨catalogue.master.write⟩ CONTENT { code: "catalogue.master.write", module: "lyxal_catalogue", scope: "installation", description: { fr: "Lire et écrire les articles maîtres (compte de synchronisation) ; aucun accès aux articles privés", en: "Read and write master items (sync account); no access to private items" } }
) END;

IF !record::exists(auth_role:catalogue_sync) THEN (
    CREATE auth_role:catalogue_sync CONTENT { scope_key: "installation", key: "catalogue_sync", name: "Synchronisation du catalogue", scope: "installation", system: true }
) END;

IF array::len(SELECT VALUE id FROM auth_role_grants WHERE in = auth_role:organization_member AND out = auth_permission:⟨catalogue.item.read⟩) = 0 THEN (
    RELATE auth_role:organization_member->auth_role_grants->auth_permission:⟨catalogue.item.read⟩
) END;
IF array::len(SELECT VALUE id FROM auth_role_grants WHERE in = auth_role:organization_admin AND out = auth_permission:⟨catalogue.item.read⟩) = 0 THEN (
    RELATE auth_role:organization_admin->auth_role_grants->auth_permission:⟨catalogue.item.read⟩
) END;
IF array::len(SELECT VALUE id FROM auth_role_grants WHERE in = auth_role:organization_admin AND out = auth_permission:⟨catalogue.item.manage⟩) = 0 THEN (
    RELATE auth_role:organization_admin->auth_role_grants->auth_permission:⟨catalogue.item.manage⟩
) END;
IF array::len(SELECT VALUE id FROM auth_role_grants WHERE in = auth_role:catalogue_sync AND out = auth_permission:⟨catalogue.master.write⟩) = 0 THEN (
    RELATE auth_role:catalogue_sync->auth_role_grants->auth_permission:⟨catalogue.master.write⟩
) END;
