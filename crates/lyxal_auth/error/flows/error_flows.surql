-- ============================================================================
-- MASTER DATA : définitions d'erreurs de lyxal_auth, thème flows
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:AUTH_FLOW_NOT_FOUND) THEN (
    CREATE error_definition:AUTH_FLOW_NOT_FOUND CONTENT {
        code: "AUTH_FLOW_NOT_FOUND",
        module: "auth",
        domain: "flows",
        category: "not_found",
        severity: "error",
        message: "Flow not found",
        default_language: "fr",
        http_status: 404,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Démarche introuvable",
                description: "Cette démarche n'existe pas.",
                resolution: "Recommencez la démarche."
            },
            en: {
                label: "Flow not found",
                description: "This flow does not exist.",
                resolution: "Start the flow again."
            }
        }
    }
) END;

IF !record::exists(error_definition:AUTH_FLOW_EXPIRED) THEN (
    CREATE error_definition:AUTH_FLOW_EXPIRED CONTENT {
        code: "AUTH_FLOW_EXPIRED",
        module: "auth",
        domain: "flows",
        category: "business",
        severity: "error",
        message: "Flow expired",
        default_language: "fr",
        http_status: 410,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Démarche expirée",
                description: "Le délai de cette démarche est dépassé.",
                resolution: "Recommencez la démarche."
            },
            en: {
                label: "Flow expired",
                description: "This flow has expired.",
                resolution: "Start the flow again."
            }
        }
    }
) END;

IF !record::exists(error_definition:AUTH_FLOW_INVALID_STATE) THEN (
    CREATE error_definition:AUTH_FLOW_INVALID_STATE CONTENT {
        code: "AUTH_FLOW_INVALID_STATE",
        module: "auth",
        domain: "flows",
        category: "conflict",
        severity: "error",
        message: "Invalid flow state",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Étape invalide",
                description: "Cette étape ne correspond pas à l'état de la démarche (déjà terminée ou étape sautée).",
                resolution: "Recommencez la démarche."
            },
            en: {
                label: "Invalid step",
                description: "This step does not match the flow state (already completed or step skipped).",
                resolution: "Start the flow again."
            }
        }
    }
) END;

IF !record::exists(error_definition:AUTH_CODE_INVALID) THEN (
    CREATE error_definition:AUTH_CODE_INVALID CONTENT {
        code: "AUTH_CODE_INVALID",
        module: "auth",
        domain: "flows",
        category: "validation",
        severity: "error",
        message: "Invalid code",
        default_language: "fr",
        http_status: 400,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Code incorrect",
                description: "Le code ou le lien est incorrect ou a déjà servi.",
                resolution: "Vérifiez le code reçu ou demandez-en un nouveau."
            },
            en: {
                label: "Invalid code",
                description: "The code or link is incorrect or has already been used.",
                resolution: "Check the code you received or request a new one."
            }
        }
    }
) END;

IF !record::exists(error_definition:AUTH_CODE_EXPIRED) THEN (
    CREATE error_definition:AUTH_CODE_EXPIRED CONTENT {
        code: "AUTH_CODE_EXPIRED",
        module: "auth",
        domain: "flows",
        category: "business",
        severity: "error",
        message: "Code expired",
        default_language: "fr",
        http_status: 410,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Code expiré",
                description: "Le code ou le lien a expiré.",
                resolution: "Demandez un nouveau code."
            },
            en: {
                label: "Code expired",
                description: "The code or link has expired.",
                resolution: "Request a new code."
            }
        }
    }
) END;

IF !record::exists(error_definition:AUTH_REGISTRATION_CLOSED) THEN (
    CREATE error_definition:AUTH_REGISTRATION_CLOSED CONTENT {
        code: "AUTH_REGISTRATION_CLOSED",
        module: "auth",
        domain: "flows",
        category: "business",
        severity: "error",
        message: "Registration closed",
        default_language: "fr",
        http_status: 403,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Inscription fermée",
                description: "L'inscription libre n'est pas ouverte : il faut une invitation.",
                resolution: "Demandez une invitation à votre organisation."
            },
            en: {
                label: "Registration closed",
                description: "Open registration is not available: an invitation is required.",
                resolution: "Ask your organization for an invitation."
            }
        }
    }
) END;

IF !record::exists(error_definition:AUTH_SETUP_DONE) THEN (
    CREATE error_definition:AUTH_SETUP_DONE CONTENT {
        code: "AUTH_SETUP_DONE",
        module: "auth",
        domain: "flows",
        category: "conflict",
        severity: "error",
        message: "Setup already done",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Installation déjà faite",
                description: "Un administrateur de la plateforme existe déjà.",
                resolution: "Connectez-vous avec le compte administrateur existant."
            },
            en: {
                label: "Setup already done",
                description: "A platform administrator already exists.",
                resolution: "Sign in with the existing administrator account."
            }
        }
    }
) END;

IF !record::exists(error_definition:AUTH_SETUP_TOKEN_INVALID) THEN (
    CREATE error_definition:AUTH_SETUP_TOKEN_INVALID CONTENT {
        code: "AUTH_SETUP_TOKEN_INVALID",
        module: "auth",
        domain: "flows",
        category: "authentication",
        severity: "error",
        message: "Invalid setup link",
        default_language: "fr",
        http_status: 401,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Lien d'installation invalide",
                description: "Le lien d'installation est incorrect, expiré ou déjà utilisé.",
                resolution: "Relancez la commande d'installation de l'hôte."
            },
            en: {
                label: "Invalid setup link",
                description: "The setup link is incorrect, expired or already used.",
                resolution: "Run the host setup command again."
            }
        }
    }
) END;

IF !record::exists(error_definition:AUTH_ADDRESS_CHANGE_PENDING) THEN (
    CREATE error_definition:AUTH_ADDRESS_CHANGE_PENDING CONTENT {
        code: "AUTH_ADDRESS_CHANGE_PENDING",
        module: "auth",
        domain: "flows",
        category: "conflict",
        severity: "error",
        message: "Address change pending",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Changement d'adresse en cours",
                description: "Un changement d'adresse attend déjà sa vérification.",
                resolution: "Confirmez le changement en cours ou recommencez."
            },
            en: {
                label: "Address change pending",
                description: "An address change is already awaiting verification.",
                resolution: "Confirm the pending change or start again."
            }
        }
    }
) END;
