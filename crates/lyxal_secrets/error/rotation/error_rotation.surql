-- ============================================================================
-- MASTER DATA : définitions d'erreurs de lyxal_secrets, thème rotation
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:SECRETS_ROTATION_IN_PROGRESS) THEN (
    CREATE error_definition:SECRETS_ROTATION_IN_PROGRESS CONTENT {
        code: "SECRETS_ROTATION_IN_PROGRESS",
        module: "secrets",
        domain: "rotation",
        category: "conflict",
        severity: "error",
        message: "Rotation already in progress",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Rotation déjà en cours",
                description: "Une rotation de ce secret est déjà en cours : une seule à la fois.",
                resolution: "Attendez sa fin ou annulez-la avant d'en démarrer une autre."
            },
            en: {
                label: "Rotation already in progress",
                description: "A rotation of this secret is already in progress: only one at a time.",
                resolution: "Wait for it to finish or cancel it before starting another one."
            }
        }
    }
) END;

IF !record::exists(error_definition:SECRETS_ROTATION_NOT_FOUND) THEN (
    CREATE error_definition:SECRETS_ROTATION_NOT_FOUND CONTENT {
        code: "SECRETS_ROTATION_NOT_FOUND",
        module: "secrets",
        domain: "rotation",
        category: "not_found",
        severity: "error",
        message: "Rotation not found",
        default_language: "fr",
        http_status: 404,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Rotation introuvable",
                description: "Cette rotation n'existe pas ou n'est pas visible avec vos droits.",
                resolution: "Vérifiez l'identifiant de la rotation."
            },
            en: {
                label: "Rotation not found",
                description: "This rotation does not exist or is not visible with your permissions.",
                resolution: "Check the rotation identifier."
            }
        }
    }
) END;

IF !record::exists(error_definition:SECRETS_ROTATION_STATE_INVALID) THEN (
    CREATE error_definition:SECRETS_ROTATION_STATE_INVALID CONTENT {
        code: "SECRETS_ROTATION_STATE_INVALID",
        module: "secrets",
        domain: "rotation",
        category: "conflict",
        severity: "error",
        message: "Invalid rotation state",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "État de rotation incompatible",
                description: "Cette étape ne correspond pas à l'état de la rotation (ordre des étapes, rotation terminée ou nouvelle valeur absente).",
                resolution: "Relisez la rotation et reprenez à l'étape attendue."
            },
            en: {
                label: "Invalid rotation state",
                description: "This step does not match the rotation state (step order, finished rotation or missing new value).",
                resolution: "Read the rotation again and resume at the expected step."
            }
        }
    }
) END;

IF !record::exists(error_definition:SECRETS_ROTATOR_UNAVAILABLE) THEN (
    CREATE error_definition:SECRETS_ROTATOR_UNAVAILABLE CONTENT {
        code: "SECRETS_ROTATOR_UNAVAILABLE",
        module: "secrets",
        domain: "rotation",
        category: "dependency",
        severity: "error",
        message: "No rotator for this secret",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Aucun rotateur pour ce secret",
                description: "Aucun module de l'hôte ne sait changer ce secret auprès de son service : la rotation ne peut pas être automatique.",
                resolution: "Écrivez vous-même la nouvelle valeur du secret, ou installez le module qui sait la changer."
            },
            en: {
                label: "No rotator for this secret",
                description: "No host module can change this secret with its service: the rotation cannot be automatic.",
                resolution: "Write the new value of the secret yourself, or install the module that can change it."
            }
        }
    }
) END;

IF !record::exists(error_definition:SECRETS_ROTATION_TEST_FAILED) THEN (
    CREATE error_definition:SECRETS_ROTATION_TEST_FAILED CONTENT {
        code: "SECRETS_ROTATION_TEST_FAILED",
        module: "secrets",
        domain: "rotation",
        category: "dependency",
        severity: "error",
        message: "New value failed its test",
        default_language: "fr",
        http_status: 502,
        retryable: true,
        enabled: true,
        translations: {
            fr: {
                label: "La nouvelle valeur ne fonctionne pas",
                description: "Le service extérieur a refusé la nouvelle valeur pendant le test : la valeur en service est conservée.",
                resolution: "La rotation sera réessayée ; si l'échec persiste, vérifiez le compte chez le service extérieur."
            },
            en: {
                label: "New value failed its test",
                description: "The external service rejected the new value during the test: the value in service is kept.",
                resolution: "The rotation will be retried; if the failure persists, check the account with the external service."
            }
        }
    }
) END;
