-- ============================================================================
-- SEEDS : socle de lyxal_auth
-- MODULE : lyxal_auth
-- ============================================================================
-- Rejouable et non destructif : chaque élément (permission, rôle, permission accordée) est créé
-- seulement s'il n'existe pas ; rien n'est modifié ni supprimé. Les seeds des autres modules
-- déclarent leurs permissions de la même façon. Aucun compte ni identifiant par défaut : le
-- premier administrateur est créé par une commande explicite de l'hôte (lien d'installation).
-- `scope_key` est écrit explicitement : l'import des seeds (OPTION IMPORT) ne calcule pas les
-- champs VALUE.

-- ----------------------------------------------------------------------------
-- Schéma de traits par défaut
-- ----------------------------------------------------------------------------

IF !record::exists(auth_identity_schema:default_v1) THEN (
    CREATE auth_identity_schema:default_v1 CONTENT {
        key: "default",
        version: 1,
        traits: {
            fields: {
                email: { pipeline: [{ rule: "email", options: { max_length: 254 } }], required: true },
                name: {
                    pipeline: [{ rule: "is_object" }, { rule: "object", options: { schema: {
                        fields: {
                            first: { pipeline: [{ rule: "display_name", options: { min_length: 1, max_length: 64, allow_emoji: false } }] },
                            last: { pipeline: [{ rule: "display_name", options: { min_length: 1, max_length: 64, allow_emoji: false } }] }
                        },
                        unknown_keys: "reject"
                    } } }]
                },
                locale: { pipeline: [{ rule: "locale", options: { require_region: false } }] },
                timezone: { pipeline: [{ rule: "timezone", options: { allow_utc: true } }] }
            },
            unknown_keys: "reject"
        },
        identifiers: [{ trait: "email", type: "email" }],
        verifiable: [
            { trait: "email", channel: "email", usage: "verification" },
            { trait: "email", channel: "email", usage: "recovery" }
        ],
        is_default: true
    }
) END;

-- ----------------------------------------------------------------------------
-- Politique de l'installation
-- ----------------------------------------------------------------------------

IF !record::exists(auth_policy:installation) THEN (
    CREATE auth_policy:installation CONTENT {
        scope_key: "installation",
        password: { min_length: 12, require_classes: 0, history: 5 },
        lockout: { max_failures: 10, lock_seconds: 900, window_seconds: 900, ip_max_failures: 50 },
        session: { access_seconds: 900, idle_seconds: 1800, absolute_seconds: 43200 },
        mfa: {
            required: false,
            methods: ["totp", "passkey", "recovery_code"],
            -- Double facteur exigé pour l'administration de la plateforme
            required_roles: ["platform_admin"],
            max_attempts: 5,
            recovery_code_count: 10,
            privileged_max_age_seconds: 900
        },
        invitation: { ttl_seconds: 604800 },
        registration: { mode: "invitation_only" },
        code: { ttl_seconds: 900, max_attempts: 5 },
        refresh: { ttl_seconds: 43200 },
        flow: { ttl_seconds: 900 },
        retention: { deleted_days: 30 }
    }
) END;

-- ----------------------------------------------------------------------------
-- Permissions de lyxal_auth (une seule portée par code)
-- ----------------------------------------------------------------------------

IF !record::exists(auth_permission:⟨auth.organization.manage⟩) THEN (
    CREATE auth_permission:⟨auth.organization.manage⟩ CONTENT { code: "auth.organization.manage", module: "lyxal_auth", scope: "installation", description: { fr: "Créer, suspendre et administrer toute organisation", en: "Create, suspend and administer any organization" } }
) END;
IF !record::exists(auth_permission:⟨auth.identity.manage⟩) THEN (
    CREATE auth_permission:⟨auth.identity.manage⟩ CONTENT { code: "auth.identity.manage", module: "lyxal_auth", scope: "installation", description: { fr: "Créer et administrer les identités de l'installation", en: "Create and administer installation identities" } }
) END;
IF !record::exists(auth_permission:⟨auth.identity.read⟩) THEN (
    CREATE auth_permission:⟨auth.identity.read⟩ CONTENT { code: "auth.identity.read", module: "lyxal_auth", scope: "installation", description: { fr: "Lire les identités de l'installation", en: "Read installation identities" } }
) END;
IF !record::exists(auth_permission:⟨auth.role.manage⟩) THEN (
    CREATE auth_permission:⟨auth.role.manage⟩ CONTENT { code: "auth.role.manage", module: "lyxal_auth", scope: "installation", description: { fr: "Gérer les rôles de l'installation et le registre des permissions", en: "Manage installation roles and the permission registry" } }
) END;
IF !record::exists(auth_permission:⟨auth.policy.manage⟩) THEN (
    CREATE auth_permission:⟨auth.policy.manage⟩ CONTENT { code: "auth.policy.manage", module: "lyxal_auth", scope: "installation", description: { fr: "Gérer la politique de sécurité de l'installation", en: "Manage the installation security policy" } }
) END;
IF !record::exists(auth_permission:⟨auth.organization.settings.manage⟩) THEN (
    CREATE auth_permission:⟨auth.organization.settings.manage⟩ CONTENT { code: "auth.organization.settings.manage", module: "lyxal_auth", scope: "organization", description: { fr: "Gérer la fiche et les domaines de son organisation", en: "Manage one's organization profile and domains" } }
) END;
IF !record::exists(auth_permission:⟨auth.member.manage⟩) THEN (
    CREATE auth_permission:⟨auth.member.manage⟩ CONTENT { code: "auth.member.manage", module: "lyxal_auth", scope: "organization", description: { fr: "Inviter, ajouter et retirer les membres", en: "Invite, add and remove members" } }
) END;
IF !record::exists(auth_permission:⟨auth.member.read⟩) THEN (
    CREATE auth_permission:⟨auth.member.read⟩ CONTENT { code: "auth.member.read", module: "lyxal_auth", scope: "organization", description: { fr: "Voir l'organisation et ses membres", en: "See the organization and its members" } }
) END;
IF !record::exists(auth_permission:⟨auth.organization.role.manage⟩) THEN (
    CREATE auth_permission:⟨auth.organization.role.manage⟩ CONTENT { code: "auth.organization.role.manage", module: "lyxal_auth", scope: "organization", description: { fr: "Gérer les rôles de son organisation et leur attribution", en: "Manage one's organization roles and assignments" } }
) END;
IF !record::exists(auth_permission:⟨auth.organization.policy.manage⟩) THEN (
    CREATE auth_permission:⟨auth.organization.policy.manage⟩ CONTENT { code: "auth.organization.policy.manage", module: "lyxal_auth", scope: "organization", description: { fr: "Gérer la politique de sécurité de son organisation", en: "Manage one's organization security policy" } }
) END;


-- Permissions des applications, des sessions et de soi-même
IF !record::exists(auth_permission:⟨auth.application.manage⟩) THEN (
    CREATE auth_permission:⟨auth.application.manage⟩ CONTENT { code: "auth.application.manage", module: "lyxal_auth", scope: "installation", description: { fr: "Gérer les applications et comptes de service de l'installation", en: "Manage installation applications and service accounts" } }
) END;
IF !record::exists(auth_permission:⟨auth.self.manage⟩) THEN (
    CREATE auth_permission:⟨auth.self.manage⟩ CONTENT { code: "auth.self.manage", module: "lyxal_auth", scope: "installation", description: { fr: "Gérer ses propres sessions, clés d'API et adresses (accordée à toute identité connectée)", en: "Manage one's own sessions, API keys and addresses" } }
) END;
IF !record::exists(auth_permission:⟨auth.organization.application.manage⟩) THEN (
    CREATE auth_permission:⟨auth.organization.application.manage⟩ CONTENT { code: "auth.organization.application.manage", module: "lyxal_auth", scope: "organization", description: { fr: "Gérer les applications et comptes de service de son organisation", en: "Manage one's organization applications and service accounts" } }
) END;
IF !record::exists(auth_permission:⟨auth.session.manage⟩) THEN (
    CREATE auth_permission:⟨auth.session.manage⟩ CONTENT { code: "auth.session.manage", module: "lyxal_auth", scope: "organization", description: { fr: "Voir et révoquer les sessions des membres de son organisation", en: "See and revoke one's organization members' sessions" } }
) END;

-- ----------------------------------------------------------------------------
-- Rôles du socle
-- ----------------------------------------------------------------------------

IF !record::exists(auth_role:platform_admin) THEN (
    CREATE auth_role:platform_admin CONTENT { scope_key: "installation", key: "platform_admin", name: "Administrateur de la plateforme", scope: "installation", system: true }
) END;
IF !record::exists(auth_role:organization_admin) THEN (
    CREATE auth_role:organization_admin CONTENT { scope_key: "installation", key: "organization_admin", name: "Administrateur de l'organisation", scope: "organization", system: true }
) END;
IF !record::exists(auth_role:organization_member) THEN (
    CREATE auth_role:organization_member CONTENT { scope_key: "installation", key: "organization_member", name: "Membre de l'organisation", scope: "organization", is_default: true, system: true }
) END;

IF array::len(SELECT VALUE id FROM auth_role_grants WHERE in = auth_role:platform_admin AND out = auth_permission:⟨auth.organization.manage⟩) = 0 THEN (
    RELATE auth_role:platform_admin->auth_role_grants->auth_permission:⟨auth.organization.manage⟩
) END;
IF array::len(SELECT VALUE id FROM auth_role_grants WHERE in = auth_role:platform_admin AND out = auth_permission:⟨auth.identity.manage⟩) = 0 THEN (
    RELATE auth_role:platform_admin->auth_role_grants->auth_permission:⟨auth.identity.manage⟩
) END;
IF array::len(SELECT VALUE id FROM auth_role_grants WHERE in = auth_role:platform_admin AND out = auth_permission:⟨auth.identity.read⟩) = 0 THEN (
    RELATE auth_role:platform_admin->auth_role_grants->auth_permission:⟨auth.identity.read⟩
) END;
IF array::len(SELECT VALUE id FROM auth_role_grants WHERE in = auth_role:platform_admin AND out = auth_permission:⟨auth.role.manage⟩) = 0 THEN (
    RELATE auth_role:platform_admin->auth_role_grants->auth_permission:⟨auth.role.manage⟩
) END;
IF array::len(SELECT VALUE id FROM auth_role_grants WHERE in = auth_role:platform_admin AND out = auth_permission:⟨auth.policy.manage⟩) = 0 THEN (
    RELATE auth_role:platform_admin->auth_role_grants->auth_permission:⟨auth.policy.manage⟩
) END;
IF array::len(SELECT VALUE id FROM auth_role_grants WHERE in = auth_role:organization_admin AND out = auth_permission:⟨auth.organization.settings.manage⟩) = 0 THEN (
    RELATE auth_role:organization_admin->auth_role_grants->auth_permission:⟨auth.organization.settings.manage⟩
) END;
IF array::len(SELECT VALUE id FROM auth_role_grants WHERE in = auth_role:organization_admin AND out = auth_permission:⟨auth.member.manage⟩) = 0 THEN (
    RELATE auth_role:organization_admin->auth_role_grants->auth_permission:⟨auth.member.manage⟩
) END;
IF array::len(SELECT VALUE id FROM auth_role_grants WHERE in = auth_role:organization_admin AND out = auth_permission:⟨auth.member.read⟩) = 0 THEN (
    RELATE auth_role:organization_admin->auth_role_grants->auth_permission:⟨auth.member.read⟩
) END;
IF array::len(SELECT VALUE id FROM auth_role_grants WHERE in = auth_role:organization_admin AND out = auth_permission:⟨auth.organization.role.manage⟩) = 0 THEN (
    RELATE auth_role:organization_admin->auth_role_grants->auth_permission:⟨auth.organization.role.manage⟩
) END;
IF array::len(SELECT VALUE id FROM auth_role_grants WHERE in = auth_role:organization_admin AND out = auth_permission:⟨auth.organization.policy.manage⟩) = 0 THEN (
    RELATE auth_role:organization_admin->auth_role_grants->auth_permission:⟨auth.organization.policy.manage⟩
) END;
IF array::len(SELECT VALUE id FROM auth_role_grants WHERE in = auth_role:organization_member AND out = auth_permission:⟨auth.member.read⟩) = 0 THEN (
    RELATE auth_role:organization_member->auth_role_grants->auth_permission:⟨auth.member.read⟩
) END;

-- Attributions des applications et des sessions
IF array::len(SELECT VALUE id FROM auth_role_grants WHERE in = auth_role:platform_admin AND out = auth_permission:⟨auth.application.manage⟩) = 0 THEN (
    RELATE auth_role:platform_admin->auth_role_grants->auth_permission:⟨auth.application.manage⟩
) END;
IF array::len(SELECT VALUE id FROM auth_role_grants WHERE in = auth_role:organization_admin AND out = auth_permission:⟨auth.organization.application.manage⟩) = 0 THEN (
    RELATE auth_role:organization_admin->auth_role_grants->auth_permission:⟨auth.organization.application.manage⟩
) END;
IF array::len(SELECT VALUE id FROM auth_role_grants WHERE in = auth_role:organization_admin AND out = auth_permission:⟨auth.session.manage⟩) = 0 THEN (
    RELATE auth_role:organization_admin->auth_role_grants->auth_permission:⟨auth.session.manage⟩
) END;
