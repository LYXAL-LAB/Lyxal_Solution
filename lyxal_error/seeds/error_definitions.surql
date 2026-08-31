-- ============================================================================
-- SEEDS : Catalogue canonique des erreurs initiales Lyxal
-- MODULE : lyxal_error
-- ============================================================================

CREATE error_definition CONTENT {
    code: "BOOKING_USERNAME_EMAIL_REQUIRED",
    module: "booking",
    domain: "username",
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

CREATE error_definition CONTENT {
    code: "BOOKING_USERNAME_EMAIL_INVALID",
    module: "booking",
    domain: "username",
    category: "validation",
    severity: "error",
    message: "The provided email address is invalid",
    default_language: "en",
    http_status: 422,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "L'adresse e-mail est invalide",
            description: "L'adresse saisie ne respecte pas le format attendu.",
            resolution: "Vérifiez l'adresse e-mail saisie."
        },
        en: {
            label: "Invalid email address",
            description: "The provided email address is invalid.",
            resolution: "Check the provided email address."
        }
    }
};

CREATE error_definition CONTENT {
    code: "BOOKING_USERNAME_GENERATION_FAILED",
    module: "booking",
    domain: "username",
    category: "business",
    severity: "error",
    message: "Failed to generate a unique username",
    default_language: "en",
    http_status: 409,
    retryable: true,
    enabled: true,
    translations: {
        fr: {
            label: "Échec de génération du pseudo",
            description: "Impossible de déterminer un pseudo unique disponible.",
            resolution: "Choisissez un pseudo personnalisé."
        },
        en: {
            label: "Username generation failed",
            description: "Could not generate a unique available username.",
            resolution: "Choose a custom username."
        }
    }
};

CREATE error_definition CONTENT {
    code: "BOOKING_SLOT_ALREADY_TAKEN",
    module: "booking",
    domain: "booking",
    category: "conflict",
    severity: "warning",
    message: "The selected time slot is no longer available",
    default_language: "en",
    http_status: 409,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Créneau déjà réservé",
            description: "Le créneau horaire sélectionné vient d'être réservé par un autre utilisateur.",
            resolution: "Sélectionnez un autre créneau dans le calendrier."
        },
        en: {
            label: "Time slot unavailable",
            description: "The selected time slot has already been booked by another user.",
            resolution: "Select another time slot from the calendar."
        }
    }
};

CREATE error_definition CONTENT {
    code: "CORE_ERROR_DEFINITION_NOT_FOUND",
    module: "core",
    domain: "error",
    category: "internal",
    severity: "error",
    message: "The requested error definition was not found",
    default_language: "en",
    http_status: 500,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Une erreur inconnue est survenue",
            description: "Le code d'erreur n'a pas pu être résolu.",
            resolution: "Réessayez ou contactez le support technique."
        },
        en: {
            label: "An unknown error occurred",
            description: "The error code could not be resolved.",
            resolution: "Retry or contact support."
        }
    }
};
