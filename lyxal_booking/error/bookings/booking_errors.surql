-- ============================================================================
-- DEFINITIONS D'ERREURS MASTER DATA : DOMAINE RESERVATIONS & CRENEAUX
-- MODULE : lyxal_booking
-- ============================================================================

UPSERT ONLY error_definition:booking_slot_already_taken CONTENT {
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

UPSERT ONLY error_definition:booking_not_found CONTENT {
    code: "BOOKING_NOT_FOUND",
    module: "booking",
    domain: "booking",
    category: "not_found",
    severity: "error",
    message: "The requested booking could not be found",
    default_language: "en",
    http_status: 404,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Réservation introuvable",
            description: "La réservation demandée n'existe pas ou a été annulée.",
            resolution: "Vérifiez l'identifiant de réservation."
        },
        en: {
            label: "Booking not found",
            description: "The requested booking does not exist or has been cancelled.",
            resolution: "Verify the booking ID."
        }
    }
};
