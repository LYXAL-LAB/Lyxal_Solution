-- SPDX-License-Identifier: AGPL-3.0-only
-- ============================================================================
-- MASTER DATA : définitions d'erreurs de lyxal_mail, thème messages
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:MAIL_MESSAGE_NOT_FOUND) THEN (
    CREATE error_definition:MAIL_MESSAGE_NOT_FOUND CONTENT {
        code: "MAIL_MESSAGE_NOT_FOUND",
        module: "mail",
        domain: "messages",
        category: "not_found",
        severity: "error",
        message: "Message not found",
        default_language: "fr",
        http_status: 404,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Message introuvable",
                description: "Ce message n'existe pas ou n'est pas visible de votre session.",
                resolution: "Actualisez la liste des messages."
            },
            en: {
                label: "Message not found",
                description: "This message does not exist or is not visible to your session.",
                resolution: "Refresh the message list."
            }
        }
    }
) END;

IF !record::exists(error_definition:MAIL_MESSAGE_TOO_LARGE) THEN (
    CREATE error_definition:MAIL_MESSAGE_TOO_LARGE CONTENT {
        code: "MAIL_MESSAGE_TOO_LARGE",
        module: "mail",
        domain: "messages",
        category: "validation",
        severity: "error",
        message: "Message too large",
        default_language: "fr",
        http_status: 413,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Message trop volumineux",
                description: "Ce message dépasse la taille maximale acceptée.",
                resolution: "Réduisez le message ou ses pièces jointes."
            },
            en: {
                label: "Message too large",
                description: "This message exceeds the maximum accepted size.",
                resolution: "Reduce the message or its attachments."
            }
        }
    }
) END;

IF !record::exists(error_definition:MAIL_MESSAGE_MALFORMED) THEN (
    CREATE error_definition:MAIL_MESSAGE_MALFORMED CONTENT {
        code: "MAIL_MESSAGE_MALFORMED",
        module: "mail",
        domain: "messages",
        category: "validation",
        severity: "error",
        message: "Malformed message",
        default_language: "fr",
        http_status: 400,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Message illisible",
                description: "Le message n'a pas pu être lu (structure ou en-têtes absents ou hors limites).",
                resolution: "Vérifiez le message envoyé."
            },
            en: {
                label: "Malformed message",
                description: "The message could not be read (structure or headers missing or beyond limits).",
                resolution: "Check the message sent."
            }
        }
    }
) END;

IF !record::exists(error_definition:MAIL_MESSAGE_BATCH_TOO_LARGE) THEN (
    CREATE error_definition:MAIL_MESSAGE_BATCH_TOO_LARGE CONTENT {
        code: "MAIL_MESSAGE_BATCH_TOO_LARGE",
        module: "mail",
        domain: "messages",
        category: "validation",
        severity: "error",
        message: "Message batch too large",
        default_language: "fr",
        http_status: 400,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Lot trop grand",
                description: "Une opération porte sur 500 messages au plus.",
                resolution: "Découpez l'opération en plusieurs lots."
            },
            en: {
                label: "Batch too large",
                description: "An operation covers at most 500 messages.",
                resolution: "Split the operation into several batches."
            }
        }
    }
) END;

IF !record::exists(error_definition:MAIL_CHANGES_TOO_OLD) THEN (
    CREATE error_definition:MAIL_CHANGES_TOO_OLD CONTENT {
        code: "MAIL_CHANGES_TOO_OLD",
        module: "mail",
        domain: "messages",
        category: "business",
        severity: "error",
        message: "Changes too old to compute",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Synchronisation trop ancienne",
                description: "Les effacements antérieurs à ce point ne sont plus conservés.",
                resolution: "Refaites une synchronisation complète."
            },
            en: {
                label: "Changes too old",
                description: "Deletions before this point are no longer kept.",
                resolution: "Run a full synchronization again."
            }
        }
    }
) END;

IF !record::exists(error_definition:MAIL_KEYWORD_LIMIT) THEN (
    CREATE error_definition:MAIL_KEYWORD_LIMIT CONTENT {
        code: "MAIL_KEYWORD_LIMIT",
        module: "mail",
        domain: "messages",
        category: "validation",
        severity: "error",
        message: "Keyword limit reached",
        default_language: "fr",
        http_status: 400,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Trop de mots-clés",
                description: "Un message a atteint le nombre maximal de mots-clés.",
                resolution: "Retirez des mots-clés ou relevez la limite dans les réglages."
            },
            en: {
                label: "Too many keywords",
                description: "A message has reached the maximum number of keywords.",
                resolution: "Remove keywords or raise the limit in the settings."
            }
        }
    }
) END;
