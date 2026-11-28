-- ============================================================================
-- MASTER DATA : définitions d'erreurs de lyxal_infra, thème fournisseurs
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:INFRA_PROVIDER_AUTH) THEN (
    CREATE error_definition:INFRA_PROVIDER_AUTH CONTENT {
        code: "INFRA_PROVIDER_AUTH",
        module: "infra",
        domain: "fournisseurs",
        category: "authentication",
        severity: "error",
        message: "Provider refused the API key",
        default_language: "fr",
        http_status: 502,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Clé refusée par l'hébergeur",
                description: "L'hébergeur a refusé la clé d'API (authentification ou droits) : le compte passe en échec.",
                resolution: "Vérifiez la clé et la politique IAM, puis demandez un nouvel essai du compte."
            },
            en: {
                label: "Key refused by the provider",
                description: "The provider refused the API key (authentication or permissions): the account is failing.",
                resolution: "Check the key and the IAM policy, then request a new account test."
            }
        }
    }
) END;

IF !record::exists(error_definition:INFRA_PROVIDER_REJECTED) THEN (
    CREATE error_definition:INFRA_PROVIDER_REJECTED CONTENT {
        code: "INFRA_PROVIDER_REJECTED",
        module: "infra",
        domain: "fournisseurs",
        category: "dependency",
        severity: "error",
        message: "Provider rejected the change",
        default_language: "fr",
        http_status: 502,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Changement refusé",
                description: "L'hébergeur a refusé le changement (arguments invalides, précondition non remplie).",
                resolution: "Consultez le journal des changements de la zone."
            },
            en: {
                label: "Change rejected",
                description: "The provider rejected the change (invalid arguments, failed precondition).",
                resolution: "Read the zone change log."
            }
        }
    }
) END;

IF !record::exists(error_definition:INFRA_PROVIDER_NOT_FOUND) THEN (
    CREATE error_definition:INFRA_PROVIDER_NOT_FOUND CONTENT {
        code: "INFRA_PROVIDER_NOT_FOUND",
        module: "infra",
        domain: "fournisseurs",
        category: "dependency",
        severity: "error",
        message: "Resource missing at the provider",
        default_language: "fr",
        http_status: 502,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Ressource absente chez l'hébergeur",
                description: "La zone (ou l'adresse) n'existe plus chez l'hébergeur.",
                resolution: "Vérifiez la zone dans la console de l'hébergeur."
            },
            en: {
                label: "Resource missing at the provider",
                description: "The zone (or address) no longer exists at the provider.",
                resolution: "Check the zone in the provider console."
            }
        }
    }
) END;

IF !record::exists(error_definition:INFRA_PROVIDER_QUOTA) THEN (
    CREATE error_definition:INFRA_PROVIDER_QUOTA CONTENT {
        code: "INFRA_PROVIDER_QUOTA",
        module: "infra",
        domain: "fournisseurs",
        category: "dependency",
        severity: "error",
        message: "Provider quota exceeded",
        default_language: "fr",
        http_status: 502,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Quota de l'hébergeur atteint",
                description: "L'hébergeur refuse le changement : quota dépassé.",
                resolution: "Augmentez le quota chez l'hébergeur ou réduisez les enregistrements."
            },
            en: {
                label: "Provider quota exceeded",
                description: "The provider refuses the change: quota exceeded.",
                resolution: "Raise the provider quota or reduce the records."
            }
        }
    }
) END;

IF !record::exists(error_definition:INFRA_PROVIDER_RATE_LIMITED) THEN (
    CREATE error_definition:INFRA_PROVIDER_RATE_LIMITED CONTENT {
        code: "INFRA_PROVIDER_RATE_LIMITED",
        module: "infra",
        domain: "fournisseurs",
        category: "rate_limit",
        severity: "error",
        message: "Provider rate limit reached",
        default_language: "fr",
        http_status: 503,
        retryable: true,
        enabled: true,
        translations: {
            fr: {
                label: "Débit de l'hébergeur dépassé",
                description: "L'hébergeur limite les appels (429).",
                resolution: "La passe sera reprise plus tard."
            },
            en: {
                label: "Provider rate limit reached",
                description: "The provider limits calls (429).",
                resolution: "The pass will be retried later."
            }
        }
    }
) END;

IF !record::exists(error_definition:INFRA_PROVIDER_UNAVAILABLE) THEN (
    CREATE error_definition:INFRA_PROVIDER_UNAVAILABLE CONTENT {
        code: "INFRA_PROVIDER_UNAVAILABLE",
        module: "infra",
        domain: "fournisseurs",
        category: "dependency",
        severity: "error",
        message: "Provider unavailable",
        default_language: "fr",
        http_status: 503,
        retryable: true,
        enabled: true,
        translations: {
            fr: {
                label: "Hébergeur indisponible",
                description: "L'hébergeur ne répond pas ou signale un état passager (5xx, réseau, délai).",
                resolution: "La passe sera reprise plus tard."
            },
            en: {
                label: "Provider unavailable",
                description: "The provider does not respond or reports a transient state (5xx, network, timeout).",
                resolution: "The pass will be retried later."
            }
        }
    }
) END;

IF !record::exists(error_definition:INFRA_PROVIDER_RESPONSE_INVALID) THEN (
    CREATE error_definition:INFRA_PROVIDER_RESPONSE_INVALID CONTENT {
        code: "INFRA_PROVIDER_RESPONSE_INVALID",
        module: "infra",
        domain: "fournisseurs",
        category: "dependency",
        severity: "error",
        message: "Unreadable provider response",
        default_language: "fr",
        http_status: 502,
        retryable: true,
        enabled: true,
        translations: {
            fr: {
                label: "Réponse illisible",
                description: "La réponse de l'hébergeur ne suit pas le format attendu.",
                resolution: "La passe sera reprise plus tard ; signalez l'erreur si elle persiste."
            },
            en: {
                label: "Unreadable response",
                description: "The provider response does not follow the expected format.",
                resolution: "The pass will be retried later; report the error if it persists."
            }
        }
    }
) END;

IF !record::exists(error_definition:INFRA_CREDENTIALS_UNAVAILABLE) THEN (
    CREATE error_definition:INFRA_CREDENTIALS_UNAVAILABLE CONTENT {
        code: "INFRA_CREDENTIALS_UNAVAILABLE",
        module: "infra",
        domain: "fournisseurs",
        category: "dependency",
        severity: "error",
        message: "Account credentials unavailable",
        default_language: "fr",
        http_status: 503,
        retryable: true,
        enabled: true,
        translations: {
            fr: {
                label: "Identifiants indisponibles",
                description: "La clé maîtresse du coffre-fort est absente ou le secret du compte est illisible.",
                resolution: "Vérifiez la clé maîtresse de lyxal_secrets et le secret du compte."
            },
            en: {
                label: "Credentials unavailable",
                description: "The vault master key is missing or the account secret is unreadable.",
                resolution: "Check the lyxal_secrets master key and the account secret."
            }
        }
    }
) END;

IF !record::exists(error_definition:INFRA_DNS_UNAVAILABLE) THEN (
    CREATE error_definition:INFRA_DNS_UNAVAILABLE CONTENT {
        code: "INFRA_DNS_UNAVAILABLE",
        module: "infra",
        domain: "fournisseurs",
        category: "network",
        severity: "error",
        message: "Authoritative DNS servers unreachable",
        default_language: "fr",
        http_status: 503,
        retryable: true,
        enabled: true,
        translations: {
            fr: {
                label: "Serveurs DNS injoignables",
                description: "Les serveurs faisant autorité de la zone ne répondent pas.",
                resolution: "La vérification sera reprise plus tard."
            },
            en: {
                label: "DNS servers unreachable",
                description: "The zone authoritative servers do not respond.",
                resolution: "The check will be retried later."
            }
        }
    }
) END;

IF !record::exists(error_definition:INFRA_DNS_NOT_PUBLISHED) THEN (
    CREATE error_definition:INFRA_DNS_NOT_PUBLISHED CONTENT {
        code: "INFRA_DNS_NOT_PUBLISHED",
        module: "infra",
        domain: "fournisseurs",
        category: "timeout",
        severity: "error",
        message: "Record not served in time",
        default_language: "fr",
        http_status: 504,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Enregistrement non publié",
                description: "Les serveurs faisant autorité ne servent pas l'enregistrement après le délai de vérification.",
                resolution: "Vérifiez la zone chez l'hébergeur et sa délégation."
            },
            en: {
                label: "Record not published",
                description: "The authoritative servers do not serve the record after the verification timeout.",
                resolution: "Check the zone at the provider and its delegation."
            }
        }
    }
) END;
