-- ============================================================================
-- MASTER DATA : Définitions d'erreurs pour le module lyxal_event
-- ============================================================================

UPSERT ONLY error_definition:EVENT_NOT_FOUND CONTENT {
    code: "EVENT_NOT_FOUND",
    module: "event",
    domain: "outbox",
    category: "technical",
    severity: "error",
    message: "Requested outbox event was not found",
    default_language: "fr",
    http_status: 404,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Événement introuvable",
            description: "L'identifiant de l'événement outbox spécifié n'existe pas.",
            resolution: "Vérifiez l'identifiant fourni."
        },
        en: {
            label: "Event not found",
            description: "The specified outbox event ID does not exist.",
            resolution: "Verify the provided ID."
        }
    }
};

UPSERT ONLY error_definition:EVENT_SUBSCRIPTION_NOT_FOUND CONTENT {
    code: "EVENT_SUBSCRIPTION_NOT_FOUND",
    module: "event",
    domain: "subscription",
    category: "technical",
    severity: "error",
    message: "Requested event subscription was not found",
    default_language: "fr",
    http_status: 404,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Abonnement introuvable",
            description: "L'abonnement d'événement spécifié n'existe pas.",
            resolution: "Vérifiez la configuration de l'abonnement."
        },
        en: {
            label: "Subscription not found",
            description: "The specified event subscription does not exist.",
            resolution: "Check subscription configuration."
        }
    }
};

UPSERT ONLY error_definition:EVENT_DELIVERY_NOT_FOUND CONTENT {
    code: "EVENT_DELIVERY_NOT_FOUND",
    module: "event",
    domain: "delivery",
    category: "technical",
    severity: "error",
    message: "Requested event delivery was not found",
    default_language: "fr",
    http_status: 404,
    retryable: false,
    enabled: true,
    translations: {
        fr: {
            label: "Livraison d'événement introuvable",
            description: "L'enregistrement de livraison spécifié n'existe pas.",
            resolution: "Vérifiez l'identifiant de la livraison."
        },
        en: {
            label: "Event delivery not found",
            description: "The specified event delivery was not found.",
            resolution: "Check the delivery ID."
        }
    }
};

UPSERT ONLY error_definition:EVENT_CLAIM_FAILED CONTENT {
    code: "EVENT_CLAIM_FAILED",
    module: "event",
    domain: "worker",
    category: "technical",
    severity: "warning",
    message: "Failed to claim event delivery batch",
    default_language: "fr",
    http_status: 500,
    retryable: true,
    enabled: true,
    translations: {
        fr: {
            label: "Échec de réclamation du lot",
            description: "Le worker n'a pas pu acquérir le bail sur le lot de livraisons.",
            resolution: "Réessayez au cycle de polling suivant."
        },
        en: {
            label: "Batch claim failed",
            description: "Worker failed to acquire lease on delivery batch.",
            resolution: "Retry on next polling cycle."
        }
    }
};

UPSERT ONLY error_definition:EVENT_HANDLER_TIMEOUT CONTENT {
    code: "EVENT_HANDLER_TIMEOUT",
    module: "event",
    domain: "handler",
    category: "technical",
    severity: "error",
    message: "Handler execution exceeded allowed dispatch timeout",
    default_language: "fr",
    http_status: 504,
    retryable: true,
    enabled: true,
    translations: {
        fr: {
            label: "Délai d'exécution dépassé",
            description: "Le handler de l'événement n'a pas répondu dans le délai imparti.",
            resolution: "Optimisez le handler ou augmentez le dispatch_timeout."
        },
        en: {
            label: "Handler timeout",
            description: "The event handler exceeded the dispatch timeout.",
            resolution: "Optimize the handler or increase dispatch_timeout."
        }
    }
};
