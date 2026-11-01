-- ============================================================================
-- DÉFINITIONS D'ERREURS — PRIMITIVES LYXAL_CORE
-- ============================================================================
-- Codes fixes levés par `THROW` dans les fonctions de `crates/lyxal_core` quand
-- un argument fourni par le code appelant est invalide (erreur de programmation,
-- jamais une donnée utilisateur invalide : celle-ci est signalée par le résultat
-- { valid, value, code, details } des fonctions `fn::validation_*`).
--
-- Le Core n'a aucune table : ces définitions sont portées par `lyxal_error`,
-- propriétaire de `error_definition`. Forme idempotente non destructive (§5.5).
-- ============================================================================

IF !record::exists(error_definition:CORE_INVALID_ARGUMENT) THEN (
    CREATE error_definition:CORE_INVALID_ARGUMENT CONTENT {
        code: "CORE_INVALID_ARGUMENT",
        module: "core",
        domain: "argument",
        category: "internal",
        severity: "error",
        message: "A lyxal_core primitive received an invalid argument from its caller",
        default_language: "en",
        http_status: 500,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Argument invalide transmis au Core",
                description: "Une primitive de lyxal_core a reçu un argument invalide (borne négative, bornes inversées, liste vide…) de la part du code appelant.",
                resolution: "Corriger l'appel dans le module : les arguments de configuration d'une primitive du Core sont fixés par le développeur, pas par l'utilisateur."
            },
            en: {
                label: "Invalid argument passed to the Core",
                description: "A lyxal_core primitive received an invalid argument (negative bound, inverted bounds, empty list…) from the calling code.",
                resolution: "Fix the call in the module: configuration arguments of a Core primitive are set by the developer, not by the user."
            }
        }
    }
) END;

IF !record::exists(error_definition:CORE_UNSUPPORTED_OPTION) THEN (
    CREATE error_definition:CORE_UNSUPPORTED_OPTION CONTENT {
        code: "CORE_UNSUPPORTED_OPTION",
        module: "core",
        domain: "argument",
        category: "internal",
        severity: "error",
        message: "A lyxal_core primitive received an option it does not support",
        default_language: "en",
        http_status: 500,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Option non prise en charge par le Core",
                description: "Une primitive de lyxal_core a reçu une option inconnue (opérateur, mode, format…) de la part du code appelant.",
                resolution: "Corriger l'appel dans le module en utilisant une des options documentées dans l'en-tête de la primitive."
            },
            en: {
                label: "Option not supported by the Core",
                description: "A lyxal_core primitive received an unknown option (operator, mode, format…) from the calling code.",
                resolution: "Fix the call in the module using one of the options documented in the primitive header."
            }
        }
    }
) END;
