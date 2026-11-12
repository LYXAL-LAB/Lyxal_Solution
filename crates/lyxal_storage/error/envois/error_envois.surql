-- ============================================================================
-- MASTER DATA : définitions d'erreurs de lyxal_storage, thème envois (envois reprenables)
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:STORAGE_UPLOAD_OFFSET_MISMATCH) THEN (
    CREATE error_definition:STORAGE_UPLOAD_OFFSET_MISMATCH CONTENT {
        code: "STORAGE_UPLOAD_OFFSET_MISMATCH",
        module: "storage",
        domain: "envois",
        category: "conflict",
        severity: "warning",
        message: "Upload offset mismatch",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Position d'envoi incorrecte",
                description: "La position annoncée n'est pas celle où l'envoi en est : des octets ont déjà été reçus, ou il en manque.",
                resolution: "Demandez la position courante de l'envoi, puis reprenez à cette position."
            },
            en: {
                label: "Upload offset mismatch",
                description: "The announced offset is not the current offset of the upload: some bytes were already received, or some are missing.",
                resolution: "Ask for the current offset of the upload, then resume from it."
            }
        }
    }
) END;

IF !record::exists(error_definition:STORAGE_UPLOAD_EXPIRED) THEN (
    CREATE error_definition:STORAGE_UPLOAD_EXPIRED CONTENT {
        code: "STORAGE_UPLOAD_EXPIRED",
        module: "storage",
        domain: "envois",
        category: "business",
        severity: "warning",
        message: "Upload expired",
        default_language: "fr",
        http_status: 410,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Envoi expiré",
                description: "Le délai de cet envoi est écoulé : les octets déjà reçus sont retirés.",
                resolution: "Recommencez l'envoi du fichier."
            },
            en: {
                label: "Upload expired",
                description: "The time allowed for this upload has elapsed: the bytes already received are removed.",
                resolution: "Start the upload of the file again."
            }
        }
    }
) END;

IF !record::exists(error_definition:STORAGE_UPLOAD_INVALID_REQUEST) THEN (
    CREATE error_definition:STORAGE_UPLOAD_INVALID_REQUEST CONTENT {
        code: "STORAGE_UPLOAD_INVALID_REQUEST",
        module: "storage",
        domain: "envois",
        category: "validation",
        severity: "warning",
        message: "Invalid upload request",
        default_language: "fr",
        http_status: 400,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Requête d'envoi invalide",
                description: "La requête ne respecte pas le protocole d'envoi reprenable (tus 1.0) : en-tête absent ou mal formé.",
                resolution: "Corrigez l'en-tête indiqué dans les détails de l'erreur."
            },
            en: {
                label: "Invalid upload request",
                description: "The request does not follow the resumable upload protocol (tus 1.0): a header is missing or malformed.",
                resolution: "Fix the header named in the error details."
            }
        }
    }
) END;

IF !record::exists(error_definition:STORAGE_UPLOAD_VERSION_UNSUPPORTED) THEN (
    CREATE error_definition:STORAGE_UPLOAD_VERSION_UNSUPPORTED CONTENT {
        code: "STORAGE_UPLOAD_VERSION_UNSUPPORTED",
        module: "storage",
        domain: "envois",
        category: "validation",
        severity: "warning",
        message: "Unsupported upload protocol version",
        default_language: "fr",
        http_status: 412,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Version du protocole d'envoi non prise en charge",
                description: "La version du protocole d'envoi reprenable demandée par le client n'est pas prise en charge par ce serveur.",
                resolution: "Utilisez la version 1.0.0 du protocole tus."
            },
            en: {
                label: "Unsupported upload protocol version",
                description: "The resumable upload protocol version requested by the client is not supported by this server.",
                resolution: "Use version 1.0.0 of the tus protocol."
            }
        }
    }
) END;

IF !record::exists(error_definition:STORAGE_UPLOAD_TOO_MANY_PARTS) THEN (
    CREATE error_definition:STORAGE_UPLOAD_TOO_MANY_PARTS CONTENT {
        code: "STORAGE_UPLOAD_TOO_MANY_PARTS",
        module: "storage",
        domain: "envois",
        category: "business",
        severity: "warning",
        message: "Too many upload parts",
        default_language: "fr",
        http_status: 400,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Envoi en trop de morceaux",
                description: "Cet envoi a été reçu en trop de morceaux (10 000 au plus).",
                resolution: "Recommencez l'envoi avec des morceaux plus grands."
            },
            en: {
                label: "Too many upload parts",
                description: "This upload was received in too many parts (10,000 at most).",
                resolution: "Start the upload again with larger chunks."
            }
        }
    }
) END;

IF !record::exists(error_definition:STORAGE_UPLOAD_BUSY) THEN (
    CREATE error_definition:STORAGE_UPLOAD_BUSY CONTENT {
        code: "STORAGE_UPLOAD_BUSY",
        module: "storage",
        domain: "envois",
        category: "conflict",
        severity: "warning",
        message: "Upload being assembled",
        default_language: "fr",
        http_status: 409,
        retryable: true,
        enabled: true,
        translations: {
            fr: {
                label: "Envoi en cours d'assemblage",
                description: "Toutes les parties de cet envoi sont reçues et le fichier est en cours d'assemblage.",
                resolution: "Patientez, puis consultez de nouveau l'envoi."
            },
            en: {
                label: "Upload being assembled",
                description: "All the parts of this upload are received and the file is being assembled.",
                resolution: "Wait, then check the upload again."
            }
        }
    }
) END;
