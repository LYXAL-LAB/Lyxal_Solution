-- ============================================================================
-- DEFINITIONS D'ERREURS MASTER DATA : DOMAINE RESSOURCES
-- MODULE : lyxal_booking
-- ============================================================================

UPSERT ONLY error_definition:booking_resource_unavailable CONTENT {
    code: "BOOKING_RESOURCE_UNAVAILABLE",
    module: "booking",
    domain: "resource",
    category: "conflict",
    severity: "error",
    message: "The requested resource is unavailable for the selected slot",
    default_language: "en",
    http_status: 409,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Ressource indisponible",
            description: "La ressource demandée (salle, équipement) est déjà allouée sur ce créneau.",
            resolution: "Choisissez une autre ressource ou un autre créneau."
        },
        en: {
            label: "Resource unavailable",
            description: "The requested resource (room, equipment) is already allocated for this slot.",
            resolution: "Select another resource or time slot."
        }
    }
};

UPSERT ONLY error_definition:booking_resource_not_found CONTENT {
    code: "BOOKING_RESOURCE_NOT_FOUND",
    module: "booking",
    domain: "resource",
    category: "not_found",
    severity: "error",
    message: "The requested resource was not found",
    default_language: "en",
    http_status: 404,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Ressource introuvable",
            description: "La ressource spécifiée n'existe pas.",
            resolution: "Vérifiez l'identifiant de la ressource."
        },
        en: {
            label: "Resource not found",
            description: "The specified resource does not exist.",
            resolution: "Verify the resource ID."
        }
    }
};
