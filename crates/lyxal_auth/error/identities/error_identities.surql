-- ============================================================================
-- MASTER DATA : définitions d'erreurs de lyxal_auth, thème identities
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:AUTH_IDENTITY_NOT_FOUND) THEN (
    CREATE error_definition:AUTH_IDENTITY_NOT_FOUND CONTENT {
        code: "AUTH_IDENTITY_NOT_FOUND",
        module: "auth",
        domain: "identities",
        category: "not_found",
        severity: "error",
        message: "Identity not found",
        default_language: "fr",
        http_status: 404,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Identité introuvable",
                description: "L'identité demandée n'existe pas ou n'est pas visible.",
                resolution: "Vérifiez l'identifiant."
            },
            en: {
                label: "Identity not found",
                description: "The requested identity does not exist or is not visible.",
                resolution: "Check the identifier."
            }
        }
    }
) END;

IF !record::exists(error_definition:AUTH_IDENTITY_INACTIVE) THEN (
    CREATE error_definition:AUTH_IDENTITY_INACTIVE CONTENT {
        code: "AUTH_IDENTITY_INACTIVE",
        module: "auth",
        domain: "identities",
        category: "business",
        severity: "error",
        message: "Inactive identity",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Identité inactive",
                description: "L'identité n'est pas active.",
                resolution: "Réactivez l'identité si nécessaire."
            },
            en: {
                label: "Inactive identity",
                description: "The identity is not active.",
                resolution: "Reactivate the identity if needed."
            }
        }
    }
) END;

IF !record::exists(error_definition:AUTH_IDENTIFIER_TAKEN) THEN (
    CREATE error_definition:AUTH_IDENTIFIER_TAKEN CONTENT {
        code: "AUTH_IDENTIFIER_TAKEN",
        module: "auth",
        domain: "identities",
        category: "conflict",
        severity: "error",
        message: "Identifier taken",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Identifiant déjà utilisé",
                description: "Cet identifiant de connexion appartient déjà à une autre identité.",
                resolution: "Utilisez l'identité existante."
            },
            en: {
                label: "Identifier taken",
                description: "This sign-in identifier already belongs to another identity.",
                resolution: "Use the existing identity."
            }
        }
    }
) END;

IF !record::exists(error_definition:AUTH_TRAITS_INVALID) THEN (
    CREATE error_definition:AUTH_TRAITS_INVALID CONTENT {
        code: "AUTH_TRAITS_INVALID",
        module: "auth",
        domain: "identities",
        category: "validation",
        severity: "error",
        message: "Invalid traits",
        default_language: "fr",
        http_status: 400,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Traits invalides",
                description: "Les traits ne respectent pas le schéma d'identité.",
                resolution: "Corrigez les champs signalés."
            },
            en: {
                label: "Invalid traits",
                description: "The traits do not match the identity schema.",
                resolution: "Fix the reported fields."
            }
        }
    }
) END;

IF !record::exists(error_definition:AUTH_SCHEMA_INVALID) THEN (
    CREATE error_definition:AUTH_SCHEMA_INVALID CONTENT {
        code: "AUTH_SCHEMA_INVALID",
        module: "auth",
        domain: "identities",
        category: "validation",
        severity: "error",
        message: "Invalid identity schema",
        default_language: "fr",
        http_status: 400,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Schéma d'identité invalide",
                description: "Le schéma de traits est introuvable ou mal formé.",
                resolution: "Fournissez un schéma du moteur lyxal_core dont les traits identifiants existent."
            },
            en: {
                label: "Invalid identity schema",
                description: "The traits schema is missing or malformed.",
                resolution: "Provide a lyxal_core engine schema whose identifier traits exist."
            }
        }
    }
) END;
