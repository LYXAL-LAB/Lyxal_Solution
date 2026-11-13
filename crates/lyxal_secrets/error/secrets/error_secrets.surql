-- ============================================================================
-- MASTER DATA : définitions d'erreurs de lyxal_secrets, thème secrets
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:SECRETS_SECRET_NOT_FOUND) THEN (
    CREATE error_definition:SECRETS_SECRET_NOT_FOUND CONTENT {
        code: "SECRETS_SECRET_NOT_FOUND",
        module: "secrets",
        domain: "secrets",
        category: "not_found",
        severity: "error",
        message: "Secret not found",
        default_language: "fr",
        http_status: 404,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Secret introuvable",
                description: "Aucun secret ne correspond à cet identifiant ou à ce chemin, ou vous ne pouvez pas le voir.",
                resolution: "Vérifiez l'identifiant, le chemin et l'organisation."
            },
            en: {
                label: "Secret not found",
                description: "No secret matches this identifier or path, or you cannot see it.",
                resolution: "Check the identifier, the path and the organization."
            }
        }
    }
) END;

IF !record::exists(error_definition:SECRETS_SECRET_EXISTS) THEN (
    CREATE error_definition:SECRETS_SECRET_EXISTS CONTENT {
        code: "SECRETS_SECRET_EXISTS",
        module: "secrets",
        domain: "secrets",
        category: "conflict",
        severity: "error",
        message: "Secret already exists",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Secret déjà existant",
                description: "Un secret porte déjà ce chemin dans cette organisation (y compris un secret supprimé non encore purgé).",
                resolution: "Choisissez un autre chemin, ou restaurez ou purgez le secret existant."
            },
            en: {
                label: "Secret already exists",
                description: "A secret already uses this path in this organization (including a deleted secret not yet purged).",
                resolution: "Choose another path, or restore or purge the existing secret."
            }
        }
    }
) END;

IF !record::exists(error_definition:SECRETS_SECRET_STATE_INVALID) THEN (
    CREATE error_definition:SECRETS_SECRET_STATE_INVALID CONTENT {
        code: "SECRETS_SECRET_STATE_INVALID",
        module: "secrets",
        domain: "secrets",
        category: "conflict",
        severity: "error",
        message: "Invalid secret state",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "État du secret incompatible",
                description: "Le secret n'est pas dans un état qui permet cette opération (détail : state).",
                resolution: "Consultez l'état du secret avant de recommencer."
            },
            en: {
                label: "Invalid secret state",
                description: "The secret is not in a state that allows this operation (detail: state).",
                resolution: "Check the secret state before trying again."
            }
        }
    }
) END;

IF !record::exists(error_definition:SECRETS_SECRET_DISABLED) THEN (
    CREATE error_definition:SECRETS_SECRET_DISABLED CONTENT {
        code: "SECRETS_SECRET_DISABLED",
        module: "secrets",
        domain: "secrets",
        category: "conflict",
        severity: "error",
        message: "Secret disabled",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Secret désactivé",
                description: "Le secret est désactivé : sa valeur ne peut pas être lue.",
                resolution: "Réactivez le secret si sa désactivation n'est plus justifiée."
            },
            en: {
                label: "Secret disabled",
                description: "The secret is disabled: its value cannot be read.",
                resolution: "Enable the secret again if it no longer needs to be disabled."
            }
        }
    }
) END;

IF !record::exists(error_definition:SECRETS_SECRET_DELETED) THEN (
    CREATE error_definition:SECRETS_SECRET_DELETED CONTENT {
        code: "SECRETS_SECRET_DELETED",
        module: "secrets",
        domain: "secrets",
        category: "conflict",
        severity: "error",
        message: "Secret deleted",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Secret supprimé",
                description: "Le secret est supprimé : il ne peut être ni lu ni modifié avant sa restauration.",
                resolution: "Restaurez le secret avant sa date de purge si vous en avez encore besoin."
            },
            en: {
                label: "Secret deleted",
                description: "The secret is deleted: it can be neither read nor changed until it is restored.",
                resolution: "Restore the secret before its purge date if you still need it."
            }
        }
    }
) END;

IF !record::exists(error_definition:SECRETS_SECRET_EXPIRED) THEN (
    CREATE error_definition:SECRETS_SECRET_EXPIRED CONTENT {
        code: "SECRETS_SECRET_EXPIRED",
        module: "secrets",
        domain: "secrets",
        category: "conflict",
        severity: "error",
        message: "Secret expired",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Secret expiré",
                description: "L'échéance du secret est passée : sa valeur est refusée (détail : expires_at).",
                resolution: "Remplacez le secret par une nouvelle valeur et repoussez son échéance."
            },
            en: {
                label: "Secret expired",
                description: "The secret expiry date has passed: its value is refused (detail: expires_at).",
                resolution: "Replace the secret with a new value and move its expiry date."
            }
        }
    }
) END;

IF !record::exists(error_definition:SECRETS_PURGE_PROTECTED) THEN (
    CREATE error_definition:SECRETS_PURGE_PROTECTED CONTENT {
        code: "SECRETS_PURGE_PROTECTED",
        module: "secrets",
        domain: "secrets",
        category: "conflict",
        severity: "error",
        message: "Purge protection active",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Protection contre la purge",
                description: "La protection contre la purge est activée : un secret supprimé n'est purgé qu'à sa date de purge, et la protection ne se retire pas.",
                resolution: "Attendez la date de purge du secret."
            },
            en: {
                label: "Purge protection active",
                description: "Purge protection is on: a deleted secret is only purged at its purge date, and the protection cannot be removed.",
                resolution: "Wait for the secret purge date."
            }
        }
    }
) END;
