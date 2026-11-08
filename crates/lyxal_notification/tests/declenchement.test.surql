-- lyxal-test: assertions
-- Déclenchement : parcours de l'organisation puis de l'installation (clé ou événement),
-- validation des variables, idempotence, parcours inactif ou inconnu, liste de suppression
-- (parcours critique contre désabonnement et rejet définitif), activité, permissions.
--
-- identité admin: { "id": "auth_session:admin", "pv": 1, "permissions": ["notification.read", "notification.manage", "notification.send"] }
-- identité envoyeur: { "id": "auth_session:envoyeur", "pv": 1, "permissions": ["notification.send"] }
-- identité autre: { "id": "auth_session:autre", "pv": 1, "permissions": ["notification.read", "notification.manage", "notification.send"] }
-- identité membre: { "id": "auth_session:membre", "pv": 1, "permissions": [] }
-- identité plateforme: { "id": "auth_session:plateforme", "pv": 1, "permissions": ["notification.installation.manage"] }

-- préparation: organisations, sessions, parcours de l'organisation et de l'installation
{
    CREATE auth_organization:alpha CONTENT { slug: "alpha", name: "Alpha BTP" };
    CREATE auth_organization:beta CONTENT { slug: "beta", name: "Beta" };
    FOR $n IN ["admin", "envoyeur", "membre", "autre", "plateforme"] {
        CREATE type::record("auth_identity", $n) CONTENT { schema: auth_identity_schema:default_v1, traits: { email: string::concat($n, "@lyxal.test") } };
    };
    RELATE auth_identity:admin->auth_member_of->auth_organization:alpha;
    RELATE auth_identity:envoyeur->auth_member_of->auth_organization:alpha;
    RELATE auth_identity:membre->auth_member_of->auth_organization:alpha;
    RELATE auth_identity:autre->auth_member_of->auth_organization:beta;
    CREATE auth_session:admin CONTENT { identity: auth_identity:admin, organization: auth_organization:alpha, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_session:envoyeur CONTENT { identity: auth_identity:envoyeur, organization: auth_organization:alpha, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_session:membre CONTENT { identity: auth_identity:membre, organization: auth_organization:alpha, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_session:autre CONTENT { identity: auth_identity:autre, organization: auth_organization:beta, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_session:plateforme CONTENT { identity: auth_identity:plateforme, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE notification_workflow:devis_installation CONTENT { key: "devis", name: "Devis (installation)", trigger_event: "crm.quote.sent", status: "active", steps: [{ key: "email", channel: "email" }] };
    CREATE notification_workflow:devis_alpha CONTENT {
        tenant: auth_organization:alpha, key: "devis", name: "Devis Alpha", trigger_event: "crm.quote.sent", status: "active",
        payload_schema: { fields: { quote_number: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 32 } }], required: true } }, unknown_keys: "reject" },
        steps: [{ key: "email", channel: "email" }]
    };
    CREATE notification_workflow:brouillon_alpha CONTENT { tenant: auth_organization:alpha, key: "brouillon", name: "Brouillon", status: "draft", steps: [{ key: "email", channel: "email" }] };
};

-- test: déclenchement par clé : parcours de l'organisation, une étape en file
-- en tant que: envoyeur
{
    LET $r = fn::notification_trigger({
        tenant: "auth_organization:alpha", workflow_key: "devis", idempotency_key: "devis-001",
        recipient: { email: "Client@Exemple.fr", locale: "fr-FR", name: "Claire" },
        payload: { quote_number: "D-001" }, secret: "enc:v2:cle-2026:AAAAAAAAAAAAAAAAAAAAAAAA"
    }).data;
    RETURN $r.status == "created" AND array::len($r.job_ids) == 1 AND $r.skip_reason IS NONE;
};

-- test: déclenchement enregistré : parcours de l'organisation, adresse normalisée, secret conservé scellé
RETURN (SELECT workflow, recipient, status, secret FROM ONLY notification_run WHERE idempotency_key = "devis-001" LIMIT 1)
    == { workflow: notification_workflow:devis_alpha, recipient: { email: "client@exemple.fr", locale: "fr-FR", name: "Claire" }, status: "pending", secret: "enc:v2:cle-2026:AAAAAAAAAAAAAAAAAAAAAAAA" };

-- test: le secret n'est pas lisible par qui déclenche
-- en tant que: envoyeur
RETURN (SELECT VALUE secret FROM ONLY notification_run WHERE idempotency_key = "devis-001" LIMIT 1) IS NONE
    AND (SELECT VALUE status FROM ONLY notification_run WHERE idempotency_key = "devis-001" LIMIT 1) == "pending";

-- test: rejeu de la même clé : déclenchement existant renvoyé, aucune étape en plus
-- en tant que: envoyeur
{
    LET $first = (SELECT VALUE id FROM ONLY notification_run WHERE idempotency_key = "devis-001" LIMIT 1);
    LET $r = fn::notification_trigger({
        tenant: "auth_organization:alpha", workflow_key: "devis", idempotency_key: "devis-001",
        recipient: { email: "autre@exemple.fr" }, payload: { quote_number: "D-002" }
    }).data;
    RETURN $r.status == "duplicate" AND $r.run_id == $first AND array::len($r.job_ids) == 1
        AND array::len(SELECT * FROM notification_job WHERE run = $first) == 1;
};

-- test: variables refusées par le schéma du parcours
-- en tant que: envoyeur
RETURN fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "devis", idempotency_key: "devis-002", recipient: { email: "c@exemple.fr" }, payload: { autre: 1 } }).error.code == "NOTIFICATION_PAYLOAD_INVALID";

-- test: une autre organisation déclenche le parcours de l'installation de même clé
-- en tant que: autre
{
    LET $r = fn::notification_trigger({ tenant: "auth_organization:beta", workflow_key: "devis", idempotency_key: "devis-001", recipient: { email: "c@exemple.fr" } }).data;
    RETURN $r.status == "created" AND (SELECT VALUE workflow FROM ONLY $r.run_id) == notification_workflow:devis_installation;
};

-- test: déclenchement par événement : repli sur le parcours de l'installation
-- en tant que: envoyeur
{
    LET $r = fn::notification_trigger({
        tenant: "auth_organization:alpha", trigger_event: "auth.invitation.created", idempotency_key: "01a1bca0-0000-7000-8000-000000000010",
        event_id: "01a1bca0-0000-7000-8000-000000000010", recipient: { email: "invitee@exemple.fr", locale: "en" },
        payload: { invitation_id: "auth_organization_invitation:x", organization_name: "Alpha BTP", inviter_name: NONE },
        secret: "enc:v2:cle-2026:BBBBBBBBBBBBBBBBBBBBBBBB", expires_at: time::now() + 7d
    }).data;
    RETURN $r.status == "created" AND (SELECT VALUE workflow FROM ONLY $r.run_id) == notification_workflow:auth_invitation;
};

-- test: parcours inactif, inconnu, ou ni clé ni événement
-- en tant que: envoyeur
RETURN fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "brouillon", idempotency_key: "b-1", recipient: { email: "c@exemple.fr" } }).error.code == "NOTIFICATION_WORKFLOW_INACTIVE"
    AND fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "inconnu", idempotency_key: "b-2", recipient: { email: "c@exemple.fr" } }).error.code == "NOTIFICATION_WORKFLOW_NOT_FOUND"
    AND fn::notification_trigger({ tenant: "auth_organization:alpha", idempotency_key: "b-3", recipient: { email: "c@exemple.fr" } }).error.code == "NOTIFICATION_INVALID_INPUT";

-- test: entrées invalides : secret non scellé, adresse invalide, expiration passée
-- en tant que: envoyeur
RETURN fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "devis", idempotency_key: "i-1", recipient: { email: "c@exemple.fr" }, payload: { quote_number: "1" }, secret: "https://lien-en-clair.test/abc123456789" }).error.code == "NOTIFICATION_INVALID_INPUT"
    AND fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "devis", idempotency_key: "i-2", recipient: { email: "pas-une-adresse" }, payload: { quote_number: "1" } }).error.code == "NOTIFICATION_INVALID_INPUT"
    AND fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "devis", idempotency_key: "i-3", recipient: { email: "c@exemple.fr" }, payload: { quote_number: "1" }, expires_at: time::now() - 1h }).error.code == "NOTIFICATION_INVALID_INPUT";

-- test: sans permission d'envoi, ou pour une autre organisation : refusé
-- en tant que: membre
RETURN fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "devis", idempotency_key: "p-1", recipient: { email: "c@exemple.fr" }, payload: { quote_number: "1" } }).error.code == "NOTIFICATION_PERMISSION_DENIED";

-- test: une organisation ne déclenche pas pour une autre ni pour l'installation
-- en tant que: autre
RETURN fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "devis", idempotency_key: "p-2", recipient: { email: "c@exemple.fr" }, payload: { quote_number: "1" } }).error.code == "NOTIFICATION_PERMISSION_DENIED"
    AND fn::notification_trigger({ workflow_key: "devis", idempotency_key: "p-3", recipient: { email: "c@exemple.fr" } }).error.code == "NOTIFICATION_PERMISSION_DENIED";

-- test: adresses ajoutées à la liste de suppression (désabonnement, rejet définitif) ; adresse normalisée
-- en tant que: admin
RETURN fn::notification_suppression_add({ tenant: "auth_organization:alpha", address: "Desabonne@Exemple.fr", reason: "unsubscribe", source: "lien de désabonnement" }).data.address == "desabonne@exemple.fr"
    AND fn::notification_suppression_add({ tenant: "auth_organization:alpha", address: "inexistant@exemple.fr", reason: "hard_bounce" }).data.reason == "hard_bounce";

-- test: événement notification.address.suppressed publié pour chaque adresse
RETURN (SELECT VALUE payload.address FROM event_outbox WHERE event_type = "notification.address.suppressed" ORDER BY payload.address)
    == ["desabonne@exemple.fr", "inexistant@exemple.fr"];

-- test: parcours non critique vers une adresse désabonnée : déclenchement et étape abandonnés
-- en tant que: envoyeur
{
    LET $r = fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "devis", idempotency_key: "s-1", recipient: { email: "desabonne@exemple.fr" }, payload: { quote_number: "1" }, secret: "enc:v2:cle-2026:CCCCCCCCCCCCCCCCCCCCCCCC" }).data;
    RETURN $r.status == "skipped" AND $r.skip_reason == "suppressed:unsubscribe"
        AND (SELECT VALUE status FROM notification_job WHERE run = $r.run_id) == ["skipped"];
};

-- test: un déclenchement abandonné ne conserve pas le secret
RETURN (SELECT VALUE secret FROM ONLY notification_run WHERE idempotency_key = "s-1" LIMIT 1) IS NONE;

-- test: parcours critique : un désabonnement ne bloque pas, un rejet définitif oui
-- en tant que: envoyeur
{
    LET $ok = fn::notification_trigger({ tenant: "auth_organization:alpha", trigger_event: "auth.invitation.created", idempotency_key: "s-2", recipient: { email: "desabonne@exemple.fr" }, payload: { invitation_id: "i", organization_name: "Alpha BTP" }, secret: "enc:v2:cle-2026:DDDDDDDDDDDDDDDDDDDDDDDD" }).data;
    LET $ko = fn::notification_trigger({ tenant: "auth_organization:alpha", trigger_event: "auth.invitation.created", idempotency_key: "s-3", recipient: { email: "inexistant@exemple.fr" }, payload: { invitation_id: "i", organization_name: "Alpha BTP" }, secret: "enc:v2:cle-2026:EEEEEEEEEEEEEEEEEEEEEEEE" }).data;
    RETURN $ok.status == "created" AND $ko.status == "skipped" AND $ko.skip_reason == "suppressed:hard_bounce";
};

-- test: une suppression de l'installation s'applique aux organisations
-- en tant que: plateforme
RETURN fn::notification_suppression_add({ address: "bloque@exemple.fr", reason: "manual", source: "support" }).ok;

-- test: adresse bloquée par l'installation : déclenchement critique de l'organisation abandonné
-- en tant que: envoyeur
RETURN fn::notification_trigger({ tenant: "auth_organization:alpha", trigger_event: "auth.invitation.created", idempotency_key: "s-4", recipient: { email: "bloque@exemple.fr" }, payload: { invitation_id: "i", organization_name: "Alpha BTP" } }).data.skip_reason == "suppressed:manual";

-- test: une suppression d'une autre organisation ne s'applique pas
-- en tant que: autre
RETURN fn::notification_trigger({ tenant: "auth_organization:beta", workflow_key: "devis", idempotency_key: "s-5", recipient: { email: "desabonne@exemple.fr" } }).data.status == "created";

-- test: liste de suppression filtrée par motif ; remplacement sans doublon
-- en tant que: admin
RETURN fn::notification_suppression_list({ tenant: "auth_organization:alpha", reason: "hard_bounce" }).data.address == ["inexistant@exemple.fr"]
    AND fn::notification_suppression_add({ tenant: "auth_organization:alpha", address: "desabonne@exemple.fr", reason: "complaint" }).data.reason == "complaint"
    AND array::len(fn::notification_suppression_list({ tenant: "auth_organization:alpha" }).data) == 2;

-- test: adresse retirée ; une adresse absente est signalée
-- en tant que: admin
RETURN fn::notification_suppression_remove({ tenant: "auth_organization:alpha", address: "desabonne@exemple.fr" }).ok
    AND fn::notification_suppression_remove({ tenant: "auth_organization:alpha", address: "desabonne@exemple.fr" }).error.code == "NOTIFICATION_NOT_FOUND";

-- test: une organisation ne voit ni ne modifie la liste d'une autre
-- en tant que: autre
RETURN fn::notification_suppression_list({ tenant: "auth_organization:alpha" }).error.code == "NOTIFICATION_PERMISSION_DENIED"
    AND fn::notification_suppression_remove({ tenant: "auth_organization:alpha", address: "inexistant@exemple.fr" }).error.code == "NOTIFICATION_PERMISSION_DENIED"
    AND array::len(SELECT * FROM notification_suppression WHERE scope_key = "alpha") == 0;

-- test: activité : déclenchement avec ses étapes, sans secret
-- en tant que: admin
{
    LET $run = (SELECT VALUE id FROM ONLY notification_run WHERE idempotency_key = "devis-001" AND scope_key = "alpha" LIMIT 1);
    LET $g = fn::notification_run_get({ run: <string> $run }).data;
    RETURN $g.status == "pending" AND !object::keys($g).any(|$k| $k = "secret") AND $g.jobs.status == ["queued"]
        AND $g.messages == [] AND $g.log == [] AND $g.jobs[0].claim_token IS NONE;
};

-- test: activité listée par état et par parcours
-- en tant que: admin
RETURN array::len(fn::notification_run_list({ tenant: "auth_organization:alpha", status: "skipped" }).data) == 3
    AND array::sort(fn::notification_run_list({ tenant: "auth_organization:alpha", workflow: "notification_workflow:devis_alpha" }).data.idempotency_key) == ["devis-001", "s-1"];

-- test: qui déclenche relit son déclenchement, mais ne liste pas l'activité
-- en tant que: envoyeur
{
    LET $run = (SELECT VALUE id FROM ONLY notification_run WHERE idempotency_key = "devis-001" LIMIT 1);
    RETURN fn::notification_run_get({ run: <string> $run }).ok
        AND fn::notification_run_list({ tenant: "auth_organization:alpha" }).error.code == "NOTIFICATION_PERMISSION_DENIED";
};

-- test: une autre organisation ne voit pas l'activité
-- en tant que: autre
RETURN fn::notification_run_get({ run: "notification_run:inconnu" }).error.code == "NOTIFICATION_NOT_FOUND"
    AND array::len(SELECT * FROM notification_run WHERE scope_key = "alpha") == 0
    AND array::len(SELECT * FROM notification_job WHERE run.scope_key = "alpha") == 0;
