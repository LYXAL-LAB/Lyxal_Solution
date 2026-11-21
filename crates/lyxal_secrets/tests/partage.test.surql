-- lyxal-test: assertions
-- Partages à usage unique : création (droits, bornes, source), éléments scellés illisibles,
-- chargement et consommation par la session système seulement, ouvertures comptées jusqu'au
-- maximum, essais faux et destruction, retrait, worker, gardes, journal et bus.
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
-- identité partageur: { "id": "auth_session:partageur", "pv": 1, "permissions": ["secrets.secret.list", "secrets.value.read", "secrets.share.create"] }
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

-- préparation: auteur de partages d'alpha ; clé et secret révélable d'alpha
{
    CREATE auth_identity:partageur CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "partageur@lyxal.test" } };
    RELATE auth_identity:partageur->auth_member_of->auth_organization:alpha;
    CREATE auth_session:partageur CONTENT { identity: auth_identity:partageur, organization: auth_organization:alpha, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    fn::secrets_tenant_key_create({ tenant: "auth_organization:alpha", purpose: "secrets", key_id: "k1", wrapped: "enc:v2:m1:K1" });
    LET $s = fn::secrets_secret_create({ tenant: "auth_organization:alpha", path: "api/brevo", kind: "api_key", visibility: "revealable" }).data.id;
    fn::secrets_version_add({ secret: <string> $s, number: 1, envelope: "enc:v2:k1:AAAA", key_id: "k1" });
    CREATE passe:ids SET secret = $s, empreinte = "aa" + string::repeat("0", 62);
};

-- test: sans le droit de partage, rien
-- en tant que: membre
RETURN fn::secrets_share_create({ tenant: "auth_organization:alpha", envelope: "enc:v2:share:XXXX", key_fingerprint: string::repeat("a", 64) }).error.code = "SECRETS_PERMISSION_DENIED";

-- test: partage d'un texte, deux ouvertures ; bornes des réglages
-- en tant que: partageur
{
    LET $f = (SELECT VALUE empreinte FROM ONLY passe:ids);
    LET $sh = fn::secrets_share_create({ tenant: "auth_organization:alpha", envelope: "enc:v2:share:TEXTE", key_fingerprint: $f, max_views: 2, ttl: 1h, note: "prestataire" });
    UPDATE passe:ids SET texte = $sh.data.id;
    RETURN $sh.ok AND $sh.data.state = "active" AND $sh.data.protected = false AND $sh.data.views = 0 AND $sh.data.max_views = 2
        AND $sh.data.created_identity = auth_identity:partageur AND $sh.data.envelope IS NONE
        AND $sh.data.expires_at > time::now() + 59m AND $sh.data.expires_at < time::now() + 61m
        AND fn::secrets_share_create({ tenant: "auth_organization:alpha", envelope: "enc:v2:share:X", key_fingerprint: $f, ttl: 8d }).error.code = "SECRETS_SHARE_INVALID"
        AND fn::secrets_share_create({ tenant: "auth_organization:alpha", envelope: "enc:v2:share:X", key_fingerprint: $f, max_views: 11 }).error.code = "SECRETS_INVALID_PARAMETERS"
        AND fn::secrets_share_create({ tenant: "auth_organization:alpha", envelope: "enc:v2:share:X", key_fingerprint: $f, passphrase_hash: "md5:abc1234567" }).error.code = "SECRETS_INVALID_PARAMETERS"
        AND fn::secrets_share_create({ tenant: "auth_organization:alpha", envelope: "clair", key_fingerprint: $f }).error.code = "SECRETS_INVALID_PARAMETERS";
};

-- test: partage d'un secret avec mot de passe ; sans numéro de version, refusé ; durée par défaut 24 h
-- en tant que: partageur
{
    LET $ids = (SELECT * FROM ONLY passe:ids);
    LET $sh = fn::secrets_share_create({ tenant: "auth_organization:alpha", secret: <string> $ids.secret, number: 1, envelope: "enc:v2:share:COPIE",
        key_fingerprint: $ids.empreinte, passphrase_hash: "$argon2id$v=19$m=19456,t=2,p=1$c2VsMTIzNDU2$aGFzaA" });
    UPDATE passe:ids SET copie = $sh.data.id;
    RETURN $sh.ok AND $sh.data.protected AND $sh.data.secret = $ids.secret AND $sh.data.number = 1
        AND $sh.data.expires_at > time::now() + 23h59m AND $sh.data.expires_at < time::now() + 24h1m
        AND fn::secrets_share_create({ tenant: "auth_organization:alpha", secret: <string> $ids.secret, envelope: "enc:v2:share:X", key_fingerprint: $ids.empreinte }).error.code = "SECRETS_SHARE_INVALID";
};

-- test: éléments scellés jamais lisibles ; liste de ses partages
-- en tant que: partageur
{
    LET $rows = (SELECT envelope, key_fingerprint, passphrase_hash FROM secrets_share);
    RETURN array::len($rows) = 2 AND array::all($rows, |$r| $r.envelope IS NONE AND $r.key_fingerprint IS NONE AND $r.passphrase_hash IS NONE)
        AND fn::secrets_share_list({ tenant: "auth_organization:alpha" }).data.total = 2;
};

-- test: chargement, essai faux et consommation réservés à la session système
-- en tant que: partageur
{
    LET $t = <string> (SELECT VALUE texte FROM ONLY passe:ids);
    RETURN fn::secrets_share_load({ share: $t }).error.code = "SECRETS_PERMISSION_DENIED"
        AND fn::secrets_share_consume({ share: $t }).error.code = "SECRETS_PERMISSION_DENIED"
        AND fn::secrets_share_fail({ share: $t }).error.code = "SECRETS_PERMISSION_DENIED";
};

-- test: session système : chargement, deux ouvertures, puis épuisé et copie effacée
{
    LET $t = (SELECT VALUE texte FROM ONLY passe:ids);
    LET $loaded = fn::secrets_share_load({ share: <string> $t }).data;
    LET $one = fn::secrets_share_consume({ share: <string> $t }).data;
    LET $two = fn::secrets_share_consume({ share: <string> $t, opener: "auth_identity:membre" }).data;
    RETURN $loaded.envelope = "enc:v2:share:TEXTE" AND $loaded.key_fingerprint = (SELECT VALUE empreinte FROM ONLY passe:ids)
        AND $one.views = 1 AND $one.remaining = 1 AND $one.state = "active"
        AND $two.views = 2 AND $two.remaining = 0 AND $two.state = "consumed"
        AND fn::secrets_share_consume({ share: <string> $t }).error.code = "SECRETS_SHARE_UNAVAILABLE"
        AND fn::secrets_share_load({ share: <string> $t }).error.code = "SECRETS_SHARE_UNAVAILABLE"
        AND (SELECT VALUE envelope FROM ONLY $t) IS NONE AND (SELECT VALUE key_fingerprint FROM ONLY $t) IS NONE
        AND fn::secrets_share_load({ share: "secrets_share:inconnu" }).error.code = "SECRETS_SHARE_UNAVAILABLE";
};

-- test: cinq essais faux détruisent le partage
{
    LET $c = <string> (SELECT VALUE copie FROM ONLY passe:ids);
    LET $tries = array::map([1, 2, 3, 4], |$i| fn::secrets_share_fail({ share: $c }).data);
    LET $last = fn::secrets_share_fail({ share: $c }).data;
    RETURN $tries.failed_attempts = [1, 2, 3, 4] AND $tries.destroyed = [false, false, false, false]
        AND $last.destroyed AND $last.failed_attempts = 5
        AND fn::secrets_share_load({ share: $c }).error.code = "SECRETS_SHARE_UNAVAILABLE"
        AND (SELECT VALUE passphrase_hash FROM ONLY type::record($c)) IS NONE;
};

-- test: retrait par l'auteur, une fois
-- en tant que: partageur
{
    LET $f = (SELECT VALUE empreinte FROM ONLY passe:ids);
    LET $sh = fn::secrets_share_create({ tenant: "auth_organization:alpha", envelope: "enc:v2:share:R", key_fingerprint: $f }).data.id;
    UPDATE passe:ids SET retire = $sh;
    LET $r = fn::secrets_share_revoke({ share: <string> $sh }).data;
    LET $other = fn::secrets_share_create({ tenant: "auth_organization:alpha", envelope: "enc:v2:share:O", key_fingerprint: $f }).data.id;
    UPDATE passe:ids SET autre_partage = $other;
    RETURN $r.state = "revoked" AND $r.finished_at IS NOT NONE
        AND fn::secrets_share_revoke({ share: <string> $sh }).error.code = "SECRETS_SHARE_UNAVAILABLE";
};

-- test: un membre ne voit ni ne retire le partage d'un autre
-- en tant que: membre
RETURN fn::secrets_share_revoke({ share: <string> (SELECT VALUE autre_partage FROM ONLY passe:ids) }).error.code = "SECRETS_SHARE_NOT_FOUND"
    AND fn::secrets_share_list({ tenant: "auth_organization:alpha" }).data.total = 0;

-- test: écriture directe : l'auteur ne compte pas d'ouverture
-- en tant que: partageur
-- attendu-erreur: SECRETS_SHARE_INVALID
UPDATE (SELECT VALUE autre_partage FROM ONLY passe:ids) SET views = 1;

-- test: écriture directe : un partage ne naît pas déjà échu
-- en tant que: partageur
-- attendu-erreur: SECRETS_SHARE_INVALID
CREATE secrets_share CONTENT { tenant: auth_organization:alpha, created_identity: auth_identity:partageur, envelope: "enc:v2:share:X", key_fingerprint: string::repeat("b", 64), expires_at: time::now() - 1m };

-- test: écriture directe : on ne partage pas au nom d'un autre
-- en tant que: partageur
-- attendu-erreur: SECRETS_PERMISSION_DENIED
CREATE secrets_share CONTENT { tenant: auth_organization:alpha, created_identity: auth_identity:admin, envelope: "enc:v2:share:X", key_fingerprint: string::repeat("b", 64), expires_at: time::now() + 1h };

-- test: worker : rien d'échu, rien de vieux ; réservé au worker
-- en tant que: worker
{
    LET $r = fn::secrets_share_due({}).data;
    RETURN $r.shares_expired = 0 AND $r.shares_removed = 0;
};

-- test: le worker seul nettoie
-- en tant que: partageur
RETURN fn::secrets_share_due({}).error.code = "SECRETS_PERMISSION_DENIED";

-- test: un secret partagé se purge ; le partage garde sa fiche sans source
{
    LET $ids = (SELECT * FROM ONLY passe:ids);
    LET $d = fn::secrets_secret_delete({ secret: <string> $ids.secret });
    LET $p = fn::secrets_secret_purge({ secret: <string> $ids.secret });
    RETURN $d.ok AND $p.ok AND (SELECT VALUE secret FROM ONLY $ids.copie) IS NONE
        AND (SELECT VALUE state FROM ONLY $ids.copie) = "destroyed";
};

-- test: l'auteur d'un partage peut être supprimé ; le partage reste, sans auteur
{
    LET $o = (SELECT VALUE autre_partage FROM ONLY passe:ids);
    DELETE auth_session:partageur;
    DELETE auth_identity:partageur;
    RETURN (SELECT VALUE created_identity FROM ONLY $o) IS NONE AND (SELECT VALUE state FROM ONLY $o) = "active";
};

-- test: écriture directe : la source d'un partage ne se change pas
-- attendu-erreur: SECRETS_SHARE_INVALID
UPDATE (SELECT VALUE autre_partage FROM ONLY passe:ids) SET secret = NONE, created_identity = auth_identity:admin;

-- test: fonctions internes des partages
{
    LET $ids = (SELECT * FROM ONLY passe:ids);
    RETURN fn::secrets_share_view($ids.texte).state = "consumed"
        AND fn::secrets_share_load_params({ share: "secrets_share:inconnu" }).error.error.code = "SECRETS_SHARE_UNAVAILABLE"
        AND fn::secrets_share_refusal("UPDATE", { state: "consumed" }, { state: "active", tenant: auth_organization:alpha }) = "SECRETS_SHARE_UNAVAILABLE";
};

-- test: journal et bus des partages, sans valeur
{
    LET $actions = (SELECT VALUE event.action FROM secrets_audit WHERE scope_key = "alpha" AND string::starts_with(event.action, "share."));
    LET $types = array::distinct(SELECT VALUE event_type FROM event_outbox WHERE string::starts_with(event_type, "secrets.share."));
    RETURN array::sort(array::distinct($actions)) = ["share.consume", "share.create", "share.destroy", "share.fail", "share.open", "share.opener", "share.revoke"]
        AND array::sort($types) = ["secrets.share.consumed", "secrets.share.created", "secrets.share.destroyed", "secrets.share.opened", "secrets.share.revoked"]
        AND !string::contains(<string> (SELECT * FROM secrets_audit), "TEXTE") AND !string::contains(<string> (SELECT * FROM event_outbox), "COPIE");
};

-- préparation: trois partages d'une autre organisation, dont deux créés à la même date
{
    CREATE auth_organization:tri CONTENT { slug: "tri", name: "Tri" };
    CREATE secrets_share:tri_a CONTENT { tenant: auth_organization:tri, created_identity: auth_identity:partageur, envelope: "enc:v2:share:A", key_fingerprint: string::repeat("a", 64), expires_at: time::now() + 1h, created_at: d"2026-01-02T00:00:00Z" };
    CREATE secrets_share:tri_b CONTENT { tenant: auth_organization:tri, created_identity: auth_identity:partageur, envelope: "enc:v2:share:B", key_fingerprint: string::repeat("b", 64), expires_at: time::now() + 1h, created_at: d"2026-01-02T00:00:00Z" };
    CREATE secrets_share:tri_c CONTENT { tenant: auth_organization:tri, created_identity: auth_identity:partageur, envelope: "enc:v2:share:C", key_fingerprint: string::repeat("c", 64), expires_at: time::now() + 1h, created_at: d"2026-01-01T00:00:00Z" };
};

-- test: deux partages créés à la même date gardent le même ordre, page par page, sans doublon ni manque
{
    LET $expected = [secrets_share:tri_b, secrets_share:tri_a, secrets_share:tri_c];
    LET $pages = [
        fn::secrets_share_list({ tenant: "auth_organization:tri", limit: 1, start: 0 }).data.items[0].id,
        fn::secrets_share_list({ tenant: "auth_organization:tri", limit: 1, start: 1 }).data.items[0].id,
        fn::secrets_share_list({ tenant: "auth_organization:tri", limit: 1, start: 2 }).data.items[0].id
    ];
    LET $again = [
        fn::secrets_share_list({ tenant: "auth_organization:tri", limit: 1, start: 0 }).data.items[0].id,
        fn::secrets_share_list({ tenant: "auth_organization:tri", limit: 1, start: 1 }).data.items[0].id,
        fn::secrets_share_list({ tenant: "auth_organization:tri", limit: 1, start: 2 }).data.items[0].id
    ];
    RETURN fn::secrets_share_list({ tenant: "auth_organization:tri" }).data.items.id == $expected AND $pages == $expected AND $again == $expected;
};
