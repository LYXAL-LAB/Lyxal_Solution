-- ============================================================================
-- SEED   : permissions de l'hôte
-- HÔTE   : lyxal_server
-- RÔLE   : Droit d'administration de l'installation (routes système de l'hôte)
-- ============================================================================
-- lyxal_runtime est sous lyxal_auth dans la hiérarchie (.agents/AGENTS.md §6) : il ne déclare
-- aucune permission. L'hôte, qui expose ses opérations d'administration (reprise d'une migration
-- interrompue), déclare donc le droit qui les réserve et le contrôle avant d'appeler le runtime.
-- Installé en session système après les modules hébergés (la table auth_permission existe).
-- Rejouable : rien n'est recréé ni écrasé.

IF !record::exists(auth_permission:⟨server.installation.manage⟩) THEN (
    CREATE auth_permission:⟨server.installation.manage⟩ CONTENT { code: "server.installation.manage", module: "lyxal_server", scope: "installation", description: { fr: "Administrer l'installation : lister les migrations interrompues et décider de leur reprise ou de leur abandon", en: "Administer the installation: list interrupted migrations and decide to replay or abandon them" } }
) END;

IF array::len(SELECT VALUE id FROM auth_role_grants WHERE in = auth_role:platform_admin AND out = auth_permission:⟨server.installation.manage⟩) = 0 THEN (
    RELATE auth_role:platform_admin->auth_role_grants->auth_permission:⟨server.installation.manage⟩
) END;
