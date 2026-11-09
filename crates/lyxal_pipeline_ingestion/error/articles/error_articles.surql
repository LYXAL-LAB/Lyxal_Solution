-- ============================================================================
-- MASTER DATA : définitions d'erreurs du pipeline d'ingestion, articles en staging
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:INGESTION_VALIDATION_ERROR) THEN (
    CREATE error_definition:INGESTION_VALIDATION_ERROR CONTENT {
        code: "INGESTION_VALIDATION_ERROR",
        module: "ingestion",
        domain: "staged",
        category: "validation",
        severity: "error",
        message: "Ligne source invalide",
        default_language: "fr",
        http_status: 400,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Donnée source invalide",
                description: "Une ligne du fichier n'a pas pu être lue ou validée.",
                resolution: "Corriger la ligne indiquée dans le fichier source."
            },
            en: {
                label: "Invalid source data",
                description: "A file line could not be read or validated.",
                resolution: "Fix the reported line in the source file."
            }
        }
    }
) END;

IF !record::exists(error_definition:INGESTION_ADAPTER_ERROR) THEN (
    CREATE error_definition:INGESTION_ADAPTER_ERROR CONTENT {
        code: "INGESTION_ADAPTER_ERROR",
        module: "ingestion",
        domain: "staged",
        category: "validation",
        severity: "error",
        message: "Erreur de l'adaptateur de source",
        default_language: "fr",
        http_status: 400,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Erreur d'adaptateur",
                description: "L'adaptateur du format déclaré n'a pas pu lire le contenu.",
                resolution: "Vérifier l'encodage et la structure du fichier."
            },
            en: {
                label: "Adapter error",
                description: "The adapter for the declared format could not read the content.",
                resolution: "Check the file encoding and structure."
            }
        }
    }
) END;

IF !record::exists(error_definition:INGESTION_GTIN_INVALID) THEN (
    CREATE error_definition:INGESTION_GTIN_INVALID CONTENT {
        code: "INGESTION_GTIN_INVALID",
        module: "ingestion",
        domain: "staged",
        category: "validation",
        severity: "error",
        message: "Code GTIN invalide",
        default_language: "fr",
        http_status: 400,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "GTIN invalide",
                description: "Le code-barres ne respecte pas la clé de contrôle GS1.",
                resolution: "Corriger le code-barres du fabricant."
            },
            en: {
                label: "Invalid GTIN",
                description: "The barcode does not pass the GS1 check digit.",
                resolution: "Fix the manufacturer barcode."
            }
        }
    }
) END;

IF !record::exists(error_definition:INGESTION_MANUFACTURER_REF_MISSING) THEN (
    CREATE error_definition:INGESTION_MANUFACTURER_REF_MISSING CONTENT {
        code: "INGESTION_MANUFACTURER_REF_MISSING",
        module: "ingestion",
        domain: "staged",
        category: "validation",
        severity: "error",
        message: "Référence fabricant ou fournisseur manquante",
        default_language: "fr",
        http_status: 400,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Référence fabricant manquante",
                description: "La référence fabricant (ou l'identifiant fournisseur du lot) est obligatoire.",
                resolution: "Renseigner la référence fabricant."
            },
            en: {
                label: "Manufacturer reference missing",
                description: "The manufacturer reference (or batch supplier) is required.",
                resolution: "Provide the manufacturer reference."
            }
        }
    }
) END;

IF !record::exists(error_definition:INGESTION_UNIT_UNRESOLVED) THEN (
    CREATE error_definition:INGESTION_UNIT_UNRESOLVED CONTENT {
        code: "INGESTION_UNIT_UNRESOLVED",
        module: "ingestion",
        domain: "staged",
        category: "validation",
        severity: "error",
        message: "Unité inconnue du référentiel",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Unité non résolue",
                description: "L'unité fournisseur ne correspond à aucun alias ni à aucune unité de lyxal_base.",
                resolution: "Ajouter l'alias d'unité ou corriger le fichier."
            },
            en: {
                label: "Unresolved unit",
                description: "The supplier unit matches no alias nor any lyxal_base unit.",
                resolution: "Add the unit alias or fix the file."
            }
        }
    }
) END;

IF !record::exists(error_definition:INGESTION_PACKAGING_INCOHERENT) THEN (
    CREATE error_definition:INGESTION_PACKAGING_INCOHERENT CONTENT {
        code: "INGESTION_PACKAGING_INCOHERENT",
        module: "ingestion",
        domain: "staged",
        category: "validation",
        severity: "error",
        message: "Conditionnement incohérent",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Conditionnement incohérent",
                description: "Les quantités, poids ou dimensions du conditionnement sont contradictoires.",
                resolution: "Corriger le conditionnement dans le fichier source."
            },
            en: {
                label: "Inconsistent packaging",
                description: "Packaging quantities, weights or dimensions are contradictory.",
                resolution: "Fix the packaging in the source file."
            }
        }
    }
) END;

IF !record::exists(error_definition:INGESTION_ITEM_NOT_FOUND) THEN (
    CREATE error_definition:INGESTION_ITEM_NOT_FOUND CONTENT {
        code: "INGESTION_ITEM_NOT_FOUND",
        module: "ingestion",
        domain: "staged",
        category: "not_found",
        severity: "error",
        message: "Article en staging introuvable",
        default_language: "fr",
        http_status: 404,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Article introuvable",
                description: "Aucun article en staging ne correspond à l'identifiant fourni.",
                resolution: "Vérifier l'identifiant de l'article."
            },
            en: {
                label: "Staged item not found",
                description: "No staged item matches the given identifier.",
                resolution: "Check the item identifier."
            }
        }
    }
) END;

IF !record::exists(error_definition:INGESTION_QUALIFICATION_REJECTED) THEN (
    CREATE error_definition:INGESTION_QUALIFICATION_REJECTED CONTENT {
        code: "INGESTION_QUALIFICATION_REJECTED",
        module: "ingestion",
        domain: "staged",
        category: "validation",
        severity: "error",
        message: "Ligne rejetée à la qualification",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Ligne rejetée",
                description: "La ligne ne réunit pas les preuves et spécifications nécessaires ; elle est consignée en quarantaine.",
                resolution: "Examiner la quarantaine et corriger la ligne."
            },
            en: {
                label: "Line rejected at qualification",
                description: "The line lacks the required proof and specifications; it was quarantined.",
                resolution: "Review the quarantine and fix the line."
            }
        }
    }
) END;

IF !record::exists(error_definition:INGESTION_STAGED_ILLEGAL_QUALIFICATION_TRANSITION) THEN (
    CREATE error_definition:INGESTION_STAGED_ILLEGAL_QUALIFICATION_TRANSITION CONTENT {
        code: "INGESTION_STAGED_ILLEGAL_QUALIFICATION_TRANSITION",
        module: "ingestion",
        domain: "staged",
        category: "conflict",
        severity: "error",
        message: "Changement de qualification interdit",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Qualification non modifiable ainsi",
                description: "Ce passage d'une qualification à l'autre n'est pas permis.",
                resolution: "Passer par une qualification intermédiaire autorisée."
            },
            en: {
                label: "Illegal qualification change",
                description: "This qualification change is not allowed.",
                resolution: "Go through an allowed intermediate qualification."
            }
        }
    }
) END;

IF !record::exists(error_definition:INGESTION_STAGED_CANNOT_APPROVE_NON_VERIFIED) THEN (
    CREATE error_definition:INGESTION_STAGED_CANNOT_APPROVE_NON_VERIFIED CONTENT {
        code: "INGESTION_STAGED_CANNOT_APPROVE_NON_VERIFIED",
        module: "ingestion",
        domain: "staged",
        category: "conflict",
        severity: "error",
        message: "Seul un article VERIFIED peut être approuvé",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Article non vérifié",
                description: "L'approbation exige un article qualifié VERIFIED.",
                resolution: "Requalifier l'article en VERIFIED avec preuve avant de l'approuver."
            },
            en: {
                label: "Only VERIFIED items can be approved",
                description: "Approval requires a VERIFIED item.",
                resolution: "Requalify the item as VERIFIED with proof first."
            }
        }
    }
) END;

IF !record::exists(error_definition:INGESTION_STAGED_APPROVAL_REQUIRES_STEWARD) THEN (
    CREATE error_definition:INGESTION_STAGED_APPROVAL_REQUIRES_STEWARD CONTENT {
        code: "INGESTION_STAGED_APPROVAL_REQUIRES_STEWARD",
        module: "ingestion",
        domain: "staged",
        category: "authorization",
        severity: "error",
        message: "L'approbation d'un article exige un Data Steward",
        default_language: "fr",
        http_status: 403,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Approbation réservée au Data Steward",
                description: "Seule une session détenant la permission ingestion.manifest.approve peut approuver un article, à son propre nom ; jamais à la création ni par écriture directe.",
                resolution: "Faire approuver l'article par un Data Steward."
            },
            en: {
                label: "Item approval requires a Data Steward",
                description: "Only a session holding the ingestion.manifest.approve permission can approve an item, in its own name; never at creation nor by direct write.",
                resolution: "Have a Data Steward approve the item."
            }
        }
    }
) END;

IF !record::exists(error_definition:INGESTION_STAGED_ITEM_SEALED) THEN (
    CREATE error_definition:INGESTION_STAGED_ITEM_SEALED CONTENT {
        code: "INGESTION_STAGED_ITEM_SEALED",
        module: "ingestion",
        domain: "staged",
        category: "conflict",
        severity: "error",
        message: "Article verrouillé par le manifeste scellé de son lot",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Article verrouillé",
                description: "Un manifeste du lot de cet article a été scellé : son contenu publié est figé jusqu'à la remise en brouillon de ce manifeste.",
                resolution: "Remettre le manifeste en brouillon (details.manifest_ref), corriger l'article, puis le resceller et le faire réapprouver."
            },
            en: {
                label: "Item locked",
                description: "A manifest of this item's batch has been sealed: its published content is frozen until that manifest returns to draft.",
                resolution: "Return the manifest to draft (details.manifest_ref), fix the item, then seal it again and have it re-approved."
            }
        }
    }
) END;
