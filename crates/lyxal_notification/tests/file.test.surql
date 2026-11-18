-- lyxal-test: assertions
-- File d'envoi : réservation (langue de l'envoi et textes des clés, une étape réservée une seule fois), succès
-- (message, journal, secret effacé, événement), échec temporaire puis définitif, destinataire
-- refusé (suppression), échec définitif, secret expiré, réservation expirée, purge.
--
-- identité worker: { "id": "auth_session:worker", "pv": 1, "permissions": ["notification.worker", "i18n.translation.read"] }
-- identité admin: { "id": "auth_session:admin", "pv": 1, "permissions": ["notification.read", "notification.manage", "notification.send"] }

-- préparation: organisation, sessions, réglages, parcours et deux déclenchements
{
    CREATE notification_integration:relais CONTENT { key: "relais", channel: "email", provider: "smtp", name: "Relais", primary: true, settings: { from_address: "noreply@lyxal.test", host: "127.0.0.1", port: 2525, security: "local_plain" }, credentials_path: "notification/smtp/relais" };
    CREATE auth_organization:alpha CONTENT { slug: "alpha", name: "Alpha BTP" };
    CREATE auth_identity:worker CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "worker@lyxal.test" } };
    CREATE auth_identity:admin CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "admin@alpha.test" } };
    RELATE auth_identity:admin->auth_member_of->auth_organization:alpha;
    CREATE auth_session:worker CONTENT { identity: auth_identity:worker, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_session:admin CONTENT { identity: auth_identity:admin, organization: auth_organization:alpha, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    fn::notification_settings_set({ tenant: "auth_organization:alpha", max_attempts: 2 });
    CREATE notification_workflow:devis CONTENT { tenant: auth_organization:alpha, key: "devis", name: "Devis", status: "active", steps: [{ key: "email", type: "email" }] };
    CREATE notification_template:devis_email CONTENT { tenant: auth_organization:alpha, workflow: notification_workflow:devis, step_key: "email", subject: "Devis {{ payload.n }}", html_body: "<p>{{ t(\"notification.common.greeting\") }}</p>", text_body: "Devis", keys: ["notification.common.greeting"] };
    fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "devis", idempotency_key: "devis-1", to: { subscriber_id: "email:client@exemple.fr", email: "client@exemple.fr", locale: "en-GB" }, payload: { n: "D-1" }, secret: "enc:v2:cle-2026:AAAAAAAAAAAAAAAAAAAAAAAA" });
    fn::notification_trigger({ tenant: "auth_organization:alpha", trigger_event: "auth.invitation.created", idempotency_key: "invit-1", to: { subscriber_id: "email:invitee@exemple.fr", email: "invitee@exemple.fr", locale: "de" }, payload: { invitation_id: "i", organization_name: "Alpha BTP" }, secret: "enc:v2:cle-2026:BBBBBBBBBBBBBBBBBBBBBBBB", expires_at: time::now() + 1d });
    DEFINE TABLE test_ref SCHEMALESS PERMISSIONS FULL;
};

-- préparation: l'organisation remplace un texte de l'e-mail d'invitation
fn::i18n_translation_set({ key: "notification.auth_invitation.action", locale: "fr", tenant: "auth_organization:alpha", text: "Rejoindre Alpha BTP" });

-- test: réservation des deux étapes : langue de l'envoi, textes des clés (surcharge de l'organisation), mise en page, réglages et secret scellé
-- en tant que: worker
{
    LET $jobs = fn::notification_job_claim({ channel: "email", worker_id: "w1", limit: 10, lease_seconds: 60 }).data;
    LET $devis = $jobs.find(|$j| $j.idempotency_key = "devis-1");
    LET $invit = $jobs.find(|$j| $j.idempotency_key = "invit-1");
    CREATE test_ref:devis CONTENT { job: $devis.job_id, token: $devis.claim_token };
    CREATE test_ref:invit CONTENT { job: $invit.job_id, token: $invit.claim_token };
    RETURN array::len($jobs) == 2
        AND $devis.{ locale, subject, sensitive, attempt, layout_html, secret, texts_error }
            == { locale: "en", subject: "Devis {{ payload.n }}", sensitive: false, attempt: 1, layout_html: NONE, secret: "enc:v2:cle-2026:AAAAAAAAAAAAAAAAAAAAAAAA", texts_error: NONE }
        -- Intégration de l'envoi : celle de l'installation (repli), sans aucun secret
        AND $devis.integration == { id: notification_integration:relais, tenant: NONE, key: "relais", channel: "email", provider: "smtp", settings: { from_address: "noreply@lyxal.test", host: "127.0.0.1", port: 2525, security: "local_plain" }, credentials_path: "notification/smtp/relais", webhook_path: NONE }
        AND $devis.texts == [{ key: "notification.common.greeting", text: "Hello,", syntax: "plain", locale: "en", overridden: false, missing: false }]
        -- Langue du destinataire inactive (de) : langue par défaut de l'installation
        AND $invit.{ locale, sensitive, tenant, texts_error } == { locale: "fr", sensitive: true, tenant: auth_organization:alpha, texts_error: NONE }
        AND $invit.texts.find(|$t| $t.key = "notification.auth_invitation.action").{ text, overridden } == { text: "Rejoindre Alpha BTP", overridden: true }
        AND $invit.texts.find(|$t| $t.key = "notification.auth_invitation.subject").{ text, syntax, overridden } == { text: "Invitation à rejoindre {organization}", syntax: "icu_mf1", overridden: false }
        AND string::contains($invit.layout_html, "{{ content }}") AND $invit.payload.organization_name == "Alpha BTP";
};

-- test: une étape réservée ne l'est pas une seconde fois
-- en tant que: worker
RETURN fn::notification_job_claim({ channel: "email", worker_id: "w2" }).data == [];

-- test: la file est réservée au worker
-- en tant que: admin
RETURN fn::notification_job_claim({ channel: "email", worker_id: "w1" }).error.code == "NOTIFICATION_PERMISSION_DENIED"
    AND fn::notification_purge({}).error.code == "NOTIFICATION_PERMISSION_DENIED";

-- test: un jeton de réservation périmé est refusé
-- en tant que: worker
RETURN fn::notification_job_complete({ job_id: <string> test_ref:devis.job, claim_token: "01a1bca0-0000-7000-8000-000000000000", integration: "notification_integration:relais" }).error.code == "NOTIFICATION_JOB_CLAIM_LOST";

-- test: envoi réussi : message avec objet, étape et déclenchement terminés
-- en tant que: worker
{
    LET $r = fn::notification_job_complete({ job_id: <string> test_ref:devis.job, claim_token: test_ref:devis.token, integration: "notification_integration:relais", provider_message_id: "<abc@smtp>", response_code: 250, subject: "Quote D-1" }).data;
    RETURN $r.status == "completed" AND $r.run_status == "completed"
        AND (SELECT VALUE [to, subject, status, provider_message_id] FROM ONLY $r.messages[0]) == ["client@exemple.fr", "Quote D-1", "sent", "<abc@smtp>"];
};

-- test: secret effacé, journal et événement notification.message.sent sans contenu
{
    LET $run = (SELECT * FROM ONLY notification_run WHERE idempotency_key = "devis-1" LIMIT 1);
    LET $e = (SELECT * FROM ONLY event_outbox WHERE event_type = "notification.message.sent" LIMIT 1);
    RETURN $run.secret IS NONE AND $run.status == "completed"
        AND (SELECT VALUE [status, code, attempt] FROM notification_delivery_log WHERE run = $run.id) == [["sent", "250", 1]]
        AND $e.payload.run_id == <string> $run.id AND $e.payload.tenant == "auth_organization:alpha"
        AND !object::keys($e.payload).any(|$k| $k IN ["subject", "secret", "to"]);
};

-- test: étape terminée : un second achèvement est refusé
-- en tant que: worker
RETURN fn::notification_job_complete({ job_id: <string> test_ref:devis.job, claim_token: test_ref:devis.token, integration: "notification_integration:relais" }).error.code == "NOTIFICATION_JOB_CLAIM_LOST";

-- test: parcours sensible : aucun objet conservé
-- en tant que: worker
{
    LET $r = fn::notification_job_complete({ job_id: <string> test_ref:invit.job, claim_token: test_ref:invit.token, integration: "notification_integration:relais", subject: "Invitation à rejoindre Alpha BTP" }).data;
    RETURN (SELECT VALUE subject FROM ONLY $r.messages[0]) IS NONE;
};

-- préparation: déclenchement pour l'échec temporaire
fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "devis", idempotency_key: "retry-1", to: { subscriber_id: "email:lent@exemple.fr", email: "lent@exemple.fr" }, payload: { n: "D-2" }, secret: "enc:v2:cle-2026:CCCCCCCCCCCCCCCCCCCCCCCC" });

-- test: échec temporaire : nouvelle tentative programmée
-- en tant que: worker
{
    LET $job = fn::notification_job_claim({ channel: "email", worker_id: "w1" }).data[0];
    LET $r = fn::notification_job_fail({ job_id: <string> $job.job_id, claim_token: $job.claim_token, integration: "notification_integration:relais", class: "transient", code: "NOTIFICATION_SMTP_TRANSIENT", detail: "421 service indisponible", retry_delay_seconds: 0 }).data;
    RETURN $r.status == "queued" AND $r.next_retry_at IS NOT NONE AND $r.run_status IS NONE;
};

-- test: dernière tentative échouée : échec définitif, secret effacé, événement notification.message.failed
-- en tant que: worker
{
    LET $job = fn::notification_job_claim({ channel: "email", worker_id: "w1" }).data[0];
    LET $r = fn::notification_job_fail({ job_id: <string> $job.job_id, claim_token: $job.claim_token, integration: "notification_integration:relais", class: "transient", code: "NOTIFICATION_SMTP_TRANSIENT", detail: "421", retry_delay_seconds: 0 }).data;
    RETURN $job.attempt == 2 AND $r.status == "failed" AND $r.run_status == "failed";
};

-- test: journal des deux tentatives ; secret effacé ; événement d'échec publié
{
    LET $run = (SELECT * FROM ONLY notification_run WHERE idempotency_key = "retry-1" LIMIT 1);
    RETURN (SELECT VALUE status FROM notification_delivery_log WHERE run = $run.id ORDER BY attempt) == ["retry", "failed"]
        AND $run.secret IS NONE
        AND (SELECT VALUE payload.error_code FROM event_outbox WHERE event_type = "notification.message.failed") == ["NOTIFICATION_SMTP_TRANSIENT"];
};

-- préparation: déclenchements pour le destinataire refusé et l'échec définitif
{
    fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "devis", idempotency_key: "rejet-1", to: { subscriber_id: "email:absent@exemple.fr", email: "Absent@Exemple.fr" }, payload: { n: "D-3" } });
    fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "devis", idempotency_key: "permanent-1", to: { subscriber_id: "email:x@exemple.fr", email: "x@exemple.fr" }, payload: { n: "D-4" } });
};

-- test: destinataire refusé : échec définitif dès la première tentative, adresse supprimée
-- en tant que: worker
{
    LET $jobs = fn::notification_job_claim({ channel: "email", worker_id: "w1" }).data;
    LET $rejet = $jobs.find(|$j| $j.idempotency_key = "rejet-1");
    LET $perm = $jobs.find(|$j| $j.idempotency_key = "permanent-1");
    LET $a = fn::notification_job_fail({ job_id: <string> $rejet.job_id, claim_token: $rejet.claim_token, integration: "notification_integration:relais", class: "recipient_rejected", code: "550", detail: "5.1.1 utilisateur inconnu" }).data;
    LET $b = fn::notification_job_fail({ job_id: <string> $perm.job_id, claim_token: $perm.claim_token, integration: "notification_integration:relais", class: "permanent", code: "NOTIFICATION_RENDER_FAILED", detail: "variable inconnue" }).data;
    RETURN $a.status == "failed" AND $b.status == "failed";
};

-- test: adresse refusée ajoutée à la liste de suppression de l'organisation (rejet définitif)
-- en tant que: admin
RETURN fn::notification_suppression_list({ tenant: "auth_organization:alpha" }).data.map(|$s| [$s.address, $s.reason, $s.source]) == [["absent@exemple.fr", "hard_bounce", "550"]];

-- test: entrées invalides refusées
-- en tant que: worker
RETURN fn::notification_job_fail({ job_id: <string> test_ref:devis.job, claim_token: test_ref:devis.token, integration: "notification_integration:relais", class: "inconnue", code: "X" }).error.code == "NOTIFICATION_INVALID_INPUT"
    AND fn::notification_job_claim({ channel: "email", worker_id: "", limit: 1000 }).error.code == "NOTIFICATION_INVALID_INPUT";

-- préparation: déclenchement dont le secret expire avant l'envoi
{
    LET $r = fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "devis", idempotency_key: "expire-1", to: { subscriber_id: "email:tard@exemple.fr", email: "tard@exemple.fr" }, payload: { n: "D-5" }, secret: "enc:v2:cle-2026:DDDDDDDDDDDDDDDDDDDDDDDD" }).data;
    UPDATE $r.run_id SET expires_at = time::now() - 1m;
};

-- test: secret expiré : étape annulée sans envoi en retard, déclenchement abandonné, secret effacé
-- en tant que: worker
{
    LET $jobs = fn::notification_job_claim({ channel: "email", worker_id: "w1" }).data;
    LET $run = (SELECT * FROM ONLY notification_run WHERE idempotency_key = "expire-1" LIMIT 1);
    LET $job = (SELECT * FROM ONLY notification_job WHERE run = $run.id LIMIT 1);
    RETURN $jobs == [] AND $job.status == "canceled" AND $job.last_error.code == "NOTIFICATION_RUN_EXPIRED"
        AND $run.status == "skipped" AND $run.secret IS NONE;
};

-- préparation: deux déclenchements pour les réservations expirées
{
    fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "devis", idempotency_key: "bail-1", to: { subscriber_id: "email:a@exemple.fr", email: "a@exemple.fr" }, payload: { n: "D-6" } });
    fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "devis", idempotency_key: "bail-2", to: { subscriber_id: "email:b@exemple.fr", email: "b@exemple.fr" }, payload: { n: "D-7" } });
};

-- test: réservation des deux étapes
-- en tant que: worker
{
    LET $jobs = fn::notification_job_claim({ channel: "email", worker_id: "w1" }).data;
    CREATE test_ref:bail1 CONTENT { job: $jobs.find(|$j| $j.idempotency_key = "bail-1").job_id, token: $jobs.find(|$j| $j.idempotency_key = "bail-1").claim_token };
    RETURN array::len($jobs) == 2;
};

-- préparation: worker arrêté : réservations expirées, la seconde après sa dernière tentative
{
    UPDATE notification_job SET locked_until = time::now() - 1s WHERE run.idempotency_key IN ["bail-1", "bail-2"];
    UPDATE notification_job SET attempts = 2 WHERE run.idempotency_key = "bail-2";
};

-- test: réservation expirée reprise par un autre worker ; après la dernière tentative : échec définitif
-- en tant que: worker
{
    LET $jobs = fn::notification_job_claim({ channel: "email", worker_id: "w2" }).data;
    LET $lost = (SELECT * FROM ONLY notification_job WHERE run.idempotency_key = "bail-2" LIMIT 1);
    RETURN $jobs.idempotency_key == ["bail-1"] AND $jobs[0].attempt == 2
        AND $lost.status == "failed" AND $lost.last_error.code == "NOTIFICATION_JOB_LEASE_EXPIRED";
};

-- test: l'ancien worker ne peut plus terminer l'étape reprise
-- en tant que: worker
RETURN fn::notification_job_complete({ job_id: <string> test_ref:bail1.job, claim_token: test_ref:bail1.token, integration: "notification_integration:relais" }).error.code == "NOTIFICATION_JOB_CLAIM_LOST";

-- test: réservation renouvelée avant l'envoi ; jeton périmé refusé ; étape rendue sans tentative comptée
-- en tant que: worker
{
    LET $r = fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "devis", idempotency_key: "renouv-1", to: { subscriber_id: "email:r@exemple.fr", email: "r@exemple.fr" }, payload: { n: "D-8" } }).data;
    LET $job = fn::notification_job_claim({ channel: "email", worker_id: "w3", lease_seconds: 10 }).data[0];
    LET $renewed = fn::notification_job_renew({ job_id: <string> $job.job_id, claim_token: $job.claim_token, lease_seconds: 600 }).data;
    LET $stale = fn::notification_job_renew({ job_id: <string> $job.job_id, claim_token: "01a1bca0-0000-7000-8000-000000000000" });
    LET $released = fn::notification_job_release({ job_id: <string> $job.job_id, claim_token: $job.claim_token }).data;
    LET $job_after = (SELECT status, attempts, claim_token FROM ONLY $job.job_id);
    RETURN $renewed.locked_until > time::now() + 500s AND $stale.error.code == "NOTIFICATION_JOB_CLAIM_LOST"
        AND $released.status == "queued" AND $job_after == { status: "queued", attempts: 0, claim_token: NONE }
        AND fn::notification_job_release({ job_id: <string> $job.job_id, claim_token: $job.claim_token }).error.code == "NOTIFICATION_JOB_CLAIM_LOST";
};

-- préparation: durées de conservation écoulées pour deux déclenchements terminés et le journal
{
    UPDATE notification_run SET purge_after = time::now() - 1s WHERE idempotency_key IN ["devis-1", "retry-1"];
    LET $log = (SELECT * FROM ONLY notification_delivery_log WHERE run.idempotency_key = "rejet-1" LIMIT 1);
    CREATE notification_delivery_log CONTENT { run: $log.run, job: $log.job, attempt: 0, status: "retry", code: "ancien", purge_after: time::now() - 1s };
};

-- test: purge : déclenchements terminés (étapes, messages et journal avec eux) et journal expiré
-- en tant que: worker
{
    LET $r = fn::notification_purge({ args: { limit: 100 } }).data;
    RETURN $r.runs == 2 AND $r.log_entries == 1;
};

-- test: aucune trace des déclenchements purgés
RETURN array::len(SELECT * FROM notification_run WHERE idempotency_key IN ["devis-1", "retry-1"]) == 0
    AND array::len(SELECT * FROM notification_job WHERE run.idempotency_key IN ["devis-1", "retry-1"]) == 0
    AND array::len(SELECT * FROM notification_message WHERE to = "client@exemple.fr") == 0
    AND (SELECT VALUE code FROM notification_delivery_log WHERE run.idempotency_key = "rejet-1") == ["550"]
    AND array::len(SELECT * FROM notification_run WHERE idempotency_key = "invit-1") == 1;

-- préparation: langue de l'organisation
UPDATE auth_organization:alpha SET locale = "en";

-- préparation: déclenchement pour un destinataire sans langue
fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "devis", idempotency_key: "devis-sans-langue", to: { subscriber_id: "email:sans-langue@exemple.fr", email: "sans-langue@exemple.fr" }, payload: { n: "D-9" }, secret: "enc:v2:cle-2026:AAAAAAAAAAAAAAAAAAAAAAAA" });

-- test: le worker (compte de service, sans droit de lire l'organisation) envoie dans la langue de l'organisation
-- en tant que: worker
{
    LET $job = fn::notification_job_claim({ channel: "email", worker_id: "w1", limit: 10, lease_seconds: 60 }).data.find(|$j| $j.idempotency_key = "devis-sans-langue");
    RETURN array::len(SELECT VALUE id FROM auth_organization) == 0
        AND $job.{ locale, texts_error } == { locale: "en", texts_error: NONE }
        AND $job.texts.text == ["Hello,"];
};

-- préparation: déclenchement dont l'étape sera close sous un droit d'écriture retiré
fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "devis", idempotency_key: "devis-refus", to: { subscriber_id: "email:refus@exemple.fr", email: "refus@exemple.fr" }, payload: { n: "D-10" }, secret: "enc:v2:cle-2026:AAAAAAAAAAAAAAAAAAAAAAAA" });

-- test: le worker réserve l'étape
-- en tant que: worker
{
    LET $job = fn::notification_job_claim({ channel: "email", worker_id: "w1", limit: 10, lease_seconds: 60 }).data.find(|$j| $j.idempotency_key = "devis-refus");
    CREATE test_ref:refus CONTENT { job: $job.job_id, token: $job.claim_token };
    RETURN $job.job_id IS NOT NONE;
};

-- préparation: écriture des étapes refusée (droit retiré entre la réservation et la clôture)
DEFINE TABLE OVERWRITE notification_job
    TYPE NORMAL
    SCHEMAFULL
    PERMISSIONS
        FOR select WHERE fn::notification_can({ action: "read", tenant: run.tenant }) OR fn::notification_can({ action: "send", tenant: run.tenant })
        FOR create, update WHERE false
        FOR delete WHERE fn::notification_can({ action: "worker", tenant: run.tenant })
    COMMENT "Étapes engagées d'un déclenchement (file d'envoi, attentes)";

-- test: écriture filtrée par les permissions : clôture de l'étape refusée, à l'échec comme au succès (NOTIFICATION_WRITE_FORBIDDEN)
-- en tant que: worker
RETURN fn::notification_job_fail({ job_id: <string> test_ref:refus.job, claim_token: test_ref:refus.token, integration: "notification_integration:relais", class: "permanent", code: "X" }).error.code == "NOTIFICATION_WRITE_FORBIDDEN"
    AND fn::notification_job_complete({ job_id: <string> test_ref:refus.job, claim_token: test_ref:refus.token, integration: "notification_integration:relais" }).error.code == "NOTIFICATION_WRITE_FORBIDDEN";

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
RETURN (SELECT VALUE status FROM ONLY test_ref:refus.job) == "running";

-- préparation: deux lignes de journal échues, la plus ancienne créée en dernier
{
    LET $log = (SELECT * FROM ONLY notification_delivery_log WHERE run.idempotency_key = "rejet-1" LIMIT 1);
    CREATE notification_delivery_log:a_recente CONTENT { run: $log.run, job: $log.job, attempt: 0, status: "retry", code: "recente", purge_after: time::now() - 1h };
    CREATE notification_delivery_log:z_ancienne CONTENT { run: $log.run, job: $log.job, attempt: 0, status: "retry", code: "ancienne", purge_after: time::now() - 2h };
};

-- test: purge par paquets : la ligne échue depuis le plus longtemps part la première
-- en tant que: worker
RETURN fn::notification_purge({ args: { limit: 1 } }).data.log_entries == 1;

-- test: la ligne la plus récente attend le paquet suivant
RETURN (SELECT VALUE code FROM notification_delivery_log WHERE code IN ["recente", "ancienne"]) == ["recente"];
