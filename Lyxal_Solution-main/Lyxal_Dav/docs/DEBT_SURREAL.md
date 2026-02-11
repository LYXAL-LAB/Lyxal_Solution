# Dette Technique — Backend SurrealDB (D7.5)

Statut : NON VALIDÉ (bloqué par chantier SurrealDB)

Ce qui est implémenté :
- SurrealBackend complet (D7.1 → D7.4)
- Mapping strict sur tables Surreal existantes
- Transactions BEGIN/COMMIT par opération
- ACL / Locks / Sync-token implémentés

Ce qui reste à valider :
1. Parité fonctionnelle SQLite ↔ SurrealDB
   - PUT / GET / DELETE
   - MOVE / COPY atomiques
   - LOCK / UNLOCK
   - Sync-collection
   - Scheduling iTIP

2. Tests à rejouer dès que possible :
   - cargo test -p lyxal-dav-core
   - cargo test -p lyxal-dav-server -- --storage surreal://
   - scripts/e2e_tests.sh --storage surreal://

Blocage actuel :
- Chantier SurrealDB en cours
- Impossible de sortir un build stable Surreal

Décision CTO :
- Cette dette est ACCEPTÉE
- Aucun contournement ou fallback ne sera ajouté
- Validation reportée en D7.5 bis

