# 🗺️ Feuille de Route Transversale — Intégration LYXAL SPACE

> **Périmètre :** Intégration des modules [`lyxal_catalogue`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue) et [`lyxal_pipeline_ingestion`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_pipeline_ingestion) dans l'interface unifiée **LYXAL SPACE**.  
> **Référence d'architecture :** [`.agents/AGENTS.md`](file:///c:/Users/HP/Desktop/Lyxal_OS/.agents/AGENTS.md) & [`LYXAL_ARCHITECTURE.md`](file:///c:/Users/HP/Desktop/Lyxal_OS/LYXAL_ARCHITECTURE.md).  
> **Principe fondamental :** Cette feuille de route est transversale et commune aux deux modules. Elle est **découplée de leurs cycles de versions backend** et s'appuie exclusivement sur les contrats d'API publics existants et le serveur hôte officiel [`apps/lyxal-server`](file:///c:/Users/HP/Desktop/Lyxal_OS/apps/lyxal-server).

---

## 🏗️ Architecture & Règles d'Intégration Inviolables

1. **Aucun composant d'infrastructure parallèle :**
   - Interdiction formelle de créer un serveur HTTP, un proxy Node.js ou une couche backend ad-hoc pour l'UI.
   - Tout le trafic transite exclusivement par le binaire officiel [`apps/lyxal-server`](file:///c:/Users/HP/Desktop/Lyxal_OS/apps/lyxal-server) (Axum Handlers).
2. **Pas d'authentification parallèle :**
   - L'interface utilise les Record Users SurrealDB et les sessions sécurisées (`ingestion_session`, `auth`).
   - Respect strict des 4 rôles spécialisés : `ingestion_agent`, `qualification_agent`, `steward_admin` et `catalogue_sync_agent`.
3. **Réutilisation stricte des contrats SurrealQL :**
   - L'interface ne réimplémente aucune règle métier.
   - Les actions graphiques appellent les fonctions publiques `fn::catalogue_*` et `fn::ingestion_*`.
4. **Zéro logique métier dans l'UI :**
   - L'interface LYXAL SPACE est une vue purement déclarative, réactive et ergonomique.

---

## 📌 Les 4 Étapes d'Intégration

### 🎨 Étape A — Interfaces Utilisateur (`PLANNED` 📋)
**Objectif :** Fournir aux utilisateurs (exploitants, agents d'ingestion et Data Stewards) des écrans ergonomiques et unifiés au sein de LYXAL SPACE.

- **Catalogue Universel :**
  - Consultation arborescente de la taxonomie des catégories.
  - Fiche détaillée de l'article avec unités de base, conditionnements, attributs statiques et différentiateurs.
  - Visualisation de la matrice des variantes avec empreinte SHA-256.
  - Explorateur graphique de composition des ouvrages composés et détection de cycle.
- **Supervision du Pipeline d'Ingestion :**
  - Tableau de bord en temps réel alimenté par `fn::ingestion_dashboard_metrics` (taux de qualification, temps moyen, répartition par format).
  - Écran d'import et de suivi des lots (chargement de fichiers bruts, progression du curseur de traitement).
- **Poste de Pilotage Data Steward :**
  - Console de gestion de la quarantaine (`fn::ingestion_quarantine_list`) avec affichage des codes d'erreurs normalisés.
  - Modal d'arbitrage forçant la justification technique ($\ge 15$ caractères) lors de la résolution vers `TO_CONFIRM` (`fn::ingestion_quarantine_resolve`).
  - Table de requalification des articles en staging (`fn::ingestion_staged_list`, `fn::ingestion_staged_requalify`) avec attachement et visualisation des pièces justificatives.
  - Visualisation et approbation formelle des manifestes scellés par BLAKE3 (`fn::ingestion_manifest_approve`).
- **Gestion des Autorisations :**
  - Adaptation dynamique de l'interface et masquage des actions selon le rôle actif du jeton.

---

### 🔌 Étape B — Raccordement & Contrats API (`PLANNED` 📋)
**Objectif :** Connecter les composants graphiques aux points d'entrée du serveur hôte officiel sans régression.

- **Points d'Entrée HTTP Axum :**
  - Vérification et exposition des routes nécessaires dans [`apps/lyxal-server`](file:///c:/Users/HP/Desktop/Lyxal_OS/apps/lyxal-server) :
    - `/api/v1/ingestion/batches`
    - `/api/v1/ingestion/staged`
    - `/api/v1/ingestion/quarantine`
    - `/api/v1/ingestion/manifests`
    - `/api/v1/catalogue/items`
    - `/api/v1/catalogue/categories`
- **Contrats Typés :**
  - Sérialisation et désérialisation JSON conformes aux enveloppes `fn::result_ok` et `fn::error_result`.
- **Gestion Unifiée des Erreurs :**
  - Traduction automatique et affichage des messages d'erreur enrichis avec résolution suggérée (`error_definition`).

---

### 🧪 Étape C — Recette Industrielle & Parcours Utilisateurs (`PLANNED` 📋)
**Objectif :** Valider l'intégrité de bout en bout de l'expérience utilisateur et de la sécurité.

- **Scénarios Bout-en-Bout :**
  - *Scénario 1 :* Réception d'un catalogue brut $\rightarrow$ Parsing $\rightarrow$ Normalisation $\rightarrow$ Détection d'anomalie GTIN $\rightarrow$ Quarantaine $\rightarrow$ Arbitrage Data Steward $\rightarrow$ Publication.
  - *Scénario 2 :* Tentative d'approbation d'un manifeste par un rôle non habilité $\rightarrow$ Rejet immédiat avec message d'erreur `INGESTION_UNAUTHORIZED_APPROVER`.
  - *Scénario 3 :* Modification post-scellement $\rightarrow$ Détection d'altération BLAKE3 $\rightarrow$ Blocage de publication `INGESTION_SEAL_VERIFICATION_FAILED`.
- **Tests de Charge & Ergonomie :**
  - Fluidité du défilement virtuel sur les listes de plusieurs milliers d'articles en staging.
  - Validation du responsive design et des retours d'état asynchrones (toasts, barres de progression).

---

### 🔒 Étape D — Préparation à la Production (`PLANNED` 📋)
**Objectif :** Répondre à l'ensemble des exigences de gouvernance CTO avant tout passage en production réelle.

- **Vérification Documentaire :**
  - Remplacement obligatoire de tous les tokens et références de simulation (`PROOF-AUTH-2026-*`, `SYNTH-*`) par des justificatifs authentifiés physiquement auprès des fabricants.
- **Sécurité & Secrets :**
  - Clés d'administration Staging et Production scellées dans le coffre-fort de secrets.
  - Politique de rotation périodique des clés de chiffrement et d'authentification.
- **Exploitation & Continuité :**
  - Procédures documentées de sauvegarde à chaud et restauration de la base SurrealDB.
  - Métriques de santé exposées sur `/health` et alertes via `lyxal_event`.
- **Gouvernance :**
  - **Autorisation formelle et explicite du CTO** requise avant tout branchement sur le Master Catalogue de production.

---

## 🔗 Références & Documentation Associée
- Charte d'architecture Lyxal OS : [`LYXAL_ARCHITECTURE.md`](file:///c:/Users/HP/Desktop/Lyxal_OS/LYXAL_ARCHITECTURE.md)
- Audit architectural des tables relationnelles SurrealDB : [`docs/architecture/AUDIT_SURREALDB_RELATION_TABLES.md`](file:///c:/Users/HP/Desktop/Lyxal_OS/docs/architecture/AUDIT_SURREALDB_RELATION_TABLES.md)
- Roadmap Master Catalogue : [`crates/lyxal_catalogue/ROADMAP.md`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/ROADMAP.md)
- Roadmap Pipeline Ingestion : [`crates/lyxal_pipeline_ingestion/ROADMAP.md`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_pipeline_ingestion/ROADMAP.md)
- Serveur hôte officiel : [`apps/lyxal-server/README.md`](file:///c:/Users/HP/Desktop/Lyxal_OS/apps/lyxal-server/)
