-- lyxal-test: assertions
-- Fonctions internes (fn::infra__*) appelées directement : valeurs canoniques, clés, aides du
-- journal, réglages effectifs, zone couvrante, plan d'un enregistrement, refus du contrat.

-- préparation: compte et zone
{
    fn::secrets_secret_create({ path: "infra/scaleway", kind: "api_key" });
    fn::infra_account_create({ key: "scw", name: "Scaleway", credentials_path: "infra/scaleway", settings: { project_id: u"0b3a6f1e-3c1d-4f2a-9a55-6f3f0a7b2c11" } });
    fn::infra_account_test_result({ account: "infra_account:scw", ok: true, zones: [{ name: "exemple.fr", status: "active" }] });
    fn::infra_zone_attach({ account: "infra_account:scw", name: "exemple.fr" });
};

-- test: fn::infra__record_value : forme canonique de chaque type
RETURN fn::infra__record_value("A", " 192.0.2.1 ").value == "192.0.2.1"
    AND fn::infra__record_value("AAAA", "2001:DB8::1").value == "2001:db8::1"
    AND fn::infra__record_value("CNAME", "Cible.Exemple.FR.").value == "cible.exemple.fr"
    AND fn::infra__record_value("MX", "10 MX.exemple.fr.").value == "10 mx.exemple.fr"
    AND fn::infra__record_value("SRV", "0 5 443 Srv.Exemple.fr").value == "0 5 443 srv.exemple.fr"
    AND fn::infra__record_value("CAA", "128 issuewild \";\"").value == "128 issuewild \";\""
    AND fn::infra__record_value("TXT", "v=spf1 -all").value == "v=spf1 -all"
    AND fn::infra__record_value("TLSA", "x").code == "CORE_VALIDATION_NOT_ALLOWED"
    AND fn::infra__record_value("CAA", "256 issue \"x\"").code == "CORE_VALIDATION_TOO_LARGE";

-- test: fn::infra__number : chiffres seulement, bornes par lyxal_core
RETURN fn::infra__number("65535", 0, 65535).value == 65535 AND fn::infra__number("-1", 0, 10).code == "CORE_VALIDATION_FORMAT"
    AND fn::infra__number("12345678901", 0, 10).code == "CORE_VALIDATION_FORMAT" AND fn::infra__number("11", 0, 10).code == "CORE_VALIDATION_TOO_LARGE";

-- test: fn::infra__record_key : stable, opaque, sans nom en clair
RETURN fn::infra__record_key("lyxal_mail", "d1", "exemple.fr", "MX") == fn::infra__record_key("lyxal_mail", "d1", "exemple.fr", "MX")
    AND fn::infra__record_key("lyxal_mail", "d1", "exemple.fr", "MX") != fn::infra__record_key("lyxal_mail", "d2", "exemple.fr", "MX")
    AND string::len(<string> record::id(fn::infra__record_key("lyxal_mail", "d1", "exemple.fr", "MX"))) == 32
    AND !string::contains(<string> fn::infra__record_key("lyxal_mail", "d1", "exemple.fr", "MX"), "exemple");

-- test: fn::infra__declared_item : défaut des réglages, type en majuscules, valeurs triées, chemins d'erreur
{
    LET $settings = fn::infra__settings();
    LET $ok = fn::infra__declared_item({ fqdn: "exemple.fr", type: "txt", values: ["b", "a", "b"], mode: "shared" }, 3, $settings);
    LET $bad = fn::infra__declared_item({ fqdn: "exemple.fr", type: "A", values: ["x"], mode: "exclusive" }, 2, $settings);
    RETURN $ok.valid AND $ok.value.type == "TXT" AND $ok.value.values == ["a", "b"] AND $ok.value.ttl == 3600
        AND $bad.errors == { "records[2].values[0]": ["CORE_VALIDATION_FORMAT"] };
};

-- test: fn::infra__settings : valeurs du seed ; fn::infra__clean : NONE en NULL, identifiants en texte
RETURN fn::infra__settings().max_deletion_percent == 30
    AND fn::infra__clean({ a: NONE, b: [NONE, infra_zone:x], c: { d: 1 } }) == { a: NULL, b: [NULL, "infra_zone:x"], c: { d: 1 } };

-- test: fn::infra__language et fn::infra__invalid : langue valide reprise, sinon celle de l'erreur
RETURN fn::infra__language({ language: "en" }) == "en" AND fn::infra__language({ language: "xx-yy" }) IS NONE AND fn::infra__language("x") IS NONE
    AND fn::infra__invalid({ language: "en" }, { a: ["CORE_VALIDATION_REQUIRED"] }).error.label == "Invalid parameters"
    AND fn::infra__invalid({}, NONE).error.details == { fields: {} };

-- test: fn::infra__actor : session système
RETURN fn::infra__actor() == "system";

-- test: fn::infra__covering_zone : zone la plus longue qui couvre le nom, aucune sinon
RETURN fn::infra__covering_zone("a.b.exemple.fr").name == "exemple.fr" AND fn::infra__covering_zone("exemple.fr").name == "exemple.fr"
    AND fn::infra__covering_zone("autre.fr") IS NONE AND fn::infra__covering_zone("fr") IS NONE;

-- test: fn::infra__contract_refusal et fn::infra__worker_refusal : session système dispensée
RETURN fn::infra__contract_refusal("manual") IS NONE AND fn::infra__contract_refusal("lyxal_mail") IS NONE
    AND fn::infra__worker_refusal({ valid: true, value: { language: "fr" } }, {}) IS NONE
    AND fn::infra__worker_refusal({ valid: false, value: {}, by_field: { limit: ["CORE_VALIDATION_TYPE"] } }, {}).error.code == "INFRA_INVALID_PARAMETERS";

-- test: fn::infra__declare_refusal : doublon, CNAME, propriétaire exclusif
{
    fn::infra_records_declare({ owner: "manual", subject: "s1", records: [{ fqdn: "exemple.fr", type: "MX", values: ["10 mx.exemple.fr"], mode: "exclusive" }] });
    LET $p = { owner: "lyxal_mail", subject: "d1" };
    RETURN fn::infra__declare_refusal($p, [{ fqdn: "a.exemple.fr", type: "A", mode: "exclusive" }, { fqdn: "a.exemple.fr", type: "A", mode: "exclusive" }]).details.fields.records == ["CORE_VALIDATION_DUPLICATE"]
        AND fn::infra__declare_refusal($p, [{ fqdn: "a.exemple.fr", type: "A", mode: "exclusive" }, { fqdn: "a.exemple.fr", type: "CNAME", mode: "exclusive" }]).code == "INFRA_RECORD_CNAME_CONFLICT"
        AND fn::infra__declare_refusal($p, [{ fqdn: "exemple.fr", type: "MX", mode: "shared" }]).code == "INFRA_RECORD_OWNED"
        AND fn::infra__declare_refusal($p, [{ fqdn: "exemple.fr", type: "TXT", mode: "shared" }]) IS NONE;
};

-- test: fn::infra__declare_write : création puis identique sans écriture
{
    LET $p = { owner: "manual", subject: "s2", tenant: NONE };
    LET $item = { fqdn: "w.exemple.fr", type: "A", values: ["192.0.2.1"], ttl: 3600, mode: "exclusive", singleton_prefix: NONE, zone: NONE };
    LET $first = fn::infra__declare_write($p, [$item]);
    LET $second = fn::infra__declare_write($p, [$item]);
    RETURN $first.outcomes[0].changed AND $first.outcomes[0].row.state == "unmanaged" AND !$second.outcomes[0].changed AND $second.removed == [];
};

-- test: fn::infra__record_plan : exclusif avec valeur humaine étrangère → conflit ; retrait → suppression de la valeur écrite seulement
{
    LET $r = { id: infra_record:x, fqdn: "exemple.fr", type: "MX", values: ["10 mx.exemple.fr"], ttl: 3600, mode: "exclusive", state: "pending", provider_ids: [], applied_values: [] };
    LET $observed = [{ provider_id: "h1", fqdn: "exemple.fr", type: "MX", value: "5 autre.exemple.net", ttl: 3600, record: NONE }];
    LET $conflict = fn::infra__record_plan($r, $observed);
    LET $releasing = fn::infra__record_plan(object::extend($r, { state: "releasing", applied_values: ["10 mx.exemple.fr"] }), [
        { provider_id: "p1", fqdn: "exemple.fr", type: "MX", value: "10 mx.exemple.fr", ttl: 3600, record: infra_record:x },
        { provider_id: "p2", fqdn: "exemple.fr", type: "MX", value: "20 change.exemple.fr", ttl: 3600, record: infra_record:x }
    ]);
    RETURN $conflict.conflict == { reason: "foreign_value", observed: ["5 autre.exemple.net"] } AND $conflict.changes == []
        AND $releasing.release AND $releasing.changes.provider_id == ["p1"];
};

-- test: fn::infra__change_sorted : ordre par la clé calculée
RETURN fn::infra__change_sorted([{ k: "b" }, { k: "a" }], |$c: object| $c.k) == [{ k: "a" }, { k: "b" }];

-- test: fn::infra__zone_compute, fn::infra__zone_counts, fn::infra__zone_view, fn::infra__zone_adopt : plan d'une zone, adoption d'un enregistrement déclaré sans zone
{
    LET $zone = (SELECT * FROM ONLY infra_zone LIMIT 1);
    LET $plan = fn::infra__zone_compute($zone);
    RETURN $plan.changes.action == ["add"] AND $plan.deletions == 0 AND !$plan.over AND string::len($plan.hash) == 64
        AND fn::infra__zone_counts($zone.id).pending == 1 AND fn::infra__zone_view($zone).claim IS NONE
        AND fn::infra__zone_adopt($zone) == 1;
};

-- test: fn::infra__plan_states : enregistrement satisfait passe written
{
    LET $zone = (SELECT * FROM ONLY infra_zone LIMIT 1);
    LET $key = fn::infra__record_key("manual", "s1", "exemple.fr", "MX");
    LET $states = fn::infra__plan_states($zone, [{ record: $key, conflict: NONE, changes: [], drift: [], adopt: [], release: false }]);
    RETURN $states == { conflicts: 0, satisfied: 1, pending: 0, released: 0 } AND (SELECT VALUE state FROM ONLY $key) == "written";
};

-- test: fn::infra__apply_record : échec définitif noté
{
    LET $key = fn::infra__record_key("manual", "s1", "exemple.fr", "MX");
    LET $row = (SELECT * FROM ONLY $key);
    LET $done = fn::infra__apply_record($row, [{ ok: false, retryable: false, code: "INFRA_PROVIDER_QUOTA", action: "add", value: "10 mx.exemple.fr" }]);
    RETURN $done.state == "failed" AND (SELECT VALUE error.code FROM ONLY $key) == "INFRA_PROVIDER_QUOTA";
};

-- test: fn::infra__claim_check : zone inconnue, jeton absent
RETURN fn::infra__claim_check(infra_zone:inconnue, "x").code == "INFRA_ZONE_NOT_FOUND"
    AND fn::infra__claim_check((SELECT VALUE id FROM ONLY infra_zone LIMIT 1), "x").code == "INFRA_ZONE_CLAIM_LOST";

-- test: fn::infra__verify_delay : 30 s, 1, 2, 5, 10 min, puis 30 min
RETURN [1, 2, 3, 4, 5, 6, 40].map(|$n| fn::infra__verify_delay($n)) == [30s, 1m, 2m, 5m, 10m, 30m, 30m];

-- test: fn::infra__observed_row : type en majuscules, chemin d'erreur
RETURN fn::infra__observed_row({ provider_id: "a", fqdn: "*.exemple.fr", type: "cname", value: "x.exemple.fr", ttl: 60 }, 0).value.type == "CNAME"
    AND fn::infra__observed_row({ provider_id: "a", fqdn: "exemple.fr", type: "A", value: "x", ttl: -1 }, 4).errors == { "records[4].ttl": ["CORE_VALIDATION_TOO_SMALL"] };

-- test: fn::infra__account_fields, fn::infra__account_view, fn::infra__account_secret_refusal
RETURN fn::infra__account_fields(true).key.required == true AND fn::infra__account_fields(false).account.required == true
    AND fn::infra__account_view((SELECT * FROM ONLY infra_account:scw)).credentials_path == "infra/scaleway"
    AND fn::infra__account_secret_refusal("infra/scaleway") IS NONE
    AND fn::infra__account_secret_refusal("infra/absent") == "INFRA_ACCOUNT_SECRET_INVALID"
    AND fn::infra__account_secret_refusal(42) == "INFRA_ACCOUNT_SECRET_INVALID";

-- test: fn::infra__record_view et fn::infra__reconcile_enqueue (aucune zone : rien en file)
RETURN fn::infra__record_view((SELECT * FROM ONLY fn::infra__record_key("manual", "s1", "exemple.fr", "MX"))).provider_ids IS NONE
    AND fn::infra__reconcile_enqueue([]) == { queued: 0, codes: [] };

-- test: fn::infra__change_write, fn::infra__change_content, fn::infra__change_view : entrée chaînée relue identique
{
    LET $entry = fn::infra__change_write({ zone: NONE, record: NONE, action: "mode", after: { mode: "managed", vide: NONE } });
    LET $row = (SELECT * FROM ONLY $entry.id);
    RETURN fn::security_audit_entry(fn::infra__change_content($row), $row.previous_hash).entry_hash == $row.entry_hash
        AND fn::infra__change_view($row).after == { mode: "managed", vide: NULL } AND $row.actor == "system";
};
