-- ============================================================================
-- MASTER DATA : définitions d'erreurs de lyxal_auth, thème credentials
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:AUTH_CREDENTIALS_INVALID) THEN (
    CREATE error_definition:AUTH_CREDENTIALS_INVALID CONTENT {
        code: "AUTH_CREDENTIALS_INVALID",
        module: "auth",
        domain: "credentials",
        category: "authentication",
        severity: "error",
        message: "Invalid credentials",
        default_language: "fr",
        http_status: 401,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Identifiants incorrects",
                description: "L'identifiant ou le mot de passe est incorrect.",
                resolution: "Vérifiez vos identifiants ou utilisez la récupération de compte."
            },
            en: {
                label: "Invalid credentials",
                description: "The identifier or password is incorrect.",
                resolution: "Check your credentials or use account recovery."
            }
        }
    }
) END;

IF !record::exists(error_definition:AUTH_PASSWORD_COMPROMISED) THEN (
    CREATE error_definition:AUTH_PASSWORD_COMPROMISED CONTENT {
        code: "AUTH_PASSWORD_COMPROMISED",
        module: "auth",
        domain: "credentials",
        category: "validation",
        severity: "error",
        message: "Password found in a list of leaked passwords",
        default_language: "fr",
        http_status: 400,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Mot de passe divulgué",
                description: "Ce mot de passe figure parmi les mots de passe les plus utilisés et divulgués lors de fuites de données.",
                resolution: "Choisissez un autre mot de passe, propre à ce compte."
            },
            en: {
                label: "Leaked password",
                description: "This password is among the most used passwords exposed in data breaches.",
                resolution: "Choose another password, unique to this account."
            }
        }
    }
) END;

IF !record::exists(error_definition:AUTH_PASSWORD_POLICY_VIOLATION) THEN (
    CREATE error_definition:AUTH_PASSWORD_POLICY_VIOLATION CONTENT {
        code: "AUTH_PASSWORD_POLICY_VIOLATION",
        module: "auth",
        domain: "credentials",
        category: "validation",
        severity: "error",
        message: "Password policy violation",
        default_language: "fr",
        http_status: 400,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Mot de passe trop faible",
                description: "Le mot de passe ne respecte pas la politique (longueur, types de caractères).",
                resolution: "Choisissez un mot de passe plus long ou plus varié."
            },
            en: {
                label: "Password too weak",
                description: "The password does not meet the policy (length, character classes).",
                resolution: "Choose a longer or more varied password."
            }
        }
    }
) END;

IF !record::exists(error_definition:AUTH_PASSWORD_REUSED) THEN (
    CREATE error_definition:AUTH_PASSWORD_REUSED CONTENT {
        code: "AUTH_PASSWORD_REUSED",
        module: "auth",
        domain: "credentials",
        category: "validation",
        severity: "error",
        message: "Password reused",
        default_language: "fr",
        http_status: 400,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Mot de passe déjà utilisé",
                description: "Ce mot de passe fait partie des derniers mots de passe utilisés.",
                resolution: "Choisissez un mot de passe que vous n'avez pas utilisé récemment."
            },
            en: {
                label: "Password already used",
                description: "This password is one of the most recently used ones.",
                resolution: "Choose a password you have not used recently."
            }
        }
    }
) END;

IF !record::exists(error_definition:AUTH_TOO_MANY_ATTEMPTS) THEN (
    CREATE error_definition:AUTH_TOO_MANY_ATTEMPTS CONTENT {
        code: "AUTH_TOO_MANY_ATTEMPTS",
        module: "auth",
        domain: "credentials",
        category: "rate_limit",
        severity: "error",
        message: "Too many attempts",
        default_language: "fr",
        http_status: 429,
        retryable: true,
        enabled: true,
        translations: {
            fr: {
                label: "Trop de tentatives",
                description: "Trop de tentatives ont échoué ; l'accès est suspendu temporairement.",
                resolution: "Réessayez plus tard."
            },
            en: {
                label: "Too many attempts",
                description: "Too many attempts failed; access is temporarily suspended.",
                resolution: "Try again later."
            }
        }
    }
) END;

IF !record::exists(error_definition:AUTH_IDENTITY_LOCKED) THEN (
    CREATE error_definition:AUTH_IDENTITY_LOCKED CONTENT {
        code: "AUTH_IDENTITY_LOCKED",
        module: "auth",
        domain: "credentials",
        category: "authorization",
        severity: "error",
        message: "Identity locked",
        default_language: "fr",
        http_status: 403,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Compte bloqué",
                description: "Ce compte est bloqué par un administrateur.",
                resolution: "Contactez votre administrateur."
            },
            en: {
                label: "Account locked",
                description: "This account is locked by an administrator.",
                resolution: "Contact your administrator."
            }
        }
    }
) END;

IF !record::exists(error_definition:AUTH_REQUIRED_ACTION_PENDING) THEN (
    CREATE error_definition:AUTH_REQUIRED_ACTION_PENDING CONTENT {
        code: "AUTH_REQUIRED_ACTION_PENDING",
        module: "auth",
        domain: "credentials",
        category: "business",
        severity: "error",
        message: "Required action pending",
        default_language: "fr",
        http_status: 403,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Action requise",
                description: "Une action est requise avant d'accéder à votre compte (vérifier l'adresse, changer le mot de passe, accepter les conditions).",
                resolution: "Terminez les actions demandées."
            },
            en: {
                label: "Action required",
                description: "An action is required before accessing your account (verify address, change password, accept terms).",
                resolution: "Complete the requested actions."
            }
        }
    }
) END;
