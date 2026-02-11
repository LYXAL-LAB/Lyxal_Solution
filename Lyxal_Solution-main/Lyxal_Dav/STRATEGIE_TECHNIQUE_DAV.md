# Stratégie Technique & Roadmap CTO : Module Lyxal DAV

**Version :** 1.0.0  
**Date :** 08 Décembre 2025  
**Cible :** Intégration Native SurrealDB (Rust)  
**Contexte :** Pivot stratégique "Lyxal Smart Data Platform"

> Décision CTO (2025-12) : iCal / CalDAV = Rust only.  
> Toute logique iCal en TypeScript est gelée/abandonnée. La source de vérité sera le crate Rust `lyxal_ical_core`, consommé par Surreal (fonctions natives) et par Lyxal_Dav. Le contenu ci-dessous reste pour contexte historique, mais la pile cible est 100 % Rust/Surreal.

---

## 1. Executive Summary : Le Changement de Paradigme

Le standard actuel du marché pour CalDAV/CardDAV (ex: Apple Calendar Server, SabreDAV, Radicale) repose sur une architecture 3-tiers classique : `Serveur HTTP <=> Logique Métier (PHP/Python/JS) <=> Base de Données`.

**Lyxal rompt ce modèle.**

Nous basculons vers une architecture **Embedded Database Extension**. La logique DAV n'est plus une application *au-dessus* de la base, elle devient une **primitive de la base**.

### Pourquoi ? (Avantages Concurrentiels "Unfair Advantages")

| KPI | Standard du Marché | Lyxal DAV Native | Gain Client |
| :--- | :--- | :--- | :--- |
| **Latence de Synchro** | 100~500ms (Allers-retours réseau) | **< 5ms** (Zero-Copy RAM) | Expérience mobile instantanée ("Snappy"). |
| **Cohérence** | Risque de Race Conditions (Locking complexe) | **ACID Natif** (MVCC SurrealDB) | Fiabilité bancaire sur les agendas partagés. |
| **Infrastructure** | Lourde (Node.js + Redis + SQL) | **Single Binary** (30MB) | TCO (Total Cost of Ownership) divisé par 10. |
| **Scalabilité** | Limitée par le CPU du Middleware | **Lineaire** (Sharding SurrealDB) | Capacité de millions d'événements sans latence. |

---

## 2. Stack Technique & Choix d'Architecture

### A. Le "Rust Native Crate"
Le cœur du module ne sera pas un serveur, mais une librairie Rust (`crates/dav`) compilée statiquement dans le binaire SurrealDB.

*   **Langage :** Rust (Edition 2021)
*   **Parsing XML :** `roxmltree` (ou `quick-xml`) pour une tolérance zéro-allocation.
*   **Standard iCal :** Implémentation custom `ical.rs` (déjà prototypée) pour mapper directement `Surreal Value` <-> `RFC 5545`.
*   **Sécurité :** Utilisation directe du subsysteme d'authentification `kvs::ds` de Surreal. Pas de couche d'auth re-implémentée.

### B. "Data-First" Design
Au lieu de parser un fichier ICS à chaque lecture, les données sont stockées sous forme **décomposée et indexée** (Objets Surreal), et le format ICS/XML est généré à la volée ("Lazy Generation") uniquement lors de l'export.

*   `DTSTART/DTEND` : Indexés nativement (Range Queries rapides).
*   `RRULE` : pré-calculée ou expansée à la demande via les fonctions natives.

---

## 3. Plan d'Implémentation Industrielle

### Phase 1 : Fondations & Nettoyage (Semaine 1)
L'objectif est de préparer le terrain pour le code Rust en éliminant la dette technique Node.js.

*   **Action 1.1 :** "Freeze" du code TypeScript actuel. Il sert uniquement de référence.
*   **Action 1.2 :** Initialisation du crate `crates/dav` dans le mono-repo SurrealDB.
*   **Action 1.3 :** Implémentation des tests unitaires Rust pour le parsing XML (WebDAV verbs: `PROPFIND`, `REPORT`).

### Phase 2 : Le Moteur "Read-Only" (Semaine 2)
Permettre la lecture des calendriers (c'est 90% du trafic).

*   **Action 2.1 :** Création de la fonction SurQL `dav::propfind($xml_body, $context)`.
*   **Action 2.2 :** Implémentation de la génération XML récursive.
*   **Action 2.3 :** Mapping des tables existantes (`calendar_objects`) vers le format de réponse DAV.
*   **Tech Check :** Benchmark de performance (Rust vs Node.js) sur une liste de 1000 événements.

### Phase 3 : Le Moteur "Write" & Logique Métier (Semaine 3-4)
C'est la partie critique pour les écritures (PUT, DELETE).

*   **Action 3.1 :** Gestion des ETags (`GetCTag`) avec le système de versionning de SurrealDB (`VERSION` ou `CHANGE FEED`).
*   **Action 3.2 :** Implémentation du parsing iCal entrant (`ical::parse`) pour éclater les données dans les tables.
*   **Action 3.3 :** Gestion des conflits (412 Precondition Failed) nativement.

### Phase 4 : Remplacement & Déploiement (Semaine 5)
Bascule finale ("The Switch").

*   **Action 4.1 :** **Suppression Totale de Node.js.** Le serveur `Lyxal_Dav` est retiré du stack de déploiement. SurrealDB écoute directement le trafic CalDAV (Port 8000).
*   **Action 4.2 :** Tests d'intégration avec clients réels (iOS, macOS, Thunderbird).

### 3.5 L'Innovation Majeure : Le Statement `DEFINE DAV`

Au lieu d'utiliser une API générique (`DEFINE API`), nous introduirons un nouveau statement SQL natif pour faire du protocole DAV un citoyen de première classe.

**Pourquoi ?**
*   **Validation Stricte :** Le parser SQL vérifiera la configuration DAV (Types, Tables liées).
*   **Routing Automatique :** Gère nativement les verbes exotiques `PROPFIND`, `REPORT`, `MKCALENDAR`.

**Syntaxe Cible :**
```sql
DEFINE DAV "/calendars"
    TYPE CALDAV
    FOR TABLE calendar_objects
    PERMISSIONS FULL
    CONFIG {
        "sync_window": "30d",
        "auto_provision": true
    }
    COMMENT "Point d'entrée natif pour iOS/macOS";
```
Cette approche fait de SurrealDB le premier moteur de base de données "DAV-Native" au monde.

### 3.6 Zéro-Touch Provisioning (Data-Driven)

Pour répondre au besoin d'automatisation sans exposer de SQL aux utilisateurs finaux, l'architecture repose sur le **Binding Dynamique**.

*   **Configuration Admin (Once) :** Le `DEFINE DAV` est exécuté une seule fois par le DevOps lors de l'installation.
*   **Action Utilisateur (Runtime) :** L'application métier crée simplement une donnée.
    *   Ex: `CREATE calendar:projet_x SET name = "Projet X", owner = user:me;`
*   **Réaction Native :** Le module DAV détecte ce record et "monte" automatiquement l'URL : `https://api.lyxal/dav/user:me/projet_x`.
*   **Bénéfice :** L'approvisionnement DAV devient implicite. Ajouter une ligne dans la BDD suffit à créer le service protocolaire associé. Aucune API de gestion d'infrastructure n'est nécessaire.

### 3.7 Interaction Client Lambda (Architecture "Unified Backend")

Pour l'utilisateur final (qui ne connaît pas SQL), l'architecture permet une interaction directe et transparente depuis l'application front-end (Web/Mobile/IA).

**Workflow "Création d'Agenda" :**
1.  **Interface Utilisateur :** L'utilisateur clique sur *[ + Créer Agenda "Projet A" ]*.
2.  **Front-End (SDK Surreal) :** L'application envoie une requête WebSocket directe :
    ```javascript
    await db.create('calendar', {
        title: "Projet A",
        type: "DAV_CALENDAR"
    });
    ```
3.  **SurrealDB (Interne) :** Le module DAV intercepte cette création et active instantanément les endpoints protocolaires.
4.  **Résultat :** L'agenda est immédiatement accessible pour les clients CalDAV.

**Conséquence :** Le middleware Node.js disparait totalement. L'application cliente (Front) communique en direct avec le moteur (Back), simplifiant drastiquement la stack.

---

## 4. Règles d'Or pour l'Équipe (Guidelines)

1.  **Allocation Memoire :** On chasse les `.clone()`. Dans une DB, copier la mémoire est un péché mortel. Utiliser des références (`&str`) partout où c'est possible.
2.  **Thread Safety :** Aucune opération bloquante sur le thread `async`. Si le parsing XML prend > 50µs, il part dans un `spawn_blocking`.
3.  **Erreurs :** Pas de `unwrap()`. Toutes les erreurs doivent être typées (`dav::error::Error`) et mappées vers des codes HTTP DAV corrects (404, 403, 409, 507).
4.  **Dépendances :** Minimalisme absolu. Chaque crate ajouté doit être justifié devant le CTO.

---

## 5. Conclusion

Cette roadmap n'est pas une simple refonte, c'est un **upgrade infrastructurel**. Elle positionne Lyxal non plus comme un "logiciel utilisant SurrealDB", mais comme la **référence d'utilisation avancée** de la plateforme, potentiellement commercialisable comme *plugin SurrealDB* autonome à l'avenir.

**Go for launch.**
