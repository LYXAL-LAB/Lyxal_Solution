# Lyxal Studio : La Transformation de Surrealist en OS Métier
## Stratégie d'Interface Unifiée "Single Pane of Glass"

**Date :** 08 Décembre 2025  
**Projet :** Lyxal Studio (Fork Surrealist)  
**Vision :** Une interface unique pour gérer la Donnée, le Document et le Métier.

---

### 1. Le Concept : "The Business OS"

Nous ne construisons pas juste un "Admin Panel". Nous transformons **Surrealist** (qui est un excellent client SQL) en **Lyxal Studio**, un véritable système d'exploitation métier pour l'entreprise.

L'utilisateur ne doit jamais sortir de cette interface. Il y gère ses données (BDD), ses documents (PDF), ses relations clients (CRM) et ses fichiers (Media).

---

### 2. Architecture Modulaire du Frontend

Pour ne pas transformer Surrealist en "usine à gaz", nous devons adopter une architecture de **Modules Métiers** (Business Modules) qui s'injectent dans le Core de Surrealist.

#### Core (Existant - Surrealist)
*   Gestion de connexion / Auth
*   Explorateur de Données (Data Explorer)
*   Console SQL
*   Designer de Schéma

#### Module 1 : Lyxal Designer (PDF Engine)
*   **Rôle :** Éditeur WYSIWYG de templates PDF.
*   **Tech :** Moteur de rendu Lyxal compilé en **WASM**.
*   **Intégration :**
    *   Onglet dédié "Documents".
    *   Split-view : Template à gauche / Données JSON (live de la BDD) à droite.
    *   Bouton "Print" qui appelle le moteur Rust du serveur ou le moteur WASM local.

#### Module 2 : Lyxal CRM (Relation Client)
*   **Rôle :** Vues métiers sur les données (Kanban, Listes, Fiches).
*   **Tech :** Composants React purs qui requêtent SurrealDB via Live Queries.
*   **Intégration :**
    *   Abstraction des tables SQL brutes (`SELECT * FROM lead`) en vues UI (`Kanban des Leads`).
    *   Pas de backend spécifique : le backend EST la base de données.

#### Module 3 : Lyxal Media (DAM - Digital Asset Management)
*   **Rôle :** Gestionnaire de fichiers (Images, Vidéos, Assets).
*   **Tech :** Upload direct vers SurrealKV (Blob Storage).
*   **Intégration :**
    *   Gallerie média avec prévisualisation.
    *   Drag & Drop pour insérer une image dans un Template PDF (Lien direct entre Module Media et Module PDF).

---

### 3. Avantages de l'Intégration Totale

#### A. Le Cercle Vertueux de la Donnée
1.  J'ajoute un contact dans le **Module CRM**.
2.  J'upload son logo dans le **Module Media**.
3.  Je génère son contrat PDF dans le **Module Document** (qui utilise le contact et le logo).
4.  Tout se passe dans la même fenêtre, avec la même session utilisateur, sans jamais changer d'outil.

#### B. Performance & Sécurité
*   Puisque Lyxal Studio est connecté directement au Socket de SurrealDB, chaque action est **temps réel**.
*   Si je modifie le modèle de facture dans le Module Document, le commercial dans le Module CRM voit la mise à jour instantanément.

---

### 4. Roadmap Technique (Surrealist Fork)

1.  **Nettoyage :** Retirer les fonctionnalités de Surrealist trop "DevOps" (ex: Designer de topologie cluster) pour simplifier l'UI pour un usage métier.
2.  **Injection WASM :** Intégrer le binaire `lyxal_engine.wasm` dans le build process de l'application React.
3.  **Création du "Module Loader" :** Un système pour charger dynamiquement les vues (CRM, PDF, Media) en fonction des permissions de l'utilisateur.
4.  **UX Unifiée :** Créer un Design System commun pour que l'éditeur de PDF ressemble au CRM (cohérence visuelle).

---

### 5. Conclusion

**Lyxal Studio** devient le visage de votre technologie.
*   Sous le capot : La puissance brute de **SurrealDB + Rust**.
*   En surface : L'élégance et la simplicité de **Surrealist + Modules Métiers**.

C'est une proposition de valeur massive : "Installez un seul exécutable, et vous avez tout votre SI (Système d'Information) opérationnel."

