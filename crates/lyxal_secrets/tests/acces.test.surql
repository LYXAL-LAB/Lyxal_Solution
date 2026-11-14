-- lyxal-test: assertions
-- Accès avancés : accès temporaires par secret et par dossier (opérations, durée, retrait,
-- organisation), demandes d'accès et de changement (approbations, auto-approbation interdite,
-- refus, annulation, expiration), protections (écriture directe refusée, valeur proposée,
-- application), accès d'urgence ; gardes, worker, journal et bus.
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
-- identité gestion: { "id": "auth_session:gestion", "pv": 1, "permissions": ["secrets.secret.list", "secrets.access.manage"] }
-- identité gestion2: { "id": "auth_session:gestion2", "pv": 1, "permissions": ["secrets.secret.list", "secrets.access.manage"] }
-- identité urgentiste: { "id": "auth_session:urgentiste", "pv": 1, "permissions": ["secrets.secret.list", "secrets.secret.write", "secrets.access.emergency"] }
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

-- préparation: gestionnaires des accès et urgentiste d'alpha ; clé et secrets d'alpha et de beta
{
    FOR $n IN ["gestion", "gestion2", "urgentiste"] {
        CREATE type::record("auth_identity", $n) CONTENT { schema: auth_identity_schema:default_v1, traits: { email: $n + "@lyxal.test" } };
        RELATE (type::record("auth_identity", $n))->auth_member_of->auth_organization:alpha;
        CREATE type::record("auth_session", $n) CONTENT { identity: type::record("auth_identity", $n), organization: auth_organization:alpha, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    };
    fn::secrets_tenant_key_create({ tenant: "auth_organization:alpha", key_id: "k1", wrapped: "enc:v2:m1:K1" });
    fn::secrets_tenant_key_create({ tenant: "auth_organization:beta", key_id: "kb", wrapped: "enc:v2:m1:KB" });
    LET $brevo = fn::secrets_secret_create({ tenant: "auth_organization:alpha", path: "api/brevo", kind: "api_key", visibility: "revealable" }).data.id;
    LET $stripe = fn::secrets_secret_create({ tenant: "auth_organization:alpha", path: "api/stripe", kind: "api_key", visibility: "revealable" }).data.id;
    LET $db = fn::secrets_secret_create({ tenant: "auth_organization:alpha", path: "infra/db", kind: "password" }).data.id;
    LET $old = fn::secrets_secret_create({ tenant: "auth_organization:alpha", path: "api-old/key", kind: "api_key", visibility: "revealable" }).data.id;
    LET $beta = fn::secrets_secret_create({ tenant: "auth_organization:beta", path: "api/brevo", kind: "api_key", visibility: "revealable" }).data.id;
    FOR $s IN [$brevo, $stripe, $db, $old] {
        fn::secrets_version_add({ secret: <string> $s, number: 1, envelope: "enc:v2:k1:AAAA", key_id: "k1" });
    };
    fn::secrets_version_add({ secret: <string> $beta, number: 1, envelope: "enc:v2:kb:AAAA", key_id: "kb" });
    CREATE passe:ids SET brevo = $brevo, stripe = $stripe, db = $db, old = $old, beta = $beta;
};

-- test: sans droit ni accès, un membre ne voit ni ne lit rien
-- en tant que: membre
{
    LET $b = <string> (SELECT VALUE brevo FROM ONLY passe:ids);
    RETURN fn::secrets_secret_list({ tenant: "auth_organization:alpha" }).error.code = "SECRETS_PERMISSION_DENIED"
        AND fn::secrets_read_begin({ secret: $b }).error.code = "SECRETS_SECRET_NOT_FOUND";
};

-- test: un gestionnaire accorde un accès de lecture au dossier api ; bornes et bénéficiaire contrôlés
-- en tant que: gestion
{
    LET $g = fn::secrets_grant_create({ tenant: "auth_organization:alpha", identity: "auth_identity:membre", path: "api", folder: true, actions: ["list", "read_value"], duration: 1h, reason: "incident support" });
    UPDATE passe:ids SET grant = $g.data.id;
    RETURN $g.ok AND $g.data.active AND $g.data.folder AND $g.data.granted_by = "auth_identity:gestion"
        AND $g.data.expires_at > time::now() + 59m AND $g.data.expires_at < time::now() + 61m
        AND fn::secrets_grant_create({ tenant: "auth_organization:alpha", identity: "auth_identity:membre", application: "auth_application:robot", path: "api", actions: ["list"], reason: "x" }).error.code = "SECRETS_GRANT_INVALID"
        AND fn::secrets_grant_create({ tenant: "auth_organization:alpha", path: "api", actions: ["list"], reason: "x" }).error.code = "SECRETS_GRANT_INVALID"
        AND fn::secrets_grant_create({ tenant: "auth_organization:alpha", identity: "auth_identity:membre", path: "api", actions: ["list"], duration: 91d, reason: "x" }).error.code = "SECRETS_INVALID_PARAMETERS"
        AND fn::secrets_grant_create({ tenant: "auth_organization:alpha", identity: "auth_identity:membre", path: "api", actions: ["purge"], reason: "x" }).error.code = "SECRETS_INVALID_PARAMETERS";
};

-- test: sans durée, l'accès dure le temps par défaut des réglages (8 h)
-- en tant que: gestion
{
    LET $g = fn::secrets_grant_create({ tenant: "auth_organization:alpha", identity: "auth_identity:lecteur", path: "infra/db", actions: ["list"], reason: "audit" }).data;
    RETURN $g.expires_at > time::now() + 7h59m AND $g.expires_at < time::now() + 8h1m;
};

-- test: l'accès couvre le dossier et seulement lui : liste filtrée, lecture permise, pas d'écriture
-- en tant que: membre
{
    LET $ids = (SELECT * FROM ONLY passe:ids);
    LET $list = fn::secrets_secret_list({ tenant: "auth_organization:alpha" });
    RETURN $list.ok AND $list.data.items.path = ["api/brevo", "api/stripe"]
        AND fn::secrets_read_begin({ secret: <string> $ids.brevo }).ok
        AND fn::secrets_read_begin({ secret: <string> $ids.old }).error.code = "SECRETS_SECRET_NOT_FOUND"
        AND fn::secrets_read_begin({ secret: <string> $ids.db }).error.code = "SECRETS_SECRET_NOT_FOUND"
        AND fn::secrets_version_add({ secret: <string> $ids.brevo, number: 2, envelope: "enc:v2:k1:BBBB", key_id: "k1" }).error.code = "SECRETS_PERMISSION_DENIED"
        AND fn::secrets_secret_list({ tenant: "auth_organization:beta" }).error.code = "SECRETS_PERMISSION_DENIED";
};

-- test: chacun voit ses accès ; le gestionnaire voit tout ; un autre ne gère pas les accès
-- en tant que: membre
{
    LET $mine = fn::secrets_grant_list({ tenant: "auth_organization:alpha" }).data;
    RETURN $mine.total = 1 AND $mine.items[0].path = "api"
        AND fn::secrets_grant_create({ tenant: "auth_organization:alpha", identity: "auth_identity:membre", path: "infra", folder: true, actions: ["list"], reason: "x" }).error.code = "SECRETS_PERMISSION_DENIED";
};

-- test: le gestionnaire liste les accès de l'organisation
-- en tant que: gestion
RETURN fn::secrets_grant_list({ tenant: "auth_organization:alpha" }).data.total = 2
    AND fn::secrets_grant_list({ tenant: "auth_organization:alpha", identity: "auth_identity:lecteur" }).data.items.path = ["infra/db"];

-- test: une autre organisation n'accorde rien chez alpha
-- en tant que: autre
RETURN fn::secrets_grant_create({ tenant: "auth_organization:alpha", identity: "auth_identity:autre", path: "api", folder: true, actions: ["read_value"], reason: "x" }).error.code = "SECRETS_PERMISSION_DENIED";

-- test: retrait immédiat, une seule fois
-- en tant que: gestion
{
    LET $g = <string> (SELECT VALUE grant FROM ONLY passe:ids);
    LET $r = fn::secrets_grant_revoke({ grant: $g });
    RETURN $r.ok AND $r.data.active = false AND $r.data.revoked_by = "auth_identity:gestion"
        AND fn::secrets_grant_revoke({ grant: $g }).error.code = "SECRETS_GRANT_INVALID"
        AND fn::secrets_grant_revoke({ grant: "secrets_grant:inconnu" }).error.code = "SECRETS_GRANT_NOT_FOUND";
};

-- test: accès retiré : plus rien
-- en tant que: membre
RETURN fn::secrets_secret_list({ tenant: "auth_organization:alpha" }).error.code = "SECRETS_PERMISSION_DENIED";

-- test: demande d'accès d'un membre, en attente d'une approbation
-- en tant que: membre
{
    LET $r = fn::secrets_request_access({ tenant: "auth_organization:alpha", path: "api/stripe", actions: ["read_value"], duration: 2h, reason: "paiement bloqué" });
    UPDATE passe:ids SET req_access = $r.data.id;
    RETURN $r.ok AND $r.data.state = "pending" AND $r.data.kind = "access" AND $r.data.required_approvals = 1
        AND $r.data.requested_identity = auth_identity:membre AND $r.data.expires_at > time::now() + 6d
        AND fn::secrets_request_approve({ request: <string> $r.data.id }).error.code = "SECRETS_PERMISSION_DENIED"
        AND fn::secrets_request_access({ tenant: "auth_organization:beta", path: "api", actions: ["list"], reason: "x" }).error.code = "SECRETS_PERMISSION_DENIED";
};

-- test: un gestionnaire n'approuve pas sa propre demande
-- en tant que: gestion
{
    LET $r = fn::secrets_request_access({ tenant: "auth_organization:alpha", path: "infra", folder: true, actions: ["list"], reason: "revue" }).data.id;
    UPDATE passe:ids SET req_self = $r;
    RETURN fn::secrets_request_approve({ request: <string> $r }).error.code = "SECRETS_REQUEST_SELF_APPROVAL"
        AND fn::secrets_request_reject({ request: <string> $r, reason: "non" }).error.code = "SECRETS_REQUEST_SELF_APPROVAL";
};

-- test: approbation finale : l'accès est créé pour le demandeur
-- en tant que: gestion
{
    LET $r = <string> (SELECT VALUE req_access FROM ONLY passe:ids);
    LET $a = fn::secrets_request_approve({ request: $r, comment: "ok" }).data;
    LET $g = fn::secrets_grant_view($a.grant);
    RETURN $a.state = "approved" AND $a.approvals.by = ["auth_identity:gestion"] AND $g.subject_identity = auth_identity:membre
        AND $g.path = "api/stripe" AND $g.actions = ["read_value"] AND $g.request = type::record($r) AND $g.active
        AND fn::secrets_request_approve({ request: $r }).error.code = "SECRETS_REQUEST_ALREADY_DECIDED";
};

-- test: l'accès approuvé permet la lecture demandée, et elle seule
-- en tant que: membre
{
    LET $ids = (SELECT * FROM ONLY passe:ids);
    RETURN fn::secrets_read_begin({ secret: <string> $ids.stripe }).ok
        AND fn::secrets_read_begin({ secret: <string> $ids.brevo }).error.code = "SECRETS_SECRET_NOT_FOUND"
        AND fn::secrets_request_get({ request: <string> $ids.req_access }).data.state = "approved"
        AND fn::secrets_request_list({ tenant: "auth_organization:alpha", mine: true }).data.total = 1;
};

-- test: refus par un autre gestionnaire : la demande est close
-- en tant que: gestion2
{
    LET $r = <string> (SELECT VALUE req_self FROM ONLY passe:ids);
    LET $x = fn::secrets_request_reject({ request: $r, reason: "pas nécessaire" }).data;
    RETURN $x.state = "rejected" AND $x.decided_by = "auth_identity:gestion2"
        AND fn::secrets_request_approve({ request: $r }).error.code = "SECRETS_REQUEST_ALREADY_DECIDED";
};

-- test: annulation de sa propre demande, pas de celle d'un autre
-- en tant que: membre
{
    LET $r = fn::secrets_request_access({ tenant: "auth_organization:alpha", path: "infra/db", actions: ["list"], reason: "x" }).data.id;
    LET $c = fn::secrets_request_cancel({ request: <string> $r }).data;
    RETURN $c.state = "cancelled" AND fn::secrets_request_cancel({ request: <string> $r }).error.code = "SECRETS_REQUEST_STATE_INVALID"
        AND fn::secrets_request_cancel({ request: <string> (SELECT VALUE req_self FROM ONLY passe:ids) }).error.code = "SECRETS_REQUEST_NOT_FOUND";
};

-- test: protection du dossier infra : deux approbations, toutes les opérations
-- en tant que: gestion
{
    LET $p = fn::secrets_policy_set({ tenant: "auth_organization:alpha", path: "infra", folder: true, required_approvals: 2 });
    RETURN $p.ok AND $p.data.operations = ["value", "rollback", "disable", "delete", "destroy"]
        AND fn::secrets_policy_list({ tenant: "auth_organization:alpha", path: "infra/db" }).data.effective.required_approvals = 2
        AND fn::secrets_policy_set({ tenant: "auth_organization:alpha", path: "api", folder: true, required_approvals: 6 }).error.code = "SECRETS_INVALID_PARAMETERS";
};

-- test: un rédacteur ne contourne pas la protection
-- en tant que: redacteur
{
    LET $db = <string> (SELECT VALUE db FROM ONLY passe:ids);
    RETURN fn::secrets_version_add({ secret: $db, number: 2, envelope: "enc:v2:k1:BBBB", key_id: "k1" }).error.code = "SECRETS_APPROVAL_REQUIRED"
        AND fn::secrets_secret_disable({ secret: $db }).error.code = "SECRETS_APPROVAL_REQUIRED"
        AND fn::secrets_secret_update({ secret: $db, description: "base principale" }).ok
        AND fn::secrets_policy_set({ tenant: "auth_organization:alpha", path: "infra", folder: true }).error.code = "SECRETS_PERMISSION_DENIED";
};

-- test: écriture directe dans la table : refusée de même
-- en tant que: redacteur
-- attendu-erreur: SECRETS_APPROVAL_REQUIRED
UPDATE (SELECT VALUE db FROM ONLY passe:ids) SET state = "disabled";

-- test: valeur proposée, jamais en service avant l'application ; une demande ouverte par secret
-- en tant que: redacteur
{
    LET $db = <string> (SELECT VALUE db FROM ONLY passe:ids);
    LET $v = fn::secrets_version_add({ secret: $db, number: 2, envelope: "enc:v2:k1:BBBB", key_id: "k1", stage: "proposed" });
    LET $r = fn::secrets_request_change({ secret: $db, operation: "value", number: 2, reason: "nouveau mot de passe" });
    UPDATE passe:ids SET req_change = $r.data.id;
    RETURN $v.data.labels = { current: 1, proposed: 2 } AND $r.data.state = "pending" AND $r.data.required_approvals = 2
        AND fn::secrets_request_change({ secret: $db, operation: "disable", reason: "x" }).error.code = "SECRETS_CHANGE_IN_PROGRESS"
        AND fn::secrets_request_apply({ request: <string> $r.data.id }).error.code = "SECRETS_REQUEST_STATE_INVALID"
        AND fn::secrets_request_change({ secret: <string> (SELECT VALUE brevo FROM ONLY passe:ids), operation: "disable", reason: "x" }).error.code = "SECRETS_POLICY_NOT_FOUND";
};

-- test: première approbation : la demande attend la seconde
-- en tant que: gestion
{
    LET $r = <string> (SELECT VALUE req_change FROM ONLY passe:ids);
    LET $a = fn::secrets_request_approve({ request: $r }).data;
    RETURN $a.state = "pending" AND array::len($a.approvals) = 1
        AND fn::secrets_request_approve({ request: $r }).error.code = "SECRETS_REQUEST_ALREADY_DECIDED";
};

-- test: seconde approbation : approuvée
-- en tant que: gestion2
RETURN fn::secrets_request_approve({ request: <string> (SELECT VALUE req_change FROM ONLY passe:ids) }).data.state = "approved";

-- test: seul l'auteur applique ; la valeur proposée passe en service
-- en tant que: redacteur
{
    LET $ids = (SELECT * FROM ONLY passe:ids);
    LET $a = fn::secrets_request_apply({ request: <string> $ids.req_change });
    LET $f = (SELECT labels FROM ONLY $ids.db);
    RETURN $a.ok AND $a.data.state = "applied" AND $a.data.applied_at IS NOT NONE
        AND $f.labels = { current: 2, previous: 1 }
        AND fn::secrets_request_apply({ request: <string> $ids.req_change }).error.code = "SECRETS_REQUEST_STATE_INVALID";
};

-- test: un autre que l'auteur n'applique pas
-- en tant que: gestion
{
    LET $db = <string> (SELECT VALUE db FROM ONLY passe:ids);
    RETURN fn::secrets_request_apply({ request: <string> (SELECT VALUE req_change FROM ONLY passe:ids) }).error.code = "SECRETS_PERMISSION_DENIED";
};

-- test: urgence : changement appliqué avant les approbations, avec motif ; jamais sans le droit
-- en tant que: urgentiste
{
    LET $db = <string> (SELECT VALUE db FROM ONLY passe:ids);
    LET $r = fn::secrets_request_change({ secret: $db, operation: "disable", reason: "fuite" }).data.id;
    LET $missing = fn::secrets_request_apply({ request: <string> $r, emergency: true });
    LET $a = fn::secrets_request_apply({ request: <string> $r, emergency: true, reason: "identifiant publié par erreur" });
    RETURN $missing.error.code = "SECRETS_INVALID_PARAMETERS" AND $a.data.state = "applied" AND $a.data.emergency
        AND (SELECT VALUE state FROM ONLY type::record($db)) = "disabled";
};

-- test: un rédacteur sans droit d'urgence ne passe pas outre
-- en tant que: redacteur
{
    LET $db = <string> (SELECT VALUE db FROM ONLY passe:ids);
    LET $r = fn::secrets_request_change({ secret: $db, operation: "rollback", number: 1, reason: "retour à l'ancien mot de passe" }).data.id;
    UPDATE passe:ids SET req_delete = $r;
    RETURN fn::secrets_request_apply({ request: <string> $r, emergency: true, reason: "x" }).error.code = "SECRETS_PERMISSION_DENIED";
};

-- test: accès d'urgence pour soi, une heure au plus ; jamais sans le droit
-- en tant que: urgentiste
{
    LET $g = fn::secrets_access_emergency({ tenant: "auth_organization:alpha", path: "api/brevo", actions: ["read_value"], duration: 30m, reason: "panne d'envoi" });
    RETURN $g.ok AND $g.data.emergency AND $g.data.subject_identity = auth_identity:urgentiste
        AND fn::secrets_access_emergency({ tenant: "auth_organization:alpha", path: "api/brevo", actions: ["read_value"], duration: 2h, reason: "x" }).error.code = "SECRETS_INVALID_PARAMETERS";
};

-- test: un membre sans droit d'urgence ne s'accorde rien
-- en tant que: membre
RETURN fn::secrets_access_emergency({ tenant: "auth_organization:alpha", path: "api", folder: true, actions: ["read_value"], reason: "x" }).error.code = "SECRETS_PERMISSION_DENIED";

-- test: écriture directe : un accès d'urgence ne se donne pas à un autre
-- en tant que: urgentiste
-- attendu-erreur: SECRETS_PERMISSION_DENIED
CREATE secrets_grant CONTENT { tenant: auth_organization:alpha, subject_identity: auth_identity:membre, path: "api", folder: true, actions: ["read_value"], expires_at: time::now() + 30m, reason: "x", emergency: true };

-- test: écriture directe : une demande ne se crée pas sous le nombre d'approbations de la protection
-- en tant que: redacteur
-- attendu-erreur: SECRETS_REQUEST_STATE_INVALID
CREATE secrets_request CONTENT { tenant: auth_organization:alpha, kind: "access", requested_identity: auth_identity:redacteur, path: "infra", folder: true, actions: ["list"], duration: 1h, reason: "x", required_approvals: 1, expires_at: time::now() + 1d };

-- test: écriture directe : le demandeur ne s'approuve pas
-- en tant que: membre
-- attendu-erreur: SECRETS_PERMISSION_DENIED
UPDATE (SELECT VALUE req_access FROM ONLY passe:ids) SET state = "pending", approvals = [{ by: "auth_identity:membre", at: time::now() }];

-- préparation: demande et accès échus
{
    CREATE secrets_request:echue CONTENT { tenant: auth_organization:alpha, kind: "access", requested_identity: auth_identity:lecteur, path: "api", folder: true, actions: ["list"], duration: 1h, reason: "x", required_approvals: 1, expires_at: time::now() - 1m };
    CREATE secrets_grant:vieux CONTENT { tenant: auth_organization:alpha, subject_identity: auth_identity:lecteur, path: "api", folder: true, actions: ["list"], starts_at: time::now() - 41d, expires_at: time::now() - 40d, reason: "ancien" };
};

-- test: worker : demandes échues expirées, accès finis depuis 30 jours retirés
-- en tant que: worker
{
    LET $r = fn::secrets_access_due({});
    RETURN $r.ok AND $r.data.requests_expired >= 1 AND $r.data.grants_removed = 1
        AND (SELECT VALUE state FROM ONLY secrets_request:echue) = "expired";
};

-- test: un rédacteur ne lance pas le worker
-- en tant que: redacteur
RETURN fn::secrets_access_due({}).error.code = "SECRETS_PERMISSION_DENIED";

-- test: retrait d'une protection : le changement redevient direct
-- en tant que: gestion
{
    LET $p = (SELECT VALUE id FROM ONLY secrets_policy WHERE path = "infra" LIMIT 1);
    LET $d = fn::secrets_policy_delete({ policy: <string> $p });
    RETURN $d.ok AND fn::secrets_policy_list({ tenant: "auth_organization:alpha" }).data.items = []
        AND fn::secrets_policy_delete({ policy: <string> $p }).error.code = "SECRETS_POLICY_NOT_FOUND";
};

-- test: fonctions internes des accès et des demandes
{
    LET $ids = (SELECT * FROM ONLY passe:ids);
    LET $l = fn::secrets_request_load({ request: <string> $ids.req_delete }, {});
    RETURN fn::secrets_actor() IS NONE
        AND fn::secrets_policy_for({ tenant: auth_organization:alpha, path: "infra/db" }).protected = false
        AND fn::secrets_change_refusal({ tenant: auth_organization:alpha, path: "infra/db", secret: $ids.db, operation: "delete" }) IS NONE
        AND fn::secrets_grant_covers({ tenant: auth_organization:alpha, path: "api/brevo", action: "list" }) = false
        AND fn::secrets_grant_duration({ tenant: auth_organization:alpha, path: "api", folder: true }).duration = 8h
        AND fn::secrets_grant_refusal("CREATE", NONE, { tenant: auth_organization:alpha, path: "api", starts_at: time::now(), expires_at: time::now() + 1h }) = "SECRETS_GRANT_INVALID"
        AND fn::secrets_grant_insert({ tenant: auth_organization:alpha, subject_identity: auth_identity:lecteur, path: "api", actions: ["list"], expires_at: time::now() + 1h, reason: "x" }) IS NOT NONE
        AND fn::secrets_request_view($ids.req_delete).operation = "rollback"
        AND fn::secrets_request_insert({ tenant: auth_organization:alpha, kind: "change", path: "infra/db", secret: $ids.db, operation: "disable", reason: "x", required_approvals: 1 }) IS NONE
        AND fn::secrets_request_refusal("CREATE", NONE, { tenant: auth_organization:alpha, kind: "access", state: "approved", approvals: [] }) = "SECRETS_REQUEST_STATE_INVALID"
        AND $l.mine = false AND $l.request.state = "pending"
        AND fn::secrets_request_perform($l.request, "fr").ok
        AND (SELECT VALUE labels FROM ONLY $ids.db).current = 1;
};

-- test: journal des accès et des demandes, sans valeur
{
    LET $actions = (SELECT VALUE event.action FROM secrets_audit WHERE scope_key = "alpha"
        AND (string::starts_with(event.action, "access.") OR string::starts_with(event.action, "request.") OR string::starts_with(event.action, "policy.")));
    RETURN "access.grant" INSIDE $actions AND "access.revoke" INSIDE $actions AND "access.emergency" INSIDE $actions
        AND "request.create" INSIDE $actions AND "request.approve" INSIDE $actions AND "request.reject" INSIDE $actions
        AND "request.cancel" INSIDE $actions AND "request.apply" INSIDE $actions AND "request.expire" INSIDE $actions
        AND "policy.set" INSIDE $actions AND "policy.delete" INSIDE $actions
        AND !string::contains(<string> (SELECT * FROM secrets_audit), "BBBB");
};

-- test: événements publiés sur le bus
{
    LET $types = array::distinct(SELECT VALUE event_type FROM event_outbox WHERE producer = "lyxal_secrets"
        AND (string::starts_with(event_type, "secrets.access.") OR string::starts_with(event_type, "secrets.request.") OR string::starts_with(event_type, "secrets.policy.")));
    RETURN array::sort($types) = ["secrets.access.emergency", "secrets.access.granted", "secrets.access.revoked", "secrets.policy.updated",
        "secrets.request.applied", "secrets.request.approved", "secrets.request.cancelled", "secrets.request.created", "secrets.request.expired", "secrets.request.rejected"];
};
