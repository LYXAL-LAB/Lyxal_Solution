-- ============================================================================
-- SEEDS : réglages et tâches de lyxal_scheduler
-- MODULE : lyxal_infra
-- ============================================================================
-- Rejouable et non destructif : chaque fiche est créée seulement si elle n'existe pas (un réglage
-- modifié par l'administrateur n'est jamais écrasé). Les planifications (infra.tick chaque minute,
-- infra.purge chaque jour) sont créées par le module de l'hôte à l'installation (lot 1b) ; les
-- tâches handler ne sont réservées que par un nœud qui a leur code (lyxal-server).

IF !record::exists(infra_settings:installation) THEN (
    CREATE infra_settings:installation CONTENT {
        reconcile_minutes: 15,
        default_ttl: 3600,
        min_ttl: 60,
        max_deletions: 10,
        max_deletion_percent: 30,
        verify_timeout_hours: 24,
        requests_per_second: 5,
        change_retention_days: 400,
        released_retention_days: 30
    }
) END;

-- Une passe de réconciliation d'une zone (argument zone : clé opaque infra_zone:…), mise en file
-- par une déclaration, une demande de l'administrateur ou infra.tick ; unique par zone pendant
-- une minute.
IF !record::exists(scheduler_task:⟨infra.zone_reconcile⟩) THEN (
    CREATE scheduler_task:⟨infra.zone_reconcile⟩ CONTENT {
        module: "lyxal_infra",
        executor: "handler",
        target: "infra.zone_reconcile",
        permission: "infra.worker",
        args_schema: { fields: {
            zone: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 128 } }], required: true }
        }, unknown_keys: "reject" },
        queue: scheduler_queue:default,
        priority: 4,
        retry: { max_attempts: 3, strategy: "exponential", initial_delay: 30s, max_delay: 5m },
        timeout: 5m,
        unique_for: 1m,
        scope: "installation",
        state: "active",
        description: { fr: "Passe de réconciliation d'une zone DNS : lecture chez l'hébergeur, plan, écriture des seuls enregistrements de Lyxal, vérification", en: "DNS zone reconciliation pass: read at the provider, plan, write Lyxal's own records only, verification" },
        created_at: time::now(),
        updated_at: time::now()
    }
) END;

-- Passage périodique : comptes à essayer, zones échues (une passe mise en file pour chacune),
-- vérifications de publication dues.
IF !record::exists(scheduler_task:⟨infra.tick⟩) THEN (
    CREATE scheduler_task:⟨infra.tick⟩ CONTENT {
        module: "lyxal_infra",
        executor: "handler",
        target: "infra.tick",
        permission: "infra.worker",
        args_schema: NONE,
        queue: scheduler_queue:default,
        priority: 5,
        retry: { max_attempts: 1, strategy: "exponential", initial_delay: 30s, max_delay: 30s },
        timeout: 2m,
        unique_for: NONE,
        scope: "installation",
        state: "active",
        description: { fr: "Passage périodique du pilotage de l'hébergeur : essais des comptes, zones échues, vérifications de publication", en: "Periodic provider control pass: account tests, due zones, publication checks" },
        created_at: time::now(),
        updated_at: time::now()
    }
) END;

IF !record::exists(scheduler_task:⟨infra.purge⟩) THEN (
    CREATE scheduler_task:⟨infra.purge⟩ CONTENT {
        module: "lyxal_infra",
        executor: "function",
        target: "infra_purge",
        permission: "infra.worker",
        args_schema: { fields: {
            limit: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 10000 } }] }
        }, unknown_keys: "reject" },
        queue: scheduler_queue:default,
        priority: 7,
        retry: { max_attempts: 3, strategy: "exponential", initial_delay: 1m, max_delay: 30m },
        timeout: 10m,
        unique_for: NONE,
        scope: "installation",
        state: "active",
        description: { fr: "Purge du pilotage de l'hébergeur : journal au-delà de sa conservation (dernière entrée de chaque zone gardée), enregistrements retirés", en: "Provider control purge: change log beyond its retention (last entry of each zone kept), released records" },
        created_at: time::now(),
        updated_at: time::now()
    }
) END;
