# Plan d'implémentation — audit externe, lot 5 (A07)

Cinquième lot de correction de l'audit externe
[`audit_externe/2026-11-07_audit_crates_cto_chatgpt_codex.md`](audit_externe/2026-11-07_audit_crates_cto_chatgpt_codex.md).
Constat vérifié sur `main` (après #95) en lecture seule. Changement dans
`lyxal_pipeline_ingestion` seul. Plan placé à la racine comme les lots précédents, supprimé
une fois exécuté. La reprise automatique après redémarrage (A06) reste un lot ultérieur ; ce
lot en pose la base (une réservation expirée libère le lot).

**En attente de validation du CTO (Q1, Q2).**

## 1. Constat

| ID | Constat | Preuve |
| :- | :--- | :--- |
| A07-a | Le verrou du worker laisse passer un **second traitement du même lot** : il ne refuse qu'un lot *différent* ; deux appels simultanés pour le même `batch_id` s'exécutent ensemble, et le premier qui termine libère le verrou pendant que l'autre tourne encore. | `src/worker/ingestion_worker.rs:121-138` |
| A07-b | Ce verrou est une variable **en mémoire du processus** : deux instances du serveur (ou deux workers) traitent le même lot sans le savoir. | `active_batch_lock: Arc<Mutex<Option<String>>>` |
| A07-c | Conséquences possibles : checkpoints concurrents qui reculent le curseur, transitions d'état croisées (`STAGED` puis `FAILED`), anomalies de quarantaine en double, lignes refusées par les index uniques au milieu d'un bloc. | index `idx_staged_batch_line`, `idx_staged_business_id` |

## 2. Décisions demandées

| # | Question | Options | Recommandation |
| :- | :--- | :--- | :--- |
| Q1 | Où porter l'exclusion | **A.** Une **réservation du lot** dans l'ingestion : champs du lot (`claim_owner`, `claim_generation`, `claim_until`), prise par une écriture conditionnelle atomique ; **chaque écriture du traitement** (lignes brutes, articles, anomalies, point de reprise, transitions) vérifie dans la même requête que le worker détient toujours la réservation (cloisonnement), sinon `INGESTION_BATCH_CLAIM_LOST`. **B.** Réutiliser les baux de `lyxal_runtime` (élargis à un type « travail ») : un seul mécanisme de bail, mais les fonctions de l'ingestion ne peuvent pas le vérifier dans leurs écritures sans lire une table interne du runtime (§1) ; l'exclusion serait vérifiée au début seulement. | **A** : l'exclusion vit avec la donnée qu'elle protège et chaque écriture la vérifie atomiquement, comme le bail du moteur d'événements (§5.6.4) ; un worker qui a perdu la réservation (pause, réseau) ne peut plus rien écrire. |
| Q2 | Durée et renouvellement | **A.** Réservation de 60 s, renouvelée à chaque point de reprise (fin de bloc) ; expirée, elle peut être reprise par un autre worker, avec une génération supérieure qui écarte l'ancien ; libérée à la fin (succès, échec, interruption). **B.** Réservation sans expiration, libérée seulement explicitement. | **A** : un worker arrêté brutalement ne bloque pas le lot indéfiniment ; c'est la base de la reprise automatique (A06). |

## 3. Contrat cible (si Q1-A, Q2-A)

### SurrealQL

* `ingestion_batch` : `claim_owner` (`option<string>`), `claim_generation` (`int`, défaut 0,
  monotone), `claim_until` (`option<datetime>`, heure de la base) ; la garde du lot refuse toute
  baisse de génération.
* **Nouvelle** `fn::ingestion_batch_claim($params)` : `id`, `owner` (identifiant du worker),
  `ttl_seconds` (défaut 60, 5 à 600) ; prend la réservation si elle est libre, expirée ou déjà
  à ce worker (renouvellement) ; renvoie `{ generation, until }` ; sinon
  `INGESTION_BATCH_ALREADY_CLAIMED` (`details.owner`, `details.until`).
* **Nouvelle** `fn::ingestion_batch_release($params)` : `id`, `owner`, `generation` ; libère si
  la réservation est toujours la sienne (sinon `INGESTION_BATCH_CLAIM_LOST`).
* Cloisonnement : `fn::ingestion_raw_records_save`, `fn::ingestion_staged_save`,
  `fn::ingestion_quarantine_log`, `fn::ingestion_batch_checkpoint` et
  `fn::ingestion_batch_transition` reçoivent `claim: { owner, generation }` (**rupture**,
  appelants du dépôt mis à jour) ; chacune vérifie, dans sa requête, que le lot est réservé par
  ce worker, à cette génération et non expiré, sinon `INGESTION_BATCH_CLAIM_LOST` sans rien
  écrire. Le point de reprise renouvelle la réservation.
* Les écritures hors traitement (steward, quarantaine résolue, requalification) ne changent
  pas : elles ne portent pas sur un lot en cours de traitement.
* Nouveaux codes (master data, fr/en) : `INGESTION_BATCH_ALREADY_CLAIMED` (409),
  `INGESTION_BATCH_CLAIM_LOST` (409).

### Rust

* `IngestionWorker` : identifiant d'instance (UUID v7) ; `process_batch` prend la réservation,
  transmet `{ owner, generation }` à chaque écriture, la libère à la fin quelle que soit
  l'issue ; lot déjà réservé → `IngestionError` dédiée, le lot n'est pas marqué `FAILED`.
* Suppression du verrou en mémoire `active_batch_lock` (remplacé, zéro dette).
* `IngestionStore` : `claim_batch`, `release_batch` ; paramètres `claim` sur les méthodes
  d'écriture concernées.

## 4. Tests

| Cas | Preuve attendue |
| :- | :--- |
| Exclusion | Banc : un second worker ne prend pas un lot réservé (`INGESTION_BATCH_ALREADY_CLAIMED`) ; le même worker renouvelle. |
| Cloisonnement | Banc : une écriture avec une génération périmée ou un autre propriétaire → `INGESTION_BATCH_CLAIM_LOST`, rien n'est écrit (point de reprise, articles, transition). |
| Expiration | Banc : réservation expirée reprise par un autre worker, génération supérieure ; l'ancien ne peut plus écrire. |
| Concurrence réelle | Test Rust : deux workers lancés en même temps sur le même lot → un seul traite, l'autre est refusé ; le lot finit `STAGED` une seule fois (un seul `ingestion.batch.staged`). |
| Libération | Après succès, échec ou interruption, la réservation est libérée ; un nouveau traitement peut la prendre. |

Contrôle complet : `scripts/ci/ci_local.sh`.

## 5. Checklist (§13)

* SurrealQL : `$params: object` ; entrées par le moteur de `lyxal_core` ; heure de la base
  pour les échéances ; écritures vérifiées ; codes préfixés `INGESTION_`.
* Rust : `LyxalWorker` inchangé ; aucun `tokio::spawn` ; verrou en mémoire supprimé.
* Zéro dette : rupture coordonnée, aucun ancien chemin conservé ; plan supprimé après exécution.

## 6. Lots suivants (rappel)

6 : création de `lyxal_parsing`, puis A05 (adaptateurs) · 7 : A06 (source persistée et reprise
automatique, dépend de `lyxal_storage`).
