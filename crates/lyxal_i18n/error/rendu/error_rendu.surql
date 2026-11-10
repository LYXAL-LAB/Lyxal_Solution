-- ============================================================================
-- MASTER DATA : définitions d'erreurs de lyxal_i18n, thème rendu
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================
-- Codes renvoyés par le rendu Rust (FormatError::code).

IF !record::exists(error_definition:I18N_MESSAGE_INVALID) THEN (
    CREATE error_definition:I18N_MESSAGE_INVALID CONTENT {
        code: "I18N_MESSAGE_INVALID",
        module: "i18n",
        domain: "rendu",
        category: "validation",
        severity: "error",
        message: "Invalid message",
        default_language: "fr",
        http_status: 400,
        retryable: false,
        enabled: true,
        translations: {
            fr: { label: "Message invalide", description: "Le texte ne respecte pas la syntaxe des messages ou utilise un élément non pris en charge.", resolution: "Corrigez le texte de la traduction." },
            en: { label: "Invalid message", description: "The text does not follow the message syntax or uses an unsupported element.", resolution: "Fix the translation text." }
        }
    }
) END;

IF !record::exists(error_definition:I18N_ARGUMENT_MISSING) THEN (
    CREATE error_definition:I18N_ARGUMENT_MISSING CONTENT {
        code: "I18N_ARGUMENT_MISSING",
        module: "i18n",
        domain: "rendu",
        category: "validation",
        severity: "error",
        message: "Missing message argument",
        default_language: "fr",
        http_status: 400,
        retryable: false,
        enabled: true,
        translations: {
            fr: { label: "Argument manquant", description: "Une valeur attendue par le texte n'a pas été fournie.", resolution: "Fournissez toutes les valeurs des paramètres de la clé." },
            en: { label: "Missing argument", description: "A value expected by the text was not provided.", resolution: "Provide every value of the key's parameters." }
        }
    }
) END;

IF !record::exists(error_definition:I18N_ARGUMENT_TYPE) THEN (
    CREATE error_definition:I18N_ARGUMENT_TYPE CONTENT {
        code: "I18N_ARGUMENT_TYPE",
        module: "i18n",
        domain: "rendu",
        category: "validation",
        severity: "error",
        message: "Wrong message argument type",
        default_language: "fr",
        http_status: 400,
        retryable: false,
        enabled: true,
        translations: {
            fr: { label: "Argument du mauvais type", description: "Une valeur fournie n'a pas le type attendu par le texte.", resolution: "Fournissez un texte, un nombre ou une date selon le paramètre." },
            en: { label: "Wrong argument type", description: "A provided value does not have the type expected by the text.", resolution: "Provide a text, a number or a date as the parameter requires." }
        }
    }
) END;

IF !record::exists(error_definition:I18N_LOCALE_UNSUPPORTED) THEN (
    CREATE error_definition:I18N_LOCALE_UNSUPPORTED CONTENT {
        code: "I18N_LOCALE_UNSUPPORTED",
        module: "i18n",
        domain: "rendu",
        category: "validation",
        severity: "error",
        message: "Unsupported locale",
        default_language: "fr",
        http_status: 400,
        retryable: false,
        enabled: true,
        translations: {
            fr: { label: "Langue non prise en charge", description: "L'étiquette de langue n'est pas lisible.", resolution: "Utilisez une étiquette de langue valide, par exemple fr ou fr-CA." },
            en: { label: "Unsupported language", description: "The language tag cannot be read.", resolution: "Use a valid language tag, for example fr or fr-CA." }
        }
    }
) END;

IF !record::exists(error_definition:I18N_TIMEZONE_UNKNOWN) THEN (
    CREATE error_definition:I18N_TIMEZONE_UNKNOWN CONTENT {
        code: "I18N_TIMEZONE_UNKNOWN",
        module: "i18n",
        domain: "rendu",
        category: "validation",
        severity: "error",
        message: "Unknown time zone",
        default_language: "fr",
        http_status: 400,
        retryable: false,
        enabled: true,
        translations: {
            fr: { label: "Fuseau horaire inconnu", description: "Le fuseau horaire demandé n'existe pas dans la base des fuseaux.", resolution: "Utilisez un identifiant comme Europe/Paris." },
            en: { label: "Unknown time zone", description: "The requested time zone does not exist in the time zone database.", resolution: "Use an identifier such as Europe/Paris." }
        }
    }
) END;

IF !record::exists(error_definition:I18N_CURRENCY_UNKNOWN) THEN (
    CREATE error_definition:I18N_CURRENCY_UNKNOWN CONTENT {
        code: "I18N_CURRENCY_UNKNOWN",
        module: "i18n",
        domain: "rendu",
        category: "validation",
        severity: "error",
        message: "Unknown currency",
        default_language: "fr",
        http_status: 400,
        retryable: false,
        enabled: true,
        translations: {
            fr: { label: "Monnaie inconnue", description: "Le code de monnaie n'a pas la forme attendue.", resolution: "Utilisez un code à trois lettres majuscules, par exemple EUR." },
            en: { label: "Unknown currency", description: "The currency code does not have the expected form.", resolution: "Use a three-letter uppercase code, for example EUR." }
        }
    }
) END;

IF !record::exists(error_definition:I18N_NUMBER_INVALID) THEN (
    CREATE error_definition:I18N_NUMBER_INVALID CONTENT {
        code: "I18N_NUMBER_INVALID",
        module: "i18n",
        domain: "rendu",
        category: "validation",
        severity: "error",
        message: "Invalid number",
        default_language: "fr",
        http_status: 400,
        retryable: false,
        enabled: true,
        translations: {
            fr: { label: "Nombre invalide", description: "La valeur fournie n'est pas un nombre décimal.", resolution: "Fournissez un nombre comme 1234.56." },
            en: { label: "Invalid number", description: "The provided value is not a decimal number.", resolution: "Provide a number such as 1234.56." }
        }
    }
) END;
