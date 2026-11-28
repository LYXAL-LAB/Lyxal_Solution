-- ============================================================================
-- MASTER DATA : définitions d'erreurs de lyxal_infra, thème enregistrements
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- ============================================================================

IF !record::exists(error_definition:INFRA_RECORD_NOT_FOUND) THEN (
    CREATE error_definition:INFRA_RECORD_NOT_FOUND CONTENT {
        code: "INFRA_RECORD_NOT_FOUND",
        module: "infra",
        domain: "enregistrements",
        category: "not_found",
        severity: "error",
        message: "Record not found",
        default_language: "fr",
        http_status: 404,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Enregistrement introuvable",
                description: "L'enregistrement voulu demandé n'existe pas, ou n'est pas dans l'état attendu.",
                resolution: "Vérifiez l'identifiant et l'état de l'enregistrement."
            },
            en: {
                label: "Record not found",
                description: "The requested desired record does not exist, or is not in the expected state.",
                resolution: "Check the record identifier and state."
            }
        }
    }
) END;

IF !record::exists(error_definition:INFRA_RECORD_OWNED) THEN (
    CREATE error_definition:INFRA_RECORD_OWNED CONTENT {
        code: "INFRA_RECORD_OWNED",
        module: "infra",
        domain: "enregistrements",
        category: "conflict",
        severity: "error",
        message: "Name and type owned by another declarer",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Nom déjà pris",
                description: "Ce nom et ce type sont déjà déclarés en mode exclusif par un autre propriétaire (ou le seraient).",
                resolution: "Déclarez en mode partagé, ou retirez l'autre déclaration."
            },
            en: {
                label: "Name already owned",
                description: "This name and type are already declared exclusively by another owner (or would be).",
                resolution: "Declare in shared mode, or release the other declaration."
            }
        }
    }
) END;

IF !record::exists(error_definition:INFRA_RECORD_SINGLETON_TAKEN) THEN (
    CREATE error_definition:INFRA_RECORD_SINGLETON_TAKEN CONTENT {
        code: "INFRA_RECORD_SINGLETON_TAKEN",
        module: "infra",
        domain: "enregistrements",
        category: "conflict",
        severity: "error",
        message: "Unique TXT prefix already held by another declarer",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Préfixe unique déjà tenu",
                description: "Un TXT de ce nom portant ce préfixe unique (par exemple v=spf1) est déjà déclaré par un autre propriétaire ou sujet : deux valeurs casseraient le service.",
                resolution: "Déclarez la valeur auprès du propriétaire actuel, ou retirez d'abord l'autre déclaration."
            },
            en: {
                label: "Unique prefix already held",
                description: "A TXT record of this name with this unique prefix (for example v=spf1) is already declared by another owner or subject: two values would break the service.",
                resolution: "Declare the value through the current owner, or release the other declaration first."
            }
        }
    }
) END;

IF !record::exists(error_definition:INFRA_RECORD_CNAME_CONFLICT) THEN (
    CREATE error_definition:INFRA_RECORD_CNAME_CONFLICT CONTENT {
        code: "INFRA_RECORD_CNAME_CONFLICT",
        module: "infra",
        domain: "enregistrements",
        category: "conflict",
        severity: "error",
        message: "CNAME cannot coexist with other records",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "CNAME en conflit",
                description: "Un CNAME ne cohabite avec aucun autre enregistrement du même nom.",
                resolution: "Retirez le CNAME ou les autres enregistrements de ce nom."
            },
            en: {
                label: "CNAME conflict",
                description: "A CNAME cannot coexist with any other record of the same name.",
                resolution: "Remove the CNAME or the other records of this name."
            }
        }
    }
) END;

IF !record::exists(error_definition:INFRA_RECORD_TENANT_REFUSED) THEN (
    CREATE error_definition:INFRA_RECORD_TENANT_REFUSED CONTENT {
        code: "INFRA_RECORD_TENANT_REFUSED",
        module: "infra",
        domain: "enregistrements",
        category: "authorization",
        severity: "error",
        message: "Zone does not accept this organization",
        default_language: "fr",
        http_status: 403,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Organisation refusée",
                description: "La zone qui couvre ce nom n'accepte pas les déclarations de cette organisation.",
                resolution: "Demandez à l'administrateur de la plateforme d'ajouter l'organisation à la zone."
            },
            en: {
                label: "Organization refused",
                description: "The zone covering this name does not accept declarations from this organization.",
                resolution: "Ask the platform administrator to add the organization to the zone."
            }
        }
    }
) END;

IF !record::exists(error_definition:INFRA_RECORD_LIMIT) THEN (
    CREATE error_definition:INFRA_RECORD_LIMIT CONTENT {
        code: "INFRA_RECORD_LIMIT",
        module: "infra",
        domain: "enregistrements",
        category: "validation",
        severity: "error",
        message: "Too many records in one declaration",
        default_language: "fr",
        http_status: 400,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Trop d'enregistrements",
                description: "Une déclaration porte 50 enregistrements au plus.",
                resolution: "Découpez la déclaration en plusieurs sujets."
            },
            en: {
                label: "Too many records",
                description: "A declaration carries 50 records at most.",
                resolution: "Split the declaration into several subjects."
            }
        }
    }
) END;
