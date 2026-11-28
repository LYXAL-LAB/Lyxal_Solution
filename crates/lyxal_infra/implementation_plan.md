# Plan d'implémentation — `lyxal_infra` : piloter l'hébergeur par API (DNS, DNS inverse, inventaire)

Plan de création d'un module du noyau technique, soumis au CTO (`.agents/AGENTS.md` §3). Aucune
ligne de code avant sa validation. Recherches et sources : [`RECHERCHE_SOURCES.md`](RECHERCHE_SOURCES.md).

> **État : validé par le CTO** (décisions **I1** à **I24** et réponses **Q1** à **Q6** selon les
> recommandations du plan). Précision du CTO sur **I18** : l'achat, le renouvellement et la gestion
> des noms de domaine (titulaire, contacts, transferts, délégation) relèvent d'un **module dédié à
> la gestion complète des noms de domaine**, à concevoir plus tard : le domaine n'est pas la
> propriété de `lyxal_infra`, qui ne gère que le contenu DNS des zones qu'on lui confie, le DNS
> inverse et l'inventaire. Relecture : la clé de `infra_zone` est opaque (aucun nom de domaine dans
> les événements ni les journaux).

| Brique | Ce que c'est, en clair | Lot |
| :--- | :--- | :-: |
| Comptes d'hébergeur | La clé d'API Scaleway rangée dans le coffre-fort (`lyxal_secrets`), jamais ailleurs | 1 |
| Zones DNS | Les domaines dont Lyxal a le droit d'écrire le DNS, choisis un par un par l'administrateur | 1 |
| État désiré | La liste des enregistrements que Lyxal **veut** voir publiés, déclarée par les modules (d'abord le courrier) ou par l'administrateur | 1 |
| Réconciliation | Comparer ce que Lyxal veut à ce qui existe chez l'hébergeur, puis écrire **seulement** ce qui appartient à Lyxal ; jamais toucher ce qu'un humain a créé ; tout noter dans un journal | 1 |
| Vérification | Interroger les serveurs DNS qui font autorité pour savoir quand un enregistrement est vraiment publié | 1 |
| Courrier | `lyxal_mail` déclare lui-même MX, SPF, DKIM et DMARC de ses domaines : la publication des clés DKIM devient automatique | 2 |
| DNS inverse et inventaire | Régler le nom inverse (PTR) des adresses IP ; lire serveurs, IP et blocage SMTP chez Scaleway | 3 |

**Ce que fait le module, une fois les lots 1 et 2 fusionnés.** L'administrateur de la plateforme
range la clé d'une application IAM Scaleway dans le coffre-fort, crée le compte dans Lyxal, et
rattache la zone `exemple.fr` d'abord en mode « observation ». Lyxal lit la zone, montre ce qu'il
ferait, sans rien écrire. L'administrateur passe la zone en mode « géré ». Dès qu'une organisation
active le courrier sur `exemple.fr`, `lyxal_mail` crée ses clés DKIM et déclare MX, SPF, DKIM et
DMARC ; Lyxal les écrit chez Scaleway en une requête, vérifie auprès des serveurs `ns0` et `ns1`
de Scaleway qu'ils répondent, et `lyxal_mail` active les clés. Un enregistrement créé à la main
(par exemple un ancien SPF) n'est jamais remplacé : Lyxal le signale comme conflit et attend la
décision d'un humain. Rien n'est acheté, aucun serveur n'est créé.

Touche : nouveau dossier `crates/lyxal_infra` (SurrealQL et Rust, `MIT OR Apache-2.0`),
`crates/lyxal_core` (une fonction de validation, sur décision **I3**), `apps/lyxal-server`
(hébergement), puis au lot 2 `crates/lyxal_mail` et `apps/lyxal-groupware`. `lyxal_booking/`
n'est pas touché.

Méthode : lecture du dépôt (`AGENTS.md`, règles et skills ; plans des lots 5 et 6 du courrier ;
`crates/lyxal_mail` : `src/dkim.rs`, `functions/mail_dkim.surql`, `README.md`, `ROADMAP.md` ;
`crates/lyxal_notification` : `src/outbound.rs`, `src/provider/{mod,http}.rs`,
`schema/11_notification_integration.surql`, `functions/notification_integration.surql`, seeds ;
`crates/lyxal_secrets/README.md` ; `crates/lyxal_auth/schema/02_auth_organization_domain.surql` ;
`apps/lyxal-groupware/src/services.rs`, `seeds/groupware_tasks.surql`, `build.rs` ;
`apps/lyxal-server/build.rs`, `src/modules/` ; `scripts/ci/check_agpl_isolation.py`,
`check_crypto_dependencies.py` ; `crates/lyxal_core/functions/`), lecture des sources publiques
listées dans `RECHERCHE_SOURCES.md`, et un essai sur SurrealDB 3.3.4 (`string::is_domain` refuse
`_dmarc.exemple.fr`, §2.3). **Rien n'a été compilé ; aucun appel n'a été fait chez Scaleway.**

## 1. Nom et place du module

**Nom proposé : `lyxal_infra`** (décision **I1**). Préfixes : tables `infra_*`, fonctions
`fn::infra_*`, erreurs `INFRA_*`, événements `infra.<entité>.<action>`, permissions `infra.*`.

* `lyxal_dns` serait trop étroit : le DNS inverse est une propriété de l'**adresse IP**, pas d'une
  zone ; l'inventaire des serveurs et l'état du blocage SMTP ne sont pas du DNS ; chez Scaleway
  comme chez OVHcloud, **une même clé** couvre DNS, IP et serveurs. Un seul module tient donc
  le compte, les limites de débit et le journal de l'hébergeur.
* `lyxal_infra` n'est pas un outil de déploiement : il ne pilote que ce qui sert au
  fonctionnement de Lyxal (DNS, DNS inverse, inventaire en lecture). Créer des serveurs ou acheter
  des domaines n'entre pas en V1 (§13).

**Place (`AGENTS.md` §6)** : noyau technique, après `lyxal_notification` et avant
`lyxal_mail_proto` / `lyxal_mail` : il dépend de `lyxal_auth`, `lyxal_secrets`,
`lyxal_scheduler`, `lyxal_event` ; `lyxal_mail` dépend de lui (lot 2), jamais l'inverse. Licence
**`MIT OR Apache-2.0`** (celle du workspace) ; hébergé par `lyxal-server`. Il ne dépend
d'**aucun** paquet AGPL (`check_agpl_isolation.py` le vérifie) ; le sens inverse
(`lyxal_mail` → `lyxal_infra`) est permis.

**Nature** : hybride. Le métier (état désiré, propriété, conflits, plan de changements, journal,
droits) est en SurrealQL ; le dialogue avec l'hébergeur (HTTP, TLS, format de chaque API) et
l'interrogation du DNS sont en Rust (`.agents/rules/…` §10).

## 2. Bilan de réutilisation (`AGENTS.md` §3, §5.7)

### 2.1. `lyxal_core` (fonctions présentes, vérifiées dans `crates/lyxal_core/functions/`)

| Besoin | Fonction ou règle du Core |
| :--- | :--- |
| Entrées des fonctions d'administration | `fn::validation_object_execute`, `fn::sanitize_object_execute` |
| Entrées des fonctions appelées souvent (déclaration par un module, résultats du worker) | `fn::validation_fields_execute` (contrôles par fermetures) |
| Identifiants | `fn::validation_record`, `fn::validation_identifier` (clé de compte, `subject`), `fn::validation_slug`, `fn::validation_snake_case_name` (`owner` = identifiant de module) |
| Nom d'une zone, cible d'un MX ou d'un CNAME (sans tiret bas) | `fn::validation_domain(…, true)`, `fn::sanitize_domain`, `fn::validation_hostname` |
| Adresses A / AAAA, adresse d'une IP | `fn::validation_ip($v, "v4" / "v6")` |
| Valeurs TXT | `fn::validation_ascii`, `fn::validation_required_string` (longueur), `fn::security_detect_header_injection` (aucun CR ni LF) |
| Bornes, états, listes | `fn::validation_integer`, `fn::validation_integer_range`, `fn::validation_enum`, `fn::validation_array_length`, `fn::validation_max_serialized_length`, `fn::validation_language_code` |
| Journal chaîné | `fn::security_audit_entry`, `fn::security_audit_verify` |
| Empreinte d'un plan (approbation) | `fn::security_hash_object` |
| Journal sans donnée personnelle | `fn::security_redact_ip` |

### 2.2. Autres modules

| Module | Ce qui est réutilisé |
| :--- | :--- |
| `lyxal_secrets` | Clé d'API rangée sous `infra/<clé du compte>` (installation), lue par `SecretsClient` (session système, consommateur annoncé `lyxal_infra`, lecture tracée) ; droit de l'appelant contrôlé à la création du compte comme `fn::notification_integration_secret_check` (`fn::secrets_secret_get` au nom de l'appelant, `secrets.installation.manage`). Plus tard : `SecretRotator` pour la rotation des clés (§13) |
| `lyxal_scheduler` | Tâches `handler` (code Rust dans `lyxal-server`) : réconciliation d'une zone, passage périodique, vérification, inventaire (lot 3) ; tâche `function` de purge ; `fn::scheduler_run_enqueue` pour lancer une zone dès qu'une déclaration change (comme `fn::notification_wait_schedule`) |
| `lyxal_event` | `fn::event_publish` vérifié dans les `DEFINE EVENT` (§5.5) |
| `lyxal_auth` | Permissions déclarées par seed, `fn::auth_has_permission`, `fn::auth_session_valid` (session système), rôle `auth_role:platform_admin` |
| `lyxal_crypto` | Aucune primitive nouvelle. `SecretString` pour la clé en mémoire ; TLS du client HTTP par `tls_client_config(WebPki)` (décision **I8**) |
| `lyxal_runtime` | `LyxalModule`, `ModuleHealthCheck` ; aucun `LyxalWorker` propre (décision **I10**) |

### 2.3. Fonctions Core manquantes (signalées, **non ajoutées**)

**`fn::validation_dns_name($value, $options)`** (dossier `validations/`). Un nom DNS de service
contient des tirets bas : `_dmarc.exemple.fr`, `lyx202611r._domainkey.exemple.fr`,
`_smtp._tls.exemple.fr`, `_mta-sts.exemple.fr`. Essai sur SurrealDB 3.3.4 :
`string::is_domain("_dmarc.example.com")` rend `false` (de même pour les deux autres), alors que
`example.com` et `xn--bcher-kva.example` rendent `true`. `fn::validation_domain` repose sur
`string::is_domain` : il refuse donc ces noms. Besoin générique (le courrier, les certificats
ACME `_acme-challenge` et tout module DNS en auront besoin), sans logique métier. Contrat proposé :
étiquettes de 1 à 63 octets en lettres ASCII, chiffres, tiret (jamais au bord) et tiret bas,
253 octets au plus, au moins deux étiquettes, forme A-label seulement ; options
`allow_underscore` (vrai par défaut), `allow_wildcard` (faux : `*` seulement en première
étiquette) ; résultat habituel `{ valid, value (minuscules, sans point final), code, details }`.
Décision **I3** ; sans elle, le lot 1 ne peut pas démarrer (aucune validation locale n'est
permise, §5.7.8).

**`lyxal_crypto`** : aucun besoin pour Scaleway. Pour un futur fournisseur OVHcloud, la signature
historique demande SHA-1 (non offert) : la voie recommandée (comptes de service OAuth2) n'en a pas
besoin (décision **I22**).

### 2.4. Client HTTP sortant contrôlé de `lyxal_notification`

`lyxal_notification::OutboundClient` (`src/outbound.rs`) protège contre la falsification de
requêtes côté serveur (SSRF) les appels vers une **adresse choisie par une personne** : HTTPS
seulement, hôte autorisé, résolution vérifiée (aucune adresse privée, de boucle locale, de
métadonnées), connexion à l'adresse vérifiée, aucune redirection. Les API des fournisseurs
d'e-mail, elles, ont des **adresses fixées dans le code** (`src/provider/http.rs`,
`ApiEndpoints`) et n'en ont pas besoin.

`lyxal_infra` est dans le second cas : `https://api.scaleway.com` est une constante, aucune
valeur de la base ni d'une personne ne choisit l'hôte. **Recommandation (décision I9)** : ne pas
réutiliser ni déplacer `OutboundClient` maintenant ; écrire dans `lyxal_infra` un client à
adresses fixes sur le modèle de `ApiEndpoints` (constantes, `local()` réservé aux essais sur la
boucle locale). Le jour où un fournisseur aura une adresse choisie par une personne (serveur
PowerDNS, RFC 2136, webhook de fournisseur), `OutboundClient` et `forbidden_ip` seront **déplacés**
dans un crate commun permissif (par exemple `lyxal_outbound`), dans le même changement que leurs
appelants (`AGENTS.md` §0.3, §5.1), et non recopiés.

## 3. Modèle : état désiré, propriété, réconciliation

### 3.1. Principes (décisions **I4** à **I7**)

1. **L'état désiré est déclaré, jamais deviné.** Un enregistrement voulu (`infra_record`) a un
   **propriétaire** (`owner` : identifiant de module, par exemple `lyxal_mail`, ou `manual` pour
   l'administrateur) et un **sujet** (`subject` : clé opaque choisie par le propriétaire, sans nom
   de domaine ni adresse, par exemple `mail_domain:01JD…`). Une déclaration remplace **tout**
   l'ensemble du couple (propriétaire, sujet) : ce qui n'y figure plus sera retiré.
2. **Propriété prouvée.** Lyxal ne modifie ou ne supprime chez l'hébergeur que les
   enregistrements qu'il a lui-même créés : identifiant du fournisseur noté en base au moment de
   l'écriture, et, quand le fournisseur a un champ de commentaire (Scaleway : `comment`), la
   marque `lyxal:<clé de l'enregistrement>` (sert à retrouver ses propres écritures après un
   arrêt brutal ou une perte de la base). Pas de TXT de propriété à la manière d'external-dns :
   ils encombrent la zone (décision **I5**).
3. **Jamais d'écrasement d'un humain** (équivalent permanent de `NO_PURGE` de DNSControl) :
   * enregistrement étranger qui gêne une déclaration → état `conflict`, rien n'est écrit ;
   * enregistrement de Lyxal **modifié** par un humain → `conflict` (`drift_modified`), rien
     n'est réécrit ;
   * enregistrement de Lyxal **supprimé** par un humain → recréé, noté (`drift_deleted`) et
     signalé (décision **I6**) ;
   * un conflit ne se lève que par une décision humaine (`fn::infra_record_conflict_resolve` :
     `take_over` remplace la valeur étrangère, noté au journal avec son auteur ; `yield` laisse
     la valeur humaine et met l'enregistrement de Lyxal en sommeil).
4. **Règles de cohabitation par jeu (nom, type)** : `exclusive` (Lyxal veut tout le jeu : MX,
   DKIM, A d'un hôte) ou `shared` (Lyxal n'ajoute que ses valeurs). Pour un TXT partagé, un
   **préfixe unique** facultatif (`v=spf1`, `v=DMARC1`, `v=STSv1`, `v=TLSRPTv1`) : une valeur
   étrangère qui commence par le même préfixe est un conflit (deux SPF casseraient le courrier).
   Un CNAME ne cohabite avec rien.
5. **Prudence (idée d'octoDNS)** : un passage qui supprimerait plus de 10 enregistrements, ou
   plus de 30 % des enregistrements de Lyxal dans la zone, n'est pas appliqué ; la zone passe en
   `blocked` et attend `fn::infra_zone_plan_approve` avec l'empreinte exacte du plan montré
   (décision **I7**).
6. **Mode observation** : une zone rattachée commence en `observe` : le plan est calculé et
   montré, rien n'est écrit. L'administrateur la passe en `managed`.
7. **Journal** : toute intention d'écriture est notée **avant** l'appel (`sent`), puis son issue
   (`done`, `failed`) ; entrées chaînées (`fn::security_audit_entry`), jamais modifiées.

### 3.2. Une passe de réconciliation d'une zone

Exécutée par la tâche `infra.zone_reconcile` (§6.3), sous réservation de la zone :

1. `fn::infra_zone_claim` : réservation (jeton, 5 minutes, renouvelée) ; une autre passe en cours
   → rien.
2. Rust : lecture de la zone chez l'hébergeur (statut, serveurs de noms) et de **tous** ses
   enregistrements (pages de 1 000), traduits en **forme canonique** (§3.3).
3. `fn::infra_zone_observe` : la photo est écrite par différence dans `infra_zone_record`
   (seules les lignes changées sont écrites) ; les marques `lyxal:` et les identifiants connus
   rattachent chaque ligne à son `infra_record`.
4. `fn::infra_zone_plan` (SurrealQL, testable au banc) : compare voulu et observé, rend la liste
   des changements (`add`, `set` par identifiant, `delete` par identifiant) et des conflits, et
   applique les règles 3 à 5. Zone `observe` ou `blocked` : le plan est rangé
   (`infra_zone.last_plan`, empreinte) et la passe s'arrête.
5. `fn::infra_zone_apply_begin` : entrées `sent` du journal, sous garde du jeton.
6. Rust : **une** requête `PATCH …/records` pour tous les changements (Scaleway), avec
   `disallow_new_zone_creation: true`.
7. `fn::infra_zone_apply_result` : identifiants rendus, états (`written`), entrées `done` ou
   `failed`, événements, prochaine passe. Un arrêt entre 6 et 7 laisse des entrées `sent` : la
   passe suivante relit la zone et retrouve les enregistrements écrits par leur marque
   `lyxal:` et leur valeur exacte (aucun doublon d'ajout).
8. Vérification (§3.4) des enregistrements `written`, puis `fn::infra_zone_release`.

Une passe qui ne trouve aucun écart n'écrit qu'une date (`reconciled_at`).

### 3.3. Forme canonique des valeurs

Comparaison par égalité de chaînes après mise en forme canonique, faite **en Rust par
l'adaptateur** du fournisseur (format propre à chaque API) et **contrôlée en SurrealQL** à la
déclaration :

| Type | Forme canonique | Contrôle à la déclaration |
| :--- | :--- | :--- |
| A | IPv4 pointée | `fn::validation_ip(…, "v4")` |
| AAAA | IPv6 compressée, minuscules | `fn::validation_ip(…, "v6")` |
| CNAME | nom complet en minuscules, sans point final | `fn::validation_dns_name` (I3) |
| MX | `"<priorité> <cible>"`, priorité 0 à 65 535 | priorité : `fn::validation_integer` ; cible : `fn::validation_domain` |
| TXT | texte logique non découpé, ASCII imprimable, 4 096 octets au plus | `fn::validation_ascii`, longueur, `fn::security_detect_header_injection` |
| SRV | `"<priorité> <poids> <port> <cible>"` | entiers et nom |
| CAA | `"<drapeaux> <balise> \"<valeur>\""`, balises `issue`, `issuewild`, `iodef` | `fn::validation_enum`, longueur |

Types de la V1 : A, AAAA, CNAME, MX, TXT, SRV, CAA (TLSA viendra avec DANE, lot 7 du courrier).
TTL de 60 à 86 400 s, défaut des réglages (3 600). L'adaptateur Scaleway écrit un TXT entre
guillemets et le découpe en chaînes de 255 octets au plus ; il relit les deux formes.

### 3.4. Vérification de la publication

Un enregistrement `written` devient `published` quand **tous** les serveurs faisant autorité de
la zone le servent : serveurs de noms lus chez l'hébergeur (`ns` de la zone), adresses résolues,
puis question directe à chacun sans récursion (`hickory-resolver` 0.26, déjà dans l'arbre par
`lyxal_auth` et `lyxal_mail`, cache coupé). Essais espacés (30 s, 1, 2, 5, 10 min, puis toutes
les 30 min) ; au-delà de 24 h, `failed` (`INFRA_DNS_NOT_PUBLISHED`). Le **rattachement** de la
zone est aussi contrôlé : si les serveurs de noms annoncés par la zone parente ne sont pas ceux
de l'hébergeur, la zone est `not_delegated` (rien de ce qui est écrit n'est visible sur
Internet) ; la sonde le signale et les enregistrements restent `written`.

## 4. SurrealQL (`crates/lyxal_infra/`)

Une seule migration `migrations/0001_initial.surql` réécrite en place (§0.3), version `0.1.0`.
Règles de SurrealDB 3.3.4 tenues (skill `lyxal-surrealdb`) : jamais `LET $event`, `$before`,
`$after`, `$value`, `$input`, `$parent`, `$self` ni `$this` ; lectures bornées ; écriture
principale vérifiée (`INFRA_WRITE_FORBIDDEN`). Tables `TYPE NORMAL SCHEMAFULL`, aucune
`TYPE RELATION`.

### 4.1. Manifeste

```toml
manifest_version = 1
id = "lyxal_infra"
name = "Lyxal Infra"
version = "0.1.0"
description = "Pilotage de l'hébergeur par API : comptes, zones DNS, état désiré et réconciliation, vérification de la publication, DNS inverse et inventaire"
capabilities = ["database", "events", "workers"]

[runtime]
min_version = ">=0.1.0"

[[dependencies]]
id = "lyxal_core"
version = ">=0.1.0"
# … de même : lyxal_error, lyxal_event, lyxal_auth, lyxal_secrets, lyxal_scheduler

[resources]
schemas = ["schema/01_infra_settings.surql", "schema/02_infra_account.surql", "schema/03_infra_zone.surql",
           "schema/04_infra_record.surql", "schema/05_infra_zone_record.surql", "schema/06_infra_change.surql"]
           # lot 3 : "schema/07_infra_ip.surql", "schema/08_infra_server.surql"
functions = ["functions/infra_access.surql", "functions/infra_settings.surql", "functions/infra_account.surql",
             "functions/infra_zone.surql", "functions/infra_record.surql", "functions/infra_plan.surql",
             "functions/infra_worker.surql", "functions/infra_change.surql"]
error_definitions = ["error/parametres/error_parametres.surql", "error/comptes/error_comptes.surql",
                     "error/zones/error_zones.surql", "error/enregistrements/error_enregistrements.surql",
                     "error/fournisseurs/error_fournisseurs.surql"]
events = ["events/infra_events.surql"]
seeds = ["seeds/infra_auth.surql", "seeds/infra_initial.surql"]
migrations = ["migrations/0001_initial.surql"]
```

### 4.2. Tables

| Table | Contenu |
| :--- | :--- |
| `infra_settings` | Fiche unique `infra_settings:installation` : `reconcile_minutes` (15), `default_ttl` (3 600), `min_ttl` (60), `max_deletions` (10), `max_deletion_percent` (30), `verify_timeout_hours` (24), `requests_per_second` (5, par compte), `change_retention_days` (400), `released_retention_days` (30) |
| `infra_account` | `infra_account:⟨<clé>⟩` ; `key` (slug, 64), `name`, `provider` (`scaleway` ; plus tard `ovhcloud`, `bunny`), `credentials_path` (commence par `infra/`, jamais une valeur), `settings` (Scaleway : `project_id` UUID, `organization_id` facultatif, `default_zone` `fr-par-1`, `default_region` `fr-par`), `state` (`active`, `disabled`, `failing`), `last_test` { `at`, `ok`, `code` }, `test_requested_at`, `discovered_zones` (noms et statuts rendus par le dernier essai, 1 000 au plus), `created_at`, `updated_at` |
| `infra_zone` | `infra_zone:<UUID v7>` (clé opaque : la clé figure dans les événements et les journaux, jamais le nom) ; `account`, `name` (zone, A-label, unique par index, lu sous les permissions de la table), `provider_ref` (nom de zone chez le fournisseur), `mode` (`observe`, `managed`), `tenants` (organisations dont les déclarations sont acceptées ; vide = enregistrements de l'installation seulement), `state` (`ok`, `blocked`, `not_delegated`, `failing`, `pending_provider`), `nameservers` (observés), `delegated`, `claim`, `locked_until` (compte de service seulement), `last_plan` { `hash`, `at`, `changes`, `conflicts`, `deletions` }, `approved_plan_hash`, `reconcile_requested_at`, `reconciled_at`, `next_reconcile_at`, `last_error` { `code`, `at` }, `observed_hash` ; zone emboîtée dans une autre zone rattachée refusée |
| `infra_record` | Enregistrement voulu. `infra_record:⟨<empreinte BLAKE3 tronquée de owner+subject+fqdn+type>⟩` ; `owner`, `subject`, `tenant` (`option<record<auth_organization>>`), `zone` (`option` : aucune zone rattachée ne couvre le nom → `unmanaged`), `fqdn`, `type`, `values` (1 à 20, canoniques, triées), `ttl`, `mode` (`exclusive`, `shared`), `singleton_prefix` (`option`), `state` (`unmanaged`, `pending`, `written`, `published`, `conflict`, `yielded`, `failed`, `releasing`, `released`), `conflict` { `reason` (`foreign_value`, `foreign_singleton`, `cname`, `drift_modified`), `observed` (valeurs, 4 Kio au plus), `at` }, `resolution` (`take_over` / `yield`, auteur, date), `provider_ids` (identifiants des valeurs écrites), `applied_values`, `written_at`, `published_at`, `verify_attempts`, `next_verify_at`, `error` { `code`, `at` }, `declared_at`, `updated_at` |
| `infra_zone_record` | Photo de la zone chez le fournisseur : `infra_zone_record:⟨<clé de zone>_<identifiant du fournisseur>⟩` ; `zone`, `provider_id`, `fqdn`, `type`, `value` (canonique), `ttl`, `comment`, `record` (`option<record<infra_record>>` : à Lyxal), `seen_at` ; écrite par le worker seulement |
| `infra_change` | Journal : `infra_change:⟨<UUID v7>⟩` ; `rank` (unique), `zone`, `record` (`option`), `action` (`add`, `set`, `delete`, `conflict`, `resolve`, `approve`, `drift_deleted`, `attach`, `detach`, `mode` ; lot 3 : `reverse_set`), `state` (`sent`, `done`, `failed`, `noted`), `before`, `after` (valeurs, jamais de secret), `actor` (identité, compte de service ou `system`), `provider_status`, `code`, `hash`, `previous_hash`, `created_at` ; champs figés après `done` / `failed` |

Index : `infra_record(owner, subject)`, `infra_record(zone, fqdn, type)`, `infra_record(state,
next_verify_at)`, `infra_zone(next_reconcile_at)`, `infra_zone_record(zone, fqdn, type)`,
`infra_change(rank)` unique, `infra_change(zone, created_at)`.

**Permissions** : lecture de tout par `infra.read` (installation) ; `infra_record` lisible aussi
par `infra.records.declare` pour les seuls enregistrements de son propriétaire (règle par fiche
sur `owner` non applicable sans identité de module : la lecture passe par
`fn::infra_records_status`) ; aucune écriture directe hors fonctions et compte de service, gardes
(`DEFINE EVENT … THROW`) sur les états, les champs figés, le jeton de réservation et le journal.

### 4.3. Permissions (`seeds/infra_auth.surql`, rejouable)

| Permission | Portée | Donne | Rôle d'office |
| :--- | :--- | :--- | :--- |
| `infra.read` | installation | lire comptes (sans secret), zones, enregistrements, photo, journal | `platform_admin` |
| `infra.manage` | installation | comptes, zones (rattacher, mode, détacher), enregistrements `manual`, conflits, approbation des plans, réglages | `platform_admin` |
| `infra.records.declare` | installation | déclarer, retirer et lire **ses** enregistrements par le contrat public (§4.4) | aucun (comptes de service ; la session système d'un hôte n'a pas à le prouver) |
| `infra.worker` | installation | fonctions du worker | aucun (compte de service, session système) |

Une organisation n'a aucun droit en V1 : l'état de ses enregistrements lui parvient par le module
qui les a déclarés (le courrier, §8). Décision **I11**.

### 4.4. Fonctions publiques

Toutes `fn::infra_<action>($params: object)`, résultat `fn::result_ok` / `fn::error_result`,
`COMMENT` documentant le contrat, moins de 300 lignes (découpe en fonctions internes
`fn::infra__*` sinon).

**Contrat public des modules** (stable, documenté dans le `README.md`) :

| Fonction | Paramètres → résultat | Droit |
| :--- | :--- | :--- |
| `fn::infra_records_declare` | `{ owner, subject, tenant?, records: [0..50 × { fqdn, type, values: [1..20], ttl?, mode, singleton_prefix? }], language }` → `{ items: [{ record, fqdn, type, state, managed }], changed }` ; remplace l'ensemble (owner, subject) ; une liste vide retire tout ; refus : nom couvert par une zone qui n'accepte pas `tenant` (`INFRA_RECORD_TENANT_REFUSED`), même (fqdn, type) déjà `exclusive` chez un autre propriétaire (`INFRA_RECORD_OWNED`), CNAME avec autre chose (`INFRA_RECORD_CNAME_CONFLICT`) ; une déclaration identique n'écrit rien (`changed: false`) ; un changement demande une passe de la zone (`fn::scheduler_run_enqueue`, unique par zone pendant 1 min, départ dans 10 s) | `infra.records.declare`, `infra.manage` (owner `manual` seulement), session système |
| `fn::infra_records_release` | `{ owner, subject, keep_at_provider: false, language }` → `{ released }` : `releasing` (suppression chez le fournisseur à la passe suivante, seulement si la valeur est encore celle écrite par Lyxal) ou oubli simple | idem |
| `fn::infra_records_status` | `{ owner, subjects: [1..500], language }` → `{ items: [{ subject, record, fqdn, type, state, conflict_reason, published_at, error_code }] }` | idem |
| `fn::infra_records_subjects` | `{ owner, after?, limit (1..1000), language }` → `{ subjects, next }` (sert au propriétaire à retirer les sujets disparus) | idem |

**Administration** (objet entier contrôlé par `fn::validation_object_execute`) :

| Fonction | Rôle | Droit |
| :--- | :--- | :--- |
| `fn::infra_account_create`, `_update`, `_get`, `_list`, `_delete` | Compte d'hébergeur ; secret contrôlé comme pour `lyxal_notification` (existe, même portée, lisible par l'appelant) ; suppression refusée tant qu'une zone l'utilise (`INFRA_ACCOUNT_IN_USE`) | `infra.manage` (`_get`, `_list` : `infra.read`) |
| `fn::infra_account_test_request` | Demande un essai (le worker lit les zones visibles et les range dans `discovered_zones`) | `infra.manage` |
| `fn::infra_zone_attach` | `{ account, name, mode: "observe", tenants: [] }` : zone visible du compte (`discovered_zones`), non emboîtée | `infra.manage` |
| `fn::infra_zone_update` | `mode`, `tenants` | `infra.manage` |
| `fn::infra_zone_detach` | Refusé tant que des enregistrements de Lyxal y sont `written` / `published` (`INFRA_ZONE_HAS_RECORDS`) : on les retire d'abord, ou `forget: true` (ils restent chez le fournisseur, Lyxal les oublie, noté) | `infra.manage` |
| `fn::infra_zone_get`, `_list` | Zone, dernier plan, compteurs par état | `infra.read` |
| `fn::infra_zone_reconcile_request` | Passe demandée tout de suite | `infra.manage` |
| `fn::infra_zone_plan_approve` | `{ zone, plan_hash }` : applique une fois un plan `blocked` ; empreinte différente → `INFRA_ZONE_PLAN_STALE` | `infra.manage` |
| `fn::infra_zone_records` | Photo de la zone (paginée, filtre propriétaire : Lyxal / humain) | `infra.read` |
| `fn::infra_record_list`, `_get` | Enregistrements voulus (filtres zone, état, propriétaire) | `infra.read` |
| `fn::infra_record_conflict_resolve` | `{ record, action: "take_over" | "yield" }` ; `take_over` sur un `exclusive` remplace la valeur étrangère à la passe suivante | `infra.manage` |
| `fn::infra_change_list`, `fn::infra_change_verify` | Journal (paginé) ; contrôle de la chaîne (`fn::security_audit_verify`) | `infra.read` |
| `fn::infra_settings_get`, `_update` | Réglages | `infra.read` / `infra.manage` |

**Worker** (`fn::validation_fields_execute` ; droit `infra.worker` ou session système) :
`fn::infra_account_due` (comptes à essayer), `fn::infra_account_test_result`,
`fn::infra_zone_due` (zones dont `next_reconcile_at` ou `reconcile_requested_at` est échu),
`fn::infra_zone_claim`, `fn::infra_zone_renew`, `fn::infra_zone_observe`, `fn::infra_zone_plan`,
`fn::infra_zone_apply_begin`, `fn::infra_zone_apply_result`, `fn::infra_zone_release`,
`fn::infra_records_to_verify`, `fn::infra_record_verify_result`, `fn::infra_purge` (journal au-delà
de `change_retention_days`, sauf la dernière entrée de chaque zone, et enregistrements `released`).
Toute écriture du worker exige le jeton de réservation de la zone (`INFRA_ZONE_CLAIM_LOST`).

### 4.5. Événements (`events/infra_events.surql`)

Publiés par `DEFINE EVENT` sur `infra_record` et `infra_zone`, par `fn::event_publish` vérifié
(`THROW` sinon). **Charges sans nom de domaine, sans adresse, sans valeur** : identifiants et
codes seulement (décision **I12**).

| Événement | Quand | Charge |
| :--- | :--- | :--- |
| `infra.record.published` | `written` → `published` | `record`, `owner`, `subject`, `zone` |
| `infra.record.conflict` | entrée en `conflict` | `record`, `owner`, `subject`, `zone`, `reason` |
| `infra.record.failed` | entrée en `failed` | `record`, `owner`, `subject`, `code` |
| `infra.zone.blocked` | zone `blocked`, `not_delegated` ou `failing` | `zone`, `state`, `code`, `deletions` |

`lyxal_infra` ne connaît aucun consommateur. `lyxal_notification` pourra prévenir
l'administrateur de la plateforme (parcours à créer dans son propre plan).

### 4.6. Erreurs `INFRA_*` (`error/<thème>/`, rejouables, `fr` et `en`)

| Code | HTTP | À réessayer | Sens |
| :--- | :-: | :-: | :--- |
| `INFRA_INVALID_PARAMETERS` | 400 | non | Paramètres refusés par le Core (`fields`) |
| `INFRA_PERMISSION_DENIED` | 403 | non | Droit manquant |
| `INFRA_WRITE_FORBIDDEN` | 403 | non | Écriture filtrée par les permissions de table |
| `INFRA_SETTINGS_INVALID` | 400 | non | Réglage hors bornes |
| `INFRA_ACCOUNT_NOT_FOUND`, `INFRA_ACCOUNT_EXISTS`, `INFRA_ACCOUNT_IN_USE` | 404 / 409 / 409 | non | Comptes |
| `INFRA_ACCOUNT_SECRET_INVALID` | 400 | non | Secret absent, hors `infra/`, ou illisible par l'appelant |
| `INFRA_ZONE_NOT_FOUND`, `INFRA_ZONE_EXISTS`, `INFRA_ZONE_OVERLAP`, `INFRA_ZONE_NOT_VISIBLE` | 404 / 409 / 409 / 400 | non | Zones ; `NOT_VISIBLE` : absente de la liste rendue par le compte |
| `INFRA_ZONE_HAS_RECORDS` | 409 | non | Détachement refusé |
| `INFRA_ZONE_PLAN_STALE` | 409 | non | Le plan a changé depuis son affichage |
| `INFRA_ZONE_CLAIM_LOST` | 409 | oui | Réservation perdue (autre passe) |
| `INFRA_RECORD_NOT_FOUND`, `INFRA_RECORD_OWNED`, `INFRA_RECORD_CNAME_CONFLICT`, `INFRA_RECORD_TENANT_REFUSED`, `INFRA_RECORD_LIMIT` | 404 / 409 / 409 / 403 / 400 | non | Enregistrements voulus |
| `INFRA_PROVIDER_AUTH` | 502 | non | Clé refusée par l'hébergeur (`denied_authentication`, `permissions_denied`) : compte `failing` |
| `INFRA_PROVIDER_REJECTED` | 502 | non | Changement refusé (`invalid_arguments`, `precondition_failed`, 4xx) |
| `INFRA_PROVIDER_NOT_FOUND` | 502 | non | Zone ou IP disparue chez l'hébergeur |
| `INFRA_PROVIDER_QUOTA` | 502 | non | `quotas_exceeded` |
| `INFRA_PROVIDER_RATE_LIMITED` | 503 | oui | `429` |
| `INFRA_PROVIDER_UNAVAILABLE` | 503 | oui | `5xx`, `transient_state`, `locked`, réseau, délai |
| `INFRA_PROVIDER_RESPONSE_INVALID` | 502 | oui | Réponse illisible |
| `INFRA_CREDENTIALS_UNAVAILABLE` | 503 | oui | Clé maîtresse absente ou secret illisible |
| `INFRA_DNS_UNAVAILABLE` | 503 | oui | Serveurs faisant autorité injoignables |
| `INFRA_DNS_NOT_PUBLISHED` | 504 | non | Non servi après `verify_timeout_hours` |
| lot 3 : `INFRA_IP_NOT_FOUND`, `INFRA_IP_FORWARD_MISSING`, `INFRA_IP_OWNED` | 404 / 409 / 409 | non / oui / non | DNS inverse |

### 4.7. Seeds

`seeds/infra_auth.surql` (permissions et rôle, §4.3) ; `seeds/infra_initial.surql` : réglages
`infra_settings:installation`, tâches de `lyxal_scheduler` (§6.3) déclarées comme le fait
`lyxal_notification` (`IF !record::exists(scheduler_task:⟨…⟩) THEN ( CREATE … ) END;`, tous les
champs donnés).

## 5. Contrat Rust des fournisseurs (`crates/lyxal_infra/src/`)

```text
src/
├── lib.rs, module.rs (InfraModule), health.rs (InfraHealthCheck), metrics.rs (InfraMetrics), error.rs
├── store.rs            InfraStore : LyxalSurrealCall, un wrapper d'une ligne par fonction
├── models/             account.rs, zone.rs, record.rs, change.rs, settings.rs, types.rs, mod.rs
├── provider/           mod.rs (traits, ProviderError, ProviderRegistry), http.rs (client à adresses fixes),
│                       canonical.rs, scaleway/{mod,dns,instance}.rs, fake.rs (cfg(test) et feature « test-provider »)
├── reconcile.rs        Reconciler : une passe de zone (§3.2)
├── verify.rs           AuthoritativeVerifier (hickory-resolver), DnsProbe (trait), StaticProbe (essais)
└── tasks.rs            TaskHandler de lyxal_scheduler (§6.3)
```

### 5.1. Traits

```rust
/// Fournisseur DNS d'un compte (une instance par compte, clé lue du coffre-fort).
#[async_trait]
pub trait DnsProvider: Send + Sync {
    fn kind(&self) -> ProviderKind;                      // Scaleway, …
    fn capabilities(&self) -> DnsCapabilities;           // comment: bool, batch: bool, types acceptés, txt_chunk: usize
    async fn probe(&self) -> Result<AccountProbe, ProviderError>;              // clé valide, zones visibles
    async fn zone(&self, zone: &ZoneRef) -> Result<ProviderZone, ProviderError>; // statut, serveurs de noms
    async fn records(&self, zone: &ZoneRef) -> Result<Vec<ObservedRecord>, ProviderError>; // canoniques
    async fn apply(&self, zone: &ZoneRef, changes: &[PlannedChange]) -> Result<ApplyOutcome, ProviderError>;
}

/// DNS inverse et inventaire (lot 3).
#[async_trait]
pub trait HostingProvider: Send + Sync {
    async fn ips(&self) -> Result<Vec<ProviderIp>, ProviderError>;
    async fn set_reverse(&self, ip: &ProviderIpRef, reverse: Option<&str>) -> Result<(), ProviderError>;
    async fn servers(&self) -> Result<Vec<ProviderServer>, ProviderError>;   // dont smtp_blocked
}
```

`ProviderError { class: Permanent | Transient | RateLimited { retry_after } | Auth, code:
&'static str (INFRA_PROVIDER_*), detail: String }` : `detail` ne contient ni clé, ni corps de
réponse, ni nom de domaine (identifiant de zone et code HTTP seulement). `ApplyOutcome` rend,
pour chaque `add`, l'identifiant attribué (Scaleway rend les enregistrements ajoutés quand
`return_all_records` est faux : à confirmer, §15 ; sinon relecture de la zone).
`ProviderRegistry::build(account, credentials)` choisit l'adaptateur ; un fournisseur inconnu est
`INFRA_PROVIDER_REJECTED`.

### 5.2. Client HTTP (`provider/http.rs`, décisions **I8**, **I9**)

* Adresses fixées dans le code : `https://api.scaleway.com` ; `Endpoints::local(base)` réservé aux
  essais, boucle locale seulement (modèle de `ApiEndpoints::local`).
* `reqwest` 0.12 (déjà dans l'arbre par `lyxal_notification`, aucune crate nouvelle), TLS fourni
  par `lyxal_crypto::tls_client_config(TlsServerVerification::WebPki)` passé à
  `use_preconfigured_tls` (règle 10 du §11.3 ; à confirmer en 1b : version de `rustls` commune et
  jeu de fonctions de `reqwest` sans second fournisseur ; repli : réglage validé en K10 pour
  `lyxal_notification`).
* Aucune redirection, aucun mandataire, délai de connexion 10 s, requête 30 s, réponse lue sur
  4 Mio au plus, `User-Agent: lyxal-infra`.
* En-tête `X-Auth-Token` construit à chaque requête depuis le `SecretString`, marqué sensible
  (`HeaderValue::set_sensitive`) ; jamais journalisé, jamais dans un `Debug`.
* Débit : seau à jetons par compte (`requests_per_second`, rafale du double) ; `429` → attente de
  `Retry-After` (60 s au plus) sinon recul exponentiel à gigue complète (1 s, plafond 30 s),
  3 essais dans une passe ; `5xx` et réseau : idem ; ensuite la passe échoue (`retryable`) et le
  planificateur la reprend.
* Le code n'appelle **que** les chemins listés au §5.3 : achat, renouvellement, suppression de
  zone, `clear` et création de serveur n'existent pas dans le crate (un essai vérifie que le faux
  fournisseur ne reçoit jamais d'autre chemin).

### 5.3. Adaptateur Scaleway

| Opération | Appel |
| :--- | :--- |
| `probe` | `GET /domain/v2beta1/dns-zones?project_id=…&page_size=100` (toutes les pages) |
| `zone` | `GET /domain/v2beta1/dns-zones?dns_zone=<zone>` (`status`, `ns`, `ns_default`) |
| `records` | `GET /domain/v2beta1/dns-zones/{zone}/records?page=…&page_size=1000` |
| `apply` | `PATCH /domain/v2beta1/dns-zones/{zone}/records` : `{ changes: [ {add: {records}}, {set: {id, records}}, {delete: {id}} ], return_all_records: false, disallow_new_zone_creation: true }` ; chaque valeur écrite porte `comment: "lyxal:<clé>"` |
| lot 3 `ips` | `GET /instance/v1/zones/{zone}/ips` (zones du compte), IPv6 : `GET /ipam/v1/regions/{region}/ips` |
| lot 3 `set_reverse` | IPv4 : `PATCH /instance/v1/zones/{zone}/ips/{id}` `{ reverse }` ; IPv6 : `PATCH /ipam/v1/regions/{region}/ips/{id}` `{ reverses: [{ hostname, address }] }` |
| lot 3 `servers` | `GET /instance/v1/zones/{zone}/servers`, `GET …/security_groups` (`enable_default_security` → `smtp_blocked`) |

Classement des réponses : 2xx succès ; `denied_authentication` / `permissions_denied` / 401 / 403
→ `Auth` (compte `failing`, aucune autre zone du compte n'est tentée dans la passe) ;
`invalid_arguments`, `precondition_failed`, autres 4xx → `Permanent` ; `quotas_exceeded` →
`Permanent` (`INFRA_PROVIDER_QUOTA`) ; 404 → `INFRA_PROVIDER_NOT_FOUND` ; `transient_state`,
`locked`, 5xx → `Transient` ; 429 → `RateLimited`.

Un `PATCH` refusé en bloc (une valeur invalide) : la passe réessaie **une fois** changement par
changement pour isoler la valeur fautive (`failed` sur elle seule, les autres écrites).

### 5.4. Modèles Rust (`models/`)

Paramètres et résultats nommés, un par fonction publique (`#[derive(Debug, Serialize)]` pour les
`*Params`, `#[derive(Debug, SurrealValue)]` pour les `*Result`, skill `lyxal-surrealdb` §2.6) :
`AccountCreateParams` / `AccountResult`, `AccountUpdateParams`, `AccountListParams` /
`AccountListResult`, `ZoneAttachParams` / `ZoneResult`, `ZoneUpdateParams`, `ZoneDetachParams` /
`ZoneDetachResult`, `ZonePlanApproveParams`, `RecordsDeclareParams` (`DeclaredRecord`) /
`RecordsDeclareResult`, `RecordsReleaseParams` / `RecordsReleaseResult`, `RecordsStatusParams` /
`RecordsStatusResult`, `ConflictResolveParams`, `ChangeListParams` / `ChangeListResult`,
`SettingsUpdateParams` / `SettingsResult`, et ceux du worker (`ZoneClaimParams` / `ZoneClaim`,
`ZoneObserveParams`, `ZonePlanResult` (`PlannedChange`, `PlannedConflict`), `ApplyResultParams`,
`VerifyResultParams`…). Alias `InfraRecordId`, `InfraDatetime` dans `models/types.rs`. La clé
d'API n'existe qu'en `ScalewayCredentials { secret_key: SecretString, access_key:
Option<String> }`, `pub(crate)`, sans `Serialize`, `Debug` masqué ; valeur JSON du coffre-fort
`{ "secret_key": "…", "access_key": "SCW…" }`, champs inconnus refusés.

## 6. Exécution : tâches, santé, mesures

### 6.1. Pourquoi des tâches du planificateur et pas un `LyxalWorker` (décision **I10**)

Le travail est périodique et par zone. `lyxal_scheduler` fournit déjà l'élection d'un
planificateur pour toute la base, la réservation sous bail, les reprises, le refus des
chevauchements, l'unicité (`unique_for`) et le journal ; ses exécuteurs sont des `LyxalWorker`
supervisés par l'hôte. Une tâche `handler` n'est réservée que par un nœud qui a son code : ici
`lyxal-server` seulement. C'est le choix déjà fait pour la maintenance du courrier et la tâche
DKIM (lot 6, E2) et pour `lyxal_secrets`. La réservation de la zone (§3.2) protège en plus contre
deux passes simultanées.

### 6.2. Hébergement (`apps/lyxal-server`)

* `build.rs` : `("lyxal_infra", None)` après `lyxal_notification`.
* `src/modules/infra.rs` : `InfraModule` (descripteur égal au manifeste ; `install` crée les
  planifications par `SchedulerClient`, rejouable, comme `lyxal_notification`) ; handlers
  inscrits auprès du moteur du planificateur ; `InfraHealthCheck` enregistrée ; mesures ajoutées
  au document `/metrics`. Sans clé maîtresse du coffre-fort : les handlers rendent
  `{ skipped: "master_key_missing" }` et la sonde est « dégradé » (comme `DkimProvisionHandler`).
* Configuration `[infra]` (facultative) : `dns_servers` (résolveur utilisé pour trouver les
  adresses des serveurs faisant autorité ; défaut : celui du système), `dns_timeout_seconds` (5).
  Aucun secret dans la configuration ; aucune variable d'environnement nouvelle.
* **Aucune route HTTP en V1** : l'administration passe par les fonctions SurrealQL (console
  Surrealist), les actions qui demandent l'hébergeur (essai d'un compte, passe immédiate) sont des
  demandes notées en base et exécutées par les tâches. Routes `/infra/*` éventuelles avec l'écran
  d'administration (§13).

### 6.3. Tâches de `lyxal_scheduler`

| Tâche | Exécuteur | Rôle | Planification |
| :--- | :--- | :--- | :--- |
| `infra.zone_reconcile` | `handler` | Une passe d'une zone (argument `zone`) | à la demande (`fn::scheduler_run_enqueue`, unique 1 min), 3 essais, délai 5 min |
| `infra.tick` | `handler` | Comptes à essayer, zones échues (`infra.zone_reconcile` mise en file pour chacune), vérifications dues | toutes les 1 min, `overlap: skip` |
| `infra.purge` | `function` (`fn::infra_purge`) | Journal et enregistrements retirés au-delà de leur conservation | chaque jour |
| lot 3 `infra.inventory` | `handler` | IP, serveurs, blocage SMTP ; DNS inverse voulu | toutes les 15 min |

Permission propre des tâches : `infra.worker`.

### 6.4. Sonde de santé (`InfraHealthCheck`)

Légère (une lecture : `fn::infra_health`, interne) : réglages illisibles → « malade » ; aucun
compte → « sain » (« aucun hébergeur configuré ») ; clé maîtresse absente, compte `failing`, zone
`blocked` / `not_delegated` / `failing`, passe en retard de plus de 3 intervalles, enregistrement
en `conflict` ou `failed`, ou `written` depuis plus d'une heure → « dégradé », avec le nombre de
chaque cas (jamais de nom).

### 6.5. Mesures (`InfraMetrics`, sans nom ni adresse)

Appels au fournisseur par issue (`ok`, `rate_limited`, `transient`, `permanent`, `auth`) et
durée ; passes (`noop`, `applied`, `blocked`, `failed`) ; changements par action ; conflits
apparus ; vérifications (`published`, `pending`, `timeout`) ; enregistrements par état.

### 6.6. Journal applicatif

Zone et enregistrement par identifiant ; code et classe d'erreur ; **jamais** la clé, le corps
d'une réponse, une valeur TXT ou un nom de domaine (sauf réglage de débogage, comme E28 du lot 6
du courrier).

## 7. Sécurité

* **Moindre privilège chez Scaleway** : une **application IAM** dédiée `lyxal-infra`, une clé
  d'API, une politique limitée au **projet** qui porte les zones : `DomainsDNSFullAccess` au
  lot 1 ; au lot 3 en plus la lecture des Instances et le droit de régler le DNS inverse (jeu exact
  à confirmer, §15). Jamais la clé d'un utilisateur humain, jamais une portée organisation.
* **Ce que le code ne sait pas faire** : acheter, renouveler ou transférer un domaine, supprimer
  ou vider une zone, créer ou supprimer un serveur, changer un groupe de sécurité. Si
  `DomainsDNSFullAccess` permet l'achat (non vérifié), le risque est borné par l'absence de code et
  par l'essai du §10 ; le CTO peut en plus restreindre la politique si Scaleway offre plus fin.
* **Clé dans `lyxal_secrets` seulement** : écrite par l'administrateur avec les routes du
  coffre-fort, lue par la session système (lecture tracée au journal du coffre-fort, consommateur
  `lyxal_infra`), gardée en `SecretString` le temps d'une passe, jamais en cache au-delà, jamais
  dans un journal, un événement, une erreur ou une table de `lyxal_infra`.
* **Zones et organisations** : seule la plateforme rattache une zone ; une organisation ne fait
  publier des enregistrements que dans une zone qui la nomme dans `tenants` ; les déclarations
  d'une organisation n'atteignent jamais une zone de l'installation.
* **Aucune donnée personnelle** dans les événements ; les valeurs (adresses `rua=` de DMARC)
  restent dans les tables lisibles par `infra.read`.
* **Rotation de la clé** : manuelle en V1 (nouvelle version du secret, lue à la passe suivante) ;
  automatique plus tard par un `SecretRotator` (§13).

## 8. Intégration avec `lyxal_mail` (lot 2)

### 8.1. Contrats étudiés

| Solution | Pour | Contre |
| :--- | :--- | :--- |
| **A — `lyxal_mail` appelle le contrat SurrealQL public de `lyxal_infra`** (`fn::infra_records_declare`, `_release`, `_status`, `_subjects`) | Sens permis des dépendances (AGPL → permissif) ; refus immédiat et clair ; état désiré complet par domaine, rejouable ; le courrier garde seul la connaissance de ses enregistrements ; aucune donnée personnelle ne circule par le bus | `lyxal_mail` déclare une dépendance de plus ; `lyxal-groupware` installe aussi les fichiers SurrealQL de `lyxal_infra` |
| B — `lyxal_mail` publie `mail.domain.dns_changed` (identifiant seulement) ; `lyxal_infra` le consomme puis **lit** `fn::mail_dns_wanted` | Le courrier ne connaît pas l'infra | `lyxal_infra` (Noyau, permissif) dépendrait du courrier (AGPL, au-dessus de lui) : sens interdit (§6) et question de licence (Q3 du lot 6) ; le consommateur fabriquerait des enregistrements qu'il ne comprend pas |
| C — `lyxal_infra` lit directement les tables du courrier | — | Interdit (§1, encapsulation) |
| D — événement portant les enregistrements | — | Domaines et valeurs dans `event_outbox` (règle du lot 6) ; commande déguisée en événement (§5.6.1) |

**Recommandation : A** (décision **I13**), plus l'événement `infra.record.published` que le
courrier **pourra** consommer plus tard pour activer une clé DKIM sans attendre son passage de
10 minutes (pas nécessaire au lot 2).

### 8.2. Changements dans `lyxal_mail` et `lyxal-groupware`

* `manifest.toml` de `lyxal_mail` : dépendance `lyxal_infra >=0.1.0`. Aucune dépendance Cargo
  (les appels sont en SurrealQL). `apps/lyxal-groupware/build.rs` : `("lyxal_infra", None)`
  avant `lyxal_mail`, module porté par un `ManifestModule` (aucun code Rust de `lyxal_infra` lié,
  aucun handler : les tâches `infra.*` ne sont réservées que par `lyxal-server`). Les deux hôtes
  installent la même release (même commit, règle existante).
* Nouvelles fonctions du courrier (droit `mail.worker`, session système) :
  * `fn::mail_dns_declare({ domain, mx_hosts: [1..5 × { priority, host }], spf, dmarc, ttl })` :
    construit les enregistrements du domaine et appelle `fn::infra_records_declare` avec
    `owner: "lyxal_mail"`, `subject: <clé du mail_domain>`, `tenant` du domaine :
    MX à l'apex (`exclusive`) ; SPF à l'apex (`shared`, préfixe `v=spf1`) ; DMARC sur `_dmarc`
    (`shared`, préfixe `v=DMARC1`) ; une clé DKIM par sélecteur `pending` ou `active`
    (`<sélecteur>._domainkey`, `exclusive`, valeur `v=DKIM1; k=…; p=…`) ;
  * `fn::mail_dns_sync({ limit })` : lit `fn::infra_records_status` et note sur `mail_domain` un
    résumé `dns` { `state` (`unmanaged`, `pending`, `published`, `conflict`, `failed`),
    `checked_at`, `declared_hash` } ; retire (`fn::infra_records_release`) les sujets dont le
    domaine a disparu ou est désactivé (`fn::infra_records_subjects`).
* `DkimProvisioner` (`src/dkim.rs`) : après la création des clés manquantes, `mail_dns_declare`
  pour chaque domaine dont l'empreinte déclarée a changé, puis `mail_dns_sync`. L'**activation**
  d'une clé reste fondée sur la lecture du TXT par le résolveur du nœud (inchangée) : la vérité
  est ce que voit Internet, pas ce que dit l'hébergeur.
* Valeurs par défaut, section `[dns]` de `lyxal-groupware` : `mx_hosts` = `smtp.hostname`
  (priorité 10) ; `spf` = `v=spf1 a:<smtp.hostname> -all`, ou `include:` du relais sortant
  quand `[outbound.relay]` est réglé ; `dmarc` = `v=DMARC1; p=none` (décision **I14**) ; `ttl`
  3 600. Réglage par domaine : lot 13 du courrier.
* Un domaine dont la zone n'est pas rattachée reste `unmanaged` : `fn::mail_dkim_key_list` rend,
  comme aujourd'hui, les enregistrements à publier à la main, avec le nouvel état.
* Banc du courrier (`tests/dns.test.surql`) : déclaration complète, empreinte inchangée → aucun
  appel, domaine retiré → `release`, zone non rattachée → `unmanaged`, conflit d'un SPF humain
  remonté ; essai de `lyxal-groupware` avec un faux fournisseur dans `lyxal-server`.

## 9. DNS inverse et inventaire (lot 3)

* Table `infra_ip` : `account`, `address`, `version`, `provider_id`, `provider_zone` / `region`,
  `server` (`option`), `reverse_observed`, `reverse` (voulu, `option`), `owner`, `subject`,
  `state` (`unmanaged`, `pending`, `waiting_forward`, `written`, `published`, `conflict`,
  `failed`), `checked_at`. Table `infra_server` (lecture seule) : `account`, `provider_id`,
  `name`, `zone`, `state`, `type`, `public_ips`, `security_groups`, `smtp_blocked`, `seen_at`.
* `fn::infra_ip_reverse_declare({ address, reverse, owner, subject })` (contrat public, même
  droit que §4.4) et `fn::infra_ip_list`, `fn::infra_server_list` (`infra.read`).
* Ordre imposé par Scaleway : le nom voulu doit d'abord résoudre vers l'adresse. Lyxal vérifie
  sur les serveurs faisant autorité que `A` / `AAAA` du nom donne l'adresse (`waiting_forward`
  sinon, `INFRA_IP_FORWARD_MISSING`), puis écrit le PTR, puis vérifie la réponse du DNS inverse.
  Un nom inverse déjà réglé par un humain (différent du nom par défaut
  `*.pub.instances.scw.cloud`) est un conflit, comme au §3.1.
* **Ouverture du port 25 : impossible par API.** Le champ `enable_default_security` est en
  lecture seule (« open a support ticket ») ; Scaleway exige la vérification d'identité du compte
  puis la case « Enable SMTP » de la console. Lyxal **lit** l'état et le montre : la sonde passe
  « dégradé » si une IP qui porte un nœud `lyxal-groupware` (déclarée par l'administrateur) est
  derrière un groupe de sécurité qui bloque SMTP. La procédure humaine est écrite dans
  `apps/lyxal-groupware/docs/PRODUCTION-CHECKLIST.md`.
* Usage pour le courrier : l'administrateur déclare (owner `manual`) l'A / AAAA de
  `smtp.hostname` et le PTR de chaque IP sortante ; le contrôle « `EHLO` = DNS inverse » du lot 6
  devient vérifiable par Lyxal.

## 10. Essais

Aucun essai automatique n'appelle un vrai hébergeur ni le vrai DNS.

**SurrealQL** (`crates/lyxal_infra/tests/`, `scripts/ci/test_lyxal_modules.py`) :
`comptes.test.surql` (création, secret absent, hors `infra/`, illisible par l'appelant ;
suppression refusée en usage), `zones.test.surql` (zone non visible, emboîtée, `tenants`,
détachement refusé puis `forget`), `declarations.test.surql` (remplacement de l'ensemble,
déclaration identique sans écriture, liste vide, propriétaire concurrent, CNAME, 50 au plus,
organisation refusée, nom non couvert → `unmanaged`, demande de passe mise en file une fois),
`plan.test.surql` (cœur des règles : exclusif / partagé / préfixe unique, valeur humaine,
`drift_modified`, `drift_deleted` recréé, `take_over`, `yield`, retrait seulement si valeur
inchangée, seuils de suppression et approbation par empreinte, mode `observe`, aucun changement
→ plan vide), `worker.test.surql` (réservation, jeton perdu, journal `sent` puis `done`, chaîne
vérifiée, événements une fois, sans nom), `droits.test.surql` (administrateur de plateforme,
administrateur d'organisation, membre, compte de service avec et sans `infra.records.declare`,
session système), écritures filtrées (`INFRA_WRITE_FORBIDDEN`), réglages, purge ; chaque fonction
publique appelée.

**Rust** :

* Unitaires : forme canonique (IPv6, MX, TXT avec guillemets, découpe à 255 octets et relecture,
  CAA), classement des erreurs Scaleway, seau à jetons, recul et `Retry-After`, masquage du
  `Debug` des identifiants.
* **Faux fournisseur Scaleway** (serveur HTTP local, `hyper`, déjà employé par les essais de
  `lyxal_notification`) qui tient une zone en mémoire et applique `add`, `set`, `delete` par
  identifiant et par `id_fields` comme l'API : pagination ; `comment` ; zone `pending` ; `429`
  avec `Retry-After`, puis succès ; `500` passager ; `401` ; `PATCH` refusé en bloc ; latence ;
  journal des chemins reçus (aucun chemin hors §5.3).
* Scénarios du `Reconciler` contre ce faux fournisseur : première passe en `observe` sans
  écriture ; passe `managed` ; seconde passe sans aucun appel d'écriture (idempotence) ;
  enregistrement humain en conflit jamais touché ; humain qui modifie puis supprime un
  enregistrement de Lyxal ; arrêt simulé entre l'écriture et le résultat, reprise sans doublon
  (marque `lyxal:`) ; deux passes simultanées (une seule écrit) ; zone de 5 000 enregistrements
  (durée et nombre d'appels mesurés) ; seuil de suppression ; clé refusée → compte `failing`.
* Vérification : `StaticProbe` (réponses faisant autorité simulées : publié, partiel, absent,
  serveur muet), zone non rattachée chez la zone parente.
* `apps/lyxal-server` : installation et rejeu des ressources (`module_resources_are_replayable`),
  handlers inscrits, sonde ; essai de bout en bout avec le faux fournisseur
  (`Endpoints::local`).
* Lot 2 : banc du courrier (§8.2) et essai `lyxal-groupware` + `lyxal-server` sur une base.
* Lot 3 : faux fournisseur étendu (IP, IPAM, serveurs, groupes de sécurité), ordre A puis PTR.

### 10.1. Essais réels (sur le compte Scaleway du CTO)

**Ce que le CTO doit fournir** :

1. Une **organisation Scaleway** avec un **projet dédié** aux essais (par exemple `lyxal-essais`) ;
   compte vérifié (identité) si l'on veut essayer le blocage SMTP au lot 3.
2. Une **application IAM** `lyxal-infra` avec une **clé d'API** et une politique sur ce seul
   projet : `DomainsDNSFullAccess` (lot 1), puis lecture des Instances et DNS inverse (lot 3).
   La clé est saisie **par le CTO lui-même** dans le coffre-fort de Lyxal (jamais dans une
   conversation, un ticket ou un fichier).
3. Un **domaine d'essai** dont il contrôle le bureau d'enregistrement, ou mieux une **sous-zone
   déléguée** d'un domaine existant (par exemple `essai.<domaine>` déléguée à
   `ns0.dom.scw.cloud` et `ns1.dom.scw.cloud`) : aucun achat, aucun risque pour le domaine
   principal. L'achat éventuel d'un domaine est fait à la main par le CTO (décision **I18**).
4. Lot 3 : une **Instance** de petite taille avec une **IP flexible** (quelques euros par mois),
   l'IP dédiée aux essais.
5. Un environnement de session qui laisse joindre `api.scaleway.com` et les serveurs DNS.

| Lot | Action | Résultat attendu |
| :-: | :--- | :--- |
| 1 | Essai du compte | Zones du projet listées ; clé jamais visible dans les journaux de Lyxal |
| 1 | Rattacher la sous-zone en `observe`, déclarer un A et un TXT `manual` | Plan montré, aucune écriture chez Scaleway (versions de zone inchangées) |
| 1 | Passer en `managed` | Écriture en une requête ; marque `lyxal:` visible dans la console ; `published` en moins de quelques minutes ; nouvelle version de zone chez Scaleway |
| 1 | Créer à la main un TXT `v=spf1` puis déclarer un SPF | Conflit, aucune écriture ; `take_over` puis remplacement noté au journal |
| 1 | Supprimer à la main un enregistrement de Lyxal ; en modifier un autre | Le premier recréé ; le second en conflit |
| 1 | Clé révoquée dans la console | Compte `failing`, sonde « dégradé », aucune boucle d'appels |
| 1 | Relever les limites réelles | Nombre de requêtes avant `429`, présence de `Retry-After`, atomicité d'un `PATCH` à plusieurs changements, TXT de plus de 255 octets, nom de l'apex |
| 1 | Lister les *permission sets* proposés | Jeu le plus fin pour le DNS ; `DomainsDNSFullAccess` permet-il `buy-domains` ? (essai sans contact valide : refus attendu avant toute dépense) |
| 2 | Activer le courrier sur un domaine de la sous-zone | MX, SPF, DMARC et deux DKIM publiés ; clés activées par `lyxal_mail` ; message envoyé vers Gmail avec DKIM `pass` (essais du lot 6) |
| 3 | Déclarer le PTR de l'IP | `waiting_forward` tant que l'A manque ; puis PTR réglé et vu par le DNS inverse public |
| 3 | Lire l'inventaire | Serveur, IP, `smtp_blocked` exact avant et après « Enable SMTP » dans la console |

## 11. Découpage en demandes de fusion

| PR | Contenu | Touche | Taille |
| :- | :--- | :--- | :-: |
| **0** | `fn::validation_dns_name` (décision I3), essais du Core | `lyxal_core` | S (≈ 300 lignes) |
| **1a** | SurrealQL complet du lot 1 (§4), banc, `InfraStore` et modèles Rust, `README.md`, `ROADMAP.md` | `lyxal_infra` | M (≈ 4 000) |
| **1b** | Fournisseurs (§5), client HTTP, adaptateur Scaleway, faux fournisseur, `Reconciler`, vérification, tâches, sonde, mesures, hébergement dans `lyxal-server`, essais | `lyxal_infra`, `lyxal-server` | L (≈ 5 500) |
| **2** | Intégration du courrier (§8) | `lyxal_mail`, `lyxal-groupware` | M (≈ 1 800) |
| **3** | DNS inverse et inventaire (§9) | `lyxal_infra`, `lyxal-server`, documents de `lyxal-groupware` | M (≈ 3 000) |

Ordre : 0 → 1a → 1b → 2 → 3. Chaque demande compile, passe la CI et laisse le dépôt cohérent.
**V1 = PR 0 à 3.** Après 1b, l'administrateur publie des enregistrements à la main par Lyxal ;
après 2, le DNS du courrier se publie seul ; après 3, le DNS inverse aussi. Le lot 2 peut être
écrit par le programme courrier si le CTO préfère le rattacher à son lot 13 (question **Q4**).

## 12. Documents mis à jour

`crates/lyxal_infra/{README,ROADMAP}.md` (créés en 1a ; ce plan et `RECHERCHE_SOURCES.md`
supprimés après la fusion du lot 3, la recherche reprise dans le `README.md` pour ce qui reste
vrai) ; `.agents/AGENTS.md` §6 et `.agents/rules/…` §13 si une règle change (ajout de
`lyxal_infra` au noyau) ; `docs/14-roadmap/ROADMAP_NOYAU.md` (crate retiré une fois créé) ;
`crates/lyxal_mail/{README,ROADMAP}.md` et `apps/lyxal-groupware/{README}.md`,
`docs/PRODUCTION-CHECKLIST.md` (lot 2 et 3) ; `apps/lyxal-server/{README,ROADMAP}.md` et
`docs/PRODUCTION-CHECKLIST.md` (application IAM, politique, clé dans le coffre-fort, zone en
`observe` d'abord) ; `scripts/ci/check_agpl_isolation.py` (commentaire : `lyxal_infra`
permissif, dépendance du courrier).

## 13. Reporté, avec la raison

| Élément | Raison | Quand |
| :--- | :--- | :--- |
| MTA-STS et TLS-RPT (`_mta-sts` TXT, hôte `mta-sts` et sa politique en HTTPS, `_smtp._tls` TXT) | Le contrat de déclaration les porte déjà ; ils n'ont de sens qu'avec le lot 7 du courrier (politique servie en HTTPS, rapports lus) | Lot 7 du courrier, par `fn::infra_records_declare` |
| Défi ACME DNS-01 (`_acme-challenge`) pour les certificats | Utile aux certificats automatiques du lot 13 du courrier ; demande des enregistrements de courte durée | Avec le lot 13 du courrier |
| Défi `_lyxal-challenge` de `lyxal_auth` publié seul | `lyxal_auth` est sous `lyxal_infra` : la publication doit être orchestrée par l'hôte au moment de l'ajout du domaine ; le jeton n'est montré qu'une fois | Lot ultérieur, décision **I19** |
| Fournisseur OVHcloud (DNS, DNS inverse) | Deuxième fournisseur seulement après des essais réels du premier ; comptes de service OAuth2 recommandés (aucune extension cryptographique) | Sur demande, décision **I22** |
| Fournisseur Bunny DNS | DNS seulement (pas d'IP) | Sur demande |
| Ajout d'un domaine externe chez Scaleway (`POST external-domains`) | La délégation des serveurs de noms se fait chez le bureau d'enregistrement, par un humain ; peu fréquent | Lot ultérieur |
| **Achat de domaine** | Engage de l'argent, des contacts juridiques (titulaire, `.fr` : AFNIC) et un renouvellement annuel ; fait rarement | Décision **I18** : jamais automatique ; au mieux, plus tard, recherche de disponibilité en lecture seule |
| Création et suppression de serveurs | Coût, cycle de vie, sauvegardes : outil de déploiement à part entière, hors du besoin du courrier | Décision **I20** |
| Ouverture du port 25 | Impossible par API (§9) | — (procédure humaine) |
| Rotation automatique de la clé (`SecretRotator` de `lyxal_secrets`) | Demande que la clé puisse créer des clés IAM : contraire au moindre privilège | Décision **I21** |
| Comptes d'hébergeur propres à une organisation | Aucune demande ; complique droits et facturation | Sur demande |
| DNSSEC, enregistrements TLSA (DANE) | Avec le lot 7 du courrier | Lot 7 |
| Écran d'administration et routes `/infra/*` | La V1 se pilote par la console ; l'écran suit la charte §15 | Après la V1 |

## 14. Risques

| Risque | Parade |
| :--- | :--- |
| **Effacer ou remplacer le DNS d'un client** | Propriété prouvée (§3.1) ; aucun effacement hors enregistrements de Lyxal à valeur inchangée ; mode `observe` d'abord ; seuils et approbation ; zones rattachées une à une |
| **Boucle avec un humain ou un autre outil** | Un conflit n'est jamais réécrit ; `yield` met fin à la boucle |
| **SPF ou DMARC faux qui fait rejeter tout le courrier** | Préfixe unique (jamais deux SPF) ; DMARC `p=none` par défaut ; essais réels avant toute montée |
| **API Scaleway en bêta (`v2beta1`)** | Adaptateur isolé ; essais contre le faux fournisseur et essais réels ; un changement de l'API ne touche que `provider/scaleway` |
| **Clé trop puissante** (achat, suppression de zone) | Application IAM dédiée, portée projet ; code sans ces chemins, vérifié par essai ; question **Q2** |
| **Fuite de la clé** | Coffre-fort, lecture tracée, `SecretString`, en-tête sensible, aucun journal ; révocation dans la console Scaleway |
| **Panne de l'hébergeur** | Rien n'est supprimé ; reprises espacées ; sonde « dégradé » ; le DNS déjà publié continue de répondre |
| **Base perdue** | Marques `lyxal:` dans les commentaires Scaleway : les enregistrements sont retrouvés ; sans commentaire (autres fournisseurs), les valeurs déclarées identiques sont reprises, le reste devient étranger (jamais effacé) |
| **Délais de propagation et caches** | Vérification sur les serveurs faisant autorité ; le courrier n'active ses clés que lorsque son propre résolveur voit le TXT |
| **Charge de la base** | Photo écrite par différence ; une passe par zone ; zones de 5 000 enregistrements mesurées |

## 15. Ce qui n'a pas pu être vérifié

* **Rien n'a été compilé ni exécuté**, sauf l'essai de `string::is_domain` sur SurrealDB 3.3.4.
* Site et documentation de Scaleway non joignables depuis la session : faits tirés du SDK Go
  (spécification générée) et d'extraits de recherche ; à confirmer par les essais réels :
  atomicité d'un `PATCH` à plusieurs changements ; identifiants rendus par `add` avec
  `return_all_records: false` ; écriture d'un TXT de plus de 255 octets ; nom de l'apex (`""` ou
  `@`) ; taille de page maximale de la liste ; valeurs réelles des limites de débit et présence de
  `Retry-After` ; champ `comment` conservé tel quel.
* Contenu exact des *permission sets* (`DomainsDNSFullAccess` et achat ; jeu le plus fin pour le
  DNS inverse et la lecture des Instances).
* Changement de `enable_default_security` impossible par API : affirmé par le commentaire du SDK,
  non essayé.
* OVHcloud : chemin du DNS inverse cité de mémoire.
* `reqwest` 0.12 avec `use_preconfigured_tls` et la configuration de `lyxal_crypto` (version de
  `rustls`, absence d'un second fournisseur cryptographique) : à confirmer en 1b.
* SurrealDB 3.3.4 : coût d'une photo de 5 000 enregistrements écrite par différence et d'un plan
  calculé en SurrealQL sur cette taille : à mesurer en 1a ; repli prévu : plan calculé en Rust
  sur les mêmes règles **seulement** si la mesure l'impose (décision du CTO à ce moment).

## 16. Décisions soumises au CTO

| N° | Question | Recommandation |
| :- | :--- | :--- |
| **I1** | Nom du module | `lyxal_infra` (§1) |
| **I2** | Place et licence | Noyau technique, après `lyxal_notification` ; `MIT OR Apache-2.0` ; hébergé par `lyxal-server` |
| **I3** | Fonction Core manquante | Ajouter `fn::validation_dns_name` à `lyxal_core/validations` (PR 0, §2.3) |
| **I4** | Modèle | État désiré déclaré par propriétaire et sujet, réconcilié avec l'hébergeur ; plan calculé en SurrealQL ; dialogue et DNS en Rust (§3) |
| **I5** | Preuve de propriété | Identifiants en base + marque `lyxal:` dans le commentaire quand le fournisseur en a un ; pas de TXT de propriété |
| **I6** | Écarts créés par un humain | Valeur modifiée : conflit, jamais réécrite ; enregistrement supprimé : recréé et signalé ; levée d'un conflit par `take_over` ou `yield` |
| **I7** | Prudence | Zone en `observe` au rattachement ; plus de 10 suppressions ou 30 % : plan bloqué jusqu'à approbation par empreinte |
| **I8** | Client HTTP et TLS | `reqwest` 0.12 déjà présent, TLS par `lyxal_crypto::tls_client_config(WebPki)` ; repli sur le réglage K10 de `lyxal_notification` si la combinaison n'est pas possible |
| **I9** | Client contrôlé de `lyxal_notification` | Ni réutilisé ni déplacé maintenant (adresses fixes) ; déplacé dans un crate commun le jour où une adresse sera choisie par une personne |
| **I10** | Exécution | Tâches `handler` de `lyxal_scheduler` dans `lyxal-server` (pas de `LyxalWorker` propre) ; réservation de zone en base |
| **I11** | Droits | `infra.read`, `infra.manage` (administrateur de la plateforme), `infra.records.declare`, `infra.worker` (comptes de service) ; aucun droit d'organisation en V1 |
| **I12** | Événements | `infra.record.published`, `.conflict`, `.failed`, `infra.zone.blocked` ; identifiants et codes seulement |
| **I13** | Contrat avec le courrier | Solution A : `lyxal_mail` appelle `fn::infra_records_declare` / `_release` / `_status` / `_subjects` ; dépendance de manifeste `lyxal_mail` → `lyxal_infra` ; `lyxal-groupware` installe les fichiers SurrealQL de `lyxal_infra` sans son code |
| **I14** | Valeurs du courrier | MX = `smtp.hostname` ; SPF `a:` de l'hôte (ou `include:` du relais) `-all` ; DMARC `p=none` au départ ; durcissement de DMARC décidé domaine par domaine plus tard |
| **I15** | Types d'enregistrements de la V1 | A, AAAA, CNAME, MX, TXT, SRV, CAA |
| **I16** | Vérification | Serveurs faisant autorité, sans cache ; délégation contrôlée ; échec après 24 h |
| **I17** | Débit | 5 requêtes par seconde et par compte (réglable), `Retry-After` respecté, 3 essais par passe |
| **I18** | Achat de domaine | Jamais dans `lyxal_infra`, aucun code d'achat ; achat à la main en attendant un **module dédié à la gestion complète des noms de domaine** (achat, renouvellement, titulaire et contacts, transferts, délégation), décidé par le CTO |
| **I19** | Défi `_lyxal-challenge` de `lyxal_auth` | Reporté ; orchestration par l'hôte dans un plan ultérieur |
| **I20** | Serveurs | Inventaire en lecture seule au lot 3 ; aucune création ni suppression |
| **I21** | Rotation de la clé | Manuelle en V1 ; automatique seulement si une politique IAM étroite le permet |
| **I22** | Fournisseurs futurs | OVHcloud par comptes de service OAuth2 (aucune extension de `lyxal_crypto`), puis Bunny DNS, chacun par son propre plan |
| **I23** | Découpage | PR 0, 1a, 1b, 2, 3 (§11) ; V1 = les cinq |
| **I24** | Tableau de bord | Aucune route HTTP en V1 ; administration par fonctions SurrealQL ; écran plus tard |

## 17. Questions au CTO

| N° | Question | Recommandation |
| :- | :--- | :--- |
| **Q1** | Quel domaine pour les essais réels : un domaine neuf acheté par vous, ou une **sous-zone** d'un domaine existant déléguée à Scaleway ? | **Une sous-zone** (`essai.<domaine>`) : gratuite, sans risque pour le domaine principal, suffisante pour le DNS et le courrier d'essai |
| **Q2** | Accepter qu'au lot 1 la clé ait `DomainsDNSFullAccess` sur le **seul projet d'essai**, même si ce jeu permettait d'acheter un domaine ? | **Oui**, sur un projet dédié et avec une carte de paiement à plafond si possible ; le code n'a aucun chemin d'achat ; on resserre si Scaleway propose un jeu plus fin (relevé aux essais réels) |
| **Q3** | Les organisations clientes doivent-elles un jour publier leur DNS par **leur propre** compte d'hébergeur ? | **Pas en V1** : seule la plateforme a des comptes ; une zone peut accepter les déclarations d'organisations nommées (`tenants`) |
| **Q4** | Faire le lot 2 (courrier) dans ce plan, ou le rattacher au lot 13 « Administration du courrier » ? | **Dans ce plan, juste après 1b** : c'est l'usage principal, et le lot est petit ; le lot 13 garde la rotation des clés et les réglages par domaine |
| **Q5** | Politique DMARC de départ des domaines publiés par Lyxal ? | **`p=none`** puis passage à `quarantine` domaine par domaine après quelques semaines de rapports (lot 7 du courrier) |
| **Q6** | Quand pouvez-vous fournir le projet Scaleway, l'application IAM, la sous-zone (et au lot 3 l'Instance avec IP flexible) ? | **À la fusion de 1b**, pour essayer la publication réelle avant d'y brancher le courrier |

## Checklist (`.agents/rules/lyxal_standards_and_checklist.md` §13)

* [ ] **Architecture** : responsabilité propre (pilotage de l'hébergeur), absente des autres
  modules ; dépendances `lyxal_core`, `lyxal_error`, `lyxal_event`, `lyxal_auth`,
  `lyxal_secrets`, `lyxal_scheduler` ; `lyxal_mail` → `lyxal_infra` seulement ; aucun cycle ;
  aucun paquet AGPL dans l'arbre ; métier en SurrealQL, protocoles en Rust.
* [ ] **Core** : validation, nettoyage et sécurité vérifiés (§2.1) ; entrées par le moteur unique ;
  aucune règle générique réécrite ; besoin `fn::validation_dns_name` signalé (I3), non contourné.
* [ ] **SurrealQL** : `fn::infra_<action>($params: object)`, `fn::result_ok` /
  `fn::error_result`, `COMMENT`, moins de 300 lignes, écritures vérifiées
  (`INFRA_WRITE_FORBIDDEN`), banc complet sous identités, une seule migration.
* [ ] **Rust** : `XxxParams` / `XxxResult` nommés, wrappers `store.call_fn`, aucun `panic!`, aucun
  `raw_query()` métier, aucun secret exposé (`SecretString`, `Debug` masqué, en-tête sensible),
  aucun `tokio::spawn` hors du planificateur.
* [ ] **Erreurs** : codes `INFRA_*` en master data `fr` / `en` (§4.6) ; aucune erreur silencieuse
  (chaque refus, échec d'appel et conflit noté, compté et visible dans la sonde).
* [ ] **Événements** : `fn::event_publish` vérifié ; charges sans nom ni adresse ; aucun
  consommateur connu.
* [ ] **Cryptographie** : aucune primitive nouvelle ; TLS par `lyxal_crypto` ; aucune crate
  cryptographique directe ; clé dans `lyxal_secrets` seulement.
* [ ] **Zéro dette** : schéma à l'état cible, aucun alias ; plan et recherche supprimés après le
  lot 3 ; `ROADMAP.md` tenue ; version `0.1.0`.
* [ ] **Validation CTO** : ce plan, décisions I1 à I24, questions Q1 à Q6.
