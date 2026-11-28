-- lyxal-test: assertions
-- Cœur des règles du plan (plan §3.1) : mode observe, passe gérée, idempotence, exclusif /
-- partagé / préfixe unique, valeur humaine identique satisfaite, CNAME, drift_modified, yield,
-- take_over (une fois), drift_deleted recréé, reprise par la marque lyxal:, retrait seulement si
-- la valeur est inchangée, seuils de suppression et approbation par empreinte.
--
-- Un faux fournisseur en SurrealQL (fn::essai_passe, défini par la préparation) tient la photo de
-- la zone (passe:photo) et joue une passe complète du worker : réservation, lecture, plan,
-- écriture (identifiants attribués aux ajouts, marque lyxal:<clé>), résultat, fin de passe.
--
-- identité plateforme: { "id": "auth_session:plateforme", "pv": 1, "permissions": ["infra.read", "infra.manage"] }

-- préparation: compte, zone en observation, faux fournisseur
{
    CREATE auth_identity:plateforme CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "plateforme@lyxal.test" } };
    CREATE auth_session:plateforme CONTENT { identity: auth_identity:plateforme, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    fn::secrets_secret_create({ path: "infra/scaleway", kind: "api_key" });
    fn::infra_account_create({ key: "scw", name: "Scaleway", credentials_path: "infra/scaleway", settings: { project_id: u"0b3a6f1e-3c1d-4f2a-9a55-6f3f0a7b2c11" } });
    fn::infra_account_test_result({ account: "infra_account:scw", ok: true, zones: [{ name: "exemple.fr", status: "active" }] });
    LET $zone = fn::infra_zone_attach({ account: "infra_account:scw", name: "exemple.fr" }).data.id;
    DEFINE TABLE OVERWRITE passe SCHEMALESS PERMISSIONS FULL;
    CREATE passe:photo CONTENT { zone: $zone, rows: [
        { provider_id: "h-ns", fqdn: "exemple.fr", type: "NS", value: "ns0.dom.scw.cloud", ttl: 86400 },
        { provider_id: "h-spf", fqdn: "exemple.fr", type: "TXT", value: "v=spf1 include:_spf.google.com -all", ttl: 3600 },
        { provider_id: "h-mx", fqdn: "exemple.fr", type: "MX", value: "10 mx.exemple.fr", ttl: 3600 },
        { provider_id: "h-docs", fqdn: "docs.exemple.fr", type: "A", value: "198.51.100.7", ttl: 3600 }
    ] };
    -- Passe complète contre le faux fournisseur : rend le plan, l'issue et la photo mise à jour
    DEFINE FUNCTION OVERWRITE fn::essai_passe() {
        LET $photo = (SELECT * FROM ONLY passe:photo);
        LET $zone = <string> $photo.zone;
        LET $claim = fn::infra_zone_claim({ zone: $zone }).data.claim;
        LET $observed = fn::infra_zone_observe({ zone: $zone, claim: $claim, status: "active", nameservers: ["ns0.dom.scw.cloud", "ns1.dom.scw.cloud"], delegated: true, records: $photo.rows });
        LET $plan = fn::infra_zone_plan({ zone: $zone, claim: $claim });
        LET $begun = IF $plan.data.apply { fn::infra_zone_apply_begin({ zone: $zone, claim: $claim, plan_hash: $plan.data.hash }) } ELSE { NONE };
        LET $results = array::map($begun.data.changes ?? [], |$c| {
            change: <string> $c.change, ok: true, provider_status: 200,
            provider_id: IF $c.action = "add" { "p-" + string::slice(crypto::sha256($c.fqdn + $c.type + $c.value), 0, 8) } ELSE { NONE }
        });
        LET $applied = IF $begun IS NONE { NONE } ELSE { fn::infra_zone_apply_result({ zone: $zone, claim: $claim, results: $results }) };
        -- Le fournisseur applique les changements à sa zone
        LET $changes = $begun.data.changes ?? [];
        LET $removed = array::filter($changes, |$c| $c.action IN ["delete", "set"]).provider_id;
        LET $kept = array::filter($photo.rows, |$r| $r.provider_id NOT IN $removed);
        LET $set = array::map(array::filter($changes, |$c| $c.action = "set"), |$c| { provider_id: $c.provider_id, fqdn: $c.fqdn, type: $c.type, value: $c.value, ttl: $c.ttl, comment: $c.comment });
        LET $added = array::map(array::filter($changes, |$c| $c.action = "add"), |$c| {
            provider_id: "p-" + string::slice(crypto::sha256($c.fqdn + $c.type + $c.value), 0, 8), fqdn: $c.fqdn, type: $c.type, value: $c.value, ttl: $c.ttl, comment: $c.comment
        });
        UPDATE passe:photo SET rows = array::concat(array::concat($kept, $set), $added);
        LET $released = fn::infra_zone_release({ zone: $zone, claim: $claim, outcome: IF $plan.data.reason = "apply" { "applied" } ELSE IF $plan.data.reason = "observe" { "observed" } ELSE { $plan.data.reason } });
        RETURN { observed: $observed, plan: $plan, begun: $begun, applied: $applied, released: $released };
    };
    -- Enregistrements voulus : un hôte (manual)
    fn::infra_records_declare({ owner: "manual", subject: "site", records: [{ fqdn: "www.exemple.fr", type: "A", values: ["192.0.2.10"], mode: "exclusive" }] });
};

-- test: zone en observation : plan calculé et rangé, rien n'est écrit, aucun état changé
{
    LET $pass = fn::essai_passe();
    LET $zone = (SELECT * FROM ONLY (SELECT VALUE zone FROM ONLY passe:photo));
    RETURN $pass.observed.data.total == 4 AND $pass.observed.data.written == 4 AND $pass.observed.data.owned == 0
        AND $pass.plan.data.reason == "observe" AND $pass.plan.data.apply == false AND $pass.begun IS NONE
        AND $pass.plan.data.changes == [{ action: "add", record: fn::infra__record_key("manual", "site", "www.exemple.fr", "A"), fqdn: "www.exemple.fr", type: "A", value: "192.0.2.10", ttl: 3600 }]
        AND $zone.last_plan.hash == $pass.plan.data.hash AND $zone.claim IS NONE AND $zone.nameservers == ["ns0.dom.scw.cloud", "ns1.dom.scw.cloud"] AND $zone.delegated
        AND $zone.reconciled_at IS NOT NONE AND $zone.reconcile_requested_at IS NONE
        AND (SELECT VALUE state FROM ONLY infra_record WHERE fqdn = "www.exemple.fr" LIMIT 1) == "pending"
        AND count(SELECT id FROM infra_change WHERE state = "sent") == 0;
};

-- test: zone gérée : une écriture, marque lyxal:<clé>, identifiant noté, état written, journal sent puis done
{
    UPDATE (SELECT VALUE zone FROM ONLY passe:photo) SET mode = "managed";
    LET $pass = fn::essai_passe();
    LET $record = (SELECT * FROM ONLY fn::infra__record_key("manual", "site", "www.exemple.fr", "A"));
    LET $entry = (SELECT * FROM ONLY infra_change WHERE action = "add" LIMIT 1);
    RETURN $pass.plan.data.reason == "apply" AND array::len($pass.begun.data.changes) == 1
        AND $pass.begun.data.changes[0].comment == "lyxal:" + <string> record::id($record.id)
        AND $pass.applied.data.done == 1 AND $pass.applied.data.records == [{ record: $record.id, state: "written" }]
        AND $record.state == "written" AND $record.provider_ids == [{ id: "p-" + string::slice(crypto::sha256("www.exemple.frA192.0.2.10"), 0, 8), value: "192.0.2.10" }]
        AND $record.applied_values == ["192.0.2.10"] AND $record.next_verify_at > time::now()
        AND $entry.state == "done" AND $entry.provider_status == 200 AND $entry.after.value == "192.0.2.10"
        AND $pass.released.data.state == "ok";
};

-- test: passe suivante sans écart : aucun changement, aucune écriture (idempotence)
{
    LET $previous = count(SELECT id FROM infra_change);
    LET $pass = fn::essai_passe();
    RETURN $pass.observed.data.written == 1 AND $pass.observed.data.owned == 1 AND $pass.plan.data.reason == "noop" AND $pass.plan.data.changes == []
        AND $pass.begun IS NONE AND count(SELECT id FROM infra_change) == $previous
        AND (SELECT VALUE state FROM ONLY infra_record WHERE fqdn = "www.exemple.fr" LIMIT 1) == "written";
};

-- test: SPF humain : conflit foreign_singleton, jamais écrasé ; MX humain identique : satisfait, jamais dupliqué ni pris ; CNAME sur un nom habité : conflit
{
    fn::infra_records_declare({ owner: "lyxal_mail", subject: "d1", records: [
        { fqdn: "exemple.fr", type: "TXT", values: ["v=spf1 a:mx.exemple.fr -all"], mode: "shared", singleton_prefix: "v=spf1" },
        { fqdn: "exemple.fr", type: "MX", values: ["10 mx.exemple.fr"], mode: "exclusive" },
        { fqdn: "docs.exemple.fr", type: "CNAME", values: ["pages.example.net"], mode: "exclusive" }
    ] });
    LET $pass = fn::essai_passe();
    LET $spf = (SELECT * FROM ONLY fn::infra__record_key("lyxal_mail", "d1", "exemple.fr", "TXT"));
    LET $mx = (SELECT * FROM ONLY fn::infra__record_key("lyxal_mail", "d1", "exemple.fr", "MX"));
    LET $docs = (SELECT * FROM ONLY fn::infra__record_key("lyxal_mail", "d1", "docs.exemple.fr", "CNAME"));
    RETURN $pass.plan.data.reason == "noop" AND $pass.plan.data.changes == [] AND array::len($pass.plan.data.conflicts) == 2
        AND $spf.state == "conflict" AND $spf.conflict.reason == "foreign_singleton" AND $spf.conflict.observed == ["v=spf1 include:_spf.google.com -all"]
        AND $docs.state == "conflict" AND $docs.conflict.reason == "cname" AND $docs.conflict.observed == ["198.51.100.7"]
        AND $mx.state == "written" AND $mx.provider_ids == []
        AND (SELECT VALUE rows.provider_id FROM ONLY passe:photo) CONTAINSALL ["h-spf", "h-mx", "h-docs"]
        AND count(SELECT id FROM infra_change WHERE action = "conflict") == 2
        AND count(SELECT id FROM event_outbox WHERE event_type = "infra.record.conflict") == 2;
};

-- test: conflit persistant : ni nouvelle note ni nouvel événement à la passe suivante
{
    LET $pass = fn::essai_passe();
    RETURN $pass.plan.data.reason == "noop" AND count(SELECT id FROM infra_change WHERE action = "conflict") == 2
        AND count(SELECT id FROM event_outbox WHERE event_type = "infra.record.conflict") == 2
        AND !string::contains(<string> (SELECT VALUE payload FROM event_outbox WHERE event_type = "infra.record.conflict"), "exemple.fr");
};

-- test: take_over (administrateur) : la valeur humaine est remplacée à la passe suivante, une seule fois
-- en tant que: plateforme
{
    LET $spf = fn::infra__record_key("lyxal_mail", "d1", "exemple.fr", "TXT");
    LET $resolved = fn::infra_record_conflict_resolve({ record: <string> $spf, action: "take_over" });
    LET $again = fn::infra_record_conflict_resolve({ record: <string> $spf, action: "yield" });
    RETURN $resolved.data.state == "pending" AND $resolved.data.resolution.action == "take_over" AND $resolved.data.resolution.actor == "auth_identity:plateforme"
        AND $again.error.code == "INFRA_RECORD_NOT_FOUND"
        AND fn::infra_record_conflict_resolve({ record: "infra_record:inconnu", action: "yield" }).error.code == "INFRA_RECORD_NOT_FOUND"
        AND fn::infra_record_conflict_resolve({ record: <string> $spf, action: "ecraser" }).error.code == "INFRA_INVALID_PARAMETERS"
        AND (SELECT VALUE after FROM ONLY infra_change WHERE action = "resolve" LIMIT 1) == { action: "take_over" };
};

-- test: passe après take_over : suppression de la valeur humaine et ajout de celle de Lyxal, décision consommée
{
    LET $pass = fn::essai_passe();
    LET $spf = (SELECT * FROM ONLY fn::infra__record_key("lyxal_mail", "d1", "exemple.fr", "TXT"));
    LET $next = fn::essai_passe();
    RETURN $pass.plan.data.reason == "apply" AND $pass.plan.data.changes.action == ["add", "delete"]
        AND $pass.plan.data.changes[1].provider_id == "h-spf"
        AND $spf.state == "written" AND $spf.resolution.applied_at IS NOT NONE AND $spf.conflict IS NONE
        AND $next.plan.data.reason == "noop"
        AND "h-spf" NOT IN (SELECT VALUE rows.provider_id FROM ONLY passe:photo);
};

-- test: un humain modifie une écriture de Lyxal : conflit drift_modified, rien n'est réécrit ; yield la laisse en sommeil
{
    UPDATE passe:photo SET rows = array::map(rows, |$r| IF $r.value = "192.0.2.10" { object::extend($r, { value: "192.0.2.99" }) } ELSE { $r });
    LET $pass = fn::essai_passe();
    LET $www = fn::infra__record_key("manual", "site", "www.exemple.fr", "A");
    LET $state = (SELECT VALUE conflict.reason FROM ONLY $www);
    LET $yield = fn::infra_record_conflict_resolve({ record: <string> $www, action: "yield" });
    LET $later = fn::essai_passe();
    RETURN $pass.plan.data.changes == [] AND $state == "drift_modified" AND array::filter($pass.plan.data.conflicts, |$c| $c.record = $www)[0].observed == ["192.0.2.99"]
        AND $yield.data.state == "yielded" AND $later.plan.data.changes == [] AND $later.plan.data.conflicts.record CONTAINSNOT $www
        AND (SELECT VALUE state FROM ONLY $www) == "yielded";
};

-- test: un humain supprime une écriture de Lyxal : recréée, notée (drift_deleted)
{
    LET $spf = fn::infra__record_key("lyxal_mail", "d1", "exemple.fr", "TXT");
    LET $old = (SELECT VALUE provider_ids[0].id FROM ONLY $spf);
    UPDATE passe:photo SET rows = array::filter(rows, |$r| $r.provider_id != $old);
    LET $pass = fn::essai_passe();
    RETURN $pass.plan.data.changes.action == ["add"] AND $pass.plan.data.changes[0].value == "v=spf1 a:mx.exemple.fr -all"
        AND (SELECT VALUE before FROM ONLY infra_change WHERE action = "drift_deleted" LIMIT 1) == { values: ["v=spf1 a:mx.exemple.fr -all"] }
        AND (SELECT VALUE state FROM ONLY $spf) == "written" AND array::len((SELECT VALUE provider_ids FROM ONLY $spf)) == 1;
};

-- test: reprise après un arrêt entre l'écriture et son résultat : la marque lyxal: rattache l'écriture, aucun doublon
{
    fn::infra_records_declare({ owner: "manual", subject: "reprise", records: [{ fqdn: "api.exemple.fr", type: "AAAA", values: ["2001:db8::5"], mode: "exclusive" }] });
    LET $key = fn::infra__record_key("manual", "reprise", "api.exemple.fr", "AAAA");
    UPDATE passe:photo SET rows += { provider_id: "p-perdu", fqdn: "api.exemple.fr", type: "AAAA", value: "2001:db8::5", ttl: 3600, comment: "lyxal:" + <string> record::id($key) };
    LET $pass = fn::essai_passe();
    LET $record = (SELECT * FROM ONLY $key);
    RETURN $pass.plan.data.reason == "noop" AND $record.state == "written" AND $record.provider_ids == [{ id: "p-perdu", value: "2001:db8::5" }]
        AND (SELECT VALUE record FROM ONLY infra_zone_record WHERE provider_id = "p-perdu" LIMIT 1) == $key;
};

-- test: durée de vie changée : set par identifiant
{
    fn::infra_records_declare({ owner: "manual", subject: "reprise", records: [{ fqdn: "api.exemple.fr", type: "AAAA", values: ["2001:db8::5"], mode: "exclusive", ttl: 300 }] });
    LET $pass = fn::essai_passe();
    RETURN $pass.plan.data.changes == [{ action: "set", record: fn::infra__record_key("manual", "reprise", "api.exemple.fr", "AAAA"), provider_id: "p-perdu", fqdn: "api.exemple.fr", type: "AAAA", value: "2001:db8::5", ttl: 300 }]
        AND $pass.applied.data.records[0].state == "written"
        AND array::filter((SELECT VALUE rows FROM ONLY passe:photo), |$r| $r.provider_id = "p-perdu")[0].ttl == 300;
};

-- test: retrait : suppression chez le fournisseur seulement si la valeur est encore celle écrite par Lyxal
{
    -- Le SPF (écrit) est retiré ; la valeur AAAA a été modifiée par un humain avant le retrait
    UPDATE passe:photo SET rows = array::map(rows, |$r| IF $r.provider_id = "p-perdu" { object::extend($r, { value: "2001:db8::6" }) } ELSE { $r });
    LET $released = fn::infra_records_release({ owner: "lyxal_mail", subject: "d1" });
    LET $released_api = fn::infra_records_release({ owner: "manual", subject: "reprise" });
    LET $pass = fn::essai_passe();
    LET $spf = (SELECT * FROM ONLY fn::infra__record_key("lyxal_mail", "d1", "exemple.fr", "TXT"));
    LET $api = (SELECT * FROM ONLY fn::infra__record_key("manual", "reprise", "api.exemple.fr", "AAAA"));
    RETURN $released.data.releasing == 1 AND $released_api.data.releasing == 1
        AND $pass.plan.data.changes.action == ["delete"] AND $pass.plan.data.changes[0].value == "v=spf1 a:mx.exemple.fr -all"
        AND $spf.state == "released" AND $spf.provider_ids == []
        AND $api.state == "released" AND "p-perdu" IN (SELECT VALUE rows.provider_id FROM ONLY passe:photo);
};

-- test: seuil de prudence : plus de 10 suppressions bloquent le plan (événement), l'approbation par empreinte l'applique une fois
{
    fn::infra_records_declare({ owner: "manual", subject: "lot", records: array::map(<array>(0..12), |$i| { fqdn: "h" + <string> $i + ".exemple.fr", type: "A", values: ["192.0.2." + <string> ($i + 100)], mode: "exclusive" }) });
    LET $written = fn::essai_passe();
    fn::infra_records_release({ owner: "manual", subject: "lot" });
    LET $blocked = fn::essai_passe();
    LET $zone = (SELECT * FROM ONLY (SELECT VALUE zone FROM ONLY passe:photo));
    RETURN $written.applied.data.done == 12 AND $blocked.plan.data.reason == "blocked" AND $blocked.plan.data.deletions == 12 AND $blocked.begun IS NONE
        AND $zone.state == "blocked" AND $zone.last_plan.deletions == 12 AND $zone.last_plan.hash == $blocked.plan.data.hash
        AND count(SELECT id FROM event_outbox WHERE event_type = "infra.zone.blocked" AND payload.deletions = 12) == 1
        AND count(SELECT id FROM infra_record WHERE subject = "lot" AND state = "releasing") == 12;
};

-- test: approbation par l'administrateur puis passe : plan appliqué, zone de nouveau ok
-- en tant que: plateforme
RETURN fn::infra_zone_plan_approve({ zone: <string> (SELECT VALUE zone FROM ONLY passe:photo), plan_hash: (SELECT VALUE last_plan.hash FROM ONLY (SELECT VALUE zone FROM ONLY passe:photo)) }).data.state == "ok";

-- test: plan approuvé appliqué une fois, approbation consommée
{
    LET $pass = fn::essai_passe();
    LET $zone = (SELECT * FROM ONLY (SELECT VALUE zone FROM ONLY passe:photo));
    RETURN $pass.plan.data.reason == "apply" AND $pass.applied.data.done == 12 AND $zone.state == "ok" AND $zone.approved_plan_hash IS NONE
        AND count(SELECT id FROM infra_record WHERE subject = "lot" AND state = "released") == 12;
};

-- test: retrait pendant l'écriture d'un ajout : le résultat tardif garde le retrait et l'identifiant rendu, la passe suivante supprime l'entrée
{
    LET $zone = <string> (SELECT VALUE zone FROM ONLY passe:photo);
    fn::infra_records_declare({ owner: "manual", subject: "tardif", records: [{ fqdn: "tard.exemple.fr", type: "A", values: ["192.0.2.30"], mode: "exclusive" }] });
    LET $key = fn::infra__record_key("manual", "tardif", "tard.exemple.fr", "A");
    LET $claim = fn::infra_zone_claim({ zone: $zone }).data.claim;
    fn::infra_zone_observe({ zone: $zone, claim: $claim, status: "active", delegated: true, records: (SELECT VALUE rows FROM ONLY passe:photo) });
    LET $plan = fn::infra_zone_plan({ zone: $zone, claim: $claim });
    LET $begun = fn::infra_zone_apply_begin({ zone: $zone, claim: $claim, plan_hash: $plan.data.hash });
    -- Retrait arrivé entre le début de l'écriture et son résultat : aucun identifiant encore noté
    LET $released = fn::infra_records_release({ owner: "manual", subject: "tardif" });
    LET $between = (SELECT VALUE state FROM ONLY $key);
    LET $change = $begun.data.changes[0];
    LET $applied = fn::infra_zone_apply_result({ zone: $zone, claim: $claim, results: [{ change: <string> $change.change, ok: true, provider_status: 200, provider_id: "p-tard" }] });
    UPDATE passe:photo SET rows += { provider_id: "p-tard", fqdn: "tard.exemple.fr", type: "A", value: "192.0.2.30", ttl: 3600, comment: $change.comment };
    fn::infra_zone_release({ zone: $zone, claim: $claim, outcome: "applied" });
    LET $late = (SELECT state, provider_ids, applied_values FROM ONLY $key);
    LET $next = fn::essai_passe();
    RETURN $begun.data.changes.action == ["add"] AND $released.data.released == 1 AND $between == "released"
        AND $applied.data.records == [{ record: $key, state: "releasing" }]
        AND $late == { state: "releasing", provider_ids: [{ id: "p-tard", value: "192.0.2.30" }], applied_values: ["192.0.2.30"] }
        AND $next.plan.data.changes.action == ["delete"] AND $next.plan.data.changes[0].provider_id == "p-tard"
        AND (SELECT VALUE state FROM ONLY $key) == "released"
        AND "p-tard" NOT IN (SELECT VALUE rows.provider_id FROM ONLY passe:photo);
};

-- test: plan identique deux fois de suite : même empreinte (ordre stable)
{
    LET $zone = <string> (SELECT VALUE zone FROM ONLY passe:photo);
    fn::infra_records_declare({ owner: "manual", subject: "stable", records: [
        { fqdn: "b.exemple.fr", type: "TXT", values: ["deux", "un"], mode: "shared" },
        { fqdn: "a.exemple.fr", type: "A", values: ["192.0.2.2", "192.0.2.1"], mode: "exclusive" }
    ] });
    UPDATE <record> $zone SET mode = "observe";
    LET $first = fn::essai_passe();
    LET $second = fn::essai_passe();
    UPDATE <record> $zone SET mode = "managed";
    RETURN $first.plan.data.hash == $second.plan.data.hash AND array::len($first.plan.data.changes) == 4
        AND $first.plan.data.changes.fqdn == ["a.exemple.fr", "a.exemple.fr", "b.exemple.fr", "b.exemple.fr"];
};
