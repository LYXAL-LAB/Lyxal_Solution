-- SPDX-License-Identifier: AGPL-3.0-only
-- ============================================================================
-- MASTER DATA : définitions d'erreurs de lyxal_mail, thème file d'envoi
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:MAIL_QUEUE_CLAIM_LOST) THEN (
    CREATE error_definition:MAIL_QUEUE_CLAIM_LOST CONTENT {
        code: "MAIL_QUEUE_CLAIM_LOST",
        module: "mail",
        domain: "file",
        category: "conflict",
        severity: "error",
        message: "Queue claim lost",
        default_language: "fr",
        http_status: 409,
        retryable: true,
        enabled: true,
        translations: {
            fr: {
                label: "Réservation perdue",
                description: "Le jeton de réservation est périmé ou son bail est échu : le destinataire a pu être repris par un autre nœud.",
                resolution: "Abandonnez ce destinataire sans rien écrire et relisez la file."
            },
            en: {
                label: "Queue claim lost",
                description: "The claim token is stale or its lease has expired: the recipient may have been taken by another node.",
                resolution: "Drop this recipient without writing anything and read the queue again."
            }
        }
    }
) END;

IF !record::exists(error_definition:MAIL_QUEUE_BATCH_TOO_LARGE) THEN (
    CREATE error_definition:MAIL_QUEUE_BATCH_TOO_LARGE CONTENT {
        code: "MAIL_QUEUE_BATCH_TOO_LARGE",
        module: "mail",
        domain: "file",
        category: "validation",
        severity: "error",
        message: "Queue batch too large",
        default_language: "fr",
        http_status: 400,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Lot trop grand",
                description: "Le lot du worker d'envoi dépasse sa borne.",
                resolution: "Découpez le lot."
            },
            en: {
                label: "Queue batch too large",
                description: "The batch of the outbound worker exceeds its bound.",
                resolution: "Split the batch."
            }
        }
    }
) END;
