-- lyxal-test: assertions
-- Contrat public des modules : déclaration (forme canonique par type, remplacement de
-- l'ensemble, déclaration identique sans écriture, liste vide, propriétaire concurrent, CNAME,
-- 50 au plus, organisation refusée, nom non couvert → unmanaged, passe mise en file une fois),
-- retrait, état et sujets ; droits du contrat (module, manual, refus) ; écriture filtrée.
--
-- identité courrier: { "id": "auth_session:courrier", "pv": 1, "permissions": ["infra.records.declare"] }
-- identité plateforme: { "id": "auth_session:plateforme", "pv": 1, "permissions": ["infra.read", "infra.manage"] }
-- identité membre: { "id": "auth_session:membre", "pv": 1, "permissions": [] }

-- préparation: organisations, sessions, compte et zones rattachées
{
    CREATE auth_organization:alpha CONTENT { slug: "alpha", name: "Alpha BTP" };
    CREATE auth_organization:beta CONTENT { slug: "beta", name: "Beta Bois" };
    CREATE auth_application:courrier CONTENT { client_id: "lyxal-test-courrier", name: "Courrier", type: "machine", redirect_uris: [], state: "active", permissions_version: 1 };
    CREATE auth_session:courrier CONTENT { application: auth_application:courrier, kind: "service", idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_identity:plateforme CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "plateforme@lyxal.test" } };
    CREATE auth_session:plateforme CONTENT { identity: auth_identity:plateforme, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_identity:membre CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "membre@lyxal.test" } };
    RELATE auth_identity:membre->auth_member_of->auth_organization:alpha;
    CREATE auth_session:membre CONTENT { identity: auth_identity:membre, organization: auth_organization:alpha, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    fn::secrets_secret_create({ path: "infra/scaleway", kind: "api_key" });
    fn::infra_account_create({ key: "scw", name: "Scaleway", credentials_path: "infra/scaleway", settings: { project_id: u"0b3a6f1e-3c1d-4f2a-9a55-6f3f0a7b2c11" } });
    fn::infra_account_test_result({ account: "infra_account:scw", ok: true, zones: [{ name: "exemple.fr", status: "active" }, { name: "alpha.test", status: "active" }] });
    LET $installation = fn::infra_zone_attach({ account: "infra_account:scw", name: "exemple.fr", mode: "managed" }).data.id;
    LET $alpha = fn::infra_zone_attach({ account: "infra_account:scw", name: "alpha.test", tenants: ["auth_organization:alpha"] }).data.id;
    DEFINE TABLE OVERWRITE passe SCHEMALESS PERMISSIONS FULL;
    CREATE passe:ids CONTENT { installation: <string> $installation, alpha: <string> $alpha };
};

-- test: déclaration du courrier d'un domaine : forme canonique, valeurs triées, zone couverte, passe en file
-- en tant que: courrier
{
    LET $r = fn::infra_records_declare({ owner: "lyxal_mail", subject: "mail_domain:d1", records: [
        { fqdn: "Exemple.FR.", type: "mx", values: ["20  mx2.exemple.fr"], mode: "exclusive" },
        { fqdn: "exemple.fr", type: "MX", values: ["20 MX2.exemple.fr.", "10 mx1.exemple.fr"], mode: "exclusive", ttl: 600 },
        { fqdn: "exemple.fr", type: "TXT", values: ["v=spf1 a:mx1.exemple.fr -all"], mode: "shared", singleton_prefix: "v=spf1" },
        { fqdn: "_dmarc.exemple.fr", type: "TXT", values: ["v=DMARC1; p=none"], mode: "shared", singleton_prefix: "v=DMARC1" },
        { fqdn: "lyx202611r._domainkey.exemple.fr", type: "TXT", values: ["v=DKIM1; k=rsa; p=MIIB"], mode: "exclusive" }
    ] });
    RETURN $r.error.code == "INFRA_INVALID_PARAMETERS" AND $r.error.details.fields == { "records[0].values[0]": ["CORE_VALIDATION_FORMAT"] };
};

-- test: même déclaration corrigée : acceptée, états pending, organisation de l'installation
-- en tant que: courrier
{
    LET $r = fn::infra_records_declare({ owner: "lyxal_mail", subject: "mail_domain:d1", records: [
        { fqdn: "Exemple.FR.", type: "mx", values: ["20 MX2.exemple.fr.", "10 mx1.exemple.fr", "10 mx1.exemple.fr"], mode: "exclusive", ttl: 600 },
        { fqdn: "exemple.fr", type: "TXT", values: ["v=spf1 a:mx1.exemple.fr -all"], mode: "shared", singleton_prefix: "v=spf1" },
        { fqdn: "_dmarc.exemple.fr", type: "TXT", values: ["v=DMARC1; p=none"], mode: "shared", singleton_prefix: "v=DMARC1" },
        { fqdn: "lyx202611r._domainkey.exemple.fr", type: "TXT", values: ["v=DKIM1; k=rsa; p=MIIB"], mode: "exclusive" }
    ] });
    LET $mx = (SELECT * FROM ONLY infra_record WHERE fqdn = "exemple.fr" AND type = "MX" LIMIT 1);
    RETURN $r.ok AND $r.data.changed AND array::len($r.data.items) == 4 AND $r.data.items.state == ["pending", "pending", "pending", "pending"]
        AND $r.data.items[0].managed AND $r.data.queued == 0
        AND $mx.values == ["10 mx1.exemple.fr", "20 mx2.exemple.fr"] AND $mx.ttl == 600 AND $mx.zone == <record> (SELECT VALUE installation FROM ONLY passe:ids)
        AND (SELECT VALUE ttl FROM ONLY infra_record WHERE fqdn = "_dmarc.exemple.fr" LIMIT 1) == 3600
        AND string::len(<string> record::id($mx.id)) == 32 AND $mx.id == $r.data.items[0].record;
};

-- test: déclaration identique : rien n'est écrit (changed faux, dates inchangées)
-- en tant que: courrier
{
    LET $previous = (SELECT VALUE updated_at FROM infra_record WHERE owner = "lyxal_mail" ORDER BY id);
    LET $r = fn::infra_records_declare({ owner: "lyxal_mail", subject: "mail_domain:d1", records: [
        { fqdn: "exemple.fr", type: "MX", values: ["10 mx1.exemple.fr", "20 mx2.exemple.fr"], mode: "exclusive", ttl: 600 },
        { fqdn: "exemple.fr", type: "TXT", values: ["v=spf1 a:mx1.exemple.fr -all"], mode: "shared", singleton_prefix: "v=spf1" },
        { fqdn: "_dmarc.exemple.fr", type: "TXT", values: ["v=DMARC1; p=none"], mode: "shared", singleton_prefix: "v=DMARC1" },
        { fqdn: "lyx202611r._domainkey.exemple.fr", type: "TXT", values: ["v=DKIM1; k=rsa; p=MIIB"], mode: "exclusive" }
    ] });
    RETURN $r.ok AND $r.data.changed == false AND (SELECT VALUE updated_at FROM infra_record WHERE owner = "lyxal_mail" ORDER BY id) == $previous;
};

-- test: remplacement de l'ensemble : une valeur changée, un enregistrement absent retiré (jamais écrit : released)
-- en tant que: courrier
{
    LET $r = fn::infra_records_declare({ owner: "lyxal_mail", subject: "mail_domain:d1", records: [
        { fqdn: "exemple.fr", type: "MX", values: ["10 mx1.exemple.fr"], mode: "exclusive", ttl: 600 },
        { fqdn: "exemple.fr", type: "TXT", values: ["v=spf1 a:mx1.exemple.fr -all"], mode: "shared", singleton_prefix: "v=spf1" },
        { fqdn: "_dmarc.exemple.fr", type: "TXT", values: ["v=DMARC1; p=quarantine"], mode: "shared", singleton_prefix: "v=DMARC1" }
    ] });
    RETURN $r.data.changed AND array::len($r.data.items) == 3
        AND (SELECT VALUE values FROM ONLY infra_record WHERE fqdn = "exemple.fr" AND type = "MX" LIMIT 1) == ["10 mx1.exemple.fr"]
        AND (SELECT VALUE state FROM ONLY infra_record WHERE fqdn = "lyx202611r._domainkey.exemple.fr" LIMIT 1) == "released";
};

-- test: un enregistrement écrit chez l'hébergeur qui disparaît de la déclaration passe en releasing
-- en tant que: courrier
{
    UPDATE infra_record SET state = "written", provider_ids = [{ id: "p-dmarc", value: "v=DMARC1; p=quarantine" }], applied_values = ["v=DMARC1; p=quarantine"] WHERE fqdn = "_dmarc.exemple.fr";
    LET $r = fn::infra_records_declare({ owner: "lyxal_mail", subject: "mail_domain:d1", records: [
        { fqdn: "exemple.fr", type: "MX", values: ["10 mx1.exemple.fr"], mode: "exclusive", ttl: 600 },
        { fqdn: "exemple.fr", type: "TXT", values: ["v=spf1 a:mx1.exemple.fr -all"], mode: "shared", singleton_prefix: "v=spf1" }
    ] });
    RETURN $r.data.changed AND (SELECT VALUE state FROM ONLY infra_record WHERE fqdn = "_dmarc.exemple.fr" LIMIT 1) == "releasing";
};

-- test: la session système met en file une seule passe par zone pour une déclaration
{
    LET $r = fn::infra_records_declare({ owner: "lyxal_mail", subject: "mail_domain:d2", records: [
        { fqdn: "www.exemple.fr", type: "A", values: ["192.0.2.1", "192.0.2.2"], mode: "exclusive" },
        { fqdn: "www.exemple.fr", type: "AAAA", values: ["2001:DB8::1"], mode: "exclusive" }
    ] });
    LET $again = fn::infra_records_declare({ owner: "lyxal_mail", subject: "mail_domain:d2", records: [
        { fqdn: "www.exemple.fr", type: "A", values: ["192.0.2.1"], mode: "exclusive" }
    ] });
    RETURN $r.data.queued == 1 AND $again.data.queued == 1
        AND (SELECT VALUE values FROM ONLY infra_record WHERE fqdn = "www.exemple.fr" AND type = "AAAA" LIMIT 1) == ["2001:db8::1"]
        AND count(SELECT id FROM scheduler_run WHERE task = scheduler_task:⟨infra.zone_reconcile⟩ AND args.zone = (SELECT VALUE installation FROM ONLY passe:ids)) == 1;
};

-- test: forme canonique et refus de chaque type (SRV, CAA, CNAME, TXT, A, MX)
{
    LET $ok = fn::infra_records_declare({ owner: "manual", subject: "types", records: [
        { fqdn: "_sip._tcp.exemple.fr", type: "SRV", values: ["10 60 5060 SIP.exemple.fr."], mode: "exclusive" },
        { fqdn: "exemple.fr", type: "CAA", values: ["0 issue \"letsencrypt.org\""], mode: "shared" },
        { fqdn: "docs.exemple.fr", type: "CNAME", values: ["Pages.Example.NET."], mode: "exclusive" }
    ] });
    LET $bad = |$type: string, $value: string, $mode: string| fn::infra_records_declare({ owner: "manual", subject: "mauvais", records: [{ fqdn: "x.exemple.fr", type: $type, values: [$value], mode: $mode }] }).error.details.fields["records[0].values[0]"][0];
    RETURN $ok.ok AND (SELECT VALUE values FROM infra_record WHERE subject = "types" ORDER BY fqdn) == [["10 60 5060 sip.exemple.fr"], ["pages.example.net"], ["0 issue \"letsencrypt.org\""]]
        AND ($bad("A", "192.0.2.300", "exclusive")) == "CORE_VALIDATION_FORMAT"
        AND ($bad("AAAA", "192.0.2.1", "exclusive")) == "CORE_VALIDATION_FORMAT"
        AND ($bad("MX", "70000 mx.exemple.fr", "exclusive")) == "CORE_VALIDATION_TOO_LARGE"
        AND ($bad("MX", "dix mx.exemple.fr", "exclusive")) == "CORE_VALIDATION_FORMAT"
        AND ($bad("MX", "10 _mx.exemple.fr", "exclusive")) == "CORE_VALIDATION_NOT_ALLOWED"
        AND ($bad("SRV", "10 60 mx.exemple.fr", "exclusive")) == "CORE_VALIDATION_FORMAT"
        AND ($bad("CAA", "0 autre \"x\"", "shared")) == "CORE_VALIDATION_NOT_ALLOWED"
        AND ($bad("CAA", "0 issue x", "shared")) == "CORE_VALIDATION_FORMAT"
        AND ($bad("CAA", "0 issue \"a\"b\"", "shared")) == "CORE_VALIDATION_FORMAT"
        AND ($bad("TXT", "ligne\nnouvelle", "shared")) == "CORE_VALIDATION_NOT_ALLOWED"
        AND ($bad("TXT", "é", "shared")) == "CORE_VALIDATION_FORMAT"
        AND fn::infra_records_declare({ owner: "manual", subject: "mauvais", records: [{ fqdn: "x.exemple.fr", type: "TXT", values: [string::repeat("a", 4097)], mode: "shared" }] }).error.details.fields == { "records[0].values": ["CORE_VALIDATION_TOO_LONG"] }
        AND ($bad("CNAME", "pas un nom", "exclusive")) == "CORE_VALIDATION_FORMAT";
};

-- test: règles des types : CNAME exclusif à une valeur, préfixe unique d'un TXT partagé, doublons, ttl, champs
{
    LET $declare = |$records: array| fn::infra_records_declare({ owner: "manual", subject: "regles", records: $records });
    RETURN ($declare([{ fqdn: "c.exemple.fr", type: "CNAME", values: ["a.exemple.fr", "b.exemple.fr"], mode: "exclusive" }])).error.details.fields == { "records[0]": ["CORE_VALIDATION_NOT_ALLOWED"] }
        AND ($declare([{ fqdn: "c.exemple.fr", type: "CNAME", values: ["a.exemple.fr"], mode: "shared" }])).error.code == "INFRA_INVALID_PARAMETERS"
        AND ($declare([{ fqdn: "t.exemple.fr", type: "TXT", values: ["v=spf1 -all"], mode: "exclusive", singleton_prefix: "v=spf1" }])).error.details.fields == { "records[0].singleton_prefix": ["CORE_VALIDATION_NOT_ALLOWED"] }
        AND ($declare([{ fqdn: "t.exemple.fr", type: "TXT", values: ["autre"], mode: "shared", singleton_prefix: "v=spf1" }])).error.code == "INFRA_INVALID_PARAMETERS"
        AND ($declare([{ fqdn: "t.exemple.fr", type: "TXT", values: ["a"], mode: "shared" }, { fqdn: "T.exemple.fr", type: "txt", values: ["b"], mode: "shared" }])).error.details.fields == { records: ["CORE_VALIDATION_DUPLICATE"] }
        AND ($declare([{ fqdn: "t.exemple.fr", type: "TXT", values: ["a"], mode: "shared", ttl: 30 }])).error.details.fields == { "records[0].ttl": ["CORE_VALIDATION_TOO_SMALL"] }
        AND ($declare([{ fqdn: "t.exemple.fr", type: "PTR", values: ["a"], mode: "shared" }])).error.code == "INFRA_INVALID_PARAMETERS"
        AND ($declare([{ fqdn: "t.exemple.fr", type: "TXT", values: [], mode: "shared" }])).error.code == "INFRA_INVALID_PARAMETERS"
        AND ($declare([{ fqdn: "*.exemple.fr", type: "A", values: ["192.0.2.1"], mode: "exclusive" }])).error.code == "INFRA_INVALID_PARAMETERS"
        AND ($declare([{ fqdn: "t.exemple.fr", type: "TXT", values: ["a"], mode: "shared", inconnu: 1 }])).error.code == "INFRA_INVALID_PARAMETERS"
        AND fn::infra_records_declare({ owner: "Pas Valide", subject: "s", records: [] }).error.code == "INFRA_INVALID_PARAMETERS"
        AND fn::infra_records_declare({ owner: "manual", subject: "s", records: [], inconnu: true }).error.code == "INFRA_INVALID_PARAMETERS"
        AND fn::infra_records_declare({ owner: "manual", subject: "s" }).error.code == "INFRA_INVALID_PARAMETERS";
};

-- test: plus de 50 enregistrements : INFRA_RECORD_LIMIT
RETURN fn::infra_records_declare({ owner: "manual", subject: "trop", records: array::map(<array>(0..51), |$i| { fqdn: "h" + <string> $i + ".exemple.fr", type: "A", values: ["192.0.2.1"], mode: "exclusive" }) }).error.code == "INFRA_RECORD_LIMIT";

-- test: (nom, type) exclusif d'un autre propriétaire : INFRA_RECORD_OWNED ; partagé des deux côtés : accepté
{
    LET $owned = fn::infra_records_declare({ owner: "manual", subject: "concurrent", records: [{ fqdn: "exemple.fr", type: "MX", values: ["5 autre.exemple.fr"], mode: "exclusive" }] });
    LET $shared_vs_exclusive = fn::infra_records_declare({ owner: "manual", subject: "concurrent", records: [{ fqdn: "exemple.fr", type: "MX", values: ["5 autre.exemple.fr"], mode: "shared" }] });
    LET $shared = fn::infra_records_declare({ owner: "manual", subject: "concurrent", records: [{ fqdn: "exemple.fr", type: "TXT", values: ["google-site-verification=abc"], mode: "shared" }] });
    RETURN $owned.error.code == "INFRA_RECORD_OWNED" AND $owned.error.details.index == 0 AND $shared_vs_exclusive.error.code == "INFRA_RECORD_OWNED" AND $shared.ok;
};

-- test: préfixe unique d'un TXT partagé : un second déclarant du même préfixe au même nom est refusé (INFRA_RECORD_SINGLETON_TAKEN), qu'il déclare le préfixe ou seulement une valeur qui le porte ; autre nom ou valeur sans le préfixe : accepté
{
    LET $spf = |$owner: string, $subject: string, $record: object| fn::infra_records_declare({ owner: $owner, subject: $subject, records: [$record] });
    LET $with_prefix = $spf("manual", "spf2", { fqdn: "exemple.fr", type: "TXT", values: ["v=spf1 include:autre.example -all"], mode: "shared", singleton_prefix: "v=spf1" });
    LET $value_only = $spf("manual", "spf2", { fqdn: "Exemple.fr", type: "TXT", values: ["v=spf1 -all"], mode: "shared" });
    LET $same_owner = $spf("lyxal_mail", "mail_domain:spf2", { fqdn: "exemple.fr", type: "TXT", values: ["v=spf1 -all"], mode: "shared", singleton_prefix: "v=spf1" });
    LET $other_name = $spf("manual", "spf2", { fqdn: "autre.exemple.fr", type: "TXT", values: ["v=spf1 -all"], mode: "shared", singleton_prefix: "v=spf1" });
    LET $reverse = $spf("manual", "spf3", { fqdn: "autre.exemple.fr", type: "TXT", values: ["v=spf1 a -all"], mode: "shared" });
    LET $unrelated = $spf("manual", "spf3", { fqdn: "autre.exemple.fr", type: "TXT", values: ["google-site-verification=abc"], mode: "shared" });
    LET $cleared = fn::infra_records_declare({ owner: "manual", subject: "spf2", records: [] }).ok AND fn::infra_records_declare({ owner: "manual", subject: "spf3", records: [] }).ok;
    RETURN $with_prefix.error.code == "INFRA_RECORD_SINGLETON_TAKEN" AND $with_prefix.error.details == { index: 0, prefix: "v=spf1" }
        AND $value_only.error.code == "INFRA_RECORD_SINGLETON_TAKEN" AND $same_owner.error.code == "INFRA_RECORD_SINGLETON_TAKEN"
        AND $other_name.ok AND $reverse.error.code == "INFRA_RECORD_SINGLETON_TAKEN" AND $unrelated.ok AND $cleared
        AND !string::contains(<string> $with_prefix.error, "exemple.fr");
};

-- test: un CNAME ne cohabite avec rien (dans la déclaration ou avec un autre propriétaire)
{
    LET $inside = fn::infra_records_declare({ owner: "manual", subject: "cname", records: [
        { fqdn: "c.exemple.fr", type: "CNAME", values: ["a.exemple.fr"], mode: "exclusive" },
        { fqdn: "c.exemple.fr", type: "TXT", values: ["x"], mode: "shared" }
    ] });
    LET $other = fn::infra_records_declare({ owner: "manual", subject: "cname", records: [{ fqdn: "www.exemple.fr", type: "CNAME", values: ["a.exemple.fr"], mode: "exclusive" }] });
    LET $reverse = fn::infra_records_declare({ owner: "manual", subject: "cname", records: [{ fqdn: "docs.exemple.fr", type: "TXT", values: ["x"], mode: "shared" }] });
    RETURN $inside.error.code == "INFRA_RECORD_CNAME_CONFLICT" AND $other.error.code == "INFRA_RECORD_CNAME_CONFLICT" AND $reverse.error.code == "INFRA_RECORD_CNAME_CONFLICT";
};

-- test: une organisation n'écrit que dans une zone qui la nomme ; nom non couvert : unmanaged
{
    LET $accepted = fn::infra_records_declare({ owner: "lyxal_mail", subject: "mail_domain:alpha", tenant: "auth_organization:alpha", records: [{ fqdn: "alpha.test", type: "MX", values: ["10 mx.exemple.fr"], mode: "exclusive" }] });
    LET $refused = fn::infra_records_declare({ owner: "lyxal_mail", subject: "mail_domain:beta", tenant: "auth_organization:beta", records: [{ fqdn: "alpha.test", type: "TXT", values: ["v=spf1 -all"], mode: "shared" }] });
    LET $installation_zone = fn::infra_records_declare({ owner: "lyxal_mail", subject: "mail_domain:beta", tenant: "auth_organization:beta", records: [{ fqdn: "beta.exemple.fr", type: "TXT", values: ["x"], mode: "shared" }] });
    LET $outside = fn::infra_records_declare({ owner: "lyxal_mail", subject: "mail_domain:beta", tenant: "auth_organization:beta", records: [{ fqdn: "beta.test", type: "MX", values: ["10 mx.exemple.fr"], mode: "exclusive" }] });
    RETURN $accepted.data.items[0].managed AND $accepted.data.items[0].state == "pending"
        AND $refused.error.code == "INFRA_RECORD_TENANT_REFUSED" AND $installation_zone.error.code == "INFRA_RECORD_TENANT_REFUSED"
        AND $outside.ok AND $outside.data.items[0].state == "unmanaged" AND !$outside.data.items[0].managed;
};

-- test: liste vide : tout le sujet est retiré
{
    LET $r = fn::infra_records_declare({ owner: "manual", subject: "types", records: [] });
    RETURN $r.data == { items: [], changed: true, queued: 0 } AND (SELECT VALUE state FROM infra_record WHERE subject = "types") == ["released", "released", "released"]
        AND fn::infra_records_declare({ owner: "manual", subject: "types", records: [] }).data.changed == false;
};

-- test: un enregistrement retiré redéclaré revient en pending
{
    LET $r = fn::infra_records_declare({ owner: "manual", subject: "types", records: [{ fqdn: "docs.exemple.fr", type: "CNAME", values: ["pages.example.net"], mode: "exclusive" }] });
    RETURN $r.data.changed AND $r.data.items[0].state == "pending";
};

-- test: état des enregistrements d'un propriétaire par sujet
-- en tant que: courrier
{
    LET $s = fn::infra_records_status({ owner: "lyxal_mail", subjects: ["mail_domain:d1", "mail_domain:beta", "inconnu"] });
    RETURN $s.ok AND $s.data.items.subject == ["mail_domain:beta", "mail_domain:d1", "mail_domain:d1", "mail_domain:d1", "mail_domain:d1"]
        AND $s.data.items[0].{ subject, fqdn, type, state, managed } == { subject: "mail_domain:beta", fqdn: "beta.test", type: "MX", state: "unmanaged", managed: false }
        AND $s.data.items[0].conflict_reason IS NONE AND $s.data.items[0].published_at IS NONE AND $s.data.items[0].error_code IS NONE
        AND $s.data.items.state CONTAINS "releasing"
        AND fn::infra_records_status({ owner: "lyxal_mail", subjects: [] }).error.code == "INFRA_INVALID_PARAMETERS";
};

-- test: sujets d'un propriétaire, page par page (retirés exclus)
-- en tant que: courrier
{
    LET $first = fn::infra_records_subjects({ owner: "lyxal_mail", limit: 2 });
    LET $second = fn::infra_records_subjects({ owner: "lyxal_mail", after: $first.data.next, limit: 2 });
    RETURN $first.data == { subjects: ["mail_domain:alpha", "mail_domain:beta"], next: "mail_domain:beta" }
        AND $second.data == { subjects: ["mail_domain:d1", "mail_domain:d2"], next: NONE }
        AND fn::infra_records_subjects({ owner: "lyxal_mail", limit: 0 }).error.code == "INFRA_INVALID_PARAMETERS";
};

-- test: retrait d'un sujet : écrit chez l'hébergeur → releasing ; jamais écrit → released ; keep_at_provider : oubli
-- en tant que: courrier
{
    UPDATE infra_record SET state = "written", provider_ids = [{ id: "p-a", value: "192.0.2.1" }], applied_values = ["192.0.2.1"] WHERE fqdn = "www.exemple.fr" AND type = "A";
    LET $r = fn::infra_records_release({ owner: "lyxal_mail", subject: "mail_domain:d2" });
    LET $kept = fn::infra_records_release({ owner: "lyxal_mail", subject: "mail_domain:alpha", keep_at_provider: true });
    LET $again = fn::infra_records_release({ owner: "lyxal_mail", subject: "mail_domain:d2" });
    RETURN $r.data.releasing == 1 AND $r.data.released == 0 AND $kept.data.released == 1 AND $again.data == { released: 0, releasing: 0, queued: 0 }
        AND (SELECT VALUE state FROM ONLY infra_record WHERE fqdn = "www.exemple.fr" AND type = "A" LIMIT 1) == "releasing"
        AND fn::infra_records_release({ owner: "lyxal_mail" }).error.code == "INFRA_INVALID_PARAMETERS";
};

-- test: le contrat du courrier ne déclare pas d'enregistrement manual, ni ne lit l'administration
-- en tant que: courrier
RETURN fn::infra_records_declare({ owner: "manual", subject: "x", records: [] }).error.code == "INFRA_PERMISSION_DENIED"
    AND fn::infra_records_release({ owner: "manual", subject: "x" }).error.code == "INFRA_PERMISSION_DENIED"
    AND fn::infra_records_status({ owner: "manual", subjects: ["x"] }).error.code == "INFRA_PERMISSION_DENIED"
    AND fn::infra_records_subjects({ owner: "manual" }).error.code == "INFRA_PERMISSION_DENIED"
    AND fn::infra_record_list({}).error.code == "INFRA_PERMISSION_DENIED"
    AND fn::infra_zone_list({}).error.code == "INFRA_PERMISSION_DENIED";

-- test: l'administrateur de la plateforme déclare des enregistrements manual, jamais au nom d'un module
-- en tant que: plateforme
RETURN fn::infra_records_declare({ owner: "manual", subject: "admin", records: [{ fqdn: "smtp.exemple.fr", type: "A", values: ["192.0.2.25"], mode: "exclusive" }] }).ok
    AND fn::infra_records_status({ owner: "manual", subjects: ["admin"] }).data.items[0].fqdn == "smtp.exemple.fr"
    AND fn::infra_records_subjects({ owner: "manual" }).data.subjects CONTAINS "admin"
    AND fn::infra_records_release({ owner: "manual", subject: "admin" }).data.released == 1
    AND fn::infra_records_declare({ owner: "lyxal_mail", subject: "x", records: [] }).error.code == "INFRA_PERMISSION_DENIED";

-- test: un membre d'organisation n'a aucun droit
-- en tant que: membre
RETURN fn::infra_records_declare({ owner: "lyxal_mail", subject: "x", records: [] }).error.code == "INFRA_PERMISSION_DENIED"
    AND fn::infra_records_declare({ owner: "manual", subject: "x", records: [] }).error.code == "INFRA_PERMISSION_DENIED"
    AND array::len(SELECT id FROM infra_record) == 0;

-- test: liste et lecture d'administration (valeurs observées, sans identifiant du fournisseur)
-- en tant que: plateforme
{
    LET $zone = (SELECT VALUE installation FROM ONLY passe:ids);
    LET $list = fn::infra_record_list({ zone: $zone, owner: "lyxal_mail", limit: 2 });
    LET $one = fn::infra_record_get({ record: <string> $list.data.items[0].id });
    RETURN $list.data.total == 6 AND array::len($list.data.items) == 2 AND $list.data.items[0].provider_ids IS NONE
        AND $one.data.observed == [] AND $one.data.fqdn == $list.data.items[0].fqdn
        AND fn::infra_record_list({ state: "releasing" }).data.total == 2
        AND fn::infra_record_get({ record: "infra_record:inconnu" }).error.code == "INFRA_RECORD_NOT_FOUND";
};

-- préparation: table des enregistrements fermée à l'écriture
{
    DEFINE TABLE OVERWRITE infra_record TYPE NORMAL SCHEMAFULL PERMISSIONS FOR select FULL FOR create, update, delete NONE;
};

-- test: déclaration refusée par la table : erreur explicite, rien n'est écrit
-- en tant que: courrier
-- attendu-erreur: INFRA_WRITE_FORBIDDEN
RETURN fn::infra_records_declare({ owner: "lyxal_mail", subject: "mail_domain:d9", records: [{ fqdn: "d9.exemple.fr", type: "TXT", values: ["x"], mode: "shared" }] });
