# Audit & Validation Cluster Distribué (Bloc 7.3)

Ce document analyse le comportement attendu du scheduler Lyxal (intégré à SurrealDB) sur un backend de stockage distribué transactionnel (TiKV, FoundationDB, etc.), en se concentrant sur les mécanismes de Haute Disponibilité (HA) implémentés via les leases.

## 1. Audit Transactionnel (Acquisition de Lease)

Le cœur de la HA repose sur l'acquisition atomique d'un lease par job.

### Mécanisme Actuel
L'acquisition se fait via une requête SurrealQL unique exécutée par le `SchedulerService` :

```sql
UPDATE scheduler::task SET
    lease_owner = $node_id,
    lease_until = time::now() + duration::seconds($ttl)
WHERE id = $id
  AND enabled = true
  AND next_run <= time::now()
  AND (lease_owner IS NONE OR lease_until < time::now());
```

### Analyse sur Backend Distribué (TiKV)

1.  **Atomicité (ACID)** :
    *   SurrealDB (via son layer KV transactionnel) garantit que l'instruction `UPDATE` est atomique.
    *   Sur TiKV, cela se traduit par une transaction distribuée (2PC ou optimisé).
    *   **Garantie** : Si deux nœuds tentent cet `UPDATE` simultanément sur le même `id`, un seul réussira (le premier commité), l'autre échouera (condition `WHERE` non remplie ou conflit transactionnel géré par retry/fail).
    *   **Risque** : Latence réseau élevée peut augmenter le temps de transaction, mais l'intégrité est préservée (pas de double lease).

2.  **Isolation** :
    *   Le niveau d'isolation par défaut de SurrealDB/TiKV est généralement Snapshot Isolation ou Serializable.
    *   Cela suffit pour garantir que la lecture de `lease_owner` dans le `WHERE` est cohérente avec l'état commité.

3.  **Conclusion** : Le mécanisme de lease via `UPDATE` conditionnel est **sûr** sur un backend distribué transactionnel. Aucune double exécution n'est possible tant que le backend garantit l'atomicité de l'écriture row-level.

## 2. Audit des Scans & Performances

Le scheduler effectue un scan périodique pour trouver les jobs éligibles.

### Requête de Scan
```sql
SELECT * FROM scheduler::task
WHERE enabled = true
  AND next_run <= time::now()
  AND (lease_owner IS NONE OR lease_until < time::now());
```

### Analyse Performance Distribuée

1.  **Index** :
    *   Des index existent sur `enabled`, `next_run`, et `instance_id`.
    *   SurrealDB devrait utiliser ces index pour éviter un Full Table Scan.
    *   **Point critique** : Si l'optimiseur n'utilise pas l'index composite ou si les index sont dispersés sur plusieurs régions TiKV, la latence du `SELECT` peut augmenter.

2.  **Volumétrie** :
    *   La complexité est O(N jobs éligibles), pas O(N total jobs) si les index sont utilisés.
    *   Si beaucoup de jobs deviennent éligibles en même temps (ex: cron `* * * * *` sur 10k jobs), le scan peut rapporter beaucoup de lignes.
    *   **Garde-fou** : Le `SchedulerService` traite les jobs par lot. La pagination ou limite (LIMIT) pourrait être nécessaire si le volume explose, mais pour l'instant le flow est streaming.

3.  **Latence Réseau** :
    *   En cluster géodistribué, la latence entre le nœud compute (Scheduler) et le stockage (TiKV) s'ajoute à chaque tick.
    *   Cela ne crée pas d'incohérence, mais peut retarder le déclenchement effectif (`next_run` + latence). C'est acceptable pour un scheduler "best effort" (pas temps réel dur).

## 3. Concurrence Inter-Nœuds & Scénarios de Panne

### Scénario A : Concurrence Frontale
*   **Action** : Nœud A et Nœud B démarrent un tick au même moment. Ils voient le même job éligible.
*   **Résultat** :
    *   A envoie `UPDATE ... WHERE ...`
    *   B envoie `UPDATE ... WHERE ...`
    *   Le backend KV sérialise. Supposons A gagne.
    *   L'update de A modifie `lease_owner`.
    *   L'update de B échoue (condition `WHERE lease_owner IS NONE` fausse).
    *   A exécute, B passe au suivant.
*   **Validation** : **OK**. Design robuste.

### Scénario B : Crash du Lease Owner
*   **Action** : Nœud A acquiert le lease (TTL 60s), commence l'exécution, puis crashe brutalement (kill -9, panne courant).
*   **Résultat** :
    *   Le job reste en état "running" (`lease_owner = A`) dans la base.
    *   Le worker de A est mort, l'exécution s'arrête (ou est perdue).
    *   Pendant 60s, personne ne touche au job.
    *   À T+61s, Nœud B scanne. La condition `lease_until < time::now()` devient vraie.
    *   B acquiert le lease (écrase l'ancien owner A) et relance le job.
*   **Validation** : **OK**. Reprise automatique garantie après TTL. Risque : double exécution si A n'était pas vraiment mort (partition réseau "zombie"), mais c'est un compromis classique des leases à expiration. Le "hard timeout" local du worker A (30s) est < TTL (60s), minimisant ce risque.

### Scénario C : Mount Dynamique
*   **Action** : On ajoute une instance `ns:db` dans `system::scheduler_mount`.
*   **Résultat** :
    *   Tous les nœuds détectent l'ajout (via polling `update_dynamic_mounts`).
    *   Ils commencent tous à scanner cette instance.
    *   La compétition pour les leases commence naturellement.
*   **Validation** : **OK**. Pas de "master" pour l'instance, tout est symétrique.

## 4. Recommandations & Garde-fous

Suite à l'audit, le design est validé pour un cluster distribué. Quelques ajustements mineurs sont recommandés pour durcir la résilience :

1.  **Jitter sur le Tick** :
    *   Pour éviter que tous les nœuds ne scannent exactement en même temps (thundering herd sur le KV), ajouter un léger jitter aléatoire (0-500ms) avant chaque tick ou sleep.
    *   *Action* : Ajout minimal dans `SchedulerService`.

2.  **Marge de Sécurité TTL** :
    *   S'assurer que `LEASE_TTL` > `JOB_TIMEOUT` avec une marge confortable (ex: x2).
    *   Actuellement `DEFAULT_LEASE_TTL_SECS = 60` et `DEFAULT_TIMEOUT_SECS = 30`. C'est correct.

## 5. Conclusion

Le scheduler Lyxal respecte les principes transactionnels nécessaires pour fonctionner sur un backend distribué comme TiKV. L'utilisation de `UPDATE` conditionnel atomique pour les leases est la bonne approche. Aucune modification structurelle n'est requise.

**Statut : VALIDÉ POUR CLUSTER (avec jitter recommandé).**

