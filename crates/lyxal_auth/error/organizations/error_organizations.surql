-- ============================================================================
-- MASTER DATA : définitions d'erreurs de lyxal_auth, thème organizations
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:AUTH_ORGANIZATION_NOT_FOUND) THEN (
    CREATE error_definition:AUTH_ORGANIZATION_NOT_FOUND CONTENT {
        code: "AUTH_ORGANIZATION_NOT_FOUND",
        module: "auth",
        domain: "organizations",
        category: "not_found",
        severity: "error",
        message: "Organization not found",
        default_language: "fr",
        http_status: 404,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Organisation introuvable",
                description: "L'organisation demandée n'existe pas ou n'est pas visible.",
                resolution: "Vérifiez l'identifiant."
            },
            en: {
                label: "Organization not found",
                description: "The requested organization does not exist or is not visible.",
                resolution: "Check the identifier."
            }
        }
    }
) END;

IF !record::exists(error_definition:AUTH_ORGANIZATION_SLUG_TAKEN) THEN (
    CREATE error_definition:AUTH_ORGANIZATION_SLUG_TAKEN CONTENT {
        code: "AUTH_ORGANIZATION_SLUG_TAKEN",
        module: "auth",
        domain: "organizations",
        category: "conflict",
        severity: "error",
        message: "Organization slug taken",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Identifiant d'organisation déjà utilisé",
                description: "Une organisation utilise déjà ce slug.",
                resolution: "Choisissez un autre slug."
            },
            en: {
                label: "Organization slug taken",
                description: "An organization already uses this slug.",
                resolution: "Choose another slug."
            }
        }
    }
) END;

IF !record::exists(error_definition:AUTH_ORGANIZATION_INACTIVE) THEN (
    CREATE error_definition:AUTH_ORGANIZATION_INACTIVE CONTENT {
        code: "AUTH_ORGANIZATION_INACTIVE",
        module: "auth",
        domain: "organizations",
        category: "business",
        severity: "error",
        message: "Inactive organization",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Organisation inactive",
                description: "L'organisation est suspendue ou supprimée.",
                resolution: "Réactivez l'organisation si nécessaire."
            },
            en: {
                label: "Inactive organization",
                description: "The organization is suspended or deleted.",
                resolution: "Reactivate the organization if needed."
            }
        }
    }
) END;

IF !record::exists(error_definition:AUTH_DOMAIN_TAKEN) THEN (
    CREATE error_definition:AUTH_DOMAIN_TAKEN CONTENT {
        code: "AUTH_DOMAIN_TAKEN",
        module: "auth",
        domain: "organizations",
        category: "conflict",
        severity: "error",
        message: "Domain taken",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Domaine déjà déclaré",
                description: "Ce domaine est déjà déclaré par une organisation.",
                resolution: "Contactez l'administration de la plateforme."
            },
            en: {
                label: "Domain taken",
                description: "This domain is already declared by an organization.",
                resolution: "Contact the platform administration."
            }
        }
    }
) END;

IF !record::exists(error_definition:AUTH_DOMAIN_NOT_VERIFIED) THEN (
    CREATE error_definition:AUTH_DOMAIN_NOT_VERIFIED CONTENT {
        code: "AUTH_DOMAIN_NOT_VERIFIED",
        module: "auth",
        domain: "organizations",
        category: "business",
        severity: "error",
        message: "Domain not verified",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Domaine non vérifié",
                description: "L'enregistrement DNS TXT attendu n'a pas été trouvé.",
                resolution: "Publiez l'enregistrement TXT indiqué puis relancez la vérification."
            },
            en: {
                label: "Domain not verified",
                description: "The expected DNS TXT record was not found.",
                resolution: "Publish the indicated TXT record then retry."
            }
        }
    }
) END;

IF !record::exists(error_definition:AUTH_NOT_A_MEMBER) THEN (
    CREATE error_definition:AUTH_NOT_A_MEMBER CONTENT {
        code: "AUTH_NOT_A_MEMBER",
        module: "auth",
        domain: "organizations",
        category: "business",
        severity: "error",
        message: "Not a member",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Pas membre",
                description: "L'identité n'est pas membre active de l'organisation.",
                resolution: "Ajoutez d'abord l'identité à l'organisation."
            },
            en: {
                label: "Not a member",
                description: "The identity is not an active member of the organization.",
                resolution: "Add the identity to the organization first."
            }
        }
    }
) END;

IF !record::exists(error_definition:AUTH_ALREADY_A_MEMBER) THEN (
    CREATE error_definition:AUTH_ALREADY_A_MEMBER CONTENT {
        code: "AUTH_ALREADY_A_MEMBER",
        module: "auth",
        domain: "organizations",
        category: "conflict",
        severity: "error",
        message: "Already a member",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Déjà membre",
                description: "L'identité est déjà membre de l'organisation.",
                resolution: "Aucune action nécessaire."
            },
            en: {
                label: "Already a member",
                description: "The identity is already a member of the organization.",
                resolution: "No action needed."
            }
        }
    }
) END;

IF !record::exists(error_definition:AUTH_LAST_ADMIN) THEN (
    CREATE error_definition:AUTH_LAST_ADMIN CONTENT {
        code: "AUTH_LAST_ADMIN",
        module: "auth",
        domain: "organizations",
        category: "business",
        severity: "error",
        message: "Last administrator",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Dernier administrateur",
                description: "Ce membre est le dernier administrateur actif de l'organisation.",
                resolution: "Nommez un autre administrateur d'abord."
            },
            en: {
                label: "Last administrator",
                description: "This member is the organization's last active administrator.",
                resolution: "Appoint another administrator first."
            }
        }
    }
) END;

IF !record::exists(error_definition:AUTH_INVITATION_INVALID) THEN (
    CREATE error_definition:AUTH_INVITATION_INVALID CONTENT {
        code: "AUTH_INVITATION_INVALID",
        module: "auth",
        domain: "organizations",
        category: "business",
        severity: "error",
        message: "Invalid invitation",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Invitation invalide",
                description: "L'invitation est inconnue, déjà utilisée ou révoquée.",
                resolution: "Demandez une nouvelle invitation."
            },
            en: {
                label: "Invalid invitation",
                description: "The invitation is unknown, already used or revoked.",
                resolution: "Request a new invitation."
            }
        }
    }
) END;

IF !record::exists(error_definition:AUTH_INVITATION_EXPIRED) THEN (
    CREATE error_definition:AUTH_INVITATION_EXPIRED CONTENT {
        code: "AUTH_INVITATION_EXPIRED",
        module: "auth",
        domain: "organizations",
        category: "business",
        severity: "error",
        message: "Expired invitation",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Invitation expirée",
                description: "L'invitation a expiré.",
                resolution: "Demandez une nouvelle invitation."
            },
            en: {
                label: "Expired invitation",
                description: "The invitation has expired.",
                resolution: "Request a new invitation."
            }
        }
    }
) END;
