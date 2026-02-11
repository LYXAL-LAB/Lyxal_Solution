# 📍 FICHE MODULE : `lyxalhelpdesk`

```
MODULE: lyxalhelpdesk
FONCTION: Gestion complète des tickets clients, SLA, workflow, attribution dynamique
VERSION ACTUELLE: structure XML Axelor basique
VERSION VISEE: module SaaS enrichi, compatible IA (agents), stateless + multi-tenant SurrealDB
```

---

## 1. 🔍 ÉTAT DES LIEUX ACTUEL

### 📦 Entités disponibles :
- `Ticket`
- `Sla`
- `TicketType`
- `TicketStatus`
- `AppHelpdesk`
- `Project`
- `Sequence`

### ❌ Limites structurelles :
| Problème | Impact |
|---------|--------|
| Pas de moteur de transitions | Blocage pour l’automatisation ou IA |
| SLA non calculé automatiquement | Pas d’alerte ni de suivi réel |
| Aucune trace d’historique | Impossible de traquer les actions ou l’évolution |
| Pas de graphe de relations (user, client, statut, etc.) | Pas d’analyse avancée ou de requête intelligente |
| Pas de machine d’état ou moteur de règles | IA ne peut pas interagir intelligemment avec le ticket |
| Aucune structuration pour agents IA | L’agent ne sait ni ce qu’il peut faire ni quand agir |
| Pas de priorité dynamique ou planification | Impossible de classer automatiquement les urgences |

---

## 2. 🚀 VERSION CIBLE

### 🧠 Cible : **LYXALHELPDESK** = SaaS helpdesk intelligent + IA-native

### 📌 Objectifs :

| Domaine          | Fonctionnalité visée |
|------------------|----------------------|
| 🎫 Tickets        | Création + suivi + clôture avec SLA |
| 🕒 SLA            | Triggers automatiques, temps restants, indicateurs |
| 🔄 Statuts        | Machine d'état complète (ex: New → In Progress → Closed) |
| 📈 KPI            | Suivi SLA, durée, résolution, % respect SLA |
| 👥 Attribution    | Logique dynamique : file d’attente, par compétence, round robin |
| 🧠 Agents IA      | API claire pour : lire, proposer action, mettre à jour, notifier |
| 📬 Email-to-ticket | Endpoint Surreal / webhook pour ouvrir un ticket depuis un email |
| 🌍 Portail Client | CRUD ticket en public (REST ou via mini frontend intégré) |
| 🔔 Notification   | Intégrée via `notification_configuration` SurrealDB |
| 🔎 Recherche avancée | Statut, priorités, filtres par client, date, etc. |
| 📊 Dashboard      | Requêtes prêtes pour agents IA ou UI : SLA en cours, urgences, etc. |

---

## 3. 📂 FICHIERS À PRODUIRE

### ✅ Structure SurrealDB (fichiers `.srql` comme `lyxalgdpr`)

| Fichier                        | Fonction |
|-------------------------------|----------|
| `schema.srql`                 | Définition complète des tables + index |
| `referenceData.srql`          | Statuts par défaut, types de tickets, niveaux de priorité |
| `initHelpdeskDatabase.ts`     | Initialisation pour SDK `lyxal-surreal` |
| `surreal.md`                  | Documentation complète pour l’IA et l’équipe |
| *(optionnel)* `rules.srql`    | Moteur de transition de statuts / SLA automatisés |
| *(optionnel)* `kpi.srql`      | Table et logique de suivi SLA, durées moyennes, etc. |

---

## 🔄 ÉTAPES À SUIVRE (ROADMAP DEV)

| Étape | Description |
|-------|-------------|
| ✅ Étape 1 | Analyse structure Axelor (fini) |
| 🔄 Étape 2 | Génération des fichiers `.srql` (schema, ref, règles) |
| ⏳ Étape 3 | Ajout du moteur de transition statuts + trigger SLA |
| ⏳ Étape 4 | Ajout de tables graphe : historique, transitions, actions IA |
| ⏳ Étape 5 | Écriture des queries IA-friendly (analyse de priorités, résolution auto) |
| ⏳ Étape 6 | Rendu API (endpoint REST, client ou portail) |
| ⏳ Étape 7 | Requête front pour dashboard / page tickets (prête pour UI générative) |


📂 Structure du module

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
