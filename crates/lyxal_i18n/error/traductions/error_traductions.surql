-- ============================================================================
-- MASTER DATA : définitions d'erreurs de lyxal_i18n, thème traductions
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:I18N_NAMESPACE_NOT_FOUND) THEN (
    CREATE error_definition:I18N_NAMESPACE_NOT_FOUND CONTENT {
        code: "I18N_NAMESPACE_NOT_FOUND",
        module: "i18n",
        domain: "traductions",
        category: "not_found",
        severity: "warning",
        message: "Namespace not found",
        default_language: "fr",
        http_status: 404,
        retryable: false,
        enabled: true,
        translations: {
            fr: { label: "Espace de noms inconnu", description: "Cet espace de noms n'existe pas.", resolution: "Créez l'espace de noms ou corrigez sa clé." },
            en: { label: "Unknown namespace", description: "This namespace does not exist.", resolution: "Create the namespace or fix its key." }
        }
    }
) END;

IF !record::exists(error_definition:I18N_NAMESPACE_EXISTS) THEN (
    CREATE error_definition:I18N_NAMESPACE_EXISTS CONTENT {
        code: "I18N_NAMESPACE_EXISTS",
        module: "i18n",
        domain: "traductions",
        category: "conflict",
        severity: "warning",
        message: "Namespace already exists",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: { label: "Espace de noms existant", description: "Un espace de noms porte déjà cette clé.", resolution: "Choisissez une autre clé." },
            en: { label: "Namespace already exists", description: "A namespace already has this key.", resolution: "Choose another key." }
        }
    }
) END;

IF !record::exists(error_definition:I18N_KEY_NOT_FOUND) THEN (
    CREATE error_definition:I18N_KEY_NOT_FOUND CONTENT {
        code: "I18N_KEY_NOT_FOUND",
        module: "i18n",
        domain: "traductions",
        category: "not_found",
        severity: "warning",
        message: "Translation key not found",
        default_language: "fr",
        http_status: 404,
        retryable: false,
        enabled: true,
        translations: {
            fr: { label: "Clé inconnue", description: "Cette clé de traduction n'est pas déclarée.", resolution: "Déclarez la clé ou corrigez son nom." },
            en: { label: "Unknown key", description: "This translation key is not declared.", resolution: "Declare the key or fix its name." }
        }
    }
) END;

IF !record::exists(error_definition:I18N_KEY_EXISTS) THEN (
    CREATE error_definition:I18N_KEY_EXISTS CONTENT {
        code: "I18N_KEY_EXISTS",
        module: "i18n",
        domain: "traductions",
        category: "conflict",
        severity: "warning",
        message: "Translation key already exists",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: { label: "Clé existante", description: "Cette clé de traduction existe déjà.", resolution: "Modifiez la clé existante ou choisissez un autre nom." },
            en: { label: "Key already exists", description: "This translation key already exists.", resolution: "Edit the existing key or choose another name." }
        }
    }
) END;

IF !record::exists(error_definition:I18N_TRANSLATION_NOT_FOUND) THEN (
    CREATE error_definition:I18N_TRANSLATION_NOT_FOUND CONTENT {
        code: "I18N_TRANSLATION_NOT_FOUND",
        module: "i18n",
        domain: "traductions",
        category: "not_found",
        severity: "warning",
        message: "Translation not found",
        default_language: "fr",
        http_status: 404,
        retryable: false,
        enabled: true,
        translations: {
            fr: { label: "Traduction absente", description: "Aucun texte n'existe pour cette clé dans cette langue et cette portée.", resolution: "Écrivez d'abord le texte." },
            en: { label: "Translation not found", description: "No text exists for this key in this language and scope.", resolution: "Write the text first." }
        }
    }
) END;

IF !record::exists(error_definition:I18N_TRANSLATION_INVALID) THEN (
    CREATE error_definition:I18N_TRANSLATION_INVALID CONTENT {
        code: "I18N_TRANSLATION_INVALID",
        module: "i18n",
        domain: "traductions",
        category: "validation",
        severity: "error",
        message: "Invalid translation text",
        default_language: "fr",
        http_status: 400,
        retryable: false,
        enabled: true,
        translations: {
            fr: { label: "Texte invalide", description: "Le texte ne respecte pas les paramètres ou les règles de la clé.", resolution: "Corrigez les problèmes signalés (paramètres, pluriels, accolades, longueur)." },
            en: { label: "Invalid text", description: "The text does not match the key's parameters or rules.", resolution: "Fix the reported problems (parameters, plurals, braces, length)." }
        }
    }
) END;

IF !record::exists(error_definition:I18N_TRANSLATION_OUTDATED) THEN (
    CREATE error_definition:I18N_TRANSLATION_OUTDATED CONTENT {
        code: "I18N_TRANSLATION_OUTDATED",
        module: "i18n",
        domain: "traductions",
        category: "conflict",
        severity: "warning",
        message: "Translation is outdated",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: { label: "Traduction à revoir", description: "Le texte source a changé depuis cette traduction.", resolution: "Mettez la traduction à jour avant de la marquer relue." },
            en: { label: "Outdated translation", description: "The source text changed since this translation.", resolution: "Update the translation before marking it reviewed." }
        }
    }
) END;

IF !record::exists(error_definition:I18N_SOURCE_REQUIRED) THEN (
    CREATE error_definition:I18N_SOURCE_REQUIRED CONTENT {
        code: "I18N_SOURCE_REQUIRED",
        module: "i18n",
        domain: "traductions",
        category: "business",
        severity: "warning",
        message: "Source text is required",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: { label: "Texte source obligatoire", description: "Le texte source d'une clé ne peut pas être supprimé.", resolution: "Modifiez le texte source ou supprimez la clé." },
            en: { label: "Source text required", description: "The source text of a key cannot be deleted.", resolution: "Edit the source text or delete the key." }
        }
    }
) END;
