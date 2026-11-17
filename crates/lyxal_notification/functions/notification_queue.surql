-- ============================================================================
-- FONCTIONS : file d'envoi (worker)
-- MODULE    : lyxal_notification
-- ============================================================================
-- Réservation par `locked_until` et `claim_token` : plusieurs workers se partagent la file sans
-- envoyer deux fois la même étape ; une réservation expirée est reprise. Le délai avant une
-- nouvelle tentative est calculé par le worker (attente exponentielle avec gigue, comme
-- lyxal_event) ; la base décide de la nouvelle tentative ou de l'échec définitif. Une étape
-- terminée fait avancer son déclenchement (fn::notification_run_advance). Seules les étapes de
-- canal passent par cette file ; les attentes passent par lyxal_scheduler
-- (fn::notification_wait_schedule). Permission notification.worker (ou session système).
-- Fil (`in_app`) : ni fournisseur, ni intégration, ni heures calmes (décision F8) ; l'étape est
-- terminée par fn::notification_inbox_deliver.
-- Un worker par canal (`channel` : email, sms, chat, webhook, in_app, push). Une étape de
-- messagerie, d'adresse web ou push sert toutes les adresses (appareils) actives de l'abonné pour
-- son canal (décisions E1, G1) : chacune avec l'intégration éligible de son service ; une adresse
-- déjà servie par une tentative précédente n'est pas rappelée.

-- ----------------------------------------------------------------------------
-- fn::notification_job_claim
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_job_claim($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            worker_id: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 128 } }], required: true },
            channel: { pipeline: [{ rule: "enum", options: { allowed: ["email", "sms", "chat", "webhook", "in_app", "push"], case_sensitive: true } }], required: true },
            limit: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 100 } }], default: 10 },
            lease_seconds: { pipeline: [{ rule: "integer", options: { min_value: 10, max_value: 3600 } }], default: 120 },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::notification_can({ action: "worker" }) { RETURN fn::error_result("NOTIFICATION_PERMISSION_DENIED", $p.language, {}); };
    LET $now = time::now();
    -- Étapes dont le secret a expiré : annulées, jamais envoyées en retard
    LET $channels = [$p.channel];
    LET $expired = (SELECT VALUE id FROM notification_job
        WHERE type IN $channels AND status IN ["queued", "running"] AND run.expires_at IS NOT NONE AND run.expires_at <= $now AND (locked_until IS NONE OR locked_until < $now));
    FOR $job IN $expired {
        UPDATE $job SET status = "canceled", locked_until = NONE, claim_token = NONE,
            last_error = { class: "permanent", code: "NOTIFICATION_RUN_EXPIRED", detail: "secret expiré avant l'envoi" };
        fn::notification_run_advance({ run: (SELECT VALUE run FROM ONLY $job) });
    };
    -- Déclenchement annulé : étapes en file ou à réservation expirée annulées, jamais renvoyées
    LET $orphans = (SELECT VALUE id FROM notification_job
        WHERE type IN $channels AND status IN ["queued", "running"] AND run.status = "canceled" AND (locked_until IS NONE OR locked_until < $now));
    FOR $job IN $orphans {
        UPDATE $job SET status = "canceled", skip_reason = "canceled", locked_until = NONE, claim_token = NONE;
    };
    -- Réservation expirée après la dernière tentative (worker arrêté pendant l'envoi) : échec définitif
    LET $abandoned = (SELECT VALUE id FROM notification_job
        WHERE type IN $channels AND status = "running" AND locked_until < $now AND attempts >= max_attempts);
    FOR $job IN $abandoned {
        UPDATE $job SET status = "failed", locked_until = NONE, claim_token = NONE,
            last_error = { class: "transient", code: "NOTIFICATION_JOB_LEASE_EXPIRED", detail: "réservation expirée après la dernière tentative" };
        fn::notification_run_advance({ run: (SELECT VALUE run FROM ONLY $job) });
    };
    LET $due = (SELECT VALUE id FROM notification_job
        WHERE type IN $channels AND status IN ["queued", "running"] AND attempts < max_attempts AND next_retry_at <= $now AND (locked_until IS NONE OR locked_until < $now)
        ORDER BY next_retry_at LIMIT $p.limit);
    -- Réservation conditionnelle : si un autre worker l'a prise entre-temps, l'étape est ignorée
    LET $claim = <string> rand::uuid::v7();
    FOR $job IN $due {
        UPDATE $job SET status = "running", locked_until = $now + duration::from_secs($p.lease_seconds),
            claim_token = $claim, worker_id = $p.worker_id, attempts += 1
            WHERE status IN ["queued", "running"] AND attempts < max_attempts AND (locked_until IS NONE OR locked_until < $now);
    };
    LET $claimed = (SELECT * FROM notification_job WHERE claim_token = $claim ORDER BY next_retry_at);
    -- Préférences relues à la réservation : un choix fait depuis le déclenchement est respecté
    LET $ready = array::filter(array::map($claimed, |$job| {
        LET $run = (SELECT tenant, workflow, subscriber FROM ONLY $job.run);
        LET $workflow = (SELECT * FROM ONLY $run.workflow);
        LET $subscriber = IF $run.subscriber IS NONE { NONE } ELSE { (SELECT * FROM ONLY $run.subscriber) };
        LET $decision = fn::notification_preference_resolve({ tenant: $run.tenant, workflow: $workflow, subscriber: $subscriber });
        LET $choice = $decision.channels[$job.type];
        IF !$choice.allowed {
            UPDATE $job.id SET status = "skipped", skip_reason = string::concat("preference:", $choice.level),
                locked_until = NONE, claim_token = NONE, attempts -= 1;
            fn::notification_run_advance({ run: $job.run });
            RETURN NONE;
        };
        -- Fil : ni intégration, ni adresse, ni heures calmes (F8)
        IF $job.type = "in_app" {
            RETURN fn::notification_job_payload({ job: $job, workflow: $workflow, quiet_hours: NONE, integration: NONE });
        };
        -- Intégration de l'envoi (D1, bascule D3) ; aucune : l'étape attend en file, sans tentative comptée
        LET $integrations = fn::notification_integration_for_job({ job: $job });
        -- Messagerie, adresse web, push : adresses (appareils) actives de l'abonné pas encore
        -- servies, chacune avec l'intégration éligible de son service
        LET $multi = $job.type IN ["chat", "webhook", "push"];
        LET $endpoints = IF $multi AND array::len($integrations) > 0 {
            fn::notification_job_endpoints({ job: $job, subscriber: $run.subscriber, tenant: $run.tenant, integrations: $integrations })
        } ELSE { { served: 0, pending: 0, ready: [] } };
        -- Plus aucune adresse à servir : terminée si une adresse a été servie (reprise), sinon
        -- écartée ; une adresse restante sans intégration de son service fait attendre l'étape
        IF $multi AND array::len($integrations) > 0 AND array::len($endpoints.ready) = 0
            AND $endpoints.pending = 0 {
            UPDATE $job.id SET status = IF $endpoints.served > 0 { "completed" } ELSE { "skipped" },
                skip_reason = IF $endpoints.served > 0 { NONE } ELSE { string::concat("no_address:", $job.type) },
                locked_until = NONE, claim_token = NONE, attempts -= 1;
            fn::notification_run_advance({ run: $job.run });
            RETURN NONE;
        };
        -- Aucune intégration (ou aucune pour le service des adresses restantes) : l'étape attend
        IF array::len($integrations) = 0 OR ($multi AND array::len($endpoints.ready) = 0) {
            UPDATE $job.id SET status = "queued", locked_until = NONE, claim_token = NONE, attempts -= 1,
                next_retry_at = time::now() + 1m,
                last_error = { class: "transient", code: "NOTIFICATION_INTEGRATION_UNAVAILABLE", detail: "aucune intégration éligible pour ce canal" };
            RETURN NONE;
        };
        LET $integration = IF $multi { array::find($integrations, |$i| $i.id = $endpoints.ready[0].integration.id) } ELSE { $integrations[0] };
        -- Pas d'heures calmes pour l'adresse web (appel de machine à machine, décision E7)
        RETURN object::extend(
            fn::notification_job_payload({ job: $job, workflow: $workflow, quiet_hours: IF $job.type = "webhook" { NONE } ELSE { $decision.quiet_hours }, integration: $integration }),
            { endpoints: $endpoints.ready ?? [], served_endpoints: $endpoints.served ?? 0 });
    }), |$payload| $payload IS NOT NONE);
    RETURN fn::result_ok($ready);
} COMMENT "Réserve jusqu'à limit étapes dues d'un canal ({ worker_id, channel : email, sms, chat, webhook, in_app, push ; limit, lease_seconds }) et renvoie tout le nécessaire au rendu (heures calmes, sauf pour l'adresse web et le fil ; fil : sans intégration ni secret ; cible du désabonnement ; intégration de l'envoi ; adresses scellées de messagerie ou web et appareils push (jeton et clés scellés), chacun avec l'intégration de son service ; hôtes autorisés de l'installation) ; les étapes dont le secret a expiré sont annulées, celles qu'une préférence refuse désormais sont écartées ; une étape sans intégration éligible reste en file (nouvel essai dans une minute, sans tentative comptée) ; une étape dont toutes les adresses sont déjà servies est terminée. Permission notification.worker";

-- ----------------------------------------------------------------------------
-- fn::notification_job_endpoints (interne) : adresses d'une étape de messagerie ou web
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_job_endpoints($params: object) -> object {
    LET $served = (SELECT VALUE endpoint FROM notification_message WHERE job = $params.job.id AND endpoint IS NOT NONE);
    LET $pending = IF $params.subscriber IS NONE { [] } ELSE {
        (SELECT * FROM notification_endpoint
            WHERE subscriber = $params.subscriber AND tenant = $params.tenant AND channel = $params.job.type AND active = true AND id NOTINSIDE $served
            ORDER BY created_at ASC LIMIT 10)
    };
    -- Intégration de chaque adresse : la première éligible de son service (ordre D1, bascule D3)
    LET $paired = array::filter(array::map($pending, |$e| {
        endpoint: $e, integration: array::find($params.integrations, |$i| $i.provider = $e.provider)
    }), |$x| $x.integration IS NOT NONE);
    RETURN {
        served: array::len($served),
        pending: array::len($pending),
        ready: array::map($paired, |$x| fn::notification_endpoint_payload({ endpoint: $x.endpoint, integration: $x.integration }))
    };
} COMMENT "Interne : adresses actives d'une étape de messagerie, web ou push ({ job, subscriber, tenant : organisation du déclenchement, integrations }) pas encore servies (10 au plus), chacune avec la première intégration éligible de son service : { served, pending, ready }";

-- ----------------------------------------------------------------------------
-- fn::notification_job_payload : données de rendu d'une étape réservée (langue résolue)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_job_payload($params: object) -> object {
    LET $job = $params.job;
    LET $run = (SELECT * FROM ONLY $job.run);
    LET $workflow = $params.workflow ?? (SELECT * FROM ONLY $run.workflow);
    LET $template = (SELECT * FROM ONLY notification_template WHERE workflow = $workflow.id AND step_key = $job.step_key LIMIT 1);
    -- Langue de l'envoi : celle du destinataire, sinon celle de son organisation (notée sur le
    -- déclenchement par la base), sinon la langue
    -- par défaut de l'installation ; textes des clés du gabarit dans cette langue (surcharge de
    -- l'organisation, repli de lyxal_i18n)
    LET $chosen = fn::i18n_locale_resolve({ candidates: array::filter([$run.address.locale, $run.organization_locale], |$l| $l IS NOT NONE) });
    LET $locale = IF $chosen.ok { $chosen.data.locale } ELSE { NONE };
    LET $texts = IF $locale IS NONE OR array::len($template.keys ?? []) = 0 { { ok: true, data: [] } } ELSE {
        fn::i18n_resolve_many({ keys: $template.keys, locale: $locale, tenant: IF $run.tenant IS NONE { NONE } ELSE { <string> $run.tenant } })
    };
    LET $layout = IF $template.layout IS NONE { NONE } ELSE { (SELECT html, text FROM ONLY $template.layout) };
    RETURN {
        job_id: $job.id,
        claim_token: $job.claim_token,
        run_id: $run.id,
        tenant: $run.tenant,
        tenant_key: IF $run.tenant IS NONE { NONE } ELSE { <string> record::id($run.tenant) },
        organization_name: IF $run.tenant IS NONE { NONE } ELSE { (SELECT VALUE name FROM ONLY $run.tenant) },
        idempotency_key: $run.idempotency_key,
        attempt: $job.attempts,
        channel: $job.type,
        step_key: $job.step_key,
        workflow_key: $workflow.key,
        subscriber_id: IF $run.subscriber IS NONE { NONE } ELSE { (SELECT VALUE subscriber_id FROM ONLY $run.subscriber) },
        recipient: { email: $run.address.email, phone: $run.address.phone, locale: $run.address.locale, name: $run.address.name },
        -- Hôtes autorisés de l'installation (adresses web et Mattermost, décision E3)
        allowed_hosts: fn::notification_settings_effective({}).allowed_hosts,
        locale: $locale,
        subject: $template.subject,
        html_body: $template.html_body,
        text_body: $template.text_body,
        texts: IF $texts.ok { $texts.data } ELSE { [] },
        texts_error: IF $chosen.ok { IF $texts.ok { NONE } ELSE { $texts.error.code } } ELSE { $chosen.error.code },
        layout_html: $layout.html,
        layout_text: $layout.text,
        -- Fil : avatar, lien de redirection, boutons et données (gabarits)
        avatar: $template.avatar,
        redirect: $template.redirect,
        actions: $template.actions ?? [],
        data_templates: $template.data ?? {},
        -- Push : icône (gabarit)
        icon: $template.icon,
        payload: $run.payload,
        -- Le fil (F3) et le push (G4 : contenu remis à Google ou Apple) ne portent jamais le
        -- secret du déclenchement
        secret: IF $job.type IN ["in_app", "push"] { NONE } ELSE { $run.secret },
        sensitive: $workflow.sensitive,
        critical: $workflow.critical,
        quiet_hours: $params.quiet_hours,
        -- Intégration de l'envoi : fournisseur, réglages (expéditeur), chemin du secret des identifiants
        integration: IF $params.integration IS NONE { NONE } ELSE { fn::notification_integration_payload($params.integration) },
        -- Regroupement porté par ce déclenchement : nombre et données des événements
        digest: IF $run.digest IS NONE { NONE } ELSE { (SELECT count, events.{ payload, at } AS events FROM ONLY $run.digest WHERE carrier = $run.id) },
        -- Désabonnement en un clic (hors parcours critique) : catégorie du parcours, sinon le parcours
        unsubscribe: IF $workflow.critical OR $run.subscriber IS NONE { NONE } ELSE {
            {
                scope: $run.scope_key,
                subscriber: $run.subscriber,
                category: $workflow.category,
                workflow: IF $workflow.category IS NONE { $workflow.id } ELSE { NONE },
                channel: $job.type
            }
        }
    };
} COMMENT "Données de rendu d'une étape réservée ({ job, workflow, quiet_hours, integration : absente pour le fil }) : canal, étape, parcours, abonné, destinataire (e-mail, téléphone), hôtes autorisés de l'installation, intégration de l'envoi, gabarit (fil : avatar, lien, boutons, données ; jamais le secret ; push : lien, icône, données), regroupement porté ({ count, events }), langue de l'envoi (destinataire, organisation, installation), textes des clés du gabarit dans cette langue (texts ; texts_error : code I18N_* si leur lecture a échoué), mise en page, secret scellé, heures calmes, cible du lien de désabonnement (NONE pour un parcours critique)";

-- ----------------------------------------------------------------------------
-- fn::notification_job_check : réservation encore détenue ?
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_job_check($params: object) -> object {
    LET $job = (SELECT * FROM ONLY $params.job);
    IF $job == NONE { RETURN { code: "NOTIFICATION_NOT_FOUND", job: NONE }; };
    IF $job.status != "running" OR $job.claim_token != $params.claim_token { RETURN { code: "NOTIFICATION_JOB_CLAIM_LOST", job: NONE }; };
    RETURN { code: NONE, job: $job };
} COMMENT "Vérifie qu'une étape ({ job, claim_token }) est encore réservée par ce jeton ; { code, job }";

-- ----------------------------------------------------------------------------
-- fn::notification_job_endpoint_fields (interne) : issue de chaque adresse servie
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_job_endpoint_fields($params: object) -> object {
    RETURN { pipeline: [{ rule: "array_objects", options: { allow_empty_objects: false } }, { rule: "array_length", options: { max_length: 10 } },
        { rule: "each", options: { pipeline: [{ rule: "object", options: { schema: {
            fields: {
                endpoint: { pipeline: [{ rule: "record", options: { expected_table: "notification_endpoint" } }], required: true },
                integration: { pipeline: [{ rule: "record", options: { expected_table: "notification_integration" } }], required: true },
                ok: { pipeline: [{ rule: "boolean" }], required: true },
                code: { pipeline: [{ rule: "optional_string", options: { max_length: 64 } }] },
                provider_message_id: { pipeline: [{ rule: "optional_string", options: { max_length: 512 } }] },
                response_code: { pipeline: [{ rule: "integer", options: { min_value: 100, max_value: 599 } }] }
            },
            unknown_keys: "reject"
        } } }] } }], default: [] };
} COMMENT "Interne : champ endpoints de notification_job_complete et _fail : issue de chaque adresse de messagerie ou web servie ({ endpoint, integration, ok, code, provider_message_id, response_code }, 10 au plus)";

-- ----------------------------------------------------------------------------
-- fn::notification_job_endpoint_record (interne) : messages et dernier résultat des adresses
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_job_endpoint_record($params: object) -> option<string> {
    LET $outcomes = array::map($params.results, |$r| {
        LET $endpoint = (SELECT id, host, provider, channel, platform FROM ONLY $r.endpoint);
        IF $endpoint == NONE { RETURN "skipped"; };
        LET $noted = (UPDATE ONLY $endpoint.id SET last_result = { at: time::now(), ok: $r.ok, code: $r.code ?? IF $r.response_code IS NONE { NONE } ELSE { <string> $r.response_code } });
        IF $noted == NONE { RETURN "NOTIFICATION_WRITE_FORBIDDEN"; };
        IF !$r.ok { RETURN "noted"; };
        -- Message de l'adresse servie : son hôte, jamais l'adresse complète ; appareil push : son
        -- type (service et plateforme), jamais le jeton
        LET $to = IF $endpoint.channel = "push" { string::concat($endpoint.provider, ":", $endpoint.platform) } ELSE { $endpoint.host };
        LET $message = (CREATE ONLY notification_message CONTENT {
            run: $params.run.id, job: $params.job.id, channel: $params.job.type, to: $to, endpoint: $endpoint.id,
            subject: $params.subject, integration: $r.integration, provider: $endpoint.provider,
            provider_message_id: $r.provider_message_id, status: "sent"
        });
        RETURN IF $message == NONE { "NOTIFICATION_WRITE_FORBIDDEN" } ELSE { "sent" };
    });
    RETURN array::find($outcomes, |$o| $o NOT IN ["skipped", "noted", "sent"]);
} COMMENT "Interne : pour chaque adresse servie ({ job, run, subject, results }) : dernier résultat noté sur l'adresse, message (hôte de l'adresse, ou type d'un appareil push ; intégration, identifiant chez le service) pour un appel réussi ; une adresse supprimée entre-temps (appareil retiré) est ignorée. NONE, ou NOTIFICATION_WRITE_FORBIDDEN";

-- ----------------------------------------------------------------------------
-- fn::notification_job_complete
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_job_complete($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            job_id: { pipeline: [{ rule: "record", options: { expected_table: "notification_job" } }], required: true },
            claim_token: { pipeline: [{ rule: "uuid_v7", options: { allow_string: true } }], required: true },
            integration: { pipeline: [{ rule: "record", options: { expected_table: "notification_integration" } }], required: true },
            provider_message_id: { pipeline: [{ rule: "optional_string", options: { max_length: 512 } }] },
            response_code: { pipeline: [{ rule: "integer", options: { min_value: 200, max_value: 599 } }] },
            subject: { pipeline: [{ rule: "optional_string", options: { max_length: 998 } }] },
            parts: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 10 } }] },
            endpoints: fn::notification_job_endpoint_fields({}),
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::notification_can({ action: "worker" }) { RETURN fn::error_result("NOTIFICATION_PERMISSION_DENIED", $p.language, {}); };
    LET $check = fn::notification_job_check({ job: $p.job_id, claim_token: <string> $p.claim_token });
    IF $check.code IS NOT NONE { RETURN fn::error_result($check.code, $p.language, {}); };
    LET $job = $check.job;
    LET $run = (SELECT * FROM ONLY $job.run);
    LET $sensitive = (SELECT VALUE sensitive FROM ONLY $run.workflow);
    LET $settings = fn::notification_settings_effective({ tenant: $run.tenant });
    LET $integration = (SELECT id, provider FROM ONLY $p.integration);
    LET $subject = IF $sensitive { NONE } ELSE { $p.subject };
    -- Messagerie, adresse web, push : un message par adresse servie ; e-mail, SMS : un message
    IF $job.type IN ["chat", "webhook", "push"] {
        IF !array::any($p.endpoints, |$r| $r.ok) AND count(SELECT VALUE id FROM notification_message WHERE job = $job.id) = 0 {
            RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", $p.language, { fields: { endpoints: ["CORE_VALIDATION_REQUIRED"] } });
        };
        LET $recorded = fn::notification_job_endpoint_record({ job: $job, run: $run, subject: $subject, results: $p.endpoints });
        IF $recorded IS NOT NONE { RETURN fn::error_result($recorded, $p.language, { table: "notification_message" }); };
    } ELSE {
        LET $message = (CREATE ONLY notification_message CONTENT {
            run: $run.id,
            job: $job.id,
            channel: $job.type,
            to: IF $job.type = "sms" { $run.address.phone } ELSE { $run.address.email },
            subject: $subject,
            integration: $integration.id,
            provider: $integration.provider,
            provider_message_id: $p.provider_message_id,
            parts: IF $job.type = "sms" { $p.parts } ELSE { NONE },
            status: "sent"
        });
        IF $message == NONE { RETURN fn::error_result("NOTIFICATION_WRITE_FORBIDDEN", $p.language, { table: "notification_message" }); };
        -- Retours du fournisseur reçus avant cet enregistrement (webhook plus rapide que le worker)
        LET $reconciled = fn::notification_provider_event_reconcile({ integration: $integration.id, provider_message_id: $p.provider_message_id, message: $message.id, tenant: $run.tenant });
        IF $reconciled IS NOT NONE { RETURN fn::error_result($reconciled, $p.language, { table: "notification_provider_event" }); };
    };
    CREATE notification_delivery_log CONTENT {
        run: $run.id, job: $job.id, attempt: $job.attempts, status: "sent",
        code: IF $p.response_code IS NONE { NONE } ELSE { <string> $p.response_code },
        purge_after: time::now() + duration::from_days($settings.retention_days_log)
    };
    UPDATE $job.id SET status = "completed", locked_until = NONE, claim_token = NONE, last_error = NONE, integration = $integration.id;
    LET $next = fn::notification_run_advance({ run: $run.id });
    RETURN fn::result_ok({ messages: (SELECT VALUE id FROM notification_message WHERE job = $job.id ORDER BY sent_at), status: "completed", run_status: IF $next.status IN ["completed", "failed", "skipped", "canceled", "merged"] { $next.status } ELSE { NONE } });
} COMMENT "Termine une étape envoyée ({ job_id, claim_token, integration, provider_message_id, response_code : code SMTP ou HTTP, subject, parts : SMS, endpoints : messagerie, adresse web et push, issue de chaque adresse servie }) : message (destinataire : e-mail, téléphone, hôte de chaque adresse servie ou type de chaque appareil push ; intégration, fournisseur, identifiant chez le fournisseur ; objet omis si sensible), dernier résultat des adresses, journal, puis étape suivante du déclenchement ; déclenchement terminé et secret effacé si c'était la dernière étape (run_status). Renvoie { messages, status, run_status }. Permission notification.worker";

-- ----------------------------------------------------------------------------
-- fn::notification_job_fail
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_job_fail($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            job_id: { pipeline: [{ rule: "record", options: { expected_table: "notification_job" } }], required: true },
            claim_token: { pipeline: [{ rule: "uuid_v7", options: { allow_string: true } }], required: true },
            integration: { pipeline: [{ rule: "record", options: { expected_table: "notification_integration" } }] },
            class: { pipeline: [{ rule: "enum", options: { allowed: ["transient", "permanent", "recipient_rejected", "recipient_opted_out"], case_sensitive: true } }], required: true },
            code: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 64 } }], required: true },
            detail: { pipeline: [{ rule: "optional_string", options: { max_length: 512 } }], default: "" },
            retry_delay_seconds: { pipeline: [{ rule: "integer", options: { min_value: 0, max_value: 86400 } }], default: 60 },
            endpoints: fn::notification_job_endpoint_fields({}),
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::notification_can({ action: "worker" }) { RETURN fn::error_result("NOTIFICATION_PERMISSION_DENIED", $p.language, {}); };
    LET $check = fn::notification_job_check({ job: $p.job_id, claim_token: <string> $p.claim_token });
    IF $check.code IS NOT NONE { RETURN fn::error_result($check.code, $p.language, {}); };
    LET $job = $check.job;
    LET $run = (SELECT * FROM ONLY $job.run);
    LET $settings = fn::notification_settings_effective({ tenant: $run.tenant });
    -- Messagerie, adresse web : adresses déjà servies par cette tentative enregistrées (elles ne
    -- sont pas rappelées à la suivante) et dernier résultat de chacune
    IF array::len($p.endpoints) > 0 {
        LET $recorded = fn::notification_job_endpoint_record({ job: $job, run: $run, subject: NONE, results: $p.endpoints });
        IF $recorded IS NOT NONE { RETURN fn::error_result($recorded, $p.language, { table: "notification_message" }); };
    };
    -- Déclenchement annulé pendant l'envoi : aucune nouvelle tentative
    LET $canceled = $run.status = "canceled";
    LET $retry = !$canceled AND $p.class = "transient" AND $job.attempts < $job.max_attempts;
    LET $next = time::now() + duration::from_secs($p.retry_delay_seconds);
    LET $error = { class: $p.class, code: $p.code, detail: $p.detail ?? "" };
    LET $status = IF $retry { "queued" } ELSE IF $canceled { "canceled" } ELSE { "failed" };
    -- Intégration de cette tentative : la suivante passe à la prochaine éligible (bascule D3)
    LET $integration = IF $p.integration IS NOT NONE AND record::exists($p.integration) { $p.integration } ELSE { NONE };
    IF $retry {
        UPDATE $job.id SET status = "queued", next_retry_at = $next, locked_until = NONE, claim_token = NONE, last_error = $error, integration = $integration;
    } ELSE {
        UPDATE $job.id SET status = $status, locked_until = NONE, claim_token = NONE, last_error = $error, integration = $integration;
    };
    CREATE notification_delivery_log CONTENT {
        run: $run.id, job: $job.id, attempt: $job.attempts, status: IF $retry { "retry" } ELSE { "failed" },
        code: $p.code, detail: $p.detail,
        purge_after: time::now() + duration::from_days($settings.retention_days_log)
    };
    -- Destinataire refusé (adresse ou numéro invalide) ou désinscrit chez l'opérateur (STOP) :
    -- adresse ou numéro supprimé (rejet définitif ou plainte)
    LET $address = IF $job.type = "sms" { $run.address.phone } ELSE IF $job.type = "email" { $run.address.email } ELSE { NONE };
    IF $p.class IN ["recipient_rejected", "recipient_opted_out"] AND $address IS NOT NONE {
        INSERT IGNORE INTO notification_suppression {
            tenant: $run.tenant, channel: $job.type, address: string::lowercase($address),
            reason: IF $p.class = "recipient_opted_out" { "complaint" } ELSE { "hard_bounce" }, source: $p.code
        };
    };
    LET $final = IF $retry { { status: NONE } } ELSE { fn::notification_run_advance({ run: $run.id }) };
    RETURN fn::result_ok({
        status: $status,
        next_retry_at: IF $retry { $next } ELSE { NONE },
        run_status: $final.status
    });
} COMMENT "Enregistre l'échec d'une étape ({ job_id, claim_token, integration (absente pour le fil), class : transient, permanent, recipient_rejected, recipient_opted_out ; code, detail, retry_delay_seconds, endpoints : issue de chaque adresse de messagerie ou web servie par cette tentative }) : intégration notée (après un échec temporaire, la tentative suivante passe à l'intégration éligible suivante, D3) ; adresses déjà servies enregistrées (non rappelées) ; nouvelle tentative tant que attempts < max_attempts pour un échec temporaire, sinon échec définitif ; déclenchement annulé entre-temps : étape annulée, sans nouvelle tentative ; destinataire refusé : adresse ou numéro supprimé (hard_bounce) ; désinscrit chez l'opérateur : numéro supprimé (complaint). Permission notification.worker";

-- ----------------------------------------------------------------------------
-- fn::notification_purge
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_purge($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            args: { pipeline: [{ rule: "is_object" }, { rule: "object", options: { schema: {
                fields: { limit: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 10000 } }], default: 1000 } },
                unknown_keys: "reject"
            } } }], default: {} },
            run: { pipeline: [{ rule: "record_id", options: { allowed_tables: ["scheduler_run"] } }] },
            tenant: { pipeline: [{ rule: "record_id", options: { allowed_tables: ["auth_organization"] } }] },
            scheduled_for: { pipeline: [{ rule: "datetime" }] },
            attempt: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 100 } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 30);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::notification_can({ action: "worker" }) { RETURN fn::error_result("NOTIFICATION_PERMISSION_DENIED", $p.language, {}); };
    LET $limit = $p.args.limit ?? 1000;
    LET $now = time::now();
    LET $secrets = (UPDATE notification_run SET secret = NONE WHERE secret IS NOT NONE AND expires_at IS NOT NONE AND expires_at <= $now RETURN id);
    LET $log_ids = (SELECT VALUE id FROM notification_delivery_log WHERE purge_after <= $now LIMIT $limit);
    LET $logs = IF array::len($log_ids) = 0 { [] } ELSE { (DELETE $log_ids RETURN BEFORE) };
    LET $run_ids = (SELECT VALUE id FROM notification_run WHERE purge_after <= $now AND status NOT IN ["pending", "waiting"] LIMIT $limit);
    LET $runs = IF array::len($run_ids) = 0 { [] } ELSE { (DELETE $run_ids RETURN BEFORE) };
    LET $broadcast_ids = (SELECT VALUE id FROM notification_broadcast WHERE purge_after <= $now AND status = "completed" LIMIT $limit);
    LET $broadcasts = IF array::len($broadcast_ids) = 0 { [] } ELSE { (DELETE $broadcast_ids RETURN BEFORE) };
    LET $digest_ids = (SELECT VALUE id FROM notification_digest WHERE status = "closed" AND purge_after <= $now LIMIT $limit);
    LET $digests = IF array::len($digest_ids) = 0 { [] } ELSE { (DELETE $digest_ids RETURN BEFORE) };
    LET $counter_ids = (SELECT VALUE id FROM notification_rate_limit WHERE purge_after <= $now LIMIT $limit);
    LET $counters = IF array::len($counter_ids) = 0 { [] } ELSE { (DELETE $counter_ids RETURN BEFORE) };
    LET $event_ids = (SELECT VALUE id FROM notification_provider_event WHERE purge_after <= $now LIMIT $limit);
    LET $events = IF array::len($event_ids) = 0 { [] } ELSE { (DELETE $event_ids RETURN BEFORE) };
    -- Fil : messages au-delà de leur conservation (retention_days_inbox, décision F8)
    LET $inbox_ids = (SELECT VALUE id FROM notification_inbox WHERE purge_after <= $now LIMIT $limit);
    LET $inbox = IF array::len($inbox_ids) = 0 { [] } ELSE { (DELETE $inbox_ids RETURN BEFORE) };
    RETURN fn::result_ok({
        secrets_cleared: array::len($secrets), log_entries: array::len($logs), runs: array::len($runs),
        broadcasts: array::len($broadcasts), digests: array::len($digests), rate_limits: array::len($counters),
        provider_events: array::len($events), inbox_items: array::len($inbox)
    });
} COMMENT "Purge par paquets, appelée par lyxal_scheduler (tâche notification.purge, planification horaire notification-purge) avec { args : { limit : 1000 par défaut }, run, tenant, scheduled_for, attempt } : secrets expirés effacés ; journal, déclenchements terminés (étapes, messages et regroupements portés avec eux), diffusions terminées, regroupements fermés, compteurs de limitation expirés, retours des fournisseurs et messages du fil (retention_days_inbox) supprimés au-delà de leur conservation. Permission notification.worker (session système du moteur)";

-- ----------------------------------------------------------------------------
-- fn::notification_job_renew : réservation renouvelée juste avant l'envoi
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_job_renew($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            job_id: { pipeline: [{ rule: "record", options: { expected_table: "notification_job" } }], required: true },
            claim_token: { pipeline: [{ rule: "uuid_v7", options: { allow_string: true } }], required: true },
            lease_seconds: { pipeline: [{ rule: "integer", options: { min_value: 10, max_value: 3600 } }], default: 120 },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::notification_can({ action: "worker" }) { RETURN fn::error_result("NOTIFICATION_PERMISSION_DENIED", $p.language, {}); };
    -- Conditionnel : une reprise par un autre worker a remplacé le jeton
    LET $renewed = (UPDATE ONLY $p.job_id SET locked_until = time::now() + duration::from_secs($p.lease_seconds)
        WHERE status = "running" AND claim_token = <string> $p.claim_token);
    IF $renewed == NONE { RETURN fn::error_result("NOTIFICATION_JOB_CLAIM_LOST", $p.language, {}); };
    RETURN fn::result_ok({ locked_until: $renewed.locked_until });
} COMMENT "Renouvelle la réservation d'une étape ({ job_id, claim_token, lease_seconds }) juste avant son envoi ; NOTIFICATION_JOB_CLAIM_LOST si un autre worker l'a reprise. Permission notification.worker";

-- ----------------------------------------------------------------------------
-- fn::notification_job_release : étape réservée rendue à la file sans tentative (arrêt du worker)
-- ----------------------------------------------------------------------------

DEFINE FUNCTION OVERWRITE fn::notification_job_release($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            job_id: { pipeline: [{ rule: "record", options: { expected_table: "notification_job" } }], required: true },
            claim_token: { pipeline: [{ rule: "uuid_v7", options: { allow_string: true } }], required: true },
            not_before: { pipeline: [{ rule: "future_datetime", options: { allow_equal: false } }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 20);
    IF !$report.valid {
        RETURN fn::error_result("NOTIFICATION_INVALID_INPUT", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    IF !fn::notification_can({ action: "worker" }) { RETURN fn::error_result("NOTIFICATION_PERMISSION_DENIED", $p.language, {}); };
    LET $released = (UPDATE ONLY $p.job_id SET status = "queued", locked_until = NONE, claim_token = NONE, attempts -= 1,
        next_retry_at = $p.not_before ?? next_retry_at
        WHERE status = "running" AND claim_token = <string> $p.claim_token);
    IF $released == NONE { RETURN fn::error_result("NOTIFICATION_JOB_CLAIM_LOST", $p.language, {}); };
    RETURN fn::result_ok({ status: "queued", next_retry_at: $released.next_retry_at });
} COMMENT "Rend à la file une étape réservée et non commencée ({ job_id, claim_token, not_before }), sans compter de tentative : arrêt du worker, ou heures calmes de l'abonné (reprise à not_before). Permission notification.worker";
