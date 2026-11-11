-- lyxal-test: assertions
-- Fonctions internes appelées directement : nettoyage HTML, emplacement du contenu, réglages
-- effectifs, étapes sans gabarit, données de rendu, contrôle de réservation, fin d'un
-- déclenchement.

-- préparation: organisation, parcours et déclenchement réservé
{
    CREATE auth_organization:alpha CONTENT { slug: "alpha", name: "Alpha BTP" };
    CREATE notification_workflow:w CONTENT { tenant: auth_organization:alpha, key: "w", name: "W", status: "active", steps: [{ key: "email", channel: "email" }, { key: "rappel", channel: "email" }] };
    UPDATE auth_organization:alpha SET locale = "en";
    CREATE notification_template:w_email CONTENT { tenant: auth_organization:alpha, workflow: notification_workflow:w, step_key: "email", subject: "S", html_body: "<p>H</p>", text_body: "T", keys: ["notification.common.greeting"] };
    fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "w", idempotency_key: "k-1", recipient: { email: "c@exemple.fr", locale: "fr-CA" } });
    fn::notification_job_claim({ worker_id: "w1", limit: 1 });
};

-- préparation: texte canadien de la salutation
fn::i18n_translation_set({ key: "notification.common.greeting", locale: "fr-CA", text: "Allô," });

-- test: HTML nettoyé ; texte conservé
RETURN fn::notification_html_clean({ html: "<b onmouseover=\"x()\">ok</b><script>x()</script>" }) == "<b>ok</b>";

-- test: emplacement du contenu détecté
RETURN fn::notification_has_content_slot({ text: "a {{ content }} b" }) AND !fn::notification_has_content_slot({ text: "{{content}}" });

-- test: réglages effectifs sans réglages de l'organisation : ceux de l'installation
RETURN fn::notification_settings_effective({ tenant: auth_organization:alpha }).max_attempts == 8
    AND fn::notification_settings_effective({}) == { from_name: NONE, reply_to: NONE, max_attempts: 8, retention_days_runs: 90, retention_days_log: 30 };

-- test: étapes sans gabarit
RETURN fn::notification_workflow_missing_templates({ workflow: notification_workflow:w, steps: [{ key: "email" }, { key: "rappel" }] }) == ["rappel"];

-- test: données de rendu : langue du destinataire inactive (fr-CA), repli sur sa langue parente active (fr)
{
    LET $job = (SELECT * FROM ONLY notification_job WHERE status = "running" LIMIT 1);
    RETURN fn::notification_job_payload({ job: $job }).{ locale, subject, texts, texts_error }
        == { locale: "fr", subject: "S", texts: [{ key: "notification.common.greeting", text: "Bonjour,", syntax: "plain", locale: "fr", overridden: false, missing: false }], texts_error: NONE };
};

-- préparation: langue du destinataire activée
fn::i18n_locale_activate({ locale: "fr-CA" });

-- test: données de rendu : langue exacte du destinataire, texte de cette langue
{
    LET $job = (SELECT * FROM ONLY notification_job WHERE status = "running" LIMIT 1);
    RETURN fn::notification_job_payload({ job: $job }).{ locale, texts } == { locale: "fr-CA", texts: [{ key: "notification.common.greeting", text: "Allô,", syntax: "plain", locale: "fr-CA", overridden: false, missing: false }] };
};

-- préparation: déclenchement pour un destinataire sans langue
fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "w", idempotency_key: "k-2", recipient: { email: "d@exemple.fr" } });

-- test: données de rendu : sans langue du destinataire, celle de son organisation (en), notée sur le déclenchement
{
    LET $job = (SELECT * FROM ONLY notification_job WHERE run.idempotency_key = "k-2" AND step_key = "email" LIMIT 1);
    RETURN fn::notification_job_payload({ job: $job }).{ locale, texts } == { locale: "en", texts: [{ key: "notification.common.greeting", text: "Hello,", syntax: "plain", locale: "en", overridden: false, missing: false }] };
};

-- test: contenu d'un gabarit nettoyé : objet sur une ligne, HTML nettoyé, clés sans doublon, champs absents ignorés
RETURN fn::notification_template_content({ subject: " Objet\r\nBcc: x@y.test ", html_body: "<p onload=\"x()\">a</p><script>x()</script>", keys: ["a.b", "a.b"] })
        == { subject: "ObjetBcc: x@y.test", html_body: "<p>a</p>", keys: ["a.b"] }
    AND fn::notification_template_content({}) == {};

-- test: clés inconnues de lyxal_i18n
RETURN fn::notification_template_unknown_keys({ keys: ["notification.common.greeting", "notification.absente", "autre.cle"] }) == { error: NONE, unknown: ["notification.absente", "autre.cle"] }
    AND fn::notification_template_unknown_keys({ keys: [] }) == { error: NONE, unknown: [] };

-- test: contrôle de réservation : jeton juste, jeton faux, étape inconnue
{
    LET $job = (SELECT * FROM ONLY notification_job WHERE status = "running" LIMIT 1);
    RETURN fn::notification_job_check({ job: $job.id, claim_token: $job.claim_token }).code IS NONE
        AND fn::notification_job_check({ job: $job.id, claim_token: "faux" }).code == "NOTIFICATION_JOB_CLAIM_LOST"
        AND fn::notification_job_check({ job: notification_job:inconnu, claim_token: "x" }).code == "NOTIFICATION_NOT_FOUND";
};

-- test: un déclenchement n'est terminé qu'avec toutes ses étapes
{
    LET $run = (SELECT VALUE id FROM ONLY notification_run LIMIT 1);
    LET $before = fn::notification_run_finalize({ run: $run });
    UPDATE notification_job SET status = "completed" WHERE run = $run AND step_key = "email";
    UPDATE notification_job SET status = "canceled" WHERE run = $run AND step_key = "rappel";
    LET $after = fn::notification_run_finalize({ run: $run });
    RETURN $before == { finalized: false } AND $after == { finalized: true, status: "completed" };
};
