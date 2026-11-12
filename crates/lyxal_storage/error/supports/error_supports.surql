-- ============================================================================
-- MASTER DATA : définitions d'erreurs de lyxal_storage, thème supports
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:STORAGE_BACKEND_UNKNOWN) THEN (
    CREATE error_definition:STORAGE_BACKEND_UNKNOWN CONTENT {
        code: "STORAGE_BACKEND_UNKNOWN",
        module: "storage",
        domain: "supports",
        category: "dependency",
        severity: "error",
        message: "Storage backend not configured",
        default_language: "fr",
        http_status: 503,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Support de stockage non configuré",
                description: "Le support de stockage du bucket n'est pas configuré sur ce serveur : aucun fichier ne peut y être écrit ni lu.",
                resolution: "Configurez le dossier de stockage du serveur (LYXAL__STORAGE__DISK__ROOT), puis redémarrez-le."
            },
            en: {
                label: "Storage backend not configured",
                description: "The bucket storage backend is not configured on this server: no file can be written to or read from it.",
                resolution: "Configure the server storage folder (LYXAL__STORAGE__DISK__ROOT), then restart it."
            }
        }
    }
) END;

IF !record::exists(error_definition:STORAGE_BACKEND_UNAVAILABLE) THEN (
    CREATE error_definition:STORAGE_BACKEND_UNAVAILABLE CONTENT {
        code: "STORAGE_BACKEND_UNAVAILABLE",
        module: "storage",
        domain: "supports",
        category: "dependency",
        severity: "error",
        message: "Storage backend unavailable",
        default_language: "fr",
        http_status: 503,
        retryable: true,
        enabled: true,
        translations: {
            fr: {
                label: "Support de stockage indisponible",
                description: "Le support de stockage n'a pas répondu ou a refusé l'opération.",
                resolution: "Réessayez plus tard ; si l'erreur persiste, vérifiez le support (disque, droits d'accès, espace libre)."
            },
            en: {
                label: "Storage backend unavailable",
                description: "The storage backend did not answer or refused the operation.",
                resolution: "Try again later; if the error persists, check the backend (disk, access rights, free space)."
            }
        }
    }
) END;

IF !record::exists(error_definition:STORAGE_OBJECT_NOT_AVAILABLE) THEN (
    CREATE error_definition:STORAGE_OBJECT_NOT_AVAILABLE CONTENT {
        code: "STORAGE_OBJECT_NOT_AVAILABLE",
        module: "storage",
        domain: "supports",
        category: "conflict",
        severity: "error",
        message: "File not available",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Fichier non disponible",
                description: "Le fichier n'est pas à l'état disponible (écriture en cours, quarantaine ou suppression) : son contenu n'est pas servi.",
                resolution: "Attendez la fin de l'écriture, ou vérifiez l'état du fichier."
            },
            en: {
                label: "File not available",
                description: "The file is not in the available state (write in progress, quarantine or deletion): its content is not served.",
                resolution: "Wait for the write to end, or check the file state."
            }
        }
    }
) END;

IF !record::exists(error_definition:STORAGE_CONTENT_MISMATCH) THEN (
    CREATE error_definition:STORAGE_CONTENT_MISMATCH CONTENT {
        code: "STORAGE_CONTENT_MISMATCH",
        module: "storage",
        domain: "supports",
        category: "validation",
        severity: "error",
        message: "Content does not match the announcement",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Contenu différent de l'annonce",
                description: "Le contenu reçu n'a pas la taille annoncée, ou dépasse la taille maximale acceptée : l'écriture est abandonnée.",
                resolution: "Envoyez le fichier entier, avec sa taille exacte."
            },
            en: {
                label: "Content does not match the announcement",
                description: "The received content does not have the announced size, or exceeds the maximum accepted size: the write is abandoned.",
                resolution: "Send the whole file, with its exact size."
            }
        }
    }
) END;

IF !record::exists(error_definition:STORAGE_INTEGRITY_FAILED) THEN (
    CREATE error_definition:STORAGE_INTEGRITY_FAILED CONTENT {
        code: "STORAGE_INTEGRITY_FAILED",
        module: "storage",
        domain: "supports",
        category: "internal",
        severity: "error",
        message: "File integrity check failed",
        default_language: "fr",
        http_status: 500,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Fichier altéré",
                description: "Le contenu relu sur le support n'a plus la taille ou l'empreinte enregistrées dans la fiche du fichier.",
                resolution: "Restaurez le fichier depuis une sauvegarde, ou supprimez-le et envoyez-le de nouveau."
            },
            en: {
                label: "File altered",
                description: "The content read back from the backend no longer has the size or the fingerprint recorded for the file.",
                resolution: "Restore the file from a backup, or delete it and send it again."
            }
        }
    }
) END;
