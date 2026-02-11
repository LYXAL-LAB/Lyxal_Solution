# Stratégie d'Intégration Native Lyxal x SurrealDB
## Vision Architecturale et Avantages Concurrentiels

**Date :** 08 Décembre 2025  
**Projet :** Lyxal Solution  
**Cible :** Intégration Native dans le Moteur SurrealDB (Rust)

---

### 1. Synthèse de la Vision : "The Smart Data Platform"

L'objectif est de pivoter d'une architecture classique (Application + BDD) vers une architecture **unifiée**. Lyxal ne sera plus une "application" qui utilise SurrealDB, mais deviendra un **module natif** intégré au cœur même du moteur de base de données.

Cette approche transforme Lyxal en une **plateforme de données intelligente** capable de générer, transformer et servir des documents (PDF, Rapports) de manière atomique, transactionnelle et ultra-performante, le tout distribué sous la forme d'un binaire unique.

---

### 2. Avantages Concurrentiels Majeurs

Cette architecture offre des différenciateurs drastiques par rapport aux solutions CRM/GED classiques (Salesforce, Odoo, Micro-services) :

| Avantage | Description | Impact Client |
| :--- | :--- | :--- |
| **Data Gravity (Vitesse)** | Les données et le moteur PDF partagent la même mémoire RAM. Pas d'appels réseau, pas de sérialisation JSON coûteuse. | Génération de documents quasi-instantanée (>1000/sec). |
| **Déploiement Atomique** | **Single Binary Deployment**. Un seul exécutable contient la BDD, l'API, la Sécurité et le Moteur PDF. | Installation "Zero-Config" pour les clients On-Premise. Maintenance triviale. |
| **Cohérence Absolue** | La génération de document peut s'effectuer DANS une transaction BDD (`BEGIN` ... `COMMIT`). | Garantie légale et financière : pas de document orphelin ou de données incohérentes. |
| **Sécurité (Air Gap)** | Les données sensibles ne sortent jamais du processus BDD pour aller vers un serveur tiers. | Conformité maximale (GDPR, Santé, Banque). |
| **Live Queries** | Intégration native avec les WebSockets de SurrealDB. | Le client reçoit le PDF en temps réel dès sa création, sans polling. |

---

### 3. Architecture Technique Cible

#### A. Structure du Projet (Workspace Rust)
Nous devons adopter le modèle modulaire de SurrealDB (similaire à `SurrealML`), et non le modèle de script simple (`ical.rs`).

```text
surrealdb/
├── Cargo.toml          (Workspace Root)
├── crates/
│   ├── core/           (Moteur BDD existant)
│   │   ├── Cargo.toml
│   │   └── src/fnc/    (Pont d'appel vers Lyxal)
│   └── lyxal/          (NOUVEAU CRATE : Moteur Lyxal)
│       ├── Cargo.toml
│       └── src/        (Logique PDF pure, sans dépendance BDD)
```

#### B. Stratégie d'Exécution (Safety First)
Pour éviter de bloquer le moteur de base de données lors d'une génération PDF lourde, nous utiliserons strictement le **Thread Offloading**.

*   **Règle d'Or :** Aucun calcul > 1ms sur le thread principal (Tokio Runtime).
*   **Implémentation :** Utilisation systématique de `tokio::task::spawn_blocking`.
*   **Résilience :** Encapsulation dans `std::panic::catch_unwind` pour qu'un crash du moteur PDF ne fasse jamais crasher la base de données.

#### C. Intégration SurQL (Langage de Requête)
Lyxal exposera ses fonctions directement dans le langage SQL de Surreal :

```sql
-- Exemple d'usage natif futur
UPDATE transaction:123 
SET 
    status = 'PROCESSED',
    invoice_pdf = lyxal::pdf::generate({
        template: 'invoice_v1',
        data: this
    });
```

---

### 4. Plan de Réorientation du Projet Lyxal

Pour passer de l'état actuel (Projet TypeScript/Rust externe) à cette intégration native, voici la roadmap :

#### Phase 1 : Migration du Cœur (Lyxal Core Rust)
*   [ ] Isoler la logique "Métier" de Lyxal (Parsing, Layout, Rendu) dans une librairie Rust pure (`crates/lyxal`).
*   [ ] Supprimer toute dépendance au réseau ou au système de fichiers dans ce cœur (input = données, output = bytes).
*   [ ] Rendre ce module compatible WASM (optionnel mais recommandé pour le futur).

#### Phase 2 : Le Pont (Bridge)
*   [ ] Créer le module `crates/core/src/fnc/lyxal.rs`.
*   [ ] Implémenter la conversion des types : `surrealdb::val::Value` <-> `lyxal::Document`.
*   [ ] Implémenter le `spawn_blocking` pour l'exécution asynchrone sécurisée.

#### Phase 3 : L'Intégration Workspace
*   [ ] Ajouter `lyxal` comme dépendance optionnelle dans `Cargo.toml` (Feature Flag `lyxal`).
*   [ ] Compiler un binaire `surreal` personnalisé incluant Lyxal.

#### Phase 4 : Industrialisation
*   [ ] Tests de charge : Vérifier que générer 100 PDF ne ralentit pas les requêtes `SELECT` simples des autres utilisateurs.
*   [ ] Création de templates stockés directement en base (dans une table `lyxal_templates`).

---

### 5. Conclusion

Cette réorientation positionne Lyxal non plus comme un "logiciel de plus", mais comme une **extension infrastructurelle**. C'est un pari technique ambitieux (Rust, Asynchronisme, Low-level) mais qui offre une barrière à l'entrée quasi-infranchissable pour la concurrence et une valeur immense pour les clients cherchant performance et simplicité.

