-- ============================================================================
-- MASTER DATA : Définitions d'erreurs pour le module lyxal_event
-- STANDARD    : Méthode canonique CREATE conforme à AGENTS.md & LYXAL_ARCHITECTURE.md
-- ============================================================================

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
