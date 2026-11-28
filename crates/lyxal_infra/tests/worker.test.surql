-- lyxal-test: assertions
-- Worker : zones échues, réservation (jeton perdu, renouvellement, garde), lecture refusée sans
-- jeton, journal sent puis done ou failed (échec définitif, passager), chaîne vérifiée,
-- événements une fois et sans nom, vérification de la publication (essais espacés, délai
-- dépassé), fin de passe en échec (zone et compte failing), purge, sonde de santé.
--
-- identité worker: { "id": "auth_session:worker", "pv": 1, "permissions": ["infra.worker"] }
-- identité lecteur: { "id": "auth_session:lecteur", "pv": 1, "permissions": ["infra.read"] }

-- préparation: compte de service du worker, compte, zone gérée, enregistrements déclarés
{
    CREATE auth_application:worker CONTENT { client_id: "lyxal-test-infra-worker", name: "Worker", type: "machine", redirect_uris: [], state: "active", permissions_version: 1 };
    CREATE auth_session:worker CONTENT { application: auth_application:worker, kind: "service", idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_identity:lecteur CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "lecteur@lyxal.test" } };
    CREATE auth_session:lecteur CONTENT { identity: auth_identity:lecteur, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    fn::secrets_secret_create({ path: "infra/scaleway", kind: "api_key" });
    fn::infra_account_create({ key: "scw", name: "Scaleway", credentials_path: "infra/scaleway", settings: { project_id: u"0b3a6f1e-3c1d-4f2a-9a55-6f3f0a7b2c11" } });
    fn::infra_account_test_result({ account: "infra_account:scw", ok: true, zones: [{ name: "exemple.fr", status: "active" }] });
    LET $zone = fn::infra_zone_attach({ account: "infra_account:scw", name: "exemple.fr", mode: "managed" }).data.id;
    fn::infra_records_declare({ owner: "lyxal_mail", subject: "d1", records: [
        { fqdn: "exemple.fr", type: "MX", values: ["10 mx.exemple.fr"], mode: "exclusive" },
        { fqdn: "_dmarc.exemple.fr", type: "TXT", values: ["v=DMARC1; p=none; rua=mailto:dmarc@exemple.fr"], mode: "shared", singleton_prefix: "v=DMARC1" }
    ] });
    DEFINE TABLE OVERWRITE passe SCHEMALESS PERMISSIONS FULL;
    CREATE passe:ids CONTENT { zone: <string> $zone };
};

-- test: zones échues : passe demandée au rattachement ; aucune pour un compte désactivé
-- en tant que: worker
{
    LET $due = fn::infra_zone_due({});
    RETURN $due.ok AND $due.data.items == [{ zone: <record> (SELECT VALUE zone FROM ONLY passe:ids), account: infra_account:scw }];
};

-- test: réservation : jeton UUID v7, informations d'appel sans secret ; deuxième réservation refusée ; zone réservée non échue
-- en tant que: worker
{
    LET $zone = (SELECT VALUE zone FROM ONLY passe:ids);
    LET $claim = fn::infra_zone_claim({ zone: $zone, ttl_seconds: 120 });
    LET $other = fn::infra_zone_claim({ zone: $zone });
    UPSERT passe:ids SET claim = $claim.data.claim;
    RETURN $claim.ok AND fn::validation_uuid_v7($claim.data.claim, true).valid AND $claim.data.name == "exemple.fr" AND $claim.data.mode == "managed"
        AND $claim.data.account == { account: infra_account:scw, provider: "scaleway", credentials_path: "infra/scaleway", settings: { project_id: u"0b3a6f1e-3c1d-4f2a-9a55-6f3f0a7b2c11", default_zone: "fr-par-1", default_region: "fr-par" }, state: "active" }
        AND $other.error.code == "INFRA_ZONE_CLAIM_LOST" AND fn::infra_zone_due({}).data.items == []
        AND fn::infra_zone_claim({ zone: "infra_zone:inconnue" }).error.code == "INFRA_ZONE_NOT_FOUND"
        AND fn::infra_zone_claim({ zone: $zone, ttl_seconds: 5 }).error.code == "INFRA_INVALID_PARAMETERS";
};

-- test: renouvellement par le détenteur ; jeton étranger : INFRA_ZONE_CLAIM_LOST partout
-- en tant que: worker
{
    LET $zone = (SELECT VALUE zone FROM ONLY passe:ids);
    LET $claim = (SELECT VALUE claim FROM ONLY passe:ids);
    LET $stranger = <string> rand::uuid::v7();
    LET $renewed = fn::infra_zone_renew({ zone: $zone, claim: $claim, ttl_seconds: 600 });
    RETURN $renewed.ok AND $renewed.data.locked_until > time::now() + 9m
        AND [
            fn::infra_zone_renew({ zone: $zone, claim: $stranger }),
            fn::infra_zone_observe({ zone: $zone, claim: $stranger, status: "active", records: [] }),
            fn::infra_zone_plan({ zone: $zone, claim: $stranger }),
            fn::infra_zone_apply_begin({ zone: $zone, claim: $stranger, plan_hash: string::repeat("a", 64) }),
            fn::infra_zone_apply_result({ zone: $zone, claim: $stranger, results: [{ change: "infra_change:x", ok: true }] }),
            fn::infra_zone_release({ zone: $zone, claim: $stranger, outcome: "noop" })
        ].all(|$r| $r.error.code == "INFRA_ZONE_CLAIM_LOST")
        AND fn::infra_zone_renew({ zone: $zone, claim: "pas-un-jeton" }).error.code == "INFRA_INVALID_PARAMETERS";
};

-- test: garde : une écriture directe ne vole pas une réservation en cours
-- attendu-erreur: INFRA_ZONE_CLAIM_LOST
UPDATE <record> (SELECT VALUE zone FROM ONLY passe:ids) SET claim = "autre";

-- test: lecture de la zone : lignes contrôlées (nom, valeur), photo écrite par différence
-- en tant que: worker
{
    LET $zone = (SELECT VALUE zone FROM ONLY passe:ids);
    LET $claim = (SELECT VALUE claim FROM ONLY passe:ids);
    LET $bad = fn::infra_zone_observe({ zone: $zone, claim: $claim, status: "active", records: [{ provider_id: "x", fqdn: "pas un nom", type: "A", value: "1", ttl: 60 }] });
    LET $rows = [
        { provider_id: "h-ns", fqdn: "exemple.fr", type: "ns", value: "ns0.dom.scw.cloud", ttl: 86400 },
        { provider_id: "h-txt", fqdn: "exemple.fr", type: "TXT", value: "google-site-verification=abc", ttl: 3600, comment: "humain" }
    ];
    LET $first = fn::infra_zone_observe({ zone: $zone, claim: $claim, status: "active", nameservers: ["ns0.dom.scw.cloud"], delegated: true, records: $rows });
    LET $same = fn::infra_zone_observe({ zone: $zone, claim: $claim, status: "active", nameservers: ["ns0.dom.scw.cloud"], delegated: true, records: $rows });
    LET $less = fn::infra_zone_observe({ zone: $zone, claim: $claim, status: "active", nameservers: ["ns0.dom.scw.cloud"], delegated: true, records: [$rows[0]] });
    RETURN $bad.error.details.fields == { "records[0].fqdn": ["CORE_VALIDATION_FORMAT"] }
        AND $first.data.written == 2 AND $first.data.removed == 0 AND $same.data.written == 0 AND $same.data.hash == $first.data.hash
        AND $less.data.removed == 1 AND $less.data.total == 1
        AND (SELECT VALUE type FROM infra_zone_record) == ["NS"];
};

-- test: zone non rattachée chez la zone parente, puis zone en attente chez l'hébergeur : états et événement
-- en tant que: worker
{
    LET $zone = (SELECT VALUE zone FROM ONLY passe:ids);
    LET $claim = (SELECT VALUE claim FROM ONLY passe:ids);
    LET $not_delegated = fn::infra_zone_observe({ zone: $zone, claim: $claim, status: "active", delegated: false, records: [] });
    LET $pending = fn::infra_zone_observe({ zone: $zone, claim: $claim, status: "pending", delegated: true, records: [] });
    LET $ok = fn::infra_zone_observe({ zone: $zone, claim: $claim, status: "active", delegated: true, records: [] });
    RETURN $not_delegated.data.state == "not_delegated" AND $pending.data.state == "pending_provider" AND $ok.data.state == "ok";
};

-- test: événement infra.zone.blocked de la zone non rattachée : identifiant opaque, sans nom
RETURN (SELECT VALUE payload FROM event_outbox WHERE event_type = "infra.zone.blocked") == [{ zone: (SELECT VALUE zone FROM ONLY passe:ids), state: "not_delegated" }];

-- test: plan puis écriture : intentions sent avant l'appel, issues done et failed (définitive), échec passager
-- en tant que: worker
{
    LET $zone = (SELECT VALUE zone FROM ONLY passe:ids);
    LET $claim = (SELECT VALUE claim FROM ONLY passe:ids);
    LET $plan = fn::infra_zone_plan({ zone: $zone, claim: $claim });
    LET $stale = fn::infra_zone_apply_begin({ zone: $zone, claim: $claim, plan_hash: string::repeat("f", 64) });
    LET $begun = fn::infra_zone_apply_begin({ zone: $zone, claim: $claim, plan_hash: $plan.data.hash });
    LET $sent = count(SELECT id FROM infra_change WHERE state = "sent");
    LET $mx = array::filter($begun.data.changes, |$c| $c.type = "MX")[0];
    LET $dmarc = array::filter($begun.data.changes, |$c| $c.type = "TXT")[0];
    LET $refused = fn::infra_zone_apply_result({ zone: $zone, claim: $claim, results: [{ change: <string> $mx.change, ok: true }] });
    LET $result = fn::infra_zone_apply_result({ zone: $zone, claim: $claim, results: [
        { change: <string> $mx.change, ok: true, provider_id: "p-mx", provider_status: 200 },
        { change: <string> $dmarc.change, ok: false, provider_status: 400, code: "INFRA_PROVIDER_REJECTED" }
    ] });
    LET $twice = fn::infra_zone_apply_result({ zone: $zone, claim: $claim, results: [{ change: <string> $mx.change, ok: true, provider_id: "p-mx" }] });
    RETURN $plan.data.reason == "apply" AND array::len($plan.data.changes) == 2 AND $stale.error.code == "INFRA_ZONE_PLAN_STALE"
        AND $sent == 2 AND $refused.error.code == "INFRA_INVALID_PARAMETERS"
        AND $result.data.done == 1 AND $result.data.failed == 1
        AND array::sort($result.data.records.state) == ["failed", "written"]
        AND (SELECT VALUE error.code FROM ONLY infra_record WHERE fqdn = "_dmarc.exemple.fr" LIMIT 1) == "INFRA_PROVIDER_REJECTED"
        AND array::sort(SELECT VALUE state FROM infra_change WHERE action = "add") == ["done", "failed"]
        AND (SELECT VALUE code FROM ONLY infra_change WHERE state = "failed" LIMIT 1) == "INFRA_PROVIDER_REJECTED"
        AND $twice.error.code == "INFRA_INVALID_PARAMETERS";
};

-- test: garde du journal : une issue posée ne change plus
-- attendu-erreur: INFRA_WRITE_FORBIDDEN
UPDATE infra_change SET state = "sent" WHERE state = "done";

-- test: événement infra.record.failed une fois, sans nom de domaine ni valeur
{
    LET $events = (SELECT VALUE payload FROM event_outbox WHERE event_type = "infra.record.failed");
    RETURN array::len($events) == 1 AND $events[0].owner == "lyxal_mail" AND $events[0].subject == "d1" AND $events[0].code == "INFRA_PROVIDER_REJECTED"
        AND !string::contains(<string> $events, "exemple.fr") AND !string::contains(<string> $events, "DMARC1");
};

-- préparation: un hôte déclaré par l'administrateur
{
    fn::infra_records_declare({ owner: "manual", subject: "site", records: [{ fqdn: "www.exemple.fr", type: "A", values: ["192.0.2.10"], mode: "exclusive" }] });
};

-- test: échec passager : état inchangé, last_error de la zone ; écriture de Lyxal relue chez le fournisseur : satisfaite
-- en tant que: worker
{
    LET $zone = (SELECT VALUE zone FROM ONLY passe:ids);
    LET $claim = (SELECT VALUE claim FROM ONLY passe:ids);
    LET $mx_key = (SELECT VALUE id FROM ONLY infra_record WHERE type = "MX" LIMIT 1);
    LET $observed = fn::infra_zone_observe({ zone: $zone, claim: $claim, status: "active", nameservers: ["ns0.dom.scw.cloud"], delegated: true, records: [
        { provider_id: "h-ns", fqdn: "exemple.fr", type: "NS", value: "ns0.dom.scw.cloud", ttl: 86400 },
        { provider_id: "p-mx", fqdn: "exemple.fr", type: "MX", value: "10 mx.exemple.fr", ttl: 3600, comment: "lyxal:" + <string> record::id($mx_key) }
    ] });
    LET $plan = fn::infra_zone_plan({ zone: $zone, claim: $claim });
    LET $begun = fn::infra_zone_apply_begin({ zone: $zone, claim: $claim, plan_hash: $plan.data.hash });
    LET $www = array::filter($begun.data.changes, |$c| $c.fqdn = "www.exemple.fr")[0];
    LET $result = fn::infra_zone_apply_result({ zone: $zone, claim: $claim, results: array::map($begun.data.changes, |$c| { change: <string> $c.change, ok: false, code: "INFRA_PROVIDER_UNAVAILABLE", retryable: true, provider_status: 503 }) });
    RETURN $observed.data.owned == 1 AND array::len($begun.data.changes) == 2 AND $result.data.failed == 2 AND $www IS NOT NONE
        AND (SELECT VALUE state FROM ONLY $mx_key) == "written"
        AND (SELECT VALUE state FROM ONLY infra_record WHERE fqdn = "www.exemple.fr" LIMIT 1) == "pending"
        AND (SELECT VALUE last_error.code FROM ONLY <record> $zone) == "INFRA_PROVIDER_UNAVAILABLE";
};

-- test: un compte de service sans infra.records.declare ne déclare pas (le worker n'est pas un déclarant)
-- en tant que: worker
RETURN fn::infra_records_declare({ owner: "lyxal_mail", subject: "x", records: [] }).error.code == "INFRA_PERMISSION_DENIED";

-- test: fin de passe en échec définitif : zone failing, compte failing (clé refusée), réservation levée
-- en tant que: worker
{
    LET $zone = (SELECT VALUE zone FROM ONLY passe:ids);
    LET $claim = (SELECT VALUE claim FROM ONLY passe:ids);
    LET $missing = fn::infra_zone_release({ zone: $zone, claim: $claim, outcome: "failed" });
    LET $released = fn::infra_zone_release({ zone: $zone, claim: $claim, outcome: "failed", code: "INFRA_PROVIDER_AUTH" });
    LET $z = (SELECT * FROM ONLY <record> $zone);
    RETURN $missing.error.code == "INFRA_INVALID_PARAMETERS" AND $released.data.state == "failing"
        AND $z.claim IS NONE AND $z.locked_until IS NONE AND $z.last_error.code == "INFRA_PROVIDER_AUTH" AND $z.next_reconcile_at > time::now()
        AND (SELECT VALUE state FROM ONLY infra_account:scw) == "failing"
        AND fn::infra_zone_release({ zone: $zone, claim: $claim, outcome: "noop" }).error.code == "INFRA_ZONE_CLAIM_LOST"
        AND fn::infra_zone_due({}).data.items == [];
};

-- test: compte réactivé, passe réussie : zone de nouveau ok
{
    fn::infra_account_test_result({ account: "infra_account:scw", ok: true, zones: [{ name: "exemple.fr", status: "active" }] });
    LET $zone = (SELECT VALUE zone FROM ONLY passe:ids);
    LET $claim = fn::infra_zone_claim({ zone: $zone }).data.claim;
    LET $released = fn::infra_zone_release({ zone: $zone, claim: $claim, outcome: "noop" });
    RETURN $released.data.state == "ok" AND (SELECT VALUE last_error FROM ONLY <record> $zone) IS NONE;
};

-- test: enregistrements à vérifier : écrits et échus, avec les serveurs de noms de leur zone
-- en tant que: worker
{
    UPDATE infra_record SET next_verify_at = time::now() - 1s WHERE state = "written";
    LET $due = fn::infra_records_to_verify({});
    RETURN array::len($due.data.items) == 1 AND $due.data.items[0].fqdn == "exemple.fr" AND $due.data.items[0].type == "MX"
        AND $due.data.items[0].values == ["10 mx.exemple.fr"] AND $due.data.items[0].nameservers == ["ns0.dom.scw.cloud"] AND $due.data.items[0].zone_name == "exemple.fr";
};

-- test: vérification : pas encore servi (essais espacés), réponse périmée ignorée, puis publié (événement)
-- en tant que: worker
{
    LET $item = fn::infra_records_to_verify({}).data.items[0];
    LET $first = fn::infra_record_verify_result({ record: <string> $item.record, written_at: $item.written_at, published: false });
    LET $second = fn::infra_record_verify_result({ record: <string> $item.record, written_at: $item.written_at, published: false, code: "INFRA_DNS_UNAVAILABLE" });
    LET $stale = fn::infra_record_verify_result({ record: <string> $item.record, written_at: time::now() - 1d, published: true });
    LET $published = fn::infra_record_verify_result({ record: <string> $item.record, written_at: $item.written_at, published: true });
    LET $later = fn::infra_record_verify_result({ record: <string> $item.record, written_at: $item.written_at, published: true });
    RETURN $first.data.state == "written" AND $first.data.next_verify_at > time::now() + 25s AND $first.data.next_verify_at < time::now() + 35s
        AND $second.data.next_verify_at > time::now() + 55s
        AND $stale.data.skipped AND $published.data.state == "published" AND $later.data.skipped
        AND (SELECT VALUE verify_attempts FROM ONLY $item.record) == 3
        AND (SELECT VALUE state FROM ONLY $item.record) == "published"
        AND fn::infra_record_verify_result({ record: "infra_record:inconnu", written_at: time::now(), published: true }).error.code == "INFRA_RECORD_NOT_FOUND";
};

-- test: événement infra.record.published une fois : identifiants et propriétaire, sans nom ni valeur
{
    LET $events = (SELECT VALUE payload FROM event_outbox WHERE event_type = "infra.record.published");
    LET $mx = (SELECT VALUE id FROM ONLY infra_record WHERE type = "MX" LIMIT 1);
    RETURN array::len($events) == 1 AND $events[0] == { record: <string> $mx, owner: "lyxal_mail", subject: "d1", zone: (SELECT VALUE zone FROM ONLY passe:ids) };
};

-- test: délai de vérification dépassé : failed (INFRA_DNS_NOT_PUBLISHED)
-- en tant que: worker
{
    LET $zone = <record> (SELECT VALUE zone FROM ONLY passe:ids);
    CREATE infra_record:verif CONTENT { owner: "manual", subject: "verif", zone: $zone, fqdn: "v.exemple.fr", type: "A", values: ["192.0.2.50"], ttl: 3600, mode: "exclusive",
        state: "written", written_at: time::now() - 25h, next_verify_at: time::now() - 1s, verify_attempts: 40 };
    LET $result = fn::infra_record_verify_result({ record: "infra_record:verif", written_at: (SELECT VALUE written_at FROM ONLY infra_record:verif), published: false });
    RETURN $result.data.state == "failed" AND (SELECT VALUE error.code FROM ONLY infra_record:verif) == "INFRA_DNS_NOT_PUBLISHED";
};

-- test: sonde de santé : nombres sans nom ; dégradé (enregistrements en échec)
-- en tant que: lecteur
{
    LET $health = fn::infra_health({});
    RETURN $health.ok AND $health.data.status == "degraded" AND $health.data.settings_ok AND $health.data.accounts == 1
        AND $health.data.records_failed == 2 AND $health.data.zones == 1 AND $health.data.zones_failing == 0
        AND !string::contains(<string> $health.data, "exemple.fr");
};

-- test: la chaîne du journal est intacte après toutes ces écritures
-- en tant que: lecteur
{
    LET $verify = fn::infra_change_verify({});
    LET $page = fn::infra_change_verify({ from_rank: 2, limit: 2 });
    RETURN $verify.data.valid AND $verify.data.complete AND $verify.data.from_rank == 1 AND $page.data.valid AND $page.data.checked == 2 AND !$page.data.complete;
};

-- préparation: une entrée du journal falsifiée en base (garde et champ figé levés le temps de l'écriture)
{
    REMOVE EVENT infra_change_guard ON TABLE infra_change;
    DEFINE FIELD OVERWRITE actor ON TABLE infra_change TYPE string;
    UPDATE infra_change SET actor = "pirate" WHERE rank = 2;
    DEFINE FIELD OVERWRITE actor ON TABLE infra_change TYPE string READONLY;
    DEFINE EVENT OVERWRITE infra_change_guard ON TABLE infra_change WHEN $event = "UPDATE" THEN {
        IF $before.state != "sent" OR $after.state NOT IN ["done", "failed"] { THROW "INFRA_WRITE_FORBIDDEN"; };
    };
};

-- test: la falsification est détectée au rang exact
-- en tant que: lecteur
{
    LET $verify = fn::infra_change_verify({});
    RETURN (SELECT VALUE actor FROM ONLY infra_change WHERE rank = 2 LIMIT 1) == "pirate" AND $verify.data.valid == false AND $verify.data.broken_at == 2;
};

-- test: purge : rien avant la conservation
-- en tant que: worker
RETURN fn::infra_purge({}).data == { changes: 0, records: 0, more: false };

-- préparation: entrées anciennes du journal, enregistrement retiré depuis longtemps
{
    REMOVE EVENT infra_change_guard ON TABLE infra_change;
    DEFINE FIELD OVERWRITE created_at ON TABLE infra_change TYPE datetime;
    UPDATE infra_change SET created_at = time::now() - 500d WHERE rank <= 3;
    DEFINE FIELD OVERWRITE created_at ON TABLE infra_change TYPE datetime READONLY;
    DEFINE EVENT OVERWRITE infra_change_guard ON TABLE infra_change WHEN $event = "UPDATE" THEN {
        IF $before.state != "sent" OR $after.state NOT IN ["done", "failed"] { THROW "INFRA_WRITE_FORBIDDEN"; };
    };
    CREATE infra_record:ancien CONTENT { owner: "manual", subject: "ancien", fqdn: "ancien.exemple.fr", type: "A", values: ["192.0.2.60"], ttl: 3600, mode: "exclusive", state: "released" };
    UPDATE infra_record:ancien SET state = "released";
    DEFINE FIELD OVERWRITE updated_at ON TABLE infra_record TYPE datetime;
    UPDATE infra_record:ancien SET updated_at = time::now() - 40d;
    DEFINE FIELD OVERWRITE updated_at ON TABLE infra_record TYPE datetime VALUE time::now();
};

-- test: purge : journal ancien (début contigu) et retraits anciens retirés ; dernière entrée de chaque zone gardée
-- en tant que: worker
{
    LET $purged = fn::infra_purge({ limit: 100 });
    RETURN $purged.data.records == 1 AND $purged.data.changes == 3
        AND !record::exists(infra_record:ancien) AND (SELECT VALUE rank FROM infra_change ORDER BY rank LIMIT 1)[0] == 4;
};

-- test: un lecteur n'appelle aucune fonction du worker
-- en tant que: lecteur
RETURN [
    fn::infra_account_due({}),
    fn::infra_account_test_result({ account: "infra_account:scw", ok: true }),
    fn::infra_zone_due({}),
    fn::infra_zone_claim({ zone: "infra_zone:x" }),
    fn::infra_records_to_verify({}),
    fn::infra_record_verify_result({ record: "infra_record:x", written_at: time::now(), published: true }),
    fn::infra_purge({})
].all(|$r| $r.error.code == "INFRA_PERMISSION_DENIED")
    AND fn::infra_zone_due({ limit: "dix" }).error.code == "INFRA_INVALID_PARAMETERS";
