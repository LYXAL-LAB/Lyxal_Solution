-- ============================================================================
-- MASTER DATA : définitions d'erreurs du pipeline d'ingestion, manifestes de publication
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:INGESTION_MANIFEST_NOT_FOUND) THEN (
    CREATE error_definition:INGESTION_MANIFEST_NOT_FOUND CONTENT {
        code: "INGESTION_MANIFEST_NOT_FOUND",
        module: "ingestion",
        domain: "manifest",
        category: "not_found",
        severity: "error",
        message: "Manifeste de publication introuvable",
        default_language: "fr",
        http_status: 404,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Manifeste introuvable",
                description: "Aucun manifeste ne correspond à la référence fournie.",
                resolution: "Vérifier la référence du manifeste."
            },
            en: {
                label: "Manifest not found",
                description: "No manifest matches the given reference.",
                resolution: "Check the manifest reference."
            }
        }
    }
) END;

IF !record::exists(error_definition:INGESTION_MANIFEST_UNSEALED) THEN (
    CREATE error_definition:INGESTION_MANIFEST_UNSEALED CONTENT {
        code: "INGESTION_MANIFEST_UNSEALED",
        module: "ingestion",
        domain: "manifest",
        category: "conflict",
        severity: "error",
        message: "Le manifeste n'est pas scellé",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Manifeste non scellé",
                description: "L'approbation et la publication exigent un manifeste scellé par son empreinte BLAKE3.",
                resolution: "Sceller le manifeste avant de l'approuver."
            },
            en: {
                label: "Manifest not sealed",
                description: "Approval and publication require a manifest sealed by its BLAKE3 fingerprint.",
                resolution: "Seal the manifest before approving it."
            }
        }
    }
) END;

IF !record::exists(error_definition:INGESTION_MANIFEST_ILLEGAL_STATE_TRANSITION) THEN (
    CREATE error_definition:INGESTION_MANIFEST_ILLEGAL_STATE_TRANSITION CONTENT {
        code: "INGESTION_MANIFEST_ILLEGAL_STATE_TRANSITION",
        module: "ingestion",
        domain: "manifest",
        category: "conflict",
        severity: "error",
        message: "Transition d'état de manifeste interdite",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Transition de manifeste interdite",
                description: "Un manifeste naît DRAFT ou SEALED, puis passe APPROVED → EXECUTING → COMMITTED.",
                resolution: "Respecter l'ordre des états du manifeste."
            },
            en: {
                label: "Illegal manifest state transition",
                description: "A manifest starts DRAFT or SEALED, then goes APPROVED → EXECUTING → COMMITTED.",
                resolution: "Follow the manifest state order."
            }
        }
    }
) END;

IF !record::exists(error_definition:INGESTION_MANIFEST_APPROVAL_REQUIRES_STEWARD) THEN (
    CREATE error_definition:INGESTION_MANIFEST_APPROVAL_REQUIRES_STEWARD CONTENT {
        code: "INGESTION_MANIFEST_APPROVAL_REQUIRES_STEWARD",
        module: "ingestion",
        domain: "manifest",
        category: "authorization",
        severity: "error",
        message: "L'approbation d'un manifeste exige un Data Steward",
        default_language: "fr",
        http_status: 403,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Approbation réservée au Data Steward",
                description: "Seule la session d'un steward_admin peut approuver un manifeste ; son identité est enregistrée.",
                resolution: "Faire approuver le manifeste par un Data Steward."
            },
            en: {
                label: "Manifest approval requires a Data Steward",
                description: "Only a steward_admin session can approve a manifest; its identity is recorded.",
                resolution: "Have a Data Steward approve the manifest."
            }
        }
    }
) END;

IF !record::exists(error_definition:INGESTION_MANIFEST_EXECUTION_UNAUTHORIZED) THEN (
    CREATE error_definition:INGESTION_MANIFEST_EXECUTION_UNAUTHORIZED CONTENT {
        code: "INGESTION_MANIFEST_EXECUTION_UNAUTHORIZED",
        module: "ingestion",
        domain: "manifest",
        category: "authorization",
        severity: "error",
        message: "Exécution de publication réservée à l'agent de synchronisation",
        default_language: "fr",
        http_status: 403,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Exécution non autorisée",
                description: "Seul catalogue_sync_agent (ou l'hôte) exécute la publication vers le catalogue.",
                resolution: "Exécuter la publication avec l'identité de l'agent de synchronisation."
            },
            en: {
                label: "Publication execution reserved to the sync agent",
                description: "Only catalogue_sync_agent (or the host) runs publication to the catalogue.",
                resolution: "Run publication with the sync agent identity."
            }
        }
    }
) END;

IF !record::exists(error_definition:INGESTION_SEAL_VERIFICATION_FAILED) THEN (
    CREATE error_definition:INGESTION_SEAL_VERIFICATION_FAILED CONTENT {
        code: "INGESTION_SEAL_VERIFICATION_FAILED",
        module: "ingestion",
        domain: "manifest",
        category: "conflict",
        severity: "error",
        message: "Le sceau du manifeste ne correspond plus aux données",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Sceau rompu",
                description: "Les articles en staging ont changé depuis le scellement du manifeste.",
                resolution: "Recalculer et resceller le manifeste, puis le faire approuver à nouveau."
            },
            en: {
                label: "Manifest seal broken",
                description: "Staged items changed since the manifest was sealed.",
                resolution: "Recompute and reseal the manifest, then have it approved again."
            }
        }
    }
) END;

IF !record::exists(error_definition:INGESTION_FINGERPRINT_TAMPERED) THEN (
    CREATE error_definition:INGESTION_FINGERPRINT_TAMPERED CONTENT {
        code: "INGESTION_FINGERPRINT_TAMPERED",
        module: "ingestion",
        domain: "manifest",
        category: "conflict",
        severity: "error",
        message: "Empreinte ou sceau altéré",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Empreinte altérée",
                description: "Une empreinte calculée ne correspond pas à celle enregistrée.",
                resolution: "Recalculer les empreintes du lot concerné."
            },
            en: {
                label: "Fingerprint tampered",
                description: "A computed fingerprint does not match the recorded one.",
                resolution: "Recompute the batch fingerprints."
            }
        }
    }
) END;
