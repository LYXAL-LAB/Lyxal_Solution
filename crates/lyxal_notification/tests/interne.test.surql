-- lyxal-test: assertions
-- Fonctions internes appelées directement : nettoyage HTML, emplacement du contenu, réglages
-- effectifs, étapes sans gabarit, données de rendu, contrôle de réservation, fin d'un
-- déclenchement.

-- préparation: organisation, parcours et déclenchement réservé
{
    CREATE auth_organization:alpha CONTENT { slug: "alpha", name: "Alpha BTP" };
    CREATE notification_workflow:w CONTENT { tenant: auth_organization:alpha, key: "w", name: "W", status: "active", steps: [{ key: "email", channel: "email" }, { key: "rappel", channel: "email" }] };
    CREATE notification_template:w_email CONTENT { tenant: auth_organization:alpha, workflow: notification_workflow:w, step_key: "email", default_locale: "en" };
    CREATE notification_template_locale:w_email_en CONTENT { template: notification_template:w_email, locale: "en", subject: "S", html_body: "<p>H</p>", text_body: "T" };
    CREATE notification_template_locale:w_email_fr_ca CONTENT { template: notification_template:w_email, locale: "fr-CA", subject: "S-CA", html_body: "<p>H</p>", text_body: "T" };
    fn::notification_trigger({ tenant: "auth_organization:alpha", workflow_key: "w", idempotency_key: "k-1", recipient: { email: "c@exemple.fr", locale: "fr-CA" } });
    fn::notification_job_claim({ worker_id: "w1", limit: 1 });
};

-- test: HTML nettoyé ; texte conservé
RETURN fn::notification_html_clean({ html: "<b onmouseover=\"x()\">ok</b><script>x()</script>" }) == "<b>ok</b>";

-- test: emplacement du contenu détecté
RETURN fn::notification_has_content_slot({ text: "a {{ content }} b" }) AND !fn::notification_has_content_slot({ text: "{{content}}" });

-- test: réglages effectifs sans réglages de l'organisation : ceux de l'installation
RETURN fn::notification_settings_effective({ tenant: auth_organization:alpha }).max_attempts == 8
    AND fn::notification_settings_effective({}).default_locale == "fr";

-- test: étapes sans gabarit prêt
RETURN fn::notification_workflow_missing_templates({ workflow: notification_workflow:w, steps: [{ key: "email" }, { key: "rappel" }] }) == ["rappel"];

-- test: données de rendu : langue exacte trouvée (fr-CA)
{
    LET $job = (SELECT * FROM ONLY notification_job WHERE status = "running" LIMIT 1);
    RETURN fn::notification_job_payload({ job: $job }).{ locale, subject } == { locale: "fr-CA", subject: "S-CA" };
};

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
