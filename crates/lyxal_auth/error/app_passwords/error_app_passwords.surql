-- ============================================================================
-- MASTER DATA : définitions d'erreurs de lyxal_auth, thème app_passwords (mots de passe
-- d'application). Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:AUTH_APP_PASSWORD_INVALID) THEN (
    CREATE error_definition:AUTH_APP_PASSWORD_INVALID CONTENT {
        code: "AUTH_APP_PASSWORD_INVALID",
        module: "auth",
        domain: "app_passwords",
        category: "authentication",
        severity: "error",
        message: "Application password invalid",
        default_language: "fr",
        http_status: 401,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Mot de passe d'application refusé",
                description: "L'identifiant ou le mot de passe d'application est faux, inconnu, révoqué ou expiré.",
                resolution: "Vérifiez l'identifiant et le mot de passe saisis dans le logiciel, ou créez un nouveau mot de passe d'application."
            },
            en: {
                label: "Application password refused",
                description: "The username or application password is wrong, unknown, revoked or expired.",
                resolution: "Check the username and password entered in the app, or create a new application password."
            }
        }
    }
) END;

IF !record::exists(error_definition:AUTH_APP_PASSWORD_NOT_FOUND) THEN (
    CREATE error_definition:AUTH_APP_PASSWORD_NOT_FOUND CONTENT {
        code: "AUTH_APP_PASSWORD_NOT_FOUND",
        module: "auth",
        domain: "app_passwords",
        category: "not_found",
        severity: "error",
        message: "Application password not found",
        default_language: "fr",
        http_status: 404,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Mot de passe d'application introuvable",
                description: "Ce mot de passe d'application n'existe pas ou n'est pas visible pour vous.",
                resolution: "Vérifiez l'identifiant du mot de passe d'application."
            },
            en: {
                label: "Application password not found",
                description: "This application password does not exist or is not visible to you.",
                resolution: "Check the application password identifier."
            }
        }
    }
) END;

IF !record::exists(error_definition:AUTH_APP_PASSWORD_DISABLED) THEN (
    CREATE error_definition:AUTH_APP_PASSWORD_DISABLED CONTENT {
        code: "AUTH_APP_PASSWORD_DISABLED",
        module: "auth",
        domain: "app_passwords",
        category: "authorization",
        severity: "error",
        message: "Application passwords disabled",
        default_language: "fr",
        http_status: 403,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Mots de passe d'application désactivés",
                description: "Les mots de passe d'application sont désactivés par la politique de l'installation ou de l'organisation.",
                resolution: "Demandez à votre administrateur de les activer."
            },
            en: {
                label: "Application passwords disabled",
                description: "Application passwords are disabled by the installation or organization policy.",
                resolution: "Ask your administrator to enable them."
            }
        }
    }
) END;

IF !record::exists(error_definition:AUTH_APP_PASSWORD_LIMIT_REACHED) THEN (
    CREATE error_definition:AUTH_APP_PASSWORD_LIMIT_REACHED CONTENT {
        code: "AUTH_APP_PASSWORD_LIMIT_REACHED",
        module: "auth",
        domain: "app_passwords",
        category: "conflict",
        severity: "error",
        message: "Application password limit reached",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Nombre maximal de mots de passe d'application atteint",
                description: "Vous avez déjà le nombre maximal de mots de passe d'application actifs dans cette organisation.",
                resolution: "Révoquez un mot de passe d'application que vous n'utilisez plus, puis recommencez."
            },
            en: {
                label: "Application password limit reached",
                description: "You already have the maximum number of active application passwords in this organization.",
                resolution: "Revoke an application password you no longer use, then try again."
            }
        }
    }
) END;

IF !record::exists(error_definition:AUTH_APP_PASSWORD_PERMISSION_NOT_ALLOWED) THEN (
    CREATE error_definition:AUTH_APP_PASSWORD_PERMISSION_NOT_ALLOWED CONTENT {
        code: "AUTH_APP_PASSWORD_PERMISSION_NOT_ALLOWED",
        module: "auth",
        domain: "app_passwords",
        category: "authorization",
        severity: "error",
        message: "Permission not allowed for an application password",
        default_language: "fr",
        http_status: 403,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Permission impossible pour un mot de passe d'application",
                description: "Une permission demandée n'est pas détenue dans l'organisation ou ne peut pas être donnée à un mot de passe d'application.",
                resolution: "Choisissez parmi les permissions proposées pour les mots de passe d'application."
            },
            en: {
                label: "Permission not allowed for an application password",
                description: "A requested permission is not held in the organization or cannot be given to an application password.",
                resolution: "Choose among the permissions offered for application passwords."
            }
        }
    }
) END;

IF !record::exists(error_definition:AUTH_APP_PASSWORD_NO_PERMISSION) THEN (
    CREATE error_definition:AUTH_APP_PASSWORD_NO_PERMISSION CONTENT {
        code: "AUTH_APP_PASSWORD_NO_PERMISSION",
        module: "auth",
        domain: "app_passwords",
        category: "authorization",
        severity: "error",
        message: "Application password has no usable permission",
        default_language: "fr",
        http_status: 403,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Mot de passe d'application sans droit",
                description: "Ce mot de passe d'application ne donne plus aucune permission que vous détenez encore.",
                resolution: "Demandez à votre administrateur de vous rendre les droits, ou créez un autre mot de passe d'application."
            },
            en: {
                label: "Application password has no usable permission",
                description: "This application password no longer grants any permission you still hold.",
                resolution: "Ask your administrator to restore your rights, or create another application password."
            }
        }
    }
) END;

IF !record::exists(error_definition:AUTH_APP_PASSWORD_ORGANIZATION_REQUIRED) THEN (
    CREATE error_definition:AUTH_APP_PASSWORD_ORGANIZATION_REQUIRED CONTENT {
        code: "AUTH_APP_PASSWORD_ORGANIZATION_REQUIRED",
        module: "auth",
        domain: "app_passwords",
        category: "validation",
        severity: "error",
        message: "Active organization required",
        default_language: "fr",
        http_status: 400,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Organisation active requise",
                description: "Un mot de passe d'application porte des permissions d'une organisation : la session doit avoir une organisation active.",
                resolution: "Choisissez une organisation active, puis recommencez."
            },
            en: {
                label: "Active organization required",
                description: "An application password carries permissions of one organization: the session must have an active organization.",
                resolution: "Choose an active organization, then try again."
            }
        }
    }
) END;

IF !record::exists(error_definition:AUTH_APP_PASSWORD_EXPIRY_TOO_LONG) THEN (
    CREATE error_definition:AUTH_APP_PASSWORD_EXPIRY_TOO_LONG CONTENT {
        code: "AUTH_APP_PASSWORD_EXPIRY_TOO_LONG",
        module: "auth",
        domain: "app_passwords",
        category: "validation",
        severity: "error",
        message: "Application password expiry too long",
        default_language: "fr",
        http_status: 400,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Expiration trop lointaine",
                description: "L'expiration demandée dépasse la durée maximale fixée par la politique.",
                resolution: "Choisissez une expiration plus proche."
            },
            en: {
                label: "Expiry too far",
                description: "The requested expiry exceeds the maximum lifetime set by the policy.",
                resolution: "Choose an earlier expiry."
            }
        }
    }
) END;

IF !record::exists(error_definition:AUTH_APP_PASSWORD_INSECURE_TRANSPORT) THEN (
    CREATE error_definition:AUTH_APP_PASSWORD_INSECURE_TRANSPORT CONTENT {
        code: "AUTH_APP_PASSWORD_INSECURE_TRANSPORT",
        module: "auth",
        domain: "app_passwords",
        category: "authorization",
        severity: "error",
        message: "Unencrypted connection refused",
        default_language: "fr",
        http_status: 403,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Connexion non chiffrée refusée",
                description: "Un mot de passe d'application n'est accepté que sur une connexion chiffrée.",
                resolution: "Activez SSL/TLS dans les réglages du logiciel."
            },
            en: {
                label: "Unencrypted connection refused",
                description: "An application password is only accepted over an encrypted connection.",
                resolution: "Enable SSL/TLS in the app settings."
            }
        }
    }
) END;
