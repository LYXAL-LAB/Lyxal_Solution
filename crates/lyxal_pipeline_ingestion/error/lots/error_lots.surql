-- ============================================================================
-- MASTER DATA : définitions d'erreurs du pipeline d'ingestion, lots
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:INGESTION_SOURCE_INVALID) THEN (
    CREATE error_definition:INGESTION_SOURCE_INVALID CONTENT {
        code: "INGESTION_SOURCE_INVALID",
        module: "ingestion",
        domain: "batch",
        category: "validation",
        severity: "error",
        message: "Le fichier ou le flux ne respecte pas le format déclaré",
        default_language: "fr",
        http_status: 400,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Format source invalide",
                description: "L'adaptateur n'a pas pu valider l'en-tête ou la structure du fichier.",
                resolution: "Vérifier le format déclaré (FAB-DIS, CSV, XML, JSON) et les en-têtes."
            },
            en: {
                label: "Invalid source format",
                description: "The adapter could not validate the file header or structure.",
                resolution: "Check the declared format (FAB-DIS, CSV, XML, JSON) and headers."
            }
        }
    }
) END;

IF !record::exists(error_definition:INGESTION_BATCH_DUPLICATE) THEN (
    CREATE error_definition:INGESTION_BATCH_DUPLICATE CONTENT {
        code: "INGESTION_BATCH_DUPLICATE",
        module: "ingestion",
        domain: "batch",
        category: "conflict",
        severity: "error",
        message: "Un lot avec la même empreinte BLAKE3 existe déjà",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Lot déjà importé",
                description: "Un fichier identique (même empreinte) a déjà été soumis.",
                resolution: "Reprendre le lot existant plutôt que de soumettre à nouveau le fichier."
            },
            en: {
                label: "Batch already imported",
                description: "An identical file (same fingerprint) was already submitted.",
                resolution: "Resume the existing batch instead of submitting the file again."
            }
        }
    }
) END;

IF !record::exists(error_definition:INGESTION_BATCH_NOT_FOUND) THEN (
    CREATE error_definition:INGESTION_BATCH_NOT_FOUND CONTENT {
        code: "INGESTION_BATCH_NOT_FOUND",
        module: "ingestion",
        domain: "batch",
        category: "not_found",
        severity: "error",
        message: "Lot d'ingestion introuvable",
        default_language: "fr",
        http_status: 404,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Lot introuvable",
                description: "Aucun lot ne correspond à l'identifiant fourni.",
                resolution: "Vérifier l'identifiant du lot."
            },
            en: {
                label: "Batch not found",
                description: "No batch matches the given identifier.",
                resolution: "Check the batch identifier."
            }
        }
    }
) END;

IF !record::exists(error_definition:INGESTION_BATCH_TERMINAL_STATE) THEN (
    CREATE error_definition:INGESTION_BATCH_TERMINAL_STATE CONTENT {
        code: "INGESTION_BATCH_TERMINAL_STATE",
        module: "ingestion",
        domain: "batch",
        category: "conflict",
        severity: "error",
        message: "Le lot est dans un état terminal et ne peut plus changer",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Lot terminé",
                description: "Un lot publié ne change plus d'état.",
                resolution: "Créer un nouveau lot pour un nouvel import."
            },
            en: {
                label: "Batch in terminal state",
                description: "A published batch can no longer change state.",
                resolution: "Create a new batch for a new import."
            }
        }
    }
) END;

IF !record::exists(error_definition:INGESTION_BATCH_ILLEGAL_STATE_TRANSITION) THEN (
    CREATE error_definition:INGESTION_BATCH_ILLEGAL_STATE_TRANSITION CONTENT {
        code: "INGESTION_BATCH_ILLEGAL_STATE_TRANSITION",
        module: "ingestion",
        domain: "batch",
        category: "conflict",
        severity: "error",
        message: "Transition d'état de lot interdite",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Transition de lot interdite",
                description: "Le cycle d'un lot est RECEIVED → PARSING → VALIDATING → STAGED → PUBLISHED, avec reprise possible depuis FAILED.",
                resolution: "Respecter l'ordre des états du lot."
            },
            en: {
                label: "Illegal batch state transition",
                description: "A batch goes RECEIVED → PARSING → VALIDATING → STAGED → PUBLISHED, and may resume from FAILED.",
                resolution: "Follow the batch state order."
            }
        }
    }
) END;

IF !record::exists(error_definition:INGESTION_BATCH_FAILED) THEN (
    CREATE error_definition:INGESTION_BATCH_FAILED CONTENT {
        code: "INGESTION_BATCH_FAILED",
        module: "ingestion",
        domain: "batch",
        category: "internal",
        severity: "critical",
        message: "Échec du traitement d'un lot",
        default_language: "fr",
        http_status: 500,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Échec du lot",
                description: "Le traitement du lot a échoué ; le lot est passé en FAILED.",
                resolution: "Consulter la cause jointe, corriger puis reprendre le lot."
            },
            en: {
                label: "Batch processing failed",
                description: "Processing failed; the batch moved to FAILED.",
                resolution: "Read the attached cause, fix it and resume the batch."
            }
        }
    }
) END;

IF !record::exists(error_definition:INGESTION_ILLEGAL_STATE_TRANSITION) THEN (
    CREATE error_definition:INGESTION_ILLEGAL_STATE_TRANSITION CONTENT {
        code: "INGESTION_ILLEGAL_STATE_TRANSITION",
        module: "ingestion",
        domain: "batch",
        category: "conflict",
        severity: "error",
        message: "Transition d'état interdite",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Transition interdite",
                description: "L'opération demandée n'est pas permise dans l'état actuel.",
                resolution: "Vérifier l'état courant avant de relancer l'opération."
            },
            en: {
                label: "Illegal state transition",
                description: "The requested operation is not allowed in the current state.",
                resolution: "Check the current state before retrying."
            }
        }
    }
) END;
