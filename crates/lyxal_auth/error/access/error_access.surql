-- ============================================================================
-- MASTER DATA : définitions d'erreurs de lyxal_auth, thème access
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:AUTH_INVALID_PARAMETERS) THEN (
    CREATE error_definition:AUTH_INVALID_PARAMETERS CONTENT {
        code: "AUTH_INVALID_PARAMETERS",
        module: "auth",
        domain: "access",
        category: "validation",
        severity: "error",
        message: "Invalid parameters",
        default_language: "fr",
        http_status: 400,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Paramètres invalides",
                description: "Les paramètres fournis ne respectent pas le format attendu.",
                resolution: "Corrigez les champs signalés."
            },
            en: {
                label: "Invalid parameters",
                description: "The supplied parameters do not match the expected format.",
                resolution: "Fix the reported fields."
            }
        }
    }
) END;

IF !record::exists(error_definition:AUTH_WRITE_FORBIDDEN) THEN (
    CREATE error_definition:AUTH_WRITE_FORBIDDEN CONTENT {
        code: "AUTH_WRITE_FORBIDDEN",
        module: "auth",
        domain: "access",
        category: "authorization",
        severity: "error",
        message: "Write forbidden",
        default_language: "fr",
        http_status: 403,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Écriture refusée",
                description: "Les permissions de la table ont refusé l'écriture.",
                resolution: "Vérifiez les droits de l'identité connectée."
            },
            en: {
                label: "Write forbidden",
                description: "Table permissions refused the write.",
                resolution: "Check the connected identity's rights."
            }
        }
    }
) END;

IF !record::exists(error_definition:AUTH_PERMISSION_DENIED) THEN (
    CREATE error_definition:AUTH_PERMISSION_DENIED CONTENT {
        code: "AUTH_PERMISSION_DENIED",
        module: "auth",
        domain: "access",
        category: "authorization",
        severity: "error",
        message: "Permission denied",
        default_language: "fr",
        http_status: 403,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Permission refusée",
                description: "L'identité connectée ne détient pas la permission requise.",
                resolution: "Demandez la permission à un administrateur."
            },
            en: {
                label: "Permission denied",
                description: "The connected identity lacks the required permission.",
                resolution: "Ask an administrator for the permission."
            }
        }
    }
) END;

IF !record::exists(error_definition:AUTH_PERMISSION_UNKNOWN) THEN (
    CREATE error_definition:AUTH_PERMISSION_UNKNOWN CONTENT {
        code: "AUTH_PERMISSION_UNKNOWN",
        module: "auth",
        domain: "access",
        category: "not_found",
        severity: "error",
        message: "Unknown permission",
        default_language: "fr",
        http_status: 404,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Permission inconnue",
                description: "Une permission demandée n'est déclarée par aucun module.",
                resolution: "Utilisez un code déclaré (fn::auth_permission_list)."
            },
            en: {
                label: "Unknown permission",
                description: "A requested permission is not declared by any module.",
                resolution: "Use a declared code (fn::auth_permission_list)."
            }
        }
    }
) END;

IF !record::exists(error_definition:AUTH_PERMISSION_CONFLICT) THEN (
    CREATE error_definition:AUTH_PERMISSION_CONFLICT CONTENT {
        code: "AUTH_PERMISSION_CONFLICT",
        module: "auth",
        domain: "access",
        category: "conflict",
        severity: "error",
        message: "Permission declared differently",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Permission déjà déclarée autrement",
                description: "Ce code est déjà déclaré par un autre module ou avec une autre portée.",
                resolution: "Choisissez un code propre au module."
            },
            en: {
                label: "Permission declared differently",
                description: "This code is already declared by another module or with another scope.",
                resolution: "Choose a module-specific code."
            }
        }
    }
) END;

IF !record::exists(error_definition:AUTH_ROLE_NOT_FOUND) THEN (
    CREATE error_definition:AUTH_ROLE_NOT_FOUND CONTENT {
        code: "AUTH_ROLE_NOT_FOUND",
        module: "auth",
        domain: "access",
        category: "not_found",
        severity: "error",
        message: "Role not found",
        default_language: "fr",
        http_status: 404,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Rôle introuvable",
                description: "Le rôle demandé n'existe pas ou n'est pas visible.",
                resolution: "Vérifiez l'identifiant du rôle."
            },
            en: {
                label: "Role not found",
                description: "The requested role does not exist or is not visible.",
                resolution: "Check the role identifier."
            }
        }
    }
) END;

IF !record::exists(error_definition:AUTH_ROLE_KEY_TAKEN) THEN (
    CREATE error_definition:AUTH_ROLE_KEY_TAKEN CONTENT {
        code: "AUTH_ROLE_KEY_TAKEN",
        module: "auth",
        domain: "access",
        category: "conflict",
        severity: "error",
        message: "Role key taken",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Clé de rôle déjà utilisée",
                description: "Un rôle utilise déjà cette clé dans cette portée.",
                resolution: "Choisissez une autre clé."
            },
            en: {
                label: "Role key taken",
                description: "A role already uses this key in this scope.",
                resolution: "Choose another key."
            }
        }
    }
) END;

IF !record::exists(error_definition:AUTH_ROLE_SCOPE_MISMATCH) THEN (
    CREATE error_definition:AUTH_ROLE_SCOPE_MISMATCH CONTENT {
        code: "AUTH_ROLE_SCOPE_MISMATCH",
        module: "auth",
        domain: "access",
        category: "business",
        severity: "error",
        message: "Scope mismatch",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Portée incompatible",
                description: "La portée du rôle, de la permission ou de l'organisation ne correspond pas.",
                resolution: "Attribuez un rôle d'installation à une identité et un rôle d'organisation à une adhésion de cette organisation."
            },
            en: {
                label: "Scope mismatch",
                description: "The scope of the role, permission or organization does not match.",
                resolution: "Assign installation roles to identities and organization roles to memberships of that organization."
            }
        }
    }
) END;

IF !record::exists(error_definition:AUTH_ROLE_CYCLE) THEN (
    CREATE error_definition:AUTH_ROLE_CYCLE CONTENT {
        code: "AUTH_ROLE_CYCLE",
        module: "auth",
        domain: "access",
        category: "business",
        severity: "error",
        message: "Role cycle",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Cycle de rôles",
                description: "Ce rôle inclurait, directement ou non, lui-même.",
                resolution: "Retirez l'inclusion qui crée la boucle."
            },
            en: {
                label: "Role cycle",
                description: "This role would include itself, directly or indirectly.",
                resolution: "Remove the inclusion creating the loop."
            }
        }
    }
) END;

IF !record::exists(error_definition:AUTH_ROLE_SYSTEM) THEN (
    CREATE error_definition:AUTH_ROLE_SYSTEM CONTENT {
        code: "AUTH_ROLE_SYSTEM",
        module: "auth",
        domain: "access",
        category: "authorization",
        severity: "error",
        message: "Protected system role",
        default_language: "fr",
        http_status: 403,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Rôle système protégé",
                description: "Un rôle du socle n'est modifiable que par la session système.",
                resolution: "Créez un rôle propre ou passez par le seed du module."
            },
            en: {
                label: "Protected system role",
                description: "A core role can only be changed by the system session.",
                resolution: "Create your own role or use the module seed."
            }
        }
    }
) END;

IF !record::exists(error_definition:AUTH_CRYPTO_ERROR) THEN (
    CREATE error_definition:AUTH_CRYPTO_ERROR CONTENT {
        code: "AUTH_CRYPTO_ERROR",
        module: "auth",
        domain: "access",
        category: "internal",
        severity: "error",
        message: "Cryptographic error",
        default_language: "fr",
        http_status: 500,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Erreur cryptographique",
                description: "La génération ou le scellement d'un secret a échoué.",
                resolution: "Vérifiez le trousseau de clés de l'hôte."
            },
            en: {
                label: "Cryptographic error",
                description: "Generating or sealing a secret failed.",
                resolution: "Check the host key ring."
            }
        }
    }
) END;

IF !record::exists(error_definition:AUTH_DNS_UNAVAILABLE) THEN (
    CREATE error_definition:AUTH_DNS_UNAVAILABLE CONTENT {
        code: "AUTH_DNS_UNAVAILABLE",
        module: "auth",
        domain: "access",
        category: "dependency",
        severity: "error",
        message: "DNS unavailable",
        default_language: "fr",
        http_status: 503,
        retryable: true,
        enabled: true,
        translations: {
            fr: {
                label: "DNS indisponible",
                description: "Les enregistrements DNS n'ont pas pu être lus.",
                resolution: "Réessayez plus tard."
            },
            en: {
                label: "DNS unavailable",
                description: "DNS records could not be read.",
                resolution: "Retry later."
            }
        }
    }
) END;
