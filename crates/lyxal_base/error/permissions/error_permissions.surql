-- ============================================================================
-- MASTER DATA : définitions d'erreurs de lyxal_base, droits d'écriture
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:BASE_WRITE_FORBIDDEN) THEN (
    CREATE error_definition:BASE_WRITE_FORBIDDEN CONTENT {
        code: "BASE_WRITE_FORBIDDEN",
        module: "base",
        domain: "permissions",
        category: "authorization",
        severity: "error",
        message: "Écriture refusée par les permissions des référentiels de base",
        default_language: "fr",
        http_status: 403,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Écriture refusée",
                description: "L'identité appelante n'a pas le droit de créer, modifier ou supprimer une unité ou un type d'unité ; rien n'a été écrit.",
                resolution: "Administrer les référentiels depuis une session d'administration (root ou système)."
            },
            en: {
                label: "Write forbidden",
                description: "The calling identity is not allowed to create, update or delete a unit or unit type; nothing was written.",
                resolution: "Manage reference data from an administration session (root or system)."
            }
        }
    }
) END;
