-- ============================================================================
-- MASTER DATA : définitions d'erreurs de lyxal_infra, thème zones
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:INFRA_ZONE_NOT_FOUND) THEN (
    CREATE error_definition:INFRA_ZONE_NOT_FOUND CONTENT {
        code: "INFRA_ZONE_NOT_FOUND",
        module: "infra",
        domain: "zones",
        category: "not_found",
        severity: "error",
        message: "Zone not found",
        default_language: "fr",
        http_status: 404,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Zone introuvable",
                description: "La zone demandée n'est pas rattachée.",
                resolution: "Vérifiez l'identifiant de la zone."
            },
            en: {
                label: "Zone not found",
                description: "The requested zone is not attached.",
                resolution: "Check the zone identifier."
            }
        }
    }
) END;

IF !record::exists(error_definition:INFRA_ZONE_EXISTS) THEN (
    CREATE error_definition:INFRA_ZONE_EXISTS CONTENT {
        code: "INFRA_ZONE_EXISTS",
        module: "infra",
        domain: "zones",
        category: "conflict",
        severity: "error",
        message: "Zone already attached",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Zone déjà rattachée",
                description: "Cette zone est déjà rattachée.",
                resolution: "Modifiez la zone existante."
            },
            en: {
                label: "Zone already attached",
                description: "This zone is already attached.",
                resolution: "Update the existing zone."
            }
        }
    }
) END;

IF !record::exists(error_definition:INFRA_ZONE_OVERLAP) THEN (
    CREATE error_definition:INFRA_ZONE_OVERLAP CONTENT {
        code: "INFRA_ZONE_OVERLAP",
        module: "infra",
        domain: "zones",
        category: "conflict",
        severity: "error",
        message: "Zone overlaps an attached zone",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Zones emboîtées",
                description: "La zone est contenue dans une zone rattachée, ou en contient une.",
                resolution: "Rattachez une seule des deux zones."
            },
            en: {
                label: "Overlapping zones",
                description: "The zone is inside an attached zone, or contains one.",
                resolution: "Attach only one of the two zones."
            }
        }
    }
) END;

IF !record::exists(error_definition:INFRA_ZONE_NOT_VISIBLE) THEN (
    CREATE error_definition:INFRA_ZONE_NOT_VISIBLE CONTENT {
        code: "INFRA_ZONE_NOT_VISIBLE",
        module: "infra",
        domain: "zones",
        category: "validation",
        severity: "error",
        message: "Zone not visible to the account",
        default_language: "fr",
        http_status: 400,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Zone non visible",
                description: "La zone ne figure pas parmi les zones rendues par le compte à son dernier essai.",
                resolution: "Créez la zone chez l'hébergeur ou demandez un nouvel essai du compte."
            },
            en: {
                label: "Zone not visible",
                description: "The zone is not among the zones returned by the account at its last test.",
                resolution: "Create the zone at the provider or request a new account test."
            }
        }
    }
) END;

IF !record::exists(error_definition:INFRA_ZONE_HAS_RECORDS) THEN (
    CREATE error_definition:INFRA_ZONE_HAS_RECORDS CONTENT {
        code: "INFRA_ZONE_HAS_RECORDS",
        module: "infra",
        domain: "zones",
        category: "conflict",
        severity: "error",
        message: "Zone still has records written by Lyxal",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Zone encore utilisée",
                description: "Des enregistrements écrits par Lyxal sont encore dans la zone.",
                resolution: "Retirez-les d'abord, ou détachez avec forget pour les laisser chez l'hébergeur."
            },
            en: {
                label: "Zone still in use",
                description: "Records written by Lyxal are still in the zone.",
                resolution: "Release them first, or detach with forget to leave them at the provider."
            }
        }
    }
) END;

IF !record::exists(error_definition:INFRA_ZONE_PLAN_STALE) THEN (
    CREATE error_definition:INFRA_ZONE_PLAN_STALE CONTENT {
        code: "INFRA_ZONE_PLAN_STALE",
        module: "infra",
        domain: "zones",
        category: "conflict",
        severity: "error",
        message: "Plan changed since it was shown",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Plan périmé",
                description: "Le plan a changé depuis son affichage, ou la zone n'est plus bloquée.",
                resolution: "Relisez le plan de la zone et approuvez sa nouvelle empreinte."
            },
            en: {
                label: "Stale plan",
                description: "The plan changed since it was shown, or the zone is no longer blocked.",
                resolution: "Read the zone plan again and approve its new hash."
            }
        }
    }
) END;

IF !record::exists(error_definition:INFRA_ZONE_CLAIM_LOST) THEN (
    CREATE error_definition:INFRA_ZONE_CLAIM_LOST CONTENT {
        code: "INFRA_ZONE_CLAIM_LOST",
        module: "infra",
        domain: "zones",
        category: "conflict",
        severity: "error",
        message: "Zone reservation lost",
        default_language: "fr",
        http_status: 409,
        retryable: true,
        enabled: true,
        translations: {
            fr: {
                label: "Réservation perdue",
                description: "La zone est réservée par une autre passe, ou la réservation de cette passe a expiré.",
                resolution: "La passe sera reprise par le planificateur."
            },
            en: {
                label: "Reservation lost",
                description: "The zone is reserved by another pass, or this pass reservation expired.",
                resolution: "The pass will be retried by the scheduler."
            }
        }
    }
) END;
