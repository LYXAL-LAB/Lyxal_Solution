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
| `ingestion_batch` | lot : source, encodage déclaré (`UTF-8`, `WINDOWS-1252`, `ISO-8859-1`), empreinte du fichier (unique par format), statut, compteurs, point de reprise, réservation du traitement, transitions | les quatre rôles | création : `ingestion_agent` ; mise à jour : agents et steward |
| `ingestion_raw_record` | ligne brute immuable (`<lot>_<ligne>`) | `ingestion_agent`, `qualification_agent`, `steward_admin` | création : `ingestion_agent` ; jamais modifiée |
| `ingestion_staged_item` | article normalisé : identité (lot, fabricant, référence uniques), code-barres, conditionnement, qualification, preuve, approbation, transitions | `qualification_agent`, `steward_admin`, `catalogue_sync_agent` | `qualification_agent` ; requalification : `steward_admin` |
| `ingestion_quarantine_record` | anomalie : ligne, code, sévérité, champ, valeur, cause, résolution | `qualification_agent`, `steward_admin` | création : `qualification_agent` ; résolution : `steward_admin` |
| `ingestion_publication_manifest` | manifeste : sceau BLAKE3, statut, approbation, journal d'exécution, transitions | `steward_admin`, `catalogue_sync_agent` | `steward_admin` ; exécution : `catalogue_sync_agent` |
| `ingestion_family_rule`, `ingestion_specification`, `ingestion_manufacturer_alias`, `ingestion_unit_alias`, `ingestion_substitution_rule` | référentiels (familles, spécifications patronnes, alias, substitutions certifiées) | les quatre rôles | `steward_admin` |

Gardes (`DEFINE EVENT`) :

* `evt_batch_guard` : `RECEIVED → PARSING → VALIDATING → STAGED → PUBLISHED`, `FAILED` depuis
  chaque étape, reprise `FAILED → RECEIVED | PARSING` (`INGESTION_BATCH_ILLEGAL_STATE_TRANSITION`).
* `evt_staged_guard` : un article d'un lot verrouillé par un manifeste scellé
  (`ingestion_batch.sealed_manifest`) ne se crée ni ne se modifie (`INGESTION_STAGED_ITEM_SEALED`) ;
  transitions de qualification autorisées ; un article n'est jamais créé approuvé ; approbation réservée à un article `VERIFIED` et à l'identité de session d'un
  `steward_admin` (ou de la session système).
* `evt_manifest_guard` : `DRAFT → SEALED → APPROVED → EXECUTING → COMMITTED`, `FAILED` ;
  approbation : scellement (contenu et sceau) et identité de session du steward ; exécution :
  `catalogue_sync_agent` (ou session système) ; contenu et sceau ne changent qu'en brouillon ou
  au scellement.
* `evt_batch_guard` refuse aussi qu'un autre rôle que le steward (ou la session système) pose ou
  retire le verrou `sealed_manifest` d'un lot, et qu'une génération de réservation recule
  (`INGESTION_BATCH_CLAIM_LOST`).

**Réservation du traitement.** Un lot n'est traité que par une exécution à la fois, tous workers
et toutes instances confondus. `fn::ingestion_batch_claim` (jeton propre à l'exécution, durée de
5 à 600 s, 60 par défaut) prend la réservation seulement si elle est libre ou expirée — une
réservation active est refusée même au même jeton (`INGESTION_BATCH_ALREADY_CLAIMED`,
`details.until`) — et incrémente sa génération (`claim_owner`, `claim_generation`, `claim_until`,
heure de la base). Les écritures du traitement (`raw_records_save`, `staged_save`,
`quarantine_log`, `batch_checkpoint`, `batch_transition`) reçoivent `claim: { owner, generation }`
et vérifient dans leur requête (`fn::ingestion_batch_claim_verify`) que la réservation est
détenue et non expirée, sinon `INGESTION_BATCH_CLAIM_LOST` sans rien écrire. Seul le point de reprise la renouvelle : le worker l'enregistre en fin de bloc et le rejoue au
tiers de la durée de réservation pendant le traitement (lecture du fichier, bloc long), ses
écritures étant sérialisées ; `fn::ingestion_batch_release` la libère (exécution détentrice seulement).
Une réservation expirée (exécution arrêtée) est reprise à la génération suivante, ce qui écarte
l'ancienne exécution.

**Scellement.** `fn::ingestion_manifest_save` au statut `SEALED` fige dans le manifeste le contenu
exact à publier (`contenu`, construit par `fn::ingestion_manifest_content` : un élément par
article `VERIFIED`, avec la charge utile de `fn::catalogue_item_create` et la preuve
commerciale), calcule son sceau BLAKE3 sur le contenu stocké (aucun sceau n'est accepté de
l'appelant) et verrouille le lot. Pour corriger un article, le steward remet le manifeste en
brouillon (`SEALED` ou `FAILED` → `DRAFT` : contenu et sceau effacés, lot déverrouillé), corrige,
rescelle puis réapprouve. `fn::ingestion_manifest_get_detail` renvoie `seal_valid`, le sceau
recalculé par le serveur sur le contenu.

---

## 2. Fonctions (`functions/`)

26 fonctions `fn::ingestion_*($params: object)`, au contrat `fn::result_ok` /
`fn::error_result`. Entrées contrôlées par `lyxal_core` : moteur
`fn::validation_object_execute` / `fn::sanitize_object_execute` (`unknown_keys: "reject"`) pour
les fonctions appelées de l'extérieur ou une fois par lot ou par bloc ; primitives, en contrôles
successifs, pour les articles d'un bloc (appel ligne à ligne). Donnée invalide :
`INGESTION_INVALID_PARAMETERS` (détail par champ). Toute écriture est vérifiée
(`INGESTION_WRITE_FORBIDDEN` si les permissions la filtrent). Les transitions sont construites
par SurrealQL au nom de l'identité de session (`triggered_by`) et horodatées par la base.

| Groupe | Fonctions |
| :--- | :--- |
| Lots (`batch/`) | `batch_create` (état `RECEIVED` ; fichier ou identifiant déjà reçu : `INGESTION_BATCH_DUPLICATE`), `batch_get`, `batch_claim`, `batch_release`, `batch_claim_verify` (interne), `batch_transition`, `batch_checkpoint` (renouvelle la réservation), `raw_records_save` (bloc ; ligne existante jamais réécrite) ; écritures du traitement sous réservation (`claim`) |
| Staging (`staged/`) | `staged_save` (bloc d'articles d'un lot, un résultat par article ; code-barres contrôlé par `fn::validation_gtin` : `INGESTION_GTIN_INVALID`), `staged_list`, `staged_requalify` (steward ; `VERIFIED` exige une unité du référentiel et une preuve commerciale) ; unité et unité de vente facultatives tant que l'unité fournisseur n'est pas résolue |
| Quarantaine (`quarantine/`) | `quarantine_log` (rejouable : une anomalie ouverte par ligne et par code), `quarantine_list`, `quarantine_resolve` (steward ; corrections contrôlées, article repassé `TO_CONFIRM`) |
| Manifestes (`manifest/`) | `manifest_save` (`DRAFT` / `SEALED`, modifiable tant qu'il n'est pas approuvé ; une version par lot), `manifest_approve` (steward, justification journalisée), `manifest_execution_item_update`, `manifest_record_exec` (agent de synchronisation), `manifest_list`, `manifest_get_detail` |
| Référentiels (`rule/`) | `resolve_units` (bloc de 500 au plus : alias commerciaux, puis codes Lyxal et codes d'échange par `fn::base_unite_resolve` de `lyxal_base` ; seules les unités utilisables), `resolve_manufacturers` (bloc : alias après normalisation et retrait des suffixes juridiques ; `is_verified = false` pour un groupe sans entité déterminée), `rule_family_add`, `rule_spec_add`, `rule_substitution_add` (révocation motivée), `rules_load` |
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
| `ingestion.manifest.approved` | passage du manifeste à `APPROVED` |
| `ingestion.manifest.published` | passage du manifeste à `COMMITTED` (compteurs d'exécution, auteur de la transition) |
| `ingestion.batch.staged` | passage du lot à `STAGED` (compteurs du dernier checkpoint) |
| `ingestion.batch.failed` | passage du lot à `FAILED` (code d'erreur et motif de la transition) |

Tous sont émis par la base (`events/01_events.surql`) : un `DEFINE EVENT` sur la transition
appelle `fn::event_publish` dans la même transaction et annule la transition si la publication
échoue. L'état et son événement ne peuvent pas diverger, et une transition n'émet qu'une fois.
Le passage d'un lot à `FAILED` exige son code d'erreur (`error_code` de
`fn::ingestion_batch_transition`, `IngestionStore::fail_batch`).

---

## 5. Publication vers le catalogue

`PublicationConsumer` (consommateur `lyxal_event`, abonnement `ingestion_manifest_publication`)
publie chaque manifeste approuvé ; la livraison est au moins une fois, la publication idempotente.

* **Identité** : jeton HS256 `catalogue_sync_agent` (`iss = lyxal-os`, `aud = lyxal-catalogue`,
  5 min) signé par `HmacCatalogueTokenIssuer` (`lyxal_crypto::hmac`) avec la clé de l'hôte
  (`CatalogueSyncKey`, 32 caractères `A-Z a-z 0-9 _ -`) ; le client de l'hôte est cloné (nouvelle
  session SurrealDB) puis authentifié par ce jeton.
* **Contrôles** : sceau du contenu figé vérifié par le serveur (`seal_valid`), sinon refus sans
  aucune écriture ; seuls les éléments du contenu figé dont la preuve est éligible à la production
  (ni pilote, ni synthétique) sont publiés, jamais l'état courant du staging.
* **Écriture** : `fn::catalogue_item_create` avec la charge utile figée (article commercial
  maître, `code = master_id = ING-<32 premiers caractères du BLAKE3 de [fabricant, référence]>`,
  type, unité de référence, conditionnement, unité de conditionnement) ; un article déjà présent
  est mis à jour (`fn::catalogue_item_update`).
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
| `adapters/` | correspondance métier des sources lues par `lyxal_parsing` (encodage déclaré du lot, rejets explicites) : CSV (séparateur détecté, champs multilignes), JSON / NDJSON (élément non objet rejeté), XML / BMEcat (entités décodées, éléments `ARTICLE` / `PRODUCT` / `ITEM`), FAB-DIS 3.0 (tabulaire) et 2.3 (blocs `C` / `L` / `R` sans en-tête, regroupés par référence ; bloc orphelin, en double, sans référence ou inconnu : `INGESTION_FABDIS_BLOCK_INVALID`) ; `SourceAdapter::read` rend la suite des éléments (enregistrement ou rejet) ou `IngestionError::SourceInvalid` |
| `normalization/` | nettoyage, dimensions et poids, attributs techniques, qualification initiale (`VERIFIED` exige une preuve commerciale valide et une unité) ; unités et fabricants lus dans les résolutions du bloc (`BlockReferentials`), sans table de correspondance en Rust |
| `fingerprint.rs` | empreintes canoniques et sceau des manifestes (BLAKE3, `lyxal_crypto`) |
| `worker/` | `IngestionWorker` (`LyxalWorker`) : traitement par blocs, point de reprise ; chaque `process_batch` tire un jeton (UUID v7), réserve le lot en base, présente la réservation à chaque écriture et la libère quelle que soit l'issue (lot déjà réservé : `IngestionError::BatchAlreadyClaimed`, ni traité ni marqué `FAILED` ; réservation perdue : travail remis en file ; réservation ou passage en `FAILED` impossibles pour une raison technique : `IngestionError::FailureNotRecorded`, travail conservé et worker arrêté pour relance par le superviseur) ; unités et fabricants du bloc résolus en base en deux appels (`IngestionStore::block_referentials`) ; source lue en entier avant le premier bloc (illisible : lot `FAILED`, `INGESTION_SOURCE_INVALID`, rien en staging) ; un enregistrement écarté à la lecture garde son numéro, reçoit une ligne brute de rejet (cause, sans contenu) et une anomalie `INGESTION_SOURCE_RECORD_REJECTED` (cause `PARSING_*` en détail) ; GTIN refusé ou article rejeté consigné en quarantaine ; unité inconnue : article en staging sans unité et anomalie `INGESTION_UNIT_UNRESOLVED` (jamais de valeur par défaut) ; un lot en échec passe en `FAILED` pendant que la réservation est détenue, sans arrêter le worker |
| `storage/` | `IngestionStore` : appels `call_fn` des fonctions du module ; erreur métier transmise avec son code (`IngestionError::Surreal`) |
| `publisher/` | publication (§5) |
| `rules.rs` | modèles des référentiels |
| `module.rs`, `health.rs` | `PipelineIngestionModule` (`LyxalModule`), `IngestionHealthCheck` |
| `error.rs` | `IngestionError` et correspondance avec les définitions (`info()`, test) |

---

## 7. Erreurs (`error/`) et seeds

40 définitions `INGESTION_*` par thème (`articles`, `lots`, `manifestes`, `parametres`,
`permissions`, `preuves`, `quarantaine`, `referentiels`, `techniques`), créées seulement si elles
n'existent pas. Seeds rejouables : familles (`01`), spécifications (`02`), alias de fabricants (44) et
libellés d'unités fournisseurs (46) (`03`) ; les codes Lyxal et d'échange des unités sont résolus par
`lyxal_base`, sans alias. Démonstration carrelage : `tests/fixtures/carrelage_demo.surql`, jamais installée.

---

## 8. Vérification

* Banc SurrealQL (`scripts/ci/test_lyxal_modules.py`, module installé depuis son manifeste,
  identités simulées) : `lots`, `qualification`, `quarantaine`, `manifestes`, `referentiels`,
  `permissions`, `securite` ; chaque fonction publique est appelée.
* `cargo test -p lyxal_pipeline_ingestion` : module installé depuis son manifeste
  (`tests/it/support.rs`), adaptateurs, normalisation, worker (reprise, interruption, lot en
  échec, GTIN, unité inconnue), console du steward, publication réelle dans le catalogue, débit
  (1 600 articles, seuil 50 articles/s).
  Les tests « serveur réel » utilisent le serveur de recette démarré par `scripts/ci/test_all.sh`
  (identifiants générés à chaque exécution).
* `apps/lyxal-server` : publication de bout en bout par le moteur d'événements.
* `scripts/ci/ci_local.sh` rejoue la CI complète.
