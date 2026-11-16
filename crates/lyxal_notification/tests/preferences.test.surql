-- lyxal-test: assertions
-- Préférences : chaque niveau et l'ordre B4 (défaut du parcours, organisation, abonné global,
-- catégorie, parcours), parcours critique, canal imposé, valeur effacée ; heures calmes (plage qui
-- passe minuit, fuseau de l'abonné, des réglages, sinon UTC ; absentes pour un parcours
-- critique) ; préférences de la personne connectée ; désabonnement par lien ; préférences
-- relues à la réservation ; report d'une étape aux heures calmes ; permissions.
--
-- identité admin: { "id": "auth_session:admin", "pv": 1, "permissions": ["notification.read", "notification.manage", "notification.send"] }
-- identité lecteur: { "id": "auth_session:lecteur", "pv": 1, "permissions": ["notification.read"] }
-- identité autre: { "id": "auth_session:autre", "pv": 1, "permissions": ["notification.read", "notification.manage", "notification.send"] }
-- identité membre: { "id": "auth_session:membre", "pv": 1, "permissions": [] }
-- identité voisin: { "id": "auth_session:voisin", "pv": 1, "permissions": [] }

-- préparation: organisations, sessions, catégorie, parcours (normal, imposé, critique), abonnés
{
    CREATE auth_organization:alpha CONTENT { slug: "alpha", name: "Alpha BTP" };
    CREATE auth_organization:beta CONTENT { slug: "beta", name: "Beta" };
    FOR $n IN ["admin", "lecteur", "membre", "voisin", "autre"] {
        CREATE type::record("auth_identity", $n) CONTENT { schema: auth_identity_schema:default_v1, traits: { email: string::concat($n, "@lyxal.test"), locale: "fr" } };
    };
    FOR $n IN ["admin", "lecteur", "membre", "voisin"] {
        RELATE (type::record("auth_identity", $n))->auth_member_of->auth_organization:alpha;
        CREATE type::record("auth_session", $n) CONTENT { identity: type::record("auth_identity", $n), organization: auth_organization:alpha, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    };
    RELATE auth_identity:autre->auth_member_of->auth_organization:beta;
    CREATE auth_session:autre CONTENT { identity: auth_identity:autre, organization: auth_organization:beta, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE notification_category:actualites CONTENT { tenant: auth_organization:alpha, key: "actualites", name: "Actualités" };
    CREATE notification_workflow:lettre CONTENT { tenant: auth_organization:alpha, key: "lettre", name: "Lettre", status: "active", category: notification_category:actualites, steps: [{ key: "email", channel: "email" }] };
    CREATE notification_workflow:facture CONTENT { tenant: auth_organization:alpha, key: "facture", name: "Facture", status: "active", preferences: { channels: { email: true }, enforced: ["email"] }, steps: [{ key: "email", channel: "email" }] };
    CREATE notification_workflow:alerte CONTENT { tenant: auth_organization:alpha, key: "alerte", name: "Alerte", status: "active", critical: true, steps: [{ key: "email", channel: "email" }] };
    CREATE notification_workflow:sans_avis CONTENT { tenant: auth_organization:alpha, key: "sans_avis", name: "Sans avis", status: "active", preferences: { channels: { email: false }, enforced: [] }, steps: [{ key: "email", channel: "email" }] };
    fn::notification_subscriber_save({ tenant: auth_organization:alpha, input: { subscriber_id: "s", email: "s@exemple.fr", timezone: "America/Montreal" }, must_exist: false });
    fn::notification_subscriber_save({ tenant: auth_organization:alpha, input: { subscriber_id: "t", email: "t@exemple.fr" }, must_exist: false });
};

-- test: canaux connus et clé de cible d'une préférence
RETURN fn::notification_channels({}) == ["email", "sms", "chat", "push", "in_app", "webhook"]
    AND fn::notification_preference_key({ level: "subscriber_global", tenant: auth_organization:alpha, subscriber: notification_subscriber:x })
        == "subscriber_global|alpha|notification_subscriber:x||"
    AND object::keys(fn::notification_preference_fields({})) == ["channels", "quiet_hours"];

-- test: sans aucun réglage : canal autorisé par défaut ; un défaut du parcours s'applique
RETURN fn::notification_preference_resolve({ tenant: auth_organization:alpha, workflow: (SELECT * FROM ONLY notification_workflow:lettre), subscriber: NONE }).channels.email == { allowed: true, level: "default" }
    AND fn::notification_preference_resolve({ tenant: auth_organization:alpha, workflow: (SELECT * FROM ONLY notification_workflow:sans_avis), subscriber: NONE }).channels.email == { allowed: false, level: "workflow_default" };

-- test: ordre B4 : chaque niveau plus précis l'emporte sur le précédent
-- en tant que: admin
{
    LET $level = || fn::notification_preference_get({ tenant: "auth_organization:alpha", subscriber_id: "s", workflow: "notification_workflow:sans_avis" }).data.resolved.channels.email;
    LET $default = $level();
    LET $tenant = fn::notification_preference_set({ tenant: "auth_organization:alpha", level: "tenant_workflow", workflow: "notification_workflow:sans_avis", channels: { email: true } }).ok;
    LET $after_tenant = $level();
    LET $global = fn::notification_preference_set({ tenant: "auth_organization:alpha", level: "subscriber_global", subscriber_id: "s", channels: { email: false } }).ok;
    LET $after_global = $level();
    LET $wf = fn::notification_preference_set({ tenant: "auth_organization:alpha", level: "subscriber_workflow", subscriber_id: "s", workflow: "notification_workflow:sans_avis", channels: { email: true } }).ok;
    LET $after_wf = $level();
    RETURN $default == { allowed: false, level: "workflow_default" }
        AND $tenant AND $after_tenant == { allowed: true, level: "tenant_workflow" }
        AND $global AND $after_global == { allowed: false, level: "subscriber_global" }
        AND $wf AND $after_wf == { allowed: true, level: "subscriber_workflow" };
};

-- test: la catégorie du parcours s'intercale entre le choix global et celui du parcours
-- en tant que: admin
{
    LET $before = fn::notification_preference_get({ tenant: "auth_organization:alpha", subscriber_id: "s", workflow: "notification_workflow:lettre" }).data.resolved.channels.email;
    LET $set = fn::notification_preference_set({ tenant: "auth_organization:alpha", level: "subscriber_category", subscriber_id: "s", category: "actualites", channels: { email: true, sms: false } }).data;
    LET $after = fn::notification_preference_get({ tenant: "auth_organization:alpha", subscriber_id: "s", workflow: "notification_workflow:lettre" }).data;
    RETURN $before == { allowed: false, level: "subscriber_global" }
        AND $set.channels == { email: true, sms: false }
        AND $after.resolved.channels.email == { allowed: true, level: "subscriber_category" }
        AND $after.resolved.channels.sms == { allowed: false, level: "subscriber_category" }
        AND $after.categories.map(|$c| [$c.key, $c.channels]) == [["actualites", { email: true, sms: false }]]
        AND $after.global.channels == { email: false };
};

-- test: null efface un canal d'un niveau, qui ne s'exprime plus
-- en tant que: admin
{
    LET $set = fn::notification_preference_set({ tenant: "auth_organization:alpha", level: "subscriber_category", subscriber_id: "s", category: "actualites", channels: { email: NULL } }).data;
    RETURN $set.channels == { sms: false }
        AND fn::notification_preference_get({ tenant: "auth_organization:alpha", subscriber_id: "s", workflow: "notification_workflow:lettre" }).data.resolved.channels.email.level == "subscriber_global";
};

-- test: canal imposé par le parcours : l'abonné ne le règle pas et son choix global est ignoré
-- en tant que: admin
RETURN fn::notification_preference_set({ tenant: "auth_organization:alpha", level: "subscriber_workflow", subscriber_id: "s", workflow: "notification_workflow:facture", channels: { email: false } }).error.code == "NOTIFICATION_PREFERENCE_ENFORCED"
    AND fn::notification_preference_get({ tenant: "auth_organization:alpha", subscriber_id: "s", workflow: "notification_workflow:facture" }).data.resolved.channels.email == { allowed: true, level: "workflow_default" };

-- test: parcours critique : choix de l'abonné ignorés, aucun réglage par parcours, pas d'heures calmes
-- en tant que: admin
{
    LET $set = fn::notification_preference_set({ tenant: "auth_organization:alpha", level: "subscriber_workflow", subscriber_id: "s", workflow: "notification_workflow:alerte", channels: { sms: false } });
    LET $quiet = fn::notification_preference_set({ tenant: "auth_organization:alpha", level: "subscriber_global", subscriber_id: "s", quiet_hours: { ranges: [{ days: [1, 2, 3, 4, 5, 6, 7], start: 0, end: 0 }] } }).ok;
    LET $resolved = fn::notification_preference_get({ tenant: "auth_organization:alpha", subscriber_id: "s", workflow: "notification_workflow:alerte" }).data.resolved;
    RETURN $set.error.code == "NOTIFICATION_PREFERENCE_ENFORCED" AND $set.error.details.channels == ["sms"]
        AND $quiet AND $resolved.critical AND $resolved.channels.email == { allowed: true, level: "default" } AND $resolved.quiet_hours IS NONE;
};

-- test: heures calmes : plage qui passe minuit, dans le fuseau de l'abonné
-- en tant que: admin
{
    LET $set = fn::notification_preference_set({ tenant: "auth_organization:alpha", level: "subscriber_global", subscriber_id: "s", quiet_hours: { ranges: [{ days: [1, 2, 3, 4, 5], start: 1320, end: 420 }, { days: [6, 7], start: 0, end: 600 }] } }).data;
    LET $resolved = fn::notification_preference_get({ tenant: "auth_organization:alpha", subscriber_id: "s", workflow: "notification_workflow:lettre" }).data.resolved;
    RETURN $set.channels == { email: false } AND array::len($set.quiet_hours.ranges) == 2
        AND $resolved.quiet_hours == { timezone: "America/Montreal", ranges: [{ days: [1, 2, 3, 4, 5], start: 1320, end: 420 }, { days: [6, 7], start: 0, end: 600 }] };
};

-- test: heures calmes : sans fuseau de l'abonné, celui des réglages, sinon UTC
-- en tant que: admin
{
    LET $set = fn::notification_preference_set({ tenant: "auth_organization:alpha", level: "subscriber_global", subscriber_id: "t", quiet_hours: { ranges: [{ days: [1], start: 60, end: 120 }] } }).ok;
    LET $utc = fn::notification_preference_get({ tenant: "auth_organization:alpha", subscriber_id: "t", workflow: "notification_workflow:lettre" }).data.resolved.quiet_hours.timezone;
    LET $settings = fn::notification_settings_set({ tenant: "auth_organization:alpha", timezone: "Europe/Paris" }).ok;
    LET $paris = fn::notification_preference_get({ tenant: "auth_organization:alpha", subscriber_id: "t", workflow: "notification_workflow:lettre" }).data.resolved.quiet_hours.timezone;
    RETURN $set AND $utc == "UTC" AND $settings AND $paris == "Europe/Paris";
};

-- test: heures calmes effacées par null ; plages invalides refusées ; seulement au niveau global
-- en tant que: admin
RETURN fn::notification_preference_set({ tenant: "auth_organization:alpha", level: "subscriber_global", subscriber_id: "t", quiet_hours: NULL }).data.quiet_hours IS NONE
    AND fn::notification_preference_set({ tenant: "auth_organization:alpha", level: "subscriber_global", subscriber_id: "t", quiet_hours: { ranges: [{ days: [8], start: 0, end: 60 }] } }).error.code == "NOTIFICATION_INVALID_INPUT"
    AND fn::notification_preference_set({ tenant: "auth_organization:alpha", level: "subscriber_global", subscriber_id: "t", quiet_hours: { ranges: [{ days: [1], start: 1500, end: 60 }] } }).error.code == "NOTIFICATION_INVALID_INPUT"
    AND fn::notification_preference_set({ tenant: "auth_organization:alpha", level: "subscriber_category", subscriber_id: "t", category: "actualites", quiet_hours: { ranges: [] } }).error.code == "NOTIFICATION_INVALID_INPUT";

-- test: cible du niveau exigée ; canal inconnu, parcours, catégorie ou abonné inconnus refusés
-- en tant que: admin
RETURN fn::notification_preference_set({ tenant: "auth_organization:alpha", level: "subscriber_workflow", subscriber_id: "s", channels: { email: true } }).error.code == "NOTIFICATION_INVALID_INPUT"
    AND fn::notification_preference_set({ tenant: "auth_organization:alpha", level: "tenant_workflow", workflow: "notification_workflow:lettre", subscriber_id: "s", channels: { email: true } }).error.code == "NOTIFICATION_INVALID_INPUT"
    AND fn::notification_preference_set({ tenant: "auth_organization:alpha", level: "subscriber_global", subscriber_id: "s" }).error.code == "NOTIFICATION_INVALID_INPUT"
    AND fn::notification_preference_set({ tenant: "auth_organization:alpha", level: "subscriber_global", subscriber_id: "s", channels: { fax: true } }).error.code == "NOTIFICATION_INVALID_INPUT"
    AND fn::notification_preference_set({ tenant: "auth_organization:alpha", level: "subscriber_workflow", subscriber_id: "s", workflow: "notification_workflow:inconnu", channels: { email: true } }).error.code == "NOTIFICATION_WORKFLOW_NOT_FOUND"
    AND fn::notification_preference_set({ tenant: "auth_organization:alpha", level: "subscriber_category", subscriber_id: "s", category: "inconnue", channels: { email: true } }).error.code == "NOTIFICATION_CATEGORY_NOT_FOUND"
    AND fn::notification_preference_set({ tenant: "auth_organization:alpha", level: "subscriber_global", subscriber_id: "inconnu", channels: { email: true } }).error.code == "NOTIFICATION_SUBSCRIBER_NOT_FOUND";

-- test: réglages de l'organisation par parcours, lus sans abonné
-- en tant que: lecteur
{
    LET $r = fn::notification_preference_get({ tenant: "auth_organization:alpha", workflow: "notification_workflow:sans_avis" }).data;
    RETURN $r.workflows.map(|$w| [$w.key, $w.channels]) == [["sans_avis", { email: true }]]
        AND $r.resolved.channels.email == { allowed: true, level: "tenant_workflow" }
        AND fn::notification_preference_set({ tenant: "auth_organization:alpha", level: "subscriber_global", subscriber_id: "s", channels: { email: true } }).error.code == "NOTIFICATION_PERMISSION_DENIED";
};

-- test: une autre organisation ne lit ni ne règle les préférences d'Alpha
-- en tant que: autre
RETURN fn::notification_preference_get({ tenant: "auth_organization:alpha", subscriber_id: "s" }).error.code == "NOTIFICATION_PERMISSION_DENIED"
    AND fn::notification_preference_set({ tenant: "auth_organization:alpha", level: "subscriber_global", subscriber_id: "s", channels: { email: true } }).error.code == "NOTIFICATION_PERMISSION_DENIED"
    AND count(SELECT id FROM notification_preference) == 0;

-- test: événements notification.preference.updated : identifiants seulement
RETURN count(SELECT id FROM event_outbox WHERE event_type = "notification.preference.updated") >= 6
    AND (SELECT VALUE object::keys(payload) FROM event_outbox WHERE event_type = "notification.preference.updated")
        .all(|$keys| $keys.all(|$k| $k IN ["category_id", "level", "preference_id", "subscriber_id", "tenant", "workflow_id"]));

-- test: la personne connectée règle ses propres préférences sans permission : son abonné auth:<identité> est créé avec l'adresse de son compte
-- en tant que: membre
{
    LET $set = fn::notification_my_preference_set({ tenant: "auth_organization:alpha", level: "subscriber_global", channels: { email: false } });
    LET $cat = fn::notification_my_preference_set({ tenant: "auth_organization:alpha", level: "subscriber_category", category: "actualites", channels: { email: true } });
    LET $mine = fn::notification_my_preference_get({ tenant: "auth_organization:alpha", workflow: "notification_workflow:lettre" }).data;
    RETURN $set.ok AND $cat.ok AND $mine.subscriber_id == "auth:membre"
        AND $mine.global.channels == { email: false }
        AND $mine.resolved.channels.email == { allowed: true, level: "subscriber_category" }
        AND (SELECT VALUE [email, identity] FROM ONLY notification_subscriber WHERE subscriber_id = "auth:membre" LIMIT 1) == ["membre@lyxal.test", auth_identity:membre];
};

-- test: elle ne règle ni un parcours critique ni un canal imposé, ni le niveau de l'organisation, ni une autre organisation
-- en tant que: membre
RETURN fn::notification_my_preference_set({ tenant: "auth_organization:alpha", level: "subscriber_workflow", workflow: "notification_workflow:alerte", channels: { email: false } }).error.code == "NOTIFICATION_PREFERENCE_ENFORCED"
    AND fn::notification_my_preference_set({ tenant: "auth_organization:alpha", level: "subscriber_workflow", workflow: "notification_workflow:facture", channels: { email: false } }).error.code == "NOTIFICATION_PREFERENCE_ENFORCED"
    AND fn::notification_my_preference_set({ tenant: "auth_organization:alpha", level: "tenant_workflow", workflow: "notification_workflow:lettre", channels: { email: false } }).error.code == "NOTIFICATION_INVALID_INPUT"
    AND fn::notification_my_preference_set({ tenant: "auth_organization:beta", level: "subscriber_global", channels: { email: false } }).error.code == "NOTIFICATION_PERMISSION_DENIED"
    AND fn::notification_my_preference_get({ tenant: "auth_organization:beta" }).error.code == "NOTIFICATION_PERMISSION_DENIED";

-- test: elle ne voit que ses propres préférences et son propre abonné
-- en tant que: membre
RETURN count(SELECT id FROM notification_preference) == 2
    AND (SELECT VALUE subscriber_id FROM notification_subscriber) == ["auth:membre"];

-- test: une autre personne sans réglage lit les valeurs par défaut, sans abonné créé
-- en tant que: voisin
{
    LET $mine = fn::notification_my_preference_get({ tenant: "auth_organization:alpha", workflow: "notification_workflow:lettre" }).data;
    RETURN $mine.subscriber_id IS NONE AND $mine.global.channels == {} AND $mine.resolved.channels.email == { allowed: true, level: "default" }
        AND count(SELECT id FROM notification_preference) == 0;
};

-- test: abonné de la personne connectée : refusé pour la session système (aucune identité)
RETURN fn::notification_my_subscriber({ tenant: NONE, create: false }).code == "NOTIFICATION_PERMISSION_DENIED"
    AND fn::notification_my_preference_get({}).error.code == "NOTIFICATION_PERMISSION_DENIED";

-- test: fonctions internes : cibles, vue par niveau, contrôle et écriture
{
    LET $s = fn::notification_subscriber_find({ tenant: auth_organization:alpha, subscriber_id: "t" });
    LET $targets = fn::notification_preference_targets({ tenant: auth_organization:alpha, workflow: notification_workflow:lettre, category: "actualites" });
    LET $applied = fn::notification_preference_apply({ tenant: auth_organization:alpha, level: "subscriber_workflow", subscriber: $s, workflow: $targets.workflow, category: NONE, channels: { push: false }, quiet_hours: NONE, language: "fr" });
    LET $written = fn::notification_preference_write({ tenant: auth_organization:alpha, level: "subscriber_workflow", subscriber: $s.id, workflow: notification_workflow:lettre, channels: { sms: true } });
    LET $view = fn::notification_preference_view({ tenant: auth_organization:alpha, subscriber: $s, workflow: NONE });
    RETURN $targets.code IS NONE AND $targets.category.key == "actualites" AND $applied.ok
        AND $written.channels == { push: false, sms: true }
        AND $view.workflows.map(|$w| [$w.key, $w.channels]) == [["lettre", { push: false, sms: true }]] AND $view.resolved IS NONE
        AND fn::notification_preference_targets({ tenant: auth_organization:beta, workflow: notification_workflow:lettre }).code == "NOTIFICATION_WORKFLOW_NOT_FOUND";
};

-- test: désabonnement par lien : réservé à l'hôte (session système ou worker)
-- en tant que: admin
RETURN fn::notification_unsubscribe({ subscriber: "notification_subscriber:x", category: "notification_category:actualites", channel: "email" }).error.code == "NOTIFICATION_PERMISSION_DENIED";

-- test: désabonnement par lien : coupe l'e-mail pour la catégorie ; publie notification.subscriber.unsubscribed
{
    LET $s = fn::notification_subscriber_find({ tenant: auth_organization:alpha, subscriber_id: "t" });
    LET $r = fn::notification_unsubscribe({ subscriber: <string> $s.id, category: "notification_category:actualites", channel: "email" }).data;
    LET $again = fn::notification_unsubscribe({ subscriber: <string> $s.id, category: "notification_category:actualites", channel: "email" }).ok;
    LET $event = (SELECT VALUE payload FROM ONLY event_outbox WHERE event_type = "notification.subscriber.unsubscribed" LIMIT 1);
    RETURN $r == { subscriber: $s.id, level: "subscriber_category", channel: "email" } AND $again
        AND (SELECT VALUE channels FROM ONLY notification_preference WHERE subscriber = $s.id AND level = "subscriber_category" LIMIT 1) == { email: false }
        AND fn::notification_preference_resolve({ tenant: auth_organization:alpha, workflow: (SELECT * FROM ONLY notification_workflow:lettre), subscriber: $s }).channels.email == { allowed: false, level: "subscriber_category" }
        AND $event == { subscriber_id: <string> $s.id, tenant: "auth_organization:alpha", category_id: "notification_category:actualites", channel: "email" };
};

-- test: désabonnement d'un parcours sans catégorie ; lien invalide (cibles manquantes ou supprimées)
{
    LET $s = fn::notification_subscriber_find({ tenant: auth_organization:alpha, subscriber_id: "t" });
    RETURN fn::notification_unsubscribe({ subscriber: <string> $s.id, workflow: "notification_workflow:sans_avis", channel: "email" }).data.level == "subscriber_workflow"
        AND fn::notification_unsubscribe({ subscriber: <string> $s.id, channel: "email" }).error.code == "NOTIFICATION_INVALID_INPUT"
        AND fn::notification_unsubscribe({ subscriber: <string> $s.id, workflow: "notification_workflow:sans_avis", category: "notification_category:actualites", channel: "email" }).error.code == "NOTIFICATION_INVALID_INPUT"
        AND fn::notification_unsubscribe({ subscriber: "notification_subscriber:supprime", workflow: "notification_workflow:sans_avis", channel: "email" }).error.code == "NOTIFICATION_UNSUBSCRIBE_INVALID"
        AND fn::notification_unsubscribe({ subscriber: <string> $s.id, category: "notification_category:supprimee", channel: "email" }).error.code == "NOTIFICATION_UNSUBSCRIBE_INVALID";
};

-- test: déclenchement refusé par une préférence : étape et déclenchement écartés avec le niveau
-- en tant que: admin
{
    LET $r = fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "lettre", idempotency_key: "pref-1", to: { subscriber_id: "t" } }).data;
    RETURN $r.status == "skipped" AND $r.skip_reason == "preference:subscriber_category"
        AND (SELECT VALUE [status, skip_reason] FROM notification_job WHERE run = $r.run_id) == [["skipped", "preference:subscriber_category"]];
};

-- test: un choix fait après le déclenchement est respecté à la réservation : étape écartée, rien n'est rendu
{
    LET $r = fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "facture", idempotency_key: "pref-2", to: { subscriber_id: "s" } }).data;
    LET $s = fn::notification_subscriber_find({ tenant: auth_organization:alpha, subscriber_id: "s" });
    CREATE notification_preference CONTENT { tenant: auth_organization:alpha, level: "tenant_workflow", workflow: notification_workflow:facture, channels: { email: false } };
    LET $claimed = fn::notification_job_claim({ worker_id: "w", limit: 10 }).data;
    RETURN $r.status == "created" AND $claimed == []
        AND (SELECT VALUE [status, skip_reason, attempts] FROM notification_job WHERE run = $r.run_id) == [["skipped", "preference:tenant_workflow", 0]]
        AND (SELECT VALUE status FROM ONLY $r.run_id) == "skipped";
};

-- test: étape réservée : heures calmes de l'abonné et cible du lien de désabonnement (catégorie du parcours) ; aucune pour un parcours critique
{
    LET $s = fn::notification_subscriber_find({ tenant: auth_organization:alpha, subscriber_id: "s" });
    DELETE notification_preference WHERE level = "subscriber_category";
    UPDATE notification_preference SET channels = { email: true } WHERE level = "subscriber_global" AND subscriber = $s.id;
    LET $a = fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "lettre", idempotency_key: "calme-1", to: { subscriber_id: "s" } }).data;
    LET $b = fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "alerte", idempotency_key: "calme-2", to: { subscriber_id: "s" } }).data;
    LET $claimed = fn::notification_job_claim({ worker_id: "w", limit: 10 }).data;
    LET $lettre = array::find($claimed, |$j| $j.run_id = $a.run_id);
    LET $alerte = array::find($claimed, |$j| $j.run_id = $b.run_id);
    RETURN $lettre.quiet_hours.timezone == "America/Montreal" AND array::len($lettre.quiet_hours.ranges) == 2
        AND $lettre.unsubscribe.{ scope, subscriber, category, workflow, channel } == { scope: "alpha", subscriber: $s.id, category: notification_category:actualites, workflow: NONE, channel: "email" }
        AND !$lettre.critical
        AND $alerte.critical AND $alerte.quiet_hours IS NONE AND $alerte.unsubscribe IS NONE;
};

-- test: étape reportée à la fin des heures calmes : rendue à la file sans tentative, reprise à la date donnée
{
    LET $job = (SELECT * FROM ONLY notification_job WHERE status = "running" AND run.idempotency_key = "calme-1" LIMIT 1);
    LET $later = time::now() + 8h;
    LET $r = fn::notification_job_release({ job_id: <string> $job.id, claim_token: $job.claim_token, not_before: $later }).data;
    RETURN $r == { status: "queued", next_retry_at: $later }
        AND (SELECT VALUE [status, attempts, next_retry_at] FROM ONLY $job.id) == ["queued", 0, $later]
        AND array::len(fn::notification_job_claim({ worker_id: "w", limit: 10 }).data) == 0;
};
