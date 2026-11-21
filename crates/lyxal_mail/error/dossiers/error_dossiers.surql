-- SPDX-License-Identifier: AGPL-3.0-only
-- ============================================================================
-- MASTER DATA : définitions d'erreurs de lyxal_mail, thème dossiers
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:MAIL_MAILBOX_NOT_FOUND) THEN (
    CREATE error_definition:MAIL_MAILBOX_NOT_FOUND CONTENT {
        code: "MAIL_MAILBOX_NOT_FOUND",
        module: "mail",
        domain: "dossiers",
        category: "not_found",
        severity: "error",
        message: "Mailbox not found",
        default_language: "fr",
        http_status: 404,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Dossier introuvable",
                description: "Ce dossier n'existe pas ou n'est pas visible de votre session.",
                resolution: "Vérifiez le dossier choisi."
            },
            en: {
                label: "Mailbox not found",
                description: "This mailbox does not exist or is not visible to your session.",
                resolution: "Check the selected mailbox."
            }
        }
    }
) END;

IF !record::exists(error_definition:MAIL_MAILBOX_EXISTS) THEN (
    CREATE error_definition:MAIL_MAILBOX_EXISTS CONTENT {
        code: "MAIL_MAILBOX_EXISTS",
        module: "mail",
        domain: "dossiers",
        category: "conflict",
        severity: "error",
        message: "Mailbox already exists",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Dossier déjà présent",
                description: "Un dossier porte déjà ce nom à cet endroit (INBOX est réservé).",
                resolution: "Choisissez un autre nom."
            },
            en: {
                label: "Mailbox already exists",
                description: "A mailbox already has this name at this place (INBOX is reserved).",
                resolution: "Choose another name."
            }
        }
    }
) END;

IF !record::exists(error_definition:MAIL_MAILBOX_HAS_CHILDREN) THEN (
    CREATE error_definition:MAIL_MAILBOX_HAS_CHILDREN CONTENT {
        code: "MAIL_MAILBOX_HAS_CHILDREN",
        module: "mail",
        domain: "dossiers",
        category: "conflict",
        severity: "error",
        message: "Mailbox has children",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Dossier parent",
                description: "Ce dossier contient des sous-dossiers.",
                resolution: "Supprimez ou déplacez d'abord ses sous-dossiers."
            },
            en: {
                label: "Mailbox has children",
                description: "This mailbox contains sub-mailboxes.",
                resolution: "Delete or move its sub-mailboxes first."
            }
        }
    }
) END;

IF !record::exists(error_definition:MAIL_MAILBOX_NOT_EMPTY) THEN (
    CREATE error_definition:MAIL_MAILBOX_NOT_EMPTY CONTENT {
        code: "MAIL_MAILBOX_NOT_EMPTY",
        module: "mail",
        domain: "dossiers",
        category: "conflict",
        severity: "error",
        message: "Mailbox not empty",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Dossier non vide",
                description: "Ce dossier contient encore des messages.",
                resolution: "Videz le dossier, ou demandez la suppression de ses messages."
            },
            en: {
                label: "Mailbox not empty",
                description: "This mailbox still contains messages.",
                resolution: "Empty the mailbox, or ask for its messages to be removed."
            }
        }
    }
) END;

IF !record::exists(error_definition:MAIL_MAILBOX_TOO_LARGE) THEN (
    CREATE error_definition:MAIL_MAILBOX_TOO_LARGE CONTENT {
        code: "MAIL_MAILBOX_TOO_LARGE",
        module: "mail",
        domain: "dossiers",
        category: "business",
        severity: "error",
        message: "Mailbox too large to delete at once",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Dossier trop volumineux",
                description: "Ce dossier contient trop de messages pour être supprimé en une fois.",
                resolution: "Effacez ses messages par lots, puis supprimez le dossier."
            },
            en: {
                label: "Mailbox too large",
                description: "This mailbox holds too many messages to be deleted at once.",
                resolution: "Expunge its messages in batches, then delete the mailbox."
            }
        }
    }
) END;

IF !record::exists(error_definition:MAIL_MAILBOX_PROTECTED) THEN (
    CREATE error_definition:MAIL_MAILBOX_PROTECTED CONTENT {
        code: "MAIL_MAILBOX_PROTECTED",
        module: "mail",
        domain: "dossiers",
        category: "business",
        severity: "error",
        message: "Mailbox protected",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Dossier protégé",
                description: "La boîte de réception ne se supprime, ne se renomme ni ne se déplace.",
                resolution: "Choisissez un autre dossier."
            },
            en: {
                label: "Protected mailbox",
                description: "The inbox cannot be deleted, renamed or moved.",
                resolution: "Choose another mailbox."
            }
        }
    }
) END;

IF !record::exists(error_definition:MAIL_MAILBOX_ROLE_TAKEN) THEN (
    CREATE error_definition:MAIL_MAILBOX_ROLE_TAKEN CONTENT {
        code: "MAIL_MAILBOX_ROLE_TAKEN",
        module: "mail",
        domain: "dossiers",
        category: "conflict",
        severity: "error",
        message: "Mailbox role already used",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Rôle déjà attribué",
                description: "Un autre dossier du compte a déjà ce rôle.",
                resolution: "Retirez d'abord le rôle de l'autre dossier."
            },
            en: {
                label: "Role already used",
                description: "Another mailbox of the account already has this role.",
                resolution: "Remove the role from the other mailbox first."
            }
        }
    }
) END;

IF !record::exists(error_definition:MAIL_MAILBOX_LIMIT) THEN (
    CREATE error_definition:MAIL_MAILBOX_LIMIT CONTENT {
        code: "MAIL_MAILBOX_LIMIT",
        module: "mail",
        domain: "dossiers",
        category: "business",
        severity: "error",
        message: "Mailbox limit reached",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Trop de dossiers",
                description: "Ce compte a atteint le nombre maximal de dossiers.",
                resolution: "Supprimez un dossier ou relevez la limite dans les réglages."
            },
            en: {
                label: "Too many mailboxes",
                description: "This account has reached the maximum number of mailboxes.",
                resolution: "Delete a mailbox or raise the limit in the settings."
            }
        }
    }
) END;

IF !record::exists(error_definition:MAIL_MAILBOX_UID_EXHAUSTED) THEN (
    CREATE error_definition:MAIL_MAILBOX_UID_EXHAUSTED CONTENT {
        code: "MAIL_MAILBOX_UID_EXHAUSTED",
        module: "mail",
        domain: "dossiers",
        category: "business",
        severity: "error",
        message: "Mailbox UID space exhausted",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Dossier saturé",
                description: "Ce dossier a épuisé ses numéros de messages (UID) et n'accepte plus aucun message.",
                resolution: "Créez un nouveau dossier et déplacez-y les messages."
            },
            en: {
                label: "Mailbox exhausted",
                description: "This mailbox has used up its message numbers (UID) and accepts no more messages.",
                resolution: "Create a new mailbox and move the messages into it."
            }
        }
    }
) END;
