-- ============================================================================
-- DEFINITIONS D'ERREURS MASTER DATA : DOMAINE CALENDRIERS & CALDAV
-- MODULE : lyxal_booking
-- ============================================================================

UPSERT ONLY error_definition:booking_calendar_credentials_invalid CONTENT {
    code: "BOOKING_CALENDAR_CREDENTIALS_INVALID",
    module: "booking",
    domain: "calendar",
    category: "authentication",
    severity: "error",
    message: "Calendar provider authentication failed",
    default_language: "en",
    http_status: 401,
    retryable: true,
    enabled: true,
    translations: {
        fr: {
            label: "Identifiants calendrier invalides",
            description: "Impossible de se connecter au fournisseur de calendrier externe (Google / CalDAV).",
            resolution: "Reconnectez votre compte de calendrier dans les paramètres."
        },
        en: {
            label: "Invalid calendar credentials",
            description: "Failed to authenticate with external calendar provider (Google / CalDAV).",
            resolution: "Reconnect your calendar account in settings."
        }
    }
};

UPSERT ONLY error_definition:booking_calendar_sync_failed CONTENT {
    code: "BOOKING_CALENDAR_SYNC_FAILED",
    module: "booking",
    domain: "calendar",
    category: "dependency",
    severity: "error",
    message: "Failed to synchronize events with calendar provider",
    default_language: "en",
    http_status: 502,
    retryable: true,
    enabled: true,
    translations: {
        fr: {
            label: "Échec de synchronisation du calendrier",
            description: "Une erreur est survenue lors de la synchronisation des événements.",
            resolution: "Vérifiez la connexion réseau ou réessayez ultérieurement."
        },
        en: {
            label: "Calendar sync failed",
            description: "An error occurred while synchronizing calendar events.",
            resolution: "Check network connection or try again later."
        }
    }
};
