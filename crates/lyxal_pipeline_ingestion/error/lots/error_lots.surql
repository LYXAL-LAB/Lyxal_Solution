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

IF !record::exists(error_definition:INGESTION_BATCH_ALREADY_CLAIMED) THEN (
    CREATE error_definition:INGESTION_BATCH_ALREADY_CLAIMED CONTENT {
        code: "INGESTION_BATCH_ALREADY_CLAIMED",
        module: "ingestion",
        domain: "batch",
        category: "conflict",
        severity: "warning",
        message: "Le lot est déjà en cours de traitement par une autre exécution",
        default_language: "fr",
        http_status: 409,
        retryable: true,
        enabled: true,
        translations: {
            fr: {
                label: "Lot déjà en traitement",
                description: "Une autre exécution détient la réservation du lot jusqu'à son échéance.",
                resolution: "Attendre la fin du traitement en cours ou l'expiration de sa réservation (details.until)."
            },
            en: {
                label: "Batch already being processed",
                description: "Another execution holds the batch claim until it expires.",
                resolution: "Wait for the running processing to finish or for its claim to expire (details.until)."
            }
        }
    }
) END;

IF !record::exists(error_definition:INGESTION_BATCH_CLAIM_LOST) THEN (
    CREATE error_definition:INGESTION_BATCH_CLAIM_LOST CONTENT {
        code: "INGESTION_BATCH_CLAIM_LOST",
        module: "ingestion",
        domain: "batch",
        category: "conflict",
        severity: "error",
        message: "L'exécution ne détient plus la réservation du lot : l'écriture est refusée",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Réservation du lot perdue",
                description: "La réservation a expiré ou a été reprise par une autre exécution ; rien n'a été écrit.",
                resolution: "Relancer le traitement du lot : il reprendra au dernier point de reprise."
            },
            en: {
                label: "Batch claim lost",
                description: "The claim expired or was taken over by another execution; nothing was written.",
                resolution: "Restart the batch processing: it resumes from the last checkpoint."
            }
        }
    }
) END;

IF !record::exists(error_definition:INGESTION_SOURCE_RECORD_REJECTED) THEN (
    CREATE error_definition:INGESTION_SOURCE_RECORD_REJECTED CONTENT {
        code: "INGESTION_SOURCE_RECORD_REJECTED",
        module: "ingestion",
        domain: "batch",
        category: "validation",
        severity: "error",
        message: "Un enregistrement du fichier n'a pas pu être lu et a été écarté",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Enregistrement illisible",
                description: "La lecture du fichier a écarté cet enregistrement (nombre de champs, élément non objet, entité inconnue, texte non décodable, taille ou profondeur excessive) ; la cause précise PARSING_* est indiquée.",
                resolution: "Corriger l'enregistrement dans le fichier source (ligne indiquée) puis le réimporter."
            },
            en: {
                label: "Unreadable record",
                description: "Reading the file discarded this record (field count, non-object element, unknown entity, undecodable text, excessive size or depth); the precise PARSING_* cause is given.",
                resolution: "Fix the record in the source file (line given) and import it again."
            }
        }
    }
) END;

IF !record::exists(error_definition:INGESTION_FABDIS_BLOCK_INVALID) THEN (
    CREATE error_definition:INGESTION_FABDIS_BLOCK_INVALID CONTENT {
        code: "INGESTION_FABDIS_BLOCK_INVALID",
        module: "ingestion",
        domain: "batch",
        category: "validation",
        severity: "error",
        message: "Un bloc FAB-DIS 2.3 est invalide et a été écarté",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Bloc FAB-DIS invalide",
                description: "Bloc sans référence fabricant, de type inconnu, en double, ou bloc logistique ou réglementaire sans bloc commercial (C) de même référence.",
                resolution: "Corriger le bloc dans le fichier FAB-DIS (ligne indiquée) puis le réimporter."
            },
            en: {
                label: "Invalid FAB-DIS block",
                description: "Block without manufacturer reference, of unknown type, duplicated, or logistics or regulatory block without a commercial (C) block for the same reference.",
                resolution: "Fix the block in the FAB-DIS file (line given) and import it again."
            }
        }
    }
) END;
