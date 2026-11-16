-- ============================================================================
-- DÉFINITIONS D'ERREURS — PRIMITIVES LYXAL_CORE
-- ============================================================================
-- Codes fixes levés par `THROW` dans les fonctions de `crates/lyxal_core` quand
-- un argument fourni par le code appelant est invalide (erreur de programmation,
-- jamais une donnée utilisateur invalide : celle-ci est signalée par le résultat
-- { valid, value, code, details } des fonctions `fn::validation_*`).
--
-- Chaque module porte ses propres définitions (§5.5). Elles s'écrivent dans la
-- table `error_definition` de `lyxal_error` : elles s'installent après les
-- schémas. Forme idempotente non destructive.
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

IF !record::exists(error_definition:CORE_SANITIZE_INVALID_TYPE) THEN (
    CREATE error_definition:CORE_SANITIZE_INVALID_TYPE CONTENT {
        code: "CORE_SANITIZE_INVALID_TYPE",
        module: "core",
        domain: "sanitize",
        category: "internal",
        severity: "error",
        message: "A lyxal_core sanitize primitive received a value of the wrong type (or NULL)",
        default_language: "en",
        http_status: 500,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Type invalide transmis à une fonction sanitize",
                description: "Une fonction fn::sanitize_* du Core a reçu une valeur NULL ou d'un type qu'elle ne sait pas transformer.",
                resolution: "Valider la donnée avant de la nettoyer (fonctions fn::validation_*) : une fonction sanitize suppose une valeur du bon type, ou NONE."
            },
            en: {
                label: "Invalid type passed to a sanitize function",
                description: "A Core fn::sanitize_* function received a NULL value or a value of a type it cannot transform.",
                resolution: "Validate the value before sanitizing it (fn::validation_* functions): a sanitize function expects a value of the right type, or NONE."
            }
        }
    }
) END;

IF !record::exists(error_definition:CORE_CONDITION_INVALID) THEN (
    CREATE error_definition:CORE_CONDITION_INVALID CONTENT {
        code: "CORE_CONDITION_INVALID",
        module: "core",
        domain: "condition",
        category: "internal",
        severity: "error",
        message: "A lyxal_core condition has an invalid shape or exceeds its limits",
        default_language: "en",
        http_status: 500,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Condition invalide transmise au Core",
                description: "fn::utils_condition_evaluate a reçu une condition de forme invalide (nœud inconnu, opérateur inconnu, valeur manquante) ou qui dépasse ses limites de profondeur ou de règles.",
                resolution: "Contrôler la condition à son enregistrement avec fn::utils_condition_check et refuser une condition invalide avec l'erreur du module."
            },
            en: {
                label: "Invalid condition passed to the Core",
                description: "fn::utils_condition_evaluate received a condition with an invalid shape (unknown node, unknown operator, missing value) or exceeding its depth or rule limits.",
                resolution: "Check the condition when it is saved with fn::utils_condition_check and reject an invalid condition with the module's error."
            }
        }
    }
) END;
