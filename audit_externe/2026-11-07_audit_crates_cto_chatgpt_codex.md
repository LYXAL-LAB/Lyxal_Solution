# Audit externe CTO — dossier `crates/` de Lyxal Solution

| Métadonnée | Valeur |
|---|---|
| Date de l'audit | **7 novembre 2026 (UTC)** |
| Date de mise en dossier du rapport | **7 novembre 2026 (UTC)** |
| Auteur et auditeur | **ChatGPT / Codex, assistant d'intelligence artificielle d'OpenAI** |
| Attribution explicite | **Cet audit a été réalisé et ce rapport rédigé par ChatGPT / Codex (OpenAI), à la demande de l'utilisateur, en adoptant une perspective de CTO.** |
| Projet | Lyxal Solution / Lyxal OS |
| Périmètre | Les neuf dossiers de `crates/` à la racine du projet |
| Commit audité | `3c994ee31deb451a5e5eb87a2320c4b436cb71ba` |
| Branche lors de l'analyse | `work` |
| Branche de remise du rapport | `main` |
| Verdict | **NON CONFORME — points P0/P1 bloquants** |

Ce document reprend l'intégralité du rapport remis dans la conversation : périmètre,
synthèse, constats A01 à A11, correspondances DTO, tests, limites de preuve,
appréciations par module et plan correctif. Les liens vers le code sont relatifs
au présent dossier ; les numéros de ligne se rapportent au commit audité.

L'analyse a été effectuée sans modification de fichier suivi par Git. La présente
remise ajoute uniquement ce document dans `audit_externe/`. La branche locale
`main`, absente lors de la remise, a été créée au commit audité ; aucune référence
distante à `main` n'était disponible. Aucun correctif applicatif n'est inclus.
Les résultats d'exécution ci-dessous proviennent de l'audit initial : ils n'ont
pas été réexécutés pour cette simple mise en dossier.

## 1. Périmètre audité

L'audit couvre les neuf dossiers de `crates/`, selon le [guide d'audit du dépôt](../.agents/skills/lyxal-audit/SKILL.md).

| Module | Position architecturale | Rust, fichiers | SurrealQL, fichiers | Fonctions SurrealQL |
|---|---|---:|---:|---:|
| `lyxal_core` | Bibliothèque transversale | 0 | 963 | 481 |
| `lyxal_crypto` | Fondation cryptographique | 39 | 0 | 0 |
| `lyxal_error` | Contrats et moteur d'erreurs | 8 | 22 | 18 |
| `lyxal_surreal` | Transport et appels typés | 6 | 1 | 0 |
| `lyxal_event` | Moteur événementiel | 45 | 25 | 18 |
| `lyxal_runtime` | Installation et orchestration | 142 | 11 | 21 |
| `lyxal_base` | Référentiels transversaux | 0 | 28 | 11 |
| `lyxal_catalogue` | Module métier | 0 | 56 | 24 |
| `lyxal_pipeline_ingestion` | Module métier hybride | 38 | 57 | 25 |
| **Total** | | **278** | **1 263** | **598** |

Ces nombres incluent les fichiers de tests.

Les contrôles globaux ont porté sur les manifestes, les graphes de dépendances,
les ressources installées, les signatures, les références de fonctions, les codes
d'erreur et les constructions obsolètes. La lecture manuelle a ciblé les chemins
critiques : transport, cryptographie, permissions, publication, événements,
ressources, workers et reprise.

Les huit manifestes présents sont en version `0.1.0`. L'absence de manifeste dans
`lyxal_crypto`, bibliothèque pure sans ressources en base, n'est pas retenue comme
anomalie.

Référentiels consultés :

- [Point d'entrée des agents](../AGENTS.md).
- [Charte d'architecture du workspace](../.agents/AGENTS.md).
- [Standards et checklist](../.agents/rules/lyxal_standards_and_checklist.md).
- [Constitution d'architecture](../LYXAL_ARCHITECTURE.md).
- [Procédure d'audit](../.agents/skills/lyxal-audit/SKILL.md).
- [Workspace Cargo](../Cargo.toml), [lockfile](../Cargo.lock) et [toolchain](../rust-toolchain.toml).
- Manifestes, sources, schémas, fonctions, événements, seeds, définitions d'erreurs,
  tests, README et feuilles de route des modules du périmètre ; fichiers critiques
  référencés dans les sections suivantes.
- [Workflow CI](../.github/workflows/ci.yml) et scripts de `scripts/ci/`.

## 2. Synthèse exécutive et verdict

**Mon verdict de CTO : le socle est structuré et largement testé, mais plusieurs
défauts d'intégrité et de reprise bloquent une mise en production.** Les corrections
doivent porter en priorité sur l'ingestion, l'isolation des personnalisations et
certains mécanismes du runtime.

**Verdict : NON CONFORME — points P0/P1 bloquants.**

Le projet possède des fondations concrètes :

- les responsabilités des crates sont identifiables ;
- les dépendances Cargo et les dépendances des manifestes ne présentent pas de cycle ;
- les ressources déclarées correspondent aux fichiers de production ;
- les appels métier passent par des contrats typés ;
- les suites du runtime et du moteur événementiel passent intégralement dans les
  conditions testées.

Le principal problème est **l'écart entre certaines garanties annoncées et les
garanties effectivement assurées par le code** :

- un manifeste scellé ne garantit pas intégralement le contenu publié ;
- une personnalisation dite locale peut affecter plusieurs locataires dans une
  base partagée ;
- certains succès en base peuvent être suivis d'une perte d'événement ;
- les checkpoints d'ingestion ne suffisent pas à reconstruire automatiquement le
  travail après un redémarrage ;
- plusieurs adaptateurs peuvent transformer ou ignorer des données sans signaler
  le problème.

**Ma décision serait de conserver l'architecture générale et de suspendre
l'élargissement fonctionnel jusqu'à fermeture de ces défauts.** Les preuves
recueillies ne justifient pas une réécriture générale.

## 3. Écarts constatés

P0 désigne ici un blocage d'intégrité ou d'isolation ; P1 un défaut majeur de
fonctionnement ou de fiabilité ; P2 un écart de qualité ou de gouvernance.

| ID | Niveau | Constat et preuve | Correction recommandée |
|---|---|---|---|
| A01 | **P0** | Le contrôle du sceau réutilise les `canonical_fingerprint` stockées, sans recalculer l'empreinte du contenu courant. Voir [publication](../crates/lyxal_pipeline_ingestion/src/publisher/controlled_publisher.rs#L126) et [empreinte canonique](../crates/lyxal_pipeline_ingestion/src/fingerprint.rs#L21). | Sceller un contenu canonique complet et immuable, puis vérifier exactement ce contenu avant publication. |
| A02 | **P0 en base partagée** | Les personnalisations des articles maîtres sont des champs du même enregistrement partagé. Un `tenant_user` peut modifier un article maître sans condition de propriété sur cette branche. Voir [permissions](../crates/lyxal_catalogue/schema/02_catalogue_item.surql#L31) et [champs personnalisés](../crates/lyxal_catalogue/schema/02_catalogue_item.surql#L230). | Séparer les personnalisations par couple `(tenant_id, article maître)`, ou démontrer et imposer l'isolation physique des bases. |
| A03 | **P1** | Le lecteur de ressources annonce une protection contre les liens symboliques, mais utilise `is_file`, `metadata` et `fs::read`, qui les suivent. Sortie du dossier du module reproduite. Voir [FilesystemResourceProvider](../crates/lyxal_runtime/src/resource/filesystem.rs#L35). | Vérifier le confinement réel du fichier ouvert et refuser les liens symboliques selon le modèle de confiance retenu. |
| A04 | **P1** | L'état `COMMITTED` est enregistré avant l'émission de `ingestion.manifest.published`. Une reprise retourne immédiatement si le manifeste est déjà `COMMITTED`. L'événement peut donc être perdu. Voir [retour anticipé](../crates/lyxal_pipeline_ingestion/src/publisher/controlled_publisher.rs#L106) et [émission](../crates/lyxal_pipeline_ingestion/src/publisher/controlled_publisher.rs#L204). | Produire l'événement dans la transaction qui termine le manifeste, via l'outbox. |
| A05 | **P1** | Les adaptateurs acceptent des cas qu'ils traitent incorrectement : CSV multiligne découpé en plusieurs articles, éléments JSON non objets ignorés, entités XML non décodées. Reproductions exécutées. Voir [CSV](../crates/lyxal_pipeline_ingestion/src/adapters/csv.rs#L121), [JSON](../crates/lyxal_pipeline_ingestion/src/adapters/json.rs#L194), [XML](../crates/lyxal_pipeline_ingestion/src/adapters/xml.rs#L20). | Utiliser des parseurs adaptés aux formats et rendre chaque rejet explicite et traçable. |
| A06 | **P1** | La file d'ingestion et les octets sources sont conservés en mémoire. Le fichier est intégralement parsé avant traitement par blocs. Voir [file de travail](../crates/lyxal_pipeline_ingestion/src/worker/ingestion_worker.rs#L60) et [parsing complet](../crates/lyxal_pipeline_ingestion/src/worker/ingestion_worker.rs#L195). | Persister la source et le travail à exécuter, reconstruire la file au redémarrage et borner mémoire/file d'attente. |
| A07 | **P1** | Le verrou logique du worker laisse passer un second traitement lorsqu'il porte sur le même `batch_id`. Il reste également local au processus. Voir [process_batch](../crates/lyxal_pipeline_ingestion/src/worker/ingestion_worker.rs#L131). | Exclure toute exécution simultanée du même lot et coordonner les instances si plusieurs workers peuvent le prendre. |
| A08 | **P1** | La purge supprime les livraisons anciennes marquées `delivered`, sans vérifier leur position par rapport au curseur persistant. Or le flush exige la présence de chaque séquence lors d'un avancement ultérieur. Voir [purge](../crates/lyxal_event/functions/event_purge_garbage.surql#L25) et [contrôle des trous](../crates/lyxal_event/functions/event_flush_batch.surql#L123). | Ne purger que les séquences couvertes par le curseur durable de leur abonnement. |
| A09 | **P1** | Certaines fonctions d'erreur enveloppent directement une écriture dans `result_ok`, sans vérifier qu'elle a produit un enregistrement. Un refus par permissions peut ainsi être présenté comme un succès sans donnée. Voir [error_log](../crates/lyxal_error/functions/service/error_log.surql#L53) et [création de définition](../crates/lyxal_error/functions/definition/error_definition_create.surql#L57). | Contrôler le résultat des écritures et distinguer explicitement refus d'écriture et absence volontaire de journalisation. |
| A10 | **P2** | `lyxal_pipeline_ingestion` est explicitement exclu du contrôle Clippy bloquant. Voir [script CI](../scripts/ci/clippy.sh#L8). | Résorber les avertissements et réintégrer le module au contrôle commun. |
| A11 | **P2** | La constitution recommande encore `fn::result_error`, interdit par les règles actuelles. La roadmap d'ingestion décrit aussi des fichiers et mécanismes déjà remplacés. Voir [constitution](../LYXAL_ARCHITECTURE.md#L91) et [roadmap](../crates/lyxal_pipeline_ingestion/ROADMAP.md#L23). | Aligner les documents normatifs et les feuilles de route sur le code actuel. |

Règles internes principalement concernées : charte §1 (isolation et contrats),
§5.5 (idempotence), §5.6 (outbox, livraison, curseurs), §5.8 (workers et runtime),
standards §11.4 (écritures refusées et absence d'erreurs silencieuses), ainsi que
le régime documentaire pré-production de la charte §0.

### A01 — La garantie de scellement est insuffisante

L'empreinte canonique ne couvre notamment pas le conditionnement complet, la
description technique ou la preuve commerciale. Une modification de ces données
peut conserver les mêmes empreintes stockées et le même sceau. Les
[corrections de quarantaine](../crates/lyxal_pipeline_ingestion/functions/quarantine/ingestion_quarantine_resolve.surql#L76)
modifient aussi des données sans recalculer cette empreinte. Le problème porte
sur le contenu engagé par le hash, indépendamment de la solidité de BLAKE3.

### A02 — Le risque concerne précisément une base mutualisée

Dans cette configuration, Alpha et Beta accèdent au même article maître. Si Alpha
change son `libelle_personnalise` ou son `enabled`, il modifie les champs que Beta
lit également. Les protections des articles privés ne résolvent pas ce cas. Une
base distincte par locataire peut changer l'analyse, mais cette contrainte doit
être imposée et prouvée.

### A04 — La fenêtre de perte est identifiable

Le catalogue et le manifeste peuvent être correctement enregistrés, puis le
processus s'arrêter avant l'émission de l'événement final. Au rejeu, la branche
« déjà exécuté » empêche cette émission. Le worker présente une fenêtre comparable
entre le passage du lot à `STAGED` et l'émission de `ingestion.batch.staged`.

### A08 — Scénario à tester impérativement

Une livraison située après un trou de séquence peut déjà être marquée livrée. Si
elle est purgée pendant une suspension prolongée de l'abonnement, la résolution
ultérieure du trou peut rencontrer une séquence manquante. Ce constat vient de
l'analyse du code ; ce scénario n'a pas été reproduit sur serveur pendant cet audit.

## 4. Correspondance DTO Rust ↔ SurrealQL

Le croisement des noms de champs n'a révélé **aucune divergence bloquante au premier
niveau des DTO examinés**. Les alias et transformations explicites ont été pris
en compte, notamment `type_item` → `type` dans le client du catalogue.

Le tableau suivant donne la correspondance par fonction. « Alignés » désigne les
champs sérialisés du DTO indiqué ; `L` signifie que SurrealQL accepte aussi
`language`, facultatif avec valeur par défaut, sans que ce DTO l'expose. Cette
omission ne constitue pas un défaut d'exécution.

Les définitions sont consultables dans les fichiers
[erreurs](../crates/lyxal_error/src/types.rs),
[runtime](../crates/lyxal_runtime/src/store/dto.rs),
[baux runtime](../crates/lyxal_runtime/src/lock/store.rs),
[événements](../crates/lyxal_event/src/engine/dto.rs),
[store événementiel](../crates/lyxal_event/src/store/event_store.rs),
[ingestion](../crates/lyxal_pipeline_ingestion/src/storage/store.rs) et
[client catalogue](../crates/lyxal_pipeline_ingestion/src/publisher/catalogue.rs).

### Correspondance détaillée des fonctions et DTO

Les préfixes indiqués dans chaque groupe font partie du nom de fonction. Aucun
champ incompatible n'a été relevé dans ce contrôle statique au premier niveau.

| Fonction `fn::error_*` | DTO Rust | Champs conformes | Absents côté Rust | Supplémentaires |
|---|---|---|---|---|
| `definition_create` | `ErrorDefinitionCreateParams` | Alignés | — | — |
| `definition_get` | `ErrorDefinitionGetParams` | Alignés | — | — |
| `definition_list` | `ErrorDefinitionListParams` | Alignés | — | — |
| `definition_update` | `ErrorDefinitionUpdateParams` | Alignés, modifications appliquées dynamiquement | — | — |
| `definition_disable` | `ErrorDefinitionDisableParams` | Alignés | — | — |
| `mapping_create` | `ErrorMappingCreateParams` | Alignés | — | — |
| `mapping_get` | `ErrorMappingGetParams` | Alignés | — | — |
| `mapping_list` | `ErrorMappingListParams` | Alignés | — | — |
| `mapping_update` | `ErrorMappingUpdateParams` | Alignés, modifications appliquées dynamiquement | — | — |
| `mapping_disable` | `ErrorMappingDisableParams` | Alignés | — | — |
| `map_external` | `ErrorMapExternalParams` | Alignés | — | — |
| `log` | `ErrorLogParams` | Alignés | — | — |
| `occurrence_get` | `ErrorOccurrenceGetParams` | Alignés | — | — |
| `occurrence_list` | `ErrorOccurrenceListParams` | Alignés | — | — |
| `occurrence_purge_before` | `ErrorOccurrencePurgeParams` | Alignés ; `before_date` natif `Datetime` | — | — |

| Fonction `fn::runtime_*` | DTO Rust | Champs conformes | Absents côté Rust | Supplémentaires |
|---|---|---|---|---|
| `module_upsert` | `ModuleUpsertParams` | Alignés | L | — |
| `module_get` | `ModuleGetParams` | Alignés | L | — |
| `module_list` | `ListParams` | Aucun champ métier | — | `language`, ignoré |
| `release_register` | `ReleaseRegisterParams` | Alignés | L | — |
| `release_get` | `ReleaseGetParams` | Alignés | L | — |
| `release_list` | `ReleaseListParams` | Alignés | L | — |
| `release_status_update` | `ReleaseStatusUpdateParams` | Alignés | L | — |
| `migration_record` | `MigrationRecordParams` | Alignés, dont garde de bail | L | — |
| `migration_get` | `MigrationGetParams` | Alignés | L | — |
| `migration_list` | `MigrationListParams` | Alignés | L | — |
| `lease_acquire` | `LeaseAcquireParams` | Alignés | L | — |
| `lease_renew` | `LeaseRenewParams` | Alignés | L | — |
| `lease_release` | `LeaseReleaseParams` | Alignés | L | — |
| `lease_get` | `LeaseGetParams` | Alignés | L | — |
| `health_record` | `HealthRecordParams` | Alignés | L | — |
| `health_list` | `NodeParams` | Alignés | L | — |
| `worker_upsert` | `WorkerUpsertParams` | Alignés | L | — |
| `worker_get` | `WorkerGetParams` | Alignés | L | — |
| `worker_list` | `NodeParams` | Alignés | L | — |
| `event_append` | `EventAppendParams` | Alignés | L | — |
| `event_list` | `EventListParams` | Alignés | L | — |

| Fonction `fn::event_*` | DTO Rust | Champs conformes | Absents côté Rust | Supplémentaires |
|---|---|---|---|---|
| `publish` | `PublishParams` | Alignés ; UUID et référence natifs | L | — |
| `fanout` | `FanoutParams` | Alignés | L | — |
| `recover_pending_fanouts` | `RecoverFanoutParams` | Alignés | L | — |
| `subscription_register` | `SubscriptionRegisterParams` | Alignés | L | — |
| `outbox_get` | `OutboxGetParams` | Alignés | L | — |
| `delivery_get` | `DeliveryGetParams` | Alignés | L | — |
| `dead_letter_list` | `DeadLetterListParams` | Alignés | L | — |
| `dead_letter_replay` | `DeadLetterReplayParams` | Alignés | L | — |
| `purge_garbage` | `PurgeGarbageParams` | Alignés | L | — |
| `lease_acquire` | `LeaseAcquireParams` | Alignés | L | — |
| `lease_renew` | `LeaseRenewParams` | Alignés | L | — |
| `lease_release` | `LeaseReleaseParams` | Alignés | L | — |
| `delivery_assign_seq` | `DeliveryAssignSeqParams` | Alignés | L | — |
| `flush_batch` | `FlushBatchParams` | Alignés | L | — |
| `dead_letter_transfer` | `DeadLetterTransferParams` | Alignés | L | — |
| `progress_get` | `ProgressGetParams` | Alignés | L | — |
| `delivery_fetch_pending` | `DeliveryFetchPendingParams` | Alignés | L | — |
| `delivery_failure` | `DeliveryFailureParams` | Alignés | L | — |

| Fonction `fn::ingestion_*` | DTO Rust | Champs conformes | Absents côté Rust | Supplémentaires |
|---|---|---|---|---|
| `batch_create` | `NewBatch` | Alignés | L | — |
| `batch_get` | `IdParams` | `id` | — | — |
| `batch_checkpoint` | `BatchCheckpointParams` | Alignés | L | — |
| `batch_transition` | `BatchTransitionParams` | Alignés | L | — |
| `raw_records_save` | `RawRecordsSaveParams` | `batch_id`, `records` | L | — |
| `staged_save` | `StagedSaveParams` | `batch_id`, `rules_version`, `items` | L | — |
| `staged_list` | `StagedListFilter` | Alignés | L | — |
| `staged_requalify` | `StagedRequalifyParams` | Alignés | — | — |
| `quarantine_log` | `QuarantineLogParams` | Alignés | L | — |
| `quarantine_list` | `QuarantineListFilter` | Alignés | L | — |
| `quarantine_resolve` | `QuarantineResolveParams` | Alignés | — | — |
| `manifest_save` | `ManifestDraft` | Alignés | L | — |
| `manifest_approve` | `ManifestApproveParams` | Alignés | L | — |
| `manifest_record_exec` | `ManifestRecordExecParams` | Alignés | L | — |
| `manifest_execution_item_update` | `ManifestExecutionItemParams` | Alignés | L | — |
| `manifest_list` | `ManifestListFilter` | Alignés | L | — |
| `manifest_get_detail` | `ManifestRefParams` | `manifest_ref` | L | — |
| `resolve_units` | `ResolveUnitsParams` | `raw_units` | L | — |
| `resolve_manufacturers` | `ResolveManufacturersParams` | `raw_names` | L | — |
| `rule_family_add` | `FamilyRuleAddParams` | Alignés | L | — |
| `rule_spec_add` | `SpecAddParams` | Alignés | L | — |
| `rule_substitution_add` | `SubstitutionRuleAddParams` | Alignés ; `valid_until` natif `Datetime` | L | — |
| `dashboard_metrics` | `DashboardMetricsParams` | `batch_id` | L | — |

`ingestion_rules_load` et `ingestion_session_identity` n'ont pas de DTO d'entrée
Rust dédié identifié dans ce contrôle.

| Fonction appelée du catalogue | DTO Rust de l'ingestion | Champs conformes | Champs acceptés par SurrealQL non exposés | Supplémentaires |
|---|---|---|---|---|
| `catalogue_item_create` | `CatalogueItemCreateParams` | Champs transmis alignés ; alias `type_item` → `type` | Options : `has_variants`, `categories`, `statut_commercial`, `documents`, `is_custom`, `code_interne_client`, `libelle_personnalise`, `tenant_id`, `language` | — |
| `catalogue_item_update` | `CatalogueItemUpdateParams` | Champs transmis alignés | Options : `code`, `type`, `nature_reference`, `enabled`, `statut_commercial`, `documents`, `code_interne_client`, `libelle_personnalise`, `master_id`, `is_custom`, `tenant_id`, `language` | — |
| `catalogue_item_get` | `CatalogueItemGetParams` | `code` | `id`, `language` | — |

Cette vérification ne certifie pas toutes les combinaisons de valeurs imbriquées,
de `NONE`/`NULL` et de permissions. Les tests exécutés apportent une preuve
complémentaire sur les cas qu'ils exercent.

## 5. Tests exécutés et limites de preuve

### Compilation et exécution

**Compilation des tests : réussie**, code retour `0` :

```bash
cargo test --workspace --locked --offline --no-run
```

Les exécutables fraîchement produits pour les six crates Rust ont ensuite été
lancés avec `--test-threads=2`.

| Crate | Réussis | Échecs liés à l'environnement | Ignorés |
|---|---:|---:|---:|
| `lyxal_crypto` | 67 | 1 | 2 |
| `lyxal_error` | 15 | 5 | 0 |
| `lyxal_surreal` | 20 | 1 | 1 |
| `lyxal_event` | 89 | 0 | 0 |
| `lyxal_runtime` | 208 | 0 | 0 |
| `lyxal_pipeline_ingestion` | 65 | 1 | 0 |
| **Total** | **464** | **8** | **3** |

Les huit échecs surviennent sur l'ouverture de sockets :
`PermissionDenied / Operation not permitted`. Ils ne démontrent pas une régression
du produit, mais les scénarios concernés restent non validés ici.

### Exécutables et résultats détaillés de l'audit initial

Chaque chemin ci-dessous a été exécuté depuis la racine avec l'argument
`--test-threads=2`. Les suffixes sont ceux de la compilation réalisée lors de cet
audit ; ils peuvent changer après une nouvelle compilation.

| Exécutable dans `target/debug/deps/` | Réussis | Échecs | Ignorés | Code retour |
|---|---:|---:|---:|---:|
| `lyxal_crypto-f1b02d8a3a58d42f` | 16 | 0 | 1 | 0 |
| `it-e43984d56495ca6a` (crypto) | 51 | 1 | 1 | 101 |
| `lyxal_error-ee43fa64aea30969` | 3 | 0 | 0 | 0 |
| `it-4749e9685061140a` (error) | 12 | 5 | 0 | 101 |
| `lyxal_surreal-dc1187f8c2210cc9` | 12 | 1 | 0 | 101 |
| `it-68cd33a9b0b98aa5` (surreal) | 8 | 0 | 1 | 0 |
| `lyxal_event-71ba0ee9838fc6eb` | 50 | 0 | 0 | 0 |
| `it-8e88ad58d989bf2c` (event) | 39 | 0 | 0 | 0 |
| `lyxal_runtime-7b9dcad3d60d08a7` | 5 | 0 | 0 | 0 |
| `it-c59285e35d15e46d` (runtime) | 203 | 0 | 0 | 0 |
| `lyxal_pipeline_ingestion-3182e28e7a04d4b8` | 24 | 0 | 0 | 0 |
| `it-ab60767b0c4a1259` (ingestion) | 41 | 1 | 0 | 101 |

Les tests bloqués par l'environnement sont :

- `file_v2::special_files_parent_links_and_permission_variants_are_rejected` :
  `UnixListener::bind`, `crates/lyxal_crypto/tests/it/file_v2.rs:221`.
- `surreal_integration_tests::test_surreal_bootstrap_idempotence`.
- `surreal_integration_tests::test_surreal_error_definition_lifecycle`.
- `surreal_integration_tests::test_surreal_error_mapping_and_external_resolution`.
- `surreal_integration_tests::test_surreal_error_occurrence_logging_and_purging`.
- `surreal_integration_tests::test_surreal_result_ok_and_error_result`.
  Ces cinq tests échouent sur la réservation d'un port libre dans
  `crates/lyxal_error/tests/it/surreal_integration_tests.rs:38`.
- `client::tests::test_create_surreal_client_times_out` : réservation de port,
  `crates/lyxal_surreal/src/client.rs:251`.
- `integration_staging_live_server::test_staging_live_connection_and_reconnection` :
  connexion TCP à `127.0.0.1:8001`,
  `crates/lyxal_pipeline_ingestion/tests/it/integration_staging_live_server.rs:67`.

### Autres vérifications

| Contrôle | Résultat |
|---|---|
| `cargo fmt --all -- --check` | Réussi, code `0` |
| `python3 -B crates/lyxal_crypto/tools/check_fixtures.py` | Réussi : contrôle NIST et trois vecteurs indépendants |
| Reproductions sur les bibliothèques compilées | CSV, JSON, XML et sortie par lien symbolique confirmés |
| Analyse des tests SurrealQL métier | 439 blocs identifiés, sans problème de parsing du banc ; chaque fonction publique des trois modules est appelée par un test |
| Auto-test du banc Core | Bloqué à l'ouverture d'une socket |
| État Git à la fin de l'analyse initiale | Propre ; `git diff --exit-code` retourne `0` |

L'analyse statique des fichiers de tests métier identifie :

| Module | Fichiers | Blocs de test | Problèmes de parsing du banc | Fonctions publiques non appelées |
|---|---:|---:|---:|---:|
| `lyxal_base` | 7 | 99 | 0 | 0 |
| `lyxal_catalogue` | 7 | 189 | 0 | 0 |
| `lyxal_pipeline_ingestion` | 7 | 151 | 0 | 0 |

Ce contrôle de présence et de parsing des tests ne signifie pas que les 439 blocs
SurrealQL ont été exécutés sur un serveur pendant l'audit.

### Reproductions ciblées

Une sonde temporaire liée aux bibliothèques compilées du dépôt a reproduit les
quatre comportements suivants. Sa compilation et son exécution ont retourné `0` :

```text
CSV multiline: 2 records for 1 logical row
JSON invalid item: success with 2 records for 3 entries
XML entity: A &amp; B
Resource symlink escapes module root: true
```

Les données étaient synthétiques. Le test de lien symbolique utilisait un fichier
de test hors du sous-dossier du module, dans un répertoire temporaire, sans lecture
de secret. Les fichiers temporaires ont été supprimés. Aucun test ou correctif
n'a été ajouté aux sources lors de ces reproductions.

### Points non vérifiés faute de preuves

**SurrealDB 3.3.4 n'est pas certifié par cet audit.** Les tests embarqués ont
utilisé le moteur SDK **3.3.5** résolu par le lockfile. Le binaire `surreal` de
référence n'était pas disponible dans le `PATH`, et les tests réseau étaient bloqués.

Le banc complet [scripts/ci/ci_local.sh](../scripts/ci/ci_local.sh) n'a donc pas été
exécuté intégralement. La compatibilité serveur 3.3.4, la CI complète, les
performances représentatives de production et la reprise après arrêt brutal
restent à valider.

Les scénarios A01, A02, A04, A06, A07, A08 et A09 sont étayés par l'analyse du code ;
leurs scénarios complets d'exploitation ou d'incident n'ont pas tous été reproduits
en conditions serveur pendant cet audit. A02 dépend explicitement d'une base
partagée entre locataires. A03 et les trois cas d'A05 ont été reproduits.

## 6. Éléments conformes et appréciation par module

| Module | Appréciation CTO |
|---|---|
| **Core** | Catalogue conséquent, responsabilités documentées, un fichier de test par fonction. Aucun appel de fonction non défini trouvé dans le contrôle global. Son volume exige de maintenir des preuves automatisées solides. |
| **Crypto** | Bonne discipline : secrets opaques, diagnostics masqués, mémoire effacée, limites explicites, AAD contextualisé, vecteurs indépendants et tests de rotation. C'est l'une des parties les mieux encadrées. |
| **Error** | Contrat de résultat cohérent et DTO alignés. La vérification des écritures refusées doit être renforcée. |
| **Surreal** | Transport centralisé, noms de fonctions contrôlés, paramètres liés et contrat de réponse vérifié. La connexion distante reste partiellement non validée dans cet environnement. |
| **Event** | Mécanismes de fencing, curseurs et lettres mortes présents ; **89 tests réussis**. La purge doit être confrontée aux invariants de progression. |
| **Runtime** | Installation, baux, supervision et réconciliation disposent d'une couverture importante : **208 tests réussis**. Le confinement des ressources présente un défaut confirmé. |
| **Base** | Frontière claire, référentiel réutilisable, ressources synchronisées et tests métier présents. Aucune anomalie majeure établie dans les contrôles effectués. |
| **Catalogue** | Règles métier et gardes substantielles. La portée des personnalisations des articles maîtres doit être corrigée ou encadrée par une isolation physique démontrée. |
| **Ingestion** | Parcours fonctionnel riche, mais c'est le module qui concentre les risques : sceau incomplet, parseurs permissifs, file volatile, concurrence et fenêtres de perte d'événements. |

Deux résultats transversaux sont positifs : **aucune ressource de production
manquante ou oubliée dans les manifestes**, et **aucun cycle détecté dans les
graphes contrôlés**.

La notion de « preuve commerciale authentifiée » mérite aussi une précision
produit : [is_eligible_for_production](../crates/lyxal_pipeline_ingestion/src/proof.rs#L100)
contrôle actuellement une structure et des motifs textuels de données pilotes.
La vérification positive de provenance documentaire reste une évolution prévue.
Les garanties affichées aux utilisateurs doivent refléter cette limite.

## 7. Plan correctif proposé

Ce plan exprime des recommandations de l'auditeur. Il n'emporte aucune autorisation
d'implémentation et aucun correctif n'a été effectué dans le cadre de cette remise.

| Priorité | Chantier | Condition de clôture |
|---|---|---|
| **1 — Intégrité** | Scellement complet et immutabilité après approbation | Toute modification d'une donnée publiée invalide l'approbation ou rend la publication impossible. |
| **2 — Isolation** | Personnalisations du catalogue | Alpha peut personnaliser ou désactiver un article sans modifier ce que Beta lit. |
| **3 — Événements** | Finalisation transactionnelle via l'outbox | Un arrêt entre chaque étape ne perd aucun événement final et ne produit aucun effet métier incorrect au rejeu. |
| **4 — Ingestion durable** | Source persistée, reprise et exclusion concurrente | Un lot reprend après arrêt brutal sans nouvelle soumission du fichier ; deux traitements du même lot sont exclus. |
| **5 — Fidélité des données** | Parseurs CSV/XML et rejets JSON explicites | Les fixtures multiligne, entités, entrées invalides et fichiers malformés produisent des données exactes ou des rejets traçables. |
| **6 — Runtime et événements** | Confinement des ressources et purge | Aucun lien ne sort du périmètre autorisé ; aucune purge ne crée de trou avant le curseur durable. |
| **7 — Contrats d'écriture** | Refus de permissions explicites | Une écriture refusée ne renvoie jamais un succès trompeur. |
| **8 — Validation commune** | Clippy, documentation et serveur 3.3.4 | Ingestion réintégrée aux contrôles ; CI complète verte et scénarios d'incident démontrés sur la version serveur cible. |

**Le prochain jalon devrait être une recette de fiabilité du parcours complet :
source → ingestion → approbation → catalogue → événement final, avec interruptions
et deux locataires.** C'est cette preuve qui permettra de décider d'une mise en
production.

---

**Auteur et auditeur : ChatGPT / Codex (OpenAI).**

**Date : 7 novembre 2026 (UTC).**

Rapport externe établi à la demande de l'utilisateur. Le jugement CTO exprimé est
celui de l'assistant dans le cadre de cette mission ; il ne constitue pas une
certification par un cabinet ou un organisme tiers.
