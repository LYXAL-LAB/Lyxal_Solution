# Module Email (`engine/src/email/`) — Lyxal Booking

## Statut
**VALIDÉ & ARCHITECTURALEMENT STABLE**

---

## 📌 Dette Technique Non-Bloquante & Roadmap

### Ticket : `EMAIL-DB-001`
- **Description** : Migrer le chargement SMTP brut dans `config.rs` (`load_smtp_config` / `load_smtp_status`) vers la fonction SurrealQL typée `fn::booking_get_smtp_config` via `store.call_fn(...)`.
- **Statut** : Planifié pour lot d'évolution ultérieur (`EMAIL-DB-001`).
- **Remarque** : N'impacte pas la modularisation, la sécurité ni la compatibilité du module `email/`, qui sont officiellement validées.
