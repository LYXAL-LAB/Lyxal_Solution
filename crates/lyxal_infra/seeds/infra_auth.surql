-- ============================================================================
-- SEEDS : permissions lyxal_auth du pilotage de l'hébergeur
-- MODULE : lyxal_infra
-- ============================================================================
-- Rejouable et non destructif : permissions et attributions créées seulement si elles n'existent
-- pas. Toutes portent sur l'installation (aucun droit d'organisation en V1, décision I11).
-- infra.read et infra.manage sont données au rôle platform_admin ; infra.records.declare et
-- infra.worker ne sont données à aucun rôle : elles sont réservées aux comptes de service (la
-- session système d'un hôte n'a aucun droit à prouver).

IF !record::exists(auth_permission:⟨infra.read⟩) THEN (
    CREATE auth_permission:⟨infra.read⟩ CONTENT { code: "infra.read", module: "lyxal_infra", scope: "installation", description: { fr: "Lire les comptes d'hébergeur (sans secret), les zones, les enregistrements voulus, la photo des zones et le journal", en: "Read provider accounts (without secrets), zones, desired records, zone snapshots and the change log" } }
) END;

IF !record::exists(auth_permission:⟨infra.manage⟩) THEN (
    CREATE auth_permission:⟨infra.manage⟩ CONTENT { code: "infra.manage", module: "lyxal_infra", scope: "installation", description: { fr: "Gérer les comptes d'hébergeur, les zones, les enregistrements manuels, les conflits, l'approbation des plans et les réglages", en: "Manage provider accounts, zones, manual records, conflicts, plan approvals and settings" } }
) END;

IF !record::exists(auth_permission:⟨infra.records.declare⟩) THEN (
    CREATE auth_permission:⟨infra.records.declare⟩ CONTENT { code: "infra.records.declare", module: "lyxal_infra", scope: "installation", description: { fr: "Déclarer, retirer et lire ses enregistrements DNS par le contrat public (comptes de service des modules)", en: "Declare, release and read one's DNS records through the public contract (module service accounts)" } }
) END;

IF !record::exists(auth_permission:⟨infra.worker⟩) THEN (
    CREATE auth_permission:⟨infra.worker⟩ CONTENT { code: "infra.worker", module: "lyxal_infra", scope: "installation", description: { fr: "Compte de service du pilotage de l'hébergeur : passes de réconciliation, essais des comptes, vérifications, purge", en: "Provider control service account: reconciliation passes, account tests, checks, purge" } }
) END;

IF array::len(SELECT VALUE id FROM auth_role_grants WHERE in = auth_role:platform_admin AND out = auth_permission:⟨infra.read⟩) = 0 THEN (
    RELATE auth_role:platform_admin->auth_role_grants->auth_permission:⟨infra.read⟩
) END;

IF array::len(SELECT VALUE id FROM auth_role_grants WHERE in = auth_role:platform_admin AND out = auth_permission:⟨infra.manage⟩) = 0 THEN (
    RELATE auth_role:platform_admin->auth_role_grants->auth_permission:⟨infra.manage⟩
) END;
