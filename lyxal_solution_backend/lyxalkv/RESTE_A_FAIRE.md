# LyxalKV - Reste à faire (TODO)

Ce fichier suit les tâches restantes pour assurer la stabilité de `lyxalkv` sur Windows et la robustesse globale du moteur LSM.

## Stabilité Windows (Priorité Haute)

- [ ] **Résoudre les erreurs "Permission Denied" (Access Denied) dans les tests `levels`**
  - Les tests `test_last_sequence_persistence_across_manifest_reload`, `test_lsn_with_multiple_l0_tables`, et `test_manifest_v1_with_log_number_and_last_sequence` échouent par intermittence ou systématiquement sur Windows.
  - Cause suspecte : Concurrence d'accès aux fichiers SST ou Manifeste lors de la création/chargement.

- [ ] **Valider la correction du LockFile**
  - Vérifier que l'erreur `ERROR_LOCK_VIOLATION` (code 33) est correctement traitée comme une tentative d'accès concurrent légitime.
  - Assurer que les verrous OS sont libérés assez rapidement pour que les tests suivants puissent s'exécuter.

- [ ] **Optimiser les retries I/O dans `vfs.rs`**
  - Ajuster les délais et le nombre de tentatives pour `PermissionDenied` si nécessaire.

## Robustesse & Performance

- [ ] **Audit de la gestion des descripteurs de fichiers**
  - S'assurer que tous les fichiers (SST, WAL, Vlog) sont fermés proprement, surtout dans les chemins d'erreur.

- [ ] **Vérifier la récupération après crash (WAL Recovery)**
  - Assurer la stabilité du test `test_recovery_with_manually_created_wal_segments`.

- [ ] **Nettoyage des fichiers temporaires**
  - Améliorer le nettoyage automatique des répertoires de test pour éviter l'accumulation de fichiers `Access Denied` résiduels.

## Documentation

- [ ] Finaliser le `walkthrough.md` détaillant toutes les corrections apportées pour la compatibilité Windows.
