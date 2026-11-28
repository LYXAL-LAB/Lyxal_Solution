-- lyxal-test: assertions
-- Zones : rattachement (zone non visible, emboîtée, déjà rattachée, clé opaque), modification
-- (mode, organisations acceptées, adoption des enregistrements déjà déclarés), lecture, photo,
-- demande de passe, approbation d'un plan bloqué, détachement refusé puis forget ; journal.
--
-- identité plateforme: { "id": "auth_session:plateforme", "pv": 1, "permissions": ["infra.read", "infra.manage", "secrets.installation.manage"] }
-- identité lecteur: { "id": "auth_session:lecteur", "pv": 1, "permissions": ["infra.read"] }

-- préparation: identités, organisations, secret, compte et zones visibles
{
    CREATE auth_organization:alpha CONTENT { slug: "alpha", name: "Alpha BTP" };
    CREATE auth_organization:beta CONTENT { slug: "beta", name: "Beta Bois" };
    CREATE auth_identity:plateforme CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "plateforme@lyxal.test" } };
    CREATE auth_session:plateforme CONTENT { identity: auth_identity:plateforme, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_identity:lecteur CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "lecteur@lyxal.test" } };
    CREATE auth_session:lecteur CONTENT { identity: auth_identity:lecteur, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    fn::secrets_secret_create({ path: "infra/scaleway", kind: "api_key" });
    fn::infra_account_create({ key: "scw", name: "Scaleway", credentials_path: "infra/scaleway", settings: { project_id: u"0b3a6f1e-3c1d-4f2a-9a55-6f3f0a7b2c11" } });
    fn::infra_account_test_result({ account: "infra_account:scw", ok: true, zones: [
        { name: "exemple.fr", status: "active" }, { name: "sous.exemple.fr", status: "active" },
        { name: "lyxal.test", status: "active" }, { name: "client.test", status: "active" }
    ] });
    -- Enregistrements déjà déclarés, avant tout rattachement : sans zone (unmanaged)
    fn::infra_records_declare({ owner: "lyxal_mail", subject: "mail_domain:alpha", tenant: "auth_organization:alpha", records: [
        { fqdn: "client.test", type: "MX", values: ["10 mx.lyxal.test"], mode: "exclusive" }
    ] });
    fn::infra_records_declare({ owner: "manual", subject: "hote", records: [
        { fqdn: "www.lyxal.test", type: "A", values: ["192.0.2.10"], mode: "exclusive" }
    ] });
    DEFINE TABLE OVERWRITE passe SCHEMALESS PERMISSIONS FULL;
};

-- test: rattachement en observation, clé opaque (UUID v7 sans nom), enregistrements couverts adoptés, journal
-- en tant que: plateforme
{
    LET $r = fn::infra_zone_attach({ account: "infra_account:scw", name: "Lyxal.Test." });
    UPSERT passe:ids SET lyxal = <string> $r.data.id;
    RETURN $r.ok AND $r.data.mode == "observe" AND $r.data.name == "lyxal.test" AND $r.data.state == "ok" AND $r.data.adopted == 1
        AND string::len(<string> record::id($r.data.id)) == 32 AND !string::contains(<string> $r.data.id, "lyxal")
        AND (SELECT VALUE state FROM ONLY infra_record WHERE fqdn = "www.lyxal.test" LIMIT 1) == "pending"
        AND (SELECT VALUE action FROM infra_change WHERE zone = $r.data.id) == ["attach"];
};

-- test: zone non visible, déjà rattachée, emboîtée ou contenant une zone rattachée ; compte inconnu ; paramètres
-- en tant que: plateforme
{
    LET $parent_zone = fn::infra_zone_attach({ account: "infra_account:scw", name: "exemple.fr" });
    RETURN $parent_zone.ok
        AND fn::infra_zone_attach({ account: "infra_account:scw", name: "inconnu.fr" }).error.code == "INFRA_ZONE_NOT_VISIBLE"
        AND fn::infra_zone_attach({ account: "infra_account:scw", name: "exemple.fr" }).error.code == "INFRA_ZONE_EXISTS"
        AND fn::infra_zone_attach({ account: "infra_account:scw", name: "sous.exemple.fr" }).error.code == "INFRA_ZONE_OVERLAP"
        AND fn::infra_zone_attach({ account: "infra_account:inconnu", name: "client.test" }).error.code == "INFRA_ACCOUNT_NOT_FOUND"
        AND fn::infra_zone_attach({ account: "infra_account:scw", name: "_dmarc.client.test" }).error.code == "INFRA_INVALID_PARAMETERS"
        AND fn::infra_zone_attach({ account: "infra_account:scw", name: "client.test", mode: "autre" }).error.code == "INFRA_INVALID_PARAMETERS"
        AND fn::infra_zone_detach({ zone: <string> $parent_zone.data.id }).ok;
};

-- test: zone d'une organisation : ses enregistrements déjà déclarés adoptés seulement si elle est acceptée
-- en tant que: plateforme
{
    LET $z = fn::infra_zone_attach({ account: "infra_account:scw", name: "client.test" });
    LET $previous = (SELECT VALUE state FROM ONLY infra_record WHERE fqdn = "client.test" LIMIT 1);
    LET $u = fn::infra_zone_update({ zone: <string> $z.data.id, tenants: ["auth_organization:alpha", "auth_organization:alpha"] });
    UPSERT passe:ids SET client = <string> $z.data.id;
    RETURN $z.data.adopted == 0 AND $previous == "unmanaged" AND $u.data.adopted == 1 AND $u.data.tenants == [auth_organization:alpha]
        AND (SELECT VALUE state FROM ONLY infra_record WHERE fqdn = "client.test" LIMIT 1) == "pending";
};

-- test: changement de mode noté au journal, demande de passe ; zone inconnue
-- en tant que: plateforme
{
    LET $zone = <string> (SELECT VALUE lyxal FROM ONLY passe:ids);
    LET $m = fn::infra_zone_update({ zone: $zone, mode: "managed" });
    LET $same = fn::infra_zone_update({ zone: $zone, mode: "managed" });
    LET $req = fn::infra_zone_reconcile_request({ zone: $zone });
    RETURN $m.data.mode == "managed" AND $m.data.reconcile_requested_at IS NOT NONE AND $req.ok AND $req.data.requested_at IS NOT NONE AND $req.data.queued == 0
        AND (SELECT VALUE action FROM infra_change WHERE zone = <record> $zone ORDER BY rank) == ["attach", "mode"]
        AND (SELECT VALUE after FROM ONLY infra_change WHERE action = "mode" LIMIT 1) == { mode: "managed" }
        AND fn::infra_zone_update({ zone: "infra_zone:inconnue", mode: "observe" }).error.code == "INFRA_ZONE_NOT_FOUND"
        AND fn::infra_zone_reconcile_request({ zone: "infra_zone:inconnue" }).error.code == "INFRA_ZONE_NOT_FOUND"
        AND fn::infra_zone_get({ zone: "infra_zone:inconnue" }).error.code == "INFRA_ZONE_NOT_FOUND";
};

-- test: la session système met la passe en file (unique par zone pendant une minute)
{
    LET $zone = <string> (SELECT VALUE lyxal FROM ONLY passe:ids);
    LET $first = fn::infra_zone_reconcile_request({ zone: $zone });
    LET $second = fn::infra_zone_reconcile_request({ zone: $zone });
    RETURN $first.data.queued == 1 AND $second.data.queued == 1
        AND count(SELECT id FROM scheduler_run WHERE task = scheduler_task:⟨infra.zone_reconcile⟩ AND args.zone = $zone) == 1;
};

-- test: un lecteur lit zones, compteurs et photo, ne change rien
-- en tant que: lecteur
{
    LET $zone = <string> (SELECT VALUE lyxal FROM ONLY passe:ids);
    LET $get = fn::infra_zone_get({ zone: $zone });
    LET $list = fn::infra_zone_list({});
    RETURN $get.ok AND $get.data.counts.pending == 1 AND $get.data.observed == 0 AND $get.data.claim IS NONE
        AND $list.data.items.name == ["client.test", "lyxal.test"]
        AND fn::infra_zone_list({ state: "blocked" }).data.items == []
        AND fn::infra_zone_list({ account: "infra_account:scw" }).data.items.name == ["client.test", "lyxal.test"]
        AND fn::infra_zone_records({ zone: $zone }).data == { items: [], total: 0 }
        AND fn::infra_zone_update({ zone: $zone, mode: "observe" }).error.code == "INFRA_PERMISSION_DENIED"
        AND fn::infra_zone_attach({ account: "infra_account:scw", name: "exemple.fr" }).error.code == "INFRA_PERMISSION_DENIED"
        AND fn::infra_zone_detach({ zone: $zone }).error.code == "INFRA_PERMISSION_DENIED"
        AND fn::infra_zone_reconcile_request({ zone: $zone }).error.code == "INFRA_PERMISSION_DENIED"
        AND fn::infra_zone_plan_approve({ zone: $zone, plan_hash: string::repeat("a", 64) }).error.code == "INFRA_PERMISSION_DENIED";
};

-- test: photo de la zone, filtrée par propriétaire (Lyxal ou humain)
{
    LET $zone = <record> (SELECT VALUE lyxal FROM ONLY passe:ids);
    LET $mine = (SELECT VALUE id FROM ONLY infra_record WHERE fqdn = "www.lyxal.test" LIMIT 1);
    CREATE infra_zone_record CONTENT { zone: $zone, provider_id: "h1", fqdn: "lyxal.test", type: "TXT", value: "v=spf1 -all", ttl: 3600 };
    CREATE infra_zone_record CONTENT { zone: $zone, provider_id: "l1", fqdn: "www.lyxal.test", type: "A", value: "192.0.2.10", ttl: 3600, comment: "lyxal:x", record: $mine };
    LET $all = fn::infra_zone_records({ zone: <string> $zone });
    LET $lyxal = fn::infra_zone_records({ zone: <string> $zone, owner: "lyxal" });
    LET $human = fn::infra_zone_records({ zone: <string> $zone, owner: "human", limit: 1 });
    DELETE infra_zone_record;
    RETURN $all.data.total == 2 AND $all.data.items.provider_id == ["h1", "l1"] AND $lyxal.data.items.provider_id == ["l1"]
        AND $human.data.items.provider_id == ["h1"] AND $human.data.total == 1
        AND fn::infra_zone_records({ zone: "infra_zone:inconnue" }).error.code == "INFRA_ZONE_NOT_FOUND";
};

-- test: approbation : zone non bloquée ou empreinte différente refusées, plan bloqué approuvé une fois
-- en tant que: plateforme
{
    LET $zone = <string> (SELECT VALUE lyxal FROM ONLY passe:ids);
    LET $hash = string::repeat("b", 64);
    LET $not_blocked = fn::infra_zone_plan_approve({ zone: $zone, plan_hash: $hash });
    UPDATE <record> $zone SET state = "blocked", last_plan = { hash: $hash, at: time::now(), changes: [], conflicts: [], deletions: 12, owned: 20 };
    LET $wrong = fn::infra_zone_plan_approve({ zone: $zone, plan_hash: string::repeat("c", 64) });
    LET $approved = fn::infra_zone_plan_approve({ zone: $zone, plan_hash: string::uppercase($hash) });
    LET $again = fn::infra_zone_plan_approve({ zone: $zone, plan_hash: $hash });
    RETURN $not_blocked.error.code == "INFRA_ZONE_PLAN_STALE" AND $wrong.error.code == "INFRA_ZONE_PLAN_STALE"
        AND $approved.data.state == "ok" AND $approved.data.approved_plan_hash == $hash
        AND $again.error.code == "INFRA_ZONE_PLAN_STALE"
        AND (SELECT VALUE after FROM ONLY infra_change WHERE action = "approve" LIMIT 1) == { plan_hash: $hash, deletions: 12 }
        AND fn::infra_zone_plan_approve({ zone: $zone, plan_hash: "court" }).error.code == "INFRA_INVALID_PARAMETERS"
        AND fn::infra_zone_plan_approve({ zone: "infra_zone:inconnue", plan_hash: $hash }).error.code == "INFRA_ZONE_NOT_FOUND";
};

-- test: zone bloquée : l'événement infra.zone.blocked est publié une fois, sans nom de domaine
{
    LET $zone = <record> (SELECT VALUE client FROM ONLY passe:ids);
    UPDATE $zone SET state = "blocked", last_plan = { hash: string::repeat("d", 64), at: time::now(), changes: [], conflicts: [], deletions: 15, owned: 40 };
    UPDATE $zone SET state = "blocked";
    LET $events = (SELECT event_type, payload FROM event_outbox WHERE event_type = "infra.zone.blocked" AND payload.zone = <string> $zone);
    RETURN array::len($events) == 1 AND $events[0].payload == { zone: <string> $zone, state: "blocked", deletions: 15 }
        AND !string::contains(<string> $events, "client.test");
};

-- test: détachement refusé tant que Lyxal a écrit dans la zone, puis forget : enregistrements oubliés, photo supprimée, noté
-- en tant que: plateforme
{
    LET $zone = <string> (SELECT VALUE client FROM ONLY passe:ids);
    UPDATE infra_record SET provider_ids = [{ id: "p1", value: "10 mx.lyxal.test" }], applied_values = ["10 mx.lyxal.test"], state = "written" WHERE fqdn = "client.test";
    LET $refused = fn::infra_zone_detach({ zone: $zone });
    LET $forgotten = fn::infra_zone_detach({ zone: $zone, forget: true });
    LET $record = (SELECT * FROM ONLY infra_record WHERE fqdn = "client.test" LIMIT 1);
    RETURN $refused.error.code == "INFRA_ZONE_HAS_RECORDS" AND $refused.error.details.records == 1
        AND $forgotten.data == { detached: <record> $zone, records: 1, kept_at_provider: 1 }
        AND !record::exists(<record> $zone) AND $record.zone IS NONE AND $record.state == "unmanaged" AND $record.provider_ids == []
        AND (SELECT VALUE after FROM ONLY infra_change WHERE action = "detach" AND zone = <record> $zone LIMIT 1) == { forget: true, records: 1, kept_at_provider: 1 }
        AND fn::infra_zone_detach({ zone: $zone }).error.code == "INFRA_ZONE_NOT_FOUND";
};

-- test: détachement : un enregistrement retiré (released, ou releasing oublié) reste retiré, sans zone ; rattachement suivant : seuls les enregistrements voulus actifs sont repris
-- en tant que: plateforme
{
    LET $first = fn::infra_zone_attach({ account: "infra_account:scw", name: "client.test", tenants: ["auth_organization:alpha"] });
    fn::infra_records_declare({ owner: "manual", subject: "ancien", records: [{ fqdn: "ancien.client.test", type: "TXT", values: ["retire"], mode: "shared" }] });
    fn::infra_records_release({ owner: "manual", subject: "ancien" });
    fn::infra_records_declare({ owner: "manual", subject: "partant", records: [{ fqdn: "partant.client.test", type: "A", values: ["192.0.2.20"], mode: "exclusive" }] });
    UPDATE infra_record SET state = "releasing", provider_ids = [{ id: "p2", value: "192.0.2.20" }], applied_values = ["192.0.2.20"] WHERE subject = "partant";
    LET $detached = fn::infra_zone_detach({ zone: <string> $first.data.id, forget: true });
    LET $after_detach = (SELECT VALUE [subject, state, zone, provider_ids] FROM infra_record WHERE fqdn CONTAINS "client.test" ORDER BY subject);
    LET $second = fn::infra_zone_attach({ account: "infra_account:scw", name: "client.test", tenants: ["auth_organization:alpha"] });
    LET $after_attach = (SELECT VALUE [subject, state, zone, provider_ids] FROM infra_record WHERE fqdn CONTAINS "client.test" ORDER BY subject);
    LET $final = fn::infra_zone_detach({ zone: <string> $second.data.id });
    RETURN $first.data.adopted == 1 AND $detached.data == { detached: $first.data.id, records: 3, kept_at_provider: 1 }
        AND $after_detach == [["ancien", "released", NONE, []], ["mail_domain:alpha", "unmanaged", NONE, []], ["partant", "released", NONE, []]]
        AND $second.data.adopted == 1
        AND $after_attach == [["ancien", "released", NONE, []], ["mail_domain:alpha", "pending", $second.data.id, []], ["partant", "released", NONE, []]]
        AND $final.ok;
};

-- test: journal lu et vérifié (chaîne intacte)
-- en tant que: lecteur
{
    LET $list = fn::infra_change_list({});
    LET $verify = fn::infra_change_verify({});
    RETURN $list.data.total >= 5 AND $list.data.items[0].action == "detach" AND $verify.data.valid AND $verify.data.head_matches AND $verify.data.complete
        AND $verify.data.checked == $list.data.total;
};

-- préparation: table des zones fermée à l'écriture
{
    DEFINE TABLE OVERWRITE infra_zone TYPE NORMAL SCHEMAFULL PERMISSIONS FOR select FULL FOR create, update, delete NONE;
};

-- test: zones : rattachement et modification refusés par la table, erreur explicite
-- en tant que: plateforme
{
    LET $zone = <string> (SELECT VALUE lyxal FROM ONLY passe:ids);
    RETURN fn::infra_zone_attach({ account: "infra_account:scw", name: "exemple.fr" }).error.code == "INFRA_WRITE_FORBIDDEN"
        AND fn::infra_zone_update({ zone: $zone, mode: "observe" }).error.code == "INFRA_WRITE_FORBIDDEN"
        AND fn::infra_zone_reconcile_request({ zone: $zone }).error.code == "INFRA_WRITE_FORBIDDEN";
};
