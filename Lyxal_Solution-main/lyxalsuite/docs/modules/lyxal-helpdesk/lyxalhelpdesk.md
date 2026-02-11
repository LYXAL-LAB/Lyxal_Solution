# 📘 Documentation du module `lyxalhelpdesk`

## 📌 Objectif du module

Le module `lyxalhelpdesk` permet de gérer de bout en bout un système de support client via des tickets, avec logique SLA, transitions de statuts, audit et extensions IA.

Ce module est conçu pour exploiter **pleinement les capacités de SurrealDB**, y compris :
- relations graphe typées (`RELATE`)
- triggers (`DEFINE EVENT`)
- requêtes graphe avancées
- suivi de transitions
- génération IA-friendly

---

## 📂 Structure du module

```
lyxalhelpdesk/
├──── gateway/
│       ├── index.ts
│       ├── routes/
│       │   ├── ticket.routes.ts         # CRUD + transitions des tickets
│       │   ├── sla.routes.ts            # Règles SLA (lecture, test, deadlines)
│       │   ├── status.routes.ts         # Statuts possibles et transitions
│       │   └── helpdesk.routes.ts       # Regroupe tous les endpoints métier
│       ├── controllers/
│       │   └── helpdeskController.ts    # Centralise logique de réponse, erreurs, déclencheurs
│       ├── services/
│       │   ├── ticketService.ts         # Logique métier : création, transitions, SLA
│       │   └── slaEngine.ts             # Calcul SLA, échéances, alertes
│       ├── validators/
│       │   └── helpdeskSchemas.ts       # Zod schemas : ticket, SLA, statut, réponse
│       ├── utils/
│       │   ├── computeSlaDeadline.ts    # Fonction de calcul de la deadline SLA
│       │   └── logAuditEvent.ts         # Audit automatique des actions helpdesk
│       └── middlewares/
│           ├── errorsHandler.ts
│           ├── rateLimit.ts
│           └── requireRole.ts 
├──── sdk/ 
│      ├── backend/
│      │      └── helpdeskClient.ts      # Fonctions backend pour créer, clôturer, prioriser ticket
│      ├── frontend/
│      │      └── helpdeskClient.ts      # Fonctions pour afficher liste, créer, suivre un ticket
│      └── types/
│            └── types.ts                # `Ticket`, `Sla`, `TicketStatus`, `AgentAction`
├──── model/ 
│        ├── helpdesk_index.surql
│        ├── helpdesk_structure.surql
│        ├── referenceHelpdeskData.surql
│        ├── helpdesk_triggers.surql
│        └── testHelpdeskFlow.surql
└───── docs/
        └── lyxalhelpdesk.md
```

---

## 📄 Tables principales

- `ticket`: entité principale avec sujet, description, priorités, SLA, statut, etc.
- `sla`: règles associées à chaque type de ticket avec jours/heures autorisés
- `ticket_status`: statuts (New, In Progress, etc.)
- `ticket_type`: type (Bug, Feature, Incident)
- `ticket_kpi`: durée résolution, nombre de transitions, SLA respecté
- `agent_suggestion`: pour agent IA (recommandations, transitions)

---

## 🔗 Relations en graphe

- `ticket->transitioned_to->ticket_status`: suivi des changements de statut
- `ticket->assigned_to->user`: attribution des tickets aux utilisateurs

---

## ⚙️ Événements automatiques

```surrealql
-- Génération du fullName à partir du ticketSeq et du subject
DEFINE EVENT ticket_fullname ON TABLE ticket WHEN ...

-- Marque un ticket comme hors-SLA si la deadline est dépassée
DEFINE EVENT check_sla ON TABLE ticket WHEN ...

-- Trace une transition de statut dans le graphe
DEFINE EVENT track_transition ON TABLE ticket WHEN ...
```

---

## 🧠 Support IA

- `agent_suggestion` stocke les recommandations de transition ou d'action
- Exploitable via un assistant IA pour proposer, classer, assigner les tickets

---

## 🧪 Exemples de requêtes

### 1. Tous les tickets en retard de SLA

```sql
SELECT * FROM ticket WHERE deadlineDateT < time::now() AND isSlaCompleted = false;
```

### 2. Historique complet d’un ticket

```sql
SELECT out.name, changedAt, comment FROM ticket:<id>->transitioned_to->ticket_status;
```

### 3. Suggestions IA pour un ticket

```sql
SELECT * FROM agent_suggestion WHERE ticket = ticket:<id> ORDER BY score DESC;
```

---

## 🔐 Permissions (à définir)

- Lecture des tickets par rôle `agent`, `manager`
- Écriture uniquement si responsable ou utilisateur assigné
- Historique de transition tracé automatiquement

---

## 🚧 À venir (roadmap)

- `ticket_rule` (transitions conditionnelles)
- `ticket_activity_log` (audit complet)
- Dashboard KPI généré
- Suggestions IA exécutables automatiquement (actions agents)