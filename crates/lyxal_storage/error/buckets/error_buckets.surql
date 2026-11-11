-- ============================================================================
-- MASTER DATA : définitions d'erreurs de lyxal_storage, thème buckets
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:STORAGE_BUCKET_NOT_FOUND) THEN (
    CREATE error_definition:STORAGE_BUCKET_NOT_FOUND CONTENT {
        code: "STORAGE_BUCKET_NOT_FOUND",
        module: "storage",
        domain: "buckets",
        category: "not_found",
        severity: "error",
        message: "Bucket not found",
        default_language: "fr",
        http_status: 404,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Bucket introuvable",
                description: "Le bucket demandé n'existe pas ou n'est pas visible de votre session.",
                resolution: "Vérifiez l'identifiant du bucket."
            },
            en: {
                label: "Bucket not found",
                description: "The requested bucket does not exist or is not visible to your session.",
                resolution: "Check the bucket identifier."
            }
        }
    }
) END;

IF !record::exists(error_definition:STORAGE_BUCKET_EXISTS) THEN (
    CREATE error_definition:STORAGE_BUCKET_EXISTS CONTENT {
        code: "STORAGE_BUCKET_EXISTS",
        module: "storage",
        domain: "buckets",
        category: "conflict",
        severity: "error",
        message: "Bucket exists",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Nom de bucket déjà pris",
                description: "Un bucket porte déjà ce nom dans cette portée.",
                resolution: "Choisissez un autre nom."
            },
            en: {
                label: "Bucket name taken",
                description: "A bucket already has this name in this scope.",
                resolution: "Choose another name."
            }
        }
    }
) END;

IF !record::exists(error_definition:STORAGE_BUCKET_NOT_EMPTY) THEN (
    CREATE error_definition:STORAGE_BUCKET_NOT_EMPTY CONTENT {
        code: "STORAGE_BUCKET_NOT_EMPTY",
        module: "storage",
        domain: "buckets",
        category: "conflict",
        severity: "error",
        message: "Bucket not empty",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Bucket non vide",
                description: "Le bucket contient encore des fichiers, ou des fichiers supprimés dont le contenu n'est pas encore retiré (détail : objects).",
                resolution: "Supprimez ses fichiers et attendez leur purge."
            },
            en: {
                label: "Bucket not empty",
                description: "The bucket still holds files, or deleted files whose content is not removed yet (detail: objects).",
                resolution: "Delete its files and wait for their purge."
            }
        }
    }
) END;

IF !record::exists(error_definition:STORAGE_BUCKET_READONLY) THEN (
    CREATE error_definition:STORAGE_BUCKET_READONLY CONTENT {
        code: "STORAGE_BUCKET_READONLY",
        module: "storage",
        domain: "buckets",
        category: "conflict",
        severity: "error",
        message: "Bucket read-only",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Bucket en lecture seule",
                description: "Le bucket n'accepte ni écriture ni suppression de fichier.",
                resolution: "Retirez la lecture seule du bucket ou utilisez-en un autre."
            },
            en: {
                label: "Read-only bucket",
                description: "The bucket accepts no file write or deletion.",
                resolution: "Remove the read-only flag or use another bucket."
            }
        }
    }
) END;
