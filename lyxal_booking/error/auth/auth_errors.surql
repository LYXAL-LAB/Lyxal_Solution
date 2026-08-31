-- ============================================================================
-- DEFINITIONS D'ERREURS MASTER DATA : DOMAINE AUTHENTIFICATION
-- MODULE : lyxal_booking
-- ============================================================================

UPSERT ONLY error_definition:booking_username_email_required CONTENT {
    code: "BOOKING_USERNAME_EMAIL_REQUIRED",
    module: "booking",
    domain: "auth",
    category: "validation",
    severity: "error",
    message: "Email address is required for username generation",
    default_language: "en",
    http_status: 400,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "L'adresse e-mail est obligatoire",
            description: "L'adresse e-mail n'a pas été fournie.",
            resolution: "Saisissez une adresse e-mail valide."
        },
        en: {
            label: "Email address is required",
            description: "No email address was provided.",
            resolution: "Enter a valid email address."
        }
    }
};

UPSERT ONLY error_definition:booking_auth_invalid_credentials CONTENT {
    code: "BOOKING_AUTH_INVALID_CREDENTIALS",
    module: "booking",
    domain: "auth",
    category: "authentication",
    severity: "error",
    message: "Invalid email or password provided",
    default_language: "en",
    http_status: 401,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Identifiants invalides",
            description: "L'adresse e-mail ou le mot de passe est incorrect.",
            resolution: "Vérifiez vos identifiants de connexion."
        },
        en: {
            label: "Invalid credentials",
            description: "The email address or password is incorrect.",
            resolution: "Verify your login credentials."
        }
    }
};

UPSERT ONLY error_definition:booking_account_not_found CONTENT {
    code: "BOOKING_ACCOUNT_NOT_FOUND",
    module: "booking",
    domain: "auth",
    category: "not_found",
    severity: "error",
    message: "The requested user account was not found",
    default_language: "en",
    http_status: 404,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Compte utilisateur introuvable",
            description: "Aucun compte ne correspond à cet identifiant.",
            resolution: "Vérifiez l'adresse e-mail ou l'identifiant."
        },
        en: {
            label: "Account not found",
            description: "No account matched the provided identifier.",
            resolution: "Verify the email address or account ID."
        }
    }
};

UPSERT ONLY error_definition:booking_session_not_found CONTENT {
    code: "BOOKING_SESSION_NOT_FOUND",
    module: "booking",
    domain: "auth",
    category: "not_found",
    severity: "error",
    message: "The session token is invalid or has expired",
    default_language: "en",
    http_status: 401,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Session invalide ou expirée",
            description: "Votre session de connexion est expirée.",
            resolution: "Veuillez vous reconnecter."
        },
        en: {
            label: "Invalid or expired session",
            description: "Your login session has expired.",
            resolution: "Please log in again."
        }
    }
};

UPSERT ONLY error_definition:booking_auth_has_future_bookings CONTENT {
    code: "BOOKING_AUTH_HAS_FUTURE_BOOKINGS",
    module: "booking",
    domain: "auth",
    category: "validation",
    severity: "error",
    message: "Cannot delete user with future upcoming bookings",
    default_language: "en",
    http_status: 400,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Réservations futures en cours",
            description: "L'utilisateur a des réservations à venir (comme hôte ou membre assigné).",
            resolution: "Annulez les réservations à venir avant de supprimer l'utilisateur."
        },
        en: {
            label: "User has future bookings",
            description: "User has upcoming bookings as host or assigned team member.",
            resolution: "Cancel upcoming bookings before deleting the user."
        }
    }
};
