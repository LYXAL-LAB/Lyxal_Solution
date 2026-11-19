-- lyxal-test: assertions
-- Plusieurs hôtes sur une base : abonnements rattachés à un hôte (fn::event_subscription_register),
-- ventilation qui recopie l'hôte, lecture par hôte (fn::event_delivery_fetch_pending), un bail par
-- hôte (fn::event_lease_*), garde et contrôle de propriété des écritures du chef
-- (fn::event_delivery_assign_seq, fn::event_flush_batch, fn::event_dead_letter_transfer),
-- changement d'hôte (fn::event_subscription_transfer) et attente par hôte (fn::event_backlog).
-- Cas nominaux, paramètres refusés, et identité sans droit (tables en PERMISSIONS NONE : une
-- session autre que la session système n'écrit ni ne lit rien).
-- Exécuté par scripts/ci/test_lyxal_modules.py (format en tête du script).
--
-- identité utilisateur: { "id": "user:tester", "sub": "user:tester", "iss": "lyxal-os" }

-- ---------------------------------------------------------------------------
-- Abonnements
-- ---------------------------------------------------------------------------

-- test: un abonnement est enregistré pour l'hôte qui porte son handler
RETURN fn::event_subscription_register({ name: "a_mail", target_module: "mod_mail", host: "host_a", event_pattern: "mail.received", handler_name: "mail.on_received" }).data.host == "host_a";

-- test: le même hôte réenregistre l'abonnement : mise à jour, sans doublon
RETURN fn::event_subscription_register({ name: "a_mail", target_module: "mod_mail", host: "host_a", event_pattern: "mail.received", handler_name: "mail.on_received", max_attempts: 3 }).data.max_attempts == 3
    AND count(SELECT * FROM event_subscription WHERE name = "a_mail") == 1;

-- test: un autre hôte qui réclame l'abonnement est refusé, l'abonnement reste à son hôte
RETURN fn::event_subscription_register({ name: "a_mail", target_module: "mod_mail", host: "host_b", event_pattern: "mail.received", handler_name: "mail.on_received" }).error.code == "EVENT_SUBSCRIPTION_HOST_CONFLICT"
    AND (SELECT VALUE host FROM ONLY event_subscription WHERE name = "a_mail" LIMIT 1) == "host_a";

-- test: l'hôte est obligatoire et au format d'un identifiant de module
RETURN fn::event_subscription_register({ name: "x", target_module: "mod_x", event_pattern: "x.y", handler_name: "x.h" }).error.details.fields.host != NONE
    AND fn::event_subscription_register({ name: "x", target_module: "mod_x", host: "Host-B", event_pattern: "x.y", handler_name: "x.h" }).error.code == "EVENT_INVALID_PARAMETERS"
    AND fn::event_subscription_register({ name: "x", target_module: "mod_x", host: string::repeat("a", 65), event_pattern: "x.y", handler_name: "x.h" }).error.code == "EVENT_INVALID_PARAMETERS"
    AND count(SELECT * FROM event_subscription WHERE name = "x") == 0;

-- test: une identité sans droit n'enregistre pas d'abonnement
-- en tant que: utilisateur
RETURN fn::event_subscription_register({ name: "pirate", target_module: "mod_x", host: "host_a", event_pattern: "x.y", handler_name: "x.h" }).error.code == "EVENT_WRITE_FORBIDDEN";

-- test: rien n'a été écrit par l'identité sans droit
RETURN count(SELECT * FROM event_subscription WHERE name = "pirate") == 0;

-- préparation: l'hôte B écoute le même type d'événement (abonnement propre)
RETURN fn::event_subscription_register({ name: "b_mail", target_module: "mod_booking", host: "host_b", event_pattern: "mail.received", handler_name: "booking.on_mail" });

-- ---------------------------------------------------------------------------
-- Ventilation et lecture par hôte
-- ---------------------------------------------------------------------------

-- test: chaque livraison porte l'hôte de son abonnement (même type écouté sur deux hôtes)
RETURN fn::event_publish({ event_id: rand::uuid::v7(), event_type: "mail.received", producer: "lyxal_test", payload: { n: 1 } }).ok
    AND (SELECT VALUE host FROM event_delivery ORDER BY host) == ["host_a", "host_b"]
    AND count(SELECT * FROM event_delivery WHERE host != subscription.host) == 0;

-- préparation: identifiants partagés par les tests suivants
CREATE essai:ids SET
    outbox = (SELECT VALUE id FROM ONLY event_outbox LIMIT 1),
    a_mail = (SELECT VALUE id FROM ONLY event_subscription WHERE name = "a_mail" LIMIT 1),
    b_mail = (SELECT VALUE id FROM ONLY event_subscription WHERE name = "b_mail" LIMIT 1),
    a_delivery = (SELECT VALUE id FROM ONLY event_delivery WHERE host = "host_a" LIMIT 1),
    b_delivery = (SELECT VALUE id FROM ONLY event_delivery WHERE host = "host_b" LIMIT 1);

-- test: une nouvelle ventilation ne crée rien (idempotence)
RETURN fn::event_fanout({ outbox_id: essai:ids.outbox }).data.deliveries_created == 0
    AND count(SELECT * FROM event_delivery) == 2;

-- test: le chef d'un hôte ne lit que les livraisons de son hôte
RETURN fn::event_delivery_fetch_pending({ host: "host_a" }).data.map(|$d| $d.id) == [essai:ids.a_delivery]
    AND fn::event_delivery_fetch_pending({ host: "host_b", limit: 10 }).data.map(|$d| $d.id) == [essai:ids.b_delivery]
    AND fn::event_delivery_fetch_pending({ host: "host_c" }).data == [];

-- test: la lecture sans hôte ou avec un hôte hors format est refusée
RETURN fn::event_delivery_fetch_pending({ limit: 10 }).error.details.fields.host != NONE
    AND fn::event_delivery_fetch_pending({ host: "Host A" }).error.code == "EVENT_INVALID_PARAMETERS";

-- test: une identité sans droit ne lit aucune livraison
-- en tant que: utilisateur
RETURN fn::event_delivery_fetch_pending({ host: "host_a" }).data == [];

-- ---------------------------------------------------------------------------
-- Un bail par hôte
-- ---------------------------------------------------------------------------

-- test: chaque hôte a son bail, dont l'identifiant est l'hôte
RETURN fn::event_lease_acquire({ host: "host_a", node_id: "a1", ttl_seconds: 60 }).data.generation == 1
    AND fn::event_lease_acquire({ host: "host_b", node_id: "b1", ttl_seconds: 60 }).data.acquired == true
    AND (SELECT VALUE host FROM event_stream_lease ORDER BY host) == ["host_a", "host_b"]
    AND event_stream_lease:host_a.owner_node_id == "a1";

-- test: un second nœud du même hôte n'obtient pas le bail
RETURN fn::event_lease_acquire({ host: "host_a", node_id: "a2", ttl_seconds: 60 }).data.acquired == false
    AND fn::event_lease_acquire({ host: "host_a", node_id: "a2", ttl_seconds: 60 }).data.owner_node_id == "a1";

-- test: seul le chef de l'hôte renouvelle son bail
RETURN fn::event_lease_renew({ host: "host_a", node_id: "a1", generation: 1, ttl_seconds: 60 }).data.renewed == true
    AND fn::event_lease_renew({ host: "host_a", node_id: "a2", generation: 1, ttl_seconds: 60 }).data.renewed == false
    AND fn::event_lease_renew({ host: "host_b", node_id: "a1", generation: 1, ttl_seconds: 60 }).data.renewed == false;

-- test: l'hôte est obligatoire pour les baux
RETURN fn::event_lease_acquire({ node_id: "a1" }).error.details.fields.host != NONE
    AND fn::event_lease_renew({ node_id: "a1", generation: 1 }).error.details.fields.host != NONE
    AND fn::event_lease_release({ node_id: "a1", generation: 1 }).error.details.fields.host != NONE;

-- test: une identité sans droit n'obtient aucun bail
-- en tant que: utilisateur
RETURN fn::event_lease_acquire({ host: "host_c", node_id: "pirate", ttl_seconds: 60 }).error.code == "EVENT_WRITE_FORBIDDEN";

-- test: aucun bail n'a été écrit par l'identité sans droit
RETURN record::exists(event_stream_lease:host_c) == false;

-- ---------------------------------------------------------------------------
-- Garde et propriété des écritures du chef
-- ---------------------------------------------------------------------------

-- test: le chef de A numérote la livraison de son abonnement
RETURN fn::event_delivery_assign_seq({ outbox_event: essai:ids.outbox, subscription: essai:ids.a_mail, target_module: "mod_mail", host: "host_a", node_id: "a1", generation: 1 }).data.delivery_seq == 1;

-- test: le chef de A ne numérote pas une livraison de l'abonnement de B
RETURN fn::event_delivery_assign_seq({ outbox_event: essai:ids.outbox, subscription: essai:ids.b_mail, target_module: "mod_booking", host: "host_a", node_id: "a1", generation: 1 }).error.code == "EVENT_SUBSCRIPTION_NOT_OWNED"
    AND essai:ids.b_delivery.delivery_seq == NONE
    AND essai:ids.b_delivery.status == "pending";

-- test: un nœud qui n'est pas le chef de l'hôte est refusé par la garde
-- attendu-erreur: EVENT_STALE_LEADER_FENCED
RETURN fn::event_delivery_assign_seq({ outbox_event: essai:ids.outbox, subscription: essai:ids.a_mail, target_module: "mod_mail", host: "host_a", node_id: "a2", generation: 1 });

-- test: le bail d'un autre hôte ne vaut pas garde (a1 n'est pas chef de host_b)
-- attendu-erreur: EVENT_STALE_LEADER_FENCED
RETURN fn::event_delivery_assign_seq({ outbox_event: essai:ids.outbox, subscription: essai:ids.b_mail, target_module: "mod_booking", host: "host_b", node_id: "a1", generation: 1 });

-- test: une identité sans droit est refusée par la garde
-- en tant que: utilisateur
-- attendu-erreur: EVENT_STALE_LEADER_FENCED
RETURN fn::event_flush_batch({ subscription: event_subscription:x, target_cursor: 0, host: "host_a", node_id: "a1", generation: 1 });

-- test: l'hôte est obligatoire pour les écritures du chef
RETURN fn::event_delivery_assign_seq({ outbox_event: essai:ids.outbox, subscription: essai:ids.a_mail, target_module: "mod_mail", node_id: "a1", generation: 1 }).error.details.fields.host != NONE
    AND fn::event_flush_batch({ subscription: essai:ids.a_mail, target_cursor: 1, node_id: "a1", generation: 1 }).error.details.fields.host != NONE
    AND fn::event_dead_letter_transfer({ delivery_id: essai:ids.a_delivery, error: "x", node_id: "a1", generation: 1 }).error.details.fields.host != NONE;

-- test: le chef de A solde sa livraison et avance le curseur de son abonnement
RETURN fn::event_flush_batch({ subscription: essai:ids.a_mail, target_cursor: 1, host: "host_a", node_id: "a1", generation: 1, delivered_ids: [essai:ids.a_delivery] }).data.persisted_cursor == 1
    AND fn::event_progress_get({ subscription: essai:ids.a_mail }).data.last_persisted_cursor == 1
    AND fn::event_delivery_get({ id: essai:ids.a_delivery }).data.status == "delivered";

-- test: le chef de A n'avance pas le curseur de l'abonnement de B
RETURN fn::event_flush_batch({ subscription: essai:ids.b_mail, target_cursor: 0, host: "host_a", node_id: "a1", generation: 1 }).error.code == "EVENT_SUBSCRIPTION_NOT_OWNED";

-- test: le chef de B numérote sa livraison
RETURN fn::event_delivery_assign_seq({ outbox_event: essai:ids.outbox, subscription: essai:ids.b_mail, target_module: "mod_booking", host: "host_b", node_id: "b1", generation: 1 }).data.delivery_seq == 1;

-- test: le chef de A ne met pas en dead letter une livraison de B
RETURN fn::event_dead_letter_transfer({ delivery_id: essai:ids.b_delivery, error: "poison", host: "host_a", node_id: "a1", generation: 1 }).error.code == "EVENT_SUBSCRIPTION_NOT_OWNED"
    AND count(SELECT * FROM event_dead_letter) == 0;

-- test: le chef de B met sa livraison en dead letter, puis avance son curseur
RETURN fn::event_dead_letter_transfer({ delivery_id: essai:ids.b_delivery, error: "poison", host: "host_b", node_id: "b1", generation: 1 }).data.dead_lettered == true
    AND fn::event_flush_batch({ subscription: essai:ids.b_mail, target_cursor: 1, host: "host_b", node_id: "b1", generation: 1, dead_letter_ids: [essai:ids.b_delivery] }).data.persisted_cursor == 1
    AND array::len(fn::event_dead_letter_list({ delivery: essai:ids.b_delivery }).data) == 1;

-- ---------------------------------------------------------------------------
-- Changement d'hôte d'un abonnement
-- ---------------------------------------------------------------------------

-- préparation: un deuxième événement, en attente pour les deux hôtes
RETURN fn::event_publish({ event_id: rand::uuid::v7(), event_type: "mail.received", producer: "lyxal_test", payload: { n: 2 } });

-- test: le changement d'hôte est refusé tant que le chef de l'ancien hôte est vivant
RETURN fn::event_subscription_transfer({ name: "b_mail", host: "host_a" }).error.code == "EVENT_HOST_ACTIVE"
    AND (SELECT VALUE host FROM ONLY event_subscription WHERE name = "b_mail" LIMIT 1) == "host_b";

-- test: un abonnement inconnu ou des paramètres invalides sont refusés
RETURN fn::event_subscription_transfer({ name: "inconnu", host: "host_a" }).error.code == "EVENT_SUBSCRIPTION_NOT_FOUND"
    AND fn::event_subscription_transfer({ name: "b_mail" }).error.code == "EVENT_INVALID_PARAMETERS"
    AND fn::event_subscription_transfer({ name: "b_mail", host: "Host A" }).error.code == "EVENT_INVALID_PARAMETERS"
    AND fn::event_subscription_transfer({ name: "b_mail", host: "host_a", inconnu: 1 }).error.code == "EVENT_INVALID_PARAMETERS";

-- test: une identité sans droit ne change pas l'hôte d'un abonnement
-- en tant que: utilisateur
RETURN fn::event_subscription_transfer({ name: "b_mail", host: "host_a" }).error.code == "EVENT_WRITE_FORBIDDEN";

-- test: l'arrêt propre du chef de B libère son bail
RETURN fn::event_lease_release({ host: "host_b", node_id: "b1", generation: 1 }).data.released == true
    AND event_stream_lease:host_b.is_released == true
    AND event_stream_lease:host_a.is_released == false;

-- test: l'ancien hôte arrêté, le changement d'hôte emporte les livraisons non soldées seulement
RETURN fn::event_subscription_transfer({ name: "b_mail", host: "host_a" }).data == { name: "b_mail", previous_host: "host_b", host: "host_a", deliveries: 1 }
    AND (SELECT VALUE host FROM ONLY event_subscription WHERE name = "b_mail" LIMIT 1) == "host_a"
    AND (SELECT VALUE host FROM event_delivery WHERE subscription = essai:ids.b_mail AND status = "pending") == ["host_a"]
    AND essai:ids.b_delivery.host == "host_b";

-- test: le même hôte demandé une seconde fois ne déplace rien
RETURN fn::event_subscription_transfer({ name: "b_mail", host: "host_a" }).data.deliveries == 0;

-- test: le rejeu de la dead letter rend la livraison à l'hôte courant de son abonnement
RETURN fn::event_dead_letter_replay({ dead_letter_id: type::record("event_dead_letter", "dlq_" + record::id(essai:ids.b_delivery)) }).data == true
    AND essai:ids.b_delivery.status == "pending"
    AND essai:ids.b_delivery.host == "host_a";

-- ---------------------------------------------------------------------------
-- Attente par hôte
-- ---------------------------------------------------------------------------

-- test: l'attente est donnée par hôte, avec l'état de son chef
RETURN fn::event_backlog({}).data.map(|$h| [$h.host, $h.pending, $h.waiting, $h.leader_alive, $h.leader_node]) == [["host_a", 3, 0, true, "a1"]];

-- préparation: l'hôte A s'arrête sans libérer son bail, ses livraisons vieillissent
UPDATE event_delivery SET created_at = time::now() - 10m WHERE host = "host_a";

-- préparation: le bail de A expire
UPDATE event_stream_lease:host_a SET expires_at = time::now() - 1s;

-- test: un hôte sans chef vivant montre ses livraisons anciennes
RETURN fn::event_backlog({ older_than: 5m }).data.map(|$h| [$h.host, $h.pending, $h.waiting, $h.leader_alive, $h.leader_node]) == [["host_a", 3, 3, false, NONE]]
    AND fn::event_backlog({ older_than: 5m }).data[0].oldest <= time::now() - 10m;

-- test: un seuil hors bornes ou d'un autre type est refusé
RETURN fn::event_backlog({ older_than: 0s }).error.code == "EVENT_INVALID_PARAMETERS"
    AND fn::event_backlog({ older_than: 31d }).error.code == "EVENT_INVALID_PARAMETERS"
    AND fn::event_backlog({ older_than: "bientôt" }).error.code == "EVENT_INVALID_PARAMETERS"
    AND fn::event_backlog({ inconnu: 1 }).error.code == "EVENT_INVALID_PARAMETERS";

-- test: une identité sans droit ne voit aucune attente
-- en tant que: utilisateur
RETURN fn::event_backlog({}).data == [];
