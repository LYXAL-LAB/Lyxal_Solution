-- lyxal-test: assertions
-- Abonnés : création et mise à jour (portée, unicité, adresse normalisée, identité liée), lecture,
-- recherche, import avec erreurs par ligne, permissions, événements sans donnée personnelle,
-- suppression des données personnelles (préférences et abonnements avec l'abonné, déclenchements
-- qui gardent l'adresse), reprise des préférences de l'invité par son compte.
--
-- identité admin: { "id": "auth_session:admin", "pv": 1, "permissions": ["notification.read", "notification.manage", "notification.send"] }
-- identité lecteur: { "id": "auth_session:lecteur", "pv": 1, "permissions": ["notification.read"] }
-- identité envoyeur: { "id": "auth_session:envoyeur", "pv": 1, "permissions": ["notification.send"] }
-- identité autre: { "id": "auth_session:autre", "pv": 1, "permissions": ["notification.read", "notification.manage", "notification.send"] }
-- identité membre: { "id": "auth_session:membre", "pv": 1, "permissions": [] }

-- préparation: organisations, identités et sessions ; parcours actif d'Alpha
{
    CREATE auth_organization:alpha CONTENT { slug: "alpha", name: "Alpha BTP" };
    CREATE auth_organization:beta CONTENT { slug: "beta", name: "Beta" };
    FOR $n IN ["admin", "lecteur", "envoyeur", "membre", "autre", "claire"] {
        CREATE type::record("auth_identity", $n) CONTENT { schema: auth_identity_schema:default_v1, traits: { email: string::concat($n, "@lyxal.test") } };
    };
    FOR $n IN ["admin", "lecteur", "envoyeur", "membre"] {
        RELATE (type::record("auth_identity", $n))->auth_member_of->auth_organization:alpha;
        CREATE type::record("auth_session", $n) CONTENT { identity: type::record("auth_identity", $n), organization: auth_organization:alpha, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    };
    RELATE auth_identity:autre->auth_member_of->auth_organization:beta;
    CREATE auth_session:autre CONTENT { identity: auth_identity:autre, organization: auth_organization:beta, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE notification_workflow:info_alpha CONTENT { tenant: auth_organization:alpha, key: "info", name: "Info", status: "active", steps: [{ key: "email", channel: "email" }] };
};

-- test: abonné créé dans sa portée ; adresse normalisée, identifiant conservé
-- en tant que: admin
{
    LET $r = fn::notification_subscriber_upsert({ tenant: "auth_organization:alpha", subscriber_id: "client-42", email: "Claire@Exemple.FR", first_name: "Claire", locale: "fr-FR", timezone: "Europe/Paris", phone: "+33612345678", data: { region: "nord" } }).data;
    RETURN $r.created AND $r.changed AND $r.subscriber.{ subscriber_id, email, scope_key, timezone, phone, data }
        == { subscriber_id: "client-42", email: "claire@exemple.fr", scope_key: "alpha", timezone: "Europe/Paris", phone: "+33612345678", data: { region: "nord" } };
};

-- test: seconde écriture : seuls les champs fournis changent ; une écriture identique ne change rien
-- en tant que: admin
{
    LET $a = fn::notification_subscriber_upsert({ tenant: "auth_organization:alpha", subscriber_id: "client-42", last_name: "Martin" }).data;
    LET $b = fn::notification_subscriber_upsert({ tenant: "auth_organization:alpha", subscriber_id: "client-42", last_name: "Martin" }).data;
    RETURN !$a.created AND $a.changed AND $a.subscriber.email == "claire@exemple.fr" AND $a.subscriber.last_name == "Martin"
        AND !$b.changed AND count(SELECT id FROM notification_subscriber WHERE subscriber_id = "client-42") == 1;
};

-- test: le même identifiant dans une autre organisation est un autre abonné
-- en tant que: autre
RETURN fn::notification_subscriber_upsert({ tenant: "auth_organization:beta", subscriber_id: "client-42", email: "c@beta.test" }).data.created
    AND count(SELECT id FROM notification_subscriber WHERE subscriber_id = "client-42") == 1;

-- test: entrées invalides : adresse, téléphone hors E.164, fuseau, langue, données trop volumineuses, identité d'un autre abonné
-- en tant que: admin
RETURN fn::notification_subscriber_upsert({ tenant: "auth_organization:alpha", subscriber_id: "x", email: "pas-une-adresse" }).error.code == "NOTIFICATION_INVALID_INPUT"
    AND fn::notification_subscriber_upsert({ tenant: "auth_organization:alpha", subscriber_id: "x", phone: "06 12 34 56 78" }).error.code == "NOTIFICATION_INVALID_INPUT"
    AND fn::notification_subscriber_upsert({ tenant: "auth_organization:alpha", subscriber_id: "x", timezone: "Paris" }).error.code == "NOTIFICATION_INVALID_INPUT"
    AND fn::notification_subscriber_upsert({ tenant: "auth_organization:alpha", subscriber_id: "x", locale: "pas une langue" }).error.code == "NOTIFICATION_INVALID_INPUT"
    AND fn::notification_subscriber_upsert({ tenant: "auth_organization:alpha", subscriber_id: "x", data: { blob: string::repeat("a", 9000) } }).error.code == "NOTIFICATION_INVALID_INPUT"
    AND fn::notification_subscriber_upsert({ tenant: "auth_organization:alpha", subscriber_id: "auth:admin", identity: "auth_identity:claire" }).error.code == "NOTIFICATION_INVALID_INPUT"
    AND fn::notification_subscriber_upsert({ tenant: "auth_organization:alpha", subscriber_id: "x", inconnu: 1 }).error.code == "NOTIFICATION_INVALID_INPUT"
    AND fn::notification_subscriber_upsert({ tenant: "auth_organization:alpha", email: "a@exemple.fr" }).error.code == "NOTIFICATION_INVALID_INPUT";

-- test: champs d'un abonné et enregistrement interne (abonné absent exigé)
RETURN object::keys(fn::notification_subscriber_fields({})) == ["data", "email", "first_name", "identity", "last_name", "locale", "phone", "subscriber_id", "timezone"]
    AND fn::notification_subscriber_save({ tenant: auth_organization:alpha, input: { subscriber_id: "absent" }, must_exist: true }).code == "NOTIFICATION_SUBSCRIBER_NOT_FOUND"
    AND fn::notification_subscriber_find({ tenant: auth_organization:alpha, subscriber_id: "client-42" }).email == "claire@exemple.fr"
    AND fn::notification_subscriber_find({ subscriber_id: "client-42" }) IS NONE;

-- test: lecture et recherche (identifiant, adresse, nom), sans permission refusées
-- en tant que: lecteur
RETURN fn::notification_subscriber_get({ tenant: "auth_organization:alpha", subscriber_id: "client-42" }).data.{ email, topics } == { email: "claire@exemple.fr", topics: [] }
    AND fn::notification_subscriber_get({ tenant: "auth_organization:alpha", subscriber_id: "inconnu" }).error.code == "NOTIFICATION_SUBSCRIBER_NOT_FOUND"
    AND fn::notification_subscriber_list({ tenant: "auth_organization:alpha", search: "MARTIN" }).data.subscriber_id == ["client-42"]
    AND fn::notification_subscriber_list({ tenant: "auth_organization:alpha", search: "exemple.fr" }).data.subscriber_id == ["client-42"]
    AND fn::notification_subscriber_list({ tenant: "auth_organization:alpha", search: "zzz" }).data == []
    AND fn::notification_subscriber_upsert({ tenant: "auth_organization:alpha", subscriber_id: "y", email: "y@exemple.fr" }).error.code == "NOTIFICATION_PERMISSION_DENIED"
    AND fn::notification_subscriber_delete({ tenant: "auth_organization:alpha", subscriber_id: "client-42" }).error.code == "NOTIFICATION_PERMISSION_DENIED";

-- test: une organisation ne lit ni ne gère les abonnés d'une autre ; un membre sans permission non plus
-- en tant que: autre
RETURN fn::notification_subscriber_get({ tenant: "auth_organization:alpha", subscriber_id: "client-42" }).error.code == "NOTIFICATION_PERMISSION_DENIED"
    AND fn::notification_subscriber_list({ tenant: "auth_organization:alpha" }).error.code == "NOTIFICATION_PERMISSION_DENIED"
    AND fn::notification_subscriber_upsert({ tenant: "auth_organization:alpha", subscriber_id: "intrus" }).error.code == "NOTIFICATION_PERMISSION_DENIED"
    AND count(SELECT id FROM notification_subscriber WHERE scope_key = "alpha") == 0;

-- test: un membre sans permission ne voit aucun abonné
-- en tant que: membre
RETURN fn::notification_subscriber_list({ tenant: "auth_organization:alpha" }).error.code == "NOTIFICATION_PERMISSION_DENIED"
    AND count(SELECT id FROM notification_subscriber) == 0;

-- test: import : lignes créées, mises à jour, inchangées et refusées, sans arrêter l'import
-- en tant que: admin
{
    LET $r = fn::notification_subscriber_import({ tenant: "auth_organization:alpha", subscribers: [
        { subscriber_id: "imp-1", email: "imp1@exemple.fr" },
        { subscriber_id: "imp-2", email: "pas-une-adresse" },
        { subscriber_id: "client-42", first_name: "Claire-Marie" },
        { subscriber_id: "imp-3", email: "imp3@exemple.fr", inconnu: true },
        { subscriber_id: "client-42", first_name: "Claire-Marie" },
        "pas un objet"
    ] }).data;
    RETURN $r.created == 1 AND $r.updated == 1 AND $r.unchanged == 1
        AND $r.rejected.index == [1, 3, 5] AND $r.rejected.code == ["NOTIFICATION_INVALID_INPUT", "NOTIFICATION_INVALID_INPUT", "NOTIFICATION_INVALID_INPUT"]
        AND $r.rejected[0].fields.email IS NOT NONE;
};

-- test: import de plus de 500 abonnés refusé ; import sans permission refusé
-- en tant que: admin
RETURN fn::notification_subscriber_import({ tenant: "auth_organization:alpha", subscribers: array::map(<array>(0..501), |$i| { subscriber_id: <string> $i }) }).error.code == "NOTIFICATION_IMPORT_TOO_LARGE"
    AND fn::notification_subscriber_import({ tenant: "auth_organization:alpha", subscribers: "x" }).error.code == "NOTIFICATION_INVALID_INPUT";

-- test: qui déclenche ne peut pas importer
-- en tant que: envoyeur
RETURN fn::notification_subscriber_import({ tenant: "auth_organization:alpha", subscribers: [{ subscriber_id: "z" }] }).error.code == "NOTIFICATION_PERMISSION_DENIED";

-- test: déclenchement à la volée par qui déclenche : abonné créé puis mis à jour ; un identifiant seul doit exister ; sans adresse refusé
-- en tant que: envoyeur
{
    LET $a = fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "info", idempotency_key: "v-1", to: { subscriber_id: "volee", email: "volee@exemple.fr" } }).data;
    LET $b = fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "info", idempotency_key: "v-2", to: { subscriber_id: "volee", first_name: "Vol" } }).data;
    LET $c = fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "info", idempotency_key: "v-3", to: { subscriber_id: "fantome" } });
    LET $d = fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "info", idempotency_key: "v-4", to: { subscriber_id: "sans-adresse", first_name: "Sans" } });
    RETURN $a.kind == "subscriber" AND $a.status == "created" AND $b.status == "created" AND $a.subscriber == $b.subscriber
        AND (SELECT VALUE first_name FROM ONLY $b.subscriber) == "Vol"
        AND $c.error.code == "NOTIFICATION_SUBSCRIBER_NOT_FOUND"
        AND $d.error.code == "NOTIFICATION_SUBSCRIBER_NO_ADDRESS" AND count(SELECT id FROM notification_run WHERE idempotency_key = "v-4") == 0;
};

-- test: événements des abonnés : identifiants seulement, jamais l'adresse ni le nom
RETURN count(SELECT id FROM event_outbox WHERE event_type = "notification.subscriber.created") >= 4
    AND count(SELECT id FROM event_outbox WHERE event_type = "notification.subscriber.updated") >= 2
    AND (SELECT VALUE payload FROM event_outbox WHERE event_type IN ["notification.subscriber.created", "notification.subscriber.updated"])
        .all(|$p| object::keys($p) == ["identity_id", "subscriber_id", "tenant"] OR object::keys($p) == ["subscriber_id", "tenant"])
    AND !string::contains(<string> (SELECT VALUE payload FROM event_outbox WHERE string::starts_with(event_type, "notification.subscriber")), "@");

-- préparation: préférence, abonnement à un sujet et déclenchement de client-42
{
    LET $s = (SELECT VALUE id FROM ONLY notification_subscriber WHERE scope_key = "alpha" AND subscriber_id = "client-42" LIMIT 1);
    CREATE notification_topic:chantier CONTENT { tenant: auth_organization:alpha, key: "chantier", name: "Chantier" };
    CREATE notification_topic_member CONTENT { topic: notification_topic:chantier, subscriber: $s };
    CREATE notification_preference CONTENT { tenant: auth_organization:alpha, level: "subscriber_global", subscriber: $s, channels: { email: true } };
    fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "info", idempotency_key: "rgpd-1", to: { subscriber_id: "client-42" } });
};

-- test: suppression d'un abonné : préférences et abonnements supprimés ; le déclenchement garde l'adresse utilisée
-- en tant que: admin
{
    LET $r = fn::notification_subscriber_delete({ tenant: "auth_organization:alpha", subscriber_id: "client-42" });
    RETURN $r.ok AND fn::notification_subscriber_delete({ tenant: "auth_organization:alpha", subscriber_id: "client-42" }).error.code == "NOTIFICATION_SUBSCRIBER_NOT_FOUND";
};

-- test: après suppression : plus de préférence ni d'abonnement ; déclenchement sans abonné, adresse conservée ; événement de suppression
RETURN count(SELECT id FROM notification_preference) == 0
    AND count(SELECT id FROM notification_topic_member) == 0
    AND (SELECT VALUE [subscriber, address.email] FROM ONLY notification_run WHERE idempotency_key = "rgpd-1" LIMIT 1) == [NONE, "claire@exemple.fr"]
    AND count(SELECT id FROM event_outbox WHERE event_type = "notification.subscriber.deleted") == 1;

-- préparation: Claire, invitée sans compte (abonné email:), a coupé l'e-mail ; puis son compte est créé
{
    LET $guest = fn::notification_subscriber_save({ tenant: auth_organization:alpha, input: { subscriber_id: "email:claire@lyxal.test", email: "claire@lyxal.test" }, must_exist: false }).subscriber;
    CREATE notification_preference CONTENT { tenant: auth_organization:alpha, level: "subscriber_global", subscriber: $guest.id, channels: { email: false } };
};

-- test: son abonné auth:<identité> reprend les préférences de l'abonné email: ; identité liée
{
    LET $saved = fn::notification_subscriber_save({ tenant: auth_organization:alpha, input: { subscriber_id: "auth:claire", identity: auth_identity:claire, email: "Claire@Lyxal.test" }, must_exist: false });
    RETURN $saved.created AND $saved.subscriber.identity == auth_identity:claire
        AND (SELECT VALUE channels FROM notification_preference WHERE subscriber = $saved.subscriber.id) == [{ email: false }];
};

-- test: le compte supprimé emporte son abonné auth:
{
    DELETE auth_identity:claire;
    RETURN count(SELECT id FROM notification_subscriber WHERE subscriber_id = "auth:claire") == 0
        AND count(SELECT id FROM notification_subscriber WHERE subscriber_id = "email:claire@lyxal.test") == 1;
};
