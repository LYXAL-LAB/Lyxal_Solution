-- ============================================================================
-- MASTER DATA : Définitions d'erreurs pour le module lyxal_event
-- STANDARD    : Méthode canonique CREATE conforme à AGENTS.md & LYXAL_ARCHITECTURE.md
-- ============================================================================

IF !record::exists(error_definition:EVENT_NOT_FOUND) THEN (
    CREATE error_definition:EVENT_NOT_FOUND CONTENT {
        code: "EVENT_NOT_FOUND",
        module: "event",
        domain: "outbox",
        category: "not_found",
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
    }
) END;

IF !record::exists(error_definition:EVENT_SUBSCRIPTION_NOT_FOUND) THEN (
    CREATE error_definition:EVENT_SUBSCRIPTION_NOT_FOUND CONTENT {
        code: "EVENT_SUBSCRIPTION_NOT_FOUND",
        module: "event",
        domain: "subscription",
        category: "not_found",
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
    }
) END;

IF !record::exists(error_definition:EVENT_DELIVERY_NOT_FOUND) THEN (
    CREATE error_definition:EVENT_DELIVERY_NOT_FOUND CONTENT {
        code: "EVENT_DELIVERY_NOT_FOUND",
        module: "event",
        domain: "delivery",
        category: "not_found",
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
    }
) END;

IF !record::exists(error_definition:EVENT_CLAIM_FAILED) THEN (
    CREATE error_definition:EVENT_CLAIM_FAILED CONTENT {
        code: "EVENT_CLAIM_FAILED",
        module: "event",
        domain: "worker",
        category: "internal",
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
    }
) END;

IF !record::exists(error_definition:EVENT_HANDLER_TIMEOUT) THEN (
    CREATE error_definition:EVENT_HANDLER_TIMEOUT CONTENT {
        code: "EVENT_HANDLER_TIMEOUT",
        module: "event",
        domain: "handler",
        category: "timeout",
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
    }
) END;

IF !record::exists(error_definition:EVENT_LEASE_ACQUIRE_FAILED) THEN (
    CREATE error_definition:EVENT_LEASE_ACQUIRE_FAILED CONTENT {
        code: "EVENT_LEASE_ACQUIRE_FAILED",
        module: "event",
        domain: "lease",
        category: "conflict",
        severity: "warning",
        message: "Failed to acquire outbox streaming leader lease",
        default_language: "fr",
        http_status: 409,
        retryable: true,
        enabled: true,
        translations: {
            fr: {
                label: "Acquisition de bail échouée",
                description: "Le bail de leadership de streaming outbox est actuellement détenu par un autre nœud actif.",
                resolution: "Attendez l'expiration du bail ou réessayez."
            },
            en: {
                label: "Lease acquisition failed",
                description: "The outbox streaming leader lease is held by another active node.",
                resolution: "Wait for lease expiration or retry."
            }
        }
    }
) END;

IF !record::exists(error_definition:EVENT_LEASE_LOST) THEN (
    CREATE error_definition:EVENT_LEASE_LOST CONTENT {
        code: "EVENT_LEASE_LOST",
        module: "event",
        domain: "lease",
        category: "conflict",
        severity: "error",
        message: "Distributed streaming lease was lost or expired",
        default_language: "fr",
        http_status: 410,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Bail distribué perdu",
                description: "Le bail de leadership a expiré ou a été repris par une génération supérieure.",
                resolution: "Cessez immédiatement les écritures et ré-acquérez le leadership."
            },
            en: {
                label: "Distributed lease lost",
                description: "The streaming leader lease expired or was superseded by a higher generation.",
                resolution: "Cease writes immediately and re-acquire leadership."
            }
        }
    }
) END;

IF !record::exists(error_definition:EVENT_STALE_LEADER_FENCED) THEN (
    CREATE error_definition:EVENT_STALE_LEADER_FENCED CONTENT {
        code: "EVENT_STALE_LEADER_FENCED",
        module: "event",
        domain: "fencing",
        category: "conflict",
        severity: "error",
        message: "Operation blocked by transactional fencing: node is not the active leader",
        default_language: "fr",
        http_status: 412,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Opération bloquée par le fencing",
                description: "Le nœud émetteur a été évincé par une génération de leadership supérieure.",
                resolution: "Annulez le traitement local et synchronisez l'état du dispatcher."
            },
            en: {
                label: "Stale leader fenced",
                description: "The node has been superseded by a higher leader generation.",
                resolution: "Cancel local dispatching and re-sync."
            }
        }
    }
) END;

IF !record::exists(error_definition:EVENT_CURSOR_INVARIANT_VIOLATION) THEN (
    CREATE error_definition:EVENT_CURSOR_INVARIANT_VIOLATION CONTENT {
        code: "EVENT_CURSOR_INVARIANT_VIOLATION",
        module: "event",
        domain: "progress",
        category: "validation",
        severity: "error",
        message: "Cursor advance rejected: contiguous terminal invariant violated",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Violation d'invariant de curseur",
                description: "Impossible d'avancer le curseur : une ou plusieurs livraisons intermédiaires ne sont pas en état terminal ou manquent.",
                resolution: "Résolvez toutes les livraisons en suspens avant de committer le curseur."
            },
            en: {
                label: "Cursor invariant violation",
                description: "Cannot advance cursor: intermediate deliveries are unresolved or missing.",
                resolution: "Resolve all pending deliveries before committing cursor."
            }
        }
    }
) END;

IF !record::exists(error_definition:EVENT_CURSOR_NON_MONOTONIC) THEN (
    CREATE error_definition:EVENT_CURSOR_NON_MONOTONIC CONTENT {
        code: "EVENT_CURSOR_NON_MONOTONIC",
        module: "event",
        domain: "progress",
        category: "validation",
        severity: "error",
        message: "Target cursor is lower than or equal to current persisted cursor",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Curseur non monotone",
                description: "Le curseur cible est inférieur ou égal au curseur persisté actuel.",
                resolution: "Vérifiez la progression des séquences d'acquittement."
            },
            en: {
                label: "Non-monotonic cursor",
                description: "Target cursor is lower than or equal to the current persisted cursor.",
                resolution: "Verify the sequence acknowledgement progression."
            }
        }
    }
) END;

IF !record::exists(error_definition:EVENT_CURSOR_EXCEEDS_ASSIGNED_SEQ) THEN (
    CREATE error_definition:EVENT_CURSOR_EXCEEDS_ASSIGNED_SEQ CONTENT {
        code: "EVENT_CURSOR_EXCEEDS_ASSIGNED_SEQ",
        module: "event",
        domain: "progress",
        category: "validation",
        severity: "error",
        message: "Target cursor exceeds last assigned sequence",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Curseur dépasse la séquence assignée",
                description: "Le curseur cible dépasse le dernier numéro de séquence alloué.",
                resolution: "Attendez l'allocation de la séquence avant de committer le curseur."
            },
            en: {
                label: "Cursor exceeds assigned sequence",
                description: "Target cursor exceeds the last assigned sequence number.",
                resolution: "Wait for sequence allocation before committing cursor."
            }
        }
    }
) END;

IF !record::exists(error_definition:EVENT_CURSOR_INVARIANT_VIOLATION_UNRESOLVED_SEQUENCES) THEN (
    CREATE error_definition:EVENT_CURSOR_INVARIANT_VIOLATION_UNRESOLVED_SEQUENCES CONTENT {
        code: "EVENT_CURSOR_INVARIANT_VIOLATION_UNRESOLVED_SEQUENCES",
        module: "event",
        domain: "progress",
        category: "validation",
        severity: "error",
        message: "Intermediate deliveries are unresolved before target cursor",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Séquences intermédiaires non résolues",
                description: "Impossible d'avancer le curseur : des livraisons intermédiaires ne sont pas en état terminal (delivered, dead_letter, dropped).",
                resolution: "Résolvez toutes les livraisons antérieures avant d'avancer le curseur."
            },
            en: {
                label: "Unresolved intermediate sequences",
                description: "Cannot advance cursor: intermediate deliveries are not in terminal state.",
                resolution: "Resolve all prior deliveries before advancing cursor."
            }
        }
    }
) END;

IF !record::exists(error_definition:EVENT_CURSOR_MISSING_SEQUENCE_HOLE) THEN (
    CREATE error_definition:EVENT_CURSOR_MISSING_SEQUENCE_HOLE CONTENT {
        code: "EVENT_CURSOR_MISSING_SEQUENCE_HOLE",
        module: "event",
        domain: "progress",
        category: "validation",
        severity: "error",
        message: "Missing sequence hole detected before target cursor",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Trou de séquence détecté",
                description: "Impossible d'avancer le curseur : une séquence intermédiaire est manquante dans l'historique contigu.",
                resolution: "Assurez la contiguïté sans trou avant d'acquitter le curseur."
            },
            en: {
                label: "Sequence hole detected",
                description: "Cannot advance cursor: an intermediate sequence number is missing.",
                resolution: "Ensure gapless contiguity before committing cursor."
            }
        }
    }
) END;

IF !record::exists(error_definition:EVENT_PROGRESS_NOT_FOUND) THEN (
    CREATE error_definition:EVENT_PROGRESS_NOT_FOUND CONTENT {
        code: "EVENT_PROGRESS_NOT_FOUND",
        module: "event",
        domain: "progress",
        category: "not_found",
        severity: "error",
        message: "Subscription progress record was not found",
        default_language: "fr",
        http_status: 404,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Progression d'abonnement introuvable",
                description: "Aucun enregistrement de progression n'a été trouvé pour cet abonnement.",
                resolution: "Initialisez la progression de l'abonnement."
            },
            en: {
                label: "Subscription progress not found",
                description: "No progress record found for this subscription.",
                resolution: "Initialize the subscription progress."
            }
        }
    }
) END;

IF !record::exists(error_definition:EVENT_INVALID_PARAMETERS) THEN (
    CREATE error_definition:EVENT_INVALID_PARAMETERS CONTENT {
        code: "EVENT_INVALID_PARAMETERS",
        module: "event",
        domain: "common",
        category: "validation",
        severity: "error",
        message: "Required parameters were missing or invalid",
        default_language: "fr",
        http_status: 400,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Paramètres invalides",
                description: "Des paramètres obligatoires sont manquants ou de format incorrect.",
                resolution: "Vérifiez les paramètres transmis à la fonction."
            },
            en: {
                label: "Invalid parameters",
                description: "Mandatory parameters are missing or invalid.",
                resolution: "Verify parameters passed to the function."
            }
        }
    }
) END;
