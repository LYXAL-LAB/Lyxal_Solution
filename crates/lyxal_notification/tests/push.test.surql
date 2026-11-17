-- lyxal-test: assertions
-- Notifications push : intégrations push (Web Push, FCM, APNs : réglages et secrets) ;
-- inscription des appareils par la personne elle-même (valeurs scellées exigées, service push
-- inconnu refusé, mise à jour d'une inscription renvoyée, limite de 10, écriture filtrée) ;
-- lecture sans jeton (personne, autre personne, gestionnaire : type et date seulement) ; étape
-- push refusée dans un parcours sensible ; gabarits push ; préférences et heures calmes ; file
-- du canal push (appareils scellés, intégration de chaque service) ; appareil invalide retiré par
-- le worker (événement notification.endpoint.removed, identifiants seulement), les autres servis ;
-- clé publique VAPID ; essai d'une intégration push ; fonctions internes.
--
-- identité admin: { "id": "auth_session:admin", "pv": 1, "permissions": ["notification.read", "notification.manage", "notification.send", "secrets.value.read"] }
-- identité lecteur: { "id": "auth_session:lecteur", "pv": 1, "permissions": ["notification.read"] }
-- identité membre: { "id": "auth_session:membre", "pv": 1, "permissions": [] }
-- identité voisin: { "id": "auth_session:voisin", "pv": 1, "permissions": [] }
-- identité worker: { "id": "auth_session:worker", "pv": 1, "permissions": ["notification.worker", "i18n.translation.read"] }

-- préparation: organisations, sessions, secrets, parcours push
{
    CREATE auth_organization:alpha CONTENT { slug: "alpha", name: "Alpha BTP" };
    CREATE auth_organization:beta CONTENT { slug: "beta", name: "Beta Bois" };
    FOR $name IN ["admin", "lecteur", "membre", "voisin", "worker"] {
        LET $identity = type::record("auth_identity", $name);
        CREATE $identity CONTENT { schema: auth_identity_schema:default_v1, traits: { email: string::concat($name, "@lyxal.test"), locale: "fr" } };
        LET $org = IF $name = "worker" { NONE } ELSE { auth_organization:alpha };
        IF $org IS NOT NONE { RELATE $identity->auth_member_of->$org; };
        CREATE type::record("auth_session", $name) CONTENT { identity: $identity, organization: $org, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    };
    fn::secrets_secret_create({ tenant: "auth_organization:alpha", path: "notification/push/vapid", kind: "api_key" });
    fn::secrets_secret_create({ tenant: "auth_organization:alpha", path: "notification/push/fcm", kind: "api_key" });
    fn::secrets_secret_create({ tenant: "auth_organization:alpha", path: "notification/push/apns", kind: "api_key" });
    CREATE notification_workflow:rappel CONTENT { tenant: auth_organization:alpha, key: "rappel", name: "Rappel", status: "active", steps: [{ key: "push", type: "push" }] };
    CREATE notification_template:rappel CONTENT { tenant: auth_organization:alpha, workflow: notification_workflow:rappel, step_key: "push", subject: "Rappel", text_body: "Rendez-vous {{ payload.n }}", redirect: "/agenda", data: { n: "{{ payload.n }}" } };
    CREATE notification_workflow:brouillon CONTENT { tenant: auth_organization:alpha, key: "brouillon", name: "Brouillon", status: "draft",
        steps: [{ key: "push", type: "push" }, { key: "sms", type: "sms" }] };
    DEFINE TABLE test_ref SCHEMALESS PERMISSIONS FULL;
};

-- test: intégrations push : Web Push (contact et clé publique VAPID), FCM (projet), APNs (équipe, application, environnement), identifiants requis
-- en tant que: admin
{
    LET $base = { tenant: "auth_organization:alpha", channel: "push", name: "X" };
    LET $web = fn::notification_integration_create(object::extend($base, { key: "webpush", provider: "webpush", settings: { vapid_subject: "mailto:contact@alpha.test", vapid_public_key: "BP4z9KsN6nGRTbVYI_c7VJSPQTBtkgcy27mlmlMoZIIgDll6e3vCYLocInmYWAmS6TlzAC8wEqKK6PBru3jl7A8" }, credentials_path: "notification/push/vapid" }));
    LET $fcm = fn::notification_integration_create(object::extend($base, { key: "fcm", provider: "fcm", settings: { project_id: "lyxal-essai" }, credentials_path: "notification/push/fcm" }));
    LET $apns = fn::notification_integration_create(object::extend($base, { key: "apns", provider: "apns", settings: { team_id: "ABCDE12345", bundle_id: "fr.lyxal.essai", environment: "sandbox" }, credentials_path: "notification/push/apns" }));
    RETURN $web.ok AND $web.data.settings.vapid_subject == "mailto:contact@alpha.test"
        AND $fcm.ok AND $fcm.data.settings == { project_id: "lyxal-essai" }
        AND $apns.ok AND $apns.data.settings.environment == "sandbox"
        AND fn::notification_integration_list({ tenant: "auth_organization:alpha", channel: "push" }).data.key == ["apns", "fcm", "webpush"];
};

-- test: intégrations push refusées : réglage requis absent ou d'un autre service, contact VAPID ni mailto: ni https:, clé publique mal formée, identifiants absents, service d'un autre canal
-- en tant que: admin
{
    LET $base = { tenant: "auth_organization:alpha", key: "x", channel: "push", name: "X" };
    RETURN fn::notification_integration_create(object::extend($base, { provider: "webpush", credentials_path: "notification/push/vapid" })).error.details.fields.settings.details.field == "vapid_subject"
        AND fn::notification_integration_create(object::extend($base, { provider: "webpush", settings: { vapid_subject: "ftp://alpha.test/contact" }, credentials_path: "notification/push/vapid" })).error.details.fields.settings == { code: "CORE_VALIDATION_FORMAT", details: { field: "vapid_subject" } }
        AND fn::notification_integration_create(object::extend($base, { provider: "webpush", settings: { vapid_subject: "mailto:pas-une-adresse" }, credentials_path: "notification/push/vapid" })).error.details.fields.settings.details.field == "vapid_subject"
        AND fn::notification_integration_create(object::extend($base, { provider: "webpush", settings: { vapid_subject: "https://alpha.test/contact" }, credentials_path: "notification/push/vapid" })).ok
        AND fn::notification_integration_create(object::extend($base, { key: "y", provider: "webpush", settings: { vapid_subject: "https://alpha.test", vapid_public_key: "court" }, credentials_path: "notification/push/vapid" })).error.code == "NOTIFICATION_INVALID_INPUT"
        AND fn::notification_integration_create(object::extend($base, { key: "y", provider: "webpush", settings: { vapid_subject: "https://alpha.test", project_id: "lyxal-essai" }, credentials_path: "notification/push/vapid" })).error.details.fields.settings.details.field == "project_id"
        AND fn::notification_integration_create(object::extend($base, { key: "y", provider: "apns", settings: { team_id: "ABCDE12345", bundle_id: "fr.lyxal.essai" }, credentials_path: "notification/push/apns" })).error.details.fields.settings.details.field == "environment"
        AND fn::notification_integration_create(object::extend($base, { key: "y", provider: "apns", settings: { team_id: "abc", bundle_id: "fr.lyxal.essai", environment: "sandbox" }, credentials_path: "notification/push/apns" })).error.code == "NOTIFICATION_INVALID_INPUT"
        AND fn::notification_integration_create(object::extend($base, { key: "y", provider: "fcm", settings: { project_id: "lyxal-essai" } })).error.details.fields.credentials_path.code == "CORE_VALIDATION_NOT_ALLOWED"
        AND fn::notification_integration_create(object::extend($base, { key: "y", provider: "slack" })).error.details.fields.provider.code == "CORE_VALIDATION_NOT_ALLOWED"
        AND fn::notification_integration_create({ tenant: "auth_organization:alpha", key: "y", channel: "chat", provider: "fcm", name: "X" }).error.details.fields.provider.code == "CORE_VALIDATION_NOT_ALLOWED"
        AND fn::notification_integration_delete({ tenant: "auth_organization:alpha", key: "x" }).ok;
};

-- test: la personne inscrit ses appareils (Web Push, Android, iPhone) ; valeurs scellées seules enregistrées, vue sans jeton ni clé ni empreinte
-- en tant que: membre
{
    LET $sealed = "enc:v2:cle-2026:AAAAAAAAAAAAAAAAAAAAAAAA";
    LET $web = fn::notification_my_device_register({ tenant: "auth_organization:alpha", device: "0190a5b2-7c3e-7d4a-9b1c-0000000000a1", provider: "webpush", name: "Firefox",
        url: "https://updates.push.services.mozilla.com/wpush/v2/essai-abonnement", p256dh: "BCVxsr7N_eNgVRqvHtD0zTZsEc6-VV-JvLexhqUzORcxaOzi6-AYWXvTBHm4bjyPjs7Vd8pZGH6SRpkNtoIAiw4", auth: "BTBZMqHH6r4Tts7J_aSIgg",
        fingerprint: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", sealed_token: $sealed, sealed_p256dh: $sealed, sealed_auth: $sealed });
    LET $android = fn::notification_my_device_register({ tenant: "auth_organization:alpha", provider: "fcm", token: "jeton-fcm-essai-0000000000000000000000000001",
        fingerprint: "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb", sealed_token: $sealed });
    LET $iphone = fn::notification_my_device_register({ tenant: "auth_organization:alpha", provider: "apns", name: "iPhone", token: "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
        fingerprint: "cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc", sealed_token: $sealed });
    CREATE test_ref:web CONTENT { id_: $web.data.device.id };
    CREATE test_ref:android CONTENT { id_: $android.data.device.id };
    CREATE test_ref:iphone CONTENT { id_: $iphone.data.device.id };
    RETURN $web.ok AND $web.data.created AND $web.data.device.id == notification_endpoint:0190a5b27c3e7d4a9b1c0000000000a1
        AND $web.data.device.{ provider, platform, name, host, active } == { provider: "webpush", platform: "web", name: "Firefox", host: "updates.push.services.mozilla.com", active: true }
        AND object::keys($web.data.device).sort() == ["active", "created_at", "host", "id", "last_result", "name", "platform", "provider", "registered_at"]
        AND $android.data.device.{ provider, platform, name, host } == { provider: "fcm", platform: "android", name: "Android", host: "fcm.googleapis.com" }
        AND $iphone.data.device.{ provider, platform, host } == { provider: "apns", platform: "ios", host: "api.push.apple.com" }
        AND (SELECT VALUE subscriber.subscriber_id FROM ONLY $web.data.device.id) == "auth:membre";
};

-- test: une inscription renvoyée (même empreinte) met l'appareil à jour au lieu d'en créer un autre
-- en tant que: membre
{
    LET $before = (SELECT VALUE registered_at FROM ONLY test_ref:android.id_);
    LET $again = fn::notification_my_device_register({ tenant: "auth_organization:alpha", provider: "fcm", platform: "android", name: "Pixel", token: "jeton-fcm-essai-0000000000000000000000000001",
        fingerprint: "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb", sealed_token: "enc:v2:cle-2027:BBBBBBBBBBBBBBBBBBBBBBBB" });
    LET $other_service = fn::notification_my_device_register({ tenant: "auth_organization:alpha", provider: "apns", token: "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
        fingerprint: "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb", sealed_token: "enc:v2:cle-2027:BBBBBBBBBBBBBBBBBBBBBBBB" });
    RETURN $again.ok AND $again.data.created == false AND $again.data.device.id == test_ref:android.id_
        AND $again.data.device.name == "Pixel" AND $again.data.device.registered_at >= $before
        AND $other_service.error.details.reason == "provider"
        AND array::len(fn::notification_my_device_list({ tenant: "auth_organization:alpha" }).data) == 3;
};

-- test: inscriptions refusées : service push inconnu, HTTP, valeur non scellée, jeton pour Web Push, clés absentes, jeton APNs non hexadécimal, plateforme d'un autre service, empreinte mal formée, autre organisation
-- en tant que: membre
{
    LET $sealed = "enc:v2:cle-2026:AAAAAAAAAAAAAAAAAAAAAAAA";
    LET $web = { tenant: "auth_organization:alpha", provider: "webpush", p256dh: "BCVxsr7N_eNgVRqvHtD0zTZsEc6-VV-JvLexhqUzORcxaOzi6-AYWXvTBHm4bjyPjs7Vd8pZGH6SRpkNtoIAiw4", auth: "BTBZMqHH6r4Tts7J_aSIgg",
        fingerprint: "dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd", sealed_token: $sealed, sealed_p256dh: $sealed, sealed_auth: $sealed };
    LET $apns = { tenant: "auth_organization:alpha", provider: "apns", fingerprint: "dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd", sealed_token: $sealed };
    RETURN fn::notification_my_device_register(object::extend($web, { url: "https://push.pirate.test/abonnement" })).error.details.reason == "unofficial_host"
        AND fn::notification_my_device_register(object::extend($web, { url: "https://updates.push.services.mozilla.com.pirate.test/x" })).error.details.reason == "unofficial_host"
        AND fn::notification_my_device_register(object::extend($web, { url: "https://wns2-par02p.notify.windows.com/w/?token=essai" })).ok
        AND fn::notification_my_device_register(object::extend($web, { url: "http://fcm.googleapis.com/fcm/send/x" })).error.details.fields.url IS NOT NONE
        AND fn::notification_my_device_register(object::extend($web, { url: "https://fcm.googleapis.com/fcm/send/x", sealed_token: "https://fcm.googleapis.com/fcm/send/x" })).error.details.fields.sealed_token IS NOT NONE
        AND fn::notification_my_device_register(object::extend($web, { url: "https://fcm.googleapis.com/fcm/send/x", token: "jeton-fcm-essai-0000000000000000000000000001" })).error.details.reason == "webpush_subscription"
        AND fn::notification_my_device_register(object::extend($web, { url: "https://fcm.googleapis.com/fcm/send/x", sealed_auth: NONE })).error.details.reason == "webpush_subscription"
        AND fn::notification_my_device_register(object::extend($web, { url: "https://fcm.googleapis.com/fcm/send/x", p256dh: "BCVxsr7N" })).error.details.fields.p256dh IS NOT NONE
        AND fn::notification_my_device_register(object::extend($web, { url: "https://fcm.googleapis.com/fcm/send/x", platform: "android" })).error.details.reason == "platform"
        AND fn::notification_my_device_register(object::extend($apns, { token: "jeton-pas-hexadecimal-0000000000000000000000000000000000000000000" })).error.details.reason == "token"
        AND fn::notification_my_device_register(object::extend($apns, { token: "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef", url: "https://fcm.googleapis.com/x" })).error.details.reason == "token"
        AND fn::notification_my_device_register(object::extend($apns, { token: "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef", platform: "android" })).error.details.reason == "platform"
        AND fn::notification_my_device_register(object::extend($apns, { token: "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef", fingerprint: "jeton-en-clair" })).error.code == "NOTIFICATION_DEVICE_INVALID"
        AND fn::notification_my_device_register(object::extend($apns, { token: "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef", provider: "huawei" })).error.code == "NOTIFICATION_DEVICE_INVALID"
        AND fn::notification_my_device_register(object::extend($apns, { tenant: "auth_organization:beta", token: "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef" })).error.code == "NOTIFICATION_PERMISSION_DENIED";
};

-- test: l'appareil Windows inscrit par erreur est retiré par la personne ; il en reste trois
-- en tant que: membre
{
    LET $windows = fn::notification_my_device_list({ tenant: "auth_organization:alpha" }).data.find(|$d| $d.host = "wns2-par02p.notify.windows.com");
    LET $deleted = fn::notification_my_device_delete({ tenant: "auth_organization:alpha", endpoint: <string> $windows.id });
    RETURN $deleted.data.deleted == $windows.id
        AND fn::notification_my_device_delete({ tenant: "auth_organization:alpha", endpoint: <string> $windows.id }).error.code == "NOTIFICATION_DEVICE_NOT_FOUND"
        AND fn::notification_my_device_list({ tenant: "auth_organization:alpha" }).data.provider == ["webpush", "fcm", "apns"];
};

-- test: le jeton, les clés et l'empreinte ne sont jamais lus par la personne ; le worker lit les valeurs scellées
-- en tant que: membre
RETURN (SELECT VALUE [token, p256dh, auth, device_slot] FROM ONLY test_ref:web.id_) == [NONE, NONE, NONE, NONE]
    AND (SELECT VALUE fingerprint FROM ONLY test_ref:web.id_) == "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa";

-- test: le worker lit le jeton et les clés scellés
-- en tant que: worker
RETURN (SELECT VALUE [token, p256dh, auth] FROM ONLY test_ref:web.id_) == ["enc:v2:cle-2026:AAAAAAAAAAAAAAAAAAAAAAAA", "enc:v2:cle-2026:AAAAAAAAAAAAAAAAAAAAAAAA", "enc:v2:cle-2026:AAAAAAAAAAAAAAAAAAAAAAAA"];

-- test: une autre personne ne voit ni ne retire les appareils d'autrui
-- en tant que: voisin
RETURN fn::notification_my_device_list({ tenant: "auth_organization:alpha" }).data == []
    AND fn::notification_my_device_delete({ tenant: "auth_organization:alpha", endpoint: <string> test_ref:web.id_ }).error.code == "NOTIFICATION_DEVICE_NOT_FOUND"
    AND (SELECT VALUE id FROM notification_endpoint WHERE channel = "push") == [];

-- test: un gestionnaire voit le type et la date seulement ; les fonctions des adresses ignorent les appareils
-- en tant que: lecteur
{
    LET $devices = fn::notification_device_list({ tenant: "auth_organization:alpha", subscriber_id: "auth:membre" }).data;
    RETURN array::len($devices) == 3
        AND array::distinct($devices.map(|$d| object::keys($d).sort())) == [["id", "platform", "provider", "registered_at"]]
        AND $devices.map(|$d| [$d.provider, $d.platform]) == [["webpush", "web"], ["fcm", "android"], ["apns", "ios"]]
        -- Lecture directe : ni nom, ni jeton, ni empreinte
        AND (SELECT VALUE [name, token, fingerprint] FROM ONLY test_ref:iphone.id_) == [NONE, NONE, NONE]
        AND fn::notification_endpoint_list({ tenant: "auth_organization:alpha" }).data == []
        AND fn::notification_device_list({ tenant: "auth_organization:alpha", subscriber_id: "inconnu" }).error.code == "NOTIFICATION_SUBSCRIBER_NOT_FOUND"
        AND fn::notification_device_list({ tenant: "auth_organization:beta", subscriber_id: "auth:membre" }).error.code == "NOTIFICATION_PERMISSION_DENIED";
};

-- test: un gestionnaire ne modifie ni ne supprime un appareil par les fonctions des adresses
-- en tant que: admin
RETURN fn::notification_endpoint_update({ tenant: "auth_organization:alpha", endpoint: <string> test_ref:web.id_, name: "X" }).error.code == "NOTIFICATION_ENDPOINT_NOT_FOUND"
    AND fn::notification_endpoint_delete({ tenant: "auth_organization:alpha", endpoint: <string> test_ref:web.id_ }).error.code == "NOTIFICATION_ENDPOINT_NOT_FOUND"
    AND fn::notification_my_device_list({ tenant: "auth_organization:alpha" }).data == [];

-- test: dix appareils au plus par personne ; une inscription renvoyée passe encore à la limite
-- en tant que: voisin
{
    LET $register = |$i: int| fn::notification_my_device_register({ tenant: "auth_organization:alpha", provider: "fcm", token: string::concat("jeton-fcm-voisin-00000000000000000000000000", <string> $i),
        fingerprint: string::concat("e00000000000000000000000000000000000000000000000000000000000000", <string> $i), sealed_token: "enc:v2:cle-2026:AAAAAAAAAAAAAAAAAAAAAAAA" });
    LET $results = array::map(<array>(0..10), |$i| $register($i));
    LET $eleventh = fn::notification_my_device_register({ tenant: "auth_organization:alpha", provider: "fcm", token: "jeton-fcm-voisin-0000000000000000000000000011",
        fingerprint: "ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff", sealed_token: "enc:v2:cle-2026:AAAAAAAAAAAAAAAAAAAAAAAA" });
    LET $again = $register(3);
    RETURN array::len(array::filter($results, |$r| $r.ok AND $r.data.created)) == 10
        AND $eleventh.error.code == "NOTIFICATION_DEVICE_LIMIT" AND $eleventh.error.details.max == 10
        AND $again.ok AND $again.data.created == false
        AND array::len(fn::notification_my_device_list({ tenant: "auth_organization:alpha" }).data) == 10;
};

-- test: écriture filtrée par les permissions : un appareil pour l'abonné d'une autre personne est refusé (NOTIFICATION_WRITE_FORBIDDEN)
-- en tant que: voisin
{
    LET $membre = (SELECT * FROM ONLY notification_subscriber WHERE subscriber_id = "auth:membre" LIMIT 1);
    LET $p = { provider: "fcm", fingerprint: "1111111111111111111111111111111111111111111111111111111111111111", sealed_token: "enc:v2:cle-2026:AAAAAAAAAAAAAAAAAAAAAAAA" };
    RETURN fn::notification_device_write({ p: $p, subscriber: { id: notification_subscriber:inexistant, tenant: auth_organization:alpha }, host: "fcm.googleapis.com", platform: "android" }).code == "NOTIFICATION_WRITE_FORBIDDEN"
        AND $membre IS NONE;
};

-- test: étape push refusée dans un parcours sensible (création, ou parcours devenu sensible)
-- en tant que: admin
{
    LET $created = fn::notification_workflow_create({ tenant: "auth_organization:alpha", key: "code", name: "Code", sensitive: true, steps: [{ key: "mail", type: "email" }, { key: "alerte", type: "push" }] });
    LET $updated = fn::notification_workflow_update({ workflow: "notification_workflow:rappel", sensitive: true });
    LET $fine = fn::notification_workflow_create({ tenant: "auth_organization:alpha", key: "info", name: "Info", steps: [{ key: "alerte", type: "push", condition: { field: "payload.n", op: "exists" } }] });
    RETURN $created.error.code == "NOTIFICATION_STEP_INVALID" AND $created.error.details == { step: "alerte", reason: "push_sensitive" }
        AND $updated.error.details.reason == "push_sensitive"
        AND $fine.ok AND $fine.data.steps[0].type == "push";
};

-- test: gabarits push : titre et texte requis, lien et icône (chemin de l'application ou HTTPS), données (2 Kio) ; ni avatar ni boutons ; icône réservée au push
-- en tant que: admin
{
    LET $w = "notification_workflow:brouillon";
    LET $no_title = fn::notification_template_create({ workflow: $w, step_key: "push", text_body: "Bonjour" });
    LET $avatar = fn::notification_template_create({ workflow: $w, step_key: "push", subject: "T", text_body: "B", avatar: "/a.png", actions: [{ kind: "primary", label: "Ok" }] });
    LET $bad_link = fn::notification_template_create({ workflow: $w, step_key: "push", subject: "T", text_body: "B", redirect: "javascript:alert(1)", icon: "http://alpha.test/i.png" });
    LET $big = fn::notification_template_create({ workflow: $w, step_key: "push", subject: "T", text_body: "B", data: { n: array::join(array::repeat("a", 2100), "") } });
    LET $html = fn::notification_template_create({ workflow: $w, step_key: "push", subject: "T", text_body: "B", html_body: "<p>B</p>" });
    LET $ok = fn::notification_template_create({ workflow: $w, step_key: "push", subject: "Devis {{ payload.n }}", text_body: "Votre devis est prêt", redirect: "/devis/{{ payload.n }}", icon: "https://alpha.test/icone.png", data: { devis: "{{ payload.n }}" } });
    LET $cleared = fn::notification_template_update({ template: <string> $ok.data.id, icon: NULL, redirect: "https://alpha.test/devis" });
    LET $icon_sms = fn::notification_template_create({ workflow: $w, step_key: "sms", text_body: "Bonjour", icon: "/i.png" });
    RETURN object::keys($no_title.error.details.fields) == ["subject"]
        AND object::keys($avatar.error.details.fields).sort() == ["actions", "avatar"]
        AND object::keys($bad_link.error.details.fields).sort() == ["icon", "redirect"]
        AND $big.error.details.fields.data == ["CORE_VALIDATION_FORMAT"]
        AND $html.error.details.fields.html_body == ["CORE_VALIDATION_NOT_ALLOWED"]
        AND $ok.ok AND $ok.data.{ subject, redirect, icon, data } == { subject: "Devis {{ payload.n }}", redirect: "/devis/{{ payload.n }}", icon: "https://alpha.test/icone.png", data: { devis: "{{ payload.n }}" } }
        AND $cleared.ok AND $cleared.data.icon IS NONE AND $cleared.data.redirect == "https://alpha.test/devis"
        AND $icon_sms.error.details.fields.icon == ["CORE_VALIDATION_NOT_ALLOWED"];
};

-- test: préférence du canal push : étape écartée ; heures calmes de la personne portées par l'étape réservée
-- en tant que: admin
{
    LET $off = fn::notification_preference_set({ tenant: "auth_organization:alpha", level: "subscriber_global", subscriber_id: "auth:membre", channels: { push: false } }).ok;
    LET $refused = fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "rappel", idempotency_key: "pref-1", to: { subscriber_id: "auth:membre" }, payload: { n: 1 } }).data;
    LET $on = fn::notification_preference_set({ tenant: "auth_organization:alpha", level: "subscriber_global", subscriber_id: "auth:membre", channels: { push: NULL },
        quiet_hours: { ranges: [{ days: [1, 2, 3, 4, 5, 6, 7], start: 0, end: 0 }] } }).ok;
    LET $r = fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "rappel", idempotency_key: "push-1", to: { subscriber_id: "auth:membre" }, payload: { n: 7 } }).data;
    -- Sans appareil actif : aucune adresse pour le seul canal du parcours
    LET $no_device = fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "rappel", idempotency_key: "push-2", to: { subscriber_id: "auth:admin", email: "admin@lyxal.test" }, payload: { n: 1 } });
    CREATE test_ref:run CONTENT { run: $r.run_id };
    RETURN $off AND (SELECT VALUE skip_reason FROM ONLY notification_job WHERE run = $refused.run_id LIMIT 1) == "preference:subscriber_global"
        AND $on AND $r.status == "created" AND (SELECT VALUE [step_key, status] FROM notification_job WHERE run = $r.run_id) == [["push", "queued"]]
        AND $no_device.error.code == "NOTIFICATION_SUBSCRIBER_NO_ADDRESS";
};

-- test: file du canal push : appareils scellés de l'abonné, chacun avec l'intégration de son service ; heures calmes ; gabarit push
-- en tant que: worker
{
    LET $sms = fn::notification_job_claim({ channel: "sms", worker_id: "w-sms" }).data;
    LET $job = fn::notification_job_claim({ channel: "push", worker_id: "w-push" }).data.find(|$j| $j.run_id = test_ref:run.run);
    CREATE test_ref:job CONTENT { job: $job.job_id, token: $job.claim_token, integration: $job.integration.id,
        web_integration: $job.endpoints[0].integration.id, fcm_integration: $job.endpoints[1].integration.id, apns_integration: $job.endpoints[2].integration.id };
    RETURN $sms == [] AND $job.channel == "push" AND $job.quiet_hours IS NOT NONE
        AND $job.{ subject, text_body, redirect, data_templates } == { subject: "Rappel", text_body: "Rendez-vous {{ payload.n }}", redirect: "/agenda", data_templates: { n: "{{ payload.n }}" } }
        AND $job.endpoints.map(|$e| [$e.provider, $e.platform, $e.integration.key]) == [["webpush", "web", "webpush"], ["fcm", "android", "fcm"], ["apns", "ios", "apns"]]
        AND $job.endpoints[0].{ token, p256dh, auth, fingerprint, tenant_key } == { token: "enc:v2:cle-2026:AAAAAAAAAAAAAAAAAAAAAAAA", p256dh: "enc:v2:cle-2026:AAAAAAAAAAAAAAAAAAAAAAAA", auth: "enc:v2:cle-2026:AAAAAAAAAAAAAAAAAAAAAAAA", fingerprint: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", tenant_key: "alpha" }
        AND $job.endpoints[1].token == "enc:v2:cle-2027:BBBBBBBBBBBBBBBBBBBBBBBB"
        AND $job.endpoints[1].p256dh IS NONE
        AND $job.endpoints[2].integration.settings == { team_id: "ABCDE12345", bundle_id: "fr.lyxal.essai", environment: "sandbox" }
        -- Jamais le secret du déclenchement dans un message push (G4)
        AND $job.secret IS NONE;
};

-- test: appareil Android déclaré invalide : retiré par le worker ; l'étape réussit grâce aux deux autres (message par appareil : type, jamais le jeton)
-- en tant que: worker
{
    LET $removed = fn::notification_device_remove({ endpoint: <string> test_ref:android.id_, reason: "expired" });
    LET $again = fn::notification_device_remove({ endpoint: <string> test_ref:android.id_, reason: "expired" });
    LET $done = fn::notification_job_complete({ job_id: <string> test_ref:job.job, claim_token: test_ref:job.token, integration: <string> test_ref:job.web_integration, subject: "Rappel",
        endpoints: [
            { endpoint: <string> test_ref:web.id_, integration: <string> test_ref:job.web_integration, ok: true, response_code: 201 },
            { endpoint: <string> test_ref:android.id_, integration: <string> test_ref:job.fcm_integration, ok: false, code: "NOTIFICATION_DEVICE_INVALID", response_code: 404 },
            { endpoint: <string> test_ref:iphone.id_, integration: <string> test_ref:job.apns_integration, ok: true, provider_message_id: "0190-apns-essai", response_code: 200 }
        ] }).data;
    RETURN $removed.data == { removed: test_ref:android.id_, reason: "expired" }
        AND $again.error.code == "NOTIFICATION_DEVICE_NOT_FOUND"
        AND $done.status == "completed" AND $done.run_status == "completed"
        AND (SELECT VALUE [channel, to, provider, subject] FROM notification_message WHERE job = test_ref:job.job ORDER BY to) == [["push", "apns:ios", "apns", "Rappel"], ["push", "webpush:web", "webpush", "Rappel"]]
        AND (SELECT VALUE provider_message_id FROM ONLY notification_message WHERE job = test_ref:job.job AND provider = "apns" LIMIT 1) == "0190-apns-essai"
        AND (SELECT VALUE last_result.ok FROM ONLY test_ref:web.id_) == true
        AND count(SELECT id FROM notification_endpoint WHERE channel = "push" AND subscriber.subscriber_id = "auth:membre") == 2;
};

-- test: retrait publié (notification.endpoint.removed, identifiants seulement : jamais le jeton, l'empreinte ni l'hôte)
RETURN (SELECT VALUE payload FROM event_outbox WHERE event_type = "notification.endpoint.removed") == [{ endpoint_id: <string> test_ref:android.id_, subscriber_id: (SELECT VALUE <string> subscriber FROM ONLY test_ref:web.id_), tenant: "auth_organization:alpha", channel: "push" }]
    AND array::distinct(SELECT VALUE object::keys(payload).sort() FROM event_outbox WHERE event_type CONTAINS "notification.endpoint") == [["channel", "endpoint_id", "subscriber_id", "tenant"]]
    AND count(SELECT id FROM event_outbox WHERE event_type = "notification.endpoint.updated" AND payload.endpoint_id = <string> test_ref:android.id_) == 1
    AND (SELECT VALUE payload.endpoint_id FROM event_outbox WHERE event_type = "notification.endpoint.deleted" AND payload.channel = "push").len() == 1;

-- test: retrait réservé au worker ; une adresse de messagerie n'est pas un appareil
-- en tant que: admin
{
    LET $chat = fn::notification_endpoint_create({ tenant: "auth_organization:alpha", subscriber_id: "auth:membre", channel: "chat", provider: "telegram", name: "Robot", chat_id: "-1001234567890" });
    CREATE test_ref:chat CONTENT { id_: $chat.data.id };
    RETURN fn::notification_device_remove({ endpoint: <string> test_ref:iphone.id_, reason: "invalid" }).error.code == "NOTIFICATION_PERMISSION_DENIED"
        AND fn::notification_device_remove({ endpoint: <string> test_ref:iphone.id_, reason: "autre" }).error.code == "NOTIFICATION_INVALID_INPUT";
};

-- test: le worker ne retire pas une adresse de messagerie
-- en tant que: worker
RETURN fn::notification_device_remove({ endpoint: <string> test_ref:chat.id_, reason: "invalid" }).error.code == "NOTIFICATION_DEVICE_NOT_FOUND"
    AND record::exists(test_ref:chat.id_);

-- test: clé publique VAPID d'une portée (hôte, session système) : intégration Web Push de l'organisation, aucune pour une autre
-- en tant que: worker
RETURN fn::notification_push_vapid_key({ tenant: "auth_organization:alpha" }).data.public_key == "BP4z9KsN6nGRTbVYI_c7VJSPQTBtkgcy27mlmlMoZIIgDll6e3vCYLocInmYWAmS6TlzAC8wEqKK6PBru3jl7A8"
    AND fn::notification_push_vapid_key({ tenant: "auth_organization:alpha" }).data.integration == (SELECT VALUE id FROM ONLY notification_integration WHERE key = "webpush" LIMIT 1)
    AND fn::notification_push_vapid_key({ tenant: "auth_organization:beta" }).error.code == "NOTIFICATION_INTEGRATION_UNAVAILABLE"
    AND fn::notification_push_vapid_key({}).error.code == "NOTIFICATION_INTEGRATION_UNAVAILABLE";

-- test: liens rendus d'un message push contrôlés avant l'envoi (règles du fil)
-- en tant que: worker
RETURN fn::notification_push_links_check({ link: "/devis/7", icon: "https://alpha.test/i.png" }).data.refused == []
    AND fn::notification_push_links_check({ link: "javascript:alert(1)", icon: "//pirate.test/i.png" }).data.refused == ["link", "icon"]
    AND fn::notification_push_links_check({ link: "http://alpha.test/x" }).data.refused == ["link"]
    AND fn::notification_push_links_check({}).data.refused == [];

-- test: clé publique VAPID réservée à l'hôte
-- en tant que: membre
RETURN fn::notification_push_vapid_key({ tenant: "auth_organization:alpha" }).error.code == "NOTIFICATION_PERMISSION_DENIED"
    AND fn::notification_push_links_check({ link: "/x" }).error.code == "NOTIFICATION_PERMISSION_DENIED";

-- test: essai d'une intégration push : un appareil du même service et de la même organisation
-- en tant que: admin
{
    LET $apns = (SELECT VALUE id FROM ONLY notification_integration WHERE key = "apns" LIMIT 1);
    RETURN fn::notification_integration_test({ integration: <string> $apns, to: <string> test_ref:iphone.id_ }).data.to == <string> test_ref:iphone.id_
        AND fn::notification_integration_test({ integration: <string> $apns, to: <string> test_ref:web.id_ }).error.code == "NOTIFICATION_INVALID_INPUT";
};

-- test: appareil d'un essai remis à l'hôte (jeton scellé)
-- en tant que: worker
{
    LET $apns = (SELECT VALUE id FROM ONLY notification_integration WHERE key = "apns" LIMIT 1);
    RETURN fn::notification_endpoint_resolve({ integration: <string> $apns, endpoint: <string> test_ref:iphone.id_ }).data.{ provider, platform, token } == { provider: "apns", platform: "ios", token: "enc:v2:cle-2026:AAAAAAAAAAAAAAAAAAAAAAAA" };
};

-- test: un appareil déjà servi est retiré : ses messages restent (type de l'appareil), sans lien vers lui
-- en tant que: worker
RETURN fn::notification_device_remove({ endpoint: <string> test_ref:iphone.id_, reason: "invalid" }).ok
    AND (SELECT VALUE [to, endpoint] FROM notification_message WHERE job = test_ref:job.job AND provider = "apns") == [["apns:ios", NONE]];

-- test: appareils supprimés avec l'abonné
-- en tant que: admin
RETURN fn::notification_subscriber_delete({ tenant: "auth_organization:alpha", subscriber_id: "auth:membre" }).ok
    AND count(SELECT id FROM notification_endpoint WHERE channel = "push" AND tenant = auth_organization:alpha AND subscriber.subscriber_id = "auth:membre") == 0;

-- test: fonctions internes du push
{
    LET $fields = fn::notification_device_fields({});
    LET $device = { id: notification_endpoint:x, provider: "fcm", platform: "android", registered_at: d"2026-11-17T08:00:00Z", name: "Pixel", host: "fcm.googleapis.com", active: true, token: "enc:v2:k:AAAA", fingerprint: "f" };
    LET $sealed = "enc:v2:cle-2026:AAAAAAAAAAAAAAAAAAAAAAAA";
    RETURN object::keys($fields).sort() == ["auth", "device", "fingerprint", "language", "name", "p256dh", "platform", "provider", "sealed_auth", "sealed_p256dh", "sealed_token", "tenant", "token", "url"]
        AND fn::notification_device_shape({ provider: "fcm", token: "jeton-fcm-essai-0000000000000000000000000001", sealed_token: $sealed }) == { code: NONE, host: "fcm.googleapis.com", platform: "android" }
        AND fn::notification_device_shape({ provider: "fcm", platform: "ios", token: "jeton-fcm-essai-0000000000000000000000000001", sealed_token: $sealed }).platform == "ios"
        AND fn::notification_device_shape({ provider: "webpush", url: "https://web.push.apple.com/QGk", p256dh: "B", auth: "a", sealed_p256dh: $sealed, sealed_auth: $sealed }) == { code: NONE, host: "web.push.apple.com", platform: "web" }
        AND fn::notification_device_shape({ provider: "webpush", url: "https://10.0.0.5/x", p256dh: "B", auth: "a", sealed_p256dh: $sealed, sealed_auth: $sealed }).details.reason == "ip_address"
        AND fn::notification_device_view({ device: $device, mine: false }) == { id: notification_endpoint:x, provider: "fcm", platform: "android", registered_at: d"2026-11-17T08:00:00Z" }
        AND fn::notification_device_view({ device: $device, mine: true }).token IS NONE
        AND fn::notification_endpoint_official_hosts("webpush").exact.len() == 3
        AND fn::notification_endpoint_host_refusal({ provider: "webpush", host: "fcm.googleapis.com" }) IS NONE
        AND fn::notification_endpoint_host_refusal({ provider: "webpush", host: "eu.push.services.mozilla.com" }) IS NONE
        AND fn::notification_endpoint_host_refusal({ provider: "webpush", host: "hooks.slack.com" }) == "unofficial_host"
        AND fn::notification_template_push_refusal({ subject: "T", text_body: "B", redirect: "/x", icon: "/i.png", data: { a: "b" } }) IS NONE
        AND fn::notification_template_push_refusal({ subject: "T", text_body: "B", layout: notification_layout:default }).details.fields.layout == ["CORE_VALIDATION_NOT_ALLOWED"]
        AND fn::notification_template_push_refusal({ subject: "T", text_body: "B", data: { a: 1 } }).details.fields.data == ["CORE_VALIDATION_FORMAT"]
        AND fn::notification_template_channel_refusal({ channel: "push", template: { subject: "T", text_body: "B", icon: "/i.png" } }) IS NONE
        AND fn::notification_template_channel_refusal({ channel: "in_app", template: { subject: "T", text_body: "B", icon: "/i.png" } }).details.fields.icon == ["CORE_VALIDATION_NOT_ALLOWED"]
        AND fn::notification_channel_address({ type: "push", address: {}, subscriber: NONE }) IS NONE
        AND fn::notification_step_check({ steps: [{ key: "p", type: "push" }], sensitive: true }).details.reason == "push_sensitive";
};
