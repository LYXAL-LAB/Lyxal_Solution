-- lyxal-test: assertions
-- Gestion : parcours (création, clé unique, modification, activation conditionnée aux gabarits,
-- liste, état), mises en page (emplacement du contenu, HTML nettoyé), gabarits et versions par
-- langue, réglages ; isolation entre organisations et permissions.
--
-- identité admin: { "id": "auth_session:admin", "pv": 1, "permissions": ["notification.read", "notification.manage", "notification.send"] }
-- identité autre: { "id": "auth_session:autre", "pv": 1, "permissions": ["notification.read", "notification.manage", "notification.send"] }
-- identité membre: { "id": "auth_session:membre", "pv": 1, "permissions": [] }
-- identité plateforme: { "id": "auth_session:plateforme", "pv": 1, "permissions": ["notification.installation.manage"] }

-- préparation: organisations, identités et sessions
{
    CREATE auth_organization:alpha CONTENT { slug: "alpha", name: "Alpha BTP" };
    CREATE auth_organization:beta CONTENT { slug: "beta", name: "Beta" };
    CREATE auth_identity:admin CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "admin@alpha.test" } };
    CREATE auth_identity:autre CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "admin@beta.test" } };
    CREATE auth_identity:membre CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "membre@alpha.test" } };
    CREATE auth_identity:plateforme CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "plateforme@lyxal.test" } };
    RELATE auth_identity:admin->auth_member_of->auth_organization:alpha;
    RELATE auth_identity:membre->auth_member_of->auth_organization:alpha;
    RELATE auth_identity:autre->auth_member_of->auth_organization:beta;
    CREATE auth_session:admin CONTENT { identity: auth_identity:admin, organization: auth_organization:alpha, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_session:membre CONTENT { identity: auth_identity:membre, organization: auth_organization:alpha, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_session:autre CONTENT { identity: auth_identity:autre, organization: auth_organization:beta, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_session:plateforme CONTENT { identity: auth_identity:plateforme, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE notification_layout:maison_alpha CONTENT { tenant: auth_organization:alpha, key: "alpha_fixe", name: "Alpha", html: "{{ content }}", text: "{{ content }}" };
};

-- test: parcours créé à l'état brouillon
-- en tant que: admin
RETURN fn::notification_workflow_create({
    tenant: "auth_organization:alpha",
    key: "devis_envoye",
    name: "Devis envoyé",
    trigger_event: "crm.quote.sent",
    payload_schema: { fields: { quote_number: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 32 } }], required: true } }, unknown_keys: "reject" },
    steps: [{ key: "email", channel: "email" }],
    tags: ["crm"]
}).data.{ key, status, critical, sensitive, scope_key } == { key: "devis_envoye", status: "draft", critical: false, sensitive: false, scope_key: "alpha" };

-- test: clé déjà utilisée dans la même organisation refusée ; autorisée dans une autre
-- en tant que: admin
RETURN fn::notification_workflow_create({ tenant: "auth_organization:alpha", key: "devis_envoye", name: "Doublon", steps: [{ key: "email", channel: "email" }] }).error.code == "NOTIFICATION_WORKFLOW_KEY_TAKEN";

-- test: la même clé dans une autre organisation est acceptée
-- en tant que: autre
RETURN fn::notification_workflow_create({ tenant: "auth_organization:beta", key: "devis_envoye", name: "Devis", steps: [{ key: "email", channel: "email" }] }).ok;

-- test: entrées invalides (clé, étapes vides, canal inconnu, étapes en double)
-- en tant que: admin
RETURN fn::notification_workflow_create({ tenant: "auth_organization:alpha", key: "Pas Snake", name: "X", steps: [{ key: "email", channel: "email" }] }).error.code == "NOTIFICATION_INVALID_INPUT"
    AND fn::notification_workflow_create({ tenant: "auth_organization:alpha", key: "vide", name: "X", steps: [] }).error.code == "NOTIFICATION_INVALID_INPUT"
    AND fn::notification_workflow_create({ tenant: "auth_organization:alpha", key: "sms", name: "X", steps: [{ key: "sms", channel: "sms" }] }).error.code == "NOTIFICATION_INVALID_INPUT"
    AND fn::notification_workflow_create({ tenant: "auth_organization:alpha", key: "double", name: "X", steps: [{ key: "email", channel: "email" }, { key: "email", channel: "email" }] }).error.code == "NOTIFICATION_INVALID_INPUT";

-- test: un schéma de variables invalide est refusé par lyxal_core
-- en tant que: admin
-- attendu-erreur: CORE_UNSUPPORTED_OPTION
RETURN fn::notification_workflow_create({ tenant: "auth_organization:alpha", key: "schema_faux", name: "X", payload_schema: { fields: { a: { pipeline: [{ rule: "regle_inconnue" }] } } }, steps: [{ key: "email", channel: "email" }] });

-- test: un membre sans permission ne crée pas de parcours ; un administrateur d'une autre organisation non plus
-- en tant que: membre
RETURN fn::notification_workflow_create({ tenant: "auth_organization:alpha", key: "interdit", name: "X", steps: [{ key: "email", channel: "email" }] }).error.code == "NOTIFICATION_PERMISSION_DENIED";

-- test: une organisation ne crée pas de parcours chez une autre, ni pour l'installation
-- en tant que: autre
RETURN fn::notification_workflow_create({ tenant: "auth_organization:alpha", key: "intrus", name: "X", steps: [{ key: "email", channel: "email" }] }).error.code == "NOTIFICATION_PERMISSION_DENIED"
    AND fn::notification_workflow_create({ key: "intrus", name: "X", steps: [{ key: "email", channel: "email" }] }).error.code == "NOTIFICATION_PERMISSION_DENIED";

-- test: un parcours sans gabarit ne peut pas être activé
-- en tant que: admin
{
    LET $w = (SELECT VALUE id FROM ONLY notification_workflow WHERE scope_key = "alpha" AND key = "devis_envoye" LIMIT 1);
    LET $r = fn::notification_workflow_set_status({ workflow: <string> $w, status: "active" });
    RETURN $r.error.code == "NOTIFICATION_TEMPLATE_DEFAULT_LOCALE_REQUIRED" AND $r.error.details.steps == ["email"];
};

-- test: mise en page sans emplacement du contenu refusée
-- en tant que: admin
RETURN fn::notification_layout_create({ tenant: "auth_organization:alpha", key: "maison", name: "Maison", html: "<p>sans contenu</p>", text: "{{ content }}" }).error.code == "NOTIFICATION_LAYOUT_CONTENT_SLOT_MISSING";

-- test: mise en page créée, HTML nettoyé (script, iframe et gestionnaire d'événement retirés)
-- en tant que: admin
{
    LET $l = fn::notification_layout_create({
        tenant: "auth_organization:alpha", key: "maison", name: "Maison",
        html: "<div onclick=\"vol()\"><script>vol()</script><iframe src=\"x\"></iframe>{{ content }}</div>",
        text: "Alpha\n{{ content }}"
    }).data;
    RETURN !string::contains($l.html, "script") AND !string::contains($l.html, "iframe") AND !string::contains($l.html, "onclick")
        AND string::contains($l.html, "{{ content }}");
};

-- test: clé de mise en page déjà utilisée refusée
-- en tant que: admin
RETURN fn::notification_layout_create({ tenant: "auth_organization:alpha", key: "maison", name: "Bis", html: "{{ content }}", text: "{{ content }}" }).error.code == "NOTIFICATION_LAYOUT_KEY_TAKEN";

-- test: mise en page modifiée ; emplacement du contenu toujours exigé
-- en tant que: admin
{
    LET $l = (SELECT VALUE id FROM ONLY notification_layout WHERE scope_key = "alpha" AND key = "maison" LIMIT 1);
    RETURN fn::notification_layout_update({ layout: <string> $l, name: "Maison Alpha" }).data.name == "Maison Alpha"
        AND fn::notification_layout_update({ layout: <string> $l, text: "plus de contenu" }).error.code == "NOTIFICATION_LAYOUT_CONTENT_SLOT_MISSING";
};

-- test: mises en page de l'organisation listées ; celles d'une autre organisation invisibles
-- en tant que: autre
{
    LET $l = (SELECT VALUE id FROM notification_layout WHERE key = "maison");
    RETURN fn::notification_layout_list({ tenant: "auth_organization:beta" }).data == [] AND $l == []
        AND fn::notification_layout_list({ tenant: "auth_organization:alpha" }).error.code == "NOTIFICATION_PERMISSION_DENIED"
        AND fn::notification_layout_get({ layout: "notification_layout:inconnue" }).error.code == "NOTIFICATION_NOT_FOUND";
};

-- test: gabarit créé pour l'étape, avec une mise en page de l'organisation ; étape inconnue refusée
-- en tant que: admin
{
    LET $w = (SELECT VALUE id FROM ONLY notification_workflow WHERE scope_key = "alpha" AND key = "devis_envoye" LIMIT 1);
    LET $l = (SELECT VALUE id FROM ONLY notification_layout WHERE scope_key = "alpha" AND key = "maison" LIMIT 1);
    RETURN fn::notification_template_create({ workflow: <string> $w, step_key: "email", default_locale: "fr", layout: <string> $l }).data.{ step_key, default_locale } == { step_key: "email", default_locale: "fr" }
        AND fn::notification_template_create({ workflow: <string> $w, step_key: "sms", default_locale: "fr" }).error.code == "NOTIFICATION_INVALID_INPUT"
        AND fn::notification_template_create({ workflow: <string> $w, step_key: "email", default_locale: "en" }).error.code == "NOTIFICATION_TEMPLATE_EXISTS";
};

-- test: une mise en page d'une autre organisation n'est pas utilisable ; celle de l'installation oui
-- en tant que: autre
{
    LET $w = (SELECT VALUE id FROM ONLY notification_workflow WHERE scope_key = "beta" AND key = "devis_envoye" LIMIT 1);
    LET $alpha = fn::notification_template_create({ workflow: <string> $w, step_key: "email", default_locale: "fr", layout: "notification_layout:maison_alpha" });
    RETURN $alpha.error.code == "NOTIFICATION_NOT_FOUND"
        AND fn::notification_template_create({ workflow: <string> $w, step_key: "email", default_locale: "fr", layout: "notification_layout:default" }).ok;
};

-- test: version française enregistrée ; objet sur une ligne, HTML nettoyé
-- en tant que: admin
{
    LET $t = (SELECT VALUE id FROM ONLY notification_template WHERE workflow.key = "devis_envoye" AND tenant = auth_organization:alpha LIMIT 1);
    LET $v = fn::notification_template_locale_set({
        template: <string> $t, locale: "fr",
        subject: "Votre devis {{ payload.quote_number }}\r\nBcc: espion@x.test",
        html_body: "<p onload=\"x()\">Devis {{ payload.quote_number }}</p><script>x()</script>",
        text_body: "Devis {{ payload.quote_number }}"
    }).data;
    RETURN !string::contains($v.subject, "\n") AND !string::contains($v.subject, "\r")
        AND !string::contains($v.html_body, "script") AND !string::contains($v.html_body, "onload");
};

-- test: version remplacée (une seule version par langue), version anglaise ajoutée
-- en tant que: admin
{
    LET $t = (SELECT VALUE id FROM ONLY notification_template WHERE workflow.key = "devis_envoye" AND tenant = auth_organization:alpha LIMIT 1);
    fn::notification_template_locale_set({ template: <string> $t, locale: "fr", subject: "Devis {{ payload.quote_number }}", html_body: "<p>Devis {{ payload.quote_number }}</p>", text_body: "Devis {{ payload.quote_number }}" });
    fn::notification_template_locale_set({ template: <string> $t, locale: "en", subject: "Quote {{ payload.quote_number }}", html_body: "<p>Quote {{ payload.quote_number }}</p>", text_body: "Quote {{ payload.quote_number }}" });
    LET $g = fn::notification_template_get({ template: <string> $t }).data;
    RETURN $g.locales.map(|$l| [$l.locale, $l.subject]) == [["en", "Quote {{ payload.quote_number }}"], ["fr", "Devis {{ payload.quote_number }}"]];
};

-- test: parcours activé une fois son gabarit prêt
-- en tant que: admin
{
    LET $w = (SELECT VALUE id FROM ONLY notification_workflow WHERE scope_key = "alpha" AND key = "devis_envoye" LIMIT 1);
    RETURN fn::notification_workflow_set_status({ workflow: <string> $w, status: "active" }).data.status == "active";
};

-- test: la version de la langue par défaut ne peut pas être supprimée ; une autre version oui
-- en tant que: admin
{
    LET $t = (SELECT VALUE id FROM ONLY notification_template WHERE workflow.key = "devis_envoye" AND tenant = auth_organization:alpha LIMIT 1);
    RETURN fn::notification_template_locale_delete({ template: <string> $t, locale: "fr" }).error.code == "NOTIFICATION_TEMPLATE_DEFAULT_LOCALE_REQUIRED"
        AND fn::notification_template_locale_delete({ template: <string> $t, locale: "en" }).ok
        AND fn::notification_template_locale_delete({ template: <string> $t, locale: "en" }).error.code == "NOTIFICATION_TEMPLATE_LOCALE_MISSING";
};

-- test: gabarit d'un parcours actif : langue par défaut sans version refusée ; mise en page retirée
-- en tant que: admin
{
    LET $t = (SELECT VALUE id FROM ONLY notification_template WHERE workflow.key = "devis_envoye" AND tenant = auth_organization:alpha LIMIT 1);
    RETURN fn::notification_template_update({ template: <string> $t, default_locale: "de" }).error.code == "NOTIFICATION_TEMPLATE_DEFAULT_LOCALE_REQUIRED"
        AND fn::notification_template_update({ template: <string> $t, clear_layout: true }).data.layout IS NONE;
};

-- test: parcours actif : une nouvelle étape sans gabarit refusée ; nom et étiquettes modifiés
-- en tant que: admin
{
    LET $w = (SELECT VALUE id FROM ONLY notification_workflow WHERE scope_key = "alpha" AND key = "devis_envoye" LIMIT 1);
    RETURN fn::notification_workflow_update({ workflow: <string> $w, steps: [{ key: "email", channel: "email" }, { key: "rappel", channel: "email" }] }).error.code == "NOTIFICATION_TEMPLATE_DEFAULT_LOCALE_REQUIRED"
        AND fn::notification_workflow_update({ workflow: <string> $w, name: "Devis transmis", tags: ["crm", "devis"] }).data.{ name, tags } == { name: "Devis transmis", tags: ["crm", "devis"] };
};

-- test: liste par état et lecture du parcours ; parcours introuvable
-- en tant que: admin
RETURN fn::notification_workflow_list({ tenant: "auth_organization:alpha", status: "active" }).data.key == ["devis_envoye"]
    AND fn::notification_workflow_list({ tenant: "auth_organization:alpha", status: "draft" }).data == []
    AND fn::notification_workflow_get({ workflow: "notification_workflow:inconnu" }).error.code == "NOTIFICATION_WORKFLOW_NOT_FOUND";

-- test: une autre organisation ne voit ni ne modifie le parcours
-- en tant que: autre
{
    LET $w = (SELECT VALUE id FROM notification_workflow WHERE scope_key = "alpha");
    RETURN $w == [] AND fn::notification_workflow_list({ tenant: "auth_organization:alpha" }).error.code == "NOTIFICATION_PERMISSION_DENIED";
};

-- test: un membre sans permission ne lit rien
-- en tant que: membre
RETURN fn::notification_workflow_list({ tenant: "auth_organization:alpha" }).error.code == "NOTIFICATION_PERMISSION_DENIED"
    AND array::len(SELECT * FROM notification_workflow) == 0;

-- test: désactivation (un parcours n'est jamais supprimé)
-- en tant que: admin
{
    LET $w = (SELECT VALUE id FROM ONLY notification_workflow WHERE scope_key = "alpha" AND key = "devis_envoye" LIMIT 1);
    RETURN fn::notification_workflow_set_status({ workflow: <string> $w, status: "inactive" }).data.status == "inactive"
        AND fn::notification_workflow_set_status({ workflow: <string> $w, status: "active" }).data.status == "active";
};

-- test: réglages de l'organisation : surcharge partielle de ceux de l'installation
-- en tant que: admin
RETURN fn::notification_settings_set({ tenant: "auth_organization:alpha", from_name: "Alpha BTP", reply_to: "Contact@Alpha.test", max_attempts: 3 }).ok
    AND fn::notification_settings_get({ tenant: "auth_organization:alpha" }).data.effective
        == { default_locale: "fr", from_name: "Alpha BTP", reply_to: "contact@alpha.test", max_attempts: 3, retention_days_runs: 90, retention_days_log: 30 };

-- test: réglages modifiés sans recréation ; valeurs hors bornes refusées
-- en tant que: admin
RETURN fn::notification_settings_set({ tenant: "auth_organization:alpha", default_locale: "en" }).data.{ default_locale, max_attempts } == { default_locale: "en", max_attempts: 3 }
    AND fn::notification_settings_set({ tenant: "auth_organization:alpha", max_attempts: 50 }).error.code == "NOTIFICATION_INVALID_INPUT";

-- test: une organisation ne lit ni ne modifie les réglages d'une autre ou de l'installation
-- en tant que: autre
RETURN fn::notification_settings_get({ tenant: "auth_organization:alpha" }).error.code == "NOTIFICATION_PERMISSION_DENIED"
    AND fn::notification_settings_set({ max_attempts: 2 }).error.code == "NOTIFICATION_PERMISSION_DENIED";

-- test: l'administrateur de l'installation règle l'installation
-- en tant que: plateforme
RETURN fn::notification_settings_set({ from_name: "Lyxal", retention_days_log: 14 }).data.{ from_name, retention_days_log, max_attempts } == { from_name: "Lyxal", retention_days_log: 14, max_attempts: 8 };

-- test: réglages de l'installation visibles dans les réglages effectifs de l'organisation
-- en tant que: admin
RETURN fn::notification_settings_get({ tenant: "auth_organization:alpha" }).data.effective.{ from_name, retention_days_log } == { from_name: "Alpha BTP", retention_days_log: 14 };

-- test: l'administrateur de l'installation modifie la mise en page de l'installation
-- en tant que: plateforme
RETURN fn::notification_layout_update({ layout: "notification_layout:default", name: "Défaut" }).data.name == "Défaut";

-- préparation: les permissions de table refusent désormais toute écriture (fin du fichier)
{
    DEFINE TABLE OVERWRITE notification_layout TYPE NORMAL SCHEMAFULL PERMISSIONS
        FOR select WHERE fn::notification_can({ action: "read_config", tenant: tenant }) FOR create, update, delete NONE;
    DEFINE TABLE OVERWRITE notification_settings TYPE NORMAL SCHEMAFULL PERMISSIONS
        FOR select WHERE fn::notification_can({ action: "read_config", tenant: tenant }) FOR create, update, delete NONE;
};

-- test: une écriture filtrée par les permissions de la table est signalée, jamais annoncée comme réussie
-- en tant que: plateforme
RETURN fn::notification_layout_update({ layout: "notification_layout:default", name: "Refusé" }).error.code == "NOTIFICATION_WRITE_FORBIDDEN"
    AND fn::notification_settings_set({ from_name: "Refusé" }).error.code == "NOTIFICATION_WRITE_FORBIDDEN";
