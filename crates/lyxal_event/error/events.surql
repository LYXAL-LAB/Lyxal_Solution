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

IF !record::exists(error_definition:EVENT_DEAD_LETTER_REPLAY_NOT_SETTLED) THEN (
    CREATE error_definition:EVENT_DEAD_LETTER_REPLAY_NOT_SETTLED CONTENT {
        code: "EVENT_DEAD_LETTER_REPLAY_NOT_SETTLED",
        module: "event",
        domain: "dead_letter",
        category: "conflict",
        severity: "warning",
        message: "Dead letter cannot be replayed before its sequence is covered by the persisted cursor",
        default_language: "fr",
        http_status: 409,
        retryable: true,
        enabled: true,
        translations: {
            fr: {
                label: "Rejeu prématuré",
                description: "La séquence de la livraison n'est pas encore couverte par le curseur persisté de son abonnement.",
                resolution: "Réessayez une fois les livraisons précédentes de l'abonnement résolues."
            },
            en: {
                label: "Replay not settled",
                description: "The delivery sequence is not yet covered by the persisted cursor of its subscription.",
                resolution: "Retry once the previous deliveries of the subscription are resolved."
            }
        }
    }
) END;

IF !record::exists(error_definition:EVENT_WRITE_FORBIDDEN) THEN (
    CREATE error_definition:EVENT_WRITE_FORBIDDEN CONTENT {
        code: "EVENT_WRITE_FORBIDDEN",
        module: "event",
        domain: "common",
        category: "authorization",
        severity: "error",
        message: "Table permissions refused a write of the event engine",
        default_language: "fr",
        http_status: 403,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Écriture refusée",
                description: "Les permissions d'une table du moteur d'événements (outbox, abonnements, baux) ont refusé l'écriture.",
                resolution: "Publiez depuis la session système ou par un DEFINE EVENT de la table concernée ; gérez abonnements et baux depuis la session système."
            },
            en: {
                label: "Write refused",
                description: "Permissions of an event engine table (outbox, subscriptions, leases) refused the write.",
                resolution: "Publish from the system session or from a DEFINE EVENT on the table concerned; manage subscriptions and leases from the system session."
            }
        }
    }
) END;

IF !record::exists(error_definition:EVENT_SUBSCRIPTION_HOST_CONFLICT) THEN (
    CREATE error_definition:EVENT_SUBSCRIPTION_HOST_CONFLICT CONTENT {
        code: "EVENT_SUBSCRIPTION_HOST_CONFLICT",
        module: "event",
        domain: "subscription",
        category: "conflict",
        severity: "error",
        message: "The subscription already belongs to another host",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Abonnement d'un autre hôte",
                description: "L'abonnement est déjà enregistré par un autre hôte : deux binaires portent le même handler.",
                resolution: "Retirez le handler de l'un des deux hôtes, ou changez l'hôte de l'abonnement par fn::event_subscription_transfer, ancien hôte arrêté."
            },
            en: {
                label: "Subscription owned by another host",
                description: "The subscription is already registered by another host: two binaries carry the same handler.",
                resolution: "Remove the handler from one of the hosts, or move the subscription with fn::event_subscription_transfer once the old host is stopped."
            }
        }
    }
) END;

IF !record::exists(error_definition:EVENT_SUBSCRIPTION_NOT_OWNED) THEN (
    CREATE error_definition:EVENT_SUBSCRIPTION_NOT_OWNED CONTENT {
        code: "EVENT_SUBSCRIPTION_NOT_OWNED",
        module: "event",
        domain: "subscription",
        category: "conflict",
        severity: "error",
        message: "The subscription or delivery belongs to another host",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Écriture hors de l'hôte propriétaire",
                description: "Le chef des événements d'un hôte a tenté d'écrire dans le flux d'un abonnement ou d'une livraison d'un autre hôte.",
                resolution: "Aucune action : chaque hôte ne traite que ses propres livraisons. Vérifiez l'hôte de l'abonnement."
            },
            en: {
                label: "Subscription not owned",
                description: "The event leader of a host tried to write to the stream of a subscription or delivery of another host.",
                resolution: "No action: each host only processes its own deliveries. Check the subscription host."
            }
        }
    }
) END;

IF !record::exists(error_definition:EVENT_HOST_ACTIVE) THEN (
    CREATE error_definition:EVENT_HOST_ACTIVE CONTENT {
        code: "EVENT_HOST_ACTIVE",
        module: "event",
        domain: "subscription",
        category: "conflict",
        severity: "warning",
        message: "The subscription host is still running",
        default_language: "fr",
        http_status: 409,
        retryable: true,
        enabled: true,
        translations: {
            fr: {
                label: "Hôte encore en marche",
                description: "Le bail du chef des événements de l'hôte actuel de l'abonnement est vivant : changer d'hôte ferait deux écrivains.",
                resolution: "Arrêtez l'hôte actuel et attendez l'expiration de son bail, puis réessayez."
            },
            en: {
                label: "Host still running",
                description: "The event leader lease of the current subscription host is alive: moving it would create two writers.",
                resolution: "Stop the current host, wait for its lease to expire, then retry."
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
                description: "Aucun abonnement ne porte ce nom.",
                resolution: "Vérifiez le nom de l'abonnement."
            },
            en: {
                label: "Subscription not found",
                description: "No subscription has this name.",
                resolution: "Check the subscription name."
            }
        }
    }
) END;
