-- lyxal-test: assertions
-- Sujets (création, clé unique, modification, lecture, liste, suppression), abonnements avec
-- condition lyxal_core (contrôlée à l'enregistrement), retrait ; catégories de désabonnement
-- (portée, catégories de l'installation, suppression refusée si un parcours l'utilise) ;
-- permissions et isolation entre organisations ; événements des abonnements.
--
-- identité admin: { "id": "auth_session:admin", "pv": 1, "permissions": ["notification.read", "notification.manage", "notification.send"] }
-- identité lecteur: { "id": "auth_session:lecteur", "pv": 1, "permissions": ["notification.read"] }
-- identité autre: { "id": "auth_session:autre", "pv": 1, "permissions": ["notification.read", "notification.manage", "notification.send"] }
-- identité membre: { "id": "auth_session:membre", "pv": 1, "permissions": [] }
-- identité plateforme: { "id": "auth_session:plateforme", "pv": 1, "permissions": ["notification.installation.manage"] }

-- préparation: organisations, identités, sessions, abonnés d'Alpha
{
    CREATE auth_organization:alpha CONTENT { slug: "alpha", name: "Alpha BTP" };
    CREATE auth_organization:beta CONTENT { slug: "beta", name: "Beta" };
    FOR $n IN ["admin", "lecteur", "membre", "autre", "plateforme"] {
        CREATE type::record("auth_identity", $n) CONTENT { schema: auth_identity_schema:default_v1, traits: { email: string::concat($n, "@lyxal.test") } };
    };
    FOR $n IN ["admin", "lecteur", "membre"] {
        RELATE (type::record("auth_identity", $n))->auth_member_of->auth_organization:alpha;
        CREATE type::record("auth_session", $n) CONTENT { identity: type::record("auth_identity", $n), organization: auth_organization:alpha, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    };
    RELATE auth_identity:autre->auth_member_of->auth_organization:beta;
    CREATE auth_session:autre CONTENT { identity: auth_identity:autre, organization: auth_organization:beta, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_session:plateforme CONTENT { identity: auth_identity:plateforme, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    FOR $n IN ["a", "b", "c"] {
        fn::notification_subscriber_save({ tenant: auth_organization:alpha, input: { subscriber_id: $n, email: string::concat($n, "@exemple.fr") }, must_exist: false });
    };
};

-- test: sujet créé ; clé unique dans sa portée ; clé invalide refusée
-- en tant que: admin
RETURN fn::notification_topic_create({ tenant: "auth_organization:alpha", key: "chantier_nord", name: "Chantier nord", description: "Équipe nord" }).data.{ key, scope_key } == { key: "chantier_nord", scope_key: "alpha" }
    AND fn::notification_topic_create({ tenant: "auth_organization:alpha", key: "chantier_nord", name: "Doublon" }).error.code == "NOTIFICATION_TOPIC_KEY_TAKEN"
    AND fn::notification_topic_create({ tenant: "auth_organization:alpha", key: "Pas Snake", name: "X" }).error.code == "NOTIFICATION_INVALID_INPUT";

-- test: la même clé dans une autre organisation est acceptée ; une organisation ne crée rien chez une autre
-- en tant que: autre
RETURN fn::notification_topic_create({ tenant: "auth_organization:beta", key: "chantier_nord", name: "Beta" }).ok
    AND fn::notification_topic_create({ tenant: "auth_organization:alpha", key: "intrus", name: "X" }).error.code == "NOTIFICATION_PERMISSION_DENIED"
    AND fn::notification_topic_get({ tenant: "auth_organization:alpha", key: "chantier_nord" }).error.code == "NOTIFICATION_PERMISSION_DENIED";

-- test: modification et recherche interne du sujet
-- en tant que: admin
RETURN fn::notification_topic_update({ tenant: "auth_organization:alpha", key: "chantier_nord", name: "Chantier Nord", data: { site: 12 } }).data.{ name, description, data } == { name: "Chantier Nord", description: "Équipe nord", data: { site: 12 } }
    AND fn::notification_topic_update({ tenant: "auth_organization:alpha", key: "absent", name: "X" }).error.code == "NOTIFICATION_TOPIC_NOT_FOUND"
    AND fn::notification_topic_find({ tenant: auth_organization:alpha, key: "chantier_nord" }).name == "Chantier Nord";

-- test: abonnements : abonnés existants ajoutés, inconnus signalés ; condition invalide refusée
-- en tant que: admin
{
    LET $r = fn::notification_topic_subscribe({ tenant: "auth_organization:alpha", key: "chantier_nord", subscribers: ["a", "b", "inconnu"] }).data;
    LET $bad = fn::notification_topic_subscribe({ tenant: "auth_organization:alpha", key: "chantier_nord", subscribers: ["c"], condition: { field: "payload.x", op: "regex", value: "." } });
    RETURN $r == { added: 2, updated: 0, unchanged: 0, not_found: ["inconnu"] }
        AND $bad.error.code == "NOTIFICATION_CONDITION_INVALID" AND $bad.error.details == { path: "$", reason: "unknown_operator" };
};

-- test: condition ajoutée à un abonnement existant et à un nouvel abonnement ; réécriture identique sans effet
-- en tant que: admin
{
    LET $condition = { all: [{ field: "payload.priority", op: "gte", value: 2 }, { field: "subscriber.data.region", op: "eq", value: "nord" }] };
    LET $r = fn::notification_topic_subscribe({ tenant: "auth_organization:alpha", key: "chantier_nord", subscribers: ["b", "c"], condition: $condition }).data;
    LET $again = fn::notification_topic_subscribe({ tenant: "auth_organization:alpha", key: "chantier_nord", subscribers: ["c"], condition: $condition }).data;
    RETURN $r.{ added, updated } == { added: 1, updated: 1 } AND $again.unchanged == 1;
};

-- test: lecture : nombre d'abonnés, liste des abonnés avec leur condition, liste des sujets ; lecteur autorisé
-- en tant que: lecteur
RETURN fn::notification_topic_get({ tenant: "auth_organization:alpha", key: "chantier_nord" }).data.members == 3
    AND fn::notification_topic_members({ tenant: "auth_organization:alpha", key: "chantier_nord" }).data.map(|$m| [$m.subscriber_id, $m.condition IS NOT NONE]) == [["a", false], ["b", true], ["c", true]]
    AND fn::notification_topic_list({ tenant: "auth_organization:alpha" }).data.key == ["chantier_nord"]
    AND fn::notification_topic_subscribe({ tenant: "auth_organization:alpha", key: "chantier_nord", subscribers: ["a"] }).error.code == "NOTIFICATION_PERMISSION_DENIED";

-- test: entrées invalides : plus de 100 abonnés, liste vide, sujet inconnu
-- en tant que: admin
RETURN fn::notification_topic_subscribe({ tenant: "auth_organization:alpha", key: "chantier_nord", subscribers: array::map(<array>(0..101), |$i| <string> $i) }).error.code == "NOTIFICATION_INVALID_INPUT"
    AND fn::notification_topic_subscribe({ tenant: "auth_organization:alpha", key: "chantier_nord", subscribers: [] }).error.code == "NOTIFICATION_INVALID_INPUT"
    AND fn::notification_topic_subscribe({ tenant: "auth_organization:alpha", key: "absent", subscribers: ["a"] }).error.code == "NOTIFICATION_TOPIC_NOT_FOUND"
    AND fn::notification_topic_members({ tenant: "auth_organization:alpha", key: "absent" }).error.code == "NOTIFICATION_TOPIC_NOT_FOUND";

-- test: retrait d'abonnés ; absent signalé
-- en tant que: admin
RETURN fn::notification_topic_unsubscribe({ tenant: "auth_organization:alpha", key: "chantier_nord", subscribers: ["a", "inconnu"] }).data == { removed: 1, not_found: ["inconnu"] }
    AND fn::notification_topic_members({ tenant: "auth_organization:alpha", key: "chantier_nord" }).data.subscriber_id == ["b", "c"];

-- test: événements d'abonnement et de retrait : identifiants seulement
RETURN count(SELECT id FROM event_outbox WHERE event_type = "notification.topic.subscribed") == 3
    AND (SELECT VALUE object::keys(payload) FROM event_outbox WHERE event_type = "notification.topic.unsubscribed") == [["subscriber_id", "topic_id"]];

-- test: un membre sans permission ne voit aucun sujet
-- en tant que: membre
RETURN fn::notification_topic_list({ tenant: "auth_organization:alpha" }).error.code == "NOTIFICATION_PERMISSION_DENIED"
    AND count(SELECT id FROM notification_topic) == 0 AND count(SELECT id FROM notification_topic_member) == 0;

-- test: suppression d'un sujet avec ses abonnements
-- en tant que: admin
RETURN fn::notification_topic_delete({ tenant: "auth_organization:alpha", key: "chantier_nord" }).ok
    AND fn::notification_topic_delete({ tenant: "auth_organization:alpha", key: "chantier_nord" }).error.code == "NOTIFICATION_TOPIC_NOT_FOUND"
    AND count(SELECT id FROM notification_topic_member) == 0;

-- test: catégorie de l'installation créée par la plateforme
-- en tant que: plateforme
RETURN fn::notification_category_create({ key: "actualites", name: "Actualités" }).data.scope_key == "installation"
    AND fn::notification_category_create({ tenant: "auth_organization:alpha", key: "x", name: "X" }).error.code == "NOTIFICATION_PERMISSION_DENIED";

-- test: catégorie d'une organisation ; clé unique dans sa portée ; une organisation peut réutiliser une clé de l'installation
-- en tant que: admin
RETURN fn::notification_category_create({ tenant: "auth_organization:alpha", key: "rappels", name: "Rappels", description: "Rappels de chantier" }).ok
    AND fn::notification_category_create({ tenant: "auth_organization:alpha", key: "rappels", name: "Doublon" }).error.code == "NOTIFICATION_CATEGORY_KEY_TAKEN"
    AND fn::notification_category_create({ tenant: "auth_organization:alpha", key: "actualites", name: "Actualités Alpha" }).ok
    AND fn::notification_category_update({ tenant: "auth_organization:alpha", key: "rappels", name: "Rappels chantier" }).data.name == "Rappels chantier"
    AND fn::notification_category_update({ tenant: "auth_organization:alpha", key: "absente", name: "X" }).error.code == "NOTIFICATION_CATEGORY_NOT_FOUND";

-- test: liste : catégories de l'organisation et de l'installation ; recherche interne avec repli sur l'installation
-- en tant que: admin
RETURN fn::notification_category_list({ tenant: "auth_organization:alpha" }).data.map(|$c| [$c.scope_key, $c.key]) == [["alpha", "actualites"], ["alpha", "rappels"], ["installation", "actualites"]]
    AND fn::notification_category_find({ tenant: auth_organization:beta, key: "actualites", own_only: false }).scope_key == "installation"
    AND fn::notification_category_find({ tenant: auth_organization:beta, key: "actualites", own_only: true }) IS NONE;

-- test: une personne sans permission voit les catégories de son organisation et de l'installation (réglage de ses préférences)
-- en tant que: membre
RETURN array::len(fn::notification_category_list({ tenant: "auth_organization:alpha" }).data) == 3
    AND fn::notification_category_list({ tenant: "auth_organization:beta" }).error.code == "NOTIFICATION_PERMISSION_DENIED"
    AND fn::notification_category_create({ tenant: "auth_organization:alpha", key: "y", name: "Y" }).error.code == "NOTIFICATION_PERMISSION_DENIED";

-- test: parcours rangé dans une catégorie (de l'organisation, sinon de l'installation) ; catégorie inconnue refusée
-- en tant que: admin
RETURN fn::notification_workflow_create({ tenant: "auth_organization:alpha", key: "relance", name: "Relance", category: "rappels", steps: [{ key: "email", type: "email" }] }).data.category.key == "rappels"
    AND fn::notification_workflow_create({ tenant: "auth_organization:alpha", key: "lettre", name: "Lettre", category: "inconnue", steps: [{ key: "email", type: "email" }] }).error.code == "NOTIFICATION_CATEGORY_NOT_FOUND";

-- test: une catégorie utilisée par un parcours ne peut pas être supprimée ; retirée du parcours, elle peut l'être
-- en tant que: admin
{
    LET $w = (SELECT VALUE id FROM ONLY notification_workflow WHERE scope_key = "alpha" AND key = "relance" LIMIT 1);
    LET $refused = fn::notification_category_delete({ tenant: "auth_organization:alpha", key: "rappels" });
    LET $cleared = fn::notification_workflow_update({ workflow: <string> $w, clear_category: true }).data;
    RETURN $refused.error.code == "NOTIFICATION_CATEGORY_IN_USE" AND $refused.error.details.workflows == ["relance"]
        AND $cleared.category IS NONE
        AND fn::notification_category_delete({ tenant: "auth_organization:alpha", key: "rappels" }).ok
        AND fn::notification_category_delete({ tenant: "auth_organization:alpha", key: "rappels" }).error.code == "NOTIFICATION_CATEGORY_NOT_FOUND";
};

-- test: une organisation ne supprime pas une catégorie de l'installation
-- en tant que: autre
RETURN fn::notification_category_delete({ key: "actualites" }).error.code == "NOTIFICATION_PERMISSION_DENIED"
    AND fn::notification_category_delete({ tenant: "auth_organization:beta", key: "actualites" }).error.code == "NOTIFICATION_CATEGORY_NOT_FOUND";

-- test: catégorie utilisée par plusieurs parcours : leurs clés sont renvoyées triées
-- en tant que: admin
{
    LET $category = fn::notification_category_create({ tenant: "auth_organization:alpha", key: "tri", name: "Tri" });
    LET $last = fn::notification_workflow_create({ tenant: "auth_organization:alpha", key: "zeta", name: "Zeta", category: "tri", steps: [{ key: "email", type: "email" }] });
    LET $first = fn::notification_workflow_create({ tenant: "auth_organization:alpha", key: "alerte", name: "Alerte", category: "tri", steps: [{ key: "email", type: "email" }] });
    RETURN $category.ok AND $last.ok AND $first.ok
        AND fn::notification_category_delete({ tenant: "auth_organization:alpha", key: "tri" }).error.details.workflows == ["alerte", "zeta"];
};
