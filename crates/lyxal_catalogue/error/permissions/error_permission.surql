-- ============================================================================
-- MASTER DATA : définitions d'erreurs du catalogue, droits d'écriture
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:CATALOGUE_WRITE_FORBIDDEN) THEN (
    CREATE error_definition:CATALOGUE_WRITE_FORBIDDEN CONTENT {
        code: "CATALOGUE_WRITE_FORBIDDEN",
        module: "catalogue",
        domain: "permissions",
        category: "authorization",
        severity: "error",
        message: "Écriture refusée par les permissions du catalogue",
        default_language: "fr",
        http_status: 403,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Écriture refusée",
                description: "L'identité appelante n'a pas le droit de créer, modifier ou supprimer cet enregistrement ; rien n'a été écrit.",
                resolution: "Utiliser une identité autorisée (référentiels : administration ; articles maîtres : compte de synchronisation ; articles privés : membre de l'organisation propriétaire disposant de catalogue.item.manage)."
            },
            en: {
                label: "Write forbidden",
                description: "The calling identity is not allowed to create, update or delete this record; nothing was written.",
                resolution: "Use an authorised identity (reference data: administration; master items: sync account; private items: member of the owning organization with catalogue.item.manage)."
            }
        }
    }
) END;
