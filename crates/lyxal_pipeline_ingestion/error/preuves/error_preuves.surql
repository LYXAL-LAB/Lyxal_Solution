-- ============================================================================
-- MASTER DATA : définitions d'erreurs du pipeline d'ingestion, preuves commerciales
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:INGESTION_PROOF_MISSING) THEN (
    CREATE error_definition:INGESTION_PROOF_MISSING CONTENT {
        code: "INGESTION_PROOF_MISSING",
        module: "ingestion",
        domain: "proof",
        category: "validation",
        severity: "error",
        message: "Preuve commerciale manquante",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Preuve manquante",
                description: "Le passage en VERIFIED exige une preuve commerciale formelle.",
                resolution: "Joindre une preuve (catalogue signé, EDI fabricant, tarif officiel, validation documentée)."
            },
            en: {
                label: "Commercial proof missing",
                description: "Moving to VERIFIED requires formal commercial proof.",
                resolution: "Attach a proof (signed catalogue, manufacturer EDI, official tariff, documented validation)."
            }
        }
    }
) END;

IF !record::exists(error_definition:INGESTION_PROOF_INVALID) THEN (
    CREATE error_definition:INGESTION_PROOF_INVALID CONTENT {
        code: "INGESTION_PROOF_INVALID",
        module: "ingestion",
        domain: "proof",
        category: "validation",
        severity: "error",
        message: "Preuve commerciale incomplète",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Preuve invalide",
                description: "La référence documentaire et l'autorité émettrice de la preuve sont obligatoires.",
                resolution: "Compléter la référence et l'autorité de la preuve."
            },
            en: {
                label: "Invalid commercial proof",
                description: "The proof reference and issuing authority are required.",
                resolution: "Complete the proof reference and authority."
            }
        }
    }
) END;

IF !record::exists(error_definition:INGESTION_PROOF_TYPE_UNKNOWN) THEN (
    CREATE error_definition:INGESTION_PROOF_TYPE_UNKNOWN CONTENT {
        code: "INGESTION_PROOF_TYPE_UNKNOWN",
        module: "ingestion",
        domain: "proof",
        category: "validation",
        severity: "error",
        message: "Type de preuve inconnu",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Type de preuve inconnu",
                description: "Types admis : CERTIFIED_MANUFACTURER_EDI, SIGNED_VENDOR_CATALOG, OFFICIAL_TARIFF_CERTIFICATE, STEWARD_DOCUMENTED_VALIDATION.",
                resolution: "Choisir un type de preuve admis."
            },
            en: {
                label: "Unknown proof type",
                description: "Allowed types: CERTIFIED_MANUFACTURER_EDI, SIGNED_VENDOR_CATALOG, OFFICIAL_TARIFF_CERTIFICATE, STEWARD_DOCUMENTED_VALIDATION.",
                resolution: "Choose an allowed proof type."
            }
        }
    }
) END;
