-- ============================================================================
-- MASTER DATA : définitions d'erreurs du catalogue, domaine `relation`
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:CATALOGUE_RELATION_SELF_REFERENCED) THEN (
    CREATE error_definition:CATALOGUE_RELATION_SELF_REFERENCED CONTENT {
        code: "CATALOGUE_RELATION_SELF_REFERENCED",
        module: "catalogue",
        domain: "relation",
        category: "validation",
        severity: "error",
        message: "Une relation ne peut pas lier un élément à lui-même",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Auto-liaison interdite",
                description: "L'élément source et l'élément cible d'une relation doivent être distincts.",
                resolution: "Sélectionnez deux éléments différents."
            },
            en: {
                label: "Self-referencing relation forbidden",
                description: "Source and target items of a relation must be distinct.",
                resolution: "Select two distinct items."
            }
        }
    }
) END;

IF !record::exists(error_definition:CATALOGUE_RELATION_TYPE_NOT_FOUND) THEN (
    CREATE error_definition:CATALOGUE_RELATION_TYPE_NOT_FOUND CONTENT {
        code: "CATALOGUE_RELATION_TYPE_NOT_FOUND",
        module: "catalogue",
        domain: "relation",
        category: "not_found",
        severity: "error",
        message: "Type de relation inter-éléments introuvable ou inactif",
        default_language: "fr",
        http_status: 404,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Type de relation introuvable",
                description: "Le type de relation spécifié n'existe pas dans catalogue_relation_type ou est inactif.",
                resolution: "Sélectionnez un type de relation actif (ACCESSOIRE, SUBSTITUT, SIMILAIRE, COMPATIBLE, OBLIGATOIRE)."
            },
            en: {
                label: "Relation type not found",
                description: "The specified relation type does not exist or is inactive.",
                resolution: "Select an active relation type."
            }
        }
    }
) END;

IF !record::exists(error_definition:CATALOGUE_RELATION_NOT_FOUND) THEN (
    CREATE error_definition:CATALOGUE_RELATION_NOT_FOUND CONTENT {
        code: "CATALOGUE_RELATION_NOT_FOUND",
        module: "catalogue",
        domain: "relation",
        category: "not_found",
        severity: "error",
        message: "Relation inter-éléments introuvable",
        default_language: "fr",
        http_status: 404,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Relation introuvable",
                description: "La liaison demandée n'existe pas.",
                resolution: "Vérifiez l'identifiant de la relation."
            },
            en: {
                label: "Relation not found",
                description: "The requested relation does not exist.",
                resolution: "Check relation ID."
            }
        }
    }
) END;

IF !record::exists(error_definition:CATALOGUE_RELATION_COMMERCIAL_SPEC_INVALID) THEN (
    CREATE error_definition:CATALOGUE_RELATION_COMMERCIAL_SPEC_INVALID CONTENT {
        code: "CATALOGUE_RELATION_COMMERCIAL_SPEC_INVALID",
        module: "catalogue",
        domain: "relation",
        category: "validation",
        severity: "error",
        message: "La relation COMMERCIAL_SPECIFICATION exige une source commerciale et une cible générique",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Liaison commerciale/générique invalide",
                description: "Une spécification commerciale doit relier un article COMMERCIAL vers un article GÉNÉRIQUE.",
                resolution: "Vérifiez la nature de la source (COMMERCIALE) et de la cible (GENERIQUE)."
            },
            en: {
                label: "Invalid commercial specification link",
                description: "A commercial specification must link a COMMERCIAL source to a GENERIQUE target.",
                resolution: "Verify item natures."
            }
        }
    }
) END;

IF !record::exists(error_definition:CATALOGUE_RELATION_REMPLACEMENT_TARGET_INVALID) THEN (
    CREATE error_definition:CATALOGUE_RELATION_REMPLACEMENT_TARGET_INVALID CONTENT {
        code: "CATALOGUE_RELATION_REMPLACEMENT_TARGET_INVALID",
        module: "catalogue",
        domain: "relation",
        category: "validation",
        severity: "error",
        message: "L'article cible de remplacement doit être actif et non obsolète",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Cible de remplacement invalide",
                description: "Un article de remplacement doit être activé et ne peut pas être lui-même obsolète.",
                resolution: "Sélectionnez un article de substitution actif."
            },
            en: {
                label: "Invalid replacement target",
                description: "A replacement target must be active and not obsolete.",
                resolution: "Select an active substitute item."
            }
        }
    }
) END;

IF !record::exists(error_definition:CATALOGUE_RELATION_REMPLACEMENT_CYCLE) THEN (
    CREATE error_definition:CATALOGUE_RELATION_REMPLACEMENT_CYCLE CONTENT {
        code: "CATALOGUE_RELATION_REMPLACEMENT_CYCLE",
        module: "catalogue",
        domain: "relation",
        category: "validation",
        severity: "error",
        message: "Détection d'un cycle de remplacement direct ou indirect interdit",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Cycle de remplacement interdit",
                description: "La chaîne de remplacement forme une boucle fermée (A remplace B qui remplace A).",
                resolution: "Supprimez la boucle de substitution."
            },
            en: {
                label: "Replacement cycle detected",
                description: "The replacement sequence forms a closed loop.",
                resolution: "Break the replacement loop."
            }
        }
    }
) END;

IF !record::exists(error_definition:CATALOGUE_RELATION_CYCLE_DEPTH_EXCEEDED) THEN (
    CREATE error_definition:CATALOGUE_RELATION_CYCLE_DEPTH_EXCEEDED CONTENT {
        code: "CATALOGUE_RELATION_CYCLE_DEPTH_EXCEEDED",
        module: "catalogue",
        domain: "relation",
        category: "internal",
        severity: "error",
        message: "Limite de profondeur atteinte lors du contrôle anti-cycle de relation",
        default_language: "fr",
        http_status: 500,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Profondeur de relation dépassée",
                description: "Le parcours de contrôle anti-cycle a atteint sa limite technique maximale.",
                resolution: "Vérifiez la structure du graphe de relations."
            },
            en: {
                label: "Relation depth exceeded",
                description: "Anti-cycle traversal reached the maximum depth limit.",
                resolution: "Inspect graph structure."
            }
        }
    }
) END;

IF !record::exists(error_definition:CATALOGUE_RELATION_BEFORE_SOURCE_UNAUTHORIZED) THEN (
    CREATE error_definition:CATALOGUE_RELATION_BEFORE_SOURCE_UNAUTHORIZED CONTENT {
        code: "CATALOGUE_RELATION_BEFORE_SOURCE_UNAUTHORIZED",
        module: "catalogue",
        domain: "relation",
        category: "authorization",
        severity: "error",
        message: "L'article source d'origine de la relation appartient à un autre locataire",
        default_language: "fr",
        http_status: 403,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Source d'origine non autorisée",
                description: "Une relation existante dont la source est un article privé d'un autre locataire ne peut pas être modifiée ni supprimée.",
                resolution: "Ne modifier que les relations de son propre locataire."
            },
            en: {
                label: "Original source not allowed",
                description: "An existing relation whose source is another tenant's private item cannot be changed or deleted.",
                resolution: "Only change your own tenant's relations."
            }
        }
    }
) END;

IF !record::exists(error_definition:CATALOGUE_RELATION_BEFORE_TARGET_UNAUTHORIZED) THEN (
    CREATE error_definition:CATALOGUE_RELATION_BEFORE_TARGET_UNAUTHORIZED CONTENT {
        code: "CATALOGUE_RELATION_BEFORE_TARGET_UNAUTHORIZED",
        module: "catalogue",
        domain: "relation",
        category: "authorization",
        severity: "error",
        message: "L'article cible d'origine de la relation appartient à un autre locataire",
        default_language: "fr",
        http_status: 403,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Cible d'origine non autorisée",
                description: "Une relation existante dont la cible est un article privé d'un autre locataire ne peut pas être modifiée ni supprimée.",
                resolution: "Ne modifier que les relations de son propre locataire."
            },
            en: {
                label: "Original target not allowed",
                description: "An existing relation whose target is another tenant's private item cannot be changed or deleted.",
                resolution: "Only change your own tenant's relations."
            }
        }
    }
) END;

IF !record::exists(error_definition:CATALOGUE_RELATION_AFTER_SOURCE_UNAUTHORIZED) THEN (
    CREATE error_definition:CATALOGUE_RELATION_AFTER_SOURCE_UNAUTHORIZED CONTENT {
        code: "CATALOGUE_RELATION_AFTER_SOURCE_UNAUTHORIZED",
        module: "catalogue",
        domain: "relation",
        category: "authorization",
        severity: "error",
        message: "L'article source indiqué appartient à un autre locataire",
        default_language: "fr",
        http_status: 403,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Source non autorisée",
                description: "La source d'une relation ne peut pas être un article privé d'un autre locataire.",
                resolution: "Choisir un article maître ou un article de son locataire."
            },
            en: {
                label: "Source not allowed",
                description: "A relation source cannot be another tenant's private item.",
                resolution: "Choose a master item or one of your tenant's items."
            }
        }
    }
) END;

IF !record::exists(error_definition:CATALOGUE_RELATION_AFTER_TARGET_UNAUTHORIZED) THEN (
    CREATE error_definition:CATALOGUE_RELATION_AFTER_TARGET_UNAUTHORIZED CONTENT {
        code: "CATALOGUE_RELATION_AFTER_TARGET_UNAUTHORIZED",
        module: "catalogue",
        domain: "relation",
        category: "authorization",
        severity: "error",
        message: "L'article cible indiqué appartient à un autre locataire",
        default_language: "fr",
        http_status: 403,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Cible non autorisée",
                description: "La cible d'une relation ne peut pas être un article privé d'un autre locataire.",
                resolution: "Choisir un article maître ou un article de son locataire."
            },
            en: {
                label: "Target not allowed",
                description: "A relation target cannot be another tenant's private item.",
                resolution: "Choose a master item or one of your tenant's items."
            }
        }
    }
) END;

IF !record::exists(error_definition:CATALOGUE_RELATION_CANNOT_LINK_MASTER) THEN (
    CREATE error_definition:CATALOGUE_RELATION_CANNOT_LINK_MASTER CONTENT {
        code: "CATALOGUE_RELATION_CANNOT_LINK_MASTER",
        module: "catalogue",
        domain: "relation",
        category: "authorization",
        severity: "error",
        message: "Un locataire ne relie pas deux articles maîtres entre eux",
        default_language: "fr",
        http_status: 403,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Relation maître réservée",
                description: "Les relations entre deux articles maîtres relèvent de l'agent de synchronisation.",
                resolution: "Relier un article privé à un article maître, ou passer par la synchronisation."
            },
            en: {
                label: "Master relation reserved",
                description: "Relations between two master items belong to the sync agent.",
                resolution: "Link a private item to a master item, or go through synchronisation."
            }
        }
    }
) END;

IF !record::exists(error_definition:CATALOGUE_RELATION_CANNOT_ALTER_MASTER) THEN (
    CREATE error_definition:CATALOGUE_RELATION_CANNOT_ALTER_MASTER CONTENT {
        code: "CATALOGUE_RELATION_CANNOT_ALTER_MASTER",
        module: "catalogue",
        domain: "relation",
        category: "authorization",
        severity: "error",
        message: "Un locataire ne modifie pas une relation entre deux articles maîtres",
        default_language: "fr",
        http_status: 403,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Relation maître non modifiable",
                description: "Une relation entre deux articles maîtres ne peut être modifiée ou supprimée que par l'agent de synchronisation.",
                resolution: "Passer par la synchronisation du catalogue maître."
            },
            en: {
                label: "Master relation read-only",
                description: "A relation between two master items can only be changed by the sync agent.",
                resolution: "Go through master catalogue synchronisation."
            }
        }
    }
) END;

IF !record::exists(error_definition:CATALOGUE_RELATION_SYNC_CANNOT_ACCESS_CUSTOM) THEN (
    CREATE error_definition:CATALOGUE_RELATION_SYNC_CANNOT_ACCESS_CUSTOM CONTENT {
        code: "CATALOGUE_RELATION_SYNC_CANNOT_ACCESS_CUSTOM",
        module: "catalogue",
        domain: "relation",
        category: "authorization",
        severity: "error",
        message: "L'agent de synchronisation ne touche pas aux relations d'articles privés",
        default_language: "fr",
        http_status: 403,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Relation privée inaccessible",
                description: "L'agent de synchronisation ne crée, ne modifie ni ne supprime de relation impliquant un article privé.",
                resolution: "Limiter la synchronisation aux articles maîtres."
            },
            en: {
                label: "Private relation off-limits",
                description: "The sync agent never creates, changes or deletes a relation involving a private item.",
                resolution: "Limit synchronisation to master items."
            }
        }
    }
) END;
