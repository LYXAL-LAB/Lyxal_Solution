# `lyxal_pipeline_ingestion` — Ingestion des catalogues fabricants

Ingestion, normalisation, qualification et publication des catalogues fabricants (FAB-DIS, CSV,
XML / BMEcat, JSON) vers le catalogue maître (`lyxal_catalogue`). Module hybride : les données,
les règles métier, les contrôles d'identité et les transitions d'état vivent dans le SurrealQL
du module ; le Rust lit les fichiers, normalise, calcule les empreintes, pilote le traitement par
blocs et publie vers le catalogue.

| | |
| :--- | :--- |
| Identifiant | `lyxal_pipeline_ingestion` (version `0.1.0`) |
| Dépendances (`manifest.toml`) | `lyxal_core`, `lyxal_base`, `lyxal_error`, `lyxal_event`, `lyxal_catalogue` |
| Hébergement | `apps/lyxal-server` (fonctionnalité `module-ingestion`) |
| Évolutions prévues | [`ROADMAP.md`](ROADMAP.md) |

```text
fichier → lot (RECEIVED) → lignes brutes immuables → normalisation → articles en staging
        → (anomalies en quarantaine) → manifeste scellé (BLAKE3) → approbation du Data Steward
        → ingestion.manifest.approved → publication au catalogue (catalogue_sync_agent)
```

---

## 1. Tables (`schema/`)

11 tables `TYPE NORMAL SCHEMAFULL`, sans suppression possible (`FOR delete NONE`).

| Table | Contenu | Lecture | Écriture |
| :--- | :--- | :--- | :--- |
| `ingestion_session` | session d'enregistrement | elle-même | — |
| `ingestion_batch` | lot : source, empreinte du fichier (unique par format), statut, compteurs, point de reprise, transitions | les quatre rôles | création : `ingestion_agent` ; mise à jour : agents et steward |
| `ingestion_raw_record` | ligne brute immuable (`<lot>_<ligne>`) | `ingestion_agent`, `qualification_agent`, `steward_admin` | création : `ingestion_agent` ; jamais modifiée |
| `ingestion_staged_item` | article normalisé : identité (lot, fabricant, référence uniques), code-barres, conditionnement, qualification, preuve, approbation, transitions | `qualification_agent`, `steward_admin`, `catalogue_sync_agent` | `qualification_agent` ; requalification : `steward_admin` |
| `ingestion_quarantine_record` | anomalie : ligne, code, sévérité, champ, valeur, cause, résolution | `qualification_agent`, `steward_admin` | création : `qualification_agent` ; résolution : `steward_admin` |
| `ingestion_publication_manifest` | manifeste : sceau BLAKE3, statut, approbation, journal d'exécution, transitions | `steward_admin`, `catalogue_sync_agent` | `steward_admin` ; exécution : `catalogue_sync_agent` |
| `ingestion_family_rule`, `ingestion_specification`, `ingestion_manufacturer_alias`, `ingestion_unit_alias`, `ingestion_substitution_rule` | référentiels (familles, spécifications patronnes, alias, substitutions certifiées) | les quatre rôles | `steward_admin` |

Gardes (`DEFINE EVENT`) :

* `evt_batch_guard` : `RECEIVED → PARSING → VALIDATING → STAGED → PUBLISHED`, `FAILED` depuis
  chaque étape, reprise `FAILED → RECEIVED | PARSING` (`INGESTION_BATCH_ILLEGAL_STATE_TRANSITION`).
* `evt_staged_guard` : transitions de qualification autorisées ; un article n'est jamais créé
  approuvé ; approbation réservée à un article `VERIFIED` et à l'identité de session d'un
  `steward_admin` (ou de la session système).
* `evt_manifest_guard` : `DRAFT → SEALED → APPROVED → EXECUTING → COMMITTED`, `FAILED` ;
  approbation : scellement et identité de session du steward ; exécution : `catalogue_sync_agent`
  (ou session système).

---

## 2. Fonctions (`functions/`)

25 fonctions `fn::ingestion_*($params: object)`, au contrat `fn::result_ok` /
`fn::error_result`. Entrées contrôlées par `lyxal_core` : moteur
`fn::validation_object_execute` / `fn::sanitize_object_execute` (`unknown_keys: "reject"`) pour
les fonctions appelées de l'extérieur ou une fois par lot ou par bloc ; primitives, en contrôles
successifs, pour les articles d'un bloc (appel ligne à ligne). Donnée invalide :
`INGESTION_INVALID_PARAMETERS` (détail par champ). Toute écriture est vérifiée
(`INGESTION_WRITE_FORBIDDEN` si les permissions la filtrent). Les transitions sont construites
par SurrealQL au nom de l'identité de session (`triggered_by`) et horodatées par la base.

| Groupe | Fonctions |
| :--- | :--- |
| Lots (`batch/`) | `batch_create` (état `RECEIVED` ; fichier ou identifiant déjà reçu : `INGESTION_BATCH_DUPLICATE`), `batch_get`, `batch_transition`, `batch_checkpoint`, `raw_records_save` (bloc ; ligne existante jamais réécrite) |
| Staging (`staged/`) | `staged_save` (bloc d'articles d'un lot, un résultat par article ; code-barres contrôlé par `fn::validation_gtin` : `INGESTION_GTIN_INVALID`), `staged_list`, `staged_requalify` (steward ; `VERIFIED` exige une preuve commerciale) |
| Quarantaine (`quarantine/`) | `quarantine_log` (rejouable : une anomalie ouverte par ligne et par code), `quarantine_list`, `quarantine_resolve` (steward ; corrections contrôlées, article repassé `TO_CONFIRM`) |
| Manifestes (`manifest/`) | `manifest_save` (`DRAFT` / `SEALED`, modifiable tant qu'il n'est pas approuvé ; une version par lot), `manifest_approve` (steward, justification journalisée), `manifest_execution_item_update`, `manifest_record_exec` (agent de synchronisation), `manifest_list`, `manifest_get_detail` |
| Référentiels (`rule/`) | `resolve_unit` (alias, puis unité utilisable lue par `fn::base_unite_get` de `lyxal_base`), `resolve_manufacturer`, `rule_family_add`, `rule_spec_add`, `rule_substitution_add` (révocation motivée), `rules_load` |
| Pilotage | `dashboard_metrics` |
| Session (`session/`) | `session_identity` (interne) : rôle et opérateur lus dans `$token` / `$auth` ; session de l'hôte = `system` ; jamais dans les paramètres |

---

## 3. Identités

| Rôle (claims `role`, `scope`) | Responsabilité |
| :--- | :--- |
| `ingestion_agent` (`ingestion:batch:write`) | lots et lignes brutes |
| `qualification_agent` (`ingestion:staged:qualify`) | articles en staging, anomalies |
| `steward_admin` (`ingestion:manifest:approve`) | requalification, résolution, manifestes, approbation, référentiels |
| `catalogue_sync_agent` (`catalogue:sync:write`) | exécution des manifestes approuvés |

La session système de l'hôte (root, sans accès d'enregistrement) agit comme `system`. Un rôle
inconnu ne lit rien et n'écrit rien.

---

## 4. Événements

| Événement | Émetteur |
| :--- | :--- |
| `ingestion.manifest.approved` | `DEFINE EVENT` sur le passage à `APPROVED` (`fn::event_publish` vérifié) |
| `ingestion.batch.staged`, `ingestion.batch.failed` | worker |
| `ingestion.manifest.published` | publication, manifeste `COMMITTED` |

---

## 5. Publication vers le catalogue

`PublicationConsumer` (consommateur `lyxal_event`, abonnement `ingestion_manifest_publication`)
publie chaque manifeste approuvé ; la livraison est au moins une fois, la publication idempotente.

* **Identité** : jeton HS256 `catalogue_sync_agent` (`iss = lyxal-os`, `aud = lyxal-catalogue`,
  5 min) signé par `HmacCatalogueTokenIssuer` (`lyxal_crypto::hmac`) avec la clé de l'hôte
  (`CatalogueSyncKey`, 32 caractères `A-Z a-z 0-9 _ -`) ; le client de l'hôte est cloné (nouvelle
  session SurrealDB) puis authentifié par ce jeton.
* **Contrôles** : sceau recalculé sur les articles du lot ; seuls les articles `VERIFIED` dont la
  preuve est éligible à la production (ni pilote, ni synthétique) sont publiés.
* **Écriture** : `fn::catalogue_item_create` (article commercial maître, `code = master_id =
  ING-<empreinte BLAKE3 de fabricant et référence>`, type, unité de référence, unité de
  conditionnement `unite_conditionnement`, conditionnement) ;
  un article déjà présent est mis à jour (`fn::catalogue_item_update`).
* **Journal et issue** : chaque article est journalisé dans le manifeste ; une reprise saute les
  articles déjà publiés. `COMMITTED` si tout est publié, sinon `FAILED` (le steward corrige puis
  réapprouve). Panne de base : l'événement est rejoué ; manifeste non publiable : lettre morte.
* **Hôte** : clé `LYXAL__CATALOGUE_SYNC__SIGNING_KEY` ; avec elle, l'hôte définit l'accès JWT
  `lyxal_catalogue_sync` et active l'abonnement ; sans elle, l'abonnement est suspendu, l'accès
  retiré et la sonde de santé du module dégradée.

---

## 6. Rust (`src/`)

| Composant | Rôle |
| :--- | :--- |
| `adapters/` | lecture FAB-DIS, CSV (délimiteurs), XML / BMEcat, JSON / NDJSON |
| `normalization/` | nettoyage, dimensions et poids, attributs techniques, qualification initiale (`VERIFIED` exige une preuve commerciale valide) |
| `fingerprint.rs` | empreintes canoniques et sceau des manifestes (BLAKE3, `lyxal_crypto`) |
| `worker/` | `IngestionWorker` (`LyxalWorker`) : traitement par blocs, point de reprise, verrou de lot ; GTIN refusé ou article rejeté consigné en quarantaine ; un lot en échec passe en `FAILED` sans arrêter le worker |
| `storage/` | `IngestionStore` : appels `call_fn` des fonctions du module ; erreur métier transmise avec son code (`IngestionError::Surreal`) |
| `publisher/` | publication (§5) |
| `rules.rs` | modèles des référentiels |
| `module.rs`, `health.rs` | `PipelineIngestionModule` (`LyxalModule`), `IngestionHealthCheck` |
| `error.rs` | `IngestionError` et correspondance avec les définitions (`info()`, test) |

---

## 7. Erreurs (`error/`) et seeds

40 définitions `INGESTION_*` par thème (`articles`, `lots`, `manifestes`, `parametres`,
`permissions`, `preuves`, `quarantaine`, `referentiels`, `techniques`), créées seulement si elles
n'existent pas. Seeds rejouables : familles (`01`), spécifications (`02`), alias de fabricants et
d'unités (`03`). Démonstration carrelage : `tests/fixtures/carrelage_demo.surql`, jamais installée.

---

## 8. Vérification

* Banc SurrealQL (`scripts/ci/test_lyxal_modules.py`, module installé depuis son manifeste,
  identités simulées) : `lots`, `qualification`, `quarantaine`, `manifestes`, `referentiels`,
  `permissions`, `securite` ; chaque fonction publique est appelée.
* `cargo test -p lyxal_pipeline_ingestion` : module installé depuis son manifeste
  (`tests/it/support.rs`), adaptateurs, normalisation, worker (reprise, interruption, lot en
  échec, GTIN), console du steward, publication réelle dans le catalogue, débit (1 600 articles).
  Les tests « serveur réel » utilisent le serveur de recette démarré par `scripts/ci/test_all.sh`
  (identifiants générés à chaque exécution).
* `apps/lyxal-server` : publication de bout en bout par le moteur d'événements.
* `scripts/ci/ci_local.sh` rejoue la CI complète.
