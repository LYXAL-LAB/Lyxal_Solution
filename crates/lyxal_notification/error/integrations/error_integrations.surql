-- ============================================================================
-- MASTER DATA : définitions d'erreurs de lyxal_notification, thème intégrations (fournisseurs,
-- secrets des intégrations, retours des fournisseurs)
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:NOTIFICATION_INTEGRATION_NOT_FOUND) THEN (
    CREATE error_definition:NOTIFICATION_INTEGRATION_NOT_FOUND CONTENT {
        code: "NOTIFICATION_INTEGRATION_NOT_FOUND",
        module: "notification",
        domain: "integrations",
        category: "not_found",
        severity: "error",
        message: "Integration not found",
        default_language: "fr",
        http_status: 404,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Intégration introuvable",
                description: "Aucune intégration de cette portée n'a cette clé ou cet identifiant, ou elle n'est pas lisible.",
                resolution: "Vérifiez la clé de l'intégration et sa portée (organisation ou installation)."
            },
            en: {
                label: "Integration not found",
                description: "No integration of this scope has this key or identifier, or it is not readable.",
                resolution: "Check the integration key and its scope (organization or installation)."
            }
        }
    }
) END;

IF !record::exists(error_definition:NOTIFICATION_INTEGRATION_KEY_TAKEN) THEN (
    CREATE error_definition:NOTIFICATION_INTEGRATION_KEY_TAKEN CONTENT {
        code: "NOTIFICATION_INTEGRATION_KEY_TAKEN",
        module: "notification",
        domain: "integrations",
        category: "conflict",
        severity: "error",
        message: "Integration key already used",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Clé d'intégration déjà utilisée",
                description: "Une intégration de cette portée a déjà cette clé.",
                resolution: "Choisissez une autre clé ou modifiez l'intégration existante."
            },
            en: {
                label: "Integration key already used",
                description: "An integration of this scope already has this key.",
                resolution: "Choose another key or update the existing integration."
            }
        }
    }
) END;

IF !record::exists(error_definition:NOTIFICATION_INTEGRATION_SECRET_INVALID) THEN (
    CREATE error_definition:NOTIFICATION_INTEGRATION_SECRET_INVALID CONTENT {
        code: "NOTIFICATION_INTEGRATION_SECRET_INVALID",
        module: "notification",
        domain: "integrations",
        category: "authorization",
        severity: "error",
        message: "Integration secret refused",
        default_language: "fr",
        http_status: 403,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Secret de l'intégration refusé",
                description: "Le chemin du secret n'est pas sous notification/, le secret n'existe pas dans la même portée du coffre-fort, ou vous n'avez pas le droit de le lire (secrets.value.read ; installation : secrets.installation.manage).",
                resolution: "Créez le secret dans lyxal_secrets sous notification/ de la même portée, et demandez le droit de le lire."
            },
            en: {
                label: "Integration secret refused",
                description: "The secret path is not under notification/, the secret does not exist in the same vault scope, or you may not read it (secrets.value.read; installation: secrets.installation.manage).",
                resolution: "Create the secret in lyxal_secrets under notification/ of the same scope, and ask for the right to read it."
            }
        }
    }
) END;

IF !record::exists(error_definition:NOTIFICATION_INTEGRATION_UNAVAILABLE) THEN (
    CREATE error_definition:NOTIFICATION_INTEGRATION_UNAVAILABLE CONTENT {
        code: "NOTIFICATION_INTEGRATION_UNAVAILABLE",
        module: "notification",
        domain: "integrations",
        category: "dependency",
        severity: "error",
        message: "No integration available",
        default_language: "fr",
        http_status: 503,
        retryable: true,
        enabled: true,
        translations: {
            fr: {
                label: "Aucune intégration disponible",
                description: "Aucune intégration active et éligible pour ce canal, ni dans l'organisation ni dans l'installation : les envois attendent en file.",
                resolution: "Créez l'intégration e-mail de l'installation (administrateur de la plateforme) ou celle de l'organisation."
            },
            en: {
                label: "No integration available",
                description: "No active and eligible integration for this channel, neither in the organization nor in the installation: deliveries wait in the queue.",
                resolution: "Create the installation email integration (platform administrator) or the organization one."
            }
        }
    }
) END;

IF !record::exists(error_definition:NOTIFICATION_PROVIDER_REJECTED) THEN (
    CREATE error_definition:NOTIFICATION_PROVIDER_REJECTED CONTENT {
        code: "NOTIFICATION_PROVIDER_REJECTED",
        module: "notification",
        domain: "integrations",
        category: "dependency",
        severity: "error",
        message: "Provider rejected the message",
        default_language: "fr",
        http_status: 502,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Refus définitif du fournisseur",
                description: "Le fournisseur a refusé définitivement le message ou les identifiants (400, 401, 403, 422, autre 4xx) ; aucune bascule vers une autre intégration.",
                resolution: "Vérifiez les identifiants dans le coffre-fort, l'expéditeur autorisé chez le fournisseur et le message."
            },
            en: {
                label: "Provider rejected the message",
                description: "The provider permanently refused the message or the credentials (400, 401, 403, 422, other 4xx); no failover to another integration.",
                resolution: "Check the credentials in the vault, the sender allowed by the provider and the message."
            }
        }
    }
) END;

IF !record::exists(error_definition:NOTIFICATION_PROVIDER_UNAVAILABLE) THEN (
    CREATE error_definition:NOTIFICATION_PROVIDER_UNAVAILABLE CONTENT {
        code: "NOTIFICATION_PROVIDER_UNAVAILABLE",
        module: "notification",
        domain: "integrations",
        category: "network",
        severity: "error",
        message: "Provider temporarily unavailable",
        default_language: "fr",
        http_status: 503,
        retryable: true,
        enabled: true,
        translations: {
            fr: {
                label: "Fournisseur indisponible",
                description: "Le fournisseur est injoignable, trop lent ou a répondu 429 ou 5xx ; la tentative suivante passe à l'intégration éligible suivante.",
                resolution: "Aucune action : l'envoi est retenté automatiquement."
            },
            en: {
                label: "Provider temporarily unavailable",
                description: "The provider is unreachable, too slow or answered 429 or 5xx; the next attempt uses the next eligible integration.",
                resolution: "No action: delivery is retried automatically."
            }
        }
    }
) END;

IF !record::exists(error_definition:NOTIFICATION_WEBHOOK_INVALID) THEN (
    CREATE error_definition:NOTIFICATION_WEBHOOK_INVALID CONTENT {
        code: "NOTIFICATION_WEBHOOK_INVALID",
        module: "notification",
        domain: "integrations",
        category: "validation",
        severity: "error",
        message: "Provider webhook refused",
        default_language: "fr",
        http_status: 401,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Retour du fournisseur refusé",
                description: "La signature, les identifiants, l'horodatage ou le corps du retour sont refusés.",
                resolution: "Vérifiez le secret des retours de l'intégration et l'adresse réglée chez le fournisseur."
            },
            en: {
                label: "Provider webhook refused",
                description: "The webhook signature, credentials, timestamp or body were refused.",
                resolution: "Check the integration webhook secret and the address set at the provider."
            }
        }
    }
) END;

IF !record::exists(error_definition:NOTIFICATION_CONFIGURATION_INVALID) THEN (
    CREATE error_definition:NOTIFICATION_CONFIGURATION_INVALID CONTENT {
        code: "NOTIFICATION_CONFIGURATION_INVALID",
        module: "notification",
        domain: "integrations",
        category: "dependency",
        severity: "error",
        message: "Notification configuration invalid",
        default_language: "fr",
        http_status: 503,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Configuration des notifications invalide",
                description: "Un réglage d'envoi est refusé (expéditeur, relais SMTP, identifiants lus du coffre-fort, adresse publique des liens).",
                resolution: "Corrigez l'intégration, ses identifiants dans le coffre-fort ou la configuration de l'hôte."
            },
            en: {
                label: "Notification configuration invalid",
                description: "A delivery setting is refused (sender, SMTP relay, credentials read from the vault, public link address).",
                resolution: "Fix the integration, its credentials in the vault or the host configuration."
            }
        }
    }
) END;
