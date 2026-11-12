-- ============================================================================
-- MASTER DATA : définitions d'erreurs de lyxal_storage, thème fichiers
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:STORAGE_OBJECT_NOT_FOUND) THEN (
    CREATE error_definition:STORAGE_OBJECT_NOT_FOUND CONTENT {
        code: "STORAGE_OBJECT_NOT_FOUND",
        module: "storage",
        domain: "fichiers",
        category: "not_found",
        severity: "error",
        message: "File not found",
        default_language: "fr",
        http_status: 404,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Fichier introuvable",
                description: "Le fichier demandé n'existe pas ou n'est pas visible de votre session.",
                resolution: "Vérifiez l'identifiant ou l'adresse du fichier."
            },
            en: {
                label: "File not found",
                description: "The requested file does not exist or is not visible to your session.",
                resolution: "Check the file identifier or address."
            }
        }
    }
) END;

IF !record::exists(error_definition:STORAGE_OBJECT_EXISTS) THEN (
    CREATE error_definition:STORAGE_OBJECT_EXISTS CONTENT {
        code: "STORAGE_OBJECT_EXISTS",
        module: "storage",
        domain: "fichiers",
        category: "conflict",
        severity: "error",
        message: "File exists",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Adresse déjà occupée",
                description: "Un fichier occupe déjà cette adresse (bucket et clé).",
                resolution: "Supprimez le fichier existant ou choisissez une autre clé."
            },
            en: {
                label: "Address already taken",
                description: "A file already uses this address (bucket and key).",
                resolution: "Delete the existing file or choose another key."
            }
        }
    }
) END;

IF !record::exists(error_definition:STORAGE_OBJECT_STATE_INVALID) THEN (
    CREATE error_definition:STORAGE_OBJECT_STATE_INVALID CONTENT {
        code: "STORAGE_OBJECT_STATE_INVALID",
        module: "storage",
        domain: "fichiers",
        category: "conflict",
        severity: "error",
        message: "Invalid file state",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "État du fichier incompatible",
                description: "L'état du fichier ne permet pas cette opération (détail : state, expected), ou le délai de son écriture est passé.",
                resolution: "Relisez la fiche du fichier avant de recommencer."
            },
            en: {
                label: "Incompatible file state",
                description: "The file state does not allow this operation (detail: state, expected), or its write delay has passed.",
                resolution: "Read the file record again before retrying."
            }
        }
    }
) END;

IF !record::exists(error_definition:STORAGE_OBJECT_IN_USE) THEN (
    CREATE error_definition:STORAGE_OBJECT_IN_USE CONTENT {
        code: "STORAGE_OBJECT_IN_USE",
        module: "storage",
        domain: "fichiers",
        category: "conflict",
        severity: "error",
        message: "File in use",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Fichier utilisé",
                description: "Le fichier est référencé par d'autres données (détail : references).",
                resolution: "Retirez d'abord ces références."
            },
            en: {
                label: "File in use",
                description: "The file is referenced by other data (detail: references).",
                resolution: "Remove those references first."
            }
        }
    }
) END;

IF !record::exists(error_definition:STORAGE_OBJECT_TOO_LARGE) THEN (
    CREATE error_definition:STORAGE_OBJECT_TOO_LARGE CONTENT {
        code: "STORAGE_OBJECT_TOO_LARGE",
        module: "storage",
        domain: "fichiers",
        category: "validation",
        severity: "error",
        message: "File too large",
        default_language: "fr",
        http_status: 413,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Fichier trop volumineux",
                description: "La taille du fichier dépasse la limite du bucket (détail : size, max_object_size).",
                resolution: "Réduisez le fichier ou augmentez la limite du bucket."
            },
            en: {
                label: "File too large",
                description: "The file size exceeds the bucket limit (detail: size, max_object_size).",
                resolution: "Reduce the file or raise the bucket limit."
            }
        }
    }
) END;

IF !record::exists(error_definition:STORAGE_OBJECT_TYPE_REFUSED) THEN (
    CREATE error_definition:STORAGE_OBJECT_TYPE_REFUSED CONTENT {
        code: "STORAGE_OBJECT_TYPE_REFUSED",
        module: "storage",
        domain: "fichiers",
        category: "validation",
        severity: "error",
        message: "File type refused",
        default_language: "fr",
        http_status: 415,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Type de fichier refusé",
                description: "Le type du fichier n'est pas accepté par ce bucket (détail : content_type, allowed_types).",
                resolution: "Utilisez un type accepté ou un autre bucket."
            },
            en: {
                label: "File type refused",
                description: "The file type is not accepted by this bucket (detail: content_type, allowed_types).",
                resolution: "Use an accepted type or another bucket."
            }
        }
    }
) END;

IF !record::exists(error_definition:STORAGE_QUOTA_EXCEEDED) THEN (
    CREATE error_definition:STORAGE_QUOTA_EXCEEDED CONTENT {
        code: "STORAGE_QUOTA_EXCEEDED",
        module: "storage",
        domain: "fichiers",
        category: "business",
        severity: "error",
        message: "Quota exceeded",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Quota dépassé",
                description: "Ce fichier ferait dépasser le volume autorisé de la portée (détail : quota_bytes, used_bytes).",
                resolution: "Supprimez des fichiers ou augmentez le quota."
            },
            en: {
                label: "Quota exceeded",
                description: "This file would exceed the allowed volume of the scope (detail: quota_bytes, used_bytes).",
                resolution: "Delete files or raise the quota."
            }
        }
    }
) END;

IF !record::exists(error_definition:STORAGE_RANGE_NOT_SATISFIABLE) THEN (
    CREATE error_definition:STORAGE_RANGE_NOT_SATISFIABLE CONTENT {
        code: "STORAGE_RANGE_NOT_SATISFIABLE",
        module: "storage",
        domain: "fichiers",
        category: "validation",
        severity: "error",
        message: "Byte range not satisfiable",
        default_language: "fr",
        http_status: 416,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Plage d'octets hors du fichier",
                description: "La partie du fichier demandée ne contient aucun octet : elle commence après la fin du fichier.",
                resolution: "Demandez une plage comprise dans la taille du fichier, ou le fichier entier."
            },
            en: {
                label: "Byte range outside the file",
                description: "The requested part of the file contains no byte: it starts after the end of the file.",
                resolution: "Request a range within the file size, or the whole file."
            }
        }
    }
) END;
