-- lyxal-test: assertions
-- Liste de blocage de l'installation : réseau valide et invalide (plage CIDR de lyxal_core),
-- doublon, expiration, droits des entrées manuelles (administrateur de la plateforme) et des
-- bannissements automatiques (service du courrier), récidive (durée doublée, 24 h au plus),
-- liste par curseur, retrait, réseaux en vigueur, écritures filtrées par les permissions.
--
-- identité admin: { "id": "auth_session:admin", "pv": 1, "permissions": ["mail.domain.manage", "mail.mailbox.access"] }
-- identité jean: { "id": "auth_session:jean", "pv": 1, "permissions": ["mail.mailbox.access"] }
-- identité worker: { "id": "auth_session:worker", "pv": 1, "permissions": ["mail.worker"] }
-- identité plateforme: { "id": "auth_session:plateforme", "pv": 1, "permissions": ["mail.installation.manage"] }

-- préparation: organisation alpha, identités et sessions lyxal_auth
{
    CREATE auth_organization:alpha CONTENT { slug: "alpha", name: "Alpha BTP" };
    FOR $name IN ["admin", "jean"] {
        LET $identity = type::record("auth_identity", $name);
        CREATE $identity CONTENT { schema: auth_identity_schema:default_v1, traits: { email: string::concat($name, "@lyxal.test") } };
        RELATE $identity->auth_member_of->auth_organization:alpha;
        CREATE type::record("auth_session", $name) CONTENT { identity: $identity, organization: auth_organization:alpha, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    };
    FOR $name IN ["worker", "plateforme"] {
        CREATE type::record("auth_identity", $name) CONTENT { schema: auth_identity_schema:default_v1, traits: { email: string::concat($name, "@lyxal.test") } };
        CREATE type::record("auth_session", $name) CONTENT { identity: type::record("auth_identity", $name), idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    };
};

-- test: liste vide ; aucun réseau en vigueur
RETURN fn::mail_block_list({}).data == { items: [], next: NONE }
    AND fn::mail_block_active({}).data == { networks: [] };

-- test: entrée manuelle sans fin, posée par l'administrateur de la plateforme ; réseau rangé en minuscules
-- en tant que: plateforme
{
    LET $created = fn::mail_block_create({ network: " 2001:DB8::/32 " }).data;
    RETURN $created.{ network, reason, strikes, expires_at, created_by } == { network: "2001:db8::/32", reason: "manual", strikes: 1, expires_at: NONE, created_by: auth_identity:plateforme }
        AND fn::mail_block_create({ network: "203.0.113.0/24", expires_at: time::now() + 1h }).data.expires_at > time::now() + 59m;
};

-- test: réseau invalide refusé par lyxal_core : adresse sans préfixe, préfixe trop grand, texte, absent, fin passée, motif inconnu, clé inconnue
-- en tant que: plateforme
RETURN [{ network: "203.0.113.7" }, { network: "203.0.113.0/33" }, { network: "2001:db8::/129" }, { network: "pas-un-reseau/8" }, { network: "" }, {}, { network: 42 },
        { network: "198.51.100.0/24", expires_at: time::now() - 1h }, { network: "198.51.100.0/24", reason: "humeur" }, { network: "198.51.100.0/24", autre: 1 }]
    .all(|$p| fn::mail_block_create($p).error.code == "MAIL_INVALID_PARAMETERS")
    AND array::len(SELECT VALUE id FROM mail_network_block) == 2;

-- test: doublon d'une entrée manuelle refusé, casse ignorée
-- en tant que: plateforme
RETURN fn::mail_block_create({ network: "2001:DB8::/32" }).error.{ code, details } == { code: "MAIL_BLOCK_EXISTS", details: { network: "2001:db8::/32" } }
    AND fn::mail_block_create({ network: "203.0.113.0/24" }).error.code == "MAIL_BLOCK_EXISTS";

-- test: l'administrateur de la plateforme ne pose pas de bannissement automatique ni ne lit les réseaux en vigueur
-- en tant que: plateforme
RETURN fn::mail_block_create({ network: "192.0.2.1/32", reason: "errors" }).error.code == "MAIL_PERMISSION_DENIED"
    AND fn::mail_block_active({}).error.code == "MAIL_PERMISSION_DENIED";

-- test: bannissement automatique par le service : une heure, motif gardé
-- en tant que: worker
{
    LET $ban = fn::mail_block_create({ network: "192.0.2.1/32", reason: "harvest" }).data;
    RETURN $ban.{ network, reason, strikes, created_by } == { network: "192.0.2.1/32", reason: "harvest", strikes: 1, created_by: NONE }
        AND $ban.expires_at > time::now() + 59m AND $ban.expires_at <= time::now() + 1h;
};

-- test: récidive : strikes incrémenté, durée doublée (2 h, 4 h), motif d'origine gardé
-- en tant que: worker
{
    LET $second = fn::mail_block_create({ network: "192.0.2.1/32", reason: "errors" }).data;
    LET $third = fn::mail_block_create({ network: "192.0.2.1/32", reason: "smuggling" }).data;
    RETURN $second.{ reason, strikes } == { reason: "harvest", strikes: 2 } AND $second.expires_at > time::now() + 119m AND $second.expires_at <= time::now() + 2h
        AND $third.strikes == 3 AND $third.expires_at > time::now() + 239m AND $third.expires_at <= time::now() + 4h
        AND array::len(SELECT VALUE id FROM mail_network_block WHERE network = "192.0.2.1/32") == 1;
};

-- test: récidives nombreuses : vingt-quatre heures au plus
-- en tant que: worker
{
    LET $bans = (<array> (0..6)).map(|$i| fn::mail_block_create({ network: "192.0.2.1/32", reason: "errors" }).data);
    LET $last = array::last($bans);
    RETURN $last.strikes == 9 AND $last.expires_at > time::now() + 23h AND $last.expires_at <= time::now() + 24h;
};

-- test: fin fournie par le service gardée ; un bannissement ne change pas une entrée manuelle
-- en tant que: worker
{
    LET $short = fn::mail_block_create({ network: "192.0.2.2/32", reason: "smuggling", expires_at: time::now() + 10m }).data;
    LET $manual = fn::mail_block_create({ network: "203.0.113.0/24", reason: "errors" }).data;
    RETURN $short.expires_at <= time::now() + 10m AND $short.strikes == 1
        AND $manual.{ reason, strikes } == { reason: "manual", strikes: 1 };
};

-- test: le service ne pose pas d'entrée manuelle, ne liste pas et ne retire rien
-- en tant que: worker
RETURN fn::mail_block_create({ network: "198.51.100.0/24" }).error.code == "MAIL_PERMISSION_DENIED"
    AND fn::mail_block_list({}).error.code == "MAIL_PERMISSION_DENIED"
    AND fn::mail_block_delete({ network: "192.0.2.1/32" }).error.code == "MAIL_PERMISSION_DENIED";

-- test: réseaux en vigueur lus par le service : triés
-- en tant que: worker
RETURN fn::mail_block_active({}).data == { networks: ["192.0.2.1/32", "192.0.2.2/32", "2001:db8::/32", "203.0.113.0/24"] }
    AND fn::mail_block_active({ autre: 1 }).error.code == "MAIL_INVALID_PARAMETERS";

-- préparation: un bannissement et une entrée manuelle arrivés à leur fin (écrits par la session système)
{
    UPDATE mail_network_block SET expires_at = time::now() - 1m WHERE network IN ["192.0.2.2/32", "203.0.113.0/24"];
};

-- test: expiration : une entrée échue n'est plus en vigueur, mais reste dans la liste
-- en tant que: worker
RETURN fn::mail_block_active({}).data.networks == ["192.0.2.1/32", "2001:db8::/32"];

-- test: liste par curseur : triée par réseau, sans doublon ni manque, entrées échues comprises
-- en tant que: plateforme
{
    LET $first = fn::mail_block_list({ limit: 3 }).data;
    LET $second = fn::mail_block_list({ limit: 3, after: $first.next }).data;
    RETURN $first.items.network == ["192.0.2.1/32", "192.0.2.2/32", "2001:db8::/32"] AND $first.next == "2001:db8::/32"
        AND $second.items.network == ["203.0.113.0/24"] AND $second.next IS NONE
        AND fn::mail_block_list({ limit: 0 }).error.code == "MAIL_INVALID_PARAMETERS";
};

-- test: un bannissement échu puis repris : récidive comptée, une heure doublée à nouveau
-- en tant que: worker
{
    LET $again = fn::mail_block_create({ network: "192.0.2.2/32", reason: "errors" }).data;
    RETURN $again.{ reason, strikes } == { reason: "smuggling", strikes: 2 } AND $again.expires_at > time::now() + 119m;
};

-- test: retrait par l'administrateur de la plateforme : entrée manuelle et bannissement ; réseau absent ou invalide
-- en tant que: plateforme
RETURN fn::mail_block_delete({ network: "203.0.113.0/24" }).data == { deleted: true }
    AND fn::mail_block_delete({ network: "192.0.2.2/32" }).data == { deleted: true }
    AND fn::mail_block_delete({ network: "203.0.113.0/24" }).error.{ code, details } == { code: "MAIL_BLOCK_NOT_FOUND", details: { network: "203.0.113.0/24" } }
    AND fn::mail_block_delete({ network: "203.0.113.7" }).error.code == "MAIL_INVALID_PARAMETERS"
    AND fn::mail_block_list({}).data.items.network == ["192.0.2.1/32", "2001:db8::/32"];

-- test: administrateur d'organisation : aucune fonction de la liste de blocage, aucune fiche visible
-- en tant que: admin
RETURN [fn::mail_block_create({ network: "198.51.100.0/24" }), fn::mail_block_create({ network: "198.51.100.0/24", reason: "errors" }), fn::mail_block_list({}),
        fn::mail_block_delete({ network: "2001:db8::/32" }), fn::mail_block_active({})].all(|$r| $r.error.code == "MAIL_PERMISSION_DENIED")
    AND array::len(SELECT * FROM mail_network_block) == 0;

-- test: membre : aucune fonction de la liste de blocage, aucune fiche visible
-- en tant que: jean
RETURN [fn::mail_block_create({ network: "198.51.100.0/24" }), fn::mail_block_create({ network: "198.51.100.0/24", reason: "errors" }), fn::mail_block_list({}),
        fn::mail_block_delete({ network: "2001:db8::/32" }), fn::mail_block_active({})].all(|$r| $r.error.code == "MAIL_PERMISSION_DENIED")
    AND array::len(SELECT * FROM mail_network_block) == 0;

-- test: écriture directe : un membre ne crée, ne change ni ne retire une entrée (filtré, rien d'écrit)
-- en tant que: jean
{
    LET $created = (CREATE mail_network_block CONTENT { network: "198.51.100.0/24", reason: "manual" });
    LET $updated = (UPDATE mail_network_block SET expires_at = time::now() + 1m);
    LET $deleted = (DELETE mail_network_block RETURN BEFORE);
    RETURN $created == [] AND $updated == [] AND $deleted == [];
};

-- test: écriture directe : le service ne pose pas d'entrée manuelle et ne retire rien
-- en tant que: worker
{
    LET $created = (CREATE mail_network_block CONTENT { network: "198.51.100.0/24", reason: "manual" });
    LET $deleted = (DELETE mail_network_block RETURN BEFORE);
    RETURN $created == [] AND $deleted == [] AND array::len(SELECT VALUE id FROM mail_network_block) == 2;
};

-- préparation: table fermée à l'écriture (lecture inchangée), pour vérifier le contrôle de l'écriture principale
DEFINE TABLE OVERWRITE mail_network_block TYPE NORMAL SCHEMAFULL PERMISSIONS FOR select WHERE fn::mail_can({ action: "manage" }) OR fn::mail_can({ action: "worker" }) FOR create, update, delete NONE;

-- test: entrées manuelles : écritures filtrées, erreur explicite, rien d'écrit ni retiré
-- en tant que: plateforme
RETURN fn::mail_block_create({ network: "198.51.100.0/24" }).error.{ code, details } == { code: "MAIL_WRITE_FORBIDDEN", details: { table: "mail_network_block" } }
    AND fn::mail_block_delete({ network: "2001:db8::/32" }).error.code == "MAIL_WRITE_FORBIDDEN"
    AND fn::mail_block_list({}).data.items.network == ["192.0.2.1/32", "2001:db8::/32"];

-- test: bannissements : écritures filtrées (nouveau réseau, récidive), erreur explicite, rien d'écrit
-- en tant que: worker
RETURN fn::mail_block_create({ network: "198.51.100.9/32", reason: "errors" }).error.code == "MAIL_WRITE_FORBIDDEN"
    AND fn::mail_block_create({ network: "192.0.2.1/32", reason: "errors" }).error.code == "MAIL_WRITE_FORBIDDEN"
    AND fn::mail_block_active({}).data.networks == ["192.0.2.1/32", "2001:db8::/32"];
