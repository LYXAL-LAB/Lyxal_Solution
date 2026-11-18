-- lyxal-test: assertions
-- Intégrations : création et contrôles des réglages, chemin du secret et droit de le lire
-- (D2), principale unique, modification, suppression ; choix d'une intégration pour un envoi
-- (D1 : organisation, repli sur l'installation, condition, priorité), bascule après un échec
-- temporaire (D3), envoi qui attend faute d'intégration ; retours des fournisseurs
-- (dédoublonnage, état du message, suppression sur rejet et plainte, retour inconnu) ; essai
-- (D6) ; droits (organisation, installation, autre organisation, sans droit) ; écritures filtrées.
--
-- identité admin: { "id": "auth_session:admin", "pv": 1, "permissions": ["notification.read", "notification.manage", "notification.send", "secrets.value.read"] }
-- identité gestion: { "id": "auth_session:gestion", "pv": 1, "permissions": ["notification.read", "notification.manage"] }
-- identité lecteur: { "id": "auth_session:lecteur", "pv": 1, "permissions": ["notification.read"] }
-- identité autre: { "id": "auth_session:autre", "pv": 1, "permissions": ["notification.read", "notification.manage", "secrets.value.read"] }
-- identité plateforme: { "id": "auth_session:plateforme", "pv": 1, "permissions": ["notification.installation.manage", "secrets.installation.manage"] }
-- identité plateforme_seule: { "id": "auth_session:plateforme_seule", "pv": 1, "permissions": ["notification.installation.manage"] }
-- identité worker: { "id": "auth_session:worker", "pv": 1, "permissions": ["notification.worker", "i18n.translation.read"] }

-- préparation: organisations, sessions, secrets du coffre-fort, parcours et gabarit
{
    CREATE auth_organization:alpha CONTENT { slug: "alpha", name: "Alpha BTP" };
    CREATE auth_organization:beta CONTENT { slug: "beta", name: "Beta Bois" };
    FOR $name IN ["admin", "gestion", "lecteur", "autre", "plateforme", "plateforme_seule", "worker"] {
        LET $identity = type::record("auth_identity", $name);
        CREATE $identity CONTENT { schema: auth_identity_schema:default_v1, traits: { email: string::concat($name, "@lyxal.test") } };
        LET $org = IF $name IN ["admin", "gestion", "lecteur"] { auth_organization:alpha } ELSE IF $name = "autre" { auth_organization:beta } ELSE { NONE };
        IF $org IS NOT NONE { RELATE $identity->auth_member_of->$org; };
        CREATE type::record("auth_session", $name) CONTENT { identity: $identity, organization: $org, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    };
    fn::secrets_secret_create({ tenant: "auth_organization:alpha", path: "notification/brevo/api", kind: "api_key", consumers: ["lyxal_notification"] });
    fn::secrets_secret_create({ tenant: "auth_organization:alpha", path: "notification/postmark/api", kind: "api_key" });
    fn::secrets_secret_create({ tenant: "auth_organization:alpha", path: "notification/resend/api", kind: "api_key" });
    fn::secrets_secret_create({ tenant: "auth_organization:alpha", path: "notification/brevo/webhook", kind: "password" });
    fn::secrets_secret_create({ tenant: "auth_organization:alpha", path: "autre/dossier/api", kind: "api_key" });
    fn::secrets_secret_create({ tenant: "auth_organization:beta", path: "notification/brevo/api", kind: "api_key" });
    fn::secrets_secret_create({ tenant: "auth_organization:alpha", path: "notification/smtp/restreint", kind: "password", visibility: "restricted" });
    fn::secrets_secret_create({ tenant: "auth_organization:alpha", path: "notification/smtp/visible", kind: "password", visibility: "revealable" });
    fn::secrets_secret_create({ path: "notification/smtp/relais", kind: "password" });
    fn::secrets_secret_create({ path: "notification/mailgun/api", kind: "api_key" });
    CREATE notification_workflow:devis CONTENT { tenant: auth_organization:alpha, key: "devis", name: "Devis", status: "active", steps: [{ key: "email", type: "email" }] };
    CREATE notification_template:devis_email CONTENT { tenant: auth_organization:alpha, workflow: notification_workflow:devis, step_key: "email", subject: "Devis", html_body: "<p>Devis</p>", text_body: "Devis" };
    CREATE notification_workflow:annonce CONTENT { key: "annonce", name: "Annonce", status: "active", steps: [{ key: "email", type: "email" }] };
    CREATE notification_template:annonce_email CONTENT { workflow: notification_workflow:annonce, step_key: "email", subject: "Annonce", html_body: "<p>A</p>", text_body: "A" };
    DEFINE TABLE test_ref SCHEMALESS PERMISSIONS FULL;
};

-- test: aucune intégration : l'envoi attend en file, sans tentative comptée
-- en tant que: worker
{
    fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "devis", idempotency_key: "attente-1", to: { subscriber_id: "c0", email: "c0@exemple.fr" } });
    LET $claimed = fn::notification_job_claim({ channel: "email", worker_id: "w1", limit: 10 }).data;
    LET $job = (SELECT * FROM ONLY notification_job WHERE run.idempotency_key = "attente-1" LIMIT 1);
    RETURN $claimed == []
        AND $job.{ status, attempts, locked_until, claim_token } == { status: "queued", attempts: 0, locked_until: NONE, claim_token: NONE }
        AND $job.last_error.code == "NOTIFICATION_INTEGRATION_UNAVAILABLE"
        AND $job.next_retry_at > time::now() + 50s
        AND fn::notification_integration_select({ job_id: <string> $job.id }).data == [];
};

-- test: création d'une intégration de l'organisation : réglages contrôlés et normalisés, aucun secret
-- en tant que: admin
{
    LET $r = fn::notification_integration_create({ tenant: "auth_organization:alpha", key: "principale", provider: "brevo", name: "Brevo", primary: true,
        settings: { from_address: "Devis@Alpha.test", from_name: "Alpha BTP", reply_to: "Contact@Alpha.test" }, credentials_path: "notification/brevo/api", webhook_path: "notification/brevo/webhook" });
    CREATE test_ref:principale CONTENT { id_: $r.data.id };
    RETURN $r.ok
        AND $r.data.{ key, provider, channel, active, primary, priority, credentials_path, webhook_path } == { key: "principale", provider: "brevo", channel: "email", active: true, primary: true, priority: 100, credentials_path: "notification/brevo/api", webhook_path: "notification/brevo/webhook" }
        AND $r.data.settings == { from_address: "devis@alpha.test", from_name: "Alpha BTP", reply_to: "contact@alpha.test" };
};

-- test: contrôles : fournisseur, réglages propres au fournisseur, condition, clé déjà prise
-- en tant que: admin
{
    LET $base = { tenant: "auth_organization:alpha", key: "x", name: "X", credentials_path: "notification/postmark/api" };
    RETURN fn::notification_integration_create(object::extend($base, { provider: "sendgrid", settings: { from_address: "a@alpha.test" } })).error.code == "NOTIFICATION_INVALID_INPUT"
        AND fn::notification_integration_create(object::extend($base, { provider: "postmark", settings: { from_address: "pas-une-adresse" } })).error.code == "NOTIFICATION_INVALID_INPUT"
        AND fn::notification_integration_create(object::extend($base, { provider: "postmark", settings: { from_address: "a@alpha.test", host: "smtp.alpha.test" } })).error.details.fields.settings.details.field == "host"
        AND fn::notification_integration_create(object::extend($base, { provider: "mailgun", settings: { from_address: "a@alpha.test" } })).error.details.fields.settings.details.field == "domain"
        AND fn::notification_integration_create(object::extend($base, { provider: "smtp", settings: { from_address: "a@alpha.test", host: "smtp.alpha.test", port: 70000, security: "tls" } })).error.code == "NOTIFICATION_INVALID_INPUT"
        -- Organisation : ni relais en clair, ni hôte IP ou local
        AND fn::notification_integration_create(object::extend($base, { provider: "smtp", settings: { from_address: "a@alpha.test", host: "smtp.alpha.test", port: 25, security: "local_plain" } })).error.details.fields.settings.details.field == "security"
        AND fn::notification_integration_create(object::extend($base, { provider: "smtp", settings: { from_address: "a@alpha.test", host: "10.0.0.5", port: 587, security: "starttls" } })).error.details.fields.settings.details.field == "host"
        AND fn::notification_integration_create(object::extend($base, { provider: "smtp", settings: { from_address: "a@alpha.test", host: "localhost", port: 587, security: "starttls" } })).error.details.fields.settings.details.field == "host"
        AND fn::notification_integration_create(object::extend($base, { provider: "postmark", settings: { from_address: "a@alpha.test" }, condition: { field: "payload.x", op: "ressemble" } })).error.code == "NOTIFICATION_CONDITION_INVALID"
        AND fn::notification_integration_create(object::extend($base, { key: "principale", provider: "postmark", settings: { from_address: "a@alpha.test" } })).error.code == "NOTIFICATION_INTEGRATION_KEY_TAKEN"
        AND fn::notification_integration_create(object::extend($base, { provider: "postmark", settings: { from_address: "a@alpha.test" }, cle_api: "secret" })).error.code == "NOTIFICATION_INVALID_INPUT";
};

-- test: D2 : chemin hors notification/, secret absent ou d'une autre portée : refusés
-- en tant que: admin
{
    LET $base = { tenant: "auth_organization:alpha", key: "x", name: "X", provider: "postmark", settings: { from_address: "a@alpha.test" } };
    RETURN fn::notification_integration_create(object::extend($base, { credentials_path: "autre/dossier/api" })).error.code == "NOTIFICATION_INTEGRATION_SECRET_INVALID"
        AND fn::notification_integration_create(object::extend($base, { credentials_path: "notification/absent/api" })).error.code == "NOTIFICATION_INTEGRATION_SECRET_INVALID"
        AND fn::notification_integration_create(object::extend($base, { credentials_path: "notification/smtp/relais" })).error.code == "NOTIFICATION_INTEGRATION_SECRET_INVALID"
        AND fn::notification_integration_create(object::extend($base, { credentials_path: "notification/postmark/api", webhook_path: "notification/absent/webhook" })).error.code == "NOTIFICATION_INTEGRATION_SECRET_INVALID"
        AND count(SELECT id FROM notification_integration WHERE key = "x") == 0;
};

-- test: D2 : gérer les notifications sans pouvoir lire le secret ne suffit pas, ni pour créer ni pour modifier
-- en tant que: gestion
RETURN fn::notification_integration_create({ tenant: "auth_organization:alpha", key: "detournee", name: "D", provider: "postmark", settings: { from_address: "a@alpha.test" }, credentials_path: "notification/postmark/api" }).error.code == "NOTIFICATION_INTEGRATION_SECRET_INVALID"
    AND fn::notification_integration_update({ tenant: "auth_organization:alpha", key: "principale", name: "Renommée" }).error.code == "NOTIFICATION_INTEGRATION_SECRET_INVALID"
    -- Activer une intégration, la rendre principale ou la supprimer ne change pas où part le secret
    AND fn::notification_integration_list({ tenant: "auth_organization:alpha" }).data.key == ["principale"];

-- test: D2 : une écriture directe dans la table est gardée de même
-- en tant que: gestion
-- attendu-erreur: NOTIFICATION_INTEGRATION_SECRET_INVALID
UPDATE notification_integration SET settings.from_address = "pirate@ailleurs.test" WHERE key = "principale";

-- test: autres intégrations de l'organisation : secours (priorité 10) et conditionnelle (priorité 5)
-- en tant que: admin
RETURN fn::notification_integration_create({ tenant: "auth_organization:alpha", key: "secours", provider: "postmark", name: "Postmark", priority: 10, settings: { from_address: "devis@alpha.test" }, credentials_path: "notification/postmark/api" }).ok
    AND fn::notification_integration_create({ tenant: "auth_organization:alpha", key: "vip", provider: "resend", name: "Resend", priority: 5, condition: { field: "payload.vip", op: "eq", value: true }, settings: { from_address: "devis@alpha.test" }, credentials_path: "notification/resend/api" }).ok
    AND fn::notification_integration_list({ tenant: "auth_organization:alpha" }).data.key == ["principale", "vip", "secours"];

-- test: événements des intégrations : identifiants seulement, jamais de chemin ni de réglage
RETURN (SELECT VALUE event_type FROM event_outbox WHERE event_type = "notification.integration.created").len() == 3
    AND (SELECT VALUE object::keys(payload) FROM event_outbox WHERE event_type = "notification.integration.created")[0].sort() == ["channel", "integration_id", "tenant"];

-- test: une seule principale par portée et canal
-- en tant que: admin
RETURN fn::notification_integration_set_primary({ tenant: "auth_organization:alpha", key: "secours" }).data.primary == true
    AND (SELECT VALUE key FROM notification_integration WHERE primary = true AND scope_key = "alpha") == ["secours"]
    AND fn::notification_integration_set_primary({ tenant: "auth_organization:alpha", key: "principale" }).ok
    AND (SELECT VALUE key FROM notification_integration WHERE primary = true AND scope_key = "alpha") == ["principale"]
    AND fn::notification_integration_set_primary({ tenant: "auth_organization:alpha", key: "inconnue" }).error.code == "NOTIFICATION_INTEGRATION_NOT_FOUND";

-- test: modification : réglages remplacés, fournisseur fixe, chemin contrôlé, condition retirée
-- en tant que: admin
RETURN fn::notification_integration_update({ tenant: "auth_organization:alpha", key: "secours", name: "Postmark secours", settings: { from_address: "secours@alpha.test" } }).data.{ name, settings } == { name: "Postmark secours", settings: { from_address: "secours@alpha.test" } }
    AND fn::notification_integration_update({ tenant: "auth_organization:alpha", key: "secours", provider: "brevo" }).error.code == "NOTIFICATION_INVALID_INPUT"
    AND fn::notification_integration_update({ tenant: "auth_organization:alpha", key: "secours", credentials_path: "autre/dossier/api" }).error.code == "NOTIFICATION_INTEGRATION_SECRET_INVALID"
    AND fn::notification_integration_update({ tenant: "auth_organization:alpha", key: "absente", name: "A" }).error.code == "NOTIFICATION_INTEGRATION_NOT_FOUND"
    AND fn::notification_integration_update({ tenant: "auth_organization:alpha", key: "vip", clear_condition: true }).data.condition == NONE
    AND fn::notification_integration_update({ tenant: "auth_organization:alpha", key: "vip", condition: { field: "payload.vip", op: "eq", value: true } }).data.condition == { field: "payload.vip", op: "eq", value: true };

-- test: lecture : par clé ou par identifiant, chemins seulement ; lecteur sans gestion
-- en tant que: lecteur
RETURN fn::notification_integration_get({ tenant: "auth_organization:alpha", key: "principale" }).data.credentials_path == "notification/brevo/api"
    AND fn::notification_integration_get({ integration: <string> test_ref:principale.id_ }).data.key == "principale"
    AND fn::notification_integration_get({}).error.code == "NOTIFICATION_INVALID_INPUT"
    AND fn::notification_integration_list({ tenant: "auth_organization:alpha", active: true }).data.len() == 3
    AND fn::notification_integration_create({ tenant: "auth_organization:alpha", key: "y", name: "Y", provider: "postmark", settings: { from_address: "a@alpha.test" }, credentials_path: "notification/postmark/api" }).error.code == "NOTIFICATION_PERMISSION_DENIED"
    AND fn::notification_integration_delete({ tenant: "auth_organization:alpha", key: "secours" }).error.code == "NOTIFICATION_PERMISSION_DENIED";

-- test: une autre organisation ne voit ni ne gère les intégrations d'Alpha
-- en tant que: autre
RETURN fn::notification_integration_list({ tenant: "auth_organization:alpha" }).error.code == "NOTIFICATION_PERMISSION_DENIED"
    AND fn::notification_integration_get({ integration: <string> test_ref:principale.id_ }).error.code == "NOTIFICATION_INTEGRATION_NOT_FOUND"
    AND fn::notification_integration_update({ tenant: "auth_organization:alpha", key: "principale", name: "X" }).error.code == "NOTIFICATION_PERMISSION_DENIED"
    AND fn::notification_integration_create({ tenant: "auth_organization:alpha", key: "y", name: "Y", provider: "brevo", settings: { from_address: "a@beta.test" }, credentials_path: "notification/brevo/api" }).error.code == "NOTIFICATION_PERMISSION_DENIED";

-- test: installation : l'administrateur de la plateforme crée le relais SMTP (en clair sur la boucle locale) et un Mailgun européen
-- en tant que: plateforme
RETURN fn::notification_integration_create({ key: "relais", provider: "smtp", name: "Relais", primary: true, settings: { from_address: "noreply@lyxal.test", host: "127.0.0.1", port: 2525, security: "local_plain" }, credentials_path: "notification/smtp/relais" }).ok
    AND fn::notification_integration_create({ key: "mailgun", provider: "mailgun", name: "Mailgun", priority: 50, settings: { from_address: "noreply@lyxal.test", domain: "mg.lyxal.test", region: "eu" }, credentials_path: "notification/mailgun/api" }).data.settings == { from_address: "noreply@lyxal.test", domain: "mg.lyxal.test", region: "eu" }
    AND fn::notification_integration_list({}).data.key == ["relais", "mailgun"];

-- test: installation : sans secrets.installation.manage, refusée ; une organisation ne gère pas l'installation
-- en tant que: plateforme_seule
RETURN fn::notification_integration_create({ key: "autre", provider: "postmark", name: "P", settings: { from_address: "a@lyxal.test" }, credentials_path: "notification/smtp/relais" }).error.code == "NOTIFICATION_INTEGRATION_SECRET_INVALID";

-- test: une organisation ne crée pas d'intégration de l'installation
-- en tant que: admin
RETURN fn::notification_integration_create({ key: "z", provider: "postmark", name: "Z", settings: { from_address: "a@alpha.test" }, credentials_path: "notification/smtp/relais" }).error.code == "NOTIFICATION_PERMISSION_DENIED"
    AND fn::notification_integration_list({}).error.code == "NOTIFICATION_PERMISSION_DENIED";

-- préparation: déclenchements d'Alpha (normal et VIP) et de Beta (sans intégration propre)
{
    fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "devis", idempotency_key: "d1", to: { subscriber_id: "c1", email: "c1@exemple.fr" }, payload: { vip: false } });
    fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "devis", idempotency_key: "d2", to: { subscriber_id: "c2", email: "c2@exemple.fr" }, payload: { vip: true } });
    fn::notification_trigger({ tenant: "auth_organization:beta", workflow_key: "annonce", idempotency_key: "b1", to: { subscriber_id: "c3", email: "c3@exemple.fr" } });
};

-- test: D1 : la principale d'abord, puis par priorité ; condition appliquée ; Beta sert l'installation
-- en tant que: worker
{
    LET $order = |$key: string| fn::notification_integration_select({ job_id: <string> (SELECT VALUE id FROM ONLY notification_job WHERE run.idempotency_key = $key LIMIT 1) }).data.key;
    RETURN $order("d1") == ["principale", "secours"]
        AND $order("d2") == ["principale", "vip", "secours"]
        AND $order("b1") == ["relais", "mailgun"];
};

-- test: réservation : chaque étape porte l'intégration retenue (fournisseur, réglages, chemins), jamais un secret
-- en tant que: worker
{
    LET $jobs = fn::notification_job_claim({ channel: "email", worker_id: "w1", limit: 10 }).data;
    LET $d1 = $jobs.find(|$j| $j.idempotency_key = "d1");
    LET $b1 = $jobs.find(|$j| $j.idempotency_key = "b1");
    CREATE test_ref:d1 CONTENT { job: $d1.job_id, token: $d1.claim_token, integration: $d1.integration.id };
    CREATE test_ref:d2 CONTENT { job: $jobs.find(|$j| $j.idempotency_key = "d2").job_id, token: $jobs.find(|$j| $j.idempotency_key = "d2").claim_token };
    RETURN $d1.integration.{ key, provider, tenant, credentials_path, webhook_path, settings }
            == { key: "principale", provider: "brevo", tenant: auth_organization:alpha, credentials_path: "notification/brevo/api", webhook_path: "notification/brevo/webhook", settings: { from_address: "devis@alpha.test", from_name: "Alpha BTP", reply_to: "contact@alpha.test" } }
        AND $b1.integration.{ key, tenant } == { key: "relais", tenant: NONE }
        -- L'étape restée sans intégration n'est reprise qu'à sa prochaine échéance (une minute)
        AND array::len($jobs) == 3;
};

-- test: D3 : après un échec temporaire, la tentative suivante passe à l'intégration éligible suivante
-- en tant que: worker
{
    LET $failed = fn::notification_job_fail({ job_id: <string> test_ref:d1.job, claim_token: test_ref:d1.token, integration: <string> test_ref:d1.integration, class: "transient", code: "NOTIFICATION_PROVIDER_UNAVAILABLE", detail: "HTTP 503", retry_delay_seconds: 0 }).data;
    LET $order_after = fn::notification_integration_select({ job_id: <string> test_ref:d1.job }).data.key;
    LET $claimed = fn::notification_job_claim({ channel: "email", worker_id: "w2", limit: 10 }).data.find(|$j| $j.idempotency_key = "d1");
    CREATE test_ref:d1b CONTENT { job: $claimed.job_id, token: $claimed.claim_token, integration: $claimed.integration.id };
    RETURN $failed.status == "queued"
        AND (SELECT VALUE integration.key FROM ONLY test_ref:d1.job) == "principale"
        AND $order_after == ["secours", "principale"]
        AND $claimed.integration.key == "secours";
};

-- test: D3 : un refus définitif ne bascule pas ; un envoi réussi note l'intégration et le fournisseur
-- en tant que: worker
{
    LET $done = fn::notification_job_complete({ job_id: <string> test_ref:d1b.job, claim_token: test_ref:d1b.token, integration: <string> test_ref:d1b.integration, provider_message_id: "pm-1", response_code: 200, subject: "Devis" }).data;
    LET $message = (SELECT * FROM ONLY $done.messages[0]);
    LET $failed = fn::notification_job_fail({ job_id: <string> test_ref:d2.job, claim_token: test_ref:d2.token, integration: <string> test_ref:principale.id_, class: "permanent", code: "NOTIFICATION_PROVIDER_REJECTED", detail: "HTTP 400" }).data;
    CREATE test_ref:pm1 CONTENT { message: $done.messages[0] };
    RETURN $message.{ provider, provider_message_id, status } == { provider: "postmark", provider_message_id: "pm-1", status: "sent" }
        AND (SELECT VALUE integration.key FROM ONLY $message.id) == "secours"
        AND $failed.status == "failed";
};

-- test: retour « délivré » : message mis à jour, événement publié (identifiants seulement), rejeu sans effet
-- en tant que: worker
{
    LET $secours = (SELECT VALUE id FROM ONLY notification_integration WHERE key = "secours" LIMIT 1);
    LET $first = fn::notification_provider_event_record({ integration: <string> $secours, event_id: "Delivery:pm-1", type: "delivered", provider_message_id: "pm-1", occurred_at: time::now() }).data;
    LET $again = fn::notification_provider_event_record({ integration: <string> $secours, event_id: "Delivery:pm-1", type: "delivered", provider_message_id: "pm-1" }).data;
    RETURN $first.status == "recorded" AND $first.message == test_ref:pm1.message
        AND $again.status == "duplicate"
        AND (SELECT VALUE status FROM ONLY test_ref:pm1.message) == "delivered"
        AND count(SELECT id FROM notification_provider_event) == 1;
};

-- test: événement « délivré » publié une fois, identifiants seulement (jamais l'adresse)
{
    LET $published = (SELECT VALUE payload FROM event_outbox WHERE event_type = "notification.message.delivered");
    RETURN array::len($published) == 1
        AND object::keys($published[0]).sort() == ["integration_id", "message_id", "run_id"];
};

-- test: rejet temporaire sans effet ; rejet définitif : message rejeté et adresse supprimée dans l'organisation du message
-- en tant que: worker
{
    LET $secours = (SELECT VALUE id FROM ONLY notification_integration WHERE key = "secours" LIMIT 1);
    LET $soft = fn::notification_provider_event_record({ integration: <string> $secours, event_id: "Bounce:1", type: "soft_bounced", provider_message_id: "pm-1" }).data;
    LET $status_soft = (SELECT VALUE status FROM ONLY test_ref:pm1.message);
    LET $hard = fn::notification_provider_event_record({ integration: <string> $secours, event_id: "Bounce:2", type: "bounced", provider_message_id: "pm-1" }).data;
    RETURN $soft.status == "recorded" AND $status_soft == "delivered"
        AND $hard.status == "recorded"
        AND (SELECT VALUE status FROM ONLY test_ref:pm1.message) == "bounced"
        AND (SELECT scope_key, address, reason FROM notification_suppression) == [{ scope_key: "alpha", address: "c1@exemple.fr", reason: "hard_bounce" }];
};

-- test: plainte : adresse supprimée (plainte) ; retour d'un message inconnu ou d'une autre intégration : gardé, sans effet
-- en tant que: worker
{
    LET $secours = (SELECT VALUE id FROM ONLY notification_integration WHERE key = "secours" LIMIT 1);
    UPDATE notification_suppression SET reason = "manual";
    DELETE notification_suppression;
    LET $complaint = fn::notification_provider_event_record({ integration: <string> $secours, event_id: "SpamComplaint:3", type: "complained", provider_message_id: "pm-1" }).data;
    LET $unknown = fn::notification_provider_event_record({ integration: <string> $secours, event_id: "Delivery:inconnu", type: "delivered", provider_message_id: "inconnu" }).data;
    LET $other = fn::notification_provider_event_record({ integration: <string> test_ref:principale.id_, event_id: "Bounce:4", type: "bounced", provider_message_id: "pm-1" }).data;
    RETURN $complaint.status == "recorded"
        AND (SELECT VALUE status FROM ONLY test_ref:pm1.message) == "complained"
        AND $unknown.{ status, message } == { status: "unmatched", message: NONE }
        AND $other.status == "unmatched"
        AND fn::notification_provider_event_record({ integration: "notification_integration:absente", event_id: "x", type: "delivered" }).error.code == "NOTIFICATION_INTEGRATION_NOT_FOUND"
        AND fn::notification_provider_event_record({ integration: <string> $secours, event_id: "x", type: "opened" }).error.code == "NOTIFICATION_INVALID_INPUT";
};

-- test: les retours et la sélection sont réservés au worker (session système de l'hôte)
-- en tant que: admin
RETURN fn::notification_provider_event_record({ integration: <string> test_ref:principale.id_, event_id: "x", type: "delivered" }).error.code == "NOTIFICATION_PERMISSION_DENIED"
    AND fn::notification_integration_select({ job_id: <string> test_ref:d1.job }).error.code == "NOTIFICATION_PERMISSION_DENIED"
    AND fn::notification_integration_test_record({ integration: <string> test_ref:principale.id_, ok: true }).error.code == "NOTIFICATION_PERMISSION_DENIED";

-- test: essai (D6) : droit de gestion, adresse contrôlée ; l'hôte enregistre l'issue sans secret
-- en tant que: admin
{
    LET $r = fn::notification_integration_test({ integration: <string> test_ref:principale.id_, to: "Essai@Alpha.test" }).data;
    RETURN $r.to == "essai@alpha.test" AND $r.integration.{ provider, credentials_path } == { provider: "brevo", credentials_path: "notification/brevo/api" }
        AND fn::notification_integration_test({ integration: <string> test_ref:principale.id_, to: "pas-une-adresse" }).error.code == "NOTIFICATION_INVALID_INPUT";
};

-- test: essai refusé sans gestion, ou pour une autre organisation
-- en tant que: lecteur
RETURN fn::notification_integration_test({ integration: <string> test_ref:principale.id_, to: "a@alpha.test" }).error.code == "NOTIFICATION_PERMISSION_DENIED";

-- test: essai : l'issue est notée sur l'intégration
-- en tant que: worker
RETURN fn::notification_integration_test_record({ integration: <string> test_ref:principale.id_, ok: false, code: "NOTIFICATION_PROVIDER_REJECTED" }).data.{ ok, code } == { ok: false, code: "NOTIFICATION_PROVIDER_REJECTED" }
    AND fn::notification_integration_test_record({ integration: "notification_integration:absente", ok: true }).error.code == "NOTIFICATION_INTEGRATION_NOT_FOUND";

-- test: essai d'une intégration d'une autre organisation : introuvable
-- en tant que: autre
RETURN fn::notification_integration_test({ integration: <string> test_ref:principale.id_, to: "a@beta.test" }).error.code == "NOTIFICATION_INTEGRATION_NOT_FOUND";

-- test: suppression, même de la dernière : le secret du coffre-fort reste ; les envois repassent sur l'installation
-- en tant que: admin
RETURN fn::notification_integration_delete({ tenant: "auth_organization:alpha", key: "vip" }).ok
    AND fn::notification_integration_delete({ tenant: "auth_organization:alpha", key: "secours" }).ok
    AND fn::notification_integration_delete({ tenant: "auth_organization:alpha", key: "principale" }).ok
    AND fn::notification_integration_delete({ tenant: "auth_organization:alpha", key: "principale" }).error.code == "NOTIFICATION_INTEGRATION_NOT_FOUND"
    AND fn::notification_integration_list({ tenant: "auth_organization:alpha" }).data == []
    AND fn::secrets_secret_get({ tenant: "auth_organization:alpha", path: "notification/brevo/api" }).ok
    AND (SELECT VALUE integration FROM ONLY test_ref:pm1.message) == NONE;

-- test: événements publiés : rejet, plainte, intégrations supprimées
RETURN (SELECT VALUE event_type FROM event_outbox WHERE event_type IN ["notification.message.bounced", "notification.message.complained"] ORDER BY event_type) == ["notification.message.bounced", "notification.message.complained"]
    AND (SELECT VALUE event_type FROM event_outbox WHERE event_type = "notification.integration.deleted").len() == 3;

-- test: D1 : sans intégration propre, Alpha sert l'installation ; une intégration inactive ne sert pas
-- en tant que: worker
{
    fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "devis", idempotency_key: "d3", to: { subscriber_id: "c4", email: "c4@exemple.fr" } });
    UPDATE notification_integration SET active = false WHERE key = "relais";
    LET $job = (SELECT VALUE id FROM ONLY notification_job WHERE run.idempotency_key = "d3" LIMIT 1);
    RETURN fn::notification_integration_select({ job_id: <string> $job }).data.key == ["mailgun"];
};

-- test: fonctions internes : refus des réglages, vue, normalisation, contrôle du secret, éligibilité, champs, garde
{
    LET $i = (SELECT * FROM ONLY notification_integration WHERE key = "mailgun" LIMIT 1);
    RETURN fn::notification_integration_settings_refusal({ channel: "email", provider: "brevo", tenant: NONE, settings: { from_address: "a@b.test", region: "eu" } }) == { field: "region", code: "CORE_VALIDATION_NOT_ALLOWED" }
        AND fn::notification_integration_settings_refusal({ channel: "email", provider: "smtp", tenant: NONE, settings: { from_address: "a@b.test", host: "127.0.0.1", port: 25, security: "local_plain" } }) == NONE
        AND fn::notification_integration_view($i).credentials_path == "notification/mailgun/api"
        AND fn::notification_integration_payload($i).provider == "mailgun"
        AND fn::notification_integration_payload(NONE) == NONE
        AND fn::notification_integration_clean_settings({ provider: "mailgun", settings: { from_address: "A@B.test", domain: "mg.b.test" } }) == { from_address: "a@b.test", domain: "mg.b.test", region: "us" }
        AND fn::notification_integration_secret_check({ tenant: NONE, path: "notification/mailgun/api" }) == NONE
        AND fn::notification_integration_secret_check({ tenant: NONE, path: "notification/absent" }) == "NOTIFICATION_INTEGRATION_SECRET_INVALID"
        AND fn::notification_integration_secret_check({ tenant: NONE, path: "autre/x" }) == "NOTIFICATION_INTEGRATION_SECRET_INVALID"
        AND fn::notification_integration_find({ tenant: NONE, key: "mailgun" }).id == $i.id
        AND fn::notification_integration_eligible({ tenant: auth_organization:beta, channel: "email", context: {} }).key == ["mailgun"]
        AND fn::notification_integration_for_job({ job: (SELECT * FROM ONLY notification_job WHERE run.idempotency_key = "d3" LIMIT 1) }).key == ["mailgun"]
        AND fn::notification_integration_fields(true).key.required == true
        AND fn::notification_integration_refusal($i) == NONE
        AND fn::notification_integration_checked({ p: { tenant: NONE }, channel: "email", provider: "postmark", settings: { from_address: "a@b.test" }, credentials_path: "notification/absent" }).code == "NOTIFICATION_INTEGRATION_SECRET_INVALID"
        AND fn::notification_integration_unset_primary({ tenant: NONE, channel: "email", except: NONE }) == true
        AND count(SELECT id FROM notification_integration WHERE primary = true) == 0;
};

-- test: relais SMTP d'une organisation : son serveur est choisi par la personne, le mot de passe doit être un secret qu'elle peut déjà voir (revealable), jamais un secret réservé aux programmes
-- en tant que: admin
{
    LET $smtp = { tenant: "auth_organization:alpha", provider: "smtp", name: "Relais", active: false, settings: { from_address: "a@alpha.test", host: "smtp.alpha.test", port: 587, security: "starttls" } };
    LET $restricted = fn::notification_integration_create(object::extend($smtp, { key: "relais_restreint", credentials_path: "notification/smtp/restreint" }));
    LET $visible = fn::notification_integration_create(object::extend($smtp, { key: "relais_visible", credentials_path: "notification/smtp/visible" }));
    LET $api = fn::notification_integration_create({ tenant: "auth_organization:alpha", key: "api_restreint", provider: "postmark", name: "P", active: false, settings: { from_address: "a@alpha.test" }, credentials_path: "notification/smtp/restreint" });
    LET $moved = fn::notification_integration_update({ tenant: "auth_organization:alpha", key: "relais_visible", credentials_path: "notification/smtp/restreint" });
    RETURN $restricted.error.code == "NOTIFICATION_INTEGRATION_SECRET_INVALID" AND $visible.ok AND $api.ok
        AND $moved.error.code == "NOTIFICATION_INTEGRATION_SECRET_INVALID";
};

-- test: retour du fournisseur arrivé avant l'enregistrement de l'envoi : gardé, puis appliqué à la création du message (état, suppression)
{
    fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "devis", idempotency_key: "rapide-1", to: { subscriber_id: "rapide", email: "rapide@exemple.fr" } });
    LET $job = fn::notification_job_claim({ channel: "email", worker_id: "w9", limit: 50 }).data.find(|$j| $j.idempotency_key = "rapide-1");
    LET $early = fn::notification_provider_event_record({ integration: <string> $job.integration.id, event_id: "Bounce:rapide", type: "bounced", provider_message_id: "pm-rapide" }).data;
    LET $done = fn::notification_job_complete({ job_id: <string> $job.job_id, claim_token: $job.claim_token, integration: <string> $job.integration.id, provider_message_id: "pm-rapide", response_code: 200, subject: "Devis" }).data;
    RETURN $early.{ status, message } == { status: "unmatched", message: NONE }
        AND (SELECT VALUE status FROM ONLY $done.messages[0]) == "bounced"
        AND (SELECT VALUE [message, address] FROM ONLY notification_provider_event WHERE provider_event_id = "Bounce:rapide" LIMIT 1) == [$done.messages[0], "rapide@exemple.fr"]
        AND count(SELECT id FROM notification_suppression WHERE address = "rapide@exemple.fr" AND reason = "hard_bounce") == 1
        -- Fonctions internes : rien à rapprocher sans identifiant ; un rejet temporaire ne change pas l'état
        AND fn::notification_provider_event_reconcile({ integration: $job.integration.id, provider_message_id: NONE, message: $done.messages[0], tenant: auth_organization:alpha }) == NONE
        AND fn::notification_provider_event_apply({ type: "soft_bounced", message: (SELECT id, channel, to, status FROM ONLY $done.messages[0]), tenant: auth_organization:alpha, event_id: "x" }) == NONE
        AND (SELECT VALUE status FROM ONLY $done.messages[0]) == "bounced";
};

-- préparation: les permissions de table refusent désormais toute écriture des intégrations et des retours (fin du fichier)
{
    DEFINE TABLE OVERWRITE notification_integration TYPE NORMAL SCHEMAFULL PERMISSIONS
        FOR select WHERE fn::notification_can({ action: "read", tenant: tenant }) FOR create, update, delete NONE;
};

-- test: une écriture filtrée par les permissions de la table est signalée, jamais annoncée comme réussie
-- en tant que: plateforme
RETURN fn::notification_integration_create({ key: "refusee", provider: "postmark", name: "R", settings: { from_address: "a@lyxal.test" }, credentials_path: "notification/smtp/relais" }).error.code == "NOTIFICATION_WRITE_FORBIDDEN"
    AND fn::notification_integration_update({ key: "mailgun", name: "Refusé" }).error.code == "NOTIFICATION_WRITE_FORBIDDEN"
    AND fn::notification_integration_set_primary({ key: "mailgun" }).error.code == "NOTIFICATION_WRITE_FORBIDDEN"
    AND fn::notification_integration_delete({ key: "mailgun" }).error.code == "NOTIFICATION_WRITE_FORBIDDEN";
