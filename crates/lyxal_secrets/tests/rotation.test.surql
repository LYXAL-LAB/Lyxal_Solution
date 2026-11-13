-- lyxal-test: assertions
-- Cycle de vie : alertes d'échéance et rappel de rotation (une seule fois, remis à zéro), rotation
-- en quatre étapes (ordre, une seule en cours, nouvelle valeur du worker, nouveaux essais, échec,
-- annulation, bascule), urgence, essai sans bascule, rotation des clés d'organisation ; droits,
-- gardes, journal et bus.
--
-- identité admin: { "id": "auth_session:admin", "pv": 1, "permissions": ["secrets.secret.list", "secrets.secret.write", "secrets.secret.delete", "secrets.secret.restore", "secrets.secret.purge", "secrets.audit.read", "secrets.settings.manage", "secrets.value.read"] }
-- identité redacteur: { "id": "auth_session:redacteur", "pv": 1, "permissions": ["secrets.secret.list", "secrets.secret.write"] }
-- identité lecteur: { "id": "auth_session:lecteur", "pv": 1, "permissions": ["secrets.secret.list"] }
-- identité humain: { "id": "auth_session:humain", "pv": 1, "permissions": ["secrets.secret.list", "secrets.value.read"] }
-- identité autre: { "id": "auth_session:autre", "pv": 1, "permissions": ["secrets.secret.list", "secrets.secret.write", "secrets.secret.delete", "secrets.secret.restore", "secrets.secret.purge", "secrets.audit.read", "secrets.settings.manage", "secrets.value.read"] }
-- identité membre: { "id": "auth_session:membre", "pv": 1, "permissions": [] }
-- identité plateforme: { "id": "auth_session:plateforme", "pv": 1, "permissions": ["secrets.installation.manage"] }
-- identité robot: { "id": "auth_session:robot", "pv": 1, "permissions": ["secrets.value.read"] }
-- identité worker: { "id": "auth_session:worker", "pv": 1, "permissions": ["secrets.worker"] }

-- préparation: organisations, identités et sessions lyxal_auth
{
    CREATE auth_organization:alpha CONTENT { slug: "alpha", name: "Alpha BTP" };
    CREATE auth_organization:beta CONTENT { slug: "beta", name: "Beta Bois" };
    FOR $n IN ["admin", "redacteur", "lecteur", "humain", "membre"] {
        CREATE type::record("auth_identity", $n) CONTENT { schema: auth_identity_schema:default_v1, traits: { email: $n + "@lyxal.test" } };
        RELATE (type::record("auth_identity", $n))->auth_member_of->auth_organization:alpha;
        CREATE type::record("auth_session", $n) CONTENT { identity: type::record("auth_identity", $n), organization: auth_organization:alpha, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    };
    CREATE auth_identity:autre CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "autre@lyxal.test" } };
    RELATE auth_identity:autre->auth_member_of->auth_organization:beta;
    CREATE auth_session:autre CONTENT { identity: auth_identity:autre, organization: auth_organization:beta, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    FOR $n IN ["plateforme", "worker"] {
        CREATE type::record("auth_identity", $n) CONTENT { schema: auth_identity_schema:default_v1, traits: { email: $n + "@lyxal.test" } };
        CREATE type::record("auth_session", $n) CONTENT { identity: type::record("auth_identity", $n), idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    };
    -- Compte de service d'alpha : session sans identité
    CREATE auth_application:robot CONTENT { tenant: auth_organization:alpha, client_id: "lyxal-test-robot-alpha", name: "Robot", type: "machine", redirect_uris: [], state: "active", permissions_version: 1 };
    CREATE auth_session:robot CONTENT { application: auth_application:robot, kind: "service", organization: auth_organization:alpha, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    -- Table de passage d'identifiants entre identités (lisible par tous)
    DEFINE TABLE OVERWRITE passe SCHEMALESS PERMISSIONS FULL;
};

-- préparation: clé d'alpha, secret à rotation (90 jours) avec une version, secret à échéance (10 jours)
{
    fn::secrets_tenant_key_create({ tenant: "auth_organization:alpha", key_id: "k1", wrapped: "enc:v2:m1:K1" });
    LET $s = fn::secrets_secret_create({ tenant: "auth_organization:alpha", path: "api/brevo", kind: "api_key", rotation_period: 90d }).data.id;
    fn::secrets_version_add({ secret: <string> $s, number: 1, envelope: "enc:v2:k1:AAAA", key_id: "k1" });
    LET $e = fn::secrets_secret_create({ tenant: "auth_organization:alpha", path: "api/echeance", kind: "token", expires_at: time::now() + 10d }).data.id;
    CREATE passe:ids SET s = $s, e = $e;
};

-- test: échéance dans le délai d'alerte : signalée ; rien d'autre n'est dû
-- en tant que: worker
{
    LET $e = (SELECT VALUE e FROM ONLY passe:ids);
    LET $due = fn::secrets_due_list({}).data;
    RETURN $due.expiring.id = [$e] AND $due.expired = [] AND $due.rotation_due = [] AND $due.tenant_keys_due = [];
};

-- test: alerte posée une seule fois, puis plus listée
-- en tant que: worker
{
    LET $e = <string> (SELECT VALUE e FROM ONLY passe:ids);
    LET $first = fn::secrets_due_mark({ secret: $e, kind: "expiring" }).data.marked;
    LET $second = fn::secrets_due_mark({ secret: $e, kind: "expiring" }).data.marked;
    RETURN $first = true AND $second = false AND fn::secrets_due_list({}).data.expiring = []
        AND fn::secrets_due_mark({ secret: $e, kind: "expired" }).data.marked = false;
};

-- test: un rédacteur ne signale pas d'échéance ni ne liste les échéances
-- en tant que: redacteur
{
    LET $e = <string> (SELECT VALUE e FROM ONLY passe:ids);
    RETURN fn::secrets_due_list({}).error.code = "SECRETS_PERMISSION_DENIED"
        AND fn::secrets_due_mark({ secret: $e, kind: "expired" }).error.code = "SECRETS_PERMISSION_DENIED";
};

-- préparation: l'échéance est passée
{
    UPDATE (SELECT VALUE e FROM ONLY passe:ids) SET expires_at = time::now() - 1m;
};

-- test: échéance atteinte signalée une fois
-- en tant que: worker
{
    LET $e = <string> (SELECT VALUE e FROM ONLY passe:ids);
    RETURN fn::secrets_due_list({}).data.expired.path = ["api/echeance"]
        AND fn::secrets_due_mark({ secret: $e, kind: "expired" }).data.marked = true
        AND fn::secrets_due_list({}).data.expired = [];
};

-- test: nouvelle échéance : les alertes repartent
-- en tant que: admin
{
    LET $e = <string> (SELECT VALUE e FROM ONLY passe:ids);
    LET $f = fn::secrets_secret_update({ secret: $e, expires_at: time::now() + 200d }).data;
    RETURN $f.expiry_warned_at IS NONE AND $f.expired_notified_at IS NONE;
};

-- préparation: la date de rotation est passée
{
    UPDATE (SELECT VALUE s FROM ONLY passe:ids) SET next_rotation_at = time::now() - 1m;
};

-- test: rotation due : rappel envoyé une fois
-- en tant que: worker
{
    LET $s = <string> (SELECT VALUE s FROM ONLY passe:ids);
    RETURN fn::secrets_due_list({}).data.rotation_due.path = ["api/brevo"]
        AND fn::secrets_due_mark({ secret: $s, kind: "rotation_due" }).data.marked = true
        AND fn::secrets_due_list({}).data.rotation_due = [];
};

-- test: un lecteur ne démarre pas de rotation
-- en tant que: lecteur
{
    LET $s = <string> (SELECT VALUE s FROM ONLY passe:ids);
    RETURN fn::secrets_rotation_begin({ secret: $s }).error.code = "SECRETS_PERMISSION_DENIED";
};

-- test: une autre organisation ne voit pas le secret
-- en tant que: autre
{
    LET $s = <string> (SELECT VALUE s FROM ONLY passe:ids);
    RETURN fn::secrets_rotation_begin({ secret: $s }).error.code = "SECRETS_SECRET_NOT_FOUND";
};

-- test: le worker démarre la rotation planifiée ; une seule en cours
-- en tant que: worker
{
    LET $s = <string> (SELECT VALUE s FROM ONLY passe:ids);
    LET $r = fn::secrets_rotation_begin({ secret: $s, reason: "planifiée" });
    UPDATE passe:ids SET r1 = $r.data.id;
    RETURN $r.ok AND $r.data.state = "started" AND $r.data.previous_number = 1 AND $r.data.emergency = false
        AND fn::secrets_rotation_begin({ secret: $s }).error.code = "SECRETS_ROTATION_IN_PROGRESS";
};

-- test: le worker ne déclare pas d'urgence
-- en tant que: worker
{
    LET $e = <string> (SELECT VALUE e FROM ONLY passe:ids);
    RETURN fn::secrets_rotation_begin({ secret: $e, emergency: true }).error.code = "SECRETS_PERMISSION_DENIED";
};

-- test: étapes dans l'ordre seulement ; created exige la nouvelle version
-- en tant que: worker
{
    LET $r = <string> (SELECT VALUE r1 FROM ONLY passe:ids);
    RETURN fn::secrets_rotation_step({ rotation: $r, step: "installed" }).error.code = "SECRETS_ROTATION_STATE_INVALID"
        AND fn::secrets_rotation_step({ rotation: $r, step: "created" }).error.code = "SECRETS_ROTATION_STATE_INVALID"
        AND fn::secrets_rotation_step({ rotation: $r, step: "created", pending_number: 2 }).error.code = "SECRETS_ROTATION_STATE_INVALID"
        AND fn::secrets_rotation_finish({ rotation: $r }).error.code = "SECRETS_ROTATION_STATE_INVALID";
};

-- test: réservation par le worker : une seule fois tant que le bail court
-- en tant que: worker
{
    LET $r = (SELECT VALUE r1 FROM ONLY passe:ids);
    LET $first = fn::secrets_rotation_claim({}).data.items;
    LET $second = fn::secrets_rotation_claim({}).data.items;
    RETURN $first.id = [$r] AND $first[0].locked_until > time::now() AND $second = [];
};

-- test: un rédacteur ne réserve pas et ne fait pas avancer une rotation
-- en tant que: redacteur
{
    LET $r = <string> (SELECT VALUE r1 FROM ONLY passe:ids);
    RETURN fn::secrets_rotation_claim({}).error.code = "SECRETS_PERMISSION_DENIED"
        AND fn::secrets_rotation_step({ rotation: $r, step: "created", pending_number: 2 }).error.code = "SECRETS_PERMISSION_DENIED"
        AND fn::secrets_rotation_fail({ rotation: $r, code: "X" }).error.code = "SECRETS_PERMISSION_DENIED";
};

-- test: le worker écrit la nouvelle valeur en pending, jamais en current
-- en tant que: worker
{
    LET $s = <string> (SELECT VALUE s FROM ONLY passe:ids);
    LET $current = fn::secrets_version_add({ secret: $s, number: 2, envelope: "enc:v2:k1:BBBB", key_id: "k1" });
    LET $pending = fn::secrets_version_add({ secret: $s, number: 2, envelope: "enc:v2:k1:BBBB", key_id: "k1", stage: "pending" });
    RETURN $current.error.code = "SECRETS_PERMISSION_DENIED" AND $pending.ok AND $pending.data.labels = { current: 1, pending: 2 };
};

-- test: étape created ; ensuite le worker n'écrit plus de version
-- en tant que: worker
{
    LET $s = <string> (SELECT VALUE s FROM ONLY passe:ids);
    LET $r = <string> (SELECT VALUE r1 FROM ONLY passe:ids);
    LET $step = fn::secrets_rotation_step({ rotation: $r, step: "created", pending_number: 2 });
    RETURN $step.data.state = "created" AND $step.data.pending_number = 2
        AND fn::secrets_version_add({ secret: $s, number: 3, envelope: "enc:v2:k1:CCCC", key_id: "k1", stage: "pending" }).error.code = "SECRETS_PERMISSION_DENIED";
};

-- test: échec d'installation : nouvel essai dans une minute, étape conservée, plus réservable d'ici là
-- en tant que: worker
{
    LET $r = <string> (SELECT VALUE r1 FROM ONLY passe:ids);
    LET $f = fn::secrets_rotation_fail({ rotation: $r, code: "SECRETS_ROTATION_TEST_FAILED" }).data;
    RETURN $f.state = "created" AND $f.attempts = 1 AND $f.last_error = "SECRETS_ROTATION_TEST_FAILED"
        AND $f.next_attempt_at > time::now() + 50s AND $f.next_attempt_at < time::now() + 70s AND $f.locked_until IS NONE
        AND fn::secrets_rotation_claim({}).data.items = [];
};

-- test: installation, test, bascule : current sur la nouvelle version, previous sur l'ancienne
-- en tant que: worker
{
    LET $s = (SELECT VALUE s FROM ONLY passe:ids);
    LET $r = <string> (SELECT VALUE r1 FROM ONLY passe:ids);
    LET $a = fn::secrets_rotation_step({ rotation: $r, step: "installed" }).data.state;
    LET $b = fn::secrets_rotation_step({ rotation: $r, step: "tested" }).data.state;
    LET $done = fn::secrets_rotation_finish({ rotation: $r }).data;
    LET $f = (SELECT * FROM ONLY $s);
    RETURN $a = "installed" AND $b = "tested" AND $done.state = "succeeded" AND $done.finished_at IS NOT NONE
        AND $f.labels = { current: 2, previous: 1 } AND $f.last_rotated_at IS NOT NONE AND $f.rotation_notified_at IS NONE
        AND $f.next_rotation_at > time::now() + 89d AND fn::secrets_rotation_finish({ rotation: $r }).error.code = "SECRETS_ROTATION_STATE_INVALID";
};

-- test: historique des rotations : aucune en cours
-- en tant que: lecteur
{
    LET $s = <string> (SELECT VALUE s FROM ONLY passe:ids);
    LET $g = fn::secrets_rotation_get({ secret: $s }).data;
    RETURN $g.active IS NONE AND $g.items.state = ["succeeded"];
};

-- test: échecs répétés : trois nouveaux essais, puis échec ; la version courante reste, pending retirée
-- en tant que: worker
{
    LET $s = (SELECT VALUE s FROM ONLY passe:ids);
    LET $r = fn::secrets_rotation_begin({ secret: <string> $s }).data.id;
    fn::secrets_version_add({ secret: <string> $s, number: 3, envelope: "enc:v2:k1:CCCC", key_id: "k1", stage: "pending" });
    fn::secrets_rotation_step({ rotation: <string> $r, step: "created", pending_number: 3 });
    LET $tries = array::map([1, 2, 3], |$i| fn::secrets_rotation_fail({ rotation: <string> $r, code: "SECRETS_ROTATION_TEST_FAILED" }).data);
    LET $last = fn::secrets_rotation_fail({ rotation: <string> $r, code: "SECRETS_ROTATION_TEST_FAILED" }).data;
    LET $f = (SELECT labels FROM ONLY $s);
    RETURN $tries.attempts = [1, 2, 3] AND $tries.state = ["created", "created", "created"]
        AND $tries[2].next_attempt_at > time::now() + 59m
        AND $last.state = "failed" AND $last.attempts = 4 AND $last.finished_at IS NOT NONE
        AND $f.labels = { current: 2, previous: 1 };
};

-- test: échec définitif sans nouvel essai (aucun rotateur)
-- en tant que: worker
{
    LET $s = <string> (SELECT VALUE s FROM ONLY passe:ids);
    LET $r = fn::secrets_rotation_begin({ secret: $s }).data.id;
    LET $f = fn::secrets_rotation_fail({ rotation: <string> $r, code: "SECRETS_ROTATOR_UNAVAILABLE", retry: false }).data;
    RETURN $f.state = "failed" AND $f.attempts = 1 AND $f.last_error = "SECRETS_ROTATOR_UNAVAILABLE";
};

-- test: annulation par l'écriture, pas par un lecteur ; rotation terminée intouchable
-- en tant que: admin
{
    LET $s = <string> (SELECT VALUE s FROM ONLY passe:ids);
    LET $r = fn::secrets_rotation_begin({ secret: $s }).data.id;
    UPDATE passe:ids SET r2 = $r;
    RETURN $r IS NOT NONE;
};

-- test: un lecteur n'annule pas
-- en tant que: lecteur
{
    LET $r = <string> (SELECT VALUE r2 FROM ONLY passe:ids);
    RETURN fn::secrets_rotation_cancel({ rotation: $r }).error.code = "SECRETS_PERMISSION_DENIED";
};

-- test: annulation
-- en tant que: admin
{
    LET $r = <string> (SELECT VALUE r2 FROM ONLY passe:ids);
    LET $c = fn::secrets_rotation_cancel({ rotation: $r }).data;
    RETURN $c.state = "cancelled" AND $c.finished_at IS NOT NONE
        AND fn::secrets_rotation_cancel({ rotation: $r }).error.code = "SECRETS_ROTATION_STATE_INVALID"
        AND fn::secrets_rotation_cancel({ rotation: "secrets_rotation:inconnue" }).error.code = "SECRETS_ROTATION_NOT_FOUND";
};

-- préparation: le rédacteur a un second facteur qu'il n'a pas utilisé dans sa session
{
    UPDATE auth_identity:redacteur SET available_aal = 2;
};

-- test: urgence demandée par une personne sans le niveau d'assurance requis : refusée, rien ne change
-- en tant que: redacteur
{
    LET $s = <string> (SELECT VALUE s FROM ONLY passe:ids);
    RETURN fn::secrets_rotation_begin({ secret: $s, emergency: true }).error.code = "AUTH_AAL_INSUFFICIENT"
        AND fn::secrets_rotation_get({ secret: $s }).data.active IS NONE;
};

-- test: urgence : la version courante est coupée tout de suite
-- en tant que: admin
{
    LET $s = (SELECT VALUE s FROM ONLY passe:ids);
    LET $r = fn::secrets_rotation_begin({ secret: <string> $s, emergency: true, reason: "fuite soupçonnée" }).data;
    UPDATE passe:ids SET r3 = $r.id;
    RETURN $r.emergency = true AND $r.previous_number = 2
        AND (SELECT VALUE state FROM ONLY secrets_version WHERE secret = $s AND number = 2 LIMIT 1) = "disabled"
        AND fn::secrets_read_begin({ secret: <string> $s }).error.code = "SECRETS_VERSION_STATE_INVALID";
};

-- test: écriture directe : un rédacteur ne fait pas avancer une rotation, le worker ne saute pas d'étape
-- en tant que: admin
-- attendu-erreur: SECRETS_PERMISSION_DENIED
UPDATE (SELECT VALUE r3 FROM ONLY passe:ids) SET state = "created", pending_number = 2;

-- test: le worker ne saute pas d'étape
-- en tant que: worker
-- attendu-erreur: SECRETS_ROTATION_STATE_INVALID
UPDATE (SELECT VALUE r3 FROM ONLY passe:ids) SET state = "tested";

-- test: une rotation ne se crée pas directement dans un autre état que started
-- en tant que: admin
-- attendu-erreur: SECRETS_ROTATION_STATE_INVALID
CREATE secrets_rotation CONTENT { secret: (SELECT VALUE e FROM ONLY passe:ids), tenant: auth_organization:alpha, state: "tested" };

-- test: essai sans bascule journalisé et publié ; réservé au worker
-- en tant que: worker
{
    LET $s = <string> (SELECT VALUE s FROM ONLY passe:ids);
    LET $c = fn::secrets_rotation_check_record({ secret: $s, ok: false, code: "SECRETS_ROTATION_TEST_FAILED" });
    RETURN $c.ok AND $c.data.ok = false AND $c.data.code = "SECRETS_ROTATION_TEST_FAILED"
        AND fn::secrets_secret_get({ secret: $s }).data.last_check_ok = false;
};

-- test: un rédacteur n'enregistre pas d'essai
-- en tant que: redacteur
{
    LET $s = <string> (SELECT VALUE s FROM ONLY passe:ids);
    RETURN fn::secrets_rotation_check_record({ secret: $s, ok: true }).error.code = "SECRETS_PERMISSION_DENIED";
};

-- préparation: clé de beta créée il y a 400 jours ; réglage de rotation des clés
{
    CREATE secrets_tenant_key CONTENT { tenant: auth_organization:beta, key_id: "kb", wrapped: "enc:v2:m1:KB", created_at: time::now() - 400d };
};

-- test: clé d'organisation plus ancienne que la période : à faire tourner
-- en tant que: worker
RETURN fn::secrets_due_list({}).data.tenant_keys_due.key_id = ["kb"];

-- test: rotation des clés désactivée ou bornée par les réglages
-- en tant que: autre
{
    LET $off = fn::secrets_settings_set({ tenant: "auth_organization:beta", tenant_key_rotation_days: 0 });
    RETURN $off.ok AND fn::secrets_settings_set({ tenant: "auth_organization:beta", tenant_key_rotation_days: 10 }).error.code = "SECRETS_INVALID_PARAMETERS"
        AND fn::secrets_settings_set({ tenant: "auth_organization:beta", tenant_key_rotation_days: 4000 }).error.code = "SECRETS_INVALID_PARAMETERS";
};

-- test: rotation désactivée : la clé n'est plus due
-- en tant que: worker
RETURN fn::secrets_due_list({}).data.tenant_keys_due = [];

-- test: fonctions internes de la rotation
{
    LET $s = (SELECT VALUE s FROM ONLY passe:ids);
    LET $r = (SELECT VALUE r3 FROM ONLY passe:ids);
    LET $l = fn::secrets_rotation_load({ rotation: <string> $r }, {});
    RETURN fn::secrets_rotation_started($s) = true AND fn::secrets_rotation_view($r).state = "started"
        AND fn::secrets_rotation_refusal("CREATE", NONE, { secret: $s, tenant: auth_organization:alpha, state: "created", attempts: 0 }) = "SECRETS_ROTATION_STATE_INVALID"
        AND fn::secrets_rotation_load({}, {}).error.error.code = "SECRETS_INVALID_PARAMETERS"
        AND $l.secret.path = "api/brevo"
        AND fn::secrets_rotation_close($l, "cancelled", NONE).data.state = "cancelled"
        AND fn::secrets_rotation_started($s) = false;
};

-- test: journal de la rotation, sans valeur
{
    LET $actions = (SELECT VALUE event.action FROM secrets_audit WHERE scope_key = "alpha" AND string::starts_with(event.action, "rotation.") ORDER BY seq ASC);
    RETURN $actions = ["rotation.start", "rotation.step", "rotation.retry", "rotation.step", "rotation.step", "rotation.succeed",
        "rotation.start", "rotation.step", "rotation.retry", "rotation.retry", "rotation.retry", "rotation.fail",
        "rotation.start", "rotation.fail", "rotation.start", "rotation.cancel", "rotation.start", "rotation.check", "rotation.cancel"]
        AND !string::contains(<string> (SELECT * FROM secrets_audit), "AAAA") AND !string::contains(<string> (SELECT * FROM secrets_audit), "BBBB");
};

-- test: événements du cycle de vie publiés sur le bus
RETURN (SELECT VALUE event_type FROM event_outbox WHERE producer = "lyxal_secrets" AND (string::starts_with(event_type, "secrets.rotation.")
        OR event_type IN ["secrets.secret.expiring", "secrets.secret.expired", "secrets.secret.rotation_due"]) ORDER BY created_at ASC) = [
    "secrets.secret.expiring", "secrets.secret.expired", "secrets.secret.rotation_due",
    "secrets.rotation.started", "secrets.rotation.succeeded",
    "secrets.rotation.started", "secrets.rotation.failed",
    "secrets.rotation.started", "secrets.rotation.failed",
    "secrets.rotation.started", "secrets.rotation.cancelled",
    "secrets.rotation.started", "secrets.rotation.checked", "secrets.rotation.cancelled"
];
