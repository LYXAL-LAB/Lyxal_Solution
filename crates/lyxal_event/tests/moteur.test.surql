-- lyxal-test: assertions
-- Fonctions du moteur sans lien direct avec les hôtes : reprise des ventilations
-- (fn::event_recover_pending_fanouts), échec transitoire (fn::event_delivery_failure), lecture
-- d'un événement (fn::event_outbox_get) et purge (fn::event_purge_garbage). La ventilation
-- reprise recopie l'hôte de l'abonnement sur la livraison.
-- Exécuté par scripts/ci/test_lyxal_modules.py (format en tête du script).
--
-- identité utilisateur: { "id": "user:tester", "sub": "user:tester", "iss": "lyxal-os" }

-- préparation: un abonnement de l'hôte A
RETURN fn::event_subscription_register({ name: "a_task", target_module: "mod_task", host: "host_a", event_pattern: "task.*", handler_name: "task.on_any" });

-- test: un événement publié sans ventilation immédiate reste en attente, sans livraison
RETURN fn::event_publish({ event_id: rand::uuid::v7(), event_type: "task.assigned", producer: "lyxal_test", payload: { n: 1 }, auto_fanout: false }).data.status == "pending"
    AND count(SELECT * FROM event_delivery) == 0;

-- test: la reprise ventile l'événement en attente, pour l'hôte de l'abonnement
RETURN fn::event_recover_pending_fanouts({ limit: 10 }).data.recovered_count == 1
    AND (SELECT VALUE host FROM event_delivery) == ["host_a"]
    AND (SELECT VALUE status FROM event_outbox) == ["fanned_out"];

-- test: une limite hors bornes est refusée
RETURN fn::event_recover_pending_fanouts({ limit: 0 }).error.code == "EVENT_INVALID_PARAMETERS";

-- test: l'événement se relit par son identifiant
RETURN fn::event_outbox_get({ id: (SELECT VALUE id FROM ONLY event_outbox LIMIT 1) }).data.event_type == "task.assigned"
    AND fn::event_outbox_get({ id: "pas_un_id" }).error.code == "EVENT_INVALID_PARAMETERS";

-- test: un échec transitoire est enregistré avec la date du prochain essai
RETURN fn::event_delivery_failure({ delivery_id: (SELECT VALUE id FROM ONLY event_delivery LIMIT 1), error: "service indisponible", retry_delay_seconds: 60 }).data == true
    AND (SELECT VALUE status FROM ONLY event_delivery LIMIT 1) == "failed"
    AND (SELECT VALUE next_retry_at FROM ONLY event_delivery LIMIT 1) > time::now() + 30s;

-- test: une livraison en retry futur n'est pas lue par le chef de son hôte
RETURN fn::event_delivery_fetch_pending({ host: "host_a" }).data == [];

-- test: un échec sur une livraison inconnue est refusé
RETURN fn::event_delivery_failure({ delivery_id: event_delivery:inconnue, error: "x" }).error.code == "EVENT_DELIVERY_NOT_FOUND";

-- test: la purge garde les livraisons non soldées et leur événement
RETURN fn::event_purge_garbage({ retention_days: 1 }).data == true
    AND count(SELECT * FROM event_delivery) == 1
    AND count(SELECT * FROM event_outbox) == 1;

-- test: une rétention hors bornes est refusée
RETURN fn::event_purge_garbage({ retention_days: 0 }).error.code == "EVENT_INVALID_PARAMETERS";

-- test: une identité sans droit ne publie rien
-- en tant que: utilisateur
RETURN fn::event_publish({ event_id: rand::uuid::v7(), event_type: "task.assigned", producer: "lyxal_test" }).error.code == "EVENT_WRITE_FORBIDDEN";
