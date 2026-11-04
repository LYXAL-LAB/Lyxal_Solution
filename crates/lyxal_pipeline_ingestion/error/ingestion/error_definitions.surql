-- ============================================================================
-- MASTER DATA : Définitions d'erreurs du module lyxal_pipeline_ingestion (10 définitions)
-- STANDARD    : Méthode canonique CREATE conforme à AGENTS.md & LYXAL_ARCHITECTURE.md
-- ============================================================================

IF !record::exists(error_definition:INGESTION_SOURCE_INVALID) THEN (
    CREATE error_definition:INGESTION_SOURCE_INVALID CONTENT {
        code: "INGESTION_SOURCE_INVALID",
        module: "ingestion",
        domain: "source",
        category: "validation",
        severity: "error",
        message: "Le fichier ou flux soumis ne respecte pas les spécifications attendues pour le format déclaré.",
        default_language: "fr",
        http_status: 400,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Format source ou structure de fichier invalide",
                description: "L'adaptateur de source n'a pas pu valider l'en-tête ou la délimitation des colonnes.",
                resolution: "Vérifier le format déclaré (FAB-DIS, CSV, XML, JSON) et la structure des en-têtes."
            }
        }
    }
) END;

IF !record::exists(error_definition:INGESTION_BATCH_DUPLICATE) THEN (
    CREATE error_definition:INGESTION_BATCH_DUPLICATE CONTENT {
        code: "INGESTION_BATCH_DUPLICATE",
        module: "ingestion",
        domain: "batch",
        category: "business",
        severity: "warning",
        message: "Un lot avec une empreinte BLAKE3 identique a déjà été traité avec succès.",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Lot d'ingestion dupliqué",
                description: "Protection contre les réimports intempestifs du même fichier source.",
                resolution: "Vérifier si le fichier a déjà été ingéré ou incrémenter la version du fichier si modification voulue."
            }
        }
    }
) END;

IF !record::exists(error_definition:INGESTION_GTIN_INVALID) THEN (
    CREATE error_definition:INGESTION_GTIN_INVALID CONTENT {
        code: "INGESTION_GTIN_INVALID",
        module: "ingestion",
        domain: "gtin",
        category: "validation",
        severity: "error",
        message: "Le code GTIN fourni comporte une clé de contrôle GS1 Modulo 10 erronée ou un format non conforme.",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Code GTIN/EAN invalide",
                description: "Rejet immédiat en quarantaine pour empêcher l'insertion de codes-barres corrompus.",
                resolution: "Corriger le code GTIN auprès du fabricant selon l'algorithme officiel GS1."
            }
        }
    }
) END;

IF !record::exists(error_definition:INGESTION_MANUFACTURER_REF_MISSING) THEN (
    CREATE error_definition:INGESTION_MANUFACTURER_REF_MISSING CONTENT {
        code: "INGESTION_MANUFACTURER_REF_MISSING",
        module: "ingestion",
        domain: "manufacturer",
        category: "validation",
        severity: "error",
        message: "La référence catalogue usine du fabricant est obligatoire pour tout article commercial.",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Référence fabricant absente",
                description: "Aucun article ne peut être créé sans identité usine claire.",
                resolution: "Renseigner la référence catalogue du fabricant dans le champ approprié."
            }
        }
    }
) END;

IF !record::exists(error_definition:INGESTION_UNIT_UNRESOLVED) THEN (
    CREATE error_definition:INGESTION_UNIT_UNRESOLVED CONTENT {
        code: "INGESTION_UNIT_UNRESOLVED",
        module: "ingestion",
        domain: "unit",
        category: "validation",
        severity: "error",
        message: "L'unité fournie par le fabricant n'a pu être rapprochée d'aucune unité officielle du référentiel 'base_unite'.",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Unité de vente non résolue",
                description: "Impossibilité d'intégrer une référence sans unité métrologique standardisée.",
                resolution: "Associer l'abréviation fournisseur à une unité de base (PCE, M2, ML, KG, LTR)."
            }
        }
    }
) END;

IF !record::exists(error_definition:INGESTION_PACKAGING_INCOHERENT) THEN (
    CREATE error_definition:INGESTION_PACKAGING_INCOHERENT CONTENT {
        code: "INGESTION_PACKAGING_INCOHERENT",
        module: "ingestion",
        domain: "packaging",
        category: "validation",
        severity: "error",
        message: "Les valeurs de quantité, poids ou dimensions du colisage sont négatives, nulles ou absurdes.",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Conditionnement physique incohérent",
                description: "Contrôle d'intégrité physique du conditionnement.",
                resolution: "Fournir des cotes dimensionnelles et des poids bruts strictement positifs."
            }
        }
    }
) END;

IF !record::exists(error_definition:INGESTION_ILLEGAL_STATE_TRANSITION) THEN (
    CREATE error_definition:INGESTION_ILLEGAL_STATE_TRANSITION CONTENT {
        code: "INGESTION_ILLEGAL_STATE_TRANSITION",
        module: "ingestion",
        domain: "illegal",
        category: "business",
        severity: "error",
        message: "La transition demandée n'est pas autorisée par la machine à états de l'entité.",
        default_language: "fr",
        http_status: 400,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Transition d'état illégale",
                description: "Verrouillage strict du cycle de vie des lots, articles en staging et manifestes.",
                resolution: "Consulter la machine à états officielle et respecter l'ordre strict des transitions."
            }
        }
    }
) END;

IF !record::exists(error_definition:INGESTION_SEAL_VERIFICATION_FAILED) THEN (
    CREATE error_definition:INGESTION_SEAL_VERIFICATION_FAILED CONTENT {
        code: "INGESTION_SEAL_VERIFICATION_FAILED",
        module: "ingestion",
        domain: "seal",
        category: "authorization",
        severity: "critical",
        message: "Les données d'articles en staging ont été modifiées après l'approbation formelle du manifeste.",
        default_language: "fr",
        http_status: 403,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Rupture de scellement du manifeste",
                description: "Détection d'altération post-approbation via divergence du hachage BLAKE3.",
                resolution: "Régénérer et faire ré-approuver formellement le manifeste par le Data Steward."
            }
        }
    }
) END;

IF !record::exists(error_definition:INGESTION_UNAUTHORIZED) THEN (
    CREATE error_definition:INGESTION_UNAUTHORIZED CONTENT {
        code: "INGESTION_UNAUTHORIZED",
        module: "ingestion",
        domain: "unauthorized",
        category: "authorization",
        severity: "critical",
        message: "L'identité authentifiée ne possède pas le rôle ou les habilitations nécessaires pour cette étape.",
        default_language: "fr",
        http_status: 403,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Opération d'ingestion non autorisée",
                description: "Cloisonnement des rôles : ingestion_agent, qualification_agent, steward_admin, catalogue_sync_agent.",
                resolution: "Utiliser un jeton d'accès pourvu des privilèges appropriés."
            }
        }
    }
) END;

IF !record::exists(error_definition:INGESTION_UNAUTHORIZED_APPROVER) THEN (
    CREATE error_definition:INGESTION_UNAUTHORIZED_APPROVER CONTENT {
        code: "INGESTION_UNAUTHORIZED_APPROVER",
        module: "ingestion",
        domain: "unauthorized",
        category: "authorization",
        severity: "critical",
        message: "La requalification ou l'approbation requiert le rôle steward_admin sous session dédiée.",
        default_language: "fr",
        http_status: 403,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Approbateur non habilité",
                description: "Contrôle strict des habilitations d'arbitrage Data Steward sur les données en quarantaine et en staging.",
                resolution: "Utiliser une session active disposant du rôle steward_admin."
            }
        }
    }
) END;
