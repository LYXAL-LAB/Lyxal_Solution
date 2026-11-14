-- ============================================================================
-- MASTER DATA : définitions d'erreurs de lyxal_secrets, thème acces
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:SECRETS_GRANT_NOT_FOUND) THEN (
    CREATE error_definition:SECRETS_GRANT_NOT_FOUND CONTENT {
        code: "SECRETS_GRANT_NOT_FOUND",
        module: "secrets",
        domain: "acces",
        category: "not_found",
        severity: "error",
        message: "Access not found",
        default_language: "fr",
        http_status: 404,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Accès introuvable",
                description: "Cet accès temporaire n'existe pas ou n'est pas visible avec vos droits.",
                resolution: "Vérifiez l'identifiant de l'accès."
            },
            en: {
                label: "Access not found",
                description: "This temporary access does not exist or is not visible with your permissions.",
                resolution: "Check the access identifier."
            }
        }
    }
) END;

IF !record::exists(error_definition:SECRETS_GRANT_INVALID) THEN (
    CREATE error_definition:SECRETS_GRANT_INVALID CONTENT {
        code: "SECRETS_GRANT_INVALID",
        module: "secrets",
        domain: "acces",
        category: "validation",
        severity: "error",
        message: "Invalid access",
        default_language: "fr",
        http_status: 400,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Accès invalide",
                description: "L'accès demandé n'est pas valable : bénéficiaire absent ou double, durée trop longue, ou accès déjà retiré.",
                resolution: "Indiquez un seul bénéficiaire et une durée dans la limite permise (réglages et protection du chemin)."
            },
            en: {
                label: "Invalid access",
                description: "The requested access is not valid: missing or double subject, duration too long, or access already revoked.",
                resolution: "Give a single subject and a duration within the allowed limit (settings and path protection)."
            }
        }
    }
) END;

IF !record::exists(error_definition:SECRETS_REQUEST_NOT_FOUND) THEN (
    CREATE error_definition:SECRETS_REQUEST_NOT_FOUND CONTENT {
        code: "SECRETS_REQUEST_NOT_FOUND",
        module: "secrets",
        domain: "acces",
        category: "not_found",
        severity: "error",
        message: "Request not found",
        default_language: "fr",
        http_status: 404,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Demande introuvable",
                description: "Cette demande n'existe pas ou n'est pas visible avec vos droits.",
                resolution: "Vérifiez l'identifiant de la demande."
            },
            en: {
                label: "Request not found",
                description: "This request does not exist or is not visible with your permissions.",
                resolution: "Check the request identifier."
            }
        }
    }
) END;

IF !record::exists(error_definition:SECRETS_REQUEST_STATE_INVALID) THEN (
    CREATE error_definition:SECRETS_REQUEST_STATE_INVALID CONTENT {
        code: "SECRETS_REQUEST_STATE_INVALID",
        module: "secrets",
        domain: "acces",
        category: "conflict",
        severity: "error",
        message: "Invalid request state",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "État de demande incompatible",
                description: "Cette action ne correspond pas à l'état de la demande (pas encore approuvée, déjà close, ou valeur proposée absente).",
                resolution: "Relisez la demande ; un changement s'applique une fois approuvé, ou en urgence avec le droit dédié."
            },
            en: {
                label: "Invalid request state",
                description: "This action does not match the request state (not yet approved, already closed, or proposed value missing).",
                resolution: "Read the request again; a change is applied once approved, or in an emergency with the dedicated permission."
            }
        }
    }
) END;

IF !record::exists(error_definition:SECRETS_REQUEST_SELF_APPROVAL) THEN (
    CREATE error_definition:SECRETS_REQUEST_SELF_APPROVAL CONTENT {
        code: "SECRETS_REQUEST_SELF_APPROVAL",
        module: "secrets",
        domain: "acces",
        category: "authorization",
        severity: "error",
        message: "Self-approval forbidden",
        default_language: "fr",
        http_status: 403,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Approbation de sa propre demande interdite",
                description: "Personne ne peut approuver ni refuser sa propre demande.",
                resolution: "Un autre gestionnaire des accès doit se prononcer."
            },
            en: {
                label: "Self-approval forbidden",
                description: "No one may approve or reject their own request.",
                resolution: "Another access manager must decide."
            }
        }
    }
) END;

IF !record::exists(error_definition:SECRETS_REQUEST_ALREADY_DECIDED) THEN (
    CREATE error_definition:SECRETS_REQUEST_ALREADY_DECIDED CONTENT {
        code: "SECRETS_REQUEST_ALREADY_DECIDED",
        module: "secrets",
        domain: "acces",
        category: "conflict",
        severity: "error",
        message: "Request already decided",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Demande déjà tranchée",
                description: "Cette demande n'attend plus de décision (approuvée, refusée, annulée ou expirée), ou vous l'avez déjà approuvée.",
                resolution: "Consultez l'état de la demande."
            },
            en: {
                label: "Request already decided",
                description: "This request no longer awaits a decision (approved, rejected, cancelled or expired), or you already approved it.",
                resolution: "Check the request state."
            }
        }
    }
) END;

IF !record::exists(error_definition:SECRETS_CHANGE_IN_PROGRESS) THEN (
    CREATE error_definition:SECRETS_CHANGE_IN_PROGRESS CONTENT {
        code: "SECRETS_CHANGE_IN_PROGRESS",
        module: "secrets",
        domain: "acces",
        category: "conflict",
        severity: "error",
        message: "Change request already open",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Demande de changement déjà ouverte",
                description: "Une demande de changement est déjà ouverte sur ce secret : une seule à la fois.",
                resolution: "Attendez qu'elle soit appliquée, refusée ou annulée."
            },
            en: {
                label: "Change request already open",
                description: "A change request is already open on this secret: only one at a time.",
                resolution: "Wait until it is applied, rejected or cancelled."
            }
        }
    }
) END;

IF !record::exists(error_definition:SECRETS_APPROVAL_REQUIRED) THEN (
    CREATE error_definition:SECRETS_APPROVAL_REQUIRED CONTENT {
        code: "SECRETS_APPROVAL_REQUIRED",
        module: "secrets",
        domain: "acces",
        category: "authorization",
        severity: "error",
        message: "Approval required",
        default_language: "fr",
        http_status: 403,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Approbation requise",
                description: "Ce secret est protégé : ce changement passe par une demande approuvée.",
                resolution: "Proposez le changement (fn::secrets_request_change), faites-le approuver, puis appliquez-le."
            },
            en: {
                label: "Approval required",
                description: "This secret is protected: this change requires an approved request.",
                resolution: "Propose the change (fn::secrets_request_change), have it approved, then apply it."
            }
        }
    }
) END;

IF !record::exists(error_definition:SECRETS_POLICY_NOT_FOUND) THEN (
    CREATE error_definition:SECRETS_POLICY_NOT_FOUND CONTENT {
        code: "SECRETS_POLICY_NOT_FOUND",
        module: "secrets",
        domain: "acces",
        category: "not_found",
        severity: "error",
        message: "Protection not found",
        default_language: "fr",
        http_status: 404,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Protection introuvable",
                description: "Aucune protection ne couvre ce chemin pour cette opération, ou la protection demandée n'existe pas.",
                resolution: "Écrivez directement si le secret n'est pas protégé, ou vérifiez l'identifiant de la protection."
            },
            en: {
                label: "Protection not found",
                description: "No protection covers this path for this operation, or the requested protection does not exist.",
                resolution: "Write directly if the secret is not protected, or check the protection identifier."
            }
        }
    }
) END;
