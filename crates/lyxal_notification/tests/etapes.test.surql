-- lyxal-test: assertions
-- Étapes typées d'un parcours : forme de chaque type, bornes, conditions, ordre, durées bornées
-- par max_wait_days ; surcharges au déclenchement ; aperçu d'une étape ; fonctions internes de
-- forme.
--
-- identité admin: { "id": "auth_session:admin", "pv": 1, "permissions": ["notification.read", "notification.manage", "notification.send"] }
-- identité lecteur: { "id": "auth_session:lecteur", "pv": 1, "permissions": ["notification.read"] }
-- identité envoyeur: { "id": "auth_session:envoyeur", "pv": 1, "permissions": ["notification.send"] }
-- identité autre: { "id": "auth_session:autre", "pv": 1, "permissions": ["notification.read", "notification.manage", "notification.send"] }
-- identité membre: { "id": "auth_session:membre", "pv": 1, "permissions": [] }

-- préparation: organisations et sessions
{
    CREATE auth_organization:alpha CONTENT { slug: "alpha", name: "Alpha BTP" };
    CREATE auth_organization:beta CONTENT { slug: "beta", name: "Beta" };
    FOR $n IN ["admin", "lecteur", "envoyeur", "membre", "autre"] {
        LET $org = IF $n = "autre" { auth_organization:beta } ELSE { auth_organization:alpha };
        LET $identity = type::record("auth_identity", $n);
        CREATE $identity CONTENT { schema: auth_identity_schema:default_v1, traits: { email: string::concat($n, "@lyxal.test") } };
        RELATE $identity->auth_member_of->$org;
        CREATE type::record("auth_session", $n) CONTENT { identity: $identity, organization: $org, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    };
    DEFINE TABLE test_ref SCHEMALESS PERMISSIONS FULL;
};

-- test: parcours complet : canal, attente, regroupement, limitation, conditions ; forme normalisée
-- en tant que: admin
{
    LET $r = fn::notification_workflow_create({
        tenant: "auth_organization:alpha", key: "relance", name: "Relance",
        steps: [
            { key: "limite", type: "throttle", limit: 3, window: { amount: 1, unit: "hours" }, group_by: "payload.projet" },
            { key: "premier", type: "email" },
            { key: "pause", type: "delay", amount: 2, unit: "days" },
            { key: "veille", type: "delay", until: "payload.rendez_vous", offset: { amount: -1, unit: "days" } },
            { key: "lot", type: "digest", window: { amount: 30, unit: "minutes" }, group_by: "payload.projet", lookback: { amount: 1, unit: "hours" } },
            { key: "rappel", type: "email", condition: { all: [{ field: "steps.premier.status", op: "eq", value: "completed" }, { field: "payload.urgent", op: "ne", value: true }] } }
        ]
    });
    CREATE test_ref:relance CONTENT { id_workflow: $r.data.id };
    RETURN $r.ok AND $r.data.steps.map(|$s| $s.type) == ["throttle", "email", "delay", "delay", "digest", "email"]
        AND $r.data.steps[3].offset == { amount: -1, unit: "days" } AND $r.data.steps[5].condition.all[0].field == "steps.premier.status";
};

-- test: forme refusée par type : champ inconnu, champ propre à un autre type, champ requis absent ; détail par étape et par champ
-- en tant que: admin
{
    LET $a = fn::notification_workflow_create({ tenant: "auth_organization:alpha", key: "a", name: "A", steps: [{ key: "email", type: "email", amount: 1 }] }).error;
    LET $b = fn::notification_workflow_create({ tenant: "auth_organization:alpha", key: "b", name: "B", steps: [{ key: "lot", type: "digest" }, { key: "email", type: "email" }] }).error;
    LET $c = fn::notification_workflow_create({ tenant: "auth_organization:alpha", key: "c", name: "C", steps: [{ key: "email", type: "fax" }] }).error;
    LET $d = fn::notification_workflow_create({ tenant: "auth_organization:alpha", key: "d", name: "D", steps: [{ key: "email", type: "email" }, { key: "limite", type: "throttle", limit: 0, window: { amount: 1, unit: "hours" } }] }).error;
    LET $e = fn::notification_workflow_create({ tenant: "auth_organization:alpha", key: "e", name: "E", steps: [{ key: "pause", type: "delay", amount: 1, unit: "siecles" }, { key: "email", type: "email" }] }).error;
    LET $f = fn::notification_workflow_create({ tenant: "auth_organization:alpha", key: "f", name: "F", steps: [{ key: "pause", type: "delay", until: "payload.[*]" }, { key: "email", type: "email" }] }).error;
    RETURN [$a.code, $b.code, $c.code, $d.code, $e.code, $f.code] == ["NOTIFICATION_STEP_INVALID", "NOTIFICATION_STEP_INVALID", "NOTIFICATION_STEP_INVALID", "NOTIFICATION_STEP_INVALID", "NOTIFICATION_STEP_INVALID", "NOTIFICATION_STEP_INVALID"]
        AND object::keys($a.details.fields) == ["0"] AND object::keys($b.details.fields) == ["0"] AND object::keys($d.details.fields) == ["1"]
        AND $b.details.fields["0"].window IS NOT NONE AND $d.details.fields["1"].limit IS NOT NONE;
};

-- test: attente : une durée ou une date des données, jamais les deux ; décalage seulement avec une date
-- en tant que: admin
{
    LET $both = fn::notification_workflow_create({ tenant: "auth_organization:alpha", key: "g", name: "G", steps: [{ key: "pause", type: "delay", amount: 1, unit: "hours", until: "payload.a" }, { key: "email", type: "email" }] }).error;
    LET $none = fn::notification_workflow_create({ tenant: "auth_organization:alpha", key: "h", name: "H", steps: [{ key: "pause", type: "delay" }, { key: "email", type: "email" }] }).error;
    LET $offset = fn::notification_workflow_create({ tenant: "auth_organization:alpha", key: "i", name: "I", steps: [{ key: "pause", type: "delay", amount: 1, unit: "hours", offset: { amount: 1, unit: "hours" } }, { key: "email", type: "email" }] }).error;
    LET $half = fn::notification_workflow_create({ tenant: "auth_organization:alpha", key: "j", name: "J", steps: [{ key: "pause", type: "delay", amount: 1 }, { key: "email", type: "email" }] }).error;
    RETURN [$both, $none, $offset, $half].all(|$e| $e.code == "NOTIFICATION_STEP_INVALID" AND $e.details == { step: "pause", reason: "delay_form" });
};

-- test: ordre : au moins une étape de canal ; un regroupement ou une limitation précède une étape de canal ; clés uniques ; 20 étapes au plus
-- en tant que: admin
{
    LET $no_channel = fn::notification_workflow_create({ tenant: "auth_organization:alpha", key: "k", name: "K", steps: [{ key: "pause", type: "delay", amount: 1, unit: "hours" }] }).error;
    LET $digest_last = fn::notification_workflow_create({ tenant: "auth_organization:alpha", key: "l", name: "L", steps: [{ key: "email", type: "email" }, { key: "lot", type: "digest", window: { amount: 1, unit: "hours" } }] }).error;
    LET $throttle_last = fn::notification_workflow_create({ tenant: "auth_organization:alpha", key: "m", name: "M", steps: [{ key: "email", type: "email" }, { key: "limite", type: "throttle", limit: 1, window: { amount: 1, unit: "hours" } }] }).error;
    LET $duplicate = fn::notification_workflow_create({ tenant: "auth_organization:alpha", key: "n", name: "N", steps: [{ key: "email", type: "email" }, { key: "email", type: "delay", amount: 1, unit: "hours" }] }).error;
    LET $many = fn::notification_workflow_create({ tenant: "auth_organization:alpha", key: "o", name: "O", steps: array::map(<array>(0..21), |$i| { key: string::concat("e", <string> $i), type: "email" }) }).error;
    RETURN $no_channel.details == { reason: "no_channel_step" }
        AND $digest_last.details == { step: "lot", reason: "no_channel_after" }
        AND $throttle_last.details == { step: "limite", reason: "no_channel_after" }
        AND $duplicate.details == { reason: "duplicate_key" }
        AND $many.code == "NOTIFICATION_INVALID_INPUT";
};

-- test: condition d'étape invalide refusée par fn::utils_condition_check, avec l'étape fautive
-- en tant que: admin
{
    LET $e = fn::notification_workflow_create({ tenant: "auth_organization:alpha", key: "p", name: "P", steps: [{ key: "email", type: "email", condition: { field: "payload.x", op: "ressemble" } }] }).error;
    RETURN $e.code == "NOTIFICATION_CONDITION_INVALID" AND $e.details.step == "email" AND $e.details.reason == "unknown_operator";
};

-- test: durées bornées par max_wait_days (30 jours par défaut) : attente, décalage, fenêtres
-- en tant que: admin
{
    LET $delay = fn::notification_workflow_create({ tenant: "auth_organization:alpha", key: "q", name: "Q", steps: [{ key: "pause", type: "delay", amount: 31, unit: "days" }, { key: "email", type: "email" }] }).error;
    LET $offset = fn::notification_workflow_create({ tenant: "auth_organization:alpha", key: "r", name: "R", steps: [{ key: "pause", type: "delay", until: "payload.a", offset: { amount: -5, unit: "weeks" } }, { key: "email", type: "email" }] }).error;
    LET $window = fn::notification_workflow_create({ tenant: "auth_organization:alpha", key: "s", name: "S", steps: [{ key: "limite", type: "throttle", limit: 1, window: { amount: 31, unit: "days" } }, { key: "email", type: "email" }] }).error;
    LET $ok = fn::notification_workflow_create({ tenant: "auth_organization:alpha", key: "t", name: "T", steps: [{ key: "pause", type: "delay", amount: 30, unit: "days" }, { key: "email", type: "email" }] }).ok;
    RETURN $delay.code == "NOTIFICATION_WAIT_TOO_LONG" AND $delay.details == { step: "pause", max_days: 30 }
        AND $offset.details == { step: "pause", max_days: 30 } AND $window.details == { step: "limite", max_days: 30 } AND $ok;
};

-- test: max_wait_days réglé par l'organisation (1 à 366) : la borne suit le réglage
-- en tant que: admin
{
    LET $set = fn::notification_settings_set({ tenant: "auth_organization:alpha", max_wait_days: 60 }).ok;
    LET $bad = fn::notification_settings_set({ tenant: "auth_organization:alpha", max_wait_days: 400 }).error.code;
    LET $ok = fn::notification_workflow_create({ tenant: "auth_organization:alpha", key: "u", name: "U", steps: [{ key: "pause", type: "delay", amount: 45, unit: "days" }, { key: "email", type: "email" }] }).ok;
    RETURN $set AND $bad == "NOTIFICATION_INVALID_INPUT" AND $ok
        AND fn::notification_settings_get({ tenant: "auth_organization:alpha" }).data.effective.max_wait_days == 60;
};

-- test: modification des étapes contrôlée de même ; un parcours actif garde un gabarit par étape de canal (pas pour une attente)
-- en tant que: admin
{
    LET $w = (SELECT VALUE id_workflow FROM ONLY test_ref:relance);
    LET $bad = fn::notification_workflow_update({ workflow: <string> $w, steps: [{ key: "pause", type: "delay", amount: 1, unit: "hours" }] }).error.code;
    fn::notification_template_create({ workflow: <string> $w, step_key: "premier", subject: "S", html_body: "<p>H</p>", text_body: "T" });
    LET $no_template = fn::notification_template_create({ workflow: <string> $w, step_key: "pause", subject: "S", html_body: "<p>H</p>", text_body: "T" }).error.code;
    LET $missing = fn::notification_workflow_set_status({ workflow: <string> $w, status: "active" }).error.details.steps;
    fn::notification_template_create({ workflow: <string> $w, step_key: "rappel", subject: "Rappel {{ payload.projet }}", html_body: "<p>{{ t(\"notification.common.greeting\") }} {% if digest %}{{ digest.count }}{% endif %}</p>", text_body: "Rappel", keys: ["notification.common.greeting"] });
    LET $active = fn::notification_workflow_set_status({ workflow: <string> $w, status: "active" }).ok;
    LET $updated = fn::notification_workflow_update({ workflow: <string> $w, steps: [{ key: "premier", type: "email" }, { key: "pause", type: "delay", amount: 1, unit: "hours" }, { key: "rappel", type: "email" }] }).data.steps.key;
    RETURN $bad == "NOTIFICATION_STEP_INVALID" AND $no_template == "NOTIFICATION_INVALID_INPUT" AND $missing == ["rappel"] AND $active
        AND $updated == ["premier", "pause", "rappel"];
};

-- test: un membre sans droit ne crée pas de parcours à étapes ; une autre organisation non plus
-- en tant que: autre
RETURN fn::notification_workflow_create({ tenant: "auth_organization:alpha", key: "v", name: "V", steps: [{ key: "email", type: "email" }] }).error.code == "NOTIFICATION_PERMISSION_DENIED";

-- test: surcharges au déclenchement : étape inconnue, champ non permis pour le type, attente trop longue, forme incomplète
-- en tant que: envoyeur
{
    LET $call = |$overrides| fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "relance", idempotency_key: "o-1", to: { subscriber_id: "client-1", email: "client@exemple.fr" }, overrides: $overrides }).error;
    LET $unknown = $call({ steps: { inconnue: { skip: true } } });
    LET $window_on_delay = $call({ steps: { pause: { window: { amount: 1, unit: "hours" } } } });
    LET $amount_on_email = $call({ steps: { premier: { amount: 1, unit: "hours" } } });
    LET $too_long = $call({ steps: { pause: { amount: 90, unit: "days" } } });
    LET $half = $call({ steps: { pause: { amount: 2 } } });
    LET $shape = $call({ autre: {} });
    RETURN $unknown.code == "NOTIFICATION_OVERRIDE_INVALID" AND $unknown.details == { step: "inconnue", reason: "unknown_step" }
        AND $window_on_delay.code == "NOTIFICATION_OVERRIDE_INVALID" AND $window_on_delay.details.step == "pause"
        AND $amount_on_email.code == "NOTIFICATION_OVERRIDE_INVALID"
        AND $too_long.code == "NOTIFICATION_WAIT_TOO_LONG" AND $too_long.details == { step: "pause", max_days: 60 }
        AND $half.details == { step: "pause", reason: "delay_form" }
        AND $shape.code == "NOTIFICATION_OVERRIDE_INVALID"
        AND count(SELECT id FROM notification_run WHERE idempotency_key = "o-1") == 0;
};

-- test: surcharges acceptées : gardées sur le déclenchement
-- en tant que: envoyeur
{
    LET $r = fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "relance", idempotency_key: "o-2", to: { subscriber_id: "client-1", email: "client@exemple.fr" }, overrides: { steps: { pause: { amount: 5, unit: "minutes" }, rappel: { skip: true } } } }).data;
    RETURN $r.status == "created" AND (SELECT VALUE overrides FROM ONLY $r.run_id) == { steps: { pause: { amount: 5, unit: "minutes" }, rappel: { skip: true } } };
};

-- test: aperçu d'une étape : données de rendu (gabarit, langue demandée, textes, réglages), sans écriture
-- en tant que: lecteur
{
    LET $w = (SELECT VALUE id_workflow FROM ONLY test_ref:relance);
    LET $runs = count(SELECT id FROM notification_run);
    LET $p = fn::notification_step_preview({ workflow: <string> $w, step_key: "rappel", payload: { projet: "Tour B" }, locale: "en-GB", digest: { count: 3, events: [{ payload: { projet: "Tour B" } }] } }).data;
    RETURN $p.{ step_key, locale, recipient_locale, subject, texts_error } == { step_key: "rappel", locale: "en", recipient_locale: "en-GB", subject: "Rappel {{ payload.projet }}", texts_error: NONE }
        AND $p.texts[0].text == "Hello," AND $p.payload == { projet: "Tour B" } AND $p.digest.count == 3
        AND count(SELECT id FROM notification_run) == $runs;
};

-- préparation: identifiant du parcours, lisible par les identités de test
{
    LET $w = <string> (SELECT VALUE id_workflow FROM ONLY test_ref:relance);
    CREATE test_ref:apercu CONTENT { w: $w };
};

-- test: aperçu : étape d'attente, étape inconnue, entrée invalide
-- en tant que: lecteur
{
    LET $w = (SELECT VALUE w FROM ONLY test_ref:apercu);
    RETURN fn::notification_step_preview({ workflow: $w, step_key: "pause" }).error.code == "NOTIFICATION_NOT_FOUND"
        AND fn::notification_step_preview({ workflow: $w, step_key: "inconnue" }).error.code == "NOTIFICATION_NOT_FOUND"
        AND fn::notification_step_preview({ workflow: $w, step_key: "rappel", secret: { code: "1" } }).error.code == "NOTIFICATION_INVALID_INPUT"
        AND fn::notification_step_preview({ workflow: "notification_workflow:inconnu", step_key: "rappel" }).error.code == "NOTIFICATION_WORKFLOW_NOT_FOUND";
};

-- test: aperçu réservé à la lecture de l'organisation
-- en tant que: membre
RETURN fn::notification_step_preview({ workflow: (SELECT VALUE w FROM ONLY test_ref:apercu), step_key: "rappel" }).error.code == "NOTIFICATION_PERMISSION_DENIED";

-- test: aperçu refusé à une autre organisation
-- en tant que: autre
RETURN fn::notification_step_preview({ workflow: (SELECT VALUE w FROM ONLY test_ref:apercu), step_key: "rappel" }).error.code IN ["NOTIFICATION_PERMISSION_DENIED", "NOTIFICATION_WORKFLOW_NOT_FOUND"];

-- test: fonctions internes de forme : durée en secondes, schémas, contrôle des étapes et des surcharges
{
    LET $workflow = { steps: [{ key: "pause", type: "delay", amount: 1, unit: "hours" }, { key: "lot", type: "digest", window: { amount: 1, unit: "hours" } }, { key: "email", type: "email" }] };
    RETURN fn::notification_duration_seconds({ amount: 2, unit: "weeks" }) == 1209600
        AND fn::notification_duration_seconds({ amount: -1, unit: "days" }) == -86400
        AND object::keys(fn::notification_step_fields({})) == ["chat", "common", "delay", "digest", "email", "in_app", "push", "sms", "span", "throttle", "webhook"]
        AND fn::notification_step_check({ steps: $workflow.steps }).code IS NONE
        AND fn::notification_step_check({ steps: [{ key: "email", type: "email", condition: { field: "payload.a", op: "exists" } }] }).steps[0].condition == { field: "payload.a", op: "exists" }
        AND fn::notification_override_check({ overrides: { steps: { lot: { window: { amount: 2, unit: "hours" } }, email: { skip: true } } }, workflow: $workflow, max_wait_days: 30 }).overrides
            == { steps: { lot: { window: { amount: 2, unit: "hours" } }, email: { skip: true } } }
        AND fn::notification_override_check({ overrides: {}, workflow: $workflow, max_wait_days: 30 }).overrides == { steps: {} };
};
