# Plan d'implémentation — audit externe, lot 3 (A01)

Troisième lot de correction de l'audit externe
[`audit_externe/2026-11-07_audit_crates_cto_chatgpt_codex.md`](audit_externe/2026-11-07_audit_crates_cto_chatgpt_codex.md).
Constats vérifiés sur `main` (après #91) en lecture seule. Changement dans
`lyxal_pipeline_ingestion` ; appelants à mettre à jour dans les tests de `lyxal-server`.
Plan placé à la racine comme les lots précédents, supprimé une fois exécuté.

**En attente de validation du CTO (Q1, Q2).**

## 1. Constats

| ID | Constat | Preuve |
| :- | :--- | :--- |
| A01-a | Le sceau d'un manifeste n'est **pas calculé par le serveur** : `fn::ingestion_manifest_save` enregistre le `seal_hash` fourni par l'appelant (64 caractères, sans autre contrôle). | `functions/manifest/ingestion_manifest_save.surql:14,34` |
| A01-b | À la publication, le sceau est recalculé à partir des **empreintes stockées** des articles, jamais à partir de leur contenu. | `controlled_publisher.rs:118` |
| A01-c | L'empreinte d'un article ne couvre pas tout ce qui est publié : description technique et conditionnement (quantité, poids, dimensions, unité de vente) sont envoyés au catalogue sans être couverts. | `normalization/mod.rs:248-259` ; `publisher/catalogue.rs` (`create_params`) |
| A01-d | Le verrou annoncé (« `is_sealed` interdit toute modification des articles du manifeste ») n'existe pas : un article reste modifiable après scellement et après approbation, par l'agent de qualification, le steward ou `fn::ingestion_quarantine_resolve` (GTIN, unité), sans recalcul. | `schema/05_ingestion_publication_manifest.surql:60` ; `schema/03_ingestion_staged_item.surql:19` ; `ingestion_quarantine_resolve.surql:71-79` |
| A01-e | Code mort : `FingerprintEngine::compute_canonical_fingerprint` n'est appelée que par ses tests et décrit une empreinte qui n'est pas celle utilisée. | `src/fingerprint.rs:21` |

## 2. Décisions demandées

| # | Question | Options | Recommandation |
| :- | :--- | :--- | :--- |
| Q1 | Ce que scelle et publie un manifeste | **A.** Au scellement, le serveur fige dans le manifeste le **contenu exact à publier** (pour chaque article `VERIFIED` : référence, action, charge utile du catalogue, preuve commerciale) et calcule le sceau BLAKE3 de ce contenu. La publication vérifie le sceau côté serveur puis publie **depuis ce contenu figé**, plus depuis le staging. **B.** Garder la publication depuis le staging, étendre l'empreinte de chaque article à tout le contenu publié et la recalculer à chaque publication. | **A** : ce qui est approuvé est exactement ce qui est publié, vérifiable à tout moment ; le sceau ne dépend plus d'aucune empreinte intermédiaire ni d'un calcul côté client. B laisse le contenu publié dépendre de l'état du staging au moment de la publication. |
| Q2 | Modification d'un article dont le lot a un manifeste scellé, approuvé ou en cours d'exécution | **A.** Refusée par la base (`INGESTION_STAGED_ITEM_SEALED`) ; pour corriger, le steward remet le manifeste en brouillon (`SEALED → DRAFT`, ou `FAILED → DRAFT` après un échec), corrige, puis rescelle et réapprouve. **B.** Acceptée, mais elle fait retomber automatiquement le manifeste en brouillon et annule l'approbation. | **A** : aucun changement d'état implicite ; la correction après approbation devient un acte explicite et tracé, comme l'exige une approbation humaine. |

## 3. Contrat cible (si Q1-A, Q2-A)

### SurrealQL

* `ingestion_publication_manifest` : nouveau champ `contenu` (tableau ordonné par référence
  d'article : `item_ref`, `publication_action`, `catalogue` — charge utile de
  `fn::catalogue_item_create` —, `commercial_proof`). La garde `evt_manifest_guard` refuse toute
  modification de `contenu` ou de `seal_hash` hors passage à `SEALED`.
* Nouvelle fonction interne `fn::ingestion_manifest_content($batch)` : construit `contenu` depuis
  les articles `VERIFIED` du lot ; elle porte la correspondance staging → catalogue, aujourd'hui
  en Rust (`create_params`) — une seule correspondance, côté données (§10).
* `fn::ingestion_manifest_save` : **plus de paramètre `seal_hash`** (rupture) ; au statut
  `SEALED`, le serveur fige `contenu` et calcule `seal_hash = crypto::blake3(<string> contenu)`.
  Le rescellement d'un manifeste remis en brouillon passe par la même fonction.
* `fn::ingestion_manifest_get_detail` renvoie aussi `contenu` et `seal_valid` (sceau recalculé
  sur `contenu` par le serveur).
* Verrou (Q2-A) : `DEFINE EVENT` de garde sur `ingestion_staged_item` (`UPDATE`) : si le lot a un
  manifeste `SEALED`, `APPROVED` ou `EXECUTING`, `THROW "INGESTION_STAGED_ITEM_SEALED"`.
  `fn::ingestion_quarantine_resolve` et `fn::ingestion_staged_requalify` renvoient ce code au
  lieu d'écrire.
* Nouveau code `INGESTION_STAGED_ITEM_SEALED` (master data, fr/en, 409).

### Rust

* `ControlledPublisher` : lit `contenu` et `seal_valid` ; `seal_valid = false` →
  `IngestionError::FingerprintTampered` sans aucune écriture ; publie chaque entrée de `contenu`
  (refus préalables inchangés : preuve non éligible, retrait non pris en charge).
* `CatalogueSyncClient::publish` reçoit la charge utile figée ; `create_params` est supprimé.
* `ManifestDraft` perd `seal_hash` ; `FingerprintEngine::compute_manifest_seal` et
  `compute_canonical_fingerprint` sont supprimés (code mort ensuite) ; l'empreinte canonique
  d'article reste calculée à la normalisation pour la détection des doublons.
* Rupture coordonnée (§0.3) : tests de l'ingestion et `apps/lyxal-server/tests/it/startup.rs`
  mis à jour.

## 4. Tests

| Cas | Preuve attendue |
| :- | :--- |
| Sceau serveur | Banc : un manifeste scellé porte `contenu` (articles `VERIFIED` seulement) et `seal_hash = crypto::blake3(<string> contenu)` ; un `seal_hash` fourni par l'appelant est refusé (`INGESTION_INVALID_PARAMETERS`, clé inconnue). |
| Couverture | Le contenu figé contient description et conditionnement ; il est identique à ce que reçoit le catalogue (test Rust de publication : article du catalogue comparé au contenu figé). |
| Verrou | Banc : après scellement, l'agent de qualification, le steward et `fn::ingestion_quarantine_resolve` reçoivent `INGESTION_STAGED_ITEM_SEALED` et l'article est inchangé ; après remise en brouillon, la correction passe et le rescellement change le sceau. |
| Immutabilité du manifeste | Une modification directe de `contenu` ou `seal_hash` d'un manifeste scellé est refusée par la garde. |
| Publication | Un `contenu` altéré en base (session root, garde contournée dans le test) → `seal_valid = false`, publication refusée sans écriture au catalogue ; les tests de publication existants restent verts. |

Contrôle complet : `scripts/ci/ci_local.sh`.

## 5. Checklist (§13)

* Core : `crypto::blake3` natif (déjà utilisé par les seeds et tests du module) ; entrées par
  `fn::validation_object_execute` ; aucune fonction Core nouvelle.
* SurrealQL : `$params: object` ; écritures vérifiées ; garde par `DEFINE EVENT` ; nouveau code
  préfixé `INGESTION_`, master data rejouable.
* Rust : correspondance staging → catalogue à un seul endroit (SurrealQL) ; code mort supprimé.
* Zéro dette : `seal_hash` fourni par le client supprimé sans alias ; plan supprimé après exécution.

## 6. Lots suivants (rappel)

4 : A02 (personnalisations par locataire) · 5 : A05 (adaptateurs sur `lyxal_parsing`) ·
6 : A07 puis A06.
