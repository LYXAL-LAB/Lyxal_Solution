-- lyxal-test: assertions
-- Mots de passe d'application : permissions déclarées utilisables, création (action sensible,
-- organisation, permissions, politique, nombre et durée maximaux), empreinte illisible,
-- écriture directe refusée, listes et journal (titulaire, administrateurs, isolation),
-- vérification (session app_password partagée, AAL 1, droits réduits, journal regroupé),
-- échecs comptés (adresse IP bloquée, identifiant compté sans blocage, compteurs de la console
-- intacts, ancien appareil non compté), renouvellement, révocations (titulaire, administrateur,
-- sortie de l'organisation, récupération, remise à zéro du double facteur), politique (une
-- organisation ne peut que restreindre, désactivation), événements, purge.
--
-- identité claire: { "id": "auth_session:claire", "pv": 1, "permissions": ["auth.member.read", "auth.self.manage", "calendar.access", "mail.admin", "mail.mailbox.access"] }
-- identité marc: { "id": "auth_session:marc", "pv": 1, "permissions": ["auth.member.read", "auth.self.manage"] }
-- identité alpha_admin: { "id": "auth_session:alpha_admin", "pv": 1, "permissions": ["auth.member.manage", "auth.member.read", "auth.self.manage"] }
-- identité beta_admin: { "id": "auth_session:beta_admin", "pv": 1, "permissions": ["auth.member.manage", "auth.member.read", "auth.self.manage"] }
-- identité plateforme: { "id": "auth_session:plateforme", "pv": 1, "permissions": ["auth.identity.manage", "auth.self.manage"] }
-- identité appareil: { "id": "auth_session:appareil", "pv": 1, "permissions": ["calendar.access", "mail.mailbox.access"] }
-- identité ancien_appareil: { "id": "auth_session:ancien_appareil", "pv": 1, "permissions": ["mail.mailbox.access"] }

-- préparation: organisations, permissions des modules du courrier, rôles, identités et sessions
{
    CREATE auth_organization:alpha CONTENT { slug: "alpha", name: "Alpha BTP" };
    CREATE auth_organization:beta CONTENT { slug: "beta", name: "Beta" };
    fn::auth_permission_register({ code: "mail.mailbox.access", module: "lyxal_mail", scope: "organization", app_password: true, description: { fr: "Boîtes aux lettres", en: "Mailboxes" } });
    fn::auth_permission_register({ code: "calendar.access", module: "lyxal_calendar", scope: "organization", app_password: true });
    fn::auth_permission_register({ code: "mail.admin", module: "lyxal_mail", scope: "organization" });
    CREATE auth_role:messagerie CONTENT { scope_key: "installation", key: "messagerie", name: "Messagerie", scope: "organization" };
    RELATE auth_role:messagerie->auth_role_grants->auth_permission:⟨mail.mailbox.access⟩;
    RELATE auth_role:messagerie->auth_role_grants->auth_permission:⟨calendar.access⟩;
    RELATE auth_role:messagerie->auth_role_grants->auth_permission:⟨mail.admin⟩;
    CREATE auth_role:gestion_identites CONTENT { scope_key: "installation", key: "gestion_identites", name: "Gestion des identités", scope: "installation" };
    RELATE auth_role:gestion_identites->auth_role_grants->auth_permission:⟨auth.identity.manage⟩;
    fn::auth_identity_create({ traits: { email: "claire@exemple.fr", name: { first: "Claire" }, locale: "fr" }, organization: "auth_organization:alpha" });
    fn::auth_identity_create({ traits: { email: "marc@exemple.fr" }, organization: "auth_organization:alpha" });
    fn::auth_identity_create({ traits: { email: "admin@alpha.test" }, organization: "auth_organization:alpha" });
    fn::auth_identity_create({ traits: { email: "admin@beta.test" }, organization: "auth_organization:beta" });
    fn::auth_identity_create({ traits: { email: "ines@exemple.fr" }, organization: "auth_organization:alpha" });
    LET $id = |$email| (SELECT VALUE identity FROM ONLY auth_credential_identifier WHERE value = $email LIMIT 1);
    LET $claire = $id("claire@exemple.fr");
    RELATE $claire->auth_member_of->auth_organization:beta;
    LET $alpha_membership = (SELECT VALUE id FROM ONLY auth_member_of WHERE in = $claire AND out = auth_organization:alpha LIMIT 1);
    LET $beta_membership = (SELECT VALUE id FROM ONLY auth_member_of WHERE in = $claire AND out = auth_organization:beta LIMIT 1);
    RELATE $alpha_membership->auth_has_role->auth_role:messagerie;
    RELATE $beta_membership->auth_has_role->auth_role:messagerie;
    LET $alpha_admin_membership = (SELECT VALUE id FROM ONLY auth_member_of WHERE in = $id("admin@alpha.test") LIMIT 1);
    RELATE $alpha_admin_membership->auth_has_role->auth_role:organization_admin;
    LET $beta_admin_membership = (SELECT VALUE id FROM ONLY auth_member_of WHERE in = $id("admin@beta.test") LIMIT 1);
    RELATE $beta_admin_membership->auth_has_role->auth_role:organization_admin;
    CREATE auth_identity:plateforme CONTENT { schema: auth_identity_schema:default_v1, traits: { email: "plateforme@lyxal.test" } };
    RELATE auth_identity:plateforme->auth_has_role->auth_role:gestion_identites;
    UPDATE $id("ines@exemple.fr") SET available_aal = 2;
    CREATE auth_application:outil CONTENT { client_id: "lyx_outil_0000000000000", name: "Outil", type: "machine" };
    LET $open = |$key, $identity, $organization| (CREATE ONLY type::record("auth_session", $key) CONTENT {
        identity: $identity, organization: $organization, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d
    });
    $open("claire", $claire, auth_organization:alpha);
    $open("claire_beta", $claire, auth_organization:beta);
    $open("claire_sans_org", $claire, NONE);
    $open("marc", $id("marc@exemple.fr"), auth_organization:alpha);
    $open("alpha_admin", $id("admin@alpha.test"), auth_organization:alpha);
    $open("beta_admin", $id("admin@beta.test"), auth_organization:beta);
    $open("plateforme", auth_identity:plateforme, NONE);
    $open("ines", $id("ines@exemple.fr"), auth_organization:alpha);
    CREATE auth_session:claire_ancienne CONTENT { identity: $claire, organization: auth_organization:alpha, authenticated_at: time::now() - 1d, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_session:alpha_admin_ancienne CONTENT { identity: $id("admin@alpha.test"), organization: auth_organization:alpha, authenticated_at: time::now() - 1d, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_session:claire_cle CONTENT { identity: $claire, kind: "api_key", organization: auth_organization:alpha, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    CREATE auth_session:service CONTENT { application: auth_application:outil, kind: "service", idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    DEFINE TABLE test_ref SCHEMALESS PERMISSIONS FULL;
    CREATE test_ref:claire CONTENT { identity: $claire };
};

-- test: permissions utilisables : déclarées par leur module, d'organisation et d'AAL 1 seulement
RETURN fn::auth_app_password_allowed({}) == ["calendar.access", "mail.mailbox.access"]
    AND fn::auth_permission_register({ code: "mail.sensible", module: "lyxal_mail", scope: "organization", min_aal: 2, app_password: true }).error.code == "AUTH_INVALID_PARAMETERS"
    AND fn::auth_permission_register({ code: "mail.global", module: "lyxal_mail", scope: "installation", app_password: true }).error.code == "AUTH_INVALID_PARAMETERS"
    AND fn::auth_permission_update({ code: "mail.mailbox.access", min_aal: 2 }).error.code == "AUTH_INVALID_PARAMETERS"
    AND fn::auth_permission_update({ code: "auth.self.manage", app_password: true }).error.code == "AUTH_INVALID_PARAMETERS"
    AND fn::auth_permission_list({ module: "lyxal_mail" }).data.map(|$p| [$p.code, $p.app_password, $p.min_aal]) == [["mail.admin", false, 1], ["mail.mailbox.access", true, 1]];

-- test: création : nom nettoyé, permissions triées, identifiant de connexion, aucune expiration par défaut
{
    LET $r = fn::auth_app_password_create({ session: "auth_session:claire", name: "  iPhone de Claire ", permissions: ["mail.mailbox.access", "calendar.access"], password_hash: "1111111111111111111111111111111111111111111111111111111111111111" });
    CREATE test_ref:iphone CONTENT { app: $r.data.app_password.id };
    RETURN $r.ok AND $r.data.username == "claire@exemple.fr" AND $r.data.app_password.name == "iPhone de Claire"
        AND $r.data.app_password.permissions == ["calendar.access", "mail.mailbox.access"] AND $r.data.app_password.state == "active"
        AND $r.data.app_password.organization == auth_organization:alpha AND $r.data.app_password.expires_at IS NONE;
};

-- test: événement auth.app_password.created adressé au titulaire, sans empreinte
{
    LET $e = (SELECT VALUE payload FROM ONLY event_outbox WHERE event_type = "auth.app_password.created" LIMIT 1);
    RETURN $e.recipient_email == "claire@exemple.fr" AND $e.recipient_name == "Claire" AND $e.recipient_locale == "fr"
        AND $e.name == "iPhone de Claire" AND $e.app_password_id == <string> test_ref:iphone.app AND $e.organization_id == "auth_organization:alpha"
        AND $e.permissions == ["calendar.access", "mail.mailbox.access"] AND $e.password_hash IS NONE;
};

-- test: création refusée : authentification ancienne, AAL insuffisante, sans organisation, session non interactive, clé d'API, compte de service, paramètres
RETURN fn::auth_app_password_create({ session: "auth_session:claire_ancienne", name: "X", permissions: ["mail.mailbox.access"], password_hash: "9999999999999999999999999999999999999999999999999999999999999999" }).error.code == "AUTH_REAUTHENTICATION_REQUIRED"
    AND fn::auth_app_password_create({ session: "auth_session:ines", name: "X", permissions: ["mail.mailbox.access"], password_hash: "9999999999999999999999999999999999999999999999999999999999999999" }).error.code == "AUTH_AAL_INSUFFICIENT"
    AND fn::auth_app_password_create({ session: "auth_session:claire_sans_org", name: "X", permissions: ["mail.mailbox.access"], password_hash: "9999999999999999999999999999999999999999999999999999999999999999" }).error.code == "AUTH_APP_PASSWORD_ORGANIZATION_REQUIRED"
    AND fn::auth_app_password_create({ session: "auth_session:claire_cle", name: "X", permissions: ["mail.mailbox.access"], password_hash: "9999999999999999999999999999999999999999999999999999999999999999" }).error.code == "AUTH_SESSION_REQUIRED"
    AND fn::auth_app_password_create({ session: "auth_session:service", name: "X", permissions: ["mail.mailbox.access"], password_hash: "9999999999999999999999999999999999999999999999999999999999999999" }).error.code == "AUTH_SESSION_REQUIRED"
    AND fn::auth_app_password_create({ session: "auth_session:claire", name: "", permissions: ["mail.mailbox.access"], password_hash: "9999999999999999999999999999999999999999999999999999999999999999" }).error.code == "AUTH_INVALID_PARAMETERS"
    AND fn::auth_app_password_create({ session: "auth_session:claire", name: "X", permissions: [], password_hash: "9999999999999999999999999999999999999999999999999999999999999999" }).error.code == "AUTH_INVALID_PARAMETERS"
    AND fn::auth_app_password_create({ session: "auth_session:claire", name: "X", permissions: ["mail.mailbox.access"], password_hash: "court" }).error.code == "AUTH_INVALID_PARAMETERS"
    AND array::len(SELECT * FROM auth_app_password) == 1;

-- test: permission non déclarée utilisable, de lyxal_auth, ou non détenue : refusée avec la liste
{
    LET $admin = fn::auth_app_password_create({ session: "auth_session:claire", name: "X", permissions: ["mail.admin", "mail.mailbox.access"], password_hash: "9999999999999999999999999999999999999999999999999999999999999999" });
    LET $own_rights = fn::auth_app_password_create({ session: "auth_session:claire", name: "X", permissions: ["auth.self.manage"], password_hash: "9999999999999999999999999999999999999999999999999999999999999999" });
    LET $marc = fn::auth_app_password_create({ session: "auth_session:marc", name: "X", permissions: ["mail.mailbox.access"], password_hash: "9999999999999999999999999999999999999999999999999999999999999999" });
    RETURN $admin.error.code == "AUTH_APP_PASSWORD_PERMISSION_NOT_ALLOWED" AND $admin.error.details.permissions == ["mail.admin"]
        AND $own_rights.error.code == "AUTH_APP_PASSWORD_PERMISSION_NOT_ALLOWED" AND $own_rights.error.details.permissions == ["auth.self.manage"]
        AND $marc.error.code == "AUTH_APP_PASSWORD_PERMISSION_NOT_ALLOWED" AND $marc.error.details.permissions == ["mail.mailbox.access"];
};

-- préparation: un second mot de passe dans alpha (expiration), un dans beta
{
    LET $portable = fn::auth_app_password_create({ session: "auth_session:claire", name: "Portable", permissions: ["mail.mailbox.access"], expires_at: time::now() + 30d, password_hash: "2222222222222222222222222222222222222222222222222222222222222222" }).data.app_password.id;
    LET $tablette = fn::auth_app_password_create({ session: "auth_session:claire_beta", name: "Tablette", permissions: ["calendar.access"], password_hash: "3333333333333333333333333333333333333333333333333333333333333333" }).data.app_password.id;
    CREATE test_ref:portable CONTENT { app: $portable };
    CREATE test_ref:tablette CONTENT { app: $tablette };
};

-- test: le titulaire liste ses mots de passe, sans empreinte, du plus récent au plus ancien
-- en tant que: claire
{
    LET $list = fn::auth_app_password_list({}).data;
    RETURN $list.name == ["Tablette", "Portable", "iPhone de Claire"] AND $list.state == ["active", "active", "active"]
        AND $list.organization == [auth_organization:beta, auth_organization:alpha, auth_organization:alpha]
        AND array::len(SELECT * FROM auth_app_password) == 3
        AND array::len(array::filter((SELECT VALUE password_hash FROM auth_app_password), |$h| $h IS NOT NONE)) == 0
        AND fn::auth_app_password_list({ organization: "auth_organization:beta" }).data.name == ["Tablette"];
};

-- test: l'administrateur de l'organisation voit les mots de passe de son organisation seulement
-- en tant que: alpha_admin
RETURN fn::auth_app_password_list({ identity: <string> test_ref:claire.identity }).data.name == ["Portable", "iPhone de Claire"];

-- test: isolation entre organisations : l'administrateur de beta ne voit que ceux de beta
-- en tant que: beta_admin
RETURN fn::auth_app_password_list({ identity: <string> test_ref:claire.identity }).data.name == ["Tablette"];

-- test: l'administrateur de l'installation voit tout
-- en tant que: plateforme
RETURN array::len(fn::auth_app_password_list({ identity: <string> test_ref:claire.identity }).data) == 3;

-- test: un autre membre ne voit pas ceux de quelqu'un d'autre
-- en tant que: marc
RETURN fn::auth_app_password_list({ identity: <string> test_ref:claire.identity }).error.code == "AUTH_PERMISSION_DENIED"
    AND fn::auth_app_password_list({}).data == []
    AND array::len(SELECT * FROM auth_app_password) == 0;

-- test: permissions que le titulaire peut donner ; aucune pour un membre sans droit du courrier
-- en tant que: claire
RETURN fn::auth_app_password_eligible({}).data.code == ["calendar.access", "mail.mailbox.access"]
    AND fn::auth_app_password_eligible({}).data[1].description.fr == "Boîtes aux lettres";

-- test: aucune permission à donner pour marc ; session système : session requise
-- en tant que: marc
RETURN fn::auth_app_password_eligible({}).data == [];

-- test: éligibilité de la session système refusée
RETURN fn::auth_app_password_eligible({}).error.code == "AUTH_SESSION_REQUIRED";

-- test: écriture directe refusée au titulaire (création, révocation)
-- en tant que: claire
{
    CREATE auth_app_password CONTENT { identity: test_ref:claire.identity, organization: auth_organization:alpha, name: "Directe", password_hash: "4444444444444444444444444444444444444444444444444444444444444444", permissions: ["mail.mailbox.access"] };
    UPDATE auth_app_password SET revoked_at = time::now();
    RETURN true;
};

-- test: rien n'a été écrit
RETURN array::len(SELECT * FROM auth_app_password WHERE name = "Directe") == 0
    AND array::len(SELECT * FROM auth_app_password WHERE revoked_at IS NOT NONE) == 0;

-- test: vérification : session app_password, AAL 1, permissions du mot de passe, identifiant normalisé
{
    LET $v = fn::auth_app_password_verify({
        password_hash: "1111111111111111111111111111111111111111111111111111111111111111", identifier: "Claire@Exemple.FR", protocol: "imap",
        client: { ip: "203.0.113.5", user_agent: "Thunderbird" }, client_name: "Thunderbird 128",
        ip_hash: "a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1", identifier_hash: "b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1", access_slot: "a"
    });
    UPDATE test_ref:iphone SET session = $v.data.session;
    LET $s = (SELECT * FROM ONLY $v.data.session);
    RETURN $v.ok AND $v.data.kind == "app_password" AND $v.data.aal == 1 AND $v.data.permissions == ["calendar.access", "mail.mailbox.access"]
        AND $v.data.app_password == test_ref:iphone.app AND $v.data.refresh_expires_at IS NONE AND $v.data.access_seconds == 900
        AND $s.amr.method == ["app_password"] AND $s.app_password == test_ref:iphone.app AND $s.kind == "app_password"
        AND $s.expires_at > time::now() + 11h AND $s.organization == auth_organization:alpha;
};

-- test: journal regroupé créé, dernier usage noté
{
    LET $uses = (SELECT * FROM auth_app_password_use);
    LET $app = (SELECT * FROM ONLY test_ref:iphone.app);
    RETURN array::len($uses) == 1 AND $uses[0].count == 1 AND $uses[0].protocol == "imap" AND $uses[0].ip == "203.0.113.5"
        AND $uses[0].client_name == "Thunderbird 128" AND $uses[0].identity == test_ref:claire.identity
        AND $app.last_used_protocol == "imap" AND $app.last_used_ip == "203.0.113.5" AND $app.last_used_at IS NOT NONE;
};

-- test: seconde vérification : même session reprise, ligne du journal mise à jour, une seule création de session publiée
{
    LET $v = fn::auth_app_password_verify({ password_hash: "1111111111111111111111111111111111111111111111111111111111111111", identifier: "claire@exemple.fr", protocol: "imap", client: { ip: "203.0.113.5" }, ip_hash: "a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1", identifier_hash: "b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1", access_slot: "b" });
    RETURN $v.data.session == test_ref:iphone.session AND (SELECT VALUE count FROM ONLY auth_app_password_use LIMIT 1) == 2
        AND (SELECT VALUE client_name FROM ONLY auth_app_password_use LIMIT 1) == "Thunderbird 128"
        AND array::len(SELECT * FROM auth_session WHERE app_password = test_ref:iphone.app) == 1
        AND array::len(SELECT * FROM event_outbox WHERE event_type = "auth.session.created" AND payload.kind = "app_password") == 1;
};

-- test: autre protocole et autre adresse : nouvelle ligne du journal, même session
{
    LET $v = fn::auth_app_password_verify({ password_hash: "1111111111111111111111111111111111111111111111111111111111111111", identifier: "claire@exemple.fr", protocol: "dav", client: { ip: "198.51.100.7" }, client_name: "DAVx5", ip_hash: "a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3", identifier_hash: "b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1", access_slot: "a" });
    RETURN $v.data.session == test_ref:iphone.session AND array::len(SELECT * FROM auth_app_password_use) == 2;
};

-- test: journal lu par le titulaire, dernière connexion d'abord
-- en tant que: claire
RETURN fn::auth_app_password_uses({ app_password: <string> test_ref:iphone.app }).data.map(|$u| [$u.protocol, $u.ip, $u.count]) == [["dav", "198.51.100.7", 1], ["imap", "203.0.113.5", 2]]
    AND fn::auth_app_password_uses({ app_password: <string> test_ref:iphone.app, limit: 1 }).data.protocol == ["dav"];

-- test: journal lu par l'administrateur de l'organisation
-- en tant que: alpha_admin
RETURN array::len(fn::auth_app_password_uses({ app_password: <string> test_ref:iphone.app }).data) == 2;

-- test: journal invisible pour un autre membre et pour l'administrateur d'une autre organisation
-- en tant que: marc
RETURN fn::auth_app_password_uses({ app_password: <string> test_ref:iphone.app }).error.code == "AUTH_APP_PASSWORD_NOT_FOUND"
    AND array::len(SELECT * FROM auth_app_password_use) == 0;

-- test: journal invisible pour l'administrateur de beta
-- en tant que: beta_admin
RETURN fn::auth_app_password_uses({ app_password: <string> test_ref:iphone.app }).error.code == "AUTH_APP_PASSWORD_NOT_FOUND";

-- préparation: session de test d'un appareil connecté par le mot de passe
{
    LET $s = (SELECT * FROM ONLY test_ref:iphone.session);
    CREATE auth_session:appareil CONTENT { identity: $s.identity, kind: "app_password", app_password: $s.app_password, organization: $s.organization, amr: $s.amr, idle_expires_at: $s.idle_expires_at, expires_at: $s.expires_at };
};

-- test: l'appareil exerce les permissions du mot de passe seulement, sans gestion du compte
-- en tant que: appareil
RETURN fn::auth_context({}).data.{ kind, aal } == { kind: "app_password", aal: 1 }
    AND fn::auth_has_permission({ permission: "mail.mailbox.access", tenant: auth_organization:alpha })
    AND !fn::auth_has_permission({ permission: "mail.admin", tenant: auth_organization:alpha })
    AND !fn::auth_has_permission({ permission: "auth.self.manage" });

-- test: une session de mot de passe d'application ne crée pas de mot de passe d'application
RETURN fn::auth_app_password_create({ session: "auth_session:appareil", name: "X", permissions: ["mail.mailbox.access"], password_hash: "9999999999999999999999999999999999999999999999999999999999999999" }).error.code == "AUTH_SESSION_REQUIRED";

-- test: renouvellement : même session, nouvel emplacement de clé ; une session interactive n'est pas renouvelée ainsi
{
    LET $r = fn::auth_app_password_session_renew({ session: <string> test_ref:iphone.session, access_slot: "b" });
    RETURN $r.ok AND $r.data.session == test_ref:iphone.session AND $r.data.permissions == ["calendar.access", "mail.mailbox.access"]
        AND $r.data.app_password == test_ref:iphone.app
        AND (SELECT VALUE access_slot FROM ONLY test_ref:iphone.session) == "b"
        AND fn::auth_app_password_session_renew({ session: "auth_session:claire", access_slot: "a" }).error.code == "AUTH_SESSION_REVOKED";
};

-- test: session près de son expiration : la vérification en ouvre une nouvelle ; une session expirée n'est pas renouvelée
{
    LET $old = test_ref:iphone.session;
    UPDATE $old SET expires_at = time::now() + 2m, idle_expires_at = time::now() + 2m;
    LET $v = fn::auth_app_password_session_open({ app_password: test_ref:iphone.app, client: { ip: "203.0.113.5" }, access_slot: "a" });
    UPDATE $old SET state = "expired";
    UPDATE test_ref:iphone SET session = $v.session;
    RETURN $v.code IS NONE AND $v.session != $old AND $v.kind == "app_password"
        AND fn::auth_app_password_session_renew({ session: <string> $old, access_slot: "a" }).error.code == "AUTH_SESSION_EXPIRED";
};

-- test: mauvais identifiant (autre identité) et mot de passe inconnu : échecs comptés par adresse IP et par identifiant
{
    LET $other = fn::auth_app_password_verify({ password_hash: "1111111111111111111111111111111111111111111111111111111111111111", identifier: "marc@exemple.fr", protocol: "smtp", client: { ip: "192.0.2.10" }, ip_hash: "a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2", identifier_hash: "b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2", access_slot: "a" });
    LET $unknown = fn::auth_app_password_verify({ password_hash: "9999999999999999999999999999999999999999999999999999999999999999", identifier: "claire@exemple.fr", protocol: "smtp", client: { ip: "192.0.2.10" }, ip_hash: "a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2", identifier_hash: "b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1", access_slot: "a" });
    RETURN $other.error.code == "AUTH_APP_PASSWORD_INVALID" AND $unknown.error.code == "AUTH_APP_PASSWORD_INVALID"
        AND (SELECT VALUE failures FROM ONLY auth_login_failure WHERE kind = "app_password_ip" AND key_hash = "a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2" LIMIT 1) == 2
        AND (SELECT VALUE failures FROM ONLY auth_login_failure WHERE kind = "app_password_identifier" AND key_hash = "b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1" LIMIT 1) == 1
        AND array::len(SELECT * FROM auth_login_failure WHERE kind IN ["identifier", "ip"]) == 0;
};

-- test: seuils de la politique de l'installation : adresse IP bloquée au cinquième échec
{
    fn::auth_policy_save({ app_password: { ip_max_failures: 5, identifier_alert_failures: 10 } });
    LET $attempt = || fn::auth_app_password_verify({ password_hash: "9999999999999999999999999999999999999999999999999999999999999999", identifier: "claire@exemple.fr", protocol: "smtp", client: { ip: "192.0.2.10" }, ip_hash: "a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2", identifier_hash: "b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2", access_slot: "a" });
    LET $third = $attempt();
    LET $fourth = $attempt();
    LET $fifth = $attempt();
    RETURN $third.error.code == "AUTH_APP_PASSWORD_INVALID" AND $fourth.error.code == "AUTH_APP_PASSWORD_INVALID" AND $fifth.error.code == "AUTH_TOO_MANY_ATTEMPTS"
        AND (SELECT VALUE payload FROM event_outbox WHERE event_type = "auth.app_password.ip_locked").ip_hash == ["a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2"];
};

-- test: adresse bloquée : même le bon mot de passe est refusé, sans nouvel échec compté ; une autre adresse passe ; la console n'est pas verrouillée
{
    LET $blocked = fn::auth_app_password_verify({ password_hash: "1111111111111111111111111111111111111111111111111111111111111111", identifier: "claire@exemple.fr", protocol: "imap", client: { ip: "192.0.2.10" }, ip_hash: "a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2", identifier_hash: "b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1", access_slot: "a" });
    LET $elsewhere = fn::auth_app_password_verify({ password_hash: "1111111111111111111111111111111111111111111111111111111111111111", identifier: "claire@exemple.fr", protocol: "imap", client: { ip: "203.0.113.5" }, ip_hash: "a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1", identifier_hash: "b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1", access_slot: "a" });
    RETURN $blocked.error.code == "AUTH_TOO_MANY_ATTEMPTS" AND $elsewhere.ok
        AND (SELECT VALUE failures FROM ONLY auth_login_failure WHERE kind = "app_password_ip" AND key_hash = "a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2" LIMIT 1) == 5
        AND !fn::auth_login_failure_check({ identifier_hash: "b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1", ip_hash: "a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2" }).data.locked
        AND fn::auth_login_failure_status({ ip_hash: "a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2", ip_kind: "app_password_ip" }).locked;
};

-- test: échecs par identifiant : comptés sans blocage, événement au seuil une seule fois par fenêtre
{
    FOR $i IN <array>(0..11) {
        fn::auth_app_password_verify({ password_hash: "9999999999999999999999999999999999999999999999999999999999999999", identifier: "claire@exemple.fr", protocol: "pop3", client: { ip: "192.0.2.20" }, ip_hash: crypto::sha256(<string> $i), identifier_hash: "b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3", access_slot: "a" });
    };
    LET $events = (SELECT VALUE payload FROM event_outbox WHERE event_type = "auth.app_password.failed");
    RETURN array::len($events) == 1 AND $events[0].failures == 10 AND $events[0].identifier_hash == "b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3"
        AND $events[0].identity_id == <string> test_ref:claire.identity
        AND (SELECT VALUE failures FROM ONLY auth_login_failure WHERE kind = "app_password_identifier" AND key_hash = "b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3" LIMIT 1) == 11
        AND (SELECT VALUE locked_until FROM ONLY auth_login_failure WHERE kind = "app_password_identifier" AND key_hash = "b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3" LIMIT 1) IS NONE
        AND fn::auth_app_password_verify({ password_hash: "1111111111111111111111111111111111111111111111111111111111111111", identifier: "claire@exemple.fr", protocol: "pop3", client: { ip: "203.0.113.5" }, ip_hash: "a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1", identifier_hash: "b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3", access_slot: "a" }).ok;
};

-- test: compteur seul (sans limite) et échec compté directement par la session système
RETURN fn::auth_login_failure_count({ kind: "app_password_identifier", hash: "b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4", window: 15m, lock: 15m, limit: NONE }).{ failures, newly_locked, locked_until } == { failures: 1, newly_locked: false, locked_until: NONE }
    AND fn::auth_app_password_failure_record({ ip_hash: "a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4", identifier_hash: "b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4" }).data.locked == false
    AND fn::auth_app_password_failure_record({ ip_hash: "court", identifier_hash: "b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4" }).error.code == "AUTH_INVALID_PARAMETERS";

-- test: révocation par le titulaire : motif owner, événement publié, puis mot de passe refusé sans compter
{
    LET $r = fn::auth_app_password_revoke({ session: "auth_session:claire", app_password: <string> test_ref:portable.app });
    LET $app = (SELECT * FROM ONLY test_ref:portable.app);
    LET $refused = fn::auth_app_password_verify({ password_hash: "2222222222222222222222222222222222222222222222222222222222222222", identifier: "claire@exemple.fr", protocol: "smtp", client: { ip: "192.0.2.30" }, ip_hash: "a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5", identifier_hash: "b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5", access_slot: "a" });
    LET $revoked_event = (SELECT VALUE payload FROM ONLY event_outbox WHERE event_type = "auth.app_password.revoked" LIMIT 1);
    RETURN $r.data.revoked == 1 AND $app.revoked_reason == "owner" AND $app.revoked_by == test_ref:claire.identity
        AND $refused.error.code == "AUTH_APP_PASSWORD_INVALID"
        AND array::len(SELECT * FROM auth_login_failure WHERE key_hash IN ["a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5", "b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5b5"]) == 0
        AND $revoked_event.reason == "owner" AND $revoked_event.name == "Portable" AND $revoked_event.recipient_email == "claire@exemple.fr"
        AND fn::auth_app_password_revoke({ session: "auth_session:claire", app_password: <string> test_ref:portable.app }).data.revoked == 0;
};

-- test: une révocation est définitive
-- attendu-erreur: AUTH_APP_PASSWORD_INVALID
UPDATE auth_app_password SET revoked_at = NONE WHERE name = "Portable";

-- test: révocation par un tiers : autre membre et administrateur d'une autre organisation : introuvable ; administrateur à l'authentification ancienne : réauthentification
RETURN fn::auth_app_password_revoke({ session: "auth_session:marc", app_password: <string> test_ref:iphone.app }).error.code == "AUTH_APP_PASSWORD_NOT_FOUND"
    AND fn::auth_app_password_revoke({ session: "auth_session:beta_admin", app_password: <string> test_ref:iphone.app }).error.code == "AUTH_APP_PASSWORD_NOT_FOUND"
    AND fn::auth_app_password_revoke({ session: "auth_session:marc", identity: <string> test_ref:claire.identity }).error.code == "AUTH_PERMISSION_DENIED"
    AND fn::auth_app_password_revoke({ session: "auth_session:alpha_admin_ancienne", app_password: <string> test_ref:iphone.app }).error.code == "AUTH_REAUTHENTICATION_REQUIRED"
    AND fn::auth_app_password_revoke({ session: "auth_session:alpha_admin", app_password: <string> test_ref:iphone.app, identity: <string> test_ref:claire.identity }).error.code == "AUTH_INVALID_PARAMETERS"
    AND (SELECT VALUE revoked_at FROM ONLY test_ref:iphone.app) IS NONE;

-- test: révocation par l'administrateur de l'organisation : motif admin, sessions du mot de passe révoquées
{
    LET $r = fn::auth_app_password_revoke({ session: "auth_session:alpha_admin", app_password: <string> test_ref:iphone.app });
    LET $app = (SELECT * FROM ONLY test_ref:iphone.app);
    RETURN $r.data.revoked == 1 AND $app.revoked_reason == "admin"
        AND array::len(SELECT * FROM auth_session WHERE app_password = test_ref:iphone.app AND state = "active") == 0
        AND (SELECT VALUE revoked_reason FROM ONLY auth_session:appareil) == "app_password_revoked";
};

-- test: l'appareil perd ses droits dès l'opération suivante
-- en tant que: appareil
RETURN fn::auth_context({}).error.code == "AUTH_SESSION_REVOKED"
    AND !fn::auth_has_permission({ permission: "mail.mailbox.access", tenant: auth_organization:alpha });

-- préparation: mot de passe expiré et une session qui le désigne encore
{
    CREATE auth_app_password:ancien CONTENT { identity: test_ref:claire.identity, organization: auth_organization:alpha, name: "Ancien", password_hash: "5555555555555555555555555555555555555555555555555555555555555555", permissions: ["mail.mailbox.access"], expires_at: time::now() - 1s };
    CREATE auth_session:ancien_appareil CONTENT { identity: test_ref:claire.identity, kind: "app_password", app_password: auth_app_password:ancien, organization: auth_organization:alpha, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1h };
};

-- test: mot de passe expiré : la session est refusée
-- en tant que: ancien_appareil
RETURN fn::auth_context({}).error.code == "AUTH_SESSION_REVOKED";

-- test: mot de passe expiré : contrôle de la session par l'hôte refusé, vérification refusée sans compter, état calculé
RETURN fn::auth_session_check({ session: "auth_session:ancien_appareil", pv: 1 }).error.code == "AUTH_SESSION_REVOKED"
    AND fn::auth_app_password_verify({ password_hash: "5555555555555555555555555555555555555555555555555555555555555555", identifier: "claire@exemple.fr", protocol: "imap", client: { ip: "192.0.2.40" }, ip_hash: "a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6", identifier_hash: "b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6", access_slot: "a" }).error.code == "AUTH_APP_PASSWORD_INVALID"
    AND array::len(SELECT * FROM auth_login_failure WHERE key_hash IN ["a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6a6", "b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6"]) == 0
    AND fn::auth_app_password_list({ identity: <string> test_ref:claire.identity, organization: "auth_organization:alpha" }).data.map(|$a| [$a.name, $a.state])
        == [["Ancien", "expired"], ["Portable", "revoked"], ["iPhone de Claire", "revoked"]];

-- test: fonctions de la session système refusées à une identité
-- en tant que: claire
RETURN fn::auth_app_password_create({ session: "auth_session:claire", name: "X", permissions: ["mail.mailbox.access"], password_hash: "9999999999999999999999999999999999999999999999999999999999999999" }).error.code == "AUTH_PERMISSION_DENIED"
    AND fn::auth_app_password_verify({ password_hash: "1111111111111111111111111111111111111111111111111111111111111111", identifier: "claire@exemple.fr", protocol: "imap", client: { ip: "203.0.113.5" }, ip_hash: "a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1", identifier_hash: "b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1", access_slot: "a" }).error.code == "AUTH_PERMISSION_DENIED"
    AND fn::auth_app_password_revoke({ session: "auth_session:claire", app_password: <string> test_ref:tablette.app }).error.code == "AUTH_PERMISSION_DENIED"
    AND fn::auth_app_password_session_renew({ session: "auth_session:appareil", access_slot: "a" }).error.code == "AUTH_PERMISSION_DENIED"
    AND fn::auth_app_password_session_open({ app_password: test_ref:tablette.app, access_slot: "a" }).code == "AUTH_PERMISSION_DENIED"
    AND fn::auth_app_password_failure_record({ ip_hash: "a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4", identifier_hash: "b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4" }).error.code == "AUTH_PERMISSION_DENIED"
    AND fn::auth_app_password_log({ app_password: test_ref:tablette.app, protocol: "imap", ip: "192.0.2.1" }).code == "AUTH_PERMISSION_DENIED"
    AND fn::auth_login_failure_count({ kind: "app_password_ip", hash: "a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4", window: 15m, lock: 15m, limit: 1 }).code == "AUTH_PERMISSION_DENIED"
    AND fn::auth_app_password_revoke_all({ identity: test_ref:claire.identity, reason: "owner" }) == 0;

-- test: le titulaire voit toujours ses mots de passe actifs
RETURN (SELECT VALUE revoked_at FROM ONLY test_ref:tablette.app) IS NONE;

-- test: journal direct par la session système : ligne créée puis mise à jour
{
    LET $first = fn::auth_app_password_log({ app_password: test_ref:tablette.app, protocol: "jmap", ip: "192.0.2.50", client_name: "Client JMAP" });
    LET $second = fn::auth_app_password_log({ app_password: test_ref:tablette.app, protocol: "jmap", ip: "192.0.2.50" });
    LET $row = (SELECT * FROM ONLY auth_app_password_use WHERE app_password = test_ref:tablette.app LIMIT 1);
    RETURN $first.code IS NONE AND $second.code IS NONE AND $row.count == 2 AND $row.client_name == "Client JMAP" AND $row.organization == auth_organization:beta;
};

-- test: politique : une organisation ne peut que restreindre ; seuils d'essais et journal réservés à l'installation
RETURN fn::auth_policy_save({ organization: "auth_organization:alpha", app_password: { max_per_identity: 50, session_seconds: 3600 } }).ok
    AND fn::auth_policy_get({ organization: "auth_organization:alpha" }).data.app_password.{ enabled, max_per_identity, session_seconds, ip_max_failures }
        == { enabled: true, max_per_identity: 20, session_seconds: 3600, ip_max_failures: 5 }
    AND fn::auth_policy_save({ organization: "auth_organization:alpha", app_password: { ip_max_failures: 30 } }).error.code == "AUTH_INVALID_PARAMETERS"
    AND fn::auth_policy_save({ organization: "auth_organization:alpha", app_password: { log_days: 30 } }).error.code == "AUTH_INVALID_PARAMETERS"
    AND fn::auth_policy_save({ app_password: { session_seconds: 60 } }).error.code == "AUTH_INVALID_PARAMETERS";

-- test: nouvelle session d'un mot de passe d'alpha : durée de l'organisation
{
    LET $created = fn::auth_app_password_create({ session: "auth_session:claire", name: "Agenda", permissions: ["calendar.access", "mail.mailbox.access"], password_hash: "6666666666666666666666666666666666666666666666666666666666666666" }).data.app_password.id;
    CREATE test_ref:agenda CONTENT { app: $created };
    LET $v = fn::auth_app_password_verify({ password_hash: "6666666666666666666666666666666666666666666666666666666666666666", identifier: "claire@exemple.fr", protocol: "dav", client: { ip: "203.0.113.5" }, ip_hash: "a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1", identifier_hash: "b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1", access_slot: "a" });
    UPDATE test_ref:agenda SET session = $v.data.session;
    RETURN $v.ok AND $v.data.expires_at < time::now() + 61m AND $v.data.expires_at > time::now() + 59m;
};

-- test: désactivés dans l'organisation : sessions app_password révoquées, mots de passe gardés, connexion et création refusées
{
    fn::auth_policy_save({ organization: "auth_organization:alpha", app_password: { enabled: false } });
    RETURN (SELECT VALUE state FROM ONLY test_ref:agenda.session) == "revoked"
        AND (SELECT VALUE revoked_reason FROM ONLY test_ref:agenda.session) == "app_password_disabled"
        AND (SELECT VALUE revoked_at FROM ONLY test_ref:agenda.app) IS NONE
        AND fn::auth_app_password_verify({ password_hash: "6666666666666666666666666666666666666666666666666666666666666666", identifier: "claire@exemple.fr", protocol: "dav", client: { ip: "203.0.113.5" }, ip_hash: "a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1", identifier_hash: "b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1", access_slot: "a" }).error.code == "AUTH_APP_PASSWORD_DISABLED"
        AND fn::auth_app_password_create({ session: "auth_session:claire", name: "X", permissions: ["mail.mailbox.access"], password_hash: "9999999999999999999999999999999999999999999999999999999999999999" }).error.code == "AUTH_APP_PASSWORD_DISABLED"
        AND fn::auth_app_password_verify({ password_hash: "3333333333333333333333333333333333333333333333333333333333333333", identifier: "claire@exemple.fr", protocol: "dav", client: { ip: "203.0.113.5" }, ip_hash: "a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1", identifier_hash: "b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1", access_slot: "a" }).ok;
};

-- test: désactivés dans l'organisation : plus de permission à proposer
-- en tant que: claire
RETURN fn::auth_app_password_eligible({}).error.code == "AUTH_APP_PASSWORD_DISABLED";

-- test: réactivés dans l'organisation : les mots de passe resservent ; l'installation qui désactive l'emporte
{
    fn::auth_policy_save({ organization: "auth_organization:alpha", app_password: { enabled: true } });
    fn::auth_policy_save({ app_password: { enabled: false } });
    LET $installation = fn::auth_app_password_verify({ password_hash: "3333333333333333333333333333333333333333333333333333333333333333", identifier: "claire@exemple.fr", protocol: "dav", client: { ip: "203.0.113.5" }, ip_hash: "a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1", identifier_hash: "b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1", access_slot: "a" });
    LET $beta = fn::auth_policy_get({ organization: "auth_organization:beta" }).data.app_password.enabled;
    fn::auth_policy_save({ app_password: { enabled: true } });
    LET $back = fn::auth_app_password_verify({ password_hash: "6666666666666666666666666666666666666666666666666666666666666666", identifier: "claire@exemple.fr", protocol: "dav", client: { ip: "203.0.113.5" }, ip_hash: "a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1", identifier_hash: "b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1", access_slot: "a" });
    UPDATE test_ref:agenda SET session = $back.data.session;
    RETURN $back.ok AND $installation.error.code == "AUTH_APP_PASSWORD_DISABLED" AND $beta == false;
};

-- test: nombre maximal et durée maximale de l'organisation ; expiration imposée par la politique
{
    fn::auth_policy_save({ organization: "auth_organization:beta", app_password: { max_per_identity: 2, max_lifetime_days: 30 } });
    LET $too_long = fn::auth_app_password_create({ session: "auth_session:claire_beta", name: "Long", permissions: ["calendar.access"], expires_at: time::now() + 40d, password_hash: "7777777777777777777777777777777777777777777777777777777777777777" });
    LET $imposed = fn::auth_app_password_create({ session: "auth_session:claire_beta", name: "Imposé", permissions: ["calendar.access"], password_hash: "7777777777777777777777777777777777777777777777777777777777777777" });
    LET $limit = fn::auth_app_password_create({ session: "auth_session:claire_beta", name: "Trop", permissions: ["calendar.access"], password_hash: "8888888888888888888888888888888888888888888888888888888888888888" });
    RETURN $too_long.error.code == "AUTH_APP_PASSWORD_EXPIRY_TOO_LONG" AND $too_long.error.details.max_lifetime_days == 30
        AND $imposed.data.app_password.expires_at > time::now() + 29d AND $imposed.data.app_password.expires_at < time::now() + 31d
        AND $limit.error.code == "AUTH_APP_PASSWORD_LIMIT_REACHED" AND $limit.error.details.max_per_identity == 2;
};

-- test: permission retirée : droits réduits au renouvellement, puis plus aucun droit, mot de passe gardé
{
    DELETE auth_role_grants WHERE in = auth_role:messagerie AND out = auth_permission:⟨calendar.access⟩;
    LET $reduced = fn::auth_app_password_session_renew({ session: <string> test_ref:agenda.session, access_slot: "a" });
    LET $membership = (SELECT VALUE id FROM ONLY auth_member_of WHERE in = test_ref:claire.identity AND out = auth_organization:alpha LIMIT 1);
    DELETE auth_has_role WHERE in = $membership AND out = auth_role:messagerie;
    LET $none = fn::auth_app_password_verify({ password_hash: "6666666666666666666666666666666666666666666666666666666666666666", identifier: "claire@exemple.fr", protocol: "dav", client: { ip: "203.0.113.5" }, ip_hash: "a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1", identifier_hash: "b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1", access_slot: "a" });
    LET $renewed = fn::auth_app_password_session_renew({ session: <string> test_ref:agenda.session, access_slot: "a" });
    RELATE $membership->auth_has_role->auth_role:messagerie;
    LET $back = fn::auth_app_password_verify({ password_hash: "6666666666666666666666666666666666666666666666666666666666666666", identifier: "claire@exemple.fr", protocol: "dav", client: { ip: "203.0.113.5" }, ip_hash: "a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1", identifier_hash: "b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1", access_slot: "a" });
    RETURN $reduced.data.permissions == ["mail.mailbox.access"] AND $reduced.data.version > 1
        AND $none.error.code == "AUTH_APP_PASSWORD_NO_PERMISSION" AND $renewed.error.code == "AUTH_APP_PASSWORD_NO_PERMISSION"
        AND (SELECT VALUE revoked_at FROM ONLY test_ref:agenda.app) IS NONE
        AND $back.data.permissions == ["mail.mailbox.access"];
};

-- test: identité inactive, organisation suspendue, adhésion suspendue : refus sans révocation
{
    LET $attempt = || fn::auth_app_password_verify({ password_hash: "6666666666666666666666666666666666666666666666666666666666666666", identifier: "claire@exemple.fr", protocol: "dav", client: { ip: "203.0.113.5" }, ip_hash: "a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1", identifier_hash: "b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1", access_slot: "a" });
    UPDATE test_ref:claire.identity SET state = "inactive";
    LET $identity = $attempt();
    UPDATE test_ref:claire.identity SET state = "active";
    UPDATE auth_organization:alpha SET state = "suspended";
    LET $organization = $attempt();
    UPDATE auth_organization:alpha SET state = "active";
    UPDATE auth_member_of SET state = "suspended" WHERE in = test_ref:claire.identity AND out = auth_organization:alpha;
    LET $membership = $attempt();
    UPDATE auth_member_of SET state = "active" WHERE in = test_ref:claire.identity AND out = auth_organization:alpha;
    LET $final = $attempt();
    RETURN $identity.error.code == "AUTH_IDENTITY_INACTIVE" AND $organization.error.code == "AUTH_ORGANIZATION_INACTIVE"
        AND $membership.error.code == "AUTH_NOT_A_MEMBER"
        AND $final.ok AND (SELECT VALUE revoked_at FROM ONLY test_ref:agenda.app) IS NONE;
};

-- test: changement volontaire du mot de passe principal : mots de passe d'application gardés ; récupération du compte : révoqués
{
    LET $voluntary = fn::auth_password_set({ identity: <string> test_ref:claire.identity, secret: "enc:v2:cle-2026:AAAAAAAAAAAAAAAAAAAAAAAA" }).data;
    LET $active_before = array::len(SELECT * FROM auth_app_password WHERE identity = test_ref:claire.identity AND revoked_at IS NONE);
    LET $recovery = fn::auth_password_set({ identity: <string> test_ref:claire.identity, secret: "enc:v2:cle-2026:BBBBBBBBBBBBBBBBBBBBBBBB", revoke_app_passwords: true }).data;
    RETURN $voluntary.app_passwords_revoked == 0 AND $active_before == 4
        AND $recovery.app_passwords_revoked == 4
        AND (SELECT VALUE revoked_reason FROM ONLY test_ref:agenda.app) == "recovery"
        AND (SELECT VALUE revoked_by FROM ONLY test_ref:agenda.app) IS NONE
        AND array::len(SELECT * FROM auth_app_password WHERE identity = test_ref:claire.identity AND revoked_at IS NONE) == 0;
};

-- test: sortie d'une organisation : ses mots de passe d'application dans cette organisation révoqués
{
    -- La suspension d'alpha a révoqué les sessions qui y étaient ouvertes : nouvelle session
    CREATE auth_session:claire_retour CONTENT { identity: test_ref:claire.identity, organization: auth_organization:alpha, idle_expires_at: time::now() + 1h, expires_at: time::now() + 1d };
    LET $beta = fn::auth_app_password_create({ session: "auth_session:claire_beta", name: "Beta 2", permissions: ["mail.mailbox.access"], password_hash: "8888888888888888888888888888888888888888888888888888888888888888" }).data.app_password.id;
    LET $alpha = fn::auth_app_password_create({ session: "auth_session:claire_retour", name: "Alpha 2", permissions: ["mail.mailbox.access"], password_hash: "c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0" }).data.app_password.id;
    DELETE auth_member_of WHERE in = test_ref:claire.identity AND out = auth_organization:beta;
    CREATE test_ref:alpha2 CONTENT { app: $alpha };
    RETURN (SELECT VALUE revoked_reason FROM ONLY $beta) == "membership_removed" AND (SELECT VALUE revoked_at FROM ONLY $alpha) IS NONE;
};

-- test: remise à zéro du double facteur par un administrateur : mots de passe d'application révoqués
{
    LET $reset = fn::auth_mfa_reset({ session: "auth_session:plateforme", identity: <string> test_ref:claire.identity }).data;
    RETURN $reset.app_passwords_revoked == 1 AND (SELECT VALUE revoked_reason FROM ONLY test_ref:alpha2.app) == "mfa_reset"
        AND (SELECT VALUE revoked_by FROM ONLY test_ref:alpha2.app) == auth_identity:plateforme;
};

-- test: révocation de tous les mots de passe d'une identité par l'administrateur de l'installation, et révocation d'office directe
{
    LET $marc = (SELECT VALUE identity FROM ONLY auth_credential_identifier WHERE value = "marc@exemple.fr" LIMIT 1);
    CREATE auth_app_password CONTENT { identity: $marc, organization: auth_organization:alpha, name: "Marc 1", password_hash: "c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1", permissions: ["mail.mailbox.access"] };
    CREATE auth_app_password CONTENT { identity: $marc, organization: auth_organization:alpha, name: "Marc 2", password_hash: "c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2", permissions: ["mail.mailbox.access"] };
    CREATE auth_app_password CONTENT { identity: $marc, organization: auth_organization:beta, name: "Marc 3", password_hash: "c3c3c3c3c3c3c3c3c3c3c3c3c3c3c3c3c3c3c3c3c3c3c3c3c3c3c3c3c3c3c3c3", permissions: ["mail.mailbox.access"] };
    LET $org = fn::auth_app_password_revoke({ session: "auth_session:plateforme", identity: <string> $marc, organization: "auth_organization:beta" });
    LET $all = fn::auth_app_password_revoke({ session: "auth_session:plateforme", identity: <string> $marc });
    RETURN $org.data.revoked == 1 AND $all.data.revoked == 2
        AND (SELECT VALUE revoked_reason FROM auth_app_password WHERE identity = $marc) == ["admin", "admin", "admin"]
        AND fn::auth_app_password_revoke_all({ identity: $marc, reason: "owner" }) == 0;
};

-- test: alertes de révocation publiées avec leur motif, aucun mot de passe ni empreinte dans les charges utiles
{
    LET $reasons = (SELECT VALUE payload.reason FROM event_outbox WHERE event_type = "auth.app_password.revoked");
    LET $payloads = (SELECT VALUE payload FROM event_outbox WHERE string::starts_with(event_type, "auth.app_password."));
    RETURN "owner" IN $reasons AND "admin" IN $reasons AND "recovery" IN $reasons AND "membership_removed" IN $reasons AND "mfa_reset" IN $reasons
        AND array::all($payloads, |$p| $p.password_hash IS NONE AND $p.password IS NONE);
};

-- préparation: mot de passe révoqué il y a longtemps et ligne de journal ancienne
{
    CREATE auth_app_password:vieux CONTENT { identity: test_ref:claire.identity, organization: auth_organization:alpha, name: "Vieux", password_hash: "c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4", permissions: ["mail.mailbox.access"], revoked_at: time::now() - 60d, revoked_reason: "owner" };
    UPSERT type::record("auth_app_password_use", [test_ref:tablette.app, "imap", "192.0.2.99"]) SET app_password = test_ref:tablette.app, identity = test_ref:claire.identity, organization = auth_organization:beta, protocol = "imap", ip = "192.0.2.99", count = 1, last_seen_at = time::now() - 100d;
};

-- test: purge : mot de passe révoqué au-delà de la conservation, journal plus vieux que log_days
{
    LET $r = fn::auth_purge({ limit: 100 }).data;
    RETURN $r.app_passwords >= 1 AND $r.app_password_uses == 1
        AND !record::exists(auth_app_password:vieux) AND record::exists(test_ref:tablette.app)
        AND array::len(SELECT * FROM auth_app_password_use WHERE ip = "192.0.2.99") == 0;
};
