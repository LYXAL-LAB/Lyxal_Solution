-- ============================================================================
-- MASTER DATA : définitions d'erreurs de lyxal_notification, thème destinataires (abonnés,
-- sujets, catégories, préférences, désabonnement, diffusions)
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:NOTIFICATION_SUBSCRIBER_NOT_FOUND) THEN (
    CREATE error_definition:NOTIFICATION_SUBSCRIBER_NOT_FOUND CONTENT {
        code: "NOTIFICATION_SUBSCRIBER_NOT_FOUND",
        module: "notification",
        domain: "destinataires",
        category: "not_found",
        severity: "error",
        message: "Subscriber not found",
        default_language: "fr",
        http_status: 404,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Abonné introuvable",
                description: "Aucun abonné de cette portée n'a cet identifiant.",
                resolution: "Vérifiez l'identifiant, ou fournissez son adresse pour le créer à la volée."
            },
            en: {
                label: "Subscriber not found",
                description: "No subscriber of this scope has this identifier.",
                resolution: "Check the identifier, or provide an address to create it on the fly."
            }
        }
    }
) END;

IF !record::exists(error_definition:NOTIFICATION_SUBSCRIBER_NO_ADDRESS) THEN (
    CREATE error_definition:NOTIFICATION_SUBSCRIBER_NO_ADDRESS CONTENT {
        code: "NOTIFICATION_SUBSCRIBER_NO_ADDRESS",
        module: "notification",
        domain: "destinataires",
        category: "validation",
        severity: "error",
        message: "Subscriber has no address for the workflow channels",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Abonné sans adresse",
                description: "L'abonné n'a aucune adresse pour les canaux du parcours (e-mail…).",
                resolution: "Ajoutez l'adresse du canal à l'abonné."
            },
            en: {
                label: "Subscriber without address",
                description: "The subscriber has no address for the workflow channels (email…).",
                resolution: "Add the channel address to the subscriber."
            }
        }
    }
) END;

IF !record::exists(error_definition:NOTIFICATION_TOPIC_NOT_FOUND) THEN (
    CREATE error_definition:NOTIFICATION_TOPIC_NOT_FOUND CONTENT {
        code: "NOTIFICATION_TOPIC_NOT_FOUND",
        module: "notification",
        domain: "destinataires",
        category: "not_found",
        severity: "error",
        message: "Topic not found",
        default_language: "fr",
        http_status: 404,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Sujet introuvable",
                description: "Aucun sujet de cette portée n'a cette clé.",
                resolution: "Vérifiez la clé du sujet."
            },
            en: {
                label: "Topic not found",
                description: "No topic of this scope has this key.",
                resolution: "Check the topic key."
            }
        }
    }
) END;

IF !record::exists(error_definition:NOTIFICATION_TOPIC_KEY_TAKEN) THEN (
    CREATE error_definition:NOTIFICATION_TOPIC_KEY_TAKEN CONTENT {
        code: "NOTIFICATION_TOPIC_KEY_TAKEN",
        module: "notification",
        domain: "destinataires",
        category: "conflict",
        severity: "error",
        message: "Topic key taken",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Clé de sujet déjà utilisée",
                description: "Un sujet de cette portée utilise déjà cette clé.",
                resolution: "Choisissez une autre clé."
            },
            en: {
                label: "Topic key already used",
                description: "A topic of this scope already uses this key.",
                resolution: "Choose another key."
            }
        }
    }
) END;

IF !record::exists(error_definition:NOTIFICATION_CATEGORY_NOT_FOUND) THEN (
    CREATE error_definition:NOTIFICATION_CATEGORY_NOT_FOUND CONTENT {
        code: "NOTIFICATION_CATEGORY_NOT_FOUND",
        module: "notification",
        domain: "destinataires",
        category: "not_found",
        severity: "error",
        message: "Category not found",
        default_language: "fr",
        http_status: 404,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Catégorie introuvable",
                description: "Aucune catégorie de cette portée ni de l'installation n'a cette clé.",
                resolution: "Vérifiez la clé de la catégorie."
            },
            en: {
                label: "Category not found",
                description: "No category of this scope or of the installation has this key.",
                resolution: "Check the category key."
            }
        }
    }
) END;

IF !record::exists(error_definition:NOTIFICATION_CATEGORY_KEY_TAKEN) THEN (
    CREATE error_definition:NOTIFICATION_CATEGORY_KEY_TAKEN CONTENT {
        code: "NOTIFICATION_CATEGORY_KEY_TAKEN",
        module: "notification",
        domain: "destinataires",
        category: "conflict",
        severity: "error",
        message: "Category key taken",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Clé de catégorie déjà utilisée",
                description: "Une catégorie de cette portée utilise déjà cette clé.",
                resolution: "Choisissez une autre clé."
            },
            en: {
                label: "Category key already used",
                description: "A category of this scope already uses this key.",
                resolution: "Choose another key."
            }
        }
    }
) END;

IF !record::exists(error_definition:NOTIFICATION_CATEGORY_IN_USE) THEN (
    CREATE error_definition:NOTIFICATION_CATEGORY_IN_USE CONTENT {
        code: "NOTIFICATION_CATEGORY_IN_USE",
        module: "notification",
        domain: "destinataires",
        category: "conflict",
        severity: "error",
        message: "Category in use",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Catégorie utilisée",
                description: "Des parcours utilisent cette catégorie : elle ne peut pas être supprimée.",
                resolution: "Retirez la catégorie des parcours concernés avant de la supprimer."
            },
            en: {
                label: "Category in use",
                description: "Workflows use this category: it cannot be deleted.",
                resolution: "Remove the category from these workflows before deleting it."
            }
        }
    }
) END;

IF !record::exists(error_definition:NOTIFICATION_PREFERENCE_ENFORCED) THEN (
    CREATE error_definition:NOTIFICATION_PREFERENCE_ENFORCED CONTENT {
        code: "NOTIFICATION_PREFERENCE_ENFORCED",
        module: "notification",
        domain: "destinataires",
        category: "conflict",
        severity: "error",
        message: "Preference enforced by the workflow",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Préférence imposée",
                description: "Ce canal est imposé par le parcours (ou le parcours est critique) : l'abonné ne peut pas le changer.",
                resolution: "Réglez ce canal au niveau du parcours ou de l'organisation."
            },
            en: {
                label: "Preference enforced",
                description: "This channel is enforced by the workflow (or the workflow is critical): the subscriber cannot change it.",
                resolution: "Set this channel at the workflow or organization level."
            }
        }
    }
) END;

IF !record::exists(error_definition:NOTIFICATION_CONDITION_INVALID) THEN (
    CREATE error_definition:NOTIFICATION_CONDITION_INVALID CONTENT {
        code: "NOTIFICATION_CONDITION_INVALID",
        module: "notification",
        domain: "destinataires",
        category: "validation",
        severity: "error",
        message: "Invalid condition",
        default_language: "fr",
        http_status: 400,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Condition invalide",
                description: "La condition n'a pas la forme attendue (all, any, not, règles { field, op, value }) ou dépasse ses limites.",
                resolution: "Corrigez le nœud signalé (details.path, details.reason)."
            },
            en: {
                label: "Invalid condition",
                description: "The condition does not have the expected shape (all, any, not, rules { field, op, value }) or exceeds its limits.",
                resolution: "Fix the reported node (details.path, details.reason)."
            }
        }
    }
) END;

IF !record::exists(error_definition:NOTIFICATION_IMPORT_TOO_LARGE) THEN (
    CREATE error_definition:NOTIFICATION_IMPORT_TOO_LARGE CONTENT {
        code: "NOTIFICATION_IMPORT_TOO_LARGE",
        module: "notification",
        domain: "destinataires",
        category: "validation",
        severity: "error",
        message: "Import too large",
        default_language: "fr",
        http_status: 413,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Import trop volumineux",
                description: "Un import compte 500 abonnés au plus.",
                resolution: "Découpez l'import en lots de 500 abonnés au plus."
            },
            en: {
                label: "Import too large",
                description: "An import holds at most 500 subscribers.",
                resolution: "Split the import into batches of at most 500 subscribers."
            }
        }
    }
) END;

IF !record::exists(error_definition:NOTIFICATION_UNSUBSCRIBE_INVALID) THEN (
    CREATE error_definition:NOTIFICATION_UNSUBSCRIBE_INVALID CONTENT {
        code: "NOTIFICATION_UNSUBSCRIBE_INVALID",
        module: "notification",
        domain: "destinataires",
        category: "validation",
        severity: "error",
        message: "Invalid unsubscribe link",
        default_language: "fr",
        http_status: 400,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Lien de désabonnement invalide",
                description: "Le lien de désabonnement est altéré, ou l'abonné, la catégorie ou le parcours n'existent plus.",
                resolution: "Utilisez le lien du dernier message reçu, ou réglez vos préférences depuis votre compte."
            },
            en: {
                label: "Invalid unsubscribe link",
                description: "The unsubscribe link is altered, or the subscriber, category or workflow no longer exists.",
                resolution: "Use the link of the latest message received, or set your preferences from your account."
            }
        }
    }
) END;

IF !record::exists(error_definition:NOTIFICATION_BROADCAST_INCOMPLETE) THEN (
    CREATE error_definition:NOTIFICATION_BROADCAST_INCOMPLETE CONTENT {
        code: "NOTIFICATION_BROADCAST_INCOMPLETE",
        module: "notification",
        domain: "destinataires",
        category: "conflict",
        severity: "error",
        message: "Broadcast not fully processed",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Diffusion inachevée",
                description: "Des destinataires de la diffusion restent à traiter.",
                resolution: "Traitez les paquets restants (fn::notification_broadcast_step) avant de terminer la diffusion."
            },
            en: {
                label: "Broadcast not finished",
                description: "Recipients of the broadcast remain to be processed.",
                resolution: "Process the remaining batches (fn::notification_broadcast_step) before completing the broadcast."
            }
        }
    }
) END;
