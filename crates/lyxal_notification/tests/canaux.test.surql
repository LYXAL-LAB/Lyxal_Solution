-- lyxal-test: assertions
-- Canaux du lot 4 : SMS, messageries d'équipe, adresse web. Parties d'un SMS (GSM-7, UCS-2) ;
-- intégrations par canal (fournisseur du canal, réglages, secrets attendus) ; adresses des
-- abonnés (création, hôtes officiels, adresse scellée exigée, jamais relue, liste d'hôtes de
-- l'installation, limite, droits, adresses de la personne connectée, nouvelle clé de signature,
-- suppression, événements) ; gabarits par canal (texte seul, longueur d'un SMS) ; choix de
-- l'intégration par canal et par service ; file par canal (heures calmes sauf pour l'adresse
-- web, adresses servies une seule fois) ; préférences par canal ; numéro supprimé (liste,
-- retour du fournisseur, désinscription chez l'opérateur) ; essai d'une intégration.
--
-- identité admin: { "id": "auth_session:admin", "pv": 1, "permissions": ["notification.read", "notification.manage", "notification.send", "secrets.value.read"] }
-- identité lecteur: { "id": "auth_session:lecteur", "pv": 1, "permissions": ["notification.read"] }
-- identité expediteur: { "id": "auth_session:expediteur", "pv": 1, "permissions": ["notification.send"] }
-- identité membre: { "id": "auth_session:membre", "pv": 1, "permissions": [] }
-- identité voisin: { "id": "auth_session:voisin", "pv": 1, "permissions": [] }
-- identité plateforme: { "id": "auth_session:plateforme", "pv": 1, "permissions": ["notification.installation.manage", "secrets.installation.manage"] }
-- identité worker: { "id": "auth_session:worker", "pv": 1, "permissions": ["notification.worker", "i18n.translation.read"] }

-- préparation: organisations, sessions, secrets, parcours (SMS, messagerie, adresse web), abonnés
{
    CREATE auth_organization:alpha CONTENT { slug: "alpha", name: "Alpha BTP" };
    CREATE auth_organization:beta CONTENT { slug: "beta", name: "Beta Bois" };
    FOR $name IN ["admin", "lecteur", "expediteur", "membre", "voisin", "plateforme", "worker"] {
        LET $identity = type::record("auth_identity", $name);
        CREATE $identity CONTENT { schema: auth_identity_schema:default_v1, traits: { email: string::concat($name, "@lyxal.test"), locale: "fr" } };
        LET $org = IF $name IN ["admin", "lecteur", "expediteur", "membre", "voisin"] { auth_organization:alpha } ELSE { NONE };
        IF $org IS NOT NONE { RELATE $identity->auth_member_of->$org; };
        CREATE type::record("auth_session", $name) CONTENT { identity: $identity, organization: $org, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    };
    fn::secrets_secret_create({ tenant: "auth_organization:alpha", path: "notification/twilio/api", kind: "api_key" });
    fn::secrets_secret_create({ tenant: "auth_organization:alpha", path: "notification/twilio/webhook", kind: "password" });
    fn::secrets_secret_create({ tenant: "auth_organization:alpha", path: "notification/telegram/bot", kind: "api_key" });
    CREATE notification_workflow:multi CONTENT { tenant: auth_organization:alpha, key: "multi", name: "Multi", status: "active",
        steps: [{ key: "sms", type: "sms" }, { key: "salon", type: "chat" }, { key: "web", type: "webhook" }] };
    CREATE notification_template:multi_sms CONTENT { tenant: auth_organization:alpha, workflow: notification_workflow:multi, step_key: "sms", text_body: "Devis {{ payload.n }} prêt" };
    CREATE notification_template:multi_salon CONTENT { tenant: auth_organization:alpha, workflow: notification_workflow:multi, step_key: "salon", subject: "Devis", text_body: "*Devis* {{ payload.n }}" };
    CREATE notification_template:multi_web CONTENT { tenant: auth_organization:alpha, workflow: notification_workflow:multi, step_key: "web", text_body: "Devis {{ payload.n }}" };
    CREATE notification_workflow:sms_seul CONTENT { tenant: auth_organization:alpha, key: "sms_seul", name: "SMS", status: "active", steps: [{ key: "sms", type: "sms" }] };
    CREATE notification_template:sms_seul CONTENT { tenant: auth_organization:alpha, workflow: notification_workflow:sms_seul, step_key: "sms", text_body: "Code {{ payload.n }}" };
    CREATE notification_workflow:alerte CONTENT { tenant: auth_organization:alpha, key: "alerte", name: "Alerte", status: "active", critical: true, steps: [{ key: "sms", type: "sms" }] };
    CREATE notification_template:alerte CONTENT { tenant: auth_organization:alpha, workflow: notification_workflow:alerte, step_key: "sms", text_body: "Alerte" };
    CREATE notification_workflow:brouillon CONTENT { tenant: auth_organization:alpha, key: "brouillon", name: "Brouillon", status: "draft",
        steps: [{ key: "email", type: "email" }, { key: "sms", type: "sms" }, { key: "salon", type: "chat" }] };
    fn::notification_subscriber_save({ tenant: auth_organization:alpha, input: { subscriber_id: "s1", email: "s1@exemple.fr", phone: "+33612345678", timezone: "UTC" }, must_exist: false });
    fn::notification_subscriber_save({ tenant: auth_organization:alpha, input: { subscriber_id: "s2", email: "s2@exemple.fr" }, must_exist: false });
    fn::notification_subscriber_save({ tenant: auth_organization:alpha, input: { subscriber_id: "s3", phone: "+33600000003" }, must_exist: false });
    fn::notification_subscriber_save({ tenant: auth_organization:beta, input: { subscriber_id: "b1", phone: "+33600000009" }, must_exist: false });
    DEFINE TABLE test_ref SCHEMALESS PERMISSIONS FULL;
};

-- test: parties d'un SMS : GSM-7 (160, puis 153 par partie ; extension comptée double), UCS-2 (70, puis 67 ; emoji compté double), 10 parties au plus
RETURN fn::notification_sms_segments("Bonjour, votre devis est prete.") == { encoding: "gsm7", units: 31, parts: 1 }
    AND fn::notification_sms_segments("Devis prêt").encoding == "ucs2"
    AND fn::notification_sms_segments(array::join(array::repeat("a", 160), "")).parts == 1
    AND fn::notification_sms_segments(array::join(array::repeat("a", 161), "")).parts == 2
    AND fn::notification_sms_segments(array::join(array::repeat("a", 306), "")).parts == 2
    AND fn::notification_sms_segments(array::join(array::repeat("a", 307), "")).parts == 3
    AND fn::notification_sms_segments("{€}") == { encoding: "gsm7", units: 6, parts: 1 }
    AND fn::notification_sms_segments("Être là") == { encoding: "ucs2", units: 7, parts: 1 }
    AND fn::notification_sms_segments("Merci 😀") == { encoding: "ucs2", units: 8, parts: 1 }
    AND fn::notification_sms_segments(array::join(array::repeat("ê", 71), "")).parts == 2
    AND fn::notification_sms_segments(array::join(array::repeat("a", 1530), "")).parts == 10
    AND fn::notification_sms_segments(array::join(array::repeat("a", 1531), "")).parts == 11
    AND fn::notification_sms_segments(array::join(array::repeat("ê", 671), "")).parts == 11;

-- test: intégrations par canal : SMS (expéditeur, identifiants, secret des retours), messagerie (aucun identifiant sauf Telegram), adresse web
-- en tant que: admin
{
    LET $base = { tenant: "auth_organization:alpha", name: "X" };
    LET $twilio = fn::notification_integration_create(object::extend($base, { key: "sms_twilio", channel: "sms", provider: "twilio", primary: true, settings: { sender: "+33700000000" }, credentials_path: "notification/twilio/api", webhook_path: "notification/twilio/webhook" }));
    LET $slack = fn::notification_integration_create(object::extend($base, { key: "slack", channel: "chat", provider: "slack" }));
    LET $telegram = fn::notification_integration_create(object::extend($base, { key: "telegram", channel: "chat", provider: "telegram", credentials_path: "notification/telegram/bot" }));
    LET $web = fn::notification_integration_create(object::extend($base, { key: "web", channel: "webhook", provider: "webhook" }));
    RETURN $twilio.ok AND $twilio.data.{ channel, provider, settings, webhook_path } == { channel: "sms", provider: "twilio", settings: { sender: "+33700000000" }, webhook_path: "notification/twilio/webhook" }
        AND $slack.ok AND $slack.data.credentials_path IS NONE AND $slack.data.settings == {}
        AND $telegram.ok AND $web.ok
        AND fn::notification_integration_list({ tenant: "auth_organization:alpha", channel: "chat" }).data.key == ["slack", "telegram"];
};

-- test: intégrations refusées : fournisseur d'un autre canal, réglages et secrets propres au canal
-- en tant que: admin
{
    LET $base = { tenant: "auth_organization:alpha", key: "x", name: "X" };
    RETURN fn::notification_integration_create(object::extend($base, { channel: "sms", provider: "postmark", settings: { sender: "Alpha" }, credentials_path: "notification/twilio/api" })).error.details.fields.provider.code == "CORE_VALIDATION_NOT_ALLOWED"
        AND fn::notification_integration_create(object::extend($base, { channel: "chat", provider: "webhook" })).error.details.fields.provider.code == "CORE_VALIDATION_NOT_ALLOWED"
        AND fn::notification_integration_create(object::extend($base, { channel: "sms", provider: "vonage", credentials_path: "notification/twilio/api" })).error.details.fields.settings.details.field == "sender"
        AND fn::notification_integration_create(object::extend($base, { channel: "sms", provider: "vonage", settings: { sender: "Nom bien trop long" }, credentials_path: "notification/twilio/api" })).error.code == "NOTIFICATION_INVALID_INPUT"
        AND fn::notification_integration_create(object::extend($base, { channel: "sms", provider: "vonage", settings: { sender: "Alpha", from_address: "a@alpha.test" }, credentials_path: "notification/twilio/api" })).error.details.fields.settings.details.field == "from_address"
        AND fn::notification_integration_create(object::extend($base, { channel: "sms", provider: "brevo", settings: { sender: "Alpha" } })).error.details.fields.credentials_path.code == "CORE_VALIDATION_NOT_ALLOWED"
        AND fn::notification_integration_create(object::extend($base, { channel: "chat", provider: "slack", credentials_path: "notification/telegram/bot" })).error.details.fields.credentials_path.code == "CORE_VALIDATION_NOT_ALLOWED"
        AND fn::notification_integration_create(object::extend($base, { channel: "chat", provider: "telegram" })).error.details.fields.credentials_path.code == "CORE_VALIDATION_NOT_ALLOWED"
        AND fn::notification_integration_create(object::extend($base, { channel: "webhook", provider: "webhook", webhook_path: "notification/twilio/webhook" })).error.details.fields.webhook_path.code == "CORE_VALIDATION_NOT_ALLOWED"
        AND fn::notification_integration_create(object::extend($base, { channel: "chat", provider: "discord", settings: { sender: "Alpha" } })).error.details.fields.settings.details.field == "sender";
};

-- test: adresses d'un abonné : Slack (hôte officiel), Teams, Mattermost (hôte public), adresse web (clé scellée), Telegram (salon) ; vue sans adresse ni clé
-- en tant que: admin
{
    LET $sealed = "enc:v2:cle-2026:AAAAAAAAAAAAAAAAAAAAAAAA";
    LET $base = { tenant: "auth_organization:alpha", subscriber_id: "s1" };
    LET $slack = fn::notification_endpoint_create(object::extend($base, { endpoint: "0190a5b2-7c3e-7d4a-9b1c-000000000001", channel: "chat", provider: "slack", name: "Salon devis", url: "https://hooks.slack.com/services/essai/salon/faux", sealed_url: $sealed }));
    LET $teams = fn::notification_endpoint_create(object::extend($base, { channel: "chat", provider: "teams", name: "Teams", url: "https://alpha.webhook.office.com/webhookb2/essai", sealed_url: $sealed, active: false }));
    LET $telegram = fn::notification_endpoint_create(object::extend($base, { channel: "chat", provider: "telegram", name: "Robot", chat_id: "-1001234567890" }));
    LET $web = fn::notification_endpoint_create(object::extend($base, { endpoint: "0190a5b2-7c3e-7d4a-9b1c-000000000002", channel: "webhook", provider: "webhook", name: "Logiciel du client", url: "https://crm.exemple.fr/lyxal?jeton=essai", sealed_url: $sealed, signing_secret: $sealed }));
    LET $mattermost = fn::notification_endpoint_create(object::extend($base, { channel: "chat", provider: "mattermost", name: "MM", url: "https://chat.exemple.fr/hooks/essai", sealed_url: $sealed, active: false }));
    CREATE test_ref:slack CONTENT { id_: $slack.data.id };
    CREATE test_ref:telegram CONTENT { id_: $telegram.data.id };
    CREATE test_ref:web CONTENT { id_: $web.data.id };
    CREATE test_ref:teams CONTENT { id_: $teams.data.id };
    RETURN $slack.ok AND $slack.data.id == notification_endpoint:0190a5b27c3e7d4a9b1c000000000001
        AND $slack.data.{ channel, provider, host, active, signed } == { channel: "chat", provider: "slack", host: "hooks.slack.com", active: true, signed: false }
        AND object::keys($slack.data).sort() == ["active", "channel", "chat_id", "created_at", "host", "id", "last_result", "name", "provider", "secret_rotated_at", "signed", "subscriber", "tenant", "updated_at"]
        AND $teams.ok AND $teams.data.host == "alpha.webhook.office.com"
        AND $telegram.data.{ host, chat_id } == { host: "api.telegram.org", chat_id: "-1001234567890" }
        AND $web.data.{ host, signed } == { host: "crm.exemple.fr", signed: true }
        AND $mattermost.data.host == "chat.exemple.fr";
};

-- test: adresses refusées : hôte non officiel, HTTP, adresse IP, nom local, valeur non scellée, service d'un autre canal, Telegram sans salon, adresse web sans clé
-- en tant que: admin
{
    LET $sealed = "enc:v2:cle-2026:AAAAAAAAAAAAAAAAAAAAAAAA";
    LET $chat = { tenant: "auth_organization:alpha", subscriber_id: "s1", channel: "chat", name: "X", sealed_url: $sealed };
    LET $web = { tenant: "auth_organization:alpha", subscriber_id: "s1", channel: "webhook", provider: "webhook", name: "X", sealed_url: $sealed, signing_secret: $sealed };
    RETURN fn::notification_endpoint_create(object::extend($chat, { provider: "slack", url: "https://hooks.slack.com.pirate.test/x" })).error.details.reason == "unofficial_host"
        AND fn::notification_endpoint_create(object::extend($chat, { provider: "discord", url: "https://evil.test/api/webhooks/1/x" })).error.details.reason == "unofficial_host"
        AND fn::notification_endpoint_create(object::extend($chat, { provider: "google_chat", url: "https://chat.googleapis.com/v1/spaces/essai/messages?key=x" })).ok
        AND fn::notification_endpoint_create(object::extend($chat, { provider: "slack", url: "http://hooks.slack.com/services/essai" })).error.code == "NOTIFICATION_INVALID_INPUT"
        AND fn::notification_endpoint_create(object::extend($web, { url: "https://10.0.0.5/hook" })).error.details.reason == "ip_address"
        AND fn::notification_endpoint_create(object::extend($web, { url: "https://[fd00::1]/hook" })).error.details.reason == "ip_address"
        AND fn::notification_endpoint_create(object::extend($web, { url: "https://intranet.local/hook" })).error.details.reason == "local_host"
        AND fn::notification_endpoint_create(object::extend($web, { url: "https://localhost/hook" })).error.details.reason == "local_host"
        AND fn::notification_endpoint_create(object::extend($web, { url: "https://crm.exemple.fr/x", sealed_url: "https://crm.exemple.fr/x-en-clair" })).error.code == "NOTIFICATION_INVALID_INPUT"
        AND fn::notification_endpoint_create(object::extend($web, { url: "https://crm.exemple.fr/x", signing_secret: NONE })).error.details.reason == "signing_secret"
        AND fn::notification_endpoint_create(object::extend($web, { url: "https://crm.exemple.fr/x", provider: "slack" })).error.details.reason == "provider"
        AND fn::notification_endpoint_create(object::extend($chat, { provider: "slack", url: "https://hooks.slack.com/x", sealed_url: NONE })).error.details.reason == "sealed_url"
        AND fn::notification_endpoint_create({ tenant: "auth_organization:alpha", subscriber_id: "s1", channel: "chat", provider: "telegram", name: "T" }).error.details.reason == "telegram_chat_id"
        AND fn::notification_endpoint_create({ tenant: "auth_organization:alpha", subscriber_id: "s1", channel: "chat", provider: "telegram", name: "T", chat_id: "salon; DROP" }).error.code == "NOTIFICATION_INVALID_INPUT"
        AND fn::notification_endpoint_create(object::extend($web, { subscriber_id: "inconnu", url: "https://crm.exemple.fr/x" })).error.code == "NOTIFICATION_SUBSCRIBER_NOT_FOUND";
};

-- test: l'adresse complète et la clé de signature ne sont lisibles que par le worker
-- en tant que: admin
RETURN (SELECT VALUE url FROM notification_endpoint WHERE subscriber.subscriber_id = "s1").all(|$u| $u IS NONE)
    AND (SELECT VALUE signing_secret FROM ONLY test_ref:web.id_) IS NONE
    AND fn::notification_endpoint_list({ tenant: "auth_organization:alpha", subscriber_id: "s1", channel: "webhook" }).data.host == ["crm.exemple.fr"];

-- test: le worker lit l'adresse scellée
-- en tant que: worker
RETURN (SELECT VALUE url FROM ONLY notification_endpoint:0190a5b27c3e7d4a9b1c000000000001) == "enc:v2:cle-2026:AAAAAAAAAAAAAAAAAAAAAAAA";

-- test: hôtes autorisés de l'installation (adresse web, Mattermost) : réglage de l'installation seulement
-- en tant que: plateforme
RETURN fn::notification_settings_set({ allowed_hosts: ["Hooks.Exemple.fr", "hooks.exemple.fr"] }).data.allowed_hosts == ["hooks.exemple.fr"]
    AND fn::notification_settings_set({ allowed_hosts: ["pas un hôte"] }).error.code == "NOTIFICATION_INVALID_INPUT"
    AND fn::notification_settings_get({}).data.effective.allowed_hosts == ["hooks.exemple.fr"];

-- test: hôte hors de la liste refusé, hôte de la liste accepté ; un hôte officiel n'en dépend pas ; une organisation ne règle pas la liste
-- en tant que: admin
{
    LET $sealed = "enc:v2:cle-2026:AAAAAAAAAAAAAAAAAAAAAAAA";
    LET $web = { tenant: "auth_organization:alpha", subscriber_id: "s2", channel: "webhook", provider: "webhook", name: "X", sealed_url: $sealed, signing_secret: $sealed };
    RETURN fn::notification_endpoint_create(object::extend($web, { url: "https://crm.exemple.fr/x" })).error.details.reason == "host_not_allowed"
        AND fn::notification_endpoint_create(object::extend($web, { url: "https://hooks.exemple.fr/x" })).ok
        AND fn::notification_endpoint_create({ tenant: "auth_organization:alpha", subscriber_id: "s2", channel: "chat", provider: "slack", name: "S", url: "https://hooks.slack.com/x", sealed_url: $sealed }).ok
        AND fn::notification_settings_set({ tenant: "auth_organization:alpha", allowed_hosts: ["a.exemple.fr"] }).error.details.fields.allowed_hosts == ["CORE_VALIDATION_NOT_ALLOWED"];
};

-- test: liste vidée : tout hôte public
-- en tant que: plateforme
RETURN fn::notification_settings_set({ allowed_hosts: [] }).ok AND fn::notification_settings_effective({}).allowed_hosts == [];

-- test: dix adresses au plus par abonné et par canal
-- en tant que: admin
{
    LET $sealed = "enc:v2:cle-2026:AAAAAAAAAAAAAAAAAAAAAAAA";
    LET $results = array::map(<array>(0..10), |$i| fn::notification_endpoint_create({ tenant: "auth_organization:alpha", subscriber_id: "s2", channel: "chat", provider: "slack", name: string::concat("S", <string> $i), url: "https://hooks.slack.com/x", sealed_url: $sealed }));
    RETURN array::len(array::filter($results, |$r| $r.ok)) == 9
        AND array::last($results).error.details.reason == "limit"
        AND count(SELECT id FROM notification_endpoint WHERE subscriber.subscriber_id = "s2" AND channel = "chat") == 10;
};

-- test: droits : lecture sans gestion, autre organisation, adresse d'une autre portée
-- en tant que: lecteur
RETURN fn::notification_endpoint_create({ tenant: "auth_organization:alpha", subscriber_id: "s1", channel: "chat", provider: "telegram", name: "T", chat_id: "42" }).error.code == "NOTIFICATION_PERMISSION_DENIED"
    AND array::len(fn::notification_endpoint_list({ tenant: "auth_organization:alpha", subscriber_id: "s1" }).data) == 6
    AND fn::notification_endpoint_list({ tenant: "auth_organization:beta" }).error.code == "NOTIFICATION_PERMISSION_DENIED"
    AND fn::notification_endpoint_update({ tenant: "auth_organization:alpha", endpoint: <string> test_ref:slack.id_, name: "X" }).error.code == "NOTIFICATION_PERMISSION_DENIED";

-- test: écriture filtrée par les permissions : NOTIFICATION_WRITE_FORBIDDEN
-- en tant que: lecteur
RETURN fn::notification_endpoint_change({ action: "update", endpoint: (SELECT * FROM ONLY test_ref:slack.id_), p: { name: "Pirate" } }).code == "NOTIFICATION_WRITE_FORBIDDEN"
    AND fn::notification_endpoint_change({ action: "delete", endpoint: (SELECT * FROM ONLY test_ref:slack.id_), p: {} }).code == "NOTIFICATION_WRITE_FORBIDDEN";

-- test: modification (nom, active, salon Telegram), nouvelle clé d'une adresse web, refus pour une autre adresse
-- en tant que: admin
{
    LET $sealed = "enc:v2:cle-2027:BBBBBBBBBBBBBBBBBBBBBBBB";
    LET $before = (SELECT VALUE secret_rotated_at FROM ONLY test_ref:web.id_);
    LET $renamed = fn::notification_endpoint_update({ tenant: "auth_organization:alpha", endpoint: <string> test_ref:slack.id_, name: "Salon des devis" });
    LET $chat_id = fn::notification_endpoint_update({ tenant: "auth_organization:alpha", endpoint: <string> test_ref:telegram.id_, chat_id: "@alpha_devis" });
    LET $wrong = fn::notification_endpoint_update({ tenant: "auth_organization:alpha", endpoint: <string> test_ref:slack.id_, chat_id: "42" });
    LET $rotated = fn::notification_endpoint_rotate_secret({ tenant: "auth_organization:alpha", endpoint: <string> test_ref:web.id_, signing_secret: $sealed });
    LET $not_web = fn::notification_endpoint_rotate_secret({ tenant: "auth_organization:alpha", endpoint: <string> test_ref:slack.id_, signing_secret: $sealed });
    LET $other_scope = fn::notification_endpoint_update({ tenant: "auth_organization:beta", endpoint: <string> test_ref:slack.id_, name: "X" });
    RETURN $renamed.data.name == "Salon des devis" AND $chat_id.data.chat_id == "@alpha_devis"
        AND $wrong.error.details.reason == "telegram_chat_id"
        AND $rotated.data.signed AND $rotated.data.secret_rotated_at >= $before
        AND $not_web.error.details.reason == "signing_secret"
        AND $other_scope.error.code == "NOTIFICATION_PERMISSION_DENIED";
};

-- test: événements des adresses : identifiants seulement (jamais l'adresse, l'hôte ni la clé)
RETURN array::distinct(SELECT VALUE event_type FROM event_outbox WHERE event_type CONTAINS "notification.endpoint").sort() == ["notification.endpoint.created", "notification.endpoint.updated"]
    AND array::distinct(SELECT VALUE object::keys(payload).sort() FROM event_outbox WHERE event_type CONTAINS "notification.endpoint") == [["channel", "endpoint_id", "subscriber_id", "tenant"]];

-- test: la personne connectée gère ses propres adresses (abonné auth: créé au besoin)
-- en tant que: membre
{
    LET $sealed = "enc:v2:cle-2026:AAAAAAAAAAAAAAAAAAAAAAAA";
    LET $empty = fn::notification_my_endpoint_list({ tenant: "auth_organization:alpha" }).data;
    LET $created = fn::notification_my_endpoint_create({ tenant: "auth_organization:alpha", channel: "webhook", provider: "webhook", name: "Mon logiciel", url: "https://moi.exemple.fr/hook", sealed_url: $sealed, signing_secret: $sealed });
    LET $updated = fn::notification_my_endpoint_update({ tenant: "auth_organization:alpha", endpoint: <string> $created.data.id, active: false });
    LET $rotated = fn::notification_my_endpoint_rotate_secret({ tenant: "auth_organization:alpha", endpoint: <string> $created.data.id, signing_secret: $sealed });
    CREATE test_ref:membre CONTENT { id_: $created.data.id };
    RETURN $empty == [] AND $created.ok AND $updated.data.active == false AND $rotated.ok
        AND fn::notification_my_endpoint_list({ tenant: "auth_organization:alpha" }).data.name == ["Mon logiciel"]
        AND (SELECT VALUE subscriber.subscriber_id FROM ONLY $created.data.id) == "auth:membre"
        -- Pas les adresses des autres abonnés
        AND fn::notification_my_endpoint_update({ tenant: "auth_organization:alpha", endpoint: <string> test_ref:slack.id_, name: "X" }).error.code == "NOTIFICATION_ENDPOINT_NOT_FOUND"
        AND fn::notification_my_endpoint_create({ tenant: "auth_organization:beta", channel: "chat", provider: "telegram", name: "T", chat_id: "42" }).error.code == "NOTIFICATION_PERMISSION_DENIED";
};

-- test: une autre personne ne touche pas aux adresses d'autrui
-- en tant que: voisin
RETURN fn::notification_my_endpoint_delete({ tenant: "auth_organization:alpha", endpoint: <string> test_ref:membre.id_ }).error.code == "NOTIFICATION_ENDPOINT_NOT_FOUND"
    AND fn::notification_my_endpoint_rotate_secret({ tenant: "auth_organization:alpha", endpoint: <string> test_ref:membre.id_, signing_secret: "enc:v2:cle-2026:AAAAAAAAAAAAAAAAAAAAAAAA" }).error.code == "NOTIFICATION_ENDPOINT_NOT_FOUND"
    AND fn::notification_my_endpoint_list({ tenant: "auth_organization:alpha" }).data == [];

-- test: la personne supprime son adresse
-- en tant que: membre
RETURN fn::notification_my_endpoint_delete({ tenant: "auth_organization:alpha", endpoint: <string> test_ref:membre.id_ }).ok
    AND fn::notification_my_endpoint_list({ tenant: "auth_organization:alpha" }).data == [];

-- test: gabarits par canal (E5) : texte seul pour SMS, messagerie, adresse web ; SMS de 10 parties au plus ; e-mail complet
-- en tant que: admin
{
    LET $w = "notification_workflow:brouillon";
    LET $html = fn::notification_template_create({ workflow: $w, step_key: "sms", text_body: "Bonjour", html_body: "<p>Bonjour</p>" });
    LET $no_text = fn::notification_template_create({ workflow: $w, step_key: "sms", subject: "Titre" });
    LET $long = fn::notification_template_create({ workflow: $w, step_key: "sms", text_body: array::join(array::repeat("a", 1531), "") });
    LET $sms = fn::notification_template_create({ workflow: $w, step_key: "sms", text_body: "Bonjour {{ payload.n }}" });
    LET $chat = fn::notification_template_create({ workflow: $w, step_key: "salon", subject: "Titre", text_body: "**Bonjour**" });
    LET $email = fn::notification_template_create({ workflow: $w, step_key: "email", text_body: "Bonjour" });
    LET $longer = fn::notification_template_update({ template: <string> $sms.data.id, text_body: array::join(array::repeat("ê", 671), "") });
    LET $layout = fn::notification_template_update({ template: <string> $sms.data.id, layout: "notification_layout:default" });
    RETURN $html.error.details.fields.html_body == ["CORE_VALIDATION_NOT_ALLOWED"]
        AND $no_text.error.details.fields.text_body == ["CORE_VALIDATION_REQUIRED"]
        AND $long.error.code == "NOTIFICATION_SMS_TOO_LONG" AND $long.error.details.parts == 11
        AND $sms.ok AND $sms.data.subject IS NONE AND $sms.data.html_body IS NONE
        AND $chat.ok AND $chat.data.subject == "Titre"
        AND object::keys($email.error.details.fields).sort() == ["html_body", "subject"]
        AND $longer.error.code == "NOTIFICATION_SMS_TOO_LONG"
        AND $layout.error.details.fields.layout == ["CORE_VALIDATION_NOT_ALLOWED"];
};

-- test: abonné sans téléphone pour un parcours SMS seulement ; préférence par canal ; numéro supprimé
-- en tant que: admin
{
    LET $no_phone = fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "sms_seul", idempotency_key: "np-1", to: { subscriber_id: "s2" }, payload: { n: 1 } });
    LET $pref = fn::notification_preference_set({ tenant: "auth_organization:alpha", level: "subscriber_global", subscriber_id: "s3", channels: { sms: false } }).ok;
    LET $refused = fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "sms_seul", idempotency_key: "pref-1", to: { subscriber_id: "s3" }, payload: { n: 1 } }).data;
    LET $cleared = fn::notification_preference_set({ tenant: "auth_organization:alpha", level: "subscriber_global", subscriber_id: "s3", channels: { sms: NONE } }).ok;
    LET $blocked = fn::notification_suppression_add({ tenant: "auth_organization:alpha", channel: "sms", address: "+33600000003", reason: "complaint" });
    LET $suppressed = fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "sms_seul", idempotency_key: "sup-1", to: { subscriber_id: "s3" }, payload: { n: 1 } }).data;
    -- Parcours critique : une plainte n'arrête pas l'envoi
    LET $critical = fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "alerte", idempotency_key: "sup-2", to: { subscriber_id: "s3" } }).data;
    RETURN $no_phone.error.code == "NOTIFICATION_SUBSCRIBER_NO_PHONE"
        AND $pref AND (SELECT VALUE skip_reason FROM ONLY notification_job WHERE run = $refused.run_id LIMIT 1) == "preference:subscriber_global"
        AND $cleared AND $blocked.ok AND $blocked.data.{ channel, address } == { channel: "sms", address: "+33600000003" }
        AND $suppressed.status == "skipped" AND $suppressed.skip_reason == "suppressed:complaint"
        AND $critical.status == "created"
        AND fn::notification_suppression_add({ tenant: "auth_organization:alpha", channel: "sms", address: "06 00 00 00 03" }).error.details.fields.address == ["CORE_VALIDATION_FORMAT"]
        AND fn::notification_suppression_list({ tenant: "auth_organization:alpha", channel: "sms" }).data.address == ["+33600000003"]
        AND fn::notification_suppression_remove({ tenant: "auth_organization:alpha", channel: "sms", address: "+33600000003" }).ok
        -- Un numéro ne voyage jamais dans un événement
        AND (SELECT VALUE payload.address FROM ONLY event_outbox WHERE event_type = "notification.address.suppressed" AND payload.channel = "sms" LIMIT 1) IS NONE;
};

-- test: déclenchement multi-canal : étape SMS en file ; heures calmes de l'abonné
-- en tant que: admin
{
    LET $quiet = fn::notification_preference_set({ tenant: "auth_organization:alpha", level: "subscriber_global", subscriber_id: "s1", quiet_hours: { ranges: [{ days: [1, 2, 3, 4, 5, 6, 7], start: 0, end: 0 }] } }).ok;
    LET $r = fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "multi", idempotency_key: "multi-1", to: { subscriber_id: "s1" }, payload: { n: 7 } }).data;
    CREATE test_ref:multi CONTENT { run: $r.run_id };
    RETURN $quiet AND $r.status == "created" AND (SELECT VALUE [step_key, status] FROM notification_job WHERE run = $r.run_id) == [["sms", "queued"]];
};

-- test: file par canal : le worker SMS réserve l'étape SMS (téléphone, intégration SMS, heures calmes), les autres canaux n'y touchent pas
-- en tant que: worker
{
    LET $email = fn::notification_job_claim({ channel: "email", worker_id: "w-email" }).data;
    LET $jobs = fn::notification_job_claim({ channel: "sms", worker_id: "w-sms" }).data;
    LET $job = $jobs.find(|$j| $j.run_id = test_ref:multi.run);
    LET $alerte = $jobs.find(|$j| $j.idempotency_key = "sup-2");
    CREATE test_ref:sms CONTENT { job: $job.job_id, token: $job.claim_token, integration: $job.integration.id };
    CREATE test_ref:alerte CONTENT { job: $alerte.job_id, token: $alerte.claim_token, integration: $alerte.integration.id, critical: $alerte.critical, quiet_hours: $alerte.quiet_hours };
    RETURN $email == [] AND $job.channel == "sms" AND $job.recipient.phone == "+33612345678"
        AND $job.{ workflow_key, step_key, subscriber_id, endpoints } == { workflow_key: "multi", step_key: "sms", subscriber_id: "s1", endpoints: [] }
        AND $job.integration.{ key, channel, provider } == { key: "sms_twilio", channel: "sms", provider: "twilio" }
        AND $job.quiet_hours IS NOT NONE AND $job.text_body == "Devis {{ payload.n }} prêt" AND $job.html_body IS NONE
        AND fn::notification_job_claim({ channel: "fax", worker_id: "w" }).error.code == "NOTIFICATION_INVALID_INPUT";
};

-- test: SMS envoyé : message au téléphone avec le nombre de parties ; l'étape de messagerie suit
-- en tant que: worker
{
    LET $done = fn::notification_job_complete({ job_id: <string> test_ref:sms.job, claim_token: test_ref:sms.token, integration: <string> test_ref:sms.integration, provider_message_id: "SMessai0001", response_code: 201, parts: 2 }).data;
    CREATE test_ref:sms_message CONTENT { id_: $done.messages[0] };
    RETURN (SELECT VALUE [channel, to, parts, provider, provider_message_id] FROM ONLY $done.messages[0]) == ["sms", "+33612345678", 2, "twilio", "SMessai0001"]
        AND (SELECT VALUE [step_key, status] FROM notification_job WHERE run = test_ref:multi.run ORDER BY created_at) == [["sms", "completed"], ["salon", "queued"]];
};

-- test: messagerie : adresses actives de l'abonné, chacune avec l'intégration de son service (Teams inactive, Mattermost inactive et sans intégration)
-- en tant que: worker
{
    LET $job = fn::notification_job_claim({ channel: "chat", worker_id: "w-chat" }).data.find(|$j| $j.run_id = test_ref:multi.run);
    CREATE test_ref:chat CONTENT { job: $job.job_id, token: $job.claim_token };
    RETURN $job.channel == "chat" AND $job.quiet_hours IS NOT NONE
        AND $job.endpoints.map(|$e| [$e.provider, $e.host, $e.integration.key]).sort() == [["slack", "hooks.slack.com", "slack"], ["telegram", "api.telegram.org", "telegram"]]
        AND $job.endpoints.find(|$e| $e.provider = "slack").url == "enc:v2:cle-2026:AAAAAAAAAAAAAAAAAAAAAAAA"
        AND $job.endpoints.find(|$e| $e.provider = "telegram").{ url, chat_id, tenant_key } == { url: NONE, chat_id: "@alpha_devis", tenant_key: "alpha" };
};

-- test: échec temporaire d'une adresse : celle déjà servie est enregistrée (message, dernier résultat) et n'est pas rappelée
-- en tant que: worker
{
    LET $slack = (SELECT VALUE id FROM ONLY notification_integration WHERE key = "slack" LIMIT 1);
    LET $telegram = (SELECT VALUE id FROM ONLY notification_integration WHERE key = "telegram" LIMIT 1);
    LET $failed = fn::notification_job_fail({ job_id: <string> test_ref:chat.job, claim_token: test_ref:chat.token, integration: <string> $telegram, class: "transient", code: "NOTIFICATION_PROVIDER_UNAVAILABLE", retry_delay_seconds: 0,
        endpoints: [
            { endpoint: <string> test_ref:slack.id_, integration: <string> $slack, ok: true, response_code: 200 },
            { endpoint: <string> test_ref:telegram.id_, integration: <string> $telegram, ok: false, code: "NOTIFICATION_PROVIDER_UNAVAILABLE" }
        ] }).data;
    LET $again = fn::notification_job_claim({ channel: "chat", worker_id: "w-chat" }).data.find(|$j| $j.run_id = test_ref:multi.run);
    CREATE test_ref:chat2 CONTENT { job: $again.job_id, token: $again.claim_token, telegram: $telegram };
    RETURN $failed.status == "queued"
        AND (SELECT VALUE [channel, to, provider, endpoint] FROM notification_message WHERE job = test_ref:chat.job) == [["chat", "hooks.slack.com", "slack", test_ref:slack.id_]]
        AND (SELECT VALUE last_result.ok FROM ONLY test_ref:telegram.id_) == false
        AND (SELECT VALUE last_result.ok FROM ONLY test_ref:slack.id_) == true
        AND $again.endpoints.provider == ["telegram"];
};

-- test: messagerie terminée ; adresse web : sans heures calmes (machine à machine), clé de signature scellée remise au worker
-- en tant que: worker
{
    LET $done = fn::notification_job_complete({ job_id: <string> test_ref:chat2.job, claim_token: test_ref:chat2.token, integration: <string> test_ref:chat2.telegram,
        endpoints: [{ endpoint: <string> test_ref:telegram.id_, integration: <string> test_ref:chat2.telegram, ok: true, provider_message_id: "@alpha_devis:57", response_code: 200 }] }).data;
    LET $web = fn::notification_job_claim({ channel: "webhook", worker_id: "w-web" }).data.find(|$j| $j.run_id = test_ref:multi.run);
    CREATE test_ref:web_job CONTENT { job: $web.job_id, token: $web.claim_token, integration: $web.integration.id };
    RETURN $done.status == "completed" AND array::len($done.messages) == 2
        AND $web.quiet_hours IS NONE AND $web.allowed_hosts == []
        AND $web.endpoints.map(|$e| [$e.provider, $e.host, $e.signing_secret]) == [["webhook", "crm.exemple.fr", "enc:v2:cle-2027:BBBBBBBBBBBBBBBBBBBBBBBB"]];
};

-- test: adresse web servie : déclenchement terminé ; une étape sans adresse servie réussie est refusée
-- en tant que: worker
{
    LET $none = fn::notification_job_complete({ job_id: <string> test_ref:web_job.job, claim_token: test_ref:web_job.token, integration: <string> test_ref:web_job.integration, endpoints: [] });
    LET $done = fn::notification_job_complete({ job_id: <string> test_ref:web_job.job, claim_token: test_ref:web_job.token, integration: <string> test_ref:web_job.integration,
        endpoints: [{ endpoint: <string> test_ref:web.id_, integration: <string> test_ref:web_job.integration, ok: true, response_code: 204 }] }).data;
    RETURN $none.error.code == "NOTIFICATION_INVALID_INPUT"
        AND $done.run_status == "completed"
        AND (SELECT VALUE to FROM notification_message WHERE job = test_ref:web_job.job) == ["crm.exemple.fr"];
};

-- test: retour du fournisseur SMS : numéro inexistant (rejet définitif) → message rejeté et numéro supprimé (canal sms)
-- en tant que: worker
{
    LET $r = fn::notification_provider_event_record({ integration: <string> test_ref:sms.integration, event_id: "SMessai0001:undelivered", type: "bounced", provider_message_id: "SMessai0001" }).data;
    RETURN $r.status == "recorded"
        AND (SELECT VALUE status FROM ONLY test_ref:sms_message.id_) == "bounced"
        AND (SELECT VALUE [channel, address, reason] FROM notification_suppression WHERE channel = "sms" AND address = "+33612345678") == [["sms", "+33612345678", "hard_bounce"]];
};

-- test: désinscription chez l'opérateur à l'envoi (STOP) : numéro supprimé (plainte), échec définitif
-- en tant que: worker
{
    LET $failed = fn::notification_job_fail({ job_id: <string> test_ref:alerte.job, claim_token: test_ref:alerte.token, integration: <string> test_ref:alerte.integration, class: "recipient_opted_out", code: "21610", detail: "destinataire désinscrit" }).data;
    -- Parcours critique : jamais d'heures calmes
    RETURN test_ref:alerte.critical AND test_ref:alerte.quiet_hours IS NONE
        AND $failed.status == "failed"
        AND (SELECT VALUE reason FROM notification_suppression WHERE channel = "sms" AND address = "+33600000003") == ["complaint"];
};

-- test: essai d'une intégration par canal : numéro E.164 (SMS), adresse du même service (messagerie)
-- en tant que: admin
{
    LET $sms = (SELECT VALUE id FROM ONLY notification_integration WHERE key = "sms_twilio" LIMIT 1);
    LET $slack = (SELECT VALUE id FROM ONLY notification_integration WHERE key = "slack" LIMIT 1);
    RETURN fn::notification_integration_test({ integration: <string> $sms, to: "+33612345678" }).data.to == "+33612345678"
        AND fn::notification_integration_test({ integration: <string> $sms, to: "a@b.test" }).error.details.fields.to == ["CORE_VALIDATION_FORMAT"]
        AND fn::notification_integration_test({ integration: <string> $slack, to: <string> test_ref:slack.id_ }).data.to == <string> test_ref:slack.id_
        AND fn::notification_integration_test({ integration: <string> $slack, to: <string> test_ref:telegram.id_ }).error.code == "NOTIFICATION_INVALID_INPUT";
};

-- test: adresse scellée d'un essai remise à l'hôte (session système, même service et même organisation)
-- en tant que: worker
{
    LET $slack = (SELECT VALUE id FROM ONLY notification_integration WHERE key = "slack" LIMIT 1);
    LET $resolved = fn::notification_endpoint_resolve({ integration: <string> $slack, endpoint: <string> test_ref:slack.id_ }).data;
    RETURN $resolved.{ provider, host, url } == { provider: "slack", host: "hooks.slack.com", url: "enc:v2:cle-2026:AAAAAAAAAAAAAAAAAAAAAAAA" }
        AND $resolved.integration.key == "slack"
        AND fn::notification_endpoint_resolve({ integration: <string> $slack, endpoint: <string> test_ref:telegram.id_ }).error.code == "NOTIFICATION_ENDPOINT_NOT_FOUND";
};

-- test: adresse scellée réservée au worker
-- en tant que: admin
RETURN fn::notification_endpoint_resolve({ integration: "notification_integration:x", endpoint: <string> test_ref:slack.id_ }).error.code == "NOTIFICATION_PERMISSION_DENIED";

-- test: qui déclenche voit si une adresse existe, jamais l'adresse
-- en tant que: expediteur
RETURN (SELECT VALUE url FROM notification_endpoint WHERE subscriber.subscriber_id = "s1").all(|$u| $u IS NONE)
    AND fn::notification_channel_address({ type: "chat", address: {}, subscriber: (SELECT VALUE id FROM ONLY notification_subscriber WHERE subscriber_id = "s1" LIMIT 1) }) == "chat";

-- test: suppression d'une adresse ; supprimée avec l'abonné
-- en tant que: admin
{
    LET $deleted = fn::notification_endpoint_delete({ tenant: "auth_organization:alpha", endpoint: <string> test_ref:teams.id_ });
    LET $again = fn::notification_endpoint_delete({ tenant: "auth_organization:alpha", endpoint: <string> test_ref:teams.id_ });
    LET $gone = fn::notification_subscriber_delete({ tenant: "auth_organization:alpha", subscriber_id: "s2" }).ok;
    RETURN $deleted.data.deleted == test_ref:teams.id_ AND $again.error.code == "NOTIFICATION_ENDPOINT_NOT_FOUND"
        AND $gone AND count(SELECT id FROM notification_endpoint WHERE subscriber.subscriber_id = "s2") == 0;
};

-- test: suppression publiée (identifiants seulement)
RETURN (SELECT VALUE payload.endpoint_id FROM event_outbox WHERE event_type = "notification.endpoint.deleted") CONTAINS <string> test_ref:teams.id_;

-- test: fonctions internes des canaux
{
    LET $endpoint = (SELECT * FROM ONLY notification_endpoint:0190a5b27c3e7d4a9b1c000000000001);
    LET $integration = (SELECT * FROM ONLY notification_integration WHERE key = "slack" LIMIT 1);
    RETURN fn::notification_endpoint_official_hosts("teams").suffixes.len() == 3
        AND fn::notification_endpoint_official_hosts("webhook") IS NONE
        AND fn::notification_endpoint_host_refusal({ provider: "slack", host: "hooks.slack.com" }) IS NONE
        AND fn::notification_endpoint_host_refusal({ provider: "teams", host: "prod-12.westeurope.logic.azure.com" }) IS NONE
        AND fn::notification_endpoint_host_refusal({ provider: "teams", host: "webhook.office.com.pirate.test" }) == "unofficial_host"
        AND fn::notification_endpoint_host_refusal({ provider: "webhook", host: "x.internal" }) == "local_host"
        AND fn::notification_endpoint_host_refusal({ provider: "webhook", host: "intranet" }) == "host"
        AND object::keys(fn::notification_endpoint_fields(false)).sort() == ["active", "chat_id", "endpoint", "language", "name"]
        AND fn::notification_endpoint_view($endpoint).url IS NONE
        AND fn::notification_endpoint_find({ endpoint: $endpoint.id, tenant: auth_organization:beta }) IS NONE
        AND fn::notification_endpoint_find({ endpoint: $endpoint.id, tenant: auth_organization:alpha }).id == $endpoint.id
        AND fn::notification_endpoint_payload({ endpoint: $endpoint, integration: $integration }).{ provider, tenant_key } == { provider: "slack", tenant_key: "alpha" }
        AND fn::notification_endpoint_write({ p: { channel: "chat", provider: "webhook" }, subscriber: {} }).details.reason == "provider"
        AND fn::notification_my_endpoint_change({ action: "delete", p: { endpoint: $endpoint.id } }).code == "NOTIFICATION_PERMISSION_DENIED"
        AND fn::notification_job_endpoints({ job: { id: notification_job:aucun, type: "chat" }, subscriber: NONE, integrations: [] }) == { served: 0, pending: 0, ready: [] }
        AND fn::notification_job_endpoint_fields({}).default == []
        AND fn::notification_job_endpoint_record({ job: {}, run: {}, subject: NONE, results: [] }) IS NONE
        AND fn::notification_channel_address({ type: "sms", address: { phone: "+33612345678" } }) == "+33612345678"
        AND fn::notification_channel_address({ type: "webhook", address: {}, subscriber: NONE }) IS NONE
        AND fn::notification_suppression_address({ channel: "email", address: "A@B.test" }) == "a@b.test"
        AND fn::notification_suppression_address({ channel: "sms", address: "0612" }) IS NONE
        AND fn::notification_suppression_reason({ scope: "alpha", channel: "sms", address: "+33600000003", critical: false }) == "complaint"
        AND fn::notification_suppression_reason({ scope: "alpha", channel: "sms", address: "+33600000003", critical: true }) IS NONE
        AND fn::notification_suppression_reason({ scope: "alpha", channel: "chat", address: "chat", critical: false }) IS NONE
        AND fn::notification_integration_secrets_refusal({ channel: "webhook", provider: "webhook", credentials_path: NONE, webhook_path: NONE }) IS NONE
        AND fn::notification_integration_secrets_refusal({ channel: "email", provider: "smtp", credentials_path: "notification/x", webhook_path: "notification/y" }) == "webhook_path"
        AND fn::notification_template_channel_refusal({ channel: "chat", template: { text_body: "x" } }) IS NONE
        AND fn::notification_template_channel_refusal({ channel: "sms", template: { text_body: array::join(array::repeat("a", 1600), "") } }).code == "NOTIFICATION_SMS_TOO_LONG";
};
