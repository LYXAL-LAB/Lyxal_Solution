# 🚀 Spécifications & Feuille de Route Fonctionnelle — Module `lyxal_error`

Ce document consigne la vision fonctionnelle, les arbitrages d'événements (`DEFINE EVENT`), l'intégration événementielle avec `lyxal_event` et la feuille de route d'évolution du module `lyxal_error`.

---

## 1. 📌 Politique d'Événements SurrealDB (`DEFINE EVENT`)

### 1.1. Modèle de Données de Référence (`Master Data`)
- **`error_definition`** : ❌ **Aucun `DEFINE EVENT`**.
  - *Raison* : La création d'un code d'erreur, la mise à jour d'une traduction ou le changement d'une sévérité sont des données de référence stables qui ne doivent déclencher aucune action automatique.
- **`error_external_mapping`** : ❌ **Aucun `DEFINE EVENT`**.
  - *Raison* : Ce sont de simples règles de conversion entre systèmes tierces et codes canoniques Lyxal.

### 1.2. Journal Append-Only (`error_occurrence`)
- **`error_occurrence`** : ⏳ **`DEFINE EVENT` différé à la V2 (`lyxal_event`)**.
  - Lors de la création d'une occurrence d'erreur (`CREATE error_occurrence`), le système pourra publier un événement vers le bus d'événements global.

---

## 2. ⚡ Règle d'Or des Événements SurrealDB

> [!IMPORTANT]
> **Un `DEFINE EVENT` SurrealDB ne produit QUE des données.**
> Il ne doit **jamais** effectuer d'effets de bord directs (pas d'envoi d'e-mail, pas d'appel HTTP webhook, pas d'interaction direct Slack/Teams/Discord).

### Exemple d'Architecture Cible avec `lyxal_event` :
```text
error_occurrence (CREATE)
       │
       ▼
DEFINE EVENT error_occurrence_created
       │
       ▼ (Si sévérité = "critical")
CREATE event_outbox {
    module: "error",
    event: "error.critical",
    payload: { ... }
}
       │
       ▼
Moteur lyxal_notification / lyxal_event
       ├── E-mail d'alerte
       ├── Notification Slack / Teams / Discord
       └── PagerDuty / Webhook
```

---

## 3. 📈 Perspective V2 : Table `error_statistics`

Afin d'éviter des requêtes coûteuses du type `SELECT count() FROM error_occurrence` sur des millions de lignes de logs, une quatrième table d'agrégation sera ajoutée en V2.

### Modèle Cible : `error_statistics`
```surrealql
-- Table d'agrégation maintenue automatiquement par SurrealDB
DEFINE TABLE IF NOT EXISTS error_statistics TYPE NORMAL SCHEMAFULL;

-- Champs :
-- code        : record<error_definition> ou string (ex: BOOKING_USERNAME_EMAIL_INVALID)
-- count_total : int (compteur global)
-- first_seen  : datetime
-- last_seen   : datetime
-- count_today : int
-- count_week  : int
-- count_month : int
```

---

## 4. 📝 Recommandations & Arbitrages V1 Verrouillés

1. **V1 Neutre & Autonome** :
   - ✅ 0 `DEFINE EVENT` sur `error_definition`.
   - ✅ 0 `DEFINE EVENT` sur `error_external_mapping`.
   - ⏳ 0 `DEFINE EVENT` sur `error_occurrence` (en attente du module `lyxal_event`).

2. **Éviter le Code Mort** :
   - Aucun événement ne sera généré tant qu'un consommateur explicite (`lyxal_event`) n'est pas en place dans la solution.

3. **Focus V1** :
   - Concentrer `lyxal_error` sur ses trois piliers fondamentaux : **Définir**, **Résoudre** et **Journaliser** les erreurs au format universel `LyxalResult<T>`.

---

## 5. 🗺️ Feuille de Route Générale & Interface Graphique (UI)

Pour consulter la feuille de route complète en 3 phases (**V1 Moteur Fonctionnel**, **V2 Observabilité & Web Console UI**, **V3 Événementiel & IA**) ainsi que la méthodologie universelle Lyxal OS, référez-vous au document :

📄 **[ROADMAP.md](file:///C:/Users/HP/Desktop/Lyxal_Solution/lyxal_error/ROADMAP.md)**

