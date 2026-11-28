# Lyxal Infra

Module du Noyau Technique de Lyxal OS : **pilotage de l'hébergeur par API** (Scaleway en
premier). Lyxal tient l'état DNS qu'il **veut** voir publié (déclaré par les modules, d'abord le
courrier, ou par l'administrateur), le compare à ce qui existe chez l'hébergeur et n'écrit que
ce qui lui appartient : un enregistrement créé par un humain n'est jamais modifié ni supprimé,
seulement signalé comme conflit. Tout est noté dans un journal chaîné.

État : **lot 1a** — le SurrealQL complet (règles, droits, plan de réconciliation, journal,
événements, erreurs) et le crate Rust des appels typés. Le dialogue avec l'hébergeur (client
HTTP, adaptateur Scaleway), la passe de réconciliation, la vérification DNS, les tâches du
planificateur, la sonde et l'hébergement dans `lyxal-server` arrivent au lot 1b
([`ROADMAP.md`](ROADMAP.md)). Plan validé par le CTO : [`implementation_plan.md`](implementation_plan.md) ;
recherches : [`RECHERCHE_SOURCES.md`](RECHERCHE_SOURCES.md) (conservés jusqu'à la fin du lot 3).

L'achat, le renouvellement et la gestion des noms de domaine n'appartiennent pas à ce module :
il ne gère que le contenu DNS des zones qu'on lui confie (décision du CTO sur I18).

| | |
| :--- | :--- |
| Identifiant | `lyxal_infra` (version `0.1.0`, licence `MIT OR Apache-2.0`) |
| Dépendances (`manifest.toml`) | `lyxal_core`, `lyxal_error`, `lyxal_event`, `lyxal_auth`, `lyxal_secrets`, `lyxal_scheduler` |
| Dépendances Rust | `lyxal_surreal`, `surrealdb`, `async-trait` (essais : `lyxal_runtime`, `tokio`) |
| Hébergement | `apps/lyxal-server` au lot 1b (pas encore inscrit dans `build.rs`) |

## 1. Modèle

| Table | Contenu |
| :--- | :--- |
| `infra_settings` | fiche unique `infra_settings:installation` (seed) : intervalle des passes (15 min), durée de vie par défaut (3 600 s) et minimale (60 s), seuils de prudence (10 suppressions, 30 %), délai de vérification (24 h), débit par compte (5 requêtes/s), conservation du journal (400 jours) et des retraits (30 jours) |
| `infra_account` | compte d'hébergeur `infra_account:<clé>` (`snake_case`) : fournisseur (`scaleway`), chemin de la clé d'API dans `lyxal_secrets` (installation, sous `infra/`, jamais une valeur), réglages Scaleway (`project_id`, `organization_id` en UUID natifs, `default_zone`, `default_region`), état (`active`, `disabled`, `failing`), dernier essai, essai demandé, zones visibles (1 000 au plus) |
| `infra_zone` | zone confiée à Lyxal, clé **opaque** `infra_zone:<UUID v7 en 32 chiffres hexadécimaux>` (le nom de la zone n'est jamais dans un événement ni un journal) : compte, nom (unique), mode (`observe`, `managed`), organisations acceptées (`tenants`), état (`ok`, `blocked`, `not_delegated`, `failing`, `pending_provider`), serveurs de noms, rattachement à la zone parente, réservation d'une passe (`claim`, `locked_until`), dernier plan et son empreinte, approbation, dates des passes, dernière erreur |
| `infra_record` | enregistrement **voulu** `infra_record:<32 premiers chiffres du BLAKE3 de owner, subject, fqdn, type>` : propriétaire (`owner` : module ou `manual`), sujet (`subject` : clé opaque du propriétaire), organisation, zone, nom, type (A, AAAA, CNAME, MX, TXT, SRV, CAA), valeurs canoniques triées (1 à 20), durée de vie, cohabitation (`exclusive`, `shared`), préfixe unique d'un TXT partagé, état (`unmanaged`, `pending`, `written`, `published`, `conflict`, `yielded`, `failed`, `releasing`, `released`), conflit, décision humaine, écritures de Lyxal (`provider_ids`, `applied_values`), vérification |
| `infra_zone_record` | photo de la zone chez le fournisseur : une ligne par valeur, rattachée à l'enregistrement de Lyxal qui l'a écrite (marque `lyxal:<clé>` du commentaire ou identifiant noté à l'écriture), écrite par différence, par le worker seulement |
| `infra_change`, `infra_change_head` | journal chaîné (`fn::security_audit_entry`) : rang, zone, enregistrement, action (`add`, `set`, `delete`, `conflict`, `resolve`, `approve`, `drift_deleted`, `attach`, `detach`, `mode`), avant, après, auteur, date — contenu figé ; l'issue d'une intention (`sent` → `done` ou `failed`, statut HTTP, code) n'est posée qu'une fois ; la tête tient le dernier rang et la dernière empreinte |

Gardes (`DEFINE EVENT … THROW`) : chemin de la clé d'un compte (mêmes contrôles qu'à la
création), réservation d'une zone (une passe ne vole pas le jeton d'une autre), issue d'une
entrée du journal (une fois, de `sent` à `done` ou `failed`), avancée de la tête du journal (un
rang à la fois). Champs figés (`READONLY`) : clés, propriétaire, sujet, nom, type, contenu du
journal.

## 2. Règles de la réconciliation (`functions/infra_plan.surql`)

1. **Déclaré, jamais deviné** : une déclaration remplace tout l'ensemble (propriétaire, sujet) ;
   ce qui n'y figure plus est retiré.
2. **Propriété prouvée** : Lyxal ne modifie ou ne supprime que ses propres écritures (ligne
   rattachée à l'enregistrement, valeur encore celle qu'il a écrite). Chaque valeur écrite
   porte la marque `lyxal:<clé>` : après un arrêt entre l'écriture et son résultat, l'écriture
   est retrouvée et rattachée, sans doublon.
3. **Jamais d'écrasement d'un humain** : valeur étrangère qui gêne (jeu `exclusive`, préfixe
   unique d'un TXT `shared`, CNAME à côté d'autre chose) ou écriture de Lyxal modifiée par un
   humain (`drift_modified`) : conflit, rien n'est écrit, jusqu'à une décision humaine
   (`take_over` : la valeur étrangère est remplacée, une seule fois ; `yield` : la valeur
   humaine reste, l'enregistrement de Lyxal est mis en sommeil). Écriture de Lyxal supprimée
   par un humain : recréée et notée (`drift_deleted`). Valeur humaine identique à une valeur
   voulue : satisfaite, jamais prise ni dupliquée.
   **Un seul déclarant par préfixe unique** (jamais deux SPF) : une déclaration d'un TXT dont le
   préfixe est déjà tenu au même nom par une autre déclaration active est refusée
   (`INFRA_RECORD_SINGLETON_TAKEN`) ; au plan, la valeur encore publiée d'un autre
   enregistrement de Lyxal (en retrait) qui porte le préfixe est un conflit `foreign_singleton`,
   levé de lui-même quand elle disparaît.
4. **Prudence** : un plan qui supprime plus de `max_deletions` enregistrements, ou plus de
   `max_deletion_percent` % des enregistrements de Lyxal d'une zone qui en a plus de
   `max_deletions`, n'est pas appliqué : la zone passe `blocked` (événement
   `infra.zone.blocked`) jusqu'à `fn::infra_zone_plan_approve` avec l'empreinte exacte du plan.
5. **Observation d'abord** : une zone rattachée commence en `observe` (plan calculé et rangé,
   rien n'est écrit).
6. **Journal** : chaque intention d'écriture est notée avant l'appel (`sent`), puis son issue.

Une passe (tâche `infra.zone_reconcile`, lot 1b) : `fn::infra_zone_claim` (jeton UUID v7,
5 minutes) → lecture chez l'hébergeur → `fn::infra_zone_observe` (photo écrite par différence)
→ `fn::infra_zone_plan` → `fn::infra_zone_apply_begin` (intentions `sent`) → une requête chez
l'hébergeur → `fn::infra_zone_apply_result` → vérification → `fn::infra_zone_release`. Toute
écriture d'une passe exige le jeton (`INFRA_ZONE_CLAIM_LOST`).

Forme canonique contrôlée à la déclaration (`fn::infra__record_value`, primitives de
`lyxal_core`) : A (IPv4), AAAA (IPv6 en minuscules), CNAME (nom DNS), MX `"<priorité> <cible>"`,
TXT (ASCII, 4 096 octets au plus, sans retour de ligne), SRV `"<priorité> <poids> <port> <cible>"`,
CAA `"<drapeaux> <issue|issuewild|iodef> \"<valeur>\""`. Noms par `fn::validation_dns_name`
(tiret bas permis, pas de joker).

## 3. Contrat public des modules (stable)

Appelées par les modules en SurrealQL (le courrier, au lot 2) ; droit `infra.records.declare`
(`manual` : `infra.manage`), session système de l'hôte dispensée.

| Fonction | Paramètres → résultat |
| :--- | :--- |
| `fn::infra_records_declare` | `{ owner, subject, tenant?, records: [0..50 × { fqdn, type, values: [1..20], ttl?, mode, singleton_prefix? }], language }` → `{ items: [{ record, fqdn, type, state, managed }], changed, queued }`. Remplace l'ensemble (owner, subject) ; liste vide : tout est retiré ; déclaration identique : rien n'est écrit (`changed` faux). Refus : `INFRA_RECORD_TENANT_REFUSED` (zone qui n'accepte pas l'organisation), `INFRA_RECORD_OWNED` (nom et type exclusifs d'un autre propriétaire), `INFRA_RECORD_CNAME_CONFLICT`, `INFRA_RECORD_SINGLETON_TAKEN` (préfixe unique d'un TXT déjà tenu au même nom par une autre déclaration active ; détails `{ index, prefix }`), `INFRA_RECORD_LIMIT` (plus de 50). Nom non couvert par une zone rattachée : `unmanaged`. Un changement met en file une passe de la zone (`queued`, quand l'appelant peut lancer la tâche ; sinon `infra.tick` la reprend) |
| `fn::infra_records_release` | `{ owner, subject, keep_at_provider: false, language }` → `{ released, releasing, queued }` : écrit chez l'hébergeur → `releasing` (supprimé à la passe suivante, seulement si la valeur est encore celle écrite par Lyxal) ; sinon, ou avec `keep_at_provider`, oublié (`released`) |
| `fn::infra_records_status` | `{ owner, subjects: [1..500], language }` → `{ items: [{ subject, record, fqdn, type, state, managed, conflict_reason, published_at, error_code }] }` |
| `fn::infra_records_subjects` | `{ owner, after?, limit (1..1000), language }` → `{ subjects, next }` |

## 4. Administration et worker

| Fonctions | Droit |
| :--- | :--- |
| `fn::infra_account_create`, `_update`, `_delete`, `_test_request` ; `fn::infra_zone_attach`, `_update`, `_detach`, `_reconcile_request`, `_plan_approve` ; `fn::infra_record_conflict_resolve` ; `fn::infra_settings_update` | `infra.manage` (le secret d'un compte : aussi `secrets.installation.manage`) |
| `fn::infra_account_get`, `_list` ; `fn::infra_zone_get`, `_list`, `fn::infra_zone_records` ; `fn::infra_record_list`, `_get` ; `fn::infra_change_list`, `fn::infra_change_verify` ; `fn::infra_settings_get` | `infra.read` |
| `fn::infra_account_due`, `_test_result` ; `fn::infra_zone_due`, `_claim`, `_renew`, `_observe`, `_plan`, `_apply_begin`, `_apply_result`, `_release` ; `fn::infra_records_to_verify`, `fn::infra_record_verify_result` ; `fn::infra_purge` | `infra.worker` |
| `fn::infra_health` (nombres, jamais de nom) | `infra.read` ou `infra.worker` |

Toutes prennent un objet `$params` unique, rendent `fn::result_ok` / `fn::error_result`, et
valident leurs entrées par `lyxal_core` (`fn::validation_object_execute` pour l'administration,
`fn::validation_fields_execute` pour le contrat public et le worker). Une écriture filtrée par
les permissions des tables rend `INFRA_WRITE_FORBIDDEN`. `fn::infra_can({ action })` (`read`,
`manage`, `declare`, `worker`) est le contrôle unique des droits, utilisé aussi par les
`PERMISSIONS` des tables.

**Permissions** (`seeds/infra_auth.surql`, installation) : `infra.read` et `infra.manage` au
rôle `platform_admin` ; `infra.records.declare` et `infra.worker` à aucun rôle (comptes de
service). Une organisation n'a aucun droit en V1.

**Tâches de `lyxal_scheduler`** (`seeds/infra_initial.surql`, permission `infra.worker`) :
`infra.zone_reconcile` (handler, argument `zone`, unique 1 min, 3 essais), `infra.tick`
(handler), `infra.purge` (fonction `fn::infra_purge`). Leurs planifications et les handlers sont
créés par l'hôte au lot 1b.

## 5. Événements

Par `fn::event_publish` vérifié (`THROW` sinon) ; **charges sans nom de domaine, sans adresse,
sans valeur** : identifiants opaques et codes.

| Événement | Quand | Charge |
| :--- | :--- | :--- |
| `infra.record.published` | `written` → `published` | `record`, `owner`, `subject`, `zone` |
| `infra.record.conflict` | entrée en `conflict` | `record`, `owner`, `subject`, `zone`, `reason` |
| `infra.record.failed` | entrée en `failed` | `record`, `owner`, `subject`, `zone`, `code` |
| `infra.zone.blocked` | zone `blocked`, `not_delegated` ou `failing` | `zone`, `state`, `code`, `deletions` |

## 6. Erreurs (`error/<thème>/`, `fr` et `en`)

`parametres` : `INFRA_INVALID_PARAMETERS`, `INFRA_PERMISSION_DENIED`, `INFRA_WRITE_FORBIDDEN`,
`INFRA_SETTINGS_INVALID`. `comptes` : `INFRA_ACCOUNT_NOT_FOUND`, `_EXISTS`, `_IN_USE`,
`_SECRET_INVALID`. `zones` : `INFRA_ZONE_NOT_FOUND`, `_EXISTS`, `_OVERLAP`, `_NOT_VISIBLE`,
`_HAS_RECORDS`, `_PLAN_STALE`, `_CLAIM_LOST` (à réessayer). `enregistrements` :
`INFRA_RECORD_NOT_FOUND`, `_OWNED`, `_CNAME_CONFLICT`, `_SINGLETON_TAKEN`, `_TENANT_REFUSED`,
`_LIMIT`.
`fournisseurs` : `INFRA_PROVIDER_AUTH`, `_REJECTED`, `_NOT_FOUND`, `_QUOTA`, `_RATE_LIMITED`,
`_UNAVAILABLE`, `_RESPONSE_INVALID`, `INFRA_CREDENTIALS_UNAVAILABLE`, `INFRA_DNS_UNAVAILABLE`,
`INFRA_DNS_NOT_PUBLISHED`.

## 7. Crate Rust

`InfraStore` (`src/store.rs`) implémente `LyxalSurrealCall` sur un client `Surreal<Any>` ou le
pool de la session système : une enveloppe d'une ligne `store.call_fn(...)` par fonction
publique (39). Les contrats sont dans `src/models/` (`SurrealValue`) : comptes, zones et plan
(`PlannedChange`, `PlannedConflict`), enregistrements, journal, réglages, et ceux du worker
(`ZoneClaim`, `ObservedRecord`, `SentChange`, `ApplyOutcome`, `VerifyItem`, `HealthResult`…) que
la passe du lot 1b consommera. Aucune clé d'API ne traverse ce crate : seul le chemin du secret
circule.

## 8. Essais

* **SurrealQL** (`tests/*.test.surql`, `scripts/ci/test_lyxal_modules.py`) : comptes (secret
  absent, hors `infra/`, illisible ; suppression refusée en usage), zones (non visible,
  emboîtée, organisations, adoption, approbation, détachement, enregistrements retirés jamais
  repris), déclarations (forme canonique
  de chaque type, remplacement, identique sans écriture, liste vide, propriétaire concurrent,
  CNAME, préfixe unique tenu par un autre déclarant, 50 au plus, organisation refusée, `unmanaged`, passe en file une fois), plan (faux
  fournisseur en SurrealQL : observation, passe gérée, idempotence, conflits, `take_over`,
  `yield`, `drift_modified`, `drift_deleted`, reprise par la marque, retrait si valeur
  inchangée, retrait pendant l'écriture d'un ajout, préfixe unique d'un autre enregistrement de Lyxal, seuils et approbation, empreinte stable), worker (réservation, jeton perdu,
  journal `sent` puis `done` / `failed`, chaîne et falsification détectée, événements sans nom,
  vérification, purge, sonde), droits (administrateur de la plateforme, administrateur et membre
  d'organisation, comptes de service avec et sans `infra.records.declare`, worker, session
  système, écritures directes filtrées), fonctions internes. Chaque fonction, interne
  comprise, est appelée.
* **Rust** (`cargo test -p lyxal_infra`) : chaque enveloppe d'`InfraStore` sur une base `mem://`
  où le module est installé.
* **Mesure** (plan §15) : photo d'une zone de 5 000 lignes (100 de Lyxal) en 16 s à la
  première lecture (5 000 lignes écrites) et 9 s sans changement, plan en 0,4 s, sur la base
  du banc (serveur SurrealDB 3.3.4 en mémoire). L'essentiel du temps est le contrôle des lignes
  par `fn::validation_fields_execute` ; voir `ROADMAP.md`.
