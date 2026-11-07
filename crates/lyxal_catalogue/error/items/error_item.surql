-- ============================================================================
-- MASTER DATA : définitions d'erreurs du catalogue, domaine `item`
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:CATALOGUE_ITEM_NOT_FOUND) THEN (
    CREATE error_definition:CATALOGUE_ITEM_NOT_FOUND CONTENT {
        code: "CATALOGUE_ITEM_NOT_FOUND",
        module: "catalogue",
        domain: "item",
        category: "not_found",
        severity: "error",
        message: "Élément de catalogue introuvable",
        default_language: "fr",
        http_status: 404,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Élément de catalogue introuvable",
                description: "L'élément de catalogue référencé n'existe pas en base.",
                resolution: "Vérifiez l'identifiant ou le code de l'élément."
            },
            en: {
                label: "Catalogue item not found",
                description: "The requested catalogue item does not exist.",
                resolution: "Check the item code or ID."
            }
        }
    }
) END;

IF !record::exists(error_definition:CATALOGUE_ITEM_ALREADY_EXISTS) THEN (
    CREATE error_definition:CATALOGUE_ITEM_ALREADY_EXISTS CONTENT {
        code: "CATALOGUE_ITEM_ALREADY_EXISTS",
        module: "catalogue",
        domain: "item",
        category: "conflict",
        severity: "error",
        message: "Un élément avec ce code existe déjà",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Élément déjà existant",
                description: "Le code d'élément doit être unique au catalogue.",
                resolution: "Utilisez un code différent."
            },
            en: {
                label: "Item already exists",
                description: "The item code must be unique.",
                resolution: "Use a different code."
            }
        }
    }
) END;

IF !record::exists(error_definition:CATALOGUE_ITEM_TYPE_NOT_FOUND) THEN (
    CREATE error_definition:CATALOGUE_ITEM_TYPE_NOT_FOUND CONTENT {
        code: "CATALOGUE_ITEM_TYPE_NOT_FOUND",
        module: "catalogue",
        domain: "item",
        category: "not_found",
        severity: "error",
        message: "Type d'élément de catalogue introuvable ou inactif",
        default_language: "fr",
        http_status: 404,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Type d'élément introuvable",
                description: "Le type spécifié (PRODUIT, SERVICE, OUVRAGE, RESSOURCE, ENSEMBLE) n'existe pas ou est désactivé.",
                resolution: "Sélectionnez un type fondamental actif."
            },
            en: {
                label: "Item type not found",
                description: "The specified item type does not exist or is inactive.",
                resolution: "Select an active fundamental type."
            }
        }
    }
) END;

IF !record::exists(error_definition:CATALOGUE_ITEM_UNITE_INVALID) THEN (
    CREATE error_definition:CATALOGUE_ITEM_UNITE_INVALID CONTENT {
        code: "CATALOGUE_ITEM_UNITE_INVALID",
        module: "catalogue",
        domain: "item",
        category: "validation",
        severity: "error",
        message: "Unité de mesure de référence invalide ou inactive",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Unité de mesure invalide",
                description: "L'unité de référence doit exister dans base_unite et être active.",
                resolution: "Renseignez une unité de mesure valide du socle lyxal_base."
            },
            en: {
                label: "Invalid unit of measure",
                description: "The reference unit must exist in base_unite and be active.",
                resolution: "Provide a valid unit from lyxal_base."
            }
        }
    }
) END;

IF !record::exists(error_definition:CATALOGUE_ITEM_IN_USE) THEN (
    CREATE error_definition:CATALOGUE_ITEM_IN_USE CONTENT {
        code: "CATALOGUE_ITEM_IN_USE",
        module: "catalogue",
        domain: "item",
        category: "conflict",
        severity: "error",
        message: "Impossible de supprimer un élément consommé dans des nomenclatures",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Élément en cours d'utilisation",
                description: "Cet article ou ressource est référencé dans des compositions actives.",
                resolution: "Retirez d'abord l'élément de toutes les compositions associées avant suppression."
            },
            en: {
                label: "Item in use",
                description: "This item is referenced in existing active compositions.",
                resolution: "Remove the item from all compositions before deleting."
            }
        }
    }
) END;

IF !record::exists(error_definition:CATALOGUE_ITEM_SYSTEM_IMMUTABLE) THEN (
    CREATE error_definition:CATALOGUE_ITEM_SYSTEM_IMMUTABLE CONTENT {
        code: "CATALOGUE_ITEM_SYSTEM_IMMUTABLE",
        module: "catalogue",
        domain: "item",
        category: "authorization",
        severity: "error",
        message: "Impossible de supprimer un élément de catalogue système immuable",
        default_language: "fr",
        http_status: 403,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Élément système immuable",
                description: "Cet élément fait partie intégrante du socle système et ne peut être supprimé.",
                resolution: "Les éléments marqués is_system ne peuvent être altérés."
            },
            en: {
                label: "Immutable system item",
                description: "This item is part of the system core and cannot be deleted.",
                resolution: "System items cannot be modified or removed."
            }
        }
    }
) END;

IF !record::exists(error_definition:CATALOGUE_ITEM_GENERIC_CANNOT_HAVE_BRAND) THEN (
    CREATE error_definition:CATALOGUE_ITEM_GENERIC_CANNOT_HAVE_BRAND CONTENT {
        code: "CATALOGUE_ITEM_GENERIC_CANNOT_HAVE_BRAND",
        module: "catalogue",
        domain: "item",
        category: "validation",
        severity: "error",
        message: "Un article générique ne peut comporter ni fabricant, ni marque, ni référence usine, ni code-barres",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Générique avec marque interdit",
                description: "Une référence générique normative doit rester neutre sans données de fabricant ou code-barres.",
                resolution: "Supprimez les informations de fabricant ou définissez la nature sur COMMERCIALE."
            },
            en: {
                label: "Generic item cannot have brand data",
                description: "A generic normative item must remain neutral without manufacturer data or barcode.",
                resolution: "Remove brand/manufacturer fields or set nature to COMMERCIALE."
            }
        }
    }
) END;

IF !record::exists(error_definition:CATALOGUE_ITEM_COMMERCIAL_REQUIRES_BRAND) THEN (
    CREATE error_definition:CATALOGUE_ITEM_COMMERCIAL_REQUIRES_BRAND CONTENT {
        code: "CATALOGUE_ITEM_COMMERCIAL_REQUIRES_BRAND",
        module: "catalogue",
        domain: "item",
        category: "validation",
        severity: "error",
        message: "Un article commercial doit obligatoirement spécifier un fabricant ou une marque",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Fabricant ou marque obligatoire",
                description: "Toute référence marchande commerciale doit être rattachée à un industriel ou une marque.",
                resolution: "Renseignez le champ fabricant ou marque."
            },
            en: {
                label: "Commercial item requires brand or manufacturer",
                description: "Every commercial item must be linked to a manufacturer or brand.",
                resolution: "Provide manufacturer or brand field."
            }
        }
    }
) END;

IF !record::exists(error_definition:CATALOGUE_ITEM_GTIN_INVALID) THEN (
    CREATE error_definition:CATALOGUE_ITEM_GTIN_INVALID CONTENT {
        code: "CATALOGUE_ITEM_GTIN_INVALID",
        module: "catalogue",
        domain: "item",
        category: "validation",
        severity: "error",
        message: "Code-barres GTIN/EAN invalide (clé de contrôle GS1 Modulo 10 incorrecte)",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Code GTIN invalide",
                description: "Le code GTIN/EAN ne respecte pas l'algorithme officiel de contrôle GS1 Modulo 10.",
                resolution: "Vérifiez le code-barres et sa clé de contrôle terminale."
            },
            en: {
                label: "Invalid GTIN/EAN checksum",
                description: "The provided barcode fails GS1 Modulo 10 checksum verification.",
                resolution: "Verify the barcode digits and checksum."
            }
        }
    }
) END;

IF !record::exists(error_definition:CATALOGUE_ITEM_GTIN_ALREADY_EXISTS) THEN (
    CREATE error_definition:CATALOGUE_ITEM_GTIN_ALREADY_EXISTS CONTENT {
        code: "CATALOGUE_ITEM_GTIN_ALREADY_EXISTS",
        module: "catalogue",
        domain: "item",
        category: "conflict",
        severity: "error",
        message: "Un article avec ce code-barres GTIN/EAN existe déjà au catalogue",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Code-barres déjà attribué",
                description: "L'identifiant GS1 GTIN/EAN doit être universellement unique.",
                resolution: "Vérifiez si l'article n'est pas déjà enregistré au catalogue."
            },
            en: {
                label: "Duplicate GTIN barcode",
                description: "The GTIN/EAN code is globally unique and already assigned.",
                resolution: "Search for the existing item or verify barcode."
            }
        }
    }
) END;

IF !record::exists(error_definition:CATALOGUE_ITEM_FAB_REF_DUPLICATE) THEN (
    CREATE error_definition:CATALOGUE_ITEM_FAB_REF_DUPLICATE CONTENT {
        code: "CATALOGUE_ITEM_FAB_REF_DUPLICATE",
        module: "catalogue",
        domain: "item",
        category: "conflict",
        severity: "error",
        message: "Cette référence fabricant existe déjà pour ce fabricant",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Référence fabricant dupliquée",
                description: "Un fabricant ne peut pas posséder deux articles distincts avec la même référence usine.",
                resolution: "Vérifiez la référence fabricant ou mettez à jour l'article existant."
            },
            en: {
                label: "Duplicate manufacturer SKU",
                description: "A manufacturer cannot have multiple items with the same reference code.",
                resolution: "Check manufacturer reference code."
            }
        }
    }
) END;

IF !record::exists(error_definition:CATALOGUE_ITEM_MASTER_ID_DUPLICATE) THEN (
    CREATE error_definition:CATALOGUE_ITEM_MASTER_ID_DUPLICATE CONTENT {
        code: "CATALOGUE_ITEM_MASTER_ID_DUPLICATE",
        module: "catalogue",
        domain: "item",
        category: "conflict",
        severity: "error",
        message: "Une référence locale est déjà associée à cet identifiant maître de synchronisation",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Article maître déjà synchronisé",
                description: "Une base cliente ne peut pas synchroniser deux fois la même référence maîtresse.",
                resolution: "Mettez à jour la référence locale existante au lieu d'en créer une nouvelle."
            },
            en: {
                label: "Duplicate master reference ID",
                description: "A tenant database cannot synchronize the same master item twice.",
                resolution: "Update the existing local synced item instead."
            }
        }
    }
) END;

IF !record::exists(error_definition:CATALOGUE_ITEM_MASTER_ID_IMMUTABLE) THEN (
    CREATE error_definition:CATALOGUE_ITEM_MASTER_ID_IMMUTABLE CONTENT {
        code: "CATALOGUE_ITEM_MASTER_ID_IMMUTABLE",
        module: "catalogue",
        domain: "item",
        category: "authorization",
        severity: "error",
        message: "L'identifiant maître d'un article synchronisé est strictement immuable",
        default_language: "fr",
        http_status: 403,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Identifiant maître immuable",
                description: "Il est interdit de modifier la référence vers le catalogue maître une fois établie.",
                resolution: "Conservez le lien maître d'origine."
            },
            en: {
                label: "Master reference ID is immutable",
                description: "The master catalogue identifier cannot be altered once bound.",
                resolution: "Preserve original master linkage."
            }
        }
    }
) END;

IF !record::exists(error_definition:CATALOGUE_ITEM_SYNC_CANNOT_CONVERT_CUSTOM) THEN (
    CREATE error_definition:CATALOGUE_ITEM_SYNC_CANNOT_CONVERT_CUSTOM CONTENT {
        code: "CATALOGUE_ITEM_SYNC_CANNOT_CONVERT_CUSTOM",
        module: "catalogue",
        domain: "item",
        category: "authorization",
        severity: "error",
        message: "Un article synchronisé du Master ne peut pas être converti en article privé",
        default_language: "fr",
        http_status: 403,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Conversion en article privé interdite",
                description: "Un article rattaché au Master Catalogue ne peut pas devenir privé.",
                resolution: "Créez un nouvel article privé avec is_custom: true et master_id: NONE."
            },
            en: {
                label: "Cannot convert synced item to custom",
                description: "A synchronized master item cannot be changed into a private custom item.",
                resolution: "Create a separate custom item instead."
            }
        }
    }
) END;

IF !record::exists(error_definition:CATALOGUE_ITEM_SYNC_FIELD_PROTECTED) THEN (
    CREATE error_definition:CATALOGUE_ITEM_SYNC_FIELD_PROTECTED CONTENT {
        code: "CATALOGUE_ITEM_SYNC_FIELD_PROTECTED",
        module: "catalogue",
        domain: "item",
        category: "authorization",
        severity: "error",
        message: "Les spécifications maîtresses d'un article synchronisé ne peuvent être modifiées que par le flux Master officiel",
        default_language: "fr",
        http_status: 403,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Champ maître synchronisé protégé",
                description: "Les caractéristiques intrinsèques d'un article synchronisé (libellé officiel, fabricant, marque, code-barres, conditionnement, documents, disponibilité) ne sont modifiables que par synchronisation Master.",
                resolution: "Personnalisez l'article pour votre organisation (fn::catalogue_item_personnaliser : libellé, code interne, disponibilité) ou demandez la mise à jour au gestionnaire du Master Catalogue."
            },
            en: {
                label: "Synchronized master field is protected",
                description: "Intrinsic properties of a synchronized item (including availability) can only be modified by official Master sync.",
                resolution: "Customise the item for your organisation (fn::catalogue_item_personnaliser: label, internal code, availability) or update the master item in the central catalog."
            }
        }
    }
) END;

IF !record::exists(error_definition:CATALOGUE_ITEM_TENANT_REQUIRED) THEN (
    CREATE error_definition:CATALOGUE_ITEM_TENANT_REQUIRED CONTENT {
        code: "CATALOGUE_ITEM_TENANT_REQUIRED",
        module: "catalogue",
        domain: "item",
        category: "validation",
        severity: "error",
        message: "Identité cliente avec tenant_id valide obligatoire pour toute opération sur article privé",
        default_language: "fr",
        http_status: 400,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Propriétaire client obligatoire",
                description: "La création, modification ou suppression d'un article privé exige un tenant_id valide déduit de l'identité authentifiée.",
                resolution: "Authentifiez-vous avec une identité cliente valide contenant un tenant_id."
            },
            en: {
                label: "Tenant ID required",
                description: "Custom item operations require a valid authenticated tenant_id.",
                resolution: "Authenticate with a tenant account."
            }
        }
    }
) END;

IF !record::exists(error_definition:CATALOGUE_ITEM_TENANT_FORBIDDEN) THEN (
    CREATE error_definition:CATALOGUE_ITEM_TENANT_FORBIDDEN CONTENT {
        code: "CATALOGUE_ITEM_TENANT_FORBIDDEN",
        module: "catalogue",
        domain: "item",
        category: "authorization",
        severity: "error",
        message: "Accès ou opération interdite : cet article privé appartient à une autre organisation",
        default_language: "fr",
        http_status: 403,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Accès inter-organisations interdit",
                description: "Un locataire ne peut pas accéder, modifier ou supprimer les articles privés d'une autre entreprise.",
                resolution: "Vérifiez vos autorisations d'accès."
            },
            en: {
                label: "Tenant access forbidden",
                description: "Access to private items belonging to another organisation is strictly denied.",
                resolution: "Verify your organisation credentials."
            }
        }
    }
) END;

IF !record::exists(error_definition:CATALOGUE_ITEM_TENANT_ID_IMMUTABLE) THEN (
    CREATE error_definition:CATALOGUE_ITEM_TENANT_ID_IMMUTABLE CONTENT {
        code: "CATALOGUE_ITEM_TENANT_ID_IMMUTABLE",
        module: "catalogue",
        domain: "item",
        category: "authorization",
        severity: "error",
        message: "Le propriétaire tenant_id d'un article est strictement immuable",
        default_language: "fr",
        http_status: 403,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Propriétaire immuable",
                description: "Le champ tenant_id ne peut jamais être modifié après la création de l'article.",
                resolution: "La propriété d'un article ne peut pas être transférée."
            },
            en: {
                label: "Tenant ID immutable",
                description: "The tenant_id field cannot be altered once created.",
                resolution: "Item ownership cannot be transferred."
            }
        }
    }
) END;

IF !record::exists(error_definition:CATALOGUE_ITEM_TENANT_ORPHAN) THEN (
    CREATE error_definition:CATALOGUE_ITEM_TENANT_ORPHAN CONTENT {
        code: "CATALOGUE_ITEM_TENANT_ORPHAN",
        module: "catalogue",
        domain: "item",
        category: "validation",
        severity: "error",
        message: "Article privé orphelin sans propriétaire vérifiable : opération interdite",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Article privé orphelin",
                description: "Cet article privé ne possède aucun identifiant de propriétaire vérifiable en base.",
                resolution: "Contactez l'administrateur système pour réconciliation."
            },
            en: {
                label: "Orphan custom item",
                description: "This custom item has no verifiable tenant owner.",
                resolution: "Contact system administrator."
            }
        }
    }
) END;

IF !record::exists(error_definition:CATALOGUE_ITEM_SYNC_CANNOT_ACCESS_CUSTOM) THEN (
    CREATE error_definition:CATALOGUE_ITEM_SYNC_CANNOT_ACCESS_CUSTOM CONTENT {
        code: "CATALOGUE_ITEM_SYNC_CANNOT_ACCESS_CUSTOM",
        module: "catalogue",
        domain: "item",
        category: "authorization",
        severity: "error",
        message: "Le service catalogue_sync_agent ne doit pas lire, modifier ou supprimer les articles privés des clients",
        default_language: "fr",
        http_status: 403,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Accès agent sync interdit sur articles privés",
                description: "L'agent de synchronisation du Master Catalogue est strictement confiné aux articles maîtres.",
                resolution: "Le service de synchronisation ne traite que les flux de données maîtresses."
            },
            en: {
                label: "Sync agent cannot access custom items",
                description: "Master catalogue sync agent is strictly restricted to master items.",
                resolution: "Sync operations cannot target custom client items."
            }
        }
    }
) END;

IF !record::exists(error_definition:CATALOGUE_ITEM_SYNC_CANNOT_CREATE_CUSTOM) THEN (
    CREATE error_definition:CATALOGUE_ITEM_SYNC_CANNOT_CREATE_CUSTOM CONTENT {
        code: "CATALOGUE_ITEM_SYNC_CANNOT_CREATE_CUSTOM",
        module: "catalogue",
        domain: "item",
        category: "authorization",
        severity: "error",
        message: "Le service catalogue_sync_agent ne peut pas créer d'articles privés pour les clients",
        default_language: "fr",
        http_status: 403,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Création d'article privé interdite pour l'agent sync",
                description: "L'agent de synchronisation ne peut injecter que des articles maîtres (is_custom = false).",
                resolution: "Spécifiez is_custom = false pour les imports de l'agent de synchronisation."
            },
            en: {
                label: "Sync agent cannot create custom items",
                description: "Sync agent can only create master items.",
                resolution: "Use is_custom = false for sync imports."
            }
        }
    }
) END;

IF !record::exists(error_definition:CATALOGUE_ITEM_MASTER_CANNOT_BE_DELETED) THEN (
    CREATE error_definition:CATALOGUE_ITEM_MASTER_CANNOT_BE_DELETED CONTENT {
        code: "CATALOGUE_ITEM_MASTER_CANNOT_BE_DELETED",
        module: "catalogue",
        domain: "item",
        category: "authorization",
        severity: "error",
        message: "Les articles synchronisés du Master Catalogue ne peuvent pas être supprimés localement",
        default_language: "fr",
        http_status: 403,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Suppression d'article maître interdite",
                description: "Un article issu du Master Catalogue ne peut pas être supprimé localement. Utilisez la désactivation (enabled = false).",
                resolution: "Désactivez l'article localement au lieu de le supprimer."
            },
            en: {
                label: "Master item deletion forbidden",
                description: "Items synchronized from Master Catalogue cannot be deleted locally.",
                resolution: "Disable the item instead of deleting it."
            }
        }
    }
) END;

IF !record::exists(error_definition:CATALOGUE_ITEM_CUSTOM_CANNOT_HAVE_MASTER_ID) THEN (
    CREATE error_definition:CATALOGUE_ITEM_CUSTOM_CANNOT_HAVE_MASTER_ID CONTENT {
        code: "CATALOGUE_ITEM_CUSTOM_CANNOT_HAVE_MASTER_ID",
        module: "catalogue",
        domain: "item",
        category: "validation",
        severity: "error",
        message: "Un article privé ne peut pas avoir d'identifiant maître",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Identifiant maître interdit sur article privé",
                description: "Un article privé créé localement par un client ne peut pas référencer un master_id.",
                resolution: "Omettez master_id lors de la création d'articles privés."
            },
            en: {
                label: "Custom item cannot have master ID",
                description: "A private custom item cannot have a master_id.",
                resolution: "Omit master_id for custom items."
            }
        }
    }
) END;

IF !record::exists(error_definition:CATALOGUE_ITEM_CUSTOM_CANNOT_CONVERT_MASTER) THEN (
    CREATE error_definition:CATALOGUE_ITEM_CUSTOM_CANNOT_CONVERT_MASTER CONTENT {
        code: "CATALOGUE_ITEM_CUSTOM_CANNOT_CONVERT_MASTER",
        module: "catalogue",
        domain: "item",
        category: "authorization",
        severity: "error",
        message: "Un article privé ne peut pas être converti en article maître",
        default_language: "fr",
        http_status: 403,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Conversion en article maître interdite",
                description: "La nature privée d'un article local (is_custom = true) est immuable et ne peut être altérée.",
                resolution: "Créez un nouvel article via le flux Master officiel."
            },
            en: {
                label: "Cannot convert custom item to master",
                description: "A private custom item cannot be transformed into a master item.",
                resolution: "Create master items via the official Master pipeline."
            }
        }
    }
) END;

IF !record::exists(error_definition:CATALOGUE_ITEM_CODE_IMMUTABLE) THEN (
    CREATE error_definition:CATALOGUE_ITEM_CODE_IMMUTABLE CONTENT {
        code: "CATALOGUE_ITEM_CODE_IMMUTABLE",
        module: "catalogue",
        domain: "item",
        category: "conflict",
        severity: "error",
        message: "Le code d'un article ne peut pas être modifié",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Code d'article non modifiable",
                description: "Le code d'un article est son identifiant métier : il est fixé à la création.",
                resolution: "Créer un nouvel article si un autre code est nécessaire."
            },
            en: {
                label: "Item code is immutable",
                description: "The item code is set at creation and cannot change.",
                resolution: "Create a new item if another code is needed."
            }
        }
    }
) END;

IF !record::exists(error_definition:CATALOGUE_ITEM_TYPE_IMMUTABLE) THEN (
    CREATE error_definition:CATALOGUE_ITEM_TYPE_IMMUTABLE CONTENT {
        code: "CATALOGUE_ITEM_TYPE_IMMUTABLE",
        module: "catalogue",
        domain: "item",
        category: "conflict",
        severity: "error",
        message: "Le type d'un article ne peut pas être modifié",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Type d'article non modifiable",
                description: "Le type fondamental d'un article est fixé à la création.",
                resolution: "Créer un nouvel article du type voulu."
            },
            en: {
                label: "Item type is immutable",
                description: "The item type is set at creation and cannot change.",
                resolution: "Create a new item of the desired type."
            }
        }
    }
) END;

IF !record::exists(error_definition:CATALOGUE_ITEM_NATURE_IMMUTABLE) THEN (
    CREATE error_definition:CATALOGUE_ITEM_NATURE_IMMUTABLE CONTENT {
        code: "CATALOGUE_ITEM_NATURE_IMMUTABLE",
        module: "catalogue",
        domain: "item",
        category: "conflict",
        severity: "error",
        message: "La nature de référence d'un article ne peut pas être modifiée",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Nature de référence non modifiable",
                description: "La nature de référence (générique ou commerciale) est fixée à la création.",
                resolution: "Créer un nouvel article avec la nature voulue."
            },
            en: {
                label: "Item reference nature is immutable",
                description: "The reference nature is set at creation and cannot change.",
                resolution: "Create a new item with the desired nature."
            }
        }
    }
) END;

IF !record::exists(error_definition:CATALOGUE_ITEM_SYNC_CANNOT_CREATE_MASTER) THEN (
    CREATE error_definition:CATALOGUE_ITEM_SYNC_CANNOT_CREATE_MASTER CONTENT {
        code: "CATALOGUE_ITEM_SYNC_CANNOT_CREATE_MASTER",
        module: "catalogue",
        domain: "item",
        category: "authorization",
        severity: "error",
        message: "Seul l'agent de synchronisation peut créer un article maître",
        default_language: "fr",
        http_status: 403,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Création d'article maître refusée",
                description: "Un article maître ne peut être créé que par l'agent catalogue_sync_agent.",
                resolution: "Créer un article privé (is_custom) ou passer par la synchronisation du catalogue maître."
            },
            en: {
                label: "Master item creation refused",
                description: "Only the catalogue_sync_agent may create master items.",
                resolution: "Create a private item or use the master catalogue synchronisation."
            }
        }
    }
) END;

IF !record::exists(error_definition:CATALOGUE_PERSONNALISATION_ITEM_NOT_MASTER) THEN (
    CREATE error_definition:CATALOGUE_PERSONNALISATION_ITEM_NOT_MASTER CONTENT {
        code: "CATALOGUE_PERSONNALISATION_ITEM_NOT_MASTER",
        module: "catalogue",
        domain: "personnalisation",
        category: "validation",
        severity: "error",
        message: "Seul un article maître se personnalise",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Article non personnalisable",
                description: "Un article privé appartient déjà à son organisation : il ne se personnalise pas, il se modifie directement.",
                resolution: "Modifiez l'article privé avec fn::catalogue_item_update."
            },
            en: {
                label: "Item cannot be customised",
                description: "A private item already belongs to its organisation: it is not customised but edited directly.",
                resolution: "Edit the private item with fn::catalogue_item_update."
            }
        }
    }
) END;

IF !record::exists(error_definition:CATALOGUE_PERSONNALISATION_NOT_FOUND) THEN (
    CREATE error_definition:CATALOGUE_PERSONNALISATION_NOT_FOUND CONTENT {
        code: "CATALOGUE_PERSONNALISATION_NOT_FOUND",
        module: "catalogue",
        domain: "personnalisation",
        category: "not_found",
        severity: "error",
        message: "Aucune personnalisation de cet article pour votre organisation",
        default_language: "fr",
        http_status: 404,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Personnalisation introuvable",
                description: "Votre organisation n'a pas personnalisé cet article.",
                resolution: "Vérifiez l'article ; il est déjà affiché avec les valeurs du référentiel."
            },
            en: {
                label: "Customisation not found",
                description: "Your organisation has not customised this item.",
                resolution: "Check the item; it is already shown with the reference values."
            }
        }
    }
) END;
