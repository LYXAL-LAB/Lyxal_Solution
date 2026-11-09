-- ============================================================================
-- SEEDS : permissions, rôles et compte de service du pipeline d'ingestion
-- MODULE : lyxal_pipeline_ingestion
-- ============================================================================
-- Rejouable et non destructif (même forme que les seeds de lyxal_auth) : chaque permission, rôle,
-- permission accordée, application et attribution n'est créée que si elle n'existe pas ; rien
-- n'est modifié ni supprimé. `scope_key` et les valeurs par défaut de l'application sont écrits
-- explicitement : l'import des seeds ne calcule ni les champs VALUE ni les DEFAULT.
-- Le rôle catalogue_sync est créé à l'identique par les seeds du catalogue : le premier module
-- installé le crée, l'autre le complète seulement par ses permissions.
-- Le compte de service n'a aucun secret : l'hôte, maître de la base, lui ouvre une session sans
-- secret (fn::auth_service_session_open).

-- ----------------------------------------------------------------------------
-- Permissions (portée installation)
-- ----------------------------------------------------------------------------

IF !record::exists(auth_permission:⟨ingestion.read⟩) THEN (
    CREATE auth_permission:⟨ingestion.read⟩ CONTENT { code: "ingestion.read", module: "lyxal_pipeline_ingestion", scope: "installation", description: { fr: "Consulter les lots, éléments, anomalies, manifestes, référentiels et indicateurs du pipeline d'ingestion", en: "Read ingestion batches, items, anomalies, manifests, rules and metrics" } }
) END;
IF !record::exists(auth_permission:⟨ingestion.batch.write⟩) THEN (
    CREATE auth_permission:⟨ingestion.batch.write⟩ CONTENT { code: "ingestion.batch.write", module: "lyxal_pipeline_ingestion", scope: "installation", description: { fr: "Créer et faire avancer les lots d'ingestion, enregistrer les lignes brutes", en: "Create and advance ingestion batches, record raw rows" } }
) END;
IF !record::exists(auth_permission:⟨ingestion.staged.qualify⟩) THEN (
    CREATE auth_permission:⟨ingestion.staged.qualify⟩ CONTENT { code: "ingestion.staged.qualify", module: "lyxal_pipeline_ingestion", scope: "installation", description: { fr: "Qualifier les articles en préparation et consigner les anomalies en quarantaine", en: "Qualify staged items and log quarantine anomalies" } }
) END;
IF !record::exists(auth_permission:⟨ingestion.rule.manage⟩) THEN (
    CREATE auth_permission:⟨ingestion.rule.manage⟩ CONTENT { code: "ingestion.rule.manage", module: "lyxal_pipeline_ingestion", scope: "installation", description: { fr: "Gérer les référentiels d'ingestion (familles, spécifications, alias, substitutions)", en: "Manage ingestion rules (families, specifications, aliases, substitutions)" } }
) END;
IF !record::exists(auth_permission:⟨ingestion.manifest.approve⟩) THEN (
    CREATE auth_permission:⟨ingestion.manifest.approve⟩ CONTENT { code: "ingestion.manifest.approve", module: "lyxal_pipeline_ingestion", scope: "installation", min_aal: 2, description: { fr: "Préparer et approuver les manifestes de publication, requalifier les articles et résoudre les anomalies (double facteur exigé)", en: "Prepare and approve publication manifests, requalify items and resolve anomalies (second factor required)" } }
) END;
IF !record::exists(auth_permission:⟨ingestion.manifest.execute⟩) THEN (
    CREATE auth_permission:⟨ingestion.manifest.execute⟩ CONTENT { code: "ingestion.manifest.execute", module: "lyxal_pipeline_ingestion", scope: "installation", description: { fr: "Enregistrer l'exécution d'un manifeste approuvé (publication vers le catalogue)", en: "Record the execution of an approved manifest (publication to the catalogue)" } }
) END;

-- ----------------------------------------------------------------------------
-- Rôles d'installation
-- ----------------------------------------------------------------------------

IF !record::exists(auth_role:ingestion_operator) THEN (
    CREATE auth_role:ingestion_operator CONTENT { scope_key: "installation", key: "ingestion_operator", name: "Opérateur d'ingestion", scope: "installation", system: true }
) END;
IF !record::exists(auth_role:ingestion_qualifier) THEN (
    CREATE auth_role:ingestion_qualifier CONTENT { scope_key: "installation", key: "ingestion_qualifier", name: "Qualificateur d'ingestion", scope: "installation", system: true }
) END;
IF !record::exists(auth_role:ingestion_steward) THEN (
    CREATE auth_role:ingestion_steward CONTENT { scope_key: "installation", key: "ingestion_steward", name: "Data Steward d'ingestion", scope: "installation", system: true }
) END;
IF !record::exists(auth_role:catalogue_sync) THEN (
    CREATE auth_role:catalogue_sync CONTENT { scope_key: "installation", key: "catalogue_sync", name: "Synchronisation du catalogue", scope: "installation", system: true }
) END;

-- ----------------------------------------------------------------------------
-- Permissions accordées (l'administrateur de la plateforme reçoit les six)
-- ----------------------------------------------------------------------------

IF array::len(SELECT VALUE id FROM auth_role_grants WHERE in = auth_role:ingestion_operator AND out = auth_permission:⟨ingestion.read⟩) = 0 THEN (
    RELATE auth_role:ingestion_operator->auth_role_grants->auth_permission:⟨ingestion.read⟩
) END;
IF array::len(SELECT VALUE id FROM auth_role_grants WHERE in = auth_role:ingestion_operator AND out = auth_permission:⟨ingestion.batch.write⟩) = 0 THEN (
    RELATE auth_role:ingestion_operator->auth_role_grants->auth_permission:⟨ingestion.batch.write⟩
) END;
IF array::len(SELECT VALUE id FROM auth_role_grants WHERE in = auth_role:ingestion_qualifier AND out = auth_permission:⟨ingestion.read⟩) = 0 THEN (
    RELATE auth_role:ingestion_qualifier->auth_role_grants->auth_permission:⟨ingestion.read⟩
) END;
IF array::len(SELECT VALUE id FROM auth_role_grants WHERE in = auth_role:ingestion_qualifier AND out = auth_permission:⟨ingestion.staged.qualify⟩) = 0 THEN (
    RELATE auth_role:ingestion_qualifier->auth_role_grants->auth_permission:⟨ingestion.staged.qualify⟩
) END;
IF array::len(SELECT VALUE id FROM auth_role_grants WHERE in = auth_role:ingestion_steward AND out = auth_permission:⟨ingestion.read⟩) = 0 THEN (
    RELATE auth_role:ingestion_steward->auth_role_grants->auth_permission:⟨ingestion.read⟩
) END;
IF array::len(SELECT VALUE id FROM auth_role_grants WHERE in = auth_role:ingestion_steward AND out = auth_permission:⟨ingestion.rule.manage⟩) = 0 THEN (
    RELATE auth_role:ingestion_steward->auth_role_grants->auth_permission:⟨ingestion.rule.manage⟩
) END;
IF array::len(SELECT VALUE id FROM auth_role_grants WHERE in = auth_role:ingestion_steward AND out = auth_permission:⟨ingestion.manifest.approve⟩) = 0 THEN (
    RELATE auth_role:ingestion_steward->auth_role_grants->auth_permission:⟨ingestion.manifest.approve⟩
) END;
IF array::len(SELECT VALUE id FROM auth_role_grants WHERE in = auth_role:catalogue_sync AND out = auth_permission:⟨ingestion.read⟩) = 0 THEN (
    RELATE auth_role:catalogue_sync->auth_role_grants->auth_permission:⟨ingestion.read⟩
) END;
IF array::len(SELECT VALUE id FROM auth_role_grants WHERE in = auth_role:catalogue_sync AND out = auth_permission:⟨ingestion.manifest.execute⟩) = 0 THEN (
    RELATE auth_role:catalogue_sync->auth_role_grants->auth_permission:⟨ingestion.manifest.execute⟩
) END;
IF array::len(SELECT VALUE id FROM auth_role_grants WHERE in = auth_role:platform_admin AND out = auth_permission:⟨ingestion.read⟩) = 0 THEN (
    RELATE auth_role:platform_admin->auth_role_grants->auth_permission:⟨ingestion.read⟩
) END;
IF array::len(SELECT VALUE id FROM auth_role_grants WHERE in = auth_role:platform_admin AND out = auth_permission:⟨ingestion.batch.write⟩) = 0 THEN (
    RELATE auth_role:platform_admin->auth_role_grants->auth_permission:⟨ingestion.batch.write⟩
) END;
IF array::len(SELECT VALUE id FROM auth_role_grants WHERE in = auth_role:platform_admin AND out = auth_permission:⟨ingestion.staged.qualify⟩) = 0 THEN (
    RELATE auth_role:platform_admin->auth_role_grants->auth_permission:⟨ingestion.staged.qualify⟩
) END;
IF array::len(SELECT VALUE id FROM auth_role_grants WHERE in = auth_role:platform_admin AND out = auth_permission:⟨ingestion.rule.manage⟩) = 0 THEN (
    RELATE auth_role:platform_admin->auth_role_grants->auth_permission:⟨ingestion.rule.manage⟩
) END;
IF array::len(SELECT VALUE id FROM auth_role_grants WHERE in = auth_role:platform_admin AND out = auth_permission:⟨ingestion.manifest.approve⟩) = 0 THEN (
    RELATE auth_role:platform_admin->auth_role_grants->auth_permission:⟨ingestion.manifest.approve⟩
) END;
IF array::len(SELECT VALUE id FROM auth_role_grants WHERE in = auth_role:platform_admin AND out = auth_permission:⟨ingestion.manifest.execute⟩) = 0 THEN (
    RELATE auth_role:platform_admin->auth_role_grants->auth_permission:⟨ingestion.manifest.execute⟩
) END;

-- ----------------------------------------------------------------------------
-- Compte de service de synchronisation du catalogue (application machine, sans secret)
-- ----------------------------------------------------------------------------

IF !record::exists(auth_application:catalogue_sync) THEN (
    CREATE auth_application:catalogue_sync CONTENT { client_id: "lyxal-catalogue-sync", name: "Synchronisation du catalogue", type: "machine", redirect_uris: [], state: "active", permissions_version: 1, created_at: time::now(), updated_at: time::now() }
) END;
IF array::len(SELECT VALUE id FROM auth_has_role WHERE in = auth_application:catalogue_sync AND out = auth_role:catalogue_sync) = 0 THEN (
    RELATE auth_application:catalogue_sync->auth_has_role->auth_role:catalogue_sync SET granted_at = time::now()
) END;
