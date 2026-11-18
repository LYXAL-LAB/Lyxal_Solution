-- lyxal-test: assertions
-- Fil dans l'application (décisions F1 à F8) : liens du fil (chemin de l'application ou
-- adresse HTTPS, à l'enregistrement et au rendu) ; parcours (gravité, étape in_app refusée dans
-- un parcours sensible) ; gabarits du fil ; livraison par le worker (abonné avec compte, invité
-- écarté, rejeu, liens rendus contrôlés, trace d'envoi sans contenu, événement) ; lecture par la
-- personne seule (autre personne, même personne dans une autre organisation, autre organisation,
-- gestionnaire, session sans compte : rien) et écritures directes refusées ; états et actions
-- groupées ; sommeil (bornes, message caché puis de nouveau non lu à l'échéance) ; compteurs et
-- onglets (étiquettes, gravité, données, lus) ; pagination ; boutons ; suppression ; préférence
-- in_app ; « sauter si déjà lu » (C6) ; conservation et purge ; fonctions internes.
--
-- identité personne: { "id": "auth_session:personne", "pv": 1, "permissions": [] }
-- identité collegue: { "id": "auth_session:collegue", "pv": 1, "permissions": [] }
-- identité ailleurs: { "id": "auth_session:ailleurs", "pv": 1, "permissions": [] }
-- identité voisin: { "id": "auth_session:voisin", "pv": 1, "permissions": ["notification.read", "notification.manage", "notification.send"] }
-- identité gestionnaire: { "id": "auth_session:gestionnaire", "pv": 1, "permissions": ["notification.read", "notification.manage", "notification.send"] }
-- identité service: { "id": "auth_session:service", "pv": 1, "permissions": ["notification.read"] }
-- identité worker: { "id": "auth_session:worker", "pv": 1, "permissions": ["notification.worker", "i18n.translation.read"] }

-- préparation: organisations, comptes, sessions, parcours du fil et abonnés
{
    CREATE auth_organization:alpha CONTENT { slug: "alpha", name: "Alpha BTP" };
    CREATE auth_organization:beta CONTENT { slug: "beta", name: "Beta Bois" };
    FOR $name IN ["personne", "collegue", "gestionnaire", "voisin", "worker", "partant"] {
        CREATE type::record("auth_identity", $name) CONTENT { schema: auth_identity_schema:default_v1, traits: { email: string::concat($name, "@lyxal.test"), locale: "fr" } };
    };
    FOR $name IN ["personne", "collegue", "gestionnaire", "partant"] {
        RELATE (type::record("auth_identity", $name))->auth_member_of->auth_organization:alpha;
    };
    RELATE auth_identity:personne->auth_member_of->auth_organization:beta;
    RELATE auth_identity:voisin->auth_member_of->auth_organization:beta;
    CREATE auth_session:personne CONTENT { identity: auth_identity:personne, organization: auth_organization:alpha, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_session:collegue CONTENT { identity: auth_identity:collegue, organization: auth_organization:alpha, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_session:gestionnaire CONTENT { identity: auth_identity:gestionnaire, organization: auth_organization:alpha, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_session:ailleurs CONTENT { identity: auth_identity:personne, organization: auth_organization:beta, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_session:voisin CONTENT { identity: auth_identity:voisin, organization: auth_organization:beta, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_session:worker CONTENT { identity: auth_identity:worker, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_application:robot CONTENT { tenant: auth_organization:alpha, client_id: "lyxal-test-fil-robot", name: "Robot", type: "machine", redirect_uris: [], state: "active", permissions_version: 1 };
    CREATE auth_session:service CONTENT { application: auth_application:robot, kind: "service", organization: auth_organization:alpha, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE notification_workflow:devis CONTENT { tenant: auth_organization:alpha, key: "devis", name: "Devis", status: "active", tags: ["devis"], severity: "high", steps: [{ key: "fil", type: "in_app" }] };
    CREATE notification_template:devis_fil CONTENT { tenant: auth_organization:alpha, workflow: notification_workflow:devis, step_key: "fil",
        subject: "Devis {{ payload.n }}", text_body: "Le devis **{{ payload.n }}** est prêt",
        redirect: "/devis/{{ payload.n }}", actions: [{ kind: "primary", label: "Valider", url: "/devis/{{ payload.n }}/valider" }, { kind: "secondary", label: "Plus tard" }],
        data: { devis: "{{ payload.n }}" } };
    CREATE notification_workflow:info CONTENT { tenant: auth_organization:alpha, key: "info", name: "Info", status: "active", tags: ["info"], severity: "low", steps: [{ key: "fil", type: "in_app" }] };
    CREATE notification_template:info_fil CONTENT { tenant: auth_organization:alpha, workflow: notification_workflow:info, step_key: "fil", subject: "Info", text_body: "Information" };
    CREATE notification_workflow:rappel CONTENT { tenant: auth_organization:alpha, key: "rappel", name: "Rappel", status: "active", steps: [
        { key: "fil", type: "in_app" },
        { key: "pause", type: "delay", amount: 6, unit: "hours" },
        { key: "mail", type: "email", condition: { field: "steps.fil.read", op: "eq", value: false } }
    ] };
    CREATE notification_template:rappel_fil CONTENT { tenant: auth_organization:alpha, workflow: notification_workflow:rappel, step_key: "fil", subject: "Rappel", text_body: "À lire" };
    CREATE notification_template:rappel_mail CONTENT { tenant: auth_organization:alpha, workflow: notification_workflow:rappel, step_key: "mail", subject: "Rappel", html_body: "<p>À lire</p>", text_body: "À lire" };
    FOR $name IN ["personne", "collegue", "partant"] {
        fn::notification_subscriber_save({ tenant: auth_organization:alpha, input: { subscriber_id: string::concat("auth:", $name), identity: type::record("auth_identity", $name), email: string::concat($name, "@lyxal.test") }, must_exist: false });
    };
    fn::notification_subscriber_save({ tenant: auth_organization:beta, input: { subscriber_id: "auth:personne", identity: auth_identity:personne, email: "personne@lyxal.test" }, must_exist: false });
    fn::notification_subscriber_save({ tenant: auth_organization:alpha, input: { subscriber_id: "email:invite@exemple.fr", email: "invite@exemple.fr" }, must_exist: false });
};

-- test: liens du fil : chemin de l'application ou adresse HTTPS ; schémas, « // », « /\ », HTTP et caractères de contrôle refusés
RETURN fn::notification_link_valid({ value: "/devis/42?onglet=lignes#total" })
    AND fn::notification_link_valid({ value: "https://app.lyxal.test/devis/42" })
    AND !fn::notification_link_valid({ value: "javascript:alert(1)" })
    AND !fn::notification_link_valid({ value: "JavaScript:alert(1)" })
    AND !fn::notification_link_valid({ value: "data:text/html,x" })
    AND !fn::notification_link_valid({ value: "//pirate.test/x" })
    AND !fn::notification_link_valid({ value: "/\\pirate.test" })
    AND !fn::notification_link_valid({ value: "http://app.lyxal.test/x" })
    AND !fn::notification_link_valid({ value: "/\t/pirate.test" })
    AND !fn::notification_link_valid({ value: "devis/42" })
    AND !fn::notification_link_valid({ value: "" })
    AND !fn::notification_link_valid({ value: 42 });

-- test: liens d'un gabarit : la partie fixe, avant la première variable, est déjà un lien valide
RETURN fn::notification_link_valid({ value: "/devis/{{ payload.n }}", template: true })
    AND fn::notification_link_valid({ value: "https://app.lyxal.test/devis/{{ payload.n }}", template: true })
    AND !fn::notification_link_valid({ value: "{{ payload.url }}", template: true })
    AND !fn::notification_link_valid({ value: "https://{{ payload.hote }}/x", template: true })
    AND !fn::notification_link_valid({ value: "{% if x %}/a{% endif %}", template: true })
    AND !fn::notification_link_valid({ value: "javascript:{{ payload.code }}", template: true });

-- test: parcours : gravité enregistrée (none par défaut) ; étape in_app refusée dans un parcours sensible, à la création comme à la modification
-- en tant que: gestionnaire
{
    LET $created = fn::notification_workflow_create({ tenant: "auth_organization:alpha", key: "alerte_fil", name: "Alerte", severity: "medium", tags: ["alerte"], steps: [{ key: "fil", type: "in_app" }] }).data;
    LET $default = fn::notification_workflow_create({ tenant: "auth_organization:alpha", key: "neutre_fil", name: "Neutre", steps: [{ key: "fil", type: "in_app" }] }).data;
    LET $sensitive = fn::notification_workflow_create({ tenant: "auth_organization:alpha", key: "code_fil", name: "Code", sensitive: true, steps: [{ key: "mail", type: "email" }, { key: "fil", type: "in_app" }] }).error;
    LET $became = fn::notification_workflow_update({ workflow: <string> $created.id, sensitive: true }).error;
    LET $severity = fn::notification_workflow_update({ workflow: <string> $created.id, severity: "low" }).data.severity;
    RETURN $created.severity == "medium" AND $default.severity == "none"
        AND $sensitive.code == "NOTIFICATION_STEP_INVALID" AND $sensitive.details.reason == "in_app_sensitive"
        AND $became.code == "NOTIFICATION_STEP_INVALID" AND $became.details.reason == "in_app_sensitive"
        AND $severity == "low"
        AND fn::notification_workflow_create({ tenant: "auth_organization:alpha", key: "mauvais", name: "M", severity: "urgent", steps: [{ key: "fil", type: "in_app" }] }).error.code == "NOTIFICATION_INVALID_INPUT";
};

-- test: gabarit du fil : titre et texte requis, ni HTML ni mise en page, liens contrôlés, boutons distincts, données textuelles
-- en tant que: gestionnaire
{
    LET $wf = (SELECT VALUE id FROM ONLY notification_workflow WHERE key = "alerte_fil" LIMIT 1);
    LET $no_title = fn::notification_template_create({ workflow: <string> $wf, step_key: "fil", text_body: "Texte" }).error;
    LET $html = fn::notification_template_create({ workflow: <string> $wf, step_key: "fil", subject: "T", text_body: "Texte", html_body: "<p>x</p>" }).error;
    LET $script = fn::notification_template_create({ workflow: <string> $wf, step_key: "fil", subject: "T", text_body: "Texte", redirect: "javascript:alert(1)" }).error;
    LET $variable = fn::notification_template_create({ workflow: <string> $wf, step_key: "fil", subject: "T", text_body: "Texte", avatar: "{{ payload.avatar }}" }).error;
    LET $button = fn::notification_template_create({ workflow: <string> $wf, step_key: "fil", subject: "T", text_body: "Texte", actions: [{ kind: "primary", label: "A", url: "//pirate.test" }] }).error;
    LET $twice = fn::notification_template_create({ workflow: <string> $wf, step_key: "fil", subject: "T", text_body: "Texte", actions: [{ kind: "primary", label: "A" }, { kind: "primary", label: "B" }] }).error;
    LET $three = fn::notification_template_create({ workflow: <string> $wf, step_key: "fil", subject: "T", text_body: "Texte", actions: [{ kind: "primary", label: "A" }, { kind: "secondary", label: "B" }, { kind: "secondary", label: "C" }] }).error;
    LET $data = fn::notification_template_create({ workflow: <string> $wf, step_key: "fil", subject: "T", text_body: "Texte", data: { n: 1 } }).error;
    LET $saved = fn::notification_template_create({ workflow: <string> $wf, step_key: "fil", subject: "Alerte {{ payload.n }}", text_body: "Texte",
        avatar: "https://cdn.lyxal.test/a.png", redirect: "/alertes/{{ payload.n }}", actions: [{ kind: "primary", label: "Voir", url: "/alertes/{{ payload.n }}" }], data: { n: "{{ payload.n }}" } }).data;
    RETURN $no_title.code == "NOTIFICATION_INVALID_INPUT" AND $no_title.details.fields == { subject: ["CORE_VALIDATION_REQUIRED"] }
        AND $html.details.fields == { html_body: ["CORE_VALIDATION_NOT_ALLOWED"] }
        AND $script.details.fields == { redirect: ["CORE_VALIDATION_FORMAT"] }
        AND $variable.details.fields == { avatar: ["CORE_VALIDATION_FORMAT"] }
        AND $button.details.fields == { "actions.primary": ["CORE_VALIDATION_FORMAT"] }
        AND $twice.details.fields == { actions: ["CORE_VALIDATION_DUPLICATE"] }
        AND $three.code == "NOTIFICATION_INVALID_INPUT"
        AND $data.details.fields == { data: ["CORE_VALIDATION_FORMAT"] }
        AND $saved.redirect == "/alertes/{{ payload.n }}" AND array::len($saved.actions) == 1 AND $saved.data == { n: "{{ payload.n }}" };
};

-- test: gabarit du fil modifié : null efface un champ du fil, un lien refusé ne change rien ; avatar et boutons refusés pour un autre canal
-- en tant que: gestionnaire
{
    LET $template = (SELECT VALUE id FROM ONLY notification_template WHERE step_key = "fil" AND workflow.key = "alerte_fil" LIMIT 1);
    LET $cleared = fn::notification_template_update({ template: <string> $template, avatar: NULL, actions: NULL }).data;
    LET $refused = fn::notification_template_update({ template: <string> $template, redirect: "javascript:x" }).error.code;
    LET $mail = fn::notification_template_update({ template: "notification_template:rappel_mail", avatar: "/a.png" }).error;
    RETURN $cleared.avatar IS NONE AND $cleared.actions IS NONE AND $cleared.redirect == "/alertes/{{ payload.n }}" AND $cleared.data == { n: "{{ payload.n }}" }
        AND $refused == "NOTIFICATION_INVALID_INPUT"
        AND (SELECT VALUE redirect FROM ONLY $template) == "/alertes/{{ payload.n }}"
        AND $mail.details.fields == { avatar: ["CORE_VALIDATION_NOT_ALLOWED"] };
};

-- test: déclenchement : l'abonné avec un compte reçoit une étape in_app en file ; un invité sans compte n'a pas de fil
{
    LET $created = fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "devis", idempotency_key: "devis-1", to: { subscriber_id: "auth:personne" }, payload: { n: "D-1" } }).data;
    LET $guest = fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "devis", idempotency_key: "devis-invite", to: { subscriber_id: "email:invite@exemple.fr" }, payload: { n: "D-2" } });
    LET $mixed = fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "rappel", idempotency_key: "rappel-invite", to: { subscriber_id: "email:invite@exemple.fr" }, payload: {} }).data;
    RETURN $created.status == "created"
        AND (SELECT VALUE [type, status] FROM notification_job WHERE run = $created.run_id) == [["in_app", "queued"]]
        AND $guest.error.code == "NOTIFICATION_SUBSCRIBER_NO_ADDRESS"
        AND (SELECT VALUE skip_reason FROM ONLY notification_job WHERE run = $mixed.run_id AND step_key = "fil" LIMIT 1) == "no_address:in_app";
};

-- test: réservation du canal in_app : ni intégration, ni secret, ni heures calmes ; gabarits du fil fournis au rendu
-- en tant que: worker
{
    LET $jobs = fn::notification_job_claim({ channel: "in_app", worker_id: "fil-1", limit: 10 }).data;
    LET $job = $jobs[0];
    RETURN array::len($jobs) == 1 AND $job.channel == "in_app" AND $job.integration IS NONE AND $job.secret IS NONE AND $job.quiet_hours IS NONE
        AND $job.subject == "Devis {{ payload.n }}" AND $job.redirect == "/devis/{{ payload.n }}"
        AND $job.actions.kind == ["primary", "secondary"] AND $job.data_templates == { devis: "{{ payload.n }}" }
        AND $job.payload == { n: "D-1" } AND $job.subscriber_id == "auth:personne";
};

-- test: livraison : lien rendu dangereux refusé sans rien écrire ; boutons en double refusés ; étape d'un autre canal refusée
-- en tant que: worker
{
    LET $job = (SELECT * FROM ONLY notification_job WHERE type = "in_app" AND status = "running" LIMIT 1);
    LET $base = { job_id: <string> $job.id, claim_token: $job.claim_token, title: "Devis D-1", text: "Le devis **D-1** est prêt" };
    LET $redirect = fn::notification_inbox_deliver(object::extend($base, { redirect: "//pirate.test/devis" })).error;
    LET $button = fn::notification_inbox_deliver(object::extend($base, { actions: [{ kind: "primary", label: "Valider", url: "javascript:alert(1)" }] })).error;
    LET $twice = fn::notification_inbox_deliver(object::extend($base, { actions: [{ kind: "primary", label: "A" }, { kind: "primary", label: "B" }] })).error;
    LET $data = fn::notification_inbox_deliver(object::extend($base, { data: { n: 1 } })).error;
    RETURN $redirect.code == "NOTIFICATION_INVALID_INPUT" AND $redirect.details.fields == { redirect: ["CORE_VALIDATION_FORMAT"] }
        AND $button.details.fields == { "actions.primary": ["CORE_VALIDATION_FORMAT"] }
        AND $twice.details.fields == { actions: ["CORE_VALIDATION_DUPLICATE"] }
        AND $data.code == "NOTIFICATION_INVALID_INPUT"
        AND count(SELECT id FROM notification_inbox) == 0
        AND (SELECT VALUE status FROM ONLY $job.id) == "running";
};

-- test: livraison : message du fil de la personne, étiquettes et gravité du parcours, trace d'envoi sans contenu, déclenchement terminé
-- en tant que: worker
{
    LET $job = (SELECT * FROM ONLY notification_job WHERE type = "in_app" AND status = "running" LIMIT 1);
    LET $r = fn::notification_inbox_deliver({ job_id: <string> $job.id, claim_token: $job.claim_token, title: "Devis D-1", text: "Le devis **D-1** est prêt",
        redirect: "/devis/D-1", actions: [{ kind: "primary", label: "Valider", url: "/devis/D-1/valider" }, { kind: "secondary", label: "Plus tard" }], data: { devis: "D-1" } }).data;
    LET $item = (SELECT * FROM ONLY $r.item);
    LET $message = (SELECT * FROM ONLY $r.messages[0]);
    RETURN $r.status == "completed" AND $r.run_status == "completed"
        AND $item.subscriber.subscriber_id == "auth:personne" AND $item.identity == auth_identity:personne AND $item.tenant == auth_organization:alpha
        AND $item.tags == ["devis"] AND $item.severity == "high" AND $item.workflow_key == "devis" AND $item.step_key == "fil"
        AND $item.action_status == { primary: "pending", secondary: "pending" } AND $item.seen_at IS NONE AND $item.read_at IS NONE
        AND $item.purge_after > time::now() + 89d
        AND $message.channel == "in_app" AND $message.to == "auth:personne" AND $message.subject IS NONE AND $message.integration IS NONE
        AND (SELECT VALUE status FROM ONLY $job.id) == "completed";
};

-- test: livraison rejouée (réservation déjà terminée) : refusée, aucun second message
-- en tant que: worker
{
    LET $job = (SELECT * FROM ONLY notification_job WHERE type = "in_app" AND run.idempotency_key = "devis-1" LIMIT 1);
    RETURN fn::notification_inbox_deliver({ job_id: <string> $job.id, claim_token: <string> rand::uuid::v7(), title: "x", text: "y" }).error.code == "NOTIFICATION_JOB_CLAIM_LOST"
        AND count(SELECT id FROM notification_inbox) == 1;
};

-- test: livraison réservée au worker ; événement notification.inbox.delivered avec identifiants seulement
-- en tant que: gestionnaire
{
    LET $job = (SELECT VALUE id FROM ONLY notification_job WHERE type = "in_app" LIMIT 1);
    RETURN fn::notification_inbox_deliver({ job_id: <string> $job, claim_token: <string> rand::uuid::v7(), title: "x", text: "y" }).error.code == "NOTIFICATION_PERMISSION_DENIED";
};

-- test: événement de livraison : identifiants seulement, jamais le titre ni le texte
{
    LET $payloads = (SELECT VALUE payload FROM event_outbox WHERE event_type = "notification.inbox.delivered");
    RETURN array::len($payloads) == 1 AND object::keys($payloads[0]) == ["item_id", "subscriber_id", "workflow_id"]
        AND !string::contains(<string> $payloads, "Devis D-1") AND !string::contains(<string> $payloads, "prêt");
};

-- test: la personne lit son fil : vue du message, boutons avec leur état, compteurs
-- en tant que: personne
{
    LET $list = fn::notification_feed_list({}).data;
    LET $item = $list.items[0];
    RETURN array::len($list.items) == 1 AND $list.next_cursor IS NONE
        AND $item.title == "Devis D-1" AND $item.text == "Le devis **D-1** est prêt" AND $item.redirect == "/devis/D-1"
        AND $item.workflow == "devis" AND $item.tags == ["devis"] AND $item.severity == "high" AND $item.data == { devis: "D-1" }
        AND $item.actions == [{ kind: "primary", label: "Valider", url: "/devis/D-1/valider", status: "pending" }, { kind: "secondary", label: "Plus tard", url: NONE, status: "pending" }]
        AND !$item.seen AND !$item.read AND !$item.archived
        AND object::keys($item) == ["actions", "archived", "archived_at", "avatar", "created_at", "data", "id", "read", "read_at", "redirect", "seen", "seen_at", "severity", "snoozed_until", "step_key", "tags", "text", "title", "workflow"]
        AND fn::notification_feed_counts({}).data == { unseen: 1, unread: 1, total: 1 };
};

-- test: une autre personne de la même organisation ne voit rien du fil d'autrui
-- en tant que: collegue
RETURN fn::notification_feed_list({}).data.items == []
    AND fn::notification_feed_counts({}).data == { unseen: 0, unread: 0, total: 0 }
    AND (SELECT * FROM notification_inbox) == []
    AND fn::notification_feed_mark({ ids: [<string> ((SELECT VALUE id FROM notification_inbox)[0] ?? "notification_inbox:inconnu")], state: "read" }).error.code == "NOTIFICATION_FEED_ITEM_NOT_FOUND";

-- test: un gestionnaire de l'organisation ne lit pas le fil d'autrui (il n'a que le journal, sans contenu)
-- en tant que: gestionnaire
RETURN fn::notification_feed_list({}).error.code == "NOTIFICATION_FEED_NO_ACCOUNT"
    AND (SELECT * FROM notification_inbox) == []
    AND (SELECT VALUE [channel, to, subject] FROM notification_message WHERE channel = "in_app") == [["in_app", "auth:personne", NONE]];

-- test: la même personne, avec une autre organisation active, ne voit pas le fil de la première
-- en tant que: ailleurs
RETURN fn::notification_feed_list({}).data.items == [] AND (SELECT * FROM notification_inbox) == [];

-- test: une autre organisation ne voit rien
-- en tant que: voisin
RETURN (SELECT * FROM notification_inbox) == [] AND fn::notification_feed_counts({}).error.code == "NOTIFICATION_FEED_NO_ACCOUNT";

-- test: une session sans compte (compte de service) n'a pas de fil
-- en tant que: service
RETURN fn::notification_feed_list({}).error.code == "NOTIFICATION_FEED_NO_ACCOUNT"
    AND fn::notification_feed_counts({}).error.code == "NOTIFICATION_FEED_NO_ACCOUNT"
    AND (SELECT * FROM notification_inbox) == [];

-- préparation: identifiant du message de la personne, lisible par tous pour les essais d'écriture directe
{
    DEFINE TABLE OVERWRITE essai_fil SCHEMALESS PERMISSIONS FULL;
    CREATE essai_fil:message CONTENT { item: (SELECT VALUE id FROM ONLY notification_inbox LIMIT 1) };
};

-- test: écritures directes refusées à une autre personne : modification et suppression filtrées, rien ne change
-- en tant que: collegue
{
    LET $item = (SELECT VALUE item FROM ONLY essai_fil:message);
    LET $updated = (UPDATE $item SET read_at = time::now(), archived_at = time::now());
    LET $deleted = (DELETE $item RETURN BEFORE);
    RETURN $updated == [] AND $deleted == [];
};

-- test: écritures directes refusées à un gestionnaire, à la même personne dans une autre organisation et à une autre organisation
{
    LET $item = (SELECT VALUE item FROM ONLY essai_fil:message);
    RETURN (SELECT VALUE [read_at, archived_at] FROM ONLY $item) == [NONE, NONE];
};

-- test: écriture directe d'un gestionnaire filtrée
-- en tant que: gestionnaire
{
    LET $item = (SELECT VALUE item FROM ONLY essai_fil:message);
    RETURN (UPDATE $item SET read_at = time::now()) == [] AND (DELETE $item RETURN BEFORE) == [];
};

-- test: écriture directe de la même personne dans une autre organisation filtrée
-- en tant que: ailleurs
{
    LET $item = (SELECT VALUE item FROM ONLY essai_fil:message);
    RETURN (UPDATE $item SET read_at = time::now()) == [] AND (DELETE $item RETURN BEFORE) == [];
};

-- test: écriture directe d'une autre organisation filtrée
-- en tant que: voisin
{
    LET $item = (SELECT VALUE item FROM ONLY essai_fil:message);
    RETURN (UPDATE $item SET read_at = time::now()) == [] AND (DELETE $item RETURN BEFORE) == [];
};

-- test: personne ne crée un message du fil hors du worker, même à son nom ou au nom d'un autre (abonné ou compte forgés)
-- en tant que: personne
{
    LET $mine = (CREATE notification_inbox CONTENT { tenant: auth_organization:alpha, subscriber: (SELECT VALUE id FROM ONLY notification_subscriber WHERE subscriber_id = "auth:personne" AND scope_key = "alpha" LIMIT 1),
        identity: auth_identity:personne, step_key: "fil", workflow: notification_workflow:devis, workflow_key: "devis", title: "Faux", text: "Faux", purge_after: time::now() + 1d });
    LET $forged = (CREATE notification_inbox CONTENT { tenant: auth_organization:alpha, subscriber: (SELECT VALUE id FROM ONLY notification_subscriber WHERE subscriber_id = "auth:personne" AND scope_key = "alpha" LIMIT 1),
        identity: auth_identity:collegue, step_key: "fil", workflow: notification_workflow:devis, workflow_key: "devis", title: "Faux", text: "Faux", purge_after: time::now() + 1d });
    RETURN $mine == [] AND $forged == [];
};

-- test: personne d'autre ne crée un message pour autrui
-- en tant que: gestionnaire
{
    LET $forged = (CREATE notification_inbox CONTENT { tenant: auth_organization:alpha, subscriber: (SELECT VALUE id FROM ONLY notification_subscriber WHERE subscriber_id = "auth:personne" AND scope_key = "alpha" LIMIT 1),
        identity: auth_identity:personne, step_key: "fil", workflow: notification_workflow:devis, workflow_key: "devis", title: "Faux", text: "Faux", purge_after: time::now() + 1d });
    RETURN $forged == [];
};

-- test: aucun message forgé n'a été créé
RETURN count(SELECT id FROM notification_inbox) == 1;

-- test: la personne change elle-même ses états par une écriture directe (les états seulement : le contenu est en lecture seule)
-- en tant que: personne
{
    LET $item = (SELECT VALUE item FROM ONLY essai_fil:message);
    LET $updated = (UPDATE ONLY $item SET seen_at = time::now());
    LET $reset = (UPDATE ONLY $item SET seen_at = NONE);
    RETURN $updated.seen_at IS NOT NONE AND $reset.seen_at IS NONE;
};

-- test: états : vu, lu (vu aussi), non lu, archivé (hors du fil par défaut, visible dans l'onglet des archivés), désarchivé
-- en tant que: personne
{
    LET $id = fn::notification_feed_list({}).data.items[0].id;
    LET $seen = fn::notification_feed_mark({ ids: [<string> $id], state: "seen" }).data;
    LET $after_seen = fn::notification_feed_counts({}).data;
    LET $read = fn::notification_feed_mark({ ids: [<string> $id], state: "read" }).data;
    LET $after_read = fn::notification_feed_list({}).data.items[0];
    LET $unread = fn::notification_feed_mark({ ids: [<string> $id], state: "unread" }).data;
    LET $after_unread = fn::notification_feed_counts({}).data;
    LET $archived = fn::notification_feed_mark({ ids: [<string> $id], state: "archived" }).data;
    LET $default_tab = fn::notification_feed_list({}).data.items;
    LET $archive_tab = fn::notification_feed_list({ filter: { archived: true } }).data.items;
    LET $unarchived = fn::notification_feed_mark({ ids: [<string> $id], state: "unarchived" }).data;
    RETURN $seen == { state: "seen", updated: 1 } AND $after_seen == { unseen: 0, unread: 1, total: 1 }
        AND $read.updated == 1 AND $after_read.read AND $after_read.seen AND $after_read.read_at IS NOT NONE
        AND $unread.updated == 1 AND $after_unread == { unseen: 0, unread: 1, total: 1 }
        AND $archived.updated == 1 AND $default_tab == [] AND array::len($archive_tab) == 1 AND $archive_tab[0].archived
        AND $unarchived.updated == 1 AND array::len(fn::notification_feed_list({}).data.items) == 1;
};

-- test: états : identifiants et « tous » exclusifs, état inconnu refusé, message inconnu refusé comme celui d'autrui
-- en tant que: personne
{
    LET $id = fn::notification_feed_list({}).data.items[0].id;
    RETURN fn::notification_feed_mark({ ids: [<string> $id], all: true, state: "read" }).error.code == "NOTIFICATION_INVALID_INPUT"
        AND fn::notification_feed_mark({ state: "read" }).error.code == "NOTIFICATION_INVALID_INPUT"
        AND fn::notification_feed_mark({ ids: [<string> $id], state: "oublie" }).error.code == "NOTIFICATION_INVALID_INPUT"
        AND fn::notification_feed_mark({ ids: ["notification_inbox:inconnu"], state: "read" }).error.code == "NOTIFICATION_FEED_ITEM_NOT_FOUND"
        AND fn::notification_feed_mark({ ids: [<string> $id, "notification_inbox:inconnu"], state: "read" }).error.code == "NOTIFICATION_FEED_ITEM_NOT_FOUND"
        AND fn::notification_feed_list({ filter: { couleur: "rouge" } }).error.code == "NOTIFICATION_INVALID_INPUT"
        AND fn::notification_feed_list({ limit: 0 }).error.code == "NOTIFICATION_INVALID_INPUT";
};

-- préparation: trois messages d'information et un second devis pour la personne, un message pour sa collègue
{
    FOR $n IN [1, 2, 3] {
        fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "info", idempotency_key: string::concat("info-", <string> $n), to: { subscriber_id: "auth:personne" }, payload: {} });
    };
    fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "devis", idempotency_key: "devis-2", to: { subscriber_id: "auth:personne" }, payload: { n: "D-2" } });
    fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "info", idempotency_key: "info-collegue", to: { subscriber_id: "auth:collegue" }, payload: {} });
};

-- préparation: le worker livre les messages en file
-- en tant que: worker
{
    FOR $job IN fn::notification_job_claim({ channel: "in_app", worker_id: "fil-1", limit: 10 }).data {
        fn::notification_inbox_deliver({ job_id: <string> $job.job_id, claim_token: $job.claim_token,
            title: IF $job.workflow_key = "devis" { "Devis D-2" } ELSE { "Info" }, text: IF $job.workflow_key = "devis" { "Le devis D-2" } ELSE { "Information" },
            actions: IF $job.workflow_key = "devis" { [{ kind: "primary", label: "Valider", url: "/devis/D-2/valider" }] } ELSE { [] },
            data: IF $job.workflow_key = "devis" { { devis: "D-2" } } ELSE { {} } });
    };
};

-- test: onglets : étiquettes, gravité, données, lus ; compteurs par onglet
-- en tant que: personne
{
    LET $tags = fn::notification_feed_list({ filter: { tags: ["devis"] } }).data.items;
    LET $severity = fn::notification_feed_list({ filter: { severity: ["low"] } }).data.items;
    LET $data = fn::notification_feed_list({ filter: { data: { devis: "D-2" } } }).data.items;
    LET $none = fn::notification_feed_list({ filter: { tags: ["inconnue"] } }).data.items;
    RETURN array::len($tags) == 2 AND $tags.data.devis == ["D-2", "D-1"]
        AND array::len($severity) == 3 AND array::all($severity, |$i| $i.workflow == "info")
        AND $data.title == ["Devis D-2"] AND $none == []
        AND fn::notification_feed_counts({}).data == { unseen: 4, unread: 5, total: 5 }
        AND fn::notification_feed_counts({ filter: { severity: ["high"] } }).data == { unseen: 1, unread: 2, total: 2 }
        AND fn::notification_feed_counts({ filter: { read: true } }).data.total == 0;
};

-- test: pagination : du plus récent au plus ancien, curseur jusqu'à la fin, sans doublon
-- en tant que: personne
{
    LET $first = fn::notification_feed_list({ limit: 2 }).data;
    LET $second = fn::notification_feed_list({ limit: 2, cursor: <string> $first.next_cursor }).data;
    LET $third = fn::notification_feed_list({ limit: 2, cursor: <string> $second.next_cursor }).data;
    LET $ids = array::concat(array::concat($first.items.id, $second.items.id), $third.items.id);
    RETURN array::len($first.items) == 2 AND $first.next_cursor == $first.items[1].id
        AND array::len($second.items) == 2 AND array::len($third.items) == 1 AND $third.next_cursor IS NONE
        AND array::len(array::distinct($ids)) == 5 AND $first.items[0].title == "Devis D-2" AND $third.items[0].title == "Devis D-1"
        AND $ids == array::sort::desc($ids);
};

-- test: actions groupées par onglet : tout marquer vu, tout marquer lu dans un onglet, archiver tous les lus
-- en tant que: personne
{
    LET $seen = fn::notification_feed_mark({ all: true, state: "seen" }).data.updated;
    LET $read = fn::notification_feed_mark({ all: true, filter: { tags: ["info"] }, state: "read" }).data.updated;
    LET $archived = fn::notification_feed_mark({ all: true, filter: { read: true }, state: "archived" }).data.updated;
    RETURN $seen == 5 AND $read == 3 AND $archived == 3
        AND fn::notification_feed_counts({}).data == { unseen: 0, unread: 2, total: 2 }
        AND fn::notification_feed_counts({ filter: { archived: true } }).data.total == 3;
};

-- test: les actions groupées de la personne n'ont pas touché le fil de sa collègue
-- en tant que: collegue
RETURN fn::notification_feed_counts({}).data == { unseen: 1, unread: 1, total: 1 };

-- test: sommeil : bornes de 3 minutes à 90 jours, message caché et hors des compteurs pendant le sommeil
-- en tant que: personne
{
    LET $id = fn::notification_feed_list({ filter: { tags: ["devis"] } }).data.items[0].id;
    fn::notification_feed_mark({ ids: [<string> $id], state: "read" });
    LET $short = fn::notification_feed_snooze({ id: <string> $id, until: time::now() + 2m }).error;
    LET $long = fn::notification_feed_snooze({ id: <string> $id, until: time::now() + 91d }).error.code;
    LET $past = fn::notification_feed_snooze({ id: <string> $id, until: time::now() - 1h }).error.code;
    LET $text = fn::notification_feed_snooze({ id: <string> $id, until: "demain" }).error.code;
    LET $snoozed = fn::notification_feed_snooze({ id: <string> $id, until: time::now() + 1h }).data;
    LET $list = fn::notification_feed_list({}).data.items.id;
    RETURN $short.code == "NOTIFICATION_SNOOZE_INVALID" AND $short.details.fields == { until: ["CORE_VALIDATION_TOO_SMALL"] }
        AND $long == "NOTIFICATION_SNOOZE_INVALID" AND $past == "NOTIFICATION_SNOOZE_INVALID" AND $text == "NOTIFICATION_INVALID_INPUT"
        AND $snoozed.snoozed_until > time::now() AND !$snoozed.read AND !$snoozed.seen
        AND $id NOT IN $list AND fn::notification_feed_counts({}).data == { unseen: 0, unread: 1, total: 1 };
};

-- préparation: la fin du sommeil arrive (horloge avancée sur le message)
UPDATE notification_inbox SET snoozed_until = time::now() - 1s WHERE snoozed_until IS NOT NONE;

-- test: à l'échéance, le message réapparaît seul, non vu et non lu (calculé à la lecture, sans worker)
-- en tant que: personne
{
    LET $woken = array::find(fn::notification_feed_list({}).data.items, |$i| $i.snoozed_until IS NOT NONE);
    RETURN $woken IS NOT NONE AND !$woken.read AND !$woken.seen
        AND fn::notification_feed_counts({}).data == { unseen: 1, unread: 2, total: 2 };
};

-- test: réveil immédiat ; sommeil d'un message d'autrui refusé comme un message absent
-- en tant que: personne
{
    LET $id = fn::notification_feed_list({ filter: { tags: ["devis"] } }).data.items[0].id;
    LET $snoozed = fn::notification_feed_snooze({ id: <string> $id, until: time::now() + 1d }).data;
    LET $hidden = fn::notification_feed_counts({}).data.total;
    LET $woken = fn::notification_feed_unsnooze({ id: <string> $id }).data;
    RETURN $snoozed.snoozed_until IS NOT NONE AND $hidden == 1 AND $woken.snoozed_until IS NONE AND !$woken.read
        AND fn::notification_feed_counts({}).data.total == 2
        AND fn::notification_feed_unsnooze({ id: "notification_inbox:inconnu" }).error.code == "NOTIFICATION_FEED_ITEM_NOT_FOUND";
};

-- test: sommeil d'un message d'autrui : même réponse qu'un message absent
-- en tant que: collegue
{
    LET $item = (SELECT VALUE item FROM ONLY essai_fil:message);
    RETURN fn::notification_feed_snooze({ id: <string> $item, until: time::now() + 1h }).error.code == "NOTIFICATION_FEED_ITEM_NOT_FOUND"
        AND fn::notification_feed_action({ id: <string> $item, action: "primary", status: "done" }).error.code == "NOTIFICATION_FEED_ITEM_NOT_FOUND"
        AND fn::notification_feed_delete({ id: <string> $item }).error.code == "NOTIFICATION_FEED_ITEM_NOT_FOUND";
};

-- test: boutons : état « fait » puis « annulé » enregistré ; bouton absent refusé
-- en tant que: personne
{
    LET $devis = fn::notification_feed_list({ filter: { data: { devis: "D-2" } } }).data.items[0].id;
    LET $info = fn::notification_feed_list({ filter: { tags: ["info"], archived: true } }).data.items[0].id;
    LET $done = fn::notification_feed_action({ id: <string> $devis, action: "primary", status: "done" }).data;
    LET $reverted = fn::notification_feed_action({ id: <string> $devis, action: "primary", status: "reverted" }).data;
    RETURN $done.actions == [{ kind: "primary", label: "Valider", url: "/devis/D-2/valider", status: "done" }]
        AND $reverted.actions[0].status == "reverted"
        AND fn::notification_feed_action({ id: <string> $devis, action: "secondary", status: "done" }).error.code == "NOTIFICATION_FEED_ACTION_INVALID"
        AND fn::notification_feed_action({ id: <string> $info, action: "primary", status: "done" }).error.code == "NOTIFICATION_FEED_ACTION_INVALID"
        AND fn::notification_feed_action({ id: <string> $devis, action: "primary", status: "pending" }).error.code == "NOTIFICATION_INVALID_INPUT";
};

-- test: événement notification.inbox.action : identifiants, bouton et état seulement
{
    LET $payloads = (SELECT VALUE payload FROM event_outbox WHERE event_type = "notification.inbox.action" ORDER BY created_at);
    RETURN array::len($payloads) == 2 AND $payloads.action == ["primary", "primary"] AND $payloads.status == ["done", "reverted"]
        AND object::keys($payloads[0]) == ["action", "item_id", "status"];
};

-- test: suppression : un message, puis tous ceux d'un onglet ; les autres restent
-- en tant que: personne
{
    LET $devis = fn::notification_feed_list({ filter: { data: { devis: "D-2" } } }).data.items[0].id;
    LET $one = fn::notification_feed_delete({ id: <string> $devis }).data;
    LET $again = fn::notification_feed_delete({ id: <string> $devis }).error.code;
    LET $archived = fn::notification_feed_delete({ all: true, filter: { archived: true } }).data;
    LET $both = fn::notification_feed_delete({ id: <string> $devis, all: true }).error.code;
    RETURN $one == { deleted: 1 } AND $again == "NOTIFICATION_FEED_ITEM_NOT_FOUND" AND $archived == { deleted: 3 }
        AND $both == "NOTIFICATION_INVALID_INPUT" AND fn::notification_feed_counts({}).data.total == 1;
};

-- test: le fil de la collègue est intact
RETURN count(SELECT id FROM notification_inbox WHERE subscriber.subscriber_id = "auth:collegue") == 1
    AND count(SELECT id FROM notification_inbox WHERE subscriber.subscriber_id = "auth:personne") == 1;

-- test: préférence in_app de la personne : l'étape du fil est écartée
-- en tant que: personne
RETURN fn::notification_my_preference_set({ tenant: "auth_organization:alpha", level: "subscriber_global", channels: { in_app: false } }).ok;

-- test: déclenchement après la préférence : étape in_app écartée (preference)
{
    LET $r = fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "devis", idempotency_key: "devis-pref", to: { subscriber_id: "auth:personne" }, payload: { n: "D-3" } }).data;
    LET $skipped = (SELECT VALUE skip_reason FROM ONLY notification_job WHERE run = $r.run_id LIMIT 1);
    LET $reset = fn::notification_preference_set({ tenant: "auth_organization:alpha", level: "subscriber_global", subscriber_id: "auth:personne", channels: { in_app: NULL } }).ok;
    RETURN $skipped == "preference:subscriber_global" AND $reset;
};

-- préparation: deux rappels pour la personne (fil, attente, e-mail si le message du fil n'est pas lu)
{
    fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "rappel", idempotency_key: "rappel-lu", to: { subscriber_id: "auth:personne" }, payload: {} });
    fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "rappel", idempotency_key: "rappel-non-lu", to: { subscriber_id: "auth:personne" }, payload: {} });
};

-- préparation: livraison des deux messages du fil
-- en tant que: worker
{
    FOR $job IN fn::notification_job_claim({ channel: "in_app", worker_id: "fil-1", limit: 10 }).data {
        fn::notification_inbox_deliver({ job_id: <string> $job.job_id, claim_token: $job.claim_token, title: "Rappel", text: $job.idempotency_key });
    };
};

-- test: contexte des conditions : vu et lu des étapes in_app (faux tant que la personne n'a rien fait)
{
    LET $run = (SELECT * FROM ONLY notification_run WHERE idempotency_key = "rappel-lu" LIMIT 1);
    LET $steps = fn::notification_step_context({ run: $run }).steps;
    RETURN $steps.fil == { status: "completed", seen: false, read: false } AND $steps.pause == { status: "queued" } AND $run.status == "waiting";
};

-- test: la personne lit l'un des deux messages
-- en tant que: personne
{
    LET $id = array::find(fn::notification_feed_list({}).data.items, |$i| $i.text == "rappel-lu").id;
    RETURN fn::notification_feed_mark({ ids: [<string> $id], state: "read" }).data.updated == 1;
};

-- test: « sauter si déjà lu » (C6) : fin de l'attente ; e-mail écarté pour le message lu, en file pour le message non lu
{
    LET $read_run = (SELECT VALUE id FROM ONLY notification_run WHERE idempotency_key = "rappel-lu" LIMIT 1);
    LET $unread_run = (SELECT VALUE id FROM ONLY notification_run WHERE idempotency_key = "rappel-non-lu" LIMIT 1);
    LET $context = fn::notification_step_context({ run: (SELECT * FROM ONLY $read_run) }).steps.fil;
    fn::notification_wait_end({ run: $read_run, step_key: "pause" });
    fn::notification_wait_end({ run: $unread_run, step_key: "pause" });
    RETURN $context == { status: "completed", seen: true, read: true }
        AND (SELECT VALUE [status, skip_reason] FROM ONLY notification_job WHERE run = $read_run AND step_key = "mail" LIMIT 1) == ["skipped", "condition"]
        AND (SELECT VALUE status FROM ONLY notification_job WHERE run = $unread_run AND step_key = "mail" LIMIT 1) == "queued";
};

-- préparation: un message pour une personne dont l'abonné est supprimé avant la livraison
{
    fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "info", idempotency_key: "info-partant", to: { subscriber_id: "auth:partant" }, payload: {} });
};

-- préparation: réservation de son étape
-- en tant que: worker
fn::notification_job_claim({ channel: "in_app", worker_id: "fil-1", limit: 10 });

-- préparation: l'abonné est supprimé
DELETE notification_subscriber WHERE subscriber_id = "auth:partant";

-- test: abonné supprimé avant la livraison : étape écartée, aucun message du fil
-- en tant que: worker
{
    LET $job = (SELECT * FROM ONLY notification_job WHERE run.idempotency_key = "info-partant" LIMIT 1);
    LET $r = fn::notification_inbox_deliver({ job_id: <string> $job.id, claim_token: $job.claim_token, title: "Info", text: "Information" }).data;
    RETURN $r.status == "skipped" AND $r.item IS NONE
        AND (SELECT VALUE [status, skip_reason] FROM ONLY $job.id) == ["skipped", "no_address:in_app"]
        AND count(SELECT id FROM notification_inbox WHERE run = $job.run) == 0;
};

-- test: conservation du fil : réglage de 1 à 365 jours, 90 par défaut
-- en tant que: gestionnaire
{
    LET $default = fn::notification_settings_get({ tenant: "auth_organization:alpha" }).data.effective.retention_days_inbox;
    LET $saved = fn::notification_settings_set({ tenant: "auth_organization:alpha", retention_days_inbox: 30 }).data.retention_days_inbox;
    LET $refused = fn::notification_settings_set({ tenant: "auth_organization:alpha", retention_days_inbox: 400 }).error.code;
    RETURN $default == 90 AND $saved == 30 AND $refused == "NOTIFICATION_INVALID_INPUT"
        AND fn::notification_settings_effective({ tenant: auth_organization:alpha }).retention_days_inbox == 30;
};

-- préparation: un message du fil arrivé au terme de sa conservation
CREATE notification_inbox CONTENT { tenant: auth_organization:alpha, subscriber: (SELECT VALUE id FROM ONLY notification_subscriber WHERE subscriber_id = "auth:collegue" LIMIT 1),
    identity: auth_identity:collegue, step_key: "fil", workflow: notification_workflow:info, workflow_key: "info", title: "Ancien", text: "Ancien", purge_after: time::now() - 1s };

-- test: purge : les messages du fil au-delà de leur conservation sont supprimés, les autres restent
{
    LET $count_before = count(SELECT id FROM notification_inbox);
    LET $purged = fn::notification_purge({ args: { limit: 100 } }).data.inbox_items;
    RETURN $purged == 1 AND count(SELECT id FROM notification_inbox) == $count_before - 1
        AND count(SELECT id FROM notification_inbox WHERE title = "Ancien") == 0;
};

-- test: fonctions internes : portée du fil, filtre, correspondance, vue, messages désignés et contrôle commun
-- en tant que: personne
{
    LET $scope = fn::notification_feed_scope({});
    LET $item = (SELECT * FROM notification_inbox LIMIT 1)[0];
    LET $now = time::now();
    LET $filter = fn::validation_object_execute({ filter: { tags: ["devis"] } }, { fields: { filter: fn::notification_feed_filter_fields({}) }, unknown_keys: "reject" }, 20);
    LET $mine = fn::notification_feed_mine({ subscriber: $scope.subscriber, ids: [$item.id], now: $now });
    LET $all = fn::notification_feed_mine({ subscriber: $scope.subscriber, all: true, filter: {}, now: $now });
    LET $targets = fn::notification_feed_targets({ ids: [$item.id] });
    RETURN $scope.code IS NONE AND $scope.identity == auth_identity:personne AND $scope.tenant == auth_organization:alpha
        AND $filter.valid AND $filter.value.filter == { tags: ["devis"], archived: false }
        AND fn::notification_feed_match({ item: $item, filter: {}, now: $now })
        AND !fn::notification_feed_match({ item: object::extend($item, { snoozed_until: $now + 1h }), filter: {}, now: $now })
        AND !fn::notification_feed_match({ item: $item, filter: { archived: true }, now: $now })
        AND fn::notification_feed_view({ item: $item }).id == $item.id
        AND $mine == [$item.id] AND array::len($all) >= 1
        AND $targets.code IS NONE AND $targets.ids == [$item.id]
        AND fn::notification_feed_targets({}).code == "NOTIFICATION_INVALID_INPUT";
};

-- test: fonctions internes des gabarits du fil
RETURN fn::validation_object_execute({ actions: [{ kind: "primary", label: "A", url: "/a" }] }, { fields: { actions: fn::notification_template_action_fields({}) }, unknown_keys: "reject" }, 20).valid
    AND fn::notification_template_feed_refusal({ subject: "T", text_body: "x", redirect: "/a" }) IS NONE
    AND fn::notification_template_feed_refusal({ subject: "T", text_body: "x", layout: notification_layout:x }).details.fields == { layout: ["CORE_VALIDATION_NOT_ALLOWED"] }
    AND fn::notification_template_channel_refusal({ channel: "sms", template: { text_body: "x", data: { a: "b" } } }).details.fields == { data: ["CORE_VALIDATION_NOT_ALLOWED"] };

-- préparation: un message du fil dont l'étape sera close sous un droit d'écriture retiré
fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "info", idempotency_key: "info-refus", to: { subscriber_id: "auth:collegue" }, payload: {} });

-- préparation: réservation de son étape
-- en tant que: worker
fn::notification_job_claim({ channel: "in_app", worker_id: "fil-1", limit: 10 });

-- préparation: écriture des étapes refusée (droit retiré entre la réservation et la livraison)
DEFINE TABLE OVERWRITE notification_job
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE fn::notification_can({ action: "read", tenant: run.tenant }) OR fn::notification_can({ action: "send", tenant: run.tenant })
        FOR create, update WHERE false
        FOR delete WHERE fn::notification_can({ action: "worker", tenant: run.tenant })
    COMMENT "Étapes engagées d'un déclenchement (file d'envoi, attentes)";

-- test: écriture filtrée par les permissions : clôture de l'étape du fil refusée (NOTIFICATION_WRITE_FORBIDDEN)
-- en tant que: worker
{
    LET $job = (SELECT * FROM ONLY notification_job WHERE run.idempotency_key = "info-refus" LIMIT 1);
    RETURN fn::notification_inbox_deliver({ job_id: <string> $job.id, claim_token: $job.claim_token, title: "Info", text: "Information" }).error.code == "NOTIFICATION_WRITE_FORBIDDEN";
};

-- préparation: droits des étapes rétablis
DEFINE TABLE OVERWRITE notification_job
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE fn::notification_can({ action: "read", tenant: run.tenant }) OR fn::notification_can({ action: "send", tenant: run.tenant })
        FOR create, update WHERE fn::notification_can({ action: "send", tenant: run.tenant }) OR fn::notification_can({ action: "manage", tenant: run.tenant })
        FOR delete WHERE fn::notification_can({ action: "worker", tenant: run.tenant })
    COMMENT "Étapes engagées d'un déclenchement (file d'envoi, attentes)";

-- test: l'étape refusée est restée réservée
RETURN (SELECT VALUE status FROM ONLY notification_job WHERE run.idempotency_key = "info-refus" LIMIT 1) == "running";
