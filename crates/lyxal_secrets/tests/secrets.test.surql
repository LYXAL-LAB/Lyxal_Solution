-- lyxal-test: assertions
-- Fiches : création, unicité du chemin par organisation, modification, lecture, liste, états
-- (désactivation, suppression douce, restauration, purge), protection contre la purge, purge
-- à échéance, gardes des écritures directes.
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

-- test: création par l'administrateur : visibilité par défaut, propriétaire, état
-- en tant que: admin
{
    LET $r = fn::secrets_secret_create({ tenant: "auth_organization:alpha", path: "notification/smtp/password", kind: "password", description: "Relais SMTP", tags: ["mail"], consumers: ["lyxal_notification"] });
    CREATE passe:smtp SET id_secret = $r.data.id;
    RETURN $r.ok AND $r.data.visibility = "restricted" AND $r.data.owner = auth_identity:admin AND $r.data.state = "active"
        AND $r.data.latest_version = 0 AND $r.data.labels = {} AND $r.data.versions = [];
};
-- test: même chemin refusé dans la même organisation, permis dans une autre
-- en tant que: admin
RETURN fn::secrets_secret_create({ tenant: "auth_organization:alpha", path: "notification/smtp/password", kind: "password" }).error.code = "SECRETS_SECRET_EXISTS";

-- test: même chemin dans une autre organisation
-- en tant que: autre
RETURN fn::secrets_secret_create({ tenant: "auth_organization:beta", path: "notification/smtp/password", kind: "password", visibility: "revealable" }).ok;

-- test: entrées invalides refusées par lyxal_core
-- en tant que: admin
RETURN fn::secrets_secret_create({ tenant: "auth_organization:alpha", path: "../x", kind: "password" }).error.code = "SECRETS_INVALID_PARAMETERS"
    AND fn::secrets_secret_create({ tenant: "auth_organization:alpha", path: "a/b", kind: "inconnu" }).error.code = "SECRETS_INVALID_PARAMETERS"
    AND fn::secrets_secret_create({ tenant: "auth_organization:alpha", path: "a/b", kind: "token", expires_at: time::now() - 1d }).error.code = "SECRETS_INVALID_PARAMETERS"
    AND fn::secrets_secret_create({ tenant: "auth_organization:alpha", path: "a/b", kind: "token", rotation_period: 1m }).error.code = "SECRETS_INVALID_PARAMETERS"
    AND fn::secrets_secret_create({ tenant: "auth_organization:alpha", path: "a/b", kind: "token", metadata: object::from_entries(array::map(<array>(0..33), |$i| ["k" + <string> $i, $i])) }).error.code = "SECRETS_INVALID_PARAMETERS"
    AND fn::secrets_secret_create({ tenant: "auth_organization:alpha", path: "a/b", kind: "token", inconnu: 1 }).error.code = "SECRETS_INVALID_PARAMETERS";

-- test: un lecteur ne crée pas de secret
-- en tant que: lecteur
RETURN fn::secrets_secret_create({ tenant: "auth_organization:alpha", path: "x/y", kind: "token" }).error.code = "SECRETS_PERMISSION_DENIED";

-- test: modification de la fiche, effacement par clear, prochaine rotation sans version
-- en tant que: redacteur
{
    LET $s = (SELECT VALUE id_secret FROM ONLY passe:smtp);
    LET $r = fn::secrets_secret_update({ secret: <string> $s, description: "Relais SMTP principal", contact: "ops@lyxal.test", rotation_period: 30d, metadata: { fournisseur: "brevo" } });
    LET $c = fn::secrets_secret_update({ secret: <string> $s, clear: ["contact"] });
    RETURN $r.ok AND $r.data.description = "Relais SMTP principal" AND $r.data.rotation_period = 30d AND $r.data.next_rotation_at IS NONE
        AND $r.data.metadata = { fournisseur: "brevo" } AND $c.data.contact IS NONE AND $c.data.description = "Relais SMTP principal";
};
-- test: lecture par identifiant et par chemin ; secret d'une autre organisation introuvable
-- en tant que: lecteur
{
    LET $s = (SELECT VALUE id_secret FROM ONLY passe:smtp);
    RETURN fn::secrets_secret_get({ secret: <string> $s }).data.path = "notification/smtp/password"
        AND fn::secrets_secret_get({ tenant: "auth_organization:alpha", path: "notification/smtp/password" }).data.id = $s
        AND fn::secrets_secret_get({ tenant: "auth_organization:beta", path: "notification/smtp/password" }).error.code = "SECRETS_SECRET_NOT_FOUND"
        AND fn::secrets_secret_get({}).error.code = "SECRETS_INVALID_PARAMETERS";
};
-- test: liste par préfixe et par étiquette
-- en tant que: admin
{
    fn::secrets_secret_create({ tenant: "auth_organization:alpha", path: "notification/sms/token", kind: "token" });
    fn::secrets_secret_create({ tenant: "auth_organization:alpha", path: "notificationx/a", kind: "token" });
    LET $prefix = fn::secrets_secret_list({ tenant: "auth_organization:alpha", prefix: "notification" }).data;
    LET $tag = fn::secrets_secret_list({ tenant: "auth_organization:alpha", tag: "mail" }).data;
    LET $page = fn::secrets_secret_list({ tenant: "auth_organization:alpha", limit: 1, start: 1 }).data;
    RETURN $prefix.total = 2 AND $prefix.items.path = ["notification/sms/token", "notification/smtp/password"]
        AND $tag.total = 1 AND $page.total = 3 AND array::len($page.items) = 1;
};
-- test: désactivation puis réactivation ; transitions interdites
-- en tant que: redacteur
{
    LET $s = <string> (SELECT VALUE id_secret FROM ONLY passe:smtp);
    RETURN fn::secrets_secret_disable({ secret: $s }).data.state = "disabled"
        AND fn::secrets_secret_disable({ secret: $s }).error.code = "SECRETS_SECRET_STATE_INVALID"
        AND fn::secrets_secret_enable({ secret: $s }).data.state = "active"
        AND fn::secrets_secret_delete({ secret: $s }).error.code = "SECRETS_PERMISSION_DENIED";
};
-- test: suppression douce : date de purge à 30 jours, fiche intouchable, absente des listes
-- en tant que: admin
{
    LET $s = <string> (SELECT VALUE id_secret FROM ONLY passe:smtp);
    LET $d = fn::secrets_secret_delete({ secret: $s });
    RETURN $d.data.state = "deleted" AND $d.data.state_before_delete = "active"
        AND $d.data.purge_at > time::now() + 29d AND $d.data.purge_at < time::now() + 31d
        AND fn::secrets_secret_update({ secret: $s, description: "x" }).error.code = "SECRETS_SECRET_DELETED"
        AND fn::secrets_secret_disable({ secret: $s }).error.code = "SECRETS_SECRET_DELETED"
        AND fn::secrets_secret_list({ tenant: "auth_organization:alpha", prefix: "notification/smtp" }).data.total = 0
        AND fn::secrets_secret_list({ tenant: "auth_organization:alpha", state: "deleted" }).data.total = 1;
};
-- test: restauration dans l'état d'avant
-- en tant que: admin
{
    LET $s = <string> (SELECT VALUE id_secret FROM ONLY passe:smtp);
    LET $r = fn::secrets_secret_restore({ secret: $s });
    RETURN $r.data.state = "active" AND $r.data.deleted_at IS NONE AND $r.data.purge_at IS NONE AND $r.data.state_before_delete IS NONE
        AND fn::secrets_secret_restore({ secret: $s }).error.code = "SECRETS_SECRET_STATE_INVALID";
};
-- test: purge d'un secret actif refusée, purge anticipée d'un secret supprimé permise
-- en tant que: admin
{
    LET $id = fn::secrets_secret_create({ tenant: "auth_organization:alpha", path: "jetable", kind: "generic" }).data.id;
    LET $actif = fn::secrets_secret_purge({ secret: <string> $id });
    fn::secrets_secret_delete({ secret: <string> $id });
    LET $purge = fn::secrets_secret_purge({ secret: <string> $id });
    RETURN $actif.error.code = "SECRETS_SECRET_STATE_INVALID" AND $purge.data.purged = true
        AND fn::secrets_secret_get({ secret: <string> $id }).error.code = "SECRETS_SECRET_NOT_FOUND";
};
-- test: protection contre la purge : purge anticipée refusée, protection irréversible
-- en tant que: admin
{
    LET $id = fn::secrets_secret_create({ tenant: "auth_organization:alpha", path: "protege", kind: "generic" }).data.id;
    fn::secrets_secret_delete({ secret: <string> $id });
    LET $on = fn::secrets_settings_set({ tenant: "auth_organization:alpha", purge_protection: true });
    CREATE passe:protege SET id_secret = $id;
    RETURN $on.ok AND fn::secrets_secret_purge({ secret: <string> $id }).error.code = "SECRETS_PURGE_PROTECTED"
        AND fn::secrets_settings_set({ tenant: "auth_organization:alpha", purge_protection: false }).error.code = "SECRETS_PURGE_PROTECTED";
};
-- test: la protection ne se retire pas même par une écriture directe
-- attendu-erreur: SECRETS_PURGE_PROTECTED
UPDATE secrets_settings:alpha SET purge_protection = false;

-- test: purge à échéance par le worker (date de purge passée)
{
    UPDATE (SELECT VALUE id_secret FROM ONLY passe:protege) SET purge_at = time::now() - 1s;
    RETURN true;
};
-- test: le worker purge ce qui est échu
-- en tant que: worker
{
    LET $r = fn::secrets_purge_due({});
    RETURN $r.ok AND $r.data.purged = 1;
};
-- test: purge à échéance réservée au worker
-- en tant que: admin
RETURN fn::secrets_purge_due({}).error.code = "SECRETS_PERMISSION_DENIED";

-- test: écriture directe : changement d'état sans le droit refusé par la garde
-- en tant que: redacteur
-- attendu-erreur: SECRETS_PERMISSION_DENIED
UPDATE (SELECT VALUE id_secret FROM ONLY passe:smtp) SET state = "deleted", state_before_delete = "active", deleted_at = time::now(), purge_at = time::now() + 1d;

-- test: écriture directe : date de purge modifiée sans changement d'état refusée
-- en tant que: admin
-- attendu-erreur: SECRETS_SECRET_STATE_INVALID
UPDATE (SELECT VALUE id_secret FROM ONLY passe:smtp) SET purge_at = time::now();

-- test: écriture directe : création avec des étiquettes refusée
-- en tant que: admin
-- attendu-erreur: SECRETS_SECRET_STATE_INVALID
CREATE secrets_secret CONTENT { tenant: auth_organization:alpha, path: "direct", kind: "token", visibility: "restricted", owner: auth_identity:admin, labels: { current: 1 } };

-- test: écriture directe : création au nom d'un autre propriétaire refusée
-- en tant que: admin
-- attendu-erreur: SECRETS_PERMISSION_DENIED
CREATE secrets_secret CONTENT { tenant: auth_organization:alpha, path: "direct", kind: "token", visibility: "restricted", owner: auth_identity:lecteur };

-- test: écriture directe : propriétaire figé
-- en tant que: admin
-- attendu-erreur: SECRETS_PERMISSION_DENIED
UPDATE (SELECT VALUE id_secret FROM ONLY passe:smtp) SET owner = auth_identity:lecteur;

-- test: écriture directe : suppression douce avec une date de purge raccourcie refusée
-- en tant que: admin
-- attendu-erreur: SECRETS_SECRET_STATE_INVALID
UPDATE (SELECT VALUE id_secret FROM ONLY passe:smtp) SET state = "deleted", state_before_delete = "active", deleted_at = time::now(), purge_at = time::now() - 1d;
